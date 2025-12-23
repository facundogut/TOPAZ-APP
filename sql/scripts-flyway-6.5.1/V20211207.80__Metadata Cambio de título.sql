EXECUTE('
------------------------------
--CAMBIO DE TITULO OPERACIÓN--
------------------------------
UPDATE OPERACIONES
SET TITULO = 3551
WHERE TITULO = 3551 AND IDENTIFICACION = 3925
----
')
