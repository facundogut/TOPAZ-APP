
EXECUTE('
CREATE OR ALTER  VIEW [dbo].[VW_CLE_CHEQUES_RECHAZADOS] (MICRLINE,
                                           NUMERO_SERIE,
                                           NUMERO_CHEQUE, 
                                           CUENTA,
                                           SUCURSAL,
                                           MONEDA,
                                           PRODUCTO,
                                           FECHA)
AS
SELECT 
concat(r.JTS_SALDOS,r.NRO_CHEQUE,r.MONEDA, R.CLIENTE) AS "MICRLINE",
r.serie_cheque AS "NUMERO_SERIE",
r.NRO_CHEQUE AS "NUMERO_CHEQUE",
r.CUENTA,
r.SUCURSAL,
r.MONEDA,
r.PRODUCTO,
r.FECHA_CHEQUE AS "FECHA"
from CHE_BCO_RECHAZADOS R
WHERE R.TZ_LOCK = 0 
AND R.FECHA_PAGO_MULTA IS null
')