EXECUTE('
IF OBJECT_ID (''dbo.VW_CUENTAS_DPF'') IS NOT NULL
	DROP VIEW dbo.VW_CUENTAS_DPF
')

EXECUTE('

CREATE VIEW [dbo].[VW_CUENTAS_DPF](
									CUENTA,
									NOMBRE,
									PRODUCTO,
									DESCRIPCION,
									MONEDA,
									SUCURSAL,
									OPERACION,
									ORDINAL,
									CLIENTE
								) 
AS 
		SELECT S.CUENTA, 
				C.NOMBRECLIENTE, 
				S.PRODUCTO, 
				P.C6251, 
				S.MONEDA, 
				S.SUCURSAL, 
				S.OPERACION, 
				S.ORDINAL, 
				S.C1803
		FROM	SALDOS AS S with (nolock) 
				inner join PRODUCTOS AS P with (nolock)on S.PRODUCTO= P.C6250 
				inner join CLI_CLIENTES C with (nolock)on C.CODIGOCLIENTE = S.C1803
		WHERE 
			S.TZ_LOCK = 0 
			AND P.TZ_LOCK = 0 
			AND  C.TZ_LOCK = 0 
			AND S.C1785 = 4 
			AND (S.C1604 != 0 OR S.C1734 = ''U'' OR S.C1734 = ''T'')

')
