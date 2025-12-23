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
    a.HORAFIN fechaHoraReloj,
    h.DEBITO_CREDITO operacion, 
    h.MONTO monto, 
    case when h.DEBITO_CREDITO = ''D'' then -h.monto else h.monto end importe,
    COALESCE(SALDO_AJUSTADO, 0)  + 
    SUM(case when h.DEBITO_CREDITO = ''D'' then -h.monto else h.monto end ) OVER (PARTITION BY h.FECHA_VALOR ORDER BY h.FECHA_VALOR, h.MOV_JTS_OID) AS saldoParcial,
    CASE WHEN h.CODIGO_TRANSACCION = 0 then h.CONCEPTO ELSE codTtr.DESCRIPCION END concepto,
    a.OPERACION nroOperacion, 
    h.CODIGO_TRANSACCION codTransaccion, 
    h.ASIENTO comprobante,
    dbo.diaHabil(h.fecha_Valor - 1, ''D'') fechaSaldo, 
    COALESCE(SALDO_AJUSTADO, 0) saldoDiario,    
    case when mon.C6403 = ''I'' then ctz.cotBcra else null end cotizacion,
    hm.infoExtendida detalle,
    hm.infoExtendidaMeta detMeta

    from HISTORIA_VISTA h WITH (NOLOCK)
    inner join ASIENTOS A WITH (NOLOCK) on H.ASIENTO = A.ASIENTO and H.SUCURSAL = A.SUCURSAL and H.FECHA_PROCESADO = A.FECHAPROCESO 
    left join HISTORICO_MOVIMIENTOS hm WITH (NOLOCK) on h.MOV_JTS_OID = hm.movJtsOid and h.FECHA_PROCESADO = hm.fechaAsiento and DATETRUNC(day,A.HORAFIN) = hm.fechaReloj  
    inner join saldos s WITH (NOLOCK) on s.JTS_OID = h.SALDO_JTS_OID 
    left join TTR_CODIGO_TRANSACCION_DEF codTtr WITH (NOLOCK) ON h.CODIGO_TRANSACCION = codTtr.CODIGO_TRANSACCION
    left JOIN STRING_SPLIT(@P_ttr, '','') AS ttr ON ttr.value = h.CODIGO_TRANSACCION
    left join GRL_SALDOS_DIARIOS sal WITH (NOLOCK) on sal.fecha = dbo.diaHabil(h.fecha_Valor - 1, ''D'') and h.SALDO_JTS_OID = sal.SALDOS_JTS_OID
    left join VW_NBCH24_GRL_COTIZACIONES ctz WITH (NOLOCK) on h.FECHA_VALOR = ctz.fecha and ctz.codigo = s.moneda --fecha de cotizacion para UVA
    left join monedas mon on ctz.codigo = mon.C6399
    where a.ESTADO = 77 and h.MONTO > 0 

    and 
    ((h.SALDO_JTS_OID = @P_jtsoid and cast(h.FECHA_PROCESADO as Date) BETWEEN @P_fechaDesde and @P_fechaHasta and @P_filter = ''*PROC'') 
    or 
    (h.SALDO_JTS_OID = @P_jtsoid and cast(a.HORAFIN as Date)  BETWEEN @P_fechaDesde and @P_fechaHasta and @P_filter = ''*TIME'') )

    and  (@P_ttr IS NULL OR ttr.value IS NOT NULL) --si @p_ttr es null incluye todos los codigos de transaccion 
    and (@P_fv <> ''S'' OR h.FECHA_VALOR < h.FECHA_PROCESADO)
    order by h.FECHA_VALOR desc, a.HORAFIN desc
    OFFSET (@P_pagina - 1) * @P_cantidad ROWS
    FETCH NEXT @P_cantidad ROWS ONLY
END;
');

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
	s.C1679 estado, 
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
	case when s.C1679 = ''1'' then ''S'' else ''N'' end bloqueoCuenta, 	
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
