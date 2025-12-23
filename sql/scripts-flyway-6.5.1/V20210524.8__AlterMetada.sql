EXECUTE('IF OBJECT_ID (''dbo.VW_GARANTIAS'') IS NOT NULL
	DROP VIEW dbo.VW_GARANTIAS
	
	')
	
	EXECUTE ('

CREATE VIEW dbo.VW_GARANTIAS (
	Garantia, 
	NombreSucursal,
	Tipo_Garantia,
	SubClass_Garantia,
	Descripcion,
	Moneda, 
	Monto, 
	Vencimiento, 
	Tipo_Documento, 
	Documento, 
	Cobertura, 
	Cobertura_Post_Anio,
	Tipo_Documento_Ordenante,
	Documento_Ordenante,
	Estado)
AS 
	SELECT distinct
	gp.NUM_GARANTIA AS Garantia,
	s.NOMBRESUCURSAL AS NombreSucursal, 
	g.TIPOGARANTIA AS Tipo_Garantia,
	g.COD_SUBCLAGARANTIA AS SubClass_Garantia,
	c.DSC_CLASIFICACION AS Descripcion,
	m.C6401 AS Moneda, 
	g.IMPORTE_REAL AS Monto, 
	g.FCHVTO_GARANTIA AS Vencimiento, 
	doc.TIPODOC AS Tipo_Documento, 
	doc.NUMERODOC AS Documento, 
	c.PORCENTAJEAFECTACION AS Cobertura, 
	c.PORCENTAJEAFECTACION_1_ANIO AS Cobertura_Post_Anio,
	g.TIPODOCUMENTO AS Tipo_Documento_Ordenante, 
	g.NUMERODOCUMENTO AS Documento_Ordenante, 
	g.ESTADO_GARANTIA AS Estado
	FROM CRE_GarantiaPersonas gp
	INNER JOIN CRE_GARANTIASRECIBIDAS g ON gp.NUM_GARANTIA = g.NUM_GARANTIA AND gp.TZ_LOCK = 0
	INNER JOIN SUCURSALES s ON g.SUCURSAL_GARANTIA = s.SUCURSAL AND s.TZ_LOCK = 0
	INNER JOIN MONEDAS m ON g.MONEDA_GARANTIA = m.C6399 AND m.TZ_LOCK = 0
	INNER JOIN CRE_CLASGARANTIAS c ON g.TIPOGARANTIA = c.TIPOGARANTIA AND c.TZ_LOCK = 0
	INNER JOIN VW_CLI_X_DOC doc ON gp.NUM_PERSONA = doc.NUMEROPERSONA
	WHERE gp.TPO_PERSONA = ''B'' AND gp.TZ_LOCK = 0
')