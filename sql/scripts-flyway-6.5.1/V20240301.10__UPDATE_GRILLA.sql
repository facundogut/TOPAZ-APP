EXECUTE('
UPDATE dbo.AYUDAS
SET CAMPOS = ''2612;324;2613;760;2615;2614;2616;2617;52;57;58;59;67;102;105;88;977;755R;617R;565R;''
	, CAMPOSVISTA = ''Sucursal;Nombre Sucursal;Producto;Nombre Producto;Cuenta;Moneda;Operacion;Desglose;Deuda Exigible;Deuda no Exigible;Deuda Total;Deuda Contingente;Riesgo Total;Monto Origen;Saldo Capital;Vencimiento;Estado;Clasificacion;Cliente;JTS_OID;''
WHERE NUMERODEAYUDA = 49551

')