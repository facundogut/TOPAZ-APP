/****** Object:  StoredProcedure [dbo].[SP_MAILS_CARGOS_PENDIENTES]    Script Date: 23/02/2021 15:12:52 ******/
DROP PROCEDURE [dbo].[SP_MAILS_CARGOS_PENDIENTES]
GO

/****** Object:  StoredProcedure [dbo].[SP_MAILS_CARGOS_PENDIENTES]    Script Date: 23/02/2021 15:12:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_MAILS_CARGOS_PENDIENTES]
@id_proceso		NUMERIC,
@dt_proceso		DATE,
@ret_proceso	NUMERIC OUTPUT,
@msg_proceso	VARCHAR OUTPUT
AS
BEGIN
  	SET NOCOUNT ON;
  	DECLARE @CorreoOrigen	VARCHAR (128),
  	@CorreoDestino			VARCHAR (128),
  	@DescripcionCargo		VARCHAR(256),
	@Cuenta					NUMERIC (12, 0),
	@Fecha					DATETIME,
	@Moneda					NUMERIC (4, 0),
	@Importe				NUMERIC (15, 2),
	@Operacion				VARCHAR (50),
	@Data					VARCHAR (2048),
	@FechaProceso			DATETIME,
	@OutputSPCorreos		NUMERIC (10, 0)
	SET @DescripcionCargo = ''
	SET @Cuenta =			0
	SET @Fecha =			GETDATE()
	SET @Moneda =			0
	SET @Importe =			0
	SET @Operacion =		0

    DECLARE [SolicitudCargoCursor] CURSOR FOR
    
	SELECT
	S.CONCEPTO,
	(	SELECT SA.CUENTA 
		FROM SALDOS SA with (nolock)
		WHERE SA.JTS_OID = S.SALDO_JTS_OID 
				AND SA.TZ_LOCK = 0
	) AS CUENTA,
	GETDATE() AS FECHA,
	S.MONEDA AS MONEDA,
	S.IMPORTE AS IMPORTE,
	(	SELECT O.NOMBRE 
		FROM OPERACIONES O with (nolock)
		WHERE O.IDENTIFICACION = 
								(	SELECT A.OPERACION 
									FROM ASIENTOS A with (nolock) 
									WHERE A.FECHAPROCESO = S.FECHA_PROCESO 
											AND A.SUCURSAL = S.SUCURSALDIF
											AND A.ASIENTO = S.ASIENTODIF
								) 
				AND O.TZ_LOCK = 0
	) AS OPERACION,
	(	SELECT E.EMAIL 
		FROM	CLI_ClientePersona AS T with (nolock), 
				CLI_EMAILS AS E with (nolock), 
				GRL_ESTADOS_DE_CUENTA AS G with (nolock)
		WHERE G.JTSOID = S.SALDO_JTS_OID 
				AND T.CODIGOCLIENTE = G.CLIENTE 
				AND T.TITULARIDAD = 'T' 
				AND E.ID = T.NUMEROPERSONA
				AND E.FORMATO = G.FORMATO_MAIL 
				AND E.TIPO = G.TIPO_MAIL 
				AND E.ORDINAL = G.ORDINAL_MAIL
				AND T.TZ_LOCK = 0 
				AND E.TZ_LOCK = 0 
				AND G.TZ_LOCK = 0
	) AS CORREO_DESTINO
	FROM CI_SOLICITUD AS S with (nolock)
	WHERE S.TZ_LOCK = 0 --AND --agregar más cláusulas al where de ser necesario, como fecha de proceso por ejemplo.
	;	
	
  	OPEN [SolicitudCargoCursor];

	FETCH NEXT FROM [SolicitudCargoCursor] INTO @DescripcionCargo,@Cuenta,@Fecha,@Moneda,@Importe,@Operacion,@CorreoDestino;
	SET @CorreoOrigen = (SELECT ALFA FROM PARAMETROSGENERALES WHERE CODIGO = 205)
	SET @FechaProceso = (SELECT FECHAPROCESO FROM PARAMETROS)
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF @CorreoDestino IS NOT NULL
			BEGIN
				SET @Data = concat('Html=ComisionesPendientes.html;Variables=DescripcionCargo::',@DescripcionCargo,
					';Variables=Cuenta::',@Cuenta,';Variables=Fecha::',CONVERT(VARCHAR, @Fecha, 103),
			   		';Variables=Moneda::',@Moneda,';Variables=Importe::',@Importe,';Variables=Operacion::',@Operacion,';')
			    EXEC getCORREOS_A_ENVIAR  0, @OutputSPCorreos OUTPUT;
			   	PRINT @OutputSPCorreos;
				
				INSERT INTO CORREOS_A_ENVIAR (MAIL_OID, MAIL_TO, MAIL_FROM, DATA, INTENTOS, SUBJECT, FECHA_INGRESO, TZ_LOCK)
				VALUES (@OutputSPCorreos, @CorreoDestino, @CorreoOrigen, @Data, 0, 'NOTIFICACIÓN COMISIONES PENDIENTES DE PAGO', @FechaProceso, 0)
			END
		FETCH NEXT FROM [SolicitudCargoCursor] INTO @DescripcionCargo,@Cuenta,@Fecha,@Moneda,@Importe,@Operacion,@CorreoDestino;
	END
	 	
	CLOSE [SolicitudCargoCursor];
    DEALLOCATE [SolicitudCargoCursor];
    
    SET @ret_proceso = 1
	SET @msg_proceso = 'Proceso de Notificaciones Finalizado'
    
	SET NOCOUNT OFF;
END
GO


