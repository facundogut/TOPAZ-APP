EXECUTE('
-----------------------
--NOMBRES DE REPORTES--
-----------------------
UPDATE REPORTES
SET DESCRIPCION = ''Reporte Solicitudes de FN Sucursales''
WHERE TITULO = 5000 AND IDENTIFICACION = 5150
----
UPDATE REPORTES
SET DESCRIPCION = ''Reporte Pedido de devoluciones de FN''
WHERE TITULO = 5000 AND IDENTIFICACION = 5152
----
')