EXECUTE('
---------------------------------------------
--ELIMINO SUB OPERACIÓN QUE SE DEJA DE USAR--
---------------------------------------------
UPDATE OPERACIONES
SET TITULO = 9999
WHERE TITULO = 8100 AND IDENTIFICACION = 8122
----
')