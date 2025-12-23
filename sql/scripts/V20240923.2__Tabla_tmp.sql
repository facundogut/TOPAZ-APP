EXECUTE('
IF OBJECT_ID (''dbo.TEMP_ECOM_RECHAZO_NOV_ALTA'') IS NOT NULL
	DROP TABLE dbo.TEMP_ECOM_RECHAZO_NOV_ALTA
')

EXECUTE('
CREATE TABLE dbo.TEMP_ECOM_RECHAZO_NOV_ALTA
	(
	FechaRecepcion VARCHAR (8),
	FechaEnvio     VARCHAR (8),
	Asociacion     VARCHAR (3),
	Jurisdiccion   NUMERIC (2),
	NumDocFisico   NUMERIC (8),
	TipDocFisico   NUMERIC (1),
	TipoConcepto   NUMERIC (1),
	Importe        NUMERIC (11, 2),
	FecPriVcto     NUMERIC (8),
	TipoProducto   NUMERIC (4),
	DatosProducto  NUMERIC (25),
	NumCuota       NUMERIC (3),
	TipoCuota      NUMERIC (1),
	CodCuota       NUMERIC (1),
	TotCuota       NUMERIC (3),
	Descripcion    VARCHAR (20),
	DescError      VARCHAR (100),
	FechaProceso   DATETIME
	)
')

EXECUTE('
IF OBJECT_ID (''dbo.TEMP_ECOM_RECHAZO_NOV_COBRO'') IS NOT NULL
	DROP TABLE dbo.TEMP_ECOM_RECHAZO_NOV_COBRO
')

EXECUTE('
CREATE TABLE dbo.TEMP_ECOM_RECHAZO_NOV_COBRO
	(
	FechaRecepcion VARCHAR (8),
	FechaEnvio     VARCHAR (8),
	Asociacion     VARCHAR (3),
	Jurisdiccion   NUMERIC (2),
	NumDocFisico   NUMERIC (8),
	TipDocFisico   NUMERIC (1),
	TipoProducto   NUMERIC (4),
	DatosProducto  NUMERIC (25),
	TipoCuota      NUMERIC (1),
	NumCuota       NUMERIC (3),
	Importe        NUMERIC (11, 2),
	DescError      VARCHAR (100),
	FechaProceso   DATETIME
	)
')