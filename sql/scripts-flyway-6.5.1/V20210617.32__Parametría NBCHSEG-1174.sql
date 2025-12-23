EXECUTE('
-----------------------------------------
--AJUSTE PARAMETRIA CHE_MOTIVOS_RECHAZO--
-----------------------------------------
UPDATE CHE_MOTIVOS_RECHAZO
SET ESTADO_CHEQUE = ''B''
WHERE ESTADO_CHEQUE = ''H''
----
')


