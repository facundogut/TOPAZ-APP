EXECUTE('
-----------------------------------
--CORRECCIONES PROMPTS PARA AYUDA--
-----------------------------------
UPDATE dbo.DICCIONARIO
SET DESCRIPCION = ''Código Ente''
	, PROMPT = ''Código Ente''
WHERE NUMERODECAMPO = 44400
--
UPDATE dbo.DICCIONARIO
SET DESCRIPCION = ''Descripción Ente''
	, PROMPT = ''Descripción Ente''
WHERE NUMERODECAMPO = 44410
--
UPDATE dbo.DICCIONARIO
SET DESCRIPCION = ''Id Convenio Recaudación''
	, PROMPT = ''Id Convenio Recaudación''
WHERE NUMERODECAMPO = 44420
--
UPDATE dbo.DICCIONARIO
SET DESCRIPCION = ''Nombre Convenio Recaudación''
	, PROMPT = ''Nombre Convenio Recaudación''
WHERE NUMERODECAMPO = 44430
--
UPDATE dbo.DICCIONARIO
SET DESCRIPCION = ''Tipo Ente''
	, PROMPT = ''Tipo Ente''
WHERE NUMERODECAMPO = 44440
--------------------
UPDATE dbo.AYUDAS
SET CAMPOS = ''44400ROA1;44410;44420OA2;44430;44440;''
WHERE NUMERODEAYUDA = 99953
----
')
