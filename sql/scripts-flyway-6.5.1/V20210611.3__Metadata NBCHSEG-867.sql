EXECUTE('
-----------------------------------------
--VALIDACIÓN DE CAMPO VALORES NEGATIVOS--
-----------------------------------------
UPDATE DICCIONARIO
SET VALIDACION = 144
WHERE NUMERODECAMPO = 34315
----
')