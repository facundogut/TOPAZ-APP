execute('
ALTER PROCEDURE [dbo].[PA_REC_VAL_DEBITOSAUTOMATICOS]

--CAMBIOS 14/01/22 - AE - NBCHSEG-2162 - Se agregó que las cuentas bloqueada y Stop Debit queden con estado V


@ID_CABEZAL NUMERIC(15),
@P_RET_PROCESO float(53)  OUTPUT,
@P_MSG_PROCESO varchar(max)  OUTPUT
AS
   
    BEGIN
    DECLARE @tabla_cuentas_detalles TABLE (id_linea NUMERIC(15), cuenta NUMERIC(12), cancelada VARCHAR(1), ctrl_stopd NUMERIC(12),bloqueada VARCHAR(1),jts_oid NUMERIC(10));
    DECLARE @cantidad_sin_cuenta NUMERIC(15);
    DECLARE @cantidad_cuentas_cerradas NUMERIC(15);
    DECLARE @cantidad_validas NUMERIC(15);
	DECLARE @cantidad_stoped NUMERIC(15);
	DECLARE @cantidad_bloqueadas NUMERIC(15);
    DECLARE @id_tipo NUMERIC(1);
	DECLARE @estado_convenio VARCHAR(1);
    DECLARE @fecha_proceso DATETIME;
    -- INST VAR
    SET @P_RET_PROCESO = NULL
    SET @P_MSG_PROCESO = NULL
    SELECT @id_tipo = a.Id_TpoConv, @estado_convenio = a.Estado 
	FROM CONV_CONVENIOS_REC a WITH (NOLOCK)
	LEFT JOIN REC_CAB_DEBITOSAUTOMATICOS b WITH (NOLOCK) ON 
											a.Id_ConvRec = b.CONVENIO
	WHERE b.ID = @ID_CABEZAL
	
	SELECT @fecha_proceso = FECHAPROCESO FROM PARAMETROS WITH (NOLOCK)
	
    --TODOS LOS DETALLES Y SI TIENE CUENTA ENTONCES
    INSERT INTO @tabla_cuentas_detalles ( id_linea, cuenta, cancelada, ctrl_stopd,bloqueada,jts_oid) 
    SELECT b.ID_LINEA, a.CUENTA, a.C1651, sd.Adh_Cliente, a.C1679,a.jts_oid
    FROM SALDOS a WITH (NOLOCK)
    JOIN REC_DET_DEBITOSAUTOMATICOS b WITH (NOLOCK)
			ON a.JTS_OID = b.JTS_DEBITO 
				AND b.TZ_LOCK = 0 
				AND a.TZ_LOCK = 0
				AND b.ESTADO = ''I'' --VER EL TEMA DE ACA TAMBIEN FILTRAR LOS TIPOS DE PRODUCTOS
	JOIN REC_CAB_DEBITOSAUTOMATICOS c WITH (NOLOCK)
			ON c.ID = b.ID_CABEZAL 
				AND c.TZ_LOCK = 0
	JOIN CONV_CONVENIOS_REC d WITH (NOLOCK)ON d.Id_ConvRec = c.CONVENIO 
											AND d.TZ_LOCK = 0 
											AND d.Estado = ''A'' 
											AND d.Id_TpoConv = 2
	LEFT JOIN SNP_STOP_DEBIT sd WITH (NOLOCK)ON sd.ID_Convenio = c.CONVENIO 
												AND sd.Adh_Cliente = a.C1803 
												AND sd.TZ_LOCK=0 
												AND sd.SD_Fec_Desde <= @fecha_proceso 
												AND @fecha_proceso< sd.SD_Fec_Hasta 
												AND sd.Stop_DD = ''N'' 
												AND sd.SD_Estado = ''AC''
    WHERE b.ID_CABEZAL = @ID_CABEZAL 
		 

    BEGIN TRANSACTION

        BEGIN TRY
		IF @id_tipo = 2 AND @estado_convenio = ''A''
		BEGIN
            --UPDATE VALIDAS
            UPDATE det
            SET
            det.ESTADO = ''V'',
            det.DETALLE_ESTADO = ''Validado''
            FROM @tabla_cuentas_detalles a 
			JOIN  REC_DET_DEBITOSAUTOMATICOS det WITH (NOLOCK) ON a.id_linea = det.ID_LINEA 
            WHERE a.cancelada <> ''1'' 
					AND det.ID_CABEZAL = @ID_CABEZAL 
					AND ctrl_stopd IS NULL
            SET @cantidad_validas = @@ROWCOUNT

            --UPDATE ERROR  (Cuentas canceladas)
            UPDATE det
            SET
            det.ESTADO = ''E'',
            det.DETALLE_ESTADO = ''Cuenta cancelada''
            FROM @tabla_cuentas_detalles a 
			JOIN  REC_DET_DEBITOSAUTOMATICOS det WITH (NOLOCK) ON a.id_linea = det.ID_LINEA
            WHERE a.cancelada = ''1'' 
				AND det.ID_CABEZAL = @ID_CABEZAL 
				AND a.ctrl_stopd IS NULL
				AND det.TZ_LOCK = 0
            SET @cantidad_cuentas_cerradas = @@ROWCOUNT

            --UPDATE ERROR (Cuenta no válida)
            UPDATE det
            SET
            det.ESTADO = ''E'',
            det.DETALLE_ESTADO = ''Cuenta no válida''
            FROM @tabla_cuentas_detalles a 
			RIGHT JOIN REC_DET_DEBITOSAUTOMATICOS det WITH (NOLOCK) ON a.id_linea = det.ID_LINEA
            WHERE det.ID_CABEZAL = @ID_CABEZAL 
					AND a.cuenta IS NULL 
					AND a.ctrl_stopd IS NULL
                    AND a.bloqueada = ''0''
                    AND det.TZ_LOCK = 0
            SET @cantidad_sin_cuenta = @@ROWCOUNT

            --UPDATE ERROR Cuenta Bloqueada (Cuenta bloqueada)
            UPDATE det
			SET det.ESTADO = ''V'',det.DETALLE_ESTADO = ''Cuenta bloqueada''
			FROM @tabla_cuentas_detalles a 
			JOIN REC_DET_DEBITOSAUTOMATICOS det WITH (NOLOCK) ON a.id_linea = det.ID_LINEA
			JOIN GRL_BLOQUEOS b ON a.jts_oid = b.SALDO_JTS_OID AND b.TZ_LOCK = 0
			WHERE a.bloqueada = ''1'';
            SET @cantidad_bloqueadas = @@ROWCOUNT
			
			--UPDATE ERROR (STOP DEBIT)
            UPDATE det
            SET
            det.ESTADO = ''V'', -- ANTES -''E''-, CAMBIO 13/01/22 - AE - NBCHSEG-2162
            det.DETALLE_ESTADO = ''Rechazo por STOP DEBIT''
            FROM @tabla_cuentas_detalles a 
			RIGHT JOIN REC_DET_DEBITOSAUTOMATICOS det WITH (NOLOCK) ON a.id_linea = det.ID_LINEA AND det.TZ_LOCK = 0
            WHERE det.ID_CABEZAL = @ID_CABEZAL 
					AND a.ctrl_stopd IS NOT NULL 
            SET @cantidad_stoped = @@ROWCOUNT
        
		
        IF @cantidad_validas + @cantidad_sin_cuenta + @cantidad_cuentas_cerradas + @cantidad_stoped + @cantidad_bloqueadas > 0
        BEGIN
	
            IF @cantidad_cuentas_cerradas = 0 AND @cantidad_sin_cuenta = 0 AND @cantidad_stoped = 0 AND @cantidad_bloqueadas = 0
            BEGIN
                UPDATE REC_CAB_DEBITOSAUTOMATICOS
                SET ESTADO = ''V''
                WHERE ID = @ID_CABEZAL
            END
            ELSE
            BEGIN
                IF @cantidad_validas = 0
                BEGIN
                    UPDATE REC_CAB_DEBITOSAUTOMATICOS 
                    SET ESTADO = ''E''
                    WHERE ID = @ID_CABEZAL
                END
                ELSE
                BEGIN  
                    UPDATE REC_CAB_DEBITOSAUTOMATICOS
                    SET ESTADO = ''Z''
                    WHERE ID = @ID_CABEZAL
                END
            END
			SET @P_MSG_PROCESO = CONCAT(''Proceso finalizado correctamente, se procesaron ('',@cantidad_validas + @cantidad_sin_cuenta + @cantidad_cuentas_cerradas + @cantidad_stoped,'') registros, válidos ('',@cantidad_validas,''), con error ('',@cantidad_sin_cuenta + @cantidad_cuentas_cerradas + @cantidad_stoped,'')'')
		END
		
		ELSE
		BEGIN
		UPDATE REC_CAB_DEBITOSAUTOMATICOS 
        SET ESTADO = ''E''
        WHERE ID = @ID_CABEZAL
		SET @P_MSG_PROCESO = CONCAT(''Cabecera ('',@ID_CABEZAL,'') sin detalles, estado ERROR'')
		END
        END
		ELSE
		BEGIN
		UPDATE REC_CAB_DEBITOSAUTOMATICOS 
        SET ESTADO = ''E''
        WHERE ID = @ID_CABEZAL
		
		SET @P_MSG_PROCESO = CONCAT(''Proceso finalizado correctamente, cabezal con convenio inválido, no se procesan detalles, Cabecera ('',@ID_CABEZAL ,'') estado cambia a ERROR'')
		END
		COMMIT TRANSACTION

        SET @P_RET_PROCESO = 1
        
        END TRY
        
        BEGIN CATCH
        SET @P_RET_PROCESO = ERROR_NUMBER()
        SET @P_MSG_PROCESO = ERROR_MESSAGE()
        END CATCH

    END
')