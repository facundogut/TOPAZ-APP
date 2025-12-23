EXECUTE('
-------------------------------------------
--AJUSTE ESTADO DE RESERVAS DADAS DE BAJA--
-------------------------------------------
UPDATE V
	SET TZ_LOCK = 0
		, ESTADO = 2
FROM VTA_RESERVAS AS V
WHERE
	(V.TZ_LOCK >= 300000000000000 AND V.TZ_LOCK < 400000000000000)
----
')