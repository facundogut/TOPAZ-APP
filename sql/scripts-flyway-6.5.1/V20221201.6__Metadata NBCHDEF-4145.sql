EXECUTE('
----------------------
--TICKET DE CAJA DPF--
----------------------
UPDATE dbo.REPORTES
SET DESCRIPCION = ''Ticket de Caja DPF''
WHERE TITULO = 5000 AND IDENTIFICACION = 5073
----
')
