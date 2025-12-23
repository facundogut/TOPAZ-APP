-------------------------------------------------------------------------------------------
-- FIX A CUENTAS REDLINK E INTERBANK PARA CUENTAS JUDICIALES CREADAS DESDE EL 2025-03-01 --
-------------------------------------------------------------------------------------------

EXEC('
    UPDATE VS
    SET 
        VS.CTA_REDLINK = CONCAT(
            t.TIPO_CTA_REDLINK,
            FORMAT(s.SUCURSAL, ''00000''),
            FORMAT(s.CUENTA,''00000000000''),
            SPACE(3)
        ),
        VS.CTA_INTERBANK = CONCAT(
            t.TIPO_CTA_INTERBANK, 
            FORMAT(s.SUCURSAL, ''00000''), 
            FORMAT(s.CUENTA,''00000000000''),
            SPACE(1)
        )
    FROM dbo.VTA_SALDOS VS
    INNER JOIN dbo.SALDOS s 
        ON vs.JTS_OID_SALDO = s.JTS_OID 
        AND s.PRODUCTO IN (9,10)
        AND s.FECHA_REAL_APERTURA > TRY_CONVERT(DATETIME, ''2025-03-01'') 
    INNER JOIN dbo.TOPESPRODUCTO t 
        ON t.CODPRODUCTO = s.PRODUCTO 
        AND t.MONEDA = s.MONEDA
');