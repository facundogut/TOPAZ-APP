/****** Object:  View [dbo].[VW_CHE_CHEQUES]    Script Date: 24/02/2021 12:43:41 ******/
DROP VIEW [dbo].[VW_CHE_CHEQUES]
GO

/****** Object:  View [dbo].[VW_CHE_CHEQUES]    Script Date: 24/02/2021 12:43:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VW_CHE_CHEQUES]
								(SUCURSAL,
								CUENTA,
								DENOMINACION_CUENTA,
								PRODUCTO,
								DESCRIPCION_PRODUCTO,
								MONEDA,SERIE,
								NUMERO_CHEQUE,
								IMPORTE,
								ESTADO,
								FECHA_ESTADO,
								TIPO_DOCUMENTO,
								NUMERO_DOCUMENTO
								)
								AS
					SELECT CH.SUCURSAL,
							CH.CUENTA,
							V.NOMBRE_CUENTA,
							CH.PRODUCTO,
							P.C6251,
							CH.MONEDA,
							CH.SERIE,
							CH.NUMEROCHEQUE,
							CH.IMPORTE,
							E.DESCRIPCION,
							CH.FECHAESTADO,
							C.TIPODOC,
							C.NUMERODOC
					FROM CHE_CHEQUES AS CH with (nolock)
							LEFT JOIN SALDOS AS S with (nolock) ON CH.SUCURSAL=S.SUCURSAL 
																	AND CH.PRODUCTO=S.PRODUCTO 
																	AND CH.CUENTA=S.CUENTA 
																	AND CH.MONEDA=S.MONEDA 
																	AND CH.OPERACION=S.OPERACION 
																	AND CH.ORDINAL=S.ORDINAL 
																	AND S.TZ_LOCK = 0
							LEFT JOIN VTA_SALDOS AS V with (nolock) ON S.JTS_OID = V.JTS_OID_SALDO 
																	AND V.TZ_LOCK = 0
							LEFT JOIN PRODUCTOS AS P with (nolock) ON CH.PRODUCTO = P.C6250 
																	AND P.TZ_LOCK = 0
							LEFT JOIN VW_CLI_X_DOC AS C with (nolock) ON S.C1803 = C.[CODIGOCLIENTE]
							LEFT JOIN CHE_ESTADOSCHEQUES AS E with (nolock) ON CH.ESTADO = E.[CODIGO] 
																			AND E.TZ_LOCK = 0
					WHERE CH.TZ_LOCK = 0
GO


