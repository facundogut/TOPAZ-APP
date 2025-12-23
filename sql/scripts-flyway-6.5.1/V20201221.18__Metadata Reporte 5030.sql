EXECUTE('
------------------------------
--MODIFICO NOMBRE DE REPORTE--
------------------------------
UPDATE REPORTES
SET DESCRIPCION = ''Información Histórica DPF''
WHERE TITULO = 5000 AND IDENTIFICACION = 5030
-------
')