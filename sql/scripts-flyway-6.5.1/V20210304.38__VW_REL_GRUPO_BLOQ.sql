/****** Object:  View [dbo].[VW_REL_GRUPO_BLOQ]    Script Date: 24/02/2021 16:49:55 ******/
DROP VIEW [dbo].[VW_REL_GRUPO_BLOQ]
GO

/****** Object:  View [dbo].[VW_REL_GRUPO_BLOQ]    Script Date: 24/02/2021 16:49:55 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VW_REL_GRUPO_BLOQ] (
   [Código_Bloqueo], 
   [Descripción], 
   [Grupo_Bloqueo], 
   [Grupo_Desbloqueo])
AS 
   SELECT R.COD_BLOQUEO, C.DESCRIPCION, R.GRUPO_BLOQUEO, R.GRUPO_DESBLOQUEO
   FROM GRL_COD_BLOQUEOS AS C with (nolock) 
		inner join GRL_REL_BLOQUEO_SEGURIDAD AS R with (nolock)on C.COD_BLOQUEO = R.COD_BLOQUEO 
   WHERE R.TZ_LOCK = 0 
		AND C.TZ_LOCK = 0
GO


