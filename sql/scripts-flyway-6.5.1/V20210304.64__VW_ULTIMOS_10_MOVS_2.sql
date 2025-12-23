/****** Object:  View [dbo].[VW_ULTIMOS_10_MOVS_2]    Script Date: 24/02/2021 17:38:29 ******/
DROP VIEW [dbo].[VW_ULTIMOS_10_MOVS_2]
GO

/****** Object:  View [dbo].[VW_ULTIMOS_10_MOVS_2]    Script Date: 24/02/2021 17:38:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VW_ULTIMOS_10_MOVS_2] (FECHAPROCESO, 
											HORASISTEMA, 
											CLIENTE, 
											SUCURSAL_CUENTA, 
											CUENTA, 
											MONEDA, 
											PRODUCTO, SUCURSAL, 
											FECHAVALOR, 
											ASIENTO, 
											COD_TRANSACCION, 
											DESC_TRANSACCION, 
											CONCEPTO, 
											CAPITALREALIZADO, 
											DEBITOCREDITO, 
											NUMERO_CHEQUE, 
											OPERACION_CUENTA, 
											ORDINAL_CUENTA, 
											INIUSR, 
											OPERACION_TOPAZ,
											NROCAJA, 
											SALDO_JTS_OID
											)
AS 

			  SELECT m.fechaproceso,
				m.horasistema,
				m.cliente,
				m.sucursal_cuenta,
				m.cuenta,
				m.moneda,
				m.producto,
				m.sucursal,
				m.fechavalor,
				m.asiento,
				m.cod_transaccion,
				ISNULL(t.DESCRIPCION,' '),
				m.concepto,
				m.capitalrealizado,
				m.debitocredito,
				m.referencia as Numero_Cheque,
				m.operacion_cuenta,
				m.ordinal_cuenta,
				m.inicialesusuario as IniUsr,
				m.operacion as Operacion_Topaz,
				m.nrocaja,
				m.SALDO_JTS_OID
  FROM asientos a with (nolock) 
	inner join movimientos_contables m with (nolock) on m.fechaproceso = a.fechaproceso
														  AND m.sucursal   = a.sucursal
														  AND m.asiento    = a.asiento
	left join TTR_CODIGO_TRANSACCION_DEF t with (nolock) on m.COD_TRANSACCION = t.CODIGO_TRANSACCION 
  WHERE
    /*** Comparación ***/
   a.estado     = 77 
    /*** Filtros ***/
    --MANTIS 5668- Tiene que ser un Debito o un Credito
  AND rtrim(ltrim(m.debitocredito)) IS NOT NULL 
  --AND m.capitalrealizado<>0 --se comenta ya que se necesita para el reporte
GO


