EXECUTE('
ALTER PROCEDURE SP_INMOVILIZAR_SALDOS_DPF
@p_id_proceso FLOAT(53),     /* Identificador de proceso */
@p_dt_proceso DATETIME,   /* Fecha de proceso */
@p_ret_proceso FLOAT OUT, /* Estado de ejecucion del PL/SQL(1:Correcto, 2: Error) */
@p_msg_proceso VARCHAR(MAX) OUT
AS

BEGIN
	DECLARE
	
	------- Campos para el LOG --------
	@c_log_tipo_error varchar(30),
	@c_log_tipo_informacion VARCHAR(30),
	-----------------------------------
	
	@CorreoOrigen VARCHAR (128),
  	@CorreoDestino VARCHAR (128),
  	@DescripcionProducto VARCHAR(256),
	@Cuenta NUMERIC (12, 0),
	@FechaApertura DATETIME,
	@Moneda NUMERIC (4, 0),
	@SaldoActual NUMERIC (15, 2),
	@CostoCom NUMERIC (15, 2),
	@JtsOid NUMERIC (10, 0),
	@JtsOidCtaDestino NUMERIC (10, 0),
	@ContraCuenta FLOAT,
	@Cliente FLOAT,
	@Data VARCHAR (2048),
	@FechaProceso DATETIME,
	@contador NUMERIC(10)
	
	SET @DescripcionProducto = ''''
	SET @Cuenta = 0
	SET @Moneda = 0
	SET @SaldoActual = 0
	SET @CostoCom = 0
	SET @JtsOid = 0
	SET @JtsOidCtaDestino = 0
	SET @ContraCuenta = 0
	SET @Cliente = 0
	SET @FechaProceso = (SELECT FECHAPROCESO FROM PARAMETROS)
	SET @contador = 0
	
	------- Campos para el LOG --------
	SET @c_log_tipo_error = ''E''
	SET @c_log_tipo_informacion = ''I''
	-----------------------------------
	
	BEGIN TRY
		DECLARE SaldosAinmovilizar CURSOR FOR
			SELECT 	S.CUENTA,
				P.C6251 AS DESCRIPCIONPRODUCTO,
				S.C1620 AS FECHAAPERTURA,
				S.MONEDA AS MONEDA,
				S.C1604 AS SALDOACTUAL,
				CASE WHEN S.MONEDA=2
					THEN (SELECT C.IMPORTE_APLICAR 
							FROM CI_CARGOS_TARIFAS AS C 
							WHERE C.MONEDA=S.MONEDA AND C.ID_CARGO=1200 AND C.TZ_LOCK=0)
				ELSE
				(SELECT C.IMPORTE_APLICAR 
					FROM CI_CARGOS_TARIFAS AS C 
					WHERE C.MONEDA=80 AND C.ID_CARGO=1200 AND C.TZ_LOCK=0) END AS COSTOCOM,
				S.JTS_OID,
				S.C1665 AS CONTRACUENTA,
				(SELECT E.EMAIL 
				FROM CLI_EMAILS E, CLI_CLIENTES CL, CLI_ClientePersona CP, PZO_SALDOS PS 
				WHERE PS.JTS_OID_SALDO=S.JTS_OID 
					AND CL.CODIGOCLIENTE=S.C1803 AND CL.CODIGOCLIENTE=CP.CODIGOCLIENTE 
					AND PS.TIPO_MAIL=E.TIPO AND PS.FORMATO_MAIL=e.FORMATO 
					AND PS.ORDINAL_MAIL=E.ORDINAL
					AND CP.NUMEROPERSONA=E.ID AND CP.TITULARIDAD=''T''
				 	AND E.TZ_LOCK=0 AND CL.TZ_LOCK=0 AND CP.TZ_LOCK=0 AND PS.TZ_LOCK=0 
				) AS CORREODESTINO
			FROM	SALDOS S, PRODUCTOS P
			WHERE	S.PRODUCTO = P.C6250
					AND S.C1659 = ''N''
					AND S.C1627 = @FechaProceso
					AND S.C1785 = 4
					AND S.C1734 != ''I''
					AND S.TZ_LOCK = 0
					AND P.TZ_LOCK = 0;
		
		OPEN SaldosAinmovilizar;
		
		FETCH NEXT FROM SaldosAinmovilizar INTO @Cuenta, @DescripcionProducto, @FechaApertura, @Moneda, @SaldoActual, @CostoCom, @JtsOid, @ContraCuenta, @CorreoDestino;
		SET @CorreoOrigen = (SELECT ALFA FROM PARAMETROSGENERALES WHERE CODIGO = 205)
		
		WHILE @CorreoDestino IS NOT NULL
		
			BEGIN
				IF @@FETCH_STATUS <> 0 
					BREAK
				
				UPDATE SALDOS
				SET C1734 = ''I''
				WHERE JTS_OID = @JtsOid
					AND TZ_LOCK = 0
				
				SET @contador=@contador+1
				
				SET @Data = concat(''Html=SaldoInmovilizadoDPF.html;Variables=Cuenta::'',@Cuenta,
					'';Variables=DescripcionProducto::'',@DescripcionProducto,'';Variables=FechaApertura::'',CONVERT(VARCHAR, @FechaApertura, 103),
					'';Variables=Moneda::'',@Moneda,'';Variables=SaldoActual::'',@SaldoActual,'';Variables=CostoCom::'',@CostoCom,'';'')
				
				INSERT INTO CORREOS_A_ENVIAR (MAIL_OID, MAIL_TO, MAIL_FROM, DATA, INTENTOS, SUBJECT, FECHA_INGRESO, TZ_LOCK)
				VALUES (0, @CorreoDestino, @CorreoOrigen, @Data, 0, ''NOTIFICACIÓN COMISION SALDO INMOVILIZADO'', @FechaProceso, 0);
				
				INSERT INTO DPF_SALDOS_INMOVILIZADOS (TZ_LOCK, JTS_OID_SALDO_DPF, JTS_OID_SALDO, CUENTA, FECHA_ALTA, FECHA_INMOVILIZACION, MOTIVO_INMOVILIZACION)
				VALUES (0, @JtsOid, @ContraCuenta, @Cuenta, @FechaApertura, @FechaProceso, ''No tiene instrucción de Cancelar o Renovar al Vencimiento'');
				
				FETCH NEXT FROM SaldosAinmovilizar INTO @Cuenta, @DescripcionProducto, @FechaApertura, @Moneda, @SaldoActual, @CostoCom, @JtsOid, @ContraCuenta, @CorreoDestino;
		 	END
		 	
		CLOSE SaldosAinmovilizar;
	    DEALLOCATE SaldosAinmovilizar;
	    
	    SET @p_msg_proceso = ''El proceso de inmovilización de saldos DPF ha culminado correctamente. Saldos Inmovilizados: ''+ CONVERT(VARCHAR(10), @contador)
		SET @p_ret_proceso = 1 		
		
		-- Logueo de información
		EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso 
			@p_id_proceso,
	    	@p_dt_proceso,
	    	''SP_INMOVILIZAR_SALDOS_DPF'',
	    	@p_cod_error = @p_ret_proceso, 
			@p_msg_error = @p_msg_proceso, 
			@p_tipo_error = @c_log_tipo_informacion
	END TRY
						             
	BEGIN CATCH

        SET @p_ret_proceso = ERROR_NUMBER()
        SET @p_msg_proceso = ''Error al inmovilizar saldos DPF '' + ERROR_MESSAGE()

		EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso 
        	@p_id_proceso = @p_id_proceso, 
        	@p_fch_proceso = @p_dt_proceso, 
        	@p_nom_package = ''SP_INMOVILIZAR_SALDOS_DPF'', 
        	@p_cod_error = @p_ret_proceso, 
        	@p_msg_error = @p_msg_proceso, 
       		@p_tipo_error = @c_log_tipo_informacion
	END CATCH
		
END
')