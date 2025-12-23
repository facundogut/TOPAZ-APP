EXECUTE('
IF OBJECT_ID (''dbo.VW_CON_MOVIMIENTOS_IMPUESTOS_ME'') IS NOT NULL
	DROP VIEW dbo.VW_CON_MOVIMIENTOS_IMPUESTOS_ME
')
EXECUTE('
CREATE   VIEW [dbo].[VW_CON_MOVIMIENTOS_IMPUESTOS_ME] (ID_LIQUIDACION,
                                           FECHAPROCESO,
                                           SUCURSAL,
                                           ASIENTO,
                                           MONEDA,
                                           IMPORTE,
                                           SUCURSAL_CUENTA,
                                           DEBITOCREDITO,
                                           CUENTA,
                                           ORDINAL_CUENTA,
                                           RUBRO_ORIGEN,
                                           RUBRO_DESTINO,
                                           MARCAAJUSTE,
                                           CONCEPTO,
                                           FECHA_CONTABLE)
AS
SELECT 
	M.JTS_OID AS ID_LIQUIDACION,
	M.FECHAPROCESO, 
	M.SUCURSAL, 
	M.ASIENTO,
	M.MONEDA,
    M.CAPITALREALIZADO,
    M.SUCURSAL_CUENTA,
    M.DEBITOCREDITO,
    M.CUENTA,
    M.ORDINAL_CUENTA, 
    R.RUBRO_ORIGEN, 
    R.RUBRO_DESTINO,
    M.MARCAAJUSTE, 
    M.CONCEPTO, 
    M.FECHACONTABLE
FROM MOVIMIENTOS_CONTABLES AS M WITH (nolock)
JOIN ASIENTOS A ON 
	A.ASIENTO = M.ASIENTO 
	AND A.FECHAPROCESO = M.FECHAPROCESO 
	AND A.SUCURSAL = M.SUCURSAL 
	AND A.ESTADO = 77
JOIN CON_RUBRO_CONTABLE_ORIG_DEST_ME R ON 
	M.RUBROCONTABLE = R.RUBRO_ORIGEN
WHERE
	M.MONEDA NOT IN (SELECT C6399 FROM MONEDAS WHERE C6403 = ''N'')
	AND NOT EXISTS (SELECT * 
					FROM CON_MOVIMIENTOS_IMPUESTOS_ME AS M2
					WHERE
						M2.ASIENTO = M.ASIENTO
						AND M2.FECHAPROCESO = M.FECHAPROCESO
						AND M2.SUCURSAL = M.SUCURSAL
						AND M2.RESULTADO_EJECUCION = ''OK''
					)
')