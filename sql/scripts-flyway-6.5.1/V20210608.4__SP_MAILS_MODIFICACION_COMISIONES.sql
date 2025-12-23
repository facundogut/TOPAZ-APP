EXECUTE('
----
ALTER PROCEDURE [SP_MAILS_MODIFICACION_COMISIONES] 
@Cargo NUMERIC(4,0),
@Tasa NUMERIC(11,6),
@Importe NUMERIC(15,2),
@Segmento VARCHAR (150)
AS
BEGIN
  	SET NOCOUNT ON;
  	DECLARE @CorreoOrigen	VARCHAR (128),
  	@CorreoDestino			VARCHAR (128),
  	@DescripcionCargo		VARCHAR(256),
	@Fecha					DATETIME,
	@Data					VARCHAR (2048),
	@FechaProceso			DATETIME,
	@OutputSPCorreos 		NUMERIC (10, 0)	
	SET @DescripcionCargo = ''''
	SET @Fecha =			GETDATE()
	SET @CorreoOrigen = (SELECT ALFA FROM PARAMETROSGENERALES with (nolock) WHERE [CODIGO] = 205)
	SET @FechaProceso = (SELECT FECHAPROCESO FROM PARAMETROS with (nolock))
	--importe y tasa son parametro
	--segmento es parámetro
	SET @DescripcionCargo = (SELECT DESCRIPCION FROM CI_CARGOS with (nolock) WHERE ID_CARGO = @Cargo)
	
    DECLARE [ModificCargoCursor] CURSOR FOR
    
		SELECT
		DISTINCT E.EMAIL AS CORREO_DESTINO
		FROM	CLI_EMAILS AS E with (nolock), 
				CLI_ClientePersona AS T with (nolock), 
				GRL_ESTADOS_DE_CUENTA AS G with (nolock), 
				SALDOS AS S with (nolock)
		WHERE
		E.ID = T.NUMEROPERSONA 
		AND T.TITULARIDAD = ''T''
		AND T.CODIGOCLIENTE = G.CLIENTE 
		AND G.JTSOID = S.JTS_OID
		AND S.C1651 <> 1 
		AND S.PRODUCTO IN (SELECT PRODUCTO 
							FROM CI_RELPRODEVENTO AS R with (nolock) 
							WHERE R.TZ_LOCK = 0 
									AND R.NOTIFICA = ''S''
									AND R.EVENTO IN (	SELECT V.ID_EVENTO 
														FROM CI_CARGOS_X_EVENTO AS V with (nolock) 
														WHERE V.ID_CARGO = @Cargo
													)
							)
		AND S.TZ_LOCK = 0 
		AND T.TZ_LOCK = 0 
		AND G.TZ_LOCK = 0 
		AND E.TZ_LOCK = 0
	 	--AND --agregar más cláusulas al where de ser necesario.
		;	
	
  	OPEN [ModificCargoCursor];

		FETCH NEXT FROM [ModificCargoCursor] INTO @CorreoDestino;
		
		WHILE @@FETCH_STATUS = 0
		BEGIN
			IF @CorreoDestino IS NOT NULL
				BEGIN
					SET @Data = concat(''Html=ModificaciónCargos.html;Variables=DescripcionCargo::'',
										@DescripcionCargo,
										'';Variables=Fecha::''
										,CONVERT(VARCHAR, @Fecha, 103),
										'';Variables=Tasa::'',
										@Tasa,
										'';Variables=Importe::'',
										@Importe,'';Variables=Segmento::'',
										@Segmento
										)
					EXEC getCORREOS_A_ENVIAR  0, @OutputSPCorreos OUTPUT;
			   		PRINT @OutputSPCorreos;
					INSERT INTO CORREOS_A_ENVIAR (ORDINAL, MAIL_TO, MAIL_FROM, DATA, INTENTOS, SUBJECT, FECHA_INGRESO, TZ_LOCK)
					VALUES (@OutputSPCorreos, @CorreoDestino, @CorreoOrigen, @Data, 0, ''NOTIFICACIÓN POR MODIFICACIÓN DE COMISIONES'', @FechaProceso, 0)
				END
	 		FETCH NEXT FROM [ModificCargoCursor] INTO @CorreoDestino;
	 	END
	 	
	CLOSE [ModificCargoCursor];
    DEALLOCATE [ModificCargoCursor];
     
	SET NOCOUNT OFF;
END
----
')
