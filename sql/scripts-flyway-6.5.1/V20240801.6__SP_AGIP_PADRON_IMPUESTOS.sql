ALTER     PROCEDURE [dbo].[SP_AGIP_PADRON_IMPUESTOS] 
	@usuario varchar(50),
	@ARCHIVO VARCHAR(50) 
AS



BEGIN	
	   --BAJAS-- 
	--**percepcion**	   			
	INSERT INTO CON_BITACORA_IMPUESTOS (JTS_NOVEDAD
										, TIPO_NOVEDAD
										, OPERACION_TOPAZ
										, FECHA_PROCESO
										, HORA
										, ASIENTO
										, COD_USUARIO
										, ARCHIVO_PADRON
										, NUM_CERTIFICADO
										, F_EMISION
										, SUCURSAL
										, ID_CLIENTE
										, ID_PERSONA
										, TIPO_ID
										, CUIT
										, TIPO_CARGO_IMPOSITIVO
										, TABLA_CARGOS_IMPUESTOS
										, ID_CARGO_IMPUESTO
										, CONDICION
										, VALOR_EXCLUSION
										, ALICUOTA
										, VALOR_ALICUOTA_IIBB
										, FECHA_INICIO
										, FECHA_FIN
										, COMENTARIOS
										, CBU)
		SELECT ISNULL((SELECT MAX(JTS_NOVEDAD) FROM CON_BITACORA_IMPUESTOS),0)+ (ROW_NUMBER() OVER (ORDER BY PF.numeroPersonafisica))
								, 'B'
								, 0
								,(SELECT FECHAPROCESO FROM PARAMETROS (NOLOCK))
								, concat(DATEPART(HOUR, GETDATE()),':', DATEPART(MINUTE, GETDATE()),':',DATEPART(SECOND, GETDATE()))
								, 0
								, @USUARIO
							    , @ARCHIVO
								, ''
								, NULL
								, pf.SUC_ALTA
								, NULL--(SELECT TOP 1 CODIGOCLIENTE FROM VW_CLIENTES_PERSONAS WHERE NUMEROPERSONA=PF.NUMEROPERSONAFISICA)
								, PF.numeroPersonafisica  
								, ''
								, D.NUMERODOCUMENTO
								, 8
								, NULL
								, NULL
								, PF.IIBB_CABA_PERCEPCION_COND
								, 0
								, ''
								, PF.IIBB_CABA_PERCEPCION_ALI
								, NULL
								, NULL
								, ''
								, ''
	FROM CLI_PersonasFisicas PF
	LEFT JOIN CLI_DocumentosPFPJ D ON PF.NUMEROPERSONAFISICA=D.NUMEROPERSONAFJ	
	WHERE PF.IIBB_CABA_PERCEPCION_COND NOT IN ('NA', '') 
	AND PF.ESTADO=0
 
	
	--**retencion**
	
		INSERT INTO CON_BITACORA_IMPUESTOS (JTS_NOVEDAD
										, TIPO_NOVEDAD
										, OPERACION_TOPAZ
										, FECHA_PROCESO
										, HORA
										, ASIENTO
										, COD_USUARIO
										, ARCHIVO_PADRON
										, NUM_CERTIFICADO
										, F_EMISION
										, SUCURSAL
										, ID_CLIENTE
										, ID_PERSONA
										, TIPO_ID
										, CUIT
										, TIPO_CARGO_IMPOSITIVO
										, TABLA_CARGOS_IMPUESTOS
										, ID_CARGO_IMPUESTO
										, CONDICION
										, VALOR_EXCLUSION
										, ALICUOTA
										, VALOR_ALICUOTA_IIBB
										, FECHA_INICIO
										, FECHA_FIN
										, COMENTARIOS
										, CBU)
		SELECT ISNULL((SELECT MAX(JTS_NOVEDAD) FROM CON_BITACORA_IMPUESTOS),0)+ (ROW_NUMBER() OVER (ORDER BY PF.numeroPersonafisica))
								, 'B'
								, 0
								,(SELECT FECHAPROCESO FROM PARAMETROS (NOLOCK))
								, concat(DATEPART(HOUR, GETDATE()),':', DATEPART(MINUTE, GETDATE()),':',DATEPART(SECOND, GETDATE()))
								, 0
								, @USUARIO
								, @ARCHIVO
								, ''
								, NULL
								, pf.SUC_ALTA
								, NULL--(SELECT TOP 1 CODIGOCLIENTE FROM VW_CLIENTES_PERSONAS WHERE NUMEROPERSONA=PF.NUMEROPERSONAFISICA)
								, PF.numeroPersonafisica  
								, ''
								, D.NUMERODOCUMENTO
								, 12
								, NULL
								, NULL
								, PF.IIBB_CABA_RETENCION_COND
								, 0
								, ''
								, PF.IIBB_CABA_RETENCION_ALI
								, NULL
								, NULL
								, ''
								, ''
	FROM CLI_PersonasFisicas PF
	LEFT JOIN CLI_DocumentosPFPJ D ON PF.NUMEROPERSONAFISICA=D.NUMEROPERSONAFJ	
	WHERE PF.IIBB_CABA_RETENCION_COND NOT IN ('NA', '') 
	AND PF.ESTADO=0
	
	

	INSERT INTO CON_BITACORA_IMPUESTOS (JTS_NOVEDAD
										, TIPO_NOVEDAD
										, OPERACION_TOPAZ
										, FECHA_PROCESO
										, HORA
										, ASIENTO
										, COD_USUARIO
										, ARCHIVO_PADRON
										, NUM_CERTIFICADO
										, F_EMISION
										, SUCURSAL
										, ID_CLIENTE
										, ID_PERSONA
										, TIPO_ID
										, CUIT
										, TIPO_CARGO_IMPOSITIVO
										, TABLA_CARGOS_IMPUESTOS
										, ID_CARGO_IMPUESTO
										, CONDICION
										, VALOR_EXCLUSION
										, ALICUOTA
										, VALOR_ALICUOTA_IIBB
										, FECHA_INICIO
										, FECHA_FIN
										, COMENTARIOS
										, CBU)
		SELECT ISNULL((SELECT MAX(JTS_NOVEDAD) FROM CON_BITACORA_IMPUESTOS),0)+ (ROW_NUMBER() OVER (ORDER BY PF.numeroPersonajuridica))
								, 'B'
								, 0
								,(SELECT FECHAPROCESO FROM PARAMETROS (NOLOCK))
								, concat(DATEPART(HOUR, GETDATE()),':', DATEPART(MINUTE, GETDATE()),':',DATEPART(SECOND, GETDATE()))
								, 0
								, @USUARIO
								, @ARCHIVO
								, ''
								, NULL
								, pf.SUC_ALTA
								, NULL--(SELECT TOP 1 CODIGOCLIENTE FROM VW_CLIENTES_PERSONAS WHERE NUMEROPERSONA=PF.NUMEROPERSONAJURIDICA)
								, PF.numeroPersonaJURIDICA  
								, ''
								, D.NUMERODOCUMENTO
								, 8
								, NULL
								, NULL
								, PF.IIBB_CORRIENTES_RECAUD
								, 0
								, ''
								, PF.IIBB_CORRIENTES_ALI
								, NULL
								, NULL
								, ''
								, ''
	FROM CLI_PERSONASJURIDICAS PF
	LEFT JOIN CLI_DocumentosPFPJ D ON PF.NUMEROPERSONAJURIDICA=D.NUMEROPERSONAFJ	
	WHERE PF.IIBB_CABA_PERCEPCION_COND NOT IN ('NA', '') 
	AND PF.ESTADO=0


	INSERT INTO CON_BITACORA_IMPUESTOS (JTS_NOVEDAD
										, TIPO_NOVEDAD
										, OPERACION_TOPAZ
										, FECHA_PROCESO
										, HORA
										, ASIENTO
										, COD_USUARIO
										, ARCHIVO_PADRON
										, NUM_CERTIFICADO
										, F_EMISION
										, SUCURSAL
										, ID_CLIENTE
										, ID_PERSONA
										, TIPO_ID
										, CUIT
										, TIPO_CARGO_IMPOSITIVO
										, TABLA_CARGOS_IMPUESTOS
										, ID_CARGO_IMPUESTO
										, CONDICION
										, VALOR_EXCLUSION
										, ALICUOTA
										, VALOR_ALICUOTA_IIBB
										, FECHA_INICIO
										, FECHA_FIN
										, COMENTARIOS
										, CBU)
		SELECT ISNULL((SELECT MAX(JTS_NOVEDAD) FROM CON_BITACORA_IMPUESTOS),0)+ (ROW_NUMBER() OVER (ORDER BY PF.numeroPersonajuridica))
								, 'B'
								, 0
								,(SELECT FECHAPROCESO FROM PARAMETROS (NOLOCK))
								, concat(DATEPART(HOUR, GETDATE()),':', DATEPART(MINUTE, GETDATE()),':',DATEPART(SECOND, GETDATE()))
								, 0
								, @USUARIO
								, @ARCHIVO
								, ''
								, NULL
								, pf.SUC_ALTA
								, NULL--(SELECT TOP 1 CODIGOCLIENTE FROM VW_CLIENTES_PERSONAS WHERE NUMEROPERSONA=PF.NUMEROPERSONAJURIDICA)
								, PF.numeroPersonaJURIDICA  
								, ''
								, D.NUMERODOCUMENTO
								, 12
								, NULL
								, NULL
								, PF.IIBB_CORRIENTES_RECAUD
								, 0
								, ''
								, PF.IIBB_CORRIENTES_ALI
								, NULL
								, NULL
								, ''
								, ''
	FROM CLI_PERSONASJURIDICAS PF
	LEFT JOIN CLI_DocumentosPFPJ D ON PF.NUMEROPERSONAJURIDICA=D.NUMEROPERSONAFJ	
	WHERE PF.IIBB_CABA_RETENCION_COND NOT IN ('NA', '') 
	AND PF.ESTADO=0
	
	

	INSERT INTO CON_BITACORA_IMPUESTOS (JTS_NOVEDAD
										, TIPO_NOVEDAD
										, OPERACION_TOPAZ
										, FECHA_PROCESO
										, HORA
										, ASIENTO
										, COD_USUARIO
										, ARCHIVO_PADRON
										, NUM_CERTIFICADO
										, F_EMISION
										, SUCURSAL
										, ID_CLIENTE
										, ID_PERSONA
										, TIPO_ID
										, CUIT
										, TIPO_CARGO_IMPOSITIVO
										, TABLA_CARGOS_IMPUESTOS
										, ID_CARGO_IMPUESTO
										, CONDICION
										, VALOR_EXCLUSION
										, ALICUOTA
										, VALOR_ALICUOTA_IIBB
										, FECHA_INICIO
										, FECHA_FIN
										, COMENTARIOS
										, CBU)
		SELECT ISNULL((SELECT MAX(JTS_NOVEDAD) FROM CON_BITACORA_IMPUESTOS),0)+ (ROW_NUMBER() OVER (ORDER BY c.codigocliente))
								, 'B'
								, 0
								,(SELECT FECHAPROCESO FROM PARAMETROS (NOLOCK))
								, concat(DATEPART(HOUR, GETDATE()),':', DATEPART(MINUTE, GETDATE()),':',DATEPART(SECOND, GETDATE()))
								, 0
								, @USUARIO
								, @ARCHIVO
								, ''
								, NULL
								, c.SUCURSALVINCULADA
								, C.CODIGOCLIENTE 
								, V.NUMEROPERSONA  
								, ''
								, V.NUMERODOC
								, 8
								, NULL
								, NULL
								, C.IIBB_CABA_PERCEPCION_COND
								, 0
								, ''
								, C.IIBB_CABA_PERCEPCION_ALI
								, NULL
								, NULL
								, ''
								, ''
	FROM cLI_CLIENTES C
	INNER JOIN VW_CLIENTES_PERSONAS V ON C.CODIGOCLIENTE=V.CODIGOCLIENTE
	WHERE c.IIBB_CABA_PERCEPCION_COND NOT IN ('NA', '') 
	AND V.ESTADOCLIENTE=0
	AND V.ESTADOPERSONA=0


	INSERT INTO CON_BITACORA_IMPUESTOS (JTS_NOVEDAD
										, TIPO_NOVEDAD
										, OPERACION_TOPAZ
										, FECHA_PROCESO
										, HORA
										, ASIENTO
										, COD_USUARIO
										, ARCHIVO_PADRON
										, NUM_CERTIFICADO
										, F_EMISION
										, SUCURSAL
										, ID_CLIENTE
										, ID_PERSONA
										, TIPO_ID
										, CUIT
										, TIPO_CARGO_IMPOSITIVO
										, TABLA_CARGOS_IMPUESTOS
										, ID_CARGO_IMPUESTO
										, CONDICION
										, VALOR_EXCLUSION
										, ALICUOTA
										, VALOR_ALICUOTA_IIBB
										, FECHA_INICIO
										, FECHA_FIN
										, COMENTARIOS
										, CBU)
		SELECT ISNULL((SELECT MAX(JTS_NOVEDAD) FROM CON_BITACORA_IMPUESTOS),0)+ (ROW_NUMBER() OVER (ORDER BY c.codigocliente))
								, 'B'
								, 0
								,(SELECT FECHAPROCESO FROM PARAMETROS (NOLOCK))
								, concat(DATEPART(HOUR, GETDATE()),':', DATEPART(MINUTE, GETDATE()),':',DATEPART(SECOND, GETDATE()))
								, 0
								, @USUARIO
								, @ARCHIVO
								, ''
								, NULL
								, c.SUCURSALVINCULADA
								, C.CODIGOCLIENTE 
								, V.NUMEROPERSONA  
								, ''
								, V.NUMERODOC
								, 12
								, NULL
								, NULL
								, C.IIBB_CABA_RETENCION_COND
								, 0
								, ''
								, C.IIBB_CABA_RETENCION_ALI
								, NULL
								, NULL
								, ''
								, ''
	FROM cLI_CLIENTES C
	INNER JOIN VW_CLIENTES_PERSONAS V ON C.CODIGOCLIENTE=V.CODIGOCLIENTE
	WHERE C.IIBB_CABA_RETENCION_COND NOT IN ('NA', '') 
	AND V.ESTADOCLIENTE=0
	AND V.ESTADOPERSONA=0


								
	UPDATE CLI_PersonasFisicas 
	SET	IIBB_CABA_PERCEPCION_COND = 'NA'
		, IIBB_CABA_PERCEPCION_ALI = 0 
		, IIBB_CABA_RETENCION_COND = 'NA'
		, IIBB_CABA_RETENCION_ALI = 0
	WHERE (IIBB_CABA_PERCEPCION_COND NOT IN ('NA', '') OR IIBB_CABA_RETENCION_COND NOT IN ('NA', ''))
	AND ESTADO=0
		
	UPDATE CLI_PERSONASJURIDICAS 
	SET	IIBB_CABA_PERCEPCION_COND = 'NA'
		, IIBB_CABA_PERCEPCION_ALI = 0 
		, IIBB_CABA_RETENCION_COND = 'NA'
		, IIBB_CABA_RETENCION_ALI = 0
	WHERE (IIBB_CABA_PERCEPCION_COND NOT IN ('NA', '') OR IIBB_CABA_RETENCION_COND NOT IN ('NA', ''))
	AND ESTADO=0

	
	UPDATE CLI_CLIENTES 
	SET	IIBB_CABA_PERCEPCION_COND = 'NA'
		, IIBB_CABA_PERCEPCION_ALI = 0 
		, IIBB_CABA_RETENCION_COND = 'NA'
		, IIBB_CABA_RETENCION_ALI = 0
	WHERE (IIBB_CABA_PERCEPCION_COND NOT IN ('NA', '')	OR IIBB_CABA_RETENCION_COND NOT IN ('NA', ''))
	AND ESTADO=0
	
	
	
	---CARGO NUEVO PADRON (ALTAS)-----
	
	UPDATE CLI_PersonasFisicas
	SET IIBB_CABA_PERCEPCION_COND = CASE WHEN convert(NUMERIC(11,7),replace(A.Alicuota_Percepcion,',','.'))=0 THEN 'EX' ELSE 'AC' END
		, IIBB_CABA_PERCEPCION_ALI = convert(NUMERIC(11,7),replace(A.Alicuota_Percepcion,',','.'))  
		, IIBB_CABA_RETENCION_COND = CASE WHEN convert(NUMERIC(11,7),replace(A.Alicuota_RETENCION,',','.'))=0 THEN 'EX' ELSE 'AC' END
		, IIBB_CABA_RETENCION_ALI = convert(NUMERIC(11,7),replace(A.Alicuota_Retencion,',','.'))
	FROM CLI_Personasfisicas PF
	INNER JOIN VW_PERSONAS_FYJ_ACTIVAS p ON pf.NUMEROPERSONAfisica = p.NUMEROPERSONA
	INNER JOIN ITF_AGIP_PADRON_IMPUESTOS_AUX A ON p.NroDocIdent=a.CUIT
	WHERE A.MSj_ERROR='' OR a.msj_error IS NULL
	
	
	
	
	UPDATE CLI_PERSONASJURIDICAS
	SET IIBB_CABA_PERCEPCION_COND = CASE WHEN convert(NUMERIC(11,7),replace(A.Alicuota_Percepcion,',','.'))=0 THEN 'EX' ELSE 'AC' END
		, IIBB_CABA_PERCEPCION_ALI = convert(NUMERIC(11,7),replace(A.Alicuota_Percepcion,',','.')) 
		, IIBB_CABA_RETENCION_COND = CASE WHEN convert(NUMERIC(11,7),replace(A.Alicuota_RETENCION,',','.'))=0 THEN 'EX' ELSE 'AC' END
		, IIBB_CABA_RETENCION_ALI = convert(NUMERIC(11,7),replace(A.Alicuota_Retencion,',','.'))
	FROM CLI_Personasjuridicas PF
	INNER JOIN VW_PERSONAS_FYJ_ACTIVAS p ON pf.NUMEROPERSONAjuridica = p.NUMEROPERSONA
	INNER JOIN ITF_AGIP_PADRON_IMPUESTOS_AUX A ON p.NroDocIdent=a.CUIT
	WHERE A.MSj_ERROR='' OR a.msj_error IS NULL
	
