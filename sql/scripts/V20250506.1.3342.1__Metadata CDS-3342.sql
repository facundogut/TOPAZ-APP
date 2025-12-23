EXECUTE('
--------------------------------------
--AJUSTE DE OPERACION PARA AUTORIZAR--
--------------------------------------
UPDATE dbo.OPERACIONES
SET AUTORIZACION = ''N''
WHERE TITULO = 1002 AND IDENTIFICACION = 3310
----
')