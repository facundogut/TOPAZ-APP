EXECUTE('
------------------------------------------------------------------
--MACRO R PARA SABER SI GRUPO TIENE CUENTAS CON TIPO SALDO FONDO--
------------------------------------------------------------------
INSERT INTO dbo.MACROR (PROCESO, ORDINAL, ARCHIVO, INDICE, CONDICION, RECEPTOR, FORMULA)
VALUES (124, 0, 121, 1, ''Existe Cuenta FUCO para el grupo'', NULL, NULL)
--
INSERT INTO dbo.MACROR (PROCESO, ORDINAL, ARCHIVO, INDICE, CONDICION, RECEPTOR, FORMULA)
VALUES (124, 1, 121, 1, ''C1577=C1577YC5874#0'', ''C1239'', ''1'')
----
')
