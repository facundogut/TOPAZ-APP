/****** Object:  View [dbo].[VW_PYF_TEXTOS]    Script Date: 24/02/2021 16:23:55 ******/
DROP VIEW [dbo].[VW_PYF_TEXTOS]
GO

/****** Object:  View [dbo].[VW_PYF_TEXTOS]    Script Date: 24/02/2021 16:23:55 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[VW_PYF_TEXTOS] AS
									SELECT a.ID_ENTIDAD AS IdEntidad,
											a.TIPO_ENTIDAD AS TipoEntidad,
											a.TIPO_PODER AS TipoPoder, 
											PT.DESCRIPCION AS DescripcionPoder,
											CASE WHEN a.TIPO_ENTIDAD=2 THEN
											ISNULL((SELECT TIPODOC FROM VW_CLI_X_DOC with (nolock) WHERE [CODIGOCLIENTE] = s.C1803),0) 
											ELSE
											ISNULL((SELECT TIPODOC FROM VW_CLI_X_DOC with (nolock) WHERE [CODIGOCLIENTE] = CAST(a.ID_ENTIDAD AS NUMERIC)),0) end
											AS TipoDoc,
											CASE WHEN a.TIPO_ENTIDAD=2 THEN
											ISNULL((SELECT NUMERODOC FROM VW_CLI_X_DOC with (nolock) WHERE [CODIGOCLIENTE] = s.C1803),0) 
											ELSE
											ISNULL((SELECT NUMERODOC FROM VW_CLI_X_DOC with (nolock) WHERE [CODIGOCLIENTE] = CAST(a.ID_ENTIDAD AS NUMERIC)),0) end
											AS NumDoc,
											isnull(s.CUENTA,0) AS Cuenta
									FROM PYF_TEXTOS a with (nolock)
										LEFT JOIN SALDOS s with (nolock) ON s.JTS_OID=a.ID_ENTIDAD 
																		AND a.TIPO_ENTIDAD=2 
																		AND s.TZ_LOCK=0																			
										INNER JOIN PYF_TIPOPODERES PT with (nolock) ON a.TIPO_PODER = PT.TIPO_PODER 
									WHERE	a.TZ_LOCK=0;
GO


