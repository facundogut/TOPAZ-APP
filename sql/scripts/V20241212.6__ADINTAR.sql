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
		infoExtendida varchar(MAX) COLLATE Modern_Spanish_CI_AS not null default '' '', 
		infoExtendidaMeta nvarchar(MAX) COLLATE Modern_Spanish_CI_AS null check (isjson(infoExtendidaMeta) = 1), 
		TZ_LOCK numeric(15,0) DEFAULT 0 NOT NULL, 
		CONSTRAINT HISTORICO_MOVIMIENTOS_PK PRIMARY KEY (fechaAsiento, fechaReloj, movJtsOid) 
	); 
	CREATE NONCLUSTERED INDEX IX_HIS_MOV_ORDER ON dbo.HISTORICO_MOVIMIENTOS (jts_oid ASC, fechaValor DESC, TIMESTAMP_MOV DESC) INCLUDE (TZ_LOCK); 
	CREATE NONCLUSTERED INDEX IX_HIS_MOV_CUENTA ON dbo.HISTORICO_MOVIMIENTOS (sucursal ASC, cuenta ASC, modulo ASC) INCLUDE (TZ_LOCK); 
	CREATE NONCLUSTERED INDEX IX_HIS_MOV_JTS_SALDO ON dbo.HISTORICO_MOVIMIENTOS (jts_oid ASC) INCLUDE (TZ_LOCK); 
	CREATE NONCLUSTERED INDEX IX_HIS_MOV_JTS_FPROCESS ON dbo.HISTORICO_MOVIMIENTOS (fechaAsiento DESC) INCLUDE (TZ_LOCK); 
');

execute('
CREATE OR ALTER VIEW dbo.VW_NBCH24_CTA_TJD(tipo, tarjeta, estado, doc, jts_oid, descripcion, producto, clase, titularidad, primaria, ambito, comprasExterior)
AS
	select ''TJD'', t.ID_TARJETA, t.ESTADO,  docc.numerodocumento, c.saldo_jts_oid, ttt.descripcion, ttt.codigo_producto, ttt.clase, t.titularidad,
	case when c.ESTADO in( ''3'',''R'',''E'') then ''S'' else ''N'' end, --primaria
	case when c.ESTADO = ''3'' then ''NACIONAL'' when c.ESTADO = ''R'' then ''GLOBAL'' when c.ESTADO = ''E'' then ''EXTERIOR''  when c.ESTADO = ''1'' then ''VINCULADA'' else '''' end, --ambito
	case when c.ESTADO IN (''E'',''R'', ''1'', ''3'') then ''S'' else ''N'' end 
	from TJD_TARJETAS t WITH (NOLOCK)
	inner join TJD_TIPO_TARJETA ttt WITH (NOLOCK) on ttt.tipo_tarjeta = t.tipo_Tarjeta
	inner join TJD_REL_TARJETA_CUENTA c WITH (NOLOCK) on t.ID_TARJETA=c.ID_TARJETA
	inner join cli_documentospfpj docc WITH (NOLOCK) on t.nro_persona = docc.NUMEROPERSONAFJ
	where t.ESTADO in (''0'', ''1'', ''8'') and c.ESTADO NOT IN (''9'', ''X'')
	and c.TZ_LOCK = 0
	and docc.TZ_LOCK = 0

	UNION 

	select ''TJV'', caf.NRO_tARJETA, ''1'', doc.numerodocumento, caf.saldo_jts_oid, null, null, null, Null,
	''N'', '' '', ''N''  
	from itf_lk_Caf_cuentas caf WITH (NOLOCK)
	inner join saldos s WITH (NOLOCK) on caf.saldo_jts_oid = s.jts_oid 
	inner join CLI_ClientePersona ccp WITH (NOLOCK) on ccp.CODIGOCLIENTE = s.c1803
	inner join cli_documentospfpj doc WITH (NOLOCK) on doc.numeropersonafj = ccp.numeropersona 
	where estado_Cuenta = ''1''
	and ccp.TZ_LOCK = 0 and ccp.TITULARIDAD = ''T'' 
	and doc.TZ_LOCK = 0
	and caf.NRO_TARJETA not in (select x.ID_TARJETA  from TJD_TARJETAS x WITH (NOLOCK) where x.ESTADO in (''0'', ''1'', ''8''))
');
