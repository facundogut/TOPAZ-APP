EXECUTE('
IF OBJECT_ID (''VW_HISTORIAPZO'') IS NOT NULL
	DROP VIEW VW_HISTORIAPZO
	
	')
	
	EXECUTE ('


CREATE VIEW VW_HISTORIAPZO
AS (
SELECT fechaprocesomov AS FechaProceso,sucursalmov AS Sucursal,nroasientomov AS Comprobante,fechavalor AS FechaValor, 
CASE tipomov WHEN ''A'' THEN ''Desembolso''
						WHEN ''T'' THEN ''Prorroga''
							WHEN ''P'' THEN ''Pago''
								WHEN ''V'' THEN ''Cambio Fecha Vencimiento''
									WHEN ''R'' THEN ''Cambio de Rubro Contable''
										WHEN ''S'' THEN ''Ajuste de Tasa''
									END AS Evento,
CASE tipomov WHEN ''A'' THEN ''Monto Original: '' + CONVERT(varchar(30),FORMAT (CapitalOriginal, ''N'', ''es-es''))
						WHEN ''T'' THEN convert(VARCHAR(20),CantidadCuotas,1) +'' Cuota/s ,Desde la cuota: '' + convert(VARCHAR(20),CuotaBalono,1)
							WHEN ''P'' THEN ''Amortiza '' + CONVERT(varchar(30),FORMAT (CapitalPagado, ''N'', ''es-es''))
								WHEN ''V'' THEN ''Proximo Vencimiento: '' + convert(VARCHAR(10),fechaprimervto,103)
									WHEN ''R'' THEN ''Cambio de Rubro Contable''
										WHEN ''S'' THEN ''Nueva Tasa: '' + CONVERT(varchar(30),FORMAT (tasainteres, ''N7'', ''es-es''))
									END AS Detalle,
SALDOS_JTS_OID, ROW_NUMBER() OVER (ORDER BY SALDOS_JTS_OID, JTS_OID) AS RowNum							
FROM BS_HISTORIA_PLAZO WHERE TZ_LOCK=0 AND TIPOMOV IN(''A'',''T'',''V'',''R'',''P'',''S'')
)
')

