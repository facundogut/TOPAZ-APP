EXECUTE('
-----------------------------
--CORRECCIÓN NOMBRE REPORTE--
-----------------------------
UPDATE dbo.REPORTES
SET DESCRIPCION = ''Reporte Certif.con Int.Anticipados''
WHERE TITULO = 5000 AND IDENTIFICACION = 5065
----
')