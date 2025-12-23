EXECUTE('
----------------------------------------------
--AJUSTE DE AYUDA TJD_SOLICITUD_CUENTAS_LINK--
----------------------------------------------
UPDATE dbo.AYUDAS
SET CAMPOS = ''1360R;397;3843;1097;910;546;622R;2487;''
WHERE NUMERODEAYUDA = 34011
----
')