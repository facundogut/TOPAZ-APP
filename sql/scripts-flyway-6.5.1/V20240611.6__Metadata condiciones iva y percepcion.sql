EXECUTE('
------------------------------------------
--AJUSTE DE CONDICIONES IVA Y PERCEPCIÓN--
------------------------------------------
UPDATE dbo.CI_FORMULAS
SET FORMULA = ''(C35693#''''S'''')Y(C4684=0)''
WHERE ID_FORMULA = 9
----
UPDATE dbo.CI_FORMULAS
SET FORMULA = ''(C1357=''''AC'''' O C44447=''''AC'''')Y((C35693#''''S'''')Y(C4684=0))''
WHERE ID_FORMULA = 6023
----
')
