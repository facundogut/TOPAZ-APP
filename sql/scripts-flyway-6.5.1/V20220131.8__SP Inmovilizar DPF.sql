EXECUTE('

ALTER PROCEDURE [dbo].[SP_INMOVILIZAR_SALDOS_DPF]
@p_id_proceso FLOAT(53),     /* Identificador de proceso */
@p_dt_proceso DATETIME,   /* Fecha de proceso */
@p_ret_proceso FLOAT OUT, /* Estado de ejecucion del PL/SQL(1:Correcto, 2: Error) */
@p_msg_proceso VARCHAR(MAX) OUT
AS
BEGIN
	DECLARE
	
	------- Campos para el LOG --------
	@c_log_tipo_error varchar(30),
	@c_log_tipo_informacion VARCHAR(30)
	-----------------------------------
	
	------- Campos para el LOG --------
	SET @c_log_tipo_error = ''E''
	SET @c_log_tipo_informacion = ''I''
	-----------------------------------
	
	----------Tablas auxiliares------------
	DECLARE @TMPSaldosAInmovilizarDPF TABLE(
		    CUENTA NUMERIC (12, 0),
			PRODUCTO NUMERIC(5,0),
			DESCRIPCIONPRODUCTO VARCHAR(256),
			FECHAAPERTURA DATETIME,
			MONEDA NUMERIC(4, 0),
			SALDOACTUAL NUMERIC(15,2),
			COSTOCOM NUMERIC(15, 2),
			JTS_OID NUMERIC(10,0),
			CONTRACUENTA FLOAT,
			CORREODESTINO VARCHAR (128)
			)
	
    DECLARE @TMPCorreosAEnviar TABLE(
			ORDINAL INT IDENTITY(1,1) NOT NULL,
			MAIL_TO VARCHAR(128),
			MAIL_FROM VARCHAR(128),
			DATA VARCHAR(2048),
			INTENTOS NUMERIC(1,0),
			SUBJECT VARCHAR(255),
			FECHA_INGRESO DATETIME,
			TZ_LOCK NUMERIC(15,0)
	)
	
	BEGIN TRY
	-- CARGO LAS TABLAS TEMPORALES
						
				INSERT INTO @TMPSaldosAInmovilizarDPF
					SELECT 	S.CUENTA AS CUENTA,
						P.C6250 AS PRODUCTO,
						P.C6251 AS DESCRIPCIONPRODUCTO,
						S.C1620 AS FECHAAPERTURA,
						S.MONEDA AS MONEDA,
						S.C1604 AS SALDOACTUAL,
						CASE WHEN S.MONEDA IN (SELECT C6399 FROM MONEDAS WITH (nolock) WHERE C6403 = ''D'')
							THEN (SELECT C.IMPORTE_APLICAR 
									FROM CI_CARGOS_TARIFAS AS C with (nolock)
									WHERE C.MONEDA=S.MONEDA 
											AND C.ID_CARGO=1200 
											AND C.TZ_LOCK=0
								)
						ELSE
						(SELECT C.IMPORTE_APLICAR 
							FROM CI_CARGOS_TARIFAS AS C with (nolock)
							WHERE C.MONEDA IN (SELECT C6399 
												FROM MONEDAS with (nolock) 
												WHERE C6403 = ''N''
												) 
							AND C.ID_CARGO=1200 
							AND C.TZ_LOCK=0
						) 
						END AS COSTOCOM,
						S.JTS_OID AS JTS_OID,
						S.C1665 AS CONTRACUENTA,
						(SELECT E.EMAIL 
							FROM CLI_EMAILS E with (nolock) 
							INNER JOIN CLI_ClientePersona CP with (nolock)ON CP.NUMEROPERSONA=E.ID
																			AND E.TZ_LOCK=0
																			AND CP.TZ_LOCK=0
																			AND CP.TITULARIDAD=''T''
							INNER JOIN CLI_CLIENTES CL with (nolock)ON CL.CODIGOCLIENTE=CP.CODIGOCLIENTE 
																		AND CL.TZ_LOCK=0
																		AND CL.CODIGOCLIENTE=S.C1803 
							
							INNER JOIN PZO_SALDOS PS with (nolock)ON PS.ORDINAL_MAIL=E.ORDINAL
																	AND PS.TIPO_MAIL=E.TIPO
																	AND PS.FORMATO_MAIL=e.FORMATO 
																	AND PS.JTS_OID_SALDO=S.JTS_OID
																	AND PS.TZ_LOCK=0
							   
							) AS CORREODESTINO
					FROM	SALDOS S with (nolock)
					INNER JOIN	PRODUCTOS P with (nolock)ON
														S.PRODUCTO = P.C6250
														AND S.C1659 = ''N''
														AND S.C1627 = (SELECT FECHAPROCESO FROM PARAMETROS with (nolock))
														AND S.C1785 = 4
														AND S.C1734 != ''I'' AND S.C1734 != ''U'' AND S.C1734 != ''T''
														AND S.C1604>0
														AND S.TZ_LOCK = 0
														AND P.TZ_LOCK = 0;
				
				INSERT INTO @TMPCorreosAEnviar
						SELECT 
								CORREODESTINO AS MAIL_TO, 
							    (SELECT ALFA FROM PARAMETROSGENERALES with (nolock) WHERE CODIGO = 205) AS MAIL_FROM,
								 concat(''Html=SaldoInmovilizadoDPF.html;Variables=Cuenta::'',CUENTA,
									'';Variables=DescripcionProducto::'',DESCRIPCIONPRODUCTO,
									'';Variables=FechaApertura::'',CONVERT(VARCHAR, FECHAAPERTURA, 103),
									'';Variables=Moneda::'',MONEDA,'';Variables=SaldoActual::'',SALDOACTUAL,
									'';Variables=CostoCom::'',COSTOCOM,'';'') AS DATA,
								 0 AS INTENTOS,
								 ''NOTIFICACIÓN COMISION SALDO INMOVILIZADO'' AS SUBJECT,
								 (SELECT FECHAPROCESO FROM PARAMETROS with (nolock)) AS FECHA_INGRESO,	
								 0 AS TZ_LOCK		
						 FROM @TMPSaldosAInmovilizarDPF WHERE CORREODESTINO IS NOT NULL AND LEN(CORREODESTINO)>0
							
		        DECLARE @contador_registros INT
  				DECLARE @contador_correos INT
				SET @contador_registros = ISNULL((SELECT COUNT(*) FROM @TMPSaldosAInmovilizarDPF),0)
				SET @contador_correos = ISNULL((SELECT COUNT(*) FROM @TMPCorreosAEnviar),0)
				
			
				--ACTUALIZO SALDOS Y ENVÍO CORREOS
				
						BEGIN
							
								-- UVA/UVI: UPDATE ESTADO ATRASO FORZADO EN U
								UPDATE SALDOS 
								SET C1734 = ''U''
								FROM SALDOS S with (nolock)
								INNER JOIN @TMPSaldosAInmovilizarDPF I ON 
											I.JTS_OID = S.JTS_OID 
								WHERE  I.MONEDA IN (SELECT C6399 FROM MONEDAS WHERE C6403 = ''I'') 
										AND I.PRODUCTO <> (SELECT NUMERICO FROM PARAMETROSGENERALES WHERE CODIGO = 708)
								
								-- NO ES TITULO VALOR Y TAMPOCO UVA/UVI: UPDATE ESTADO ATRASO FORZADO EN I  
								UPDATE SALDOS 
								SET C1734 = ''I''
								FROM SALDOS S with (nolock)
								INNER JOIN @TMPSaldosAInmovilizarDPF I ON 
											I.JTS_OID = S.JTS_OID 
								WHERE I.MONEDA NOT IN (SELECT C6399 FROM MONEDAS WHERE C6403 = ''I'') 
										AND I.PRODUCTO <> (SELECT NUMERICO FROM PARAMETROSGENERALES WHERE CODIGO = 708)
										
								-- TITULO VALOR: UPDATE ESTADO ATRASO FORZADO EN T  		
								UPDATE SALDOS 
								SET C1734 = ''T''
								FROM SALDOS S with (nolock)
								INNER JOIN @TMPSaldosAInmovilizarDPF I ON 
											I.JTS_OID = S.JTS_OID 
								WHERE I.PRODUCTO = (SELECT NUMERICO FROM PARAMETROSGENERALES WHERE CODIGO = 708)
								
								--INSERTO EN DPF_SALDOS_INMOVILIZADOS--
								INSERT INTO
									DPF_SALDOS_INMOVILIZADOS
								SELECT
									0 AS TZ_LOCK,
									I.JTS_OID AS JTS_OID_SALDO_DPF,
									I.CONTRACUENTA AS JTS_OID_SALDO,
									I.CUENTA AS CUENTA,
									I.FECHAAPERTURA AS FECHA_ALTA,
									(SELECT FECHAPROCESO FROM PARAMETROS with (nolock)) AS FECHA_INMOVILIZACION,
									''No tiene instrucción de Cancelar o Renovar al Vencimiento''
								FROM @TMPSaldosAInmovilizarDPF AS I
								
						   						   
								--INSERTO EN CORREOS_A_ENVIAR--
								INSERT INTO
									CORREOS_A_ENVIAR
								SELECT
									C.ORDINAL + ident_current(''SEQUENCE_CORREOS_A_ENVIAR''),
									C.MAIL_TO,
									C.MAIL_FROM,
									C.DATA,
									C.INTENTOS,
									C.SUBJECT,
									C.FECHA_INGRESO,
									C.TZ_LOCK
								FROM @TMPCorreosAEnviar AS C 
								
								--INSERT EN SEQUENCE_CORREOS_A_ENVIAR--
									--PARA ACTUALIZAR NUMERADOR--
								INSERT INTO
									SEQUENCE_CORREOS_A_ENVIAR
								SELECT 0
								FROM @TMPCorreosAEnviar 
								
								DELETE FROM SEQUENCE_CORREOS_A_ENVIAR ;	
								
 											   
				 		END
					    
	    SET @p_msg_proceso = ''El proceso de inmovilización de saldos DPF ha culminado correctamente. Saldos Inmovilizados: ''+ CONVERT(VARCHAR(10), @contador_registros)
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

