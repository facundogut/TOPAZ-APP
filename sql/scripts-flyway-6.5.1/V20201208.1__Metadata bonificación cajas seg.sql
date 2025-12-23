EXECUTE('
------------------------------
--QUITAR TABLA DE VALIDACIÓN--
------------------------------
UPDATE DICCIONARIO
SET TABLADEVALIDACION = 0
WHERE NUMERODECAMPO = 8039
----
')