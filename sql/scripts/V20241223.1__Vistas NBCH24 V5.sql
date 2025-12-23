execute('
DROP INDEX IF EXISTS IX_PYF_APODERADOS_NBCH2401 ON dbo.PYF_APODERADOS;
DROP INDEX IF EXISTS IX_SALDOS_NBCH2401 ON dbo.SALDOS;
DROP INDEX IF EXISTS IX_GRL_ESTADOS_DE_CUENTA_NBCH2401 ON dbo.GRL_ESTADOS_DE_CUENTA;
DROP INDEX IF EXISTS IDX_NBCH24_PYF_APODERADOS_01 ON dbo.PYF_APODERADOS;
DROP VIEW IF EXISTS dbo.WV_NBCH24_ACCESOSCV;
');

execute('
CREATE OR ALTER VIEW dbo.VW_NBCH24_ACCESOSCV
AS
select 
    pa.id_entidad jts_oid, 
    s.C1785 modulo, 
	s.SUCURSAL sucursal, 
	s.CUENTA cuenta, 
	pa.ID_PERSONA idPersonaUsuario,  
	docp.numerodocumento documentoUsuario,
	pa.tipo_poder tipoPoder, 
	pa.FECHA_INI_VIGENCIA fechaInicioPoder, 
	pa.FECHA_VENCIMIENTO fechaFinPoder,
	ccp.numeropersona idPersonaTitular ,
	doct.numerodocumento documentoTitular, 
	case when(s.PRODUCTO = 9 or s.PRODUCTO = 10) then docp.numerodocumento else doct.numerodocumento end documentoContexto
from dbo.saldos s WITH (NOLOCK)
inner join dbo.PYF_APODERADOS pa WITH (NOLOCK) on pa.id_entidad = s.jts_oid
inner join dbo.cli_documentospfpj docp WITH (NOLOCK) on pa.ID_PERSONA = docp.NUMEROPERSONAFJ
inner join dbo.CLI_ClientePersona ccp WITH (NOLOCK) on ccp.codigocliente = s.c1803 and ccp.TITULARIDAD = ''T''
inner join dbo.cli_documentospfpj doct WITH (NOLOCK) on ccp.numeropersona = doct.NUMEROPERSONAFJ
where pa.tipo_poder in(50, 51)
	and pa.tipo_Entidad = 2 and 
	s.C1785 in (2, 3) 
');

execute('
CREATE OR ALTER VIEW dbo.VW_NBCH24_DPF_TENENCIA
AS

SELECT 
cast(s.sucursal as varchar) + ''-'' + cast(s.operacion as varchar) + ''-'' + cast(s.C1800 as varchar) id,
s.PRODUCTO producto, 
s.sucursal, 
s.cuenta, 
s.moneda mon, 
s.operacion, 
p.C6251 descripcion,
s.c1800 canal, 
s.MONEDA moneda, 
s.C1621 fechaAlta, 
s.C1627 fechaVenc, 
CASE WHEN (t.PLAZOMINCANC > 0) THEN DATEADD(day, t.PLAZOMINCANC, s.C1621) ELSE null END AS fechaMinPrecanc,
abs(DATEDIFF( DAY, s.C1627, s.C1621)) plazo, 
s.c1601 capital, 
s.C1604 saldo, 
s.C1608 interes, 
s.c1600 montoOriginal, 
s.c1601 + s.C1608  montoCobrar,
(select COALESCE(ctz.cotBcra, 0) from VW_NBCH24_GRL_COTIZACIONES ctz WITH (NOLOCK) where s.C1621  = ctz.fecha and ctz.codigo = s.MONEDA) cotizacionOriginal, --fecha de cotizacion para UVA
mon.c6440 cotizacionActual,
s.C1659 accionVenc, 
(select opc.DESCRIPCION from OPCIONES opc WITH (NOLOCK) where opc.OPCIONDEPANTALLA = s.C1659 and opc.NUMERODECAMPO = 1659 and IDIOMA = ''E'') accionDesc,
s.C1632 tea,
((POWER(1 + s.C1632 / 100.0, 1.0 / 12) - 1) * 12) * 100 AS tna,
(((POWER(1 + s.C1632 / 100.0, 1.0 / 12) - 1) * 12) * 100)  / 12 AS tem,
ps.RETENCION retencion, 

acv.jts_oid jtsCuentaCobro,
acv.modulo moduloCuentaCobro, 
acv.sucursal sucursalCuentaCobro, 
acv.cuenta cuentaCobro,

s.JTS_OID jtsDPF,
s.c1803 cliente, 
acv.idPersonaUsuario idPersonaUsuario, 
acv.documentoUsuario documentoUsuario,
acv.idPersonaTitular idPersonaTitular,
acv.documentoTitular documentoTitular,
acv.documentoContexto documentoContexto

FROM SALDOS s WITH (NOLOCK)
inner join PRODUCTOS p WITH (NOLOCK) on p.C6250 = s.PRODUCTO 
INNER join MONEDAS mon WITH (NOLOCK) on mon.C6399 = s.MONEDA 
inner join PZO_SALDOS ps WITH (NOLOCK) on  ps.JTS_OID_SALDO = s.JTS_OID 
left join TOPESPRODUCTO t  WITH (NOLOCK)  on t.CODPRODUCTO = s.PRODUCTO and t.MONEDA = s.moneda
left join CV_TRANSFERENCIA cvt  WITH (NOLOCK)  on s.C1665 = cvt.JTS_OID_CTA_FUENTE and (mon.C6403 = ''I'') and (s.C1659 <> ''N'')
inner join dbo.VW_NBCH24_ACCESOSCV acv  WITH (NOLOCK)  on acv.jts_oid = (case when cvt.JTS_OID_CTA_DESTINO  is not null then cvt.JTS_OID_CTA_DESTINO   else  s.c1665 end) 
WHERE s.C1785=4  --dpf
and acv.tipoPoder = 50
and (s.C1604 != 0 or s.C1608 != 0) -- activos 
and s.TZ_LOCK  = 0
and p.TZ_LOCK = 0
');

execute('
CREATE OR ALTER VIEW dbo.VW_NBCH24_CRE_TENENCIA
AS

SELECT 
cast(s.sucursal as varchar) + ''-'' + cast(s.operacion as varchar) + ''-'' + cast(s.ordinal as varchar) id,
s.SUCURSAL sucursal, 
s.OPERACION operacion, 
s.ORDINAL ordinal,
S.PRODUCTO producto, 
P.C6251 AS NOMBRE_PRODUCTO, 
p.c6805 tipoTasa, 
S.MONEDA moneda, 
S.C1621 AS fecInicio, 
S.C1627 AS fecVencimiento,
S.C1642*S.C1644 AS plazo, 
S.C1601 AS montoSolicitado, 
S.C1645 AS cuotasPagadas, 
S.C1644-S.C1645 AS cuotasPendientes ,
(SELECT COUNT(C2300) FROM PLANPAGOS WITH (NOLOCK) WHERE SALDO_JTS_OID=S.JTS_OID AND C2302< (SELECT FECHAPROCESO FROM PARAMETROS WITH (NOLOCK)) AND (C2309+C2310>0)) AS cuotasMorosas, 
CASE WHEN s.C1628 < (SELECT FECHAPROCESO FROM PARAMETROS WITH (NOLOCK)) THEN datediff(dd,s.C1628,(SELECT FECHAPROCESO FROM PARAMETROS WITH (NOLOCK)))  ELSE 0 END AS atraso, 
S.C1612 AS montoCuota, 
ABS(S.C1604) AS SALDO,
CASE WHEN  s.C1628 < (SELECT FECHAPROCESO FROM PARAMETROS WITH (NOLOCK)) THEN VAD.SALDO_A_FECHA ELSE 0 END AS mora, 
(C.TASA_CONVERTIDA+C.PUNTOS_CONVERTIDOS) AS TNA, 
S.C1632 AS tea,
C.CFT cft, 
C.CFT_CON_IMPUESTOS cftImpuestos,
s.jts_oid jtsCRE, 
acv.modulo moduloCuentaCobro, 
acv.SUCURSAL sucursalCuentaCobro, 
acv.CUENTA cuentaCobro,
s.C1665 jtsCuentaCobro,
acv.idPersonaUsuario idPersonaUsuario, 
acv.documentoUsuario documentoUsuario,
acv.idPersonaTitular idPersonaTitular,
acv.documentoTitular documentoTitular,
acv.documentoContexto documentoContexto


FROM SALDOS S WITH (NOLOCK)
INNER JOIN PRODUCTOS P WITH (NOLOCK) ON P.C6250=S.PRODUCTO AND P.TZ_LOCK=0
INNER JOIN CRE_SALDOS C WITH (NOLOCK) ON C.SALDOS_JTS_OID=S.JTS_OID AND C.TZ_LOCK=0
inner join VW_NBCH24_ACCESOSCV acv on s.C1665 = acv.jts_oid
INNER JOIN VW_ASISTENCIAS_DEUDA VAD ON VAD.JTS_OID=S.JTS_OID
WHERE S.C1604 < 0 AND S.TZ_LOCK=0
AND S.C1785 = 5  --prestamos 
');

execute('
CREATE OR ALTER VIEW dbo.VW_NBCH24_CTA_TJD(tipo, tarjeta, estado, doc, jts_oid, descripcion, producto, clase, titularidad, primaria, ambito, comprasExterior)
AS
	select ''TJD'', t.ID_TARJETA, t.ESTADO,  docc.numerodocumento, c.saldo_jts_oid, ttt.descripcion, ttt.codigo_producto, ttt.clase, t.titularidad,
	case when c.ESTADO in( ''3'',''R'',''E'') then ''S'' else ''N'' end, --primaria
	case when c.ESTADO = ''3'' then ''NACIONAL'' when c.ESTADO = ''R'' then ''GLOBAL'' when c.ESTADO = ''E'' then ''EXTERIOR''  when c.ESTADO = ''1'' then ''VINCULADA'' else '''' end, --ambito
	case when c.ESTADO IN (''E'',''R'', ''1'', ''3'') then ''S'' else ''N'' end 
	from TJD_TARJETAS t WITH (NOLOCK)
	inner join TJD_TIPO_TARJETA ttt WITH (NOLOCK) on ttt.tipo_tarjeta = t.tipo_Tarjeta
	inner join TJD_REL_TARJETA_CUENTA c WITH (NOLOCK) on t.ID_TARJETA=c.ID_TARJETA
	inner join cli_documentospfpj docc WITH (NOLOCK) on t.nro_persona = docc.NUMEROPERSONAFJ
	where t.ESTADO in (''0'', ''1'', ''8'') and c.ESTADO NOT IN (''9'', ''X'')
	and c.TZ_LOCK = 0
	and docc.TZ_LOCK = 0

	UNION 

	select ''TJV'', caf.NRO_tARJETA, ''1'', doc.numerodocumento, caf.saldo_jts_oid, null, null, null, Null,
	''N'', '' '', ''N''  
	from itf_lk_Caf_cuentas caf WITH (NOLOCK)
	inner join saldos s WITH (NOLOCK) on caf.saldo_jts_oid = s.jts_oid 
	inner join CLI_ClientePersona ccp WITH (NOLOCK) on ccp.CODIGOCLIENTE = s.c1803
	inner join cli_documentospfpj doc WITH (NOLOCK) on doc.numeropersonafj = ccp.numeropersona 
	where estado_Cuenta = ''1''
	and ccp.TZ_LOCK = 0 and ccp.TITULARIDAD = ''T'' 
	and doc.TZ_LOCK = 0
	and caf.NRO_TARJETA not in (select x.ID_TARJETA  from TJD_TARJETAS x WITH (NOLOCK) where x.ESTADO in (''0'', ''1'', ''8''))
');

execute('
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
	s.C1606 saldo24hs,
	s.C1607 saldo48hs,
	v.CTA_CBU cbu,
	case when acv.tipoPoder = 50 then ''F'' else ''A'' end rol, 
	acv.fechaFinPoder fechaInicioPoder, 
	acv.fechaFinPoder fechaFinPoder, 
	case when s.C1679 = ''1'' then ''S'' else ''N'' end bloqueoCuenta, 	
	acv.documentoUsuario documentoUsuario,
	CASE WHEN EXISTS (select 1 from PYF_APODERADOS pTrf WITH (NOLOCK) where acv.jts_oid =  pTrf.ID_ENTIDAD and acv.idPersonaUsuario = pTrf.ID_PERSONA and pTrf.TIPO_ENTIDAD = 2 and pTrf.TIPO_PODER = 5) THEN ''S'' ELSE ''N'' END poderTRF, --poder de transferencia de fondos
	(LEN(formula) - LEN(REPLACE(formula, ''A'', ''''))) ordenTRF, 
	CASE WHEN EXISTS (select 1 from PYF_APODERADOS pTj WITH (NOLOCK) where acv.jts_oid =  pTj.ID_ENTIDAD and acv.idPersonaUsuario = pTj.ID_PERSONA and pTj.TIPO_ENTIDAD = 2 and pTj.TIPO_PODER = 43) THEN ''S'' ELSE ''N'' END poderTJD, --poder TJD
	acv.documentoContexto documentoContexto,
 
    (select em.EMAIL from CLI_EMAILS em inner join GRL_ESTADOS_DE_CUENTA ec on em.FORMATO = ec.FORMATO_MAIL  and em.TIPO = ec.TIPO_MAIL and em.ORDINAL = ec.ORDINAL_MAIL  
	and em.ID = acv.idPersonaTitular where ec.PRODUCTO = s.PRODUCTO and ec.SUCURSAL = s.SUCURSAL and ec.CUENTA = s.CUENTA and ec.MONEDA = s.MONEDA and ec.TIPO_EMISION = ''N'' and 
	ec.OPERACION = 0 and ec.ORDINAL = 0 ) email
	
	from  saldos s WITH (NOLOCK)
	inner join VTA_SALDOS v WITH (NOLOCK) on s.JTS_OID = v.JTS_OID_SALDO
	inner join productos p WITH (NOLOCK) on s.producto = p.C6250	
	inner join VW_NBCH24_ACCESOSCV acv on CONVERT(VARCHAR(10), s.jts_oid) = acv.jts_oid 
	inner join CLI_CLIENTES c WITH (NOLOCK) on c.CODIGOCLIENTE = s.c1803 
	inner join monedas m WITH (NOLOCK) on s.MONEDA = m.c6399
	inner join PYF_FORMULAS f on CONVERT(VARCHAR(10), s.jts_oid) = f.id_entidad  and f.TIPO_ENTIDAD = 2 and f.tipo_poder = 5

	where (c.SUBDIVISION1 not in (''02'')  or (s.PRODUCTO in (9, 10))) -- excluye clientes sector publico, excepto cuentas DJ 
	and v.TZ_LOCK = 0
	and s.TZ_LOCK = 0 and s.c1651 in ('''', '' '', ''0'', null) --codigo cancelacion
	and s.C1785 in (2, 3)
	and p.tz_lock = 0	
	and c.TZ_LOCK = 0
');

execute('
CREATE OR ALTER VIEW dbo.VW_NBCH24_CRE_SCORING
AS

SELECT 
vc.JTS_CV jtsCV,
p.C6250 AS linea, 
p.C6251 AS descripcion, 
pc.MONTO_MINIMO AS montoMinimo,
pc.MONTO_MAXIMO AS montoMaximo,
doc.numerodoc documentoUsuario,
p.C6800 modulo, 
dg.CANAL canal, 
CONCAT(
        CONVERT(VARCHAR(20), vc.ID_CONVENIO), ''-'',
        CONVERT(VARCHAR(20), vc.JTS_CV), ''-'',
        CONVERT(VARCHAR(20), vc.ID_JURISDICCION), ''-'',
        CONVERT(VARCHAR(20), pc.PRODUCTO) , ''-'',
        CONVERT(VARCHAR(20), vc.ID_BENEFICIO) 
    ) AS id

FROM CRE_VINCULACIONES_CONVENIOS vc WITH (NOLOCK)
INNER JOIN SALDOS s WITH (NOLOCK) ON vc.JTS_CV = s.JTS_OID AND s.TZ_LOCK = 0 AND s.C1785 IN (2,3)
INNER JOIN SUCURSALES suc WITH (NOLOCK) ON s.SUCURSAL = suc.SUCURSAL AND suc.TZ_LOCK = 0
INNER JOIN CRE_PROD_CONVENIOS pc WITH (NOLOCK) ON vc.ID_CONVENIO = pc.DATO_TIPO AND pc.TIPO = ''C'' AND pc.HABILITADO = ''S'' 	AND pc.TZ_LOCK = 0
INNER JOIN CONV_CONVENIOS_PAG c WITH (NOLOCK) ON pc.DATO_TIPO = c.ID_ConvPago AND c.TZ_LOCK=0
INNER JOIN CONV_TIPOS t WITH (NOLOCK) ON c.Id_TpoConv = t.Id_TpoConv AND t.TZ_LOCK = 0
INNER JOIN PRODUCTOS p WITH (NOLOCK) ON pc.PRODUCTO = p.C6250 AND p.TZ_LOCK = 0 AND p.C6800 = ''AH''
INNER JOIN CRE_PRODUCTOSCANALDIGITAL dg WITH (NOLOCK) ON dg.PRODUCTO=P.C6250
INNER JOIN VW_CLI_X_DOC doc WITH (NOLOCK) ON doc.CODIGOCLIENTE=s.C1803
where vc.TZ_LOCK=0 AND dg.CANAL=''HO'' 
');

execute('
CREATE OR ALTER VIEW dbo.VW_NBCH24_ECHEQ_CTA(jts_oid, sucursal, cuenta, producto, chequesDisponibles, limiteEmision, emiteEcheq, depositaEcheq)
AS

with libretas as (
select ch.NROSOLICCHEQ nroSolic, 
	   ch.CHEQUEDESDE, 
	   ch.CHEQUEHASTA,
       ch.PRODUCTO,
	   ch.sucursal, 
	   ch.cuenta, 
       max(ch.CANTIDADCHEQUES) cantCheques, 
       COALESCE (max(ch.LIMITE_EMISION), 0) limiteEmision, 
       count(*) usados 
from CHE_CHEQUERAS ch 
inner join CHE_CHEQUES cc on ch.sucursal = cc.sucursal and ch.cuenta = cc.cuenta and   ((cc.NUMEROCHEQUE >= ch.CHEQUEDESDE) and (cc.NUMEROCHEQUE <= ch.CHEQUEHASTA))
and ch.producto = cc.PRODUCTO and ch.moneda = cc.MONEDA
where ch.estado = ''A'' and ch.SERIE = ''E'' and ch.tz_lock = 0 
group by ch.NROSOLICCHEQ,  ch.CHEQUEDESDE,    ch.CHEQUEHASTA,    ch.PRODUCTO, ch.sucursal,   ch.cuenta),

disponibles as (select producto, sucursal, cuenta, sum(cantCheques - usados) chequesDisponibles, max(limiteEmision)  limiteEmision from libretas 
GROUP by producto, SUCURSAL, CUENTA)

select s.jts_oid, s.sucursal, s.cuenta, s.producto, coalesce(d.chequesDisponibles, 0) chequesDisponibles, coalesce(d.limiteEmision, 0) limiteEmision,
case when s.permite_echeq = ''S'' then ''S'' else ''N'' end emiteEcheq, 
case when tp.ACEPTA_ECHEQ = ''S'' then ''S'' else ''N'' end depositaEcheq from saldos s 
left join disponibles d  on d.producto = s.producto and d.sucursal = s.sucursal and d.cuenta = s.cuenta 
left join topesproducto tp on tp.codproducto = s.producto and tp.moneda = s.moneda 
');

execute('
CREATE NONCLUSTERED INDEX [IDX_NBCH24_PYF_APODERADOS_01] ON [dbo].[PYF_APODERADOS]
(
	[TIPO_ENTIDAD] ASC,
	[ID_PERSONA] ASC,
	[TIPO_PODER] ASC
)
INCLUDE([FECHA_VENCIMIENTO],[FECHA_INI_VIGENCIA])
');

