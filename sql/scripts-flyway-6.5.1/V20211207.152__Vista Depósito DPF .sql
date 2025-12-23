EXECUTE('
IF OBJECT_ID (''VW_DPF_OTRO_BCO_SIN_IMG_DEPOSITOS'') IS NOT NULL
	DROP VIEW VW_DPF_OTRO_BCO_SIN_IMG_DEPOSITOS
')


EXECUTE('
CREATE VIEW [VW_DPF_OTRO_BCO_SIN_IMG_DEPOSITOS] (
														   NRO_DEPOSITO,
														   SUCURSAL,
														   FECHA,
														   HORA,
														   CANTIDAD_DPF,
														   ASIENTO,
														   USUARIO
														   )
AS 
	   					SELECT
													s.NUMERO_DEPOSITO,
													s.SUCURSAL_DE_INGRESO,
													s.FECHA_ALTA,
													m.HORASISTEMA,
													COUNT(s.NUMERO_DPF),
													s.NRO_ASIENTO,
													s.[CODIGO_USUARIO]
											FROM	PARAMETROSGENERALES P WITH (nolock),
													CLE_DPF_SALIENTE s with (nolock)
													inner join MOVIMIENTOS_CONTABLES m with (nolock) on s.NRO_ASIENTO = m.ASIENTO 
																										and s.RUBRO_CONTABLE = m.RUBROCONTABLE
																										AND m.FECHAPROCESO=s.FECHA_ALTA
																										AND m.SUCURSAL=s.SUCURSAL_DE_INGRESO
											WHERE   P.[CODIGO] = 2 AND
													s.BANCO_GIRADO<>P.NUMERICO 
													and NOT EXISTS (SELECT * 
																	FROM CLE_IMG_CHEQUES 
																	WHERE CMC7=s.BANDA
																	)
													AND s.TZ_LOCK =0 

											GROUP BY s.NUMERO_DEPOSITO,  
												s.NRO_ASIENTO, 
												s.SUCURSAL_DE_INGRESO, 
												s.FECHA_ALTA, 
												s.[CODIGO_USUARIO], 
												m.HORASISTEMA
 
')


