EXECUTE('
INSERT INTO MACROR (PROCESO, ORDINAL, ARCHIVO, INDICE, CONDICION, RECEPTOR, FORMULA)
VALUES 	(339, 0, 16, 3, ''Retorna numero persona de relación Cliente Persona'', NULL, NULL),
		(339, 1, 16, 3, ''C1504=C1504'', ''C607'', ''C1505''),
		(340, 0, 34, 3, ''Retorna nro y tipo de documento a partir de numero persona'', NULL, NULL),
		(340, 1, 34, 3, ''C1854=C1854'', ''C622'', ''C1856''),
 		(340, 2, 34, 3, ''C1854=C1854'', ''C804'', ''C1855'');
');

