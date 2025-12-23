EXECUTE('
----
IF OBJECT_ID (''dbo.Che_CheqSolicitud'') IS NOT NULL
	DROP TABLE dbo.Che_CheqSolicitud
----
')
EXECUTE('
----
IF COLUMNPROPERTY(OBJECT_ID(''SALDOS''), ''PERMITE_ECHEQ'', ''ColumnId'') IS NULL
BEGIN
    ALTER TABLE SALDOS ADD PERMITE_ECHEQ VARCHAR(1) DEFAULT ('' '')
END
--
IF COLUMNPROPERTY(OBJECT_ID(''TOPESPRODUCTO''), ''ACEPTA_ECHEQ'', ''ColumnId'') IS NULL
BEGIN
    ALTER TABLE TOPESPRODUCTO ADD ACEPTA_ECHEQ VARCHAR(1)
END
--
IF COLUMNPROPERTY(OBJECT_ID(''CHE_CHEQUERAS''), ''LIMITE_EMISION'', ''ColumnId'') IS NULL
BEGIN
    ALTER TABLE CHE_CHEQUERAS ADD LIMITE_EMISION NUMERIC(15,2) DEFAULT ((0))
END
IF COLUMNPROPERTY(OBJECT_ID(''CHE_CHEQUERAS''), ''ORDEN'', ''ColumnId'') IS NULL
BEGIN
    ALTER TABLE CHE_CHEQUERAS ADD ORDEN NUMERIC(12) DEFAULT((0))
END
IF COLUMNPROPERTY(OBJECT_ID(''CHE_CHEQUERAS''), ''CANAL_ORIGEN'', ''ColumnId'') IS NULL
BEGIN
    ALTER TABLE CHE_CHEQUERAS ADD CANAL_ORIGEN NUMERIC(2) DEFAULT((0))
END
--
IF COLUMNPROPERTY(OBJECT_ID(''CHE_CHEQUES''), ''CANAL_ORIGEN'', ''ColumnId'') IS NULL
BEGIN
    ALTER TABLE CHE_CHEQUES ADD CANAL_ORIGEN NUMERIC(2) DEFAULT((0))
END
--
CREATE TABLE dbo.Che_CheqSolicitud
	(
	TZ_LOCK           NUMERIC (15) DEFAULT ((0)) NOT NULL,
	NroSolicitud      NUMERIC (12) DEFAULT ((0)) NOT NULL,
	Cuenta            NUMERIC (12) DEFAULT ((0)),
	Moneda            NUMERIC (4) DEFAULT ((0)),
	Cliente           NUMERIC (12) DEFAULT ((0)),
	CantCheques       NUMERIC (5) DEFAULT ((0)),
	Desde             NUMERIC (7) DEFAULT ((0)),
	Hasta             NUMERIC (7) DEFAULT ((0)),
	TipoChequera      VARCHAR (1) DEFAULT ('' ''),
	FechaIngreso      DATETIME,
	Estado            VARCHAR (1) DEFAULT ('' ''),
	FechaEstado       DATETIME,
	TipoCheques       VARCHAR (1) DEFAULT ('' ''),
	Cantidad          NUMERIC (3) DEFAULT ((0)),
	CantidadPendiente NUMERIC (3) DEFAULT ((0)),
	Producto          NUMERIC (5) DEFAULT ((0)),
	PaquetesDe        NUMERIC (5) DEFAULT ((0)),
	Sucursal          NUMERIC (5) DEFAULT ((0)) NOT NULL,
	NroProveedor      NUMERIC (5) DEFAULT ((0)),
	Serie             VARCHAR (3) DEFAULT ('' ''),
	TipoEntrega       VARCHAR (1) DEFAULT ('' ''),
	RetiroChequeras   NUMERIC (1) DEFAULT ((0)),
	AutNombre         VARCHAR (30) DEFAULT ('' ''),
	AutTipoDocumento  VARCHAR (4) DEFAULT ('' ''),
	AutNroDocumento   VARCHAR (20) DEFAULT ('' ''),
	TipoDireccion     NUMERIC (3) DEFAULT ((0)),
	SucursalEntrega   NUMERIC (5) DEFAULT ((0)),
	Comentarios       VARCHAR (100) DEFAULT ('' ''),
	Observaciones     VARCHAR (100) DEFAULT ('' ''),
	SINCARGO          VARCHAR (1) DEFAULT ('' ''),
	CANAL             NUMERIC (5) DEFAULT ((0)),
	NOMBDOSCHEQ       VARCHAR (25) DEFAULT ('' ''),
	NOMBRE_CHEQ       VARCHAR (25) DEFAULT ('' ''),
	NombreCliente     VARCHAR (35) DEFAULT ('' ''),
	LIMITE_EMISION    NUMERIC (15, 2) DEFAULT ((0)),
	ORDEN		  NUMERIC (12) DEFAULT ((0)),
	CANAL_ORIGEN      NUMERIC (2) DEFAULT ((0)),
	CONSTRAINT PK_Che_CheqSolicitud_01 PRIMARY KEY (NroSolicitud, Sucursal)
	)
----
')


