EXECUTE('
---------------------------
--NUEVO CÓDIGO DE BLOQUEO--
---------------------------
INSERT INTO dbo.GRL_COD_BLOQUEOS (COD_BLOQUEO, DESCRIPCION, ACCIONES_DEBITO, ACCIONES_CREDITO, ACCIONES_MODIFICACION, TZ_LOCK)
VALUES (48, ''Inhabilitación de Personas-Clientes'', 3, 3, 3, 0)
----------------
--CORRECCIONES--
----------------
UPDATE dbo.DICCIONARIO
SET OPCIONES = 0
WHERE NUMERODECAMPO = 37353
----
UPDATE dbo.OPERACIONES
SET NOMBRE = ''Inhabilitación de personas-clientes''
	, DESCRIPCION = ''Inhabilitación de personas-clientes''
WHERE TITULO = 1000 AND IDENTIFICACION = 300
--
UPDATE dbo.OPERACIONES
SET NOMBRE = ''Habilitación de personas-clientes''
	, DESCRIPCION = ''Habilitación de personas-clientes''
WHERE TITULO = 1000 AND IDENTIFICACION = 400
-------
')

