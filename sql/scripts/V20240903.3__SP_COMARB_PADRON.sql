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
		SELECT ISNULL((SELECT MAX(JTS_NOVEDAD) FROM CON_BITACORA_IMPUESTOS WITH (NOLOCK)),0)+ (ROW_NUMBER() OVER (ORDER BY PF.numeroPersonafisica))
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
								, (SELECT TOP 1 ALICUOTA FROM ITF_PADRON_IMPUESTOS WITH (NOLOCK) WHERE CUIT=D.NUMERODOCUMENTO)
								, NULL
								, NULL
								, ''''
								, ''''
	FROM CLI_PersonasFisicas PF WITH (NOLOCK)
	LEFT JOIN CLI_DocumentosPFPJ D WITH (NOLOCK) ON PF.NUMEROPERSONAFISICA=D.NUMEROPERSONAFJ	
	WHERE ltrim(rtrim(pf.SIRCREB)) !='''' AND PF.ESTADO = 0 AND((PF.TZ_LOCK < 300000000000000 OR PF.TZ_LOCK >= 400000000000000) 
														  AND (PF.TZ_LOCK < 100000000000000 OR PF.TZ_LOCK >= 200000000000000)) 
														  AND ((D.TZ_LOCK < 300000000000000 OR D.TZ_LOCK >= 400000000000000) 
														  AND (D.TZ_LOCK < 100000000000000 OR D.TZ_LOCK >= 200000000000000))
	
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
		SELECT ISNULL((SELECT MAX(JTS_NOVEDAD) FROM CON_BITACORA_IMPUESTOS WITH (NOLOCK)),0)+ (ROW_NUMBER() OVER (ORDER BY PF.numeroPersonajuridica))
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
								, (SELECT TOP 1 ALICUOTA FROM ITF_PADRON_IMPUESTOS WITH (NOLOCK) WHERE CUIT=D.NUMERODOCUMENTO)
								, NULL
								, NULL
								, ''''
								, ''''
	FROM CLI_PERSONASJURIDICAS PF WITH (NOLOCK)
	LEFT JOIN CLI_DocumentosPFPJ D WITH (NOLOCK) ON PF.NUMEROPERSONAjuridica=D.NUMEROPERSONAFJ	
	WHERE ltrim(rtrim(pf.SIRCREB)) !=''''  AND PF.ESTADO = 0 AND PF.ESTADO = 0 AND((PF.TZ_LOCK < 300000000000000 OR PF.TZ_LOCK >= 400000000000000) 
																			 AND (PF.TZ_LOCK < 100000000000000 OR PF.TZ_LOCK >= 200000000000000)) 
																			 AND ((D.TZ_LOCK < 300000000000000 OR D.TZ_LOCK >= 400000000000000) 
																			 AND (D.TZ_LOCK < 100000000000000 OR D.TZ_LOCK >= 200000000000000))
	
	
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
		SELECT ISNULL((SELECT MAX(JTS_NOVEDAD) FROM CON_BITACORA_IMPUESTOS WITH (NOLOCK)),0)+ (ROW_NUMBER() OVER (ORDER BY c.codigocliente))
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
								, B.ID_PERSONA  
								, ''''
								, B.CUIT
								, 0
								, NULL
								, NULL
								, c.SIRCREB
								, 0
								, ''''
								, C.IIBB_CORRIENTES_ALI
								, NULL
								, NULL
								, ''''
								, ''''
	FROM cLI_CLIENTES C WITH (NOLOCK) 
	JOIN CON_BITACORA_IMPUESTOS B WITH (NOLOCK) ON B.ID_CLIENTE = C.CODIGOCLIENTE
	WHERE ltrim(rtrim(C.SIRCREB))!='''' AND C.ESTADO = 0  AND((C.TZ_LOCK < 300000000000000 OR C.TZ_LOCK >= 400000000000000) 
																AND (C.TZ_LOCK < 100000000000000 OR C.TZ_LOCK >= 200000000000000))
	 AND B.JTS_NOVEDAD IN (	SELECT TOP 1 B2.JTS_NOVEDAD 
	 						FROM CON_BITACORA_IMPUESTOS B2 WITH (NOLOCK)
	 						WHERE B2.ID_CLIENTE = C.CODIGOCLIENTE AND B2.TIPO_NOVEDAD = ''A'' 
	 						ORDER BY B2.JTS_NOVEDAD DESC)
	
	UPDATE CLI_PersonasFisicas 
	SET SIRCREB = ''''
	WHERE ltrim(rtrim(SIRCREB))!='''' AND ESTADO = 0 AND ((TZ_LOCK < 300000000000000 OR TZ_LOCK >= 400000000000000) 
															AND (TZ_LOCK < 100000000000000 OR TZ_LOCK >= 200000000000000))
		
	UPDATE CLI_PERSONASJURIDICAS 
	SET SIRCREB = ''''
	WHERE ltrim(rtrim(SIRCREB))!='''' AND ESTADO = 0 AND ((TZ_LOCK < 300000000000000 OR TZ_LOCK >= 400000000000000) 
															AND (TZ_LOCK < 100000000000000 OR TZ_LOCK >= 200000000000000))
	
	UPDATE CLI_CLIENTES 
	SET SIRCREB = ''''
	WHERE ltrim(rtrim(SIRCREB))!='''' AND ESTADO = 0  AND ((TZ_LOCK < 300000000000000 OR TZ_LOCK >= 400000000000000) 
															AND (TZ_LOCK < 100000000000000 OR TZ_LOCK >= 200000000000000))
	
	---CARGO NUEVO PADRON-----
	
	UPDATE CLI_PersonasFisicas
	SET SIRCREB=a.LETRA_ALICUOTA	
	FROM CLI_PersonasFisicas PF WITH (NOLOCK)
	INNER JOIN CLI_DocumentosPFPJ p WITH (NOLOCK) ON pf.NUMEROPERSONAFISICA = p.numeropersonafj
	INNER JOIN ITF_COMARB_PADRON_IMPUESTOS_AUX A WITH (NOLOCK) ON p.NumeroDocumento=a.CUIT
	

	UPDATE CLI_Personasjuridicas
	SET SIRCREB=a.LETRA_ALICUOTA	
	FROM CLI_Personasjuridicas PF WITH (NOLOCK)
	INNER JOIN CLI_DocumentosPFPJ p WITH (NOLOCK) ON pf.NUMEROPERSONAJURIDICA = p.numeropersonafj
	INNER JOIN ITF_COMARB_PADRON_IMPUESTOS_AUX A WITH (NOLOCK) ON p.NumeroDocumento=a.CUIT
	
	
	UPDATE CLI_CLIENTES
	SET SIRCREB=t.sircreb 
	FROM CLI_CLIENTES c
	JOIN (
    	SELECT t.sircreb, t.PERSONA, t.codigocliente
    	FROM (
        	SELECT DISTINCT cf.SIRCREB, CF.NUMEROPERSONAFISICA AS "PERSONA", v.codigocliente
        	FROM CLI_PERSONASFISICAS CF WITH (NOLOCK)
			INNER JOIN CLI_DocumentosPFPJ p WITH (NOLOCK) ON cf.NUMEROPERSONAFISICA = p.numeropersonafj
			INNER JOIN ITF_COMARB_PADRON_IMPUESTOS_AUX A WITH (NOLOCK) ON p.NumeroDocumento=a.CUIT
        	INNER JOIN VW_CLIENTES_PERSONAS v WITH (NOLOCK) ON v.numeropersona = cf.NUMEROPERSONAFISICA
        	WHERE CF.TZ_LOCK = 0
          	AND CF.sircreb != ''''
          	AND CF.NUMEROPERSONAFISICA = (
              	SELECT TOP 1 xx.numeropersonafisica
              	FROM CLI_PERSONASFISICAS xx WITH (NOLOCK)
              	INNER JOIN VW_CLIENTES_PERSONAS x WITH (NOLOCK) ON xx.numeropersonafisica = x.NUMEROPERSONA
              	WHERE x.codigocliente = v.codigocliente
              	ORDER BY xx.sircreb DESC
          		)
        	UNION ALL
        	SELECT DISTINCT CJ.SIRCREB, CJ.NUMEROPERSONAJURIDICA AS "PERSONA", v.codigocliente
        	FROM CLI_PERSONASJURIDICAS CJ WITH (NOLOCK)
			INNER JOIN CLI_DocumentosPFPJ p WITH (NOLOCK) ON cj.NUMEROPERSONAJURIDICA = p.numeropersonafj
			INNER JOIN ITF_COMARB_PADRON_IMPUESTOS_AUX A WITH (NOLOCK) ON p.NumeroDocumento=a.CUIT
        	INNER JOIN VW_CLIENTES_PERSONAS v WITH (NOLOCK) ON v.numeropersona = cj.NUMEROPERSONAJURIDICA 
        	WHERE CJ.TZ_LOCK = 0
          	AND CJ.sircreb != ''''
          	AND CJ.NUMEROPERSONAJURIDICA = (
              	SELECT TOP 1 xx.numeropersonajuridica
              	FROM CLI_PERSONASJURIDICAS xx WITH (NOLOCK)
              	INNER JOIN VW_CLIENTES_PERSONAS x WITH (NOLOCK) ON xx.numeropersonajuridica = x.NUMEROPERSONA
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
		SELECT ISNULL((SELECT MAX(JTS_NOVEDAD) FROM CON_BITACORA_IMPUESTOS WITH (NOLOCK)),0)+ (ROW_NUMBER() OVER (ORDER BY t.numeroPersona))
								, ''A''
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
								, NULL
								, NULL
								, ''''
								, ''''
	FROM 
			(SELECT  DISTINCT f.NUMEROPERSONAFJ AS numeroPersona
								, c.cuit
								, C.letra_alicuota
				FROM ITF_COMARB_PADRON_IMPUESTOS_AUX c WITH (NOLOCK)
				inner JOIN CLI_DocumentosPFPJ f WITH (NOLOCK) ON c.CUIT = f.NUMERODOCUMENTO
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
		SELECT ISNULL((SELECT MAX(JTS_NOVEDAD) FROM CON_BITACORA_IMPUESTOS WITH (NOLOCK)),0)+ (ROW_NUMBER() OVER (ORDER BY T.Persona))
								, ''A''
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
								, NULL
								, NULL
								, ''''
								, ''''
								
	    	FROM (
        	SELECT DISTINCT cf.SIRCREB, CF.NUMEROPERSONAFISICA AS "PERSONA", v.codigocliente,a.cuit
        	FROM CLI_PERSONASFISICAS CF WITH (NOLOCK)
        	INNER JOIN VW_CLI_PERSONAS p WITH (NOLOCK) ON cf.NUMEROPERSONAfisica = p.[Numero de Persona]
			INNER JOIN ITF_COMARB_PADRON_IMPUESTOS_AUX A WITH (NOLOCK) ON p.[Numero de Documento]=a.CUIT
        	INNER JOIN VW_CLIENTES_PERSONAS v WITH (NOLOCK) ON v.numeropersona = p.[Numero de Persona]
        	WHERE CF.TZ_LOCK = 0
          	AND CF.sircreb != ''''
          	AND CF.NUMEROPERSONAFISICA = (
              	SELECT TOP 1 xx.numeropersonafisica
              	FROM CLI_PERSONASFISICAS xx WITH (NOLOCK)
              	INNER JOIN VW_CLIENTES_PERSONAS x WITH (NOLOCK) ON xx.numeropersonafisica = x.NUMEROPERSONA
              	WHERE x.codigocliente = v.codigocliente
              	ORDER BY xx.sircreb DESC
          		)
        	UNION ALL
        	SELECT DISTINCT CJ.SIRCREB, CJ.NUMEROPERSONAJURIDICA AS "PERSONA", v.codigocliente,a.cuit
        	FROM CLI_PERSONASJURIDICAS CJ WITH (NOLOCK)
        	INNER JOIN VW_CLI_PERSONAS p WITH (NOLOCK) ON cj.NUMEROPERSONAjuridica = p.[Numero de Persona]
			INNER JOIN ITF_COMARB_PADRON_IMPUESTOS_AUX A WITH (NOLOCK) ON p.[Numero de Documento]=a.CUIT
        	INNER JOIN VW_CLIENTES_PERSONAS v WITH (NOLOCK) ON v.numeropersona = p.[Numero de Persona]
        	WHERE CJ.TZ_LOCK = 0
          	AND CJ.sircreb != ''''
          	AND CJ.NUMEROPERSONAJURIDICA = (
              	SELECT TOP 1 xx.numeropersonajuridica
              	FROM CLI_PERSONASJURIDICAS xx WITH (NOLOCK)
              	INNER JOIN VW_CLIENTES_PERSONAS x WITH (NOLOCK) ON xx.numeropersonajuridica = x.NUMEROPERSONA
              	WHERE x.codigocliente = v.codigocliente
              	ORDER BY xx.sircreb DESC
          		)
    		) t

		
		DELETE FROM ITF_COMARB_PADRON
		WHERE PERIODO_APLICACION=(SELECT TOP 1 periodo_aplicacion FROM ITF_COMARB_PADRON_IMPUESTOS_AUX WITH (NOLOCK))

		INSERT INTO ITF_COMARB_PADRON
		SELECT CUIT, RAZON_SOCIAL, JURISDICCION, PERIODO_APLICACION, CRC_CONTRIBUYENTE, LETRA_ALICUOTA
		FROM ITF_COMARB_PADRON_IMPUESTOS_AUX WITH (NOLOCK)
		--Calcular la fecha límite	
		DECLARE @fechaLimite VARCHAR(8);
		SET @fechaLimite = CONVERT(VARCHAR(8), DATEADD(MONTH, -6, (SELECT fechaproceso FROM parametros WITH (NOLOCK))),112);

		-- Eliminar los registros anteriores a la fecha límite
		DELETE FROM ITF_COMARB_PADRON
		WHERE CAST(CONCAT(PERIODO_APLICACION,''01'') AS DATETIME) < CONVERT(DATE, @fechaLimite, 112);
		
		TRUNCATE TABLE ITF_COMARB_PADRON_IMPUESTOS_AUX

END
');
