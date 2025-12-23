execute('create or ALTER     PROCEDURE dbo.[SP_AFIP_IVA_RG18]
	@usuario varchar(50)
AS
BEGIN
	--NUEVO BLOQUE JI 17/05/2024--


	--inserto en bitacora las bajas de los registgros que no vinieron en el nuevo padron
	
			INSERT INTO dbo.CON_BITACORA_IMPUESTOS (JTS_NOVEDAD, --n
													FECHA_PROCESO, 
													HORA, 
													ID_CLIENTE, --n
													ID_PERSONA, --n
													TIPO_ID, 
													CUIT, --n
													TIPO_CARGO_IMPOSITIVO,  --n
													ALICUOTA, 
													FECHA_INICIO, 
													FECHA_FIN,
													--id_cargo_impuesto,
													sucursal, --n
													tipo_novedad,
													archivo_padron,
													cod_usuario,
													CONDICION,
													num_certificado,
													valor_exclusion)
											SELECT  ISNULL((SELECT MAX(JTS_NOVEDAD) FROM CON_BITACORA_IMPUESTOS),0)+ (ROW_NUMBER() OVER (ORDER BY VV.TIPOCARGO)), 
													(SELECT FECHAPROCESO FROM PARAMETROS (NOLOCK)), 
													(select convert(varchar,getdate(),108)), 
													 a.ID_CLIENTE, 
													C.NUMEROPERSONA, 
													''C'', 
													try_convert(NUMERIC,V.NUMERODOC), 
													VV.tipocargo, 
													0, 
													a.PERIODO_DESDE, 
													a.PERIODO_HASTA,
													--car.id_cargo,
													(SELECT SUCURSALvinculada FROM CLI_CLIENTES WHERE codigocliente=a.ID_CLIENTE AND TZ_LOCK=0),
													''B'',
													''RG18.CSV'',
													@usuario,
													VV.SEGMENTO,
													''ITF'',
													100
						FROM ITF_IVARG18_PERCEPCION_ULT_PADRON_AUX A  							
						INNER JOIN CLI_ClientePersona c ON A.ID_CLIENTE=c.CODIGOCLIENTE
						INNER JOIN CI_CARGOS_TARIFAS CAR ON A.ID_CLIENTE=car.ID_CLIENTE
						INNER JOIN VW_CLIENTES_PERSONAS V ON V.NUMEROPERSONA=C.NUMEROPERSONA 
						INNER JOIN VW_CARGOS_IMPUESTOS VV ON vv.id_cargo= CAr.id_cargo								
						WHERE a.ID_CLIENTE NOT IN (SELECT try_convert(NUMERIC,VW.CODIGOCLIENTE)
						 					   FROM VW_CLIENTES_PERSONAS VW, ITF_AFIP_IVA_RG18 RG
						 					   WHERE try_convert(NUMERIC,VW.NUMERODOC)=RG.CUIT
						 					   AND VW.TITULARIDAD=''T'')
						AND C.TZ_LOCK=0
						AND car.TZ_LOCK=0
						--AND imp.TZ_LOCK=0
						GROUP BY vv.TIPOCARGO,a.ID_CLIENTE,C.NUMEROPERSONA,V.NUMERODOC,a.PERIODO_DESDE,a.PERIODO_HASTA,VV.SEGMENTO



 --limpio tablas

	DELETE ci FROM CI_CARGOS_TARIFAS ci
	INNER JOIN VW_CARGOS vw ON ci.ID_CARGO=vw.ID_CARGO
	WHERE RANGO_HASTA=9999999999998
	AND vw.TIPOCARGO IN (2,3)
	AND ci.ID_CLIENTE!=0
	
	DELETE ci FROM CI_IMPUESTOS_TARIFAS ci
	INNER JOIN vw_impuestos vw ON ci.ID_IMPUESTO=vw.ID_IMPUESTO
	WHERE RANGO_HASTA=9999999999998 
	AND vw.TIPOCARGO IN (2,3)
	AND ci.ID_CLIENTE != 0
	
	TRUNCATE TABLE ITF_IVARG18_PERCEPCION_ULT_PADRON_AUX

 --cargo tabla con nuevo padron

	INSERT INTO ITF_IVARG18_PERCEPCION_ULT_PADRON_AUX (PERIODO_DESDE, 
											   	   		PERIODO_HASTA, 
											   	   		INCISO_RESOLUCION_GRAL,
											   	   		RAZON_SOCIAL, 
											   	   		ID_CLIENTE)
											SELECT DISTINCT RG.PERIODO_DESDE, 
	   												RG.PERIODO_HASTA, 
	   												RG.INCISO_RESOLUCION_GRAL, 
	   												RG.RAZON_SOCIAL,
	   												VW.CODIGOCLIENTE
											FROM VW_CLIENTES_PERSONAS VW, ITF_AFIP_IVA_RG18 RG
											WHERE try_convert(NUMERIC,VW.NUMERODOC)=RG.CUIT
											AND VW.TITULARIDAD=''T''
	
	
	--doy de alta los registros que vienen en el nuevo padron
	
					INSERT INTO dbo.CI_CARGOS_TARIFAS (ID_CARGO, 
												   		MONEDA, 
												   		ID_CLIENTE, 
												   		SEGMENTO, 
												   		FECHA_DESDE, 
												   		FECHA_HASTA,
												   		tasa,
												   		rango_hasta,
												   		MONEDA_IMPORTE) 
					SELECT vw.ID_CARGO, 
					   		vw.MONEDA, 
					   		a.ID_CLIENTE, 
					   		vw.segmento, 
					   		a.PERIODO_DESDE, 
					   		a.PERIODO_HASTA,
					   		0,
					   		9999999999998,
					   		vw.MONEDA
					FROM VW_CARGOS vw, ITF_IVARG18_PERCEPCION_ULT_PADRON_AUX a, CLI_CLIENTES c
					WHERE a.ID_CLIENTE=c.CODIGOCLIENTE
					AND c.ESTADO=0 
					AND c.TZ_LOCK=0	
	
	
					INSERT INTO dbo.CI_impuestoS_TARIFAS (ID_impuesto, 
												   		MONEDA, 
												   		ID_CLIENTE, 
												   		SEGMENTO, 
												   		FECHA_DESDE, 
												   		FECHA_HASTA,
												   		tasa,
												   		rango_hasta,
												   		MONEDA_IMPORTE,
												   		IMPORTE_APLICAR) 
					SELECT vw.ID_impuesto, 
					   		vw.MONEDA, 
					   		a.ID_CLIENTE, 
					   		vw.segmento, 
					   		a.PERIODO_DESDE, 
					   		a.PERIODO_HASTA,
					   		0,
					   		9999999999998,
					   		vw.MONEDA,
					   		0
					FROM VW_impuestOS vw, ITF_IVARG18_PERCEPCION_ULT_PADRON_AUX a, CLI_CLIENTES c
					WHERE a.ID_CLIENTE=c.CODIGOCLIENTE
					AND c.ESTADO=0 
					AND c.TZ_LOCK=0		
	
	
   --inserto en bitacora Altas de cargos y de impuestos	
	
						INSERT INTO dbo.CON_BITACORA_IMPUESTOS (JTS_NOVEDAD, 
													FECHA_PROCESO, 
													HORA, 
													ID_CLIENTE, 
													ID_PERSONA,
													TIPO_ID, 
													CUIT, 
													TIPO_CARGO_IMPOSITIVO, 
													ALICUOTA, 
													FECHA_INICIO, 
													FECHA_FIN,
													--id_cargo_impuesto,
													sucursal,
													tipo_novedad,
													ARCHIVO_PADRON,
													cod_usuario,
													CONDICION,
													num_certificado,
													valor_exclusion)
											SELECT  ISNULL((SELECT MAX(JTS_NOVEDAD) FROM CON_BITACORA_IMPUESTOS),0)+ (ROW_NUMBER() OVER (ORDER BY VV.TIPOCARGO)), 
													(SELECT FECHAPROCESO FROM PARAMETROS (NOLOCK)), 
													(select convert(varchar,getdate(),108)), 
													 a.ID_CLIENTE, 
													C.NUMEROPERSONA, 
													''C'', 
													V.NUMERODOC, 
													VV.tipocargo, 
													0, 
													a.PERIODO_DESDE, 
													a.PERIODO_HASTA,
													--car.id_cargo,
													(SELECT SUCURSALvinculada FROM CLI_CLIENTES WHERE codigocliente=a.ID_CLIENTE AND TZ_LOCK=0),
													''A'',
													''RG18.CSV'',
													@usuario,
													VV.SEGMENTO,
													''ITF'',
													100
						FROM ITF_IVARG18_PERCEPCION_ULT_PADRON_AUX A  							
						INNER JOIN CLI_ClientePersona c ON A.ID_CLIENTE=c.CODIGOCLIENTE
						INNER JOIN CLI_CLIENTES cli ON cli.codigocliente=c.codigocliente
						INNER JOIN CI_CARGOS_TARIFAS CAR ON A.ID_CLIENTE=car.ID_CLIENTE
						INNER JOIN VW_CLIENTES_PERSONAS V ON V.NUMEROPERSONA=C.NUMEROPERSONA 
						INNER JOIN VW_CARGOS_IMPUESTOS VV ON vv.id_cargo= CAr.id_cargo							
						WHERE C.TZ_LOCK=0
						AND car.TZ_LOCK=0
						AND cli.ESTADO=0
						AND cli.TZ_LOCK=0
						GROUP BY vv.TIPOCARGO,a.ID_CLIENTE,C.NUMEROPERSONA, V.NUMERODOC,a.PERIODO_DESDE,a.PERIODO_HASTA,VV.SEGMENTO


					--inserto en el log los cargos faltantes	SE INSERTA UNO POR TIPO DE CARGO AGRUPAR POR CARGO
			INSERT INTO dbo.ITF_LOG_CARGOS_IMPUESTOS (COD_IMPUESTO,
														PERIODO_DESDE,  
														PERIODO_HASTA, 
														COD_CLIENTE, 
														ID_PERSONA, 
														FECHA_PROCESO, 
														FECHA_EJECUCION, 
														CONDICION, 
														ALICUOTA)
												SELECT vv.TIPOCARGO, 
					   									CONVERT(VARCHAR(8), a.PERIODO_DESDE, 112), 
					   									CONVERT(VARCHAR(8), a.PERIODO_HASTA, 112),
												   		a.ID_CLIENTE, 
												   		c.NUMEROPERSONA, 
												   		CONVERT(VARCHAR(8),(SELECT FECHAPROCESO FROM PARAMETROS (NOLOCK)), 112), 
												   		CONVERT(VARCHAR(8), GETDATE(), 112),
												   		vv.SEGMENTO,
												   		0 
						FROM ITF_IVARG18_PERCEPCION_ULT_PADRON_AUX A  							
						INNER JOIN CLI_ClientePersona c ON A.ID_CLIENTE=c.CODIGOCLIENTE
						INNER JOIN CLI_CLIENTES cli ON cli.codigocliente=c.codigocliente
						INNER JOIN CI_CARGOS_TARIFAS CAR ON A.ID_CLIENTE=car.ID_CLIENTE
						INNER JOIN VW_CLIENTES_PERSONAS V ON V.NUMEROPERSONA=C.NUMEROPERSONA 
						INNER JOIN VW_CARGOS_IMPUESTOS VV ON vv.id_cargo= CAr.id_cargo							
						WHERE C.TZ_LOCK=0
						AND car.TZ_LOCK=0
						AND cli.ESTADO=0
						AND cli.TZ_LOCK=0
						GROUP BY vv.TIPOCARGO,vv.SEGMENTO,a.ID_CLIENTE,C.NUMEROPERSONA, V.NUMERODOC,a.PERIODO_DESDE,a.PERIODO_HASTA

		   			 		   
			--para el reporte de inconsistencias		 
			   	INSERT INTO ITF_AFIP_RG18_INCONSISTENCIAS (COD_CLIENTE, 
			   											   NRO_PERSONA, 
			   											   CUIT, 
			   											   RAZON_SOCIAL, 
			   											   CONDICION_IVA, 
			   											   TIPO_CERTIFICADO,	
			   											   PORCENTAJE,	
			   											   FECHA_DESDE,
			   											   FECHA_HASTA,
			   											   COMENTARIO)
				SELECT DISTINCT a.ID_CLIENTE, 
						v.NUMEROPERSONA, 
						v.NUMERODOC, 
						a.RAZON_SOCIAL,  
						cli.IVA,
						''RG18'' , 
						0,
						CONVERT(VARCHAR(10),a.PERIODO_DESDE, 103), 
						CONVERT(VARCHAR(10),a.PERIODO_HASTA, 103),
						''INCONSISTENCIA''
						FROM ITF_IVARG18_PERCEPCION_ULT_PADRON_AUX A  							
						INNER JOIN CLI_ClientePersona c ON A.ID_CLIENTE=c.CODIGOCLIENTE
						INNER JOIN VW_CLIENTES_PERSONAS V ON V.NUMEROPERSONA=C.NUMEROPERSONA 
						INNER JOIN cli_clientes cli ON cli.CODIGOCLIENTE=a.ID_CLIENTE							
						WHERE C.TZ_LOCK=0
						AND cli.TZ_LOCK=0
						AND (cli.IVA<>''AC'' OR cli.ESTADO!=0)
			   		
	
END');