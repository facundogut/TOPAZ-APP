EXECUTE('
-----------------------------------------
--MODIFICACIÓN LARGO CAMPO CODIGOPOSTAL--
-----------------------------------------
ALTER TABLE GRL_CAB_ENVIO_ESTCTA ALTER COLUMN CODIGOPOSTAL VARCHAR(15)
----
')