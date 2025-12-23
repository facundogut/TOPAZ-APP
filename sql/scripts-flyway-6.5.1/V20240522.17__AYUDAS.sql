EXECUTE('
UPDATE dbo.AYUDAS
SET CAMPOSVISTA = ''Clasificacion;Deuda Exigible;Deuda no Exigible;Deuda Total;Deuda Contingente;Riesgo Total;Persona;''
WHERE NUMERODEAYUDA = 49550
')

EXECUTE('
UPDATE dbo.AYUDAS
SET CAMPOSVISTA = ''Deuda Exigible;Deuda no exigible;Deuda Total;Deuda Contingente;Riesgo Total;Persona;''
WHERE NUMERODEAYUDA = 49552
')