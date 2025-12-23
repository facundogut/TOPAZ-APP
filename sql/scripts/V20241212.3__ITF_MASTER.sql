execute('

DELETE from itf_master_parametros where codigo = 540 and codigo_interface = 281;
INSERT INTO dbo.ITF_MASTER_PARAMETROS (CODIGO, CODIGO_INTERFACE, FUNCIONALIDAD, ALFA_1, ALFA_2, ALFA_3, NUMERICO_1, NUMERICO_2, FECHA, IMPORTE_1, IMPORTE_2, TZ_LOCK)
VALUES (540, 281, ''cod nacha rech ajust'', '' '', '' '', '' '', 16, 0, NULL, 0, 0, 0)
');