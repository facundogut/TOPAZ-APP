EXECUTE('
IF NOT EXISTS (
    SELECT 1 
    FROM sys.indexes 
    WHERE name = ''Indice1_SDS'' 
    AND object_id = OBJECT_ID(''dbo.CLI_ClientePersona'')
)

CREATE INDEX Indice1_SDS
	ON dbo.CLI_ClientePersona (CODIGOCLIENTE,TITULARIDAD, TZ_LOCK)
')

EXECUTE('
IF NOT EXISTS (
    SELECT 1 
    FROM sys.indexes 
    WHERE name = ''Indice2_SDS'' 
    AND object_id = OBJECT_ID(''dbo.CLI_DocumentosPFPJ'')
)

CREATE INDEX Indice2_SDS
	ON dbo.CLI_DocumentosPFPJ (NUMEROPERSONAFJ, TZ_LOCK)
')