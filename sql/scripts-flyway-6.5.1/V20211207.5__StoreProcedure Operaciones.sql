EXECUTE('
-- Store Procedures
-- ++ DEBITOS AUTOMATICOS ++ --
-- SP_DEBITOSAUTOMATICOS
CREATE  PROCEDURE SP_DEBITOSAUTOMATICOS @NRO_CUENTA NUMERIC(10,0),@TIPO_CUENTA NUMERIC(1,0),@JTS_OID NUMERIC(10,0) OUTPUT,@ERRORS VARCHAR(50) OUTPUT
AS
DECLARE @cant_cuenta NUMERIC(5,0) = 0;

IF @NRO_CUENTA = 0
	BEGIN
		SET @JTS_OID=0;
	END
ELSE
	BEGIN
   	SET @cant_cuenta = (	SELECT count(*) 
							FROM SALDOS  WITH (NOLOCK)
							WHERE CUENTA=@NRO_CUENTA AND MONEDA=1 AND  C1785 = @TIPO_CUENTA 
							AND TZ_LOCK=0);
							
   	IF @cant_cuenta = 0  -- Numero de cuenta inexistente.
   		BEGIN
   			SET @ERRORS = CONCAT(@ERRORS,''NroCuenta Inexistente '');
  		END
  	ELSE 
  		BEGIN
  			SET @JTS_OID = (SELECT JTS_OID 
							FROM SALDOS  WITH (NOLOCK)
							WHERE CUENTA=@NRO_CUENTA AND MONEDA=1 AND  C1785 = @TIPO_CUENTA 
							AND TZ_LOCK=0)
  		END
 	END
')

EXECUTE('
-- PA_REC_VAL_DEBITOSAUTOMATICOS
ALTER PROCEDURE [PA_REC_VAL_DEBITOSAUTOMATICOS]

@ID_CABEZAL NUMERIC(15),
@P_RET_PROCESO float(53)  OUTPUT,
@P_MSG_PROCESO varchar(max)  OUTPUT
AS
   
    BEGIN
    DECLARE @tabla_cuentas_detalles TABLE (id_linea NUMERIC(15), cuenta NUMERIC(12), cancelada VARCHAR(1), ctrl_stopd NUMERIC(12));
    DECLARE @cantidad_sin_cuenta NUMERIC(15);
    DECLARE @cantidad_cuentas_cerradas NUMERIC(15);
    DECLARE @cantidad_validas NUMERIC(15);
	DECLARE @cantidad_stoped NUMERIC(15);
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
    INSERT INTO @tabla_cuentas_detalles ( id_linea, cuenta, cancelada, ctrl_stopd) 
    SELECT b.ID_LINEA, a.CUENTA, a.C1651, sd.Adh_Cliente 
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
            SET @cantidad_sin_cuenta = @@ROWCOUNT
			
			--UPDATE ERROR (STOP DEBIT)
            UPDATE det
            SET
            det.ESTADO = ''E'',
            det.DETALLE_ESTADO = ''Rechazo por STOP DEBIT''
            FROM @tabla_cuentas_detalles a 
			RIGHT JOIN REC_DET_DEBITOSAUTOMATICOS det WITH (NOLOCK) ON a.id_linea = det.ID_LINEA
            WHERE det.ID_CABEZAL = @ID_CABEZAL 
					AND a.ctrl_stopd IS NOT NULL 
            SET @cantidad_stoped = @@ROWCOUNT
        
		
        IF @cantidad_validas + @cantidad_sin_cuenta + @cantidad_cuentas_cerradas + @cantidad_stoped > 0
        BEGIN
	
            IF @cantidad_cuentas_cerradas = 0 AND @cantidad_sin_cuenta = 0 AND @cantidad_stoped = 0
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

EXECUTE('
-- PA_LIQ_CONV_DEB_AUTOMATICO
ALTER PROCEDURE PA_LIQ_CONV_DEB_AUTOMATICO
   @P_ID_PROCESO  float(53),
   @P_DT_PROCESO  datetime2(0),
   @P_CLAVE       varchar(max),
   @P_SUCURSAL    float(53),
   @P_NROMAQUINA  float(53),
   @P_RET_PROCESO float(53)  OUTPUT,
   @P_MSG_PROCESO varchar(max)  OUTPUT
   
AS 

   BEGIN

      SET @P_RET_PROCESO = NULL
      SET @P_MSG_PROCESO = NULL
      
      DECLARE

         @ID NUMERIC(15),
         @FECHA DATETIME,
         @SUMA_IMPORTE NUMERIC(15,2),
         @CANTIDAD_LIQ NUMERIC(10),
         @CANT NUMERIC(5),
         @ARCHIVO VARCHAR(75),
         @CONVENIO NUMERIC(15),
         @MONEDA NUMERIC(4),
         @v_constante VARCHAR(1),
         @v_numerador NUMERIC,
         @v_correlativo NUMERIC(10),
         @NOM_CONV_PADRE VARCHAR(40)
      
      SET @CANT = 0
      SELECT @FECHA= FECHAPROCESO FROM PARAMETROS
      
      DECLARE
         CUR_REGISTROS CURSOR 
         FOR 
           SELECT ID, ARCHIVO, CONVENIO, MONEDA FROM REC_CAB_DEBITOSAUTOMATICOS cab WHERE cab.FECHACORTE <= @FECHA
		OR (cab.ESTADO IN (''V'',''Z'') 
		AND (SELECT count(*) FROM REC_DET_DEBITOSAUTOMATICOS WHERE ID_CABEZAL=cab.ID AND ESTADO NOT IN (''P'',''E''))=0)

				
      OPEN CUR_REGISTROS
      FETCH NEXT FROM CUR_REGISTROS INTO @ID, @ARCHIVO, @CONVENIO, @MONEDA
      
      BEGIN TRANSACTION
      
      BEGIN TRY
      
      WHILE @@FETCH_STATUS = 0 
 
      BEGIN
      		/* CALCULO IMPORTE Y CANTIDAD PAGA*/
      		
      		SELECT @SUMA_IMPORTE = sum(IMPORTE) , @CANTIDAD_LIQ = count(*) FROM REC_DET_DEBITOSAUTOMATICOS WHERE ID_CABEZAL =@ID
      		AND ESTADO = ''P''
      		
      		/*GLENS 18/11/2020 Obtengo nombre convenio padre para actualizar en rec_liquidacion */
      		
      		SELECT @NOM_CONV_PADRE = NomConvRec FROM CONV_CONVENIOS_REC WHERE Id_ConvRec = @CONVENIO
      		
      		/* ACTUALIZO LOS VALORES */
      		      		
      		EXECUTE SP_GET_NUMERADOR_TOPAZ 45036, @v_numerador OUTPUT; 
      		
      		INSERT INTO REC_LIQUIDACION (ID_LIQUIDACION, ESTADO, ARCHIVO, CONVENIO, CONVENIO_PADRE, FECHA, MONEDA, TOTALREGISTROS, TOTALIMPORTE, COMISION_LIQUIDADA, IMPORTE_COMISION, ID_RENDICION, ASIENTO_LIQUIDACION, SUCURSAL_LIQUIDACION, FECHA_RENDICION, TZ_LOCK, TOTAL_CARGO_ESPECIFICO, NOMBRE_CONVENIO_PADRE)
			VALUES (@v_numerador, ''L'', @ARCHIVO, @CONVENIO, @CONVENIO, @FECHA, @MONEDA, @CANTIDAD_LIQ, @SUMA_IMPORTE, '' '', 0, 0, 0, @P_SUCURSAL, NULL, 0, 0, @NOM_CONV_PADRE)
			
			UPDATE REC_CAB_DEBITOSAUTOMATICOS
			SET ESTADO = ''P'', ID_LIQUIDACION = @v_numerador
			WHERE ID = @ID
			
			SET @CANT = @CANT + 1
                  
            FETCH NEXT FROM CUR_REGISTROS INTO @ID, @ARCHIVO, @CONVENIO, @MONEDA 
             
      END
      
      	
      SET @P_RET_PROCESO = 1
	  SET @P_MSG_PROCESO = ''Liquidacion Convenios Funcionó correctamente. Se Liquidaron ''+ ISNULL(CAST(@CANT AS nvarchar(max)), '''') + '' Convenios.''
	  
	  EXECUTE pkg_constantes$VarcharConstantes ''C_LOG_TIPO_INFORMACION'', @v_constante OUTPUT;
	  
	  EXECUTE PKG_LOG_PROCESO$PROC_INS_LOG_PROCESO 
	       @P_ID_PROCESO = @P_ID_PROCESO, 
	       @P_FCH_PROCESO = @P_DT_PROCESO, 
	       @P_NOM_PACKAGE = ''PA_LIQ_CONV_DEB_AUTOMATICO'', 
	       @P_COD_ERROR = @P_RET_PROCESO, 
	       @P_MSG_ERROR = @P_MSG_PROCESO, 
	       @P_TIPO_ERROR = @v_constante
	  
	  COMMIT TRANSACTION;     
         
      END TRY
      
      BEGIN CATCH

         
         BEGIN
         
         	ROLLBACK TRANSACTION

            /* Valores de Retorno.*/
            SET @p_ret_proceso = ERROR_NUMBER()

            SET @p_msg_proceso = ERROR_MESSAGE()
            
            EXECUTE pkg_constantes$VarcharConstantes ''C_LOG_TIPO_ERROR'', @v_constante OUTPUT;

            EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso 
               @p_id_proceso = @p_id_proceso, 
               @p_fch_proceso = @p_dt_proceso, 
               @p_nom_package = ''PA_LIQ_CONV_DEB_AUTOMATICO'', 
               @p_cod_error = @p_ret_proceso, 
               @p_msg_error = @p_msg_proceso, 
               @p_tipo_error = @v_constante

         END

      END CATCH
      
      CLOSE CUR_REGISTROS

      DEALLOCATE CUR_REGISTROS
      
   END
')

EXECUTE('

-- ++ AGENCIEROS ++ --
-- SP_ITF_AGENCIEROS
CREATE       PROCEDURE [SP_ITF_AGENCIEROS]  
											   @NRO_CUENTA NUMERIC(10,0),
											   @SUCURSAL NUMERIC(5,0),
											   @TIPO_CUENTA NUMERIC(1,0),
											   @FECHA INT,
											   @NRO_SORTEO NUMERIC(5,0),
											   @AGENCIA NUMERIC(4,0),
											   @IMPORTE INT,
											   @OPERACION_1 NUMERIC(1,0),
											   @OPERACION_2 NUMERIC(1,0),
											   @OPERACION_3 NUMERIC(1,0),
											   @OPERACION_4 NUMERIC(1,0),
											   @ERROR_OPERACION INT,
											   @FECHA_SORTEO VARCHAR(20),
											   @CAJA_DEBITO VARCHAR(1),
											   @CUENTA_CERO INT,
											   @JTS_OID NUMERIC(10,0) OUTPUT,
											   @ERRORS VARCHAR(50) OUTPUT,
											   @ESTADO VARCHAR(1) OUTPUT,
											   @DETALLE_ESTADO VARCHAR(10) OUTPUT
											   



AS 
   DECLARE @cant NUMERIC(5,0) = 0;
   DECLARE @cant_sucursal NUMERIC(5,0) = 0;
   DECLARE @cant_cuenta NUMERIC(5,0) = 0;
   DECLARE @cant_tipo_cuenta NUMERIC(5,0) = 0;
   DECLARE @cant_registros NUMERIC(5,0)=0;
	

   SET @ERRORS ='''';
   SET @ESTADO = ''E'';
   SET @DETALLE_ESTADO= ''Error''
   BEGIN
   	IF @CAJA_DEBITO = ''D''
   	BEGIN
   	SET @cant_tipo_cuenta = (	SELECT count(*) 
							FROM SALDOS WITH (NOLOCK) 
							WHERE C1785 = @TIPO_CUENTA  
								AND TZ_LOCK=0);
   	
   	IF @tipo_cuenta = 0  -- Tipo de cuenta incorrecto, o cuenta no definida.
   		BEGIN
   			SET @ERRORS = ''001 '';
  		END   	
   	
	SET @cant_sucursal = (	SELECT count(*) 
							FROM SALDOS  WITH (NOLOCK)
							WHERE SUCURSAL=@SUCURSAL
							AND tz_lock=0 );
	
   	IF @cant_sucursal = 0  -- Sucursal inexistente.
   		BEGIN
   			SET @ERRORS = CONCAT(@ERRORS,''002 '');
  		END   
 	
 	IF @CUENTA_CERO = 1
 		BEGIN
 			SET @JTS_OID=0;
 		END
 	ELSE
 		BEGIN
	   	SET @cant_cuenta = (	SELECT count(*) 
								FROM SALDOS  WITH (NOLOCK)
								WHERE CUENTA=@NRO_CUENTA AND MONEDA=1 AND  C1785 = @TIPO_CUENTA 
								AND TZ_LOCK=0);
								
	   	IF @cant_cuenta = 0  -- Numero de cuenta inexistente.
	   		BEGIN
	   			SET @ERRORS = CONCAT(@ERRORS,''003 '');
	  		END
	  	ELSE 
	  		BEGIN
	  			SET @JTS_OID = (SELECT JTS_OID 
								FROM SALDOS  WITH (NOLOCK)
								WHERE CUENTA=@NRO_CUENTA AND MONEDA=1 AND  C1785 = @TIPO_CUENTA 
								AND TZ_LOCK=0)
	  		END
	 	END 
	  		
  	SET @cant_cuenta =0;
  	SET @cant_cuenta = (	SELECT count(*) 
							FROM SALDOS  WITH (NOLOCK)
							WHERE CUENTA=@NRO_CUENTA AND  TZ_LOCK<>0 
							);
							
   	IF @cant_sucursal = 0  -- Cuenta dada de baja..
   		BEGIN
   			SET @ERRORS = CONCAT(@ERRORS,''004 '');
  		END 
  		
  	
   	SET @cant_cuenta =0;
  	SET @cant_cuenta = (  SELECT count(*) 
  						  FROM SALDOS AS s, GRL_BLOQUEOS AS g WITH (NOLOCK)
  						  WHERE C1679=''1'' AND s.JTS_OID=g.SALDO_JTS_OID AND s.CUENTA=@NRO_CUENTA AND s.TZ_LOCK=0
							);
							
   	IF @cant_sucursal = 0  -- Cuenta Bloqueada.
   		BEGIN
   			SET @ERRORS = CONCAT(@ERRORS,''005 '');
  		END 
	END
	IF @FECHA=1	-- Fecha invalida
		BEGIN
			SET @ERRORS = CONCAT(@ERRORS,''006 '');
		END 		

	IF @NRO_SORTEO=0	-- Numero de sorteo igual a cero.
		BEGIN
			SET @ERRORS = CONCAT(@ERRORS,''007 '');
		END
   	
	IF @AGENCIA=0	-- Numero de agencia igual a cero.
		BEGIN
			SET @ERRORS = CONCAT(@ERRORS,''008 '');
		END	
		
	IF @IMPORTE=1	-- Importe invalido.
		BEGIN
			SET @ERRORS = CONCAT(@ERRORS,''009 '');
		END	
	IF @ERROR_OPERACION=1
		BEGIN
			SET @ERRORS = CONCAT(@ERRORS,''010 '');
		END
	SET @cant_registros=(	SELECT count(*) 
							FROM REC_Agencieros  WITH (NOLOCK)
							WHERE FECHA_SORTEO=CAST(@FECHA_SORTEO AS DATETIME) AND NRO_SORTEO_NOCTURNO=@NRO_SORTEO AND AGENCIA=@AGENCIA AND TZ_LOCK=0)
	IF @cant_registros>0 -- Registro ya procesado.
		BEGIN
			SET @ERRORS = CONCAT(@ERRORS,''011'');
		END

	IF @ERRORS =''''
		BEGIN
			SET @ERRORS=''0'';
			SET @ESTADO=''V'';
			SET @DETALLE_ESTADO = ''Validado''
		END
	
   END
')

EXECUTE('

-- PA_AGENCIEROS_PASAJE
CREATE PROCEDURE PA_AGENCIEROS_PASAJE
   @P_ID_PROCESO  float(53),
   @P_DT_PROCESO  datetime2(0),
   @P_RET_PROCESO float(53)  OUTPUT,
   @P_MSG_PROCESO varchar(max)  OUTPUT
   
AS 

   BEGIN

      SET @P_RET_PROCESO = NULL
      SET @P_MSG_PROCESO = NULL
      
      DECLARE

         @ID NUMERIC(15),
         @JTS_OID NUMERIC(10),
         @TRANS_DEBITO NUMERIC(10),
         @TRANS_CREDITO NUMERIC(10),
         @SUCURSAL NUMERIC(5),
         @IMPORTE NUMERIC(15,2),
         @SIGNO NUMERIC(1),
         @CANT	NUMERIC(10),
         @FECHA DATE,
         @v_constante VARCHAR(1),
         @v_numerador NUMERIC,
         @IdConv_DB NUMERIC(15),
         @IdConv_CR NUMERIC(15)
      
      SET @CANT = 0
      SELECT @FECHA= FECHAPROCESO FROM PARAMETROS
      --12/10/2021 GLens - Obtengo códigos convenios DB/CR Lotipago de parametrosgenerales
      SELECT @IdConv_DB= NUMERICO FROM PARAMETROSGENERALES WHERE CODIGO = 300
      SELECT @IdConv_CR= NUMERICO FROM PARAMETROSGENERALES WHERE CODIGO = 301
      SELECT @TRANS_DEBITO= CTA_TRANSITORIA FROM CONV_CONVENIOS_REC WHERE Id_ConvRec=@IdConv_DB
      SELECT @TRANS_CREDITO= CTA_TRANSITORIA FROM CONV_CONVENIOS_REC WHERE Id_ConvRec=@IdConv_CR
      
      --12/10/2021 GLens Agrego filtro para solo aquellos bancarizados (CAJA_DEBITO = ''D'')
      --24/11/2021 GLens cambio filtro Estado de Estado = ''I'' a Estado = ''V''
      DECLARE
         CUR_REGISTROS CURSOR 
         FOR 
           SELECT ID,JTS_OID,IMPORTE_LIQUIDO,SIG_IMP_LIQUIDO,SUCURSAL FROM REC_Agencieros 
           WHERE ESTADO = ''V'' AND CAJA_DEBITO = ''D''
				
      OPEN CUR_REGISTROS
      FETCH NEXT FROM CUR_REGISTROS INTO @ID,@JTS_OID,@IMPORTE,@SIGNO,@SUCURSAL
      
      BEGIN TRANSACTION
      
      BEGIN TRY
      
      WHILE @@FETCH_STATUS = 0 
 
      BEGIN
      
      		IF (@SIGNO = 1) --DEBITO AGENCIERO
     		 
     			INSERT INTO GRL_ACREDITACIONES_MASIVAS (TIPO_CTA_DEB, CTA_DEB, SUC_DEB, ESTADO, FCHA_PROCESAR, TIPO_CTA_CRED, CTA_CRED, SUC_CRE, IMPORTE, MON_IMPORTE, APL_EVEN_CRE_DEB, TZ_LOCK, REFERENCIA_EXTERNA,TIPO_ACREDITACION)
				VALUES (''V'', @JTS_OID, @SUCURSAL, ''I'', @FECHA, ''V'', @TRANS_DEBITO, @SUCURSAL, @IMPORTE, 1, ''N'', 0, @ID, ''AGEN'')
			
			ELSE --CREDITO AGENCIERO
			
				INSERT INTO GRL_ACREDITACIONES_MASIVAS (TIPO_CTA_DEB, CTA_DEB, SUC_DEB, ESTADO, FCHA_PROCESAR, TIPO_CTA_CRED, CTA_CRED, SUC_CRE, IMPORTE, MON_IMPORTE, APL_EVEN_CRE_DEB, TZ_LOCK, REFERENCIA_EXTERNA,TIPO_ACREDITACION)
				VALUES (''V'', @TRANS_CREDITO, @SUCURSAL, ''I'', @FECHA, ''V'', @JTS_OID, @SUCURSAL, @IMPORTE, 1, ''N'', 0, @ID, ''AGEN'')
	
			SET @CANT = @CANT + 1
			
			UPDATE REC_Agencieros
			SET ESTADO = ''R''
			WHERE ID = @ID
      	                  
            FETCH NEXT FROM CUR_REGISTROS INTO @ID,@JTS_OID,@IMPORTE,@SIGNO,@SUCURSAL 
             
      END
      	
      SET @P_RET_PROCESO = 1
	  SET @P_MSG_PROCESO = ''Pasaje Funcionó correctamente. Se pasaron ''+ ISNULL(CAST(@CANT AS nvarchar(max)), '''') + '' registros.''
	  
	  EXECUTE pkg_constantes$VarcharConstantes ''C_LOG_TIPO_INFORMACION'', @v_constante OUTPUT;
	  
	  EXECUTE PKG_LOG_PROCESO$PROC_INS_LOG_PROCESO 
	       @P_ID_PROCESO = @P_ID_PROCESO, 
	       @P_FCH_PROCESO = @P_DT_PROCESO, 
	       @P_NOM_PACKAGE = ''PA_AGENCIEROS_PASAJE'', 
	       @P_COD_ERROR = @P_RET_PROCESO, 
	       @P_MSG_ERROR = @P_MSG_PROCESO, 
	       @P_TIPO_ERROR = @v_constante
	  
	  COMMIT TRANSACTION;     
         
      END TRY
      
      BEGIN CATCH

         
         BEGIN
         
         	ROLLBACK TRANSACTION

            /* Valores de Retorno.*/
            SET @p_ret_proceso = ERROR_NUMBER()

            SET @p_msg_proceso = ERROR_MESSAGE()
            
            EXECUTE pkg_constantes$VarcharConstantes ''C_LOG_TIPO_ERROR'', @v_constante OUTPUT;

            EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso 
               @p_id_proceso = @p_id_proceso, 
               @p_fch_proceso = @p_dt_proceso, 
               @p_nom_package = ''PA_AGENCIEROS_PASAJE'', 
               @p_cod_error = @p_ret_proceso, 
               @p_msg_error = @p_msg_proceso, 
               @p_tipo_error = @v_constante

         END

      END CATCH
      
      CLOSE CUR_REGISTROS

      DEALLOCATE CUR_REGISTROS
      
   END
')

EXECUTE('

-- PA_AGENCIEROS_ACTUALIZACION
CREATE PROCEDURE [PA_AGENCIEROS_ACTUALIZACION]
   @P_ID_PROCESO  float(53),
   @P_DT_PROCESO  datetime2(0),
   @P_RET_PROCESO float(53)  OUTPUT,
   @P_MSG_PROCESO varchar(max)  OUTPUT
   
AS 

   BEGIN

      SET @P_RET_PROCESO = NULL
      SET @P_MSG_PROCESO = NULL
      
      DECLARE

         @ID NUMERIC(15),
         @ESTADO VARCHAR(1),
         @CANT	NUMERIC(10),
         @v_constante VARCHAR(1),
         @v_numerador NUMERIC,
         @ASIENTO_PROCESADO NUMERIC(10)
      
      SET @CANT = 0
      
      DECLARE
         CUR_REGISTROS CURSOR 
         FOR 
           SELECT a.ID,am.ESTADO,am.ASIENTO_PROCESADO 
		   FROM REC_Agencieros a WITH (NOLOCK)
		   JOIN GRL_ACREDITACIONES_MASIVAS am WITH (NOLOCK)
														ON a.ID=am.REFERENCIA_EXTERNA 
		   WHERE a.ESTADO=''R'' 
				
      OPEN CUR_REGISTROS
      FETCH NEXT FROM CUR_REGISTROS INTO @ID,@ESTADO,@ASIENTO_PROCESADO
      
      BEGIN TRANSACTION
      
      BEGIN TRY
      
      WHILE @@FETCH_STATUS = 0 
 
      BEGIN
      		
			UPDATE REC_Agencieros
			SET ESTADO = @ESTADO, ASIENTO = @ASIENTO_PROCESADO
			WHERE ID = @ID 
	
			SET @CANT = @CANT + 1
    	                  
            FETCH NEXT FROM CUR_REGISTROS INTO @ID,@ESTADO,@ASIENTO_PROCESADO
             
      END
      	
      SET @P_RET_PROCESO = 1
	  SET @P_MSG_PROCESO = ''Actualizacion Funcionó correctamente. Se actualizaron ''+ ISNULL(CAST(@CANT AS nvarchar(max)), '''') + '' registros.''
	  
	  EXECUTE pkg_constantes$VarcharConstantes ''C_LOG_TIPO_INFORMACION'', @v_constante OUTPUT;
	  
	  EXECUTE PKG_LOG_PROCESO$PROC_INS_LOG_PROCESO 
	       @P_ID_PROCESO = @P_ID_PROCESO, 
	       @P_FCH_PROCESO = @P_DT_PROCESO, 
	       @P_NOM_PACKAGE = ''PA_AGENCIEROS_ACTUALIZACION'', 
	       @P_COD_ERROR = @P_RET_PROCESO, 
	       @P_MSG_ERROR = @P_MSG_PROCESO, 
	       @P_TIPO_ERROR = @v_constante
	  
	  COMMIT TRANSACTION;     
         
      END TRY
      
      BEGIN CATCH

         
         BEGIN
         
         	ROLLBACK TRANSACTION

            /* Valores de Retorno.*/
            SET @p_ret_proceso = ERROR_NUMBER()

            SET @p_msg_proceso = ERROR_MESSAGE()
            
            EXECUTE pkg_constantes$VarcharConstantes ''C_LOG_TIPO_ERROR'', @v_constante OUTPUT;

            EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso 
               @p_id_proceso = @p_id_proceso, 
               @p_fch_proceso = @p_dt_proceso, 
               @p_nom_package = ''PA_AGENCIEROS_ACTUALIZACION'', 
               @p_cod_error = @p_ret_proceso, 
               @p_msg_error = @p_msg_proceso, 
               @p_tipo_error = @v_constante

         END

      END CATCH
      
      CLOSE CUR_REGISTROS

      DEALLOCATE CUR_REGISTROS
      
   END     
')