EXECUTE('
----------------------
--MODIFICACIÓN VISTA--
----------------------
CREATE VIEW VW_IO_CAPTURA_DPF (
								"Número Plazo Fijo",
								"Número Cuenta",
								"Banco Emisor",
								"Sucursal Banco Emisor",
								"Código Postal",
								Moneda,
								Importe,
								"Fecha Vencimiento",
								Referencia,
								JTS_OID )
AS
		
		SELECT NUM_CHEQUE, 
		NUM_CUENTA, 
		BANCO_EMISOR, 
		SUC_BANCO_EMISOR, 
		COD_POSTAL,
		MONEDA,
		IMPORTE,
		FECHA_APLIC_CHEQUE, 
		REFERENCIA,
		JTS_OID
		FROM IO_CAPTURA_CHEQUES WITH (nolock)
		WHERE TZ_LOCK=0
		AND STATUS=1
-----
')