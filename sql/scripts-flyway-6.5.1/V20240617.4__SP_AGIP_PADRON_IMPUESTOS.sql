execute('CREATE OR ALTER   PROCEDURE [dbo].[SP_AGIP_PADRON_IMPUESTOS] 
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
								, ''B''
								, 0
								,(SELECT FECHAPROCESO FROM PARAMETROS (NOLOCK))
								, concat(DATEPART(HOUR, GETDATE()),'':'', DATEPART(MINUTE, GETDATE()),'':'',DATEPART(SECOND, GETDATE()))
								, 0
								, @USUARIO
							    , @ARCHIVO
								, ''''
								, NULL
								, 1
								, NULL--(SELECT TOP 1 CODIGOCLIENTE FROM VW_CLIENTES_PERSONAS WHERE NUMEROPERSONA=PF.NUMEROPERSONAFISICA)
								, PF.numeroPersonafisica  
								, ''''
								, D.NUMERODOCUMENTO
								, 8
								, NULL
								, NULL
								, PF.IIBB_CABA_PERCEPCION_COND
								, 0
								, ''''
								, PF.IIBB_CABA_PERCEPCION_ALI
								, ''''
								, NULL
								, ''''
								, ''''
	FROM CLI_PersonasFisicas PF
	LEFT JOIN CLI_DocumentosPFPJ D ON PF.NUMEROPERSONAFISICA=D.NUMEROPERSONAFJ	
	WHERE PF.IIBB_CABA_PERCEPCION_ALI >0 
	OR PF.IIBB_CABA_PERCEPCION_COND NOT IN (''NA'', NULL) 
 
	
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
								, ''B''
								, 0
								,(SELECT FECHAPROCESO FROM PARAMETROS (NOLOCK))
								, concat(DATEPART(HOUR, GETDATE()),'':'', DATEPART(MINUTE, GETDATE()),'':'',DATEPART(SECOND, GETDATE()))
								, 0
								, @USUARIO
								, @ARCHIVO
								, ''''
								, NULL
								, 1
								, NULL--(SELECT TOP 1 CODIGOCLIENTE FROM VW_CLIENTES_PERSONAS WHERE NUMEROPERSONA=PF.NUMEROPERSONAFISICA)
								, PF.numeroPersonafisica  
								, ''''
								, D.NUMERODOCUMENTO
								, 12
								, NULL
								, NULL
								, PF.IIBB_CABA_RETENCION_COND
								, 0
								, ''''
								, PF.IIBB_CABA_RETENCION_ALI
								, ''''
								, NULL
								, ''''
								, ''''
	FROM CLI_PersonasFisicas PF
	LEFT JOIN CLI_DocumentosPFPJ D ON PF.NUMEROPERSONAFISICA=D.NUMEROPERSONAFJ	
	WHERE PF.IIBB_CABA_RETENCION_ALI >0
	OR PF.IIBB_CABA_RETENCION_COND NOT IN (''NA'', NULL) 
	
	

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
								, ''B''
								, 0
								,(SELECT FECHAPROCESO FROM PARAMETROS (NOLOCK))
								, concat(DATEPART(HOUR, GETDATE()),'':'', DATEPART(MINUTE, GETDATE()),'':'',DATEPART(SECOND, GETDATE()))
								, 0
								, @USUARIO
								, @ARCHIVO
								, ''''
								, NULL
								, 1
								, NULL--(SELECT TOP 1 CODIGOCLIENTE FROM VW_CLIENTES_PERSONAS WHERE NUMEROPERSONA=PF.NUMEROPERSONAJURIDICA)
								, PF.numeroPersonaJURIDICA  
								, ''''
								, D.NUMERODOCUMENTO
								, 8
								, NULL
								, NULL
								, PF.IIBB_CORRIENTES_RECAUD
								, 0
								, ''''
								, PF.IIBB_CORRIENTES_ALI
								, ''''
								, NULL
								, ''''
								, ''''
	FROM CLI_PERSONASJURIDICAS PF
	LEFT JOIN CLI_DocumentosPFPJ D ON PF.NUMEROPERSONAJURIDICA=D.NUMEROPERSONAFJ	
	WHERE PF.IIBB_CABA_PERCEPCION_ALI >0 
	OR PF.IIBB_CABA_PERCEPCION_COND NOT IN (''NA'', NULL) 


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
								, ''B''
								, 0
								,(SELECT FECHAPROCESO FROM PARAMETROS (NOLOCK))
								, concat(DATEPART(HOUR, GETDATE()),'':'', DATEPART(MINUTE, GETDATE()),'':'',DATEPART(SECOND, GETDATE()))
								, 0
								, @USUARIO
								, @ARCHIVO
								, ''''
								, NULL
								, 1
								, NULL--(SELECT TOP 1 CODIGOCLIENTE FROM VW_CLIENTES_PERSONAS WHERE NUMEROPERSONA=PF.NUMEROPERSONAJURIDICA)
								, PF.numeroPersonaJURIDICA  
								, ''''
								, D.NUMERODOCUMENTO
								, 12
								, NULL
								, NULL
								, PF.IIBB_CORRIENTES_RECAUD
								, 0
								, ''''
								, PF.IIBB_CORRIENTES_ALI
								, ''''
								, NULL
								, ''''
								, ''''
	FROM CLI_PERSONASJURIDICAS PF
	LEFT JOIN CLI_DocumentosPFPJ D ON PF.NUMEROPERSONAJURIDICA=D.NUMEROPERSONAFJ	
	WHERE PF.IIBB_CABA_RETENCION_ALI >0
	OR PF.IIBB_CABA_RETENCION_COND NOT IN (''NA'', NULL) 
	
	

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
								, ''B''
								, 0
								,(SELECT FECHAPROCESO FROM PARAMETROS (NOLOCK))
								, concat(DATEPART(HOUR, GETDATE()),'':'', DATEPART(MINUTE, GETDATE()),'':'',DATEPART(SECOND, GETDATE()))
								, 0
								, @USUARIO
								, @ARCHIVO
								, ''''
								, NULL
								, 1
								, C.CODIGOCLIENTE 
								, V.NUMEROPERSONA  
								, ''''
								, V.NUMERODOC
								, 8
								, NULL
								, NULL
								, C.IIBB_CABA_PERCEPCION_COND
								, 0
								, ''''
								, C.IIBB_CABA_PERCEPCION_ALI
								, ''''
								, NULL
								, ''''
								, ''''
	FROM cLI_CLIENTES C
	INNER JOIN VW_CLIENTES_PERSONAS V ON C.CODIGOCLIENTE=V.CODIGOCLIENTE
	WHERE c.IIBB_CABA_PERCEPCION_ALI >0 
	OR c.IIBB_CABA_PERCEPCION_COND NOT IN (''NA'', NULL) 


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
								, ''B''
								, 0
								,(SELECT FECHAPROCESO FROM PARAMETROS (NOLOCK))
								, concat(DATEPART(HOUR, GETDATE()),'':'', DATEPART(MINUTE, GETDATE()),'':'',DATEPART(SECOND, GETDATE()))
								, 0
								, @USUARIO
								, @ARCHIVO
								, ''''
								, NULL
								, 1
								, C.CODIGOCLIENTE 
								, V.NUMEROPERSONA  
								, ''''
								, V.NUMERODOC
								, 12
								, NULL
								, NULL
								, C.IIBB_CABA_RETENCION_COND
								, 0
								, ''''
								, C.IIBB_CABA_RETENCION_ALI
								, ''''
								, NULL
								, ''''
								, ''''
	FROM cLI_CLIENTES C
	INNER JOIN VW_CLIENTES_PERSONAS V ON C.CODIGOCLIENTE=V.CODIGOCLIENTE
	WHERE C.IIBB_CABA_RETENCION_ALI >0
	OR C.IIBB_CABA_RETENCION_COND NOT IN (''NA'', NULL) 


								
	UPDATE CLI_PersonasFisicas 
	SET	IIBB_CABA_PERCEPCION_COND = ''NA''
		, IIBB_CABA_PERCEPCION_ALI = 0 
		, IIBB_CABA_RETENCION_COND = ''NA''
		, IIBB_CABA_RETENCION_ALI = 0
	WHERE IIBB_CABA_PERCEPCION_ALI >0 
	OR IIBB_CABA_PERCEPCION_COND IN (''NA'', NULL)
	OR IIBB_CABA_RETENCION_ALI >0 
	OR IIBB_CABA_RETENCION_COND IN (''NA'', NULL)
		
	UPDATE CLI_PERSONASJURIDICAS 
	SET	IIBB_CABA_PERCEPCION_COND = ''NA''
		, IIBB_CABA_PERCEPCION_ALI = 0 
		, IIBB_CABA_RETENCION_COND = ''NA''
		, IIBB_CABA_RETENCION_ALI = 0
	WHERE IIBB_CABA_PERCEPCION_ALI >0 
	OR IIBB_CABA_PERCEPCION_COND IN (''NA'', NULL)
	OR IIBB_CABA_RETENCION_ALI >0 
	OR IIBB_CABA_RETENCION_COND IN (''NA'', NULL)
	
	UPDATE CLI_CLIENTES 
	SET	IIBB_CABA_PERCEPCION_COND = ''NA''
		, IIBB_CABA_PERCEPCION_ALI = 0 
		, IIBB_CABA_RETENCION_COND = ''NA''
		, IIBB_CABA_RETENCION_ALI = 0
	WHERE IIBB_CABA_PERCEPCION_ALI >0 
	OR IIBB_CABA_PERCEPCION_COND IN (''NA'', NULL)
	OR IIBB_CABA_RETENCION_ALI >0 
	OR IIBB_CABA_RETENCION_COND IN (''NA'', NULL)
	
	
	---CARGO NUEVO PADRON-----
	
	UPDATE CLI_PersonasFisicas
	SET IIBB_CABA_PERCEPCION_COND = ''AC''
		, IIBB_CABA_PERCEPCION_ALI = A.Alicuota_Percepcion 
		, IIBB_CABA_RETENCION_COND = ''AC''
		, IIBB_CABA_RETENCION_ALI = A.Alicuota_Retencion
	FROM CLI_Personasfisicas PF
	INNER JOIN VW_CLI_PERSONAS p ON pf.NUMEROPERSONAfisica = p.[Numero de Persona]
	INNER JOIN ITF_AGIP_PADRON_IMPUESTOS_AUX A ON p.[Numero de Documento]=a.CUIT
	WHERE A.MSj_ERROR='''' OR a.msj_error IS null
	
	UPDATE CLI_PERSONASJURIDICAS
	SET IIBB_CABA_PERCEPCION_COND = ''AC''
		, IIBB_CABA_PERCEPCION_ALI = A.Alicuota_Percepcion 
		, IIBB_CABA_RETENCION_COND = ''AC''
		, IIBB_CABA_RETENCION_ALI = A.Alicuota_Retencion
	FROM CLI_Personasjuridicas PF
	INNER JOIN VW_CLI_PERSONAS p ON pf.NUMEROPERSONAjuridica = p.[Numero de Persona]
	INNER JOIN ITF_AGIP_PADRON_IMPUESTOS_AUX A ON p.[Numero de Documento]=a.CUIT
	WHERE A.MSj_ERROR='''' OR a.msj_error IS null
	
	UPDATE CLI_CLIENTES
	SET IIBB_CABA_PERCEPCION_COND = ''AC''
		, IIBB_CABA_PERCEPCION_ALI = t.IIBB_CABA_PERCEPCION_ALI 
		, IIBB_CABA_RETENCION_COND = ''AC''
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
        	AND (A.MSj_ERROR='''' OR a.msj_error IS NULL)
          	AND (CF.IIBB_CABA_PERCEPCION_COND != '''' OR cf.IIBB_CABA_RETENCION_COND!='''')
          	AND CF.NUMEROPERSONAFISICA = (
              	SELECT TOP 1 xx.numeropersonafisica
              	FROM CLI_PERSONASFISICAS xx
              	INNER JOIN VW_CLIENTES_PERSONAS x ON xx.numeropersonafisica = x.NUMEROPERSONA
              	WHERE x.codigocliente = v.codigocliente
              	ORDER BY xx.IIBB_CABA_PERCEPCION_ALI, xx.IIBB_CABA_RETENCION_ALI DESC
          		)
        	UNION ALL
        	SELECT DISTINCT CJ.IIBB_CABA_PERCEPCION_ALI, CJ.NUMEROPERSONAJURIDICA AS "PERSONA", CJ.IIBB_CABA_RETENCION_ALI, v.codigocliente
        	FROM CLI_PERSONASJURIDICAS CJ WITH (NOLOCK)
        	INNER JOIN VW_CLI_PERSONAS p ON cj.NUMEROPERSONAjuridica = p.[Numero de Persona]
			INNER JOIN ITF_AGIP_PADRON_IMPUESTOS_AUX A ON p.[Numero de Documento]=a.CUIT
        	INNER JOIN VW_CLIENTES_PERSONAS v ON v.numeropersona = p.[Numero de Persona]
        	WHERE CJ.TZ_LOCK = 0
        	AND (A.MSj_ERROR='''' OR a.msj_error IS NULL)
          	AND (CJ.IIBB_CABA_PERCEPCION_COND != '''' OR cj.IIBB_CABA_RETENCION_COND!='''')
          	AND CJ.NUMEROPERSONAJURIDICA = (
              	SELECT TOP 1 xx.numeropersonajuridica
              	FROM CLI_PERSONASJURIDICAS xx
              	INNER JOIN VW_CLIENTES_PERSONAS x ON xx.numeropersonajuridica = x.NUMEROPERSONA
              	WHERE x.codigocliente = v.codigocliente
              	ORDER BY xx.IIBB_CABA_PERCEPCION_ALI, xx.IIBB_CABA_RETENCION_ALI DESC
          		)
    		) t
		) t ON c.codigocliente = t.codigocliente;
		
	--hasta aca
	
	---INSERTO CAMBIOS EN LA BITACORA----------
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
								, ''B''
								, 0
								,(SELECT FECHAPROCESO FROM PARAMETROS (NOLOCK))
								, concat(DATEPART(HOUR, GETDATE()),'':'', DATEPART(MINUTE, GETDATE()),'':'',DATEPART(SECOND, GETDATE()))
								, 0
								, @USUARIO
								, @ARCHIVO
								, ''''
								, NULL
								, 1
								, NULL--(SELECT TOP 1 CODIGOCLIENTE FROM VW_CLIENTES_PERSONAS WHERE NUMEROPERSONA=PF.NUMEROPERSONA)
								, t.numeroPersona
								, ''''
								, t.CUIT
								, 8
								, NULL
								, NULL
--								, t.letra_alicuota 
								, 0
								, ''''
								--, ''''
								--, NULL
								, ''''
								, ''''
								, TRY_CONVERT(DATE,SUBSTRING(T.fecha_vig_desde, 5, 4) + ''-'' + SUBSTRING(T.fecha_vig_desde, 3, 2) + ''-'' + SUBSTRING(T.fecha_vig_desde, 1, 2), 120)
								, TRY_CONVERT(DATE,SUBSTRING(T.fecha_vig_HASTA, 5, 4) + ''-'' + SUBSTRING(T.fecha_vig_HASTA, 3, 2) + ''-'' + SUBSTRING(T.fecha_vig_HASTA, 1, 2), 120)
								, TRY_CONVERT(NUMERIC(11,7),REPLACE(T.alicuota_percepcion,'','',''''))/10000
			FROM 
			(SELECT  DISTINCT p.[Numero de Persona] AS numeroPersona
								, c.cuit
								--, C.letra_alicuota
								, C.marca_alicuota
								, c.alicuota_percepcion
								, c.fecha_vig_desde
								, c.fecha_vig_hasta
				FROM ITF_AGIP_PADRON_IMPUESTOS_AUX c
				inner JOIN CLI_DocumentosPFPJ f ON c.CUIT = f.NUMERODOCUMENTO
				inner JOIN VW_CLI_PERSONAS p ON f.NUMEROPERSONAFJ = p.[Numero de Persona]
				WHERE C.MSj_ERROR='''' OR c.msj_error IS null
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
								, ''B''
								, 0
								,(SELECT FECHAPROCESO FROM PARAMETROS (NOLOCK))
								, concat(DATEPART(HOUR, GETDATE()),'':'', DATEPART(MINUTE, GETDATE()),'':'',DATEPART(SECOND, GETDATE()))
								, 0
								, @USUARIO
								, @ARCHIVO
								, ''''
								, NULL
								, 1
								, NULL--(SELECT TOP 1 CODIGOCLIENTE FROM VW_CLIENTES_PERSONAS WHERE NUMEROPERSONA=PF.NUMEROPERSONA)
								, t.numeroPersona
								, ''''
								, t.CUIT
								, 12
								, NULL
								, NULL
--								, t.letra_alicuota 
								, 0
								, ''''
								--, ''''
								--, NULL
								, ''''
								, ''''
								, TRY_CONVERT(DATE,SUBSTRING(T.fecha_vig_desde, 5, 4) + ''-'' + SUBSTRING(T.fecha_vig_desde, 3, 2) + ''-'' + SUBSTRING(T.fecha_vig_desde, 1, 2), 120)
								, TRY_CONVERT(DATE,SUBSTRING(T.fecha_vig_HASTA, 5, 4) + ''-'' + SUBSTRING(T.fecha_vig_HASTA, 3, 2) + ''-'' + SUBSTRING(T.fecha_vig_HASTA, 1, 2), 120)
								, TRY_CONVERT(NUMERIC(11,7),REPLACE(T.alicuota_RETENCION,'','',''''))/10000
			FROM 
			(SELECT  DISTINCT p.[Numero de Persona] AS numeroPersona
								, c.cuit
								--, C.letra_alicuota
								, C.marca_alicuota
								, c.alicuota_RETENCION
								, c.fecha_vig_desde
								, c.fecha_vig_hasta
				FROM ITF_AGIP_PADRON_IMPUESTOS_AUX c
				inner JOIN CLI_DocumentosPFPJ f ON c.CUIT = f.NUMERODOCUMENTO
				inner JOIN VW_CLI_PERSONAS p ON f.NUMEROPERSONAFJ = p.[Numero de Persona]
				WHERE C.MSj_ERROR='''' OR c.msj_error IS null
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
								, ''B''
								, 0
								,(SELECT FECHAPROCESO FROM PARAMETROS (NOLOCK))
								, concat(DATEPART(HOUR, GETDATE()),'':'', DATEPART(MINUTE, GETDATE()),'':'',DATEPART(SECOND, GETDATE()))
								, 0
								, @USUARIO
								, @ARCHIVO
								, ''''
								, NULL
								, 1
								, T.codigocliente
								, T.PERSONA
								, ''''
								, try_convert(NUMERIC(11),ltrim(rtrim(t.cuit)))
								, 8
								, NULL
								, 0
								, NULL
								, ''''
								, ''''
								, NULL
								, TRY_CONVERT(DATE,SUBSTRING(T.fecha_vig_desde, 5, 4) + ''-'' + SUBSTRING(T.fecha_vig_desde, 3, 2) + ''-'' + SUBSTRING(T.fecha_vig_desde, 1, 2), 120)
								, TRY_CONVERT(DATE,SUBSTRING(T.fecha_vig_HASTA, 5, 4) + ''-'' + SUBSTRING(T.fecha_vig_HASTA, 3, 2) + ''-'' + SUBSTRING(T.fecha_vig_HASTA, 1, 2), 120)
								, TRY_CONVERT(NUMERIC(11,7),REPLACE(T.alicuota_percepcion,'','',''''))/10000
								
	    	FROM (SELECT DISTINCT CF.IIBB_CABA_PERCEPCION_ALI, CF.NUMEROPERSONAFISICA AS "PERSONA", CF.IIBB_CABA_RETENCION_ALI, v.codigocliente, A.fecha_vig_desde, A.fecha_vig_hasta,a.alicuota_percepcion,a.cuit
        			FROM CLI_PERSONASFISICAS CF WITH (NOLOCK)
        			INNER JOIN VW_CLI_PERSONAS p ON cf.NUMEROPERSONAfisica = p.[Numero de Persona]
					INNER JOIN ITF_AGIP_PADRON_IMPUESTOS_AUX A ON p.[Numero de Documento]=a.CUIT
        			INNER JOIN VW_CLIENTES_PERSONAS v ON v.numeropersona = p.[Numero de Persona]
        			WHERE CF.TZ_LOCK = 0
        			AND (A.MSj_ERROR='''' OR a.msj_error IS NULL)
          			AND (CF.IIBB_CABA_PERCEPCION_COND != '''' OR cf.IIBB_CABA_RETENCION_COND!='''')
          			AND CF.NUMEROPERSONAFISICA = (
               									SELECT TOP 1 xx.numeropersonafisica
              									FROM CLI_PERSONASFISICAS xx
              									INNER JOIN VW_CLIENTES_PERSONAS x ON xx.numeropersonafisica = x.NUMEROPERSONA
              									WHERE x.codigocliente = v.codigocliente
              									ORDER BY xx.IIBB_CABA_PERCEPCION_ALI, xx.IIBB_CABA_RETENCION_ALI DESC
          											)
        	UNION ALL
			SELECT DISTINCT CJ.IIBB_CABA_PERCEPCION_ALI, CJ.NUMEROPERSONAJURIDICA AS "PERSONA", CJ.IIBB_CABA_RETENCION_ALI, v.codigocliente, A.fecha_vig_desde, A.fecha_vig_hasta,a.alicuota_percepcion, a.cuit
        	FROM CLI_PERSONASJURIDICAS CJ WITH (NOLOCK)
        	INNER JOIN VW_CLI_PERSONAS p ON cj.NUMEROPERSONAjuridica = p.[Numero de Persona]
			INNER JOIN ITF_AGIP_PADRON_IMPUESTOS_AUX A ON p.[Numero de Documento]=a.CUIT
        	INNER JOIN VW_CLIENTES_PERSONAS v ON v.numeropersona = p.[Numero de Persona]
        	WHERE CJ.TZ_LOCK = 0
        	AND (A.MSj_ERROR='''' OR a.msj_error IS NULL)
          	AND (CJ.IIBB_CABA_PERCEPCION_COND != '''' OR cj.IIBB_CABA_RETENCION_COND!='''')
          	AND CJ.NUMEROPERSONAJURIDICA = (
              	SELECT TOP 1 xx.numeropersonajuridica
              	FROM CLI_PERSONASJURIDICAS xx
              	INNER JOIN VW_CLIENTES_PERSONAS x ON xx.numeropersonajuridica = x.NUMEROPERSONA
              	WHERE x.codigocliente = v.codigocliente
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
								, ''B''
								, 0
								,(SELECT FECHAPROCESO FROM PARAMETROS (NOLOCK))
								, concat(DATEPART(HOUR, GETDATE()),'':'', DATEPART(MINUTE, GETDATE()),'':'',DATEPART(SECOND, GETDATE()))
								, 0
								, @USUARIO
								, @ARCHIVO
								, ''''
								, NULL
								, 1
								, T.codigocliente
								, T.PERSONA
								, ''''
								, t.cuit
								, 12
								, NULL
								, 0
								, NULL
								, ''''
								, ''''
								, NULL
								, TRY_CONVERT(DATE,SUBSTRING(T.fecha_vig_desde, 5, 4) + ''-'' + SUBSTRING(T.fecha_vig_desde, 3, 2) + ''-'' + SUBSTRING(T.fecha_vig_desde, 1, 2), 120)
								, TRY_CONVERT(DATE,SUBSTRING(T.fecha_vig_HASTA, 5, 4) + ''-'' + SUBSTRING(T.fecha_vig_HASTA, 3, 2) + ''-'' + SUBSTRING(T.fecha_vig_HASTA, 1, 2), 120)
								, TRY_CONVERT(NUMERIC(11,7),REPLACE(T.alicuota_retencion,'','',''''))/10000
								
	    	FROM (SELECT DISTINCT CF.IIBB_CABA_PERCEPCION_ALI, CF.NUMEROPERSONAFISICA AS "PERSONA", CF.IIBB_CABA_RETENCION_ALI, v.codigocliente, A.fecha_vig_desde, A.fecha_vig_hasta,a.alicuota_retencion,a.cuit
        			FROM CLI_PERSONASFISICAS CF WITH (NOLOCK)
        			INNER JOIN VW_CLI_PERSONAS p ON cf.NUMEROPERSONAfisica = p.[Numero de Persona]
					INNER JOIN ITF_AGIP_PADRON_IMPUESTOS_AUX A ON p.[Numero de Documento]=a.CUIT
        			INNER JOIN VW_CLIENTES_PERSONAS v ON v.numeropersona = p.[Numero de Persona]
        			WHERE CF.TZ_LOCK = 0
        			AND (A.MSj_ERROR='''' OR a.msj_error IS NULL)
          			AND (CF.IIBB_CABA_PERCEPCION_COND != '''' OR cf.IIBB_CABA_RETENCION_COND!='''')
          			AND CF.NUMEROPERSONAFISICA = (
               									SELECT TOP 1 xx.numeropersonafisica
              									FROM CLI_PERSONASFISICAS xx
              									INNER JOIN VW_CLIENTES_PERSONAS x ON xx.numeropersonafisica = x.NUMEROPERSONA
              									WHERE x.codigocliente = v.codigocliente
              									ORDER BY xx.IIBB_CABA_PERCEPCION_ALI, xx.IIBB_CABA_RETENCION_ALI DESC
          											)
        	UNION ALL
			SELECT DISTINCT CJ.IIBB_CABA_PERCEPCION_ALI, CJ.NUMEROPERSONAJURIDICA AS "PERSONA", CJ.IIBB_CABA_RETENCION_ALI, v.codigocliente, A.fecha_vig_desde, A.fecha_vig_hasta,a.alicuota_retencion,a.cuit
        	FROM CLI_PERSONASJURIDICAS CJ WITH (NOLOCK)
        	INNER JOIN VW_CLI_PERSONAS p ON cj.NUMEROPERSONAjuridica = p.[Numero de Persona]
			INNER JOIN ITF_AGIP_PADRON_IMPUESTOS_AUX A ON p.[Numero de Documento]=a.CUIT
        	INNER JOIN VW_CLIENTES_PERSONAS v ON v.numeropersona = p.[Numero de Persona]
        	WHERE CJ.TZ_LOCK = 0
        	AND (A.MSj_ERROR='''' OR a.msj_error IS NULL)
          	AND (CJ.IIBB_CABA_PERCEPCION_COND != '''' OR cj.IIBB_CABA_RETENCION_COND!='''')
          	AND CJ.NUMEROPERSONAJURIDICA = (
              	SELECT TOP 1 xx.numeropersonajuridica
              	FROM CLI_PERSONASJURIDICAS xx
              	INNER JOIN VW_CLIENTES_PERSONAS x ON xx.numeropersonajuridica = x.NUMEROPERSONA
              	WHERE x.codigocliente = v.codigocliente
              	ORDER BY xx.IIBB_CABA_PERCEPCION_ALI, xx.IIBB_CABA_RETENCION_ALI DESC
          		)
    		) t




	--- ACTUALIZO PADRON-----
	DELETE FROM ITF_AGIP_PADRON WHERE Fecha_Publicacion=(SELECT TOP 1 fecha_public FROM ITF_AGIP_PADRON_IMPUESTOS_AUX)
   	INSERT INTO ITF_AGIP_PADRON
   	SELECT fecha_vig_desde
   			, fecha_public
   			, fecha_vig_hasta
   			, cuit
   			, Razon_Social
   			, Tipo_Contr_Insc
   			, Marca_alta_sujeto
   			, Alicuota_Percepcion
   			, Alicuota_Retencion   
   			, Nro_Grupo_Percepcion	
   			, Marca_alicuota
   			, Nro_Grupo_Retencion
   	FROM ITF_AGIP_PADRON_IMPUESTOS_AUX
   	WHERE msj_error='''' OR msj_error IS null
-----------------------------------------------------------------------------------------------------------


END');