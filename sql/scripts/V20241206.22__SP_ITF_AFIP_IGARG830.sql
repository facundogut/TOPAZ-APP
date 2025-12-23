ALTER     PROCEDURE dbo.[SP_ITF_AFIP_IGARG830]
	@usuario varchar(50),
	@archivo VARCHAR(100)
AS
BEGIN 

--inserto en bitacora las bajas de los registgros que no vinieron en el nuevo padron
	
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
													archivo_padron,
													valor_exclusion,
													cod_usuario,
													num_certificado,
													CONDICION
													)
											SELECT  ISNULL((SELECT MAX(JTS_NOVEDAD) FROM CON_BITACORA_IMPUESTOS),0)+ (ROW_NUMBER() OVER (ORDER BY VV.TIPOCARGO)), 
													(SELECT FECHAPROCESO FROM PARAMETROS (NOLOCK)), 
													(select convert(varchar,getdate(),108)), 
													 a.ID_CLIENTE, 
													C.NUMEROPERSONA, 
													'C', 
													V.NUMERODOC, 
													VV.tipocargo, 
													0, 
													a.FECHA_DESDE, 
													a.FECHA_HASTA,
													--car.id_cargo,
													(SELECT SUCURSALvinculada FROM CLI_CLIENTES WHERE codigocliente=a.ID_CLIENTE AND TZ_LOCK=0),
													'B',
													substring(@archivo,1,30),
													a.porcentaje,
													@usuario,
													a.certificado,
													VV.SEGMENTO
	FROM ITF_IGARG830_PERCEPCION_ULT_PADRON_AUX A  							
	INNER JOIN CLI_ClientePersona c ON A.ID_CLIENTE=c.CODIGOCLIENTE
	INNER JOIN CI_CARGOS_TARIFAS CAR ON A.ID_CLIENTE=car.ID_CLIENTE
	INNER JOIN VW_CLIENTES_PERSONAS V ON V.NUMEROPERSONA=C.NUMEROPERSONA 
	INNER JOIN VW_CARGOS_IMPUESTOS_IGARG830 VV ON vv.id_cargo= CAr.id_cargo								
	WHERE a.ID_CLIENTE NOT IN (SELECT VW.CODIGOCLIENTE
						 		FROM VW_CLIENTES_PERSONAS VW, ITF_AFIP_IGARG830 RG
						 		WHERE VW.NUMERODOC=RG.CUIT
						 		AND VW.TITULARIDAD='T')
	--AND CAR.fecha_hasta IS NOT NULL 
	AND C.TZ_LOCK=0
	AND car.TZ_LOCK=0
	AND vv.segmento=(SELECT iga FROM CLI_CLIENTES WHERE codigocliente=A.ID_CLIENTE AND TZ_LOCK=0)
	GROUP BY vv.TIPOCARGO,a.ID_CLIENTE,C.NUMEROPERSONA,V.NUMERODOC,a.FECHA_DESDE,a.FECHA_HASTA,a.certificado,a.porcentaje,vv.TASA,VV.SEGMENTO
	
	--limpio tablas

	DELETE ci 
	FROM CI_CARGOS_TARIFAS ci
	INNER JOIN VW_CARGOS_IMPUESTOS_IGARG830 vw ON ci.ID_CARGO=vw.ID_CARGO
	WHERE RANGO_HASTA =9999999999996
	AND vw.segmento=(SELECT iga FROM CLI_CLIENTES WHERE CODIGOCLIENTE=ci.ID_CLIENTE AND TZ_LOCK=0) 
	AND ci.ID_CLIENTE!=0
	--AND ci.FECHA_HASTA IS NOT NULL    
	
	TRUNCATE TABLE ITF_IGARG830_PERCEPCION_ULT_PADRON_AUX	

 	--cargo tabla con nuevo padron

	INSERT INTO dbo.ITF_IGARG830_PERCEPCION_ULT_PADRON_AUX
		(
		PERIODO
		, CERTIFICADO
		, CUIT
		, RAZON_SOCIAL
		, PERIODO_FISCAL
		, PORCENTAJE
		, RESOLUCION
		, FECHA_DESDE
		, FECHA_HASTA
		, FECHA_PROCESO
		, ID_CLIENTE
   		)
	SELECT 
		RG.PERIODO
		, RG.CERTIFICADO
		, RG.CUIT
		, RG.RAZON_SOCIAL
		, RG.PERIODO_FISCAL
		, RG.PORCENTAJE
		, RG.RESOLUCION
		, RG.FECHA_DESDE
		, RG.FECHA_HASTA
		, RG.FECHA_PROCESO
		, VW.CODIGOCLIENTE
	FROM VW_CLIENTES_PERSONAS VW, ITF_AFIP_IGARG830 RG
	WHERE VW.NUMERODOC=RG.CUIT
	AND VW.TITULARIDAD='T'


	DELETE ci 
	FROM CI_CARGOS_TARIFAS ci
	INNER JOIN ITF_IGARG830_PERCEPCION_ULT_PADRON_AUX vw ON ci.ID_Cliente=vw.ID_Cliente
	WHERE RANGO_HASTA = 9999999999995
	AND ci.TZ_LOCK=0

	--doy de alta los registros que vienen en el nuevo padron
	
	INSERT INTO dbo.CI_CARGOS_TARIFAS (ID_CARGO, 
										MONEDA, 
										ID_CLIENTE, 
										SEGMENTO, 
										FECHA_DESDE, 
										FECHA_HASTA,
										tasa,
										rango_hasta,
										MONEDA_importe) 
	SELECT vw.ID_CARGO, 
		   vw.MONEDA, 
		   a.ID_CLIENTE, 
		   vw.segmento, 
		   a.FECHA_DESDE, 
			a.FECHA_HASTA,
			vw.TASA*(1-(A.PORCENTAJE/100)),
			9999999999996,
			vw.MONEDA
	FROM VW_CARGOS_IMPUESTOS_IGARG830 vw, ITF_IGARG830_PERCEPCION_ULT_PADRON_AUX a, CLI_CLIENTES c
	WHERE a.ID_CLIENTE=c.CODIGOCLIENTE
	AND vw.segmento=c.IGA
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
													valor_exclusion,
													cod_usuario,
													num_certificado,
													CONDICION)
   SELECT  ISNULL((SELECT MAX(JTS_NOVEDAD) FROM CON_BITACORA_IMPUESTOS),0)+ (ROW_NUMBER() OVER (ORDER BY VV.TIPOCARGO)), 
													(SELECT FECHAPROCESO FROM PARAMETROS (NOLOCK)), 
													(select convert(varchar,getdate(),108)), 
													 a.ID_CLIENTE, 
													C.NUMEROPERSONA, 
													'C', 
													V.NUMERODOC, 
													VV.tipocargo, 
													0, 
													a.FECHA_DESDE, 
													a.FECHA_HASTA,
													--car.id_cargo,
													CLI.sucursalvinculada,
													'A',
													substring(@archivo,1,30),
													a.porcentaje,
												   	@usuario,
													a.CERTIFICADO ,
													VV.SEGMENTO
																										 
	FROM ITF_IGARG830_PERCEPCION_ULT_PADRON_AUX A  							
	INNER JOIN CLI_ClientePersona c ON A.ID_CLIENTE=c.CODIGOCLIENTE
	INNER JOIN CLI_CLIENTES CLI ON CLI.codigocliente=c.codigocliente
	INNER JOIN CI_CARGOS_TARIFAS CAR ON A.ID_CLIENTE=car.ID_CLIENTE
	INNER JOIN VW_CLIENTES_PERSONAS V ON V.NUMEROPERSONA=C.NUMEROPERSONA 
	INNER JOIN VW_CARGOS_IMPUESTOS_IGARG830 VV ON vv.id_cargo= CAr.id_cargo							
	WHERE C.TZ_LOCK=0
	--AND CAR.fecha_hasta IS NOT NULL 
	AND car.TZ_LOCK=0
	AND cli.estado=0
	AND vv.segmento=CLI.iga
	AND cli.tz_lock=0
	AND V.titularidad='T'
	AND c.titularidad='T'
	GROUP BY vv.TIPOCARGO,a.ID_CLIENTE,C.NUMEROPERSONA, V.NUMERODOC,a.FECHA_DESDE,a.FECHA_HASTA,a.certificado,a.porcentaje,vv.TASA,VV.SEGMENTO,CLI.sucursalvinculada


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
		   CONVERT(VARCHAR(8), a.FECHA_DESDE, 112), 
		   CONVERT(VARCHAR(8), a.FECHA_HASTA, 112),
		   a.ID_CLIENTE, 
		   c.NUMEROPERSONA, 
		   CONVERT(VARCHAR(8),(SELECT FECHAPROCESO FROM PARAMETROS (NOLOCK)), 112), 
		   CONVERT(VARCHAR(8), GETDATE(), 112),
		   vv.SEGMENTO,
		   VV.TASA*(1-A.PORCENTAJE/100) 
	 FROM ITF_IGARG830_PERCEPCION_ULT_PADRON_AUX A  							
	 INNER JOIN CLI_ClientePersona c ON A.ID_CLIENTE=c.CODIGOCLIENTE
	 INNER JOIN CLI_CLIENTES cli ON cli.codigocliente=c.codigocliente
	 INNER JOIN CI_CARGOS_TARIFAS CAR ON A.ID_CLIENTE=car.ID_CLIENTE
	 INNER JOIN VW_CLIENTES_PERSONAS V ON V.NUMEROPERSONA=C.NUMEROPERSONA 
	 INNER JOIN VW_CARGOS_IMPUESTOS_IGARG830 VV ON vv.id_cargo= CAr.id_cargo							
	 WHERE C.TZ_LOCK=0
	 AND car.TZ_LOCK=0
	 aND cli.estado=0
	 AND VV.segmento=cli.IGA
	 AND cli.TZ_LOCK=0
	 AND V.titularidad='T'
	 AND c.titularidad='T'
	 --AND CAR.fecha_hasta IS NOT NULL 
	 GROUP BY vv.TIPOCARGO,vv.SEGMENTO,a.ID_CLIENTE,C.NUMEROPERSONA, V.NUMERODOC,a.FECHA_DESDE,a.FECHA_HASTA,VV.TASA,A.PORCENTAJE

UPDATE dbo.NUMERATORVALUES
SET VALOR = (SELECT max(jts_novedad) FROM CON_BITACORA_IMPUESTOS)+1
WHERE DIA = 0 AND MES = 0 AND ANIO = 0 AND SUCURSAL = 0 AND NUMERO = 66319

END
GO

