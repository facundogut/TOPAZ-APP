Execute('
CREATE OR ALTER  PROC SP_RP_REPORTE 
--Juan Pedrozo	

AS

DECLARE @convenio INT, @fecha VARCHAR(10);

TRUNCATE TABLE ITF_RP_REPORTE;

DECLARE cursorParam CURSOR FOR
SELECT CONVENIO, FECHA_REN FROM ITF_RP_REPORTE_PARAMETROS
OPEN cursorParam
FETCH NEXT FROM cursorParam INTO @convenio, @fecha

WHILE @@FETCH_STATUS = 0
BEGIN
		
WITH 
importeIVA AS (
	SELECT  ren.FECHA AS fecha, isnull(sum(mov.CAPITALREALIZADO), 0) AS IVAcomisiones FROM REC_RENDICION ren 
		JOIN movimientos_contables mov ON  ren.SUCURSAL_RENDICION = mov.SUCURSAL AND ren.FECHA = mov.FECHACONTABLE AND ren.ASIENTO_RENDICION = mov.ASIENTO AND mov.COD_TRANSACCION = 200
		WHERE  (ren.CONVENIO = @convenio OR ren.CONVENIO_PADRE = @convenio) AND ren.FECHA = CAST(@fecha AS DATE) AND mov.DEBITOCREDITO = ''D'' AND ren.TZ_LOCK = 0
		GROUP BY ren.FECHA, mov.CONCEPTO

)
,
importeRetenciones AS (
SELECT ren.FECHA AS fecha, isnull(sum(mov.CAPITALREALIZADO), 0) totalRet  FROM REC_RENDICION ren 
	JOIN movimientos_contables mov ON  ren.SUCURSAL_RENDICION = mov.SUCURSAL AND ren.FECHA = mov.FECHACONTABLE AND ren.ASIENTO_RENDICION = mov.ASIENTO AND mov.COD_TRANSACCION = 204
	WHERE  (ren.CONVENIO = @convenio OR ren.CONVENIO_PADRE = @convenio) AND ren.FECHA = CAST(@fecha AS DATE) AND DEBITOCREDITO = ''D'' AND ren.TZ_LOCK = 0
	GROUP BY ren.FECHA, mov.CONCEPTO

)

INSERT INTO ITF_RP_REPORTE

SELECT 
	ren.NOMBRE_CONVENIO_PADRE AS empresa,
	convert(VARCHAR(10), p.fechaproceso, 120) as fechaProceso,
	conv.NomConvRec AS nombreConvenio,
	concat(''T'',RIGHT(concat(replicate(''0'',2),@convenio), 3), substring(@fecha, 5, 4), ''.txt'') AS nombreArchivo, 
   	convert(VARCHAR(10), ren.FECHA  , 120) AS fechaRendicion,
	conv.CuentaRec AS cuentaRecaudacion,
	--------------------------
	convert(VARCHAR(10), cab.FECHACARGA, 120)  AS fechaRecaudacion,
	ren.TOTALIMPORTE AS totalRecaudado,
	ren.TOTALREGISTROS AS cantComprobantes,
	ren.IMPORTE_COMISION AS impComision,
	
	isnull(iva.IVAcomisiones, 0) AS IVAsobreComisiones,
	isnull(reten.totalRet, 0) AS totalRetenciones, 
	
	ren.TOTAL_CARGO_ESPECIFICO AS cargoEspecifico,	
	
	(ren.TOTALIMPORTE - ren.IMPORTE_COMISION - isnull(iva.IVAcomisiones, 0) - isnull(reten.totalRet, 0) - isnull(ren.TOTAL_CARGO_ESPECIFICO, 0)) AS importeRendido
	
    FROM PARAMETROS p, REC_CAB_RECAUDOS_CAJA cab 
    JOIN REC_LIQUIDACION liq ON liq.ID_LIQUIDACION = cab.ID_LIQUIDACION 
    JOIN REC_RENDICION ren ON ren.ID_RENDICION = liq.ID_RENDICION 
    JOIN CONV_CONVENIOS_REC conv ON conv.Id_ConvRec = ren.CONVENIO 
    JOIN SALDOS s ON conv.CuentaRec = s.JTS_OID 
    LEFT JOIN importeIVA iva ON ren.FECHA = iva.fecha 
    LEFT JOIN importeRetenciones reten ON ren.FECHA = reten.fecha
    
	    WHERE (CONV.Id_ConvRec = @convenio OR CONV.Id_ConvPadre = @convenio)
	    
	    	AND ren.FECHA = CAST(@fecha AS DATE) 
	    	AND cab.TZ_LOCK = 0
	        AND liq.TZ_LOCK = 0
	        AND liq.ESTADO = ''R''
	        AND ren.TZ_LOCK = 0
	        AND conv.TZ_LOCK = 0
	        AND conv.Estado = ''A'' 
	        AND s.TZ_LOCK = 0

UNION ALL 

SELECT 
	ren.NOMBRE_CONVENIO_PADRE AS empresa,
	convert(VARCHAR(10), p.fechaproceso, 120) as fechaProceso,
	conv.NomConvRec AS nombreConvenio,
	concat(''T'',RIGHT(concat(replicate(''0'',2),@convenio), 3), substring(@fecha, 5, 4), ''.txt'') AS nombreArchivo, 
	convert(VARCHAR(10), ren.FECHA  , 120) AS fechaRendicion,
	conv.CuentaRec AS cuentaRecaudacion,
	--------------------------
	convert(VARCHAR(10), cab.FECHACARGA, 120)  AS fechaRecaudacion,
	ren.TOTALIMPORTE AS totalRecaudado,
	ren.TOTALREGISTROS AS cantComprobantes,
	ren.IMPORTE_COMISION AS impComision,
	
	isnull(iva.IVAcomisiones, 0) AS IVAsobreComisiones,
	isnull(reten.totalRet, 0) AS totalRetenciones, 
	
	ren.TOTAL_CARGO_ESPECIFICO AS cargoEspecifico,	
	
	(ren.TOTALIMPORTE - ren.IMPORTE_COMISION - isnull(iva.IVAcomisiones, 0) - isnull(reten.totalRet, 0) - ren.TOTAL_CARGO_ESPECIFICO) AS importeRendido
	
    FROM PARAMETROS p, REC_CAB_RECAUDOS_CANAL cab 
    JOIN REC_LIQUIDACION liq ON liq.ID_LIQUIDACION = cab.ID_LIQUIDACION 
    JOIN REC_RENDICION ren ON ren.ID_RENDICION = liq.ID_RENDICION 
    JOIN CONV_CONVENIOS_REC conv ON conv.Id_ConvRec = ren.CONVENIO 
    JOIN SALDOS s ON conv.CuentaRec = s.JTS_OID 
    LEFT JOIN importeIVA iva ON ren.FECHA = iva.fecha 
    LEFT JOIN importeRetenciones reten ON ren.FECHA = reten.fecha
    
    	WHERE (conv.Id_ConvRec = @convenio OR conv.Id_ConvPadre = @convenio) 
    	AND ren.FECHA = CAST(@fecha AS DATE) 
    	AND cab.TZ_LOCK = 0
        AND liq.TZ_LOCK = 0
        AND ren.TZ_LOCK = 0
        AND conv.TZ_LOCK = 0
        AND s.TZ_LOCK = 0
  
    FETCH NEXT FROM cursorParam INTO @convenio, @fecha
END

CLOSE cursorParam
DEALLOCATE cursorParam
')

