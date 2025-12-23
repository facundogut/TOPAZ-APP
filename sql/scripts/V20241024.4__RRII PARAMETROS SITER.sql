DELETE FROM RRI_PARAMETROS_DEF WHERE CODIGO=510
INSERT INTO dbo.RRI_PARAMETROS_DEF
	(
	CODIGO
	, NOMBRE
	, ID1
	, ID1DESC
	, ID2
	, ID2DESC
	, ID3
	, ID3DESC
	, ID4
	, ID4DESC
	, ID5
	, ID5DESC
	, NUM1
	, NUM1DESC
	, NUM2
	, NUM2DESC
	, CHAR1
	, CHR1DESC
	, CHAR2
	, CHR2DESC
	, TZ_LOCK
	)
VALUES
	(
	510
	, 'Provincia SITERDOM'
	, 'N'
	, ''
	, 'N'
	, ''
	, 'N'
	, ''
	, 'S'
	, 'PROV. DIRECCIONES'
	, 'S'
	, 'Provincia'
	, 'S'
	, 'Provincia SITERDOM'
	, 'N'
	, ''
	, 'N'
	, ''
	, 'N'
	, ''
	, 0
	)
GO

DELETE FROM RRI_PARAMETROS_INF WHERE CODIGO=510

INSERT INTO dbo.RRI_PARAMETROS_INF
	(
	CODIGO
	, ID1
	, ID2
	, ID3
	, ID4
	, ID5
	, NUM1
	, NUM2
	, CHAR1
	, CHAR2
	, TZ_LOCK
	)
VALUES
	(
	510
	, 0
	, 0
	, 0
	, 'A'
	, 'SALTA'
	, 9
	, 0
	, ' '
	, ' '
	, 0
	)
GO

INSERT INTO dbo.RRI_PARAMETROS_INF
	(
	CODIGO
	, ID1
	, ID2
	, ID3
	, ID4
	, ID5
	, NUM1
	, NUM2
	, CHAR1
	, CHAR2
	, TZ_LOCK
	)
VALUES
	(
	510
	, 0
	, 0
	, 0
	, 'B'
	, 'Buenos Aires'
	, 1
	, 0
	, ' '
	, ' '
	, 0
	)
GO

INSERT INTO dbo.RRI_PARAMETROS_INF
	(
	CODIGO
	, ID1
	, ID2
	, ID3
	, ID4
	, ID5
	, NUM1
	, NUM2
	, CHAR1
	, CHAR2
	, TZ_LOCK
	)
VALUES
	(
	510
	, 0
	, 0
	, 0
	, 'C'
	, 'Ciudad Aut. de BS AS'
	, 0
	, 0
	, ' '
	, ' '
	, 0
	)
GO

INSERT INTO dbo.RRI_PARAMETROS_INF
	(
	CODIGO
	, ID1
	, ID2
	, ID3
	, ID4
	, ID5
	, NUM1
	, NUM2
	, CHAR1
	, CHAR2
	, TZ_LOCK
	)
VALUES
	(
	510
	, 0
	, 0
	, 0
	, 'D'
	, 'San Luis'
	, 11
	, 0
	, ' '
	, ' '
	, 0
	)
GO

INSERT INTO dbo.RRI_PARAMETROS_INF
	(
	CODIGO
	, ID1
	, ID2
	, ID3
	, ID4
	, ID5
	, NUM1
	, NUM2
	, CHAR1
	, CHAR2
	, TZ_LOCK
	)
VALUES
	(
	510
	, 0
	, 0
	, 0
	, 'E'
	, 'Entre Rios'
	, 5
	, 0
	, ' '
	, ' '
	, 0
	)
GO

INSERT INTO dbo.RRI_PARAMETROS_INF
	(
	CODIGO
	, ID1
	, ID2
	, ID3
	, ID4
	, ID5
	, NUM1
	, NUM2
	, CHAR1
	, CHAR2
	, TZ_LOCK
	)
VALUES
	(
	510
	, 0
	, 0
	, 0
	, 'F'
	, 'La Rioja'
	, 8
	, 0
	, ' '
	, ' '
	, 0
	)
GO

INSERT INTO dbo.RRI_PARAMETROS_INF
	(
	CODIGO
	, ID1
	, ID2
	, ID3
	, ID4
	, ID5
	, NUM1
	, NUM2
	, CHAR1
	, CHAR2
	, TZ_LOCK
	)
VALUES
	(
	510
	, 0
	, 0
	, 0
	, 'G'
	, 'Santiago del Estero'
	, 13
	, 0
	, ' '
	, ' '
	, 0
	)
GO

INSERT INTO dbo.RRI_PARAMETROS_INF
	(
	CODIGO
	, ID1
	, ID2
	, ID3
	, ID4
	, ID5
	, NUM1
	, NUM2
	, CHAR1
	, CHAR2
	, TZ_LOCK
	)
VALUES
	(
	510
	, 0
	, 0
	, 0
	, 'H'
	, 'Chaco'
	, 16
	, 0
	, ' '
	, ' '
	, 0
	)
