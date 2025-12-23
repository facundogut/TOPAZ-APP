EXECUTE('
IF OBJECT_ID (''dbo.VW_ACREDITACIONES_SUELDOS'') IS NOT NULL
	DROP VIEW dbo.VW_ACREDITACIONES_SUELDOS
')

EXECUTE('
CREATE   VIEW [dbo].[VW_ACREDITACIONES_SUELDOS] (
														Fecha, 
														Producto, 
														Nombre_Producto, 
														Sucursal, 
														Nombre_Sucursal, 
														Cuenta, 
														Convenio, 
														Nombre_Convenio, 
														Jurisdiccion, 
														Acreditacion, 
														Monto,
														Cliente)
AS 
	SELECT TOP 9223372036854775807 WITH TIES a.FECHA AS Fecha, 
			s.PRODUCTO AS Producto, 
			p.C6251 AS ''Nombre_Producto'', 
			suc.SUCURSAL AS Sucursal, 
			suc.NOMBRESUCURSAL AS ''Nombre_Sucursal'', 
			s.CUENTA AS ''Cuenta'', 
			a.CONVENIO AS Convenio, 
			c.NomConvPago AS ''Nombre_Convenio'', 
			a.ID_JURISDICCION AS Jurisdiccion, 
			CASE WHEN a.TIPO = ''S'' THEN ''Sueldo'' ELSE ''Aguinaldo'' END AS Acreditacion, 
			a.MONTO AS Monto, 
			s.C1803 AS Cliente
	FROM CRE_SOL_ACREDITACIONES_SUELDOS a WITH(NOLOCK)
	INNER JOIN SALDOS s WITH(NOLOCK) ON a.SALDO_JTS_OID = s.JTS_OID 
										AND s.TZ_LOCK = 0
	INNER JOIN PRODUCTOS p WITH(NOLOCK) ON s.PRODUCTO = p.C6250 
										AND p.TZ_LOCK = 0
	INNER JOIN SUCURSALES suc WITH(NOLOCK) ON s.SUCURSAL = suc.SUCURSAL 
								AND suc.TZ_LOCK = 0
	INNER JOIN CONV_CONVENIOS_PAG c WITH(NOLOCK) ON a.CONVENIO = c.ID_ConvPago 
											   --	AND c.Id_TpoConv = 3 
												AND c.TZ_LOCK = 0
	WHERE a.TZ_LOCK = 0
	ORDER BY s.CUENTA, 
			a.CONVENIO, 
			a.ID_JURISDICCION, 
			a.FECHA DESC
')