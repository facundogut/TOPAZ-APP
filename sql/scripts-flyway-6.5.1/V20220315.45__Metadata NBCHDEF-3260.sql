EXECUTE('
------------------------------------
--MODIFICACION NOMBRE DE OPERACIÓN--
------------------------------------
UPDATE OPERACIONES
SET NOMBRE = ''ABC Tipos de Poderes por Tipo de Entidad''
	, DESCRIPCION = ''ABC Tipos de Poderes por Tipo de Entidad''
WHERE TITULO = 1200 AND IDENTIFICACION = 1152
------
')