GO

INSERT INTO dbo.RRI_PARAMETROS_INF
	(
	CODIGO
	, ID1
	, ID2
	, ID3
	, ID4
	, ID5
	, NUM1
	, NUM2
	, CHAR1
	, CHAR2
	, TZ_LOCK
	)
VALUES
	(
	510
	, 0
	, 0
	, 0
	, 'J'
	, 'San Juan'
	, 10
	, 0
	, ' '
	, ' '
	, 0
	)
GO

INSERT INTO dbo.RRI_PARAMETROS_INF
	(
	CODIGO
	, ID1
	, ID2
	, ID3
	, ID4
	, ID5
	, NUM1
	, NUM2
	, CHAR1
	, CHAR2
	, TZ_LOCK
	)
VALUES
	(
	510
	, 0
	, 0
	, 0
	, 'K'
	, 'Catamarca'
	, 2
	, 0
	, ' '
	, ' '
	, 0
	)
GO

INSERT INTO dbo.RRI_PARAMETROS_INF
	(
	CODIGO
	, ID1
	, ID2
	, ID3
	, ID4
	, ID5
	, NUM1
	, NUM2
	, CHAR1
	, CHAR2
	, TZ_LOCK
	)
VALUES
	(
	510
	, 0
	, 0
	, 0
	, 'L'
	, 'La Pampa'
	, 21
	, 0
	, ' '
	, ' '
	, 0
	)
GO

INSERT INTO dbo.RRI_PARAMETROS_INF
	(
	CODIGO
	, ID1
	, ID2
	, ID3
	, ID4
	, ID5
	, NUM1
	, NUM2
	, CHAR1
	, CHAR2
	, TZ_LOCK
	)
VALUES
	(
	510
	, 0
	, 0
	, 0
	, 'M'
	, 'Mendoza'
	, 7
	, 0
	, ' '
	, ' '
	, 0
	)
GO

INSERT INTO dbo.RRI_PARAMETROS_INF
	(
	CODIGO
	, ID1
	, ID2
	, ID3
	, ID4
	, ID5
	, NUM1
	, NUM2
	, CHAR1
	, CHAR2
	, TZ_LOCK
	)
VALUES
	(
	510
	, 0
	, 0
	, 0
	, 'N'
	, 'Misiones'
	, 19
	, 0
	, ' '
	, ' '
	, 0
	)
GO

INSERT INTO dbo.RRI_PARAMETROS_INF
	(
	CODIGO
	, ID1
	, ID2
	, ID3
	, ID4
	, ID5
	, NUM1
	, NUM2
	, CHAR1
	, CHAR2
	, TZ_LOCK
	)
VALUES
	(
	510
	, 0
	, 0
	, 0
	, 'P'
	, 'Formosa'
	, 18
	, 0
	, ' '
	, ' '
	, 0
	)
GO

INSERT INTO dbo.RRI_PARAMETROS_INF
	(
	CODIGO
	, ID1
	, ID2
	, ID3
	, ID4
	, ID5
	, NUM1
	, NUM2
	, CHAR1
	, CHAR2
	, TZ_LOCK
	)
VALUES
	(
	510
	, 0
	, 0
	, 0
	, 'Q'
	, 'Neuquen'
	, 20
	, 0
	, ' '
	, ' '
	, 0
	)
GO

INSERT INTO dbo.RRI_PARAMETROS_INF
	(
	CODIGO
	, ID1
	, ID2
	, ID3
	, ID4
	, ID5
	, NUM1
	, NUM2
	, CHAR1
	, CHAR2
	, TZ_LOCK
	)
VALUES
	(
	510
	, 0
	, 0
	, 0
	, 'R'
	, 'Rio Negro'
	, 22
	, 0
	, ' '
	, ' '
	, 0
	)
GO

INSERT INTO dbo.RRI_PARAMETROS_INF
	(
	CODIGO
	, ID1
	, ID2
	, ID3
	, ID4
	, ID5
	, NUM1
	, NUM2
	, CHAR1
	, CHAR2
	, TZ_LOCK
	)
VALUES
	(
	510
	, 0
	, 0
	, 0
	, 'S'
	, 'Santa Fe'
	, 12
	, 0
	, ' '
	, ' '
	, 0
	)
GO

INSERT INTO dbo.RRI_PARAMETROS_INF
	(
	CODIGO
	, ID1
	, ID2
	, ID3
	, ID4
	, ID5
	, NUM1
	, NUM2
	, CHAR1
	, CHAR2
	, TZ_LOCK
	)
VALUES
	(
	510
	, 0
	, 0
	, 0
	, 'T'
	, 'Tucuman'
	, 14
	, 0
	, ' '
	, ' '
	, 0
	)
GO

INSERT INTO dbo.RRI_PARAMETROS_INF
	(
	CODIGO
	, ID1
	, ID2
	, ID3
	, ID4
	, ID5
	, NUM1
	, NUM2
	, CHAR1
	, CHAR2
	, TZ_LOCK
	)
