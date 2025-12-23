EXECUTE('
UPDATE dbo.OPERACIONES
SET NOMBRE = ''Cancelación de Saldos Seguro Saldo Deudor''
	, DESCRIPCION = ''Cancelación de Saldos Seguro Saldo Deudor''
WHERE TITULO = 6810 AND IDENTIFICACION = 7007
')