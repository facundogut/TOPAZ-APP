/****** Object:  View [dbo].[VW_DPF_TASAS]    Script Date: 25/02/2021 10:48:20 ******/
DROP VIEW [dbo].[VW_DPF_TASAS]
GO

/****** Object:  View [dbo].[VW_DPF_TASAS]    Script Date: 25/02/2021 10:48:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VW_DPF_TASAS] (
								   TARIFA,
								   MONEDA,
								   DESCRIPCIONMONEDA,
								   PRODUCTO,
								   DESCRIPCIONPRODUCTO,
								   TIPOTASAINT,
								   PUNTOS,
								   VIGENCIADESDE,
								   VIGENCIAHASTA,
								   CLIENTE,
								   PLAZO,
								   IMPORTE)
AS 
				SELECT	T.TARIFA, 
						T.MONEDA, 
						M.C6400 AS DESCRIPCIONMONEDA, 
						T.PRODUCTO, 
						P.C6251 AS DESCRIPCIONPRODUCTO,
						T.TIPOTASAINT, 
						T.PUNTOS, 
						T.VIGENCIADESDE, 
						T.VIGENCIAHASTA, 
						T.CLIENTE, 
						T.PLAZO, 
						T.IMPORTE
				FROM Tasas T with (nolock)
					inner join PRODUCTOS P with (nolock) on T.PRODUCTO = P.C6250
					inner join MONEDAS M with (nolock) on T.MONEDA = M.C6399
				WHERE 
					T.TZ_LOCK = 0
					AND P.TZ_LOCK = 0
					AND M.TZ_LOCK = 0;
GO


