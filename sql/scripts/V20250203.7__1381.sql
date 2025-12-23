EXEC ('
	DROP TABLE IF EXISTS dbo.ASIENTOS_VARIOS_REGISTROS;
');

EXEC('
	DROP TABLE IF EXISTS dbo.ASIENTOS_VARIOS_ARCHIVOS;
');


EXEC('
	CREATE TABLE dbo.ASIENTOS_VARIOS_ARCHIVOS 
	(
		FECHA_IMPORTACION datetime not null, 
		HORA_IMPORTACION varchar(8) not null, 
		MD5_ARCH varchar(80) collate Modern_Spanish_CI_AS not null, 
		NOMBRE_ARCH varchar(50) collate Modern_Spanish_CI_AS not null, 
		USUARIO_IMPORTA varchar(10) collate Modern_Spanish_CI_AS not null, 
		TOTAL_DEBITOS numeric(15,2) default 0 not null, 
		TOTAL_CREDITOS numeric(15,2) default 0 not null, 
		CANAL_BANDEJA varchar(35) collate Modern_Spanish_CI_AS not null, 
		ESTADO varchar(1) collate Modern_Spanish_CI_AS default ''I'' not null, 
		TZ_LOCK numeric(15,0) default 0 not null, 
		CONSTRAINT PK_ASIENTOS_VARIOS_ARCHIVOS primary key (FECHA_IMPORTACION,MD5_ARCH) 
	);
');

EXEC ('
	CREATE TABLE dbo.ASIENTOS_VARIOS_REGISTROS 
	(
		FECHA_IMPORTACION datetime not null, 
		MD5_ARCH varchar(80) collate Modern_Spanish_CI_AS not null, 
		NRO_REGISTRO numeric(15,0) not null, 
		TIPO_CTA_ORIG varchar(1) collate Modern_Spanish_CI_AS not null, 
		SUC_CTA_ORIG numeric(5,0) not null, 
		NRO_CTA_ORIG numeric(12,0) not null, 
		MODULO_CTA_ORIG numeric(1,0) not null, 
		TIPO_CTA_DEST varchar(1) collate Modern_Spanish_CI_AS not null, 
		SUC_CTA_DEST numeric(5,0) not null, 
		NRO_CTA_DEST numeric(12,0) not null, 
		MODULO_CTA_DEST numeric(1,0) not null, 
		COD_MON_OPE numeric(5,0) not null, 
		IMPORTE numeric(15,2) not null, 
		COD_EVENTO numeric(5,0) not null, 
		COD_TR numeric(5,0) not null, 
		FECHA_IMPACTO datetime not null, 
		AJUSTE varchar(2) not null, 
		ESTADO varchar(1) collate Modern_Spanish_CI_AS not null, 
		MOTIVO_RECHAZO varchar(150) collate Modern_Spanish_CI_AS not null, 
		ASIENTO_PROCESADO numeric(10,0) default 0 not null, 
		FECHA_PROCESADO datetime null, 
		SUC_PROCESADO numeric(5,0) default 0 not null, 
		JTS_BANDEJA numeric(15,0) default 0 not null, 
		TZ_LOCK numeric(15,0) default 0 not null, 
		CONSTRAINT PK_ASIENTOS_VARIOS_REGISTROS primary key (FECHA_IMPORTACION,MD5_ARCH,NRO_REGISTRO), 
		CONSTRAINT FK_ASIENTOS_VARIOS_ARCHIVOS_01 FOREIGN KEY (FECHA_IMPORTACION,MD5_ARCH) REFERENCES dbo.ASIENTOS_VARIOS_ARCHIVOS(FECHA_IMPORTACION,MD5_ARCH) ON DELETE CASCADE ON UPDATE CASCADE 
	);
');

