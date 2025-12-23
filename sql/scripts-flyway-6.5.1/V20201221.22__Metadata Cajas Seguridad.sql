EXECUTE('
-----------------------------------------
--MODIFICAR ORDEN AYUDA CAJAS SEGURIDAD--
-----------------------------------------
UPDATE AYUDAS
SET CAMPOS = ''8054OA1;8055OA2;8062;8064;8063;8059;8053R;34878;''
WHERE NUMERODEAYUDA = 8053
---------------------------
--DESCRIPCIÓN DE REPORTES--
---------------------------
UPDATE REPORTES
SET DESCRIPCION = ''Solicitud y Condiciones Cajas de Seguridad PF 1''
WHERE TITULO = 9000 AND IDENTIFICACION = 7181
----
UPDATE REPORTES
SET DESCRIPCION = ''Solicitud y Condiciones Cajas de Seguridad PF 2''
WHERE TITULO = 9000 AND IDENTIFICACION = 7182
----
UPDATE REPORTES
SET DESCRIPCION = ''Solicitud y Condiciones Cajas de Seguridad PF 3''
WHERE TITULO = 9000 AND IDENTIFICACION = 7183
----
UPDATE REPORTES
SET DESCRIPCION = ''Alquiler de Cajas de Seguridad''
WHERE TITULO = 9000 AND IDENTIFICACION = 7143
----
')



