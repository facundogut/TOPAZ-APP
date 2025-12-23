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
	JTS_OID_SALDO  AS jts_oid
FROM CRE_CONF_FACTURAS WITH(NOLOCK)
WHERE ESTADO=1 
	AND TZ_LOCK=0
union
SELECT  ''CHEQUE'' AS TIPO, 
	ISNULL((SELECT C1803 
			FROM SALDOS WITH(NOLOCK) 
			WHERE JTS_OID=jts_oid_banco),0) AS cliente, 
	CASE destino_cheque WHEN 3 THEN ''DESCUENTO'' 
	ELSE ''AL COBRO'' 
	END AS destino,
	ISNULL((SELECT TOP 1 tipo_documento 
			FROM CHE_CUENTAS_CHEQUES WITH(NOLOCK) 
			WHERE CUENTA_CHEQUE= numerico_cuenta_giradora 
				AND SUC_CHEQUE = sucursal_banco_girado 
				AND  BANCO_CHEQUE=  banco_girado),'''') AS tipo_documento,
	ISNULL((SELECT TOP 1 numero_documento 
			FROM CHE_CUENTAS_CHEQUES WITH(NOLOCK) 
			WHERE CUENTA_CHEQUE= numerico_cuenta_giradora 
				AND SUC_CHEQUE = sucursal_banco_girado 
				AND  BANCO_CHEQUE=  banco_girado),'''') AS  documento_librador,
	convert(VARCHAR(4),banco_girado,1) + ''-'' + convert(VARCHAR(5),sucursal_banco_girado,1) + ''-'' + convert(VARCHAR(4),COD_POSTAL,1) + ''-'' + convert(VARCHAR(12),numero_cheque,1) + ''-'' + convert(VARCHAR(12),numerico_cuenta_giradora,1) AS documento,
	MONEDA,
	importe,
	fecha_alta AS fecha_documento,
	fecha_acreditacion AS fecha_vencimiento,
	jts_oid_banco AS jts_oid_cta_vusta,
	banco_girado,
	sucursal_banco_girado,
	numerico_cuenta_giradora,
	isnull(JTS_OID_DESCUENTO,0) AS jts_oid
FROM CLE_CHEQUES_SALIENTE WITH(NOLOCK) 
WHERE ESTADO = 2 AND acreditado=0
	AND DESTINO_CHEQUE IN(2,3) 
	AND TZ_LOCK=0
')

