
execute('  
  
UPDATE AYUDAS
SET CAMPOSVISTA = ''TipoDoc;NumeroDoc;NumeroPersona;NivelApertura;TipoPersona;Nombres;Apellidos;''
WHERE NUMERODEAYUDA = 9348

UPDATE DICCIONARIO
SET DESCRIPCION = ''Apellido/s'', PROMPT = ''Apellido/s''
WHERE NUMERODECAMPO = 838

UPDATE DICCIONARIO
SET DESCRIPCION = ''Apellido/s'', PROMPT = ''Apellido/s''
WHERE NUMERODECAMPO = 1418

UPDATE DICCIONARIO
SET DESCRIPCION = ''Nombre/s''	, PROMPT = ''Nombre/s''
WHERE NUMERODECAMPO = 1421

UPDATE AYUDAS
SET CAMPOSVISTA = ''TipoDoc;NumeroDoc;NumeroPersona;NivelApertura;TipoPersona;Nombres;Apellidos;Estado;Motivo_Inhabilitado;''
WHERE NUMERODEAYUDA = 9355
');
