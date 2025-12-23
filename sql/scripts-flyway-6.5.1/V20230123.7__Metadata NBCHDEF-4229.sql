EXECUTE('
-----------------------------------------
--CORRECCIÓN AYUDA AJUSTE POR INFLACIÓN--
-----------------------------------------
UPDATE dbo.AYUDAS
SET CAMPOS = ''51000ROA1;51002;51003;51007;51004;51001ROA2;''
WHERE NUMERODEAYUDA = 51001
----
')
