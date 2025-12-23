EXECUTE('
IF OBJECT_ID (''VW_DPF_OTRO_BCO_SIN_IMG'') IS NOT NULL
	DROP VIEW VW_DPF_OTRO_BCO_SIN_IMG
')


EXECUTE('
CREATE VIEW [VW_DPF_OTRO_BCO_SIN_IMG] (
												   TZ_LOCK, 
												   NRO_ASIENTO, 
												   NRO_DPF, 
												   BANCO, 
												   SUC_BANCO, 
												   NRO_CUENTA,
												   COD_POSTAL,
												   FECHA_VENCIMIENTO, 
												   NRO_DEPOSITO
												   )
													AS 
		SELECT DISTINCT
				s.TZ_LOCK,
				s.NRO_ASIENTO,
				s.NUMERO_DPF,
				s.BANCO_GIRADO,
				s.SUCURSAL_BANCO_GIRADO,
				s.NUMERICO_CUENTA_GIRADORA,
				s.COD_POSTAL,
				s.FECHA_VENCIMIENTO,
			   	s.NUMERO_DEPOSITO
	FROM CLE_DPF_SALIENTE s   with (nolock),
		PARAMETROSGENERALES P WITH (nolock)
	WHERE P.[CODIGO] = 2
		AND s.BANCO_GIRADO<>P.NUMERICO and NOT EXISTS 
											(	SELECT * 
												FROM CLE_IMG_CHEQUES with (nolock)
												WHERE CMC7=s.BANDA)
')



