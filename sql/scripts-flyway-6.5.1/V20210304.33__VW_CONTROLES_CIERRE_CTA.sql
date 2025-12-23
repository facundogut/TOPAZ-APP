/****** Object:  View [dbo].[VW_CONTROLES_CIERRE_CTA]    Script Date: 24/02/2021 12:16:33 ******/
DROP VIEW [dbo].[VW_CONTROLES_CIERRE_CTA]
GO

/****** Object:  View [dbo].[VW_CONTROLES_CIERRE_CTA]    Script Date: 24/02/2021 12:16:33 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VW_CONTROLES_CIERRE_CTA] (
											   CONTROL,
											   DESCRIPCION,
											   ESTADO,
											   TIPO,
											   SUCURSAL,
											   PRODUCTO,
											   CUENTA,
											   MONEDA,
											   OPERACION,
											   ORDINAL
											   )
AS 
   SELECT
      O.OPCIONINTERNA AS OPCION,
      O.DESCRIPCION,
      CASE 
      WHEN C.ESTADO = 'R' THEN 'Realizado'
      WHEN C.ESTADO = 'S' THEN 'Sin realizar'
      END,
      CASE 
      WHEN C.TIPO_CONTROL = 'M' THEN 'Manual'
      WHEN C.TIPO_CONTROL = 'A' THEN 'Automático'
      END,
      C.SUCURSAL,
      C.PRODUCTO,
      C.CUENTA,
      C.MONEDA,
      C.OPERACION,
      C.ORDINAL
   FROM 
      dbo.OPCIONES AS O WITH (NOLOCK)
      INNER JOIN dbo.VTA_CONT_CIERRE_CTA AS C WITH (NOLOCK) ON O.OPCIONINTERNA = C.CONTROL 
   WHERE 
      O.NUMERODECAMPO = 34549 
	  AND O.IDIOMA = 'E'
GO


