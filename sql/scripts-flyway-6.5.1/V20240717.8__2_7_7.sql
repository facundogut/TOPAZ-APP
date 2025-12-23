Execute('DELETE FROM ITF_MASTER_PARAMETROS WHERE CODIGO IN (287, 288, 289, 290, 291, 292, 293)

INSERT INTO ITF_MASTER_PARAMETROS (CODIGO,CODIGO_INTERFACE,FUNCIONALIDAD,ALFA_1,ALFA_2,ALFA_3,NUMERICO_1,NUMERICO_2,FECHA,IMPORTE_1,IMPORTE_2,TZ_LOCK) VALUES
	 (287,277,''2.7.7 BEE TenenciaPF'',''TipoCuenta'',''Cuenta Corriente'','' '',2,0,NULL,0.00,0.00,0),
	 (288,277,''2.7.7 BEE TenenciaPF'',''TipoCuenta'',''Caja de Ahorros'','' '',3,1,NULL,0.00,0.00,0),
	 (289,277,''2.7.7 BEE TenenciaPF'',''CuentaEspecial'',''Cuenta Especial Persona Jurídica'','' '',3,5,NULL,3.00,0.00,0),
	 (290,277,''2.7.7 BEE TenenciaPF'',''Moneda'',''Peso'','' '',1,0,NULL,0.00,0.00,0),
	 (291,277,''2.7.7 BEE TenenciaPF'',''Moneda'',''Dolar'','' '',2,1,NULL,0.00,0.00,0),
	 (292,277,''2.7.7 BEE TenenciaPF'',''Moneda'',''UVI'','' '',998,2,NULL,0.00,0.00,0),
	 (293,277,''2.7.7 BEE TenenciaPF'',''Moneda'',''UVA'','' '',999,2,NULL,0.00,0.00,0);')
