EXECUTE('
---------------------------------------------------
--Parmámetros generales límites trf. a otro banco--
---------------------------------------------------
INSERT INTO dbo.PARAMETROSGENERALES (CODIGO, DESCRIPCION, ALFA, NUMERICO, FECHA, IMPORTE, TASA, TZ_LOCK)
VALUES (699, ''Límite trans. a otro banco ME'', '''', 0, NULL, 1000, 0, 0)
--
UPDATE dbo.PARAMETROSGENERALES
SET DESCRIPCION = ''Límite trans. a otro banco MN''
WHERE CODIGO = 700
----
')


