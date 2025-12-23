EXECUTE('
IF OBJECT_ID (''dbo.ECOM_NOVEDADES_PRESTAMOS_HIS'') IS NOT NULL
	DROP TABLE dbo.ECOM_NOVEDADES_PRESTAMOS_HIS

CREATE TABLE dbo.ECOM_NOVEDADES_PRESTAMOS_HIS
	(
	FechaProceso    NUMERIC (8),
	Estado          VARCHAR (1) NOT NULL,
	Asociacion      NUMERIC (3) NOT NULL,
	Jurisdiccion    NUMERIC (2) NOT NULL,
	Num_Doc_Fisico  NUMERIC (8),
	Tipo_Doc_Fisico VARCHAR (1),
	TipoConcepto    NUMERIC (1) NOT NULL,
	Importe         NUMERIC (9,2),
	PrimerVto       NUMERIC (8),
	TipoProd        NUMERIC (4),
	Operacion       NUMERIC (14) NOT NULL,
	Ordinal         NUMERIC (6) NOT NULL,
	Producto        NUMERIC (5) NOT NULL,
	NroCuota        NUMERIC (3),
	TipoCuota       NUMERIC (1) NOT NULL,
	CodCuota        NUMERIC (1) NOT NULL,
	TotCuotas       NUMERIC (3),
	Resultado       VARCHAR (20)
	)
')

EXECUTE('
INSERT INTO dbo.ITF_MASTER (TZ_LOCK, ID, DESCRIPCION, OBJ_KETTLE, P0_MODO, P0_TIPO, P0_CAPTION, P0_CONSTANTE, P1_MODO, P1_TIPO, P1_CAPTION, P1_CONSTANTE, P2_MODO, P2_TIPO, P2_CAPTION, P2_CONSTANTE, P3_MODO, P3_TIPO, P3_CAPTION, P3_CONSTANTE, P4_MODO, P4_TIPO, P4_CAPTION, P4_CONSTANTE, P5_MODO, P5_TIPO, P5_CAPTION, P5_CONSTANTE, P6_MODO, P6_TIPO, P6_CAPTION, P6_CONSTANTE, P7_MODO, P7_TIPO, P7_CAPTION, P7_CONSTANTE, P8_MODO, P8_TIPO, P8_CONSTANTE, P8_CAPTION, P9_MODO, P9_TIPO, P9_CAPTION, P9_CONSTANTE, TIPO_OBJ, COMENTARIO, ID_REPORTE, MODO_EJECUCION)
VALUES (0, 161, ''Prestamos al SSM 052'', ''ECOM_SSMALTPR052.kjb'', '''', '''', '''', '' '', '''', '''', '''', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', ''J'', '' '', 0, ''M'')

INSERT INTO dbo.ITF_MASTER (TZ_LOCK, ID, DESCRIPCION, OBJ_KETTLE, P0_MODO, P0_TIPO, P0_CAPTION, P0_CONSTANTE, P1_MODO, P1_TIPO, P1_CAPTION, P1_CONSTANTE, P2_MODO, P2_TIPO, P2_CAPTION, P2_CONSTANTE, P3_MODO, P3_TIPO, P3_CAPTION, P3_CONSTANTE, P4_MODO, P4_TIPO, P4_CAPTION, P4_CONSTANTE, P5_MODO, P5_TIPO, P5_CAPTION, P5_CONSTANTE, P6_MODO, P6_TIPO, P6_CAPTION, P6_CONSTANTE, P7_MODO, P7_TIPO, P7_CAPTION, P7_CONSTANTE, P8_MODO, P8_TIPO, P8_CONSTANTE, P8_CAPTION, P9_MODO, P9_TIPO, P9_CAPTION, P9_CONSTANTE, TIPO_OBJ, COMENTARIO, ID_REPORTE, MODO_EJECUCION)
VALUES (0, 162, ''Prestamos al SSM 053'', ''ECOM_SSMALTPR053.kjb'', '''', '''', '''', '' '', '''', '''', '''', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', ''J'', '' '', 0, ''M'')
')