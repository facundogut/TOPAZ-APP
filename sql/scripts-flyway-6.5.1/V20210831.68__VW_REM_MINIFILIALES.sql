EXECUTE('
CREATE OR ALTER VIEW VW_REM_MINIFILIALES 
AS
SELECT	rs.NRO_SOLICITUD ''Nro. Solicitud'', 
		rs.MONEDA Moneda, 
		rs.IMPORTE Importe, 
		rs.TIPODESTINO ''Tipo Destino'', 
		o.DESCRIPCION ''Descripción'', 
		rs.CAJA_DESTINO ''Caja Destino'', 
		vwc.MINIFILIAL ''Minifilial Destino'', 
		rs.SUCURSAL Sucursal, 
		rs.ESTADO Estado, 
		rs.CAJA_ORIGEN ''Caja Origen'' 
FROM REM_SOLICITUDREMESA rs WITH (NOLOCK) 
INNER JOIN OPCIONES o  WITH (NOLOCK) ON o.OPCIONINTERNA = rs.TIPODESTINO
									AND o.NUMERODECAMPO = 2599
									AND o.IDIOMA = ''E''
									AND rs.TIPODESTINO = 11
									AND rs.TIPOORIGEN = 11

INNER JOIN VW_CAJ_CAJAS vwc  WITH (NOLOCK)ON vwc.NRO_CAJA = rs.CAJA_DESTINO
											AND vwc.SUCURSAL = CAST(rs.DESTINO AS int) 
											AND vwc.MINIFILIAL > 0
')