--	UPDATE clientes percepcion
	UPDATE CLI_CLIENTES
	SET IIBB_CABA_PERCEPCION_COND = CASE WHEN convert(NUMERIC(11,7),replace(t.IIBB_CABA_PERCEPCION_ALI,',','.'))=0 THEN 'EX' ELSE 'AC' END
		, IIBB_CABA_PERCEPCION_ALI = t.IIBB_CABA_PERCEPCION_ALI 
	FROM CLI_CLIENTES c
	JOIN (
    	SELECT t.IIBB_CABA_PERCEPCION_ALI, t.IIBB_CABA_RETENCION_ALI, t.PERSONA, t.codigocliente
    	FROM (
        	SELECT DISTINCT CF.IIBB_CABA_PERCEPCION_ALI, CF.NUMEROPERSONAFISICA AS "PERSONA", CF.IIBB_CABA_RETENCION_ALI, v.codigocliente
        	FROM CLI_PERSONASFISICAS CF WITH (NOLOCK)
        	INNER JOIN VW_CLI_PERSONAS p ON cf.NUMEROPERSONAfisica = p.[Numero de Persona]
			INNER JOIN ITF_AGIP_PADRON_IMPUESTOS_AUX A ON p.[Numero de Documento]=a.CUIT
        	INNER JOIN VW_CLIENTES_PERSONAS v ON v.numeropersona = p.[Numero de Persona]
        	WHERE CF.TZ_LOCK = 0
        	        	AND v.estadopersona=0
        	AND v.estadocliente=0
        	AND (A.MSj_ERROR='' OR a.msj_error IS NULL)
          	AND (CF.IIBB_CABA_PERCEPCION_COND != '' OR cf.IIBB_CABA_RETENCION_COND!='')
          	AND CF.NUMEROPERSONAFISICA = (
              	SELECT TOP 1 xx.numeropersonafisica
              	FROM CLI_PERSONASFISICAS xx
              	INNER JOIN VW_CLIENTES_PERSONAS x ON xx.numeropersonafisica = x.NUMEROPERSONA
              	WHERE x.codigocliente = v.codigocliente
              	              	AND x.estadopersona=0
              	AND x.ESTADOCLIENTE=0
              	ORDER BY xx.IIBB_CABA_PERCEPCION_ALI DESC
          		)
        	UNION ALL
        	SELECT DISTINCT CJ.IIBB_CABA_PERCEPCION_ALI, CJ.NUMEROPERSONAJURIDICA AS "PERSONA", CJ.IIBB_CABA_RETENCION_ALI, v.codigocliente
        	FROM CLI_PERSONASJURIDICAS CJ WITH (NOLOCK)
        	INNER JOIN VW_CLI_PERSONAS p ON cj.NUMEROPERSONAjuridica = p.[Numero de Persona]
			INNER JOIN ITF_AGIP_PADRON_IMPUESTOS_AUX A ON p.[Numero de Documento]=a.CUIT
        	INNER JOIN VW_CLIENTES_PERSONAS v ON v.numeropersona = p.[Numero de Persona]
        	WHERE CJ.TZ_LOCK = 0
        	        	AND v.estadopersona=0
        	AND v.estadocliente=0
        	AND (A.MSj_ERROR='' OR a.msj_error IS NULL)
          	AND (CJ.IIBB_CABA_PERCEPCION_COND != '' OR cj.IIBB_CABA_RETENCION_COND!='')
          	AND CJ.NUMEROPERSONAJURIDICA = (
              	SELECT TOP 1 xx.numeropersonajuridica
              	FROM CLI_PERSONASJURIDICAS xx
              	INNER JOIN VW_CLIENTES_PERSONAS x ON xx.numeropersonajuridica = x.NUMEROPERSONA
              	WHERE x.codigocliente = v.codigocliente
              	              	AND x.estadopersona=0
              	AND x.ESTADOCLIENTE=0
              	ORDER BY xx.IIBB_CABA_PERCEPCION_ALI DESC
          		)
    		) t
		) t ON c.codigocliente = t.codigocliente;
		
		
