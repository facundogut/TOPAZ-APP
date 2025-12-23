EXECUTE('
IF OBJECT_ID (''dbo.ITF_AD_CREDICOM_AUX'') IS NOT NULL
	DROP TABLE dbo.ITF_AD_CREDICOM_AUX
')

EXECUTE('
CREATE TABLE dbo.ITF_AD_CREDICOM_AUX
	(
	ID                      NUMERIC (15) NOT NULL,
	Cod_Acreditacion        VARCHAR (2) DEFAULT ('' ''),
	Nro_Cuenta_Acreditacion VARCHAR (11) DEFAULT ('' ''),
	Cod_Tipo_Mov            VARCHAR (3) DEFAULT ('' ''),
	Fecha_Acreditacion      VARCHAR (10) DEFAULT ('' ''),
	Nro_Comprobante         VARCHAR (9) DEFAULT ('' ''),
	Importe_Acreditacion    VARCHAR (13) DEFAULT ('' ''),
	Cod_Admin               VARCHAR (1) DEFAULT ('' ''),
	Cod_Moneda              VARCHAR (1) DEFAULT ('' ''),
	Suc_Cuenta              VARCHAR (5) DEFAULT ('' ''),
	Nombre_Cliente          VARCHAR (30) DEFAULT ('' ''),
	Num_CUIT                VARCHAR (11) DEFAULT ('' ''),
	Num_Comercion           VARCHAR (20) DEFAULT ('' ''),
	CBU                     VARCHAR (22) DEFAULT ('' ''),
	Id_Univoco              VARCHAR (15) DEFAULT ('' ''),
	Cod_Respuesta           VARCHAR (3) DEFAULT ('' ''),
	Descripcion             VARCHAR (148) DEFAULT ('' ''),
	CONSTRAINT PK_ITF_AD_CREDICOM_AUX_01 PRIMARY KEY (ID)
	)

')
EXECUTE('
DELETE FROM dbo.ITF_MASTER
WHERE ID = 109

DELETE FROM dbo.ITF_MASTER
WHERE ID = 110

DELETE FROM dbo.ITF_MASTER_PARAMETROS
WHERE CODIGO = 190

DELETE FROM dbo.ITF_MASTER_PARAMETROS
WHERE CODIGO = 191

INSERT INTO dbo.ITF_MASTER_PARAMETROS (CODIGO, CODIGO_INTERFACE, FUNCIONALIDAD, ALFA_1, ALFA_2, ALFA_3, NUMERICO_1, NUMERICO_2, FECHA, IMPORTE_1, IMPORTE_2, TZ_LOCK)
VALUES (190, 2143, ''2.14.3 RM OUT CTANAC'', ''1'', '''', '''', 43101, 0, NULL, 0, 0, 0)

INSERT INTO dbo.ITF_MASTER_PARAMETROS (CODIGO, CODIGO_INTERFACE, FUNCIONALIDAD, ALFA_1, ALFA_2, ALFA_3, NUMERICO_1, NUMERICO_2, FECHA, IMPORTE_1, IMPORTE_2, TZ_LOCK)
VALUES (191, 2143, ''2.14.3 RM OUT CTADOL'', ''2'', '''', '''', 45900, 0, NULL, 0, 0, 0)

INSERT INTO dbo.ITF_MASTER (TZ_LOCK, ID, DESCRIPCION, OBJ_KETTLE, P0_MODO, P0_TIPO, P0_CAPTION, P0_CONSTANTE, P1_MODO, P1_TIPO, P1_CAPTION, P1_CONSTANTE, P2_MODO, P2_TIPO, P2_CAPTION, P2_CONSTANTE, P3_MODO, P3_TIPO, P3_CAPTION, P3_CONSTANTE, P4_MODO, P4_TIPO, P4_CAPTION, P4_CONSTANTE, P5_MODO, P5_TIPO, P5_CAPTION, P5_CONSTANTE, P6_MODO, P6_TIPO, P6_CAPTION, P6_CONSTANTE, P7_MODO, P7_TIPO, P7_CAPTION, P7_CONSTANTE, P8_MODO, P8_TIPO, P8_CONSTANTE, P8_CAPTION, P9_MODO, P9_TIPO, P9_CAPTION, P9_CONSTANTE, TIPO_OBJ, COMENTARIO, ID_REPORTE, MODO_EJECUCION)
VALUES (0, 109, ''Adintar Credicom'', ''ITF_TC_AD_CREDICOM.kjb'', '''', '''', '''', '' '', '''', '''', '''', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', ''J'', '' '', 0, ''M'')

INSERT INTO dbo.ITF_MASTER (TZ_LOCK, ID, DESCRIPCION, OBJ_KETTLE, P0_MODO, P0_TIPO, P0_CAPTION, P0_CONSTANTE, P1_MODO, P1_TIPO, P1_CAPTION, P1_CONSTANTE, P2_MODO, P2_TIPO, P2_CAPTION, P2_CONSTANTE, P3_MODO, P3_TIPO, P3_CAPTION, P3_CONSTANTE, P4_MODO, P4_TIPO, P4_CAPTION, P4_CONSTANTE, P5_MODO, P5_TIPO, P5_CAPTION, P5_CONSTANTE, P6_MODO, P6_TIPO, P6_CAPTION, P6_CONSTANTE, P7_MODO, P7_TIPO, P7_CAPTION, P7_CONSTANTE, P8_MODO, P8_TIPO, P8_CONSTANTE, P8_CAPTION, P9_MODO, P9_TIPO, P9_CAPTION, P9_CONSTANTE, TIPO_OBJ, COMENTARIO, ID_REPORTE, MODO_EJECUCION)
VALUES (0, 110, ''Adintar Credicom Reporte'', ''ITF_TC_AD_CREDICOM_REPORTE.kjb'', '''', '''', '''', '' '', '''', '''', '''', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', ''J'', '' '', 0, ''M'')

')

