EXECUTE('
DECLARE @sql nvarchar(255)
BEGIN
    select @sql = ''ALTER TABLE CRE_VINCULACIONES_CONVENIOS DROP CONSTRAINT '' + default_constraints.name 
	FROM sys.all_columns
	INNER JOIN sys.tables ON all_columns.object_id = tables.object_id
	INNER JOIN  sys.schemas ON tables.schema_id = schemas.schema_id 
	INNER JOIN sys.default_constraints ON all_columns.default_object_id = default_constraints.object_id
	WHERE schemas.name = ''dbo'' AND tables.name = ''CRE_VINCULACIONES_CONVENIOS''
    AND all_columns.name = ''ID_BENEFICIO''

    exec sp_executesql @sql
END
')

EXECUTE('
ALTER TABLE CRE_VINCULACIONES_CONVENIOS ADD CONSTRAINT DF_ID_BENEFICIO DEFAULT ''0'' FOR ID_BENEFICIO
')

EXECUTE('
DELETE FROM CRE_VINCULACIONES_CONVENIOS WHERE TZ_LOCK <> 0
')

EXECUTE('
UPDATE VINC
SET ID_BENEFICIO = 0
FROM CRE_VINCULACIONES_CONVENIOS VINC
WHERE ID_BENEFICIO = '' '' AND TZ_LOCK = 0
')