--	UPDATE clientes retencion
	UPDATE CLI_CLIENTES
	SET IIBB_CABA_RETENCION_COND = CASE WHEN convert(NUMERIC(11,7),replace(t.IIBB_CABA_retencion_ALI,',','.'))=0 THEN 'EX' ELSE 'AC' END
		, IIBB_CABA_RETENCION_ALI = t.IIBB_CABA_RETENCION_ALI
	FROM CLI_CLIENTES c
	JOIN (
    	SELECT t.IIBB_CABA_PERCEPCION_ALI, t.IIBB_CABA_RETENCION_ALI, t.PERSONA, t.codigocliente
    	FROM (
        	SELECT DISTINCT CF.IIBB_CABA_PERCEPCION_ALI, CF.NUMEROPERSONAFISICA AS "PERSONA", CF.IIBB_CABA_RETENCION_ALI, v.codigocliente
        	FROM CLI_PERSONASFISICAS CF WITH (NOLOCK)
        	INNER JOIN VW_CLI_PERSONAS p ON cf.NUMEROPERSONAfisica = p.[Numero de Persona]
			INNER JOIN ITF_AGIP_PADRON_IMPUESTOS_AUX A ON p.[Numero de Documento]=a.CUIT
        	INNER JOIN VW_CLIENTES_PERSONAS v ON v.numeropersona = p.[Numero de Persona]
        	WHERE CF.TZ_LOCK = 0
        	        	AND v.estadopersona=0
        	AND v.estadocliente=0
        	AND (A.MSj_ERROR='' OR a.msj_error IS NULL)
          	AND (CF.IIBB_CABA_PERCEPCION_COND != '' OR cf.IIBB_CABA_RETENCION_COND!='')
          	AND CF.NUMEROPERSONAFISICA = (
              	SELECT TOP 1 xx.numeropersonafisica
              	FROM CLI_PERSONASFISICAS xx
              	INNER JOIN VW_CLIENTES_PERSONAS x ON xx.numeropersonafisica = x.NUMEROPERSONA
              	WHERE x.codigocliente = v.codigocliente
              	              	AND x.estadopersona=0
              	AND x.ESTADOCLIENTE=0
              	ORDER BY xx.IIBB_CABA_RETENCION_ALI DESC
          		)
        	UNION ALL
        	SELECT DISTINCT CJ.IIBB_CABA_PERCEPCION_ALI, CJ.NUMEROPERSONAJURIDICA AS "PERSONA", CJ.IIBB_CABA_RETENCION_ALI, v.codigocliente
        	FROM CLI_PERSONASJURIDICAS CJ WITH (NOLOCK)
        	INNER JOIN VW_CLI_PERSONAS p ON cj.NUMEROPERSONAjuridica = p.[Numero de Persona]
			INNER JOIN ITF_AGIP_PADRON_IMPUESTOS_AUX A ON p.[Numero de Documento]=a.CUIT
        	INNER JOIN VW_CLIENTES_PERSONAS v ON v.numeropersona = p.[Numero de Persona]
        	WHERE CJ.TZ_LOCK = 0
        	        	AND v.estadopersona=0
        	AND v.estadocliente=0
        	AND (A.MSj_ERROR='' OR a.msj_error IS NULL)
          	AND (CJ.IIBB_CABA_PERCEPCION_COND != '' OR cj.IIBB_CABA_RETENCION_COND!='')
          	AND CJ.NUMEROPERSONAJURIDICA = (
              	SELECT TOP 1 xx.numeropersonajuridica
              	FROM CLI_PERSONASJURIDICAS xx
              	INNER JOIN VW_CLIENTES_PERSONAS x ON xx.numeropersonajuridica = x.NUMEROPERSONA
              	WHERE x.codigocliente = v.codigocliente
              	              	AND x.estadopersona=0
              	AND x.ESTADOCLIENTE=0
              	ORDER BY xx.IIBB_CABA_RETENCION_ALI DESC
          		)
    		) t
		) t ON c.codigocliente = t.codigocliente;
		
	--hasta aca
	
	---INSERTO CAMBIOS EN LA BITACORA(ALTAS)----------
	--PERCEPCION
		INSERT INTO CON_BITACORA_IMPUESTOS (JTS_NOVEDAD
										, TIPO_NOVEDAD
										, OPERACION_TOPAZ
										, FECHA_PROCESO
										, HORA
										, ASIENTO
										, COD_USUARIO
										, ARCHIVO_PADRON
										, NUM_CERTIFICADO
										, F_EMISION
										, SUCURSAL
										, ID_CLIENTE
										, ID_PERSONA
										, TIPO_ID
										, CUIT
										, TIPO_CARGO_IMPOSITIVO
										, TABLA_CARGOS_IMPUESTOS
										, ID_CARGO_IMPUESTO
										--, CONDICION
										, VALOR_EXCLUSION
										, ALICUOTA
										--, FECHA_INICIO
										--, FECHA_FIN
										, COMENTARIOS
										, CBU
										, FECHA_INICIO
										, fecha_FIN
										, VALOR_ALICUOTA_IIBB)
		SELECT ISNULL((SELECT MAX(JTS_NOVEDAD) FROM CON_BITACORA_IMPUESTOS),0)+ (ROW_NUMBER() OVER (ORDER BY t.numeroPersona))
								, 'A'
								, 0
								,(SELECT FECHAPROCESO FROM PARAMETROS (NOLOCK))
								, concat(DATEPART(HOUR, GETDATE()),':', DATEPART(MINUTE, GETDATE()),':',DATEPART(SECOND, GETDATE()))
								, 0
								, @USUARIO
								, @ARCHIVO
								, ''
								, NULL
								, t.suc_alta
								, NULL--(SELECT TOP 1 CODIGOCLIENTE FROM VW_CLIENTES_PERSONAS WHERE NUMEROPERSONA=PF.NUMEROPERSONA)
								, t.numeroPersona
								, ''
								, t.CUIT
								, 8
								, NULL
								, NULL
