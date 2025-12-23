EXECUTE('
----------------------------
--CAMBIO TITULO DE REPORTE--
----------------------------
UPDATE dbo.REPORTES
SET TITULO = 9500
WHERE TITULO = 3510 AND IDENTIFICACION = 7277
----
')