VALUES
	(
	510
	, 0
	, 0
	, 0
	, 'U'
	, 'Chubut'
	, 17
	, 0
	, ' '
	, ' '
	, 0
	)
GO

INSERT INTO dbo.RRI_PARAMETROS_INF
	(
	CODIGO
	, ID1
	, ID2
	, ID3
	, ID4
	, ID5
	, NUM1
	, NUM2
	, CHAR1
	, CHAR2
	, TZ_LOCK
	)
VALUES
	(
	510
	, 0
	, 0
	, 0
	, 'V'
	, 'Tierra del Fuego'
	, 24
	, 0
	, ' '
	, ' '
	, 0
	)
GO

INSERT INTO dbo.RRI_PARAMETROS_INF
	(
	CODIGO
	, ID1
	, ID2
	, ID3
	, ID4
	, ID5
	, NUM1
	, NUM2
	, CHAR1
	, CHAR2
	, TZ_LOCK
	)
VALUES
	(
	510
	, 0
	, 0
	, 0
	, 'W'
	, 'Corrientes'
	, 4
	, 0
	, ' '
	, ' '
	, 0
	)
GO

INSERT INTO dbo.RRI_PARAMETROS_INF
	(
	CODIGO
	, ID1
	, ID2
	, ID3
	, ID4
	, ID5
	, NUM1
	, NUM2
	, CHAR1
	, CHAR2
	, TZ_LOCK
	)
VALUES
	(
	510
	, 0
	, 0
	, 0
	, 'X'
	, 'Cordoba'
	, 3
	, 0
	, ' '
	, ' '
	, 0
	)
GO

INSERT INTO dbo.RRI_PARAMETROS_INF
	(
	CODIGO
	, ID1
	, ID2
	, ID3
	, ID4
	, ID5
	, NUM1
	, NUM2
	, CHAR1
	, CHAR2
	, TZ_LOCK
	)
VALUES
	(
	510
	, 0
	, 0
	, 0
	, 'Y'
	, 'Jujuy'
	, 6
	, 0
	, ' '
	, ' '
	, 0
	)
GO

INSERT INTO dbo.RRI_PARAMETROS_INF
	(
	CODIGO
	, ID1
	, ID2
	, ID3
	, ID4
	, ID5
	, NUM1
	, NUM2
	, CHAR1
	, CHAR2
	, TZ_LOCK
	)
VALUES
	(
	510
	, 0
	, 0
	, 0
	, 'Z'
	, 'Santa Cruz'
	, 23
	, 0
	, ' '
	, ' '
	, 0
	)
GO

INSERT INTO dbo.RRI_PARAMETROS_INF
	(
	CODIGO
	, ID1
	, ID2
	, ID3
	, ID4
	, ID5
	, NUM1
	, NUM2
	, CHAR1
	, CHAR2
	, TZ_LOCK
	)
VALUES
	(
	510
	, 1
	, 0
	, 0
	, ' '
	, ' '
	, 0
	, 0
	, ' '
	, ' '
	, 313106777000003
	)
GO


DELETE FROM RRI_PARAMETROS_DEF WHERE CODIGO = 512
INSERT INTO dbo.RRI_PARAMETROS_DEF
	(
	CODIGO
	, NOMBRE
	, ID1
	, ID1DESC
	, ID2
	, ID2DESC
	, ID3
	, ID3DESC
	, ID4
	, ID4DESC
	, ID5
	, ID5DESC
	, NUM1
	, NUM1DESC
	, NUM2
	, NUM2DESC
	, CHAR1
	, CHR1DESC
	, CHAR2
	, CHR2DESC
	, TZ_LOCK
	)
VALUES
	(
	512
	, 'Tipo Cuenta SITEROP'
	, 'S'
	, 'Codigo Topaz'
	, 'S'
	, 'Producto topaz 2,3'
	, 'N'
	, ''
	, 'S'
	, 'Descripcion'
	, 'N'
	, ''
	, 'S'
	, 'Codigo BCRA'
	, 'S'
	, 'Codigo SITER'
	, 'N'
	, ''
	, 'N'
	, ''
	, 0
	)
GO



DELETE FROM  rri_parametros_inf WHERE CODIGO = 512

INSERT INTO dbo.RRI_PARAMETROS_INF
	(
	CODIGO
	, ID1
	, ID2
	, ID3
	, ID4
	, ID5
	, NUM1
	, NUM2
	, CHAR1
	, CHAR2
	, TZ_LOCK
	)
VALUES
	(
	512
	, 1
	, 3
	, 0
	, 'AC Comun'
	, ' '
	, 1
	, 1
	, ' '
	, ' '
	, 0
	)
GO

INSERT INTO dbo.RRI_PARAMETROS_INF
	(
	CODIGO
	, ID1
	, ID2
	, ID3
	, ID4
	, ID5
	, NUM1
	, NUM2
	, CHAR1
	, CHAR2
	, TZ_LOCK
	)
