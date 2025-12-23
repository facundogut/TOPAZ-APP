/****** Object:  View [dbo].[VW_COFRES]    Script Date: 24/02/2021 13:14:27 ******/
DROP VIEW [dbo].[VW_COFRES]
GO

/****** Object:  View [dbo].[VW_COFRES]    Script Date: 24/02/2021 13:14:27 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VW_COFRES] ([CODIGO_COFRE], 
								SECTOR, 
								NUMERO, 
								NRO_DEPENDENCIA, 
								NOM_DEPENDENCIA, 
								ESTADO_COFRE, 
								MONEDA_IMPORTE, 
								PRECIO, 
								[CODIGO_TIPO], 
								DESCRIPCION_TIPO, 
								[LARGO], 
								ANCHO, 
								ALTO, 
								MONEDA) 
AS
			SELECT
				C.[CODIGO] AS [CODIGO_COFRE],
				C.SECTOR,
				C.NUMERO_COFRE AS NUMERO,
				C.DEPENDENCIA AS NRO_DEPENDENCIA,
				S.NOMBRESUCURSAL AS NOM_DEPENDENCIA,
				C.ESTADO AS ESTADO_COFRE,
				CA.MONEDA_IMPORTE,
				CA.IMPORTE_APLICAR AS PRECIO,
				C.TIPO AS [CODIGO_TIPO],
				CT.DESCRIPCION,
				CT.[LARGO],
				CT.ANCHO,
				CT.ALTO,
				CA.MONEDA
			FROM
				COF_COFRES AS C with (nolock)
				inner join COF_COFRES_TIPO AS CT with (nolock) on C.TIPO = CT.TIPO
				inner join SUCURSALES AS S with (nolock) on C.DEPENDENCIA = S.SUCURSAL
				inner join [CI_CARGOS_TARIFAS] AS CA with (nolock) on CA.SEGMENTO=C.TIPO
			WHERE
				CA.[ID_CARGO] = 210 
				AND CA.MONEDA IN (SELECT MONNAC 
									FROM PARAMETROS with (nolock)
								 )
			--	AND substring(CA.SEGMENTO, 1, 1) = C.TIPO
			--	AND substring(CA.SEGMENTO, 2, 3) = CAST(C.DEPENDENCIA AS VARCHAR(5))
				AND C.TZ_LOCK = 0
				AND CT.TZ_LOCK = 0
				AND CA.TZ_LOCK = 0
				AND S.TZ_LOCK = 0;
GO


