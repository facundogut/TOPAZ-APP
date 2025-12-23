EXECUTE('
---------------------------
--CAMBIO NOMBRE OPERACIÓN--
---------------------------
UPDATE OPERACIONES
SET NOMBRE = ''Autorización Movimientos del FUCO''
	, DESCRIPCION = ''Autorización Movimientos del FUCO''
WHERE TITULO = 3504 AND IDENTIFICACION = 3667
-----
')