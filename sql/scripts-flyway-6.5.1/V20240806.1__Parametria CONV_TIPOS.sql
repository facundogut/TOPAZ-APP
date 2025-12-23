EXECUTE('

DELETE FROM CONV_TIPOS


INSERT INTO CONV_TIPOS (Id_TpoConv, DscTpoConv, TpoProducto, TpoCStopD, TpoCRev, TpoCMulta, TpoContrato, Rubro_operativo, TZ_LOCK)
VALUES (1, ''Débitos Directos'', ''R'', ''N'', ''N'', ''N'', 2, 800001, 0)


INSERT INTO CONV_TIPOS (Id_TpoConv, DscTpoConv, TpoProducto, TpoCStopD, TpoCRev, TpoCMulta, TpoContrato, Rubro_operativo, TZ_LOCK)
VALUES (2, ''Débitos Automaticos'', ''R'', ''N'', ''N'', ''N'', 1, 800002, 0)


INSERT INTO CONV_TIPOS (Id_TpoConv, DscTpoConv, TpoProducto, TpoCStopD, TpoCRev, TpoCMulta, TpoContrato, Rubro_operativo, TZ_LOCK)
VALUES (3, ''Pago de Haberes - administración pública'', ''P'', ''N'', ''N'', ''N'', 11, 0, 0)


INSERT INTO CONV_TIPOS (Id_TpoConv, DscTpoConv, TpoProducto, TpoCStopD, TpoCRev, TpoCMulta, TpoContrato, Rubro_operativo, TZ_LOCK)
VALUES (4, ''Recaudaciones por Terceros'', ''R'', ''N'', ''N'', ''N'', 3, 800003, 0)


INSERT INTO CONV_TIPOS (Id_TpoConv, DscTpoConv, TpoProducto, TpoCStopD, TpoCRev, TpoCMulta, TpoContrato, Rubro_operativo, TZ_LOCK)
VALUES (5, ''Canal Externo de Recaudo.'', ''R'', ''N'', ''N'', ''N'', 3, 800005, 0)


INSERT INTO CONV_TIPOS (Id_TpoConv, DscTpoConv, TpoProducto, TpoCStopD, TpoCRev, TpoCMulta, TpoContrato, Rubro_operativo, TZ_LOCK)
VALUES (6, ''Comercializadoras'', ''M'', ''N'', ''N'', ''N'', 6, 0, 0)


INSERT INTO CONV_TIPOS (Id_TpoConv, DscTpoConv, TpoProducto, TpoCStopD, TpoCRev, TpoCMulta, TpoContrato, Rubro_operativo, TZ_LOCK)
VALUES (7, ''Canal de Ventas'', ''C'', ''N'', ''N'', ''N'', 8, 0, 0)


INSERT INTO CONV_TIPOS (Id_TpoConv, DscTpoConv, TpoProducto, TpoCStopD, TpoCRev, TpoCMulta, TpoContrato, Rubro_operativo, TZ_LOCK)
VALUES (8, ''Pago de Honorarios'', ''P'', ''N'', ''N'', ''N'', 10, 0, 0)


INSERT INTO CONV_TIPOS (Id_TpoConv, DscTpoConv, TpoProducto, TpoCStopD, TpoCRev, TpoCMulta, TpoContrato, Rubro_operativo, TZ_LOCK)
VALUES (9, ''Pagos Varios'', ''P'', ''N'', ''N'', ''N'', 11, 0, 0)


INSERT INTO CONV_TIPOS (Id_TpoConv, DscTpoConv, TpoProducto, TpoCStopD, TpoCRev, TpoCMulta, TpoContrato, Rubro_operativo, TZ_LOCK)
VALUES (10, ''Fondo de Cese Laboral'', ''P'', ''N'', ''N'', ''N'', 9, 0, 0)


INSERT INTO CONV_TIPOS (Id_TpoConv, DscTpoConv, TpoProducto, TpoCStopD, TpoCRev, TpoCMulta, TpoContrato, Rubro_operativo, TZ_LOCK)
VALUES (11, ''Depositos Judiciales'', ''P'', ''N'', ''N'', ''N'', 13, 0, 0)


INSERT INTO CONV_TIPOS (Id_TpoConv, DscTpoConv, TpoProducto, TpoCStopD, TpoCRev, TpoCMulta, TpoContrato, Rubro_operativo, TZ_LOCK)
VALUES (12, ''Pago por Caja sin Cuenta Vista'', ''P'', ''N'', ''N'', ''N'', 6, 0, 0)


INSERT INTO CONV_TIPOS (Id_TpoConv, DscTpoConv, TpoProducto, TpoCStopD, TpoCRev, TpoCMulta, TpoContrato, Rubro_operativo, TZ_LOCK)
VALUES (13, ''Transporte de Caudales'', ''R'', ''N'', ''N'', ''N'', 7, 0, 0)


INSERT INTO CONV_TIPOS (Id_TpoConv, DscTpoConv, TpoProducto, TpoCStopD, TpoCRev, TpoCMulta, TpoContrato, Rubro_operativo, TZ_LOCK)
VALUES (14, ''Deducciones Autorizadas'', ''R'', ''N'', ''N'', ''N'', 4, 0, 0)


INSERT INTO CONV_TIPOS (Id_TpoConv, DscTpoConv, TpoProducto, TpoCStopD, TpoCRev, TpoCMulta, TpoContrato, Rubro_operativo, TZ_LOCK)
VALUES (15, ''Seguro sobre Saldo Deudor'', ''R'', ''N'', ''N'', ''N'', 3, 800005, 0)


INSERT INTO CONV_TIPOS (Id_TpoConv, DscTpoConv, TpoProducto, TpoCStopD, TpoCRev, TpoCMulta, TpoContrato, Rubro_operativo, TZ_LOCK)
VALUES (16, ''Pago de Haberes - INSSSEP ACTIVO'', ''P'', ''N'', ''N'', ''N'', 11, 0, 0)


INSERT INTO CONV_TIPOS (Id_TpoConv, DscTpoConv, TpoProducto, TpoCStopD, TpoCRev, TpoCMulta, TpoContrato, Rubro_operativo, TZ_LOCK)
VALUES (17, ''Pago de Haberes - SUELDOS PRIVADOS'', ''P'', ''N'', ''N'', ''N'', 11, 0, 0)


INSERT INTO CONV_TIPOS (Id_TpoConv, DscTpoConv, TpoProducto, TpoCStopD, TpoCRev, TpoCMulta, TpoContrato, Rubro_operativo, TZ_LOCK)
VALUES (18, ''Recaudaciones Propias del ente'', ''R'', ''N'', ''N'', ''N'', 5, 800001, 0)


INSERT INTO CONV_TIPOS (Id_TpoConv, DscTpoConv, TpoProducto, TpoCStopD, TpoCRev, TpoCMulta, TpoContrato, Rubro_operativo, TZ_LOCK)
VALUES (19, ''Pago de haberers - ANSES'', ''P'', ''N'', ''N'', ''N'', 11, 0, 0)

')