EXECUTE('
------------------------------
--MODIFICACIÓN FORMULA CARGO--
------------------------------
UPDATE dbo.CI_FORMULAS
SET FORMULA = ''C3298*((C34499/30)+1)''
WHERE ID_FORMULA = 1201
----
')