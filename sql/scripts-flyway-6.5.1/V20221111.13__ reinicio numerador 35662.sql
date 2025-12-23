EXECUTE('
DELETE FROM NumeratorDefinition WHERE NUMERO = 35662

DELETE FROM NumeratorValues WHERE NUMERO = 35662

DELETE FROM NumeratorAsigned WHERE OID IN (SELECT OID FROM NumeratorValues WHERE NUMERO = 35662)
')

EXECUTE('
INSERT INTO NUMERATORDEFINITION (Numero, IniVal, Incremento, Periodo, Reutilizable, Maximo, Ultimainic, Centralizado, Tipo)
VALUES (35662, 1, 1, ''P'', 1, 0, NULL, 0, ''T'')


INSERT INTO NUMERATORVALUES (Dia, Mes, Anio, Sucursal, Numero, Valor)
VALUES (0, 0, 0, 1, 35662, 1)
')

