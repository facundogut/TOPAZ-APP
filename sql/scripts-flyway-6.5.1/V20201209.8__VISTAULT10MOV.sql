EXECUTE('
IF OBJECT_ID (''dbo.VW_ULTIMOS_10_MOVS'') IS NOT NULL
	DROP VIEW dbo.VW_ULTIMOS_10_MOVS
')

EXECUTE('
CREATE VIEW [VW_ULTIMOS_10_MOVS] (FECHAPROCESO, HORASISTEMA, CLIENTE, SUCURSAL_CUENTA, CUENTA, MONEDA, PRODUCTO, SUCURSAL, FECHAVALOR, ASIENTO, COD_TRANSACCION, DESC_TRANSACCION, CONCEPTO, CAPITALREALIZADO, DEBITOCREDITO, NUMERO_CHEQUE, OPERACION_CUENTA, ORDINAL_CUENTA, INIUSR, OPERACION_TOPAZ,NROCAJA, SALDO_JTS_OID)
AS 
  SELECT m.fechaproceso,
    m.horasistema,
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
    m.SALDO_JTS_OID
    
	
  FROM asientos a, movimientos_contables m
	left join TTR_CODIGO_TRANSACCION_DEF t on m.COD_TRANSACCION = t.CODIGO_TRANSACCION
    
  WHERE
    /*** Comparación ***/
    m.fechaproceso = a.fechaproceso
  AND m.sucursal   = a.sucursal
  AND m.asiento    = a.asiento
  AND a.estado     = 77
  
    /*** Filtros ***/
    --MANTIS 5668- Tiene que ser un Debito o un Credito
  AND rtrim(ltrim(m.debitocredito)) IS NOT NULL 
  AND m.capitalrealizado<>0 --se buscaron capitalrealizado con esta condicion y no se encontraron
')