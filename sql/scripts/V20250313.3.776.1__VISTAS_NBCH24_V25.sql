EXECUTE('
CREATE OR ALTER PROCEDURE [dbo].[SP_NBCH24_MOVIMIENTOS]
    @P_jtsoid numeric(15, 0),
    @P_fechaDesde datetime,
    @P_fechaHasta datetime,
    @P_pagina integer, 
    @P_cantidad integer,
    @P_ttr nvarchar(MAX) = NULL,
    @P_fv char(1),
    @P_filter char(5)
AS
BEGIN

    SET NOCOUNT ON;

    SELECT 
        h.MOV_JTS_OID id,
        h.SALDO_JTS_OID jts_oid, 
        h.FECHA_VALOR fechaValor,
        h.FECHA_PROCESADO fechaProceso, 
        a.HORAFIN fechaHoraReloj,
        h.DEBITO_CREDITO operacion, 
        h.MONTO monto, 
        CASE 
            WHEN h.DEBITO_CREDITO = ''D'' THEN -h.monto 
            ELSE h.monto 
        END importe,
        COALESCE(SALDO_AJUSTADO, 0)  + 
        SUM(CASE 
                WHEN h.DEBITO_CREDITO = ''D'' THEN -h.monto 
                ELSE h.monto 
            END) OVER (PARTITION BY h.FECHA_VALOR ORDER BY h.FECHA_VALOR, h.MOV_JTS_OID) AS saldoParcial,
        CASE 
            WHEN h.CODIGO_TRANSACCION = 0 THEN h.CONCEPTO 
            ELSE codTtr.DESCRIPCION 
        END concepto,
        a.OPERACION nroOperacion, 
        h.CODIGO_TRANSACCION codTransaccion, 
        h.ASIENTO comprobante,
        dbo.diaHabil(h.fecha_Valor - 1, ''D'') fechaSaldo, 
        COALESCE(SALDO_AJUSTADO, 0) saldoDiario,    
        CASE 
            WHEN mon.C6403 = ''I'' THEN ctz.cotBcra 
            ELSE NULL 
        END cotizacion,
        hm.infoExtendida detalle,
        hm.infoExtendidaMeta detMeta

    FROM HISTORIA_VISTA h WITH (NOLOCK)
    INNER JOIN ASIENTOS A WITH (NOLOCK) 
        ON H.ASIENTO = A.ASIENTO 
        AND H.SUCURSAL = A.SUCURSAL 
        AND H.FECHA_PROCESADO = A.FECHAPROCESO 
    LEFT JOIN HISTORICO_MOVIMIENTOS hm WITH (NOLOCK) 
        ON h.MOV_JTS_OID = hm.movJtsOid 
        AND h.FECHA_PROCESADO = hm.fechaAsiento 
        AND DATETRUNC(day, A.HORAFIN) = hm.fechaReloj  
    INNER JOIN saldos s WITH (NOLOCK) 
        ON s.JTS_OID = h.SALDO_JTS_OID 
    LEFT JOIN TTR_CODIGO_TRANSACCION_DEF codTtr WITH (NOLOCK) 
        ON h.CODIGO_TRANSACCION = codTtr.CODIGO_TRANSACCION
    LEFT JOIN STRING_SPLIT(@P_ttr, '','') AS ttr 
        ON ttr.value = h.CODIGO_TRANSACCION
    LEFT JOIN GRL_SALDOS_DIARIOS sal WITH (NOLOCK) 
        ON sal.fecha = dbo.diaHabil(h.fecha_Valor - 1, ''D'') 
        AND h.SALDO_JTS_OID = sal.SALDOS_JTS_OID
    LEFT JOIN VW_NBCH24_GRL_COTIZACIONES ctz WITH (NOLOCK) 
        ON h.FECHA_VALOR = ctz.fecha 
        AND ctz.codigo = s.moneda --fecha de cotizacion para UVA
    LEFT JOIN monedas mon 
        ON ctz.codigo = mon.C6399

    WHERE a.ESTADO = 77 
    AND h.MONTO > 0 
    AND ((h.SALDO_JTS_OID = @P_jtsoid 
        AND CAST(h.FECHA_PROCESADO AS Date) BETWEEN @P_fechaDesde AND @P_fechaHasta 
        AND @P_filter = ''*PROC'') 
        OR (h.SALDO_JTS_OID = @P_jtsoid 
        AND CAST(a.HORAFIN AS Date) BETWEEN @P_fechaDesde AND @P_fechaHasta 
        AND @P_filter = ''*TIME''))

    AND (@P_ttr IS NULL OR ttr.value IS NOT NULL) --si @P_ttr es null incluye todos los codigos de transaccion 
    AND (@P_fv <> ''S'' OR h.FECHA_VALOR < h.FECHA_PROCESADO)

    ORDER BY h.FECHA_VALOR DESC, h.MOV_JTS_OID DESC
    OFFSET (@P_pagina - 1) * @P_cantidad ROWS
    FETCH NEXT @P_cantidad ROWS ONLY

END;

');
