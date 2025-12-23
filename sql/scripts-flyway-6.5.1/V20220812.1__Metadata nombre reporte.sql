EXECUTE('
----------------------------
--AJUSTE DE NOMBRE REPORTE--
----------------------------
UPDATE dbo.REPORTES
SET DESCRIPCION = ''Reimpresión de revocación de acceso a caja seg.''
WHERE TITULO = 8100 AND IDENTIFICACION = 8118
----
')