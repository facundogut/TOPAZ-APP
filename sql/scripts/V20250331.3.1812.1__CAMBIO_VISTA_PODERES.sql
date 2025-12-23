EXECUTE('
CREATE OR ALTER VIEW dbo.VW_NBCH24_CTA_TENENCIA_GENERAL
AS
    SELECT s.JTS_OID jts_oid, 
	s.PRODUCTO producto, 
	p.C6251 productoDescripcion,
	s.C1785 modulo, 
	s.SUCURSAL sucursal, 
	s.CUENTA cuenta, 
	s.moneda moneda,
	m.C6400 descripcionMoneda, 
	m.c6401 signoMoneda, 
	m.c6440 cotBcra, 
	s.c1803 cliente, 
	c.SUBDIVISION1 sector,
	CASE WHEN s.C1679 IN (''0'', '' '') then ''0'' ELSE ''1'' END estado,
	S.C1604 saldo, 
	(S.C1604 + S.C1605 + S.C1683 + S.C2627) saldoDisponible,
	(s.C1605 + s.C2627) saldoBloqueado,
	v.CTA_CBU cbu
	
	FROM  saldos s WITH (NOLOCK)
	INNER JOIN VTA_SALDOS v WITH (NOLOCK) ON s.JTS_OID = v.JTS_OID_SALDO
	INNER JOIN productos p WITH (NOLOCK) ON s.producto = p.C6250
	INNER JOIN CLI_CLIENTES c WITH (NOLOCK) ON c.CODIGOCLIENTE = s.c1803 
	INNER JOIN monedas m WITH (NOLOCK) ON s.MONEDA = m.c6399

	WHERE v.TZ_LOCK = 0 AND s.TZ_LOCK = 0 
	AND s.c1651 IN ('''', '' '', ''0'', null) --codigo cancelacion
	AND s.C1785 in (2, 3) AND p.tz_lock = 0 AND c.TZ_LOCK = 0;
');