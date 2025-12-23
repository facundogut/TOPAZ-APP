EXECUTE('
----------------------------------------------
--UPDATE DE CÓDIGO DE CANCELACIÓN INCORRECTO--
----------------------------------------------
UPDATE SALDOS
SET C1679 = ''0''
WHERE C1679 = ''''
AND C1785 in (2,3)
----
')