EXECUTE('
CREATE OR ALTER VIEW dbo.VW_NBCH24_CTA_TENENCIA
AS
    select s.JTS_OID jts_oid, 
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
	--s.C1679 estado, 
	CASE WHEN s.C1679 IN (''0'', '' '') then ''0'' else ''1'' end estado,
	S.C1604 saldo, 
	(S.C1604 + S.C1605 + S.C1683 + S.C2627) saldoDisponible,
	(s.C1605 + s.C2627) saldoBloqueado,
	--s.C1606 saldo24hs,
	0 saldo24hs,
	--s.C1607 saldo48hs,
	0 saldo48hs,
	v.CTA_CBU cbu,
	case when acv.tipoPoder = 50 then ''F'' else ''A'' end rol, 
	acv.fechaFinPoder fechaInicioPoder, 
	acv.fechaFinPoder fechaFinPoder, 
	--case when s.C1679 = ''1'' then ''S'' else ''N'' end bloqueoCuenta, 
	CASE WHEN s.C1679 IN (''0'', '' '') then ''N'' else ''S'' end bloqueoCuenta,
	acv.documentoUsuario documentoUsuario,
	CASE WHEN EXISTS (select 1 from PYF_APODERADOS pTrf WITH (NOLOCK) where acv.jts_oid =  pTrf.ID_ENTIDAD2 and acv.idPersonaUsuario = pTrf.ID_PERSONA and pTrf.TIPO_ENTIDAD = 2 and pTrf.TIPO_PODER = 5) THEN ''S'' ELSE ''N'' END poderTRF, --poder de transferencia de fondos
	COALESCE((LEN(f.formula) - LEN(REPLACE(f.formula, ''A'', ''''))), 0) ordenTRF, 
	CASE WHEN EXISTS (select 1 from PYF_APODERADOS pTj WITH (NOLOCK) where acv.jts_oid =  pTj.ID_ENTIDAD2 and acv.idPersonaUsuario = pTj.ID_PERSONA and pTj.TIPO_ENTIDAD = 2 and pTj.TIPO_PODER = 43) THEN ''S'' ELSE ''N'' END poderTJD, --poder TJD
	acv.documentoContexto documentoContexto,
 
    (select em.EMAIL from CLI_EMAILS em inner join GRL_ESTADOS_DE_CUENTA ec on em.FORMATO = ec.FORMATO_MAIL  and em.TIPO = ec.TIPO_MAIL and em.ORDINAL = ec.ORDINAL_MAIL  
	and em.ID = acv.idPersonaTitular where ec.PRODUCTO = s.PRODUCTO and ec.SUCURSAL = s.SUCURSAL and ec.CUENTA = s.CUENTA and ec.MONEDA = s.MONEDA and ec.TIPO_EMISION = ''N'' and 
	ec.OPERACION = 0 and ec.ORDINAL = 0 ) email
	
	from  saldos s WITH (NOLOCK)
	inner join VTA_SALDOS v WITH (NOLOCK) on s.JTS_OID = v.JTS_OID_SALDO
	inner join productos p WITH (NOLOCK) on s.producto = p.C6250	
	inner join VW_NBCH24_ACCESOSCV acv on s.jts_oid = acv.jts_oid 
	inner join CLI_CLIENTES c WITH (NOLOCK) on c.CODIGOCLIENTE = s.c1803 
	inner join monedas m WITH (NOLOCK) on s.MONEDA = m.c6399
	left join PYF_FORMULAS f on CONVERT(VARCHAR(10), s.jts_oid) = f.id_entidad  and f.TIPO_ENTIDAD = 2 and f.tipo_poder = 5

	where (c.SUBDIVISION1 not in (''02'')  or (s.PRODUCTO in (9, 10))) -- excluye clientes sector publico, excepto cuentas DJ 
	and v.TZ_LOCK = 0
	and s.TZ_LOCK = 0 and s.c1651 in ('''', '' '', ''0'', null) --codigo cancelacion
	and s.C1785 in (2, 3)
	and p.tz_lock = 0	
	and c.TZ_LOCK = 0;
');