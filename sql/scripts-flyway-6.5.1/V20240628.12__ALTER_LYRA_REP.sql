EXECUTE('
DROP TABLE IF EXISTS dbo.ITF_LYRA_REC_REPORTE;
CREATE TABLE dbo.ITF_LYRA_REC_REPORTE
	(
	  shopkey          VARCHAR (20) NOT NULL
	, shopname         VARCHAR (60) DEFAULT('''')
	, status 			VARCHAR(1) DEFAULT(''-'')
	, cant_reg			INT NULL
	, convenio         INT DEFAULT(-1)
	, importe NUMERIC (15, 2) DEFAULT(0)
	, CONSTRAINT PK_LYRA_REP PRIMARY KEY (shopkey, status)
	)
')

