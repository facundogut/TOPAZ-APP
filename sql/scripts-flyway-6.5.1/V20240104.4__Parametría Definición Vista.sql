EXECUTE('
-------------------------
--AJUSTE MODALIDAD PAGO--
-------------------------
UPDATE dbo.VTA_DEFINICION_VISTA
SET MODALIDADPAGO = ''P''
	, VALORMODALIDADPAGO = 0
	, ALGORITMOPAGO = ''A''
----
')
