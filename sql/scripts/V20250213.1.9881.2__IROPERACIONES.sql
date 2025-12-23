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

-------------------------------Debitos Directos

	if exists (	select b.id_convenio
				from SNP_PRESTACIONES_EMPRESAS b with(nolock) 
				where b.id_convenio not in(select a.id_convRec 
										from CONV_CONVENIOS_REC  A with(nolock))
				)	
				SELECT   ''Tabla SNP_PRESTACIONES_EMPRESAS no se ajusta a la integridad referencial con Tabla CONV_CONVENIOS_REC'',*
				from SNP_PRESTACIONES_EMPRESAS b with(nolock) 
				where b.id_convenio not in(select a.id_convRec 
										from CONV_CONVENIOS_REC  A with(nolock))
	else
	print ''Comprobación OK.Tabla SNP_PRESTACIONES_EMPRESAS con Tabla CONV_CONVENIOS_REC''

	if exists (select b.saldo_jts_oid 
				from SNP_DEBITOS b with(nolock) 
				where b.saldo_jts_oid not in(select a.jts_oid 
										from SALDOS  A with(nolock))
				)	
				SELECT   ''Tabla SNP_DEBITOS no se ajusta a la integridad referencial con Tabla SALDOS'',*
				from SNP_DEBITOS b with(nolock) 
				where b.saldo_jts_oid not in(select a.jts_oid 
										from SALDOS  A with(nolock))
	else
	print ''Comprobación OK.Tabla SNP_DEBITOS con Tabla SALDOS''

	if exists (select b.saldo_jts_oid 
				from SNP_STOP_DEBIT b with(nolock) 
				where b.saldo_jts_oid not in(select a.jts_oid 
										from SALDOS  A with(nolock))
				)	
				SELECT   ''Tabla SNP_STOP_DEBIT no se ajusta a la integridad referencial con Tabla SALDOS'',*
				from SNP_STOP_DEBIT b with(nolock) 
				where b.saldo_jts_oid not in(select a.jts_oid 
										from SALDOS  A with(nolock))
	else
	print ''Comprobación OK.Tabla SNP_STOP_DEBIT con Tabla SALDOS''


