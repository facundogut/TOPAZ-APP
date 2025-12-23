EXECUTE('
IF OBJECT_ID (''dbo.VW_CRE_DOCUMENTOS_DESC_O_AL_COBRO'') IS NOT NULL
	DROP VIEW dbo.VW_CRE_DOCUMENTOS_DESC_O_AL_COBRO
')

EXECUTE('
CREATE   VIEW [dbo].[VW_CRE_DOCUMENTOS_DESC_O_AL_COBRO]
AS

SELECT ''FACTURA'' AS tipo,
		ISNULL((SELECT C1803 
				FROM SALDOS WITH(NOLOCK) 
				WHERE JTS_OID=jts_oid_cta_vista),0) AS cliente, 
	CASE destino WHEN 3 THEN ''DESCUENTO'' 
	ELSE ''AL COBRO'' 
	END AS destino,
	tipo_documento,
	documento_librador,
	Serie + ''-'' + numero_doc_real AS documento,
	moneda,
	importe,
	fecha_documento,
	fecha_vencimiento,
	jts_oid_cta_vista ,
	0 AS banco_girado,
	0 AS sucursal_banco_girado, 
	0 AS numerico_cuenta_giradora,
	numero_doc_real AS numero,
	JTS_OID_SALDO  AS jts_oid,
	'' '' AS NOMBRE_CHEQUE
FROM CRE_CONF_FACTURAS WITH(NOLOCK)
WHERE ESTADO=1 
	AND TZ_LOCK=0
union
SELECT  ''CHEQUE'' AS TIPO, 
	ISNULL((SELECT C1803 
			FROM SALDOS WITH(NOLOCK) 
			WHERE JTS_OID=sal.jts_oid_banco),0) AS cliente, 
	CASE sal.destino_cheque WHEN 3 THEN ''DESCUENTO'' 
	ELSE ''AL COBRO'' 
	END AS destino,
	ISNULL(che.TIPO_DOCUMENTO,'''') AS tipo_documento,
	ISNULL(che.NUMERO_DOCUMENTO,'''') AS  documento_librador,
	convert(VARCHAR(4),sal.banco_girado,1) + ''-'' + convert(VARCHAR(5),sal.sucursal_banco_girado,1) + ''-'' + convert(VARCHAR(4),sal.COD_POSTAL,1) + ''-'' + convert(VARCHAR(12),sal.numero_cheque,1) + ''-'' + convert(VARCHAR(12),sal.numerico_cuenta_giradora,1) AS documento,
	sal.MONEDA,
	sal.importe,
	sal.fecha_alta AS fecha_documento,
	sal.fecha_acreditacion AS fecha_vencimiento,
	sal.jts_oid_banco AS jts_oid_cta_vusta,
	sal.banco_girado,
	sal.sucursal_banco_girado,
	sal.numerico_cuenta_giradora,
	CONVERT(VARCHAR(10),sal.numero_cheque) AS numero,
	isnull(sal.JTS_OID_DESCUENTO,0) AS jts_oid,
	che.NOMBRE_CHEQUE
FROM CLE_CHEQUES_SALIENTE sal WITH(NOLOCK) 
LEFT JOIN CHE_CUENTAS_CHEQUES che WITH(NOLOCK) ON sal.NUMERICO_CUENTA_GIRADORA = che.CUENTA_CHEQUE
AND sal.SUCURSAL_BANCO_GIRADO = che.SUC_CHEQUE AND sal.BANCO_GIRADO = che.BANCO_CHEQUE
WHERE sal.ESTADO = 2 AND sal.acreditado=0
	AND sal.DESTINO_CHEQUE IN(2,3) 
	AND sal.TZ_LOCK=0
')
