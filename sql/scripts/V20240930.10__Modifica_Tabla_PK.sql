EXECUTE('
IF OBJECT_ID (''dbo.ITF_I2000_IMPUESTOS'') IS NOT NULL
	DROP TABLE dbo.ITF_I2000_IMPUESTOS
')

EXECUTE('
CREATE TABLE dbo.ITF_I2000_IMPUESTOS
	(
	Fecha_Contenidos_Imp    DATETIME NOT NULL,
	Subsistema              VARCHAR (2),
	Id_Impuesto             NUMERIC (6) NOT NULL,
	Fecha_Percepcion        DATETIME,
	Base_Imponible_Pesos    NUMERIC (15, 2),
	Alicuota                NUMERIC (15, 2),
	Importe                 NUMERIC (15, 2),
	Moneda                  NUMERIC (4),
	Base_Imponible_ME       NUMERIC (15, 2),
	Cotizacion              NUMERIC (15, 2),
	Impuesto_ME             NUMERIC (15, 2),
	Subsistema_Afectado     VARCHAR (2),
	Tipo_Cobro              VARCHAR (1),
	Tipo_Documento          VARCHAR (4),
	CUIT_CUIL               NUMERIC (15) NOT NULL,
	Categoria_IVA           VARCHAR (3),
	Tipo_DNI_Inscipcion     VARCHAR (2),
	DNI_Nro_Inscripcion     NUMERIC (15),
	Nombre_Razon_Social     VARCHAR (30),
	Sucursal                NUMERIC (5),
	Nro_Operacion           NUMERIC (15),
	Nro_Comprobante         NUMERIC (15),
	Desglose                NUMERIC (4),
	Linea                   NUMERIC (4),
	Nro_Liquidacion_I2000   NUMERIC (10) NOT NULL,
	Nro_Transaccion_Asiento NUMERIC (19),
	Ref_Op_I2000            VARCHAR (19),
	Tipo_Operacion          NUMERIC (1),
	Modo_Operacion          NUMERIC (1),
	Nro_Liquidacion         NUMERIC (10),
	CONSTRAINT PK_IMP_I2000 PRIMARY KEY (Fecha_Contenidos_Imp, Id_Impuesto, CUIT_CUIL, Nro_Liquidacion_I2000)
	)
')