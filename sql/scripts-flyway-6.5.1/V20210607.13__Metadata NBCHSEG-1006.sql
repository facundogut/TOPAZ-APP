EXECUTE('
-----------------------------------
--MODIFICA ACTULAIZABLE DE CARGOS--
-----------------------------------
UPDATE CI_CARGOS
SET ACTUALIZABLE = ''S''
WHERE ID_CARGO = 8021
--
UPDATE CI_CARGOS
SET ACTUALIZABLE = ''S''
WHERE ID_CARGO = 8022
----
')