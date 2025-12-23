EXECUTE('
-------------------------------
--AGREGO VALIDACIÓN A IMPORTE--
-------------------------------
UPDATE DICCIONARIO
SET VALIDACION = 144
WHERE NUMERODECAMPO = 34206
----
')
