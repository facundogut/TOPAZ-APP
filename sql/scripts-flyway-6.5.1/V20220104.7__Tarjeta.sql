execute('
DELETE FROM OPERACIONES WHERE TITULO = 2850 AND IDENTIFICACION = 2855

DELETE FROM OPERACIONES WHERE TITULO = 2850 AND IDENTIFICACION = 2856

UPDATE AYUDAS SET CAMPOSVISTA = ''Num Usuario;Cod Administradora;Administradora;Num Tarjeta;Num Cartera;Cartera;Num Tipo Cobro;Tipo Cobro;Num Tipo Pago;Tipo Pago;Cuenta Debito;Cliente;Limite Compra;Limite Cuotas;Tipo Tarjeta;Desc Tipo Tarjeta;Tipo Usuario;Desc Tipo Usuario;''
WHERE NUMERODEAYUDA = 47120
')
