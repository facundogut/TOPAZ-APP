EXECUTE('
-----------------------------
--MODIFICACIÓN NOMBRE AYUDA--
-----------------------------
UPDATE AYUDAS
SET DESCRIPCION = ''Contrato Caja Seg. por Persona''
WHERE NUMERODEAYUDA = 34641
----
')