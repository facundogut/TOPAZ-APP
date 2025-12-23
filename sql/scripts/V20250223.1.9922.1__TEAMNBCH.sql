EXEC('DROP INDEX IF EXISTS scoring_prestamos ON SALDOS;');

EXEC('CREATE NONCLUSTERED INDEX [scoring_prestamos] ON [dbo].[SALDOS]  ( [TZ_LOCK], [C1785]) INCLUDE  (	[C1803], 	[JTS_OID] );');

EXEC('
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
	       999999999999999 limiteEmision, 
	       count(*) usados 
	from CHE_CHEQUERAS ch 
	inner join CHE_CHEQUES cc on ch.sucursal = cc.sucursal and ch.cuenta = cc.cuenta and   ((cc.NUMEROCHEQUE >= ch.CHEQUEDESDE) and (cc.NUMEROCHEQUE <= ch.CHEQUEHASTA))
	and ch.producto = cc.PRODUCTO and ch.moneda = cc.MONEDA
	where ch.estado = ''A'' and ch.SERIE = ''E'' and ch.tz_lock = 0 
	group by ch.NROSOLICCHEQ,  ch.CHEQUEDESDE,    ch.CHEQUEHASTA,    ch.PRODUCTO, ch.sucursal,   ch.cuenta),
	
	disponibles as (select producto, sucursal, cuenta, sum(cantCheques - usados) chequesDisponibles, max(limiteEmision)  limiteEmision from libretas 
	GROUP by producto, SUCURSAL, CUENTA)
	
	select s.jts_oid, s.sucursal, s.cuenta, s.producto, coalesce(d.chequesDisponibles, 0) chequesDisponibles, coalesce(d.limiteEmision, 999999999999999) limiteEmision,
	case when s.permite_echeq = ''S'' then ''S'' else ''N'' end emiteEcheq, 
	case when tp.ACEPTA_ECHEQ = ''S'' then ''S'' else ''N'' end depositaEcheq from saldos s 
	left join disponibles d  on d.producto = s.producto and d.sucursal = s.sucursal and d.cuenta = s.cuenta 
	left join topesproducto tp on tp.codproducto = s.producto and tp.moneda = s.moneda;
	
');

EXEC('
CREATE OR ALTER VIEW dbo.VW_NBCH24_CRE_SCORING
AS

SELECT 
vc.JTS_CV jtsCV,
p.C6250 AS linea, 
p.C6251 AS descripcion,
case when (pc.MONTO_MINIMO = 0) then pc.MONTO_MINIMO + 1000 else pc.MONTO_MINIMO end AS montoMinimo,
SUM(ca.MONTO_CALCULADO) OVER (PARTITION BY p.C6250, doc.CODIGOCLIENTE, vc.JTS_CV ORDER BY p.C6250) AS montoMaximo,
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
LEFT JOIN CRE_AUX_SOL_CALCULO_ADELANTO ca (NOLOCK) ON p.C6250 = ca.PRODUCTO AND c.ID_ConvPago = ca.CONVENIO
                AND s.C1803 = ca.CLIENTE AND vc.ID_JURISDICCION = ca.ID_JURIDICCION and dg.CANAL = ca.CANAL
where vc.TZ_LOCK=0 AND dg.CANAL=''HO'';

');