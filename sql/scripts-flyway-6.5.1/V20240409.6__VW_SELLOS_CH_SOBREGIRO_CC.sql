EXECUTE('
IF OBJECT_ID (''dbo.VW_SELLOS_CH_SOBREGIRO_CC'') IS NOT NULL
	DROP VIEW dbo.VW_SELLOS_CH_SOBREGIRO_CC
')

EXECUTE('

CREATE   VIEW VW_SELLOS_CH_SOBREGIRO_CC (
		SALDOS_JTS_OID,
		Menor_Saldo_Ajustado,
		SUCURSAL, 
		PRODUCTO, 
		CUENTA, 
		MONEDA, 
		OPERACION, 
		ORDINAL,
		CODIGOCLIENTE,
		NUMEROPERSONA,
		COD_ACTIVIDAD
		)
AS
   

SELECT SD.SALDOS_JTS_OID, CONVERT(numeric(15,2),MIN(SD.SALDO_AJUSTADO)*-1) AS Menor_Saldo_Ajustado, 
       s.SUCURSAL, s.PRODUCTO, S.CUENTA, s.MONEDA, s.OPERACION, S.ORDINAL,
       convert(NUMERIC(12),s.C1803) CODIGOCLIENTE,
       cp.NUMEROPERSONA,AE.CODIGO_ACTIVIDAD AS COD_ACTIVIDAD
       FROM GRL_SALDOS_DIARIOS sd with (nolock)
INNER JOIN SALDOS S with (nolock) ON s.JTS_OID = sd.SALDOS_JTS_OID
                   AND S.TZ_LOCK = 0
                   AND s.PRODUCTO IN (SELECT C6250 FROM PRODUCTOS WHERE C6252 = 2)
INNER JOIN CLI_ClientePersona CP with (nolock) ON CP.CODIGOCLIENTE = s.C1803
                                AND CP.TITULARIDAD = ''T''
                                AND cp.TZ_LOCK = 0
INNER JOIN CLI_ACTIVIDAD_ECONOMICA AE with (nolock) ON AE.CODIGO_PERSONA_CLIENTE = cp.NUMEROPERSONA 
						AND AE.ORDINAL_ACTIVIDAD = 1
                                      
WHERE SD.TZ_LOCK = 0 
  AND SD.SALDO_AJUSTADO < 0
  AND (
        ((SELECT MONTH(FECHAPROCESO) FROM PARAMETROS with (nolock)) = 4 AND SD.FECHA BETWEEN (SELECT concat((SELECT year(fechaProceso) FROM PARAMETROS v),''0101'')) 
                                                                        AND (SELECT concat((SELECT year(fechaProceso) FROM PARAMETROS with (nolock)),''0331'')))
        OR
        ((SELECT MONTH(FECHAPROCESO) FROM PARAMETROS with (nolock)) = 7 AND SD.FECHA BETWEEN (SELECT concat((SELECT year(fechaProceso) FROM PARAMETROS with (nolock)),''0401'')) 
                                             AND (SELECT concat((SELECT year(fechaProceso) FROM PARAMETROS with (nolock)),''0630'')))
        OR
        ((SELECT MONTH(FECHAPROCESO) FROM PARAMETROS with (nolock)) = 10 AND SD.FECHA BETWEEN (SELECT concat((SELECT year(fechaProceso) FROM PARAMETROS with (nolock)),''0701'')) 
                                             AND (SELECT concat((SELECT year(fechaProceso) FROM PARAMETROS with (nolock)),''0930'')))
        OR
        ((SELECT MONTH(FECHAPROCESO) FROM PARAMETROS with (nolock)) = 1 AND SD.FECHA BETWEEN (SELECT concat((SELECT year(fechaProceso)-1 FROM PARAMETROS with (nolock)),''1001'')) 
                                             AND (SELECT concat((SELECT year(fechaProceso)-1 FROM PARAMETROS with (nolock)),''1231'')))
      )
GROUP BY SALDOS_JTS_OID,
         s.SUCURSAL, s.PRODUCTO, S.CUENTA, s.MONEDA, s.OPERACION, S.ORDINAL,s.C1803,cp.NUMEROPERSONA, AE.CODIGO_ACTIVIDAD

')
