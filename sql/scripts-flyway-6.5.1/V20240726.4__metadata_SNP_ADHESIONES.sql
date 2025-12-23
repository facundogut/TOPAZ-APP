EXECUTE('IF NOT EXISTS (SELECT * 
               FROM sys.columns 
               WHERE Name = ''ID_CLI_PAGADOR_ORIGINAL'' 
                 AND Object_ID = Object_ID(''SNP_ADHESIONES''))
BEGIN
    ALTER TABLE SNP_ADHESIONES ADD ID_CLI_PAGADOR_ORIGINAL VARCHAR(22);
END

IF NOT EXISTS (SELECT * 
               FROM sys.columns 
               WHERE Name = ''CBU_ORIGINAL'' 
                 AND Object_ID = Object_ID(''SNP_ADHESIONES''))
BEGIN
    ALTER TABLE SNP_ADHESIONES ADD CBU_ORIGINAL VARCHAR(22);
END
');