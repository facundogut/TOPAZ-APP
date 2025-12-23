EXECUTE('
--------------------------
--CORRECCIÓN DE FÓRMULAS--
--------------------------
UPDATE dbo.CI_FORMULAS
SET FORMULA = ''((C34706=3)Y(C34704#C34705)Y(C34705=''''J'''')Y(C34707=''''S'''')Y(C34757#''''S'''')Y(C34985#''''I''''))''
WHERE ID_FORMULA = 1221
--
UPDATE dbo.CI_FORMULAS
SET FORMULA = ''((C34706=2)Y(C34704#C34705)Y(C34705=''''J'''')Y(C34707=''''S'''')Y(C34757#''''S'''')Y(C34985#''''I''''))''
WHERE ID_FORMULA = 1225
----
')
