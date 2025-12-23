/****** Object:  View [dbo].[VW_DPF_COTIZACIONESPECIE]    Script Date: 25/02/2021 9:48:56 ******/
DROP VIEW [dbo].[VW_DPF_COTIZACIONESPECIE]
GO

/****** Object:  View [dbo].[VW_DPF_COTIZACIONESPECIE]    Script Date: 25/02/2021 9:48:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VW_DPF_COTIZACIONESPECIE]
											(
											[Código Especie],
											[Descripción],
											[Cotización],
											Fecha
											)
AS
				SELECT	CT.[CODIGOESPECIE] AS [Código Especie], 
						CO.DESCRIPCION AS [Descripción], 
						CT.COTIZACION AS [Cotización], 
						CT.FECHA AS Fecha 
				FROM DPF_COTIZACION_ESPECIE CT with (nolock)
					inner join [DPF_CODIGOS_ESPECIE] CO with (nolock) on CT.[CODIGOESPECIE] = CO.[CODIGOESPECIE]
				WHERE	CT.TZ_LOCK = 0 
						AND CO.TZ_LOCK = 0;
GO


