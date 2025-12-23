EXECUTE('
------------------------------------------------
--NUEVO CAMPO FECHA REAL DETALLE ESTADO CUENTA--
------------------------------------------------
ALTER TABLE GRL_DET_ENVIO_ESTCTA ADD FECHA_REAL_MOV DATETIME
--
ALTER TABLE GRL_DET_ENVIO_ESTCTA ADD HORA_MOV VARCHAR(8)
----
')