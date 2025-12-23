EXECUTE('
------------------------------
--Modificación Ayuda Cuentas--
------------------------------
UPDATE dbo.AYUDAS
SET CAMPOS = ''1146R;1059;2639;2636;2635;9103;2638;''
	, CAMPOSVISTA = ''Cliente;Nombre Cliente;Nivel Cliente;Tipo Cliente;Código Bloqueo;Motivo Inhabilitado;Estado Cliente;''
WHERE NUMERODEAYUDA = 9372
----
')