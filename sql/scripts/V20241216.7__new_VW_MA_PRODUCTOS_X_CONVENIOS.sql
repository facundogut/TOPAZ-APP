execute ('

CREATE OR ALTER VIEW [dbo].[VW_MA_PRODUCTOS_X_CONVENIOS] (
	ConvenioPago,
	NomConvPago,
	TipoConvenio,
   	Producto,
	Descripcion_Producto)
AS
SELECT
	cp.ConvenioPago AS ConvenioPago,
	con.NomConvPago AS NomConvPago,
	con.Id_TpoConv AS TipoConvenio,
   	p.C6250 AS Producto,
	p.C6251 AS Descripcion_Producto
FROM MA_CONVENIO_PRODUCTOS cp WITH(nolock)
INNER JOIN CONV_CONVENIOS_PAG con WITH(nolock) ON cp.ConvenioPago=con.ID_ConvPago AND con.TZ_LOCK=0
INNER JOIN PRODUCTOS p WITH(nolock) ON p.C6250=cp.Producto AND p.TZ_LOCK=0
WHERE cp.TZ_LOCK=0

')