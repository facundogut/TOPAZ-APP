EXECUTE('
UPDATE dbo.ITF_MASTER
SET P0_MODO = ''P''
	, P0_TIPO = ''S''
	, P0_CAPTION = ''Nombre Archivo''
WHERE ID = 78
')