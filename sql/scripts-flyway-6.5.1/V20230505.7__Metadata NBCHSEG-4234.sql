EXECUTE('
---------------------
--CORRECCIÓN OPCIÓN--
---------------------
UPDATE dbo.OPCIONES
SET DESCRIPCION = ''Ratificación Denuncia''
WHERE NUMERODECAMPO = 7644 AND IDIOMA = ''E'' AND OPCIONINTERNA = ''B''
----
')