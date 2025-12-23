execute('BEGIN
	--Tablas
	drop table IF EXISTS dbo.EMAIL_LIST;
	drop table IF EXISTS dbo.EMAIL_CONF;
	drop table IF EXISTS dbo.EMAIL_CONF_PROC;
	drop table IF EXISTS dbo.EMAIL_CONF_SERV;
	drop table IF EXISTS dbo.EMAIL_CONF_DNS;
	--1
	create table dbo.EMAIL_CONF_DNS 
	( 
		ID numeric(15,0) identity(1,1) not null, 
		DNS varchar(100) COLLATE Modern_Spanish_CI_AS DEFAULT '' '' not null, 
		COMENTARIOS varchar(100) COLLATE Modern_Spanish_CI_AS DEFAULT '' '' not null, 
		TZ_LOCK numeric(15,0) DEFAULT 0 NOT NULL, 
		constraint PK_EMAIL_CONF_DNS_01 primary key (ID), 
		constraint UNIQUE_DNS_EMAIL_CONF_DNS_01 unique (DNS) 
	); 
	--2
	create table dbo.EMAIL_CONF_SERV 
	( 
		ID numeric(15,0) identity(1,1) not null, 
		SERVER_HOST varchar(100) COLLATE Modern_Spanish_CI_AS DEFAULT '' '' not null, 
		SERVER_PORT numeric(10,0) DEFAULT 0 not null, 
		AUTENTICACION varchar(1) COLLATE Modern_Spanish_CI_AS DEFAULT '' '' not null, 
		AUTH_USER varchar(100) COLLATE Modern_Spanish_CI_AS DEFAULT '' '' not null, 
		AUTH_PASS varchar(100) COLLATE Modern_Spanish_CI_AS DEFAULT '' '' not null, 
		COMENTARIOS varchar(100) COLLATE Modern_Spanish_CI_AS DEFAULT '' '' not null, 
		TZ_LOCK numeric(15,0) DEFAULT 0 NOT NULL, 
		constraint PK_EMAIL_CONF_SERV_01 primary key (ID) 
	); 
	--3
	create table dbo.EMAIL_CONF_PROC 
	( 
		ID numeric(15,0) identity(1,1) not null, 
		CLAVE_PROCESO varchar(100) COLLATE Modern_Spanish_CI_AS DEFAULT '' '' not null, 
		COMENTARIOS varchar(100) COLLATE Modern_Spanish_CI_AS DEFAULT '' '' not null, 
		TZ_LOCK numeric(15,0) DEFAULT 0 NOT NULL, 
		constraint PK_EMAIL_CONF_PROC_01 primary key (ID), 
		constraint UNIQUE_CLAVE_PROCESO_EMAIL_CONF_PROC_01 unique (CLAVE_PROCESO) 
	); 
	--4
	create table dbo.EMAIL_CONF 
	( 
		ID numeric(15,0) identity(1,1) not null,
		ID_DNS numeric(15,0) DEFAULT 0 not null, 
		ID_PROCESO numeric(15,0) DEFAULT 0 not null, 
		TIPO varchar(1) COLLATE Modern_Spanish_CI_AS DEFAULT '' '' not null, 
		ID_SERV numeric(15,0) DEFAULT 0 not null, 
		TZ_LOCK numeric(15,0) DEFAULT 0 NOT NULL, 
		constraint PK_EMAIL_CONF_01 primary key (ID), 
		constraint UNIQUE_CONF_EMAIL_CONF_01 unique (ID_DNS,ID_PROCESO,TIPO),
		constraint FK_DNS_EMAIL_CONF_01 foreign key (ID_DNS) references EMAIL_CONF_DNS on update cascade on delete no action, 
		constraint FK_PROC_EMAIL_CONF_02 foreign key (ID_PROCESO) references EMAIL_CONF_PROC on update cascade on delete cascade, 
		constraint FK_SERV_EMAIL_CONF_03 foreign key (ID_SERV) references EMAIL_CONF_SERV on update cascade on delete no action 
	); 
	--5
	create table dbo.EMAIL_LIST 
	( 
		ID numeric(15,0) identity(1,1) not null, 
		ID_CONF numeric(15,0) DEFAULT 0 not null, 
		TIPO varchar(1) COLLATE Modern_Spanish_CI_AS DEFAULT '' '' not null, 
		EMAIL varchar(100) COLLATE Modern_Spanish_CI_AS DEFAULT '' '' not null, 
		COMENTARIOS varchar(100) COLLATE Modern_Spanish_CI_AS DEFAULT '' '' not null, 
		TZ_LOCK numeric(15,0) DEFAULT 0 NOT NULL, 
		constraint PK_EMAIL_LIST_01 primary key (ID), 
		constraint FK_CONF_EMAIL_LIST_01 foreign key (ID_CONF) references EMAIL_CONF on update cascade on delete cascade 
	); 
	
	--Vistas
	EXECUTE (''CREATE or ALTER VIEW dbo.VW_MOD_CORREOS_SEL_DNS 
	AS 
		select 
		ID, 
		DNS 
		from EMAIL_CONF_DNS;'');

	EXECUTE (''CREATE or ALTER VIEW dbo.VW_MOD_CORREOS_SEL_SMTP 
	AS 
		select 
		ID, 
		SERVER_HOST, 
		SERVER_PORT, 
		AUTENTICACION, 
		AUTH_USER, 
		AUTH_PASS 
		from EMAIL_CONF_SERV;'');
		
	EXECUTE (''CREATE or ALTER VIEW dbo.VW_MOD_CORREOS_SEL_PROC 
	AS 
		select 
		ID, 
		CLAVE_PROCESO 
		from EMAIL_CONF_PROC;'');
		
	EXECUTE (''CREATE or ALTER VIEW dbo.VW_MOD_CORREOS_SEL_CEMAIL 
	AS 
		select 
		ec.ID, 
		ec.ID_DNS, 
		ecd.DNS, 
		ec.ID_PROCESO, 
		ecp.CLAVE_PROCESO, 
		ec.TIPO, 
		ec.ID_SERV, 
		ecs.SERVER_HOST 
		from EMAIL_CONF ec 
		inner join EMAIL_CONF_DNS ecd on ec.ID_DNS = ecd.ID 
		inner join EMAIL_CONF_PROC ecp on ec.ID_PROCESO = ecp.ID 
		inner join EMAIL_CONF_SERV ecs on ec.ID_SERV = ecs.ID;'');
		
	--SP
	EXECUTE (''CREATE or ALTER PROCEDURE dbo.SP_DELETE_EMAIL_CONF

	@V_CODIGO			NUMERIC(5), 		--SIN USO
	@V_RESULTADO 		NUMERIC(5) OUTPUT	--SIN USO

	AS

	BEGIN

	DELETE FROM EMAIL_CONF WHERE TZ_LOCK <> 0; 
	DELETE FROM EMAIL_CONF_DNS WHERE TZ_LOCK <> 0;
	DELETE FROM EMAIL_CONF_PROC WHERE TZ_LOCK <> 0;
	DELETE FROM EMAIL_CONF_SERV WHERE TZ_LOCK <> 0;
	DELETE FROM EMAIL_LIST WHERE TZ_LOCK <> 0;

	SET @V_RESULTADO = 1;

	END;'');
	
	EXECUTE (''CREATE or ALTER PROCEDURE dbo.SP_MODIF_EMAIL_CONF
    @V_CODIGO         NUMERIC(15,0),       --ID DE TABLA A MODIFICAR
    @V_TABLA          VARCHAR(1),       --IDENTIFICADOR DE TABLA
    @V_ARG1           VARCHAR(100),     --Argumento1
    @V_ARG2           VARCHAR(100),     --Argumento2
    @V_ARG3           VARCHAR(100),     --Argumento3
    @V_ARG4           VARCHAR(100),     --Argumento4
    @V_ARG5           VARCHAR(100),     --Argumento5
    @V_ARG6           VARCHAR(100),     --Argumento6
    @V_RESULTADO      NUMERIC(5) OUTPUT --SIN USO
	AS
	BEGIN

	DECLARE @AUX_ID NUMERIC(15,0)

		--AMBIENTES
		IF @V_TABLA = ''''A''''
		BEGIN
			UPDATE EMAIL_CONF_DNS
			SET DNS = @V_ARG1,
				COMENTARIOS = @V_ARG2
			WHERE ID = @V_CODIGO;
		END
		
		--SERVIDORES
		ELSE IF @V_TABLA = ''''S''''
		BEGIN
			UPDATE EMAIL_CONF_SERV
			SET SERVER_HOST = @V_ARG1,
				SERVER_PORT = CONVERT(NUMERIC(10,0),@V_ARG2),
				AUTENTICACION = @V_ARG3,
				AUTH_USER = @V_ARG4,
				AUTH_PASS = @V_ARG5,
				COMENTARIOS = @V_ARG6
			WHERE ID = @V_CODIGO;
		END

		--PROCESOS
		ELSE IF @V_TABLA = ''''P''''
		BEGIN
			UPDATE EMAIL_CONF_PROC
			SET CLAVE_PROCESO = @V_ARG1,
				COMENTARIOS = @V_ARG2
			WHERE ID = @V_CODIGO;
		END

		--LISTA DE CORREOS
		ELSE IF @V_TABLA = ''''L''''
		BEGIN

			SET @AUX_ID = (SELECT ID FROM EMAIL_LIST WHERE ID_CONF = @V_CODIGO AND TIPO = @V_ARG1 AND EMAIL = @V_ARG2)

			UPDATE EMAIL_LIST
			SET ID_CONF = CONVERT(NUMERIC(15,0), @V_ARG3),
				TIPO = @V_ARG4,
				EMAIL = @V_ARG5,
				COMENTARIOS = @V_ARG6
			WHERE ID = @AUX_ID;
		END

		--VINCULACIONES 
		ELSE IF @V_TABLA = ''''V''''
		BEGIN
			UPDATE EMAIL_CONF
			SET ID_DNS = CONVERT(NUMERIC(15,0), @V_ARG1),
				ID_PROCESO = CONVERT(NUMERIC(15,0), @V_ARG2),
				TIPO = @V_ARG3,
				ID_SERV = CONVERT(NUMERIC(15,0), @V_ARG4)
			WHERE ID = @V_CODIGO;
		END
		
		SET @V_RESULTADO = 1;
	END;'');
	
	--ITF_MASTER
	delete from dbo.ITF_MASTER where ID in (252,253);
	INSERT INTO dbo.ITF_MASTER
	(TZ_LOCK, ID, DESCRIPCION, OBJ_KETTLE, P0_MODO, P0_TIPO, P0_CAPTION, P0_CONSTANTE, P1_MODO, P1_TIPO, P1_CAPTION, P1_CONSTANTE, P2_MODO, P2_TIPO, P2_CAPTION, P2_CONSTANTE, P3_MODO, P3_TIPO, P3_CAPTION, P3_CONSTANTE, P4_MODO, P4_TIPO, P4_CAPTION, P4_CONSTANTE, P5_MODO, P5_TIPO, P5_CAPTION, P5_CONSTANTE, P6_MODO, P6_TIPO, P6_CAPTION, P6_CONSTANTE, P7_MODO, P7_TIPO, P7_CAPTION, P7_CONSTANTE, P8_MODO, P8_TIPO, P8_CONSTANTE, P8_CAPTION, P9_MODO, P9_TIPO, P9_CAPTION, P9_CONSTANTE, TIPO_OBJ, COMENTARIO, ID_REPORTE, MODO_EJECUCION, KETTLE_NAME)
	VALUES
	(0, 252, N''GENERICO ENVIO CORREO OPES TEXTO PLANO'', N''PUNTO_ENTRADA_LOG_PA.kjb'', N'' '', N'' '', N'' '', N'' '', N'' '', N'' '', N'' '', N'' '', N'' '', N'' '', N'' '', N'' '', N'' '', N'' '', N'' '', N'' '', N'' '', N'' '', N'' '', N'' '', N'' '', N'' '', N'' '', N'' '', N'' '', N'' '', N'' '', N'' '', N'' '', N'' '', N'' '', N'' '', N'' '', N'' '', N'' '', N'' '', N'' '', N'' '', N'' '', N'' '', N''J'', N'' '', 0, N''M'', N''GENERICO_ENVIAR_CORREO_PARAMETRIA_TOP_JOB.kjb''),
	(0, 253, N''GENERICO ENVIO CORREO OPES TEMPLATE'', N''PUNTO_ENTRADA_LOG_PA.kjb'', N'' '', N'' '', N'' '', N'' '', N'' '', N'' '', N'' '', N'' '', N'' '', N'' '', N'' '', N'' '', N'' '', N'' '', N'' '', N'' '', N'' '', N'' '', N'' '', N'' '', N'' '', N'' '', N'' '', N'' '', N'' '', N'' '', N'' '', N'' '', N'' '', N'' '', N'' '', N'' '', N'' '', N'' '', N'' '', N'' '', N'' '', N'' '', N'' '', N'' '', N''J'', N'' '', 0, N''M'', N''GENERICO_ENVIAR_CORREO_TEMPLATE_OPERACION.kjb'');
	
	--Metadata TOPAZ
	delete from dbo.OPERACIONES where IDENTIFICACION in (94);
	insert into dbo.OPERACIONES (TITULO,IDENTIFICACION,NOMBRE,DESCRIPCION,MNEMOTECNICO,AUTORIZACION,FORMULARIOPRINCIPAL,PROXOPERACION,ESTADO,TZ_LOCK,COPIAS,SUBOPERACION,PERMITEBAJA,COMPORTAMIENTOENCIERRE,REQUIERECONTRASENA,PERMITECONCURRENTE,PERMITEESTADODIFERIDO,ICONO_TITULO,ESTILO) values
		 (6800,94,N''ABMC - Parametría Módulo Correos'',N''ABMC - Parametría Módulo Correos'',N''94'',N''N'',NULL,NULL,N''P'',0,NULL,0,N''S'',N''N'',N''N'',N''S'',N''N'',NULL,0);

	delete from dbo.DESCRIPTORES where IDENTIFICACION in (3,4,6,10,12);
	insert into dbo.DESCRIPTORES (TITULO,IDENTIFICACION,TIPODEARCHIVO,DESCRIPCION,GRUPODELMAPA,NOMBREFISICO,TIPODEDBMS,LARGODELREGISTRO,INICIALIZACIONDELREGISTRO,BASE,SELECCION,ACEPTA_MOVS_DIFERIDO) values
		 (930,3,NULL,N''Modulo Correos - Config DNS'',0,N''EMAIL_CONF_DNS'',N''D'',NULL,NULL,N''Top/Clientes'',NULL,N''N''),
		 (930,4,NULL,N''Modulo Correos - Config SMTP'',0,N''EMAIL_CONF_SERV'',N''D'',NULL,NULL,N''Top/Clientes'',NULL,N''N''),
		 (930,6,NULL,N''Modulo Correos - Config Proc'',0,N''EMAIL_CONF_PROC'',N''D'',NULL,NULL,N''Top/Clientes'',NULL,N''N''),
		 (930,10,NULL,N''Modulo Correos - Config EMAIL'',0,N''EMAIL_CONF'',N''D'',NULL,NULL,N''Top/Clientes'',NULL,N''N''),
		 (930,12,NULL,N''Modulo Correos - EMAIL LIST'',0,N''EMAIL_LIST'',N''D'',NULL,NULL,N''Top/Clientes'',NULL,N''N'');

	delete from dbo.DICCIONARIO where NUMERODECAMPO in (7482,7483,7508,7512,7520,7547,7809,7811,7812,7813,7814,7815,7816,7817,7818,7819,7820,7821,7822,7823);
	insert into dbo.DICCIONARIO (NUMERODECAMPO,USODELCAMPO,REFERENCIA,DESCRIPCION,PROMPT,LARGO,TIPODECAMPO,DECIMALES,EDICION,CONTABILIZA,CONCEPTO,CALCULO,VALIDACION,TABLADEVALIDACION,TABLADEAYUDA,OPCIONES,TABLA,CAMPO,BASICO,MASCARA) values
		 (7482,N'''',0,N''DNS'',N''DNS'',100,N''A'',0,NULL,0,0,0,0,0,0,0,3,N''DNS'',0,NULL),
		 (7483,N'''',0,N''Host del SMTP'',N''Host del SMTP'',100,N''A'',0,NULL,0,0,0,0,0,0,0,4,N''SERVER_HOST'',0,NULL),
		 (7508,N'''',0,N''Puerto del SMTP'',N''Puerto del SMTP'',10,N''N'',0,NULL,0,0,0,0,0,0,0,4,N''SERVER_PORT'',0,NULL),
		 (7512,N'''',0,N''Modo de Autenticacion SMTP'',N''AUTH MODE SMTP'',1,N''A'',0,NULL,0,0,0,0,0,0,1,4,N''AUTENTICACION'',0,NULL),
		 (7520,N'''',0,N''Usuario de SMTP'',N''Usuario SMTP'',100,N''A'',0,NULL,0,0,0,0,0,0,0,4,N''AUTH_USER'',0,NULL),
		 (7547,N'''',0,N''Clave de SMTP'',N''Clave SMTP'',100,N''A'',0,NULL,0,0,0,0,0,0,0,4,N''AUTH_PASS'',0,NULL),
		 (7809,N'''',0,N''Proceso'',N''Proceso'',100,N''A'',0,NULL,0,0,0,0,0,0,0,6,N''CLAVE_PROCESO'',0,NULL),
		 (7811,N'''',0,N''ID DNS'',N''ID DNS'',15,N''N'',0,NULL,0,0,0,0,0,31,0,10,N''ID_DNS'',0,NULL),
		 (7812,N'''',0,N''ID Proceso'',N''ID Proceso'',15,N''N'',0,NULL,0,0,0,0,0,61,0,10,N''ID_PROCESO'',0,NULL),
		 (7813,N'''',0,N''Tipo Config'',N''Tipo Config'',1,N''A'',0,NULL,0,0,0,0,0,0,0,10,N''TIPO'',0,NULL),
		 (7814,N'''',0,N''ID SMTP'',N''ID SMTP'',15,N''N'',0,NULL,0,0,0,0,0,41,0,10,N''ID_SERV'',0,NULL),
		 (7815,N'''',0,N''ID Conf EMAIL'',N''ID Conf EMAIL'',15,N''N'',0,NULL,0,0,0,0,0,101,0,12,N''ID_CONF'',0,NULL),
		 (7816,N'''',0,N''Tipo EMAIL'',N''Tipo EMAIL'',1,N''A'',0,NULL,0,0,0,0,0,0,1,12,N''TIPO'',0,NULL),
		 (7817,N'''',0,N''Correo'',N''Correo'',100,N''A'',0,NULL,0,0,0,0,0,0,0,12,N''EMAIL'',0,NULL),
		 (7818,N'''',0,N''Grilla Lista Correos'',N''Lista de Correos'',100,N''A'',0,NULL,0,0,0,0,0,121,0,0,NULL,0,NULL),
		 (7819,N'''',0,N''Menu Modo ABMC'',N''Editar Parametria'',1,N''A'',0,NULL,0,0,0,0,0,0,1,0,NULL,0,NULL),
		 (7820,N'''',0,N''Comentarios'',N''Comentarios'',100,N''A'',0,NULL,0,0,0,0,0,0,0,3,N''COMENTARIOS'',0,NULL),
		 (7821,N'''',0,N''Comentarios'',N''Comentarios'',100,N''A'',0,NULL,0,0,0,0,0,0,0,4,N''COMENTARIOS'',0,NULL),
		 (7822,N'''',0,N''Comentarios'',N''Comentarios'',100,N''A'',0,NULL,0,0,0,0,0,0,0,6,N''COMENTARIOS'',0,NULL),
		 (7823,N'''',0,N''Comentarios'',N''Comentarios'',100,N''A'',0,NULL,0,0,0,0,0,0,0,12,N''COMENTARIOS'',0,NULL);

	delete from dbo.AYUDAS where NUMERODEAYUDA in (31,41,61,101,121);
	insert into dbo.AYUDAS (NUMERODEARCHIVO,NUMERODEAYUDA,DESCRIPCION,FILTRO,MOSTRARTODOS,CAMPOS,CAMPOSVISTA,BASEVISTA,NOMBREVISTA,AYUDAGRANDE) values
		 (0,31,N''Modulo Correos - Sel DNS'',NULL,0,N''7811ROA1;7482R;'',N''ID;DNS;'',N''TOP/CLIENTES'',N''VW_MOD_CORREOS_SEL_DNS'',0),
		 (0,41,N''Modulo Correos - Sel SMTP'',NULL,0,N''7814ROA1;7483R;7508R;7512R;7520R;7547R;'',N''ID;SERVER_HOST;SERVER_PORT;AUTENTICACION;AUTH_USER;AUTH_PASS;'',N''TOP/CLIENTES'',N''VW_MOD_CORREOS_SEL_SMTP'',0),
		 (0,61,N''Modulo Correos - Sel PROC'',NULL,0,N''7812ROA1;7809R;'',N''ID;CLAVE_PROCESO;'',N''TOP/CLIENTES'',N''VW_MOD_CORREOS_SEL_PROC'',0),
		 (0,101,N''Modulo Correos - Sel CEMAIL'',NULL,0,N''7815ROA1;7811R;7482R;7812R;7809R;7813R;7814R;7483R;'',N''ID;ID_DNS;DNS;ID_PROCESO;CLAVE_PROCESO;TIPO;ID_SERV;SERVER_HOST;'',N''TOP/CLIENTES'',N''VW_MOD_CORREOS_SEL_CEMAIL'',0),
		 (12,121,N''Modulo Correos - Sel LEMAIL'',NULL,0,N''7815R;7816ROD1;7817R;'',NULL,NULL,NULL,0);

	delete from dbo.INDICES where NUMERODEARCHIVO in (3,4,6,10,12);
	insert into dbo.INDICES (NUMERODEARCHIVO,NUMERODEINDICE,DESCRIPCION,CLAVESREPETIDAS,CAMPO1,CAMPO2,CAMPO3,CAMPO4,CAMPO5,CAMPO6,CAMPO7,CAMPO8,CAMPO9,CAMPO10,CAMPO11,CAMPO12,CAMPO13,CAMPO14,CAMPO15,CAMPO16,CAMPO17,CAMPO18,CAMPO19,CAMPO20) values
		 (3,1,N''PK Config DNS'',0,7482,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
		 (4,1,N''PK Config SMTP'',0,7483,7508,7512,7520,7547,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
		 (6,1,N''PK Config Proc'',0,7809,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
		 (10,1,N''PK EMAIL Conf'',0,7811,7812,7813,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
		 (12,1,N''PK EMAIL List'',0,7815,7816,7817,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
		 (12,2,N''Filtra EMAIL Por Config'',1,7815,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

	delete from dbo.OPCIONES where NUMERODECAMPO in (7512,7816,7819);
	insert into dbo.OPCIONES (NUMERODECAMPO,IDIOMA,DESCRIPCION,OPCIONINTERNA,OPCIONDEPANTALLA) values
		 (7512,N''E'',N''Sin Encriptar'',N''A'',N''A''),
		 (7512,N''E'',N''NO Autenticacion'',N''N'',N''N''),
		 (7512,N''E'',N''Encriptado SSL'',N''S'',N''S''),
		 (7512,N''E'',N''Encriptado TLS'',N''T'',N''T''),
		 (7816,N''E'',N''Con Copia'',N''C'',N''C''),
		 (7816,N''E'',N''Destino Principal'',N''P'',N''P''),
		 (7819,N''E'',N''Ambientes'',N''A'',N''A''),
		 (7819,N''E'',N''Listas de Correos'',N''L'',N''L''),
		 (7819,N''E'',N''Procesos'',N''P'',N''P''),
		 (7819,N''E'',N''Servidores SMTP'',N''S'',N''S''),
		 (7819,N''E'',N''Vinculaciones'',N''V'',N''V'');
	
END');