EXECUTE('
	drop index if exists IX_CPT_PK_TZ on dbo.TTR_CODIGO_PROGRAMA_TRANSACCION;
	drop index if exists IX_CTIE_PK_TZ on dbo.TTR_CODIGO_TRANSACCION_INFO_EXTENDIDA;
	drop index if exists IX_DELETE_MOVS on dbo.HISTORICO_MOVIMIENTOS;
');

EXECUTE('
	alter table dbo.TTR_CODIGO_PROGRAMA_TRANSACCION alter column nombrePrograma varchar(100) collate Modern_Spanish_CI_AS not null;
	alter table dbo.TTR_CODIGO_PROGRAMA_TRANSACCION alter column descripcion varchar(150) collate Modern_Spanish_CI_AS not null;
	alter table dbo.TTR_CODIGO_TRANSACCION_INFO_EXTENDIDA add constraint FK_PROGRAMA_INFOE foreign key (infoExtendidaTipo) references dbo.TTR_CODIGO_PROGRAMA_TRANSACCION(codigoPrograma);
	alter table dbo.TTR_CODIGO_PROGRAMA_TRANSACCION add estado numeric(1,0) default 0 not null;
	alter table dbo.TTR_CODIGO_PROGRAMA_TRANSACCION add formato numeric(5,0) default 0 not null;
');

EXECUTE('
	alter table dbo.TTR_CODIGO_PROGRAMA_TRANSACCION add constraint CHK_ESTVALID check (estado in (0,1));
');

EXECUTE('
	update dbo.TTR_CODIGO_PROGRAMA_TRANSACCION set estado = 1, TZ_LOCK = 0 where codigoPrograma in (11,18,19,20);
');

EXECUTE('
	update dbo.TTR_CODIGO_PROGRAMA_TRANSACCION set formato = 1 where codigoPrograma in (1,6,8,12,13,14);
	update dbo.TTR_CODIGO_PROGRAMA_TRANSACCION set formato = 2 where codigoPrograma in (2);
	update dbo.TTR_CODIGO_PROGRAMA_TRANSACCION set formato = 3 where codigoPrograma in (3);
	update dbo.TTR_CODIGO_PROGRAMA_TRANSACCION set formato = 4 where codigoPrograma in (4);
	update dbo.TTR_CODIGO_PROGRAMA_TRANSACCION set formato = 5 where codigoPrograma in (5);
	update dbo.TTR_CODIGO_PROGRAMA_TRANSACCION set formato = 6 where codigoPrograma in (7);
	update dbo.TTR_CODIGO_PROGRAMA_TRANSACCION set formato = 7 where codigoPrograma in (9);
	update dbo.TTR_CODIGO_PROGRAMA_TRANSACCION set formato = 8 where codigoPrograma in (10);
	update dbo.TTR_CODIGO_PROGRAMA_TRANSACCION set formato = 9 where codigoPrograma in (11);
	update dbo.TTR_CODIGO_PROGRAMA_TRANSACCION set formato = 10 where codigoPrograma in (15);
	update dbo.TTR_CODIGO_PROGRAMA_TRANSACCION set formato = 11 where codigoPrograma in (16,17);
	update dbo.TTR_CODIGO_PROGRAMA_TRANSACCION set formato = 12 where codigoPrograma in (18);
	update dbo.TTR_CODIGO_PROGRAMA_TRANSACCION set formato = 13 where codigoPrograma in (19,20);
');

EXECUTE('
	insert into dbo.DICCIONARIO (NUMERODECAMPO,USODELCAMPO,REFERENCIA,DESCRIPCION,PROMPT,LARGO,TIPODECAMPO,DECIMALES,CONTABILIZA,CONCEPTO,CALCULO,VALIDACION,TABLADEVALIDACION,TABLADEAYUDA,OPCIONES,TABLA,CAMPO,BASICO) 
	values 
		(8490,'' '',0,''estado'',''estado'',1,''N'',0,0,0,0,0,0,0,1,35,''estado'',0), 
		(8491,'' '',0,''formato'',''formato'',5,''N'',0,0,0,0,0,0,0,0,35,''formato'',0);
');

EXECUTE('
	insert into dbo.OPCIONES (NUMERODECAMPO,IDIOMA,DESCRIPCION,OPCIONINTERNA,OPCIONDEPANTALLA) 
	values 
		(8490,''E'',''Habilitado'',''0'',''0''), 
		(8490,''E'',''Deshabilitado'',''1'',''1'');
');

EXECUTE('
	update dbo.AYUDAS set CAMPOS = ''8135R;7835;8490;8491;8136;'' where NUMERODEAYUDA = 2;
');

EXECUTE('
	create nonclustered index IX_CPT_PK_TZ on dbo.TTR_CODIGO_PROGRAMA_TRANSACCION (codigoPrograma, estado, TZ_LOCK) include (nombrePrograma);
	create nonclustered index IX_CTIE_PK_TZ on dbo.TTR_CODIGO_TRANSACCION_INFO_EXTENDIDA (codigoTransaccion, TZ_LOCK) include (infoExtendidaTipo);
	create nonclustered index IX_DELETE_MOVS on dbo.HISTORICO_MOVIMIENTOS (fechaValor, TIMESTAMP_MOV, jts_oid);
');

