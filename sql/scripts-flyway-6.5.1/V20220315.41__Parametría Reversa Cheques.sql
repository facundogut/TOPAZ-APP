EXECUTE ('
----------------------------------
--MODIFICACIÓN ESTADO PA REVERSA--
----------------------------------
UPDATE PARAMETROS_JTS
SET VALOR = ''A''
WHERE FUNCIONALIDAD = ''REVERSA_CHEQUES'' AND PARAMETRO = ''ESTADO''
----
')
