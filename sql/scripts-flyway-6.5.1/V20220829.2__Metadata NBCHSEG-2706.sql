EXECUTE('
----------------------------
--CAMBIO TITULO DE REPORTE--
----------------------------
UPDATE dbo.REPORTES
SET TITULO = 3510
WHERE TITULO = 3500 AND IDENTIFICACION = 3312
----
')

