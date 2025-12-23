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
 	ccp.numeropersona idPersonaTitular, 
	acv.documentoTitular documentoTitular,
	s.C1679 estado, 
	S.C1604 saldo, 
	(S.C1604 + S.C1605 + S.C1683 + S.C2627) saldoDisponible,
	(s.C1605 + s.C2627) saldoBloqueado,
	s.C1606 saldo24hs,
	s.C1607 saldo48hs,
	v.CTA_CBU cbu,
	case when acv.tipoPoder = 50 then ''F'' else ''A'' end rol, 
	acv.fechaFinPoder fechaInicioPoder, 
	acv.fechaFinPoder fechaFinPoder, 
	case when s.C1679 = ''1'' then ''S'' else ''N'' end bloqueoCuenta, 	
	acv.documentoUsuario documentoUsuario,
	CASE WHEN EXISTS (select 1 from PYF_APODERADOS pTrf WITH (NOLOCK) where acv.jts_oid = pTrf.ID_ENTIDAD and acv.idPersonaUsuario = pTrf.ID_PERSONA and pTrf.TIPO_ENTIDAD = 2 and pTrf.TIPO_PODER = 5) THEN ''S'' ELSE ''N'' END poderTRF, --poder de transferencia de fondos
	CASE WHEN EXISTS (select 1 from PYF_APODERADOS pTj WITH (NOLOCK) where acv.jts_oid = pTj.ID_ENTIDAD and acv.idPersonaUsuario = pTj.ID_PERSONA and pTj.TIPO_ENTIDAD = 2 and pTj.TIPO_PODER = 43) THEN ''S'' ELSE ''N'' END poderTJD, --poder TJD
	acv.documentoContexto documentoContexto,
	em.EMAIL email 	
	from  saldos s WITH (NOLOCK)
	inner join VTA_SALDOS v WITH (NOLOCK) on s.JTS_OID = v.JTS_OID_SALDO
	inner join productos p WITH (NOLOCK) on s.producto = p.C6250	
	inner join CLI_ClientePersona ccp WITH (NOLOCK) on ccp.codigocliente = s.c1803 	
		inner join WV_NBCH24_ACCESOSCV acv on s.jts_oid = acv.jts_oid and ccp.NumeroPersona = acv.idPersonaTitular
	inner join CLI_CLIENTES c WITH (NOLOCK) on c.CODIGOCLIENTE = s.c1803 
	inner join monedas m WITH (NOLOCK) on s.MONEDA = m.c6399
	left join GRL_ESTADOS_DE_CUENTA ec on ec.JTSOID = s.JTS_OID and ec.correo_tradicional = ''S'' and ec.TZ_LOCK=0
	left join CLI_EMAILS em on em.FORMATO = ec.FORMATO_MAIL  and em.TIPO = ec.TIPO_MAIL and em.ORDINAL = ec.ORDINAL_MAIL  and em.ID = ccp.numeropersona and  ec.jtsoid = s.jts_oid	
	and s.C1785 = 2 	
	and v.TZ_LOCK = 0
	and s.TZ_LOCK = 0 and s.c1651 in ('''', '' '', ''0'', null) --codigo cancelacion
	and p.tz_lock = 0	
	and c.TZ_LOCK = 0
	and ccp.TZ_LOCK = 0 
	where (c.SUBDIVISION1 not in (''02'')  or (s.PRODUCTO in (9, 10))) -- excluye clientes sector publico, excepto cuentas DJ 
');

EXECUTE('
CREATE OR ALTER PROCEDURE [dbo].[SP_NBCH24_MOVIMIENTOS]
    @P_jtsoid numeric(15, 0),
    @P_fechaDesde datetime,
    @P_fechaHasta datetime,
    @P_pagina integer, 
    @P_cantidad integer,
    @P_ttr nvarchar(MAX) = NULL,
    @P_fv char(1),
    @P_filter char(5)
AS
BEGIN

    SET NOCOUNT ON;

    Select 
    h.MOV_JTS_OID id,
    h.SALDO_JTS_OID jts_oid, 
    h.FECHA_VALOR fechaValor,
    h.FECHA_PROCESADO fechaProceso, 
    a.HORAFIN fechaHoraReloj ,
    h.DEBITO_CREDITO operacion, 
    h.MONTO monto, 
    case when DEBITO_CREDITO = ''D'' then -h.monto else h.monto end importe,
    COALESCE(SALDO_AJUSTADO, 0)  + 
    SUM(case when DEBITO_CREDITO = ''D'' then -h.monto else h.monto end ) OVER (PARTITION BY h.FECHA_VALOR ORDER BY h.FECHA_VALOR, h.MOV_JTS_OID) AS saldoParcial,
    h.CONCEPTO concepto,
    a.OPERACION nroOperacion, 
    h.CODIGO_TRANSACCION codTransaccion, 
    h.ASIENTO comprobante,
    dbo.diaHabil(h.fecha_Valor - 1, ''D'') fechaSaldo, 
    COALESCE(SALDO_AJUSTADO, 0) saldoDiario,
    COALESCE(ctz.cotBcra, 0) cotizacion,
    hm.infoExtendida detalle
    from HISTORIA_VISTA h WITH (NOLOCK)
    inner join ASIENTOS A WITH (NOLOCK) on H.ASIENTO = A.ASIENTO and H.SUCURSAL = A.SUCURSAL and H.FECHA_PROCESADO = A.FECHAPROCESO 
    left join HISTORICO_MOVIMIENTOS hm WITH (NOLOCK) on h.MOV_JTS_OID = hm.movJtsOid  
    inner join saldos s WITH (NOLOCK) on s.JTS_OID = h.SALDO_JTS_OID 
    left JOIN STRING_SPLIT(@P_ttr, '','') AS ttr ON ttr.value = h.CODIGO_TRANSACCION
    left join GRL_SALDOS_DIARIOS sal WITH (NOLOCK) on sal.fecha = dbo.diaHabil(h.fecha_Valor - 1, ''D'') and h.SALDO_JTS_OID = sal.SALDOS_JTS_OID
    left join VW_NBCH24_GRL_COTIZACIONES ctz WITH (NOLOCK) on h.FECHA_VALOR = ctz.fecha and ctz.codigo = s.moneda --fecha de cotizacion para UVA
    where a.ESTADO = 77 and h.MONTO > 0 
    and 
    ((h.SALDO_JTS_OID = @P_jtsoid and cast(h.FECHA_PROCESADO as Date) BETWEEN @P_fechaDesde and @P_fechaHasta and @P_filter = ''*PROC'') 
    or 
    (h.SALDO_JTS_OID = @P_jtsoid and cast(a.HORAFIN as Date)  BETWEEN @P_fechaDesde and @P_fechaHasta and @P_filter = ''*TIME'') )
    and  (@P_ttr IS NULL OR ttr.value IS NOT NULL) --si @p_ttr es null incluye todos los codigos de transaccion 
    and (@P_fv <> ''S'' OR h.FECHA_VALOR < h.FECHA_PROCESADO)
    order by h.FECHA_VALOR, a.HORAFIN 
    OFFSET (@P_pagina - 1) * @P_cantidad ROWS
    FETCH NEXT @P_cantidad ROWS ONLY
END;
');
