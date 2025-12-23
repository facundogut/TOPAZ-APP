Execute('
DROP TABLE IF EXISTS dbo.ITF_LYRA_REC_REPORTE;
CREATE TABLE dbo.ITF_LYRA_REC_REPORTE
	(
	  shopkey          VARCHAR (20) NOT NULL
	, shopname         VARCHAR (60) NULL
	, convenio         INT NULL
	, rechazos         INT NULL
	, importeRechazado NUMERIC (15, 2) NULL
	, aceptado         INT NULL
	, importeAceptado  NUMERIC (15, 2) NULL
	, CONSTRAINT PK_LYRA_REP PRIMARY KEY (shopkey)
	)
')