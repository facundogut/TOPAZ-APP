/****** Object:  View [dbo].[VW_DPF_DOCSDISPONIBLES]    Script Date: 25/02/2021 9:51:39 ******/
DROP VIEW [dbo].[VW_DPF_DOCSDISPONIBLES]
GO

/****** Object:  View [dbo].[VW_DPF_DOCSDISPONIBLES]    Script Date: 25/02/2021 9:51:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VW_DPF_DOCSDISPONIBLES] (
										   [Id Documento],
										   [Tipo Documento],
										   [Descripcion Tipo Documento],
										   [Sucursal],
										   [Codigo Deposito],
										   [Lote])
AS
				SELECT ID_DOCUMENTO, 
						tip.[CODIGO] , 
						tip.DESCRIPCION , 
						dep.SUCURSAL, 
						[CODIGO_DEPOSITO], 
						LOTE
				FROM DPF_DOCS_DOCUMENTOS d with (nolock)
				INNER JOIN DPF_DOCS_DEPOSITOS dep with (nolock) ON	[CODIGO_DEPOSITO] = dep.[CODIGO]
				INNER JOIN DPF_DOCS_TIPO tip with (nolock) ON [CODIGO_TIPO] = tip.[CODIGO]
				WHERE ESTADO_DOCUMENTO = 1
						AND d.TZ_LOCK = 0
						AND dep.TZ_LOCK = 0
						AND tip.TZ_LOCK = 0
GO


