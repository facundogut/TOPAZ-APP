EXECUTE('
----------------------------
--AJUSTE NOMBRE DE REPORTE--
----------------------------
UPDATE dbo.REPORTES
SET DESCRIPCION = ''Pre Aviso Vto. de Contrato Caja Seguridad''
WHERE TITULO = 9000 AND IDENTIFICACION = 7142
----
')

