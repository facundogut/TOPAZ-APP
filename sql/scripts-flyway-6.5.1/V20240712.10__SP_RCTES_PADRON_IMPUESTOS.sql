execute('create or ALTER      PROCEDURE [dbo].[SP_RCTES_PADRON_IMPUESTOS]
	@usuario varchar(max),
	@ARCHIVO VARCHAR(max) 
 	
AS
BEGIN	   

	DECLARE @fechaInicio DATE=(SELECT TOP 1 CONVERT(DATE, STUFF(STUFF(''01''+PERIODO, 3, 0, ''/''), 6, 0, ''/''), 103) FROM ITF_PADRON_IMPUESTOS_AUX)
	DECLARE @fechaProceso DATE =(SELECT fechaproceso FROM parametros)
	--DECLARE @usuario VARCHAR(1)=''a'',@archivo VARCHAR(10)=''archivo''	
	   --BAJAS--	
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
								, substring(@USUARIO,1,10)
								, substring(@archivo,1,30)
								, ''''
								, @fechaProceso
								, pf.SUC_ALTA
								, NULL--(SELECT TOP 1 CODIGOCLIENTE FROM VW_CLIENTES_PERSONAS WHERE NUMEROPERSONA=PF.NUMEROPERSONAFISICA)
								, PF.numeroPersonafisica  
								, ''''
								, D.NUMERODOCUMENTO
								, 9
								, NULL
								, NULL
								, PF.IIBB_CORRIENTES_RECAUD
								, 0
								, ''''
								, PF.IIBB_CORRIENTES_ALI
								, @fechaInicio
								, NULL
								, ''''
								, ''''
	FROM CLI_PersonasFisicas PF
	LEFT JOIN CLI_DocumentosPFPJ D ON PF.NUMEROPERSONAFISICA=D.NUMEROPERSONAFJ	
	WHERE pf.estado=0
	AND (PF.IIBB_CORRIENTES_ALI >0 
	OR IIBB_CORRIENTES_RECAUD !=''NA'') 
	

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
								, substring(@USUARIO,1,10)
								, substring(@archivo,1,30)
								, ''''
								, @fechaProceso
								, pf.SUC_ALTA
								, NULL--(SELECT TOP 1 CODIGOCLIENTE FROM VW_CLIENTES_PERSONAS WHERE NUMEROPERSONA=PF.NUMEROPERSONAJURIDICA)
								, PF.numeroPersonaJURIDICA  
								, ''''
								, D.NUMERODOCUMENTO
								, 9
								, NULL
								, NULL
								, PF.IIBB_CORRIENTES_RECAUD
								, 0
								, ''''
								, PF.IIBB_CORRIENTES_ALI
								, @fechaInicio
								, NULL
								, ''''
								, ''''
	FROM CLI_PERSONASJURIDICAS PF
	LEFT JOIN CLI_DocumentosPFPJ D ON PF.NUMEROPERSONAJURIDICA=D.NUMEROPERSONAFJ	
	WHERE pf.estado=0
	AND (PF.IIBB_CORRIENTES_ALI >0 
	OR IIBB_CORRIENTES_RECAUD !=''NA'') 


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
								, substring(@USUARIO,1,10)
								, substring(@archivo,1,30)
								, ''''
								, @fechaProceso
								, c.SUCURSALVINCULADA
								, C.CODIGOCLIENTE 
								, V.NUMEROPERSONA  
								, ''''
								, V.NUMERODOC
								, 9
								, NULL
								, NULL
								, C.IIBB_CORRIENTES_RECAUD
								, 0
								, ''''
								, C.IIBB_CORRIENTES_ALI
								, @fechaInicio
								, NULL
								, ''''
								, ''''
	FROM cLI_CLIENTES C
	INNER JOIN VW_CLIENTES_PERSONAS V ON C.CODIGOCLIENTE=V.CODIGOCLIENTE
	WHERE c.ESTADO=0
	AND (C.IIBB_CORRIENTES_ALI >0 
	OR IIBB_CORRIENTES_RECAUD !=''NA'') 

								
	UPDATE CLI_PersonasFisicas 
	SET IIBB_CORRIENTES_RECAUD = ''NA''
		, IIBB_CORRIENTES_ALI = 0
	WHERE ESTADO=0 
	AND (IIBB_CORRIENTES_ALI >0 
	OR IIBB_CORRIENTES_RECAUD !=''NA'')
		
	UPDATE CLI_PERSONASJURIDICAS 
	SET IIBB_CORRIENTES_RECAUD = ''NA''
		, IIBB_CORRIENTES_ALI = 0
	WHERE ESTADO=0 
	AND (IIBB_CORRIENTES_ALI >0 
	OR IIBB_CORRIENTES_RECAUD !=''NA'')
	
	UPDATE CLI_CLIENTES 
	SET IIBB_CORRIENTES_RECAUD = ''NA''
		, IIBB_CORRIENTES_ALI = 0
	WHERE ESTADO=0 
	AND (IIBB_CORRIENTES_ALI >0 
	OR IIBB_CORRIENTES_RECAUD !=''NA'')		
	
	---CARGO NUEVO PADRON-----
	
	UPDATE CLI_PersonasFisicas
	SET IIBB_CORRIENTES_RECAUD = CASE WHEN A.ALICUOTA=0 THEN ''EX'' ELSE ''AC'' END
		, IIBB_CORRIENTES_ALI = A.ALICUOTA
	FROM CLI_PersonasFisicas PF
	INNER JOIN ITF_PADRON_IMPUESTOS_AUX A ON PF.NUMEROPERSONAFISICA = A.NUMEROPERSONA
	
	UPDATE CLI_PERSONASJURIDICAS
	SET IIBB_CORRIENTES_RECAUD = CASE WHEN A.ALICUOTA=0 THEN ''EX'' ELSE ''AC'' END
		, IIBB_CORRIENTES_ALI = A.ALICUOTA
	FROM CLI_PersonasJURIDICAS PF
	INNER JOIN ITF_PADRON_IMPUESTOS_AUX A ON PF.NUMEROPERSONAJURIDICA = A.NUMEROPERSONA

	
	UPDATE CLI_CLIENTES
	SET IIBB_CORRIENTES_RECAUD = t.IIBB_CORRIENTES_RECAUD
		, IIBB_CORRIENTES_ALI = t.IIBB_CORRIENTES_ALI
	FROM CLI_CLIENTES c
	JOIN (
    	SELECT t.IIBB_CORRIENTES_ALI, t.IIBB_CORRIENTES_RECAUD, t.PERSONA, t.codigocliente
    	FROM (
        	SELECT DISTINCT CF.IIBB_CORRIENTES_RECAUD, CF.NUMEROPERSONAFISICA AS "PERSONA", CF.IIBB_CORRIENTES_ALI, v.codigocliente
        	FROM CLI_PERSONASFISICAS CF WITH (NOLOCK)
        	INNER JOIN ITF_PADRON_IMPUESTOS_AUX A ON CF.NUMEROPERSONAFISICA = A.NUMEROPERSONA
        	INNER JOIN VW_CLIENTES_PERSONAS v ON v.numeropersona = A.NUMEROPERSONA
        	WHERE CF.TZ_LOCK = 0
          	AND CF.IIBB_CORRIENTES_RECAUD != ''''
          	AND CF.NUMEROPERSONAFISICA = (
              	SELECT TOP 1 xx.numeropersonafisica
              	FROM CLI_PERSONASFISICAS xx
              	INNER JOIN VW_CLIENTES_PERSONAS x ON xx.numeropersonafisica = x.NUMEROPERSONA
              	WHERE x.codigocliente = v.codigocliente
              	ORDER BY xx.IIBB_CORRIENTES_ALI DESC
          		)
        	UNION ALL
        	SELECT DISTINCT CJ.IIBB_CORRIENTES_RECAUD, CJ.NUMEROPERSONAJURIDICA AS "PERSONA", CJ.IIBB_CORRIENTES_ALI, v.codigocliente
        	FROM CLI_PERSONASJURIDICAS CJ WITH (NOLOCK)
        	INNER JOIN ITF_PADRON_IMPUESTOS_AUX A ON CJ.NUMEROPERSONAJURIDICA = A.NUMEROPERSONA
        	INNER JOIN VW_CLIENTES_PERSONAS v ON v.numeropersona = A.NUMEROPERSONA
        	WHERE CJ.TZ_LOCK = 0
          	AND CJ.IIBB_CORRIENTES_RECAUD != ''''
          	AND CJ.NUMEROPERSONAJURIDICA = (
              	SELECT TOP 1 xx.numeropersonajuridica
              	FROM CLI_PERSONASJURIDICAS xx
              	INNER JOIN VW_CLIENTES_PERSONAS x ON xx.numeropersonajuridica = x.NUMEROPERSONA
              	WHERE x.codigocliente = v.codigocliente
              	ORDER BY xx.IIBB_CORRIENTES_ALI DESC
          		)
    		) t
		) t ON c.codigocliente = t.codigocliente;
		
	
	
	---INSERTO CAMBIOS EN LA BITACORA----------
	
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
		SELECT ISNULL((SELECT MAX(JTS_NOVEDAD) FROM CON_BITACORA_IMPUESTOS),0)+ (ROW_NUMBER() OVER (ORDER BY PF.numeroPersona))
								, ''A''
								, 0
								,(SELECT FECHAPROCESO FROM PARAMETROS (NOLOCK))
								, concat(DATEPART(HOUR, GETDATE()),'':'', DATEPART(MINUTE, GETDATE()),'':'',DATEPART(SECOND, GETDATE()))
								, 0
								, substring(@USUARIO,1,10)
								, substring(@archivo,1,30)
								, ''''
								, @fechaProceso
								, (SELECT TOP 1 SUC_ALTA FROM VW_PERSONAS_FYJ_ACTIVAS WHERE NUMEROPERSONA=PF.numeroPersona)
								, NULL--(SELECT TOP 1 CODIGOCLIENTE FROM VW_CLIENTES_PERSONAS WHERE NUMEROPERSONA=PF.NUMEROPERSONA)
								, PF.numeroPersona
								, ''''
								, PF.CUIT
								, 9
								, NULL
								, NULL
								, CASE WHEN PF.ALICUOTA=0 THEN ''EX'' ELSE ''AC'' END 
								, 0
								, ''''
								, PF.ALICUOTA
								, @fechaInicio
								, NULL
								, ''''
								, ''''
	FROM ITF_PADRON_IMPUESTOS_AUX PF

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
		SELECT ISNULL((SELECT MAX(JTS_NOVEDAD) FROM CON_BITACORA_IMPUESTOS),0)+ (ROW_NUMBER() OVER (ORDER BY T.Persona))
								, ''A''
								, 0
								,(SELECT FECHAPROCESO FROM PARAMETROS (NOLOCK))
								, concat(DATEPART(HOUR, GETDATE()),'':'', DATEPART(MINUTE, GETDATE()),'':'',DATEPART(SECOND, GETDATE()))
								, 0
								, substring(@USUARIO,1,10)
								, substring(@archivo,1,30)
								, ''''
								, @fechaProceso
								, (SELECT TOP 1 SUC_ALTA FROM VW_PERSONAS_FYJ_ACTIVAS WHERE NUMEROPERSONA=T.PERSONA)
								, T.codigocliente
								, T.PERSONA
								, ''''
								, (SELECT TOP 1 CUIT FROM ITF_PADRON_IMPUESTOS_AUX WHERE NUMEROPERSONA=T.PERSONA)
								, 9
								, NULL
								, NULL
								, T.IIBB_CORRIENTES_RECAUD 
								, 0
								, ''''
								, T.IIBB_CORRIENTES_ALI
								, @fechaInicio
								, NULL
								, ''''
								, ''''
								
	    	FROM (
        	SELECT DISTINCT CF.IIBB_CORRIENTES_RECAUD, CF.NUMEROPERSONAFISICA AS "PERSONA", CF.IIBB_CORRIENTES_ALI, v.codigocliente
        	FROM CLI_PERSONASFISICAS CF WITH (NOLOCK)
        	INNER JOIN ITF_PADRON_IMPUESTOS_AUX A ON CF.NUMEROPERSONAFISICA = A.NUMEROPERSONA
        	INNER JOIN VW_CLIENTES_PERSONAS v ON v.numeropersona = A.NUMEROPERSONA
        	WHERE CF.TZ_LOCK = 0
  			AND V.TITULARIDAD=''T''
          	AND CF.IIBB_CORRIENTES_RECAUD != ''''
          	AND CF.NUMEROPERSONAFISICA = (
              	SELECT TOP 1 xx.numeropersonafisica
              	FROM CLI_PERSONASFISICAS xx
              	INNER JOIN VW_CLIENTES_PERSONAS x ON xx.numeropersonafisica = x.NUMEROPERSONA
              	WHERE x.codigocliente = v.codigocliente
              	ORDER BY xx.IIBB_CORRIENTES_ALI DESC
          		)
        	UNION ALL
        	SELECT DISTINCT CJ.IIBB_CORRIENTES_RECAUD, CJ.NUMEROPERSONAJURIDICA AS "PERSONA", CJ.IIBB_CORRIENTES_ALI, v.codigocliente
        	FROM CLI_PERSONASJURIDICAS CJ WITH (NOLOCK)
        	INNER JOIN ITF_PADRON_IMPUESTOS_AUX A ON CJ.NUMEROPERSONAJURIDICA = A.NUMEROPERSONA
        	INNER JOIN VW_CLIENTES_PERSONAS v ON v.numeropersona = A.NUMEROPERSONA
        	WHERE CJ.TZ_LOCK = 0
        	AND V.TITULARIDAD=''T''
          	AND CJ.IIBB_CORRIENTES_RECAUD != ''''
          	AND CJ.NUMEROPERSONAJURIDICA = (
              	SELECT TOP 1 xx.numeropersonajuridica
              	FROM CLI_PERSONASJURIDICAS xx
              	INNER JOIN VW_CLIENTES_PERSONAS x ON xx.numeropersonajuridica = x.NUMEROPERSONA
              	WHERE x.codigocliente = v.codigocliente
              	ORDER BY xx.IIBB_CORRIENTES_ALI DESC
          		)
    		) t


	--- ACTUALIZO PADRON-----
	DELETE FROM ITF_PADRON_IMPUESTOS WHERE PERIODO_ARCHIVO=(SELECT TOP 1 PERIODO FROM ITF_PADRON_IMPUESTOS_AUX)
   	INSERT INTO ITF_PADRON_IMPUESTOS(CUIT
   									, RAZON_SOCIAL
   									, PERIODO_ARCHIVO
   									, ALICUOTA)
   	SELECT CUIT
   			, RAZON_SOCIAL
   			, PERIODO
   			, ALICUOTA
   	FROM ITF_PADRON_IMPUESTOS_AUX
-----------------------------------------------------------------------------------------------------------

END');