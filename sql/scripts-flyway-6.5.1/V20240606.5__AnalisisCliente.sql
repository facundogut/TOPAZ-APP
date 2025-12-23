EXECUTE('
IF OBJECT_ID (''dbo.VW_ANALISIS_CLIENTE'') IS NOT NULL
	DROP VIEW dbo.VW_ANALISIS_CLIENTE
')

EXECUTE('
CREATE VIEW VW_ANALISIS_CLIENTE  
AS
WITH AcreditacionesSueldos AS ( 
    SELECT
        ROW_NUMBER() OVER (PARTITION BY SALDO_JTS_OID, CONVENIO ORDER BY FECHA DESC) AS RECIBO,
        SALDO_JTS_OID,
        CONVENIO,
        MONTO,
        FECHA
    FROM CRE_SOL_ACREDITACIONES_SUELDOS WITH (NOLOCK)
    WHERE TZ_LOCK = 0
), 

AcreditacionesFiltradas AS (
    SELECT
        SALDO_JTS_OID,
        CONVENIO,
        MONTO
    FROM AcreditacionesSueldos
    WHERE RECIBO < 12
    GROUP BY SALDO_JTS_OID, CONVENIO, MONTO, RECIBO
)


 SELECT     Count (A.SALDO_JTS_OID)    AS CANTIDAD,
               ROUND(AVG(A.MONTO),0) AS MONTO,
            ''Analisis de sueldos''   AS NOMBRE_PRODUCTO,
            NULL                     AS DESGLOSE,
            NULL                     AS LINEA,
            ''SU''                     AS CLASIFICACIÓN,
            S.CUENTA,
            ''''      AS SITUACION,
            S.C1785 AS TIPO,
            NULL    AS FECHA ,
            S.C1803,
            A.SALDO_JTS_OID AS JTS_OID,
            ''1''           AS SUMA_RESTA,
            A.CONVENIO,
            NULL AS SUCURSAL,
            NULL AS OPERACION 
 FROM       SALDOS S
 INNER JOIN AcreditacionesFiltradas A ON A.SALDO_JTS_OID = S.JTS_OID
 GROUP BY   A.SALDO_JTS_OID,
            S.CUENTA,
            S.C1803,
            A.CONVENIO,
            S.C1785
 UNION ALL
 SELECT DESGLOSE+1,
        MONTOORIGEN,
        CASE
               WHEN ASIST.TIPO=5 THEN ''Analisis Prestamos''
               WHEN ASIST.TIPO=1 THEN ''Analisis Tarjetas''
        END,
        DESGLOSE,
        PRODUCTO,
        CLASIFICACION,
        CUENTA,
        SITUACION,
        TIPO,
        VENCIMIENTO,
        ASIST.CLIENTE,
        JTS_OID,
        ''2'',
        ''0'',
        ASIST.SUCURSAL,
        ASIST.OPERACION
 FROM   VW_ASISTENCIAS_COBRADOR AS ASIST
 WHERE  ASIST.SALDO>0
 AND    ASIST.CLASIFICACION IN (''PP'',
                                ''AH'',
                                ''T'') 
')
