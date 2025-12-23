EXECUTE('

IF OBJECT_ID (''dbo.CHE_CHEQUESIMPRENTA'') IS NOT NULL
	DROP TABLE dbo.CHE_CHEQUESIMPRENTA


CREATE TABLE dbo.CHE_CHEQUESIMPRENTA
	(
	NroSolicitud                 NUMERIC (12) DEFAULT ((0)) NOT NULL,
	Sucursal                     NUMERIC (5) DEFAULT ((0)) NOT NULL,
	Cuenta                       NUMERIC (12) DEFAULT ((0)) NULL,
	Cliente                      NUMERIC (12) DEFAULT ((0)) NULL,
	Moneda                       NUMERIC (4) DEFAULT ((0)) NULL,
	Fecha                        DATETIME NULL,
	TipoCheques                  VARCHAR (1) DEFAULT ('' '') NULL,
	Cantidad                     NUMERIC (3) DEFAULT ((0)) NULL,
	CantCheques                  NUMERIC (5) DEFAULT ((0)) NULL,
	PaquetesDe                   NUMERIC (5) DEFAULT ((0)) NULL,
	Serie                        VARCHAR (3) DEFAULT ('' '') NULL,
	NroLote                      NUMERIC (3) DEFAULT ((0)) NULL,
	Estado                       VARCHAR (1) DEFAULT ('' '') NULL,
	NOMB_CLIENTE                 VARCHAR (50) DEFAULT ('' '') NULL,
	TipoChequera                 VARCHAR (1) DEFAULT ('' '') NULL,
	Producto                     NUMERIC (4) DEFAULT ((0)) NULL,
	TipoEntrega                  VARCHAR (1) DEFAULT ('' '') NULL,
	RetiroChequeras              NUMERIC (1) DEFAULT ((0)) NULL,
	AutNombre                    VARCHAR (30) DEFAULT ('' '') NULL,
	AutTipoDocumento             VARCHAR (4) DEFAULT ('' '') NULL,
	AutNroDocumento              VARCHAR (20) DEFAULT ('' '') NULL,
	TipoDireccion                NUMERIC (3) DEFAULT ((0)) NULL,
	SucursalEntrega              NUMERIC (3) DEFAULT ((0)) NULL,
	NROPUERTA                    VARCHAR (10) DEFAULT ('' '') NULL,
	NROAPARTAMENTO               VARCHAR (5) DEFAULT ('' '') NULL,
	NROPISO                      NUMERIC (3) DEFAULT ((0)) NULL,
	CIUDAD                       VARCHAR (60) DEFAULT ('' '') NULL,
	CALLE                        VARCHAR (60) DEFAULT ('' '') NULL,
	TZ_LOCK                      NUMERIC (15) DEFAULT ((0)) NOT NULL,
	NROSOLICITUD_SUCURSAL_CUENTA NUMERIC (12) NULL,
	CONSTRAINT PK_CHE_CHEQUESIMPRENTA_01 PRIMARY KEY (NroSolicitud,Sucursal)
	)
')