VALUES
	(
	512
	, 2
	, 3
	, 0
	, 'AC Simplificada'
	, ' '
	, 1
	, 1
	, ' '
	, ' '
	, 0
	)
GO

INSERT INTO dbo.RRI_PARAMETROS_INF
	(
	CODIGO
	, ID1
	, ID2
	, ID3
	, ID4
	, ID5
	, NUM1
	, NUM2
	, CHAR1
	, CHAR2
	, TZ_LOCK
	)
VALUES
	(
	512
	, 3
	, 3
	, 0
	, 'Cuenta Sueldo'
	, ' '
	, 2
	, 2
	, ' '
	, ' '
	, 0
	)
GO

INSERT INTO dbo.RRI_PARAMETROS_INF
	(
	CODIGO
	, ID1
	, ID2
	, ID3
	, ID4
	, ID5
	, NUM1
	, NUM2
	, CHAR1
	, CHAR2
	, TZ_LOCK
	)
VALUES
	(
	512
	, 4
	, 3
	, 0
	, 'Seg. Soc. Nac. Anses'
	, ' '
	, 3
	, 2
	, ' '
	, ' '
	, 0
	)
GO

INSERT INTO dbo.RRI_PARAMETROS_INF
	(
	CODIGO
	, ID1
	, ID2
	, ID3
	, ID4
	, ID5
	, NUM1
	, NUM2
	, CHAR1
	, CHAR2
	, TZ_LOCK
	)
VALUES
	(
	512
	, 5
	, 3
	, 0
	, 'CC Especial p/PJ'
	, ' '
	, 4
	, 6
	, ' '
	, ' '
	, 0
	)
GO

INSERT INTO dbo.RRI_PARAMETROS_INF
	(
	CODIGO
	, ID1
	, ID2
	, ID3
	, ID4
	, ID5
	, NUM1
	, NUM2
	, CHAR1
	, CHAR2
	, TZ_LOCK
	)
VALUES
	(
	512
	, 6
	, 3
	, 0
	, 'Plan y Ay Soc. ANSES'
	, ' '
	, 3
	, 10
	, ' '
	, ' '
	, 0
	)
GO

INSERT INTO dbo.RRI_PARAMETROS_INF
	(
	CODIGO
	, ID1
	, ID2
	, ID3
	, ID4
	, ID5
	, NUM1
	, NUM2
	, CHAR1
	, CHAR2
	, TZ_LOCK
	)
VALUES
	(
	512
	, 7
	, 3
	, 0
	, 'AC Menores Auto.'
	, ' '
	, 12
	, 19
	, ' '
	, ' '
	, 0
	)
GO

INSERT INTO dbo.RRI_PARAMETROS_INF
	(
	CODIGO
	, ID1
	, ID2
	, ID3
	, ID4
	, ID5
	, NUM1
	, NUM2
	, CHAR1
	, CHAR2
	, TZ_LOCK
	)
VALUES
	(
	512
	, 9
	, 3
	, 0
	, 'Dep. Jud. Ejecutivas'
	, ' '
	, 1
	, 11
	, ' '
	, ' '
	, 0
	)
GO

INSERT INTO dbo.RRI_PARAMETROS_INF
	(
	CODIGO
	, ID1
	, ID2
	, ID3
	, ID4
	, ID5
	, NUM1
	, NUM2
	, CHAR1
	, CHAR2
	, TZ_LOCK
	)
VALUES
	(
	512
	, 10
	, 3
	, 0
	, 'Dep. Jud. Lit y Alim'
	, ' '
	, 5
	, 11
	, ' '
	, ' '
	, 0
	)
GO

INSERT INTO dbo.RRI_PARAMETROS_INF
	(
	CODIGO
	, ID1
	, ID2
	, ID3
	, ID4
	, ID5
	, NUM1
	, NUM2
	, CHAR1
	, CHAR2
	, TZ_LOCK
	)
VALUES
	(
	512
	, 12
	, 3
	, 0
	, 'Fondo Cese Laboral'
	, ' '
	, 6
	, 3
	, ' '
	, ' '
	, 0
	)
GO

INSERT INTO dbo.RRI_PARAMETROS_INF
	(
	CODIGO
	, ID1
	, ID2
	, ID3
	, ID4
	, ID5
	, NUM1
	, NUM2
	, CHAR1
	, CHAR2
	, TZ_LOCK
	)
VALUES
	(
	512
	, 16
	, 3
	, 0
	, 'Pla y Ay Soc Provin'
	, ' '
	, 3
	, 10
	, ' '
	, ' '
	, 0
	)
GO

INSERT INTO dbo.RRI_PARAMETROS_INF
	(
	CODIGO
	, ID1
	, ID2
	, ID3
	, ID4
	, ID5
	, NUM1
	, NUM2
	, CHAR1
	, CHAR2
	, TZ_LOCK
	)
VALUES
	(
	512
	, 17
	, 3
	, 0
	, 'AC Red Pago sen Jud'
	, ' '
	, 1
	, 11
	, ' '
	, ' '
	, 0
	)
GO

