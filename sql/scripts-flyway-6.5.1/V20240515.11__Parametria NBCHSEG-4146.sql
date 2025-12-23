EXECUTE('
----------------------------------------------
--NUEVOS PARÁMETROS LIMITE COBRO DE COMISIÓN--
----------------------------------------------
INSERT INTO dbo.PARAMETROSGENERALES (CODIGO, DESCRIPCION, ALFA, NUMERICO, FECHA, IMPORTE, TASA, TZ_LOCK)
VALUES (697, ''Límite com. trf. otro bco. UVA'', '''', 0, NULL, 7500, 0, 0)
--
INSERT INTO dbo.PARAMETROSGENERALES (CODIGO, DESCRIPCION, ALFA, NUMERICO, FECHA, IMPORTE, TASA, TZ_LOCK)
VALUES (698, ''Límite com. trf. otro bco. USD'', '''', 0, NULL, 6000, 0, 0)
----
')
