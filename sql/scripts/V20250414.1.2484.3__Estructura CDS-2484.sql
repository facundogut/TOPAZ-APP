EXECUTE('
---------------------------------
--AJUSTE LARGO DE INFOEXTENDIDA--
---------------------------------
ALTER TABLE GRL_DET_ENVIO_ESTCTA ALTER COLUMN INFOEXTENDIDA VARCHAR (max)
----
')