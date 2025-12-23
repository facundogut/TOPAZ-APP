execute('
delete from dbo.ITF_MASTER where id=223

INSERT INTO dbo.ITF_MASTER (TZ_LOCK, ID, DESCRIPCION, OBJ_KETTLE, P0_MODO, P0_TIPO, P0_CAPTION, P0_CONSTANTE, P1_MODO, P1_TIPO, P1_CAPTION, P1_CONSTANTE, P2_MODO, P2_TIPO, P2_CAPTION, P2_CONSTANTE, P3_MODO, P3_TIPO, P3_CAPTION, P3_CONSTANTE, P4_MODO, P4_TIPO, P4_CAPTION, P4_CONSTANTE, P5_MODO, P5_TIPO, P5_CAPTION, P5_CONSTANTE, P6_MODO, P6_TIPO, P6_CAPTION, P6_CONSTANTE, P7_MODO, P7_TIPO, P7_CAPTION, P7_CONSTANTE, P8_MODO, P8_TIPO, P8_CONSTANTE, P8_CAPTION, P9_MODO, P9_TIPO, P9_CAPTION, P9_CONSTANTE, TIPO_OBJ, COMENTARIO, ID_REPORTE, MODO_EJECUCION)
VALUES (0, 223, ''ITF - AFIP CREDEBPAD 2.1.15'', ''ITF_AFIP_CREDEBPAD.kjb'', '''', '''', '''', '' '', '''', '''', '''', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', ''J'', '' '', 0, ''M'')

drop table if exists ITF_BEN_FISCAL_CREDEB
drop table if exists ITF_PADRON_FISCAL_CREDEB_aux
drop table if exists ITF_PADRON_FISCAL_CREDEB
drop table if exists ITF_BEN_FISCAL_CREDEB_INCONSISTENCIAS
drop table if exists Beneficios_fiscales
drop table if exists Valores_alicuota

create TABLE ITF_BEN_FISCAL_CREDEB
	(
	ID INT IDENTITY PRIMARY key,
	FECHAPROCESO DATETIME,
	CUIT numeric (11),	
	CBU numeric (22),
	CODIGO_BENEFICIO numeric (5),
	FECHA_VIG DATETIME,
	SEGMENTO numeric (2),
	ALICUOTA DECIMAL(5,3)
	)


create TABLE ITF_PADRON_FISCAL_CREDEB_aux
	(
	ID INT IDENTITY PRIMARY key,
	CUIT numeric (11),	
	cbu numeric (22),
	codigo_beneficio numeric (5),
	FECHA_vigencia datetime
	)

create TABLE ITF_PADRON_FISCAL_CREDEB
	(
	ID INT IDENTITY PRIMARY key,
	CUIT numeric (11),	
	cbu numeric (22),
	codigo_beneficio numeric (5),
	FECHA_vigencia datetime
	)

    create TABLE ITF_BEN_FISCAL_CREDEB_INCONSISTENCIAS
	(
	ID INT IDENTITY PRIMARY key,
	fecha_proceso DATETIME,
	COD_CLIENTE NUMERIC (11, 0),
	NRO_PERSONA NUMERIC (11, 0),
	RAZON_SOCIAL VARCHAR (80),
	CUIT VARCHAR (11),	
	cbu VARCHAR (22),
	codigo_beneficio VARCHAR (5),
	FECHA_vigencia VARCHAR (10),
	causa_rechazo VARCHAR (200),	
	)

create TABLE Beneficios_fiscales (
    ID_beneficio INT PRIMARY KEY,
    Segmento_alicuota INT,
)


INSERT INTO Beneficios_fiscales (ID_beneficio, Segmento_alicuota) VALUES (1, 1);
INSERT INTO Beneficios_fiscales (ID_beneficio, Segmento_alicuota) VALUES (2, 1);
INSERT INTO Beneficios_fiscales (ID_beneficio, Segmento_alicuota) VALUES (3, 1);
INSERT INTO Beneficios_fiscales (ID_beneficio, Segmento_alicuota) VALUES (4, 1);
INSERT INTO Beneficios_fiscales (ID_beneficio, Segmento_alicuota) VALUES (5, 1);
INSERT INTO Beneficios_fiscales (ID_beneficio, Segmento_alicuota) VALUES (6, 1);
INSERT INTO Beneficios_fiscales (ID_beneficio, Segmento_alicuota) VALUES (7, 1);
INSERT INTO Beneficios_fiscales (ID_beneficio, Segmento_alicuota) VALUES (8, 2);
INSERT INTO Beneficios_fiscales (ID_beneficio, Segmento_alicuota) VALUES (9, 2);
INSERT INTO Beneficios_fiscales (ID_beneficio, Segmento_alicuota) VALUES (10, 2);
INSERT INTO Beneficios_fiscales (ID_beneficio, Segmento_alicuota) VALUES (11, 2);
INSERT INTO Beneficios_fiscales (ID_beneficio, Segmento_alicuota) VALUES (12, 2);
INSERT INTO Beneficios_fiscales (ID_beneficio, Segmento_alicuota) VALUES (13, 2);
INSERT INTO Beneficios_fiscales (ID_beneficio, Segmento_alicuota) VALUES (14, 2);
INSERT INTO Beneficios_fiscales (ID_beneficio, Segmento_alicuota) VALUES (15, 2);
INSERT INTO Beneficios_fiscales (ID_beneficio, Segmento_alicuota) VALUES (16, 2);
INSERT INTO Beneficios_fiscales (ID_beneficio, Segmento_alicuota) VALUES (17, 2);
INSERT INTO Beneficios_fiscales (ID_beneficio, Segmento_alicuota) VALUES (18, 3);
INSERT INTO Beneficios_fiscales (ID_beneficio, Segmento_alicuota) VALUES (19, 3);
INSERT INTO Beneficios_fiscales (ID_beneficio, Segmento_alicuota) VALUES (20, 3);
INSERT INTO Beneficios_fiscales (ID_beneficio, Segmento_alicuota) VALUES (21, 3);
INSERT INTO Beneficios_fiscales (ID_beneficio, Segmento_alicuota) VALUES (22, 3);
INSERT INTO Beneficios_fiscales (ID_beneficio, Segmento_alicuota) VALUES (23, 3);
INSERT INTO Beneficios_fiscales (ID_beneficio, Segmento_alicuota) VALUES (24, 3);
INSERT INTO Beneficios_fiscales (ID_beneficio, Segmento_alicuota) VALUES (25, 3);
INSERT INTO Beneficios_fiscales (ID_beneficio, Segmento_alicuota) VALUES (26, 3);
INSERT INTO Beneficios_fiscales (ID_beneficio, Segmento_alicuota) VALUES (27, 3);
INSERT INTO Beneficios_fiscales (ID_beneficio, Segmento_alicuota) VALUES (28, 3);
INSERT INTO Beneficios_fiscales (ID_beneficio, Segmento_alicuota) VALUES (29, 3);
INSERT INTO Beneficios_fiscales (ID_beneficio, Segmento_alicuota) VALUES (30, 3);
INSERT INTO Beneficios_fiscales (ID_beneficio, Segmento_alicuota) VALUES (31, 3);
INSERT INTO Beneficios_fiscales (ID_beneficio, Segmento_alicuota) VALUES (32, 3);
INSERT INTO Beneficios_fiscales (ID_beneficio, Segmento_alicuota) VALUES (33, 3);
INSERT INTO Beneficios_fiscales (ID_beneficio, Segmento_alicuota) VALUES (34, 3);
INSERT INTO Beneficios_fiscales (ID_beneficio, Segmento_alicuota) VALUES (35, 3);
INSERT INTO Beneficios_fiscales (ID_beneficio, Segmento_alicuota) VALUES (36, 3);
INSERT INTO Beneficios_fiscales (ID_beneficio, Segmento_alicuota) VALUES (37, 3);
INSERT INTO Beneficios_fiscales (ID_beneficio, Segmento_alicuota) VALUES (38, 3);
INSERT INTO Beneficios_fiscales (ID_beneficio, Segmento_alicuota) VALUES (39, 3);
INSERT INTO Beneficios_fiscales (ID_beneficio, Segmento_alicuota) VALUES (40, 3);
INSERT INTO Beneficios_fiscales (ID_beneficio, Segmento_alicuota) VALUES (41, 3);
INSERT INTO Beneficios_fiscales (ID_beneficio, Segmento_alicuota) VALUES (42, 3);
INSERT INTO Beneficios_fiscales (ID_beneficio, Segmento_alicuota) VALUES (43, 3);
INSERT INTO Beneficios_fiscales (ID_beneficio, Segmento_alicuota) VALUES (44, 3);
INSERT INTO Beneficios_fiscales (ID_beneficio, Segmento_alicuota) VALUES (45, 3);
INSERT INTO Beneficios_fiscales (ID_beneficio, Segmento_alicuota) VALUES (46, 3);
INSERT INTO Beneficios_fiscales (ID_beneficio, Segmento_alicuota) VALUES (47, 3);
INSERT INTO Beneficios_fiscales (ID_beneficio, Segmento_alicuota) VALUES (48, 3);
INSERT INTO Beneficios_fiscales (ID_beneficio, Segmento_alicuota) VALUES (49, 3);
INSERT INTO Beneficios_fiscales (ID_beneficio, Segmento_alicuota) VALUES (50, 3);
INSERT INTO Beneficios_fiscales (ID_beneficio, Segmento_alicuota) VALUES (51, 3);
INSERT INTO Beneficios_fiscales (ID_beneficio, Segmento_alicuota) VALUES (52, 3);
INSERT INTO Beneficios_fiscales (ID_beneficio, Segmento_alicuota) VALUES (53, 3);
INSERT INTO Beneficios_fiscales (ID_beneficio, Segmento_alicuota) VALUES (54, 3);
INSERT INTO Beneficios_fiscales (ID_beneficio, Segmento_alicuota) VALUES (55, 3);
INSERT INTO Beneficios_fiscales (ID_beneficio, Segmento_alicuota) VALUES (56, 3);
INSERT INTO Beneficios_fiscales (ID_beneficio, Segmento_alicuota) VALUES (57, 1);
INSERT INTO Beneficios_fiscales (ID_beneficio, Segmento_alicuota) VALUES (58, 3);
INSERT INTO Beneficios_fiscales (ID_beneficio, Segmento_alicuota) VALUES (59, 1);
INSERT INTO Beneficios_fiscales (ID_beneficio, Segmento_alicuota) VALUES (60, 1);
INSERT INTO Beneficios_fiscales (ID_beneficio, Segmento_alicuota) VALUES (61, 3);
INSERT INTO Beneficios_fiscales (ID_beneficio, Segmento_alicuota) VALUES (62, 3);
INSERT INTO Beneficios_fiscales (ID_beneficio, Segmento_alicuota) VALUES (63, 3);
INSERT INTO Beneficios_fiscales (ID_beneficio, Segmento_alicuota) VALUES (64, 3);
INSERT INTO Beneficios_fiscales (ID_beneficio, Segmento_alicuota) VALUES (65, 3);
INSERT INTO Beneficios_fiscales (ID_beneficio, Segmento_alicuota) VALUES (66, 3);
INSERT INTO Beneficios_fiscales (ID_beneficio, Segmento_alicuota) VALUES (67, 3);
INSERT INTO Beneficios_fiscales (ID_beneficio, Segmento_alicuota) VALUES (68, 3);
INSERT INTO Beneficios_fiscales (ID_beneficio, Segmento_alicuota) VALUES (69, 3);
INSERT INTO Beneficios_fiscales (ID_beneficio, Segmento_alicuota) VALUES (70, 3);
INSERT INTO Beneficios_fiscales (ID_beneficio, Segmento_alicuota) VALUES (71, 3);
INSERT INTO Beneficios_fiscales (ID_beneficio, Segmento_alicuota) VALUES (72, 3);
INSERT INTO Beneficios_fiscales (ID_beneficio, Segmento_alicuota) VALUES (73, 3);


CREATE TABLE Valores_alicuota (
    categoria_impuesto INT PRIMARY KEY,
    alicuota DECIMAL(5,3)
)

INSERT INTO Valores_alicuota (categoria_impuesto, alicuota) VALUES (0, 0.6);
INSERT INTO Valores_alicuota (categoria_impuesto, alicuota) VALUES (1, 0.25);
INSERT INTO Valores_alicuota (categoria_impuesto, alicuota) VALUES (2, 0.075);
INSERT INTO Valores_alicuota (categoria_impuesto, alicuota) VALUES (3, 0);
');
