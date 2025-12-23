EXECUTE('
IF OBJECT_ID (''dbo.Che_CheqSolicitud'') IS NOT NULL
	DROP TABLE dbo.Che_CheqSolicitud


CREATE TABLE dbo.Che_CheqSolicitud
	(
	NroSolicitud      NUMERIC (12) DEFAULT ((0)) NOT NULL,
	Cuenta            NUMERIC (12) DEFAULT ((0)) NULL,
	Moneda            NUMERIC (4) DEFAULT ((0)) NULL,
	Cliente           NUMERIC (12) DEFAULT ((0)) NULL,
	CantCheques       NUMERIC (5) DEFAULT ((0)) NULL,
	Desde             NUMERIC (7) DEFAULT ((0)) NULL,
	Hasta             NUMERIC (7) DEFAULT ((0)) NULL,
	TipoChequera      VARCHAR (1) DEFAULT ('' '') NULL,
	FechaIngreso      DATETIME NULL,
	Estado            VARCHAR (1) DEFAULT ('' '') NULL,
	FechaEstado       DATETIME NULL,
	TipoCheques       VARCHAR (1) DEFAULT ('' '') NULL,
	Cantidad          NUMERIC (3) DEFAULT ((0)) NULL,
	CantidadPendiente NUMERIC (3) DEFAULT ((0)) NULL,
	Producto          NUMERIC (4) DEFAULT ((0)) NULL,
	PaquetesDe        NUMERIC (5) DEFAULT ((0)) NULL,
	Sucursal          NUMERIC (5) DEFAULT ((0)) NOT NULL,
	NroProveedor      NUMERIC (5) DEFAULT ((0)) NULL,
	Serie             VARCHAR (3) DEFAULT ('' '') NULL,
	TipoEntrega       VARCHAR (1) DEFAULT ('' '') NULL,
	RetiroChequeras   NUMERIC (1) DEFAULT ((0)) NULL,
	AutNombre         VARCHAR (30) DEFAULT ('' '') NULL,
	AutTipoDocumento  VARCHAR (4) DEFAULT ('' '') NULL,
	AutNroDocumento   VARCHAR (20) DEFAULT ('' '') NULL,
	TipoDireccion     NUMERIC (3) DEFAULT ((0)) NULL,
	SucursalEntrega   NUMERIC (5) DEFAULT ((0)) NULL,
	Comentarios       VARCHAR (100) DEFAULT ('' '') NULL,
	Observaciones     VARCHAR (100) DEFAULT ('' '') NULL,
	SINCARGO          VARCHAR (1) DEFAULT ('' '') NULL,
	CANAL             NUMERIC (5) DEFAULT ((0)) NULL,
	NOMBDOSCHEQ       VARCHAR (25) DEFAULT ('' '') NULL,
	NOMBRE_CHEQ       VARCHAR (25) DEFAULT ('' '') NULL,
	NombreCliente     VARCHAR (35) DEFAULT ('' '') NULL,
	TZ_LOCK           NUMERIC (15) DEFAULT ((0)) NOT NULL,
	CONSTRAINT PK_Che_CheqSolicitud_01 PRIMARY KEY (NroSolicitud,Sucursal)
	)
')


