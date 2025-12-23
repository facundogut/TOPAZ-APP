/****** Object:  View [dbo].[VW_PROD_CANALES]    Script Date: 24/02/2021 15:21:21 ******/
DROP VIEW [dbo].[VW_PROD_CANALES]
GO

/****** Object:  View [dbo].[VW_PROD_CANALES]    Script Date: 24/02/2021 15:21:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VW_PROD_CANALES] (
								   [Producto], 
								   [Descripción_producto], 
								   [Moneda], 
								   [Descripción_moneda],
								   [Canal],
								   [Descripción_canal],
								   [Habilitado])
AS 
				   SELECT P.C6250, 
							P.C6251, 
							M.C6399, 
							M.C6400, 
							C.COD_CANAL, 
							C.DSC_CANAL,
						   CASE 
						   WHEN R.HABILITADO = 'S' THEN 'Sí'
						   WHEN R.HABILITADO = 'N' THEN 'No'
						   END AS Habilitado
				   FROM PRODUCTOS AS P with (nolock)
						inner join PROD_RELCANALES AS R with (nolock) on R.PRODUCTO = P.C6250
						inner join MONEDAS AS M with (nolock) on M.C6399 = R.MONEDA
						inner join CLI_CANALES AS C with (nolock) on C.COD_CANAL = R.CANAL
				   WHERE  
							P.TZ_LOCK = 0 
							AND M.TZ_LOCK = 0 
							AND C.TZ_LOCK = 0 
							AND R.TZ_LOCK = 0
GO


