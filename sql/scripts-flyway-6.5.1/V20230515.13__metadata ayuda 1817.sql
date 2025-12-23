EXECUTE('
UPDATE AYUDAS
SET NUMERODEARCHIVO = 0
	, NUMERODEAYUDA = 1817
	, DESCRIPCION = ''Ayuda Causa - Cuentas''
	, FILTRO = ''''
	, MOSTRARTODOS = 0
	, CAMPOS = ''2615R;2616;661;44871;4898;112;4073;9208;3325;2844;1853;5011;68;''
	, CAMPOSVISTA = ''Nro. Causa;Juzgado;Año;Expediente;Tipo Causa;Fecha Causa;Estado;Caratula;Cuenta;Alta de la Cuenta;Fecha de Oficio;Bloqueo de la Cuenta;Saldo de la Cuenta;''
	, BASEVISTA = ''TOP/CLIENTES''
	, NOMBREVISTA = ''VW_DJ_CAUSAS_CUENTA_SALDO''
	, AYUDAGRANDE = 0
WHERE NUMERODEAYUDA = 1817
')

