EXECUTE('
---------------------------------------------------------
--AGREGAMOS CREDEB A LA COMISIÓN POR INMOVILIZACIÓN DPF--
---------------------------------------------------------
INSERT INTO dbo.CI_IMPUESTOS_X_CARGO (ID_IMPUESTO, ID_CARGO, LECTURA_TOPAZ, TZ_LOCK, CAMPO_SEGMENTO, DESCRIPCION_SEGMENTO)
VALUES (10, 1200, ''A'', 0, 34096, ''Cond CREDEB'')
----
')