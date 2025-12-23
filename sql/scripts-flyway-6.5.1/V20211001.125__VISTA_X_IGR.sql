EXECUTE('
CREATE   
	VIEW [dbo].[VW_CLI_PAISES] (
								CODIGOPAIS,
								NOMBREPAIS,
								CODIGOSWIFT)
	AS 
	SELECT 
		CODIGOPAIS,          
		NOMBREPAIS,
		CODIGOSWIFT           
			        
	FROM CLI_PAISES P (NOLOCK)			        
	WHERE 
      ((P.TZ_LOCK < 300000000000000 OR P.TZ_LOCK >= 400000000000000) AND (P.TZ_LOCK < 100000000000000 OR P.TZ_LOCK >= 200000000000000))
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
')

EXECUTE('
UPDATE dbo.DICCIONARIO
SET DECIMALES = 2,
	LARGO = 15
WHERE NUMERODECAMPO = 41309

UPDATE dbo.DICCIONARIO
SET DECIMALES = 2,
	LARGO = 15
WHERE NUMERODECAMPO = 41311

UPDATE dbo.DICCIONARIO
SET LARGO = 15, 
	DECIMALES = 2
WHERE NUMERODECAMPO = 41321

UPDATE dbo.DICCIONARIO
SET TABLADEAYUDA = 8501
WHERE NUMERODECAMPO = 41308

UPDATE dbo.DICCIONARIO
SET TABLADEAYUDA = 8501
WHERE NUMERODECAMPO = 41310


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
')

EXECUTE('
INSERT INTO dbo.DESCRIPTORES (TITULO, IDENTIFICACION, TIPODEARCHIVO, DESCRIPCION, GRUPODELMAPA, NOMBREFISICO, TIPODEDBMS, LARGODELREGISTRO, INICIALIZACIONDELREGISTRO, BASE, SELECCION, ACEPTA_MOVS_DIFERIDO)
VALUES (10, 850, NULL, ''Vista Países'', 0, ''VW_CLI_PAISES'', ''D'', NULL, NULL, ''TOP/CLIENTES'', NULL, ''N'')

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

INSERT INTO dbo.INDICES (NUMERODEARCHIVO, NUMERODEINDICE, DESCRIPCION, CLAVESREPETIDAS, CAMPO1, CAMPO2, CAMPO3, CAMPO4, CAMPO5, CAMPO6, CAMPO7, CAMPO8, CAMPO9, CAMPO10, CAMPO11, CAMPO12, CAMPO13, CAMPO14, CAMPO15, CAMPO16, CAMPO17, CAMPO18, CAMPO19, CAMPO20)
VALUES (850, 1, ''Indice Vista Paises'', 0, 41329, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

INSERT INTO dbo.DICCIONARIO (NUMERODECAMPO, USODELCAMPO, REFERENCIA, DESCRIPCION, PROMPT, LARGO, TIPODECAMPO, DECIMALES, EDICION, CONTABILIZA, CONCEPTO, CALCULO, VALIDACION, TABLADEVALIDACION, TABLADEAYUDA, OPCIONES, TABLA, CAMPO, BASICO, MASCARA)
VALUES (41327, '' '', 0, ''Código del País'', ''Código del País'', 5, ''N'', 0, NULL, 0, 0, 0, 0, 0, 561, 0, 850, ''CODIGOPAIS'', 0, NULL)

INSERT INTO dbo.DICCIONARIO (NUMERODECAMPO, USODELCAMPO, REFERENCIA, DESCRIPCION, PROMPT, LARGO, TIPODECAMPO, DECIMALES, EDICION, CONTABILIZA, CONCEPTO, CALCULO, VALIDACION, TABLADEVALIDACION, TABLADEAYUDA, OPCIONES, TABLA, CAMPO, BASICO, MASCARA)
VALUES (41328, '' '', 0, ''Nombre del País'', ''Nombre del País'', 20, ''A'', 0, NULL, 0, 0, 0, 0, 0, 0, 0, 850, ''NOMBREPAIS'', 0, NULL)

INSERT INTO dbo.DICCIONARIO (NUMERODECAMPO, USODELCAMPO, REFERENCIA, DESCRIPCION, PROMPT, LARGO, TIPODECAMPO, DECIMALES, EDICION, CONTABILIZA, CONCEPTO, CALCULO, VALIDACION, TABLADEVALIDACION, TABLADEAYUDA, OPCIONES, TABLA, CAMPO, BASICO, MASCARA)
VALUES (41329, '' '', 0, ''Código SWIFT'', ''Código SWIFT'', 2, ''A'', 0, NULL, 0, 0, 0, 0, 0, 0, 0, 850, ''CODIGOSWIFT'', 0, NULL)

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

INSERT INTO dbo.AYUDAS (NUMERODEARCHIVO, NUMERODEAYUDA, DESCRIPCION, FILTRO, MOSTRARTODOS, CAMPOS, CAMPOSVISTA, BASEVISTA, NOMBREVISTA, AYUDAGRANDE)
VALUES (850, 8501, ''Ayuda Países'', '''', 0, ''41327;41328;41329R;'', NULL, NULL, NULL, 0)

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
')
EXECUTE('
ALTER TABLE CLI_PERSONASJURIDICAS ALTER COLUMN INGRESOS_ANUALES NUMERIC(15,2)
ALTER TABLE CLI_PERSONASFISICAS ALTER COLUMN INGRESOS_ANUALES NUMERIC(15,2)
ALTER TABLE ITF_MATRIZ_IGR ALTER COLUMN INGRESOS_ANUALES NUMERIC(15,2)
')