EXECUTE('
---------------------------------
--AJUSTE DE AYUDA CB_ESTRUCTURA--
---------------------------------
UPDATE dbo.AYUDAS
SET CAMPOS = ''44891R;44893R;44894;44890R;44892;''
WHERE NUMERODEAYUDA = 44771
----
')