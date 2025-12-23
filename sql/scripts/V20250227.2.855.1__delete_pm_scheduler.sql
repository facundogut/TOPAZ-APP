EXECUTE('
DELETE FROM dbo.PM_SCHEDULER
WHERE ORDINAL = 13 AND NOMBREGRUPO = ''    DIA - Procesos de Apertura Integrada''

DELETE FROM dbo.PM_SCHEDULER
WHERE ORDINAL = 14 AND NOMBREGRUPO = ''    DIA - Procesos de Apertura Integrada''

DELETE FROM dbo.PM_SCHEDULER
WHERE ORDINAL = 15 AND NOMBREGRUPO = ''    DIA - Procesos de Apertura Integrada''
')