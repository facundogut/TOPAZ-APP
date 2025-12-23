EXECUTE('
IF OBJECT_ID (''VW_COMISION_BAJO_PROMEDIO'') IS NOT NULL
	DROP VIEW VW_COMISION_BAJO_PROMEDIO')

EXECUTE('
CREATE   VIEW [VW_COMISION_BAJO_PROMEDIO] (
													   JTS_OID, 
													   SALDO_ACTUAL, 
													   CLIENTE, 
													   TIPO_PRODUCTO, 
													   MONEDA, 
													   PRODUCTO, 
													   SEGMENTO, 
													   PROMEDIO, 
													   BAJOPROMEDIO, 
													   TZ_LOCK)
AS 
SELECT 
		fci.JTS_OID, 
		fci.SALDO_ACTUAL, 
		fci.CLIENTE, 
		fci.TIPO_PRODUCTO, 
		fci.MONEDA, 
		fci.PRODUCTO, 
		CAST(fci.SEGMENTO AS varchar(12)) AS SEGMENTO, 
		sum(fci.PROMEDIO) AS PROMEDIO, 
		fci.BAJOPROMEDIO, 
		0 AS TZ_LOCK
FROM 
      (
         SELECT 
            S.JTS_OID, 
            S.C1604 AS SALDO_ACTUAL, 
            S.C1803 AS CLIENTE, 
            S.C1785 AS TIPO_PRODUCTO, 
            S.MONEDA, 
            S.PRODUCTO AS PRODUCTO, 
            ISNULL(RIGHT(''00000'' + ISNULL(CAST(S.C1770 AS nvarchar(4000)), ''''), 5), '''') + ISNULL(RIGHT(''00000'' + ISNULL(CAST(S.C1771 AS nvarchar(4000)), ''''), 5), '''') AS SEGMENTO, 
            sum(I.SALDO_AJUSTADO) / count_big(I.SALDO_AJUSTADO) AS PROMEDIO, 
            CASE 
               WHEN S.C1621 < ''01-MAR-10'' THEN /*(select last_day((select add_months(fechaproceso,-2) from parametros))+1 from parametros )*/''S''
            ELSE ''N''
            END AS BAJOPROMEDIO
         FROM GRL_SALDOS_DIARIOS  AS I WITH(NOLOCK) 
         INNER JOIN SALDOS  AS S  WITH(NOLOCK) 
								ON S.JTS_OID = I.SALDOS_JTS_OID 
								AND S.TZ_LOCK = 0
								AND S.C1785 IN ( 2, 3 )  
								AND I.SALDO_AJUSTADO > 0  
								AND I.FECHA >= ''01-MAR-10''  
         GROUP BY 
            S.JTS_OID, 
            S.C1604, 
            S.C1803, 
            S.C1785, 
            S.MONEDA, 
            S.PRODUCTO, 
            S.C1770, 
            S.C1771, 
            S.C1621
		UNION
         SELECT 
            S$2.JTS_OID, 
            S$2.C1604 AS SALDO_ACTUAL, 
            S$2.C1803 AS CLIENTE, 
            S$2.C1785 AS TIPO_PRODUCTO, 
            S$2.MONEDA, 
            S$2.PRODUCTO AS PRODUCTO, 
            ISNULL(RIGHT(''00000'' + ISNULL(CAST(S$2.C1770 AS nvarchar(4000)), ''''), 5), '''') + ISNULL(RIGHT(''00000'' + ISNULL(CAST(S$2.C1771 AS nvarchar(4000)), ''''), 5), '''') AS SEGMENTO, 
            0 AS PROMEDIO, 
            CASE 
               WHEN S$2.C1621 < ''01-MAR-10'' THEN /*(select last_day((select add_months(fechaproceso,-2) from parametros))+1 from parametros )*/''S''
            ELSE ''N''
            END AS BAJOPROMEDIO
         FROM GRL_SALDOS_DIARIOS  AS I$2 WITH(NOLOCK)
         INNER JOIN SALDOS  AS S$2  WITH(NOLOCK) ON S$2.JTS_OID = I$2.SALDOS_JTS_OID 
														AND S$2.TZ_LOCK = 0
														AND S$2.C1785 IN ( 2, 3 )  
														AND I$2.SALDO_AJUSTADO <= 0  
														AND I$2.FECHA >= ''01-MAR-10''  
         GROUP BY 
            S$2.JTS_OID, 
            S$2.C1604, 
            S$2.C1803, 
            S$2.C1785, 
            S$2.MONEDA, 
            S$2.PRODUCTO, 
            S$2.C1770, 
            S$2.C1771, 
            S$2.C1621
      )  AS fci
GROUP BY 
      fci.JTS_OID, 
      fci.SALDO_ACTUAL, 
      fci.CLIENTE, 
      fci.TIPO_PRODUCTO, 
      fci.MONEDA, 
      fci.PRODUCTO, 
      fci.SEGMENTO, 
      fci.BAJOPROMEDIO')





