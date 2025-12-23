EXECUTE('
-------------------------------------------------
--ASIGNAR TJD_PERMISOS COMO TABLA DE VALIDACION--
-------------------------------------------------
UPDATE dbo.DICCIONARIO
SET TABLADEVALIDACION = 3471
WHERE NUMERODECAMPO = 34983
----
')
