EXECUTE('
----------------------------------
--NUEVO CAMPO CLE_CHEQUES_AJUSTE--
----------------------------------
ALTER TABLE CLE_CHEQUES_AJUSTE ADD MONEDA NUMERIC (4, 0)
----
')

