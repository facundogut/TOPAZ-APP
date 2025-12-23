EXECUTE('
----
IF OBJECT_ID (''dbo.VW_ULTIMOS_10_MOVS_2'') IS NOT NULL
	DROP VIEW dbo.VW_ULTIMOS_10_MOVS_2
----
')

EXECUTE('
----
CREATE   VIEW [dbo].[VW_ULTIMOS_10_MOVS_2] (	FECHA_REAL_MOV,
													FECHAPROCESO, 
													HORASISTEMA, 
													CLIENTE, 
													SUCURSAL_CUENTA, 
													CUENTA, 
													MONEDA, 
													PRODUCTO, SUCURSAL, 
													FECHAVALOR, 
													ASIENTO, 
													COD_TRANSACCION, 
													DESC_TRANSACCION, 
													CONCEPTO, 
													CAPITALREALIZADO, 
													DEBITOCREDITO, 
													NUMERO_CHEQUE, 
													OPERACION_CUENTA, 
													ORDINAL_CUENTA, 
													INIUSR, 
													OPERACION_TOPAZ,
													NROCAJA, 
													SALDO_JTS_OID,
													REGISTROS)
AS 

SELECT	
		CASE
    		WHEN m.marcaajuste = ''A''
        		THEN m.fechavalor
    		ELSE m.fechaproceso
		END AS fechareporte,
		m.fechaproceso,
		CONVERT(VARCHAR(8),a.HORAFIN, 108) AS HoraFin,
		m.cliente,
		m.sucursal_cuenta,
		m.cuenta,
		m.moneda,
		m.producto,
		m.sucursal,
		m.fechavalor,
		m.asiento,
		m.cod_transaccion,
		ISNULL(t.DESCRIPCION,'' ''),
		m.concepto,
		m.capitalrealizado,
		m.debitocredito,
		m.referencia as Numero_Cheque,
		m.operacion_cuenta,
		m.ordinal_cuenta,
		m.inicialesusuario as IniUsr,
		m.operacion as Operacion_Topaz,
		m.nrocaja,
		m.SALDO_JTS_OID,
		ISNULL((SELECT TOP 1 COUNT(*) OVER (PARTITION BY SALDO_JTS_OID) FROM VW_ULTIMOS_10_MOVS 
			WHERE SALDO_JTS_OID = m.SALDO_JTS_OID),0)
FROM asientos a with (nolock) 
inner join movimientos_contables m with (nolock) on m.fechaproceso = a.fechaproceso
											AND m.sucursal   = a.sucursal
											AND m.asiento    = a.asiento
											AND a.estado     = 77 
											AND rtrim(ltrim(m.debitocredito)) IS NOT NULL 
left join TTR_CODIGO_TRANSACCION_DEF t with (nolock) on m.COD_TRANSACCION = t.CODIGO_TRANSACCION
----
')

