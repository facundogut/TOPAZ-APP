EXECUTE ('
UPDATE dbo.AYUDAS
SET DESCRIPCION = ''Personas Jurídicas''
WHERE NUMERODEAYUDA = 9384

UPDATE dbo.AYUDAS
SET DESCRIPCION = ''Personas Humanas''
WHERE NUMERODEAYUDA = 9355

UPDATE dbo.AYUDAS
SET CAMPOS = ''1064R;1963R;537;622;274;1063R;209;531;624;1057R;''
	, CAMPOSVISTA = ''Tipo Documento Identificativo;Número Documento Identificativo;Tipo Documento Físico;Número de Documento Físico;Apellidos y Nombres;Tipo de Persona;Nivel de Apertura;Estado de la Persona;Motivo Inhabilitado;Número de Persona;''
WHERE NUMERODEAYUDA = 9355

UPDATE dbo.AYUDAS
SET CAMPOS = ''1064R;1963R;537;622;274;1063R;209;531;624;1057R;''
	, CAMPOSVISTA = ''Tipo Documento Identificativo;Número Documento Identificativo;Tipo Documento Físico;Número de Documento Físico;Razón Social;Tipo de Persona;Nivel de Apertura;Estado de la Persona;Motivo Inhabilitado;Número de Persona;''
WHERE NUMERODEAYUDA = 9384

UPDATE dbo.DICCIONARIO
SET DESCRIPCION = ''Parcela''
	, PROMPT = ''Parcela''
WHERE NUMERODECAMPO = 37244

UPDATE dbo.DICCIONARIO
SET DESCRIPCION = ''Parcela''
	, PROMPT = ''Parcela''
WHERE NUMERODECAMPO = 37253

')
