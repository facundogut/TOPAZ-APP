EXECUTE('
----------------------------
--CAMBIO DE RUBRO CONCEPTO--
----------------------------
UPDATE dbo.CONCEPCONT
SET C6501 = ''Transf. intbrias. dd Topaz mn''
	, C6502 = 3510090390
WHERE C6500 = 235
--
UPDATE dbo.CONCEPCONT
SET C6501 = ''Transf. intbrias. dd Topaz me''
	, C6502 = 3550090090
WHERE C6500 = 236
----
')