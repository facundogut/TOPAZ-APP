EXECUTE('
CREATE TABLE dbo.ITF_CUENTAS_BEE
	(
	CUIT                 NUMERIC (13) DEFAULT ((0)) NOT NULL,
	TipoCuenta           VARCHAR (2) DEFAULT ('' '') NOT NULL,
	NroCuenta            NUMERIC (19) DEFAULT ((0)) NOT NULL,
	Estado               VARCHAR (2) DEFAULT ('' '') NOT NULL,
	Cuenta_Principal     VARCHAR (1) DEFAULT ('' '') NOT NULL,
	Producto             VARCHAR (1) DEFAULT ('' '') NOT NULL,
	Fecha_ultimo_refresh NUMERIC (8) DEFAULT ((0)),
	Fecha_ultimo_extract NUMERIC (8) DEFAULT ((0)) NOT NULL,
	Fecha_alta           NUMERIC (8) DEFAULT ((0)),
	Fecha_baja           NUMERIC (8) DEFAULT ((0)),
	Fecha_reactivacion   NUMERIC (8) DEFAULT ((0)),
	TZ_LOCK              NUMERIC (15) DEFAULT ((0)) NOT NULL,
	CONSTRAINT PK_ITF_CUENTAS_BEE_01 PRIMARY KEY (CUIT, TipoCuenta, NroCuenta)
	)
')