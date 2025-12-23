EXEC('
	DELETE FROM TTR_CODIGO_TRANSACCION_INFO_EXTENDIDA WHERE codigoTransaccion = 304;
	');

EXEC('
	INSERT INTO TTR_CODIGO_TRANSACCION_INFO_EXTENDIDA (codigoTransaccion,infoExtendidaTipo,descripcion,TZ_LOCK) VALUES
		(304,6,''POS: Compra en Comercios'',0);
	');