--- Este script se crea a partir de que se carga el script con extensión .SQL lo que hace que flyway lo salte y no lo aplique, por lo cual se incrementa su version
Execute('
IF OBJECT_ID (''SIBE_CALIFICACION_DET'') IS NOT NULL
	drop table SIBE_CALIFICACION_DET;


CREATE TABLE dbo.SIBE_CALIFICACION_DET (
	Cuit numeric(12,0) NOT NULL,
	FecVig DATETIME NOT NULL,
	NroLinea numeric(8,0) NOT NULL,
	TipoCal char(1) COLLATE Modern_Spanish_CI_AS NULL,
	ImpCal numeric(15,2) NULL,
	GarantiaSC numeric(1,0) NULL,
	UsuAlta varchar(10) COLLATE Modern_Spanish_CI_AS NULL,
	FecAlta DATETIME NOT NULL,
	CONSTRAINT PK__SIBE_CAL__7E8029AFE76322C5 PRIMARY KEY (Cuit,NroLinea,FecAlta)
);

IF OBJECT_ID (''SIBE_CALIFICACION_CAB'') IS NOT NULL
	drop table SIBE_CALIFICACION_CAB;

CREATE TABLE dbo.SIBE_CALIFICACION_CAB (
	Cuit numeric(12,0) NOT NULL,
	FecVig DATETIME NOT NULL,
	FecVenc DATETIME NULL,
	RiesgCP numeric(15,2) NULL,
	RiesgLP numeric(15,2) NULL,
	CalifCP numeric(15,2) NULL,
	CalifLP numeric(15,2) NULL,
	MonTE numeric(15,2) NULL,
	Sucursal numeric(5,0) NULL,
	CtaCli numeric(9,0) NULL,
	UsuAlta varchar(10) COLLATE Modern_Spanish_CI_AS NULL,
	FecAlta DATETIME NULL,
	CONSTRAINT PK__SIBE_CAL__1A69BE803E4599B1 PRIMARY KEY (Cuit,FecVig)
);')
