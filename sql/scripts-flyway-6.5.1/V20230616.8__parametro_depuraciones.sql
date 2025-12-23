Execute('
CREATE TABLE PARAMETROS_DEPURACION
	(
	MODULO  VARCHAR (60) NOT NULL,
	ID      VARCHAR (60) NOT NULL,
	PERIODO NUMERIC (15) DEFAULT (0) NOT NULL,
	UNIDAD  VARCHAR (15) DEFAULT (0) NOT NULL,
	TZ_LOCK NUMERIC (15) DEFAULT (0) NOT NULL,
	CAMPO1  VARCHAR (50) DEFAULT ('' ''),
	CAMPO2  VARCHAR (50) DEFAULT ('' ''),
	CAMPO3  VARCHAR (50) DEFAULT ('' ''),
	CAMPO4  VARCHAR (50) DEFAULT ('' ''),
	CAMPO5  VARCHAR (50) DEFAULT ('' ''),
	CONSTRAINT PK_PARAMETROS_DEP PRIMARY KEY (MODULO, ID)
	)


INSERT INTO PARAMETROS_DEPURACION (MODULO, ID, PERIODO, UNIDAD, TZ_LOCK, CAMPO1, CAMPO2, CAMPO3, CAMPO4, CAMPO5)
VALUES (''COMMIT'', ''COMMIT'', 0000, ''X'', 0, ''Parametro utilizado para modificar '', '' el tamaño de la transaccion'', '' '', '' '', '' '');
--NOTA: Modificar 0000 por el valor correspondiente. Si no existe esta fila las depuraciones tomarán por defecto 1000000

INSERT INTO PARAMETROS_DEPURACION (MODULO, ID, PERIODO, UNIDAD, TZ_LOCK, CAMPO1, CAMPO2, CAMPO3, CAMPO4, CAMPO5)
VALUES (''BASE_DE_SALDOS'', ''PLAZO'', 9999, ''M'', 0, ''Se considerarán para depuración aquellos prestamos'', ''con más de XXXX Meses'', '' '', '' '', '' '');
--NOTA: Modificar 9999 por el valor correspondiente (en meses)

INSERT INTO PARAMETROS_DEPURACION (MODULO, ID, PERIODO, UNIDAD, TZ_LOCK, CAMPO1, CAMPO2, CAMPO3, CAMPO4, CAMPO5)
VALUES (''BASE_DE_SALDOS'', ''SALDOS_DIARIOS'', 9999, ''M'', 0, ''Se considerarán para depuración aquellos '', ''saldos diarios y mensuales con mas de XXXX Meses'', '' '', '' '', '' '');
--NOTA: Modificar 9999 por el valor correspondiente (en meses)

INSERT INTO PARAMETROS_DEPURACION (MODULO, ID, PERIODO, UNIDAD, TZ_LOCK, CAMPO1, CAMPO2, CAMPO3, CAMPO4, CAMPO5)
VALUES (''SEGURIDAD'', ''BITACORAS'', 9999, ''M'', 0, ''Esta información es utilizada para la auditoría de'', ''acciones de los usuarios en el sistema.'', '' '', '' '', '' '');
--NOTA: Modificar 9999 por el valor correspondiente (en meses)

INSERT INTO PARAMETROS_DEPURACION (MODULO, ID, PERIODO, UNIDAD, TZ_LOCK, CAMPO1, CAMPO2, CAMPO3, CAMPO4, CAMPO5)
VALUES (''CONTABILIDAD'', ''BALANCES_DIARIOS'', 9999, ''A'', 0, ''Esta información es utilizada para la generación '', ''de balances diarios'', '' '', '' '', '' '');
--NOTA: Modificar 9999 por el valor correspondiente (en años)

INSERT INTO PARAMETROS_DEPURACION (MODULO, ID, PERIODO, UNIDAD, TZ_LOCK, CAMPO1, CAMPO2, CAMPO3, CAMPO4, CAMPO5)
VALUES (''CONTABILIDAD'', ''BALANCES_MENSUALES'', 9999, ''A'', 0, ''Esta información es utilizada para la generación '', ''de balances mensuales y semestrales'', '' '', '' '', '' '');
--NOTA: Modificar 9999 por el valor correspondiente (en años)

INSERT INTO PARAMETROS_DEPURACION (MODULO, ID, PERIODO, UNIDAD, TZ_LOCK, CAMPO1, CAMPO2, CAMPO3, CAMPO4, CAMPO5)
VALUES (''CONTABILIDAD'', ''MOVIMIENTOS_CONTABILIDAD'', 9999, ''A'', 0, ''Esta información es utilizada para la generación '', ''de balances diarios, mensuales y semestrales. '', ''Historico detalle contabilidad. Historico de '', ''movimientos contables.'', '' '');
--NOTA: Modificar 9999 por el valor correspondiente (en años)

INSERT INTO PARAMETROS_DEPURACION (MODULO, ID, PERIODO, UNIDAD, TZ_LOCK, CAMPO1, CAMPO2, CAMPO3, CAMPO4, CAMPO5)
VALUES (''NUMERADORES'', ''DIARIOS'', 9999, ''D'', 0, ''Información no utilizada una vez que el período '', ''del numerador finaliza (diario en este caso)'', '' '', '' '', '' '');
--NOTA: Modificar 9999 por el valor correspondiente (en días)

INSERT INTO PARAMETROS_DEPURACION (MODULO, ID, PERIODO, UNIDAD, TZ_LOCK, CAMPO1, CAMPO2, CAMPO3, CAMPO4, CAMPO5)
VALUES (''NUMERADORES'', ''MENSUALES'', 9999, ''M'', 0, ''Información no utilizada una vez que el período '', ''del numerador finaliza (mensual en este caso)'', '' '', '' '', '' '');
--NOTA: Modificar 9999 por el valor correspondiente (en meses)

INSERT INTO PARAMETROS_DEPURACION (MODULO, ID, PERIODO, UNIDAD, TZ_LOCK, CAMPO1, CAMPO2, CAMPO3, CAMPO4, CAMPO5)
VALUES (''PROCESS_MANAGER'', ''PROCESS_MANAGER'', 9999, ''M'', 0, ''Esta información es utilizada para histórico de '', ''ejecuciones de porocesos, y las estadísicas de '', ''tiempo de ejecución en el monitor de procesos.'', '' '', '' '');
--NOTA: Modificar 9999 por el valor correspondiente (en meses)

INSERT INTO PARAMETROS_DEPURACION (MODULO, ID, PERIODO, UNIDAD, TZ_LOCK, CAMPO1, CAMPO2, CAMPO3, CAMPO4, CAMPO5)
VALUES (''TRANSACCIONAL'', ''TRANSACCIONAL'', 9999, ''M'', 0, ''Esta información es utilizada para los extornos de'', ''asientos, para la reimpresión de formularios y '', ''para la generación de balances'', '' '', '' '');
--NOTA: Modificar 9999 por el valor correspondiente (en meses)

;')