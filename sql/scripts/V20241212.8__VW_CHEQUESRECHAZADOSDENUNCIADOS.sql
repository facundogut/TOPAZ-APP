EXECUTE('

IF OBJECT_ID (''dbo.VW_ChequesRechazadosDenunciados'') IS NOT NULL
	DROP VIEW dbo.VW_ChequesRechazadosDenunciados;
')
EXECUTE('

CREATE        view [dbo].[VW_ChequesRechazadosDenunciados] as

SELECT 
--1
replicate(''0'', 5 - len(COD_ENTIDAD)) + cast (COD_ENTIDAD as varchar) as [CodigoEntidad],
--2
replicate(''0'', 3 - len(NRO_SUCURSAL)) + cast (CR.NRO_SUCURSAL as varchar) as NumeroSucursal,
--3
replicate(''0'', 11 - len(CR.CUENTA)) + cast (CR.CUENTA as varchar) as NumeroCuentaCorriente,
--4
replicate(''0'', 8 - len(CR.NRO_CHEQUE)) + cast (CR.NRO_CHEQUE as varchar) as NumeroCheque,
--5
(Select Right(Cast(Year(FECHA_NOTIF_O_DENUNCIA) As Char(4)),2)) as AvisoAnio, -- Se usa campo FECHA_NOTIF_O_DENUNCIA
--replicate(''0'', 6 - len(AVISO)) + cast (AVISO as varchar)as AvisoNumero,
AVISO AS AvisoNumero,
--6
COD_MOVIMIENTO as [CodigoMovimiento],
--7
CLASE_REGISTRO as ClaseRegistro,
--8
Cast(Year(FECHA_NOTIF_O_DENUNCIA) As Char(4)) as FechaNotificacionDenuncia_Anio, -- Se usa campo FECHA_NOTIF_O_DENUNCIA
replicate(''0'', 2 - len(Cast(MONTH(FECHA_NOTIF_O_DENUNCIA) AS varchar))) + CAST(MONTH(FECHA_NOTIF_O_DENUNCIA) AS varchar) as FechaNotificacionDenuncia_Mes, -- Se usa campo FECHA_NOTIF_O_DENUNCIA
replicate(''0'', 2 - len(Cast(DAY(FECHA_NOTIF_O_DENUNCIA) AS varchar))) + CAST(DAY(FECHA_NOTIF_O_DENUNCIA) AS varchar) as FechaNotificacionDenuncia_Dia, -- Se usa campo FECHA_NOTIF_O_DENUNCIA
--9
CAUSAL as Causal,
--10
replicate(''0'', 2 - len(CR.MONEDA)) + cast (CR.MONEDA as varchar) as [CodigoMoneda],
--11
replicate(''0'', 15 - len(cast (FLOOR((IMPORTE*100)) as varchar))) + cast (FLOOR((IMPORTE*100)) as varchar) as Importe,
--12
Cast(Year(FECHA_RECHAZO_O_PRES_COBRO) As Char(4)) as FechaRechazo_Anio,
replicate(''0'', 2 - len(Cast(MONTH(FECHA_RECHAZO_O_PRES_COBRO) AS varchar))) + CAST(MONTH(FECHA_RECHAZO_O_PRES_COBRO) AS varchar) as FechaRechazo_Mes, 
replicate(''0'', 2 - len(Cast(DAY(FECHA_RECHAZO_O_PRES_COBRO) AS varchar))) + CAST(DAY(FECHA_RECHAZO_O_PRES_COBRO) AS varchar) as FechaRechazo_Dia, 
--13
Cast(Year(FECHA_REGISTRACION) As Char(4)) as FechaRegistracion_Anio, -- Se usa campo FECHA_REGISTRACION
replicate(''0'', 2 - len(Cast(MONTH(FECHA_REGISTRACION) AS varchar))) + CAST(MONTH(FECHA_REGISTRACION) AS varchar) as FechaRegistracion_Mes, -- Se usa campo FECHA_REGISTRACION
replicate(''0'', 2 - len(Cast(DAY(FECHA_REGISTRACION) AS varchar))) + CAST(DAY(FECHA_REGISTRACION) AS varchar) as FechaRegistracion_Dia, -- Se usa campo FECHA_REGISTRACION
--14
replicate(''0'', 3 - len(PLAZO_DIFERIMIENTO)) + cast (PLAZO_DIFERIMIENTO as varchar) as PlazoDifirimiento,
--15
Cast(Year(FECHA_PAGO_CHEQUE) As Char(4)) as [FechaPagoCheque_Anio], -- Se usa campo [FECHA_PAGO_CHEQUE]
replicate(''0'', 2 - len(Cast(MONTH(FECHA_PAGO_CHEQUE) AS varchar))) + CAST(MONTH(FECHA_PAGO_CHEQUE) AS varchar) as [FechaPagoCheque_Mes], -- Se usa campo [FECHA_PAGO_CHEQUE]
replicate(''0'', 2 - len(Cast(DAY(FECHA_PAGO_CHEQUE) AS varchar))) + CAST(DAY(FECHA_PAGO_CHEQUE) AS varchar) as [FechaPagoCheque_Dia], -- Se usa campo [FECHA_PAGO_CHEQUE]
--16
''000000000000000000000000000000000000000000000000000000000000000000'' as SinUso,
--17
Cast(Year(CR.FECHA_PAGO_MULTA) As Char(4)) as [FechaPagoMulta_Anio],
replicate(''0'', 2 - len(Cast(MONTH(CR.FECHA_PAGO_MULTA) AS varchar))) + CAST(MONTH(CR.FECHA_PAGO_MULTA) AS varchar) as [FechaPagoMulta_Mes], 
replicate(''0'', 2 - len(Cast(DAY(CR.FECHA_PAGO_MULTA) AS varchar))) + CAST(DAY(CR.FECHA_PAGO_MULTA) AS varchar) as [FechaPagoMulta_Dia], 
--18
Cast(Year(CR.FECHA_CIERRE_CTA) As Char(4)) as FechaCierreCuenta_Anio, -- Se usa campo FECHA_CIERRE_CTA
replicate(''0'', 2 - len(Cast(MONTH(CR.FECHA_CIERRE_CTA) AS varchar))) + CAST(MONTH(CR.FECHA_PAGO_MULTA) AS varchar) as FechaCierreCuenta_Mes, -- Se usa campo FECHA_CIERRE_CTA
replicate(''0'', 2 - len(Cast(DAY(CR.FECHA_CIERRE_CTA) AS varchar))) + CAST(DAY(CR.FECHA_PAGO_MULTA) AS varchar) as FechaCierreCuenta_Dia, -- Se usa campo FECHA_CIERRE_CTA
--19
replicate(''0'', 11 - len(PRIMER_NRO_IDENTIFICATORIO)) + cast (PRIMER_NRO_IDENTIFICATORIO as varchar) as PrimerNumeroIdentificatorio,
--20
replicate(''0'', 11 - len(SEGUNDO_NRO_IDENTIFICATORIO)) + cast (SEGUNDO_NRO_IDENTIFICATORIO as varchar) as SegundoNumeroIdentificatorio,
--21
replicate(''0'', 11 - len(TERCER_NRO_IDENTIFICATORIO)) + cast (TERCER_NRO_IDENTIFICATORIO as varchar) as TercerNumeroIdentificatorio,
--22
replicate(''0'', 11 - len(CUARTO_NRO_IDENTIFICATORIO)) + cast (CUARTO_NRO_IDENTIFICATORIO as varchar) as CuartoNumeroIdentificatorio,
--23
replicate(''0'', 11 - len(QUINTO_NRO_IDENTIFICATORIO)) + cast (QUINTO_NRO_IDENTIFICATORIO as varchar) as QuintoNumeroIdentificatorio,
--24
replicate(''0'', 11 - len(SEXTO_NRO_IDENTIFICATORIO)) + cast (SEXTO_NRO_IDENTIFICATORIO as varchar) as SextoNumeroIdentificatorio,
--25
replicate(''0'', 11 - len(SEPTIMO_NRO_IDENTIFICATORIO)) + cast (SEPTIMO_NRO_IDENTIFICATORIO as varchar) as SeptimoNumeroIdentificatorio,
--26
replicate(''0'', 11 - len(OCTAVO_NRO_IDENTIFICATORIO)) + cast (OCTAVO_NRO_IDENTIFICATORIO as varchar) as OctavoNumeroIdentificatorio,
--27
replicate(''0'', 11 - len(NOVENO_NRO_IDENTIFICATORIO)) + cast (NOVENO_NRO_IDENTIFICATORIO as varchar) as NovenoNumeroIdentificatorio,
--28
replicate(''0'', 11 - len(DECIMO_NRO_IDENTIFICATORIO)) + cast (DECIMO_NRO_IDENTIFICATORIO as varchar) as DecimooNumeroIdentificatorio,
--29
replicate(''0'', 2 - len(CR.CODIGO_MOTIVO)) + cast (CR.CODIGO_MOTIVO as varchar) as [CodigoMotivo],
--Fecha para comparar con parametro desde manejador de procesos
FECHA_REGISTRO_NOVEDAD as FechaParametro,
CR.ESTADO
FROM RRII_CHE_RECHAZADOS CR WITH (NOLOCK);
')