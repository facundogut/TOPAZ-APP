/****** Object:  View [dbo].[VW_PYF_APODERAMIENTO_PODER]    Script Date: 24/02/2021 16:03:53 ******/
DROP VIEW [dbo].[VW_PYF_APODERAMIENTO_PODER]
GO

/****** Object:  View [dbo].[VW_PYF_APODERAMIENTO_PODER]    Script Date: 24/02/2021 16:03:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VW_PYF_APODERAMIENTO_PODER] (
											   [Código_Apoderado], 
											   [Descripción_Apoderado], 
											   [Código_Poder], 
											   [Descripción_Poder])
AS 
   SELECT T.CODAPODERAMIENTO, 
			T.DESCRIPCION, 
			P.TIPO_PODER, 
			P.DESCRIPCION
   FROM PYF_APODERAMIENTO AS A with (nolock) 
		inner join PYF_TIPOPODERES AS P with (nolock)on A.CODPODER = P.TIPO_PODER 
		inner join PYF_TIPOAPODERAMIENTO AS T with (nolock) on T.CODAPODERAMIENTO = A.CODAPODERAMIENTO
   WHERE  
		A.TZ_LOCK = 0 
		AND P.TZ_LOCK = 0 
		AND T.TZ_LOCK = 0
GO


