EXECUTE('
---------------------------------------
--AJUSTE CAMPO FECHA ESTADO CHEQUERAS--
---------------------------------------
UPDATE dbo.DICCIONARIO
SET DESCRIPCION = ''Fecha Cambio de Estado''
	, PROMPT = ''Fecha cambio Estado''
WHERE NUMERODECAMPO = 2962
----
')