-------------------------------Depositos Judiciales

	if exists (select b.NRO_CAUSA 
				from DJ_INTEGRANTES_CAUSAS b with(nolock) 
				where b.NRO_CAUSA not in(select a.NRO_CAUSA 
										from DJ_CAUSAS  A with(nolock))
				)	
				SELECT   ''Tabla DJ_INTEGRANTES_CAUSAS no se ajusta a la integridad referencial con Tabla DJ_CAUSAS'',*
				from DJ_INTEGRANTES_CAUSAS b with(nolock) 
				where b.NRO_CAUSA not in(select a.NRO_CAUSA 
										from DJ_CAUSAS  A with(nolock))
	else
	print ''Comprobación OK.Tabla DJ_INTEGRANTES_CAUSAS con Tabla DJ_CAUSAS''


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
				from DJ_SOLICITUD_AD_INTEG_JUZ b with(nolock) 
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


	if exists (select b.ID_TARJETA 
				from BITACORA_TARJETA_DEBITO b with(nolock) 
				where b.ID_TARJETA not in(select a.NRO_TARJETA_BASE 
										from TJD_SOLICITUD_LINK  A with(nolock))
				)	
				SELECT   ''Tabla BITACORA_TARJETA_DEBITO no se ajusta a la integridad referencial con Tabla TJD_SOLICITUD_LINK'',*
				from BITACORA_TARJETA_DEBITO b with(nolock) 
				where b.ID_TARJETA not in(select a.NRO_TARJETA_BASE 
										from TJD_SOLICITUD_LINK  A with(nolock))
	else
	print ''Comprobación OK.Tabla BITACORA_TARJETA_DEBITO con Tabla TJD_SOLICITUD_LINK''


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
				where b.COD_OPERACION not in(select a.COD_PERMISO 
										from TJD_PERMISOS  A with(nolock))
				)	
				SELECT   ''Tabla TJD_TIPO_COD_OPERACION no se ajusta a la integridad referencial con Tabla TJD_PERMISOS'',*
				from TJD_TIPO_COD_OPERACION b with(nolock) 
				where b.COD_OPERACION not in(select a.COD_PERMISO 
										from TJD_PERMISOS  A with(nolock))
	else
	print ''Comprobación OK.Tabla TJD_TIPO_COD_OPERACION con Tabla TJD_PERMISOS''

	if exists (select b.PERMISO 
				from TJD_TARJETAS b with(nolock) 
				where b.PERMISO not in(select a.COD_PERMISO 
										from TJD_PERMISOS  A with(nolock))
				)	
				SELECT   ''Tabla TJD_TARJETAS no se ajusta a la integridad referencial con Tabla TJD_PERMISOS'',*
				from TJD_TARJETAS b with(nolock) 
				where b.PERMISO not in(select a.COD_PERMISO 
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
				from TJD_REL_TARJETA_CUENTA b with(nolock) 
				where b.ESTADO not in(select a.ESTADO 
										from TJD_ESTADO_TARJETA_CUENTA  A with(nolock))
				)	
				SELECT   ''Tabla TJD_REL_TARJETA_CUENTA no se ajusta a la integridad referencial con Tabla TJD_ESTADO_TARJETA_CUENTA'',*
				from TJD_REL_TARJETA_CUENTA b with(nolock) 
				where b.ESTADO not in(select a.ESTADO 
										from TJD_ESTADO_TARJETA_CUENTA  A with(nolock))
	else
	print ''Comprobación OK.Tabla TJD_REL_TARJETA_CUENTA con Tabla TJD_ESTADO_TARJETA_CUENTA''

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

	if exists (select b.ID_SOLICITUD 
				from TJD_SOLICITUD_LINK b with(nolock) 
				where b.TIPO_SOLICITUD <> ''200000'' and b.ID_SOLICITUD not in(select a.ID 
																			from TJD_SOLICITUD_DIRECCIONES_LINK  A with(nolock))
				)	
				SELECT   ''Tabla TJD_SOLICITUD_LINK no se ajusta a la integridad referencial con Tabla TJD_SOLICITUD_DIRECCIONES_LINK'',*
				from TJD_SOLICITUD_LINK b with(nolock) 
				where b.TIPO_SOLICITUD <> ''200000'' and b.ID_SOLICITUD not in(select a.ID 
																			from TJD_SOLICITUD_DIRECCIONES_LINK  A with(nolock))
	else
	print ''Comprobación OK.Tabla TJD_SOLICITUD_LINK con Tabla TJD_SOLICITUD_DIRECCIONES_LINK''

	if exists (select b.ID_SOLICITUD 
				from TJD_SOLICITUD_LINK b with(nolock) 
				where b.TIPO_SOLICITUD<> ''200000'' and b.ID_SOLICITUD not in(select a.ID_SOLICITUD
																			from TJD_SOLICITUD_CUENTAS_LINK  A with(nolock))
				)	
				SELECT   ''Tabla TJD_SOLICITUD_LINK no se ajusta a la integridad referencial con Tabla TJD_SOLICITUD_CUENTAS_LINK'',*
				from TJD_SOLICITUD_LINK b with(nolock) 
				where b.TIPO_SOLICITUD<> ''200000'' and b.ID_SOLICITUD not in(select a.ID_SOLICITUD
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
--------------------------------Cheques Propios
	if exists (	select b.NRO_SOLICITUD 
				from CHE_CHEQUES b with(nolock)
				where NRO_SOLICITUD <>0 AND NRO_SOLICITUD not in(	select NRO_SOLICITUD 
																	from CHE_SOLICITUD_CANJE_INTERNO a with(nolock))
			)	
				SELECT   ''Tabla CHE_CHEQUES no se ajusta a la integridad referencial con CHE_SOLICITUD_CANJE_INTERNO '',*
				from CHE_CHEQUES b with(nolock)
				where NRO_SOLICITUD <>0 AND NRO_SOLICITUD not in(	select NRO_SOLICITUD 
																	from CHE_SOLICITUD_CANJE_INTERNO a with(nolock))
	else
	print ''Comprobación OK.Tabla CHE_CHEQUES con CHE_SOLICITUD_CANJE_INTERNO ''

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

	if exists (	select a.CLIENTE 
				from CHE_BCO_RECHAZADOS a with(nolock)
				left join CLE_CHEQUES_CLEARING_DEVUELTOS b with(nolock) on a.SUCURSAL = b.SUCURSAL
															and a.SERIE_CHEQUE = b.SERIE
															and a.NRO_CHEQUE = b.NROCHEQUE
															and a.MONEDA = b.MONEDA
															and a.PRODUCTO = b.PRODUCTO
															and a.CUENTA = b.CUENTA
															and a.FECHA_CHEQUE = b.FECHACHEQUE
				where b.SUCURSAL is null
					and b.SERIE is null
					and b.NROCHEQUE is null
					and b.MONEDA is null
					and b.PRODUCTO is null
					and b.CUENTA is null
					and b.FECHACHEQUE is null
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
				where b.SUCURSAL is null
					and b.SERIE is null
					and b.NROCHEQUE is null
					and b.MONEDA is null
					and b.PRODUCTO is null
					and b.CUENTA is null
					and b.FECHACHEQUE is null
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
-------------------------------- CLEARING PROPIOS
	if exists (select b.CODIGO_CAUSAL_DEVOLUCION 
				from CLE_CHEQUES_CLEARING_RECIBIDO b with(nolock) 
				where b.CODIGO_CAUSAL_DEVOLUCION <> 0 and b.CODIGO_CAUSAL_DEVOLUCION not in(select a.CODIGO_DE_CAUSAL
										from CLE_TIPO_CAUSAL A with(nolock))
				)	
				SELECT   ''Tabla CLE_CHEQUES_CLEARING_RECIBIDO no se ajusta a la integridad referencial con Tabla CLE_TIPO_CAUSAL'',*
				from CLE_CHEQUES_CLEARING_RECIBIDO b with(nolock) 
				where b.CODIGO_CAUSAL_DEVOLUCION <> 0 and b.CODIGO_CAUSAL_DEVOLUCION not in(select a.CODIGO_DE_CAUSAL
										from CLE_TIPO_CAUSAL A with(nolock))
	else
	print ''Comprobación OK.Tabla CLE_CHEQUES_CLEARING_RECIBIDO con Tabla CLE_TIPO_CAUSAL''

	if exists (select b.concdevolucion 
				from CLE_CHEQUES_CLEARING_DEVUELTOS b with(nolock) 
				where b.concdevolucion not in(select a.CODIGO_DE_CAUSAL
										from CLE_TIPO_CAUSAL A with(nolock))
				)	
				SELECT   ''Tabla CLE_CHEQUES_CLEARING_DEVUELTOS no se ajusta a la integridad referencial con Tabla CLE_TIPO_CAUSAL'',*
				from CLE_CHEQUES_CLEARING_DEVUELTOS b with(nolock) 
				where b.concdevolucion not in(select a.CODIGO_DE_CAUSAL
										from CLE_TIPO_CAUSAL A with(nolock))
	else
	print ''Comprobación OK.Tabla CLE_CHEQUES_CLEARING_DEVUELTOS con Tabla CLE_TIPO_CAUSAL''

	if exists (select b.CODIGO_CAUSAL 
				from CLE_CONTROLES_RECIBIDO b with(nolock) 
				where b.CODIGO_CAUSAL not in(select a.CODIGO_DE_CAUSAL
										from CLE_TIPO_CAUSAL A with(nolock))
				)	
				SELECT   ''Tabla CLE_CONTROLES_RECIBIDO no se ajusta a la integridad referencial con Tabla CLE_TIPO_CAUSAL'',*
				from CLE_CONTROLES_RECIBIDO b with(nolock) 
				where b.CODIGO_CAUSAL not in(select a.CODIGO_DE_CAUSAL
										from CLE_TIPO_CAUSAL A with(nolock))
	else
	print ''Comprobación OK.Tabla CLE_CONTROLES_RECIBIDO con Tabla CLE_TIPO_CAUSAL''
-------------------------------- CLEARING OTRO BANCO

	if exists (	select b.numero_deposito 
				from CLE_CHEQUES_SALIENTE b with(nolock) 
				where b.numero_deposito not in(	select a.numero_deposito
												from CLE_DEPOSITOS A with(nolock))
				)	
				SELECT   ''Tabla CLE_CHEQUES_SALIENTE no se ajusta a la integridad referencial con Tabla CLE_DEPOSITOS'',*
				from CLE_CHEQUES_SALIENTE b with(nolock) 
				where b.numero_deposito not in(select a.numero_deposito
										from CLE_DEPOSITOS A with(nolock))
	else
	print ''Comprobación OK.Tabla CLE_CHEQUES_SALIENTE con Tabla CLE_DEPOSITOS''

	if exists (select b.numero_deposito 
				from CLE_DPF_SALIENTE b with(nolock) 
				where b.numero_deposito not in(select a.numero_deposito
										from CLE_DEPOSITOS A with(nolock))
				)	
				SELECT   ''Tabla CLE_DPF_SALIENTE no se ajusta a la integridad referencial con Tabla CLE_DEPOSITOS'',*
				from CLE_DPF_SALIENTE b with(nolock) 
				where b.numero_deposito not in(select a.numero_deposito
										from CLE_DEPOSITOS A with(nolock))
	else
	print ''Comprobación OK.Tabla CLE_DPF_SALIENTE con Tabla CLE_DEPOSITOS''

	if exists (select b.jts_oid_saldo 
				from CLE_CHEQUES_AJUSTE_AUX b with(nolock) 
				where b.jts_oid_saldo not in(select a.jts_oid
										from saldos A with(nolock))
				)	
				SELECT   ''Tabla CLE_CHEQUES_AJUSTE_AUX no se ajusta a la integridad referencial con Tabla saldos'',*
				from CLE_CHEQUES_AJUSTE_AUX b with(nolock) 
				where b.jts_oid_saldo not in(select a.jts_oid
										from saldos A with(nolock))
	else
	print ''Comprobación OK.Tabla CLE_CHEQUES_AJUSTE_AUX con Tabla saldos''

	if exists (select b.saldo_jts_oid 
				from cle_depositos b with(nolock) 
				where b.saldo_jts_oid not in(select a.jts_oid
										from saldos A with(nolock))
				)	
				SELECT   ''Tabla cle_depositos no se ajusta a la integridad referencial con Tabla saldos'',*
				from cle_depositos b with(nolock) 
				where b.saldo_jts_oid not in(select a.jts_oid
										from saldos A with(nolock))
	else
	print ''Comprobación OK.Tabla cle_depositos con Tabla saldos''

if exists (		select a.CODIGO_RECHAZO  
				from CLE_RECEPCION_DPF_DEV a with(nolock)
				left join CLE_DPF_SALIENTE b with(nolock) on a.SUCURSAL_BANCO_GIRADO = b.SUCURSAL_BANCO_GIRADO
												and a.BANCO_GIRADO = b.BANCO_GIRADO
												and a.NUMERO_DPF = b.NUMERO_DPF
				where b.SUCURSAL_BANCO_GIRADO is null
					and b.BANCO_GIRADO is null
					and b.NUMERO_DPF is null

			)	
				SELECT   ''Tabla CLE_RECEPCION_DPF_DEV no se ajusta a la integridad referencial con CLE_DPF_SALIENTE '',*
				from CLE_RECEPCION_DPF_DEV a with(nolock)
				left join CLE_DPF_SALIENTE b with(nolock) on a.SUCURSAL_BANCO_GIRADO = b.SUCURSAL_BANCO_GIRADO
												and a.BANCO_GIRADO = b.BANCO_GIRADO
												and a.NUMERO_DPF = b.NUMERO_DPF
				where b.SUCURSAL_BANCO_GIRADO is null
					and b.BANCO_GIRADO is null
					and b.NUMERO_DPF is null
	else
	print ''Comprobación OK.Tabla CLE_RECEPCION_DPF_DEV con CLE_DPF_SALIENTE ''

	if exists (	select a.BANCO_GIRADO
				from CLE_CHEQUES_AJUSTE_AUX a with(nolock) 
				left join CLE_CHEQUES_AJUSTE b with(nolock) on a.ORDINAL = b.ORDINAL
													and b.BANCO = a.BANCO_GIRADO
													and a.FECHA_ALTA = b.FECHA_ALTA
				where b.ORDINAL is null
					and b.BANCO is null
					and b.FECHA_ALTA is null
			)	
				SELECT   ''Tabla CLE_CHEQUES_AJUSTE_AUX no se ajusta a la integridad referencial con CLE_CHEQUES_AJUSTE '',*
				from CLE_CHEQUES_AJUSTE_AUX a with(nolock) 
				left join CLE_CHEQUES_AJUSTE b with(nolock) on a.ORDINAL = b.ORDINAL
													and b.BANCO = a.BANCO_GIRADO
													and a.FECHA_ALTA = b.FECHA_ALTA
				where b.ORDINAL is null
					and b.BANCO is null
					and b.FECHA_ALTA is null
	else
	print ''Comprobación OK.Tabla CLE_CHEQUES_AJUSTE_AUX con CLE_CHEQUES_AJUSTE ''

	if exists (	select a.NUMERO_CHEQUE
				from CLE_CHEQUES_SALIENTE_HTO a with(nolock)
				left join CLE_CHEQUES_SALIENTE b with(nolock) on a.SERIE_DEL_CHEQUE = b.SERIE_DEL_CHEQUE
												and a.NUMERO_CHEQUE = b.NUMERO_CHEQUE
												and a.SUCURSAL_BANCO_GIRADO = b.SUCURSAL_BANCO_GIRADO
												and a.BANCO_GIRADO = b.BANCO_GIRADO
												and a.NUMERICO_CUENTA_GIRADORA = b.NUMERICO_CUENTA_GIRADORA
												and a.TIPO_DOCUMENTO = b.TIPO_DOCUMENTO
				where b.SERIE_DEL_CHEQUE is null
				and b.NUMERO_CHEQUE is null
				and b.SUCURSAL_BANCO_GIRADO is null
				and b.BANCO_GIRADO is null
				and b.NUMERICO_CUENTA_GIRADORA is null
				and b.TIPO_DOCUMENTO is null

			)	
				SELECT   ''Tabla CLE_CHEQUES_SALIENTE_HTO no se ajusta a la integridad referencial con CLE_CHEQUES_SALIENTE '',*
				from CLE_CHEQUES_SALIENTE_HTO a with(nolock)
				left join CLE_CHEQUES_SALIENTE b with(nolock) on a.SERIE_DEL_CHEQUE = b.SERIE_DEL_CHEQUE
												and a.NUMERO_CHEQUE = b.NUMERO_CHEQUE
												and a.SUCURSAL_BANCO_GIRADO = b.SUCURSAL_BANCO_GIRADO
												and a.BANCO_GIRADO = b.BANCO_GIRADO
												and a.NUMERICO_CUENTA_GIRADORA = b.NUMERICO_CUENTA_GIRADORA
												and a.TIPO_DOCUMENTO = b.TIPO_DOCUMENTO
				where b.SERIE_DEL_CHEQUE is null
				and b.NUMERO_CHEQUE is null
				and b.SUCURSAL_BANCO_GIRADO is null
				and b.BANCO_GIRADO is null
				and b.NUMERICO_CUENTA_GIRADORA is null
				and b.TIPO_DOCUMENTO is null
	else
	print ''Comprobación OK.Tabla CLE_CHEQUES_SALIENTE_HTO con CLE_CHEQUES_SALIENTE ''


	if exists (	select a.NUMERO_DEL_CHEQUE 
				from CLE_CHEQUES_ENVIADOS a with(nolock)
				left join CLE_CHEQUES_SALIENTE b with(nolock) on a.TIPO_DOCUMENTO = b.TIPO_DOCUMENTO
													and a.SERIE_DEL_CHEQUE = b.SERIE_DEL_CHEQUE
													and a.NUMERO_DEL_CHEQUE = b.NUMERO_CHEQUE
													and a.COD_BANCO = b.BANCO_GIRADO
													and a.NUMERO_CUENTA_GIRADORA = b.NUMERICO_CUENTA_GIRADORA
													and a.SUCURSAL = b.SUCURSAL_BANCO_GIRADO
				where b.TIPO_DOCUMENTO is null
					and b.SERIE_DEL_CHEQUE is null
					and b.NUMERO_CHEQUE is null
					and b.BANCO_GIRADO is null
					and b.NUMERICO_CUENTA_GIRADORA is null
					and b.SUCURSAL_BANCO_GIRADO is null

			)	
				SELECT    ''Tabla CLE_CHEQUES_ENVIADOS no se ajusta a la integridad referencial con CLE_CHEQUES_SALIENTE '',*
				from CLE_CHEQUES_ENVIADOS a with(nolock)
				left join CLE_CHEQUES_SALIENTE b with(nolock) on a.TIPO_DOCUMENTO = b.TIPO_DOCUMENTO
													and a.SERIE_DEL_CHEQUE = b.SERIE_DEL_CHEQUE
													and a.NUMERO_DEL_CHEQUE = b.NUMERO_CHEQUE
													and a.COD_BANCO = b.BANCO_GIRADO
													and a.NUMERO_CUENTA_GIRADORA = b.NUMERICO_CUENTA_GIRADORA
													and a.SUCURSAL = b.SUCURSAL_BANCO_GIRADO
				where b.TIPO_DOCUMENTO is null
					and b.SERIE_DEL_CHEQUE is null
					and b.NUMERO_CHEQUE is null
					and b.BANCO_GIRADO is null
					and b.NUMERICO_CUENTA_GIRADORA is null
					and b.SUCURSAL_BANCO_GIRADO is null
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
				from SNP_MSG_ORDENES a with(nolock) 
				where a.CUIT_EO not in (	select b.CUIT_EO 
												from SNP_DEBITOS b with(nolock))

			)	
				SELECT    ''Tabla SNP_MSG_ORDENES no se ajusta a la integridad referencial con SNP_DEBITOS '',*
				from SNP_MSG_ORDENES a with(nolock) 
				where a.CUIT_EO not in (	select b.CUIT_EO 
												from SNP_DEBITOS b with(nolock))
	else
	print ''Comprobación OK.Tabla SNP_MSG_ORDENES con SNP_DEBITOS ''

------------------------------------ OPERACIONES/DEBITOS AUTOMATICOS

	if exists (	select a.saldo_jts_oid 
				from MOVIMIENTOS_CONTABLES a with(nolock) 
				where a.saldo_jts_oid not in (	select b.jts_oid 
												from SALDOS b with(nolock))
			)	
				SELECT    ''Tabla MOVIMIENTOS_CONTABLES no se ajusta a la integridad referencial con SALDOS '',*
				from MOVIMIENTOS_CONTABLES a with(nolock) 
				where a.saldo_jts_oid not in (	select b.jts_oid 
												from SALDOS b with(nolock))
	else
	print ''Comprobación OK.Tabla MOVIMIENTOS_CONTABLES con SALDOS ''

	if exists (	select a.ASIENTO 
				from MOVIMIENTOS_CONTABLES a with(nolock) 
				where a.ASIENTO not in (	select b.ASIENTO 
												from ASIENTOS b with(nolock))
			)	
				SELECT    ''Tabla MOVIMIENTOS_CONTABLES no se ajusta a la integridad referencial con ASIENTO '',*
				from MOVIMIENTOS_CONTABLES a with(nolock) 
				where a.ASIENTO not in (	select b.ASIENTO 
												from ASIENTOS b with(nolock))
	else
	print ''Comprobación OK.Tabla MOVIMIENTOS_CONTABLES con ASIENTO ''

	if exists (	select a.ID_LIQUIDACION 
				from REC_CAB_DEBITOSAUTOMATICOS a with(nolock) 
				where a.ID_LIQUIDACION <>0 and a.ID_LIQUIDACION not in (	select b.ID_LIQUIDACION 
												from REC_LIQUIDACION b with(nolock))

			)	
				SELECT    ''Tabla REC_CAB_DEBITOSAUTOMATICOS no se ajusta a la integridad referencial con REC_LIQUIDACION '',*
				from REC_CAB_DEBITOSAUTOMATICOS a with(nolock) 
				where a.ID_LIQUIDACION <>0 and a.ID_LIQUIDACION not in (	select b.ID_LIQUIDACION 
												from REC_LIQUIDACION b with(nolock))
	else
	print ''Comprobación OK.Tabla REC_CAB_DEBITOSAUTOMATICOS con REC_LIQUIDACION ''

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


	if exists (	select a.id_liquidacion 
				from REC_LIQUIDACION a with(nolock) 
				where a.id_liquidacion not in (	select b.id_liquidacion
												from REC_DET_DEBITOSAUTOMATICOS b with(nolock))

			)	
				SELECT    ''Tabla REC_LIQUIDACION no se ajusta a la integridad referencial con REC_DET_DEBITOSAUTOMATICOS '',*
				from REC_LIQUIDACION a with(nolock) 
				where a.id_liquidacion not in (	select b.id_liquidacion
												from REC_DET_DEBITOSAUTOMATICOS b with(nolock))
	else
	print ''Comprobación OK.Tabla REC_LIQUIDACION con REC_DET_DEBITOSAUTOMATICOS ''
--------------------------------------OPERACIONES/CONVENIOS DE PAGOS

 	if exists (	SELECT B.id_convenio 
				FROM CONV_DOMINIOS b with (nolock)
				WHERE B.id_convenio  NOT IN (SELECT A.ID_CONVPAGO 
										FROM CONV_CONVENIOS_PAG a with (nolock)) 
				)	
				SELECT ''Tabla CONV_DOMINIOS no se ajusta a la integridad referencial con CONV_CONVENIOS_PAG '',*
				FROM CONV_DOMINIOS b with (nolock)
				WHERE B.id_convenio  NOT IN (SELECT A.ID_CONVPAGO 
										FROM CONV_CONVENIOS_PAG a with (nolock)) 
	else
		print ''Comprobación OK.Tabla CONV_DOMINIOS con CONV_CONVENIOS_PAG ''

	if exists (	SELECT B.ID_TPOCONV 
				FROM CONV_CONVENIOS_PAG b with (nolock)
				WHERE B.ID_TPOCONV  NOT IN (SELECT A.ID_TPOCONV 
										FROM CONV_TIPOS a with (nolock)) 
				)	
				SELECT ''Tabla CONV_CONVENIOS_PAG no se ajusta a la integridad referencial con CONV_TIPOS '',*
				FROM CONV_CONVENIOS_PAG b with (nolock)
				WHERE B.ID_TPOCONV  NOT IN (SELECT A.ID_TPOCONV 
										FROM CONV_TIPOS a with (nolock)) 
	else
		print ''Comprobación OK.Tabla CONV_CONVENIOS_PAG con CONV_TIPOS ''

	if exists (	SELECT B.ID_CONVPAGO 
				FROM CONV_MEDIOPAGO b with (nolock)
				WHERE B.ID_CONVPAGO  NOT IN (SELECT A.Id_ConvRec
											FROM CONV_CONVENIOS_REC a with (nolock)) 
				)	
				SELECT ''Tabla CONV_MEDIOPAGO no se ajusta a la integridad referencial con CONV_CONVENIOS_REC '',*
				FROM CONV_MEDIOPAGO b with (nolock)
				WHERE B.ID_CONVPAGO  NOT IN (SELECT A.Id_ConvRec
											FROM CONV_CONVENIOS_REC a with (nolock)) 
	else
		print ''Comprobación OK.Tabla CONV_MEDIOPAGO con CONV_CONVENIOS_REC ''


	if exists (	SELECT b.ID_CONVENIO
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
	if exists (	SELECT b.ID_CONVENIO
				fROM CONV_CONVENIOS_MORA b 
				where b.ID_CONVENIO not in ( select a.Id_ConvRec 
									from CONV_CONVENIOS_REC a with (nolock))
				)	
				SELECT ''Tabla CONV_CONVENIOS_MORA no se ajusta a la integridad referencial con CONV_CONVENIOS_REC '',*
				fROM CONV_CONVENIOS_MORA b 
				where b.ID_CONVENIO not in ( select a.Id_ConvRec 
									from CONV_CONVENIOS_REC a with (nolock))
	else
		print ''Comprobación OK.Tabla CONV_CONVENIOS_MORA con CONV_CONVENIOS_REC ''




----------------------------OPERACIONES/CONVENIOS DE RECAUDACIONES

	if exists (	SELECT B.id_convenio 
				FROM CONV_CB_ESTRUCTURA b with (nolock)
				WHERE B.id_convenio  NOT IN (SELECT A.ID_CONVrec 
										FROM CONV_CONVENIOS_REC a with (nolock)) 
				)	
				SELECT ''Tabla CONV_CB_ESTRUCTURA no se ajusta a la integridad referencial con CONV_CONVENIOS_REC '',*
				FROM CONV_CB_ESTRUCTURA b with (nolock)
				WHERE B.id_convenio  NOT IN (SELECT A.ID_CONVrec 
										FROM CONV_CONVENIOS_REC a with (nolock)) 

	else
		print ''Comprobación OK.Tabla CONV_CB_ESTRUCTURA con CONV_CONVENIOS_REC ''

	if exists (	SELECT B.ID_TPOCONV 
				FROM CONV_CONVENIOS_REC b with (nolock)
				WHERE B.ID_TPOCONV  NOT IN (SELECT A.ID_TPOCONV 
											FROM CONV_TIPOS a with (nolock)) 
				)	
				SELECT ''Tabla CONV_CONVENIOS_REC no se ajusta a la integridad referencial con CONV_TIPOS '',*
				FROM CONV_CONVENIOS_REC b with (nolock)
				WHERE B.ID_TPOCONV  NOT IN (SELECT A.ID_TPOCONV 
											FROM CONV_TIPOS a with (nolock)) 
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

	if exists (	SELECT B.ID_CABEZAL 
				FROM REC_DET_RECAUDOS_CANAL b with (nolock)
				WHERE B.ID_CABEZAL  NOT IN (SELECT A.ID
										FROM REC_CAB_RECAUDOS_CANAL a with (nolock)) 
		)	
				SELECT ''Tabla REC_DET_RECAUDOS_CANAL no se ajusta a la integridad referencial con REC_CAB_RECAUDOS_CANAL '',* 
				FROM REC_DET_RECAUDOS_CANAL b with (nolock)
				WHERE B.ID_CABEZAL  NOT IN (SELECT A.ID
											FROM REC_CAB_RECAUDOS_CANAL a with (nolock)) 
	else
		print ''Comprobación OK.Tabla REC_DET_RECAUDOS_CANAL con REC_CAB_RECAUDOS_CANAL ''

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
	if exists (	SELECT b.ID_CABEZAL
				fROM REC_DET_RECAUDOS_CAJA b 
				where b.ID_CABEZAL not in ( select a.id 
									from REC_CAB_RECAUDOS_CAJA a with (nolock))
				)	
				SELECT ''Tabla REC_DET_RECAUDOS_CAJA no se ajusta a la integridad referencial con REC_CAB_RECAUDOS_CAJA '',*
				fROM REC_DET_RECAUDOS_CAJA b 
				where b.ID_CABEZAL not in ( select a.id 
									from REC_CAB_RECAUDOS_CAJA a with (nolock))
	else
		print ''Comprobación OK.Tabla REC_DET_RECAUDOS_CAJA con REC_CAB_RECAUDOS_CAJA ''


--------------------------------------OPERACIONES/TRANSFERENCIAS
	if exists (	SELECT b.op_tipo
				fROM VTA_TRANSFERENCIAS b 
				where b.op_tipo not in ( select a.Id_tipo
									from VTA_TRANSFERENCIAS_TIPOS a with (nolock))
				)	
				SELECT ''Tabla VTA_TRANSFERENCIAS no se ajusta a la integridad referencial con VTA_TRANSFERENCIAS_TIPOS '',*
				fROM VTA_TRANSFERENCIAS b 
				where b.op_tipo not in ( select a.Id_tipo
									from VTA_TRANSFERENCIAS_TIPOS a with (nolock))
	else
		print ''Comprobación OK.Tabla VTA_TRANSFERENCIAS con VTA_TRANSFERENCIAS_TIPOS ''


	END
ELSE
	print ''NO CORRESPONDE LA BASE DE DATOS''
END
;')