--								, t.letra_alicuota 
								, 0
								, ''
								--, ''
								--, NULL
								, ''
								, ''
								, TRY_CONVERT(DATE,SUBSTRING(T.fecha_vig_desde, 5, 4) + '-' + SUBSTRING(T.fecha_vig_desde, 3, 2) + '-' + SUBSTRING(T.fecha_vig_desde, 1, 2), 120)
								, TRY_CONVERT(DATE,SUBSTRING(T.fecha_vig_HASTA, 5, 4) + '-' + SUBSTRING(T.fecha_vig_HASTA, 3, 2) + '-' + SUBSTRING(T.fecha_vig_HASTA, 1, 2), 120)
								, TRY_CONVERT(NUMERIC(11,7),REPLACE(T.alicuota_percepcion,',','.'))
			FROM 
			(SELECT  DISTINCT p.numeropersona AS numeroPersona
								, c.cuit
								--, C.letra_alicuota
								, C.marca_alicuota
								, c.alicuota_percepcion
								, c.fecha_vig_desde
								, c.fecha_vig_hasta
								, P.tipopersona AS tipoPersona
								, P.suc_alta
				FROM ITF_AGIP_PADRON_IMPUESTOS_AUX c
				INNER JOIN VW_PERSONAS_FYJ_ACTIVAS p ON try_convert(NUMERIC,c.cuit) = p.nroDocIdent
				WHERE C.MSj_ERROR='' OR c.msj_error IS NULL
				) t
				
		--RETENCION
		
				INSERT INTO CON_BITACORA_IMPUESTOS (JTS_NOVEDAD
										, TIPO_NOVEDAD
										, OPERACION_TOPAZ
										, FECHA_PROCESO
										, HORA
										, ASIENTO
										, COD_USUARIO
										, ARCHIVO_PADRON
										, NUM_CERTIFICADO
										, F_EMISION
										, SUCURSAL
										, ID_CLIENTE
										, ID_PERSONA
										, TIPO_ID
										, CUIT
										, TIPO_CARGO_IMPOSITIVO
										, TABLA_CARGOS_IMPUESTOS
										, ID_CARGO_IMPUESTO
										--, CONDICION
										, VALOR_EXCLUSION
										, ALICUOTA
										--, FECHA_INICIO
										--, FECHA_FIN
										, COMENTARIOS
										, CBU
										, FECHA_INICIO
										, fecha_FIN
										, VALOR_ALICUOTA_IIBB)
		SELECT ISNULL((SELECT MAX(JTS_NOVEDAD) FROM CON_BITACORA_IMPUESTOS),0)+ (ROW_NUMBER() OVER (ORDER BY t.numeroPersona))
								, 'A'
								, 0
								,(SELECT FECHAPROCESO FROM PARAMETROS (NOLOCK))
								, concat(DATEPART(HOUR, GETDATE()),':', DATEPART(MINUTE, GETDATE()),':',DATEPART(SECOND, GETDATE()))
								, 0
								, @USUARIO
								, @ARCHIVO
								, ''
								, NULL
								, t.suc_alta
								, NULL--(SELECT TOP 1 CODIGOCLIENTE FROM VW_CLIENTES_PERSONAS WHERE NUMEROPERSONA=PF.NUMEROPERSONA)
								, t.numeroPersona
								, ''
								, t.CUIT
								, 12
								, NULL
								, NULL
