EXECUTE('

--Oper 5016

ALTER VIEW [dbo].[VW_CUENTAS_DPF_PRECANCELADOS](
								[Numero Solicitud],
								[Cuenta], -- 1850
								[Nombre], -- 410
								[Producto], -- 43759
								[Descripción], -- 5010
								[Moneda], -- 611
								[Sucursal], -- 43769
								[Operación], -- 4356
								[Ordinal], -- 9209
								[Cliente], -- 2611
								[Estado] -- 556
								) AS 
				SELECT	DC.NRO_SOLICITUD, 
						S.CUENTA, 
						C.NOMBRECLIENTE, 
						S.PRODUCTO, 
						P.C6251, 
						S.MONEDA, 
						S.SUCURSAL, 
						S.OPERACION, 
						S.ORDINAL, 
						S.C1803, 
						DC.ESTADO 
				FROM SALDOS AS S with (nolock) 
					inner join PRODUCTOS AS P with (nolock) on S.PRODUCTO= P.C6250
					inner join CLI_CLIENTES C with (nolock) on C.CODIGOCLIENTE = S.C1803 
					inner join DPF_PRE_CANCELACION DC with (nolock) on DC.JTSOID = S.JTS_OID 
				WHERE 
					S.TZ_LOCK = 0 
					AND P.TZ_LOCK = 0 
					AND C.TZ_LOCK = 0 
					AND S.C1785 = 4 
					AND S.C1604 <> 0
					AND DC.TZ_LOCK = 0;
					
					')
					
					
					EXECUTE('

UPDATE AYUDAS
SET CAMPOSVISTA=''Numero Solicitud;Sucursal;Cuenta;Nombre;Producto;Descripción;Moneda;Cliente;Ordinal;Operación;Estado;''
WHERE NUMERODEAYUDA=3453;

--Oper 5006


UPDATE OPERACIONES
SET NOMBRE=''Pre-Cancelación Depósito a Plazo'', DESCRIPCION=''Pre-Cancelación Depósito a Plazo''
WHERE TITULO=5000 AND IDENTIFICACION=5006;



')







