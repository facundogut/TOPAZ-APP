EXECUTE('
UPDATE dbo.ITF_MASTER
SET P4_MODO = ''P''
	, P4_TIPO = ''S''
	, P4_CAPTION = ''Reversa (S/N)''
WHERE ID = 321
')

EXECUTE('
UPDATE dbo.ITF_MASTER
SET P3_MODO = ''P''
	, P3_TIPO = ''S''
	, P3_CAPTION = ''Prestación''
WHERE ID = 321
')

