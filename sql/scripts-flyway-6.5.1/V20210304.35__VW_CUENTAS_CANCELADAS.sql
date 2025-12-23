/****** Object:  View [dbo].[VW_CUENTAS_CANCELADAS]    Script Date: 24/02/2021 12:11:33 ******/
DROP VIEW [dbo].[VW_CUENTAS_CANCELADAS]
GO

/****** Object:  View [dbo].[VW_CUENTAS_CANCELADAS]    Script Date: 24/02/2021 12:11:33 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VW_CUENTAS_CANCELADAS](
										Cuenta,
										Nombre,
										Producto,
										Descripcion,
										Moneda,
										Sucursal,
										Cliente,
										[Codigo Motivo],
										Motivo,
										Fecha,
										JTS_OID
										) AS 
				SELECT C.CUENTA, 
						C.NOMBRE, 
						C.PRODUCTO, 
						C.DESCRIPCION, 
						C.MONEDA, 
						C.SUCURSAL, 
						C.CLIENTE,
						V.CODIGO_MOTIVO, 
						M.DESCRIPCION, 
						V.FECHA_CANCELACION, 
						C.JTS_OID
				FROM VW_CUENTAS C WITH (NOLOCK)
					INNER JOIN CV_CANCELACION_CUENTAS V WITH (NOLOCK) ON C.JTS_OID = V.SALDO_JTS_OID
					INNER JOIN CV_MOTIVOS_CANCELACION M WITH (NOLOCK) ON V.CODIGO_MOTIVO = M.CODIGO_MOTIVO
				WHERE   C.C1651 = '1'
						AND V.TZ_LOCK = 0 
						AND M.TZ_LOCK = 0
GO


