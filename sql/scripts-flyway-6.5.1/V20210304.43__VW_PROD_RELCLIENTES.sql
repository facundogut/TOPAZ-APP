/****** Object:  View [dbo].[VW_PROD_RELCLIENTES]    Script Date: 24/02/2021 15:29:22 ******/
DROP VIEW [dbo].[VW_PROD_RELCLIENTES]
GO

/****** Object:  View [dbo].[VW_PROD_RELCLIENTES]    Script Date: 24/02/2021 15:29:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VW_PROD_RELCLIENTES]
									(
									Apoderamiento, 
									[Descripción de Apoderamiento], 
									Producto, 
									[Descripción de Producto], 
									[Titular / Apoderado], 
									[Tipo de Cliente]
									)
AS
							SELECT R.APODERAMIENTO, 
									A.DESCRIPCION, 
									R.PRODUCTO, 
									P.C6251, 
									R.TITULAR_APODERADO, 
									R.TIPO_CLIENTE
							FROM PYF_TIPOAPODERAMIENTO AS A with (nolock) 
								inner join PROD_RELCLIENTE AS R with (nolock) on A.CODAPODERAMIENTO = R.APODERAMIENTO
								inner join PRODUCTOS AS P with (nolock) on P.C6250 = R.PRODUCTO
							WHERE  
									A.TZ_LOCK = 0 
									AND P.TZ_LOCK = 0 
									AND R.TZ_LOCK = 0
GO


