----------------PARAMETRIA GENERAL RRII 2--------------
EXECUTE ('DELETE RRI_PARAMETROS_DEF

INSERT INTO RRI_PARAMETROS_DEF (CODIGO, NOMBRE, ID1, ID1DESC, ID2, ID2DESC, ID3, ID3DESC, ID4, ID4DESC, ID5, ID5DESC, NUM1, NUM1DESC, NUM2, NUM2DESC, CHAR1, CHR1DESC, CHAR2, CHR2DESC, TZ_LOCK)
VALUES (33, ''Rubro no cambia sign'', ''S'', ''Correlativo'', ''N'', '' '', ''N'', '' '', ''N'', '' '', ''N'', '' '', ''S'', ''Código interno'', ''N'', '' '', ''N'', '' '', ''N'', '' '', 0)


INSERT INTO RRI_PARAMETROS_DEF (CODIGO, NOMBRE, ID1, ID1DESC, ID2, ID2DESC, ID3, ID3DESC, ID4, ID4DESC, ID5, ID5DESC, NUM1, NUM1DESC, NUM2, NUM2DESC, CHAR1, CHR1DESC, CHAR2, CHR2DESC, TZ_LOCK)
VALUES (555, ''Tipo de PROD'', ''S'', ''Tipo Prod'', ''N'', '' '', ''N'', '' '', ''N'', '' '', ''N'', '' '', ''N'', '' '', ''N'', '' '', ''N'', '' '', ''N'', '' '', 311384020000074)


INSERT INTO RRI_PARAMETROS_DEF (CODIGO, NOMBRE, ID1, ID1DESC, ID2, ID2DESC, ID3, ID3DESC, ID4, ID4DESC, ID5, ID5DESC, NUM1, NUM1DESC, NUM2, NUM2DESC, CHAR1, CHR1DESC, CHAR2, CHR2DESC, TZ_LOCK)
VALUES (5, ''Tipo de operación'', ''S'', ''TipoOper'', ''N'', '' '', ''N'', '' '', ''N'', '' '', ''N'', '' '', ''S'', ''Código interno'', ''N'', '' '', ''N'', '' '', ''N'', '' '', 0)


INSERT INTO RRI_PARAMETROS_DEF (CODIGO, NOMBRE, ID1, ID1DESC, ID2, ID2DESC, ID3, ID3DESC, ID4, ID4DESC, ID5, ID5DESC, NUM1, NUM1DESC, NUM2, NUM2DESC, CHAR1, CHR1DESC, CHAR2, CHR2DESC, TZ_LOCK)
VALUES (330, ''Relación FALAC'', ''S'', ''Rubro contable'', ''S'', ''Moneda'', ''N'', '' '', ''N'', '' '', ''N'', '' '', ''S'', ''Partida a informar'', ''S'', ''Coeficiente'', ''N'', '' '', ''N'', '' '', 0)


INSERT INTO RRI_PARAMETROS_DEF (CODIGO, NOMBRE, ID1, ID1DESC, ID2, ID2DESC, ID3, ID3DESC, ID4, ID4DESC, ID5, ID5DESC, NUM1, NUM1DESC, NUM2, NUM2DESC, CHAR1, CHR1DESC, CHAR2, CHR2DESC, TZ_LOCK)
VALUES (1, ''Eq. Moneda SISCEN'', ''S'', ''Moneda TOPAZ'', ''N'', '' '', ''N'', '' '', ''N'', '' '', ''N'', '' '', ''S'', ''Moneda SISCEN (T003)'', ''N'', '' '', ''S'', ''Código SWIFT'', ''N'', '' '', 0)


INSERT INTO RRI_PARAMETROS_DEF (CODIGO, NOMBRE, ID1, ID1DESC, ID2, ID2DESC, ID3, ID3DESC, ID4, ID4DESC, ID5, ID5DESC, NUM1, NUM1DESC, NUM2, NUM2DESC, CHAR1, CHR1DESC, CHAR2, CHR2DESC, TZ_LOCK)
VALUES (2, ''Equivalencia Monedas'', ''S'', ''Mda TOPAZ'', ''S'', ''Mda BCRA'', ''N'', '' '', ''N'', '' '', ''N'', '' '', ''N'', '' '', ''N'', '' '', ''N'', '' '', ''N'', '' '', 311384020000072)


INSERT INTO RRI_PARAMETROS_DEF (CODIGO, NOMBRE, ID1, ID1DESC, ID2, ID2DESC, ID3, ID3DESC, ID4, ID4DESC, ID5, ID5DESC, NUM1, NUM1DESC, NUM2, NUM2DESC, CHAR1, CHR1DESC, CHAR2, CHR2DESC, TZ_LOCK)
VALUES (4, ''Rubros excluir signo'', ''S'', ''Correlativo'', ''N'', '' '', ''N'', '' '', ''N'', '' '', ''N'', '' '', ''S'', ''Rubro 6 dígitos'', ''N'', '' '', ''N'', '' '', ''N'', '' '', 0)

DELETE RRI_PARAMETROS_INF

INSERT INTO RRI_PARAMETROS_INF (CODIGO, ID1, ID2, ID3, ID4, ID5, NUM1, NUM2, CHAR1, CHAR2, TZ_LOCK)
VALUES (4, 1, 0, 0, ''0'', ''0'', 121135, 0, ''NA'', ''NA'', 0)


INSERT INTO RRI_PARAMETROS_INF
(CODIGO, ID1, ID2, ID3, ID4, ID5, NUM1, NUM2, CHAR1, CHAR2, TZ_LOCK)
VALUES
(5, 1, 1, 1100, '' '', '' '', 0, 0, '' '', '' '', 0),
(5, 3, 1, 1110, '' '', '' '', 0, 0, '' '', '' '', 0),
(5, 24, 1, 1111, '' '', '' '', 0, 0, '' '', '' '', 0),
(5, 2, 1, 1112, '' '', '' '', 0, 0, '' '', '' '', 0),
(5, 1, 2, 1200, '' '', '' '', 0, 0, '' '', '' '', 0),
(5, 1, 5, 1300, '' '', '' '', 0, 0, '' '', '' '', 0),
(5, 1, 6, 1300, '' '', '' '', 0, 0, '' '', '' '', 0),
(5, 5, 1, 1400, '' '', '' '', 0, 0, '' '', '' '', 0),
(5, 5, 2, 1500, '' '', '' '', 0, 0, '' '', '' '', 0),
(5, 5, 5, 1600, '' '', '' '', 0, 0, '' '', '' '', 0),
(5, 5, 6, 1600, '' '', '' '', 0, 0, '' '', '' '', 0),
(5, 1, 998, 1700, '' '', '' '', 0, 0, '' '', '' '', 0),
(5, 1, 999, 1800, '' '', '' '', 0, 0, '' '', '' '', 0),
(5, 51, 1, 2100, '' '', '' '', 0, 0, '' '', '' '', 0),
(5, 101, 1, 3100, '' '', '' '', 0, 0, '' '', '' '', 0),
(5, 101, 2, 3200, '' '', '' '', 0, 0, '' '', '' '', 0),
(5, 101, 5, 3200, '' '', '' '', 0, 0, '' '', '' '', 0),
(5, 101, 6, 3200, '' '', '' '', 0, 0, '' '', '' '', 0),
(5, 104, 998, 3400, '' '', '' '', 0, 0, '' '', '' '', 0),
(5, 103, 999, 3500, '' '', '' '', 0, 0, '' '', '' '', 0),
(5, 9, 1, 5100, '' '', '' '', 0, 0, '' '', '' '', 0)')


