EXECUTE ('IF OBJECT_ID (''VW_COMISION_TARJETAS'') IS NOT NULL
	DROP VIEW VW_COMISION_TARJETAS')

EXECUTE('
CREATE      VIEW [VW_COMISION_TARJETAS] (
												JTS, 
												MONEDA, 
												SALDOACTUAL, 
												TIPOTARJETA, 
												SEGMENTO, 
												TITULAR, 
												CLASE, 
												TARJETA, 
												CANTMOVIMIENTOS, 
												JTS_OID_EMPLEADO, 
												SALDO_EMPLEADO)
AS 
SELECT 
    fci.JTS, 
    fci.MONEDA, 
    fci.SALDOACTUAL, 
    fci.TIPOTARJETA, 
    fci.SEGMENTO, 
    fci.TITULAR, 
    fci.CLASE, 
    fci.TARJETA, 
    fci.CANTMOVIMIENTOS, 
    fci.JTS_OID_EMPLEADO, 
    fci.SALDO_EMPLEADO
FROM 
    (
        SELECT 
        TA.JTS_OID_GTOS AS JTS, 
        S.MONEDA AS MONEDA, 
        S.C1604 AS SALDOACTUAL, 
        TA.TIPO_TARJETA AS TIPOTARJETA, 
        ISNULL(RIGHT(''00000'' + ISNULL(CAST(TA.COD_PAQUETE AS nvarchar(4000)), ''''), 5), '''') + ''00000'' AS SEGMENTO, 
        CASE 
            WHEN TA.TITULARIDAD = ''T'' THEN ''S''
            ELSE ''N''
        END AS TITULAR, 
        TP.CLASE AS CLASE, 
        TA.ID_TARJETA AS TARJETA, 
            
            (
                SELECT isnull(sum(TM.EXTRACCIONES_ACUMULADAS), 0) AS expr
                FROM TJD_ATM_CONTADOR_MENSUAL  AS TM WITH(NOLOCK)
                WHERE 
                    CAST(CONVERT(varchar(2), P.FECHAPROCESO, 101) AS numeric(38, 10)) = TM.MES AND 
                    CAST(CONVERT(varchar(4), P.FECHAPROCESO, 102) AS numeric(38, 10)) = TM.ANIO AND 
                    TA.ID_TARJETA = CAST(TM.ID_TARJETA AS varchar(max))
            ) AS CANTMOVIMIENTOS, 
            
            (
                SELECT isnull(SSMAROWNUM.JTS_OID, 0) AS expr
                FROM 
                    (
                    SELECT 
                        JTS_OID, 
                        SALDO_JTS_OID, 
                        TZ_LOCK, 
                        TZ_LOCK$2, 
                        ID_TARJETA, 
                        ROW_NUMBER() OVER(
                            ORDER BY SSMAPSEUDOCOLUMN) AS ROWNUM
                    FROM 
                        (
                            SELECT 
                                SA.JTS_OID, 
                                TC.SALDO_JTS_OID, 
                                TC.TZ_LOCK, 
                                SA.TZ_LOCK AS TZ_LOCK$2, 
                                TC.ID_TARJETA, 
                                0 AS SSMAPSEUDOCOLUMN
                            FROM SALDOS  AS SA WITH(NOLOCK)
							INNER JOIN TJD_REL_TARJETA_CUENTA  AS TC  WITH(NOLOCK)ON  
																						SA.JTS_OID = TC.SALDO_JTS_OID  
																						AND TC.TZ_LOCK = 0  
																						AND SA.TZ_LOCK = 0  
																						AND TC.ID_TARJETA = TA.ID_TARJETA  
																						AND TC.TZ_LOCK = 0  
																						AND 1 = 1
                        )  AS SSMAPSEUDO
                    )  AS SSMAROWNUM
                WHERE 
                    SSMAROWNUM.JTS_OID = SSMAROWNUM.SALDO_JTS_OID AND 
                    SSMAROWNUM.TZ_LOCK = 0 AND 
                    SSMAROWNUM.TZ_LOCK = 0 AND 
                    SSMAROWNUM.ID_TARJETA = TA.ID_TARJETA AND 
                    SSMAROWNUM.TZ_LOCK = 0 AND 
                    SSMAROWNUM.ROWNUM = 1
            ) AS JTS_OID_EMPLEADO, 
            
            (
                SELECT isnull(SSMAROWNUM$2.C1604, 0) AS expr
                FROM 
                    (
                    SELECT 
                        C1604, 
                        JTS_OID, 
                        SALDO_JTS_OID, 
                        TZ_LOCK, 
                        TZ_LOCK$2, 
                        ID_TARJETA, 
                        ROW_NUMBER() OVER(
                            ORDER BY SSMAPSEUDOCOLUMN) AS ROWNUM
                    FROM 
                        (
                            SELECT 
                                SA$2.C1604, 
                                SA$2.JTS_OID, 
                                TC$2.SALDO_JTS_OID, 
                                TC$2.TZ_LOCK, 
                                SA$2.TZ_LOCK AS TZ_LOCK$2, 
                                TC$2.ID_TARJETA, 
                                0 AS SSMAPSEUDOCOLUMN
                            FROM SALDOS  AS SA$2 WITH(NOLOCK)
							INNER JOIN TJD_REL_TARJETA_CUENTA  AS TC$2 WITH(NOLOCK)ON
																						SA$2.JTS_OID = TC$2.SALDO_JTS_OID  
																						AND TC$2.TZ_LOCK = 0  
																						AND SA$2.TZ_LOCK = 0  
																						AND TC$2.ID_TARJETA = TA.ID_TARJETA  
																						AND TC$2.TZ_LOCK = 0  
																						AND 1 = 1
                        )  AS SSMAPSEUDO$2
                    )  AS SSMAROWNUM$2
                WHERE 
                    SSMAROWNUM$2.JTS_OID = SSMAROWNUM$2.SALDO_JTS_OID AND 
                    SSMAROWNUM$2.TZ_LOCK = 0 AND 
                    SSMAROWNUM$2.TZ_LOCK = 0 AND 
                    SSMAROWNUM$2.ID_TARJETA = TA.ID_TARJETA AND 
                    SSMAROWNUM$2.TZ_LOCK = 0 AND 
                    SSMAROWNUM$2.ROWNUM = 1
            ) AS SALDO_EMPLEADO
        FROM TJD_TARJETAS  AS TA WITH(NOLOCK)
        INNER JOIN TJD_TIPO_TARJETA  AS TP WITH(NOLOCK)ON TA.TIPO_TARJETA = TP.TIPO_TARJETA
															AND TP.TZ_LOCK = 0
        INNER JOIN SALDOS  AS S WITH(NOLOCK)ON S.JTS_OID = TA.JTS_OID_GTOS
        ,PARAMETROS  AS P WITH(NOLOCK)
        WHERE TA.TZ_LOCK = 0 
    )  AS fci
WHERE fci.JTS_OID_EMPLEADO IS NOT NULL')




