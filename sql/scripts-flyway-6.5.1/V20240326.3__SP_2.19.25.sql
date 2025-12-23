Execute('
CREATE OR ALTER  PROC SP_RP_REPORTE
--Juan Pedrozo
--last upd: 25/03/24

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
	s.cuenta AS cuentaRecaudacion,
	--------------------------
	convert(VARCHAR(10), cab.FECHACARGA, 120)  AS fechaRecaudacion,
	ren.TOTALIMPORTE AS totalRecaudado,
	ren.TOTALREGISTROS AS cantComprobantes,
	ren.IMPORTE_COMISION AS impComision,
	ren.IMPORTE_IMPUESTOS AS totalImpuestos,
	isnull((CASE WHEN relEnte.COD_ENTE IN (''406'',''265'') THEN ren.TOTAL_CARGO_ESPECIFICO ELSE 0 END),0) AS cargoEspecifico,
		
	(ren.TOTALIMPORTE - ren.IMPORTE_COMISION - ren.IMPORTE_IMPUESTOS - isnull((CASE WHEN relEnte.COD_ENTE IN (''406'',''265'') THEN ren.TOTAL_CARGO_ESPECIFICO ELSE 0 END),0)) AS importeRendido
	
	FROM PARAMETROS p, CONV_REL_ENTECONV (NOLOCK) relEnte 
	    JOIN REC_RENDICION (NOLOCK) ren ON relEnte.ID_CONVREC = ren.CONVENIO OR relEnte.ID_CONVREC = ren.CONVENIO_PADRE
	    JOIN REC_LIQUIDACION (NOLOCK) liq ON ren.id_rendicion = liq.id_rendicion
	    JOIN REC_CAB_RECAUDOS_CAJA (NOLOCK) cab ON cab.id_liquidacion = liq.id_liquidacion
	    JOIN CONV_CONVENIOS_REC (NOLOCK) conv ON  conv.Id_ConvRec = ren.convenio
	    LEFT JOIN SALDOS (NOLOCK) s ON s.JTS_OID = conv.CuentaRec 
		    
		    WHERE ren.CONVENIO_PADRE = @convenio
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
	s.cuenta AS cuentaRecaudacion,
	--------------------------
	convert(VARCHAR(10), cab.FECHACARGA, 120)  AS fechaRecaudacion,
	ren.TOTALIMPORTE AS totalRecaudado,
	ren.TOTALREGISTROS AS cantComprobantes,
	ren.IMPORTE_COMISION AS impComision,
	ren.IMPORTE_IMPUESTOS AS totalImpuestos,
	isnull((CASE WHEN relEnte.COD_ENTE IN (''406'',''265'') THEN ren.TOTAL_CARGO_ESPECIFICO ELSE 0 END),0) AS cargoEspecifico,	
	
    (ren.TOTALIMPORTE - ren.IMPORTE_COMISION - ren.IMPORTE_IMPUESTOS - isnull((CASE WHEN relEnte.COD_ENTE IN (''406'',''265'') THEN ren.TOTAL_CARGO_ESPECIFICO ELSE 0 END),0)) AS importeRendido
   
    FROM PARAMETROS p, CONV_REL_ENTECONV (NOLOCK) relEnte 
    JOIN REC_RENDICION (NOLOCK) ren ON relEnte.ID_CONVREC = ren.CONVENIO OR relEnte.ID_CONVREC = ren.CONVENIO_PADRE
    JOIN REC_LIQUIDACION (NOLOCK) liq ON ren.id_rendicion = liq.id_rendicion
    JOIN REC_CAB_RECAUDOS_CANAL (NOLOCK) cab ON cab.id_liquidacion = liq.id_liquidacion
    JOIN CONV_CONVENIOS_REC (NOLOCK) conv ON  conv.Id_ConvRec = ren.convenio
    LEFT JOIN SALDOS (NOLOCK) s ON s.JTS_OID = conv.CuentaRec 
	    
	    WHERE ren.CONVENIO_PADRE = @convenio
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