execute('
IF OBJECT_ID (''dbo.SIBE_CALIFICACION_CAB'') IS NOT NULL
	DROP TABLE dbo.SIBE_CALIFICACION_CAB
');
execute('
CREATE TABLE dbo.SIBE_CALIFICACION_CAB
	(
	Cuit     NUMERIC (12) NOT NULL,
	FecVig   NUMERIC (8) NOT NULL,
	FecVenc  NUMERIC (8),
	RiesgCP  NUMERIC (15, 2),
	RiesgLP  NUMERIC (15, 2),
	CalifCP  NUMERIC (15, 2),
	CalifLP  NUMERIC (15, 2),
	MaEx     NUMERIC (15, 2),
	Sucursal NUMERIC (5),
	CtaCli   NUMERIC (9),
	UsuAlta  VARCHAR (10),
	FecAlta  NUMERIC (8),
	PRIMARY KEY (Cuit, FecVig)
	)
');
execute('
INSERT INTO dbo.SIBE_CALIFICACION_CAB (Cuit, FecVig, FecVenc, RiesgCP, RiesgLP, CalifCP, CalifLP, MaEx, Sucursal, CtaCli, UsuAlta, FecAlta)
VALUES (20299081827, 20230822, 0, 1000, 2000, 3.5, 4, 7000, 11, 22, ''Usuario1'', 20230821)

INSERT INTO dbo.SIBE_CALIFICACION_CAB (Cuit, FecVig, FecVenc, RiesgCP, RiesgLP, CalifCP, CalifLP, MaEx, Sucursal, CtaCli, UsuAlta, FecAlta)
VALUES (27306299412, 20230821, 0, 1000, 2000, 3.5, 4, 5000, 11, 22, ''Usuario1'', 20230821)');