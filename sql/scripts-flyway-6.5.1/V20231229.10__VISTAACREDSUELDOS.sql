EXECUTE('
UPDATE dbo.AYUDAS
SET CAMPOSVISTA = ''Fecha;Acreditacion;Monto;Producto;Nombre_Producto;Sucursal;Nombre_Sucursal;Cuenta;Convenio;Nombre_Convenio;Jurisdiccion;Cliente;''
WHERE NUMERODEAYUDA = 43442
')