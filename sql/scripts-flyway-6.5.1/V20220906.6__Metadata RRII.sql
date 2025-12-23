EXECUTE('
IF OBJECT_ID (''dbo.RRII_TARJETAS_CREDITO'') IS NOT NULL
	DROP TABLE dbo.RRII_TARJETAS_CREDITO
')
EXECUTE('
CREATE TABLE dbo.RRII_TARJETAS_CREDITO
	(
	Empresa            NUMERIC (3) NOT NULL,
	CodigoPartida      VARCHAR (12) NOT NULL,
	Cantidad           NUMERIC (10),
	FechadeInformacion NUMERIC (6) NOT NULL,
	Importe            NUMERIC (12),
	Tasa               NUMERIC (5),
	Marca              VARCHAR (4) NOT NULL,
	TZ_LOCK            NUMERIC (15) DEFAULT ((0)) NOT NULL,
	CONSTRAINT PK_TARJ_CRED PRIMARY KEY (Empresa, FechadeInformacion, CodigoPartida)
	)
')