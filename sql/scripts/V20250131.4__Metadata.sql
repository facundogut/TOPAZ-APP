EXECUTE ('






UPDATE dbo.OPERACIONES
SET 
	 NOMBRE = ''Anulación compra/venta''
	,DESCRIPCION = ''Anulación compra/venta''
WHERE TITULO = 3000 AND IDENTIFICACION = 3071




')