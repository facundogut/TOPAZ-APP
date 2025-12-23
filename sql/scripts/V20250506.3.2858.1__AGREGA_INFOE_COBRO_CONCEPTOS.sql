EXECUTE('
	drop index if exists Indice_36_35 on dbo.PLANCTAS;
	drop index if exists INFOE_DIAVOLO on dbo.PLANCTAS;
');

EXECUTE('
	create nonclustered index INFOE_DIAVOLO on dbo.PLANCTAS (TZ_LOCK, C6301) include (C6300);
');

EXECUTE('
	delete from TTR_CODIGO_TRANSACCION_INFO_EXTENDIDA where codigoTransaccion = 54;
');

EXECUTE('
	delete from TTR_CODIGO_PROGRAMA_TRANSACCION where codigoPrograma = 21;
');

EXECUTE('
	insert into TTR_CODIGO_PROGRAMA_TRANSACCION (codigoPrograma,nombrePrograma,descripcion,TZ_LOCK,estado,formato) 
		values (21,''MP_INFO_EXTENDIDA_COBRO_CONCEPTOS'',''Debitos - Cobro de Conceptos OPE 3587'',0,0,14);
');

EXECUTE('
	insert into TTR_CODIGO_TRANSACCION_INFO_EXTENDIDA (codigoTransaccion,infoExtendidaTipo,descripcion,TZ_LOCK)
		values (54,21,''Cobro de Conceptos OPE 3587'',0);
');

