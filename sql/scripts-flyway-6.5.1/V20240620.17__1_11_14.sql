Execute('IF OBJECT_ID (''dbo.ITF_I2000_IMPUESTOS'') IS NOT NULL
	DROP TABLE dbo.ITF_I2000_IMPUESTOS

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
	Nro_Liquidacion_I2000   NUMERIC (10),
	Nro_Transaccion_Asiento NUMERIC (19),
	Ref_Op_I2000            VARCHAR (19),
	Tipo_Operacion          NUMERIC (1),
	Modo_Operacion          NUMERIC (1),
	Nro_Liquidacion         NUMERIC (10),
	CONSTRAINT PK_IMP_I2000 PRIMARY KEY (Fecha_Contenidos_Imp, Id_Impuesto, CUIT_CUIL)
	)


INSERT INTO dbo.ITF_MASTER (TZ_LOCK, ID, DESCRIPCION, OBJ_KETTLE, P0_MODO, P0_TIPO, P0_CAPTION, P0_CONSTANTE, P1_MODO, P1_TIPO, P1_CAPTION, P1_CONSTANTE, P2_MODO, P2_TIPO, P2_CAPTION, P2_CONSTANTE, P3_MODO, P3_TIPO, P3_CAPTION, P3_CONSTANTE, P4_MODO, P4_TIPO, P4_CAPTION, P4_CONSTANTE, P5_MODO, P5_TIPO, P5_CAPTION, P5_CONSTANTE, P6_MODO, P6_TIPO, P6_CAPTION, P6_CONSTANTE, P7_MODO, P7_TIPO, P7_CAPTION, P7_CONSTANTE, P8_MODO, P8_TIPO, P8_CONSTANTE, P8_CAPTION, P9_MODO, P9_TIPO, P9_CAPTION, P9_CONSTANTE, TIPO_OBJ, COMENTARIO, ID_REPORTE, MODO_EJECUCION, KETTLE_NAME)
VALUES (0, 279, ''1.11.14 ITF - I2000 IMPUESTOS '', ''ITF_I2000_IMPUESTOS.kjb'', '''', '''', '''', '''', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', ''J'', '' '', 0, ''M'', NULL)



INSERT INTO dbo.ITF_MASTER_PARAMETROS (CODIGO, CODIGO_INTERFACE, FUNCIONALIDAD, ALFA_1, ALFA_2, ALFA_3, NUMERICO_1, NUMERICO_2, FECHA, IMPORTE_1, IMPORTE_2, TZ_LOCK)
VALUES (509, 0, ''1.11.14 I2000-Imp'', ''INSSSEP reciever'', '' '', ''sistemas.contabilidad@nbch.com.ar jefaturaimpuestos@nbch.com.ar'', 1, 0, NULL, 0, 0, 0)')




