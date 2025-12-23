EXECUTE('
------------------------------------------------------
--MODIFICACIÓN INDICE CLE_CHEQUES_CLEARING_RECIBIDO --
------------------------------------------------------
UPDATE INDICES
SET CAMPO1 = 4529
	, CAMPO2 = 4532
	, CAMPO3 = 4533
	, CAMPO4 = 4534
	, CAMPO5 = 4535
	, CAMPO6 = 4536
	, CAMPO7 = 4544
WHERE NUMERODEARCHIVO = 154 AND NUMERODEINDICE = 2
----
')