EXECUTE('
-------------------------------------------------------------
--NUEVO PARAMETRO PRODUCTO INTERESES PARA RENOV. DE CAPITAL--
-------------------------------------------------------------
INSERT INTO dbo.PARAMETROSGENERALES (CODIGO, DESCRIPCION, ALFA, NUMERICO, FECHA, IMPORTE, TASA, TZ_LOCK)
VALUES (718, ''Prod. UVA/UVI ints. Ren. Cap.'', NULL, 90, NULL, 0, 0, 0)
----
')