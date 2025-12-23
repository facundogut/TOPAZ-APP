EXECUTE ('
	IF OBJECT_ID (''dbo.VW_EXCLUSIONES_PROD_DOM'') IS NOT NULL
	DROP VIEW dbo.VW_EXCLUSIONES_PROD_DOM

')

EXECUTE ('
CREATE VIEW VW_EXCLUSIONES_PROD_DOM AS(
SELECT creprod.ID_PRODUCTO AS [Id Producto], prod.C6251 AS [Descripción Producto], creprod.ID_CONVENIO AS [Id Convenio], MAX(conv.NomConvPago) AS [Nombre Convenio], creprod.ID_JURISDICCION AS [Id Jurisdicción], dominio.Descripcion AS [Descripción Jurisdicción]
FROM 
CRE_PROD_CONV_EXCEPCIONES_JUR AS creprod WITH (NoLock) 
INNER JOIN productos AS prod WITH (NoLock) ON creprod.ID_PRODUCTO = prod.C6250 
INNER JOIN CONV_CONVENIOS_PAG AS conv WITH (NoLock) ON creprod.ID_CONVENIO = conv.ID_ConvPago 
INNER JOIN conv_dominios AS dominio WITH (NoLock) ON creprod.ID_JURISDICCION = dominio.ID_DOMINIO AND creprod.ID_CONVENIO = dominio.ID_CONVENIO AND DOMINIO.SUB_DOMINIO = 0
WHERE creprod.TZ_LOCK = 0
GROUP BY creprod.ID_PRODUCTO, prod.C6251, creprod.ID_CONVENIO, creprod.ID_JURISDICCION, dominio.Descripcion
)
')