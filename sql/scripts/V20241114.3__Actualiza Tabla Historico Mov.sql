EXECUTE
('
	drop table if exists dbo.HISTORICO_MOVIMIENTOS; 
');

EXECUTE
('
	create table dbo.HISTORICO_MOVIMIENTOS 
	(
		sucursal numeric(5,0) not null, 
		cuenta numeric(12,0) not null, 
		modulo numeric(1,0) not null, 
		producto numeric(5,0) not null, 
		moneda numeric(4,0) not null, 
		jts_oid numeric(10,0) not null, 
		fechaAsiento datetime not null, 
		sucursalAlta numeric(5,0) not null, 
		tipoMov varchar(1) COLLATE Modern_Spanish_CI_AS not null, 
		importe numeric(15,2) not null, 
		descripcion varchar(60) COLLATE Modern_Spanish_CI_AS not null default '' '', 
		fechaValor datetime not null, 
		asiento numeric(10,0) not null, 
		movJtsOid numeric(10,0) not null, 
		operacion numeric(5,0) not null default 0, 
		codigoTransaccion numeric(5,0) not null default 0, 
		fechaReloj datetime not null, 
		horaReloj varchar(8) COLLATE Modern_Spanish_CI_AS not null, 
		TIMESTAMP_MOV datetime not null, 
		saldoPrevio numeric(15,2) not null, 
		saldoPosterior numeric(15,2) not null, 
		infoExtendida varchar(150) COLLATE Modern_Spanish_CI_AS not null default '' '', 
		infoExtendidaMeta nvarchar(MAX) COLLATE Modern_Spanish_CI_AS null check (isjson(infoExtendidaMeta) = 1), 
		TZ_LOCK numeric(15,0) DEFAULT 0 NOT NULL, 
		CONSTRAINT HISTORICO_MOVIMIENTOS_PK PRIMARY KEY (fechaAsiento, fechaReloj, movJtsOid) 
	); 
	CREATE NONCLUSTERED INDEX IX_HIS_MOV_ORDER ON dbo.HISTORICO_MOVIMIENTOS (jts_oid ASC, fechaValor DESC, TIMESTAMP_MOV DESC) INCLUDE (TZ_LOCK); 
	CREATE NONCLUSTERED INDEX IX_HIS_MOV_CUENTA ON dbo.HISTORICO_MOVIMIENTOS (sucursal ASC, cuenta ASC, modulo ASC) INCLUDE (TZ_LOCK); 
	CREATE NONCLUSTERED INDEX IX_HIS_MOV_JTS_SALDO ON dbo.HISTORICO_MOVIMIENTOS (jts_oid ASC) INCLUDE (TZ_LOCK); 
	CREATE NONCLUSTERED INDEX IX_HIS_MOV_JTS_FPROCESS ON dbo.HISTORICO_MOVIMIENTOS (fechaAsiento DESC) INCLUDE (TZ_LOCK); 
');
