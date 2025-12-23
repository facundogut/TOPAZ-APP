EXECUTE('
----------------------------------------
--PARAMETROS APODERAMIENTOS CAJAS SEG.--
----------------------------------------
INSERT INTO dbo.PARAMETROSGENERALES (CODIGO, DESCRIPCION, ALFA, NUMERICO, FECHA, IMPORTE, TASA, TZ_LOCK)
VALUES (216, ''Poder visitas Cajas Seguridad'', NULL, 10, NULL, 0, 0, 0)
----
INSERT INTO dbo.PARAMETROSGENERALES (CODIGO, DESCRIPCION, ALFA, NUMERICO, FECHA, IMPORTE, TASA, TZ_LOCK)
VALUES (217, ''Poder rescindir Contrato Cajas'', NULL, 11, NULL, 0, 0, 0)
----
')