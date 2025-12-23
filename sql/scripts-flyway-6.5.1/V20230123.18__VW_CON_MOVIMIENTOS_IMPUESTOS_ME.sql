--VW_CON_MOVIMIENTOS_IMPUESTOS_ME

EXECUTE('IF OBJECT_ID (''VW_CON_MOVIMIENTOS_IMPUESTOS_ME'') IS NOT NULL
	DROP VIEW VW_CON_MOVIMIENTOS_IMPUESTOS_ME
')
EXECUTE('
CREATE VIEW VW_CON_MOVIMIENTOS_IMPUESTOS_ME (ID_LIQUIDACION,
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
    SELECT ROW_NUMBER() OVER(ORDER BY m.ASIENTO ASC) AS ID_LIQUIDACION,m.FECHAPROCESO, m.SUCURSAL, m.ASIENTO,m.MONEDA,
           m.CAPITALREALIZADO,m.SUCURSAL_CUENTA,m.DEBITOCREDITO,m.CUENTA,m.ORDINAL_CUENTA, R.RUBRO_ORIGEN, R.RUBRO_DESTINO,
           m.MARCAAJUSTE, m.CONCEPTO, m.FECHACONTABLE
    FROM MOVIMIENTOS_CONTABLES m
    JOIN ASIENTOS a ON a.ASIENTO=m.ASIENTO AND a.FECHAPROCESO=m.FECHAPROCESO AND a.SUCURSAL=m.SUCURSAL AND a.ESTADO=77
    JOIN CON_RUBRO_CONTABLE_ORIG_DEST_ME R ON m.RUBROCONTABLE = r.RUBRO_ORIGEN 
    
    AND NOT EXISTS (SELECT * FROM CON_MOVIMIENTOS_IMPUESTOS_ME AS MI
                     WHERE MI.RESULTADO_EJECUCION = ''OK'' 
                       AND convert(varchar(6),LEFT(CONVERT(varchar, M.FECHAPROCESO,112),6)) IN  
    
   (SELECT convert(varchar(6),LEFT(CONVERT(varchar, MI.FECHAPROCESO,112),6)) FROM ESTADO_BALANCE AS EB
          WHERE (EB.ABIERTO_CERRADO =''A''
           AND convert(varchar(6),LEFT(CONVERT(varchar, EB.ANIOMES,112),6))= convert(varchar(6),LEFT(CONVERT(varchar, MI.FECHAPROCESO,112),6)))
          UNION  
        SELECT convert(varchar(6),LEFT(CONVERT(varchar, MI.FECHAPROCESO,112),6)) FROM ESTADO_BALANCE AS EB
          WHERE  (EB.ABIERTO_CERRADO =''C''
           AND convert(varchar(6),LEFT(CONVERT(varchar, EB.ANIOMES,112),6))= convert(varchar(6),LEFT(CONVERT(varchar, MI.FECHAPROCESO,112),6))-1))
              
    )
    AND m.MONEDA<>(SELECT C6399 FROM MONEDAS WHERE C6400 =''PESOS'' AND C6403 <> ''I'')
    AND m.OPERACION<>9999
')
