/****** Object:  View [dbo].[VW_CHEQUES_OTRO_BCO_SIN_IMG_DEPOSITOS]    Script Date: 24/02/2021 12:49:40 ******/
DROP VIEW [dbo].[VW_CHEQUES_OTRO_BCO_SIN_IMG_DEPOSITOS]
GO

/****** Object:  View [dbo].[VW_CHEQUES_OTRO_BCO_SIN_IMG_DEPOSITOS]    Script Date: 24/02/2021 12:49:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VW_CHEQUES_OTRO_BCO_SIN_IMG_DEPOSITOS] (
														   NRO_DEPOSITO,
														   SUCURSAL,
														   FECHA,
														   HORA,
														   CANTIDAD_CHEQUES,
														   ASIENTO,
														   USUARIO
														   )
AS 
		SELECT
													s.NUMERO_DEPOSITO,
													s.SUCURSAL_DE_INGRESO,
													s.FECHA_ALTA,
													m.HORASISTEMA,
													COUNT(s.NUMERO_CHEQUE),
													s.NRO_ASIENTO,
													s.[CODIGO_USUARIO]
											FROM	PARAMETROSGENERALES P WITH (nolock),
													CLE_CHEQUES_SALIENTE s with (nolock)
													inner join MOVIMIENTOS_CONTABLES m with (nolock) on s.NRO_ASIENTO = m.ASIENTO 
																										and s.RUBRO_CONTABLE = m.RUBROCONTABLE
											WHERE   P.[CODIGO] = 2 AND
													s.BANCO_GIRADO<>P.NUMERICO 
													and NOT EXISTS (SELECT * 
																	FROM CLE_IMG_CHEQUES 
																	WHERE CMC7=s.CMC7
																	)
													AND s.TZ_LOCK =0 

											GROUP BY s.NUMERO_DEPOSITO,  
												s.NRO_ASIENTO, 
												s.SUCURSAL_DE_INGRESO, 
												s.FECHA_ALTA, 
												s.[CODIGO_USUARIO], 
												m.HORASISTEMA
	--ORDER BY s.FECHA_ALTA
GO


