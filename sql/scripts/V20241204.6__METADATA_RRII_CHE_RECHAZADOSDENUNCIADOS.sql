EXECUTE('

IF OBJECT_ID (''dbo.RRII_CHE_RECHAZADOS_DENUNCIADOS'') IS NOT NULL
	DROP TABLE dbo.RRII_CHE_RECHAZADOS_DENUNCIADOS;
')
EXECUTE('
CREATE TABLE dbo.RRII_CHE_RECHAZADOS_DENUNCIADOS
	(
	CodigoEntidad                  VARCHAR (8000),
	NumeroSucursal                 VARCHAR (8000),
	NumeroCuentaCorriente          VARCHAR (8000),
	NumeroCheque                   VARCHAR (8000),
	AvisoAnio                      CHAR (2),
	AvisoNumero                    VARCHAR (8000),
	CodigoMovimiento               VARCHAR (1),
	ClaseRegistro                  NUMERIC (1),
	FechaNotificacionDenuncia_Anio CHAR (4),
	FechaNotificacionDenuncia_Mes  VARCHAR (8000),
	FechaNotificacionDenuncia_Dia  VARCHAR (8000),
	Causal                         VARCHAR (8),
	CodigoMoneda                   VARCHAR (8000),
	Importe                        VARCHAR (8000),
	FechaRechazo_Anio              CHAR (4),
	FechaRechazo_Mes               VARCHAR (8000),
	FechaRechazo_Dia               VARCHAR (8000),
	FechaRegistracion_Anio         CHAR (4),
	FechaRegistracion_Mes          VARCHAR (8000),
	FechaRegistracion_Dia          VARCHAR (8000),
	PlazoDifirimiento              VARCHAR (8000),
	FechaPagoCheque_Anio           CHAR (4),
	FechaPagoCheque_Mes            VARCHAR (8000),
	FechaPagoCheque_Dia            VARCHAR (8000),
	SinUso                         VARCHAR (66),
	FechaPagoMulta_Anio            CHAR (4),
	FechaPagoMulta_Mes             VARCHAR (8000),
	FechaPagoMulta_Dia             VARCHAR (8000),
	FechaCierreCuenta_Anio         CHAR (4),
	FechaCierreCuenta_Mes          VARCHAR (8000),
	FechaCierreCuenta_Dia          VARCHAR (8000),
	PrimerNumeroIdentificatorio    VARCHAR (8000),
	SegundoNumeroIdentificatorio   VARCHAR (8000),
	TercerNumeroIdentificatorio    VARCHAR (8000),
	CuartoNumeroIdentificatorio    VARCHAR (8000),
	QuintoNumeroIdentificatorio    VARCHAR (8000),
	SextoNumeroIdentificatorio     VARCHAR (8000),
	SeptimoNumeroIdentificatorio   VARCHAR (8000),
	OctavoNumeroIdentificatorio    VARCHAR (8000),
	NovenoNumeroIdentificatorio    VARCHAR (8000),
	DecimooNumeroIdentificatorio   VARCHAR (8000),
	FechaParametro                 DATETIME,
	estado_envio                   VARCHAR (1)
	);
')