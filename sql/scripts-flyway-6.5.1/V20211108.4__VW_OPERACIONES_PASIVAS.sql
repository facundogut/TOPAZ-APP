EXECUTE('
CREATE view RRII_OperacionesPasivas as
SELECT
gsd.FECHA as FechaParametroEntrada, --Campo solo para filtro
/*1*/ s.SUCURSAL as NroSucursal,
/*2*/ (SELECT ID3 FROM RRI_PARAMETROS_INF WHERE CODIGO = 5 AND ID1 = s.PRODUCTO AND ID2= s.MONEDA) as TipoOperacion, 
/*3*/ vcp.TIPOPERSONA as TipoPersona, --C1803.saldos, obtener las personas desde cli_clientepersona y con la persona ir a la VW_PERSONAS_CLIENTE y obtener el tipopersona.  
/*4*/ CASE WHEN s.C1785<>4 THEN s.CUENTA ELSE s.OPERACION END as NroCuenta,
/*5*/ CONCAT(YEAR(s.C1620), RIGHT(''0'' + RTRIM(MONTH(s.C1620)), 2), RIGHT(''0'' + RTRIM(DAY(s.C1620)), 2)) as FechaAperturaCuenta,
/*6*/ CASE WHEN s.C1785 IN(2,3) THEN ''000000000000000'' ELSE s.OPERACION END as NroCertificadoPlazoFijo, --Para CA se completa con ceros.
/*7*/ CASE 
		WHEN s.MONEDA NOT IN (998, 999)
			THEN (SELECT s2.C1785 FROM SALDOS s2 WHERE s2.JTS_OID = s.C1665 AND s.c1688 = 0)
			ELSE (SELECT s3.C1785 FROM SALDOS s3 WHERE s3.JTS_OID = 
					(SELECT cv.JTS_OID_CTA_FUENTE FROM CV_TRANSFERENCIA cv WHERE cv.JTS_OID_CTA_DESTINO = s.JTS_OID AND s.c1688 = 0))
	  END as OrigenImposicion,
/*8*/ CASE 
		WHEN s.C1688 > 0 THEN s.OPERACION
		ELSE ''000000000000000''
		END PlazoFijoRenovado,
/*9*/  CONCAT(YEAR(s.C1620), RIGHT(''0'' + RTRIM(MONTH(s.C1620)), 2), RIGHT(''0'' + RTRIM(DAY(s.C1620)), 2)) as FechaConstitucion,
/*10*/ CASE WHEN s.C1785=4 THEN DATEDIFF(d,s.C1621, s.C1627) ELSE ''00000'' END AS Plazo,
/*11*/ CONCAT(YEAR(s.C1627), RIGHT(''0'' + RTRIM(MONTH(s.C1627)), 2), RIGHT(''0'' + RTRIM(DAY(s.C1627)), 2)) as FechaVencimientoPlazoFijo,
/*12*/ gsd.SALDO_AJUSTADO as CapitalMonedaOrigen,
/*13*/ gsd.SALDO_AJUSTADO_MN as CapitalPesos,
/*14*/ s.C1611 as InteresDevengado,
--15
/*16*/ 0 as Coef,
/*17*/ CASE 
		WHEN s.C1785=2 AND s.MONEDA IN(998, 999) 
			THEN (SELECT s2.C1604 FROM SALDOS s2 WHERE s.SUCURSAL = s2.SUCURSAL AND s.CUENTA = s2.CUENTA AND s.MONEDA = s2.MONEDA 
				  AND s.OPERACION = s2.OPERACION AND s.PRODUCTO = s2.PRODUCTO AND SUBSTRING(REPLACE(CAST(C1730 AS VARCHAR (18)), ''.'', ''''),1,6) = ''311870'')
		WHEN s.C1785=4 AND s.MONEDA IN(998, 999) 
			THEN (SELECT s2.C1604 FROM SALDOS s2 WHERE s.SUCURSAL = s2.SUCURSAL AND s.CUENTA = s2.CUENTA AND s.MONEDA = s2.MONEDA 
				  AND s.OPERACION = s2.OPERACION AND s.PRODUCTO = s2.PRODUCTO AND SUBSTRING(REPLACE(CAST(C1730 AS VARCHAR (18)), ''.'', ''''),1,6) = ''311868'')
		ELSE 0 END AS AjusteUvaUvi,
/*18*/ (select ABS(gsd.SALDO_AJUSTADO) + ABS(s.C1611)) as Monto, 
/*19*/ (select ABS(gsd.SALDO_AJUSTADO_MN) + ABS(s.C1611)) as MontoPesos,
/*20*/ s.C1632 as TasaInteresPactada,
/*21*/ CASE 
		WHEN s.C1690  = ''F'' then 0
		WHEN s.C1690  = ''V'' then 1
		END TipoTasa,--caso de Ajustable Cer aplica cuando saldo en moneda extranjera y Ajustable UVA-UVI moneda es 999 o 998.  
/*22*/ CASE 
		WHEN s.c1785 IN(2,3)
			THEN 0
			ELSE 1 
		END as TasaVariable,--tasa variable
/*23*/ CASE prd.C6259
			WHEN ''P'' THEN
			CAST ((((POWER( ((((s.C1632 / 100) * S.C1642) / prd.C6255) + 1),
			prd.C6255 / s.C1642)) - 1) * 100) AS DECIMAL(11,2))
			ELSE
			CAST ((((POWER( ((((s.C1632 / 100) * datediff(day,s.C1621,s.C1627)) / prd.C6255) + 1),
			prd.C6255 / datediff(day,s.C1621,s.C1627))) - 1) * 100) AS DECIMAL(11,2))
			END AS TasaNominalAnual,--tasa referencia 
/*24*/ (SELECT SUM(mc.CAPITALREALIZADO) from MOVIMIENTOS_CONTABLES mc /*join s on s.JTS_OID = mc.SALDO_JTS_OID*/ where mc.DEBITOCREDITO = ''D'' and MONTH(mc.FECHAPROCESO)= MONTH(gsd.FECHA)  ) as DebitosTotales, --Debitos totales
/*25*/ (SELECT SUM(mc.CAPITALREALIZADO) from MOVIMIENTOS_CONTABLES mc /*join s on s.JTS_OID = mc.SALDO_JTS_OID*/ where mc.DEBITOCREDITO = ''C'' and MONTH(mc.FECHAPROCESO)= MONTH(gsd.FECHA)  ) as CreditosTotales, --Creditos totales (preguntar si es suma de capital realizado)
/*26*/ gsd.SUMA_PROMEDIO_DIARIO as PromedioMensual,  --(SELECT gsd.SUMA_PROMEDIO_DIARIO from GRL_SALDOS_DIARIOS gsd where MONTH((GETDATE(''2024-08-28'')))) as Prom 
/*27*/ m.C6400 as MonedaOrigen,
/*28*/ 0 as RETRIB, 
/*29*/ vcp.TIPODOC as TipoIdentidad, --TITULAR 1
/*30*/ vcp.NUMERODOC as NroIdentidad, 
/*31*/ CASE 
		WHEN vcp.TIPOPERSONA = ''F'' then ''Persona Física''
		WHEN vcp.TIPOPERSONA = ''J'' then ''Persona Jurídica''
		END IdentidadDenominacion,
/*44*/ SUBSTRING(CAST(s.C1730 AS VARCHAR), 0, (8)) as CuentaContable, --primeros 6 digitos
/*45*/ s.C1730 as CuentaContableUsoInterno
FROM SALDOS s --, PRODUCTOS p, 
join GRL_SALDOS_DIARIOS gsd on s.JTS_OID = gsd.SALDOS_JTS_OID 
join VW_CLIENTES_PERSONAS vcp on s.C1803 = vcp.CODIGOCLIENTE
join MONEDAS m on s.MONEDA = m.C6399
join PRODUCTOS prd on s.PRODUCTO = prd.C6250
where s.TZ_LOCK = 0
');