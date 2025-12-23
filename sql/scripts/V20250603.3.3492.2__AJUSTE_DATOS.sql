EXECUTE ('
	update MOVIMIENTOS_CONTABLES set COD_TRANSACCION = 0 where OPERACION = 2667 and DEBITOCREDITO = ''D'' and CONCEPTO = ''Debito Transitoria'';
');

EXECUTE ('
	update MOVIMIENTOS_CONTABLES set COD_TRANSACCION = 60 where OPERACION = 2667 and DEBITOCREDITO = ''C'' and CONCEPTO = ''Credito por Convenio'';
');

EXECUTE ('
	update MOVIMIENTOS_CONTABLES set CONCEPTO = CONCAT(SUBSTRING(CONCEPTO,1,19) , '':'' , SUBSTRING(CONCEPTO,20,LEN(CONCEPTO))) where OPERACION = 7914 and COD_TRANSACCION = 62 and CONCEPTO like ''Debitos Automaticos%'' and CONCEPTO not like ''Debitos Automaticos:%'';
');

EXECUTE('
	update mc 
	set CONCEPTO = CONCAT(mc.CONCEPTO, '':'', ccr.Id_ConvRec) 
	from MOVIMIENTOS_CONTABLES mc 
	left join REC_DET_DEBITOSAUTOMATICOS rdd on rdd.FECHA_COBRANZA = mc.FECHAPROCESO and rdd.ASIENTO_COBRANZA = mc.ASIENTO and rdd.JTS_DEBITO = mc.SALDO_JTS_OID and rdd.IMPORTE = mc.CAPITALREALIZADO and rdd.TZ_LOCK = 0 
	left join REC_CAB_DEBITOSAUTOMATICOS rcd on rcd.ID = rdd.ID_CABEZAL and rcd.TZ_LOCK = 0 
	left join CONV_CONVENIOS_REC ccr on ccr.Id_ConvRec = rcd.CONVENIO and ccr.TZ_LOCK = 0 
	where mc.OPERACION = 2656 
	and mc.COD_TRANSACCION = 62 
	and mc.CONCEPTO = ''Debito Automatico'' 
');

