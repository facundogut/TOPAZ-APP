EXECUTE('
----------------------
--MODIFICACIÓN AYUDA--
----------------------
UPDATE AYUDAS
SET CAMPOS = ''3325R;3249R;3250R;3251R;5117;3267;3262;34685;''
	, CAMPOSVISTA = ''Numero_Contrato;TipoDoc;NumeroDoc;NumeroPersona;Titularidad;TipoPersona;Nombre;Poder;''
WHERE NUMERODEAYUDA = 9362
----
')

