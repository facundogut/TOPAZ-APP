EXECUTE('
-------------------------------------
--AJUSTE LARGO ID_ARCHIVO_REVERSADO--
-------------------------------------
UPDATE dbo.DICCIONARIO
SET LARGO = 44
WHERE NUMERODECAMPO = 44684
----
')