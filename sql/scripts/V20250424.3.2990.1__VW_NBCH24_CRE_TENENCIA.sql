EXECUTE('
	CREATE OR ALTER VIEW dbo.VW_NBCH24_CRE_TENENCIA
	AS
	SELECT 
	cast(s.sucursal as varchar) + ''-'' + cast(s.operacion as varchar) + ''-'' + cast(s.ordinal as varchar) + ''-'' + cast(s.jts_oid as varchar) id,
	s.SUCURSAL sucursal, 
	s.OPERACION operacion, 
	s.ORDINAL ordinal,
	S.PRODUCTO producto, 
	P.C6251 AS NOMBRE_PRODUCTO, 
	p.c6805 tipoTasa, 
	S.MONEDA moneda, 
	S.C1621 AS fecInicio, 
	S.C1627 AS fecVencimiento,
	S.C1642*S.C1644 AS plazo, 
	S.C1601 AS montoSolicitado, 
	S.C1645 AS cuotasPagadas, 
	S.C1644-S.C1645 AS cuotasPendientes ,
	(SELECT COUNT(C2300) FROM PLANPAGOS WITH (NOLOCK) WHERE SALDO_JTS_OID=S.JTS_OID AND C2302< (SELECT FECHAPROCESO FROM PARAMETROS WITH (NOLOCK)) AND (C2309+C2310>0)) AS cuotasMorosas, 
	CASE WHEN s.C1628 < (SELECT FECHAPROCESO FROM PARAMETROS WITH (NOLOCK)) THEN datediff(dd,s.C1628,(SELECT FECHAPROCESO FROM PARAMETROS WITH (NOLOCK)))  ELSE 0 END AS atraso, 
	S.C1612 AS montoCuota, 
	ABS(S.C1604) AS SALDO,
	CASE WHEN  s.C1628 < (SELECT FECHAPROCESO FROM PARAMETROS WITH (NOLOCK)) THEN VAD.SALDO_A_FECHA ELSE 0 END AS mora, 
	(C.TASA_CONVERTIDA+C.PUNTOS_CONVERTIDOS) AS TNA, 
	S.C1632 AS tea,
	C.CFT cft, 
	C.CFT_CON_IMPUESTOS cftImpuestos,
	s.jts_oid jtsCRE, 
	acv.modulo moduloCuentaCobro, 
	acv.SUCURSAL sucursalCuentaCobro, 
	acv.CUENTA cuentaCobro,
	s.C1665 jtsCuentaCobro,
	acv.idPersonaUsuario idPersonaUsuario, 
	acv.documentoUsuario documentoUsuario,
	acv.idPersonaTitular idPersonaTitular,
	acv.documentoTitular documentoTitular,
	acv.documentoContexto documentoContexto


	FROM SALDOS S WITH (NOLOCK)
	INNER JOIN PRODUCTOS P WITH (NOLOCK) ON P.C6250=S.PRODUCTO AND P.TZ_LOCK=0
	INNER JOIN CRE_SALDOS C WITH (NOLOCK) ON C.SALDOS_JTS_OID=S.JTS_OID AND C.TZ_LOCK=0
	inner join VW_NBCH24_ACCESOSCV acv on s.C1665 = acv.jts_oid
	INNER JOIN VW_ASISTENCIAS_DEUDA VAD ON VAD.JTS_OID=S.JTS_OID
	WHERE S.C1604 < 0 AND S.TZ_LOCK=0
	AND S.C1785 = 5  --prestamos;
');