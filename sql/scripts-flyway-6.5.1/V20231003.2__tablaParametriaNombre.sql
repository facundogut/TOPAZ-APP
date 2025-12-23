execute('
DROP TABLE IF EXISTS RelConvPadreNomArchivo;
CREATE TABLE dbo.RelConvPadreNomArchivo
	(
	ConvenioPadre NUMERIC (15) DEFAULT ((0)) NOT NULL,
	NombreArchivo VARCHAR (20) DEFAULT ('' ''),
	TZ_LOCK       NUMERIC (15) DEFAULT ((0)) NOT NULL,
	CodigoEmpresa NUMERIC (15),
	CONSTRAINT PK_RelConvPadreNomArchivo PRIMARY KEY (ConvenioPadre)
	);
')