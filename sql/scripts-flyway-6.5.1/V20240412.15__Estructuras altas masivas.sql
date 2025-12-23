EXECUTE('
----
IF OBJECT_ID (''dbo.MA_BANDEJA_ENTRADA'') IS NOT NULL
	DROP TABLE dbo.MA_BANDEJA_ENTRADA
--
IF OBJECT_ID (''dbo.MA_BANDEJA_SALIDA'') IS NOT NULL
	DROP TABLE dbo.MA_BANDEJA_SALIDA
--
IF OBJECT_ID (''dbo.MA_ACCIONES_X_CONVENIOS'') IS NOT NULL
	DROP TABLE dbo.MA_ACCIONES_X_CONVENIOS
--
IF OBJECT_ID (''dbo.MA_DEFAULT_GENERAL'') IS NOT NULL
	DROP TABLE dbo.MA_DEFAULT_GENERAL
----
')
EXECUTE('
----
CREATE TABLE dbo.MA_BANDEJA_ENTRADA
	(
	Id_Registro        INT IDENTITY NOT NULL,
	ConvenioPago       NUMERIC (15) DEFAULT ((0)),
	TipoConvenio       NUMERIC (5) DEFAULT ((0)),
	Dominio            NUMERIC (4) DEFAULT ((0)),
	Subdominio         NUMERIC (4) DEFAULT ((0)),
	Nro_Beneficio      NUMERIC (7) DEFAULT ((0)),
	Coparticipe        NUMERIC (1) DEFAULT ((0)),
	Digito_Verificador NUMERIC (1) DEFAULT ((0)),
	Origen             VARCHAR (2) DEFAULT ('' ''),
	Accion             NUMERIC (2) DEFAULT ((0)),
	Titular_Apoderado  VARCHAR (1) DEFAULT ('' ''),
	CUIL               VARCHAR (20) DEFAULT ('' ''),
	Tipo_Doc_Fisico    VARCHAR (4) DEFAULT ('' ''),
	Num_Doc_Fisico     VARCHAR (20) DEFAULT ('' ''),
	Apellido           VARCHAR (30) DEFAULT ('' ''),
	Nombre             VARCHAR (30) DEFAULT ('' ''),
	Cod_Postal         NUMERIC (4) DEFAULT ((0)),
	Departamento       NUMERIC (3) DEFAULT ((0)),
	Localidad          NUMERIC (3) DEFAULT ((0)),
	Provincia          VARCHAR (2) DEFAULT ('' ''),
	Calle              VARCHAR (50) DEFAULT ('' ''),
	Numero             NUMERIC (8) DEFAULT ((0)),
	Piso               NUMERIC (8) DEFAULT ((0)),
	Fecha_Nacimiento   DATETIME,
	Sexo               VARCHAR (1) DEFAULT ('' ''),
	Estado_Civil       VARCHAR (1) DEFAULT ('' ''),
	Telefono           VARCHAR (17) DEFAULT ('' ''),
	Email              VARCHAR (250) DEFAULT ('' ''),
	Codigo_Afip        VARCHAR (10) DEFAULT ('' ''),
	Sucursal           NUMERIC (5) DEFAULT ((0)),
	Localidad_Nac      NUMERIC (3) DEFAULT ((0)),
	Barrio             VARCHAR (100) DEFAULT ('' ''),
	CUIL_Titular_Anses VARCHAR (20) DEFAULT ('' ''),
	Nro_Lote           NUMERIC (10) DEFAULT ((0)),
	Estado             VARCHAR (1) DEFAULT ('' ''),
	TZ_LOCK            NUMERIC (15) DEFAULT ((0)) NOT NULL,
	Provincia_Nac      VARCHAR (2) DEFAULT ('' ''),
	Departamento_Nac   NUMERIC (3) DEFAULT ((0)),
	CONSTRAINT PK_MA_BANDEJA_ENTRADA_01 PRIMARY KEY (Id_Registro)
	)
----

CREATE TABLE dbo.MA_BANDEJA_SALIDA
	(
	Id_Registro        NUMERIC (10) NOT NULL,
	ConvenioPago       NUMERIC (15) DEFAULT ((0)) NOT NULL,
	TipoConvenio       NUMERIC (5) DEFAULT ((0)) NOT NULL,
	Dominio            NUMERIC (4) DEFAULT ((0)) NOT NULL,
	Subdominio         NUMERIC (4) DEFAULT ((0)) NOT NULL,
	Nro_Beneficio      NUMERIC (7) DEFAULT ((0)),
	Coparticipe        NUMERIC (1) DEFAULT ((0)),
	Digito_Verificador NUMERIC (1) DEFAULT ((0)),
	Origen             VARCHAR (2) DEFAULT ('' ''),
	Accion             NUMERIC (2) DEFAULT ((0)),
	Titular_Apoderado  VARCHAR (1) DEFAULT ('' ''),
	CUIL               VARCHAR (20) DEFAULT ('' ''),
	Tipo_Doc_Fisico    VARCHAR (4) DEFAULT ('' ''),
	Num_Doc_Fisico     VARCHAR (20) DEFAULT ('' ''),
	Apellido           VARCHAR (30) DEFAULT ('' ''),
	Nombre             VARCHAR (30) DEFAULT ('' ''),
	Cod_Postal         NUMERIC (4) DEFAULT ((0)),
	Departamento       NUMERIC (3) DEFAULT ((0)),
	Localidad          NUMERIC (3) DEFAULT ((0)),
	Provincia          VARCHAR (2) DEFAULT ('' ''),
	Calle              VARCHAR (50) DEFAULT ('' ''),
	Numero             NUMERIC (8) DEFAULT ((0)),
	Piso               NUMERIC (8) DEFAULT ((0)),
	Fecha_Nacimiento   DATETIME,
	Sexo               VARCHAR (1) DEFAULT ('' ''),
	Estado_Civil       VARCHAR (1) DEFAULT ('' ''),
	Telefono           VARCHAR (17) DEFAULT ('' ''),
	Email              VARCHAR (250) DEFAULT ('' ''),
	Codigo_Afip        VARCHAR (10) DEFAULT ('' ''),
	Sucursal           NUMERIC (5) DEFAULT ((0)),
	Lugar_Nacimiento   NUMERIC (3) DEFAULT ((0)),
	Barrio             VARCHAR (100) DEFAULT ('' ''),
	CUIL_Titular_Anses VARCHAR (20) DEFAULT ('' ''),
	Nro_Lote           NUMERIC (10) DEFAULT ((0)),
	Estado             VARCHAR (1) DEFAULT ('' ''),
	Descripcion        VARCHAR (250) DEFAULT ('' ''),
	Fecha_proceso      DATETIME,
	Producto           NUMERIC (5) DEFAULT ((0)),
	Cliente            NUMERIC (12) DEFAULT ((0)),
	Cuenta             NUMERIC (12) DEFAULT ((0)),
	CBU                VARCHAR (22) DEFAULT ('' ''),
	Saldo_Jts_Oid      NUMERIC (10) DEFAULT ((0)),
	TZ_LOCK            NUMERIC (15) DEFAULT ((0)) NOT NULL,
	SOLICITUD_LINK_TJD NUMERIC (15),
	CONSTRAINT PK_MA_BANDEJA_SALIDA_01 PRIMARY KEY (ConvenioPago, TipoConvenio, Dominio, Subdominio, Id_Registro)
	)
----

CREATE TABLE dbo.MA_ACCIONES_X_CONVENIOS
	(
	ConvenioPago     NUMERIC (15) DEFAULT ((0)) NOT NULL,
	TipoConvenio     NUMERIC (5) DEFAULT ((0)) NOT NULL,
	Dominio          NUMERIC (4) DEFAULT ((0)) NOT NULL,
	Subdominio       NUMERIC (4) DEFAULT ((0)) NOT NULL,
	Origen           VARCHAR (2) DEFAULT ('' ''),
	Accion           NUMERIC (2) DEFAULT ((0)),
	Producto         NUMERIC (5) DEFAULT ((0)),
	Reutiliza_Cuenta VARCHAR (1) DEFAULT ('' ''),
	Adhesion_Resumen VARCHAR (1) DEFAULT ('' ''),
	Es_Empleado      VARCHAR (1) DEFAULT ('' ''),
	Moneda           NUMERIC (4) DEFAULT ((0)),
	Codigo_Afip      VARCHAR (12) DEFAULT ('' ''),
	Cod_Profesion    VARCHAR (3) DEFAULT ('' ''),
	Motivo_Vinc      VARCHAR (2) DEFAULT ('' ''),
	Segmento         NUMERIC (3) DEFAULT ((0)),
	Subsegmento      NUMERIC (3) DEFAULT ((0)),
	Clase_TJD        NUMERIC (4) DEFAULT ((0)),
	Tipo_TJD         VARCHAR (2) DEFAULT ('' ''),
	Producto_TJD     VARCHAR (4) DEFAULT ('' ''),
	TZ_LOCK          NUMERIC (15) DEFAULT ((0)) NOT NULL,
	CONSTRAINT PK_MA_ACCIONES_X_CONVENIOS_01 PRIMARY KEY (ConvenioPago, TipoConvenio, Dominio, Subdominio)
	)
----

CREATE TABLE dbo.MA_DEFAULT_GENERAL
	(
	NumeroTabla   NUMERIC (5) DEFAULT ((0)) NOT NULL,
	NombreCampo   VARCHAR (30) DEFAULT ('' '') NOT NULL,
	Ordinal       VARCHAR (30) DEFAULT ('' '') NOT NULL,
	Valor         VARCHAR (250) DEFAULT ('' ''),
	NombreTabla   VARCHAR (60) DEFAULT ('' ''),
	NumeroDeCampo NUMERIC (5) DEFAULT ((0)),
	TZ_LOCK       NUMERIC (15) DEFAULT ((0)) NOT NULL,
	CONSTRAINT PK_MA_DEFAULT_GENERAL_01 PRIMARY KEY (NumeroTabla, NombreCampo, Ordinal)
	)
----
')