EXECUTE('

UPDATE dbo.OPERACIONES
SET NOMBRE = ''Pase Tesoro a Caja - Envío''
	, DESCRIPCION = ''Pase Tesoro a Caja - Envío''
WHERE TITULO = 3100 AND IDENTIFICACION = 8220


UPDATE dbo.OPERACIONES
SET NOMBRE = ''Pase Tesoro a Caja - Recepción''
	, DESCRIPCION = ''Pase Tesoro a Caja - Recepción''
WHERE TITULO = 3000 AND IDENTIFICACION = 8221

')
