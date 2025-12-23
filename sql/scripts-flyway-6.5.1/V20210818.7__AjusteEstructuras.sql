EXECUTE('
IF OBJECT_ID (''dbo.VW_SUBSIDIOS_PRESTAMOS'') IS NOT NULL
	DROP VIEW dbo.VW_SUBSIDIOS_PRESTAMOS
')

EXECUTE('
CREATE VIEW dbo.VW_SUBSIDIOS_PRESTAMOS (
	CodigoSubsidio, Descripcion, FechaDesde, Estado, FechaInactivacion, Prioridad, JTS_OID
)
AS
SELECT c.CodigoSubsidio, c.Descripcion, s.FechaDesde, oe.DESCRIPCION AS Estado, s.FechaInactivacion, s.Prioridad, p.JTS_OID
FROM CRE_SUBSIDIOS_PRESTAMOS s
INNER JOIN SALDOS p ON s.Jts_asistencia = p.JTS_OID AND p.TZ_LOCK = 0
INNER JOIN CRE_SUBSIDIOS c ON s.CodigoSubsidio = c.CodigoSubsidio
INNER JOIN OPCIONES oe ON s.Estado = oe.OPCIONINTERNA AND oe.NUMERODECAMPO = 43125
')