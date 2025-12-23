EXECUTE('
IF OBJECT_ID (''dbo.VW_PRODUCTOS_CONVENIOS_AH'') IS NOT NULL
	DROP VIEW dbo.VW_PRODUCTOS_CONVENIOS_AH
')

EXECUTE('
CREATE     VIEW [dbo].[VW_PRODUCTOS_CONVENIOS_AH] (
														Producto, 
														NombreProducto, 
														Convenio,
														NombreConvenio,
														SucursalCuenta,
														NombreSucursal,
														Cuenta,
														EstadoCuenta,
														ContratoMarco,
														Beneficio,
														TipoContrato,
														pf,
														JTS_OID,
														MontoCalculado,
														CantidadSueldo,
														Jurisdiccion,
														TipoScoring,
														Afectacion,
														Canal,
														CapacidadPago,
														AfectacionCanal,
														Cliente,
														TipoConvenio,
														LineaScoring
)
AS
SELECT 
		pc.PRODUCTO AS Producto, 
		p.C6251 AS NombreProducto, 
		vc.ID_CONVENIO AS Convenio,
		c.NomConvPago AS NombreConvenio,
		s.SUCURSAL AS SucursalCuenta,
		suc.NOMBRESUCURSAL AS NombreSucursal, 
		s.CUENTA AS Cuenta,
		CASE WHEN s.C1651 = ''1'' THEN ''Cuenta Cerrada'' 
		ELSE ''Cuenta Activa'' 
		END AS EstadoCuenta,
		''Sin Firmar'' AS ContratoMarco,
		vc.ID_BENEFICIO AS Beneficio,
		t.TpoContrato AS TipoContrato,
		id_persona AS pf,
		s.JTS_OID,
		isnull(ca.MONTO_CALCULADO,0) AS MontoCalculado,
		pc.CANT_SUELDO AS CantidadSueldo,
		vc.ID_JURISDICCION AS Jurisdiccion,
		tp.TIPO_SCORING AS TipoScoring,
		pc.PORC_AFECTACION AS Afectacion,
		can.CANAL,
		isnull(ca.CAPACIDAD_PAGO,0) AS CapacidadPago,
		can.PORCENTAJE_AFECTACION AS AfectacionCanal,
		s.C1803 AS Cliente,
		c.Id_TpoConv AS TipoConvenio,
		tp.LINEA_SCORING AS LineaScoring
FROM CRE_VINCULACIONES_CONVENIOS vc WITH (NOLOCK)
INNER JOIN SALDOS s WITH (NOLOCK) ON vc.JTS_CV = s.JTS_OID 
									AND s.TZ_LOCK = 0 
									AND s.C1785 IN (2,3)
INNER JOIN SUCURSALES suc WITH (NOLOCK) ON s.SUCURSAL = suc.SUCURSAL 
										AND suc.TZ_LOCK = 0
INNER JOIN CRE_PROD_CONVENIOS pc WITH (NOLOCK) ON vc.ID_CONVENIO = pc.DATO_TIPO 
											AND pc.TIPO = ''C'' 
											AND pc.HABILITADO = ''S'' 
											AND pc.TZ_LOCK = 0
INNER JOIN CONV_CONVENIOS_PAG c WITH (NOLOCK) ON pc.DATO_TIPO = c.ID_ConvPago AND c.TZ_LOCK=0
INNER JOIN CONV_TIPOS t WITH (NOLOCK) ON c.Id_TpoConv = t.Id_TpoConv 
										AND t.TZ_LOCK = 0
INNER JOIN PRODUCTOS p WITH (NOLOCK) ON pc.PRODUCTO = p.C6250 
									AND p.TZ_LOCK = 0 
									AND p.C6800 = ''AH''
INNER JOIN TOPESPRODUCTO tp WITH (NOLOCK) ON p.C6250 = tp.CODPRODUCTO 
										AND tp.MONEDA = 1 
										AND tp.TZ_LOCK = 0
INNER JOIN CRE_PRODUCTOSCANALDIGITAL can WITH (NOLOCK) ON p.C6250 = can.PRODUCTO 
														AND can.CANAL_PRESENCIAL = ''S'' 
														AND can.HABILITADO = ''S'' 
														AND can.TZ_LOCK = 0
LEFT JOIN CRE_AUX_SOL_CALCULO_ADELANTO ca WITH (NOLOCK) ON p.C6250 = ca.PRODUCTO 
														AND c.ID_ConvPago = ca.CONVENIO 
														AND s.C1803 = ca.CLIENTE 
														AND vc.ID_JURISDICCION = ca.ID_JURIDICCION 
														AND can.CANAL = ca.CANAL
WHERE vc.TZ_LOCK = 0
UNION
SELECT
	pc.PRODUCTO AS Producto, 
	p.C6251 AS NombreProducto, 
	vc.ID_CONVENIO AS Convenio,
	c.NomConvPago AS NombreConvenio,
	s.SUCURSAL AS SucursalCuenta,
	suc.NOMBRESUCURSAL AS NombreSucursal, 
	s.CUENTA AS Cuenta,
	CASE WHEN s.C1651 = ''1'' THEN ''Cuenta Cerrada'' 
	ELSE ''Cuenta Activa'' 
	END AS EstadoCuenta,
	''Sin Firmar'' AS ContratoMarco,
	vc.ID_BENEFICIO AS Beneficio,
	t.TpoContrato AS TipoContrato,
	id_persona AS pf,
	s.JTS_OID,
	isnull(ca.MONTO_CALCULADO,0) AS MontoCalculado,
	pc.CANT_SUELDO AS CantidadSueldo,
	vc.ID_JURISDICCION AS Jurisdiccion,
	tp.TIPO_SCORING AS TipoScoring,
	pc.PORC_AFECTACION AS Afectacion,
	can.CANAL,
	isnull(ca.CAPACIDAD_PAGO,0) AS CapacidadPago,
	can.PORCENTAJE_AFECTACION AS AfectacionCanal,
	s.C1803 AS Cliente,
	c.Id_TpoConv AS TipoConvenio,
	tp.LINEA_SCORING AS LineaScoring
FROM CRE_VINCULACIONES_CONVENIOS vc  WITH (NOLOCK)
INNER JOIN SALDOS s  WITH (NOLOCK)ON vc.JTS_CV = s.JTS_OID 
								AND s.TZ_LOCK = 0 
								AND s.C1785 IN (2,3)
INNER JOIN SUCURSALES suc  WITH (NOLOCK)ON s.SUCURSAL = suc.SUCURSAL 
										AND suc.TZ_LOCK = 0
INNER JOIN CONV_CONVENIOS_PAG c WITH (NOLOCK) ON vc.ID_CONVENIO = c.ID_ConvPago AND c.TZ_LOCK=0
INNER JOIN CONV_TIPOS t ON c.Id_TpoConv = t.Id_TpoConv 
						AND t.TZ_LOCK = 0
INNER JOIN CRE_PROD_CONVENIOS pc WITH (NOLOCK) ON t.TpoContrato = pc.DATO_TIPO 
											AND pc.TIPO = ''G'' 
											AND pc.HABILITADO = ''S'' 
											AND pc.TZ_LOCK = 0
INNER JOIN PRODUCTOS p WITH (NOLOCK) ON pc.PRODUCTO = p.C6250 
						AND p.TZ_LOCK = 0 
						AND p.C6800 = ''AH''
INNER JOIN TOPESPRODUCTO tp WITH (NOLOCK) ON p.C6250 = tp.CODPRODUCTO 
											AND tp.MONEDA = 1 
											AND tp.TZ_LOCK = 0
INNER JOIN  CRE_PRODUCTOSCANALDIGITAL can WITH (NOLOCK) ON p.C6250 = can.PRODUCTO 
								AND can.CANAL_PRESENCIAL = ''S'' 
								AND can.HABILITADO = ''S'' 
								AND can.TZ_LOCK = 0
LEFT JOIN CRE_AUX_SOL_CALCULO_ADELANTO ca WITH (NOLOCK) ON p.C6250 = ca.PRODUCTO 
														AND c.ID_ConvPago = ca.CONVENIO 
														AND s.C1803 = ca.CLIENTE 
														AND vc.ID_JURISDICCION = ca.ID_JURIDICCION 
														AND can.CANAL = ca.CANAL
')