EXECUTE('
UPDATE dbo.NUMERATORDEFINITION
SET INIVAL = (
    SELECT 
        CASE 
            WHEN MAX(RIGHT(RTRIM(numraiz), LEN(numraiz) - LEN(prefijo))) IS NULL THEN 1
            WHEN ISNUMERIC(MAX(RIGHT(RTRIM(numraiz), LEN(numraiz) - LEN(prefijo)))) = 1 
                THEN CAST(MAX(CAST(RIGHT(RTRIM(numraiz), LEN(numraiz) - LEN(prefijo)) AS BIGINT)) + 1 AS BIGINT)
            ELSE 1
        END
    FROM TJD_ITF_TARJETA_RAIZ AS R
    WHERE prefijo = ''514365''
    GROUP BY prefijo
)
WHERE NUMERO = 34291

DELETE FROM NUMERATORASIGNED where OID in (select OID from NUMERATORVALUES where numero = 34291)

DELETE FROM NUMERATORVALUES where numero = 34291



UPDATE dbo.NUMERATORDEFINITION
SET INIVAL = (
    SELECT 
        CASE 
            WHEN MAX(RIGHT(RTRIM(numraiz), LEN(numraiz) - LEN(prefijo))) IS NULL THEN 1
            WHEN ISNUMERIC(MAX(RIGHT(RTRIM(numraiz), LEN(numraiz) - LEN(prefijo)))) = 1 
                THEN CAST(MAX(CAST(RIGHT(RTRIM(numraiz), LEN(numraiz) - LEN(prefijo)) AS BIGINT)) + 1 AS BIGINT)
            ELSE 1
        END
    FROM TJD_ITF_TARJETA_RAIZ AS R
    WHERE prefijo = ''501056''
    GROUP BY prefijo
)
WHERE NUMERO = 34290

DELETE FROM NUMERATORASIGNED where OID in (select OID from NUMERATORVALUES where numero = 34290)

DELETE FROM NUMERATORVALUES where numero = 34290
')
