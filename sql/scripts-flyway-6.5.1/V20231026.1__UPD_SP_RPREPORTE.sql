EXECUTE('
CREATE OR ALTER  PROC SP_RP_REPORTE
--Juan Pedrozo
--last upd: 26/10/23

AS

DECLARE @convenio INT, @fecha VARCHAR(10);

TRUNCATE TABLE ITF_RP_REPORTE;

DECLARE cursorParam CURSOR FOR
SELECT CONVENIO, FECHA_REN FROM ITF_RP_REPORTE_PARAMETROS
OPEN cursorParam
FETCH NEXT FROM cursorParam INTO @convenio, @fecha

WHILE @@FETCH_STATUS = 0
BEGIN
  
INSERT INTO ITF_RP_REPORTE

SELECT DISTINCT
	ren.NOMBRE_CONVENIO_PADRE AS empresa,
	convert(VARCHAR(10), p.fechaproceso, 120) as fechaProceso,
	conv.NomConvRec AS nombreConvenio,
	concat(''T'',RIGHT(concat(''000'',@convenio), 3), RIGHT(@fecha,4), ''.txt'') AS nombreArchivo, 
   	convert(VARCHAR(10), CAST(@fecha AS DATE), 120) AS fechaRendicion,
	conv.CuentaRec AS cuentaRecaudacion,
	--------------------------
	convert(VARCHAR(10), cab.FECHACARGA, 120)  AS fechaRecaudacion,
	ren.TOTALIMPORTE AS totalRecaudado,
	ren.TOTALREGISTROS AS cantComprobantes,
	ren.IMPORTE_COMISION AS impComision,
	ren.IMPORTE_IMPUESTOS AS totalImpuestos,
	isnull((CASE WHEN relEnte.COD_ENTE IN (''406'',''265'') THEN ren.TOTAL_CARGO_ESPECIFICO ELSE 0 END),0) AS cargoEspecifico,
		
	(ren.TOTALIMPORTE - ren.IMPORTE_COMISION - ren.IMPORTE_IMPUESTOS - isnull((CASE WHEN relEnte.COD_ENTE IN (''406'',''265'') THEN ren.TOTAL_CARGO_ESPECIFICO ELSE 0 END),0)) AS importeRendido
	
    FROM PARAMETROS p,
    REC_CAB_RECAUDOS_CAJA cab JOIN
    REC_LIQUIDACION liq ON liq.ID_LIQUIDACION = cab.ID_LIQUIDACION JOIN 
    REC_RENDICION ren ON ren.ID_RENDICION = liq.ID_RENDICION JOIN
    CONV_CONVENIOS_REC conv ON conv.Id_ConvRec = ren.CONVENIO OR conv.Id_ConvRec = ren.CONVENIO_PADRE LEFT JOIN 
    CONV_REL_ENTECONV relEnte ON conv.Id_ConvRec = relEnte.ID_CONVREC 
        
    WHERE conv.Id_ConvRec = @convenio 
    	AND ren.FECHA = CAST(@fecha AS DATE)
    	AND conv.Estado = ''A'' 
    	AND cab.TZ_LOCK = 0 
        AND liq.TZ_LOCK = 0 
        AND ren.TZ_LOCK = 0
        AND conv.TZ_LOCK = 0 
                
UNION ALL 

SELECT DISTINCT
	ren.NOMBRE_CONVENIO_PADRE AS empresa,
	convert(VARCHAR(10), p.fechaproceso, 120) as fechaProceso,
	conv.NomConvRec AS nombreConvenio,
	concat(''T'',RIGHT(concat(''000'',@convenio), 3), RIGHT(@fecha,4), ''.txt'') AS nombreArchivo, 
	convert(VARCHAR(10), CAST(@fecha AS DATE), 120) AS fechaRendicion,
	conv.CuentaRec AS cuentaRecaudacion,
	--------------------------
	convert(VARCHAR(10), cab.FECHACARGA, 120)  AS fechaRecaudacion,
	ren.TOTALIMPORTE AS totalRecaudado,
	ren.TOTALREGISTROS AS cantComprobantes,
	ren.IMPORTE_COMISION AS impComision,
	ren.IMPORTE_IMPUESTOS AS totalImpuestos,
	isnull((CASE WHEN relEnte.COD_ENTE IN (''406'',''265'') THEN ren.TOTAL_CARGO_ESPECIFICO ELSE 0 END),0) AS cargoEspecifico,	
	
    (ren.TOTALIMPORTE - ren.IMPORTE_COMISION - ren.IMPORTE_IMPUESTOS - isnull((CASE WHEN relEnte.COD_ENTE IN (''406'',''265'') THEN ren.TOTAL_CARGO_ESPECIFICO ELSE 0 END),0)) AS importeRendido
   
    FROM PARAMETROS p,
    REC_CAB_RECAUDOS_CANAL cab JOIN
    REC_LIQUIDACION liq ON liq.ID_LIQUIDACION = cab.ID_LIQUIDACION JOIN 
    REC_RENDICION ren ON ren.ID_RENDICION = liq.ID_RENDICION JOIN
    CONV_CONVENIOS_REC conv ON conv.Id_ConvRec = ren.CONVENIO OR conv.Id_ConvRec = ren.CONVENIO_PADRE LEFT JOIN 
    CONV_REL_ENTECONV relEnte ON conv.Id_ConvRec = relEnte.ID_CONVREC 
    
    WHERE conv.Id_ConvRec = @convenio 
     	AND ren.FECHA = CAST(@fecha AS DATE) 
     	AND conv.Estado = ''A''
     	AND cab.TZ_LOCK = 0 
        AND liq.TZ_LOCK = 0 
        AND ren.TZ_LOCK = 0 
        AND conv.TZ_LOCK = 0 
  
    FETCH NEXT FROM cursorParam INTO @convenio, @fecha
END

CLOSE cursorParam
DEALLOCATE cursorParam
')