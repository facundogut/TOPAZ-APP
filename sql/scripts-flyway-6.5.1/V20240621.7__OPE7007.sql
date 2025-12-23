EXECUTE('
UPDATE dbo.OPERACIONES
SET NOMBRE = ''Pago de asistencias por siniestro''
	, DESCRIPCION = ''Pago de asistencias por siniestro''
WHERE TITULO = 6810 AND IDENTIFICACION = 7007
')


