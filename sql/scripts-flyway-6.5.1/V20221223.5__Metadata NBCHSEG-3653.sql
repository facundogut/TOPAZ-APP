EXECUTE('
------------------------------------
--CORRECCIÓN DE PROMPT PARA GRILLA--
------------------------------------
UPDATE DICCIONARIO
SET DESCRIPCION = ''Acción''
	, PROMPT = ''Acción''
WHERE NUMERODECAMPO = 35668
--
UPDATE dbo.DICCIONARIO
SET DESCRIPCION = ''Fecha Integración''
	, PROMPT = ''Fecha Integración''
WHERE NUMERODECAMPO = 35666
----
')

