EXECUTE('delete from TTR_CODIGO_TRANSACCION_INFO_EXTENDIDA where infoExtendidaTipo = 15;');
EXECUTE('
INSERT INTO TTR_CODIGO_TRANSACCION_INFO_EXTENDIDA (codigoTransaccion,infoExtendidaTipo,descripcion,TZ_LOCK) VALUES
	 (5,15,N''Deposito Cheque por Caja'',0),
	 (6,15,N''Depósito Cheque por Atm'',0),
	 (7,15,N''Depósito Cheque por Cámara'',0),
	 (8,15,N''Depósito Cheque Negociado'',0),
	 (11,15,N''Pago Cheque por Caja'',0),
	 (12,15,N''Crédito Depósito Cheque Cámara'',0),
	 (13,15,N''Rechazo de Cheque'',0),
	 (14,15,N''Rechazo de Cheque'',0),
	 (40,15,N''Crédito Cheque Certificado'',0),
	 (42,15,N''Débito Cheque Certificado'',0),
	 (43,15,N''Venta de Cheques Cancelatorios'',0),
	 (44,15,N''Pago de Cheque Cancelatorio'',0),
	 (85,15,N''Crédito Reserva Cheque Certificado'',0),
	 (87,15,N''Pago Cheque de Camara'',0),
	 (88,15,N''Rechazo Pago Cheque de Camara'',0),
	 (91,15,N''Depósito Cheque De Terceros'',0),
	 (98,15,N''Comisión Cheque Rechazado'',0),
	 (99,15,N''Rechazo Depósito Cheque Cámara'',0),
	 (3018,15,N''Débito Caída Cheque Propio'',0),
	 (3019,15,N''Crédito Caída Cheque Propio'',0),
	 (3020,15,N''Débito Cheque Propio Descontado'',0);
');
