EXECUTE('
	alter table TTR_CODIGO_TRANSACCION_INFO_EXTENDIDA alter column infoExtendidaTipo numeric(5,0) not null;
');

EXECUTE('
	update DICCIONARIO set LARGO = 5 where NUMERODECAMPO = 7914;
');

EXECUTE('
	delete from TTR_CODIGO_PROGRAMA_TRANSACCION where codigoPrograma = 16;
	delete from TTR_CODIGO_TRANSACCION_INFO_EXTENDIDA where codigoTransaccion = 62;
	delete from TTR_CODIGO_PROGRAMA_TRANSACCION where codigoPrograma = 17;
	delete from TTR_CODIGO_TRANSACCION_INFO_EXTENDIDA where codigoTransaccion = 60;
');

EXECUTE('
	insert into TTR_CODIGO_PROGRAMA_TRANSACCION (codigoPrograma,nombrePrograma,descripcion,TZ_LOCK) values (16,''MP_INFO_EXTENDIDA_DEBAUT_DEB'',''Debitos Automaticos - Debitos'',0);
	insert into TTR_CODIGO_TRANSACCION_INFO_EXTENDIDA (codigoTransaccion,infoExtendidaTipo,descripcion,TZ_LOCK) values (62,16,''Convenios - Debito Automatico'',0);
	insert into TTR_CODIGO_PROGRAMA_TRANSACCION (codigoPrograma,nombrePrograma,descripcion,TZ_LOCK) values (17,''MP_INFO_EXTENDIDA_DEBAUT_CRED'',''Debitos Automaticos - Creditos'',0);
	insert into TTR_CODIGO_TRANSACCION_INFO_EXTENDIDA (codigoTransaccion,infoExtendidaTipo,descripcion,TZ_LOCK) values (60,17,''Convenios - Credito Automatico'',0);
');

EXECUTE('
	drop index if exists IX_DBA_codigoTransaccion on dbo.HISTORICO_MOVIMIENTOS;
	drop index if exists IX_DBA_REBUS_INFOE on dbo.HISTORICO_MOVIMIENTOS;
	drop index if exists IX_HIS_MOV_IDENT on dbo.HISTORICO_MOVIMIENTOS;
	drop index if exists IX_HIS_MOV_ORDER on dbo.HISTORICO_MOVIMIENTOS;
	drop index if exists IX_HIS_MOV_ORDER_REAL on dbo.HISTORICO_MOVIMIENTOS;
	drop index if exists IX_CTIE_PK_TZ on dbo.TTR_CODIGO_TRANSACCION_INFO_EXTENDIDA;
	drop index if exists IX_CPT_PK_TZ on dbo.TTR_CODIGO_PROGRAMA_TRANSACCION;
	drop index if exists IDX_INFOE_DIAVOLO on dbo.REC_DET_DEBITOSAUTOMATICOS;
	drop index if exists IDX_INFOE_DIAVOLO on dbo.REC_RENDICION;
');

EXECUTE('
	create unique nonclustered index IX_HIS_MOV_IDENT on dbo.HISTORICO_MOVIMIENTOS (fechaAsiento, sucursalAlta, asiento, movJtsOid) include (jts_oid, TZ_LOCK, infoExtendidaMeta, infoExtendida, saldoPrevio, saldoPosterior);
	create nonclustered index IX_HIS_MOV_ORDER on dbo.HISTORICO_MOVIMIENTOS (TIMESTAMP_MOV desc) include (jts_oid, TZ_LOCK);
	create nonclustered index IX_HIS_MOV_ORDER_REAL on dbo.HISTORICO_MOVIMIENTOS (fechaValor desc, TIMESTAMP_MOV desc, movJtsOid desc) include (jts_oid, TZ_LOCK);
	create nonclustered index IX_DBA_REBUS_INFOE on dbo.HISTORICO_MOVIMIENTOS (codigoTransaccion, TIMESTAMP_MOV, TZ_LOCK) include (asiento, cuenta, descripcion, fechaAsiento, fechaReloj, fechaValor, horaReloj, importe, infoExtendidaMeta, jts_oid, modulo, moneda, movJtsOid, operacion, producto, saldoPosterior, saldoPrevio, sucursal, sucursalAlta, tipoMov);
	create nonclustered index IX_CTIE_PK_TZ on dbo.TTR_CODIGO_TRANSACCION_INFO_EXTENDIDA (codigoTransaccion) include (TZ_LOCK);
	create nonclustered index IX_CPT_PK_TZ on dbo.TTR_CODIGO_PROGRAMA_TRANSACCION (codigoPrograma) include (TZ_LOCK);
	create nonclustered index IDX_INFOE_DIAVOLO on dbo.REC_DET_DEBITOSAUTOMATICOS (IMPORTE, ASIENTO_COBRANZA, FECHA_COBRANZA, TZ_LOCK, JTS_DEBITO) include (ID_CABEZAL);
	create nonclustered index IDX_INFOE_DIAVOLO on dbo.REC_RENDICION (FECHA, SUCURSAL_RENDICION, ASIENTO_RENDICION, TZ_LOCK) include (CONVENIO);
');

