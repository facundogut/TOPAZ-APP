/****** Object:  View [dbo].[VW_RESERVAS_SALDO]    Script Date: 24/02/2021 17:21:29 ******/
DROP VIEW [dbo].[VW_RESERVAS_SALDO]
GO

/****** Object:  View [dbo].[VW_RESERVAS_SALDO]    Script Date: 24/02/2021 17:21:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VW_RESERVAS_SALDO] (
								   [Nro Reserva],
								   [Importe Origen],
								   [Importe Disponible],
								   [Tipo Reserva],
								   [Descripcion],
								   [Estado],
								   [Descripcion Estado],
								   [Fecha Vigencia],
								   [Fecha Vencimiento],
								   Sucursal,
								   Cuenta,
								   Nombre,
								   Producto,
								   [Descripcion Prod],
								   Moneda
								   )
AS 
  SELECT 
		  R.NRO_RESERVA, 
		  R.IMPORTE_ORIGEN, 
		  R.IMPORTE_DISPONIBLE, 
		  R.TIPO_RESERVA, 
		  V.DESCRIPCION, 
		  R.ESTADO,
			(	SELECT DESCRIPCION 
				FROM OPCIONES with (nolock)
				WHERE NUMERODECAMPO = 24545 
				AND OPCIONINTERNA = R.ESTADO
			),
		  R.FECHA_VIGENCIA, 
		  R.FECHA_VENCIMIENTO,
		  W.SUCURSAL,
		   W.CUENTA, 
		  W.NOMBRE, 
		  W.PRODUCTO, 
		  W.DESCRIPCION,
		  W.MONEDA
  FROM VTA_RESERVAS R with (nolock)
		inner join VTA_TIPO_RESERVAS V with (nolock) on R.TIPO_RESERVA = V.TIPO
		inner join VW_CUENTAS W with (nolock)on R.SALDO_JTS_OID = W.JTS_OID
  WHERE   
   R.TZ_LOCK = 0 
   AND V.TZ_LOCK = 0 
   AND W.C1651 <> '1'
GO