INSERT INTO dbo.RRI_PARAMETROS_INF
	(
	CODIGO
	, ID1
	, ID2
	, ID3
	, ID4
	, ID5
	, NUM1
	, NUM2
	, CHAR1
	, CHAR2
	, TZ_LOCK
	)
VALUES
	(
	512
	, 18
	, 3
	, 0
	, 'AC UVA Menores'
	, ' '
	, 14
	, 20
	, ' '
	, ' '
	, 0
	)
GO

INSERT INTO dbo.RRI_PARAMETROS_INF
	(
	CODIGO
	, ID1
	, ID2
	, ID3
	, ID4
	, ID5
	, NUM1
	, NUM2
	, CHAR1
	, CHAR2
	, TZ_LOCK
	)
VALUES
	(
	512
	, 19
	, 3
	, 0
	, 'AC UVA Alcancia'
	, ' '
	, 14
	, 20
	, ' '
	, ' '
	, 0
	)
GO

INSERT INTO dbo.RRI_PARAMETROS_INF
	(
	CODIGO
	, ID1
	, ID2
	, ID3
	, ID4
	, ID5
	, NUM1
	, NUM2
	, CHAR1
	, CHAR2
	, TZ_LOCK
	)
VALUES
	(
	512
	, 51
	, 2
	, 0
	, 'CC Comun'
	, ' '
	, 101
	, 14
	, ' '
	, ' '
	, 0
	)
GO

INSERT INTO dbo.RRI_PARAMETROS_INF
	(
	CODIGO
	, ID1
	, ID2
	, ID3
	, ID4
	, ID5
	, NUM1
	, NUM2
	, CHAR1
	, CHAR2
	, TZ_LOCK
	)
VALUES
	(
	512
	, 52
	, 2
	, 0
	, 'CC Monotributistas'
	, ' '
	, 101
	, 14
	, ' '
	, ' '
	, 0
	)
GO



DELETE FROM  rri_parametros_DEF WHERE CODIGO = 513

INSERT INTO dbo.RRI_PARAMETROS_DEF
	(
	CODIGO
	, NOMBRE
	, ID1
	, ID1DESC
	, ID2
	, ID2DESC
	, ID3
	, ID3DESC
	, ID4
	, ID4DESC
	, ID5
	, ID5DESC
	, NUM1
	, NUM1DESC
	, NUM2
	, NUM2DESC
	, CHAR1
	, CHR1DESC
	, CHAR2
	, CHR2DESC
	, TZ_LOCK
	)
VALUES
	(
	513
	, 'Caracter SITEROP'
	, 'N'
	, ''
	, 'N'
	, ''
	, 'N'
	, ''
	, 'S'
	, 'Tipo Cargo TOPAZ'
	, 'N'
	, ''
	, 'S'
	, 'Codigo SITER'
	, 'N'
	, ''
	, 'N'
	, ''
	, 'N'
	, ''
	, 0
	)
GO



DELETE FROM  rri_parametros_inf WHERE CODIGO = 513

INSERT INTO dbo.RRI_PARAMETROS_INF
	(
	CODIGO
	, ID1
	, ID2
	, ID3
	, ID4
	, ID5
	, NUM1
	, NUM2
	, CHAR1
	, CHAR2
	, TZ_LOCK
	)
VALUES
	(
	513
	, 0
	, 0
	, 0
	, 'ADM'
	, ' '
	, 8
	, 0
	, ' '
	, ' '
	, 0
	)
GO

INSERT INTO dbo.RRI_PARAMETROS_INF
	(
	CODIGO
	, ID1
	, ID2
	, ID3
	, ID4
	, ID5
	, NUM1
	, NUM2
	, CHAR1
	, CHAR2
	, TZ_LOCK
	)
VALUES
	(
	513
	, 0
	, 0
	, 0
	, 'APO'
	, ' '
	, 3
	, 0
	, ' '
	, ' '
	, 0
	)
GO

INSERT INTO dbo.RRI_PARAMETROS_INF
	(
	CODIGO
	, ID1
	, ID2
	, ID3
	, ID4
	, ID5
	, NUM1
	, NUM2
	, CHAR1
	, CHAR2
	, TZ_LOCK
	)
VALUES
	(
	513
	, 0
	, 0
	, 0
	, 'FCO'
	, ' '
	, 7
	, 0
	, ' '
	, ' '
	, 0
	)
GO

INSERT INTO dbo.RRI_PARAMETROS_INF
	(
	CODIGO
	, ID1
	, ID2
	, ID3
	, ID4
	, ID5
	, NUM1
	, NUM2
	, CHAR1
	, CHAR2
	, TZ_LOCK
	)
VALUES
	(
	513
	, 0
	, 0
	, 0
	, 'REP'
	, ' '
	, 4
	, 0
	, ' '
	, ' '
	, 0
	)
GO

INSERT INTO dbo.RRI_PARAMETROS_INF
	(
	CODIGO
	, ID1
	, ID2
	, ID3
	, ID4
	, ID5
	, NUM1
	, NUM2
	, CHAR1
	, CHAR2
	, TZ_LOCK
	)
