
EXECUTE 
('
UPDATE dbo.OPERACIONES
SET NOMBRE = ''Depósito Cheque Ot. Banco''
	, DESCRIPCION = ''Depósito Cheque Ot. Banco''
WHERE TITULO = 3501 AND IDENTIFICACION = 3507
')

