EXECUTE('
------------------------------------
--VW_CLE_CHEQUES_CLEARING_RECIBIDO--
------------------------------------
CREATE VIEW VW_CLE_CHEQUES_CLEARING_RECIBIDO
										(NRO_CHEQUE, 
										SUCURSAL, 
										CUENTA, 
										DENOMINACION_CUENTA, 
										PRODUCTO, 
										DESC_PRODUCTO, 
										MONEDA, 
										IMPORTE, 
										CAUSAL, 
										DESC_CAUSAL, 
										FECHA
										)
										AS
								SELECT R.NUMERO_CHEQUE, 
								 		R.SUCURSAL, 
								 		R.CUENTA, 
								 		V.NOMBRE_CUENTA, 
								 		R.PRODUCTO, 
								 		P.C6251, 
								 		R.MONEDA, 
								 		R.IMPORTE_CHEQUE, 
								 		R.CODIGO_CAUSAL_DEVOLUCION, 
								 		C.DESCRIPCION, 
								 		R.FECHA
								FROM CLE_CHEQUES_CLEARING_RECIBIDO AS R WITH (nolock)
									INNER JOIN SALDOS AS S WITH (nolock) ON R.SUCURSAL = S.SUCURSAL 
																			AND R.MONEDA = S.MONEDA 
																			AND R.CUENTA = S.CUENTA 
																			AND R.PRODUCTO = S.PRODUCTO 
																			AND R.OPERACION = S.OPERACION 
																			AND S.ORDINAL = 0 
																			AND S.TZ_LOCK = 0
									INNER JOIN VTA_SALDOS AS V WITH (nolock) ON S.JTS_OID = V.JTS_OID_SALDO 
																			AND V.TZ_LOCK = 0
									INNER JOIN PRODUCTOS AS P WITH (nolock) ON R.PRODUCTO = P.C6250 
																			AND P.TZ_LOCK = 0
									LEFT JOIN CLE_TIPO_CAUSAL AS C WITH (nolock) ON R.CODIGO_CAUSAL_DEVOLUCION = C.CODIGO_DE_CAUSAL
																			AND C.TZ_LOCK = 0
----
')