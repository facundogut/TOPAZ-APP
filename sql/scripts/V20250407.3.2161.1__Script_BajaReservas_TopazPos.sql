EXECUTE('
	UPDATE VTA_RESERVAS 
	SET TZ_LOCK = 399999920250704 
	where TIPO_RESERVA=4 and TZ_LOCK=0 and SALDO_JTS_OID_ORIGEN=0 and ESTADO = 1;
');

EXECUTE('
	with reservas as (
		SELECT r.SALDO_JTS_OID jts, sum(r.importe_origen) totReservas
		FROM VTA_RESERVAS r 
		WHERE r.estado = 1 and r.TZ_LOCK = 399999920250704 and r.TIPO_RESERVA = 4 and SALDO_JTS_OID_ORIGEN=0
		GROUP BY SALDO_JTS_OID
	)
	UPDATE ss 
	SET ss.c2627 = ss.c2627 + totReservas
	FROM SALDOS ss inner join reservas on jts= ss.JTS_OID;
');
