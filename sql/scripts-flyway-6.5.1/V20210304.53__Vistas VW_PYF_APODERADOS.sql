/****** Object:  View [dbo].[VW_PYF_APODERADOS]    Script Date: 24/02/2021 15:41:12 ******/
DROP VIEW [dbo].[VW_PYF_APODERADOS]
GO

/****** Object:  View [dbo].[VW_PYF_APODERADOS]    Script Date: 24/02/2021 15:41:12 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VW_PYF_APODERADOS] AS
SELECT	a.TIPO_ENTIDAD AS [TipoEntidad],
		te.DESCRIPCION AS [DescEntidad],
		a.ID_ENTIDAD AS [IdEntidad],
		isnull(s.CUENTA,0) AS Cuenta,
		CASE WHEN a.TIPO_ENTIDAD = 2
				THEN (isnull(vs.NOMBRE_CUENTA, ''))
			 WHEN a.TIPO_ENTIDAD = 1
			 	THEN (ISNULL((SELECT NOMBRE 
							  FROM VW_PERSONAS_F_Y_J with (nolock) 
							  WHERE NUMEROPERSONA = a.ID_PERSONA),'')) 
		END AS Denominacion,
		a.TIPO_PODER AS [TipoPoder], 
		tp.DESCRIPCION AS [DescPoder],
		ISNULL((SELECT TipoDocIdent 
				FROM VW_PERSONAS_F_Y_J with (nolock)
				WHERE NUMEROPERSONA = a.ID_PERSONA),0) AS [TipoDoc],
		ISNULL((SELECT NroDocIdent 
				FROM VW_PERSONAS_F_Y_J with (nolock) 
				WHERE NUMEROPERSONA = a.ID_PERSONA),0) AS [NroDoc],
		ISNULL((SELECT NOMBRE 
				FROM VW_PERSONAS_F_Y_J with (nolock) 
				WHERE NUMEROPERSONA = a.ID_PERSONA),'') AS Nombre,
		a.[CATEGORIA] AS [Categoria],
		a.MONEDA_MONTO_INDIV AS [MonedaMontoIndiv],
		a.MONTO_MAX_INDIV AS [MontoMaxIndiv],
		a.MONEDA_MONTO_GRUPAL AS [MonedaMontoGrupal],
		a.MONTO_MAX_GRUPAL AS [MontoMaxGrupal],
		a.FECHA_VENCIMIENTO AS [FechaVto], 
		a.FECHA_INI_VIGENCIA AS [FechaIniVigencia],
		a.FECHA_INI_SUSPENSION AS [FechaIniSuspension], 
		a.FECHA_FIN_SUSPENSION AS [FechaFinSuspension],
		a.ID_PERSONA AS [IdPersona]
FROM PYF_APODERADOS a with (nolock)
	LEFT JOIN SALDOS s with (nolock) ON s.JTS_OID=a.ID_ENTIDAD AND s.TZ_LOCK = 0
	LEFT JOIN VTA_SALDOS vs with (nolock) ON vs.JTS_OID_SALDO = s.JTS_OID AND vs.TZ_LOCK = 0
	LEFT JOIN PYF_TIPOPODERES tp with (nolock) ON a.TIPO_PODER = tp.TIPO_PODER AND tp.TZ_LOCK = 0
	LEFT JOIN PYF_TIPOENTIDAD te with (nolock) ON a.TIPO_ENTIDAD = te.TIPO_ENTIDAD AND te.TZ_LOCK = 0
WHERE a.TZ_LOCK=0
--AND a.TIPO_ENTIDAD=2 
--AND s.TZ_LOCK=0 AND vs.TZ_LOCK = 0 AND tp.TZ_LOCK = 0 AND te.TZ_LOCK = 0
GO