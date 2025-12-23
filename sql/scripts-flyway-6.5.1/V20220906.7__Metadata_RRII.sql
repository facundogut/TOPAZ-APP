EXECUTE('
IF OBJECT_ID (''dbo.RRII_CANTIDADTC_EMITIDAS'') IS NOT NULL
	DROP TABLE dbo.RRII_CANTIDADTC_EMITIDAS
')
EXECUTE('
CREATE TABLE dbo.RRII_CANTIDADTC_EMITIDAS
	(
	codigoDisenio    NUMERIC (4) NOT NULL,
	codigoEntidad    NUMERIC (5) NOT NULL,
	fechaInformacion NUMERIC (6) NOT NULL,
	codigoPartida    VARCHAR (12) NOT NULL,
	cantidad         NUMERIC (10),
	rectificativa    VARCHAR (1) NOT NULL,
	sinUso           VARCHAR (10),
	TZ_LOCK          NUMERIC (15) DEFAULT ((0)) NOT NULL,
	CONSTRAINT PK_CANT_TC_EMIT PRIMARY KEY (codigoPartida, fechaInformacion, rectificativa)
	)
')