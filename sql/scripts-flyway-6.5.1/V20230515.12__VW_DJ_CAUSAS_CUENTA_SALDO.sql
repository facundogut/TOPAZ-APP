EXECUTE('
CREATE OR ALTER VIEW VW_DJ_CAUSAS_CUENTA_SALDO (
														[Nro. Causa],
														[Juzgado],
														[Año],
														[Expediente],
														[Tipo Causa],
														[Fecha Causa],
														[Estado],
														[Caratula],
														[Cuenta],
														[Alta de la Cuenta],
														[Fecha de Oficio],
														[Bloqueo de la Cuenta],
														[Saldo de la Cuenta])
AS
SELECT
		c.NRO_CAUSA,
		c.JUZGADO,
		c.ANO,
		c.EXPEDIENTE,
		c.TIPO_CAUSA,
		c.FECHA_CAUSA,
		(	SELECT DESCRIPCION 
			FROM OPCIONES WITH(NOLOCK)
			WHERE NUMERODECAMPO=33141 
			AND OPCIONINTERNA=c.ESTADO) AS ESTADO,
		c.CARATULA,
		s.CUENTA,
		s.C1620,
		a.FECHA_OFICIO,
		b.DESCRIPCION,
		S.C1604
FROM DJ_CAUSAS c  WITH(NOLOCK)
INNER JOIN DJ_CAUSA_CUENTA a WITH(NOLOCK) ON c.NRO_CAUSA=a.NRO_CAUSA 
										AND(	(c.TZ_LOCK < 300000000000000 OR c.TZ_LOCK >= 400000000000000) 
											AND (c.TZ_LOCK < 100000000000000 OR c.TZ_LOCK >= 200000000000000)) 
										AND(	(a.TZ_LOCK < 300000000000000 OR a.TZ_LOCK >= 400000000000000) 
											AND (a.TZ_LOCK < 100000000000000 OR a.TZ_LOCK >= 200000000000000)) 
INNER JOIN saldos s WITH(NOLOCK) ON a.JTS_OID_CUENTA=s.JTS_OID 
							AND(	(s.TZ_LOCK < 300000000000000 OR s.TZ_LOCK >= 400000000000000) 
								AND (s.TZ_LOCK < 100000000000000 OR s.TZ_LOCK >= 200000000000000)) 
LEFT JOIN GRL_BLOQUEOS b WITH(NOLOCK) ON s.JTS_OID=b.SALDO_JTS_OID 
									AND b.ESTADO<>2; 
')
