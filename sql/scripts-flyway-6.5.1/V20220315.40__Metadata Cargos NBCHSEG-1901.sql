EXECUTE('
-------------------------------
--CORRECCIÓN DE EVENTO DEL PA--
-------------------------------
DELETE FROM CI_CARGOS_X_EVENTO
WHERE ID_CARGO = 1501 AND ID_EVENTO = 1500
----
')