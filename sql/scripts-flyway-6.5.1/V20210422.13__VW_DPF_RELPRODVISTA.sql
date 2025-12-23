


/****** Object:  View [dbo].[VW_DPF_RELPRODVISTA]    Script Date: 24/02/2021 17:51:21 ******/
DROP VIEW [dbo].[VW_DPF_RELPRODVISTA]
GO

/****** Object:  View [dbo].[VW_DPF_RELPRODVISTA]    Script Date: 24/02/2021 17:51:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VW_DPF_RELPRODVISTA] (
										   PRODUCTOPLAZO, 
										   DESC_PRODUCTOPLAZO, 
										   PRODUCTOVISTA, 
										   DESC_PRODUCTOVISTA
										  )
AS 
		Select ProductoPlazo, 
					(Select C6251 
					from PRODUCTOS with (nolock) 
					where C6250 = ProductoPlazo) as 'Desc_ProductoPlazo',
			   ProductoVista,
					(Select C6251 
					from PRODUCTOS with (nolock)
					where C6250 = ProductoVista) as 'Desc_ProductoVista'
		FROM DPF_RELPRODVISTA dr with (nolock)
		WHERE TZ_LOCK = 0 ;
GO


