EXECUTE('
IF OBJECT_ID (''dbo.VW_HISTORIAPZO'') IS NOT NULL
	DROP VIEW dbo.VW_HISTORIAPZO
')

EXECUTE('
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
CASE tipomov WHEN ''A'' THEN ''Monto Original: '' + convert(VARCHAR(20),CapitalOriginal,1)
						WHEN ''T'' THEN convert(VARCHAR(20),CantidadCuotas,1) +'' Cuota/s ,Desde la cuota: '' + convert(VARCHAR(20),CuotaBalono,1)
							WHEN ''P'' THEN ''Amortiza '' + convert(VARCHAR(20),CapitalPagado,1)
								WHEN ''V'' THEN ''Proximo Vencimiento: '' + convert(VARCHAR(10),fechaprimervto,103)
									WHEN ''R'' THEN ''Cambio de Rubro Contable''
										WHEN ''S'' THEN ''Nueva Tasa: '' + convert(VARCHAR(20), tasainteres)
									END AS Detalle,
SALDOS_JTS_OID, ROW_NUMBER() OVER (ORDER BY SALDOS_JTS_OID, JTS_OID) AS RowNum							
FROM BS_HISTORIA_PLAZO WHERE TZ_LOCK=0 AND TIPOMOV IN(''A'',''T'',''V'',''R'',''P'',''S'')
)
')

EXECUTE('
INSERT INTO dbo.AYUDAS (NUMERODEARCHIVO, NUMERODEAYUDA, DESCRIPCION, FILTRO, MOSTRARTODOS, CAMPOS, CAMPOSVISTA, BASEVISTA, NOMBREVISTA, AYUDAGRANDE)
VALUES (0, 4301, ''Ay. Historia Plazo'', NULL, 0, ''56;4183;401;75;1450;114;'', ''FechaProceso;Sucursal;Comprobante;FechaValor;Evento;Detalle;'', ''top/clientes'', ''VW_HISTORIAPZO'', 0);

INSERT INTO dbo.DICCIONARIO (NUMERODECAMPO, USODELCAMPO, REFERENCIA, DESCRIPCION, PROMPT, LARGO, TIPODECAMPO, DECIMALES, EDICION, CONTABILIZA, CONCEPTO, CALCULO, VALIDACION, TABLADEVALIDACION, TABLADEAYUDA, OPCIONES, TABLA, CAMPO, BASICO, MASCARA)
VALUES (43627, NULL, 0, ''Ay. Historia Plazo'', ''Ay. Historia Plazo'', 10, ''N'', 0, NULL, 0, 0, 0, 0, 0, 4301, 0, 0, ''C43627'', 0, NULL);
')

