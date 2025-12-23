EXECUTE('
-----------------------
--MODIFICACIÓN EVENTO--
-----------------------
DELETE FROM dbo.CI_CARGOS_X_EVENTO
WHERE ID_CARGO = 400 AND ID_EVENTO = 1230
----
')
