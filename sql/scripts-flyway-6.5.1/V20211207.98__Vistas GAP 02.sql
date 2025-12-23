EXECUTE('
---------------------------------
--VISTA SOLICITUD CANJE INTERNO--
---------------------------------
CREATE VIEW VW_CHE_SOLICITUD_CANJE_INTERNO
									(NRO_SOLICITUD, 
									NRO_CHEQUE, 
									IMPORTE, 
									ESTADO,
									DESCRIPCION_ESTADO, 
									FECHA_ESTADO, 
									SUCURSAL, 
									CUENTA, 
									DENOMINACION_CUENTA, 
									PRODUCTO, 
									DESCRIPCION_PRODUCTO, 
									MONEDA, 
									DENOM_CTA_DEPOSITO, 
									OPERATIVA,
									DESCRIPCION_OPERATIVA,
									ASIENTO,
									FECHA_ASIENTO,
									SUCURSAL_ASIENTO)
							AS
							SELECT C.NRO_SOLICITUD, 
									C.NRO_CHEQUE, 
									C.IMPORTE,
									C.ESTADO, 
									OE.DESCRIPCION, 
									C.FECHA_ESTADO, 
									S.SUCURSAL, 
									S.CUENTA, 
									V.NOMBRE_CUENTA, 
									S.PRODUCTO, 
									P.C6251, 
									S.MONEDA, 
									V2.NOMBRE_CUENTA,
									C.OPERATIVA, 
									OO.DESCRIPCION,
									C.ASIENTO,
									C.FECHA_ASIENTO,
									C.SUCURSAL_ASIENTO
							FROM CHE_SOLICITUD_CANJE_INTERNO AS C WITH (nolock)
							INNER JOIN SALDOS AS S WITH (nolock) ON C.SALDO_JTS_OID = S.JTS_OID 
																AND S.TZ_LOCK = 0
							INNER JOIN OPCIONES AS OE WITH (nolock) ON C.ESTADO = OE.OPCIONINTERNA 
																AND OE.NUMERODECAMPO = 35017 
																AND OE.IDIOMA = ''E''
							LEFT JOIN VTA_SALDOS AS V WITH (nolock) ON S.JTS_OID = V.JTS_OID_SALDO 
																AND V.TZ_LOCK = 0
							LEFT JOIN PRODUCTOS AS P WITH (nolock) ON S.PRODUCTO = P.C6250 
																AND P.TZ_LOCK = 0
							LEFT JOIN CLI_CLIENTES AS L WITH (nolock) ON S.C1803 = L.CODIGOCLIENTE 
																AND L.TZ_LOCK = 0
							LEFT JOIN CLI_CLIENTEPERSONA AS CP WITH (nolock) ON L.CODIGOCLIENTE = CP.CODIGOCLIENTE 
																AND CP.TITULARIDAD = ''T'' 
																AND CP.TZ_LOCK = 0
							LEFT JOIN CLI_DocumentosPFPJ AS D WITH (nolock) ON CP.NUMEROPERSONA = D.NUMEROPERSONAFJ 
																AND D.TZ_LOCK = 0
							LEFT JOIN VTA_SALDOS AS V2 WITH (nolock) ON C.JTS_OID_DEPOSITO = V2.JTS_OID_SALDO 
																AND V2.TZ_LOCK = 0
							LEFT JOIN OPCIONES AS OO WITH (nolock) ON C.OPERATIVA = OO.OPCIONINTERNA 
																AND OO.NUMERODECAMPO = 35024 
																AND OO.IDIOMA = ''E''
							WHERE (C.TZ_LOCK = 0)
----
')