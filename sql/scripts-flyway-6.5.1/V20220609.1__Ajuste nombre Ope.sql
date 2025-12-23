EXECUTE('
UPDATE dbo.OPERACIONES
SET NOMBRE = ''ABC Relación Pers. Juridica - Personas inhab''
	, DESCRIPCION = ''ABC Relación Pers. Juridica - Personas inhabilitadas''
WHERE TITULO = 1000 AND IDENTIFICACION = 42
')

