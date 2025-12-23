/****** Object:  View [dbo].[VW_CORRIMIENTO_VTO_DPF]    Script Date: 25/02/2021 9:55:55 ******/
DROP VIEW [dbo].[VW_CORRIMIENTO_VTO_DPF]
GO

/****** Object:  View [dbo].[VW_CORRIMIENTO_VTO_DPF]    Script Date: 25/02/2021 9:55:55 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VW_CORRIMIENTO_VTO_DPF](
										SUCURSAL,
										CUENTA,
										NOMBRE,
										PRODUCTO,
										DESCRIPCIONPRODUCTO,
										MONEDA,
										DESCRIPCIONMONEDA,
										CLIENTE
) AS 
				SELECT s.SUCURSAL, 
						s.CUENTA, 
						cl.NOMBRECLIENTE, 
						s.PRODUCTO, 
						p.C6251, 
						s.MONEDA, 
						m.C6400, 
						S.C1803
				FROM	SALDOS s with (nolock) 
						inner join CLI_CANALES c with (nolock) on s.C1800 = c.COD_CANAL
						inner join CLI_CLIENTES cl with (nolock)on s.C1803 = cl.[CODIGOCLIENTE]
						inner join PRODUCTOS p with (nolock) on s.PRODUCTO = p.C6250
						inner join MONEDAS m with (nolock) on s.MONEDA = m.C6399
						inner join PAROS pa with (nolock) on s.C1627 = pa.fecha
				WHERE s.C1627>=(SELECT FECHAPROCESO 
								FROM PARAMETROS with (nolock)
								) 
					AND s.C1785 = 4 
					AND s.C1604 > 0   
					AND s.C1659 = 'N'
					AND c.PRESENCIAL = 'S'
					AND ((pa.SUCURSAL = -1) OR (s.SUCURSAL  = pa.SUCURSAL AND pa.SUCURSAL <> -1))
					AND s.TZ_LOCK = 0
					AND c.TZ_LOCK = 0
					AND cl.TZ_LOCK = 0
					AND p.TZ_LOCK = 0
					AND m.TZ_LOCK = 0
GO


