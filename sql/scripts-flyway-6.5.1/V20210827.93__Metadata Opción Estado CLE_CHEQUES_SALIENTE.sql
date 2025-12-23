EXECUTE('
-----------------------
--MODIFICACIÓN OPCIÓN--
-----------------------
UPDATE OPCIONES
SET DESCRIPCION = ''Digitalizado''
WHERE NUMERODECAMPO = 7021 AND IDIOMA = ''E'' AND OPCIONINTERNA = ''1''
----
')