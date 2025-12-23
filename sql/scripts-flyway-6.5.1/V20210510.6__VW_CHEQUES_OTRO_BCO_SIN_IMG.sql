/****** Object:  View [dbo].[VW_CHEQUES_OTRO_BCO_SIN_IMG]    Script Date: 24/02/2021 12:47:37 ******/
DROP VIEW [dbo].[VW_CHEQUES_OTRO_BCO_SIN_IMG]
GO

/****** Object:  View [dbo].[VW_CHEQUES_OTRO_BCO_SIN_IMG]    Script Date: 24/02/2021 12:47:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VW_CHEQUES_OTRO_BCO_SIN_IMG] (
												   TZ_LOCK, 
												   NRO_ASIENTO, 
												   NRO_CHEQUE, 
												   BANCO, 
												   SUC_BANCO, 
												   NRO_CUENTA, 
												   CMC7,
												   NRO_DEPOSITO
												   )
													AS 
		SELECT DISTINCT
				s.TZ_LOCK,
				s.NRO_ASIENTO,
				s.NUMERO_CHEQUE,
				s.BANCO_GIRADO,
				s.SUCURSAL_BANCO_GIRADO,
				s.SUCURSAL_BANCO_GIRADO,
				s.CMC7,
				s.NUMERO_DEPOSITO
	FROM CLE_CHEQUES_SALIENTE s   with (nolock),
		PARAMETROSGENERALES P WITH (nolock)
	WHERE P.[CODIGO] = 2
		AND s.BANCO_GIRADO<>P.NUMERICO and NOT EXISTS 
											(	SELECT * 
												FROM CLE_IMG_CHEQUES with (nolock)
												WHERE CMC7=s.CMC7)
GO


