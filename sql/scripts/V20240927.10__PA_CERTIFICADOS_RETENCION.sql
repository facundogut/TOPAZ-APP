EXECUTE('
CREATE OR ALTER PROCEDURE PA_CERTIFICADOS_RETENCION
   @P_ID_PROCESO 			FLOAT(53),
   @P_DT_PROCESO			DATETIME2(0),
   @P_CLAVE                 varchar(max),
   @P_SUCURSAL              float(53),
   @P_NROMAQUINA            float(53),
   @P_RET_PROCESO			FLOAT(53)  OUTPUT,
   @P_MSG_PROCESO			VARCHAR(max)  OUTPUT
   
AS 

BEGIN

	SET @P_RET_PROCESO = NULL
	SET @P_MSG_PROCESO = NULL
	
	DECLARE
	
	@v_constante VARCHAR(1), --ESTA VARIABLE SE DEVUELVE COMO TIPO DE ERROR EN EL CATCH
	
	@CANT NUMERIC(15)
	--DECLARE Y SET DE VARIABLES
    
    ------------------------------------------------------------
	--BÚSQUEDA DE DATOS Y USO DE TABLAS TEMPORALES
		--si no se ingresa cliente (parámetro = -1), hacer búsqueda un barrido de todos los movimientos que puedan generar certificados
		--estos son los registros de CI_FACTURA_LINEA para cargos o impuestos con tipo 3 IVA Retención 4 IGA y 12 IIBB CABA Retención
		--para el cargo o impuesto, buscar el tipo de impuesto, relacionar con la tabla CON_EQUIVALENCIA_CARGO_IMPOSITIVO para saber qué valor guardar
		--relacionar con la tabla CON_REGIMEN_CERTIF_RET para saber regimen a guardar
		--según el tipo de cargo impositivo, sucursal y anteriores certificados, calcular el siguiente número de certificado a utilizar.
		--copiar los datos necesarios de ci_factura_linea, o los parámetros de entrada.
		--devolver el número de certificado en caso de que sea a operación para que se pueda buscar, imprimir y modificar registro para agregar una copia.
		--si no se puede, ya dar de alta con estado impreso y 1 copia, si el llamado viene de la operación.
	---------------------------------
	
	BEGIN TRANSACTION

	BEGIN TRY

	BEGIN
		SET @CANT =NULL;
		
		
	
		WITH DET_CONTABILIDAD_ORDENADO AS (
			SELECT
				ROW_NUMBER() OVER(PARTITION BY GD.MOV_FECHA_PROCESO, GD.MOV_ASIENTO, GD.MOV_SUCURSAL 
					ORDER BY P.C6252 DESC, GD.JTS_OID) AS NRO_FILA,
				S.JTS_OID AS SALDO_JTS_OID,
				GD.MOV_FECHA_PROCESO,
				GD.MOV_ASIENTO,
				GD.MOV_SUCURSAL
			FROM GRL_DETALLE_CONTABILIDAD AS GD WITH (nolock)
			INNER JOIN SALDOS AS S WITH (nolock) ON
				S.SUCURSAL = GD.SALDO_ORIG_SUCURSAL
				AND S.PRODUCTO = GD.SALDO_ORIG_PRODUCTO
				AND S.CUENTA = GD.SALDO_ORIG_CUENTA
				AND S.MONEDA = GD.SALDO_ORIG_MONEDA
				AND S.OPERACION = GD.SALDO_ORIG_OPERACION
				AND S.ORDINAL = GD.SALDO_ORIG_ORDINAL
				AND ((S.TZ_LOCK < 100000000000000 OR S.TZ_LOCK >= 200000000000000)
					AND (S.TZ_LOCK < 300000000000000 OR S.TZ_LOCK >= 400000000000000)
				)
			INNER JOIN PRODUCTOS AS P WITH (nolock) ON
				P.C6250 = GD.SALDO_ORIG_PRODUCTO
				AND P.C6252 IN (2,3,4)
				AND ((P.TZ_LOCK < 100000000000000 OR P.TZ_LOCK >= 200000000000000)
					AND (P.TZ_LOCK < 300000000000000 OR P.TZ_LOCK >= 400000000000000)
				)
			WHERE	
				((GD.TZ_LOCK < 100000000000000 OR GD.TZ_LOCK >= 200000000000000)
					AND (GD.TZ_LOCK < 300000000000000 OR GD.TZ_LOCK >= 400000000000000))
		)
		
    INSERT INTO CON_CERTIFICADOS_RETENCION
      	SELECT
      	    0 AS TZ_LOCK,
		    CAST(	CONCAT(
		    			D.MOV_SUCURSAL, 
			    		YEAR(D.MOV_FECHA_PROCESO),
			    		ISNULL(RIGHT(C.NRO_CERTIFICADO, 6), ''000000'')
		    		) AS NUMERIC (15)
		    ) +
		    	ROW_NUMBER() OVER(PARTITION BY E.TIPO_CARGO_IMPOSITIVO ORDER BY E.TIPO_CARGO_IMPOSITIVO)
		    AS NRO_CERTIFICADO,
		    E.TIPO_CARGO_IMPOSITIVO,
		    S.C1803 AS CLIENTE,
		    M.FECHACONTABLE,
		    CR.CODIGO_REGIMEN,
		    ISNULL(CAST(PS.CERTIFICADO_DPF AS NUMERIC(12)), S.CUENTA) AS NRO_COMPROBANTE,
		   
		    CASE WHEN D.MOV_MONEDA <>1 AND MON.C6403 <> ''I'' AND M.moneda NOT IN (SELECT C6399 FROM MONEDAS
																			     WHERE TZ_LOCK= 0 
																				   AND C6403 =''I'')
		    THEN
		    (	SELECT SUM(CAPITALREALIZADO)
		    	FROM MOVIMIENTOS_CONTABLES WITH(nolock)
		    	WHERE
		    		ASIENTO = D.MOV_ASIENTO
		    		AND SUCURSAL = D.MOV_SUCURSAL
		    		AND FECHAPROCESO = D.MOV_FECHA_PROCESO
		    		AND DEBITOCREDITO = ''D''
		    ) * CB.TC_VENTA
		    
		    WHEN D.MOV_MONEDA =1 AND MON.C6403 = ''N'' AND M.moneda IN (SELECT C6399 FROM MONEDAS
																			     WHERE TZ_LOCK= 0 
																				   AND C6403 =''I'')
		    THEN
		    (	SELECT SUM(CAPITALREALIZADO)
		    	FROM MOVIMIENTOS_CONTABLES WITH(nolock)
		    	WHERE
		    		ASIENTO = D.MOV_ASIENTO
		    		AND SUCURSAL = D.MOV_SUCURSAL
		    		AND FECHAPROCESO = D.MOV_FECHA_PROCESO
		    		AND DEBITOCREDITO = ''D''
		    ) 		    
		    
		    WHEN (D.MOV_MONEDA <>1 AND MON.C6403 = ''I'' ) 
		     THEN
		    (	SELECT SUM(CAPITALREALIZADO)
		    	FROM MOVIMIENTOS_CONTABLES WITH(nolock)
		    	WHERE
		    		ASIENTO = D.MOV_ASIENTO
		    		AND SUCURSAL = D.MOV_SUCURSAL
		    		AND FECHAPROCESO = D.MOV_FECHA_PROCESO
		    		AND DEBITOCREDITO = ''D''
		    )
		   
		   ELSE  
		    (	SELECT SUM(CAPITALREALIZADO)
		    	FROM MOVIMIENTOS_CONTABLES WITH(nolock)
		    	WHERE
		    		ASIENTO = D.MOV_ASIENTO
		    		AND SUCURSAL = D.MOV_SUCURSAL
		    		AND FECHAPROCESO = D.MOV_FECHA_PROCESO
		    		AND DEBITOCREDITO = ''D''
		    )
		    END
		    AS MONTO_COMPROBANTE,
		    
		    
		    CASE WHEN D.MOV_MONEDA <>1 AND MON.C6403 <> ''I'' THEN FL.MONTO_IMPONIBLE *CB.TC_VENTA 
		         WHEN (D.MOV_MONEDA <>1 AND MON.C6403  = ''I'') 
		              THEN FL.MONTO_IMPONIBLE *HTC.TIPO_CAMBIO_VENTA
		         WHEN D.MOV_MONEDA =1 AND MON.C6403  = ''N'' AND M.moneda IN (SELECT C6399 FROM MONEDAS WHERE TZ_LOCK= 0 AND C6403 =''I'')
		              THEN FL.MONTO_IMPONIBLE 
		         
		    ELSE FL.MONTO_IMPONIBLE END AS MONTO_IMPONIBLE,
		    
		    
		    CASE WHEN D.MOV_MONEDA <>1 AND MON.C6403 <> ''I'' THEN FL.MONTO_FACTURABLE*CB.TC_VENTA 
		         WHEN (D.MOV_MONEDA <>1 AND MON.C6403  = ''I'') 
		              THEN FL.MONTO_FACTURABLE*HTC.TIPO_CAMBIO_VENTA
		          WHEN D.MOV_MONEDA =1 AND MON.C6403  = ''N'' AND M.moneda IN (SELECT C6399 FROM MONEDAS WHERE TZ_LOCK= 0 AND C6403 =''I'')
		              THEN FL.MONTO_FACTURABLE 
		    ELSE FL.MONTO_FACTURABLE END AS IMPORTEMN,
		    
		    CASE 
				WHEN FL.IMPORTEMN/FL.MONTO_IMPONIBLE>0.05 
				THEN 10 
				ELSE 3 
				END AS ALICUOTA,
		    0 AS OTROS_CONCEPTOS,
		    ''AA'' AS ESTADO,
		    0 AS IMPRESIONES,
		    D.MOV_ASIENTO AS ASIENTO,
		    D.MOV_SUCURSAL AS SUCURSAL,
		    D.MOV_FECHA_PROCESO AS FECHAPROCESO,
		    D.MOV_OPERACION AS OPERACION,
		    ISNULL(D.CARGOS_ID_CARGO, D.CARGOS_ID_IMPUESTO) AS ID_CARGO
		FROM GRL_DETALLE_CONTABILIDAD AS D WITH(nolock)
		INNER JOIN ASIENTOS AS A WITH(nolock) ON
		    A.ASIENTO = D.MOV_ASIENTO 
		    AND A.FECHAPROCESO = D.MOV_FECHA_PROCESO
		    AND A.SUCURSAL = D.MOV_SUCURSAL
		    AND A.ESTADO = 77
		INNER JOIN MOVIMIENTOS_CONTABLES AS M WITH(nolock) ON
			M.ASIENTO = D.MOV_ASIENTO
			AND M.SUCURSAL = D.MOV_SUCURSAL
			AND M.FECHAPROCESO = D.MOV_FECHA_PROCESO
			AND M.JTS_OID = (	SELECT TOP 1 JTS_OID 
								FROM MOVIMIENTOS_CONTABLES WITH(nolock)
								WHERE M.ASIENTO = ASIENTO
									AND M.SUCURSAL = SUCURSAL
									AND M.FECHAPROCESO = FECHAPROCESO
							)
		    AND M.OPERACION <> 9999
		INNER JOIN DET_CONTABILIDAD_ORDENADO AS DCO WITH (nolock) ON
			DCO.MOV_FECHA_PROCESO = D.MOV_FECHA_PROCESO
			AND DCO.MOV_ASIENTO = D.MOV_ASIENTO
			AND DCO.MOV_SUCURSAL = D.MOV_SUCURSAL
			AND DCO.NRO_FILA = 1
		
		INNER JOIN HISTORICOTIPOSCAMBIO	HTC ON HTC.Moneda = m.MONEDA
		                                     AND HTC.TZ_LOCK = 0 
		                                     AND HTC.Fecha_Cotizacion = CASE WHEN (SELECT Fecha_Cotizacion FROM HISTORICOTIPOSCAMBIO HTC2
		                                                                        WHERE HTC2.TZ_LOCK = 0 AND HTC2.Moneda = m.moneda
		                                                                        AND HTC2.Fecha_Cotizacion = (SELECT dbo.diaHabil(fechaProceso-1, ''A'') FROM PARAMETROS)) IS NULL
		                                                                 THEN (SELECT Fecha_Cotizacion FROM CON_COTIZACIONES_BNA HTC2
		                                                                        WHERE HTC2.TZ_LOCK = 0 AND HTC2.Moneda = m.moneda
		                                                                        AND HTC2.Fecha_Cotizacion = (SELECT dbo.diaHabil(max(Fecha_Cotizacion), ''A'') 
		                                                                                                      FROM CON_COTIZACIONES_BNA WHERE TZ_LOCK = 0 AND Moneda = m.moneda
		                                                                                                      AND Fecha_Cotizacion<(SELECT fechaproceso FROM PARAMETROS)))
		                                                                 ELSE
		                                                                      (SELECT dbo.diaHabil(fechaProceso-1, ''A'') FROM PARAMETROS)
		                                                                 END
		
		
		INNER JOIN SALDOS AS S WITH (nolock) ON
			S.JTS_OID = DCO.SALDO_JTS_OID
			AND ((S.TZ_LOCK < 100000000000000 OR S.TZ_LOCK >= 200000000000000)
				AND (S.TZ_LOCK < 300000000000000 OR S.TZ_LOCK >= 400000000000000)
			)
		INNER JOIN CI_FACTURA AS F WITH(nolock) ON
			F.SUCURSAL_ASIENTO = D.MOV_SUCURSAL
			AND F.FECHA_PROCESO_ASIENTO = D.MOV_FECHA_PROCESO
			AND F.ASIENTO = D.MOV_ASIENTO
			AND ((F.TZ_LOCK < 100000000000000 OR F.TZ_LOCK >= 200000000000000)
				AND (F.TZ_LOCK < 300000000000000 OR F.TZ_LOCK >= 400000000000000)
			)
			AND F.JTS_SALDO_CLIENTE = (
				SELECT JTS_OID 
				FROM SALDOS AS SAL WITH(nolock)
				WHERE
					SAL.SUCURSAL = D.SALDO_ORIG_SUCURSAL
					AND SAL.CUENTA = D.SALDO_ORIG_CUENTA
					AND SAL.MONEDA = D.SALDO_ORIG_MONEDA
					AND SAL.PRODUCTO = D.SALDO_ORIG_PRODUCTO
					AND SAL.OPERACION = D.SALDO_ORIG_OPERACION
					AND SAL.ORDINAL = D.SALDO_ORIG_ORDINAL
					AND ((SAL.TZ_LOCK < 100000000000000 OR SAL.TZ_LOCK >= 200000000000000)
						AND (SAL.TZ_LOCK < 300000000000000 OR SAL.TZ_LOCK >= 400000000000000)
					)
			)
		INNER JOIN CI_FACTURA_LINEA AS FL WITH(nolock) ON
			FL.ASIENTO = D.MOV_ASIENTO
			AND FL.SUCURSAL_ASIENTO = D.MOV_SUCURSAL
			AND FL.FECHA_PROCESO_ASIENTO = D.MOV_FECHA_PROCESO
			AND FL.ORDINAL_MOVIMIENTO = F.ORDINAL_MOVIMIENTO
			AND FL.TR_REAL = F.TR_REAL
			AND FL.TR_VIRTUAL = F.TR_VIRTUAL
			AND FL.TR_TIPO = F.TR_TIPO
			AND (FL.ID_CARGO = D.CARGOS_ID_CARGO
				OR FL.ID_IMPUESTO = D.CARGOS_ID_IMPUESTO)
			AND ((FL.TZ_LOCK < 100000000000000 OR FL.TZ_LOCK >= 200000000000000)
				AND (FL.TZ_LOCK < 300000000000000 OR FL.TZ_LOCK >= 400000000000000)
			)
		INNER JOIN MONEDAS AS MON WITH(nolock) ON
			MON.C6399 = D.MOV_MONEDA
			AND ((MON.TZ_LOCK < 100000000000000 OR MON.TZ_LOCK >= 200000000000000)
				AND (MON.TZ_LOCK < 300000000000000 OR MON.TZ_LOCK >= 400000000000000)
			)
		INNER JOIN CON_EQUIVALENCIA_CARGO_IMPOSITIVO AS E WITH(nolock) ON
			(    
				(E.CARGO_O_IMPUESTO = ''I''
					AND E.TIPO_IMPUESTO = (	SELECT TOP 1 TIPO_IMPUESTO
		                                	FROM CI_IMPUESTOS AS CI WITH(nolock)
		                                	WHERE
		                                    	CI.ID_IMPUESTO = D.CARGOS_ID_IMPUESTO
		                                    	AND CI.FECHADESDE <= (SELECT FECHAPROCESO FROM PARAMETROS WITH(nolock))
												AND ((CI.TZ_LOCK < 100000000000000 OR CI.TZ_LOCK >= 200000000000000)
													AND (CI.TZ_LOCK < 300000000000000 OR CI.TZ_LOCK >= 400000000000000)  
												)
											ORDER BY CI.FECHADESDE DESC
		                            		)
		        ) 
		        OR     
				(E.CARGO_O_IMPUESTO = ''C''
					AND E.TIPO_CARGO_IMPOSITIVO = (	SELECT TIPO_CARGO_IMPOSITIVO 
				                                	FROM CI_CARGOS AS CC WITH(nolock)
				                                	WHERE
				                                    	CC.ID_CARGO = D.CARGOS_ID_CARGO
														AND ((CC.TZ_LOCK < 100000000000000 OR CC.TZ_LOCK >= 200000000000000)
															AND (CC.TZ_LOCK < 300000000000000 OR CC.TZ_LOCK >= 400000000000000)  
														)
				                            		)
		       )
		    )
			AND ((E.TZ_LOCK < 100000000000000 OR E.TZ_LOCK >= 200000000000000)
				AND (E.TZ_LOCK < 300000000000000 OR E.TZ_LOCK >= 400000000000000)
			)
		INNER JOIN CON_REGIMEN_CERTIF_RET AS CR WITH(nolock) ON 
			CR.TIPO_CARGO_IMPOSITIVO = E.TIPO_CARGO_IMPOSITIVO
			AND ((CR.TZ_LOCK < 100000000000000 OR CR.TZ_LOCK >= 200000000000000)
				AND (CR.TZ_LOCK < 300000000000000 OR CR.TZ_LOCK >= 400000000000000)
			)
			AND CR.VIGENCIA_DESDE = (	SELECT TOP 1 VIGENCIA_DESDE
										FROM CON_REGIMEN_CERTIF_RET
										WHERE
											TIPO_CARGO_IMPOSITIVO = CR.TIPO_CARGO_IMPOSITIVO
											AND VIGENCIA_DESDE <= (SELECT FECHAPROCESO FROM PARAMETROS WITH(nolock))
											AND ((TZ_LOCK < 100000000000000 OR TZ_LOCK >= 200000000000000)
												AND (TZ_LOCK < 300000000000000 OR TZ_LOCK >= 400000000000000)
											)
										ORDER BY VIGENCIA_DESDE DESC
									)
									
		LEFT JOIN CON_COTIZACIONES_BNA	CB ON CB.Moneda = m.MONEDA
		                                     AND cb.TZ_LOCK = 0 
		                                     AND CB.Fecha_Cotizacion = CASE WHEN (SELECT Fecha_Cotizacion FROM CON_COTIZACIONES_BNA CB2
		                                                                        WHERE CB2.TZ_LOCK = 0 AND CB2.Moneda = m.moneda
		                                                                        AND CB2.Fecha_Cotizacion = (SELECT dbo.diaHabil(fechaProceso-1, ''A'') FROM PARAMETROS)) IS NULL
		                                                                 THEN (SELECT Fecha_Cotizacion FROM CON_COTIZACIONES_BNA CB2
		                                                                        WHERE CB2.TZ_LOCK = 0 AND CB2.Moneda = m.moneda
		                                                                        AND CB2.Fecha_Cotizacion = (SELECT dbo.diaHabil(max(Fecha_Cotizacion), ''A'') 
		                                                                                                      FROM CON_COTIZACIONES_BNA WHERE TZ_LOCK = 0 AND Moneda = m.moneda
		                                                                                                      AND Fecha_Cotizacion<(SELECT fechaproceso FROM PARAMETROS)))
		                                                                 ELSE
		                                                                      (SELECT dbo.diaHabil(fechaProceso-1, ''A'') FROM PARAMETROS)
		                                                                 END
		                                     		
									
									
		LEFT JOIN PZO_SALDOS AS PS WITH(nolock) ON
			PS.JTS_OID_SALDO = S.JTS_OID
			AND ((PS.TZ_LOCK < 100000000000000 OR PS.TZ_LOCK >= 200000000000000)
				AND (PS.TZ_LOCK < 300000000000000 OR PS.TZ_LOCK >= 400000000000000)
			)
		LEFT JOIN CON_CERTIFICADOS_RETENCION AS C WITH(nolock) ON
			C.TIPO_CARGO_IMPOSITIVO = E.TIPO_CARGO_IMPOSITIVO
			AND C.NRO_CERTIFICADO = (	SELECT TOP 1 NRO_CERTIFICADO
										FROM CON_CERTIFICADOS_RETENCION
										WHERE
											TIPO_CARGO_IMPOSITIVO = C.TIPO_CARGO_IMPOSITIVO
											--SIN CONTROLAR TZ_LOCK PARA NO INSERTAR DUPLICADOS POTENCIALMENTE
										ORDER BY RIGHT(NRO_CERTIFICADO, 6) DESC
									)
		WHERE
			D.MOV_SIGNO = ''C''
		    
		    AND NOT EXISTS (
				SELECT *
		        FROM CON_CERTIFICADOS_RETENCION AS CER WITH(nolock)
				WHERE
					CER.ASIENTO = D.MOV_ASIENTO
					AND CER.SUCURSAL_ASIENTO = D.MOV_SUCURSAL
					AND CER.FECHA_ASIENTO = D.MOV_FECHA_PROCESO
					AND (CER.ID_CARGO = D.CARGOS_ID_CARGO
						OR CER.ID_CARGO = D.CARGOS_ID_IMPUESTO
					)
					AND ((CER.TZ_LOCK < 100000000000000 OR CER.TZ_LOCK >= 200000000000000)
						AND (CER.TZ_LOCK < 300000000000000 OR CER.TZ_LOCK >= 400000000000000)
					)
				   
			)
		ORDER BY
			E.TIPO_CARGO_IMPOSITIVO,
			M.SUCURSAL,
			M.FECHAPROCESO,
			M.ASIENTO
		
   		

		SELECT @CANT= @@ROWCOUNT
		
	END
		
		SET @P_RET_PROCESO = 1
		SET @P_MSG_PROCESO = ''Certificados de Retención funcionó correctamente. Se pasaron ''+ ISNULL(CAST(@CANT AS nvarchar(max)), '''') + '' registros.''
		
		EXECUTE dbo.pkg_constantes$VarcharConstantes ''C_LOG_TIPO_INFORMACION'', @v_constante OUTPUT;
		
		EXECUTE dbo.PKG_LOG_PROCESO$PROC_INS_LOG_PROCESO 
			@P_ID_PROCESO = @P_ID_PROCESO, 
			@P_FCH_PROCESO = @P_DT_PROCESO, 
			@P_NOM_PACKAGE = ''PA_CERTIFICADOS_RETENCION'', 
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
			
			EXECUTE dbo.pkg_constantes$VarcharConstantes ''C_LOG_TIPO_ERROR'', @v_constante OUTPUT;
			
			EXECUTE dbo.PKG_LOG_PROCESO$proc_ins_log_proceso 
				@p_id_proceso = @p_id_proceso, 
				@p_fch_proceso = @p_dt_proceso, 
				@p_nom_package = ''PA_CERTIFICADOS_RETENCION'', 
				@p_cod_error = @p_ret_proceso, 
				@p_msg_error = @p_msg_proceso, 
				@p_tipo_error = @v_constante

		END
	
	END CATCH

END
')
