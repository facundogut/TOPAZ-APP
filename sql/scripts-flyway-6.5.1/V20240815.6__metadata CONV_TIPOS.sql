EXECUTE('

DELETE FROM CONV_TIPOS WHERE Id_TpoConv = 12;


INSERT INTO CONV_TIPOS (Id_TpoConv, DscTpoConv, TpoProducto, TpoCStopD, TpoCRev, TpoCMulta, TpoContrato, Rubro_operativo, TZ_LOCK)
VALUES (12, ''Pago por Caja sin Cuenta Vista'', ''P'', ''N'', ''N'', ''N'', 12, 0, 0);

')