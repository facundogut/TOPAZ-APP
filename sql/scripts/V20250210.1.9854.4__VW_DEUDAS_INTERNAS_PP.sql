EXECUTE('
IF OBJECT_ID (''dbo.VW_DEUDAS_INTERNAS_PP'') IS NOT NULL
	DROP VIEW dbo.VW_DEUDAS_INTERNAS_PP
')

EXECUTE('
CREATE   VIEW [dbo].[VW_DEUDAS_INTERNAS_PP] (
											Sucursal, 
											"Nombre Sucursal", 
											Producto, 
											"Nombre Producto", 
											Cuenta, 
											Operacion, 
											Desglose, 
											Moneda, 
											Monto,  
											Opcion,
											"Numero Solicitud")
AS
SELECT	SUCURSAL AS "Sucursal", 
		NOMBRESUCURSAL AS "Nombre Sucursal", 
		PRODUCTO AS "Producto", 
		NOMBREPRODUCTO AS "Nombre Producto", 
		CUENTA AS "Cuenta", 
		OPERACION AS "Operacion", 
		DESGLOSE AS "Desglose", 
		MONEDA AS "Moneda", 
		CAP_REESTRUCTURA AS "Monto", 
		CASE 
			WHEN r.CANCELO = ''S'' THEN ''Precancelar'' 
		ELSE ''Vencido'' 
		END AS "Opcion",
		NUMERO_SOLICITUD AS "Numero Solicitud"
FROM VW_ASISTENCIAS cre WITH(NOLOCK)
INNER JOIN CRE_DET_REESTRUCTURA r WITH(NOLOCK) ON cre.JTS_OID = r.JTS_OID_REESTRUCTURADA 
												AND r.TZ_LOCK = 0




')