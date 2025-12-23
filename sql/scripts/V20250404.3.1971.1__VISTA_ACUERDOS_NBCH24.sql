EXECUTE('
CREATE OR ALTER VIEW dbo.VW_NBCH24_CTA_ACUERDOS (jts_oid, nroAcuerdo, importe, tasa, fechaInicio, fechaVencimiento)
AS
SELECT 
    S.JTS_OID_SALDO, 
    S.Nro_Autorizacion, 
    s.Importe, 
    (SELECT TOP 1 T.tasa 
     FROM VTA_TASAS_SOBREGIROS T WITH(NOLOCK) 
     WHERE T.NRO_ACUERDO = S.Nro_Autorizacion ORDER BY T.FECHADESDE DESC) AS tasa, 
    S.Valor_vigencia, 
    S.Fecha_vencimiento
FROM VTA_SOBREGIROS S WITH(NOLOCK) 
WHERE S.tz_lock = 0 AND estado = 1;
');
