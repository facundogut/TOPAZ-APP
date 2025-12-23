EXECUTE('
CREATE OR ALTER VIEW [dbo].[VW_CESIONES] (IDCONVENIORECAUDO,
									 NOMBRECONVENIO,
									 SUCURSAL,
									 NUMEROCUENTA,
									 NOMBRECUENTA,
									 CUIT, 
									 IDSERVICIORECAUDO, 
									 IDCESIONRECAUDO, 
									 DESCRIPCION, 
									 TIPOCESION, 
									 IMPORTE, 
					    			 PORCENTAJE, 
									 PRIORIDAD,
									 FECHAVENCIMIENTO)
AS 
SELECT C.Id_ConvRec AS ''Id Convenio Recaudo'',
		R.NomConvRec AS ''Nombre Convenio'', 
		V.SUCURSAL AS ''Sucursal'', 
		V.CUENTA AS ''Cuenta'', 
		V.NOMBRE AS ''Nombre Cuenta'', 
		R.Cuit AS ''CUIT'', 
		C.Id_ServRec AS ''Id Servicio Recaudo'', 
		C.Id_CesionRec AS ''Id Cesion Recaudo'', 
		C.Descripcion AS ''Descripción'',  
		O.DESCRIPCION AS ''Tipo Cesion'', 
		C.Importe AS ''Importe'', 
		C.Porcentaje AS ''Porcentaje'', 
		C.Prioridad AS ''Prioridad'', 
		R.FecVto AS ''Fecha Vencimiento''
FROM dbo.CONV_CESIONES AS C WITH (NOLOCK)
INNER JOIN dbo.CONV_CONVENIOS_REC AS R WITH (NOLOCK) 
	ON C.Id_ConvRec = R.Id_ConvRec AND R.TZ_LOCK = 0
INNER JOIN dbo.VW_CUENTAS AS V WITH (NOLOCK) 
	ON C.CuentaCes = V.JTS_OID
INNER JOIN dbo.OPCIONES AS O WITH (NOLOCK) 
	ON C.TpoCes = O.OPCIONINTERNA
WHERE C.TZ_LOCK = 0 AND O.NUMERODECAMPO = 44778
')