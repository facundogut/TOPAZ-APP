EXECUTE('
CREATE OR ALTER VIEW dbo.VW_NBCH24_DPF_PIZARRA
AS
select p.C6250 codProducto, 
p.C6251 descProducto, 
t.PLAZOMINCANC plazoMinCanc,
p.TIPO tipo,  --A: ambos, --E: PJ, --P: PF
pr.MONEDA moneda,
t.PLAZOMINIMO plazoMin,
t.PLAZOMAXIMO plazoMax,
t.MONTOMINIMOAPER montoMin, 
t.MONTOMAXIMOAPER montoMax, 
pr.HABILITADO habilitado,
pr.CANAL canal
from TOPESPRODUCTO t WITH (NOLOCK)
inner join PRODUCTOS p WITH (NOLOCK) on p.C6250 = t.CODPRODUCTO 
inner join prod_relcanales pr WITH (NOLOCK) on pr.producto = p.c6250 and t.MONEDA = pr.MONEDA
where p.C6252 = 4 --producto DPF
--and pr.CANAL = 4 --canal
and p.TZ_LOCK = 0
and pr.TZ_LOCK = 0
and t.TZ_LOCK  = 0;
');

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

    Select 
    h.MOV_JTS_OID id,
    h.SALDO_JTS_OID jts_oid, 
    h.FECHA_VALOR fechaValor,
    h.FECHA_PROCESADO fechaProceso, 
    a.HORAFIN fechaHoraReloj,
    h.DEBITO_CREDITO operacion, 
    h.MONTO monto, 
    case when h.DEBITO_CREDITO = ''D'' then -h.monto else h.monto end importe,
    COALESCE(SALDO_AJUSTADO, 0)  + 
    SUM(case when h.DEBITO_CREDITO = ''D'' then -h.monto else h.monto end ) OVER (PARTITION BY h.FECHA_VALOR ORDER BY h.FECHA_VALOR, h.MOV_JTS_OID) AS saldoParcial,
    CASE WHEN h.CODIGO_TRANSACCION = 0 then h.CONCEPTO ELSE codTtr.DESCRIPCION END concepto,
    a.OPERACION nroOperacion, 
    h.CODIGO_TRANSACCION codTransaccion, 
    h.ASIENTO comprobante,
    dbo.diaHabil(h.fecha_Valor - 1, ''D'') fechaSaldo, 
    COALESCE(SALDO_AJUSTADO, 0) saldoDiario,    
    case when mon.C6403 = ''I'' then ctz.cotBcra else null end cotizacion,
    hm.infoExtendida detalle,
    hm.infoExtendidaMeta detMeta

    from HISTORIA_VISTA h WITH (NOLOCK)
    inner join ASIENTOS A WITH (NOLOCK) on H.ASIENTO = A.ASIENTO and H.SUCURSAL = A.SUCURSAL and H.FECHA_PROCESADO = A.FECHAPROCESO 
    left join HISTORICO_MOVIMIENTOS hm WITH (NOLOCK) on h.MOV_JTS_OID = hm.movJtsOid  
    inner join saldos s WITH (NOLOCK) on s.JTS_OID = h.SALDO_JTS_OID 
    left join TTR_CODIGO_TRANSACCION_DEF codTtr WITH (NOLOCK) ON h.CODIGO_TRANSACCION = codTtr.CODIGO_TRANSACCION
    left JOIN STRING_SPLIT(@P_ttr, '','') AS ttr ON ttr.value = h.CODIGO_TRANSACCION
    left join GRL_SALDOS_DIARIOS sal WITH (NOLOCK) on sal.fecha = dbo.diaHabil(h.fecha_Valor - 1, ''D'') and h.SALDO_JTS_OID = sal.SALDOS_JTS_OID
    left join VW_NBCH24_GRL_COTIZACIONES ctz WITH (NOLOCK) on h.FECHA_VALOR = ctz.fecha and ctz.codigo = s.moneda --fecha de cotizacion para UVA
    left join monedas mon on ctz.codigo = mon.C6399
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

Execute('IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = ''SALDOS_IDX01'' AND object_id = OBJECT_ID(''dbo.SALDOS''))
    DROP INDEX [SALDOS_IDX01] ON [dbo].[SALDOS];
CREATE UNIQUE INDEX [SALDOS_IDX01] ON [dbo].[SALDOS] ([SUCURSAL] ASC,[PRODUCTO] ASC,[MONEDA] ASC,[CUENTA] ASC,[OPERACION] ASC,[ORDINAL] ASC);')

Execute('IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = ''IX_DBA_POS_ELEMENT0'' AND object_id = OBJECT_ID(''dbo.TP_TOPAZPOSCONTROL''))
    DROP INDEX [IX_DBA_POS_ELEMENT0] ON [dbo].[TP_TOPAZPOSCONTROL];
CREATE NONCLUSTERED INDEX [IX_DBA_POS_ELEMENT0] ON [dbo].[TP_TOPAZPOSCONTROL] ([ELEMENT0],[ELEMENT13],[ELEMENT37],[ELEMENT41]);')

Execute('CREATE OR ALTER   PROCEDURE SP_ITF_BUSCO_ACUMULADO_INTERBANKING(
@P_IMPORTE 		NUMERIC(15,2),
@P_FECHA 		VARCHAR(8),
@P_MONEDA 		NUMERIC(1,0),
@P_JTS_OID 		NUMERIC(10,0),
@O_RETORNO  	NUMERIC (15,2) OUTPUT) 

AS
BEGIN
	DECLARE @V_ANIO NUMERIC(4,0); 
	DECLARE @V_MES NUMERIC(2,0); 
	DECLARE @V_COUNT NUMERIC(15,2);
	DECLARE @VAL_UVA NUMERIC(15,2);
	
	SET @V_ANIO = CAST(SUBSTRING(@P_FECHA , 1, 4) AS NUMERIC(4,0)); 	
	SET @V_MES  = CAST(SUBSTRING(@P_FECHA , 5, 2) AS NUMERIC(2,0));
	
	SELECT @V_COUNT = (
	
	SELECT SUM(IMPORTE_MOVIMIENTOS) 
	FROM GRL_CONTADOR_MOVIMIENTOS GRL (NOLOCK) 
		WHERE 	GRL.ANIO=@V_ANIO 
		AND 	GRL.MES=@V_MES 
		AND 	GRL.CODIGO_TRANSACCION IN (160)
		AND 	GRL.SALDOS_JTS_OID=@P_JTS_OID 
	)
	
	SELECT @VAL_UVA= (SELECT C6440 FROM MONEDAS M (NOLOCK) WHERE M.C6399=999)
	
	IF @P_MONEDA = 1  
	    SET @O_RETORNO = (@V_COUNT + @P_IMPORTE) / @VAL_UVA;  
	ELSE  
	    SET @O_RETORNO = (@V_COUNT + @P_IMPORTE) ;
END')