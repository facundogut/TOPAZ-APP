/****** Object:  View [dbo].[VW_CUENTAS_DPF_PRECANCELADOS]    Script Date: 25/02/2021 10:32:54 ******/
DROP VIEW [dbo].[VW_CUENTAS_DPF_PRECANCELADOS]
GO

/****** Object:  View [dbo].[VW_CUENTAS_DPF_PRECANCELADOS]    Script Date: 25/02/2021 10:32:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VW_CUENTAS_DPF_PRECANCELADOS](
								[Numero Solicitud],
								[Cuenta], -- 1850
								[Nombre], -- 410
								[Producto], -- 43759
								[Descripcion], -- 5010
								[Moneda], -- 611
								[Sucursal], -- 43769
								[Operacion], -- 4356
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
GO