--								, t.letra_alicuota 
								, 0
								, ''
								--, ''
								--, NULL
								, ''
								, ''
								, TRY_CONVERT(DATE,SUBSTRING(T.fecha_vig_desde, 5, 4) + '-' + SUBSTRING(T.fecha_vig_desde, 3, 2) + '-' + SUBSTRING(T.fecha_vig_desde, 1, 2), 120)
								, TRY_CONVERT(DATE,SUBSTRING(T.fecha_vig_HASTA, 5, 4) + '-' + SUBSTRING(T.fecha_vig_HASTA, 3, 2) + '-' + SUBSTRING(T.fecha_vig_HASTA, 1, 2), 120)
								, TRY_CONVERT(NUMERIC(11,7),REPLACE(T.alicuota_RETENCION,',','.'))
			FROM 
			(SELECT  DISTINCT p.numeropersona AS numeroPersona
								, c.cuit
								--, C.letra_alicuota
								, C.marca_alicuota
								, c.alicuota_RETENCION
								, c.fecha_vig_desde
								, c.fecha_vig_hasta
								, P.tipopersona AS tipoPersona
								, P.suc_alta
				FROM ITF_AGIP_PADRON_IMPUESTOS_AUX c
				INNER JOIN VW_PERSONAS_FYJ_ACTIVAS p ON try_convert(NUMERIC,c.cuit) = p.nroDocIdent
				WHERE C.MSj_ERROR='' OR c.msj_error IS NULL
				) t

			INSERT INTO CON_BITACORA_IMPUESTOS (JTS_NOVEDAD
										, TIPO_NOVEDAD
										, OPERACION_TOPAZ
										, FECHA_PROCESO
										, HORA
										, ASIENTO
										, COD_USUARIO
										, ARCHIVO_PADRON
										, NUM_CERTIFICADO
										, F_EMISION
										, SUCURSAL
										, ID_CLIENTE
										, ID_PERSONA
										, TIPO_ID
										, CUIT
										, TIPO_CARGO_IMPOSITIVO
										, TABLA_CARGOS_IMPUESTOS
										, CONDICION
										, VALOR_EXCLUSION
										, ALICUOTA
										, COMENTARIOS
										, CBU
										, FECHA_INICIO
										, fecha_FIN
										, VALOR_ALICUOTA_IIBB
										)
		SELECT ISNULL((SELECT MAX(JTS_NOVEDAD) FROM CON_BITACORA_IMPUESTOS),0)+ (ROW_NUMBER() OVER (ORDER BY T.Persona))
								, 'A'
								, 0
								,(SELECT FECHAPROCESO FROM PARAMETROS (NOLOCK))
								, concat(DATEPART(HOUR, GETDATE()),':', DATEPART(MINUTE, GETDATE()),':',DATEPART(SECOND, GETDATE()))
								, 0
								, @USUARIO
								, @ARCHIVO
								, ''
								, NULL
								, t.suc_alta
								, T.codigocliente
								, T.PERSONA
								, ''
								, try_convert(NUMERIC(11),ltrim(rtrim(t.cuit)))
								, 8
								, NULL
								, 0
								, NULL
								, ''
								, ''
								, NULL
								, TRY_CONVERT(DATE,SUBSTRING(T.fecha_vig_desde, 5, 4) + '-' + SUBSTRING(T.fecha_vig_desde, 3, 2) + '-' + SUBSTRING(T.fecha_vig_desde, 1, 2), 120)
								, TRY_CONVERT(DATE,SUBSTRING(T.fecha_vig_HASTA, 5, 4) + '-' + SUBSTRING(T.fecha_vig_HASTA, 3, 2) + '-' + SUBSTRING(T.fecha_vig_HASTA, 1, 2), 120)
								, TRY_CONVERT(NUMERIC(11,7),REPLACE(T.alicuota_percepcion,',','.'))
								
	    	FROM (SELECT DISTINCT CF.IIBB_CABA_PERCEPCION_ALI, CF.NUMEROPERSONAFISICA AS "PERSONA", CF.IIBB_CABA_RETENCION_ALI, v.codigocliente, A.fecha_vig_desde, A.fecha_vig_hasta,a.alicuota_percepcion,a.cuit, cf.suc_alta
        			FROM CLI_PERSONASFISICAS CF WITH (NOLOCK)
        			INNER JOIN VW_CLI_PERSONAS p ON cf.NUMEROPERSONAfisica = p.[Numero de Persona]
					INNER JOIN ITF_AGIP_PADRON_IMPUESTOS_AUX A ON p.[Numero de Documento]=a.CUIT
        			INNER JOIN VW_CLIENTES_PERSONAS v ON v.numeropersona = p.[Numero de Persona]
        			WHERE CF.TZ_LOCK = 0
        			        	AND v.estadopersona=0
        	AND v.estadocliente=0
        			AND (A.MSj_ERROR='' OR a.msj_error IS NULL)
          			AND (CF.IIBB_CABA_PERCEPCION_COND != '' OR cf.IIBB_CABA_RETENCION_COND!='')
          			AND CF.NUMEROPERSONAFISICA = (
               									SELECT TOP 1 xx.numeropersonafisica
              									FROM CLI_PERSONASFISICAS xx
              									INNER JOIN VW_CLIENTES_PERSONAS x ON xx.numeropersonafisica = x.NUMEROPERSONA
              									WHERE x.codigocliente = v.codigocliente
              								   AND x.estadopersona=0
              									AND x.ESTADOCLIENTE=0
              									ORDER BY xx.IIBB_CABA_PERCEPCION_ALI, xx.IIBB_CABA_RETENCION_ALI DESC
          											)
        	UNION ALL
			SELECT DISTINCT CJ.IIBB_CABA_PERCEPCION_ALI, CJ.NUMEROPERSONAJURIDICA AS "PERSONA", CJ.IIBB_CABA_RETENCION_ALI, v.codigocliente, A.fecha_vig_desde, A.fecha_vig_hasta,a.alicuota_percepcion, a.cuit, cj.suc_alta
        	FROM CLI_PERSONASJURIDICAS CJ WITH (NOLOCK)
        	INNER JOIN VW_CLI_PERSONAS p ON cj.NUMEROPERSONAjuridica = p.[Numero de Persona]
			INNER JOIN ITF_AGIP_PADRON_IMPUESTOS_AUX A ON p.[Numero de Documento]=a.CUIT
        	INNER JOIN VW_CLIENTES_PERSONAS v ON v.numeropersona = p.[Numero de Persona]
        	WHERE CJ.TZ_LOCK = 0
        	        	AND v.estadopersona=0
        	AND v.estadocliente=0
        	AND (A.MSj_ERROR='' OR a.msj_error IS NULL)
          	AND (CJ.IIBB_CABA_PERCEPCION_COND != '' OR cj.IIBB_CABA_RETENCION_COND!='')
          	AND CJ.NUMEROPERSONAJURIDICA = (
              	SELECT TOP 1 xx.numeropersonajuridica
              	FROM CLI_PERSONASJURIDICAS xx
              	INNER JOIN VW_CLIENTES_PERSONAS x ON xx.numeropersonajuridica = x.NUMEROPERSONA
              	WHERE x.codigocliente = v.codigocliente
              	AND x.estadopersona=0
              	AND x.ESTADOCLIENTE=0
              	ORDER BY xx.IIBB_CABA_PERCEPCION_ALI, xx.IIBB_CABA_RETENCION_ALI DESC
          		)
    		) t



			INSERT INTO CON_BITACORA_IMPUESTOS (JTS_NOVEDAD
										, TIPO_NOVEDAD
										, OPERACION_TOPAZ
										, FECHA_PROCESO
										, HORA
										, ASIENTO
										, COD_USUARIO
										, ARCHIVO_PADRON
										, NUM_CERTIFICADO
										, F_EMISION
										, SUCURSAL
										, ID_CLIENTE
										, ID_PERSONA
										, TIPO_ID
										, CUIT
										, TIPO_CARGO_IMPOSITIVO
										, TABLA_CARGOS_IMPUESTOS
										, ID_CARGO_IMPUESTO
										, VALOR_EXCLUSION
										, ALICUOTA
										, COMENTARIOS
										, CBU
										, FECHA_INICIO
										, fecha_FIN
										, VALOR_ALICUOTA_IIBB
										)
		SELECT ISNULL((SELECT MAX(JTS_NOVEDAD) FROM CON_BITACORA_IMPUESTOS),0)+ (ROW_NUMBER() OVER (ORDER BY T.Persona))
								, 'A'
								, 0
								,(SELECT FECHAPROCESO FROM PARAMETROS (NOLOCK))
								, concat(DATEPART(HOUR, GETDATE()),':', DATEPART(MINUTE, GETDATE()),':',DATEPART(SECOND, GETDATE()))
								, 0
								, @USUARIO
								, @ARCHIVO
								, ''
								, NULL
								, t.suc_alta
								, T.codigocliente
								, T.PERSONA
								, ''
								, t.cuit
								, 12
								, NULL
								, 0
								, NULL
								, ''
								, ''
								, NULL
								, TRY_CONVERT(DATE,SUBSTRING(T.fecha_vig_desde, 5, 4) + '-' + SUBSTRING(T.fecha_vig_desde, 3, 2) + '-' + SUBSTRING(T.fecha_vig_desde, 1, 2), 120)
								, TRY_CONVERT(DATE,SUBSTRING(T.fecha_vig_HASTA, 5, 4) + '-' + SUBSTRING(T.fecha_vig_HASTA, 3, 2) + '-' + SUBSTRING(T.fecha_vig_HASTA, 1, 2), 120)
								, TRY_CONVERT(NUMERIC(11,7),REPLACE(T.alicuota_retencion,',','.'))
								
	    	FROM (SELECT DISTINCT CF.IIBB_CABA_PERCEPCION_ALI, CF.NUMEROPERSONAFISICA AS "PERSONA", CF.IIBB_CABA_RETENCION_ALI, v.codigocliente, A.fecha_vig_desde, A.fecha_vig_hasta,a.alicuota_retencion,a.cuit, cf.suc_alta
        			FROM CLI_PERSONASFISICAS CF WITH (NOLOCK)
        			INNER JOIN VW_CLI_PERSONAS p ON cf.NUMEROPERSONAfisica = p.[Numero de Persona]
					INNER JOIN ITF_AGIP_PADRON_IMPUESTOS_AUX A ON p.[Numero de Documento]=a.CUIT
        			INNER JOIN VW_CLIENTES_PERSONAS v ON v.numeropersona = p.[Numero de Persona]
        			WHERE CF.TZ_LOCK = 0
        			AND v.estadopersona=0
        			AND v.estadocliente=0
        			AND (A.MSj_ERROR='' OR a.msj_error IS NULL)
          			AND (CF.IIBB_CABA_PERCEPCION_COND != '' OR cf.IIBB_CABA_RETENCION_COND!='')
          			AND CF.NUMEROPERSONAFISICA = (
               									SELECT TOP 1 xx.numeropersonafisica
              									FROM CLI_PERSONASFISICAS xx
              									INNER JOIN VW_CLIENTES_PERSONAS x ON xx.numeropersonafisica = x.NUMEROPERSONA
              									WHERE x.codigocliente = v.codigocliente
              									              	AND x.estadopersona=0
              									AND x.ESTADOCLIENTE=0
              									ORDER BY xx.IIBB_CABA_PERCEPCION_ALI, xx.IIBB_CABA_RETENCION_ALI DESC
          											)
        	UNION ALL
			SELECT DISTINCT CJ.IIBB_CABA_PERCEPCION_ALI, CJ.NUMEROPERSONAJURIDICA AS "PERSONA", CJ.IIBB_CABA_RETENCION_ALI, v.codigocliente, A.fecha_vig_desde, A.fecha_vig_hasta,a.alicuota_retencion,a.cuit, CJ.SUC_ALTA
        	FROM CLI_PERSONASJURIDICAS CJ WITH (NOLOCK)
        	INNER JOIN VW_CLI_PERSONAS p ON cj.NUMEROPERSONAjuridica = p.[Numero de Persona]
			INNER JOIN ITF_AGIP_PADRON_IMPUESTOS_AUX A ON p.[Numero de Documento]=a.CUIT
        	INNER JOIN VW_CLIENTES_PERSONAS v ON v.numeropersona = p.[Numero de Persona]
        	WHERE CJ.TZ_LOCK = 0
        	AND v.estadopersona=0
        	AND v.estadocliente=0
        	AND (A.MSj_ERROR='' OR a.msj_error IS NULL)
          	AND (CJ.IIBB_CABA_PERCEPCION_COND != '' OR cj.IIBB_CABA_RETENCION_COND!='')
          	AND CJ.NUMEROPERSONAJURIDICA = (
              	SELECT TOP 1 xx.numeropersonajuridica
              	FROM CLI_PERSONASJURIDICAS xx
              	INNER JOIN VW_CLIENTES_PERSONAS x ON xx.numeropersonajuridica = x.NUMEROPERSONA
              	WHERE x.codigocliente = v.codigocliente
              	              	AND x.estadopersona=0
              	AND x.ESTADOCLIENTE=0
              	ORDER BY xx.IIBB_CABA_PERCEPCION_ALI, xx.IIBB_CABA_RETENCION_ALI DESC
          		)
    		) t




	--- ACTUALIZO PADRON-----
	DELETE FROM ITF_AGIP_PADRON WHERE Fecha_VIGENCIA_DESDE=(SELECT TOP 1 DATEADD(MONTH, -6,CONVERT(DATE, SUBSTRING(fecha_vig_desde,5,4)+'-' +SUBSTRING(fecha_vig_desde,3,2)+'-'+SUBSTRING(fecha_vig_desde,1,2)))FROM ITF_AGIP_PADRON_IMPUESTOS_AUX)
   	INSERT INTO ITF_AGIP_PADRON
   	SELECT try_CONVERT(DATE, SUBSTRING(fecha_vig_desde,5,4)+'-' +SUBSTRING(fecha_vig_desde,3,2)+'-'+SUBSTRING(fecha_vig_desde,1,2))
   			, try_CONVERT(DATE, SUBSTRING(fecha_public,5,4)+'-' +SUBSTRING(fecha_public,3,2)+'-'+SUBSTRING(fecha_public,1,2))
   			, try_CONVERT(DATE, SUBSTRING(fecha_vig_hasta,5,4)+'-' +SUBSTRING(fecha_vig_hasta,3,2)+'-'+SUBSTRING(fecha_vig_hasta,1,2))
   			, cuit
   			, Razon_Social
   			, Tipo_Contr_Insc
   			, Marca_alta_sujeto
   			, convert(NUMERIC(6,2),replace(Alicuota_Percepcion,',','.'))
   			, convert(NUMERIC(6,2),replace(Alicuota_Retencion,',','.'))   
   			, Nro_Grupo_Percepcion	
   			, Marca_alicuota
   			, Nro_Grupo_Retencion
   	FROM ITF_AGIP_PADRON_IMPUESTOS_AUX
   	WHERE msj_error='' OR msj_error IS NULL
   	
   	IF (SELECT count(1) FROM ITF_AGIP_PADRON_IMPUESTOS_AUX WHERE msj_error='' OR msj_error IS NULL)>0
   	BEGIN 
   		DECLARE @fechaLimite DATE =(SELECT TOP 1 DATEADD(MONTH, -6,CONVERT(DATE, SUBSTRING(fecha_public,5,4)+'-' +SUBSTRING(fecha_public,3,2)+'-'+SUBSTRING(fecha_public,1,2)))FROM ITF_AGIP_PADRON_IMPUESTOS_AUX)

   	
   		DELETE FROM ITF_AGIP_PADRON WHERE datediff(MONTH,fecha_publicacion,@fechaLimite)>0
   	END 
   	-----------------------------------------------------------------------------------------------------------


END