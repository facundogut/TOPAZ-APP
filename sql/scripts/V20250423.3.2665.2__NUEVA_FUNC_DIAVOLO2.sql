EXECUTE('
	create table dbo.TTR_SOLICITUDES_REPROCESO_INFOE 
	(
		TIPO varchar(1) collate Modern_Spanish_CI_AS default '' '' not null, 
		IDENT numeric(15,0) default 0 not null, 
		FECHADESDE datetime null, 
		constraint PK_SOLICITUDES_REPROCESO_INFOE primary key (TIPO,IDENT), 
		constraint CHK_TIPO_VALID check (TIPO in (''J'',''T'')) 
	);
');

EXECUTE('
	insert into dbo.DESCRIPTORES (TITULO,IDENTIFICACION,DESCRIPCION,GRUPODELMAPA,NOMBREFISICO,TIPODEDBMS,BASE,ACEPTA_MOVS_DIFERIDO) 
	values 
		(930,452,''Solicitudes Reproceso Info E'',0,''TTR_SOLICITUDES_REPROCESO_INFOE'',''D'',''Top/Clientes'',''N'');

	insert into dbo.DICCIONARIO (NUMERODECAMPO,USODELCAMPO,REFERENCIA,DESCRIPCION,PROMPT,LARGO,TIPODECAMPO,DECIMALES,CONTABILIZA,CONCEPTO,CALCULO,VALIDACION,TABLADEVALIDACION,TABLADEAYUDA,OPCIONES,TABLA,CAMPO,BASICO) 
	values 
		(8493,'' '',0,''Tipo Identificacion'',''Tipo Identificacion'',1,''A'',0,0,0,0,0,0,0,1,452,''TIPO'',0), 
		(8495,'' '',0,''Nro Identificacion'',''Nro Identificacion'',15,''N'',0,0,0,0,0,0,0,0,452,''IDENT'',0), 
		(8496,'' '',0,''Fecha Desde Reproceso'',''Fecha Desde Reproceso'',8,''F'',0,0,0,0,0,0,0,0,452,''FECHADESDE'',0), 
		(8497,'' '',0,''Campo Ayuda Tabla 452'',''Ayuda T 452'',1,''A'',0,0,0,0,0,0,10,0,0,''C8497'',0);

	insert into dbo.OPCIONES (NUMERODECAMPO,IDIOMA,DESCRIPCION,OPCIONINTERNA,OPCIONDEPANTALLA) 
	values 
		(8493,''E'',''JTS_OID de Saldo'',''J'',''J''), 
		(8493,''E'',''Codigo de Transaccion'',''T'',''T'');

	insert into dbo.AYUDAS (NUMERODEARCHIVO,NUMERODEAYUDA,DESCRIPCION,MOSTRARTODOS,CAMPOS,AYUDAGRANDE) 
	values 
		(452,10,''Ayuda Tabla 452'',0,''8493R;8495R;8496;'',0);

	insert into dbo.INDICES (NUMERODEARCHIVO,NUMERODEINDICE,DESCRIPCION,CLAVESREPETIDAS,CAMPO1,CAMPO2) 
	values (452,1,''PK Tabla 452'',0,8493,8495);
	
	insert into dbo.OPERACIONES (TITULO,IDENTIFICACION,NOMBRE,DESCRIPCION,MNEMOTECNICO,AUTORIZACION,ESTADO,TZ_LOCK,SUBOPERACION,PERMITEBAJA,COMPORTAMIENTOENCIERRE,REQUIERECONTRASENA,PERMITECONCURRENTE,PERMITEESTADODIFERIDO,ESTILO) 
	values (6800,192,''INFOE - Solicitud de Reproceso'',''INFOE - Solicitud de Reproceso'',''192'',''N'',''P'',0,0,''S'',''N'',''N'',''N'',''N'',0);
');

EXECUTE('
	create or alter procedure dbo.SP_CONSULTA_CUENTAS_RECONSTRUIR_DIAVOLO
		@FECHADESDE datetime, 
		@CODTR numeric(15,0), 
		@CANT_A_RECONSTRUIR int output 
	as
	begin 
		set @CANT_A_RECONSTRUIR = 
		(
			select 
			count(*) as ''CANT_A_RECONSTRUIR'' 
			from 
			(
				select 
				s.JTS_OID as ''SALDOJTS'' 
				from dbo.MOVIMIENTOS_CONTABLES (nolock) mc 
				inner join dbo.ASIENTOS (nolock) a on a.ASIENTO = mc.ASIENTO and a.SUCURSAL = mc.SUCURSAL and a.FECHAPROCESO = mc.FECHAPROCESO and a.ESTADO = 77 
				inner join dbo.HISTORY (nolock) h on h.TRANSACTIONID = a.ASIENTO and h.BRANCH = a.SUCURSAL and h.PROCESSDATE = a.FECHAPROCESO and h.STATE = 77 
				inner join dbo.SALDOS (nolock) s on s.JTS_OID = mc.SALDO_JTS_OID and s.C1785 in (2,3) and s.TZ_LOCK = 0 
				left join dbo.TTR_CODIGO_TRANSACCION_DEF (nolock) tctd on tctd.CODIGO_TRANSACCION = mc.COD_TRANSACCION and tctd.TZ_LOCK = 0 
				where CONVERT(DATE,mc.FECHACONTABLE) >= @FECHADESDE 
				and h.DATE_ >= @FECHADESDE 
				and mc.COD_TRANSACCION = @CODTR 
				group by s.JTS_OID 
			) as p
		)
	end 
');
