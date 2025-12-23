/****** Object:  View [dbo].[VW_PROD_RELSEGMENTOS]    Script Date: 24/02/2021 15:36:14 ******/
DROP VIEW [dbo].[VW_PROD_RELSEGMENTOS]
GO

/****** Object:  View [dbo].[VW_PROD_RELSEGMENTOS]    Script Date: 24/02/2021 15:36:14 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VW_PROD_RELSEGMENTOS]
									(Producto, 
									[Descripción de Producto], 
									Segmento, 
									[Descripción de Segmento], 
									Subsegmento, 
									[Descripción de Subsegmento], 
									Comentario
									)
AS
						SELECT	R.PRODUCTO, 
								P.C6251, 
								R.SEGMENTO, 
								S.DESCRIPCION_SEGMENTO, 
								R.SUBSEGMENTO, 
								U.DESCRIPCION_SUBSEGMENTO, 
								R.COMENTARIO
						FROM	CLI_SEGMENTOS AS S with (nolock) 
								inner join PROD_RELSEGMENTOS AS R with (nolock) on S.COD_SEGMENTO = R.SEGMENTO 
								inner join CLI_SUBSEGMENTOS AS U with (nolock) on U.COD_SUBSEGMENTO = R.SUBSEGMENTO
																				and U.COD_SEGMENTO = R.SEGMENTO
								inner join PRODUCTOS AS P with (nolock) on P.C6250 = R.PRODUCTO
								
						WHERE	
								S.TZ_LOCK = 0 
								AND U.TZ_LOCK = 0 
								AND P.TZ_LOCK = 0 
								AND R.TZ_LOCK = 0
GO


