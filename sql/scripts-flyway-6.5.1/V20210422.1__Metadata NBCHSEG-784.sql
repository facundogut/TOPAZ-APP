EXECUTE('
-------------------------------------------
--AGREGO VALIDACIÓN DE NEGATIVOS AL CAMPO--
-------------------------------------------
UPDATE DICCIONARIO
SET VALIDACION = 144
WHERE NUMERODECAMPO = 34630
----
')
