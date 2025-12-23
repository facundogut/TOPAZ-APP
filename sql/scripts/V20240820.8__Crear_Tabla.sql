execute('
IF OBJECT_ID (''dbo.ITF_TJD_CONS_EXT'') IS NOT NULL
	DROP TABLE dbo.ITF_TJD_CONS_EXT
')

execute('
CREATE TABLE dbo.ITF_TJD_CONS_EXT
	(
	TipoRegistro VARCHAR (2),
	Dato         VARCHAR (500),
	IdTarjeta    VARCHAR (20),
	CodCliente   NUMERIC (12)
	)
')