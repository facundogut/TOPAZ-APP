EXECUTE('

IF OBJECT_ID (''dbo.VW_HISTORIAPZO'') IS NOT NULL
	DROP VIEW dbo.VW_HISTORIAPZO
')

EXECUTE('
CREATE   VIEW [dbo].[VW_HISTORIAPZO]
AS
 
SELECT fechaprocesomov AS FechaProceso,sucursalmov AS Sucursal,nroasientomov AS Comprobante,fechavalor AS FechaValor, 
	CASE tipomov	WHEN ''A'' THEN ''Desembolso''
					WHEN ''T'' THEN ''Prorroga''
					WHEN ''P'' THEN ''Pago''
					WHEN ''V'' THEN ''Cambio Fecha Vencimiento''
					WHEN ''R'' THEN ''Cambio de Rubro Contable''
					WHEN ''S'' THEN ''Ajuste de Tasa''
	END AS Evento,								 
		CASE WHEN tipomov = ''A'' THEN ''Monto Original: '' + CONVERT(varchar(30),FORMAT (CapitalOriginal, ''N'', ''es-es''))
			 WHEN tipomov = ''T'' THEN convert(VARCHAR(20),CantidadCuotas,1) +'' Cuota/s ,Desde la cuota: '' + convert(VARCHAR(20),CuotaBalono,1)
			 WHEN tipomov = ''P'' AND t.HP_JTS_OID IS NOT NULL  THEN ''Amortiza '' + CONVERT(varchar(30),FORMAT (CapitalPagado, ''N'', ''es-es'')) + '' - Condonación '' + CONVERT(varchar(30),FORMAT (t.CAPITAL_CONDONADO, ''N'', ''es-es'')) 
			 WHEN tipomov = ''P'' AND t.HP_JTS_OID IS NULL THEN ''Amortiza '' + CONVERT(varchar(30),FORMAT (CapitalPagado, ''N'', ''es-es''))
			 WHEN tipomov = ''V'' THEN ''Proximo Vencimiento: '' + convert(VARCHAR(10),fechaprimervto,103)
			 WHEN tipomov = ''R'' THEN ''Cambio de Rubro Contable''
			 WHEN tipomov = ''S'' THEN ''Nueva Tasa: '' + CONVERT(varchar(30),FORMAT (tasainteres, ''N7'', ''es-es''))
		END AS Detalle,
	bs.SALDOS_JTS_OID
	--ROW_NUMBER() OVER (ORDER BY bs.SALDOS_JTS_OID, bs.JTS_OID) AS RowNum							
FROM BS_HISTORIA_PLAZO bs WITH (NOLOCK)
LEFT JOIN 
(SELECT con.SALDOS_JTS_OID,con.HP_JTS_OID, sum(con.CAPITAL_CONTAB) AS CAPITAL_CONDONADO
 FROM BS_PAYS_DETAIL_CONDONA con WITH(NOLOCK) WHERE con.TZ_LOCK=0 
 GROUP BY con.SALDOS_JTS_OID, con.HP_JTS_OID) t
	ON t.SALDOS_JTS_OID=bs.SALDOS_JTS_OID AND t.HP_JTS_OID=bs.JTS_OID
WHERE bs.TZ_LOCK=0
	AND TIPOMOV IN(''A'',''T'',''V'',''R'',''P'',''S'')
')

