EXECUTE('
--------------------------------
--MODIFICACIÓN DESCRIPCIÓN OPE--
--------------------------------
UPDATE OPERACIONES
SET NOMBRE = ''ABMC Códigos de Bloqueos''
	, DESCRIPCION = ''ABMC Códigos de Bloqueos''
WHERE TITULO = 8000 AND IDENTIFICACION = 8067
----
')