VALUES
	(
	513
	, 0
	, 0
	, 0
	, 'SDE'
	, ' '
	, 6
	, 0
	, ' '
	, ' '
	, 0
	)
GO


DELETE FROM RRI_PARAMETROS_DEF WHERE CODIGO = 514

INSERT INTO dbo.RRI_PARAMETROS_DEF
	(
	CODIGO
	, NOMBRE
	, ID1
	, ID1DESC
	, ID2
	, ID2DESC
	, ID3
	, ID3DESC
	, ID4
	, ID4DESC
	, ID5
	, ID5DESC
	, NUM1
	, NUM1DESC
	, NUM2
	, NUM2DESC
	, CHAR1
	, CHR1DESC
	, CHAR2
	, CHR2DESC
	, TZ_LOCK
	)
VALUES
	(
	514
	, 'Tipo Op DPF SITEROP'
	, 'S'
	, 'Codigo Prod. Topaz'
	, 'S'
	, 'Transferible/Intrans'
	, 'N'
	, ''
	, 'N'
	, ''
	, 'N'
	, ''
	, 'S'
	, 'Codigo SITEROP'
	, 'N'
	, ''
	, 'N'
	, ''
	, 'N'
	, ''
	, 0
	)
GO


DELETE FROM rri_parametros_inf WHERE CODIGO = 514

INSERT INTO dbo.RRI_PARAMETROS_INF
	(
	CODIGO
	, ID1
	, ID2
	, ID3
	, ID4
	, ID5
	, NUM1
	, NUM2
	, CHAR1
	, CHAR2
	, TZ_LOCK
	)
VALUES
	(
	514
	, 101
	, 0
	, 0
	, ' '
	, ' '
	, 1
	, 0
	, ' '
	, ' '
	, 317787777000023
	)
GO

INSERT INTO dbo.RRI_PARAMETROS_INF
	(
	CODIGO
	, ID1
	, ID2
	, ID3
	, ID4
	, ID5
	, NUM1
	, NUM2
	, CHAR1
	, CHAR2
	, TZ_LOCK
	)
VALUES
	(
	514
	, 101
	, 1
	, 0
	, ' '
	, ' '
	, 1
	, 0
	, ' '
	, ' '
	, 0
	)
GO

INSERT INTO dbo.RRI_PARAMETROS_INF
	(
	CODIGO
	, ID1
	, ID2
	, ID3
	, ID4
	, ID5
	, NUM1
	, NUM2
	, CHAR1
	, CHAR2
	, TZ_LOCK
	)
VALUES
	(
	514
	, 101
	, 2
	, 0
	, ' '
	, ' '
	, 2
	, 0
	, ' '
	, ' '
	, 0
	)
GO

INSERT INTO dbo.RRI_PARAMETROS_INF
	(
	CODIGO
	, ID1
	, ID2
	, ID3
	, ID4
	, ID5
	, NUM1
	, NUM2
	, CHAR1
	, CHAR2
	, TZ_LOCK
	)
VALUES
	(
	514
	, 102
	, 1
	, 0
	, ' '
	, ' '
	, 1
	, 0
	, ' '
	, ' '
	, 0
	)
GO

INSERT INTO dbo.RRI_PARAMETROS_INF
	(
	CODIGO
	, ID1
	, ID2
	, ID3
	, ID4
	, ID5
	, NUM1
	, NUM2
	, CHAR1
	, CHAR2
	, TZ_LOCK
	)
VALUES
	(
	514
	, 102
	, 2
	, 0
	, ' '
	, ' '
	, 2
	, 0
	, ' '
	, ' '
	, 0
	)
GO

INSERT INTO dbo.RRI_PARAMETROS_INF
	(
	CODIGO
	, ID1
	, ID2
	, ID3
	, ID4
	, ID5
	, NUM1
	, NUM2
	, CHAR1
	, CHAR2
	, TZ_LOCK
	)
VALUES
	(
	514
	, 103
	, 1
	, 0
	, ' '
	, ' '
	, 3
	, 0
	, ' '
	, ' '
	, 0
	)
GO

INSERT INTO dbo.RRI_PARAMETROS_INF
	(
	CODIGO
	, ID1
	, ID2
	, ID3
	, ID4
	, ID5
	, NUM1
	, NUM2
	, CHAR1
	, CHAR2
	, TZ_LOCK
	)
VALUES
	(
	514
	, 103
	, 2
	, 0
	, ' '
	, ' '
	, 5
	, 0
	, ' '
	, ' '
	, 0
	)
GO

INSERT INTO dbo.RRI_PARAMETROS_INF
	(
	CODIGO
	, ID1
	, ID2
	, ID3
	, ID4
	, ID5
	, NUM1
	, NUM2
	, CHAR1
	, CHAR2
	, TZ_LOCK
	)
VALUES
	(
	514
	, 104
	, 1
	, 0
	, ' '
	, ' '
	, 4
	, 0
	, ' '
	, ' '
	, 0
	)
