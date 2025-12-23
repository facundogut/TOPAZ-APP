EXECUTE('
---Se elimina proceso de CLEARING de la scheduler
DELETE FROM dbo.PM_SCHEDULER
WHERE ORDINAL = 12 AND NOMBREGRUPO = ''    DIA - Procesos de Apertura Integrada''
')