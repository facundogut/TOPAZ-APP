EXECUTE('
IF OBJECT_ID (''dbo.SOS_LAVADOPERDFILDET'') IS NOT NULL
	DROP TABLE dbo.SOS_LAVADOPERDFILDET
')

EXECUTE('
CREATE TABLE dbo.SOS_LAVADOPERDFILDET
	(
	EMPRESA               VARCHAR (4),
	IDENTTRIBUTARIATIPO   NUMERIC (2),
	IDENTTRIBUTARIANUMERO VARCHAR (11),
	ORIGEN                VARCHAR (20),
	MONTO                 NUMERIC (15),
	FECHAVIGENCIADESDE    NUMERIC (8),
	FECHAVIGENCIAHASTA    NUMERIC (8),
	OBSERVACIONES         VARCHAR (50),
	FECHAPROCESO          NUMERIC (8),
	PERIODO               NUMERIC (6)
	)
')

EXECUTE('
IF OBJECT_ID (''dbo.ITF_UIF_Agencieros'') IS NOT NULL
	DROP TABLE dbo.ITF_UIF_Agencieros
')

EXECUTE('
CREATE TABLE dbo.ITF_UIF_Agencieros
	(
	TipoPersona           VARCHAR (1),
	IdentTributariaTipo   NUMERIC (2),
	IdentTributariaNumero NUMERIC (11),
	SUCURSAL              NUMERIC (15),
	CuentaVistaACRec      NUMERIC (11),
	Producto              NUMERIC (10),
	SaldoAC               NUMERIC (15, 2),
	Promedio              NUMERIC (15, 2),
	Meses                 NUMERIC (4)
	)
')

EXECUTE('
IF OBJECT_ID (''dbo.ITF_HIST_UIF_AGENCIEROS'') IS NOT NULL
	DROP TABLE dbo.ITF_HIST_UIF_AGENCIEROS
')

EXECUTE('
CREATE TABLE dbo.ITF_HIST_UIF_AGENCIEROS
	(
	FechaDesde            NUMERIC (8),
	FechaHasta            NUMERIC (8),
	TipoPersona           VARCHAR (1),
	IdentTributariaTipo   NUMERIC (2),
	IdentTributariaNumero NUMERIC (11),
	SUCURSAL              NUMERIC (15),
	CuentaVistaACRec      NUMERIC (11),
	Producto              NUMERIC (10),
	SaldoAC               NUMERIC (15, 2),
	Promedio              NUMERIC (15, 2),
	Meses                 NUMERIC (4),
	FechaProceso          DATE
	)
')