EXECUTE('
---------------------------
--DIFERIR COBRO DEL CARGO--
---------------------------
UPDATE dbo.CI_CARGOS
SET ENQUEUE = ''D''
WHERE ID_CARGO = 1460
----
')
