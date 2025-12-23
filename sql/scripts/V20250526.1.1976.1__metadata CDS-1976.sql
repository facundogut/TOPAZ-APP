EXECUTE('
----------------------------------------------
--Ajuste de Rubro ME para grupo de conceptos--
----------------------------------------------
DELETE FROM dbo.CONCEPCONT
WHERE C6500 = 236
----
')
EXECUTE('
----
INSERT INTO dbo.CONCEPCONT (TZ_LOCK, C6500, C6501, C6502, GRUPO_CONCEPTO, REFERENCIA)
VALUES (0, 236, ''Transf. intbrias. dd Topaz me'', 3157549990, ''235'', 0)
----
')
