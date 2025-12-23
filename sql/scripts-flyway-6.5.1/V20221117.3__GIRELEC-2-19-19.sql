Execute('
CREATE TABLE dbo.RelConvPadreNomArchivo
(
	ConvenioPadre          NUMERIC (15) DEFAULT ((0)) NOT NULL,
	NombreArchivo          VARCHAR (20) DEFAULT ('' '') NULL,
	TZ_LOCK                NUMERIC (15) DEFAULT ((0)) NOT NULL
	CONSTRAINT PK_RelConvPadreNomArchivo PRIMARY KEY (ConvenioPadre)
)
CREATE TABLE dbo.RelConvenioSucursalRendicion
(
	TipoConvenio           NUMERIC (5) DEFAULT ((0)) NOT NULL,
	CANAL                  NUMERIC (3) DEFAULT ('' '') NOT NULL,
	SUCURSAL               NUMERIC (5) DEFAULT ('' '') NOT NULL,
	TZ_LOCK                NUMERIC (15) DEFAULT ((0)) NOT NULL
	CONSTRAINT PK_RelConvenioSucursalRendicion PRIMARY KEY (TipoConvenio,CANAL,SUCURSAL)
)

CREATE TABLE dbo.ITF_GIRELEC_AUX
(
	ID_LINEA INT IDENTITY NOT NULL,
	REGISTRO VARCHAR (140) NULL,
	SUCURSAL VARCHAR (5) NULL,
	FECHACOBRO DATETIME NULL
	CONSTRAINT PK_ITF_GIRELEC_AUX PRIMARY KEY (ID_LINEA)
)

DELETE FROM dbo.ITF_MASTER WHERE ID = 50;
INSERT INTO dbo.ITF_MASTER (TZ_LOCK, ID, DESCRIPCION, OBJ_KETTLE, P0_MODO, P0_TIPO, P0_CAPTION, P0_CONSTANTE, P1_MODO, P1_TIPO, P1_CAPTION, P1_CONSTANTE, P2_MODO, P2_TIPO, P2_CAPTION, P2_CONSTANTE, P3_MODO, P3_TIPO, P3_CAPTION, P3_CONSTANTE, P4_MODO, P4_TIPO, P4_CAPTION, P4_CONSTANTE, P5_MODO, P5_TIPO, P5_CAPTION, P5_CONSTANTE, P6_MODO, P6_TIPO, P6_CAPTION, P6_CONSTANTE, P7_MODO, P7_TIPO, P7_CAPTION, P7_CONSTANTE, P8_MODO, P8_TIPO, P8_CONSTANTE, P8_CAPTION, P9_MODO, P9_TIPO, P9_CAPTION, P9_CONSTANTE, TIPO_OBJ, COMENTARIO, ID_REPORTE, MODO_EJECUCION)
VALUES (0, 50, ''Archivo Rendición GIRE'', ''ITF_GIRELEC.kjb'', ''P'', ''N'', ''Convenio Padre'', '' '', ''P'', ''S'', ''Fecha Rend(YYYYMMDD)'', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', ''J'', '' '', 0, ''M'')
')

