EXECUTE('
UPDATE dbo.AYUDAS
SET CAMPOS = ''50299;664R;9104;''
	, CAMPOSVISTA = ''Convenio;Dominio;Descripcion;''
WHERE NUMERODEAYUDA = 49199

UPDATE dbo.AYUDAS
SET CAMPOS = ''6585I;664I;9104I;4101I;4103I;661R;9105R;''
	, CAMPOSVISTA = ''Convenio;Dominio;Descripcion;Tipo Dominio;Tipo Sub Dominio;Tipo Beneficio;Descripcion Beneficio;''
WHERE NUMERODEAYUDA = 49200

')