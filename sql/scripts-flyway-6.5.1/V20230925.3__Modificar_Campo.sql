EXECUTE('
IF OBJECT_ID (''dbo.ECOM_NOVEDADES_PRESTAMOS_HIS'') IS NOT NULL
	DROP TABLE dbo.ECOM_NOVEDADES_PRESTAMOS_HIS
')

EXECUTE('
CREATE TABLE dbo.ECOM_NOVEDADES_PRESTAMOS_HIS
	(
	FechaProceso    NUMERIC (8),
	Estado          VARCHAR (1) NOT NULL,
	Asociacion      NUMERIC (3) NOT NULL,
	Jurisdiccion    NUMERIC (2) NOT NULL,
	Num_Doc_Fisico  NUMERIC (20),
	Tipo_Doc_Fisico VARCHAR (1),
	TipoConcepto    NUMERIC (1) NOT NULL,
	Importe         NUMERIC (15, 2),
	PrimerVto       NUMERIC (8),
	TipoProd        NUMERIC (4),
	Operacion       NUMERIC (14) NOT NULL,
	Ordinal         NUMERIC (6) NOT NULL,
	Producto        NUMERIC (10) NOT NULL,
	NroCuota        NUMERIC (3),
	TipoCuota       NUMERIC (1) NOT NULL,
	CodCuota        NUMERIC (1) NOT NULL,
	TotCuotas       NUMERIC (5),
	Descripcion     VARCHAR (20)
	)
')