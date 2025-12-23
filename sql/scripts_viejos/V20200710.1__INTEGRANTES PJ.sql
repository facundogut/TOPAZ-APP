---------------------AYUDA------------------------------

UPDATE dbo.AYUDAS
SET NUMERODEARCHIVO = 0
	, NUMERODEAYUDA = 9351
	, DESCRIPCION = 'Ayuda vista Integrante PJ'
	, FILTRO = NULL
	, MOSTRARTODOS = 0
	, CAMPOS = '1064R;1963R;1057R;4161R;537R;622R;1058;3242;1063R;1901;1427;'
	, CAMPOSVISTA = 'TipoDoc;NumeroDoc;NumeroPersona;NumeroPFisica;TipoDocIntegrante;NroDocIntegrante;Nombre;Cargo;TipoPersona;RazonSocial;NombreFantasia'
	, BASEVISTA = 'Top/Clientes'
	, NOMBREVISTA = 'VW_INTEGRANTES_PJ_VISTA'
	, AYUDAGRANDE = 0
WHERE NUMERODEAYUDA = 9351
GO
 

