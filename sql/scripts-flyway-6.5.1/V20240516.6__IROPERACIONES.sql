execute('
----------------------------------------OPERACIONES.-----------------------------------------------------------
--exec SP_INTEGRIDAD_REFERENCIAL_OPERACIONES NBCH_tunning

CREATE OR ALTER  procedure [dbo].[SP_INTEGRIDAD_REFERENCIAL_OPERACIONES] 
								 @BD varchar(20)
as
BEGIN
IF (SELECT DB_NAME()) = @BD
  BEGIN
	print ''--------------------OPERACIONES---------------------''
	print ''----------------------------------------------------''

-------------------------------Depositos Judiciales

	if exists (select b.NRO_JUZGADO 
				from DJ_SOLICITUD_AD_INTEG_JUZ b with(nolock) 
				where b.NRO_JUZGADO not in(select a.NRO_JUZGADO 
										from DJ_JUZGADOS  A with(nolock))
				)	
				SELECT   ''Tabla DJ_SOLICITUD_AD_INTEG_JUZ no se ajusta a la integridad referencial con Tabla DJ_JUZGADOS'',*
				from DJ_SOLICITUD_AD_INTEG_JUZ b with(nolock) 
				where b.NRO_JUZGADO not in(select a.NRO_JUZGADO 
										from DJ_JUZGADOS  A with(nolock))
	else
	print ''Comprobación OK.Tabla DJ_SOLICITUD_AD_INTEG_JUZ con Tabla DJ_JUZGADOS''

	if exists (select b.NRO_CAUSA 
				from DJ_DEMANDADOS b with(nolock) 
				where b.NRO_CAUSA not in(select a.NRO_CAUSA 
										from DJ_CAUSA_CUENTA  A with(nolock))
				)	
				SELECT   ''Tabla DJ_DEMANDADOS no se ajusta a la integridad referencial con Tabla DJ_CAUSA_CUENTA'',*
				from DJ_DEMANDADOS b with(nolock) 
				where b.NRO_CAUSA not in(select a.NRO_CAUSA 
										from DJ_CAUSA_CUENTA  A with(nolock))
	else
	print ''Comprobación OK.Tabla DJ_DEMANDADOS con Tabla DJ_CAUSA_CUENTA''

	if exists (select b.ID_PERSONA 
				from PYF_APODERADOS b with(nolock) 
				where b.ID_PERSONA not in(select a.NUMEROPERSONAFISICA 
										from CLI_PERSONASFISICAS  A with(nolock))
				)	
				SELECT   ''Tabla DJ_SOLICITUD_AD_INTEG_JUZ no se ajusta a la integridad referencial con Tabla CLI_PERSONASFISICAS'',*
				from DJ_SOLICITUD_AD_INTEG_JUZ b with(nolock) 
				where b.ID_PERSONA not in(select a.NUMEROPERSONAFISICA 
										from CLI_PERSONASFISICAS  A with(nolock))
	else
	print ''Comprobación OK.Tabla DJ_SOLICITUD_AD_INTEG_JUZ con Tabla CLI_PERSONASFISICAS''

	if exists (select b.FUERO 
				from DJ_JUZGADOS b with(nolock) 
				where b.FUERO not in(select a.id 
										from DJ_FUEROS  A with(nolock))
				)	
				SELECT   ''Tabla DJ_JUZGADOS no se ajusta a la integridad referencial con Tabla DJ_FUEROS'',*
				from DJ_JUZGADOS b with(nolock) 
				where b.FUERO not in(select a.id 
										from DJ_FUEROS  A with(nolock))
	else
	print ''Comprobación OK.Tabla DJ_JUZGADOS con Tabla DJ_FUEROS''
	if exists (select b.CIRCUNSCRIPCION 
				from DJ_JUZGADOS b with(nolock) 
				where b.CIRCUNSCRIPCION not in(select a.id 
										from DJ_CIRCUNSCRIPCION  A with(nolock))
				)	
				SELECT   ''Tabla DJ_JUZGADOS no se ajusta a la integridad referencial con Tabla DJ_CIRCUNSCRIPCION'',*
				from DJ_JUZGADOS b with(nolock) 
				where b.CIRCUNSCRIPCION not in(select a.id 
										from DJ_CIRCUNSCRIPCION  A with(nolock))
	else
	print ''Comprobación OK.Tabla DJ_JUZGADOS con Tabla DJ_CIRCUNSCRIPCION''
	if exists (select b.JUZGADO 
				from DJ_CAUSAS b with(nolock) 
				where b.JUZGADO not in(select a.NRO_JUZGADO 
										from DJ_JUZGADOS  A with(nolock))
				)	
				SELECT   ''Tabla DJ_CAUSAS no se ajusta a la integridad referencial con Tabla DJ_JUZGADOS'',*
				from DJ_CAUSAS b with(nolock) 
				where b.JUZGADO not in(select a.NRO_JUZGADO 
										from DJ_JUZGADOS  A with(nolock))
	else
	print ''Comprobación OK.Tabla DJ_CAUSAS con Tabla DJ_JUZGADOS''
	if exists (select b.NRO_JUZGADO 
				from DJ_INTEGRANTES_JUZGADOS b with(nolock) 
				where b.NRO_JUZGADO not in(select a.NRO_JUZGADO 
										from DJ_JUZGADOS  A with(nolock))
				)	
				SELECT   ''Tabla DJ_INTEGRANTES_JUZGADOS no se ajusta a la integridad referencial con Tabla DJ_JUZGADOS'',*
				from DJ_INTEGRANTES_JUZGADOS b with(nolock) 
				where b.NRO_JUZGADO not in(select a.NRO_JUZGADO 
										from DJ_JUZGADOS  A with(nolock))
	else
	print ''Comprobación OK.Tabla DJ_INTEGRANTES_JUZGADOS con Tabla DJ_JUZGADOS''
	if exists (select b.NRO_CAUSA 
				from DJ_SOL_ACT_INAC_CAUSAS b with(nolock) 
				where b.NRO_CAUSA not in(select a.NRO_CAUSA 
										from DJ_CAUSAS  A with(nolock))
				)	
				SELECT   ''Tabla DJ_SOL_ACT_INAC_CAUSAS no se ajusta a la integridad referencial con Tabla DJ_CAUSAS'',*
				from DJ_SOL_ACT_INAC_CAUSAS b with(nolock) 
				where b.NRO_CAUSA not in(select a.NRO_CAUSA 
										from DJ_CAUSAS  A with(nolock))
	else
	print ''Comprobación OK.Tabla DJ_SOL_ACT_INAC_CAUSAS con Tabla DJ_CAUSAS''
	if exists (select b.TIPO_CAUSA 
				from DJ_CAUSAS b with(nolock) 
				where b.TIPO_CAUSA not in(select a.CODIGO 
										from DJ_TIPOS_CAUSAS  A with(nolock))
				)	
				SELECT   ''Tabla DJ_CAUSAS no se ajusta a la integridad referencial con Tabla DJ_TIPOS_CAUSAS'',*
				from DJ_CAUSAS b with(nolock) 
				where b.TIPO_CAUSA not in(select a.CODIGO 
										from DJ_TIPOS_CAUSAS  A with(nolock))
	else
	print ''Comprobación OK.Tabla DJ_CAUSAS con Tabla DJ_TIPOS_CAUSAS''
	if exists (select b.PRODUCTO 
				from DJ_TIPOS_CAUSAS b with(nolock) 
				where b.PRODUCTO not in(select a.C6250 
										from PRODUCTOS  A with(nolock))
				)	
				SELECT   ''Tabla DJ_TIPOS_CAUSAS no se ajusta a la integridad referencial con Tabla PRODUCTOS'',*
				from DJ_TIPOS_CAUSAS b with(nolock) 
				where b.PRODUCTO not in(select a.C6250 
										from PRODUCTOS  A with(nolock))
	else
	print ''Comprobación OK.Tabla DJ_TIPOS_CAUSAS con Tabla PRODUCTOS''
	if exists (select b.ID_PERSONA 
				from DJ_INTEGRANTES_JUZGADOS b with(nolock) 
				where b.ID_PERSONA not in(select a.NUMEROPERSONAFISICA 
										from CLI_PERSONASFISICAS  A with(nolock))
				)	
				SELECT   ''Tabla DJ_INTEGRANTES_JUZGADOS no se ajusta a la integridad referencial con Tabla CLI_PERSONASFISICAS'',*
				from DJ_INTEGRANTES_JUZGADOS b with(nolock) 
				where b.ID_PERSONA not in(select a.NUMEROPERSONAFISICA 
										from CLI_PERSONASFISICAS  A with(nolock))
	else
	print ''Comprobación OK.Tabla DJ_INTEGRANTES_JUZGADOS con Tabla CLI_PERSONASFISICAS''
	if exists (select b.NRO_PERSONA 
				from DJ_DEMANDADOS b with(nolock) 
				where b.NRO_PERSONA not in(select a.NUMEROPERSONAFISICA 
										from CLI_PERSONASFISICAS  A with(nolock))
				)	
				SELECT   ''Tabla DJ_DEMANDADOS no se ajusta a la integridad referencial con Tabla CLI_PERSONASFISICAS'',*
				from DJ_DEMANDADOS b with(nolock) 
				where b.NRO_PERSONA not in(select a.NUMEROPERSONAFISICA 
										from CLI_PERSONASFISICAS  A with(nolock))
	else
	print ''Comprobación OK.Tabla DJ_DEMANDADOS con Tabla CLI_PERSONASFISICAS''
	if exists (select b.ID_BENEFICIARIO 
				from DJ_BENEFICIARIOS b with(nolock) 
				where b.ID_BENEFICIARIO not in(select a.NUMEROPERSONAFISICA 
										from CLI_PERSONASFISICAS  A with(nolock))
				)	
				SELECT   ''Tabla DJ_BENEFICIARIOS no se ajusta a la integridad referencial con Tabla CLI_PERSONASFISICAS'',*
				from DJ_BENEFICIARIOS b with(nolock) 
				where b.ID_BENEFICIARIO not in(select a.NUMEROPERSONAFISICA 
										from CLI_PERSONASFISICAS  A with(nolock))
	else
	print ''Comprobación OK.Tabla DJ_BENEFICIARIOS con Tabla CLI_PERSONASFISICAS''

	if exists (select b.NRO_CAUSA 
				from DJ_BENEFICIARIOS b with(nolock) 
				where b.NRO_CAUSA not in(select a.NRO_CAUSA 
										from DJ_CAUSA_CUENTA  A with(nolock))
				)	
				SELECT   ''Tabla DJ_BENEFICIARIOS no se ajusta a la integridad referencial con Tabla DJ_CAUSA_CUENTA'',*
				from DJ_BENEFICIARIOS b with(nolock) 
				where b.NRO_CAUSA not in(select a.NRO_CAUSA 
										from DJ_CAUSA_CUENTA  A with(nolock))
	else
	print ''Comprobación OK.Tabla DJ_BENEFICIARIOS con Tabla DJ_CAUSA_CUENTA''

	if exists (select b.ACTOR 
				from DJ_INTEGRANTES_JUZGADOS b with(nolock) 
				where b.ACTOR not in(select a.Id 
										from DJ_ACTORES  A with(nolock))
				)	
				SELECT   ''Tabla DJ_INTEGRANTES_JUZGADOS no se ajusta a la integridad referencial con Tabla DJ_ACTORES'',*
				from DJ_INTEGRANTES_JUZGADOS b with(nolock) 
				where b.ACTOR not in(select a.Id 
										from DJ_ACTORES  A with(nolock))
	else
	print ''Comprobación OK.Tabla DJ_INTEGRANTES_JUZGADOS con Tabla DJ_ACTORES''

		if exists (select b.ACTOR 
				from DJ_INTEGRANTES_CAUSAS b with(nolock) 
				where b.ACTOR not in(select a.Id 
										from DJ_ACTORES  A with(nolock))
				)	
				SELECT   ''Tabla DJ_INTEGRANTES_CAUSAS no se ajusta a la integridad referencial con Tabla DJ_ACTORES'',*
				from DJ_INTEGRANTES_CAUSAS b with(nolock) 
				where b.ACTOR not in(select a.Id 
										from DJ_ACTORES  A with(nolock))
	else
	print ''Comprobación OK.Tabla DJ_INTEGRANTES_CAUSAS con Tabla DJ_ACTORES''

	if exists (select b.JTS_OID_CUENTA 
				from DJ_CAUSA_CUENTA b with(nolock) 
				where b.JTS_OID_CUENTA not in(select a.JTS_OID 
										from SALDOS  A with(nolock))
				)	
				SELECT   ''Tabla DJ_CAUSA_CUENTA no se ajusta a la integridad referencial con Tabla SALDOS'',*
				from DJ_CAUSA_CUENTA b with(nolock) 
				where b.JTS_OID_CUENTA not in(select a.JTS_OID 
										from SALDOS  A with(nolock))
	else
	print ''Comprobación OK.Tabla DJ_CAUSA_CUENTA con Tabla SALDOS''

	if exists (select b.JTS_OID_CUENTA 
				from DJ_CAUSA_CUENTA b with(nolock) 
				where b.NRO_CAUSA not in(select a.NRO_CAUSA 
										from DJ_CAUSAS  A with(nolock))
				)	
				SELECT   ''Tabla DJ_CAUSA_CUENTA no se ajusta a la integridad referencial con Tabla DJ_CAUSAS'',*
				from DJ_CAUSA_CUENTA b with(nolock) 
				where b.NRO_CAUSA not in(select a.NRO_CAUSA 
										from DJ_CAUSAS  A with(nolock))
	else
	print ''Comprobación OK.Tabla DJ_CAUSA_CUENTA con Tabla DJ_CAUSAS''


	if exists (select b.JTSOID 
				from GRL_ESTADOS_DE_CUENTA b with(nolock) 
				where b.JTSOID not in(select a.JTS_OID 
										from SALDOS  A with(nolock))
				)	
				SELECT   ''Tabla GRL_ESTADOS_DE_CUENTA no se ajusta a la integridad referencial con Tabla SALDOS'',*
				from GRL_ESTADOS_DE_CUENTA b with(nolock) 
				where b.JTSOID not in(select a.JTS_OID 
										from SALDOS  A with(nolock))
	else
	print ''Comprobación OK.Tabla GRL_ESTADOS_DE_CUENTA con Tabla SALDOS''

	if exists (select b.SALDO_JTS_OID 
				from GRL_BLOQUEOS b with(nolock) 
				where b.SALDO_JTS_OID not in(select a.JTS_OID 
										from SALDOS  A with(nolock))
				)	
				SELECT   ''Tabla GRL_BLOQUEOS no se ajusta a la integridad referencial con Tabla SALDOS'',*
				from GRL_BLOQUEOS b with(nolock) 
				where b.SALDO_JTS_OID not in(select a.JTS_OID 
										from SALDOS  A with(nolock))
	else
	print ''Comprobación OK.Tabla GRL_BLOQUEOS con Tabla SALDOS''

	if exists (select b.JTS_OID_SALDO 
				from VTA_SALDOS b with(nolock) 
				where b.JTS_OID_SALDO not in(select a.JTS_OID 
										from SALDOS  A with(nolock))
				)	
				SELECT   ''Tabla VTA_SALDOS no se ajusta a la integridad referencial con Tabla SALDOS'',*
				from VTA_SALDOS b with(nolock) 
				where b.JTS_OID_SALDO not in(select a.JTS_OID 
										from SALDOS  A with(nolock))
	else
	print ''Comprobación OK.Tabla VTA_SALDOS con Tabla SALDOS''

	if exists (select b.JTS_OID_SALDO 
				from DJ_HISTORICO_INACTIVAS b with(nolock) 
				where b.JTS_OID_SALDO not in(select a.JTS_OID 
										from SALDOS  A with(nolock))
				)	
				SELECT   ''Tabla DJ_HISTORICO_INACTIVAS no se ajusta a la integridad referencial con Tabla SALDOS'',*
				from DJ_HISTORICO_INACTIVAS b with(nolock) 
				where b.JTS_OID_SALDO not in(select a.JTS_OID 
										from SALDOS  A with(nolock))
	else
	print ''Comprobación OK.Tabla DJ_HISTORICO_INACTIVAS con Tabla SALDOS''

-------------------------------Tarjeta de Debito
	if exists (select b.clase 
				from TJD_TIPO_TARJETA b with(nolock) 
				where b.clase not in(select a.Clave 
										from TJD_CLASE  A with(nolock))
				)	
				SELECT   ''Tabla TJD_TIPO_TARJETA no se ajusta a la integridad referencial con Tabla TJD_CLASE'',*
				from TJD_TIPO_TARJETA b with(nolock) 
				where b.clase not in(select a.Clave 
										from TJD_CLASE  A with(nolock))
	else
	print ''Comprobación OK.Tabla TJD_TIPO_TARJETA con Tabla TJD_CLASE''

	if exists (select b.COD_OPERACION 
				from TJD_TIPO_COD_OPERACION b with(nolock) 
				where b.COD_OPERACION not in(select a.SUB_TIPO 
										from TJD_PERMISOS  A with(nolock))
				)	
				SELECT   ''Tabla TJD_TIPO_COD_OPERACION no se ajusta a la integridad referencial con Tabla TJD_PERMISOS'',*
				from TJD_TIPO_COD_OPERACION b with(nolock) 
				where b.COD_OPERACION not in(select a.SUB_TIPO 
										from TJD_PERMISOS  A with(nolock))
	else
	print ''Comprobación OK.Tabla TJD_TIPO_COD_OPERACION con Tabla TJD_PERMISOS''

	if exists (select b.PERMISO 
				from TJD_TARJETAS b with(nolock) 
				where b.PERMISO not in(select a.SUB_TIPO 
										from TJD_PERMISOS  A with(nolock))
				)	
				SELECT   ''Tabla TJD_TARJETAS no se ajusta a la integridad referencial con Tabla TJD_PERMISOS'',*
				from TJD_TARJETAS b with(nolock) 
				where b.PERMISO not in(select a.SUB_TIPO 
										from TJD_PERMISOS  A with(nolock))
	else
	print ''Comprobación OK.Tabla TJD_TARJETAS con Tabla TJD_PERMISOS''

	if exists (select b.TARJETA 
				from PROD_RELTARJETAS b with(nolock) 
				where b.TARJETA not in(select a.TIPO_TARJETA 
										from TJD_TIPO_TARJETA  A with(nolock))
				)	
				SELECT   ''Tabla PROD_RELTARJETAS no se ajusta a la integridad referencial con Tabla TJD_TIPO_TARJETA'',*
				from PROD_RELTARJETAS b with(nolock) 
				where b.TARJETA not in(select a.TIPO_TARJETA 
										from TJD_TIPO_TARJETA  A with(nolock))
	else
	print ''Comprobación OK.Tabla PROD_RELTARJETAS con Tabla TJD_TIPO_TARJETA''

	if exists (select b.CANAL 
				from TJD_CANAL_ORIGEN b with(nolock) 
				where b.CANAL not in(select a.CODIGO 
										from TJD_CANAL  A with(nolock))
				)	
				SELECT   ''Tabla TJD_CANAL_ORIGEN no se ajusta a la integridad referencial con Tabla TJD_CANAL'',*
				from TJD_CANAL_ORIGEN b with(nolock) 
				where b.CANAL not in(select a.CODIGO 
										from TJD_CANAL  A with(nolock))
	else
	print ''Comprobación OK.Tabla TJD_CANAL_ORIGEN con Tabla TJD_CANAL''

	if exists (select b.ORIGEN 
				from TJD_CANAL_ORIGEN b with(nolock) 
				where b.ORIGEN not in(select a.CODIGO 
										from TJD_ORIGEN  A with(nolock))
				)	
				SELECT   ''Tabla TJD_CANAL_ORIGEN no se ajusta a la integridad referencial con Tabla TJD_ORIGEN'',*
				from TJD_CANAL_ORIGEN b with(nolock) 
				where b.ORIGEN not in(select a.CODIGO 
										from TJD_ORIGEN  A with(nolock))
	else
	print ''Comprobación OK.Tabla TJD_CANAL_ORIGEN con Tabla TJD_ORIGEN''

	if exists (select b.JTS_OID_GTOS 
				from TJD_TARJETAS b with(nolock) 
				where b.JTS_OID_GTOS not in(select a.JTS_OID_SALDO 
										from VTA_SALDOS  A with(nolock))
				)	
				SELECT   ''Tabla TJD_TARJETAS no se ajusta a la integridad referencial con Tabla VTA_SALDOS'',*
				from TJD_TARJETAS b with(nolock) 
				where b.JTS_OID_GTOS not in(select a.JTS_OID_SALDO 
										from VTA_SALDOS  A with(nolock))
	else
	print ''Comprobación OK.Tabla TJD_TARJETAS con Tabla VTA_SALDOS''

	if exists (select b.ID_TARJETA 
				from TJD_DATOS_AUDITORIA b with(nolock) 
				where b.ID_TARJETA not in(select a.ID_TARJETA 
										from TJD_TARJETAS  A with(nolock))
				)	
				SELECT   ''Tabla TJD_DATOS_AUDITORIA no se ajusta a la integridad referencial con Tabla TJD_TARJETAS'',*
				from TJD_DATOS_AUDITORIA b with(nolock) 
				where b.ID_TARJETA not in(select a.ID_TARJETA 
										from TJD_TARJETAS  A with(nolock))
	else
	print ''Comprobación OK.Tabla TJD_DATOS_AUDITORIA con Tabla TJD_TARJETAS''

	if exists (select b.ID_TARJETA_BASE 
				from TJD_COBRO_COMISIONES b with(nolock) 
				where b.ID_TARJETA_BASE not in(select a.ID_TARJETA 
										from TJD_TARJETAS  A with(nolock))
				)	
				SELECT   ''Tabla TJD_COBRO_COMISIONES no se ajusta a la integridad referencial con Tabla TJD_TARJETAS'',*
				from TJD_COBRO_COMISIONES b with(nolock) 
				where b.ID_TARJETA_BASE not in(select a.ID_TARJETA 
										from TJD_TARJETAS  A with(nolock))
	else
	print ''Comprobación OK.Tabla TJD_COBRO_COMISIONES con Tabla TJD_TARJETAS''

	if exists (select b.ESTADO 
				from TJD_TARJETAS b with(nolock) 
				where b.ESTADO not in(select a.ESTADO 
										from TJD_ESTADO_TARJETA_CUENTA  A with(nolock))
				)	
				SELECT   ''Tabla TJD_TARJETAS no se ajusta a la integridad referencial con Tabla TJD_ESTADO_TARJETA_CUENTA'',*
				from TJD_TARJETAS b with(nolock) 
				where b.ESTADO not in(select a.ESTADO 
										from TJD_ESTADO_TARJETA_CUENTA  A with(nolock))
	else
	print ''Comprobación OK.Tabla TJD_TARJETAS con Tabla TJD_ESTADO_TARJETA_CUENTA''

	if exists (select b.LIMITE_DEBITO 
				from TJD_SOLICITUD_LINK b with(nolock) 
				where b.LIMITE_DEBITO not in(	select a.CODIGO 
										from TJD_LIMITES_LINK  A with(nolock))
				)	
				SELECT   ''Tabla TJD_SOLICITUD_LINK no se ajusta a la integridad referencial con Tabla TJD_LIMITES_LINK'',*
				from TJD_SOLICITUD_LINK b with(nolock) 
				where b.LIMITE_DEBITO not in(	select a.CODIGO 
										from TJD_LIMITES_LINK  A with(nolock))
	else
	print ''Comprobación OK.Tabla TJD_SOLICITUD_LINK con Tabla TJD_LIMITES_LINK''

	if exists (select b.LIMITE_DEBITO 
				from TJD_SOLICITUD_LINK b with(nolock) 
				where b.ID_SOLICITUD not in(	select a.ID 
										from TJD_SOLICITUD_DIRECCIONES_LINK  A with(nolock))
				)	
				SELECT   ''Tabla TJD_SOLICITUD_LINK no se ajusta a la integridad referencial con Tabla TJD_SOLICITUD_DIRECCIONES_LINK'',*
				from TJD_SOLICITUD_LINK b with(nolock) 
				where b.ID_SOLICITUD not in(	select a.ID 
										from TJD_SOLICITUD_DIRECCIONES_LINK  A with(nolock))
	else
	print ''Comprobación OK.Tabla TJD_SOLICITUD_LINK con Tabla TJD_SOLICITUD_DIRECCIONES_LINK''

	if exists (select b.LIMITE_DEBITO 
				from TJD_SOLICITUD_LINK b with(nolock) 
				where b.ID_SOLICITUD not in(	select a.ID_SOLICITUD
										from TJD_SOLICITUD_CUENTAS_LINK  A with(nolock))
				)	
				SELECT   ''Tabla TJD_SOLICITUD_LINK no se ajusta a la integridad referencial con Tabla TJD_SOLICITUD_CUENTAS_LINK'',*
				from TJD_SOLICITUD_LINK b with(nolock) 
				where b.ID_SOLICITUD not in(	select a.ID_SOLICITUD
										from TJD_SOLICITUD_CUENTAS_LINK  A with(nolock))
	else
	print ''Comprobación OK.Tabla TJD_SOLICITUD_LINK con Tabla TJD_SOLICITUD_CUENTAS_LINK''

	if exists (select b.ID_TARJETA 
				from TJD_LINK_MAESTRO b with(nolock) 
				where b.ID_TARJETA not in(	select a.ID_TARJETA
											from TJD_TARJETAS  A with(nolock))
				)	
				SELECT   ''Tabla TJD_LINK_MAESTRO no se ajusta a la integridad referencial con Tabla TJD_TARJETAS'',*
				from TJD_LINK_MAESTRO b with(nolock) 
				where b.ID_TARJETA not in(	select a.ID_TARJETA
											from TJD_TARJETAS  A with(nolock))
	else
	print ''Comprobación OK.Tabla TJD_LINK_MAESTRO con Tabla TJD_TARJETAS''

	if exists (select b.ID_TARJETA 
				from TJD_REL_TARJETA_CUENTA b with(nolock) 
				where b.ID_TARJETA not in(	select a.ID_TARJETA
											from TJD_TARJETAS  A with(nolock))
				)	
				SELECT   ''Tabla TJD_REL_TARJETA_CUENTA no se ajusta a la integridad referencial con Tabla TJD_TARJETAS'',*
				from TJD_REL_TARJETA_CUENTA b with(nolock) 
				where b.ID_TARJETA not in(	select a.ID_TARJETA
											from TJD_TARJETAS  A with(nolock))
	else
	print ''Comprobación OK.Tabla TJD_REL_TARJETA_CUENTA con Tabla TJD_TARJETAS''
--------------------------------LOTERIA
	if exists (select b.JTS_OID 
				from REC_Agencieros b with(nolock) 
				where b.JTS_OID not in(	select a.JTS_OID
										from saldos  A with(nolock))
				)	
				SELECT   ''Tabla REC_Agencieros no se ajusta a la integridad referencial con Tabla saldos'',*
				from REC_Agencieros b with(nolock) 
				where b.JTS_OID not in(	select a.JTS_OID
										from saldos  A with(nolock))
	else
	print ''Comprobación OK.Tabla REC_Agencieros con Tabla saldos''
-------------------------------- Clering Propios
	if exists (select b.JTS_OID 
				from REC_Agencieros b with(nolock) 
				where b.JTS_OID not in(	select a.JTS_OID
										from saldos  A with(nolock))
				)	
				SELECT   ''Tabla REC_Agencieros no se ajusta a la integridad referencial con Tabla saldos'',*
				from REC_Agencieros b with(nolock) 
				where b.JTS_OID not in(	select a.JTS_OID
										from saldos  A with(nolock))
	else
	print ''Comprobación OK.Tabla REC_Agencieros con Tabla saldos''
--------------------------------Cheques Propios
	if exists (	select b.NRO_SOLICITUD 
				from CHE_SOLICITUD_CANJE_INTERNO b with(nolock) 
				left join CHE_CHEQUES a with(nolock) on a.NRO_SOLICITUD = b.NRO_SOLICITUD
													and a.serie = b.SERIE							
													and a.NUMEROCHEQUE = b.NRO_CHEQUE
				where a.NRO_SOLICITUD is null
						and a.SERIE is null
						and a.NUMEROCHEQUE is null 
			)	
				SELECT   ''Tabla CHE_SOLICITUD_CANJE_INTERNO no se ajusta a la integridad referencial con CHE_CHEQUES '',*
				from CHE_SOLICITUD_CANJE_INTERNO b with(nolock) 
				left join CHE_CHEQUES a with(nolock) on a.NRO_SOLICITUD = b.NRO_SOLICITUD
											and a.serie = b.SERIE							
											and a.NUMEROCHEQUE = b.NRO_CHEQUE
				where a.NRO_SOLICITUD is null
						and a.SERIE is null
						and a.NUMEROCHEQUE is null 
	else
	print ''Comprobación OK.Tabla CHE_SOLICITUD_CANJE_INTERNO con CHE_CHEQUES ''
		if exists (	select a.CUENTA 
				from Che_Cheques a with(nolock)
				left join ( SELECT *
							FROM SALDOS with(nolock)
							WHERE PRODUCTO IN ( SELECT c6250
												FROM PRODUCTOS with(nolock)
												WHERE C6252=2))
															b on a.Cuenta = b.CUENTA
															and a.Moneda = b.MONEDA
															and a.Sucursal = b.SUCURSAL
															and b.ORDINAL = 0
															and b.OPERACION = 0
				where	b.cuenta is null
						and b.MONEDA is null
						and b.SUCURSAL is null
						AND b.ordinal IS NULL
						AND b.operacion IS NULL
						AND b.producto IS NULL
			)	
				SELECT   ''Tabla Che_Cheques no se ajusta a la integridad referencial con SALDOS '',*
				from Che_Cheques a with(nolock)
				left join ( SELECT *
							FROM SALDOS with(nolock)
							WHERE PRODUCTO IN ( SELECT c6250
												FROM PRODUCTOS with(nolock)
												WHERE C6252=2))
															b on a.Cuenta = b.CUENTA
															and a.Moneda = b.MONEDA
															and a.Sucursal = b.SUCURSAL
															and b.ORDINAL = 0
															and b.OPERACION = 0
				where	b.cuenta is null
						and b.MONEDA is null
						and b.SUCURSAL is null
						AND b.ordinal IS NULL
						AND b.operacion IS NULL
						AND b.producto IS NULL				
	else
	print ''Comprobación OK.Tabla Che_Cheques con SALDOS ''
		if exists (	select a.CUENTA 
				from Che_Chequeras a with(nolock)
				left join ( SELECT *
							FROM SALDOS with(nolock)
							WHERE PRODUCTO IN ( SELECT c6250
												FROM PRODUCTOS with(nolock)
												WHERE C6252=2))
															b on a.Cuenta = b.CUENTA
															and a.Moneda = b.MONEDA
															and a.Sucursal = b.SUCURSAL
															and b.ORDINAL = 0
															and b.OPERACION = 0
				where	b.cuenta is null
						and b.MONEDA is null
						and b.SUCURSAL is null
						AND b.ordinal IS NULL
						AND b.operacion IS NULL
						AND b.producto IS NULL
			)	
				SELECT   ''Tabla Che_Chequeras no se ajusta a la integridad referencial con SALDOS '',*
				from Che_Chequeras a with(nolock)
				left join ( SELECT *
							FROM SALDOS with(nolock)
							WHERE PRODUCTO IN ( SELECT c6250
												FROM PRODUCTOS with(nolock)
												WHERE C6252=2))
															b on a.Cuenta = b.CUENTA
															and a.Moneda = b.MONEDA
															and a.Sucursal = b.SUCURSAL
															and b.ORDINAL = 0
															and b.OPERACION = 0
				where	b.cuenta is null
						and b.MONEDA is null
						and b.SUCURSAL is null
						AND b.ordinal IS NULL
						AND b.operacion IS NULL
						AND b.producto IS NULL
	else
	print ''Comprobación OK.Tabla Che_Chequeras con SALDOS ''
	if exists (	select a.NROCHEQUE 
				from CLE_CHEQUES_CLEARING_DEVUELTOS a with(nolock) 
				left join CLE_CHEQUES_CLEARING_RECIBIDO b with(nolock) on a.NROCHEQUE = b.NUMERO_CHEQUE
															and a.SERIE = b.NUMERO_SERIE
															and a.SUCURSAL = b.SUCURSAL
															and a.CUENTA = b.CUENTA
															and a.CODBANCO = b.BANCO_DEPOSITANTE
															and a.FECHACHEQUE = b.FECHA_EMISION
				where a.NROCHEQUE is null
					and a.SERIE is null
					and a.SUCURSAL is null
					and a.CUENTA is null
					and a.CODBANCO is null
					and a.FECHACHEQUE is null
			)	
				SELECT   ''Tabla CLE_CHEQUES_CLEARING_DEVUELTOS no se ajusta a la integridad referencial con CLE_CHEQUES_CLEARING_RECIBIDO '',*
				from CLE_CHEQUES_CLEARING_DEVUELTOS a with(nolock) 
				left join CLE_CHEQUES_CLEARING_RECIBIDO b with(nolock) on a.NROCHEQUE = b.NUMERO_CHEQUE
															and a.SERIE = b.NUMERO_SERIE
															and a.SUCURSAL = b.SUCURSAL
															and a.CUENTA = b.CUENTA
															and a.CODBANCO = b.BANCO_DEPOSITANTE
															and a.FECHACHEQUE = b.FECHA_EMISION
				where a.NROCHEQUE is null
					and a.SERIE is null
					and a.SUCURSAL is null
					and a.CUENTA is null
					and a.CODBANCO is null
					and a.FECHACHEQUE is null
	else
	print ''Comprobación OK.Tabla CLE_CHEQUES_CLEARING_DEVUELTOS con CLE_CHEQUES_CLEARING_RECIBIDO ''
	if exists (	select a.CLIENTE 
				from CHE_BCO_RECHAZADOS a with(nolock)
				left join CLE_CHEQUES_CLEARING_DEVUELTOS b with(nolock) on a.SUCURSAL = b.SUCURSAL
															and a.SERIE_CHEQUE = b.SERIE
															and a.NRO_CHEQUE = b.NROCHEQUE
															and a.MONEDA = b.MONEDA
															and a.PRODUCTO = b.PRODUCTO
															and a.CUENTA = b.CUENTA
															and a.FECHA_CHEQUE = b.FECHACHEQUE
				where a.SUCURSAL is null
					and a.SERIE_CHEQUE is null
					and a.NRO_CHEQUE is null
					and a.MONEDA is null
					and a.PRODUCTO is null
					and a.CUENTA = b.CUENTA
					and a.FECHA_CHEQUE = b.FECHACHEQUE
			)	
				SELECT   ''Tabla CHE_BCO_RECHAZADOS no se ajusta a la integridad referencial con CLE_CHEQUES_CLEARING_DEVUELTOS '',*
				from CHE_BCO_RECHAZADOS a with(nolock)
				left join CLE_CHEQUES_CLEARING_DEVUELTOS b with(nolock) on a.SUCURSAL = b.SUCURSAL
															and a.SERIE_CHEQUE = b.SERIE
															and a.NRO_CHEQUE = b.NROCHEQUE
															and a.MONEDA = b.MONEDA
															and a.PRODUCTO = b.PRODUCTO
															and a.CUENTA = b.CUENTA
															and a.FECHA_CHEQUE = b.FECHACHEQUE
				where a.SUCURSAL is null
					and a.SERIE_CHEQUE is null
					and a.NRO_CHEQUE is null
					and a.MONEDA is null
					and a.PRODUCTO is null
					and a.CUENTA = b.CUENTA
					and a.FECHA_CHEQUE = b.FECHACHEQUE
	else
	print ''Comprobación OK.Tabla CHE_BCO_RECHAZADOS con CLE_CHEQUES_CLEARING_DEVUELTOS ''

	if exists (	select a.NRO_CHEQUE 
				from CHE_SOLICITUD_CANJE_INTERNO a with(nolock) 
				where a.SALDO_JTS_OID not in (	select b.jts_oid 
												from SALDOS b with(nolock))

			)	
				SELECT    ''Tabla CHE_SOLICITUD_CANJE_INTERNO no se ajusta a la integridad referencial con SALDOS '',*
				from CHE_SOLICITUD_CANJE_INTERNO a with(nolock) 
				where a.SALDO_JTS_OID not in (	select b.jts_oid 
												from SALDOS b with(nolock))
	else
	print ''Comprobación OK.Tabla CHE_SOLICITUD_CANJE_INTERNO con SALDOS ''
-------------------------------- CLEARING OTRO BANCO
if exists (	select a.CODIGO_RECHAZO  
				from CLE_RECEPCION_DPF_DEV a with(nolock)
				left join CLE_DPF_SALIENTE b with(nolock) on a.SUCURSAL_BANCO_GIRADO = b.SUCURSAL_BANCO_GIRADO
												and a.BANCO_GIRADO = b.BANCO_GIRADO
												and a.NUMERO_DPF = b.NUMERO_DPF
				where a.SUCURSAL_BANCO_GIRADO is null
					and a.BANCO_GIRADO is null
					and a.NUMERO_DPF is null

			)	
				SELECT   ''Tabla CLE_RECEPCION_DPF_DEV no se ajusta a la integridad referencial con CLE_DPF_SALIENTE '',*
				from CLE_RECEPCION_DPF_DEV a with(nolock)
				left join CLE_DPF_SALIENTE b with(nolock) on a.SUCURSAL_BANCO_GIRADO = b.SUCURSAL_BANCO_GIRADO
												and a.BANCO_GIRADO = b.BANCO_GIRADO
												and a.NUMERO_DPF = b.NUMERO_DPF
				where a.SUCURSAL_BANCO_GIRADO is null
					and a.BANCO_GIRADO is null
					and a.NUMERO_DPF is null
	else
	print ''Comprobación OK.Tabla CLE_RECEPCION_DPF_DEV con CLE_DPF_SALIENTE ''

	if exists (	select a.NRO_ASIENTO 
				from CLE_CHEQUES_AJUSTE a with(nolock) 
				left join CLE_CHEQUES_AJUSTE_AUX b with(nolock) on a.ORDINAL = b.ORDINAL
													and a.BANCO = b.BANCO_GIRADO
													and a.FECHA_ALTA = b.FECHA_ALTA
				where a.ORDINAL is null
					and a.banco is null
					and a.FECHA_ALTA is null
			)	
				SELECT   ''Tabla CLE_CHEQUES_AJUSTE no se ajusta a la integridad referencial con CLE_CHEQUES_AJUSTE_AUX '',*
				from CLE_CHEQUES_AJUSTE a with(nolock) 
				left join CLE_CHEQUES_AJUSTE_AUX b with(nolock) on a.ORDINAL = b.ORDINAL
													and a.BANCO = b.BANCO_GIRADO
													and a.FECHA_ALTA = b.FECHA_ALTA
				where a.ORDINAL is null
					and a.banco is null
					and a.FECHA_ALTA is null
	else
	print ''Comprobación OK.Tabla CLE_CHEQUES_AJUSTE con CLE_CHEQUES_AJUSTE_AUX ''
	if exists (	select a.NUMERO_CHEQUE 
				from CLE_RECEPCION_CHEQUES_DEV a with(nolock)
				left join CLE_CHEQUES_ENVIADOS b with(nolock) on a.SUCURSAL_BANCO_GIRADO = b.SUCURSAL
													and a.SERIE_DEL_CHEQUE = b.SERIE_DEL_CHEQUE
													and a.BANCO_GIRADO = b.COD_BANCO
													and a.NUMERO_CHEQUE = b.NUMERO_DEL_CHEQUE
													and a.TIPO_DOCUMENTO = b.TIPO_DOCUMENTO
													and a.NUMERO_CUENTA_GIRADORA = b.NUMERO_CUENTA_GIRADORA
				where a.SUCURSAL_BANCO_GIRADO is null
					and a.SERIE_DEL_CHEQUE is null
					and a.BANCO_GIRADO is null
					and a.NUMERO_CHEQUE is null
					and a.TIPO_DOCUMENTO is null
					and a.NUMERO_CUENTA_GIRADORA is null

			)	
				SELECT   ''Tabla CLE_RECEPCION_CHEQUES_DEV no se ajusta a la integridad referencial con CLE_CHEQUES_ENVIADOS '',*
				from CLE_RECEPCION_CHEQUES_DEV a with(nolock)
				left join CLE_CHEQUES_ENVIADOS b with(nolock) on a.SUCURSAL_BANCO_GIRADO = b.SUCURSAL
													and a.SERIE_DEL_CHEQUE = b.SERIE_DEL_CHEQUE
													and a.BANCO_GIRADO = b.COD_BANCO
													and a.NUMERO_CHEQUE = b.NUMERO_DEL_CHEQUE
													and a.TIPO_DOCUMENTO = b.TIPO_DOCUMENTO
													and a.NUMERO_CUENTA_GIRADORA = b.NUMERO_CUENTA_GIRADORA
				where a.SUCURSAL_BANCO_GIRADO is null
					and a.SERIE_DEL_CHEQUE is null
					and a.BANCO_GIRADO is null
					and a.NUMERO_CHEQUE is null
					and a.TIPO_DOCUMENTO is null
					and a.NUMERO_CUENTA_GIRADORA is null
	else
	print ''Comprobación OK.Tabla CLE_RECEPCION_CHEQUES_DEV con CLE_CHEQUES_ENVIADOS ''
	if exists (	select a.NUMERO_CHEQUE
				from CLE_CHEQUES_SALIENTE_HTO a with(nolock)
				left join CLE_CHEQUES_SALIENTE b with(nolock) on a.SERIE_DEL_CHEQUE = b.SERIE_DEL_CHEQUE
												and a.NUMERO_CHEQUE = b.NUMERO_CHEQUE
												and a.SUCURSAL_BANCO_GIRADO = b.SUCURSAL_BANCO_GIRADO
												and a.BANCO_GIRADO = b.BANCO_GIRADO
												and a.NUMERICO_CUENTA_GIRADORA = b.NUMERICO_CUENTA_GIRADORA
												and a.TIPO_DOCUMENTO = b.TIPO_DOCUMENTO
				where a.SERIE_DEL_CHEQUE is null
				and a.NUMERO_CHEQUE is null
				and a.SUCURSAL_BANCO_GIRADO is null
				and a.BANCO_GIRADO is null
				and a.NUMERICO_CUENTA_GIRADORA is null
				and a.TIPO_DOCUMENTO is null

			)	
				SELECT   ''Tabla CLE_CHEQUES_SALIENTE_HTO no se ajusta a la integridad referencial con CLE_CHEQUES_SALIENTE '',*
				from CLE_CHEQUES_SALIENTE_HTO a with(nolock)
				left join CLE_CHEQUES_SALIENTE b with(nolock) on a.SERIE_DEL_CHEQUE = b.SERIE_DEL_CHEQUE
												and a.NUMERO_CHEQUE = b.NUMERO_CHEQUE
												and a.SUCURSAL_BANCO_GIRADO = b.SUCURSAL_BANCO_GIRADO
												and a.BANCO_GIRADO = b.BANCO_GIRADO
												and a.NUMERICO_CUENTA_GIRADORA = b.NUMERICO_CUENTA_GIRADORA
												and a.TIPO_DOCUMENTO = b.TIPO_DOCUMENTO
				where a.SERIE_DEL_CHEQUE is null
				and a.NUMERO_CHEQUE is null
				and a.SUCURSAL_BANCO_GIRADO is null
				and a.BANCO_GIRADO is null
				and a.NUMERICO_CUENTA_GIRADORA is null
				and a.TIPO_DOCUMENTO is null
	else
	print ''Comprobación OK.Tabla CLE_CHEQUES_SALIENTE_HTO con CLE_CHEQUES_SALIENTE ''
	if exists (select a.NRO_CHEQUE 
				from ITF_COELSA_CHEQUES_OTROS a with(nolock)
				left join CLE_CHEQUES_SALIENTE b with(nolock) on a.SERIE_DEL_CHEQUE = b.SERIE_DEL_CHEQUE
													and a.NRO_CHEQUE = b.NUMERO_CHEQUE
													and a.BANCO = b.BANCO_GIRADO
													and a.SUCURSAL = b.SUCURSAL_BANCO_GIRADO
													and a.CUENTA = b.NUMERICO_CUENTA_GIRADORA
													and a.TIPO_DOCUMENTO = b.TIPO_DOCUMENTO
				where a.SERIE_DEL_CHEQUE is null
					and a.NRO_CHEQUE is null
					and a.BANCO is null
					and a.SUCURSAL is null
					and a.CUENTA is null
					and a.TIPO_DOCUMENTO is null

			)	
				SELECT   ''Tabla ITF_COELSA_CHEQUES_OTROS no se ajusta a la integridad referencial con CLE_CHEQUES_SALIENTE '',*
				from ITF_COELSA_CHEQUES_OTROS a with(nolock)
				left join CLE_CHEQUES_SALIENTE b with(nolock) on a.SERIE_DEL_CHEQUE = b.SERIE_DEL_CHEQUE
													and a.NRO_CHEQUE = b.NUMERO_CHEQUE
													and a.BANCO = b.BANCO_GIRADO
													and a.SUCURSAL = b.SUCURSAL_BANCO_GIRADO
													and a.CUENTA = b.NUMERICO_CUENTA_GIRADORA
													and a.TIPO_DOCUMENTO = b.TIPO_DOCUMENTO
				where a.SERIE_DEL_CHEQUE is null
					and a.NRO_CHEQUE is null
					and a.BANCO is null
					and a.SUCURSAL is null
					and a.CUENTA is null
					and a.TIPO_DOCUMENTO is null
	else
	print ''Comprobación OK.Tabla ITF_COELSA_CHEQUES_OTROS con CLE_CHEQUES_SALIENTE ''
	if exists (	select a.NUMERO_DEL_CHEQUE 
				from CLE_CHEQUES_ENVIADOS a with(nolock)
				left join CLE_CHEQUES_SALIENTE b with(nolock) on a.TIPO_DOCUMENTO = b.TIPO_DOCUMENTO
													and a.SERIE_DEL_CHEQUE = b.SERIE_DEL_CHEQUE
													and a.NUMERO_DEL_CHEQUE = b.NUMERO_CHEQUE
													and a.COD_BANCO = b.BANCO_GIRADO
													and a.NUMERO_CUENTA_GIRADORA = b.NUMERICO_CUENTA_GIRADORA
													and a.SUCURSAL = b.SUCURSAL_BANCO_GIRADO
				where a.TIPO_DOCUMENTO is null
					and a.SERIE_DEL_CHEQUE is null
					and a.NUMERO_DEL_CHEQUE is null
					and a.COD_BANCO is null
					and a.NUMERO_CUENTA_GIRADORA is null
					and a.SUCURSAL is null

			)	
				SELECT    ''Tabla CLE_CHEQUES_ENVIADOS no se ajusta a la integridad referencial con CLE_CHEQUES_SALIENTE '',*
				from CLE_CHEQUES_ENVIADOS a with(nolock)
				left join CLE_CHEQUES_SALIENTE b with(nolock) on a.TIPO_DOCUMENTO = b.TIPO_DOCUMENTO
													and a.SERIE_DEL_CHEQUE = b.SERIE_DEL_CHEQUE
													and a.NUMERO_DEL_CHEQUE = b.NUMERO_CHEQUE
													and a.COD_BANCO = b.BANCO_GIRADO
													and a.NUMERO_CUENTA_GIRADORA = b.NUMERICO_CUENTA_GIRADORA
													and a.SUCURSAL = b.SUCURSAL_BANCO_GIRADO
				where a.TIPO_DOCUMENTO is null
					and a.SERIE_DEL_CHEQUE is null
					and a.NUMERO_DEL_CHEQUE is null
					and a.COD_BANCO is null
					and a.NUMERO_CUENTA_GIRADORA is null
					and a.SUCURSAL is null
	else
	print ''Comprobación OK.Tabla CLE_CHEQUES_ENVIADOS con CLE_CHEQUES_SALIENTE ''

--------------------------------OPERACIONES/DEBITOS
	if exists (	select a.CODIGO_CLIENTE 
				from SNP_STOP_DEBIT a with(nolock) 
				where a.CODIGO_CLIENTE not in (	select b.CODIGOCLIENTE 
												from CLI_CLIENTES b with(nolock))

			)	
				SELECT    ''Tabla SNP_STOP_DEBIT no se ajusta a la integridad referencial con CLI_CLIENTES '',*
				from SNP_STOP_DEBIT a with(nolock) 
				where a.CODIGO_CLIENTE not in (	select b.CODIGOCLIENTE 
												from CLI_CLIENTES b with(nolock))
	else
	print ''Comprobación OK.Tabla SNP_STOP_DEBIT con CLI_CLIENTES ''
	if exists (	select a.CODIGO_CLIENTE 
				from SNP_MSG_ORDENES a with(nolock) 
				where a.CODIGO_CLIENTE not in (	select b.CODIGOCLIENTE 
												from CLI_CLIENTES b with(nolock))

			)	
				SELECT    ''Tabla SNP_MSG_ORDENES no se ajusta a la integridad referencial con CLI_CLIENTES '',*
				from SNP_MSG_ORDENES a with(nolock) 
				where a.CODIGO_CLIENTE not in (	select b.CODIGOCLIENTE 
												from CLI_CLIENTES b with(nolock))
	else
	print ''Comprobación OK.Tabla SNP_MSG_ORDENES con CLI_CLIENTES ''

	if exists (	select a.CLIENTE 
				from CONV_CONVENIOS_REC a with(nolock) 
				where a.CLIENTE not in (	select b.CODIGOCLIENTE 
												from CLI_CLIENTES b with(nolock))

			)	
				SELECT    ''Tabla CONV_CONVENIOS_REC no se ajusta a la integridad referencial con CLI_CLIENTES '',*
				from CONV_CONVENIOS_REC a with(nolock) 
				where a.CLIENTE not in (	select b.CODIGOCLIENTE 
												from CLI_CLIENTES b with(nolock))
	else
	print ''Comprobación OK.Tabla CONV_CONVENIOS_REC con CLI_CLIENTES ''

	if exists (	select a.CUIT_EO 
				from SNP_DEBITOS a with(nolock) 
				where a.CUIT_EO not in (	select b.CUIT_EO 
												from SNP_MSG_ORDENES b with(nolock))

			)	
				SELECT    ''Tabla SNP_DEBITOS no se ajusta a la integridad referencial con SNP_MSG_ORDENES '',*
				from SNP_DEBITOS a with(nolock) 
				where a.CUIT_EO not in (	select b.CUIT_EO 
												from SNP_MSG_ORDENES b with(nolock))
	else
	print ''Comprobación OK.Tabla SNP_DEBITOS con SNP_MSG_ORDENES ''
------------------------------------ OPERACIONES/DEBITOS AUTOMATICOS
	if exists (	select a.CONVENIO 
				from REC_CAB_DEBITOSAUTOMATICOS a with(nolock) 
				where a.CONVENIO not in (	select b.Id_ConvRec 
												from CONV_CONVENIOS_REC b with(nolock))

			)	
				SELECT    ''Tabla REC_CAB_DEBITOSAUTOMATICOS no se ajusta a la integridad referencial con CONV_CONVENIOS_REC '',*
				from REC_CAB_DEBITOSAUTOMATICOS a with(nolock) 
				where a.CONVENIO not in (	select b.Id_ConvRec 
												from CONV_CONVENIOS_REC b with(nolock))
	else
	print ''Comprobación OK.Tabla REC_CAB_DEBITOSAUTOMATICOS con CONV_CONVENIOS_REC ''

	if exists (	select a.ID_CABEZAL 
				from REC_DET_DEBITOSAUTOMATICOS a with(nolock) 
				where a.ID_CABEZAL not in (	select b.id 
												from REC_CAB_DEBITOSAUTOMATICOS b with(nolock))

			)	
				SELECT    ''Tabla REC_DET_DEBITOSAUTOMATICOS no se ajusta a la integridad referencial con REC_CAB_DEBITOSAUTOMATICOS '',*
				from REC_DET_DEBITOSAUTOMATICOS a with(nolock) 
				where a.ID_CABEZAL not in (	select b.id 
												from REC_CAB_DEBITOSAUTOMATICOS b with(nolock))
	else
	print ''Comprobación OK.Tabla REC_DET_DEBITOSAUTOMATICOS con REC_CAB_DEBITOSAUTOMATICOS ''

	if exists (	select a.ID_CABEZAL 
				from REC_LIQUIDACION a with(nolock) 
				where a.ID_CABEZAL not in (	select b.ID_CABEZAL
												from REC_DET_DEBITOSAUTOMATICOS b with(nolock))

			)	
				SELECT    ''Tabla REC_LIQUIDACION no se ajusta a la integridad referencial con REC_DET_DEBITOSAUTOMATICOS '',*
				from REC_LIQUIDACION a with(nolock) 
				where a.ID_CABEZAL not in (	select b.ID_CABEZAL
												from REC_DET_DEBITOSAUTOMATICOS b with(nolock))
	else
	print ''Comprobación OK.Tabla REC_LIQUIDACION con REC_DET_DEBITOSAUTOMATICOS ''
--------------------------------------OPERACIONES/CONVENIOS DE PAGOS
	if exists (	SELECT * 
				FROM CONV_MEDIOPAGO b with (nolock)
				left join CONV_CONVENIOS_PAG a with (nolock) on a.ID_ConvPago = b.ID_ConvPago
				where a.ID_ConvPago is null
		)	
				SELECT ''Tabla CONV_MEDIOPAGO no se ajusta a la integridad referencial con CONV_CONVENIOS_PAG '',*
				FROM CONV_MEDIOPAGO b with (nolock)
				left join CONV_CONVENIOS_PAG a with (nolock) on a.ID_ConvPago = b.ID_ConvPago
				where a.ID_ConvPago is null
	else
		print ''Comprobación OK.Tabla CONV_MEDIOPAGO con CONV_CONVENIOS_PAG ''
	if exists (	SELECT * 
				FROM CONV_BITACORA b with (nolock)
				left join CONV_CONVENIOS_PAG a with (nolock) on a.ID_ConvPago = b.ID_CONVENIO
				where a.ID_ConvPago is null
		)	
				SELECT ''Tabla CONV_BITACORA no se ajusta a la integridad referencial con CONV_CONVENIOS_PAG '',*
				FROM CONV_BITACORA b with (nolock)
				left join CONV_CONVENIOS_PAG a with (nolock) on a.ID_ConvPago = b.ID_CONVENIO
				where a.ID_ConvPago is null
	else
		print ''Comprobación OK.Tabla CONV_BITACORA con CONV_CONVENIOS_PAG ''
	if exists (	SELECT * 
				FROM CONV_CONVENIOS_MORA b with (nolock)
				left join CONV_CONVENIOS_REC a with (nolock) on a.Id_ConvRec = b.ID_CONVENIO
				where a.Id_ConvRec is null
		)	
				SELECT ''Tabla CONV_CONVENIOS_MORA no se ajusta a la integridad referencial con CONV_CONVENIOS_REC '',*
				FROM CONV_CONVENIOS_MORA b with (nolock)
				left join CONV_CONVENIOS_REC a with (nolock) on a.Id_ConvRec = b.ID_CONVENIO
				where a.Id_ConvRec is null
	else
		print ''Comprobación OK.Tabla CONV_CONVENIOS_MORA con CONV_CONVENIOS_REC ''
	if exists (	SELECT * 
				FROM CONV_CB_CAMPOS b with (nolock)
				left join CONV_CB_ESTRUCTURA a with (nolock) on a.ID_CODIGO_BARRAS = b.ID_CODIGO_BARRAS
				where a.ID_CODIGO_BARRAS is null
		)	
				SELECT ''Tabla CONV_CB_CAMPOS no se ajusta a la integridad referencial con CONV_CB_ESTRUCTURA '',*
				FROM CONV_CB_CAMPOS b with (nolock)
				left join CONV_CB_ESTRUCTURA a with (nolock) on a.ID_CODIGO_BARRAS = b.ID_CODIGO_BARRAS
				where a.ID_CODIGO_BARRAS is null
	else
		print ''Comprobación OK.Tabla CONV_CB_CAMPOS con CONV_CB_ESTRUCTURA ''
	if exists (	SELECT * 
				FROM CONV_CONVENIOS_MORA b with (nolock)
				left join CONV_CONVENIOS_PAG a with (nolock) on a.ID_ConvPago = b.ID_CONVENIO
				where a.ID_ConvPago is null
		)	
				SELECT ''Tabla CONV_CONVENIOS_MORA no se ajusta a la integridad referencial con CONV_CONVENIOS_PAG '',*
				FROM CONV_CONVENIOS_MORA b with (nolock)
				left join CONV_CONVENIOS_PAG a with (nolock) on a.ID_ConvPago = b.ID_CONVENIO
				where a.ID_ConvPago is null
	else
		print ''Comprobación OK.Tabla CONV_CONVENIOS_MORA con CONV_CONVENIOS_PAG ''
----------------------------OPERACIONES/CONVENIOS DE RECAUDACIONES
	if exists (	SELECT * 
				FROM CONV_CONVENIOS_REC b with (nolock)
				left join CONV_TIPOS a with (nolock) on a.Id_TpoConv = b.Id_TpoConv 
				where a.Id_TpoConv is null
			)	
				SELECT ''Tabla CONV_CONVENIOS_REC no se ajusta a la integridad referencial con CONV_TIPOS '',*
				FROM CONV_CONVENIOS_REC b with (nolock)
				left join CONV_TIPOS a with (nolock) on a.Id_TpoConv = b.Id_TpoConv 
				where a.Id_TpoConv is null
	else
		print ''Comprobación OK.Tabla CONV_CONVENIOS_REC con CONV_TIPOS ''
	if exists (	SELECT * 
				FROM CONV_BITACORA b with (nolock)
				left join CONV_CONVENIOS_REC a with (nolock) on a.Id_TpoConv = b.Id_Convenio
				where a.Id_TpoConv is null
			)	
				SELECT ''Tabla CONV_BITACORA no se ajusta a la integridad referencial con CONV_CONVENIOS_REC '',*
				FROM CONV_BITACORA b with (nolock)
				left join CONV_CONVENIOS_REC a with (nolock) on a.Id_TpoConv = b.Id_Convenio
				where a.Id_TpoConv is null
	else
		print ''Comprobación OK.Tabla CONV_BITACORA con CONV_CONVENIOS_REC ''
	if exists (	SELECT * 
				FROM CONV_CB_ESTRUCTURA b with (nolock)
				left join CONV_CONVENIOS_REC a with (nolock) on a.Id_TpoConv = b.Id_Convenio
				where a.Id_TpoConv is null
			)	
				SELECT ''Tabla CONV_CB_ESTRUCTURA no se ajusta a la integridad referencial con CONV_CONVENIOS_REC '',*
				FROM CONV_CB_ESTRUCTURA b with (nolock)
				left join CONV_CONVENIOS_REC a with (nolock) on a.Id_TpoConv = b.Id_Convenio
				where a.Id_TpoConv is null
	else
		print ''Comprobación OK.Tabla CONV_CB_ESTRUCTURA con CONV_CONVENIOS_REC ''
	if exists (	SELECT * 
				FROM CONV_CB_CAMPOS b with (nolock)
				left join CONV_CB_ESTRUCTURA a with (nolock) on a.ID_REFERENCIA = b.ID_CODIGO_BARRAS
				where a.ID_REFERENCIA is null
		)	
				SELECT ''Tabla CONV_CB_CAMPOS no se ajusta a la integridad referencial con CONV_CB_ESTRUCTURA '',*
				FROM CONV_CB_CAMPOS b with (nolock)
				left join CONV_CB_ESTRUCTURA a with (nolock) on a.ID_REFERENCIA = b.ID_CODIGO_BARRAS
				where a.ID_REFERENCIA is null
	else
		print ''Comprobación OK.Tabla CONV_CB_CAMPOS con CONV_CB_ESTRUCTURA ''
	if exists (	SELECT * 
				FROM REC_CAB_RECAUDOS_CANAL b with (nolock)
				left join REC_DET_RECAUDOS_CANAL a with (nolock) on a.ID_CABEZAL = b.ID
				where a.ID_CABEZAL is null
		)	
				SELECT ''Tabla REC_CAB_RECAUDOS_CANAL no se ajusta a la integridad referencial con REC_DET_RECAUDOS_CANAL '',*
				FROM REC_CAB_RECAUDOS_CANAL b with (nolock)
				left join REC_DET_RECAUDOS_CANAL a with (nolock) on a.ID_CABEZAL = b.ID
				where a.ID_CABEZAL is null
	else
		print ''Comprobación OK.Tabla REC_CAB_RECAUDOS_CANAL con REC_DET_RECAUDOS_CANAL ''
	if exists (	SELECT * 
				FROM REC_LIQUIDACION b with (nolock)
				left join REC_RENDICION a with (nolock) on a.ID_RENDICION = b.ID_RENDICION
				where a.ID_RENDICION is null
		)	
				SELECT ''Tabla REC_LIQUIDACION no se ajusta a la integridad referencial con REC_RENDICION '',*
				FROM REC_LIQUIDACION b with (nolock)
				left join REC_RENDICION a with (nolock) on a.ID_RENDICION = b.ID_RENDICION
				where a.ID_RENDICION is null
	else
		print ''Comprobación OK.Tabla REC_LIQUIDACION con REC_RENDICION ''
	if exists (	SELECT * 
				FROM REC_CAB_RECAUDOS_CAJA b with (nolock)
				left join REC_DET_RECAUDOS_CAJA a with (nolock) on a.ID_CABEZAL = b.ID
				where a.ID_CABEZAL is null
		)	
				SELECT ''Tabla REC_CAB_RECAUDOS_CAJA no se ajusta a la integridad referencial con REC_DET_RECAUDOS_CAJA '',*
				FROM REC_CAB_RECAUDOS_CAJA b with (nolock)
				left join REC_DET_RECAUDOS_CAJA a with (nolock) on a.ID_CABEZAL = b.ID
				where a.ID_CABEZAL is null
	else
		print ''Comprobación OK.Tabla REC_CAB_RECAUDOS_CAJA con REC_DET_RECAUDOS_CAJA ''
	if exists (	SELECT * 
				FROM CONV_DOMINIOS b with (nolock)
				left join CONV_CONVENIOS_REC a with (nolock) on a.Id_ConvRec = b.ID_CONVENIO
				where a.Id_ConvRec is null
		)	
				SELECT ''Tabla CONV_DOMINIOS no se ajusta a la integridad referencial con CONV_CONVENIOS_REC '',*
				FROM CONV_DOMINIOS b with (nolock)
				left join CONV_CONVENIOS_REC a with (nolock) on a.Id_ConvRec = b.ID_CONVENIO
				where a.Id_ConvRec is null
	else
		print ''Comprobación OK.Tabla CONV_DOMINIOS con CONV_CONVENIOS_REC ''

--------------------------------------OPERACIONES/TRANSFERENCIAS

	END
ELSE
	print ''NO CORRESPONDE LA BASE DE DATOS''
END
;')