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
	       999999999999999 limiteEmision, 
	       count(cc.NUMEROCHEQUE) usados 
	from CHE_CHEQUERAS ch 
	left join CHE_CHEQUES cc on ch.sucursal = cc.sucursal and ch.cuenta = cc.cuenta and   ((cc.NUMEROCHEQUE >= ch.CHEQUEDESDE) and (cc.NUMEROCHEQUE <= ch.CHEQUEHASTA))
	and ch.producto = cc.PRODUCTO and ch.moneda = cc.MONEDA
	where ch.estado = ''A'' and ch.SERIE = ''E'' and ch.tz_lock = 0 
	group by ch.NROSOLICCHEQ,  ch.CHEQUEDESDE,    ch.CHEQUEHASTA,    ch.PRODUCTO, ch.sucursal,   ch.cuenta),
	
	disponibles as (select producto, sucursal, cuenta, sum(cantCheques - usados) chequesDisponibles, max(limiteEmision)  limiteEmision from libretas 
	GROUP by producto, SUCURSAL, CUENTA)
	
	select s.jts_oid, s.sucursal, s.cuenta, s.producto, coalesce(d.chequesDisponibles, 0) chequesDisponibles, coalesce(d.limiteEmision, 999999999999999) limiteEmision,
	case when s.permite_echeq = ''S'' then ''S'' else ''N'' end emiteEcheq, 
	case when tp.ACEPTA_ECHEQ = ''S'' then ''S'' else ''N'' end depositaEcheq from saldos s 
	left join disponibles d  on d.producto = s.producto and d.sucursal = s.sucursal and d.cuenta = s.cuenta 
	left join topesproducto tp on tp.codproducto = s.producto and tp.moneda = s.moneda
');