GO

INSERT INTO dbo.RRI_PARAMETROS_INF
	(
	CODIGO
	, ID1
	, ID2
	, ID3
	, ID4
	, ID5
	, NUM1
	, NUM2
	, CHAR1
	, CHAR2
	, TZ_LOCK
	)
VALUES
	(
	514
	, 104
	, 2
	, 0
	, ' '
	, ' '
	, 6
	, 0
	, ' '
	, ' '
	, 0
	)
GO

INSERT INTO dbo.RRI_PARAMETROS_INF
	(
	CODIGO
	, ID1
	, ID2
	, ID3
	, ID4
	, ID5
	, NUM1
	, NUM2
	, CHAR1
	, CHAR2
	, TZ_LOCK
	)
VALUES
	(
	514
	, 105
	, 1
	, 0
	, ' '
	, ' '
	, 9
	, 0
	, ' '
	, ' '
	, 0
	)
GO

INSERT INTO dbo.RRI_PARAMETROS_INF
	(
	CODIGO
	, ID1
	, ID2
	, ID3
	, ID4
	, ID5
	, NUM1
	, NUM2
	, CHAR1
	, CHAR2
	, TZ_LOCK
	)
VALUES
	(
	514
	, 105
	, 2
	, 0
	, ' '
	, ' '
	, 7
	, 0
	, ' '
	, ' '
	, 0
	)
GO

INSERT INTO dbo.RRI_PARAMETROS_INF
	(
	CODIGO
	, ID1
	, ID2
	, ID3
	, ID4
	, ID5
	, NUM1
	, NUM2
	, CHAR1
	, CHAR2
	, TZ_LOCK
	)
VALUES
	(
	514
	, 106
	, 1
	, 0
	, ' '
	, ' '
	, 1
	, 0
	, ' '
	, ' '
	, 0
	)
GO

INSERT INTO dbo.RRI_PARAMETROS_INF
	(
	CODIGO
	, ID1
	, ID2
	, ID3
	, ID4
	, ID5
	, NUM1
	, NUM2
	, CHAR1
	, CHAR2
	, TZ_LOCK
	)
VALUES
	(
	514
	, 106
	, 2
	, 0
	, ' '
	, ' '
	, 2
	, 0
	, ' '
	, ' '
	, 0
	)
GO

INSERT INTO dbo.RRI_PARAMETROS_INF
	(
	CODIGO
	, ID1
	, ID2
	, ID3
	, ID4
	, ID5
	, NUM1
	, NUM2
	, CHAR1
	, CHAR2
	, TZ_LOCK
	)
VALUES
	(
	514
	, 107
	, 0
	, 0
	, ' '
	, ' '
	, 13
	, 0
	, ' '
	, ' '
	, 0
	)
GO

INSERT INTO dbo.RRI_PARAMETROS_INF
	(
	CODIGO
	, ID1
	, ID2
	, ID3
	, ID4
	, ID5
	, NUM1
	, NUM2
	, CHAR1
	, CHAR2
	, TZ_LOCK
	)
VALUES
	(
	514
	, 108
	, 1
	, 0
	, ' '
	, ' '
	, 19
	, 0
	, ' '
	, ' '
	, 0
	)
GO

INSERT INTO dbo.RRI_PARAMETROS_INF
	(
	CODIGO
	, ID1
	, ID2
	, ID3
	, ID4
	, ID5
	, NUM1
	, NUM2
	, CHAR1
	, CHAR2
	, TZ_LOCK
	)
VALUES
	(
	514
	, 108
	, 2
	, 0
	, ' '
	, ' '
	, 15
	, 0
	, ' '
	, ' '
	, 0
	)
GO


DELETE FROM RRI_PARAMETROS_DEF WHERE CODIGO = 517
INSERT INTO dbo.RRI_PARAMETROS_DEF
	(
	CODIGO
	, NOMBRE
	, ID1
	, ID1DESC
	, ID2
	, ID2DESC
	, ID3
	, ID3DESC
	, ID4
	, ID4DESC
	, ID5
	, ID5DESC
	, NUM1
	, NUM1DESC
	, NUM2
	, NUM2DESC
	, CHAR1
	, CHR1DESC
	, CHAR2
	, CHR2DESC
	, TZ_LOCK
	)
VALUES
	(
	517
	, 'Operacion SITEROP MC'
	, 'S'
	, 'ID ope mov. cont.'
	, 'N'
	, ' '
	, 'N'
	, ' '
	, 'N'
	, ' '
	, 'N'
	, ' '
	, 'N'
	, ' '
	, 'N'
	, ' '
	, 'N'
	, ' '
	, 'N'
	, ' '
	, 0
	)
GO

DELETE FROM RRI_PARAMETROS_INF WHERE CODIGO = 517
INSERT INTO dbo.RRI_PARAMETROS_INF
	(
	CODIGO
	, ID1
	, ID2
	, ID3
	, ID4
	, ID5
	, NUM1
	, NUM2
	, CHAR1
	, CHAR2
	, TZ_LOCK
	)
