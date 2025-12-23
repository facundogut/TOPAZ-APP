EXECUTE('
UPDATE dbo.OPERACIONES
SET NOMBRE = ''Reimpresión de resumen de cuenta (sin restricción)''
	, DESCRIPCION = ''Reimpresión de resumen de cuenta (sin restricción)''
WHERE TITULO = 3503 AND IDENTIFICACION = 3447
')