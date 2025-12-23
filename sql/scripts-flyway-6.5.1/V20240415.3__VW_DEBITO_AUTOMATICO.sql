EXECUTE('
IF OBJECT_ID (''dbo.VW_DEBITO_AUTOMATICO'') IS NOT NULL
	DROP VIEW dbo.VW_DEBITO_AUTOMATICO
')

EXECUTE('
CREATE   VIEW [dbo].[VW_DEBITO_AUTOMATICO]
AS


SELECT DISTINCT TOP 100 PERCENT
    
    L.ID_LIQUIDACION AS ''ID_LIQUIDACION'',
    L.ESTADO AS ''ESTADO'',
    L.CONVENIO AS ''CONVENIO'',
    C.NomConvRec AS ''NOMBRE_CONVENIO'',
    L.CONVENIO_PADRE AS ''CONVENIO_PADRE'',
    C.Cuit AS ''CUIT'',
    L.FECHA AS ''FECHA_LIQUIDACION'',
    C.Acreditacion AS ''PLAZO_ACRED'',
    L.MONEDA AS ''MONEDA'',
    L.TOTALREGISTROS AS ''TOTAL_REGISTROS'',
    L.TOTALIMPORTE AS ''TOTAL_IMPORTE'',
    L.COMISION_LIQUIDADA AS ''COMISION_LIQUIDADA'',
    L.IMPORTE_COMISION AS ''IMPORTE_COMISION'',
    L.TOTAL_CARGO_ESPECIFICO AS ''TOTAL_CARGO_ESPECIFICO''
FROM REC_CAB_DEBITOSAUTOMATICOS RC WITH (NOLOCK)
JOIN CONV_CONVENIOS_REC C WITH (NOLOCK) ON (C.Id_ConvRec = RC.CONVENIO OR C.Id_ConvPadre = RC.CONVENIO)
    AND C.Id_TpoConv IN (2) 
    AND C.ESTADO = ''A''
    AND (C.tz_lock <  300000000000000 OR C.tz_lock >=  400000000000000)
    AND (C.tz_lock <  100000000000000 OR C.tz_lock >=  200000000000000)
JOIN REC_LIQUIDACION L WITH (NOLOCK) ON L.ID_CABEZAL = RC.ID
      AND (L.tz_lock < 300000000000000 OR L.tz_lock >= 400000000000000)
      AND (L.tz_lock < 100000000000000 OR L.tz_lock >= 200000000000000)
      AND L.ESTADO = ''L''
      AND EXISTS (
        SELECT FECHAPROCESO FROM PARAMETROS
        WHERE FECHAPROCESO = 
            CASE 
                WHEN C.Acreditacion = ''24H'' THEN dbo.diaHabil(DATEADD(day, 1, L.FECHA), ''A'')
                WHEN C.Acreditacion = ''48H'' THEN dbo.diaHabil(DATEADD(day, 2, L.FECHA), ''A'')
                WHEN C.Acreditacion = ''DIA'' THEN dbo.diaHabil(DATEADD(day, 0, L.FECHA), ''A'')
                WHEN C.Acreditacion = ''MES'' THEN dbo.ULTIMODIAHABIL(L.FECHA)
                WHEN C.Acreditacion = ''MES'' AND C.DiaCierreDA=99 THEN dbo.ULTIMODIAHABIL(L.FECHA)
			    WHEN C.Acreditacion = ''MES'' AND C.DiaCierreDA<>99 THEN dbo.diaHabil( 
			                                            (SELECT concat((SELECT year(fechaProceso) FROM PARAMETROS),
			                                                           (SELECT format(month(fechaProceso),''00'') FROM PARAMETROS),
			                                                            format((C.DiaCierreDA),''00''))), ''A'')
            END
    )
 WHERE RC.ESTADO IN (''V'', ''Z'')
   AND (RC.tz_lock < 300000000000000 OR RC.tz_lock >= 400000000000000)    
   AND (RC.tz_lock < 100000000000000 OR RC.tz_lock >= 200000000000000)

UNION


SELECT DISTINCT TOP 100 PERCENT
    
    RC.ID AS ''ID_LIQUIDACION'',
    RC.ESTADO AS ''ESTADO'',
    RC.CONVENIO AS ''CONVENIO'',
    C.NomConvRec AS ''NOMBRE_CONVENIO'',
    c.Id_ConvPadre AS ''CONVENIO_PADRE'',
    C.Cuit AS ''CUIT'',
    RC.FECHACORTE AS ''FECHA_LIQUIDACION'',
    C.Acreditacion AS ''PLAZO_ACRED'',
    RC.MONEDA AS ''MONEDA'',
    RC.TOTALREGISTROS AS ''TOTAL_REGISTROS'',
    RC.TOTALIMPORTE AS ''TOTAL_IMPORTE'',
    ''0'' AS ''COMISION_LIQUIDADA'',
    0 AS ''IMPORTE_COMISION'',
    0 AS ''TOTAL_CARGO_ESPECIFICO''
FROM REC_CAB_DEBITOSAUTOMATICOS RC WITH (NOLOCK)
JOIN CONV_CONVENIOS_REC C WITH (NOLOCK) ON (C.Id_ConvRec = RC.CONVENIO OR C.Id_ConvPadre= RC.CONVENIO)
    AND C.Id_TpoConv IN (2) 
    AND C.ESTADO = ''A''
    AND EXISTS (
        SELECT FECHAPROCESO FROM PARAMETROS
        WHERE FECHAPROCESO =  CASE 
			                WHEN C.Acreditacion = ''24H'' THEN dbo.diaHabil(DATEADD(day, 1, RC.FECHACORTE), ''A'')
			                WHEN C.Acreditacion = ''48H'' THEN dbo.diaHabil(DATEADD(day, 2, RC.FECHACORTE), ''A'')
			                WHEN C.Acreditacion = ''DIA'' THEN dbo.diaHabil(DATEADD(day, 0, RC.FECHACORTE), ''A'')
			                WHEN C.Acreditacion = ''MES'' AND C.DiaCierreDA=99 THEN dbo.ULTIMODIAHABIL(RC.FECHACORTE)
			                WHEN C.Acreditacion = ''MES'' AND C.DiaCierreDA<>99 THEN dbo.diaHabil( 
			                                            (SELECT concat((SELECT year(fechaProceso) FROM PARAMETROS),
			                                                           (SELECT format(month(fechaProceso),''00'') FROM PARAMETROS),
			                                                            format((C.DiaCierreDA),''00''))), ''A'')
			            END
    )
    AND (C.tz_lock < 300000000000000 OR C.tz_lock >= 400000000000000)
    AND (C.tz_lock < 100000000000000 OR C.tz_lock >= 200000000000000)
     
WHERE RC.ESTADO IN (''V'', ''Z'')
  AND (RC.tz_lock < 300000000000000 OR RC.tz_lock >= 400000000000000)    
  AND (RC.tz_lock < 100000000000000 OR RC.tz_lock >= 200000000000000)

ORDER BY estado asc

')
