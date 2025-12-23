execute('
----------------------------------------ACTIVAS.-----------------------------------------------------------
--exec [dbo].[SP_INTEGRIDAD_REFERENCIAL_ACTIVAS] NBCH_tunning

CREATE OR ALTER  procedure [dbo].[SP_INTEGRIDAD_REFERENCIAL_ACTIVAS] 
						@BD varchar(20)
as
BEGIN
IF (SELECT DB_NAME()) = @BD
  BEGIN
	print ''-------------------ACTIVAS--------------''
	print ''-----------------------------------------''

	if exists (
				select b.ASIENTO 
				from ASIENTOS_EXTORNADOS b with(nolock)
				where b.ASIENTO not in ( 
											select a.ASIENTO 
											from ASIENTOS a with(nolock) )
				)
			select  ''Tabla ASIENTOS_EXTORNADOS no se ajusta a la integridad referencial con ASIENTOS '',*
				from ASIENTOS_EXTORNADOS b with(nolock)
				where b.ASIENTO not in ( 
											select a.ASIENTO 
											from ASIENTOS a with(nolock) )
	ELSE 
			print ''Comprobación OK. Tabla ASIENTOS_EXTORNADOS con ASIENTOS ''

/*if exists ( select b.numero_cheque 
				from CLE_CHEQUES_LISTA_DESCUENTO b with(nolock)
				left join io_captura_cheques a on b.numero_cheque = a.num_cheque
												and b.serie_del_cheque = a.serie_cheque
												and b.banco_girado = a.banco_emisor
												and b.sucursal_banco_girado = a.suc_banco_emisor
												and b.tipo_documento = a.tipo_documento
				where 
				a.num_cheque is null
				and a.serie_cheque is null
				and a.banco_emisor is null
				and a.suc_banco_emisor is null
				and a.tipo_documento is null  
				)	
			select   ''Tabla CLE_CHEQUES_LISTA_DESCUENTO no se ajusta a la integridad referencial con io_captura_cheques '',*
				from CLE_CHEQUES_LISTA_DESCUENTO b with(nolock)
				left join io_captura_cheques a on b.numero_cheque = a.num_cheque
												and b.serie_del_cheque = a.serie_cheque
												and b.banco_girado = a.banco_emisor
												and b.sucursal_banco_girado = a.suc_banco_emisor
												and b.tipo_documento = a.tipo_documento
				where 
				a.num_cheque is null
				and a.serie_cheque is null
				and a.banco_emisor is null
				and a.suc_banco_emisor is null
				and a.tipo_documento is null  
	else
	print ''Comprobación OK. Tabla CLE_CHEQUES_LISTA_DESCUENTO con io_captura_cheques ''
*/ --- VER SI SE UTILIZAN LAS TABLAS, DE LO CONTRARIO NO USAR ESTE CONTROL.
		if exists ( select b.numero_cheque 
				from CLE_CHEQUES_LISTA_DESCUENTO b with(nolock)
				left join CRE_REL_CAB_DOCUMENTOS a on b.numero_cheque = a.NUMERO_CHEQUE
												and b.serie_del_cheque = a.SERIE_DEL_CHEQUE
												and b.banco_girado = a.BANCO_GIRADO
												and b.sucursal_banco_girado = a.sucursal_banco_girado
												and b.tipo_documento = a.tipo_documento
				where 
				a.NUMERO_CHEQUE is null
				and a.SERIE_DEL_CHEQUE is null
				and a.BANCO_GIRADO is null
				and a.SUCURSAL_BANCO_GIRADO is null
				and a.tipo_documento is null  
				)	
			select   ''Tabla CLE_CHEQUES_LISTA_DESCUENTO no se ajusta a la integridad referencial con CRE_REL_CAB_DOCUMENTOS '',*
				from CLE_CHEQUES_LISTA_DESCUENTO b with(nolock)
				left join CRE_REL_CAB_DOCUMENTOS a on b.numero_cheque = a.NUMERO_CHEQUE
												and b.serie_del_cheque = a.SERIE_DEL_CHEQUE
												and b.banco_girado = a.BANCO_GIRADO
												and b.sucursal_banco_girado = a.sucursal_banco_girado
												and b.tipo_documento = a.tipo_documento
				where 
				a.NUMERO_CHEQUE is null
				and a.SERIE_DEL_CHEQUE is null
				and a.BANCO_GIRADO is null
				and a.SUCURSAL_BANCO_GIRADO is null
				and a.tipo_documento is null   
	else
	print ''Comprobación OK. Tabla CLE_CHEQUES_LISTA_DESCUENTO con CRE_REL_CAB_DOCUMENTOS ''

	if exists (
				select b.NUMERO_LISTA 
				from CRE_REL_CAB_DOCUMENTOS b with(nolock)
				where b.NUMERO_LISTA not in ( 
											select a.NUMERO_LISTA 
											from CRE_CAB_LISTA_DOCUMENTOS a with(nolock) )
				)
			select  ''Tabla CRE_REL_CAB_DOCUMENTOS no se ajusta a la integridad referencial con CRE_CAB_LISTA_DOCUMENTOS '',*
				from CRE_REL_CAB_DOCUMENTOS b with(nolock)
				where b.NUMERO_LISTA not in ( 
											select a.NUMERO_LISTA 
											from CRE_CAB_LISTA_DOCUMENTOS a with(nolock) )
	ELSE 
			print ''Comprobación OK. Tabla CRE_REL_CAB_DOCUMENTOS con CRE_CAB_LISTA_DOCUMENTOS ''

	if exists (
				select b.NUMERO_LISTA 
				from CRE_AUX_CONF_FACTURAS b with(nolock)
				where b.NUMERO_LISTA not in ( 
											select a.NUMERO_LISTA 
											from CRE_CAB_LISTA_DOCUMENTOS a with(nolock) )
				)
			select  ''Tabla CRE_AUX_CONF_FACTURAS no se ajusta a la integridad referencial con CRE_CAB_LISTA_DOCUMENTOS '',*
				from CRE_REL_CAB_DOCUMENTOS b with(nolock)
				where b.NUMERO_LISTA not in ( 
											select a.NUMERO_LISTA 
											from CRE_CAB_LISTA_DOCUMENTOS a with(nolock) )
	ELSE 
			print ''Comprobación OK. Tabla CRE_AUX_CONF_FACTURAS con CRE_CAB_LISTA_DOCUMENTOS ''
	if exists (
				select b.NUMERO_DOC_REAL 
				from CRE_CONF_FACTURAS b with(nolock)
				where b.NUMERO_DOC_REAL not in ( 
											select a.NUMERO_DOC_REAL 
											from CRE_AUX_CONF_FACTURAS a with(nolock) )
				)
			select  ''Tabla CRE_CONF_FACTURAS no se ajusta a la integridad referencial con CRE_AUX_CONF_FACTURAS '',*
				from CRE_REL_CAB_DOCUMENTOS b with(nolock)
				where b.NUMERO_LISTA not in ( 
											select a.NUMERO_LISTA 
											from CRE_CAB_LISTA_DOCUMENTOS a with(nolock) )
	ELSE 
			print ''Comprobación OK. Tabla CRE_CONF_FACTURAS con CRE_AUX_CONF_FACTURAS ''
	if exists (
				select b.tpo_garantia 
				from CRE_GARANTIADOCUMENTOS b with(nolock)
				where b.tpo_garantia not in ( 
											select a.tipo_garantia 
											from CRE_TIPOSGARANTIAS a with(nolock) )
				)
			select  ''Tabla CRE_CONF_FACTURAS no se ajusta a la integridad referencial con CRE_TIPOSGARANTIAS '',*
				from CRE_GARANTIADOCUMENTOS b with(nolock)
				where b.tpo_garantia not in ( 
											select a.tipo_garantia 
											from CRE_TIPOSGARANTIAS a with(nolock) )
	ELSE 
			print ''Comprobación OK. Tabla CRE_CONF_FACTURAS con CRE_TIPOSGARANTIAS ''
	if exists (
				select b.tpo_garantia 
				from CRE_DOCUMENTOS b with(nolock)
				where b.tpo_garantia not in ( 
											select a.tipo_garantia 
											from CRE_TIPOSGARANTIAS a with(nolock) )
				)
			select  ''Tabla CRE_DOCUMENTOS no se ajusta a la integridad referencial con CRE_TIPOSGARANTIAS '',*
				from CRE_DOCUMENTOS b with(nolock)
				where b.tpo_garantia not in ( 
											select a.tipo_garantia 
											from CRE_TIPOSGARANTIAS a with(nolock) )
	ELSE 
			print ''Comprobación OK. Tabla CRE_DOCUMENTOS con CRE_TIPOSGARANTIAS ''
	if exists (
				select b.TIPOGARANTIA 
				from CRE_GARANTIASRECIBIDAS b with(nolock)
				where b.tipogarantia not in ( 
											select a.tipo_garantia 
											from CRE_TIPOSGARANTIAS a with(nolock) )
				)
			select  ''Tabla CRE_GARANTIASRECIBIDAS no se ajusta a la integridad referencial con CRE_TIPOSGARANTIAS '',*
				from CRE_GARANTIASRECIBIDAS b with(nolock)
				where b.tipogarantia not in ( 
											select a.tipo_garantia 
											from CRE_TIPOSGARANTIAS a with(nolock) )
	ELSE 
			print ''Comprobación OK. Tabla CRE_GARANTIASRECIBIDAS con CRE_TIPOSGARANTIAS ''
	if exists (
				select b.GARANTIA 
				from CRE_REL_SOLICITUDGARANTIA b with(nolock)
				where b.GARANTIA not in ( 
											select a.NUM_GARANTIA 
											from CRE_GARANTIASRECIBIDAS a with(nolock) )
				)
			select  ''Tabla CRE_REL_SOLICITUDGARANTIA no se ajusta a la integridad referencial con CRE_GARANTIASRECIBIDAS '',*
				from CRE_REL_SOLICITUDGARANTIA b with(nolock)
				where b.GARANTIA not in ( 
											select a.NUM_GARANTIA 
											from CRE_GARANTIASRECIBIDAS a with(nolock) )
	ELSE 
			print ''Comprobación OK. Tabla CRE_REL_SOLICITUDGARANTIA con CRE_GARANTIASRECIBIDAS ''
	if exists (
				select b.NUM_GARANTIA 
				from CRE_GARANTIA_BIENES b with(nolock)
				where b.NUM_GARANTIA not in ( 
											select a.NUM_GARANTIA 
											from CRE_GARANTIASRECIBIDAS a with(nolock) )
				)
			select  ''Tabla CRE_GARANTIA_BIENES no se ajusta a la integridad referencial con CRE_GARANTIASRECIBIDAS '',*
				from CRE_GARANTIA_BIENES b with(nolock)
				where b.NUM_GARANTIA not in ( 
											select a.NUM_GARANTIA 
											from CRE_GARANTIASRECIBIDAS a with(nolock) )
	ELSE 
			print ''Comprobación OK. Tabla CRE_GARANTIA_BIENES con CRE_GARANTIASRECIBIDAS ''
	if exists (
				select b.NUM_GARANTIA 
				from CRE_GARANTIASRECIBIDAS b with(nolock)
				where b.NUM_GARANTIA not in ( 
											select a.NUM_GARANTIA 
											from CRE_GarantiaPersonas a with(nolock) )
				)
			select  ''Tabla CRE_GARANTIASRECIBIDAS no se ajusta a la integridad referencial con CRE_GarantiaPersonas '',*
				from CRE_GARANTIASRECIBIDAS b with(nolock)
				where b.NUM_GARANTIA not in ( 
											select a.NUM_GARANTIA 
											from CRE_GarantiaPersonas a with(nolock) )
	ELSE 
			print ''Comprobación OK. Tabla CRE_GARANTIASRECIBIDAS con CRE_GarantiaPersonas ''
	if exists (
				select b.SUBTIPOGTIA 
				from CRE_CLASGARANTIAS b with(nolock)
				where b.SUBTIPOGTIA not in ( 
											select a.COD_SUBTIPO_GARANTIA 
											from CRE_SUBTIPOGARANTIAS a with(nolock) )
				)
			select  ''Tabla CRE_CLASGARANTIAS no se ajusta a la integridad referencial con CRE_SUBTIPOGARANTIAS '',*
				from CRE_CLASGARANTIAS b with(nolock)
				where b.SUBTIPOGTIA not in ( 
											select a.COD_SUBTIPO_GARANTIA 
											from CRE_SUBTIPOGARANTIAS a with(nolock) )
	ELSE 
			print ''Comprobación OK. Tabla CRE_CLASGARANTIAS con CRE_SUBTIPOGARANTIAS ''
	if exists (
				select b.COD_SUBCLA_GARANTIA 
				from CRE_CLASGARANTIAS b with(nolock)
				where b.COD_SUBCLA_GARANTIA not in ( 
											select a.COD_SUBCLASIFICACIONGARANTIA 
											from CRE_SUBCLASGARANTIAS a with(nolock) )
				)
			select  ''Tabla CRE_CLASGARANTIAS no se ajusta a la integridad referencial con CRE_SUBCLASGARANTIAS '',*
				from CRE_CLASGARANTIAS b with(nolock)
				where b.COD_SUBCLA_GARANTIA not in ( 
											select a.COD_SUBCLASIFICACIONGARANTIA 
											from CRE_SUBCLASGARANTIAS a with(nolock) )
	ELSE 
			print ''Comprobación OK. Tabla CRE_CLASGARANTIAS con CRE_SUBCLASGARANTIAS ''
	if exists (
				select b.SUCURSAL 
				from SUCURSALESSC b with(nolock)
				where b.SUCURSAL not in ( 
											select a.SUCURSAL 
											from SUCURSALES a with(nolock) )
				)
			select ''Tabla SUCURSALESSC no se ajusta a la integridad referencial con SUCURSALES '',*
				from SUCURSALESSC b with(nolock)
				where b.SUCURSAL not in ( 
											select a.SUCURSAL 
											from SUCURSALES a with(nolock) )
	ELSE 
			print ''Comprobación OK. Tabla SUCURSALESSC con SUCURSALES ''
	if exists (
				select b.SUCURSAL_ALTA 
				from VTA_RESERVAS b with(nolock)
				where b.SUCURSAL_ALTA not in ( 
											select a.SUCURSAL 
											from SUCURSALES a with(nolock) )
				)
			select ''Tabla VTA_RESERVAS no se ajusta a la integridad referencial con SUCURSALES '',*
				from VTA_RESERVAS b with(nolock)
				where b.SUCURSAL_ALTA not in ( 
											select a.SUCURSAL 
											from SUCURSALES a with(nolock) )
	ELSE 
			print ''Comprobación OK. Tabla VTA_RESERVAS con SUCURSALES ''
	if exists (
				select b.COD_ACTIVIDAD 
				from CRE_PROD_ACTIVIDAD b with(nolock)
				where b.COD_ACTIVIDAD not in ( 
											select a.CODIGO_ACTIVIDAD 
											from CLI_ACTIVIDAD_ECONOMICA a with(nolock) )
				)
			select ''Tabla CRE_PROD_ACTIVIDAD no se ajusta a la integridad referencial con CLI_ACTIVIDAD_ECONOMICA '',*
				from CRE_PROD_ACTIVIDAD b with(nolock)
				where b.COD_ACTIVIDAD not in ( 
											select a.CODIGO_ACTIVIDAD 
											from CLI_ACTIVIDAD_ECONOMICA a with(nolock) )
	ELSE 
			print ''Comprobación OK. Tabla CRE_PROD_ACTIVIDAD con CLI_ACTIVIDAD_ECONOMICA ''
	if exists (
				select b.CODIGO_PERSONA_CLIENTE 
				from CLI_ACTIVIDAD_ECONOMICA b with(nolock)
				where b.CODIGO_PERSONA_CLIENTE not in ( 
											select a.NUMEROPERSONA 
											from CLI_ClientePersona a with(nolock) )
				)
			select ''Tabla CLI_ACTIVIDAD_ECONOMICA no se ajusta a la integridad referencial con CLI_ClientePersona '',*
				from CLI_ACTIVIDAD_ECONOMICA b with(nolock)
				where b.CODIGO_PERSONA_CLIENTE not in ( 
											select a.NUMEROPERSONA 
											from CLI_ClientePersona a with(nolock) )
	ELSE 
			print ''Comprobación OK. Tabla CLI_ACTIVIDAD_ECONOMICA con CLI_ClientePersona ''
	if exists (
				select b.COD_PRODUCTO 
				from CRE_PROD_ACTIVIDAD b with(nolock)
				where b.COD_PRODUCTO not in ( 
											select a.c6250 
											from PRODUCTOS a with(nolock) )
				)
			select ''Tabla CRE_PROD_ACTIVIDAD no se ajusta a la integridad referencial con PRODUCTOS '',*
				from CRE_PROD_ACTIVIDAD b with(nolock)
				where b.COD_PRODUCTO not in ( 
											select a.c6250 
											from PRODUCTOS a with(nolock) )
	ELSE 
			print ''Comprobación OK. Tabla CRE_PROD_ACTIVIDAD con PRODUCTOS ''
	if exists (
				select b.CODIGOCLIENTE 
				from CLI_ClientePersona b with(nolock)
				where b.CODIGOCLIENTE not in ( 
											select a.CODIGOCLIENTE 
											from CLI_CLIENTES a with(nolock) )
				)
			select ''Tabla CLI_ClientePersona no se ajusta a la integridad referencial con CLI_CLIENTES '',*
				from CLI_ClientePersona b with(nolock)
				where b.CODIGOCLIENTE not in ( 
											select a.CODIGOCLIENTE 
											from CLI_CLIENTES a with(nolock) )
	ELSE 
			print ''Comprobación OK. Tabla CLI_ClientePersona con CLI_CLIENTES ''
	if exists (
				select b.CODIGOCLIENTE 
				from CRE_GRAD_FRACC_BITACORA b with(nolock)
				where b.CODIGOCLIENTE not in ( 
											select a.CODIGOCLIENTE 
											from CLI_CLIENTES a with(nolock) )
				)
			select ''Tabla CRE_GRAD_FRACC_BITACORA no se ajusta a la integridad referencial con CLI_CLIENTES '',*
				from CRE_GRAD_FRACC_BITACORA b with(nolock)
				where b.CODIGOCLIENTE not in ( 
											select a.CODIGOCLIENTE 
											from CLI_CLIENTES a with(nolock) )
	ELSE 
			print ''Comprobación OK. Tabla CRE_GRAD_FRACC_BITACORA con CLI_CLIENTES ''
	if exists (
				select b.COD_ACUMULADOR 
				from CRE_RECIBOCONCEPTO b with(nolock)
				where b.COD_ACUMULADOR not in ( 
											select a.CODIGO 
											from CRE_RECIBOACUMULADOR a with(nolock) )
				)
			select ''Tabla CRE_RECIBOCONCEPTO no se ajusta a la integridad referencial con CRE_RECIBOACUMULADOR '',*
				from CRE_RECIBOCONCEPTO b with(nolock)
				where b.COD_ACUMULADOR not in ( 
											select a.CODIGO 
											from CRE_RECIBOACUMULADOR a with(nolock) )
	ELSE 
			print ''Comprobación OK. Tabla CRE_RECIBOCONCEPTO con CRE_RECIBOACUMULADOR ''
	if exists (
				select b.NUMERO_RECIBO 
				from CRE_SOL_RECIBO_SUELDO_DET b with(nolock)
				where b.NUMERO_RECIBO not in ( 
											select a.CODIGO 
											from CRE_RECIBOCONCEPTO a with(nolock) )
				)
			select ''Tabla CRE_SOL_RECIBO_SUELDO_DET no se ajusta a la integridad referencial con CRE_RECIBOCONCEPTO '',*
				from CRE_SOL_RECIBO_SUELDO_DET b with(nolock)
				where b.NUMERO_RECIBO not in ( 
											select a.CODIGO 
											from CRE_RECIBOCONCEPTO a with(nolock) )
	ELSE 
			print ''Comprobación OK. Tabla CRE_SOL_RECIBO_SUELDO_DET con CRE_RECIBOCONCEPTO ''
	if exists (
				select b.NUMERO_RECIBO 
				from CRE_SOL_RECIBO_SUELDO_DET b with(nolock)
				where b.NUMERO_RECIBO not in ( 
											select a.NUMERO_RECIBO 
											from CRE_SOL_RECIBO_SUELDO a with(nolock) )
				)
			select ''Tabla CRE_SOL_RECIBO_SUELDO_DET no se ajusta a la integridad referencial con CRE_SOL_RECIBO_SUELDO '',*
				from CRE_SOL_RECIBO_SUELDO_DET b with(nolock)
				where b.NUMERO_RECIBO not in ( 
											select a.NUMERO_RECIBO 
											from CRE_SOL_RECIBO_SUELDO a with(nolock) )
	ELSE 
			print ''Comprobación OK. Tabla CRE_SOL_RECIBO_SUELDO_DET con CRE_SOL_RECIBO_SUELDO ''
	if exists (
				select b.ADMINISTRADORA 
				from TJC_SALDOS b with(nolock)
				where b.ADMINISTRADORA not in ( 
											select a.COD_ADMINISTRADORA 
											from TJC_MAESTRO_ADMINISTRADORAS a with(nolock) )
				)
			select ''Tabla TJC_SALDOS no se ajusta a la integridad referencial con TJC_MAESTRO_ADMINISTRADORAS '',*
				from TJC_SALDOS b with(nolock)
				where b.ADMINISTRADORA not in ( 
											select a.COD_ADMINISTRADORA 
											from TJC_MAESTRO_ADMINISTRADORAS a with(nolock) )
	ELSE 
			print ''Comprobación OK. Tabla TJC_SALDOS con TJC_MAESTRO_ADMINISTRADORAS ''
	if exists (
				select b.ADMINISTRADORA 
				from TJC_SALDOS b with(nolock)
				where b.ADMINISTRADORA not in ( 
											select a.ADMINISTRADORA 
											from TJC_MAESTRO_USUARIO a with(nolock) )
				)
			select ''Tabla TJC_SALDOS no se ajusta a la integridad referencial con TJC_MAESTRO_USUARIO '',*
				from TJC_SALDOS b with(nolock)
				where b.ADMINISTRADORA not in ( 
											select a.ADMINISTRADORA 
											from TJC_MAESTRO_USUARIO a with(nolock) )
	ELSE 
			print ''Comprobación OK. Tabla TJC_SALDOS con TJC_MAESTRO_USUARIO ''
	if exists (
				select b.C6502 
				from CONCEPCONT b with(nolock)
				where b.C6502 not in ( 
											select a.c6301 
											from PLANCTAS a with(nolock) )
				)
			select ''Tabla CONCEPCONT no se ajusta a la integridad referencial con PLANCTAS '',*
				from CONCEPCONT b with(nolock)
				where b.C6502 not in ( 
											select a.c6301 
											from PLANCTAS a with(nolock) )
	ELSE 
			print ''Comprobación OK. Tabla CONCEPCONT con PLANCTAS ''
	if exists (
				select b.SALDOS_JTS_OID 
				from CRE_SALDOS b with(nolock)
				where b.saldos_JTS_OID not in ( 
											select a.JTS_OID 
											from SALDOS a with(nolock) )
				)
			select ''Tabla CRE_SALDOS no se ajusta a la integridad referencial con SALDOS '',*
				from CRE_SALDOS b with(nolock)
				where b.saldos_JTS_OID not in ( 
											select a.JTS_OID 
											from SALDOS a with(nolock) )
	ELSE 
			print ''Comprobación OK. Tabla CRE_SALDOS con SALDOS ''
	if exists (
				select b.SALDO_JTS_OID 
				from PLANPAGOS b with(nolock)
				where b.saldo_JTS_OID not in ( 
											select a.JTS_OID 
											from SALDOS a with(nolock) )
				)
			select ''Tabla PLANPAGOS no se ajusta a la integridad referencial con SALDOS '',*
				from PLANPAGOS b with(nolock)
				where b.saldo_JTS_OID not in ( 
											select a.JTS_OID 
											from SALDOS a with(nolock) )
	ELSE 
			print ''Comprobación OK. Tabla PLANPAGOS con SALDOS ''
	if exists (
				select b.c1803 
				from saldos b with(nolock)
				where b.c1803 not in ( 
											select a.CODIGOCLIENTE 
											from CLI_CLIENTES a with(nolock) )
				)
			select ''Tabla saldos no se ajusta a la integridad referencial con CLI_CLIENTES '',*
				from saldos b with(nolock)
				where b.c1803 not in ( 
											select a.CODIGOCLIENTE 
											from CLI_CLIENTES a with(nolock) )
	ELSE 
			print ''Comprobación OK. Tabla saldos con CLI_CLIENTES ''
	if exists (
				select b.JTSOID_SALDO 
				from CRE_GARANTIACREDITO b with(nolock)
				where b.JTSOID_SALDO not in ( 
											select a.JTS_OID 
											from saldos a with(nolock) )
				)
			select ''Tabla CRE_GARANTIACREDITO no se ajusta a la integridad referencial con saldos '',*
				from CRE_GARANTIACREDITO b with(nolock)
				where b.JTSOID_SALDO not in ( 
											select a.JTS_OID 
											from saldos a with(nolock) )
	ELSE 
			print ''Comprobación OK. Tabla CRE_GARANTIACREDITO con saldos ''
	if exists (
				select b.SALDOS_JTS_OID 
				from CRE_BIENES_LEASING b with(nolock)
				where b.SALDOS_JTS_OID not in ( 
											select a.JTS_OID 
											from saldos a with(nolock) )
				)
			select ''Tabla CRE_BIENES_LEASING no se ajusta a la integridad referencial con saldos '',*
				from CRE_BIENES_LEASING b with(nolock)
				where b.SALDOS_JTS_OID not in ( 
											select a.JTS_OID 
											from saldos a with(nolock) )
	ELSE 
			print ''Comprobación OK. Tabla CRE_BIENES_LEASING con saldos ''
	if exists (
				select b.JTS_OID_SALDO 
				from VTA_SOBREGIROS b with(nolock)
				where b.JTS_OID_SALDO not in ( 
											select a.JTS_OID 
											from saldos a with(nolock) )
				)
			select ''Tabla VTA_SOBREGIROS no se ajusta a la integridad referencial con saldos '',*
				from VTA_SOBREGIROS b with(nolock)
				where b.JTS_OID_SALDO not in ( 
											select a.JTS_OID 
											from saldos a with(nolock) )
	ELSE 
			print ''Comprobación OK. Tabla VTA_SOBREGIROS con saldos ''
	if exists (
				select b.JTS_OID_SALDO 
				from AUT_SOLICITUDES b with(nolock)
				where b.JTS_OID_SALDO not in ( 
											select a.JTS_OID 
											from saldos a with(nolock) )
				)
			select ''Tabla AUT_SOLICITUDES no se ajusta a la integridad referencial con saldos '',*
				from AUT_SOLICITUDES b with(nolock)
				where b.JTS_OID_SALDO not in ( 
											select a.JTS_OID 
											from saldos a with(nolock) )
	ELSE 
			print ''Comprobación OK. Tabla AUT_SOLICITUDES con saldos ''
	if exists (
				select b.SALDO_JTS_OID 
				from VTA_RESERVAS b with(nolock)
				where b.SALDO_JTS_OID not in ( 
											select a.JTS_OID 
											from saldos a with(nolock) )
				)
			select ''Tabla VTA_RESERVAS no se ajusta a la integridad referencial con saldos '',*
				from VTA_RESERVAS b with(nolock)
				where b.SALDO_JTS_OID not in ( 
											select a.JTS_OID 
											from saldos a with(nolock) )
	ELSE 
			print ''Comprobación OK. Tabla VTA_RESERVAS con saldos ''
	if exists (
				select b.MONEDA 
				from SALDOS b with(nolock)
				where b.MONEDA not in ( 
											select a.C6399 
											from MONEDAS a with(nolock) )
				)
			select ''Tabla SALDOS no se ajusta a la integridad referencial con MONEDAS '',*
				from SALDOS b with(nolock)
				where b.MONEDA not in ( 
											select a.C6399 
											from MONEDAS a with(nolock) )
	ELSE 
			print ''Comprobación OK. Tabla SALDOS con MONEDAS ''
	if exists (
				select b.SUCURSAL 
				from SALDOS b with(nolock)
				where b.SUCURSAL not in ( 
											select a.SUCURSAL 
											from SUCURSALES a with(nolock) )
				)
			select ''Tabla SALDOS no se ajusta a la integridad referencial con SUCURSALES '',*
				from SALDOS b with(nolock)
				where b.SUCURSAL not in ( 
											select a.SUCURSAL 
											from SUCURSALES a with(nolock) )
	ELSE 
			print ''Comprobación OK. Tabla SALDOS con SUCURSALES ''
	if exists (
				select b.NUMERO_SOLICITUD 
				from CRE_SOL_DEUDA_EXTERNA b with(nolock)
				where b.NUMERO_SOLICITUD not in ( 
											select a.NUMEROSOLICITUD 
											from CRE_SOLICITUDCREDITO a with(nolock) )
				)
			select ''Tabla CRE_SOL_DEUDA_EXTERNA no se ajusta a la integridad referencial con CRE_SOLICITUDCREDITO '',*
				from CRE_SOL_DEUDA_EXTERNA b with(nolock)
				where b.NUMERO_SOLICITUD not in ( 
											select a.NUMEROSOLICITUD 
											from CRE_SOLICITUDCREDITO a with(nolock) )
	ELSE 
			print ''Comprobación OK. Tabla CRE_SOL_DEUDA_EXTERNA con CRE_SOLICITUDCREDITO ''
	if exists (
				select b.SOLICITUD 
				from SL_CRITERIOS b with(nolock)
				where b.SOLICITUD not in ( 
											select a.NUMEROSOLICITUD 
											from CRE_SOLICITUDCREDITO a with(nolock) )
				)
			select ''Tabla SL_CRITERIOS no se ajusta a la integridad referencial con CRE_SOLICITUDCREDITO '',*
				from SL_CRITERIOS b with(nolock)
				where b.SOLICITUD not in ( 
											select a.NUMEROSOLICITUD 
											from CRE_SOLICITUDCREDITO a with(nolock) )
	ELSE 
			print ''Comprobación OK. Tabla SL_CRITERIOS con CRE_SOLICITUDCREDITO ''
	if exists (
				select b.NRO_SOLICITUD 
				from CRE_SOL_PLAN_PAGOS b with(nolock)
				where b.NRO_SOLICITUD not in ( 
											select a.NUMEROSOLICITUD 
											from CRE_SOLICITUDCREDITO a with(nolock) )
				)
			select ''Tabla CRE_SOL_PLAN_PAGOS no se ajusta a la integridad referencial con CRE_SOLICITUDCREDITO '',*
				from CRE_SOL_PLAN_PAGOS b with(nolock)
				where b.NRO_SOLICITUD not in ( 
											select a.NUMEROSOLICITUD 
											from CRE_SOLICITUDCREDITO a with(nolock) )
	ELSE 
			print ''Comprobación OK. Tabla CRE_SOL_PLAN_PAGOS con CRE_SOLICITUDCREDITO ''
	if exists (
				select b.NUMERO_SOLICITUD 
				from CRE_DET_REESTRUCTURA b with(nolock)
				where b.NUMERO_SOLICITUD not in ( 
											select a.NUMEROSOLICITUD 
											from CRE_SOLICITUDCREDITO a with(nolock) )
				)
			select ''Tabla CRE_DET_REESTRUCTURA no se ajusta a la integridad referencial con CRE_SOLICITUDCREDITO '',*
				from CRE_DET_REESTRUCTURA b with(nolock)
				where b.NUMERO_SOLICITUD not in ( 
											select a.NUMEROSOLICITUD 
											from CRE_SOLICITUDCREDITO a with(nolock) )
	ELSE 
			print ''Comprobación OK. Tabla CRE_DET_REESTRUCTURA con CRE_SOLICITUDCREDITO ''	
	if exists (
				select b.SOLICITUD 
				from CRE_SOL_RECIBO_SUELDO b with(nolock)
				where b.SOLICITUD not in ( 
											select a.NUMEROSOLICITUD 
											from CRE_SOLICITUDCREDITO a with(nolock) )
				)
			select ''Tabla CRE_SOL_RECIBO_SUELDO no se ajusta a la integridad referencial con CRE_SOLICITUDCREDITO '',*
				from CRE_SOL_RECIBO_SUELDO b with(nolock)
				where b.SOLICITUD not in ( 
											select a.NUMEROSOLICITUD 
											from CRE_SOLICITUDCREDITO a with(nolock) )
	ELSE 
			print ''Comprobación OK. Tabla CRE_SOL_RECIBO_SUELDO con CRE_SOLICITUDCREDITO ''	
	if exists (
				select b.NUMERO_SOLICITUD 
				from CRE_SOLICITUD_EXCEPCION b with(nolock)
				where b.NUMERO_SOLICITUD not in ( 
											select a.NUMEROSOLICITUD 
											from CRE_SOLICITUDCREDITO a with(nolock) )
				)
			select ''Tabla CRE_SOLICITUD_EXCEPCION no se ajusta a la integridad referencial con CRE_SOLICITUDCREDITO '',*
				from CRE_SOLICITUD_EXCEPCION b with(nolock)
				where b.NUMERO_SOLICITUD not in ( 
											select a.NUMEROSOLICITUD 
											from CRE_SOLICITUDCREDITO a with(nolock) )
	ELSE 
			print ''Comprobación OK. Tabla CRE_SOLICITUD_EXCEPCION con CRE_SOLICITUDCREDITO ''	
	if exists (
				select b.ASEGURADORA 
				from CRE_SOLICITUDCREDITO b with(nolock)
				where b.ASEGURADORA not in ( 
											select a.CODIGO 
											from CRE_ASEGURADORAS a with(nolock) )
				)
			select ''Tabla CRE_SOLICITUDCREDITO no se ajusta a la integridad referencial con CRE_ASEGURADORAS '',*
				from CRE_SOLICITUDCREDITO b with(nolock)
				where b.ASEGURADORA not in ( 
											select a.NUMEROSOLICITUD 
											from CRE_SOLICITUDCREDITO a with(nolock) )
	ELSE 
			print ''Comprobación OK. Tabla CRE_SOLICITUDCREDITO con CRE_ASEGURADORAS ''	

	if exists (
				select b.NUMERO_SOLICITUD 
				from CRE_SOLICITUD_EXCEPCION b with(nolock)
				where b.NUMERO_SOLICITUD not in ( 
											select a.NUMEROSOLICITUD 
											from CRE_SOLICITUDCREDITO a with(nolock) )
				)
			select ''Tabla CRE_SOLICITUD_EXCEPCION no se ajusta a la integridad referencial con CRE_SOLICITUDCREDITO '',*
				from CRE_SOLICITUD_EXCEPCION b with(nolock)
				where b.NUMERO_SOLICITUD not in ( 
											select a.NUMEROSOLICITUD 
											from CRE_SOLICITUDCREDITO a with(nolock) )
	ELSE 
			print ''Comprobación OK. Tabla CRE_SOLICITUD_EXCEPCION con CRE_SOLICITUDCREDITO ''	
	if exists (
				select b.SOLICITUD 
				from CRE_REL_SOLICITUDGARANTIA b with(nolock)
				where b.SOLICITUD not in ( 
											select a.NUMEROSOLICITUD 
											from CRE_SOLICITUDCREDITO a with(nolock) )
				)
			select ''Tabla CRE_REL_SOLICITUDGARANTIA no se ajusta a la integridad referencial con CRE_SOLICITUDCREDITO '',*
				from CRE_REL_SOLICITUDGARANTIA b with(nolock)
				where b.SOLICITUD not in ( 
											select a.NUMEROSOLICITUD 
											from CRE_SOLICITUDCREDITO a with(nolock) )
	ELSE 
			print ''Comprobación OK. Tabla CRE_REL_SOLICITUDGARANTIA con CRE_SOLICITUDCREDITO ''	

	if exists (
				select b.NUMERO_BIEN 
				from CRE_GASTOS_LEASING b with(nolock)
				where b.NUMERO_BIEN not in ( 
											select a.NUMERO_BIEN 
											from CRE_BIENES_LEASING a with(nolock) )
				)
			select ''Tabla CRE_GASTOS_LEASING no se ajusta a la integridad referencial con CRE_BIENES_LEASING '',*
				from CRE_GASTOS_LEASING b with(nolock)
				where b.NUMERO_BIEN not in ( 
											select a.NUMERO_BIEN 
											from CRE_BIENES_LEASING a with(nolock) )
	ELSE 
			print ''Comprobación OK. Tabla CRE_GASTOS_LEASING con CRE_BIENES_LEASING ''

	if exists (
				select b.NUMERO_BIEN 
				from BIE_INMOBILIARIO b with(nolock)
				where b.NUMERO_BIEN not in ( 
											select a.NUMERO_BIEN 
											from CRE_BIENES_LEASING a with(nolock) )
				)
			select ''Tabla BIE_INMOBILIARIO no se ajusta a la integridad referencial con CRE_BIENES_LEASING '',*
				from BIE_INMOBILIARIO b with(nolock)
				where b.NUMERO_BIEN not in ( 
											select a.NUMERO_BIEN 
											from CRE_BIENES_LEASING a with(nolock) )
	ELSE 
			print ''Comprobación OK. Tabla BIE_INMOBILIARIO con CRE_BIENES_LEASING ''	

	if exists (
				select b.NUMERO_BIEN 
				from CRE_FACTURAS_LEASING b with(nolock)
				where b.NUMERO_BIEN not in ( 
											select a.NUMERO_BIEN 
											from CRE_BIENES_LEASING a with(nolock) )
				)
			select ''Tabla CRE_FACTURAS_LEASING no se ajusta a la integridad referencial con CRE_BIENES_LEASING '',*
				from CRE_FACTURAS_LEASING b with(nolock)
				where b.NUMERO_BIEN not in ( 
											select a.NUMERO_BIEN 
											from CRE_BIENES_LEASING a with(nolock) )
	ELSE 
			print ''Comprobación OK. Tabla CRE_FACTURAS_LEASING con CRE_BIENES_LEASING ''		

	if exists (
				select b.CIRCUNSCRIPCION 
				from BIE_INMOBILIARIO b with(nolock)
				where b.CIRCUNSCRIPCION not in ( 
											select a.Id 
											from DJ_CIRCUNSCRIPCION a with(nolock) )
				)
			select ''Tabla BIE_INMOBILIARIO no se ajusta a la integridad referencial con DJ_CIRCUNSCRIPCION '',*
				from BIE_INMOBILIARIO b with(nolock)
				where b.CIRCUNSCRIPCION not in ( 
											select a.Id 
											from DJ_CIRCUNSCRIPCION a with(nolock) )
	ELSE 
			print ''Comprobación OK. Tabla BIE_INMOBILIARIO con DJ_CIRCUNSCRIPCION ''	
	if exists (
				select b.NRO_TASADOR 
				from BIE_INMOBILIARIO b with(nolock)
				where b.NRO_TASADOR not in ( 
											select a.NRO_TASADOR 
											from CRE_TASADORES a with(nolock) )
				)
			select ''Tabla BIE_INMOBILIARIO no se ajusta a la integridad referencial con CRE_TASADORES '',*
				from BIE_INMOBILIARIO b with(nolock)
				where b.NRO_TASADOR not in ( 
											select a.NRO_TASADOR 
											from CRE_TASADORES a with(nolock) )
	ELSE 
			print ''Comprobación OK. Tabla BIE_INMOBILIARIO con CRE_TASADORES ''	
	if exists (
				select b.ID_CARGO 
				from CI_CARGOS_MEMORIA b with(nolock)
				where b.ID_CARGO not in ( 
											select a.ID_CARGO 
											from CI_CARGOS a with(nolock) )
				)
			select ''Tabla CI_CARGOS_MEMORIA no se ajusta a la integridad referencial con CI_CARGOS '',*
				from CI_CARGOS_MEMORIA b with(nolock)
				where b.ID_CARGO not in ( 
											select a.ID_CARGO 
											from CI_CARGOS a with(nolock) )
	ELSE 
			print ''Comprobación OK. Tabla CI_CARGOS_MEMORIA con CI_CARGOS ''	
	if exists (
				select b.GESTOR_ESCRIBANO 
				from CRE_GASTOS_LEASING b with(nolock)
				where b.GESTOR_ESCRIBANO not in ( 
											select a.NUMESCRIBANO
											from CRE_ESCRIBANOS a with(nolock) )
				)
			select ''Tabla CRE_GASTOS_LEASING no se ajusta a la integridad referencial con CRE_ESCRIBANOS '',*
				from CRE_GASTOS_LEASING b with(nolock)
				where b.GESTOR_ESCRIBANO not in ( 
											select a.NUMESCRIBANO
											from CRE_ESCRIBANOS a with(nolock) )
	ELSE 
			print ''Comprobación OK. Tabla CRE_GASTOS_LEASING con CRE_ESCRIBANOS ''	
	if exists (
				select b.ORGANISMO_EMISOR 
				from BIE_OTROS b with(nolock)
				where b.ORGANISMO_EMISOR not in ( 
											select a.TIPO_ORGANISMO
											from CRE_GAR_ORGANISMOS a with(nolock) )
				)
			select ''Tabla BIE_OTROS no se ajusta a la integridad referencial con CRE_GAR_ORGANISMOS '',*
				from BIE_OTROS b with(nolock)
				where b.ORGANISMO_EMISOR not in ( 
											select a.TIPO_ORGANISMO
											from CRE_GAR_ORGANISMOS a with(nolock) )
	ELSE 
			print ''Comprobación OK. Tabla BIE_OTROS con CRE_GAR_ORGANISMOS ''
	if exists (
				select b.CodigoSubsidio 
				from CRE_SUBSIDIOS_PRESTAMOS b with(nolock)
				where b.CodigoSubsidio not in ( 
											select a.CodigoSubsidio
											from CRE_SUBSIDIOS a with(nolock) )
				)
			select ''Tabla CRE_SUBSIDIOS_PRESTAMOS no se ajusta a la integridad referencial con CRE_SUBSIDIOS '',*
				from CRE_SUBSIDIOS_PRESTAMOS b with(nolock)
				where b.CodigoSubsidio not in ( 
											select a.CodigoSubsidio
											from CRE_SUBSIDIOS a with(nolock) )
	ELSE 
			print ''Comprobación OK. Tabla CRE_SUBSIDIOS_PRESTAMOS con CRE_SUBSIDIOS ''
	if exists (
				select b.COD_SUBSIDIO 
				from CRE_Prod_SUBSIDIOS b with(nolock)
				where b.COD_SUBSIDIO not in ( 
											select a.CodigoSubsidio
											from CRE_SUBSIDIOS a with(nolock) )
				)
			select ''Tabla CRE_Prod_SUBSIDIOS no se ajusta a la integridad referencial con CRE_SUBSIDIOS '',*
				from CRE_Prod_SUBSIDIOS b with(nolock)
				where b.COD_SUBSIDIO not in ( 
											select a.CodigoSubsidio
											from CRE_SUBSIDIOS a with(nolock) )
	ELSE 
			print ''Comprobación OK. Tabla CRE_Prod_SUBSIDIOS con CRE_SUBSIDIOS ''
	if exists (
				select b.TIPO_CONVENIO 
				from CRE_PROD_CONVENIOS b with(nolock)
				where b.TIPO_CONVENIO not in ( 
											select a.ID_ConvPago
											from CONV_CONVENIOS_PAG a with(nolock) )
				)
			select ''Tabla CRE_Prod_SUBSIDIOS no se ajusta a la integridad referencial con CRE_SUBSIDIOS '',*
				from CRE_PROD_CONVENIOS b with(nolock)
				where b.TIPO_CONVENIO not in ( 
											select a.ID_ConvPago
											from CONV_CONVENIOS_PAG a with(nolock) )
	ELSE 
			print ''Comprobación OK. Tabla CRE_Prod_SUBSIDIOS con CRE_SUBSIDIOS ''
	if exists (
				select b.Id_TpoConv 
				from CONV_CONVENIOS_PAG b with(nolock)
				where b.Id_TpoConv not in ( 
											select a.Id_TpoConv
											from CONV_TIPOS a with(nolock) )
				)
			select ''Tabla CONV_CONVENIOS_PAG no se ajusta a la integridad referencial con CONV_TIPOS '',*
				from CONV_CONVENIOS_PAG b with(nolock)
				where b.Id_TpoConv not in ( 
											select a.Id_TpoConv
											from CONV_TIPOS a with(nolock) )
	ELSE 
			print ''Comprobación OK. Tabla CONV_CONVENIOS_PAG con CONV_TIPOS ''
	if exists (
				select b.PRODUCTO 
				from CRE_SCORINGPORCUOTAS b with(nolock)
				where b.PRODUCTO not in ( 
											select a.C6250
											from PRODUCTOS a with(nolock) )
				)
			select ''Tabla CRE_SCORINGPORCUOTAS no se ajusta a la integridad referencial con PRODUCTOS '',*
				from CRE_SCORINGPORCUOTAS b with(nolock)
				where b.PRODUCTO not in ( 
											select a.C6250
											from PRODUCTOS a with(nolock) )
	ELSE 
			print ''Comprobación OK. Tabla CRE_SCORINGPORCUOTAS con PRODUCTOS ''
	if exists (
				select b.COD_PRODUCTO 
				from CRE_Prod_SUBSIDIOS b with(nolock)
				where b.COD_PRODUCTO not in ( 
											select a.C6250
											from PRODUCTOS a with(nolock) )
				)
			select ''Tabla CRE_Prod_SUBSIDIOS no se ajusta a la integridad referencial con PRODUCTOS '',*
				from CRE_Prod_SUBSIDIOS b with(nolock)
				where b.COD_PRODUCTO not in ( 
											select a.C6250
											from PRODUCTOS a with(nolock) )
	ELSE 
			print ''Comprobación OK. Tabla CRE_Prod_SUBSIDIOS con PRODUCTOS ''
	if exists (
				select b.COD_PRODUCTO 
				from CRE_PROD_FUENTEFONDO b with(nolock)
				where b.COD_PRODUCTO not in ( 
											select a.C6250
											from PRODUCTOS a with(nolock) )
				)
			select ''Tabla CRE_PROD_FUENTEFONDO no se ajusta a la integridad referencial con PRODUCTOS '',*
				from CRE_PROD_FUENTEFONDO b with(nolock)
				where b.COD_PRODUCTO not in ( 
											select a.C6250
											from PRODUCTOS a with(nolock) )
	ELSE 
			print ''Comprobación OK. Tabla CRE_PROD_FUENTEFONDO con PRODUCTOS ''
	if exists (
				select b.COD_FUENTE_FONDO 
				from CRE_PROD_FUENTEFONDO b with(nolock)
				where b.COD_FUENTE_FONDO not in ( 
											select a.CODIGO
											from CRE_FUENTEFONDO a with(nolock) )
				)
			select ''Tabla CRE_PROD_FUENTEFONDO no se ajusta a la integridad referencial con CRE_FUENTEFONDO '',*
				from CRE_PROD_FUENTEFONDO b with(nolock)
				where b.COD_FUENTE_FONDO not in ( 
											select a.CODIGO
											from CRE_FUENTEFONDO a with(nolock) )
	ELSE 
			print ''Comprobación OK. Tabla CRE_PROD_FUENTEFONDO con CRE_FUENTEFONDO ''
	if exists (
				select b.CODIGO_DESTINO 
				from CRE_PROD_DESTINOS b with(nolock)
				where b.CODIGO_DESTINO not in ( 
											select a.CODIGO
											from CRE_DESTINOS a with(nolock) )
				)
			select ''Tabla CRE_PROD_DESTINOS no se ajusta a la integridad referencial con CRE_DESTINOS '',*
				from CRE_PROD_DESTINOS b with(nolock)
				where b.CODIGO_DESTINO not in ( 
											select a.CODIGO
											from CRE_DESTINOS a with(nolock) )
	ELSE 
			print ''Comprobación OK. Tabla CRE_PROD_DESTINOS con CRE_DESTINOS ''
	if exists (
				select b.CODIGO_PRODUCTO 
				from CRE_PROD_DESTINOS b with(nolock)
				where b.CODIGO_PRODUCTO not in ( 
											select a.C6250
											from PRODUCTOS a with(nolock) )
				)
			select ''Tabla CRE_PROD_DESTINOS no se ajusta a la integridad referencial con PRODUCTOS '',*
				from CRE_PROD_DESTINOS b with(nolock)
				where b.CODIGO_PRODUCTO not in ( 
											select a.C6250
											from PRODUCTOS a with(nolock) )
	ELSE 
			print ''Comprobación OK. Tabla CRE_PROD_DESTINOS con PRODUCTOS ''

	if exists (
				select b.CODPRODUCTO 
				from TOPESPRODUCTO b with(nolock)
				where b.CODPRODUCTO not in ( 
											select a.C6250
											from PRODUCTOS a with(nolock) )
				)
			select ''Tabla TOPESPRODUCTO no se ajusta a la integridad referencial con PRODUCTOS '',*
				from TOPESPRODUCTO b with(nolock)
				where b.CODPRODUCTO not in ( 
											select a.C6250
											from PRODUCTOS a with(nolock) )
	ELSE 
			print ''Comprobación OK. Tabla TOPESPRODUCTO con PRODUCTOS ''
	if exists (
				select b.PRODUCTO 
				from CRE_PRODUCTOSCANALDIGITAL b with(nolock)
				where b.PRODUCTO not in ( 
											select a.C6250
											from PRODUCTOS a with(nolock) )
				)
			select ''Tabla CRE_PRODUCTOSCANALDIGITAL no se ajusta a la integridad referencial con PRODUCTOS '',*
				from CRE_PRODUCTOSCANALDIGITAL b with(nolock)
				where b.PRODUCTO not in ( 
											select a.C6250
											from PRODUCTOS a with(nolock) )
	ELSE 
			print ''Comprobación OK. Tabla CRE_PRODUCTOSCANALDIGITAL con PRODUCTOS ''
	if exists (
				select b.PRODUCTO 
				from CRE_PROD_CONVENIOS b with(nolock)
				where b.PRODUCTO not in ( 
											select a.C6250
											from PRODUCTOS a with(nolock) )
				)
			select ''Tabla CRE_PROD_CONVENIOS no se ajusta a la integridad referencial con PRODUCTOS '',*
				from CRE_PROD_CONVENIOS b with(nolock)
				where b.PRODUCTO not in ( 
											select a.C6250
											from PRODUCTOS a with(nolock) )
	ELSE 
			print ''Comprobación OK. Tabla CRE_PROD_CONVENIOS con PRODUCTOS ''
	if exists (
				select b.PRODUCTO 
				from CRE_PROD_ADMINISTRADORAS b with(nolock)
				where b.PRODUCTO not in ( 
											select a.C6250
											from PRODUCTOS a with(nolock) )
				)
			select ''Tabla CRE_PROD_ADMINISTRADORAS no se ajusta a la integridad referencial con PRODUCTOS '',*
				from CRE_PROD_ADMINISTRADORAS b with(nolock)
				where b.PRODUCTO not in ( 
											select a.C6250
											from PRODUCTOS a with(nolock) )
	ELSE 
			print ''Comprobación OK. Tabla CRE_PROD_ADMINISTRADORAS con PRODUCTOS ''
	if exists (
				select b.NRO_ACUERDO 
				from VTA_TASAS_SOBREGIROS b with(nolock)
				where b.NRO_ACUERDO not in ( 
											select a.NRO_AUTORIZACION
											from VTA_SOBREGIROS a with(nolock) )
				)
			select ''Tabla VTA_TASAS_SOBREGIROS no se ajusta a la integridad referencial con VTA_SOBREGIROS '',*
				from VTA_TASAS_SOBREGIROS b with(nolock)
				where b.NRO_ACUERDO not in ( 
											select a.NRO_AUTORIZACION
											from VTA_SOBREGIROS a with(nolock) )
	ELSE 
			print ''Comprobación OK. Tabla VTA_TASAS_SOBREGIROS con VTA_SOBREGIROS ''
	if exists (
				select b.RIESGO 
				from CRE_FAMILIAS b with(nolock)
				where b.RIESGO not in ( 
											select a.CODIGO_RIESGO
											from CRE_TIPOS_RIESGOS a with(nolock) )
				)
			select ''Tabla CRE_FAMILIAS no se ajusta a la integridad referencial con CRE_TIPOS_RIESGOS '',*
				from CRE_FAMILIAS b with(nolock)
				where b.RIESGO not in ( 
											select a.CODIGO_RIESGO
											from CRE_TIPOS_RIESGOS a with(nolock) )
	ELSE 
			print ''Comprobación OK. Tabla CRE_FAMILIAS con CRE_TIPOS_RIESGOS ''
	if exists (
				select b.MONEDA 
				from CRE_FAMILIAS b with(nolock)
				where b.MONEDA not in ( 
											select a.C6399
											from MONEDAS a with(nolock) )
				)
			select ''Tabla CRE_FAMILIAS no se ajusta a la integridad referencial con MONEDAS '',*
				from CRE_FAMILIAS b with(nolock)
				where b.MONEDA not in ( 
											select a.C6399
											from MONEDAS a with(nolock) )
	ELSE 
			print ''Comprobación OK. Tabla CRE_FAMILIAS con MONEDAS ''
	if exists (
				select b.MONEDA 
				from TASAS b with(nolock)
				where b.MONEDA not in ( 
											select a.C6399
											from MONEDAS a with(nolock) )
				)
			select ''Tabla TASAS no se ajusta a la integridad referencial con MONEDAS '',*
				from TASAS b with(nolock)
				where b.MONEDA not in ( 
											select a.C6399
											from MONEDAS a with(nolock) )
	ELSE 
			print ''Comprobación OK. Tabla TASAS con MONEDAS ''
	if exists (
				select b.MONEDA 
				from CRE_LIMITE_GARANTIA b with(nolock)
				where b.MONEDA not in ( 
											select a.C6399
											from MONEDAS a with(nolock) )
				)
			select ''Tabla CRE_LIMITE_GARANTIA no se ajusta a la integridad referencial con MONEDAS '',*
				from CRE_LIMITE_GARANTIA b with(nolock)
				where b.MONEDA not in ( 
											select a.C6399
											from MONEDAS a with(nolock) )
	ELSE 
			print ''Comprobación OK. Tabla CRE_LIMITE_GARANTIA con MONEDAS ''
	if exists (
				select b.TIPO_GARANTIA 
				from CRE_LIMITE_GARANTIA b with(nolock)
				where b.TIPO_GARANTIA not in ( 
											select a.TIPOGARANTIA
											from CRE_CLASGARANTIAS a with(nolock) )
				)
			select ''Tabla CRE_LIMITE_GARANTIA no se ajusta a la integridad referencial con CRE_CLASGARANTIAS '',*
				from CRE_LIMITE_GARANTIA b with(nolock)
				where b.TIPO_GARANTIA not in ( 
											select a.TIPOGARANTIA
											from CRE_CLASGARANTIAS a with(nolock) )
	ELSE 
			print ''Comprobación OK. Tabla CRE_LIMITE_GARANTIA con CRE_CLASGARANTIAS ''
	if exists (
				select b.SUBTIPOGTIA 
				from CRE_CLASGARANTIAS b with(nolock)
				where b.SUBTIPOGTIA not in ( 
											select a.COD_SUBTIPO_GARANTIA
											from CRE_SUBTIPOGARANTIAS a with(nolock) )
				)
			select ''Tabla CRE_CLASGARANTIAS no se ajusta a la integridad referencial con CRE_CLASGARANTIAS '',*
				from CRE_CLASGARANTIAS b with(nolock)
				where b.SUBTIPOGTIA not in ( 
											select a.TIPOGARANTIA
											from CRE_CLASGARANTIAS a with(nolock) )
	ELSE 
			print ''Comprobación OK. Tabla CRE_CLASGARANTIAS con CRE_CLASGARANTIAS ''
	if exists (
				select b.COD_SUBCLA_GARANTIA 
				from CRE_CLASGARANTIAS b with(nolock)
				where b.COD_SUBCLA_GARANTIA not in ( 
											select a.COD_SUBCLASIFICACIONGARANTIA
											from CRE_SUBCLASGARANTIAS a with(nolock) )
				)
			select ''Tabla CRE_CLASGARANTIAS no se ajusta a la integridad referencial con CRE_SUBCLASGARANTIAS '',*
				from CRE_CLASGARANTIAS b with(nolock)
				where b.SUBTIPOGTIA not in ( 
											select a.COD_SUBCLASIFICACIONGARANTIA
											from CRE_SUBCLASGARANTIAS a with(nolock) )
	ELSE 
			print ''Comprobación OK. Tabla CRE_CLASGARANTIAS con CRE_SUBCLASGARANTIAS ''

	if exists (
				select b.CODIGO_RECHAZO 
				from CLE_RECEPCION_CHEQUES_DEV b with(nolock)
				where b.CODIGO_RECHAZO not in ( 
											select a.CODIGO_DE_CAUSAL
											from CLE_TIPO_CAUSAL a with(nolock) )
				)
			select ''Tabla CLE_RECEPCION_CHEQUES_DEV no se ajusta a la integridad referencial con CLE_TIPO_CAUSAL '',*
				from CLE_RECEPCION_CHEQUES_DEV b with(nolock)
				where b.CODIGO_RECHAZO not in ( 
											select a.CODIGO_DE_CAUSAL
											from CLE_TIPO_CAUSAL a with(nolock) )
	ELSE 
			print ''Comprobación OK. Tabla CLE_RECEPCION_CHEQUES_DEV con CLE_TIPO_CAUSAL ''
	if exists (
				select b.JTS_OID_CV 
				from CRE_ADELANTOS_HABERES b with(nolock)
				where b.JTS_OID_CV not in ( 
											select a.JTS_OID
											from SALDOS a with(nolock) )
				)
			select ''Tabla CRE_ADELANTOS_HABERES no se ajusta a la integridad referencial con SALDOS '',*
				from CRE_ADELANTOS_HABERES b with(nolock)
				where b.JTS_OID_CV not in ( 
											select a.JTS_OID
											from SALDOS a with(nolock) )
	ELSE 
			print ''Comprobación OK. Tabla CRE_ADELANTOS_HABERES con SALDOS ''
	if exists (
				select b.JTS_PRESTAMO 
				from HISTORICO_CALIF_X_SALDO b with(nolock)
				where b.JTS_PRESTAMO not in ( 
											select a.JTS_OID
											from SALDOS a with(nolock) )
				)
			select ''Tabla HISTORICO_CALIF_X_SALDO no se ajusta a la integridad referencial con SALDOS '',*
				from HISTORICO_CALIF_X_SALDO b with(nolock)
				where b.JTS_PRESTAMO not in ( 
											select a.JTS_OID
											from SALDOS a with(nolock) )
	ELSE 
			print ''Comprobación OK. Tabla HISTORICO_CALIF_X_SALDO con SALDOS ''
	if exists (
				select b.JTS_OID_SALDO 
				from CLE_CHEQUES_LISTA_DESCUENTO b with(nolock)
				where b.JTS_OID_SALDO not in ( 
											select a.JTS_OID
											from SALDOS a with(nolock) )
				)
			select ''Tabla CLE_CHEQUES_LISTA_DESCUENTO no se ajusta a la integridad referencial con SALDOS '',*
				from CLE_CHEQUES_LISTA_DESCUENTO b with(nolock)
				where b.JTS_OID_SALDO not in ( 
											select a.JTS_OID
											from SALDOS a with(nolock) )
	ELSE 
			print ''Comprobación OK. Tabla CLE_CHEQUES_LISTA_DESCUENTO con SALDOS ''
	if exists (
				select b.SALDOS_JTS_OID 
				from CRE_SEGURO_SALDO_DEUDOR b with(nolock)
				where b.SALDOS_JTS_OID not in ( 
											select a.JTS_OID
											from SALDOS a with(nolock) )
				)
			select ''Tabla CRE_SEGURO_SALDO_DEUDOR no se ajusta a la integridad referencial con SALDOS '',*
				from CRE_SEGURO_SALDO_DEUDOR b with(nolock)
				where b.SALDOS_JTS_OID not in ( 
											select a.JTS_OID
											from SALDOS a with(nolock) )
	ELSE 
			print ''Comprobación OK. Tabla CRE_SEGURO_SALDO_DEUDOR con SALDOS ''
	if exists (
				select b.JTS_SALDO_TARJETA 
				from TJC_HISTORICO_PAGOS b with(nolock)
				where b.JTS_SALDO_TARJETA not in ( 
											select a.JTS_OID
											from SALDOS a with(nolock) )
				)
			select ''Tabla TJC_HISTORICO_PAGOS no se ajusta a la integridad referencial con SALDOS '',*
				from TJC_HISTORICO_PAGOS b with(nolock)
				where b.JTS_SALDO_TARJETA not in ( 
											select a.JTS_OID
											from SALDOS a with(nolock) )
	ELSE 
			print ''Comprobación OK. Tabla TJC_HISTORICO_PAGOS con SALDOS ''
	if exists (
				select b.ASEGURADORA 
				from CRE_PROD_SEGUROS_SALDO_DEUDOR b with(nolock)
				where b.ASEGURADORA not in ( 
											select a.CODIGO
											from CRE_ASEGURADORAS a with(nolock) )
				)
			select ''Tabla CRE_PROD_SEGUROS_SALDO_DEUDOR no se ajusta a la integridad referencial con CRE_ASEGURADORAS '',*
				from CRE_PROD_SEGUROS_SALDO_DEUDOR b with(nolock)
				where b.ASEGURADORA not in ( 
											select a.CODIGO
											from CRE_ASEGURADORAS a with(nolock) )
	ELSE 
			print ''Comprobación OK. Tabla CRE_PROD_SEGUROS_SALDO_DEUDOR con CRE_ASEGURADORAS ''
	if exists (
				select b.TIPOTASAINT 
				from TASAS b with(nolock)
				where b.TIPOTASAINT not in ( 
											select a.TIPOTASABASE
											from TASASBASE_CODIGOS a with(nolock) )
				)
			select ''Tabla TASAS no se ajusta a la integridad referencial con TASASBASE_CODIGOS '',*
				from TASAS b with(nolock)
				where b.TIPOTASAINT not in ( 
											select a.TIPOTASABASE
											from TASASBASE_CODIGOS a with(nolock) )
	ELSE 
			print ''Comprobación OK. Tabla TASAS con TASASBASE_CODIGOS ''
	if exists (
				select b.PRODUCTO 
				from TASAS b with(nolock)
				where b.PRODUCTO not in ( 
											select a.C6250
											from PRODUCTOS a with(nolock) )
				)
			select ''Tabla TASAS no se ajusta a la integridad referencial con PRODUCTOS '',*
				from TASAS b with(nolock)
				where b.PRODUCTO not in ( 
											select a.C6250
											from PRODUCTOS a with(nolock) )
	ELSE 
			print ''Comprobación OK. Tabla TASAS con PRODUCTOS ''
	END
ELSE
	print ''NO CORRESPONDE LA BASE DE DATOS''
END
; ')