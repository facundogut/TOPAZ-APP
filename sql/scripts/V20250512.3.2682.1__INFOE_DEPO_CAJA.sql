EXECUTE('
	INSERT INTO dbo.TTR_CODIGO_PROGRAMA_TRANSACCION (codigoPrograma,nombrePrograma,descripcion,TZ_LOCK,estado,formato) VALUES
	 (22,''MP_INFO_EXTENDIDA_DEPOSITO_CAJA'',''Depósitos por Caja OPE 3508'',0,0,15);
');

EXECUTE('
	INSERT INTO dbo.TTR_CODIGO_TRANSACCION_INFO_EXTENDIDA (codigoTransaccion,infoExtendidaTipo,descripcion,TZ_LOCK) VALUES
	 (3,22,''Deposito Efectivo por Caja'',0);
');
