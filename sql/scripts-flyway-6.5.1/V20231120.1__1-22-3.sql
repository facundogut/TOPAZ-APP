EXECUTE('
INSERT INTO dbo.OPERACIONES (TITULO, IDENTIFICACION, NOMBRE, DESCRIPCION, MNEMOTECNICO, AUTORIZACION, FORMULARIOPRINCIPAL, PROXOPERACION, ESTADO, TZ_LOCK, COPIAS, SUBOPERACION, PERMITEBAJA, COMPORTAMIENTOENCIERRE, REQUIERECONTRASENA, PERMITECONCURRENTE, PERMITEESTADODIFERIDO, ICONO_TITULO, ESTILO)
VALUES (7901, 7939, ''1.22.3 EPAGO SOPORTE'', ''1.22.3 EPAGO SOPORTE'', ''7939'', ''N'', NULL, NULL, ''P'', 0, NULL, 0, ''S'', ''N'', ''N'', ''N'', ''N'', NULL, 0)

INSERT INTO dbo.ITF_MASTER (TZ_LOCK, ID, DESCRIPCION, OBJ_KETTLE, P0_MODO, P0_TIPO, P0_CAPTION, P0_CONSTANTE, P1_MODO, P1_TIPO, P1_CAPTION, P1_CONSTANTE, P2_MODO, P2_TIPO, P2_CAPTION, P2_CONSTANTE, P3_MODO, P3_TIPO, P3_CAPTION, P3_CONSTANTE, P4_MODO, P4_TIPO, P4_CAPTION, P4_CONSTANTE, P5_MODO, P5_TIPO, P5_CAPTION, P5_CONSTANTE, P6_MODO, P6_TIPO, P6_CAPTION, P6_CONSTANTE, P7_MODO, P7_TIPO, P7_CAPTION, P7_CONSTANTE, P8_MODO, P8_TIPO, P8_CONSTANTE, P8_CAPTION, P9_MODO, P9_TIPO, P9_CAPTION, P9_CONSTANTE, TIPO_OBJ, COMENTARIO, ID_REPORTE, MODO_EJECUCION)
VALUES (0, 232, ''EPAGO SOPORTE'', ''ITF_EPAGO_SOPORTE.kjb'', '''', '''', '''', '' '', '''', '''', '''', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', ''J'', '' '', 0, ''M'')

INSERT INTO dbo.EVENTOS (TZ_LOCK, ID_EVENTO, CANAL, SUB_CANAL)
VALUES (0, 130, ''7'', ''150'')

INSERT INTO dbo.EVENTOS_TRANSACCION (TZ_LOCK, CODIGO_TRANSACCION, ID_EVENTO, CONDICION, CAMPOS, PRIORIDAD, DESCRIPCION, TIPO_MAPEO, GRABAR_TABLA, ENVIAR_EN_REVERSA, ENABLE_OBJ_FORMAT)
VALUES (0, 538, 130, NULL, ''LoteId=93;resultado.estado=4886;resultado.detalle.codigo=622;resultado.detalle.descripcion=910;Transaction-ID=118;Ref=620;'', 1, ''Epago Soporte'', 2, 1, 1, 0)

INSERT INTO dbo.CODIGO_TRANSACCIONES (CODIGO_OPERACION, CODIGO_INTERNO_MOV, CODIGO_TRANSACCION, TZ_LOCK)
VALUES (7939, 130, 538, 0)

INSERT INTO dbo.DESCRIPTORES (TITULO, IDENTIFICACION, TIPODEARCHIVO, DESCRIPCION, GRUPODELMAPA, NOMBREFISICO, TIPODEDBMS, LARGODELREGISTRO, INICIALIZACIONDELREGISTRO, BASE, SELECCION, ACEPTA_MOVS_DIFERIDO)
VALUES (930, 859, '' '', ''ITF_EPAGO_SOPORTE_LOTE'', 3, ''ITF_EPAGO_SOPORTE_LOTE'', ''D'', 0, 0, ''Top/Clientes'', NULL, ''N'')

INSERT INTO dbo.DICCIONARIO (NUMERODECAMPO, USODELCAMPO, REFERENCIA, DESCRIPCION, PROMPT, LARGO, TIPODECAMPO, DECIMALES, EDICION, CONTABILIZA, CONCEPTO, CALCULO, VALIDACION, TABLADEVALIDACION, TABLADEAYUDA, OPCIONES, TABLA, CAMPO, BASICO, MASCARA)
VALUES (41346, NULL, 0, ''id_lote'', ''id_lote'', 30, ''N'', 0, NULL, 0, 0, 0, 0, 0, 0, 0, 859, ''id_lote'', 0, NULL)

INSERT INTO dbo.DICCIONARIO (NUMERODECAMPO, USODELCAMPO, REFERENCIA, DESCRIPCION, PROMPT, LARGO, TIPODECAMPO, DECIMALES, EDICION, CONTABILIZA, CONCEPTO, CALCULO, VALIDACION, TABLADEVALIDACION, TABLADEAYUDA, OPCIONES, TABLA, CAMPO, BASICO, MASCARA)
VALUES (41348, NULL, 0, ''id_registro'', ''id_registro'', 10, ''N'', 0, NULL, 0, 0, 0, 0, 0, 0, 0, 859, ''id_registro'', 0, NULL)

INSERT INTO dbo.DICCIONARIO (NUMERODECAMPO, USODELCAMPO, REFERENCIA, DESCRIPCION, PROMPT, LARGO, TIPODECAMPO, DECIMALES, EDICION, CONTABILIZA, CONCEPTO, CALCULO, VALIDACION, TABLADEVALIDACION, TABLADEAYUDA, OPCIONES, TABLA, CAMPO, BASICO, MASCARA)
VALUES (41350, NULL, 0, ''sucursal_origen'', ''sucursal_origen'', 3, ''N'', 0, NULL, 0, 0, 0, 0, 0, 0, 0, 859, ''sucursal_origen'', 0, NULL)

INSERT INTO dbo.DICCIONARIO (NUMERODECAMPO, USODELCAMPO, REFERENCIA, DESCRIPCION, PROMPT, LARGO, TIPODECAMPO, DECIMALES, EDICION, CONTABILIZA, CONCEPTO, CALCULO, VALIDACION, TABLADEVALIDACION, TABLADEAYUDA, OPCIONES, TABLA, CAMPO, BASICO, MASCARA)
VALUES (41352, NULL, 0, ''cuenta_origen'', ''cuenta_origen'', 15, ''N'', 0, NULL, 0, 0, 0, 0, 0, 0, 0, 859, ''cuenta_origen'', 0, NULL)

INSERT INTO dbo.DICCIONARIO (NUMERODECAMPO, USODELCAMPO, REFERENCIA, DESCRIPCION, PROMPT, LARGO, TIPODECAMPO, DECIMALES, EDICION, CONTABILIZA, CONCEPTO, CALCULO, VALIDACION, TABLADEVALIDACION, TABLADEAYUDA, OPCIONES, TABLA, CAMPO, BASICO, MASCARA)
VALUES (41354, NULL, 0, ''tipo_cuenta_origen'', ''tipo_cuenta_origen'', 10, ''N'', 0, NULL, 0, 0, 0, 0, 0, 0, 0, 859, ''tipo_cuenta_origen'', 0, NULL)

INSERT INTO dbo.DICCIONARIO (NUMERODECAMPO, USODELCAMPO, REFERENCIA, DESCRIPCION, PROMPT, LARGO, TIPODECAMPO, DECIMALES, EDICION, CONTABILIZA, CONCEPTO, CALCULO, VALIDACION, TABLADEVALIDACION, TABLADEAYUDA, OPCIONES, TABLA, CAMPO, BASICO, MASCARA)
VALUES (41356, NULL, 0, ''sucursal_destino'', ''tipo_cuenta_origen'', 3, ''N'', 0, NULL, 0, 0, 0, 0, 0, 0, 0, 859, ''tipo_cuenta_origen'', 0, NULL)

INSERT INTO dbo.DICCIONARIO (NUMERODECAMPO, USODELCAMPO, REFERENCIA, DESCRIPCION, PROMPT, LARGO, TIPODECAMPO, DECIMALES, EDICION, CONTABILIZA, CONCEPTO, CALCULO, VALIDACION, TABLADEVALIDACION, TABLADEAYUDA, OPCIONES, TABLA, CAMPO, BASICO, MASCARA)
VALUES (41358, NULL, 0, ''cuenta_destino'', ''cuenta_destino'', 15, ''N'', 0, NULL, 0, 0, 0, 0, 0, 0, 0, 859, ''cuenta_destino'', 0, NULL)

INSERT INTO dbo.DICCIONARIO (NUMERODECAMPO, USODELCAMPO, REFERENCIA, DESCRIPCION, PROMPT, LARGO, TIPODECAMPO, DECIMALES, EDICION, CONTABILIZA, CONCEPTO, CALCULO, VALIDACION, TABLADEVALIDACION, TABLADEAYUDA, OPCIONES, TABLA, CAMPO, BASICO, MASCARA)
VALUES (41360, NULL, 0, ''tipo_cuenta_destino'', ''tipo_cuenta_destino'', 10, ''N'', 0, NULL, 0, 0, 0, 0, 0, 0, 0, 859, ''tipo_cuenta_destino'', 0, NULL)

INSERT INTO dbo.DICCIONARIO (NUMERODECAMPO, USODELCAMPO, REFERENCIA, DESCRIPCION, PROMPT, LARGO, TIPODECAMPO, DECIMALES, EDICION, CONTABILIZA, CONCEPTO, CALCULO, VALIDACION, TABLADEVALIDACION, TABLADEAYUDA, OPCIONES, TABLA, CAMPO, BASICO, MASCARA)
VALUES (41362, NULL, 0, ''importe'', ''importe'', 15, ''N'', 2, NULL, 0, 0, 0, 0, 0, 0, 0, 859, ''importe'', 0, NULL)

INSERT INTO dbo.DICCIONARIO (NUMERODECAMPO, USODELCAMPO, REFERENCIA, DESCRIPCION, PROMPT, LARGO, TIPODECAMPO, DECIMALES, EDICION, CONTABILIZA, CONCEPTO, CALCULO, VALIDACION, TABLADEVALIDACION, TABLADEAYUDA, OPCIONES, TABLA, CAMPO, BASICO, MASCARA)
VALUES (41365, NULL, 0, ''ESTADO'', ''ESTADO'', 1, ''A'', 0, NULL, 0, 0, 0, 0, 0, 0, 0, 859, ''ESTADO'', 0, NULL)

INSERT INTO dbo.INDICES (NUMERODEARCHIVO, NUMERODEINDICE, DESCRIPCION, CLAVESREPETIDAS, CAMPO1, CAMPO2, CAMPO3, CAMPO4, CAMPO5, CAMPO6, CAMPO7, CAMPO8, CAMPO9, CAMPO10, CAMPO11, CAMPO12, CAMPO13, CAMPO14, CAMPO15, CAMPO16, CAMPO17, CAMPO18, CAMPO19, CAMPO20)
VALUES (859, 1, ''Indice Productos'', 0, 41346, 41348, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)

')
EXECUTE('

CREATE TABLE dbo.ITF_EPAGO_SOPORTE_LOTE
	(
	id                                        BIGINT IDENTITY NOT NULL,
	id_lote                                   BIGINT NOT NULL,
	id_registro                               BIGINT NOT NULL,
	banco_origen                              INT,
	sucursal_origen                           INT,
	cuenta_origen                             BIGINT,
	tipo_cuenta_origen                        INT,
	tipo_inscripcion_titular_cuenta_origen    INT,
	numero_inscripcion_titular_cuenta_origen  BIGINT,
	banco_destino                             INT,
	sucursal_destino                          INT,
	cuenta_destino                            BIGINT,
	tipo_cuenta_destino                       INT,
	tipo_inscripcion_titular_cuenta_destino   INT,
	numero_inscripcion_titular_cuenta_destino BIGINT,
	cbu_cuenta_destino                        VARCHAR (23),
	tipo_de_operacion                         INT,
	numero_de_operacion                       BIGINT,
	importe                                   NUMERIC (19, 2) NOT NULL,
	fecha_de_proceso                          DATE,
	jurisdiccion_que_ordena_operacion         INT,
	ejercicio_orden_de_pago                   INT,
	jurisdiccion_que_pertenece_operacion      INT,
	tipo_de_orden_de_pago                     VARCHAR (2),
	numero_de_orden_de_pago                   INT,
	identificador_del_lote                    VARCHAR (30),
	total_de_impuestos_sin_adicional          NUMERIC (19, 2) NOT NULL,
	numero_de_agencia                         INT,
	numero_de_sorteo                          INT,
	codigo_de_error                           INT,
	descripcion_de_error                      VARCHAR (255),
	impactar                                  BIT NOT NULL,
	fecha_de_carga                            DATETIME2 NOT NULL,
	ESTADO                                    VARCHAR (1) DEFAULT (''I'')
	)



CREATE TABLE dbo.ITF_EPAGO_TIPO_CUENTA_TIPO_OPERACION
	(
	TipoCuenta    VARCHAR (2),
	TipoOperacion VARCHAR (2),
	OrigenDestino VARCHAR (1)
	)
	
')
EXECUTE('

INSERT INTO ITF_EPAGO_TIPO_CUENTA_TIPO_OPERACION (TipoCuenta, TipoOperacion, OrigenDestino)
VALUES
(''01'', ''01'', ''D''),
(''01'', ''01'', ''O''),
(''01'', ''02'', ''D''),
(''01'', ''02'', ''O''),
(''01'', ''03'', ''D''),
(''01'', ''03'', ''O''),
(''01'', ''05'', ''D''),
(''01'', ''05'', ''O''),
(''01'', ''06'', ''D''),
(''01'', ''06'', ''O''),
(''07'', ''01'', ''D''),
(''07'', ''01'', ''O''),
(''07'', ''02'', ''D''),
(''07'', ''02'', ''O''),
(''07'', ''03'', ''D''),
(''07'', ''03'', ''O''),
(''07'', ''05'', ''D''),
(''07'', ''05'', ''O''),
(''11'', ''01'', ''D''),
(''11'', ''01'', ''O''),
(''11'', ''02'', ''D''),
(''11'', ''02'', ''O''),
(''11'', ''03'', ''D''),
(''11'', ''03'', ''O''),
(''11'', ''05'', ''D''),
(''11'', ''05'', ''O''),
(''11'', ''06'', ''D''),
(''11'', ''06'', ''O''),
(''15'', ''01'', ''D''),
(''15'', ''01'', ''O''),
(''15'', ''02'', ''D''),
(''15'', ''02'', ''O''),
(''15'', ''03'', ''D''),
(''15'', ''03'', ''O''),
(''15'', ''05'', ''D''),
(''15'', ''05'', ''O''),
(''15'', ''06'', ''D''),
(''15'', ''06'', ''O'');

')
