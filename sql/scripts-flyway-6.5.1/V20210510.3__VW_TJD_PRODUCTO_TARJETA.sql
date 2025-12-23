/****** Object:  View [dbo].[VW_TJD_PRODUCTO_TARJETA]    Script Date: 24/02/2021 17:28:17 ******/
DROP VIEW [dbo].[VW_TJD_PRODUCTO_TARJETA]
GO

/****** Object:  View [dbo].[VW_TJD_PRODUCTO_TARJETA]    Script Date: 24/02/2021 17:28:17 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VW_TJD_PRODUCTO_TARJETA] AS 
		SELECT p.PRODUCTO AS 'Cod_Producto', 
				p.DETALLE AS 'Detalle' , 
				t.clase AS 'Cod_Clase',
				c.Descripcion AS 'Clase', 
				t.TIPO_TARJETA AS 'Cod_Tipo_Tarjeta', 
				t.DESCRIPCION AS 'Tipo_Tarjeta'
		FROM PROD_RELTARJETAS p with (nolock)
		INNER JOIN TJD_TIPO_TARJETA t with (nolock) ON p.TARJETA=t.TIPO_TARJETA
		INNER JOIN TJD_CLASE c with (nolock) ON c.Clave= t.CLASE
		WHERE p.TZ_LOCK=0 AND t.TZ_LOCK=0;
GO


