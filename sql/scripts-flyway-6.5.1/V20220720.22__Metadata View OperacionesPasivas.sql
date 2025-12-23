EXECUTE('
	DROP VIEW dbo.RRII_OperacionesPasivas
')
EXECUTE ('
CREATE   view dbo.RRII_OperacionesPasivas as
SELECT
    gsd.FECHA as FechaParametroEntrada,
    S.SUCURSAL as NroSucursal,
    (SELECT 
        ID3
     FROM 
         RRI_PARAMETROS_INF WITH (NOLOCK)
     WHERE 
         CODIGO = 5
        AND ID1 = S.PRODUCTO
        AND ID2= S.MONEDA
    ) as TipoOperacion,
    vcp.TIPOPERSONA as TipoPersona,
    CASE 
        WHEN s.C1785<>4
            THEN s.CUENTA
        ELSE 
            s.OPERACION
    END as NroCuenta,
    CONCAT(YEAR(s.C1620), RIGHT(''0'' + RTRIM(MONTH(s.C1620)), 2), RIGHT(''0'' + RTRIM(DAY(s.C1620)), 2)) as FechaAperturaCuenta,
    CASE    
        WHEN s.C1785 IN(2,3)
            THEN ''000000000000000''
        ELSE 
            s.OPERACION
    END NroCertificadoPlazoFijo,
    CASE  
        WHEN S.MONEDA NOT IN (998, 999)
            THEN     (SELECT 
						S2.C1785 
                    FROM 
                        SALDOS S2 WITH (NOLOCK) 
                    WHERE 
                        S2.JTS_OID = S.C1665 
                        AND S2.C1688 = 0
                        AND S2.TZ_LOCK = 0)

        ELSE
            (SELECT 
                S3.C1785 
            FROM 
                SALDOS S3 WITH (NOLOCK) 
            WHERE 
                S3.TZ_LOCK = 0
                AND S3.JTS_OID = (SELECT TOP 1 
                                    CV.JTS_OID_CTA_FUENTE 
                                FROM 
                                    CV_TRANSFERENCIA CV WITH (NOLOCK) 
                                JOIN SALDOS S WITH (NOLOCK) ON 
                                    S.TZ_LOCK = 0
                                    AND CV.JTS_OID_CTA_DESTINO=S.JTS_OID 
                                    AND S.C1688=0
                                WHERE 
                                    CV.TZ_LOCK = 0))
	END as OrigenImposicion,
	CASE 
		WHEN s.C1688 > 0 
			THEN s.OPERACION
		ELSE ''000000000000000''
	END PlazoFijoRenovado,
	CONCAT(YEAR(s.C1620), RIGHT(''0'' + RTRIM(MONTH(s.C1620)), 2), RIGHT(''0'' + RTRIM(DAY(s.C1620)), 2)) as FechaConstitucion,
	CASE 
		WHEN s.C1785=4 
			THEN DATEDIFF(d,s.C1621, s.C1627) 
		ELSE ''00000'' 
	END AS Plazo,
	CONCAT(YEAR(s.C1627), RIGHT(''0'' + RTRIM(MONTH(s.C1627)), 2), RIGHT(''0'' + RTRIM(DAY(s.C1627)), 2)) as FechaVencimientoPlazoFijo,
	gsd.SALDO_AJUSTADO as CapitalMonedaOrigen,
	gsd.SALDO_AJUSTADO_MN as CapitalPesos,
	s.C1611 as InteresDevengado,
	0 as Coef,
	CASE 
		WHEN s.C1785=2 AND s.MONEDA IN(998, 999) 
			THEN (SELECT s2.C1604 FROM SALDOS s2 WITH (NOLOCK)  WHERE s.SUCURSAL = s2.SUCURSAL AND s.CUENTA = s2.CUENTA AND s.MONEDA = s2.MONEDA 
				  AND s.OPERACION = s2.OPERACION AND s.PRODUCTO = s2.PRODUCTO AND SUBSTRING(REPLACE(CAST(C1730 AS VARCHAR (18)), ''.'', ''''),1,6) = ''311870'')
		WHEN s.C1785=4 AND s.MONEDA IN(998, 999) 
			THEN (SELECT s2.C1604 FROM SALDOS s2 WITH (NOLOCK)  WHERE s.SUCURSAL = s2.SUCURSAL AND s.CUENTA = s2.CUENTA AND s.MONEDA = s2.MONEDA 
				  AND s.OPERACION = s2.OPERACION AND s.PRODUCTO = s2.PRODUCTO AND SUBSTRING(REPLACE(CAST(C1730 AS VARCHAR (18)), ''.'', ''''),1,6) = ''311868'')
		ELSE 0 END AS AjusteUvaUvi,
(select ABS(gsd.SALDO_AJUSTADO) + ABS(s.C1611)) as Monto, 
(select ABS(gsd.SALDO_AJUSTADO_MN) + ABS(s.C1611)) as MontoPesos,
s.C1632 as TasaInteresPactada,
CASE 
		WHEN s.C1690  = ''F'' then 0
		WHEN s.C1690  = ''V'' then 1
		END TipoTasa,--caso de Ajustable Cer aplica cuando saldo en moneda extranjera y Ajustable UVA-UVI moneda es 999 o 998.  
	CASE 
		WHEN s.c1785 IN(2,3)
				THEN 0
	ELSE 1 
	END as TasaVariable,
	CASE
		WHEN S.C1785 IN (2,3)
			THEN 0
	ELSE 
		CASE prd.C6259
			WHEN ''P''
				THEN
					CAST ((((POWER( ((((s.C1632 / 100) * S.C1642) / prd.C6255) + 1),
					prd.C6255 / s.C1642)) - 1) * 100) AS DECIMAL(11,2))
		ELSE 
			CAST ((((POWER( ((((s.C1632 / 100) * datediff(day,s.C1621,s.C1627)) / prd.C6255) + 1),
			prd.C6255 / datediff(day,s.C1621,s.C1627))) - 1) * 100) AS DECIMAL(11,2))
		END
	END AS TasaNominalAnual,
	(SELECT SUM(mc.CAPITALREALIZADO) 
		from MOVIMIENTOS_CONTABLES mc WITH (NOLOCK)  
		where mc.DEBITOCREDITO = ''D'' 
			and MONTH(mc.FECHAPROCESO)= MONTH(gsd.FECHA)  ) as DebitosTotales, 
	(SELECT SUM(mc.CAPITALREALIZADO) 
		from MOVIMIENTOS_CONTABLES mc WITH (NOLOCK)
		where mc.DEBITOCREDITO = ''C'' 
		and MONTH(mc.FECHAPROCESO)= MONTH(gsd.FECHA)) as CreditosTotales,
	gsd.SUMA_PROMEDIO_DIARIO as PromedioMensual,
	m.C6400 as MonedaOrigen,
	0 as RETRIB, 
	vcp.TIPODOC as TipoIdentidad, 
	vcp.NUMERODOC as NroIdentidad, 
	CASE 
		WHEN vcp.TIPOPERSONA = ''F'' 
			THEN ''Persona Física''
		WHEN vcp.TIPOPERSONA = ''J'' 
			THEN ''Persona Jurídica''
		END IdentidadDenominacion,
	SUBSTRING(CAST(s.C1730 AS VARCHAR), 0, (8)) as CuentaContable,
	s.C1730 as CuentaContableUsoInterno
FROM 
    SALDOS S WITH (NOLOCK)
join GRL_SALDOS_DIARIOS gsd WITH (NOLOCK) on 
    s.JTS_OID = gsd.SALDOS_JTS_OID
    AND gsd.TZ_LOCK = 0
join VW_CLIENTES_PERSONAS vcp WITH (NOLOCK) on 
    s.C1803 = vcp.CODIGOCLIENTE
join MONEDAS m WITH (NOLOCK) on 
    s.MONEDA = m.C6399
    AND m.TZ_LOCK = 0
join PRODUCTOS prd WITH (NOLOCK) ON
    s.PRODUCTO = prd.C6250
    AND prd.TZ_LOCK = 0
WHERE 
    S.TZ_LOCK = 0 AND 
    S.C1785 IN (2,3,4)
')