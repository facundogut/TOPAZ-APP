EXECUTE('
IF OBJECT_ID (''dbo.VW_SEGUROS_SALDO_VIDA'') IS NOT NULL
	DROP VIEW dbo.VW_SEGUROS_SALDO_VIDA
')

EXECUTE('
CREATE VIEW VW_SEGUROS_SALDO_VIDA AS
SELECT 
    A.Aseguradora,
    A.[Nombre Aseguradora],
    A.[Numero de Poliza],
    A.[Tipo de Seguro],
    A.[Monto de Seguro],
    A.[Tasa de Seguro],
    A.[Fecha de Vencimiento],
    A.[Jts Asistencia]
FROM (
    SELECT 
        SSD.ASEGURADORA AS Aseguradora, 
        CA.DESCRIPCION AS [Nombre Aseguradora], 
        SSD.NUMERO_POLIZA AS [Numero de Poliza], 
        ''Seguro Saldo Deudor'' AS [Tipo de Seguro],
        SSD.MONTO_SEGURO AS [Monto de Seguro], 
        SSD.TASA_SEGURO AS [Tasa de Seguro], 
        SSD.FECHA_VENCIMIENTO AS [Fecha de Vencimiento], 
        SSD.SALDOS_JTS_OID AS [Jts Asistencia]
    FROM CRE_SEGURO_SALDO_DEUDOR SSD WITH (nolock)
    INNER JOIN CRE_ASEGURADORAS CA WITH (nolock) ON CA.CODIGO = SSD.ASEGURADORA
    WHERE SSD.TIPO_SEGURO=''A'' AND SSD.TZ_LOCK=0
    UNION
    SELECT 
        SSD.ASEGURADORA AS Aseguradora, 
        CA.DESCRIPCION AS [Nombre Aseguradora], 
        SSD.NUMERO_POLIZA AS [Numero de Poliza], 
        ''Seguro de Vida Voluntario'' AS [Tipo de Seguro],
        SSD.MONTO_SEGURO AS [Monto de Seguro], 
        SSD.TASA_SEGURO AS [Tasa de Seguro], 
        SSD.FECHA_VENCIMIENTO AS [Fecha de Vencimiento], 
        SSD.SALDOS_JTS_OID AS [Jts Asistencia]
    FROM CRE_SEGURO_SALDO_DEUDOR SSD WITH (nolock)
    INNER JOIN CRE_ASEGURADORAS CA WITH (nolock) ON CA.CODIGO = SSD.ASEGURADORA
    WHERE SSD.TIPO_SEGURO=''M'' AND SSD.TZ_LOCK=0
    UNION
    SELECT 
        SVV.ASEGURADORA AS Aseguradora, 
        CREA.DESCRIPCION AS [Nombre Aseguradora], 
        SVV.NUMERO_POLIZA AS [Numero de Poliza], 
        ''Seguro de Vida Voluntario'' AS [Tipo de Seguro],
        SVV.MONTO AS [Monto de Seguro], 
        0 AS [Tasa de Seguro], 
        SVV.FECHA_VENCIMIENTO AS [Fecha de Vencimiento], 
        SVV.SALDO_JTS_OID AS [Jts Asistencia]
    FROM CRE_SEGURO_VIDA_VOLUNTARIO SVV WITH (nolock)
    INNER JOIN CRE_ASEGURADORAS CREA WITH (nolock) ON CREA.CODIGO = SVV.ASEGURADORA
    WHERE SVV.TZ_LOCK=0
    
) AS A;
')