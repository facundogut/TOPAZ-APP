EXEC('
	DELETE FROM ITF_MASTER_PARAMETROS 
	WHERE 
		CODIGO IN (
			279,
			280,
			281,
			282,
			283,
			284,
			285,
			286,
			294,
			295,
			296,
			297,
			298,
			299,
			301,
			302,
			303,
			304,
			305,
			306,
			307,
			308,
			309,
			310
		)
	;
	INSERT INTO ITF_MASTER_PARAMETROS
	(CODIGO, CODIGO_INTERFACE, FUNCIONALIDAD, ALFA_1, ALFA_2)
	VALUES
	(279, 2026001, ''INAES Map Provincias'', ''A'', ''SALTA''),
	(280, 2026001, ''INAES Map Provincias'', ''B'', ''BUENOS AIRES''),
	(281, 2026001, ''INAES Map Provincias'', ''C'', ''CAPITAL FEDERAL''),
	(282, 2026001, ''INAES Map Provincias'', ''D'', ''SAN LUIS''),
	(283, 2026001, ''INAES Map Provincias'', ''E'', ''ENTRE RIOS''),
	(284, 2026001, ''INAES Map Provincias'', ''F'', ''LA RIOJA''),
	(285, 2026001, ''INAES Map Provincias'', ''G'', ''SGO. DEL ESTERO''),
	(286, 2026001, ''INAES Map Provincias'', ''H'', ''CHACO''),
	(294, 2026001, ''INAES Map Provincias'', ''J'', ''SAN JUAN''),
	(295, 2026001, ''INAES Map Provincias'', ''K'', ''CATAMARCA''),
	(296, 2026001, ''INAES Map Provincias'', ''L'', ''LA PAMPA''),
	(297, 2026001, ''INAES Map Provincias'', ''M'', ''MENDOZA''),
	(298, 2026001, ''INAES Map Provincias'', ''N'', ''MISIONES''),
	(299, 2026001, ''INAES Map Provincias'', ''P'', ''FORMOSA''),
	(301, 2026001, ''INAES Map Provincias'', ''Q'', ''NEUQUEN''),
	(302, 2026001, ''INAES Map Provincias'', ''R'', ''RIO NEGRO''),
	(303, 2026001, ''INAES Map Provincias'', ''S'', ''SANTA FE''),
	(304, 2026001, ''INAES Map Provincias'', ''T'', ''TUCUMAN''),
	(305, 2026001, ''INAES Map Provincias'', ''U'', ''CHUBUT''),
	(306, 2026001, ''INAES Map Provincias'', ''V'', ''TIERRA DEL FUEGO''),
	(307, 2026001, ''INAES Map Provincias'', ''W'', ''CORRIENTES''),
	(308, 2026001, ''INAES Map Provincias'', ''X'', ''CORDOBA''),
	(309, 2026001, ''INAES Map Provincias'', ''Y'', ''JUJUY''),
	(310, 2026001, ''INAES Map Provincias'', ''Z'', ''SANTA CRUZ'')
	;
');

