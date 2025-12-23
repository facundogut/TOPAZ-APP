EXECUTE ('






UPDATE dbo.OPERACIONES
SET   NOMBRE = ''Cobro de Conceptos''
	, DESCRIPCION = ''Cobro de Conceptos''
WHERE TITULO = 3501 AND IDENTIFICACION = 3587



UPDATE dbo.OPERACIONES
SET   NOMBRE = ''Devolución de Conceptos''
	, DESCRIPCION = ''Devolución de Conceptos''
WHERE TITULO = 3501 AND IDENTIFICACION = 3586



')