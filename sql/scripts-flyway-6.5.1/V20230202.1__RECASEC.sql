Execute('CREATE TABLE dbo.ITF_GENERICA_ARCHIVOS
	(
	/*Campo ID_ITF = Nro Interfaz en ITF_MASTER
	//DESCRIPCION  = UTIL para saber que se esta dejando en esta tabla
	//TipoReg      = Puede ser usado como flag o indicar si es un registro de Cabezal-Detalle-Pie,etc
	//Estado       = Flag
	//Favor indicar en la interfaz y en la documentación que es lo que se va a grabar en cada campo
	*/
	ID       NUMERIC(16) IDENTITY(1,1) NOT NULL,
	ID_ITF   NUMERIC (16),
	DESCRIPCION VARCHAR (100) DEFAULT ('' '') NULL,
	TipoReg  VARCHAR(1) NULL,
	Importe1 NUMERIC(18,2) NULL,
	Importe2 NUMERIC(18,2) NULL,
	Importe3 NUMERIC(18,2) NULL,
	Importe4 NUMERIC(18,2) NULL,
	Importe5 NUMERIC(18,2) NULL,
	Importe6 NUMERIC(18,2) NULL,
	Importe7 NUMERIC(18,2) NULL,
	Importe8 NUMERIC(18,2) NULL,
	String1  VARCHAR(50)   NULL,
	String2  VARCHAR(50)   NULL,
	String3  VARCHAR(50)   NULL,
	String4  VARCHAR(50)   NULL,
	String5  VARCHAR(50)   NULL,
	String6  VARCHAR(50)   NULL,
	String7  VARCHAR(50)   NULL,
	String8  VARCHAR(100)  NULL,
	String9  VARCHAR(100)   NULL,
	String10 VARCHAR(100)   NULL,
	String11 VARCHAR(500)   NULL,
	String12 VARCHAR(500)   NULL,
	Fecha1   DATETIME NULL,
	Fecha2   DATETIME NULL,
	Fecha3   DATETIME NULL,
	Fecha4   DATETIME NULL,
	Fecha5   DATETIME NULL,
	ESTADO   VARCHAR(1) NULL,
	ID_TICKET NUMERIC(10) NULL
	
	CONSTRAINT PK_ITF_GENERICA_ARCHIVOS PRIMARY KEY (ID)
	)

INSERT INTO dbo.ITF_MASTER (TZ_LOCK, ID, DESCRIPCION, OBJ_KETTLE, P0_MODO, P0_TIPO, P0_CAPTION, P0_CONSTANTE, P1_MODO, P1_TIPO, P1_CAPTION, P1_CONSTANTE, P2_MODO, P2_TIPO, P2_CAPTION, P2_CONSTANTE, P3_MODO, P3_TIPO, P3_CAPTION, P3_CONSTANTE, P4_MODO, P4_TIPO, P4_CAPTION, P4_CONSTANTE, P5_MODO, P5_TIPO, P5_CAPTION, P5_CONSTANTE, P6_MODO, P6_TIPO, P6_CAPTION, P6_CONSTANTE, P7_MODO, P7_TIPO, P7_CAPTION, P7_CONSTANTE, P8_MODO, P8_TIPO, P8_CONSTANTE, P8_CAPTION, P9_MODO, P9_TIPO, P9_CAPTION, P9_CONSTANTE, TIPO_OBJ, COMENTARIO, ID_REPORTE, MODO_EJECUCION)
VALUES (0, 103, ''Rec de caja SECHEEP - RECASEC'', ''ITF_RECASEC.kjb'', ''P'', ''S'', ''Nombre Archivo'', '' '', ''P'', ''S'', ''Fecha (AAAAMMDD) '', '' '', '''', '''', '''', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', ''J'', '' '', 0, ''M'')
')

