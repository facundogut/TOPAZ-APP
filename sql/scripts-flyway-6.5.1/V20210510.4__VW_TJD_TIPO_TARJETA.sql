


/****** Object:  View [dbo].[VW_TJD_TIPO_TARJETA]    Script Date: 24/02/2021 17:29:39 ******/
DROP VIEW [dbo].[VW_TJD_TIPO_TARJETA]
GO

/****** Object:  View [dbo].[VW_TJD_TIPO_TARJETA]    Script Date: 24/02/2021 17:29:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VW_TJD_TIPO_TARJETA] (
						Clase,
						Descripción_clase,
						Tipo,
						Descripción,
						Bin,
						Producto
)
AS
					SELECT TT.CLASE, 
							TC.Descripcion, 
							TT.TIPO_TARJETA, 
							TT.DESCRIPCION, 
							TT.BIN, 
							TT.[CODIGO_PRODUCTO]
					FROM TJD_TIPO_TARJETA TT with (nolock)
					INNER JOIN TJD_CLASE TC with (nolock) 
							ON TT.CLASE = TC.Clave
					WHERE TT.TZ_LOCK = 0 
						AND TC.TZ_LOCK = 0
GO


