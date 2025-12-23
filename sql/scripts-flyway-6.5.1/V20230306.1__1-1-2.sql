EXECUTE('
IF OBJECT_ID (''dbo.VW_ITF_AOJ_CUENTAS'') IS NOT NULL
	DROP VIEW dbo.VW_ITF_AOJ_CUENTAS
')

EXECUTE('


CREATE VIEW [dbo].[VW_ITF_AOJ_CUENTAS] 
AS
SELECT DISTINCT 
                         RIGHT(REPLICATE(''0'', 50) + CAST(CP.NUMEROPERSONA AS VARCHAR(50)), 50) AS ID_CLIENTE, LEFT(concat((CASE WHEN s.C1785 = 2 OR
                         s.C1785 = 3 THEN CONCAT(S.SUCURSAL, ''-'', S.PRODUCTO, ''-'', S.CUENTA) WHEN s.C1785 = 4 THEN CONCAT(S.SUCURSAL, ''-'', S.PRODUCTO, ''-'', S.CUENTA, ''-'', S.OPERACION) WHEN s.C1785 = 5 THEN CONCAT(S.SUCURSAL, 
                         ''-'', S.CUENTA, ''-'', S.OPERACION, ''-'', S.ORDINAL) ELSE CONCAT(S.SUCURSAL, ''-'', S.PRODUCTO, ''-'', S.CUENTA, ''-'', S.MONEDA, ''-'', S.OPERACION, ''-'', S.ORDINAL) END), ''                                                  ''), 50) AS NUMERO_CUENTA,
                          RIGHT(concat(''00000'', (CASE WHEN (S.C1785 = 5 AND S.MONEDA = 1) THEN ''1'' WHEN (S.C1785 = 5 AND S.MONEDA = 2) THEN ''2'' WHEN (S.C1785 = 4 AND S.MONEDA IN (1, 988, 999)) THEN ''6'' WHEN (S.C1785 = 4 AND 
                         S.MONEDA = 2) THEN ''7'' WHEN (S.C1785 = 4 AND S.MONEDA = 5) THEN ''10'' WHEN ((S.C1785 = 2 OR
                         S.C1785 = 3) AND S.MONEDA IN (1, 2)) THEN
                             (SELECT        CAST(IMPORTE_1 AS NUMERIC(15))
                               FROM            ITF_MASTER_PARAMETROS WITH (NOLOCK)
                               WHERE        [CODIGO_INTERFACE] = 7 AND NUMERICO_1 = S.PRODUCTO AND NUMERICO_2 = S.MONEDA AND TZ_LOCK = 0) END)), 5) AS ''Tipo de Cuenta'', RIGHT(concat(''000000'', S.SUCURSAL), 6) AS ''Codigo Sucursal'', 
                         LEFT(concat((''Producto '' + CAST(P.C6250 AS VARCHAR(7)) + '': '' + P.C6251), replicate('' '', 200)), 200) AS ''Observacion'', (CASE WHEN p.C6252 = 1 OR
                         p.C6252 = 2 OR
                         p.C6252 = 3 AND s.C1651 = 1 THEN ''C'' WHEN p.C6252 = 2 OR
                         p.C6252 = 3 AND s.C1651 <> 1 THEN ''V'' WHEN p.C6252 = 4 OR
                         p.C6252 = 5 AND s.C1604 = 0 THEN ''C'' WHEN p.C6252 = 4 OR
                         p.C6252 = 5 AND s.C1604 <> 0 THEN ''V'' ELSE ''V'' END) AS EST_PRODUCTO, REPLACE(concat(''#{Top.Output}AOJ/ofjudiciales_cuentas_'', CONVERT(CHAR(8), FECHAPROCESO, 112)), ''#{'', ''${'') AS NOM_ARCHIVO
FROM            PARAMETROS, CLI_CLIENTES c WITH (NOLOCK) JOIN
                         CLI_ClientePersona cp WITH (NOLOCK) ON cp.[CODIGOCLIENTE] = c.[CODIGOCLIENTE] JOIN
                         SALDOS s WITH (NOLOCK) ON c.[CODIGOCLIENTE] = s.C1803 JOIN
                         PRODUCTOS p WITH (NOLOCK) ON p.C6250 = s.PRODUCTO
WHERE        ((C.TZ_LOCK < 300000000000000 OR
                         C.TZ_LOCK >= 400000000000000) AND (C.TZ_LOCK < 100000000000000 OR
                         C.TZ_LOCK >= 200000000000000)) AND ((CP.TZ_LOCK < 300000000000000 OR
                         CP.TZ_LOCK >= 400000000000000) AND (CP.TZ_LOCK < 100000000000000 OR
                         CP.TZ_LOCK >= 200000000000000)) AND ((P.TZ_LOCK < 300000000000000 OR
                         P.TZ_LOCK >= 400000000000000) AND (P.TZ_LOCK < 100000000000000 OR
                         P.TZ_LOCK >= 200000000000000)) AND ((S.TZ_LOCK < 300000000000000 OR
                         S.TZ_LOCK >= 400000000000000) AND (S.TZ_LOCK < 100000000000000 OR
                         S.TZ_LOCK >= 200000000000000)) AND s.C1651='' '' AND (s.C1785 IN (4, 5) OR
                         (s.C1785 IN (2, 3) AND S.MONEDA IN (1, 2)))
UNION
SELECT        RIGHT(REPLICATE(''0'', 50) + CAST(CP.NUMEROPERSONA AS VARCHAR(50)), 50) AS ID_CLIENTE, LEFT(concat(cc.[CODIGO_COFRE], ''                                                  ''), 50) AS NUMERO_CUENTA, ''00008'' AS ''Tipo de Cuenta'', 
                         RIGHT(concat(''000000'', cc.SUCURSAL_DEBITO), 6) AS ''Codigo Sucursal'', ''Caja de Seguridad'' AS ''Observacion'', ''V'' AS EST_PRODUCTO, REPLACE(concat(''#{Top.Output}AOJ/ofjudiciales_cuentas_'', CONVERT(CHAR(8),
                             (SELECT        FECHAPROCESO
                               FROM            PARAMETROS WITH (NOLOCK)), 112)), ''#{'', ''${'') AS NOM_ARCHIVO
FROM            COF_COFRES_CONTRATOS cc WITH (NOLOCK) INNER JOIN
                         CLI_CLIENTES c WITH (NOLOCK) ON cc.CLIENTE = c.[CODIGOCLIENTE] AND cc.TZ_LOCK = 0 INNER JOIN
                         CLI_ClientePersona cp WITH (NOLOCK) ON cp.[CODIGOCLIENTE] = c.[CODIGOCLIENTE] AND cp.TITULARIDAD = ''T'' AND cc.ESTADO = ''C''
UNION
SELECT        RIGHT(REPLICATE(''0'', 50) + CAST(CLIENTE AS VARCHAR(50)), 50) AS ID_CLIENTE, LEFT(concat(ADMINISTRADORA, ''-'', NUM_TJC, ''                                                  ''), 50) AS NUMERO_CUENTA, ''00005'' AS ''Tipo de Cuenta'', 
                         RIGHT(concat(''000000'', SUC_CUENTA_COBRO), 6) AS ''Codigo Sucursal'', ''Tarjeta de Credito'' + '' - '' + ad.DESCRIPCION AS ''Observacion'', ''V'' AS EST_PRODUCTO, 
                         /*Ver el estado de las tarjetas */ REPLACE(concat(''#{Top.Output}AOJ/ofjudiciales_cuentas_'', CONVERT(CHAR(8),
                             (SELECT        FECHAPROCESO
                               FROM            PARAMETROS WITH (NOLOCK)), 112)), ''#{'', ''${'') AS NOM_ARCHIVO
FROM            TJC_MAESTRO_USUARIO tc WITH (NOLOCK) INNER JOIN
                         CLI_CLIENTES c WITH (NOLOCK) ON tc.CLIENTE = c.[CODIGOCLIENTE] INNER JOIN
                         TJC_MAESTRO_ADMINISTRADORAS ad WITH (NOLOCK) ON tc.ADMINISTRADORA = ad.[COD_ADMINISTRADORA] AND tc.TZ_LOCK = 0 INNER JOIN
                         CLI_ClientePersona cp WITH (NOLOCK) ON cp.[CODIGOCLIENTE] = c.[CODIGOCLIENTE] AND cp.TITULARIDAD = ''T'' AND ad.COD_ADMINISTRADORA = tc.ADMINISTRADORA AND CUENTA_COBRO > 0



')

