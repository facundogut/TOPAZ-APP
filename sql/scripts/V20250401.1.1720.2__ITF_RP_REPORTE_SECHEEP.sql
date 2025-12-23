Execute('
DROP TABLE IF EXISTS dbo.ITF_RP_REPORTE_SECHEEP
DROP TABLE IF EXISTS dbo.ITF_RP_REPORTE_SECHEEP_SUBTOT

CREATE TABLE dbo.ITF_RP_REPORTE_SECHEEP
	(
	ID                INT IDENTITY NOT NULL,
	empresa           VARCHAR (40) NULL,
	fechaProceso      VARCHAR (10) NULL,
	nombreConvenio    VARCHAR (40) NULL,
	nombreArchivo     VARCHAR (12) NULL,
	fechaRendicion    VARCHAR (10) NULL,
	cuentaRecaudacion NUMERIC (15) NULL,
	fechaRecaudacion  VARCHAR (10) NULL,
	totalRecaudado    NUMERIC (15, 2) NULL,
	cantComprobantes  NUMERIC (7) NULL,
	impComision       NUMERIC (15, 2) NULL,
	cargoEspecifico   NUMERIC (15, 2) NULL,
	importeRendido    NUMERIC (15, 2) NULL,
	creditoXConvRec	NUMERIC (15, 2) NULL,
	impCredLEY25413 	NUMERIC (15, 2) NULL,
	retenIVA		NUMERIC (15, 2) NULL,
	cantMovConv		NUMERIC (15, 2) NULL,
	IVAsobrecomisiones		NUMERIC (15, 2) NULL,
	ImpDebitoLey25413		NUMERIC (15, 2) NULL,
	ImpDebitoLey25413I		NUMERIC (15, 2) NULL,
	CONSTRAINT PK_REP_SECH PRIMARY KEY (ID)
	)


CREATE TABLE dbo.ITF_RP_REPORTE_SECHEEP_SUBTOT
	(
	ID                INT IDENTITY NOT NULL,
	nombreConvenio           VARCHAR (40) NULL,
	id_convrec 		NUMERIC(15) NULL ,
	asientoRendicion NUMERIC(10) NULL,
	fechaRecaudacion      VARCHAR (10) NULL,
	totalRecaudado    NUMERIC (15, 2) NULL,
	cantComprobantes  NUMERIC (7) NULL,
	comisiones    NUMERIC (15, 2) NULL,
	IVAcomision    NUMERIC (15, 2) NULL,
	retencion   NUMERIC (15, 2) NULL
	CONSTRAINT PK_REP_SERC_SUBT PRIMARY KEY (ID)
	)
')