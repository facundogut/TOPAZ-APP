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

	if exists (	select a.ASIENTO 
				from ASIENTOS a with(nolock)
				where a.ASIENTO not in (select b.ASIENTO 
										from MOVIMIENTOS_CONTABLES b with(nolock))
			)	
				SELECT    ''Tabla ASIENTOS no se ajusta a la integridad referencial con MOVIMIENTOS_CONTABLES '',*
				from ASIENTOS a with(nolock)
				where a.ASIENTO not in (select b.ASIENTO 
										from MOVIMIENTOS_CONTABLES b with(nolock))
	else
	print ''Comprobación OK.Tabla ASIENTOS con MOVIMIENTOS_CONTABLES ''	

	
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


	if exists (	select a.ASIENTO 
				from asientos a with(nolock)
				where a.asiento not in (select b.asiento 
										from MOVIMIENTOS b with(nolock)) 
			)	
				SELECT   ''Tabla asientos no se ajusta a la integridad referencial con MOVIMIENTOS '',*
				from asientos a with(nolock)
				where a.asiento not in (select b.asiento 
										from MOVIMIENTOS b with(nolock)) 
	else
	print ''Comprobación OK.Tabla asientos con MOVIMIENTOS ''


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

	SELECT * FROM CON_CREDITO_DIVERSO
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

	END
ELSE
	print ''NO CORRESPONDE LA BASE DE DATOS''
END
;')