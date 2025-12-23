
EXEC('

BEGIN

DECLARE @ObjectName NVARCHAR(128)
DECLARE @sqlCommand varchar(1000)

SELECT @ObjectName = OBJECT_NAME([default_object_id]) FROM sys.columns WHERE object_id=OBJECT_ID(''CORREOS_A_ENVIAR'') AND [name] = ''DATA''

SET @sqlCommand = ''ALTER TABLE [dbo].[CORREOS_A_ENVIAR] DROP CONSTRAINT '' + @ObjectName

EXECUTE(@sqlCommand)

END

')

EXEC('

ALTER TABLE CORREOS_A_ENVIAR ALTER COLUMN [DATA] varchar(max) COLLATE Modern_Spanish_CI_AS NULL;

')