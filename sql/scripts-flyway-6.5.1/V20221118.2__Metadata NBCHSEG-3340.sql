EXECUTE('
---------------------------
--ACTUALIZACIÓN DE CARGOS--
---------------------------
UPDATE dbo.CI_CARGOS
SET IMPORTE_MINIMO = 240
WHERE ID_CARGO = 619
----
')