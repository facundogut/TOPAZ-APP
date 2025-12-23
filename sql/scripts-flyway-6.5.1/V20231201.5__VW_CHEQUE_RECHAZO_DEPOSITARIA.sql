EXECUTE('
IF OBJECT_ID (''dbo.VW_CHEQUE_RECHAZO_DEPOSITARIA'') IS NOT NULL
	DROP VIEW dbo.VW_CHEQUE_RECHAZO_DEPOSITARIA
')

EXECUTE('
CREATE   VIEW [dbo].[VW_CHEQUE_RECHAZO_DEPOSITARIA] (ID_LIQUIDACION,
                                           MONEDA,
                                           NUMERO_CHEQUE,
                                           FECHA_VALOR,
                                           NUMERO_BANCO,
                                           NUMERO_DEPENDENCIA,
                                           CUENTA,
                                           ORDINAL_LISTA,
                                           SERIE_CHEQUE,
                                           CODIGO_CAUSAL_DEVOLUCION)
AS
SELECT ROW_NUMBER() OVER(ORDER BY a.NUMERO_CHEQUE) AS ID_LIQUIDACION,a.MONEDA, a.NUMERO_CHEQUE, a.FECHA_VALOR, a.NUMERO_BANCO, a.NUMERO_DEPENDENCIA, 
       a.CUENTA, a.ORDINAL_LISTA, a.SERIE_CHEQUE, a.CODIGO_CAUSAL_DEVOLUCION 
  FROM CLE_CHEQUES_CLEARING_RECH_DEPOSITARIA a
   INNER JOIN CHE_CHEQUES b ON b.TZ_LOCK = 0
                            AND b.SUCURSAL = a.NUMERO_DEPENDENCIA
                            AND b.MONEDA = a.MONEDA
                            AND b.NUMEROCHEQUE = a.NUMERO_CHEQUE
                            AND b.CUENTA = a.CUENTA
                            AND b.ORDINAL = a.ORDINAL_LISTA
                            AND b.ESTADO IN (''P'',''R'')
                            
 WHERE a.FECHA_VALOR = (SELECT dbo.diaHabil(DATEADD(day,-1,fechaproceso),''N'')FROM PARAMETROS)
   AND a.TZ_LOCK = 0
')