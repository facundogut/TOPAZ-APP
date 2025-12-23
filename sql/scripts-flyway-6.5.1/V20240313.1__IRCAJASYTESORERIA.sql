execute('
----------------------------------------PASIVAS.-----------------------------------------------------------
--exec [dbo].[SP_INTEGRIDAD_REFERENCIAL_CAJASYTESORERIA] NBCH_tunning

CREATE OR ALTER  procedure [dbo].[SP_INTEGRIDAD_REFERENCIAL_CAJASYTESORERIA] 
						@BD varchar(20)
as
BEGIN
IF (SELECT DB_NAME()) = @BD
  BEGIN
	print ''-------------CAJA Y TESORERIA------------''
	print ''-----------------------------------------''
	---------------------------------------------------------------------------------------------------
    ----------------------------------CAJA Y TESORERIA----------------------------------------------
	---------------------------------------------------------------------------------------------------
----------------------------------------1
	if exists (	select a.CATEGORIA 
				from TABLA_ATM a with(nolock) 
				where a.CATEGORIA not in(	select b.CATEGORIA 
												from CAJ_ATM_CATEGORIAS B with(nolock))
			  )	
				SELECT    ''Tabla TABLA_ATM no se ajusta a la integridad referencial con CAJ_ATM_CATEGORIAS '',*
				from TABLA_ATM a with(nolock) 
				where a.CATEGORIA not in(	select b.CATEGORIA 
												from CAJ_ATM_CATEGORIAS B with(nolock))
	else
	print ''Comprobación OK.Tabla TABLA_ATM  con CAJ_ATM_CATEGORIAS ''

----------------------------------------2
	if exists (	select a.NRO_ATM 
				from TABLA_ATM a with(nolock) 
				where a.NRO_ATM not in(	select b.nro_atm 
												from SALDOSATM B with(nolock))
			  )	
				SELECT    ''Tabla TABLA_ATM no se ajusta a la integridad referencial con SALDOSATM '',*
				from TABLA_ATM a with(nolock) 
				where a.NRO_ATM not in(	select b.nro_atm 
												from SALDOSATM B with(nolock))
	else
	print ''Comprobación OK.Tabla TABLA_ATM  con SALDOSATM ''
----------------------------------------3
	if exists (	select a.NRO_ATM 
				from SALDOSATM_HISTORICO a with(nolock) 
				where a.NRO_ATM not in(	select b.nro_atm 
												from SALDOSATM B with(nolock))
			  )	
				SELECT    ''Tabla SALDOSATM_HISTORICO no se ajusta a la integridad referencial con SALDOSATM '',*
				from SALDOSATM_HISTORICO a with(nolock) 
				where a.NRO_ATM not in(	select b.nro_atm 
												from SALDOSATM B with(nolock))
	else
	print ''Comprobación OK.Tabla SALDOSATM_HISTORICO  con SALDOSATM ''
----------------------------------------4
	if exists (	select a.moneda 
				from SALDOSATM a with(nolock) 
				where a.MONEDA not in(	select b.C6399 
												from MONEDAS B with(nolock))
			  )	
				SELECT    ''Tabla SALDOSATM no se ajusta a la integridad referencial con MONEDAS '',*
				from SALDOSATM a with(nolock) 
				where a.MONEDA not in(	select b.C6399 
												from MONEDAS B with(nolock))
	else
	print ''Comprobación OK.Tabla SALDOSATM  con MONEDAS ''
----------------------------------------5
	if exists (	select a.usuario 
				from CAJ_SOLICITUD_BAJA_ASIENTO a with(nolock) 
				where a.USUARIO not in(	select b.clave 
												from USUARIOS B with(nolock))
			  )	
				SELECT    ''Tabla CAJ_SOLICITUD_BAJA_ASIENTO no se ajusta a la integridad referencial con USUARIOS '',*
				from CAJ_SOLICITUD_BAJA_ASIENTO a with(nolock) 
				where a.USUARIO not in(	select b.clave 
												from USUARIOS B with(nolock))
	else
	print ''Comprobación OK.Tabla CAJ_SOLICITUD_BAJA_ASIENTO  con USUARIOS ''

----------------------------------------6
	if exists (	select a.NROSUCURSAL 
				from USUARIOS a with(nolock) 
				where a.NROSUCURSAL not in(	select b.SUCURSAL 
												from SUCURSALES B with(nolock))
			  )	
				SELECT    ''Tabla USUARIOS no se ajusta a la integridad referencial con SUCURSALES '',*
				from USUARIOS a with(nolock) 
				where a.NROSUCURSAL not in(	select b.SUCURSAL 
												from SUCURSALES B with(nolock))
	else
	print ''Comprobación OK.Tabla USUARIOS  con SUCURSALES ''

----------------------------------------7
	if exists (	select a.nrosucursal , a.numerodemaquina, a.CLAVE
				from USUARIOS a with(nolock) 
				left join NETMAP B with(nolock) on a.nrosucursal  = b.nrosucursal 
													and a.numerodemaquina = b.numerodemaquina
				where b.nrosucursal is null
				or	b.numerodemaquina is null
			  )	
				SELECT  ''Tabla USUARIOS no se ajusta a la integridad referencial con NETMAP '',*
				from USUARIOS a with(nolock) 
				left join NETMAP B with(nolock) on a.nrosucursal  = b.nrosucursal 
													and a.numerodemaquina = b.numerodemaquina
				where b.nrosucursal is null
				or	b.numerodemaquina is null
	else
	print ''Comprobación OK.Tabla USUARIOS con NETMAP ''

----------------------------------------6
	if exists (	select a.ASIENTO 
				from CAJ_SOLICITUD_BAJA_ASIENTO a with(nolock) 
				where a.ASIENTO not in(	select b.ASIENTO 
												from ASIENTOS B with(nolock))
			  )	
				SELECT    ''Tabla CAJ_SOLICITUD_BAJA_ASIENTO no se ajusta a la integridad referencial con ASIENTOS '',*
				from CAJ_SOLICITUD_BAJA_ASIENTO a with(nolock) 
				where a.ASIENTO not in(	select b.ASIENTO 
												from ASIENTOS B with(nolock))
	else
	print ''Comprobación OK.Tabla CAJ_SOLICITUD_BAJA_ASIENTO  con ASIENTOS ''
----------------------------------------8
	if exists (	select a.ASIENTO 
				from CAJ_HISTORIAL_BILLETAJE a with(nolock) 
				where a.ASIENTO not in(	select b.ASIENTO 
												from ASIENTOS B with(nolock))
			  )	
				SELECT    ''Tabla CAJ_HISTORIAL_BILLETAJE no se ajusta a la integridad referencial con ASIENTOS '',*
				from CAJ_HISTORIAL_BILLETAJE a with(nolock) 
				where a.ASIENTO not in(	select b.ASIENTO 
												from ASIENTOS B with(nolock))
	else
	print ''Comprobación OK.Tabla CAJ_HISTORIAL_BILLETAJE con ASIENTOS ''
----------------------------------------9
	if exists (	select a.CONCEPTO_CONTABLE 
				from CAJ_FALLA_CAJA a with(nolock) 
				where a.CONCEPTO_CONTABLE not in(	select b.c6500 
												from CONCEPCONT B with(nolock))
			  )	
				SELECT    ''Tabla CAJ_FALLA_CAJA no se ajusta a la integridad referencial con CONCEPCONT '',*
				from CAJ_FALLA_CAJA a with(nolock) 
				where a.CONCEPTO_CONTABLE not in(	select b.c6500 
												from CONCEPCONT B with(nolock))
	else
	print ''Comprobación OK.Tabla CAJ_FALLA_CAJA  con CONCEPCONT ''

----------------------------------------10
	if exists (	select a.NRO_SOLICITUD 
				from REM_DENOMINACIONREMESA a with(nolock) 
				where a.NRO_SOLICITUD not in(	select b.NRO_SOLICITUD 
												from REM_SOLICITUDREMESA B with(nolock))
			  )	
				SELECT    ''Tabla REM_DENOMINACIONREMESA no se ajusta a la integridad referencial con REM_SOLICITUDREMESA '',*
				from REM_DENOMINACIONREMESA a with(nolock) 
				where a.NRO_SOLICITUD not in(	select b.NRO_SOLICITUD 
												from REM_SOLICITUDREMESA B with(nolock))
	else
	print ''Comprobación OK.Tabla REM_DENOMINACIONREMESA  con REM_SOLICITUDREMESA ''
----------------------------------------11
	if exists (	select a.SUCURSAL 
				from REM_SOLICITUDREMESA a with(nolock) 
				where a.SUCURSAL not in(	select b.SUCURSAL 
												from sucursales B with(nolock))
			  )	
				SELECT    ''Tabla REM_SOLICITUDREMESA no se ajusta a la integridad referencial con sucursales '',*
				from REM_SOLICITUDREMESA a with(nolock) 
				where a.SUCURSAL not in(	select b.SUCURSAL 
												from sucursales B with(nolock))
	else
	print ''Comprobación OK.Tabla REM_SOLICITUDREMESA  con sucursales ''
----------------------------------------12
	if exists (	select a.NRO_SOLICITUD 
				from REM_REMESA a with(nolock) 
				where a.NRO_SOLICITUD not in(	select b.NRO_SOLICITUD
												from REM_SOLICITUDREMESA B with(nolock))
			  )	
				SELECT    ''Tabla REM_REMESA no se ajusta a la integridad referencial con REM_SOLICITUDREMESA '',*
				from REM_REMESA a with(nolock) 
				where a.NRO_SOLICITUD not in(	select b.NRO_SOLICITUD
												from REM_SOLICITUDREMESA B with(nolock))
	else
	print ''Comprobación OK.Tabla REM_REMESA con REM_SOLICITUDREMESA ''
----------------------------------------13
----------------------------------------14
	if exists (	select a.SUCURSAL 
				from TABLA_CAJAS a with(nolock) 
				where a.SUCURSAL not in(	select b.SUCURSAL
												from SUCURSALES B with(nolock))
			  )	
				SELECT    ''Tabla TABLA_CAJAS no se ajusta a la integridad referencial con SUCURSALES '',*
				from TABLA_CAJAS a with(nolock) 
				where a.SUCURSAL not in(	select b.SUCURSAL
												from SUCURSALES B with(nolock))
	else
	print ''Comprobación OK.Tabla TABLA_CAJAS  con SUCURSALES ''
----------------------------------------15
	if exists (	select a.SUCURSAL 
				from CAJ_NIVEL_CAJA a with(nolock) 
				where a.SUCURSAL not in(	select b.SUCURSAL
												from SUCURSALES B with(nolock))
			  )	
				SELECT    ''Tabla CAJ_NIVEL_CAJA no se ajusta a la integridad referencial con SUCURSALES '',*
				from CAJ_NIVEL_CAJA a with(nolock) 
				where a.SUCURSAL not in(	select b.SUCURSAL
												from SUCURSALES B with(nolock))
	else
	print ''Comprobación OK.Tabla CAJ_NIVEL_CAJA  con SUCURSALES ''
----------------------------------------16
	if exists (	select a.CAJA 
				from CAJ_NIVEL_CAJA a with(nolock) 
				where a.CAJA not in(	select b.NRO_CAJA
												from TABLA_CAJAS B with(nolock))
			  )	
				SELECT    ''Tabla CAJ_NIVEL_CAJA no se ajusta a la integridad referencial con TABLA_CAJAS '',*
				from CAJ_NIVEL_CAJA a with(nolock) 
				where a.CAJA not in(	select b.NRO_CAJA
												from TABLA_CAJAS B with(nolock))
	else
	print ''Comprobación OK.Tabla CAJ_NIVEL_CAJA  con TABLA_CAJAS ''
----------------------------------------17
	if exists (	select a.SUCURSAL 
				from CAJ_MiniFiliales a with(nolock) 
				where a.Sucursal not in(	select b.SUCURSAL
												from SUCURSALES B with(nolock))
			  )	
				SELECT    ''Tabla CAJ_MiniFiliales no se ajusta a la integridad referencial con SUCURSALES '',*
				from CAJ_MiniFiliales a with(nolock) 
				where a.Sucursal not in(	select b.SUCURSAL
												from SUCURSALES B with(nolock))
	else
	print ''Comprobación OK.Tabla CAJ_MiniFiliales  con SUCURSALES ''

----------------------------------------18
	if exists (	select a.Mini_Filial 
				from CAJ_Cajas_MiniFiliales a with(nolock) 
				where a.Mini_Filial not in(	select b.Mini_Filial
												from CAJ_MiniFiliales B with(nolock))
			  )	
				SELECT    ''Tabla CAJ_Cajas_MiniFiliales no se ajusta a la integridad referencial con CAJ_MiniFiliales '',*
				from CAJ_Cajas_MiniFiliales a with(nolock) 
				where a.Mini_Filial not in(	select b.Mini_Filial
												from CAJ_MiniFiliales B with(nolock))
	else
	print ''Comprobación OK.Tabla CAJ_Cajas_MiniFiliales  con CAJ_MiniFiliales ''
----------------------------------------19
	if exists (	select a.sucursal 
				from SALDOSCAJA a with(nolock) 
				left join TABLA_CAJAS B with(nolock) on a.nrocaja= b.nro_caja
														and a.sucursal = b.sucursal
				where b.nro_caja is null
				and b.sucursal is null
			  )	
				SELECT    ''Tabla SALDOSCAJA no se ajusta a la integridad referencial con TABLA_CAJAS '',*
				from SALDOSCAJA a with(nolock) 
				left join TABLA_CAJAS B with(nolock) on a.nrocaja= b.nro_caja
														and a.sucursal = b.sucursal
				where b.nro_caja is null
				and b.sucursal is null
	else
	print ''Comprobación OK.Tabla SALDOSCAJA  con TABLA_CAJAS ''
----------------------------------------20
	if exists (	select a.sucursal 
				from SALDOSCAJA_HISTORICO a with(nolock) 
				left join SALDOSCAJA B with(nolock) on a.nrocaja= b.nrocaja
														and a.sucursal = b.sucursal
				where b.nrocaja is null
				and b.sucursal is null
			  )	
				SELECT    ''Tabla SALDOSCAJA_HISTORICO no se ajusta a la integridad referencial con SALDOSCAJA '',*
				from SALDOSCAJA_HISTORICO a with(nolock) 
				left join SALDOSCAJA B with(nolock) on a.nrocaja= b.nrocaja
														and a.sucursal = b.sucursal
				where b.nrocaja is null
				and b.sucursal is null
	else
	print ''Comprobación OK.Tabla SALDOSCAJA_HISTORICO  con SALDOSCAJA ''

----------------------------------------21
	if exists (	select a.moneda 
				from SALDOSCAJA a with(nolock) 
				where a.MONEDA not in(	select b.C6399
												from monedas B with(nolock))
			  )	
				SELECT    ''Tabla SALDOSCAJA no se ajusta a la integridad referencial con MONEDAS '',*
				from SALDOSCAJA a with(nolock) 
				where a.MONEDA not in(	select b.C6399
												from monedas B with(nolock))
	else
	print ''Comprobación OK.Tabla SALDOSCAJA  con MONEDAS ''

----------------------------------------22
	if exists (	select a.moneda 
				from REM_SOLICITUDREMESA a with(nolock) 
				where a.MONEDA not in(	select b.C6399
												from monedas B with(nolock))
			  )	
				SELECT    ''Tabla REM_SOLICITUDREMESA no se ajusta a la integridad referencial con MONEDAS '',*
				from REM_SOLICITUDREMESA a with(nolock) 
				where a.MONEDA not in(	select b.C6399
												from monedas B with(nolock))
	else
	print ''Comprobación OK.Tabla REM_SOLICITUDREMESA con MONEDAS ''
----------------------------------------23
	if exists (	select a.moneda 
				from CAJ_LIMITES_CAJA a with(nolock) 
				where a.MONEDA not in(	select b.C6399
												from monedas B with(nolock))
			  )	
				SELECT    ''Tabla CAJ_LIMITES_CAJA no se ajusta a la integridad referencial con MONEDAS '',*
				from CAJ_LIMITES_CAJA a with(nolock) 
				where a.MONEDA not in(	select b.C6399
												from monedas B with(nolock))
	else
	print ''Comprobación OK.Tabla CAJ_LIMITES_CAJA con MONEDAS ''
----------------------------------------24
	if exists (	select a.moneda 
				from CAJ_DIFERENCIA_MAX_CAJA a with(nolock) 
				where a.MONEDA not in(	select b.C6399
												from monedas B with(nolock))
			  )	
				SELECT    ''Tabla CAJ_DIFERENCIA_MAX_CAJA no se ajusta a la integridad referencial con MONEDAS '',*
				from CAJ_DIFERENCIA_MAX_CAJA a with(nolock) 
				where a.MONEDA not in(	select b.C6399
												from monedas B with(nolock))
	else
	print ''Comprobación OK.Tabla CAJ_DIFERENCIA_MAX_CAJA con MONEDAS ''
----------------------------------------25
	if exists (	select a.moneda 
				from DENOMINACIONES a with(nolock) 
				where a.MONEDA not in(	select b.C6399
												from monedas B with(nolock))
			  )	
				SELECT    ''Tabla DENOMINACIONES no se ajusta a la integridad referencial con MONEDAS '',*
				from DENOMINACIONES a with(nolock) 
				where a.MONEDA not in(	select b.C6399
												from monedas B with(nolock))
	else
	print ''Comprobación OK.Tabla DENOMINACIONES con MONEDAS ''
----------------------------------------26
	if exists (	select a.DENOMINACION 
				from CAJ_HISTORIAL_BILLETAJE a with(nolock) 
				where a.DENOMINACION not in(	select b.DENOMINACION
												from DENOMINACIONES B with(nolock))
			  )	
				SELECT    ''Tabla CAJ_HISTORIAL_BILLETAJE no se ajusta a la integridad referencial con DENOMINACIONES '',*
				from CAJ_HISTORIAL_BILLETAJE a with(nolock) 
				where a.DENOMINACION not in(	select b.DENOMINACION
												from DENOMINACIONES B with(nolock))
	else
	print ''Comprobación OK.Tabla CAJ_HISTORIAL_BILLETAJE con DENOMINACIONES ''
----------------------------------------27
	if exists (	select a.DENOMINACION 
				from REM_SOLICITUDREMESA a with(nolock) 
				where a.DENOMINACION not in(	select b.DENOMINACION
												from DENOMINACIONES B with(nolock))
			  )	
				SELECT    ''Tabla REM_SOLICITUDREMESA no se ajusta a la integridad referencial con DENOMINACIONES '',*
				from REM_SOLICITUDREMESA a with(nolock) 
				where a.DENOMINACION not in(	select b.DENOMINACION
												from DENOMINACIONES B with(nolock))
	else
	print ''Comprobación OK.Tabla REM_SOLICITUDREMESA con DENOMINACIONES ''
----------------------------------------28
	if exists (	select a.SECTOR 
				from CAJ_MAQUINASECTOR a with(nolock) 
				where a.SECTOR not in(	select b.SECTOR
												from CAJ_SECTORES_MONITOR B with(nolock))
			  )	
				SELECT    ''Tabla CAJ_MAQUINASECTOR no se ajusta a la integridad referencial con CAJ_SECTORES_MONITOR '',*
				from CAJ_MAQUINASECTOR a with(nolock) 
				where a.SECTOR not in(	select b.SECTOR
												from CAJ_SECTORES_MONITOR B with(nolock))
	else
	print ''Comprobación OK.Tabla CAJ_MAQUINASECTOR con CAJ_SECTORES_MONITOR ''
----------------------------------------29
	if exists (	select a.CONCEPTO_CONTABLE 
				from CAJ_FALLA_CAJA a with(nolock) 
				where a.CONCEPTO_CONTABLE not in(	select b.C6500
												from CONCEPCONT B with(nolock))
			  )	
				SELECT    ''Tabla CAJ_FALLA_CAJA no se ajusta a la integridad referencial con CONCEPCONT '',*
				from CAJ_FALLA_CAJA a with(nolock) 
				where a.CONCEPTO_CONTABLE not in(	select b.C6500
												from CONCEPCONT B with(nolock))
	else
	print ''Comprobación OK.Tabla CAJ_FALLA_CAJA con CONCEPCONT ''
----------------------------------------30
	if exists (	select a.MEDIO_TRANSP 
				from REM_SOLICITUDREMESA a with(nolock) 
				where a.MEDIO_TRANSP not in(	select b.NRO_CLIENTE
												from REM_TRANSPORTADORAs B with(nolock))
			  )	
				SELECT  ''Tabla REM_SOLICITUDREMESA no se ajusta a la integridad referencial con REM_TRANSPORTADORAs '',*
				from REM_SOLICITUDREMESA a with(nolock) 
				where a.MEDIO_TRANSP not in(	select b.NRO_CLIENTE
												from REM_TRANSPORTADORAs B with(nolock))
	else
	print ''Comprobación OK.Tabla REM_SOLICITUDREMESA con REM_TRANSPORTADORAs ''

	END
ELSE
	print ''NO CORRESPONDE LA BASE DE DATOS''
END
; ')