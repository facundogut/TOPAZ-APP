EXECUTE('
-------------------------------------------------
--PARAMETRO BONIFICACIÓN POR DEFECTO CAJAS SEG.--
-------------------------------------------------
INSERT INTO PARAMETROSGENERALES (CODIGO, DESCRIPCION, ALFA, NUMERICO, FECHA, IMPORTE, TASA, TZ_LOCK)
VALUES (722, ''Bonif. por defecto Cajas Seg.'', NULL, 99, NULL, 0, 0, 0)
----
')