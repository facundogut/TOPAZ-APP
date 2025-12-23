EXECUTE('
----------------------------
--AJUSTE CONDICIÓN IGA DPF--
----------------------------
UPDATE dbo.CI_CARGOS
SET CONDICION = 619
WHERE ID_CARGO = 626
----
')
