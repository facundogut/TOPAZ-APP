EXECUTE('
------------------------------------------
--AJUSTE DE IMPUESTO QUE NO CORRESPONDÍA--
------------------------------------------
DELETE FROM dbo.CI_IMPUESTOS_X_CARGO
WHERE ID_IMPUESTO = 1 AND ID_CARGO = 2200
--
')

