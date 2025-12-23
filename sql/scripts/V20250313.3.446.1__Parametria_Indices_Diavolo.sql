EXECUTE('drop index if exists IX_INFO_E_DIAVOLO on ITF_ACREDITACION_BITACORA;');
EXECUTE('create nonclustered index IX_INFO_E_DIAVOLO on ITF_ACREDITACION_BITACORA (SUCURSAL, FECHA_PROCESO, NRO_ASIENTO);');
EXECUTE('drop index if exists IX_SCAN_MOVS_DIAVOLO on HISTORY;');
EXECUTE('create nonclustered index IX_SCAN_MOVS_DIAVOLO on HISTORY (STATE, DATE_) INCLUDE (TRANSACTIONID, BRANCH, PROCESSDATE)');
EXECUTE('truncate table TTR_CODIGO_PROGRAMA_TRANSACCION;');
EXECUTE('
INSERT INTO TTR_CODIGO_PROGRAMA_TRANSACCION (codigoPrograma,nombrePrograma,descripcion,TZ_LOCK) VALUES
	 (1,N''MP_INFO_EXTENDIDA_TRANSFERENCIAS_MONOBANCO'',N''Programa Transferencias Monobanco'',0),
	 (2,N''MP_INFO_EXTENDIDA_PLAZO_FIJO'',N''Programa Plazo Fijo'',0),
	 (3,N''MP_INFO_EXTENDIDA_POS_ATM_DEP'',N''POS ATM DEPOSITOS'',0),
	 (4,N''MP_INFO_EXTENDIDA_POS_ATM_EXT'',N''POS ATM EXTRACCION'',0),
	 (5,N''MP_INFO_EXTENDIDA_POS_COMERCIOS'',N''POS COMPRA EN COMERCIOS'',0),
	 (6,N''MP_INFO_EXTENDIDA_POS_DEBIN_CREDIN'',N''POS DEBIN CREDIN'',0),
	 (7,N''MP_INFO_EXTENDIDA_POS_DIFERIDAS'',N''POS TRANSFERENCIAS DIFERIDAS'',0),
	 (8,N''MP_INFO_EXTENDIDA_POS_TRANSFERENCIAS'',N''POS CREDITO DEBITO POR TRANSFERENCIA'',0),
	 (9,N''MP_INFO_EXTENDIDA_TLF_CELULARES'',N''TLF: Recarga celulares'',0),
	 (10,N''MP_INFO_EXTENDIDA_POS_PAGO_SERVICIOS'',N''POS PAGO DE SERVICIOS'',0),
	 (11,N''MP_INFO_EXTENDIDA_PAGOS_ELECTRONICOS'',N''Pagos Electrónicos'',0),
	 (12,N''MP_INFO_EXTENDIDA_COELSA_TRANSFERENCIAS'',N''Transferencias Recibidas / Enviadas por Cámara COELSA'',0),
	 (13,N''MP_INFO_EXTENDIDA_ATE_TRANSFERENCIAS'',N''Transferencias Recibidas / Enviadas por INterbanking ATE'',0),
	 (14,N''MP_INFO_EXTENDIDA_MEP_TRANSFERENCIAS'',N''MEP Transferencias'',0),
	 (15,N''MP_INFO_EXTENDIDA_CHEQUES'',N''Informacion extra sobre cheques'',0);
');
EXECUTE('truncate table TTR_CODIGO_TRANSACCION_INFO_EXTENDIDA;');
EXECUTE('
INSERT INTO TTR_CODIGO_TRANSACCION_INFO_EXTENDIDA (codigoTransaccion,infoExtendidaTipo,descripcion,TZ_LOCK) VALUES
	 (23,1,N''TOPAZ Debito - Transferencias Monobanco'',0),
	 (30,1,N''TOPAZ Credito - Transferencias Monobanco'',0),
	 (152,1,N''NBCH24: Credito - Transferencias Monobanco'',0),
	 (153,1,N''NBCH24: Debito - Transferencias Monobanco'',0),
	 (48,2,N''Debito por Constitucion de Plazo Fijo'',0),
	 (49,2,N''Credito por Pre Cancelacion de Plazo Fijo'',0),
	 (50,2,N''Credito por Pago Plazo Fijo'',0),
	 (4,3,N''POS: Depósitos en ATM'',0),
	 (2,4,N''POS: Extracciones por ATM'',0),
	 (300,5,N''POS: Compra en Comercios'',0),
	 (304,5,N''POS: Devolucion en Comercios'',0),
	 (422,6,N''POS: Debin / Credin'',0),
	 (423,7,N''POS: Transferencias Diferidas'',0),
	 (421,8,N''POS: Debitos / Creditos por Transferencias'',0),
	 (400,9,N''TLF: Recarga de celulares'',0),
	 (410,10,N''POS: Pago de Servicios'',0),
	 (450,10,N''POS: Pago de Tarjeta de Credito'',0),
	 (134,11,N''Pagos Electrónicos'',0),
	 (21,12,N''Débito por Transferencia Atm Camara'',0),
	 (22,12,N''Débito por Transferencia Caja Camara'',0),
	 (34,12,N''Crédito por Transferencia Cámara'',0),
	 (156,13,N''IB - Transferencia Mismo Titular Monobanco'',0),
	 (157,13,N''IB - Transferencia Distinto Titular Monobanco'',0),
	 (158,13,N''IB - Debito  Mismo Titular Interbanco'',0),
	 (159,13,N''IB - Crédito  Mismo Titular Interbanco'',0),
	 (160,13,N''IB - Debito Distinto Titular Interbanco'',0),
	 (161,13,N''IB - Crédito Distinto Titular Interbanco'',0),
	 (162,14,N''MEP Pasivas'',0),
	 (5,15,N''Deposito Cheque por Caja'',0),
	 (11,15,N''Pago Cheque por Caja'',0),
	 (87,15,N''Pago Cheque de Camara'',0),
	 (88,15,N''Rechazo Pago Cheque de Camara'',0);
');
