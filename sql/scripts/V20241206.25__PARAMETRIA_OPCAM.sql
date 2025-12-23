EXECUTE('

DELETE FROM dbo.RRI_PARAMETROS_DEF
WHERE CODIGO = 200 AND NOMBRE = ''Tipo Operación OPCAM'' AND ID1 = ''S'' AND ID1DESC = ''Operación TOPAZ'' AND ID2 = ''N'' AND ID2DESC = '''' AND ID3 = ''N'' AND ID3DESC = '''' AND ID4 = ''S'' AND ID4DESC = ''Descripción'' AND ID5 = ''S'' AND ID5DESC = ''Debito/Crédito/Ambos'' AND NUM1 = ''N'' AND NUM1DESC = '''' AND NUM2 = ''N'' AND NUM2DESC = '''' AND CHAR1 = ''S'' AND CHR1DESC = ''Tipo Op. OPCAM'' AND CHAR2 = ''S'' AND CHR2DESC = ''Descripción'' AND TZ_LOCK = 0;

DELETE FROM dbo.RRI_PARAMETROS_INF
WHERE CODIGO = 200 AND ID1 = 3015 AND ID2 = 0 AND ID3 = 0 AND ID4 = ''Comp. ME x Caja'' AND ID5 = ''D'';


DELETE FROM dbo.RRI_PARAMETROS_INF
WHERE CODIGO = 200 AND ID1 = 3016 AND ID2 = 0 AND ID3 = 0 AND ID4 = ''Vent. ME x Caja'' AND ID5 = ''C'';


DELETE FROM dbo.RRI_PARAMETROS_INF
WHERE CODIGO = 200 AND ID1 = 7603 AND ID2 = 0 AND ID3 = 0 AND ID4 = ''Comp/Vta ME T.Pos'' AND ID5 = ''A'';


')
EXECUTE('
INSERT INTO dbo.RRI_PARAMETROS_DEF (CODIGO, NOMBRE, ID1, ID1DESC, ID2, ID2DESC, ID3, ID3DESC, ID4, ID4DESC, ID5, ID5DESC, NUM1, NUM1DESC, NUM2, NUM2DESC, CHAR1, CHR1DESC, CHAR2, CHR2DESC, TZ_LOCK)
VALUES (200, ''Tipo Operación OPCAM'', ''S'', ''Operación TOPAZ'', ''N'', '''', ''N'', '''', ''S'', ''Descripción'', ''S'', ''Debito/Crédito/Ambos'', ''N'', '''', ''N'', '''', ''S'', ''Tipo Op. OPCAM'', ''S'', ''Descripción'', 0);

INSERT INTO dbo.RRI_PARAMETROS_INF (CODIGO, ID1, ID2, ID3, ID4, ID5, NUM1, NUM2, CHAR1, CHAR2, TZ_LOCK)
VALUES (200, 3015, 0, 0, ''Comp. ME x Caja'', ''D'', 0, 0, ''A13'', ''Compras de billetes'', 0);

INSERT INTO dbo.RRI_PARAMETROS_INF (CODIGO, ID1, ID2, ID3, ID4, ID5, NUM1, NUM2, CHAR1, CHAR2, TZ_LOCK)
VALUES (200, 3016, 0, 0, ''Vent. ME x Caja'', ''C'', 0, 0, ''A13'', ''Ventas de billetes'', 0);

INSERT INTO dbo.RRI_PARAMETROS_INF (CODIGO, ID1, ID2, ID3, ID4, ID5, NUM1, NUM2, CHAR1, CHAR2, TZ_LOCK)
VALUES (200, 7603, 0, 0, ''Comp/Vta ME T.Pos'', ''A'', 0, 0, ''A13'', ''Compras de billetes'', 0);

')