EXECUTE(' IF OBJECT_ID (''VW_SOL_CRED_EMPRESAS'') IS NOT NULL
	DROP VIEW VW_SOL_CRED_EMPRESAS')


EXECUTE('CREATE VIEW dbo.VW_SOL_CRED_EMPRESAS (
   Solicitud, 
   Operacion, 
   TipoDocumento, 
   NumeroDocumento, 
   Nombre, 
   Estado,
   "Descripcion Estado", 
   Producto, 
   "Descripcion Producto",
   Moneda,
   Monto,
   TipoSolicitud,
   Cliente)
AS 

SELECT TOP 9223372036854775807 WITH TIES 
      S.NUMEROSOLICITUD AS Solicitud, 
      S.OPERACION_RENOVACION AS Operacion, 
      s.TIPODOCUMENTO AS TipoDocumento,
      s.NUMERODOCUMENTO AS NumeroDocumento,       
      C.NOMBRECLIENTE AS Nombre, 
      S.ESTADOSOLICITUD AS Estado, 
      (SELECT O.DESCRIPCION FROM dbo.OPCIONES  AS O
      WHERE O.NUMERODECAMPO = 7333 AND  O.IDIOMA = ''E'' AND O.OPCIONINTERNA = S.ESTADOSOLICITUD) AS "Descripcion Estado",      
      S.CODPRODUCTOSOLICITADO AS Producto, 
      (SELECT P.C6251 FROM dbo.PRODUCTOS  AS P WHERE S.CODPRODUCTOSOLICITADO = P.C6250 AND P.TZ_LOCK = 0) AS "Descripcion Producto",      
      MON.C6401 AS Moneda,
      S.MONTOSOLICITADO AS Monto,     
	  S.TIPO_SOL_NUEVA_RENOVACION AS TipoSolicitud,
	  S.CLIENTE AS Cliente
   FROM dbo.CRE_SOLICITUDCREDITO  AS S, dbo.CLI_CLIENTES  AS C, dbo.MONEDAS AS MON
   WHERE 
      S.TZ_LOCK = 0 AND c.TZ_LOCK = 0 AND MON.TZ_LOCK = 0 AND S.CLIENTE = C.CODIGOCLIENTE AND s.MONEDA = MON.C6399 AND S.SOL_CRED = 1 AND S.TIPO_SOLICITUD = ''E''
   ORDER BY S.NUMEROSOLICITUD DESC')


EXECUTE('IF OBJECT_ID (''VW_GARANTIAS'') IS NOT NULL
	DROP VIEW VW_GARANTIAS')


EXECUTE('CREATE VIEW dbo.VW_GARANTIAS (
	Garantia, 
	NombreSucursal,
	Tipo_Garantia,
	SubClass_Garantia,
	Descripcion,
	Moneda, 
	Monto, 
	Vencimiento, 
	Tipo_Documento, 
	Documento, 
	Cobertura, 
	Cobertura_Post_Anio,
	Tipo_Documento_Ordenante,
	Documento_Ordenante)
AS 
	SELECT distinct
	gp.NUM_GARANTIA AS Garantia,
	s.NOMBRESUCURSAL AS NombreSucursal, 
	g.TIPOGARANTIA AS Tipo_Garantia,
	g.COD_SUBCLAGARANTIA AS SubClass_Garantia,
	c.DSC_CLASIFICACION AS Descripcion,
	m.C6401 AS Moneda, 
	g.IMPORTE_REAL AS Monto, 
	g.FCHVTO_GARANTIA AS Vencimiento, 
	doc.TIPODOC AS Tipo_Documento, 
	doc.NUMERODOC AS Documento, 
	c.PORCENTAJEAFECTACION AS Cobertura, 
	c.PORCENTAJEAFECTACION_1_ANIO AS Cobertura_Post_Anio,
	g.TIPODOCUMENTO AS Tipo_Documento_Ordenante, 
	g.NUMERODOCUMENTO AS Documento_Ordenante
	FROM CRE_GarantiaPersonas gp
	INNER JOIN CRE_GARANTIASRECIBIDAS g ON gp.NUM_GARANTIA = g.NUM_GARANTIA AND g.ESTADO_GARANTIA = ''AA'' AND gp.TZ_LOCK = 0
	INNER JOIN SUCURSALES s ON g.SUCURSAL_GARANTIA = s.SUCURSAL AND s.TZ_LOCK = 0
	INNER JOIN MONEDAS m ON g.MONEDA_GARANTIA = m.C6399 AND m.TZ_LOCK = 0
	INNER JOIN CRE_CLASGARANTIAS c ON g.TIPOGARANTIA = c.TIPOGARANTIA AND c.TZ_LOCK = 0
	INNER JOIN VW_CLI_X_DOC doc ON gp.NUM_PERSONA = doc.NUMEROPERSONA
	WHERE gp.TPO_PERSONA = ''B'' AND gp.TZ_LOCK = 0')


EXECUTE('IF OBJECT_ID (''VW_ASISTENCIAS'') IS NOT NULL
	DROP VIEW VW_ASISTENCIAS')


EXECUTE('CREATE VIEW dbo.VW_ASISTENCIAS (
   SUCURSAL,    
   NOMBRESUCURSAL, 
   PRODUCTO, 
   NOMBREPRODUCTO, 
   CUENTA, 
   OPERACION,
   DESGLOSE, 
   MONEDA, 
   MONTOORIGEN,
   SALDO,
   VENCIMIENTO,
   CLIENTE,
   TIPO,
   JTS_OID,
   ORDINAL)
AS
SELECT s.SUCURSAL AS SUCURSAL, suc.NOMBRESUCURSAL AS NOMBRESUCURSAL, s.PRODUCTO AS PRODUCTO, p.C6251 AS NOMBREPRODUCTO,
s.CUENTA AS CUENTA, s.OPERACION AS OPERACION, s.ORDINAL AS DESGLOSE, m.C6401 AS MONEDA, 
s.C1601 AS MONTOORIGEN, s.C1604*-1 AS SALDO, s.C1627 AS VENCIMIENTO, 
s.C1803 AS CLIENTE, s.C1785 AS TIPO, s.JTS_OID AS JTS_OID, 0 AS ORDINAL
FROM SALDOS s
INNER JOIN PRODUCTOS p ON s.PRODUCTO = p.C6250 AND p.TZ_LOCK = 0
INNER JOIN MONEDAS m ON s.MONEDA = m.C6399 AND m.TZ_LOCK = 0
INNER JOIN SUCURSALES suc ON s.SUCURSAL = suc.SUCURSAL AND suc.TZ_LOCK = 0
WHERE s.C1785 IN (5,6) AND s.TZ_LOCK = 0
UNION
SELECT s.SUCURSAL AS SUCURSAL, suc.NOMBRESUCURSAL AS NOMBRESUCURSAL, v.NROLINEA AS PRODUCTO, p.C6251 AS NOMBREPRODUCTO,
s.CUENTA AS CUENTA, v.NRO_AUTORIZACION AS OPERACION, s.ORDINAL AS DESGLOSE, m.C6401 AS MONEDA, 
v.IMPORTE AS MONTOORIGEN, v.IMPORTE - v.IMPORTE_CONSUMIDO AS SALDO, v.FECHA_VENCIMIENTO AS VENCIMIENTO, 
s.C1803 AS CLIENTE, 1 AS TIPO, s.JTS_OID AS JTS_OID, v.ORDINAL AS ORDINAL
FROM VTA_SOBREGIROS v
INNER JOIN SALDOS s ON v.JTS_OID_SALDO = s.JTS_OID AND s.TZ_LOCK = 0
INNER JOIN PRODUCTOS p ON v.NROLINEA = p.C6250 AND p.TZ_LOCK = 0
INNER JOIN MONEDAS m ON s.MONEDA = m.C6399 AND m.TZ_LOCK = 0
INNER JOIN SUCURSALES suc ON v.SUCURSAL_ACUERDO = suc.SUCURSAL AND suc.TZ_LOCK = 0
WHERE v.ESTADO = 1 AND v.TZ_LOCK = 0')


EXECUTE('IF OBJECT_ID (''V_SALDOS_PLANPAGOS'') IS NOT NULL
	DROP VIEW V_SALDOS_PLANPAGOS')


EXECUTE('CREATE VIEW V_SALDOS_PLANPAGOS
AS
SELECT  0 AS TZ_LOCK,
        s.CUENTA AS NROPRESTAMO,
        p.C2300 AS NROCUOTA,
        p.C2302 AS FECHAVTO,
        s.MONEDA AS MONEDA,
        (
          CASE
            WHEN  s.C1601=(
                    SELECT  SUM(pp.C2304)
                    FROM    PLANPAGOS pp (nolock)
                    WHERE   s.JTS_OID=pp.SALDO_JTS_OID
                  )
              THEN  p.C2304
            ELSE  (
                    CASE
                      WHEN  (
                              SELECT  COUNT_BIG(*)
                              FROM    BS_PAYS_DETAIL pd (nolock),
                                      BS_HISTORIA_PLAZO hp (nolock)
                              WHERE   s.JTS_OID=pd.SALDOS_JTS_OID
                                      AND
                                      s.JTS_OID=hp.SALDOS_JTS_OID
                                      AND
                                      p.SALDO_JTS_OID=pd.SALDOS_JTS_OID
                                      AND
                                      p.SALDO_JTS_OID=hp.SALDOS_JTS_OID
                                      AND
                                      pd.HP_JTS_OID=hp.JTS_OID
                                      AND
                                      p.C2300=pd.CUOTA
                                      AND
                                      hp.ALGORITMO IN (5, 8)
                                      AND
                                      pd.CAPITALADELANTADO>0
                                      AND
                                      hp.CAPITALADELANTADO>0
                            )>0
                        THEN  p.C2304+(
                                SELECT  SUM(pd.CAPITALADELANTADO)
                                FROM    BS_PAYS_DETAIL pd (nolock),
                                        BS_HISTORIA_PLAZO hp (nolock)
                                WHERE   s.JTS_OID=pd.SALDOS_JTS_OID
                                        AND
                                        s.JTS_OID=hp.SALDOS_JTS_OID
                                        AND
                                        p.SALDO_JTS_OID=pd.SALDOS_JTS_OID
                                        AND
                                        p.SALDO_JTS_OID=hp.SALDOS_JTS_OID
                                        AND
                                        pd.HP_JTS_OID=hp.JTS_OID
                                        AND
                                        p.C2300=pd.CUOTA
                                        AND
                                        hp.ALGORITMO IN (5, 8)
                                        AND
                                        pd.CAPITALADELANTADO>0
                                        AND
                                        hp.CAPITALADELANTADO>0
                              )
                      ELSE  p.C2304
                    END
                  )
          END
        ) AS CAPITAL,
        p.C2305 AS INTERES,
        p.C2311 AS MORA, -- Este es el saldo de mora, lo carga el PA de días de atraso
        p.C2310 AS SDOINTERES,
        p.C2312 AS SDOMORA, -- No se carga
        s.PRODUCTO AS NROPRODUCTO,
        s.C1803 AS NROCLIENTE,
        p.C2309 AS SDOCAPITAL,
        s.C1785 AS TIPOPROD,
        s.C1601 AS CAPORIGINAL,
        s.C1644 AS TOTCUOTAS,
       --- s.C4765 AS CUOGRACIA,
        s.C1632 AS TASAINT,
        s.C1633 AS TASAMORA,
        s.C1621 AS FECDESEM,
        s.C1704 AS NROSOLICITUD,
        s.C1670 AS ANALISTA,
        s.JTS_OID AS IDJTSOID,
    --    p.FECHACANCELACION AS FECCANC,
        (
          SELECT  ISNULL(SUM(g.IMPORTE_GASTO), 0)
          FROM    GASTOS_POR_CUOTA g (nolock)
          WHERE   g.SALDOS_JTS_OID=s.JTS_OID
                  AND
                  g.NUMERO_CUOTA=p.C2300
                  AND
                  g.TZ_LOCK=0
        ) AS GASTO,
        (
          SELECT  ISNULL(SUM(g.SALDO_GASTO), 0)
          FROM    GASTOS_POR_CUOTA g (nolock)
          WHERE   g.SALDOS_JTS_OID=s.JTS_OID
                  AND
                  g.NUMERO_CUOTA=p.C2300
                  AND
                  g.TZ_LOCK=0
        ) AS SDOGASTO,
       --- s.CUENTASISTANT AS CUENTASISTANT,
        p.REMANENTE_CAPITAL AS REMANENTECAPITAL
     ---   p.ICMORA_DEV_CUO AS INTERESES_COMPESATORIO_MORA
FROM    SALDOS s (nolock)
        INNER JOIN  PLANPAGOS p (nolock)
          ON  s.JTS_OID=p.SALDO_JTS_OID
WHERE   p.TZ_LOCK=0
        AND
        s.TZ_LOCK=0
        AND S.ORDINAL=(SELECT max(z.ORDINAL) FROM SALDOS z WHERE z.C1785=5 and z.CUENTA=s.CUENTA AND z.TZ_LOCK=0)
        
;')

