EXECUTE('
--------------------
--UPDATE IMPUESTOS--
--------------------
UPDATE CI_CARGOS
SET CARGO_O_IMPUESTO = ''C''
WHERE ID_CARGO = 1400
----
')