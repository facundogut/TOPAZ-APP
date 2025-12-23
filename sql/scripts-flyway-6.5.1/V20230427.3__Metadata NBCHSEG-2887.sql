EXECUTE('
----------------------------
--CORRECCIÓN ENCOLA CARGOS--
----------------------------
UPDATE dbo.CI_CARGOS
SET ENQUEUE = ''D''
WHERE ID_CARGO = 1452
----
UPDATE dbo.CI_CARGOS
SET ENQUEUE = ''D''
WHERE ID_CARGO = 1453
----
')