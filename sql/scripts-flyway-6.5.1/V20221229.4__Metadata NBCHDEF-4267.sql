EXECUTE('
-------------------------------
--CORRECCIÓN NOMBRE OPERACIÓN--
-------------------------------
UPDATE dbo.OPERACIONES
SET NOMBRE = ''Reimpresión Certificado DPF''
	, DESCRIPCION = ''Reimpresión Certificado DPF''
WHERE TITULO = 5000 AND IDENTIFICACION = 5041
----
')
