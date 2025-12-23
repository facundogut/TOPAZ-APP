EXECUTE('
-------------------------------------
--MODIFICACIÓN DESC. AYUDA PERMISOS--
-------------------------------------
UPDATE AYUDAS
SET DESCRIPCION = ''Listado de Permisos''
WHERE NUMERODEAYUDA = 35130
----
')