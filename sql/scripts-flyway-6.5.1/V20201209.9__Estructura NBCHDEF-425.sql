EXECUTE('
--------------------------------
--CAMBIO TIPO Y LARGO DE CAMPO--
--------------------------------
ALTER TABLE GRL_EMBARGO DROP CONSTRAINT DF__GRL_EMBAR__NroEx__1E20D95B
--
ALTER TABLE GRL_EMBARGO ALTER COLUMN NroExpediente VARCHAR(12)
----
')