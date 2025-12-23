execute('
----------------------------------------PASIVAS.-----------------------------------------------------------
--exec SP_INTEGRIDAD_REFERENCIAL_CONTABILIDAD NBCH_tunning

CREATE OR ALTER  procedure [dbo].[SP_INTEGRIDAD_REFERENCIAL_CONTABILIDAD] 
								 @BD varchar(20)
as
BEGIN
IF (SELECT DB_NAME()) = @BD
  BEGIN
	print ''--------------------CONTABILIDAD----------------''
	print ''------------------------------------------------''
	

	if exists (select a.C1730  
				from SALDOS a with(nolock)
				where a.C1730 not in (	select b.C6326 
										from PLANCTAS b with(nolock))
				)	
				select    ''Tabla SALDOS no se ajusta a la integridad referencial con PLANCTAS '',*
				from SALDOS a with(nolock)
				where a.C1730 not in (	select b.C6326 
										from PLANCTAS b with(nolock))
	else
	print ''Comprobación OK.Tabla SALDOS con PLANCTAS ''

	if exists (	select a.saldos_jts_oid 
				from GRL_SALDOS_DIARIOS a with(nolock)
				where a.saldos_jts_oid  not in (select b.JTS_OID
										from saldos b with(nolock))
				)	
				select     ''Tabla GRL_SALDOS_DIARIOS no se ajusta a la integridad referencial con saldos '',*
				from GRL_SALDOS_DIARIOS a with(nolock)
				where a.saldos_jts_oid not in (select b.JTS_OID 
										from saldos b with(nolock))
	else
	print ''Comprobación OK. Tabla GRL_SALDOS_DIARIOS con saldos ''

/*	if exists (	select a.ASIENTO 
				from ASIENTOS a with(nolock)
				where a.ASIENTO not in (select b.ASIENTO 
										from MOVIMIENTOS_CONTABLES b with(nolock))
			)	
				SELECT    ''Tabla ASIENTOS no se ajusta a la integridad referencial con MOVIMIENTOS_CONTABLES '',*
				from ASIENTOS a with(nolock)
				where a.ASIENTO not in (select b.ASIENTO 
										from MOVIMIENTOS_CONTABLES b with(nolock))
	else
	print ''Comprobación OK.Tabla ASIENTOS con MOVIMIENTOS_CONTABLES ''*/ ---Eliminar

	if exists (	select a.SUCURSAL 
				from SALDOS a with(nolock)
				where a.SUCURSAL not in (	select b.SUCURSAL 
											from SUCURSALES b with(nolock))
			)	
			select   ''Tabla SALDOS no se ajusta a la integridad referencial con SUCURSALES '',*
			from SALDOS a with(nolock)
			where a.SUCURSAL not in (	select b.SUCURSAL 
										from SUCURSALES b with(nolock))
	else
	print ''Comprobación OK.Tabla SALDOS con SUCURSALES ''

	if exists (	select a.ASIENTO 
				from MOVIMIENTOS_CONTABLES a with(nolock)
				where a.ASIENTO not in (select b.ASIENTO 
										from ASIENTOS b with(nolock))
				)	
				select    ''Tabla MOVIMIENTOS_CONTABLES no se ajusta a la integridad referencial con ASIENTOS '',*
				from MOVIMIENTOS_CONTABLES a with(nolock)
				where a.ASIENTO not in (select b.ASIENTO 
										from ASIENTOS b with(nolock))
	else
	print ''Comprobación OK. Tabla MOVIMIENTOS_CONTABLES con ASIENTOS ''


/*	if exists (	select a.ASIENTO 
				from asientos a with(nolock)
				where a.asiento not in (select b.asiento 
										from MOVIMIENTOS b with(nolock)) 
			)	
				SELECT   ''Tabla asientos no se ajusta a la integridad referencial con MOVIMIENTOS '',*
				from asientos a with(nolock)
				where a.asiento not in (select b.asiento 
										from MOVIMIENTOS b with(nolock)) 
	else
	print ''Comprobación OK.Tabla asientos con MOVIMIENTOS ''*/ ---Eliminar


	if exists (	select a.jts_oid_saldos
				from CON_CV_REMUNERADA a with(nolock)
				where a.jts_oid_saldos  not in (select b.JTS_OID
										from saldos b with(nolock))
				)	
				select     ''Tabla CON_CV_REMUNERADA no se ajusta a la integridad referencial con saldos '',*
				from CON_CV_REMUNERADA a with(nolock)
				where a.jts_oid_saldos  not in (select b.JTS_OID
										from saldos b with(nolock))
	else
	print ''Comprobación OK. Tabla CON_CV_REMUNERADA con saldos ''


		if exists (	select a.jtSoid
				from CON_CREDITO_DIVERSO a with(nolock)
				where a.jtSoid  not in (select b.JTS_OID
										from saldos b with(nolock))
				)	
				select     ''Tabla CON_CREDITO_DIVERSO no se ajusta a la integridad referencial con saldos '',*
				from CON_CREDITO_DIVERSO a with(nolock)
				where a.jtsoid  not in (select b.JTS_OID
										from saldos b with(nolock))
	else
	print ''Comprobación OK. Tabla CON_CREDITO_DIVERSO con saldos ''


/*		if exists (	select a.jtSoid
				from CON_CREDITO_DIVERSO a with(nolock)
				where a.jtSoid  not in (select b.JTS_OID
										from saldos b with(nolock))
				)	
				select     ''Tabla CON_CREDITO_DIVERSO no se ajusta a la integridad referencial con saldos '',*
				from CON_CREDITO_DIVERSO a with(nolock)
				where a.jtsoid  not in (select b.JTS_OID
										from saldos b with(nolock))
	else
	print ''Comprobación OK. Tabla CON_CREDITO_DIVERSO con saldos ''*/ ---Eliminar

		if exists (	select a.jtSoid
				from CON_SALDOS_INVENTARIADO a with(nolock)
				where a.jtSoid  not in (select b.JTS_OID
										from saldos b with(nolock))
				)	
				select     ''Tabla CON_SALDOS_INVENTARIADO no se ajusta a la integridad referencial con saldos '',*
				from CON_SALDOS_INVENTARIADO a with(nolock)
				where a.jtsoid  not in (select b.JTS_OID
										from saldos b with(nolock))
	else
	print ''Comprobación OK. Tabla CON_SALDOS_INVENTARIADO con saldos ''

	if exists (	select a.MONEDA
				from SALDOS a with(nolock)
				where a.MONEDA  not in (select b.C6399
										from MONEDAS b with(nolock))
				)	
				select     ''Tabla SALDOS no se ajusta a la integridad referencial con MONEDAS '',*
				from SALDOS a with(nolock)
				where a.MONEDA  not in (select b.C6399
										from MONEDAS b with(nolock))
	else
	print ''Comprobación OK. Tabla SALDOS con MONEDAS ''


		if exists (	select a.PRODUCTO
				from SALDOS a with(nolock)
				where a.PRODUCTO  not in (select b.C6250
										from PRODUCTOS b with(nolock))
				)	
				select     ''Tabla SALDOS no se ajusta a la integridad referencial con PRODUCTOS '',*
				from SALDOS a with(nolock)
				where a.PRODUCTO  not in (select b.C6250
										from PRODUCTOS b with(nolock))
	else
	print ''Comprobación OK. Tabla SALDOS con PRODUCTOS ''

	if exists (	select a.RUBRO_ORIGEN
			from CON_RUBRO_CONTABLE_ORIG_DEST_ME a with(nolock)
			where a.RUBRO_ORIGEN  not in (select b.C6301
									from PLANCTAS b with(nolock))
			)	
			select     ''Tabla CON_RUBRO_CONTABLE_ORIG_DEST_ME no se ajusta a la integridad referencial con PLANCTAS '',*
			from CON_RUBRO_CONTABLE_ORIG_DEST_ME a with(nolock)
			where a.RUBRO_ORIGEN  not in (select b.C6301
									from PLANCTAS b with(nolock))
	else
	print ''Comprobación OK. Tabla CON_RUBRO_CONTABLE_ORIG_DEST_ME con PLANCTAS ''

	if exists (	select a.SALDO_JTS_OID
			from CON_HISTORICO_UVA_UVI a with(nolock)
			where a.SALDO_JTS_OID  not in (select b.SALDO_JTS_OID
									from CON_PROCESADO_UVA_UVI b with(nolock))
			)	
			select     ''Tabla CON_HISTORICO_UVA_UVI no se ajusta a la integridad referencial con CON_PROCESADO_UVA_UVI '',*
			from CON_HISTORICO_UVA_UVI a with(nolock)
			where a.SALDO_JTS_OID  not in (select b.SALDO_JTS_OID
									from CON_PROCESADO_UVA_UVI b with(nolock))
	else
	print ''Comprobación OK. Tabla CON_HISTORICO_UVA_UVI con CON_PROCESADO_UVA_UVI ''

	if exists (	select a.SALDO_JTS_OID
			from CON_DETALLES_UVA_UVI a with(nolock)
			where a.SALDO_JTS_OID  not in (select b.SALDO_JTS_OID
									from CON_PROCESADO_UVA_UVI b with(nolock))
			)	
			select     ''Tabla CON_DETALLES_UVA_UVI no se ajusta a la integridad referencial con CON_PROCESADO_UVA_UVI '',*
			from CON_DETALLES_UVA_UVI a with(nolock)
			where a.SALDO_JTS_OID  not in (select b.SALDO_JTS_OID
									from CON_PROCESADO_UVA_UVI b with(nolock))
	else
	print ''Comprobación OK. Tabla CON_DETALLES_UVA_UVI con CON_PROCESADO_UVA_UVI ''

	if exists (	select a.IDENT_ASIENTO
			from CON_ASTOS_TIPODETALLE a with(nolock)
			where a.IDENT_ASIENTO  not in (select b.ID_ASIENTO
									from CON_ASIENTOS_TIPO b with(nolock))
			)	
			select     ''Tabla CON_ASTOS_TIPODETALLE no se ajusta a la integridad referencial con CON_ASIENTOS_TIPO '',*
			from CON_ASTOS_TIPODETALLE a with(nolock)
			where a.IDENT_ASIENTO  not in (select b.ID_ASIENTO
									from CON_ASIENTOS_TIPO b with(nolock))
	else
	print ''Comprobación OK. Tabla CON_ASTOS_TIPODETALLE con CON_ASIENTOS_TIPO ''

	if exists (	select a.ASIENTO
			from ASIENTOS_A_EXTORNAR a with(nolock)
			where a.asiento  not in (select b.ASIENTO
									from asientos b with(nolock))
			)	
			select     ''Tabla ASIENTOS_A_EXTORNAR no se ajusta a la integridad referencial con ASIENTO '',*
			from ASIENTOS_A_EXTORNAR a with(nolock)
			where a.asiento  not in (select b.ASIENTO
									from asientos b with(nolock))
	else
	print ''Comprobación OK. Tabla ASIENTOS_A_EXTORNAR con ASIENTO ''


	if exists (	select a.ORIGEN
			from BANDEJA_ASIENTOS_IN a with(nolock)
			where a.ORIGEN  not in (select b.ORIGEN
									from BANDEJA_ORIGENES b with(nolock))
			)	
			select     ''Tabla BANDEJA_ASIENTOS_IN no se ajusta a la integridad referencial con BANDEJA_ORIGENES '',*
			from BANDEJA_ASIENTOS_IN a with(nolock)
			where a.ORIGEN  not in (select b.ORIGEN
									from BANDEJA_ORIGENES b with(nolock))
	else
	print ''Comprobación OK. Tabla BANDEJA_ASIENTOS_IN con BANDEJA_ORIGENES ''

	
	if exists (	select a.ID_BCE
			from CO_BALANCE_ESTRUCTURA a with(nolock)
			where a.ID_BCE  not in (select b.ID_BCE
									from CO_NIVELES_BALANCE b with(nolock))
			)	
			select     ''Tabla CO_BALANCE_ESTRUCTURA no se ajusta a la integridad referencial con CO_NIVELES_BALANCE '',*
			from CO_BALANCE_ESTRUCTURA a with(nolock)
			where a.ID_BCE  not in (select b.ID_BCE
									from CO_NIVELES_BALANCE b with(nolock))
	else
	print ''Comprobación OK. Tabla CO_BALANCE_ESTRUCTURA con CO_NIVELES_BALANCE ''

	if exists (	select a.ID_ASIENTO
			from CON_ASIENTOS_TIPO a with(nolock)
			where a.ID_ASIENTO  not in (select b.ASIENTO
									from ASIENTOS b with(nolock))
			)	
			select     ''Tabla CON_ASIENTOS_TIPO no se ajusta a la integridad referencial con ASIENTOS '',*
			from CON_ASIENTOS_TIPO a with(nolock)
			where a.ID_ASIENTO  not in (select b.ASIENTO
									from ASIENTOS b with(nolock))
	else
	print ''Comprobación OK. Tabla CON_ASIENTOS_TIPO con ASIENTOS ''

	if exists (	select a.ASIENTO
			from CON_ASIENTOS_EXTORNADOS a with(nolock)
			where a.ASIENTO  not in (select b.ASIENTO
									from ASIENTOS b with(nolock))
			)	
			select     ''Tabla CON_ASIENTOS_EXTORNADOS no se ajusta a la integridad referencial con ASIENTOS '',*
			from CON_ASIENTOS_EXTORNADOS a with(nolock)
			where a.ASIENTO  not in (select b.ASIENTO
									from ASIENTOS b with(nolock))
	else
	print ''Comprobación OK. Tabla CON_ASIENTOS_EXTORNADOS con ASIENTOS ''

	if exists (	select a.ASIENTO
			from CON_DETALLES_UVA_UVI a with(nolock)
			where a.ASIENTO  not in (select b.ASIENTO
									from ASIENTOS b with(nolock))
			)	
			select     ''Tabla CON_DETALLES_UVA_UVI no se ajusta a la integridad referencial con ASIENTOS '',*
			from CON_DETALLES_UVA_UVI a with(nolock)
			where a.ASIENTO  not in (select b.ASIENTO
									from ASIENTOS b with(nolock))
	else
	print ''Comprobación OK. Tabla CON_DETALLES_UVA_UVI con ASIENTOS ''

	if exists (	select a.ASIENTO
			from MOVIMIENTOS a with(nolock)
			left join MOVIMIENTOS_CONTABLES b with(nolock) on
			a.sucursal = b.sucursal
			and a.fechaproceso = b.fechaproceso
			and a.tipo = b.tipo
			and a.ordinal = b.ordinal
			and a.trreal = b.trreal
			and a.asiento = b.asiento
			where 
			a.sucursal is null
			and a.fechaproceso  is null
			and a.tipo  is null
			and a.ordinal  is null
			and a.trreal  is null
			and a.asiento is null)

			select ''Tabla MOVIMIENTOS no se ajusta a la integridad referencial con MOVIMIENTOS_CONTABLES '',*
			from MOVIMIENTOS a with(nolock)
			left join MOVIMIENTOS_CONTABLES b with(nolock) on
			a.sucursal = b.sucursal
			and a.fechaproceso = b.fechaproceso
			and a.tipo = b.tipo
			and a.ordinal = b.ordinal
			and a.trreal = b.trreal
			and a.asiento = b.asiento
			where 
			a.sucursal is null
			and a.fechaproceso  is null
			and a.tipo  is null
			and a.ordinal  is null
			and a.trreal  is null
			and a.asiento is null
	else
	print ''Comprobación OK. Tabla MOVIMIENTOS con MOVIMIENTOS_CONTABLES ''

	if exists (	select a.ASIENTO
			from MOVIMIENTOS_A_REAPLICAR a with(nolock)
			left join MOVIMIENTOS_CONTABLES b with(nolock) on
			a.sucursal = b.sucursal
			and a.fechaproceso = b.fechaproceso
			and a.TRTIPO = b.TRTIPO
			and a.ordinal = b.ordinal
			and a.trreal = b.trreal
			and a.asiento = b.asiento
			and a.SUCURSAL = b.SUCURSAL
			and a.trvirtual = b.TRVIRTUAL
			where 
			a.sucursal is null
			and a.fechaproceso  is null
			and a.TRTIPO  is null
			and a.ordinal  is null
			and a.trreal  is null
			and a.asiento is null
			and a.SUCURSAL is null
			and a.trvirtual  is null)

			select ''Tabla MOVIMIENTOS_A_REAPLICAR no se ajusta a la integridad referencial con MOVIMIENTOS_CONTABLES '',*
			from MOVIMIENTOS a with(nolock)
			left join MOVIMIENTOS_CONTABLES b with(nolock) on
			a.sucursal = b.sucursal
			and a.fechaproceso = b.fechaproceso
			and a.tipo = b.tipo
			and a.ordinal = b.ordinal
			and a.trreal = b.trreal
			and a.asiento = b.asiento
			where 
			a.sucursal is null
			and a.fechaproceso  is null
			and a.tipo  is null
			and a.ordinal  is null
			and a.trreal  is null
			and a.asiento is null
	else
	print ''Comprobación OK. Tabla MOVIMIENTOS_A_REAPLICAR con MOVIMIENTOS_CONTABLES ''

		if exists (	select a.ASIENTO
			from MOVIMIENTOS_SUMARIZADOS a with(nolock)
			left join MOVIMIENTOS_CONTABLES b with(nolock) on
				a.[FECHAPROCESO]= b.[FECHAPROCESO]
				and a.[SUCURSAL]= b.[SUCURSAL]
				and a.[ASIENTO]= b.[ASIENTO]
				and a.[SUB_ASIENTO]= b.[SUB_ASIENTO]
				and a.[TRREAL]= b.[TRREAL]
				and a.[ORDINAL]= b.[ORDINAL]
			where 
				a.[FECHAPROCESO] is null
				and a.[SUCURSAL]  is null
				and a.[ASIENTO]  is null
				and a.[SUB_ASIENTO]  is null
				and a.[TRREAL]  is null
				and a.[ORDINAL]  is null)

			select ''Tabla MOVIMIENTOS_SUMARIZADOS no se ajusta a la integridad referencial con MOVIMIENTOS_CONTABLES '',*
			from MOVIMIENTOS_SUMARIZADOS a with(nolock)
			left join MOVIMIENTOS_CONTABLES b with(nolock) on
				a.[FECHAPROCESO]= b.[FECHAPROCESO]
				and a.[SUCURSAL]= b.[SUCURSAL]
				and a.[ASIENTO]= b.[ASIENTO]
				and a.[SUB_ASIENTO]= b.[SUB_ASIENTO]
				and a.[TRREAL]= b.[TRREAL]
				and a.[ORDINAL]= b.[ORDINAL]
			where 
				a.[FECHAPROCESO] is null
				and a.[SUCURSAL]  is null
				and a.[ASIENTO]  is null
				and a.[SUB_ASIENTO]  is null
				and a.[TRREAL]  is null
				and a.[ORDINAL]  is null
	else
	print ''Comprobación OK. Tabla MOVIMIENTOS_SUMARIZADOS con MOVIMIENTOS_CONTABLES ''

	if exists (	select a.mov_asiento
				from GRL_DETALLE_CONTABILIDAD a with(nolock)
				left join MOVIMIENTOS_CONTABLES b with(nolock) on
					a.mov_asiento = b.[ASIENTO]
					and a.mov_fecha_proceso =b.[FECHAPROCESO]
					and a.mov_sucursal = b.[SUCURSAL]
					and a.mov_trreal = b.[TRREAL]
					and a.mov_ordinal = b.[ORDINAL]
					and a.mov_tipo = b.TIPO
				where 
					a.mov_fecha_proceso is null
					and a.mov_sucursal  is null
					and a.mov_trreal  is null
					and a.mov_ordinal  is null
					and a.mov_tipo  is null
					and a.mov_asiento  is null)
		select ''Tabla GRL_DETALLE_CONTABILIDAD no se ajusta a la integridad referencial con MOVIMIENTOS_CONTABLES '',*
		from GRL_DETALLE_CONTABILIDAD a with(nolock)
		left join MOVIMIENTOS_CONTABLES b with(nolock) on
				a.mov_asiento = b.[ASIENTO]
				and a.mov_fecha_proceso =b.[FECHAPROCESO]
				and a.mov_sucursal = b.[SUCURSAL]
				and a.mov_trreal = b.[TRREAL]
				and a.mov_ordinal = b.[ORDINAL]
				and a.mov_tipo = b.TIPO
		where 
			a.mov_fecha_proceso is null
			and a.mov_sucursal  is null
			and a.mov_trreal  is null
			and a.mov_ordinal  is null
			and a.mov_tipo  is null
			and a.mov_asiento  is null
	else
	print ''Comprobación OK. Tabla GRL_DETALLE_CONTABILIDAD con MOVIMIENTOS_CONTABLES ''

	if exists (	select a.asiento
				from CON_MOVIMIENTOS_IMPUESTOS_ME a with(nolock)
				left join MOVIMIENTOS_CONTABLES b with(nolock) on
					a.asiento = b.[ASIENTO]
					and a.fechaproceso =b.[FECHAPROCESO]
					and a.sucursal = b.[SUCURSAL]
					and a.trreal = b.[TRREAL]
					and a.ordinal = b.[ORDINAL]
					and a.TRTIPO = b.TIPO
					and a.TRVIRTUAL = b.TRVIRTUAL
				where 
					a.fechaproceso is null
					and a.sucursal  is null
					and a.trreal  is null
					and a.ordinal  is null
					and a.TRTIPO  is null
					and a.asiento  is null
					and a.trvirtual is null)
		select ''Tabla CON_MOVIMIENTOS_IMPUESTOS_ME no se ajusta a la integridad referencial con MOVIMIENTOS_CONTABLES '',*
				from CON_MOVIMIENTOS_IMPUESTOS_ME a with(nolock)
				left join MOVIMIENTOS_CONTABLES b with(nolock) on
					a.asiento = b.[ASIENTO]
					and a.fechaproceso =b.[FECHAPROCESO]
					and a.sucursal = b.[SUCURSAL]
					and a.trreal = b.[TRREAL]
					and a.ordinal = b.[ORDINAL]
					and a.TRTIPO = b.TIPO
					and a.TRVIRTUAL = b.TRVIRTUAL
				where 
					a.fechaproceso is null
					and a.sucursal  is null
					and a.trreal  is null
					and a.ordinal  is null
					and a.TRTIPO  is null
					and a.asiento  is null
					and a.trvirtual is null
			else
		print ''Comprobación OK. Tabla CON_MOVIMIENTOS_IMPUESTOS_ME con MOVIMIENTOS_CONTABLES ''

	if exists (	select a.tipo_cargo_impositivo
				from CON_CERTIFICADOS_RETENCION a with(nolock)
				left join CON_REGIMEN_CERTIF_RET b with(nolock) on
					a.tipo_cargo_impositivo = b.tipo_cargo_impositivo
					and a.codigo_regimen =b.codigo_regimen
				where 
					a.tipo_cargo_impositivo is null
					and a.codigo_regimen  is null)
		select ''Tabla CON_CERTIFICADOS_RETENCION no se ajusta a la integridad referencial con CON_REGIMEN_CERTIF_RET '',*
				from CON_CERTIFICADOS_RETENCION a with(nolock)
				left join CON_REGIMEN_CERTIF_RET b with(nolock) on
					a.tipo_cargo_impositivo = b.tipo_cargo_impositivo
					and a.codigo_regimen =b.codigo_regimen
				where 
					a.tipo_cargo_impositivo is null
					and a.codigo_regimen  is null
			else
		print ''Comprobación OK. Tabla CON_CERTIFICADOS_RETENCION con CON_REGIMEN_CERTIF_RET ''

	if exists (	select a.ordinal
				from CO_BALANCE_ESTRUCTURA a with(nolock)
				left join CO_BALANCE_IMPRESION b with(nolock) on
					a.id_bce = b.id_bce
					and a.codigo_interno =b.codigo_interno
				where 
					a.id_bce is null
					and a.codigo_interno  is null )
		select ''Tabla CO_BALANCE_ESTRUCTURA no se ajusta a la integridad referencial con CO_BALANCE_IMPRESION '',*
				from CO_BALANCE_ESTRUCTURA a with(nolock)
				left join CO_BALANCE_IMPRESION b with(nolock) on
					a.id_bce = b.id_bce
					and a.codigo_interno =b.codigo_interno
				where 
					a.id_bce is null
					and a.codigo_interno  is null
			else
		print ''Comprobación OK. Tabla CO_BALANCE_ESTRUCTURA con CO_BALANCE_IMPRESION ''


	if exists (	select a.RUBRO_CONTABLE
			from CO_BALANCE_ESTRUCTURA a with(nolock)
			where a.RUBRO_CONTABLE  not in (select b.C6301
									from PLANCTAS b with(nolock))
			)	
			select     ''Tabla CO_BALANCE_ESTRUCTURA no se ajusta a la integridad referencial con PLANCTAS '',*
			from CO_BALANCE_ESTRUCTURA a with(nolock)
			where a.RUBRO_CONTABLE  not in (select b.C6301
									from PLANCTAS b with(nolock))
	else
	print ''Comprobación OK. Tabla CO_BALANCE_ESTRUCTURA con PLANCTAS ''

	END
ELSE
	print ''NO CORRESPONDE LA BASE DE DATOS''
END

IF  NOT EXISTS (SELECT * FROM sys.indexes where name = ''PK_MOVIMIENTOS_SUMARIZADOS'')
	ALTER TABLE [dbo].[MOVIMIENTOS_SUMARIZADOS] ADD  CONSTRAINT [PK_MOVIMIENTOS_SUMARIZADOS] PRIMARY KEY CLUSTERED 
	(
		[FECHAPROCESO] ASC,
		[SUCURSAL] ASC,
		[ASIENTO] ASC,
		[SUB_ASIENTO] ASC,
		[TRREAL] ASC,
		[ORDINAL] ASC
	)ON [PRIMARY]
;')
