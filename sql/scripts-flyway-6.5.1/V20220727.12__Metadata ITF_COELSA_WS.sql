EXECUTE('
----------------------------------
--MODIFICACIÓN TIPO DE CAMPO CBU--
----------------------------------
UPDATE dbo.DICCIONARIO
SET TIPODECAMPO = ''A''
WHERE NUMERODECAMPO = 66666
----
')
