Execute('create table dbo.ITF_LK_TJD_RESIDENTES_EXTERIOR_HIST_ELIM
(
	ID bigint identity(1,1) not null primary key, 
	CUIT varchar(20) COLLATE Modern_Spanish_CI_AS default '' '' not null, 
	TIPO_DOC_FISICO varchar(4) COLLATE Modern_Spanish_CI_AS default '' '' not null, 
	NUM_DOC_FISICO varchar(20) COLLATE Modern_Spanish_CI_AS default '' '' not null, 
	FECHA_ELIM datetime not null, 
	FECHA_RELOJ datetime not null, 
	DETALLE varchar(40) COLLATE Modern_Spanish_CI_AS default ''ELIMINADO - NO RESIDE EN EL EXTERIOR'' not null, 
	USUARIO varchar(10) COLLATE Modern_Spanish_CI_AS default '' '' not null 
); 

create table dbo.ITF_LK_TJD_RESIDENTES_EXTERIOR 
(
	CUIT varchar(20) COLLATE Modern_Spanish_CI_AS default '' '' not null, 
	TIPO_DOC_FISICO varchar(4) COLLATE Modern_Spanish_CI_AS default '' '' not null, 
	NUM_DOC_FISICO varchar(20) COLLATE Modern_Spanish_CI_AS default '' '' not null, 
	FECHA_ALTA datetime not null, 
	FECHA_ENVIO datetime not null, 
	FECHA_RESPUESTA datetime null, 
	CODIGO_ERROR NUMERIC(4,0) default 0 not null, 
	FECHA_RELOJ datetime not null, 
	TZ_LOCK numeric(15,0) default 0 not null, 
	constraint PK_ITF_LK_TJD_RESIDENTES_EXTERIOR_01 primary key (CUIT) 
); ')