Execute('

INSERT INTO dbo.DICCIONARIO (NUMERODECAMPO, USODELCAMPO, REFERENCIA, DESCRIPCION, PROMPT, LARGO, TIPODECAMPO, DECIMALES, EDICION, CONTABILIZA, CONCEPTO, CALCULO, VALIDACION, TABLADEVALIDACION, TABLADEAYUDA, OPCIONES, TABLA, CAMPO, BASICO, MASCARA)
VALUES (38001, '' '', 0, ''ESTADO'', ''Estado'', 1, ''A'', 0, NULL, 0, 0, 0, 0, 0, 0, 1, 3330, ''ESTADOREG'', 0, NULL)

INSERT INTO dbo.OPCIONES (NUMERODECAMPO, IDIOMA, DESCRIPCION, OPCIONINTERNA, OPCIONDEPANTALLA)
VALUES (38001, ''E'', ''Ingresado'', ''I'', ''I'')

INSERT INTO dbo.OPCIONES (NUMERODECAMPO, IDIOMA, DESCRIPCION, OPCIONINTERNA, OPCIONDEPANTALLA)
VALUES (38001, ''E'', ''Enviado'', ''E'', ''E'')

INSERT INTO dbo.DICCIONARIO (NUMERODECAMPO, USODELCAMPO, REFERENCIA, DESCRIPCION, PROMPT, LARGO, TIPODECAMPO, DECIMALES, EDICION, CONTABILIZA, CONCEPTO, CALCULO, VALIDACION, TABLADEVALIDACION, TABLADEAYUDA, OPCIONES, TABLA, CAMPO, BASICO, MASCARA)
VALUES (38002, '' '', 0, ''ESTADO'', ''Estado'', 1, ''A'', 0, NULL, 0, 0, 0, 0, 0, 0, 1, 3333, ''ESTADOREG'', 0, NULL)

INSERT INTO dbo.OPCIONES (NUMERODECAMPO, IDIOMA, DESCRIPCION, OPCIONINTERNA, OPCIONDEPANTALLA)
VALUES (38002, ''E'', ''Ingresado'', ''I'', ''I'')

INSERT INTO dbo.OPCIONES (NUMERODECAMPO, IDIOMA, DESCRIPCION, OPCIONINTERNA, OPCIONDEPANTALLA)
VALUES (38002, ''E'', ''Enviado'', ''E'', ''E'')

INSERT INTO dbo.OPERACIONES (TITULO, IDENTIFICACION, NOMBRE, DESCRIPCION, MNEMOTECNICO, AUTORIZACION, FORMULARIOPRINCIPAL, PROXOPERACION, ESTADO, TZ_LOCK, COPIAS, SUBOPERACION, PERMITEBAJA, COMPORTAMIENTOENCIERRE, REQUIERECONTRASENA, PERMITECONCURRENTE, PERMITEESTADODIFERIDO, ICONO_TITULO, ESTILO)
VALUES (7650, 8912, ''Actualizacionn de cambios de una persona'', ''Actualizacionn de cambios de una persona'', ''8912'', ''N'', NULL, NULL, ''P'', 0, NULL, 0, ''S'', ''N'', ''N'', ''N'', ''N'', NULL, 0)

INSERT INTO dbo.EVENTOS_TRANSACCION (TZ_LOCK, CODIGO_TRANSACCION, ID_EVENTO, CONDICION, CAMPOS, PRIORIDAD, DESCRIPCION, TIPO_MAPEO, GRABAR_TABLA, ENVIAR_EN_REVERSA, ENABLE_OBJ_FORMAT)
VALUES (0, 537, 120, NULL, ''message.idPersona=1401;message.tipoPersona=1861;message.fechaNacimiento=1402;message.sexo.id=1404;message.sexo.descripcion=114;message.nombre.nombreCompleto=340;message.nombre.apellidos=2487;message.nombre.nombres=3262;message.paisNacimiento.id=1423;message.paisNacimiento.descripcion=1936;message.condicionImpositiva.iva.id=2789;message.condicionImpositiva.iva.descripcion=9211;message.documentoIdentificativo.tipoDocumento.id=1855;message.documentoIdentificativo.tipoDocumento.descripcion=1855;message.documentoIdentificativo.numeroDocumento=1856;message.documentoIdentificativo.paisDocumento.id=1857;message.documentoIdentificativo.paisDocumento.descripcion=2632;message.documentoFisico.tipoDocumento.id=33320;message.documentoFisico.tipoDocumento.descripcion=33320;message.documentoFisico.numeroDocumento=33322;message.documentoFisico.paisDocumento.id=33321;message.documentoFisico.paisDocumento.descripcion=3257;message.documentoFisico.numeroTramite=33324;message.documentoFisico.ejemplar=33325;message.documentoFisico.fechaVencimiento=1859;message.estado.fallecido=1428;message.estado.fechaFallecimiento=1430;message.estado.habilitado=3843;message.estado.motivo.id=33368;message.estado.motivo.descripcion=9208;message.accion=33386;'', 2, ''TESTING IBM MQ QUEUE !!!'', 2, 1, 1, 0)

INSERT INTO dbo.CODIGO_TRANSACCIONES (CODIGO_OPERACION, CODIGO_INTERNO_MOV, CODIGO_TRANSACCION, TZ_LOCK)
VALUES (8912, 120, 537, 0)
')