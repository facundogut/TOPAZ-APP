EXECUTE('
-------------------------------------------
--ACTUALIZACIÓN NUMERADOR CLE_TIPO_CAUSAL--
-------------------------------------------
UPDATE NUMERATORVALUES
SET VALOR = 92
WHERE NUMERO = 35008
----
DELETE FROM NUMERATORASIGNED
WHERE OID = 2744760
----
')