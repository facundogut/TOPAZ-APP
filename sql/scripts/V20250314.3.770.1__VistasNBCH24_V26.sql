EXECUTE('
CREATE OR ALTER VIEW dbo.VW_NBCH24_CTA_TENENCIA_GENERAL
AS
    SELECT s.JTS_OID jts_oid, 
	acv.idPersonaUsuario idPersonaUsuario,  
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
 	acv.idPersonaTitular idPersonaTitular, 
	acv.documentoTitular documentoTitular,
	acv.documentoUsuario documentoUsuario,
	acv.documentoContexto documentoContexto,
	CASE WHEN s.C1679 IN (''0'', '' '') then ''0'' ELSE ''1'' END estado,
	S.C1604 saldo, 
	(S.C1604 + S.C1605 + S.C1683 + S.C2627) saldoDisponible,
	(s.C1605 + s.C2627) saldoBloqueado,
	v.CTA_CBU cbu,
	CASE WHEN acv.tipoPoder = 50 THEN ''F'' ELSE ''A'' END rol,
	CASE WHEN s.C1679 IN (''0'', '' '') THEN ''N'' ELSE ''S'' END bloqueoCuenta,
	CASE WHEN EXISTS (SELECT 1 FROM PYF_APODERADOS pTrf WITH (NOLOCK) WHERE acv.jts_oid =  pTrf.ID_ENTIDAD2 AND acv.idPersonaUsuario = pTrf.ID_PERSONA AND pTrf.TIPO_ENTIDAD = 2 AND pTrf.TIPO_PODER = 5) THEN ''S'' ELSE ''N'' END poderTRF, --poder de transferencia de fondos 
	CASE WHEN EXISTS (SELECT 1 FROM PYF_APODERADOS pTj WITH (NOLOCK) WHERE acv.jts_oid =  pTj.ID_ENTIDAD2 AND acv.idPersonaUsuario = pTj.ID_PERSONA AND pTj.TIPO_ENTIDAD = 2 AND pTj.TIPO_PODER = 43) THEN ''S'' ELSE ''N'' END poderTJD, --poder TJD
 
    (SELECT em.EMAIL FROM CLI_EMAILS em INNER JOIN GRL_ESTADOS_DE_CUENTA ec ON em.FORMATO = ec.FORMATO_MAIL  AND em.TIPO = ec.TIPO_MAIL AND em.ORDINAL = ec.ORDINAL_MAIL  
	AND em.ID = acv.idPersonaTitular WHERE ec.PRODUCTO = s.PRODUCTO AND ec.SUCURSAL = s.SUCURSAL AND ec.CUENTA = s.CUENTA AND ec.MONEDA = s.MONEDA AND ec.TIPO_EMISION = ''N'' AND 
	ec.OPERACION = 0 AND ec.ORDINAL = 0 ) email
	
	FROM  saldos s WITH (NOLOCK)
	INNER JOIN VTA_SALDOS v WITH (NOLOCK) ON s.JTS_OID = v.JTS_OID_SALDO
	INNER JOIN productos p WITH (NOLOCK) ON s.producto = p.C6250	
	INNER JOIN VW_NBCH24_ACCESOSCV acv ON s.jts_oid = acv.jts_oid 
	INNER JOIN CLI_CLIENTES c WITH (NOLOCK) ON c.CODIGOCLIENTE = s.c1803 
	INNER JOIN monedas m WITH (NOLOCK) ON s.MONEDA = m.c6399

	WHERE v.TZ_LOCK = 0 AND s.TZ_LOCK = 0 
	AND s.c1651 IN ('''', '' '', ''0'', null) --codigo cancelacion
	AND s.C1785 in (2, 3) AND p.tz_lock = 0 AND c.TZ_LOCK = 0;
');
