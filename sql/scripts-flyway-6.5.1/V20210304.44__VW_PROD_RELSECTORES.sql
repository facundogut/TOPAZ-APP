/****** Object:  View [dbo].[VW_PROD_RELSECTORES]    Script Date: 24/02/2021 15:33:07 ******/
DROP VIEW [dbo].[VW_PROD_RELSECTORES]
GO

/****** Object:  View [dbo].[VW_PROD_RELSECTORES]    Script Date: 24/02/2021 15:33:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VW_PROD_RELSECTORES]
									(Producto, 
									[Descripción de Producto], 
									Sector, 
									[Descripción de Sector]
									)
AS
							SELECT  R.PRODUCTO, 
									P.C6251, 
									R.SECTOR, 
									S.DESCRIPCION
							FROM	PROD_RELSECTORES AS R with (nolock)
									inner join PRODUCTOS AS P with (nolock) on R.PRODUCTO = P.C6250
									inner join CLI_SECTORES AS S with (nolock) on R.SECTOR = S.SECTOR
							WHERE  
									R.TZ_LOCK = 0 
									AND P.TZ_LOCK = 0 
									AND S.TZ_LOCK = 0
GO