VALUES
	(
	517
	, 3052
	, 0
	, 0
	, '0'
	, '0'
	, 0
	, 0
	, ' '
	, ' '
	, 0
	)
GO

DELETE FROM RRI_PARAMETROS_DEF WHERE CODIGO IN (515)

INSERT INTO dbo.RRI_PARAMETROS_DEF
	(
	CODIGO
	, NOMBRE
	, ID1
	, ID1DESC
	, ID2
	, ID2DESC
	, ID3
	, ID3DESC
	, ID4
	, ID4DESC
	, ID5
	, ID5DESC
	, NUM1
	, NUM1DESC
	, NUM2
	, NUM2DESC
	, CHAR1
	, CHR1DESC
	, CHAR2
	, CHR2DESC
	, TZ_LOCK
	)
VALUES
	(
	515
	, 'Pais SITEREX'
	, 'N'
	, ' '
	, 'N'
	, ' '
	, 'N'
	, ' '
	, 'S'
	, 'Codigo TOPAZ'
	, 'N'
	, ' '
	, 'S'
	, 'Valor a informar'
	, 'N'
	, ' '
	, 'N'
	, ' '
	, 'N'
	, ' '
	, 0
	)
GO


DELETE FROM RRI_PARAMETROS_INF WHERE CODIGO = 515

INSERT INTO dbo.RRI_PARAMETROS_INF
	(
	CODIGO
	, ID1
	, ID2
	, ID3
	, ID4
	, ID5
	, NUM1
	, NUM2
	, CHAR1
	, CHAR2
	, TZ_LOCK
	)
VALUES
	(
	515
	, 0
	, 0
	, 0
	, 'AR'
	, ' '
	, 200
	, 0
	, ' '
	, ' '
	, 0
	)
GO

INSERT INTO dbo.RRI_PARAMETROS_INF
	(
	CODIGO
	, ID1
	, ID2
	, ID3
	, ID4
	, ID5
	, NUM1
	, NUM2
	, CHAR1
	, CHAR2
	, TZ_LOCK
	)
VALUES
	(
	515
	, 0
	, 0
	, 0
	, 'BR'
	, ' '
	, 203
	, 0
	, ' '
	, ' '
	, 0
	)
GO

INSERT INTO dbo.RRI_PARAMETROS_INF
	(
	CODIGO
	, ID1
	, ID2
	, ID3
	, ID4
	, ID5
	, NUM1
	, NUM2
	, CHAR1
	, CHAR2
	, TZ_LOCK
	)
VALUES
	(
	515
	, 0
	, 0
	, 0
	, 'CL'
	, ' '
	, 208
	, 0
	, ' '
	, ' '
	, 0
	)
GO

INSERT INTO dbo.RRI_PARAMETROS_INF
	(
	CODIGO
	, ID1
	, ID2
	, ID3
	, ID4
	, ID5
	, NUM1
	, NUM2
	, CHAR1
	, CHAR2
	, TZ_LOCK
	)
VALUES
	(
	515
	, 0
	, 0
	, 0
	, 'ERA'
	, ' '
	, 666
	, 0
	, ' '
	, ' '
	, 317656777000002
	)
GO

INSERT INTO dbo.RRI_PARAMETROS_INF
	(
	CODIGO
	, ID1
	, ID2
	, ID3
	, ID4
	, ID5
	, NUM1
	, NUM2
	, CHAR1
	, CHAR2
	, TZ_LOCK
	)
VALUES
	(
	515
	, 0
	, 0
	, 0
	, 'ES'
	, ' '
	, 410
	, 0
	, ' '
	, ' '
	, 0
	)
GO

INSERT INTO dbo.RRI_PARAMETROS_INF
	(
	CODIGO
	, ID1
	, ID2
	, ID3
	, ID4
	, ID5
	, NUM1
	, NUM2
	, CHAR1
	, CHAR2
	, TZ_LOCK
	)
VALUES
	(
	515
	, 0
	, 0
	, 0
	, 'PA'
	, ' '
	, 220
	, 0
	, ' '
	, ' '
	, 0
	)
GO

INSERT INTO dbo.RRI_PARAMETROS_INF
	(
	CODIGO
	, ID1
	, ID2
	, ID3
	, ID4
	, ID5
	, NUM1
	, NUM2
	, CHAR1
	, CHAR2
	, TZ_LOCK
	)
VALUES
	(
	515
	, 0
	, 0
	, 0
	, 'PG'
	, ' '
	, 221
	, 0
	, ' '
	, ' '
	, 0
	)
GO

INSERT INTO dbo.RRI_PARAMETROS_INF
	(
	CODIGO
	, ID1
	, ID2
	, ID3
	, ID4
	, ID5
	, NUM1
	, NUM2
	, CHAR1
	, CHAR2
	, TZ_LOCK
	)
VALUES
	(
	515
	, 0
	, 0
	, 0
	, 'UY'
	, ' '
	, 225
	, 0
	, ' '
	, ' '
	, 0
	)
GO
