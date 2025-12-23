EXECUTE('

IF OBJECT_ID (''dbo.VW_ChequesRechazadosDenunciados'') IS NOT NULL
	DROP VIEW dbo.VW_ChequesRechazadosDenunciados;
')
EXECUTE('

CREATE       view [dbo].[VW_ChequesRechazadosDenunciados] as

SELECT 
--1
RIGHT(''0'' + CAST(COD_ENTIDAD AS VARCHAR), 5) AS [CodigoEntidad],

--2
RIGHT(''0'' + CAST(CR.NRO_SUCURSAL AS VARCHAR), 3) AS NumeroSucursal,

--3
RIGHT(''0'' + CAST(CR.CUENTA AS VARCHAR), 12) AS NumeroCuentaCorriente,

--4
RIGHT(''0'' + CAST(CR.NRO_CHEQUE AS VARCHAR), 12) AS NumeroCheque,
----5
(Select Right(Cast(Year(FECHA_NOTIF_O_DENUNCIA) As Char(4)),2)) as AvisoAnio, -- Se usa campo FECHA_NOTIF_O_DENUNCIA
----replicate(''0'', 6 - len(AVISO)) + cast (AVISO as varchar)as AvisoNumero,
AVISO AS AvisoNumero,
----6
COD_MOVIMIENTO as [CodigoMovimiento],
----7
CLASE_REGISTRO as ClaseRegistro,
----8
Cast(Year(FECHA_NOTIF_O_DENUNCIA) As Char(4)) as FechaNotificacionDenuncia_Anio, -- Se usa campo FECHA_NOTIF_O_DENUNCIA
RIGHT(''0'' + CAST(MONTH(FECHA_NOTIF_O_DENUNCIA) AS VARCHAR), 2) AS FechaNotificacionDenuncia_Mes, -- Se usa campo FECHA_NOTIF_O_DENUNCIA
RIGHT(''0'' + CAST(DAY(FECHA_NOTIF_O_DENUNCIA) AS VARCHAR), 2) AS FechaNotificacionDenuncia_Dia, -- Se usa campo FECHA_NOTIF_O_DENUNCIA
--9
CAUSAL as Causal,
----10
CR.MONEDA as [CodigoMoneda],
----11
RIGHT(''0'' + CAST(FLOOR((IMPORTE * 100)) AS VARCHAR), 15) AS Importe,
----12
CAST(YEAR(FECHA_RECHAZO_O_PRES_COBRO) AS CHAR(4)) AS FechaRechazo_Anio,
RIGHT(''0'' + CAST(MONTH(FECHA_RECHAZO_O_PRES_COBRO) AS VARCHAR), 2) AS FechaRechazo_Mes,
RIGHT(''0'' + CAST(DAY(FECHA_RECHAZO_O_PRES_COBRO) AS VARCHAR), 2) AS FechaRechazo_Dia,
----13
RIGHT(''0'' + CAST(FECHA_REGISTRACION AS VARCHAR), 8) AS FechaRegistracion,
CAST(YEAR(FECHA_REGISTRACION) AS CHAR(4)) AS FechaRegistracion_Anio,
RIGHT(''0'' + CAST(MONTH(FECHA_REGISTRACION) AS VARCHAR), 2) AS FechaRegistracion_Mes,
RIGHT(''0'' + CAST(DAY(FECHA_REGISTRACION) AS VARCHAR), 2) AS FechaRegistracion_Dia,
--14
RIGHT(''0'' + CAST(PLAZO_DIFERIMIENTO AS VARCHAR), 3) AS PlazoDiferimiento,
--15

    CASE 
        WHEN COD_MOVIMIENTO = ''A'' THEN ''0000''  
        ELSE CAST(YEAR(CR.FECHA_PAGO_MULTA) AS CHAR(4))
    END AS [FechaPagoMulta_Anio],

    CASE 
        WHEN COD_MOVIMIENTO = ''A'' THEN ''00''  
        ELSE RIGHT(''0'' + CAST(MONTH(CR.FECHA_PAGO_MULTA) AS VARCHAR), 2)
    END AS [FechaPagoMulta_Mes],

    CASE 
        WHEN COD_MOVIMIENTO = ''A'' THEN ''00''  
        ELSE RIGHT(''0'' + CAST(DAY(CR.FECHA_PAGO_MULTA) AS VARCHAR), 2)
    END AS [FechaPagoMulta_Dia],
--16
''000000000000000000000000000000000000000000000000000000000000000000'' as SinUso,
--17

    CASE 
        WHEN COD_MOVIMIENTO = ''A'' THEN ''0000''  
        ELSE CAST(YEAR(CR.FECHA_PAGO_CHEQUE) AS CHAR(4))
    END AS [FechaPagoCheque_Anio],

    CASE 
        WHEN COD_MOVIMIENTO = ''A'' THEN ''00''  
        ELSE RIGHT(''0'' + CAST(MONTH(CR.FECHA_PAGO_CHEQUE) AS VARCHAR), 2)
    END AS [FechaPagoCheque_Mes],

    CASE 
        WHEN COD_MOVIMIENTO = ''A'' THEN ''00''  
        ELSE RIGHT(''0'' + CAST(DAY(CR.FECHA_PAGO_CHEQUE) AS VARCHAR), 2)
    END AS [FechaPagoCheque_Dia],

--Cast(Year(CR.FECHA_PAGO_MULTA) As Char(4)) as [FechaPagoMulta_Anio],
--RIGHT(''0'' + CAST(MONTH(CR.FECHA_PAGO_MULTA) AS VARCHAR), 2) AS [FechaPagoMulta_Mes], 
--RIGHT(''0'' + CAST(DAY(CR.FECHA_PAGO_MULTA) AS VARCHAR), 2) AS [FechaPagoMulta_Dia],
--18

    CASE 
        WHEN COD_MOVIMIENTO = ''A'' THEN ''0000''  
        ELSE CAST(YEAR(CR.FECHA_CIERRE_CTA) AS CHAR(4))
    END AS [FechaCierreCuenta_Anio],

    CASE 
        WHEN COD_MOVIMIENTO = ''A'' THEN ''00''  
        ELSE RIGHT(''0'' + CAST(MONTH(CR.FECHA_CIERRE_CTA) AS VARCHAR), 2)
    END AS [FechaCierreCuenta_Mes],

    CASE 
        WHEN COD_MOVIMIENTO = ''A'' THEN ''00''  
        ELSE RIGHT(''0'' + CAST(DAY(CR.FECHA_CIERRE_CTA) AS VARCHAR), 2)
    END AS [FechaCierreCuenta_Dia],
--CAST(YEAR(CR.FECHA_CIERRE_CTA) AS CHAR(4)) AS FechaCierreCuenta_Anio,  -- Se usa campo FECHA_CIERRE_CTA
--RIGHT(''0'' + CAST(MONTH(CR.FECHA_CIERRE_CTA) AS VARCHAR), 2) AS FechaCierreCuenta_Mes,  -- Se usa campo FECHA_CIERRE_CTA
--RIGHT(''0'' + CAST(DAY(CR.FECHA_CIERRE_CTA) AS VARCHAR), 2) AS FechaCierreCuenta_Dia,  -- Se usa campo FECHA_CIERRE_CTA
--19
RIGHT(''0'' + CAST(PRIMER_NRO_IDENTIFICATORIO AS VARCHAR), 11) AS PrimerNumeroIdentificatorio,

--20
RIGHT(''0'' + CAST(SEGUNDO_NRO_IDENTIFICATORIO AS VARCHAR), 11) AS SegundoNumeroIdentificatorio,

--21
RIGHT(''0'' + CAST(TERCER_NRO_IDENTIFICATORIO AS VARCHAR), 11) AS TercerNumeroIdentificatorio,

--22
RIGHT(''0'' + CAST(CUARTO_NRO_IDENTIFICATORIO AS VARCHAR), 11) AS CuartoNumeroIdentificatorio,

--23
RIGHT(''0'' + CAST(QUINTO_NRO_IDENTIFICATORIO AS VARCHAR), 11) AS QuintoNumeroIdentificatorio,

--24
RIGHT(''0'' + CAST(SEXTO_NRO_IDENTIFICATORIO AS VARCHAR), 11) AS SextoNumeroIdentificatorio,

--25
RIGHT(''0'' + CAST(SEPTIMO_NRO_IDENTIFICATORIO AS VARCHAR), 11) AS SeptimoNumeroIdentificatorio,

--26
RIGHT(''0'' + CAST(OCTAVO_NRO_IDENTIFICATORIO AS VARCHAR), 11) AS OctavoNumeroIdentificatorio,

--27
RIGHT(''0'' + CAST(NOVENO_NRO_IDENTIFICATORIO AS VARCHAR), 11) AS NovenoNumeroIdentificatorio,

--28
RIGHT(''0'' + CAST(DECIMO_NRO_IDENTIFICATORIO AS VARCHAR), 11) AS DecimoNumeroIdentificatorio,

--29
RIGHT(''0'' + CAST(CR.CODIGO_MOTIVO AS VARCHAR), 2) AS [CodigoMotivo],
--Fecha para comparar con parametro desde manejador de procesos
CONVERT(DATETIME,FECHA_REGISTRO_NOVEDAD,103) as FechaParametro,
CR.ESTADO,
CR.DEN_RECH
FROM RRII_CHE_RECHAZADOS CR WITH (NOLOCK);
')
