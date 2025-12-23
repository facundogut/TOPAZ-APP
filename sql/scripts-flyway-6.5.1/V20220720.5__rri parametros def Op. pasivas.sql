EXECUTE('DELETE RRI_PARAMETROS_DEF WHERE CODIGO=5

INSERT INTO RRI_PARAMETROS_DEF (CODIGO, NOMBRE, ID1, ID1DESC, ID2, ID2DESC, ID3, ID3DESC, ID4, ID4DESC, ID5, ID5DESC, NUM1, NUM1DESC, NUM2, NUM2DESC, CHAR1, CHR1DESC, CHAR2, CHR2DESC, TZ_LOCK)
VALUES (5, ''Tipo de operación'', ''S'', ''Producto'', ''S'', ''Moneda'', ''S'', ''Tipo operación'', ''N'', '''', ''N'', '''', ''N'', '''', ''N'', '''', ''N'', '''', ''N'', '''', 0)
')