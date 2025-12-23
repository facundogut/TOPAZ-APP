/****** Object:  StoredProcedure [dbo].[ENVIAR_CORREOS_CTAS_INMOVILIZADAS]    Script Date: 23/02/2021 14:41:29 ******/
DROP PROCEDURE [dbo].[ENVIAR_CORREOS_CTAS_INMOVILIZADAS]
GO

/****** Object:  StoredProcedure [dbo].[ENVIAR_CORREOS_CTAS_INMOVILIZADAS]    Script Date: 23/02/2021 14:41:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[ENVIAR_CORREOS_CTAS_INMOVILIZADAS] (@dataCorreo varchar(2048)) AS 
BEGIN 

DECLARE 
@mailOid	numeric(10, 0),
@mailTo		varchar(128),
@mailFrom	varchar(128),
@intentos	numeric(1, 0),
@asunto		varchar(255),
@fechaIngreso datetime,
@tzLock		numeric(15, 0),
@existeEnTabla numeric(15,0),
@OutputSPCorreos NUMERIC (10, 0)

SET @intentos =		0 
SET @tzLock =		0 
SET @asunto =		'Notificación de cuenta inmovilizada'
SET @mailFrom =		'NBCH@localhost.com'


SELECT @fechaIngreso = PARAMETROS.FECHAPROCESO 
FROM dbo.PARAMETROS with (nolock)



DECLARE cursorCorreo CURSOR FOR
SELECT
	CE.EMAIL

FROM
	PARAMETROS P with (nolock),
	VTA_HISTORICO_INMOVILIZADAS HI with (nolock)
INNER JOIN GRL_ESTADOS_DE_CUENTA GE with (nolock) ON
	HI.JTS_OID_SALDO = GE.JTSOID
INNER JOIN CLI_CLIENTEPERSONA CC with (nolock) ON
	GE.CLIENTE = CC.CODIGOCLIENTE
	AND TITULARIDAD = 'T'
INNER JOIN CLI_EMAILS CE with (nolock) ON
	CC.NUMEROPERSONA = CE.ID
	AND CE.TIPO = GE.TIPO_MAIL 
	AND CE.FORMATO = GE.FORMATO_MAIL 
	AND CE.ORDINAL = GE.ORDINAL_MAIL  
	
WHERE
	HI.TZ_LOCK = 0 AND GE.TZ_LOCK = 0 AND CC.TZ_LOCK = 0 
	--AND CE.TZ_LOCK = 0
	AND HI.ESTADO_CTA = 'I'
	AND HI.FECHA_NOTIFICACION IS NULL
	AND HI.MOTIVO_INMOVILIZACION = 'D'
	AND DATEDIFF(day, HI.FECHA_INMOVILIZACION, P.FECHAPROCESO) = 0
	
	
		
		
	OPEN cursorCorreo 
	
	
	WHILE 1=1

	BEGIN
	
		
	FETCH cursorCorreo INTO 
	@mailTo 
	
	IF @@FETCH_STATUS <> 0
    BREAK
	
SELECT @mailOid = MAX(MAIL_OID)+ 1 
FROM CORREOS_A_ENVIAR with (nolock)


SELECT @existeEnTabla = COUNT(*) 
FROM CORREOS_A_ENVIAR with (nolock) 
WHERE MAIL_TO = @mailTo 
		AND MAIL_FROM = @mailFrom 
		AND DATA = @dataCorreo
		AND INTENTOS = @intentos 
		AND SUBJECT = @asunto 
		AND FECHA_INGRESO = @fechaIngreso 
		AND TZ_LOCK = 0



		IF @existeEnTabla = 0
		BEGIN
		EXEC getCORREOS_A_ENVIAR  0, @OutputSPCorreos OUTPUT;
		INSERT
			INTO
				CORREOS_A_ENVIAR	(	MAIL_OID, MAIL_TO, 
										MAIL_FROM, 
										[DATA], 
										INTENTOS,
										SUBJECT, 
										FECHA_INGRESO, 
										TZ_LOCK
									)
			VALUES(@OutputSPCorreos, @mailTo, @mailFrom, @dataCorreo, @intentos, @asunto, @fechaIngreso, 0);
		END
		
		PRINT @mailOid

	END 
	
	IF @@TRANCOUNT > 0
    COMMIT WORK 
	
	CLOSE cursorCorreo
	DEALLOCATE cursorCorreo
END;
GO