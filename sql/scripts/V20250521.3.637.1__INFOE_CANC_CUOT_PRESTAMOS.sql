EXECUTE('
	delete from TTR_CODIGO_TRANSACCION_INFO_EXTENDIDA where codigoTransaccion = 3017;
');

EXECUTE('
	delete from TTR_CODIGO_PROGRAMA_TRANSACCION where codigoPrograma = 23;
');

EXECUTE('
	INSERT INTO TTR_CODIGO_PROGRAMA_TRANSACCION (codigoPrograma,nombrePrograma,descripcion,TZ_LOCK,estado,formato) VALUES
	 (23,''MP_INFO_EXTENDIDA_CANC_CUOT_PRESTAMOS'',''Programa de Cancelación de Cuotas para Prestamos.'',0,0,16);
');

EXECUTE('
	INSERT INTO TTR_CODIGO_TRANSACCION_INFO_EXTENDIDA (codigoTransaccion,infoExtendidaTipo,descripcion,TZ_LOCK) VALUES
	 (3017,23,''Info Extendida para Débitos de Cuotas por Prestamos.'',0);
');
