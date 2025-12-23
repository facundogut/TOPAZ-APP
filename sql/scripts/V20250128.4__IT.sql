EXEC('
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

    Select 
    h.MOV_JTS_OID id,
    h.SALDO_JTS_OID jts_oid, 
    h.FECHA_VALOR fechaValor,
    h.FECHA_PROCESADO fechaProceso, 
    a.HORAFIN fechaHoraReloj ,
    h.DEBITO_CREDITO operacion, 
    h.MONTO monto, 
    case when DEBITO_CREDITO = ''D'' then -h.monto else h.monto end importe,
    COALESCE(SALDO_AJUSTADO, 0)  + 
    SUM(case when DEBITO_CREDITO = ''D'' then -h.monto else h.monto end ) OVER (PARTITION BY h.FECHA_VALOR ORDER BY h.FECHA_VALOR, h.MOV_JTS_OID) AS saldoParcial,
    h.CONCEPTO concepto,
    a.OPERACION nroOperacion, 
    h.CODIGO_TRANSACCION codTransaccion, 
    h.ASIENTO comprobante,
    dbo.diaHabil(h.fecha_Valor - 1, ''D'') fechaSaldo, 
    COALESCE(SALDO_AJUSTADO, 0) saldoDiario,    
    case when mon.C6403 = ''I'' then ctz.cotBcra else null end cotizacion,
    hm.infoExtendida detalle

    from HISTORIA_VISTA h WITH (NOLOCK)
    inner join ASIENTOS A WITH (NOLOCK) on H.ASIENTO = A.ASIENTO and H.SUCURSAL = A.SUCURSAL and H.FECHA_PROCESADO = A.FECHAPROCESO 
    left join HISTORICO_MOVIMIENTOS hm WITH (NOLOCK) on h.MOV_JTS_OID = hm.movJtsOid  
    inner join saldos s WITH (NOLOCK) on s.JTS_OID = h.SALDO_JTS_OID 
    left JOIN STRING_SPLIT(@P_ttr, '','') AS ttr ON ttr.value = h.CODIGO_TRANSACCION
    left join GRL_SALDOS_DIARIOS sal WITH (NOLOCK) on sal.fecha = dbo.diaHabil(h.fecha_Valor - 1, ''D'') and h.SALDO_JTS_OID = sal.SALDOS_JTS_OID
    left join VW_NBCH24_GRL_COTIZACIONES ctz WITH (NOLOCK) on h.FECHA_VALOR = ctz.fecha and ctz.codigo = s.moneda --fecha de cotizacion para UVA
    inner join monedas mon on ctz.codigo = mon.C6399
    where a.ESTADO = 77 and h.MONTO > 0 

    and 
    ((h.SALDO_JTS_OID = @P_jtsoid and cast(h.FECHA_PROCESADO as Date) BETWEEN @P_fechaDesde and @P_fechaHasta and @P_filter = ''*PROC'') 
    or 
    (h.SALDO_JTS_OID = @P_jtsoid and cast(a.HORAFIN as Date)  BETWEEN @P_fechaDesde and @P_fechaHasta and @P_filter = ''*TIME'') )

    and  (@P_ttr IS NULL OR ttr.value IS NOT NULL) --si @p_ttr es null incluye todos los codigos de transaccion 
    and (@P_fv <> ''S'' OR h.FECHA_VALOR < h.FECHA_PROCESADO)
    order by h.FECHA_VALOR desc, a.HORAFIN desc
    OFFSET (@P_pagina - 1) * @P_cantidad ROWS
    FETCH NEXT @P_cantidad ROWS ONLY
END;
');

EXECUTE('
delete ITF_MASTER where id = 328;
INSERT INTO dbo.ITF_MASTER (TZ_LOCK, ID, DESCRIPCION, OBJ_KETTLE, P0_MODO, P0_TIPO, P0_CAPTION, P0_CONSTANTE, P1_MODO, P1_TIPO, P1_CAPTION, P1_CONSTANTE, P2_MODO, P2_TIPO, P2_CAPTION, P2_CONSTANTE, P3_MODO, P3_TIPO, P3_CAPTION, P3_CONSTANTE, P4_MODO, P4_TIPO, P4_CAPTION, P4_CONSTANTE, P5_MODO, P5_TIPO, P5_CAPTION, P5_CONSTANTE, P6_MODO, P6_TIPO, P6_CAPTION, P6_CONSTANTE, P7_MODO, P7_TIPO, P7_CAPTION, P7_CONSTANTE, P8_MODO, P8_TIPO, P8_CONSTANTE, P8_CAPTION, P9_MODO, P9_TIPO, P9_CAPTION, P9_CONSTANTE, TIPO_OBJ, COMENTARIO, ID_REPORTE, MODO_EJECUCION, KETTLE_NAME)
VALUES (0, 328, ''2.6.13 BCRA - ANULCOMPRAVENTAME'', ''PUNTO_ENTRADA_LOG_PA.kjb'', '''', '''', '''', '' '', '''', '''', '''', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', ''J'', '''', 0, ''M'', ''ITF_BCRA_ANULCOMPRAVENTAME.kjb'')

')

EXECUTE('
delete ITF_MASTER where id = 327;
INSERT INTO dbo.ITF_MASTER (TZ_LOCK, ID, DESCRIPCION, OBJ_KETTLE, P0_MODO, P0_TIPO, P0_CAPTION, P0_CONSTANTE, P1_MODO, P1_TIPO, P1_CAPTION, P1_CONSTANTE, P2_MODO, P2_TIPO, P2_CAPTION, P2_CONSTANTE, P3_MODO, P3_TIPO, P3_CAPTION, P3_CONSTANTE, P4_MODO, P4_TIPO, P4_CAPTION, P4_CONSTANTE, P5_MODO, P5_TIPO, P5_CAPTION, P5_CONSTANTE, P6_MODO, P6_TIPO, P6_CAPTION, P6_CONSTANTE, P7_MODO, P7_TIPO, P7_CAPTION, P7_CONSTANTE, P8_MODO, P8_TIPO, P8_CONSTANTE, P8_CAPTION, P9_MODO, P9_TIPO, P9_CAPTION, P9_CONSTANTE, TIPO_OBJ, COMENTARIO, ID_REPORTE, MODO_EJECUCION, KETTLE_NAME)
VALUES (0, 327, ''2.6.12 BCRA - COMPRAVENTAME'', ''PUNTO_ENTRADA_LOG_PA.kjb'', '''', '''', '''', '' '', '''', '''', '''', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', ''J'', '''', 0, ''M'', ''ITF_BCRA_COMPRAVENTAME.kjb'')

')