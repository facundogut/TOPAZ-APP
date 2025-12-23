execute('UPDATE ITF_MASTER SET OBJ_KETTLE=''ITF_COMARB_PADRON.kjb'' WHERE ID=129');

execute('
ALTER   PROCEDURE [dbo].[SP_COMARB_PADRON]  
	@usuario varchar(50),
	@ARCHIVO VARCHAR(50) 
AS


BEGIN
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
								, @USUARIO
								, @ARCHIVO
								, ''''
								, NULL
								, 1
								, NULL--(SELECT TOP 1 CODIGOCLIENTE FROM VW_CLIENTES_PERSONAS WHERE NUMEROPERSONA=PF.NUMEROPERSONAFISICA)
								, PF.numeroPersonafisica  
								, ''''
								, D.NUMERODOCUMENTO
								, 0
								, NULL
								, NULL
								, PF.SIRCREB
								, 0
								, ''''
								, (SELECT TOP 1 ALICUOTA FROM ITF_PADRON_IMPUESTOS WHERE CUIT=D.NUMERODOCUMENTO)
								, ''''
								, NULL
								, ''''
								, ''''
	FROM CLI_PersonasFisicas PF
	LEFT JOIN CLI_DocumentosPFPJ D ON PF.NUMEROPERSONAFISICA=D.NUMEROPERSONAFJ	
	WHERE ltrim(rtrim(pf.SIRCREB)) !='''' 
	
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
								, NULL--(SELECT TOP 1 CODIGOCLIENTE FROM VW_CLIENTES_PERSONAS WHERE NUMEROPERSONA=PF.NUMEROPERSONAFISICA)
								, PF.numeroPersonajuridica  
								, ''''
								, D.NUMERODOCUMENTO
								, 0
								, NULL
								, NULL
								, PF.SIRCREB
								, 0
								, ''''
								, (SELECT TOP 1 ALICUOTA FROM ITF_PADRON_IMPUESTOS WHERE CUIT=D.NUMERODOCUMENTO)
								, ''''
								, NULL
								, ''''
								, ''''
	FROM CLI_PERSONASJURIDICAS PF
	LEFT JOIN CLI_DocumentosPFPJ D ON PF.NUMEROPERSONAjuridica=D.NUMEROPERSONAFJ	
	WHERE ltrim(rtrim(pf.SIRCREB)) !='''' 
	
	
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
								, 0
								, NULL
								, NULL
								, c.SIRCREB
								, 0
								, ''''
								, C.IIBB_CORRIENTES_ALI
								, ''''
								, NULL
								, ''''
								, ''''
	FROM cLI_CLIENTES C
	INNER JOIN VW_CLIENTES_PERSONAS V ON C.CODIGOCLIENTE=V.CODIGOCLIENTE
	WHERE ltrim(rtrim(C.SIRCREB))!=''''
	
	UPDATE CLI_PersonasFisicas 
	SET SIRCREB = ''''
	WHERE ltrim(rtrim(SIRCREB))!='''' 
		
	UPDATE CLI_PERSONASJURIDICAS 
	SET SIRCREB = ''''
	WHERE ltrim(rtrim(SIRCREB))!='''' 
	
	UPDATE CLI_CLIENTES 
	SET SIRCREB = ''''
	WHERE ltrim(rtrim(SIRCREB))!='''' 
	
	---CARGO NUEVO PADRON-----
	
	UPDATE CLI_PersonasFisicas
	SET SIRCREB=a.LETRA_ALICUOTA	
	FROM CLI_PersonasFisicas PF
	INNER JOIN VW_CLI_PERSONAS p ON pf.NUMEROPERSONAFISICA = p.[Numero de Persona]
	INNER JOIN ITF_COMARB_PADRON_IMPUESTOS_AUX A ON p.[Numero de Documento]=a.CUIT
	

	UPDATE CLI_Personasjuridicas
	SET SIRCREB=a.LETRA_ALICUOTA	
	FROM CLI_Personasjuridicas PF
	INNER JOIN VW_CLI_PERSONAS p ON pf.NUMEROPERSONAjuridica = p.[Numero de Persona]
	INNER JOIN ITF_COMARB_PADRON_IMPUESTOS_AUX A ON p.[Numero de Documento]=a.CUIT
	
	
	UPDATE CLI_CLIENTES
	SET SIRCREB=t.sircreb 
	FROM CLI_CLIENTES c
	JOIN (
    	SELECT t.sircreb, t.PERSONA, t.codigocliente
    	FROM (
        	SELECT DISTINCT cf.SIRCREB, CF.NUMEROPERSONAFISICA AS "PERSONA", v.codigocliente
        	FROM CLI_PERSONASFISICAS CF WITH (NOLOCK)
        	INNER JOIN VW_CLI_PERSONAS p ON cf.NUMEROPERSONAfisica = p.[Numero de Persona]
			INNER JOIN ITF_COMARB_PADRON_IMPUESTOS_AUX A ON p.[Numero de Documento]=a.CUIT
        	INNER JOIN VW_CLIENTES_PERSONAS v ON v.numeropersona = p.[Numero de Persona]
        	WHERE CF.TZ_LOCK = 0
          	AND CF.sircreb != ''''
          	AND CF.NUMEROPERSONAFISICA = (
              	SELECT TOP 1 xx.numeropersonafisica
              	FROM CLI_PERSONASFISICAS xx
              	INNER JOIN VW_CLIENTES_PERSONAS x ON xx.numeropersonafisica = x.NUMEROPERSONA
              	WHERE x.codigocliente = v.codigocliente
              	ORDER BY xx.sircreb DESC
          		)
        	UNION ALL
        	SELECT DISTINCT CJ.SIRCREB, CJ.NUMEROPERSONAJURIDICA AS "PERSONA", v.codigocliente
        	FROM CLI_PERSONASJURIDICAS CJ WITH (NOLOCK)
        	INNER JOIN VW_CLI_PERSONAS p ON cj.NUMEROPERSONAjuridica = p.[Numero de Persona]
			INNER JOIN ITF_COMARB_PADRON_IMPUESTOS_AUX A ON p.[Numero de Documento]=a.CUIT
        	INNER JOIN VW_CLIENTES_PERSONAS v ON v.numeropersona = p.[Numero de Persona]
        	WHERE CJ.TZ_LOCK = 0
          	AND CJ.sircreb != ''''
          	AND CJ.NUMEROPERSONAJURIDICA = (
              	SELECT TOP 1 xx.numeropersonajuridica
              	FROM CLI_PERSONASJURIDICAS xx
              	INNER JOIN VW_CLIENTES_PERSONAS x ON xx.numeropersonajuridica = x.NUMEROPERSONA
              	WHERE x.codigocliente = v.codigocliente
              	ORDER BY xx.sircreb DESC
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
										, FECHA_INICIO
										, FECHA_FIN
										, COMENTARIOS
										, CBU)
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
								, 0
								, NULL
								, NULL
								, t.letra_alicuota 
								, 0
								, ''''
								, ''''
								, NULL
								, ''''
								, ''''
	FROM 
			(SELECT  DISTINCT p.[Numero de Persona] AS numeroPersona
								, c.cuit
								, C.letra_alicuota
				FROM ITF_COMARB_PADRON_IMPUESTOS_AUX c
				inner JOIN CLI_DocumentosPFPJ f ON c.CUIT = f.NUMERODOCUMENTO
				inner JOIN VW_CLI_PERSONAS p ON f.NUMEROPERSONAFJ = p.[Numero de Persona]
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
										, CONDICION
										, VALOR_EXCLUSION
										, ALICUOTA
										, FECHA_INICIO
										, FECHA_FIN
										, COMENTARIOS
										, CBU)
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
								, 0
								, NULL
								, NULL
								, T.sircreb 
								, 0
								, ''''
								, ''''
								, NULL
								, ''''
								, ''''
								
	    	FROM (
        	SELECT DISTINCT cf.SIRCREB, CF.NUMEROPERSONAFISICA AS "PERSONA", v.codigocliente,a.cuit
        	FROM CLI_PERSONASFISICAS CF WITH (NOLOCK)
        	INNER JOIN VW_CLI_PERSONAS p ON cf.NUMEROPERSONAfisica = p.[Numero de Persona]
			INNER JOIN ITF_COMARB_PADRON_IMPUESTOS_AUX A ON p.[Numero de Documento]=a.CUIT
        	INNER JOIN VW_CLIENTES_PERSONAS v ON v.numeropersona = p.[Numero de Persona]
        	WHERE CF.TZ_LOCK = 0
          	AND CF.sircreb != ''''
          	AND CF.NUMEROPERSONAFISICA = (
              	SELECT TOP 1 xx.numeropersonafisica
              	FROM CLI_PERSONASFISICAS xx
              	INNER JOIN VW_CLIENTES_PERSONAS x ON xx.numeropersonafisica = x.NUMEROPERSONA
              	WHERE x.codigocliente = v.codigocliente
              	ORDER BY xx.sircreb DESC
          		)
        	UNION ALL
        	SELECT DISTINCT CJ.SIRCREB, CJ.NUMEROPERSONAJURIDICA AS "PERSONA", v.codigocliente,a.cuit
        	FROM CLI_PERSONASJURIDICAS CJ WITH (NOLOCK)
        	INNER JOIN VW_CLI_PERSONAS p ON cj.NUMEROPERSONAjuridica = p.[Numero de Persona]
			INNER JOIN ITF_COMARB_PADRON_IMPUESTOS_AUX A ON p.[Numero de Documento]=a.CUIT
        	INNER JOIN VW_CLIENTES_PERSONAS v ON v.numeropersona = p.[Numero de Persona]
        	WHERE CJ.TZ_LOCK = 0
          	AND CJ.sircreb != ''''
          	AND CJ.NUMEROPERSONAJURIDICA = (
              	SELECT TOP 1 xx.numeropersonajuridica
              	FROM CLI_PERSONASJURIDICAS xx
              	INNER JOIN VW_CLIENTES_PERSONAS x ON xx.numeropersonajuridica = x.NUMEROPERSONA
              	WHERE x.codigocliente = v.codigocliente
              	ORDER BY xx.sircreb DESC
          		)
    		) t

		
		DELETE FROM ITF_COMARB_PADRON
		WHERE PERIODO_APLICACION=(SELECT TOP 1 periodo_aplicacion FROM ITF_COMARB_PADRON_IMPUESTOS_AUX)

		INSERT INTO ITF_COMARB_PADRON
		SELECT CUIT, RAZON_SOCIAL, JURISDICCION, PERIODO_APLICACION, CRC_CONTRIBUYENTE, LETRA_ALICUOTA
		FROM ITF_COMARB_PADRON_IMPUESTOS_AUX
		--Calcular la fecha límite	
		DECLARE @fechaLimite VARCHAR(8);
		SET @fechaLimite = CONVERT(VARCHAR(8), DATEADD(MONTH, -6, (SELECT fechaproceso FROM parametros)),112);

		-- Eliminar los registros anteriores a la fecha límite
		DELETE FROM ITF_COMARB_PADRON
		WHERE CAST(CONCAT(PERIODO_APLICACION,''01'') AS DATETIME) < CONVERT(DATE, @fechaLimite, 112);

END');