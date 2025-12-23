EXECUTE('

INSERT INTO dbo.VTA_CONTROLES_CIERRE_CTA (CONTROL, DESCRIPCION, TIPO, TIPO_CUENTA, TZ_LOCK)
VALUES (26, ''Cuenta con transferencias de otro banco pendientes'', ''A'', ''AM'', 0)


INSERT INTO dbo.VTA_CONTROLES_CIERRE_CTA (CONTROL, DESCRIPCION, TIPO, TIPO_CUENTA, TZ_LOCK)
VALUES (27, ''Cuenta con débitos directos a procesar'', ''A'', ''AM'', 0)



')
