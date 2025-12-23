EXECUTE('
	drop index if exists IDX_INFOE_DIAVOLO on dbo.SNP_DEBITOS;
	drop index if exists IDX_INFOE_DIAVOLO on dbo.SNP_PRESTACIONES_EMPRESAS;
');

EXECUTE('
	create nonclustered index IDX_INFOE_DIAVOLO on dbo.SNP_DEBITOS (NUMERO_ASIENTO, FECHA_ASIENTO, SUCURSAL_ASIENTO, TZ_LOCK) include (CUIT_EO, NOMBRE_EO, PRESTACION, REFERENCIA);
	create nonclustered index IDX_INFOE_DIAVOLO on dbo.SNP_PRESTACIONES_EMPRESAS (ID_CONVENIO, TZ_LOCK);
');

EXECUTE('
	delete from dbo.TTR_CODIGO_PROGRAMA_TRANSACCION where codigoPrograma = 18;
	delete from dbo.TTR_CODIGO_TRANSACCION_INFO_EXTENDIDA where codigoTransaccion = 36;
	delete from dbo.TTR_CODIGO_TRANSACCION_INFO_EXTENDIDA where codigoTransaccion = 37;
	delete from dbo.TTR_CODIGO_PROGRAMA_TRANSACCION where codigoPrograma = 19;
	delete from dbo.TTR_CODIGO_TRANSACCION_INFO_EXTENDIDA where codigoTransaccion = 27;
	delete from dbo.TTR_CODIGO_PROGRAMA_TRANSACCION where codigoPrograma = 20;
	delete from dbo.TTR_CODIGO_TRANSACCION_INFO_EXTENDIDA where codigoTransaccion = 38;
	delete from dbo.TTR_CODIGO_TRANSACCION_INFO_EXTENDIDA where codigoTransaccion = 35;
');

EXECUTE('
	insert into dbo.TTR_CODIGO_PROGRAMA_TRANSACCION (codigoPrograma,nombrePrograma,descripcion,TZ_LOCK) values (18,''MP_INFO_EXTENDIDA_DEBDIR_CLIENTES'',''Debitos Directos - Clientes'',0);
	insert into dbo.TTR_CODIGO_TRANSACCION_INFO_EXTENDIDA (codigoTransaccion,infoExtendidaTipo,descripcion,TZ_LOCK) values (36,18,''Débitos Directos de Cámara'',0);
	insert into dbo.TTR_CODIGO_TRANSACCION_INFO_EXTENDIDA (codigoTransaccion,infoExtendidaTipo,descripcion,TZ_LOCK) values (37,18,''Crédito reversa - Débitos directos'',0);
	insert into dbo.TTR_CODIGO_PROGRAMA_TRANSACCION (codigoPrograma,nombrePrograma,descripcion,TZ_LOCK) values (19,''MP_INFO_EXTENDIDA_DEBDIR_EMPRESAS'',''Debitos Directos - Empresas'',0);
	insert into dbo.TTR_CODIGO_TRANSACCION_INFO_EXTENDIDA (codigoTransaccion,infoExtendidaTipo,descripcion,TZ_LOCK) values (27,19,''Crédito por Débitos Directos Cámara'',0);
	insert into dbo.TTR_CODIGO_PROGRAMA_TRANSACCION (codigoPrograma,nombrePrograma,descripcion,TZ_LOCK) values (20,''MP_INFO_EXTENDIDA_DEBDIR_EMPRESAS_REVERSAS'',''Debitos Directos - Empresas Reversas'',0);
	insert into dbo.TTR_CODIGO_TRANSACCION_INFO_EXTENDIDA (codigoTransaccion,infoExtendidaTipo,descripcion,TZ_LOCK) values (38,20,''Reversa Débito Directo Cámara'',0);
	insert into dbo.TTR_CODIGO_TRANSACCION_INFO_EXTENDIDA (codigoTransaccion,infoExtendidaTipo,descripcion,TZ_LOCK) values (35,20,''Reversa rendición Débitos Directos'',0);
');

