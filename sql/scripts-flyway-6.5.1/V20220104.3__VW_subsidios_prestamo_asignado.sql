execute('
IF OBJECT_ID (''VW_SUBSIDIOS_PRESTAMO_ASIGNADO'') IS NOT NULL
	DROP VIEW VW_SUBSIDIOS_PRESTAMO_ASIGNADO
')
execute('	
CREATE   VIEW [dbo].[VW_SUBSIDIOS_PRESTAMO_ASIGNADO] (
															TipoDocumento, 
															NumeroDocumento, 
															Nombre, 
															Sucursal, 
															Producto, 
															Cuenta, 
															Operacion, 
															Ordinal, 
															Subsidio, 
															Descripcion, 
															FechaDesde, 
															Jts_asistencia,
															Prioridad,
															Moneda)
AS
SELECT c.TIPODOC AS TipoDocumento, 
		c.NUMERODOC AS NumeroDocumento, 
		c.NOMBRECLIENTE AS Nombre, 
		p.NOMBRESUCURSAL AS Sucursal, 
		p.NOMBREPRODUCTO AS Producto, 
		p.CUENTA AS Cuenta, 
		p.OPERACION AS Operacion, 
		p.DESGLOSE AS Ordinal, 
		s.CodigoSubsidio AS Subsidio, 
		sub.Descripcion, 
		s.FechaDesde, 
		s.Jts_asistencia, 
		s.Prioridad, 
		p.MONEDA AS Moneda
FROM CRE_SUBSIDIOS_PRESTAMOS s WITH(NOLOCK)
INNER JOIN CRE_SUBSIDIOS sub WITH(NOLOCK) ON s.CodigoSubsidio = sub.CodigoSubsidio AND sub.TZ_LOCK = 0
INNER JOIN VW_ASISTENCIAS p WITH(NOLOCK) ON s.Jts_asistencia = p.JTS_OID
INNER JOIN VW_CLI_X_DOC c WITH(NOLOCK) ON p.CLIENTE = c.CODIGOCLIENTE
WHERE s.Estado = ''A'' 
		AND s.TZ_LOCK = 0;
')


