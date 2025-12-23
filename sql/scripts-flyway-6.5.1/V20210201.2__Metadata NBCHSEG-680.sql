EXECUTE('
-----------------------------------
--MODIFICACIÓN DESCRIPCIÓN CAMPOS--
-----------------------------------
UPDATE DICCIONARIO
SET DESCRIPCION = ''Descripción''
	, PROMPT = ''Descripción''
WHERE NUMERODECAMPO = 50171
----
UPDATE DICCIONARIO
SET DESCRIPCION = ''Tiene Fórmula''
	, PROMPT = ''Tiene Fórmula''
WHERE NUMERODECAMPO = 50172
----
')
