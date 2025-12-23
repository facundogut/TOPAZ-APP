
EXECUTE('
UPDATE dbo.ITF_MASTER
SET 
	P1_CAPTION = ''ID Rendicion'',
	DESCRIPCION = ''Rendicion RENDSTD - Fmto 1''   
WHERE ID = 29;


UPDATE dbo.ITF_MASTER
SET 
	P1_CAPTION = ''ID Rendicion'',
	DESCRIPCION = ''Rendicion RENDSTDIG - Fmto 2''
WHERE ID = 30;
')