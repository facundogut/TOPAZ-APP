execute('

CREATE TABLE dbo.MA_CONVENIO_PRODUCTOS
	(
	ConvenioPago NUMERIC (15) DEFAULT ((0)) NOT NULL,
	TipoConvenio NUMERIC (5)  DEFAULT ((0)), 	
	Producto     NUMERIC (5) DEFAULT ((0)) NOT NULL,
	NomConvPago	 VARCHAR (40) DEFAULT ('' ''),
	TZ_LOCK      NUMERIC (15) DEFAULT ((0)) NOT NULL,
	CONSTRAINT PK_MA_CONVENIO_PRODUCTOS_01 PRIMARY KEY (ConvenioPago, TipoConvenio, Producto)
	)

')
