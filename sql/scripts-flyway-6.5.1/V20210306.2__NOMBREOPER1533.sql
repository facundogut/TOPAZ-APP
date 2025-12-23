EXECUTE('
UPDATE dbo.OPERACIONES
SET NOMBRE = ''Habilitación de Personas Humanas''
	, DESCRIPCION = ''Habilitación de Personas Humanas''
WHERE TITULO = 1000 AND IDENTIFICACION = 1533
')