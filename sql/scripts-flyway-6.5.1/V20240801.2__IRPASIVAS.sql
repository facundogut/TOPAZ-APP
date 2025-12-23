execute('
----------------------------------------PASIVAS.-----------------------------------------------------------
--exec [dbo].[SP_INTEGRIDAD_REFERENCIAL_PASIVAS] NBCH_tunning

CREATE OR ALTER  procedure [dbo].[SP_INTEGRIDAD_REFERENCIAL_PASIVAS] 
						@BD varchar(20)
as
BEGIN
IF (SELECT DB_NAME()) = @BD
  BEGIN
	print ''-------------------PASIVAS--------------''
	print ''-----------------------------------------''

	if exists (	select a.ESTADO 
				from CHE_CHEQUERAS a with(nolock) 
				where a.ESTADO not in  (select b.CODIGO 
										from CHE_ESTADOSCHEQUERAS b with(nolock))
				)	
				SELECT ''Tabla CHE_CHEQUERAS no se ajusta a la integridad referencial con CHE_ESTADOSCHEQUERAS '',*
				from	CHE_CHEQUERAS a with(nolock) 
				where	a.ESTADO not in  (select b.CODIGO 
										from CHE_ESTADOSCHEQUERAS b with(nolock))
	else
	print ''Comprobación OK.Tabla CHE_CHEQUERAS con CHE_ESTADOSCHEQUERAS ''
-----------------------------------------2	
	if exists (select a.ESTADO 
				from CHE_CHEQUES a with(nolock) 
				where a.ESTADO not in  (select b.CODIGO 
										from CHE_ESTADOSCHEQUES b with(nolock))
				)	
				SELECT   ''Tabla CHE_CHEQUES no se ajusta a la integridad referencial con CHE_ESTADOSCHEQUES '',*
				from CHE_CHEQUES a with(nolock) 
				where a.ESTADO not in  (select b.CODIGO 
										from CHE_ESTADOSCHEQUES b with(nolock))
	else
	print ''Comprobación OK.Tabla CHE_CHEQUES con CHE_ESTADOSCHEQUES ''
--------------------------------------------3	
	if exists (	select c.NroSolicitud,c.Sucursal 
				from CHE_CHEQUESIMPRENTA c with(nolock) 
				where not exists
								(select A.NroSolicitud,a.Sucursal
								from CHE_CHEQUESIMPRENTA a with(nolock) 
								inner join Che_CheqSolicitud b with(nolock) on a.NroSolicitud	= b.NroSolicitud
																			and a.Sucursal=b.SUCURSAL)
				)	
				SELECT    ''Tabla CHE_CHEQUESIMPRENTA no se ajusta a la integridad referencial con Che_CheqSolicitud '',*
				from CHE_CHEQUESIMPRENTA c with(nolock) 
				where not exists
								(select A.NroSolicitud,a.Sucursal
								from CHE_CHEQUESIMPRENTA a with(nolock) 
								inner join Che_CheqSolicitud b with(nolock) on  a.NroSolicitud	= b.NroSolicitud
																			and a.Sucursal = b.SUCURSAL)
	else
	print ''Comprobación OK.Tabla CHE_CHEQUESIMPRENTA con Che_CheqSolicitud ''
---------------------------------------------4	
	if exists (select b.codigo_motivo_rechazo 
				from CHE_CHEQUESDENUNCIADOS  b with(nolock) 
				where b.codigo_motivo_rechazo not in (	select a.CODIGO_BCRA 
														from CHE_MOTIVOS_RECHAZO a with(nolock)) 
				)	
				SELECT   ''Tabla CHE_CHEQUESDENUNCIADOS no se ajusta a la integridad referencial con CHE_MOTIVOS_RECHAZO '',*
				from CHE_CHEQUESDENUNCIADOS  b with(nolock) 
				where b.codigo_motivo_rechazo not in (select a.CODIGO_BCRA 
											from CHE_MOTIVOS_RECHAZO a with(nolock)) 
	else
	print ''Comprobación OK.Tabla CHE_CHEQUESDENUNCIADOS con CHE_MOTIVOS_RECHAZO ''
----------------------------------------------5	
	if exists (select b.NRO_SOLICITUD 
				from CHE_SOLICITUD_CANJE_INTERNO b  with(nolock)
				left join CHE_CHEQUES a  with(nolock)on a.NRO_SOLICITUD = b.NRO_SOLICITUD
														and a.serie = b.SERIE							
														and a.NUMEROCHEQUE = b.NRO_CHEQUE
				where a.NRO_SOLICITUD is null
						and a.SERIE is null
						and a.NUMEROCHEQUE is null 
				)	
				SELECT    ''Tabla CHE_SOLICITUD_CANJE_INTERNO no se ajusta a la integridad referencial con CHE_CHEQUES '',*
				from CHE_SOLICITUD_CANJE_INTERNO b  with(nolock)
				left join CHE_CHEQUES a  with(nolock)on a.NRO_SOLICITUD = b.NRO_SOLICITUD
														and a.serie = b.SERIE							
														and a.NUMEROCHEQUE = b.NRO_CHEQUE
				where a.NRO_SOLICITUD is null
						and a.SERIE is null
						and a.NUMEROCHEQUE is null 
	else
	print ''Comprobación OK.Tabla CHE_SOLICITUD_CANJE_INTERNO con CHE_CHEQUES ''
	
-----------------------------------------------6	
	
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
------------------------------------------------------------------------7	
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

---------------------------------------------------------------------8	
		if exists (	select a.Cuenta 
					from Che_CheqSolicitud a
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
				select   ''Tabla Che_CheqSolicitud no se ajusta a la integridad referencial con SALDOS '',*
				from Che_CheqSolicitud a
				left join (		SELECT *
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
	print ''Comprobación OK.Tabla Che_CheqSolicitud con SALDOS ''
	
---------------------------------------------------9	

if exists (	select a.CANTIDADCHEQUES 
				from CHE_CHEQUERAS a with(nolock) 
				left join CHE_CHEQUESIMPRENTA b on a.SUCURSAL = B.Sucursal 
													AND A.CUENTA = B.Cuenta
													AND A.MONEDA = B.Moneda
													AND A.CLIENTE = B.Cliente
													AND A.NROSOLICCHEQ = B.NroSolicitud
													and a.PRODUCTO = b.Producto
													and a.SERIE = b.Serie


				where B.Sucursal IS NULL
				AND B.CUENTA IS NULL
				AND B.MONEDA IS NULL
				AND B.CLIENTE IS NULL
				AND B.NroSolicitud IS NULL
				and b.Producto is null
				and b.Serie is null
			)	
				SELECT   ''Tabla CHE_CHEQUERAS no se ajusta a la integridad referencial con CHE_CHEQUESIMPRENTA '',*
				from CHE_CHEQUERAS a with(nolock) 
				left join CHE_CHEQUESIMPRENTA b on a.SUCURSAL = B.Sucursal
													AND A.CUENTA = B.Cuenta
													AND A.MONEDA = B.Moneda
													AND A.CLIENTE = B.Cliente
													AND A.NROSOLICCHEQ = B.NroSolicitud
													and a.PRODUCTO = b.Producto
													and a.SERIE = b.Serie


				where B.Sucursal IS NULL
				AND B.CUENTA IS NULL
				AND B.MONEDA IS NULL
				AND B.CLIENTE IS NULL
				AND B.NroSolicitud IS NULL
				and b.Producto is null
				and b.Serie is null
	else
	print ''Comprobación OK.Tabla CHE_CHEQUERAS con CHE_CHEQUESIMPRENTA ''

------------------------------------------------10	
		if exists (	select b.CUENTA 
					from CHE_CHEQUESDENUNCIADOS b with(nolock) 
					left join che_cheques a with(nolock) on a.sucursal = b.SUCURSAL
															and a.cuenta = b.CUENTA
															and a.MONEDA = b.MONEDA
															and a.OPERACION = b.OPERACION
															and a.ORDINAL = b.ORDINAL
															and a.PRODUCTO = b.PRODUCTO
															and a.SERIE = b.SERIE
															and a.CUENTA = b.CUENTA
															and a.NUMEROCHEQUE = b.NUMEROCHEQUE
					where a.sucursal is null
						and a.cuenta is null
						and a.moneda is null
						and a.operacion is null
						and a.serie is null
						and a.ordinal is null
						and a.producto is null
						and a.NUMEROCHEQUE is null
				)	
					SELECT   ''Tabla CHE_CHEQUESDENUNCIADOS no se ajusta a la integridad referencial con che_cheques '',*
					from CHE_CHEQUESDENUNCIADOS b with(nolock) 
					left join che_cheques a with(nolock) on a.sucursal = b.SUCURSAL
															and a.cuenta = b.CUENTA
															and a.MONEDA = b.MONEDA
															and a.OPERACION = b.OPERACION
															and a.ORDINAL = b.ORDINAL
															and a.PRODUCTO = b.PRODUCTO
															and a.SERIE = b.SERIE
															and a.CUENTA = b.CUENTA
															and a.NUMEROCHEQUE = b.NUMEROCHEQUE
					where a.sucursal is null
						and a.cuenta is null
						and a.moneda is null
						and a.operacion is null
						and a.serie is null
						and a.ordinal is null
						and a.producto is null
						and a.NUMEROCHEQUE is null
		else
	print ''Comprobación OK.Tabla CHE_CHEQUESDENUNCIADOS con che_cheques ''
----------------------------------------11
	if exists (	select a.MONEDA 
				from SALDOS a with(nolock) 
				where a.MONEDA not in (select b.C6399 
									from MONEDAS b with(nolock))
			)	
				SELECT   ''Tabla SALDOS no se ajusta a la integridad referencial con MONEDAS '',*
				from SALDOS a with(nolock) 
				where a.MONEDA not in (select b.C6399 
									from MONEDAS b with(nolock))
	else
	print ''Comprobación OK.Tabla SALDOS con MONEDAS ''
----------------------------------------12
	---------------------------------------------------------------------------------------------------
	------------------------------------------CAJAS DE SEGURIDAD---------------------------------------
----------------------------------------1
	if exists (	select a.CODIGO 
				from COF_COFRES a with(nolock) 
				where a.tipo not in (select b.TIPO 
									from COF_COFRES_TIPO b with(nolock))
			)	
				SELECT   ''Tabla COF_COFRES no se ajusta a la integridad referencial con COF_COFRES_TIPO '',*
				from COF_COFRES a with(nolock) 
				where a.tipo not in (select b.TIPO 
									from COF_COFRES_TIPO b with(nolock))
	else
	print ''Comprobación OK.Tabla COF_COFRES con COF_COFRES_TIPO ''
----------------------------------------2
	if exists (	select a.CODIGO_COFRE 
				from COF_COFRES_CONTRATOS a with(nolock) 
				where a.CODIGO_COFRE not in (	select b.codigo 
												from COF_COFRES b with(nolock))
			)	
				SELECT   ''Tabla COF_COFRES_CONTRATOS no se ajusta a la integridad referencial con COF_COFRES '',*
				from COF_COFRES_CONTRATOS a with(nolock) 
				where a.CODIGO_COFRE not in (	select b.codigo 
												from COF_COFRES b with(nolock))
	else
	print ''Comprobación OK.Tabla COF_COFRES_CONTRATOS con COF_COFRES ''
----------------------------------------3
	if exists (	select a.CUENTA_DEBITO 
				from COF_COFRES_CONTRATOS a with(nolock) 
				left join SALDOS b with(nolock) on a.SUCURSAL_DEBITO = b.SUCURSAL
										and a.PRODUCTO_DEBITO = b.PRODUCTO
										and a.ORDINAL_DEBITO = b.ORDINAL
										and a.OPERACION_DEBITO = b.OPERACION
										and a.MONEDA_DEBITO = b.MONEDA
										and a.CUENTA_DEBITO = b.CUENTA
				where b.PRODUCTO is null
				and b.ordinal is null
				and b.OPERACION is null
				and b.MONEDA is null
				and b.CUENTA is null
				and b.SUCURSAL is null
				)	
				SELECT   ''Tabla COF_COFRES_CONTRATOS no se ajusta a la integridad referencial con SALDOS '',*
				from COF_COFRES_CONTRATOS a with(nolock) 
				left join SALDOS b with(nolock) on a.SUCURSAL_DEBITO = b.SUCURSAL
										and a.PRODUCTO_DEBITO = b.PRODUCTO
										and a.ORDINAL_DEBITO = b.ORDINAL
										and a.OPERACION_DEBITO = b.OPERACION
										and a.MONEDA_DEBITO = b.MONEDA
										and a.CUENTA_DEBITO = b.CUENTA
				where b.PRODUCTO is null
				and b.ordinal is null
				and b.OPERACION is null
				and b.MONEDA is null
				and b.CUENTA is null
				and b.SUCURSAL is null
	else
	print ''Comprobación OK.Tabla COF_COFRES_CONTRATOS con SALDOS ''
----------------------------------------4	
	if exists (	select a.SUCURSAL 
				from BITACORA_CAJAS_SEGURIDAD a with(nolock) 
				where NRO_CAJA_SEGURIDAD not in (select b.CODIGO_COFRE 
												from COF_COFRES_CONTRATOS b with(nolock))
			  )	
				SELECT   ''Tabla BITACORA_CAJAS_SEGURIDAD no se ajusta a la integridad referencial con COF_COFRES_CONTRATOS '',*
				from BITACORA_CAJAS_SEGURIDAD a with(nolock) 
				where NRO_CAJA_SEGURIDAD not in (select b.CODIGO_COFRE 
												from COF_COFRES_CONTRATOS b with(nolock))
	else
	print ''Comprobación OK.Tabla BITACORA_CAJAS_SEGURIDAD con COF_COFRES_CONTRATOS ''
----------------------------------------5
	if exists (	select a.CODIGO_CONTRATO 
				from COF_COFRES_EVENTOS a with(nolock) 
				where a.CODIGO_CONTRATO not in (select b.CODIGO 
												from COF_COFRES_CONTRATOS b with(nolock))
			)	
				SELECT   ''Tabla COF_COFRES_EVENTOS no se ajusta a la integridad referencial con COF_COFRES_CONTRATOS '',*
				from COF_COFRES_EVENTOS a with(nolock) 
				where a.CODIGO_CONTRATO not in (select b.CODIGO 
												from COF_COFRES_CONTRATOS b with(nolock))
	else
	print ''Comprobación OK.Tabla COF_COFRES_EVENTOS con COF_COFRES_CONTRATOS ''
----------------------------------------6
	if exists (	select a.CODIGO_EVENTO 
				from COF_COFRES_DETALLE_EVENTOS a with(nolock) 
				where a.CODIGO_EVENTO not in (	select b.numero_evento
												from COF_COFRES_EVENTOS b with(nolock))
			)	
				SELECT   ''Tabla COF_COFRES_DETALLE_EVENTOS no se ajusta a la integridad referencial con COF_COFRES_EVENTOS '',*
				from COF_COFRES_DETALLE_EVENTOS a with(nolock) 
				where a.CODIGO_EVENTO not in (	select b.numero_evento 
												from COF_COFRES_EVENTOS b with(nolock))
	else
	print ''Comprobación OK.Tabla COF_COFRES_DETALLE_EVENTOS con COF_COFRES_EVENTOS ''

----------------------------------------7
	if exists (	select a.cod_bonificacion 
				from cof_cofres_contratos a with(nolock) 
				where a.cod_bonificacion not in (	select b.CODIGO
												from cof_bonificaciones b with(nolock))
			)	
				SELECT   ''Tabla cof_cofres_contratos no se ajusta a la integridad referencial con cof_bonificaciones '',*
				from cof_cofres_contratos a with(nolock) 
				where a.cod_bonificacion not in (	select b.codigo 
												from cof_bonificaciones b with(nolock))
	else
	print ''Comprobación OK.Tabla cof_cofres_contratos con cof_bonificaciones ''
----------------------------------------8
	if exists (	select a.ID_PERSONA 
				from PYF_APODERADOS a with(nolock) 
				where a.ID_PERSONA not in (select b.NUMEROPERSONAFISICA 
											from CLI_PERSONASFISICAS b with(nolock))
			)	
				SELECT   ''Tabla PYF_APODERADOS no se ajusta a la integridad referencial con CLI_PERSONASFISICAS '',*
				from PYF_APODERADOS a with(nolock) 
				where a.ID_PERSONA not in (select b.NUMEROPERSONAFISICA 
											from CLI_PERSONASFISICAS b with(nolock))
	else
	print ''Comprobación OK.Tabla PYF_APODERADOS con CLI_PERSONASFISICAS ''

	---------------------------------------------------------------------------------------------------
    ----------------------------------DEPOSITO PLAZO FIJO----------------------------------------------
	---------------------------------------------------------------------------------------------------
----------------------------------------1
	if exists (	select a.DEPOSITO_SOLICITUD 
				from DPF_DOCS_SOLICITUDES a with(nolock) 
				where a.DEPOSITO_SOLICITUD not in(	select b.codigo 
													from DPF_DOCS_DEPOSITOS b with(nolock))
			)	
				SELECT   ''Tabla DPF_DOCS_SOLICITUDES no se ajusta a la integridad referencial con DPF_DOCS_DEPOSITOS '',*
				from DPF_DOCS_SOLICITUDES a with(nolock) 
				where a.DEPOSITO_SOLICITUD not in (	select b.codigo 
											from DPF_DOCS_DEPOSITOS b with(nolock))
	else
	print ''Comprobación OK.Tabla DPF_DOCS_SOLICITUDES con DPF_DOCS_DEPOSITOS ''
----------------------------------------2
	if exists (	select a.CODIGO_TIPO
				from DPF_DOCS_SOLICITUDES a with(nolock) 
				where a.CODIGO_TIPO not in(select b.CODIGO 
											from DPF_DOCS_TIPO b with(nolock))
			  )	
				SELECT   ''Tabla DPF_DOCS_SOLICITUDES no se ajusta a la integridad referencial con DPF_DOCS_TIPO '',*
				from DPF_DOCS_SOLICITUDES a with(nolock) 
				where a.CODIGO_TIPO not in(select b.CODIGO 
											from DPF_DOCS_TIPO b with(nolock))
	else
	print ''Comprobación OK.Tabla DPF_DOCS_SOLICITUDES con DPF_DOCS_TIPO ''
----------------------------------------3
	if exists (	select a.CODIGO_TIPO
				from DPF_DOCS_DOCUMENTOS a with(nolock) 
				where a.CODIGO_TIPO not in(select b.CODIGO_TIPO 
											from DPF_DOCS_SOLICITUDES b with(nolock))
			  )	
				SELECT   ''Tabla DPF_DOCS_DOCUMENTOS no se ajusta a la integridad referencial con DPF_DOCS_SOLICITUDES '',*
				from DPF_DOCS_DOCUMENTOS a with(nolock) 
				where a.CODIGO_TIPO not in(select b.CODIGO_TIPO 
											from DPF_DOCS_SOLICITUDES b with(nolock))
	else
	print ''Comprobación OK.Tabla DPF_DOCS_DOCUMENTOS con DPF_DOCS_SOLICITUDES ''
----------------------------------------4
	if exists (	select a.CODIGO_TIPO
				from DPF_DOCS_MOVIMIENTOS a with(nolock) 
				where a.CODIGO_TIPO not in(select b.CODIGO_TIPO 
											from DPF_DOCS_DOCUMENTOS b with(nolock))
			  )	
				SELECT   ''Tabla DPF_DOCS_MOVIMIENTOS no se ajusta a la integridad referencial con DPF_DOCS_DOCUMENTOS '',*
				from DPF_DOCS_MOVIMIENTOS a with(nolock) 
				where a.CODIGO_TIPO not in(select b.CODIGO_TIPO 
											from DPF_DOCS_DOCUMENTOS b with(nolock))
	else
	print ''Comprobación OK.Tabla DPF_DOCS_MOVIMIENTOS con DPF_DOCS_DOCUMENTOS ''

----------------------------------------5
	if exists (	select a.TARIFA
				from TASAS a with(nolock) 
				where a.TARIFA not in(select b.TARIFA 
											from DETERMINACION_TARIFAS b with(nolock))
			  )	
				SELECT   ''Tabla TASAS no se ajusta a la integridad referencial con DETERMINACION_TARIFAS '',*
				from TASAS a with(nolock) 
				where a.TARIFA not in(select b.TARIFA 
											from DETERMINACION_TARIFAS b with(nolock))
	else
	print ''Comprobación OK.Tabla TASAS con DETERMINACION_TARIFAS ''


----------------------------------------6
	if exists (	select a.CATEGORIA
				from DPF_CODIGOS_ESPECIE a with(nolock) 
				where a.CATEGORIA not in(	select b.CODIGOCATEGORIA 
											from DPF_CATEGORIAS_ESPECIE b with(nolock))
			  )	
				SELECT   ''Tabla DPF_CODIGOS_ESPECIE no se ajusta a la integridad referencial con DPF_CATEGORIAS_ESPECIE '',*
				from DPF_CODIGOS_ESPECIE a with(nolock) 
				where a.CATEGORIA not in(select b.CODIGOCATEGORIA 
											from DPF_CATEGORIAS_ESPECIE b with(nolock))
	else
	print ''Comprobación OK.DPF_CODIGOS_ESPECIE con DPF_CATEGORIAS_ESPECIE ''

----------------------------------------7
	if exists (	select a.PRODUCTO
				from SOLICAPERTURADPF a with(nolock) 
				where a.PRODUCTO not in(select b.ProductoPlazo 
											from DPF_RELPRODVISTA b with(nolock))
			  )	
				SELECT   ''Tabla SOLICAPERTURADPF no se ajusta a la integridad referencial con DPF_RELPRODVISTA '',*
				from SOLICAPERTURADPF a with(nolock) 
				where a.PRODUCTO not in(select b.ProductoPlazo 
											from DPF_RELPRODVISTA b with(nolock))
	else
	print ''Comprobación OK.SOLICAPERTURADPF con DPF_RELPRODVISTA ''

----------------------------------------8
	if exists (	select a.NRO_CLIENTE 
				from DPF_PRE_CANCELACION a with(nolock) 
				where a.JTSOID not in(	select b.jts_oid 
										from SALDOS B with(nolock))
			  )	
				SELECT    ''Tabla DPF_PRE_CANCELACION no se ajusta a la integridad referencial con SALDOS '',*
				from DPF_PRE_CANCELACION a with(nolock) 
				where a.JTSOID not in(	select b.jts_oid 
										from SALDOS B with(nolock))
	else
	print ''Comprobación OK.Tabla DPF_PRE_CANCELACION  con SALDOS ''


----------------------------------------9
	if exists (	select a.SALDO_JTS_OID 
				from DPF_CAMBIO_VTO_POR_PARO a with(nolock) 
				where a.SALDO_JTS_OID not in(	select b.jts_oid 
												from SALDOS B with(nolock))
			  )	
				SELECT    ''Tabla DPF_CAMBIO_VTO_POR_PARO no se ajusta a la integridad referencial con SALDOS '',*
				from DPF_CAMBIO_VTO_POR_PARO a with(nolock) 
				where a.SALDO_JTS_OID not in(	select b.jts_oid 
												from SALDOS B with(nolock))
	else
	print ''Comprobación OK.Tabla DPF_CAMBIO_VTO_POR_PARO  con SALDOS ''

----------------------------------------10
	if exists (	select a.JTS_OID 
				from BS_HISTORIA_PLAZO a with(nolock) 
				where a.SALDOS_JTS_OID not in(	select b.jts_oid 
												from SALDOS B with(nolock))
			  )	
				SELECT    ''Tabla BS_HISTORIA_PLAZO no se ajusta a la integridad referencial con SALDOS '',*
				from BS_HISTORIA_PLAZO a with(nolock) 
				where a.SALDOS_JTS_OID not in(	select b.jts_oid 
												from SALDOS B with(nolock))
	else
	print ''Comprobación OK.Tabla BS_HISTORIA_PLAZO  con SALDOS ''

----------------------------------------11
	if exists (	select a.SALDO_JTS_OID 
				from GRL_BLOQUEOS a with(nolock) 
				where a.SALDO_JTS_OID not in(	select b.jts_oid 
												from SALDOS B with(nolock))
			  )	
				SELECT    ''Tabla GRL_BLOQUEOS no se ajusta a la integridad referencial con SALDOS '',*
				from GRL_BLOQUEOS a with(nolock) 
				where a.SALDO_JTS_OID not in(	select b.jts_oid 
												from SALDOS B with(nolock))
	else
	print ''Comprobación OK.Tabla GRL_BLOQUEOS  con SALDOS ''
----------------------------------------12
	if exists (	select a.SALDO_JTS_OID 
				from GRL_EMBARGO a with(nolock) 
				where a.SALDO_JTS_OID not in(	select b.jts_oid 
												from SALDOS B with(nolock))
			  )	
				SELECT    ''Tabla GRL_EMBARGO no se ajusta a la integridad referencial con SALDOS '',*
				from GRL_EMBARGO a with(nolock) 
				where a.SALDO_JTS_OID not in(	select b.jts_oid 
												from SALDOS B with(nolock))
	else
	print ''Comprobación OK.Tabla GRL_EMBARGO  con SALDOS ''
----------------------------------------13
	if exists (	select a.JTS_OID_SALDO 
				from DPF_SALDOS_INMOVILIZADOS a with(nolock) 
				where a.JTS_OID_SALDO not in(	select b.jts_oid 
												from SALDOS B with(nolock))
			  )	
				SELECT    ''Tabla DPF_SALDOS_INMOVILIZADOS no se ajusta a la integridad referencial con SALDOS '',*
				from DPF_SALDOS_INMOVILIZADOS a with(nolock) 
				where a.JTS_OID_SALDO not in(	select b.jts_oid 
												from SALDOS B with(nolock))
	else
	print ''Comprobación OK.Tabla DPF_SALDOS_INMOVILIZADOS  con SALDOS ''

----------------------------------------14
	if exists (	select a.cuenta 
				from DPF_RENOVACIONES a with(nolock) 
				left join SALDOS B with(nolock) on		a.cuenta = b.cuenta
														and b.sucursal = a.sucursal
														and a.OPERACION = b.OPERACION
														and a.MONEDA = b.MONEDA
														and a.ORDINAL = b.ORDINAL
				where b.cuenta is null
					and b.sucursal is null 
					and b.ordinal is null
					and b.moneda is null
					and b.OPERACION is null
			  )	
				SELECT    ''Tabla DPF_RENOVACIONES no se ajusta a la integridad referencial con SALDOS '',*
				from DPF_RENOVACIONES a with(nolock) 
				left join SALDOS B with(nolock) on		a.cuenta = b.cuenta
														and b.sucursal = a.sucursal
														and a.OPERACION = b.OPERACION
														and a.MONEDA = b.MONEDA
														and a.ORDINAL = b.ORDINAL
				where b.cuenta is null
					and b.sucursal is null 
					and b.ordinal is null
					and b.moneda is null
					and b.OPERACION is null
	else
	print ''Comprobación OK.Tabla DPF_RENOVACIONES  con SALDOS ''

----------------------------------------15
	if exists (	select a.asiento 
				from ASIENTOS_EXTORNADOS a with(nolock) 
				where a.ASIENTO not in(	select b.ASIENTO 
												from ASIENTOS B with(nolock))
			  )	
				SELECT    ''Tabla ASIENTOS_EXTORNADOS no se ajusta a la integridad referencial con SALDOS '',*
				from ASIENTOS_EXTORNADOS a with(nolock) 
				where a.ASIENTO not in(	select b.ASIENTO 
												from ASIENTOS B with(nolock))
	else
	print ''Comprobación OK.Tabla ASIENTOS_EXTORNADOS  con SALDOS ''

----------------------------------------16
	if exists (	select a.NROASIENTOMOV 
				from BS_HISTORIA_PLAZO a with(nolock) 
				where a.NROASIENTOMOV not in(	select b.asiento 
												from asientos B with(nolock))
			  )	
				SELECT    ''Tabla BS_HISTORIA_PLAZO no se ajusta a la integridad referencial con asientos '',*
				from BS_HISTORIA_PLAZO a with(nolock) 
				where a.NROASIENTOMOV not in(	select b.asiento 
												from asientos B with(nolock))
	else
	print ''Comprobación OK.Tabla BS_HISTORIA_PLAZO  con asientos ''

----------------------------------------17
----------------------------------------18
	if exists (	select a.MONEDA 
				from VTA_DEFINICION_VISTA a with(nolock) 
				where a.MONEDA not in(	select b.C6399
												from MONEDAS B with(nolock))
			  )	
				SELECT    ''Tabla VTA_DEFINICION_VISTA no se ajusta a la integridad referencial con MONEDAS '',*
				from VTA_DEFINICION_VISTA a with(nolock) 
				where a.MONEDA not in(	select b.C6399
												from MONEDAS B with(nolock))
	else
	print ''Comprobación OK.Tabla VTA_DEFINICION_VISTA  con MONEDAS ''
----------------------------------------19
	if exists (	select a.tasa_fondo_garantia 
				from SOLICAPERTURADPF a with(nolock) 
				where a.COD_ESPECIE not in(	select b.CODIGOESPECIE
												from DPF_COTIZACION_ESPECIE B with(nolock))
			  )	
				SELECT    ''Tabla SOLICAPERTURADPF no se ajusta a la integridad referencial con DPF_COTIZACION_ESPECIE '',*
				from SOLICAPERTURADPF a with(nolock) 
				where a.COD_ESPECIE not in(	select b.CODIGOESPECIE
												from DPF_COTIZACION_ESPECIE B with(nolock))
	else
	print ''Comprobación OK.Tabla SOLICAPERTURADPF  con DPF_COTIZACION_ESPECIE ''
----------------------------------------20
	if exists (select a.codigo_tipo 
				from dpf_docs_movimientos a with(nolock) 
				where a.codigo_tipo not in (select b.codigo
										from dpf_docs_depositos b with(nolock))
				)	
				SELECT   ''Tabla dpf_docs_movimientos no se ajusta a la integridad referencial con dpf_docs_depositos '',*
				from dpf_docs_movimientos a with(nolock) 
				where a.codigo_tipo not in (select b.codigo
										from dpf_docs_depositos b with(nolock))
	else
	print ''Comprobación OK. Tabla dpf_docs_movimientos con dpf_docs_depositos ''
----------------------------------------21
	if exists (select a.codigoESPECIE
				from DPF_COTIZACION_ESPECIE a with(nolock) 
				where a.codigoESPECIE not in (select b.codigoESPECIE
										from dpf_CODIGOS_ESPECIE b with(nolock))
				)	
				SELECT   ''Tabla DPF_COTIZACION_ESPECIE no se ajusta a la integridad referencial con dpf_CODIGOS_ESPECIE '',*
				from DPF_COTIZACION_ESPECIE a with(nolock) 
				where a.codigoESPECIE not in (select b.codigoESPECIE
										from dpf_CODIGOS_ESPECIE b with(nolock))
	else
	print ''Comprobación OK. Tabla DPF_COTIZACION_ESPECIE con dpf_CODIGOS_ESPECIE ''
----------------------------------------22
	if exists (select a.jts_oid_saldo
				from pzo_saldos a with(nolock) 
				where a.jts_oid_saldo not in (	select b.jts_oid
												from saldos b with(nolock))
				)	
				SELECT   ''Tabla PZO_SALDOS no se ajusta a la integridad referencial con SALDOS '',*
				from pzo_saldos a with(nolock) 
				where a.jts_oid_saldo not in (	select b.jts_oid
												from saldos b with(nolock))
	else
	print ''Comprobación OK. Tabla PZO_SALDOS con SALDOS ''

	---------------------------------------------------------------------------------------------------
    ----------------------------------CTAS VISTAS------------------------------------------------------
	---------------------------------------------------------------------------------------------------
----------------------------------------1
	if exists (	select a.CODIGO_TRANSACCION 
				from CODIGO_TRANSACCIONES a with(nolock)
				where a.CODIGO_TRANSACCION not in (	select b.CODIGO_TRANSACCION 
													from TTR_CODIGO_TRANSACCION_DEF b with(nolock))

				)	
				select  ''Tabla CODIGO_TRANSACCIONES no se ajusta a la integridad referencial con TTR_CODIGO_TRANSACCION_DEF '',*
				from CODIGO_TRANSACCIONES a with(nolock)
				where a.CODIGO_TRANSACCION not in (	select b.CODIGO_TRANSACCION 
													from TTR_CODIGO_TRANSACCION_DEF b with(nolock))
	else
	print ''Comprobación OK. Tabla CODIGO_TRANSACCIONES con TTR_CODIGO_TRANSACCION_DEF ''
----------------------------------------2
	if exists (	select b.COD_TRANSACCION 
				from MOVIMIENTOS_CONTABLES b with(nolock) 
				where b.COD_TRANSACCION not in( select a.CODIGO_TRANSACCION 
												from codigo_transacciones a with(nolock)) 
			)	
				SELECT   ''Tabla MOVIMIENTOS_CONTABLES no se ajusta a la integridad referencial con CODIGO_TRANSACCIONES '',*
				from MOVIMIENTOS_CONTABLES b with(nolock) 
				where b.COD_TRANSACCION not in( select a.CODIGO_TRANSACCION 
												from codigo_transacciones a with(nolock)) 
	else
	print ''Comprobación OK.Tabla MOVIMIENTOS_CONTABLES con CODIGO_TRANSACCIONES ''
----------------------------------------3
	if exists (	select a.SUCURSAL 
				from SUCURSALES a with(nolock)
				where a.SUCURSAL not in (select b.SUCURSAL 
										from SUCURSALESSC b with(nolock))
				)	
			select   ''Tabla SUCURSALES no se ajusta a la integridad referencial con SUCURSALESSC '',*
			from SUCURSALES a with(nolock)
			where a.SUCURSAL not in (	select b.SUCURSAL 
										from SUCURSALESSC b with(nolock))
	else
	print ''Comprobación OK. Tabla SUCURSALES con SUCURSALESSC ''
----------------------------------------4
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
----------------------------------------5
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
----------------------------------------6
	if exists (	select a.SUCURSAL 
				from TABLA_CAJAS a with(nolock)
				where a.SUCURSAL not in (select b.SUCURSAL 
										from SUCURSALES b with(nolock))
			)	
				select    ''Tabla TABLA_CAJAS no se ajusta a la integridad referencial con SUCURSALES '',*
				from TABLA_CAJAS a with(nolock)
				where a.SUCURSAL not in (select b.SUCURSAL 
										from SUCURSALES b with(nolock))
	else
	print ''Comprobación OK.Tabla TABLA_CAJAS con SUCURSALES ''
----------------------------------------7
	if exists (	select a.MONEDA 
				from SALDOSCAJA a with(nolock)
				where a.MONEDA not in(select b.c6399 from MONEDAS b with(nolock))
				)	
				select  ''Tabla SALDOSCAJA no se ajusta a la integridad referencial con MONEDAS '',*
				from SALDOSCAJA a with(nolock)
				where a.MONEDA not in(select b.c6399 from monedas b with(nolock))
	else
	print ''Comprobación OK. Tabla SALDOSCAJA con MONEDAS ''

----------------------------------------8
	if exists (select a.PRODUCTO 
				from PROD_RELCLIENTE a with(nolock) 
				where a.PRODUCTO not in (select b.c6250 
											from PRODUCTOS b with(nolock))
				)	
				SELECT   ''Tabla PROD_RELCLIENTE no se ajusta a la integridad referencial con PRODUCTOS '',*
				from PROD_RELCLIENTE a with(nolock) 
				where a.PRODUCTO not in (select b.c6250 
											from PRODUCTOS b with(nolock))
	else
	print ''Comprobación OK.Tabla PROD_RELCLIENTE con PRODUCTOS ''
----------------------------------------9
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
----------------------------------------10
	if exists (	select a.c6502 
				from CONCEPCONT a with(nolock) 
				where a.c6502 not in (	select b.C6326
										from PLANCTAS b with(nolock))
			)	
				SELECT   ''Tabla CONCEPCONT no se ajusta a la integridad referencial con PLANCTAS '',*
				from CONCEPCONT a with(nolock) 
				where a.c6502 not in (	select b.C6326
										from PLANCTAS b with(nolock))
	else
	print ''Comprobación OK.Tabla CONCEPCONT con PLANCTAS ''
----------------------------------------11
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
----------------------------------------12

	if exists (	select a.ASIENTO 
				from MOVIMIENTOS a with(nolock)
				where a.ASIENTO  not in (select b.ASIENTO
										from ASIENTOS b with(nolock))
				)	
				select     ''Tabla MOVIMIENTOS no se ajusta a la integridad referencial con ASIENTOS '',*
				from MOVIMIENTOS a with(nolock)
				where a.ASIENTO  not in (select b.ASIENTO
										from ASIENTOS b with(nolock))
	else
	print ''Comprobación OK. Tabla MOVIMIENTOS con ASIENTOS ''
----------------------------------------13

----------------------------------------14
	if exists (	select b.SALDO_JTS_OID 
				from CI_SOLICITUD b  with(nolock)
				where b.SALDO_JTS_OID not in(select a.JTS_OID 
												from SALDOS a  with(nolock))
				)	
				select      ''Tabla CI_SOLICITUD no se ajusta a la integridad referencial con SALDOS '',*
				from CI_SOLICITUD b  with(nolock)
				where b.SALDO_JTS_OID not in(	select a.JTS_OID 
												from SALDOS a  with(nolock))
	else
	print ''Comprobación OK.Tabla CI_SOLICITUD con SALDOS ''
----------------------------------------15
	if exists (select a.COD_BLOQUEO 
				from GRL_BLOQUEOS a with(nolock) 
				where a.COD_BLOQUEO not in (select b.COD_BLOQUEO 
											from GRL_COD_BLOQUEOS b  with(nolock))
				)	
				SELECT   ''Tabla GRL_BLOQUEOS no se ajusta a la integridad referencial con GRL_COD_BLOQUEOS '',*
				from GRL_BLOQUEOS a with(nolock) 
				where a.COD_BLOQUEO not in (select b.COD_BLOQUEO 
											from GRL_COD_BLOQUEOS b  with(nolock))
	else
	print ''Comprobación OK.Tabla GRL_BLOQUEOS con GRL_COD_BLOQUEOS ''
----------------------------------------16
	if exists (	select a.COD_BLOQUEO 
				from GRL_REL_BLOQUEO_SEGURIDAD a with(nolock) 
				where a.COD_BLOQUEO not in (select b.COD_BLOQUEO 
											from GRL_COD_BLOQUEOS B with(nolock))
			)	
				SELECT   ''Tabla GRL_REL_BLOQUEO_SEGURIDAD no se ajusta a la integridad referencial con GRL_COD_BLOQUEOS '',*
				from GRL_REL_BLOQUEO_SEGURIDAD a with(nolock) 
				where a.COD_BLOQUEO not in (select b.COD_BLOQUEO 
											from GRL_COD_BLOQUEOS B with(nolock))
	else
	print ''Comprobación OK.Tabla GRL_REL_BLOQUEO_SEGURIDAD con GRL_COD_BLOQUEOS ''
----------------------------------------17
	if exists (	select a.JTS_OID_SALDO 
				from VTA_SALDOS a with(nolock) 
				where a.JTS_OID_SALDO not in(select b.JTS_OID 
											from SALDOS  B with(nolock))
			)	
				SELECT    ''Tabla VTA_SALDOS no se ajusta a la integridad referencial con SALDOS '',*
				from VTA_SALDOS a with(nolock) 
				where a.JTS_OID_SALDO not in(select b.JTS_OID 
											from SALDOS  B with(nolock))
	else
	print ''Comprobación OK.Tabla VTA_SALDOS con SALDOS ''
----------------------------------------18
	if exists (	select a.CUENTA 
				from GRL_ESTADOS_DE_CUENTA a with(nolock) 
				left join SALDOS b with(nolock) on
							b.sucursal = a.SUCURSAL 
							and b.Moneda = a.MONEDA 
							and b.Operacion = a.OPERACION
							and b.ordinal = a.ORDINAL
							and b.Producto = a.PRODUCTO
							and b.CUENTA = a.CUENTA
				where
				a.SUCURSAL is null
				and b.moneda is null
				and b.operacion is null
				and b.ordinal is null
				and b.producto is null
				and b.cuenta is null

			)	
			select   ''Tabla GRL_ESTADOS_DE_CUENTA no se ajusta a la integridad referencial con SALDOS '',*
			from GRL_ESTADOS_DE_CUENTA a with(nolock) 
			left join  SALDOS b with(nolock) on
							b.sucursal = a.SUCURSAL 
							and b.Moneda = a.MONEDA 
							and b.Operacion = a.OPERACION
							and b.ordinal = a.ORDINAL
							and b.Producto = a.PRODUCTO
							and b.CUENTA = a.CUENTA
			where
				a.SUCURSAL is null
				and b.moneda is null
				and b.operacion is null
				and b.ordinal is null
				and b.producto is null
				and b.cuenta is null
	else
	print ''Comprobación OK.Tabla GRL_ESTADOS_DE_CUENTA con SALDOS''
----------------------------------------19
	if exists (select b.SALDO_JTS_OID 
				from CV_CANCELACION_CUENTAS b  with(nolock)  
				where b.SALDO_JTS_OID not in (	select a.JTS_OID 
												from SALDOS a  with(nolock))
				)	
				select   ''Tabla CV_CANCELACION_CUENTAS no se ajusta a la integridad referencial con SALDOS '',*
				from CV_CANCELACION_CUENTAS b  with(nolock)  
				where b.SALDO_JTS_OID not in (	select a.JTS_OID 
												from SALDOS a  with(nolock))
	else
	print ''Comprobación OK. Tabla CV_CANCELACION_CUENTAS con SALDOS ''
----------------------------------------20
	if exists (select a.CODIGO_MOTIVO 
				from CV_CANCELACION_CUENTAS a  with(nolock) 
				where a.CODIGO_MOTIVO not in (	select b.CODIGO_MOTIVO 
												from CV_MOTIVOS_CANCELACION  b  with(nolock))
				)	
				select   ''Tabla CV_CANCELACION_CUENTAS no se ajusta a la integridad referencial con CV_MOTIVOS_CANCELACION '',*
				from CV_CANCELACION_CUENTAS a  with(nolock) 
				where a.CODIGO_MOTIVO not in (	select b.CODIGO_MOTIVO 
												from CV_MOTIVOS_CANCELACION  b  with(nolock))
	else
	print ''Comprobación OK.Tabla CV_CANCELACION_CUENTAS con CV_MOTIVOS_CANCELACION ''
----------------------------------------21
	if exists (	select A.Cuenta
				from VTA_CUENTAS_SECRETAS a with(nolock) 
				left join SALDOS b with(nolock) on
						b.sucursal = a.SUCURSAL 
						and b.cuenta = a.CUENTA 
						and b.Moneda = a.MONEDA 
						and b.Operacion = a.OPERACION
						and b.ordinal = a.ORDINAL
						and b.Producto = a.PRODUCTO
				where 
					b.SUCURSAL is null
					and b.CUENTA is null
					and b.MONEDA is null
					and b.OPERACION is null
					and b.ORDINAL is null
					and b.PRODUCTO is null
			)	
			SELECT   ''Tabla VTA_CUENTAS_SECRETAS no se ajusta a la integridad referencial con SALDOS '',*
				from VTA_CUENTAS_SECRETAS a with(nolock) 
				left join SALDOS b with(nolock) on
						b.sucursal = a.SUCURSAL 
						and b.cuenta = a.CUENTA 
						and b.Moneda = a.MONEDA 
						and b.Operacion = a.OPERACION
						and b.ordinal = a.ORDINAL
						and b.Producto = a.PRODUCTO
				where 
					b.SUCURSAL is null
					and b.CUENTA is null
					and b.MONEDA is null
					and b.OPERACION is null
					and b.ORDINAL is null
					and b.PRODUCTO is null
	else
	print ''Comprobación OK.Tabla VTA_CUENTAS_SECRETAS con SALDOS ''
----------------------------------------22
	if exists (	select a.SALDOS_JTS_OID 
				from CLI_DECLARACION_USO a with(nolock) 
				where a.SALDOS_JTS_OID not in (select b.JTS_OID
												from SALDOS b with(nolock))
			)	
				SELECT   ''Tabla CLI_DECLARACION_USO no se ajusta a la integridad referencial con SALDOS '',*
				from CLI_DECLARACION_USO a with(nolock) 
				where a.SALDOS_JTS_OID not in (select b.JTS_OID
												from SALDOS b with(nolock))
	else
	print ''Comprobación OK.Tabla CLI_DECLARACION_USO con SALDOS ''
----------------------------------------23
	if exists (	select a.NROCAJA 
				from SALDOSCAJA a with(nolock)
				LEFT JOIN TABLA_CAJAS b with(nolock) ON  a.NROCAJA = b.NRO_CAJA 
													AND A.SUCURSAL = B.SUCURSAL
				WHERE B.NRO_CAJA IS NULL
				AND B.SUCURSAL IS NULL )
					
				select   ''Tabla SALDOSCAJA no se ajusta a la integridad referencial con TABLA_CAJAS '',*
				from SALDOSCAJA a with(nolock)
				LEFT JOIN TABLA_CAJAS b with(nolock)ON  a.NROCAJA = b.NRO_CAJA 
														AND A.SUCURSAL = B.SUCURSAL
				WHERE B.NRO_CAJA IS NULL
				AND B.SUCURSAL IS NULL 
	else
	print ''Comprobación OK. Tabla SALDOSCAJA con TABLA_CAJAS ''
----------------------------------------24
	if exists (	select a.CODIGOTASABASE 
				from VTA_DEFINICION_TASAS a with(nolock)
				where a.CODIGOTASABASE not in (	select b.TIPOTASABASE 
												from TASASBASE b with(nolock))
			)	
				select     ''Tabla VTA_DEFINICION_TASAS no se ajusta a la integridad referencial con TASASBASE '',*
				from VTA_DEFINICION_TASAS a with(nolock)
				where a.CODIGOTASABASE not in (	select b.TIPOTASABASE 
												from TASASBASE b with(nolock))
	else
	print ''Comprobación OK.Tabla VTA_DEFINICION_TASAS con TASASBASE ''
----------------------------------------25
	if exists (	select a.CODIGORANGO 
				from VTA_RANGOS_TASAS a with(nolock)
				where a.CODIGORANGO not in (select b.CODIGORANGO 
											from VTA_DEFINICION_TASAS b with(nolock))
			)	
				select    ''Tabla VTA_DEFINICION_TASAS no se ajusta a la integridad referencial con VTA_RANGOS_TASAS '',*
				from VTA_RANGOS_TASAS a with(nolock)
				where a.CODIGORANGO not in (select b.CODIGORANGO 
											from VTA_DEFINICION_TASAS b with(nolock))

	else
	print ''Comprobación OK.Tabla VTA_DEFINICION_TASAS con VTA_RANGOS_TASAS ''
----------------------------------------26
	if exists (SELECT a.CANAL 
				FROM PROD_RELCANALES a with(nolock) 
				WHERE a.CANAL not in (SELECT b.COD_CANAL 
										FROM CLI_CANALES b  with(nolock))
				)	
				select     ''Tabla PROD_RELCANALES no se ajusta a la integridad referencial con CLI_CANALES '',*
				FROM PROD_RELCANALES a with(nolock) 
				WHERE a.CANAL not in (SELECT b.COD_CANAL 
										FROM CLI_CANALES b  with(nolock))
	else
	print ''Comprobación OK.Tabla PROD_RELCANALES con CLI_CANALES ''
----------------------------------------27
	if exists (select a.MONEDA 
				from PROD_RESTRICCIONES a with(nolock) 
				where a.MONEDA not in (select b.C6399 
										from MONEDAS b with(nolock))
				)	
				SELECT   ''Tabla PROD_RESTRICCIONES no se ajusta a la integridad referencial con monedas '',*
				from PROD_RESTRICCIONES a with(nolock) 
				where a.MONEDA not in (select b.C6399 
										from MONEDAS b with(nolock))
	else
	print ''Comprobación OK. Tabla PROD_RESTRICCIONES con monedas ''
----------------------------------------28
	if exists (select a.PRODUCTO
				from PROD_RELCANALES a with(nolock) 
				where a.PRODUCTO not in (select b.C6250 
										from PRODUCTOS b with(nolock))
				)	
				SELECT   ''Tabla PROD_RELCANALES no se ajusta a la integridad referencial con PRODUCTOS '',*
				from PROD_RELCANALES a with(nolock) 
				where a.PRODUCTO not in (select b.C6250 
										from PRODUCTOS b with(nolock))
	else
	print ''Comprobación OK.Tabla PROD_RELCANALES con PRODUCTOS ''
----------------------------------------29
	if exists (	select b.PRODUCTO 
				from PROD_RELSEGMENTOS b with(nolock) 
				where b.PRODUCTO not in(select a.C6250 
										from PRODUCTOS a with (nolock))
			)	
				SELECT   ''Tabla PROD_RELSEGMENTOS no se ajusta a la integridad referencial con PRODUCTOS '',*
				from PROD_RELSEGMENTOS b with(nolock) 
				where b.PRODUCTO not in(select a.C6250 
										from PRODUCTOS a with (nolock))
	else
	print ''Comprobación OK.Tabla PROD_RELSEGMENTOS con PRODUCTOS ''
----------------------------------------30
	if exists (	select b.TARJETA 
				from PROD_RELTARJETAS b with(nolock) 
				where b.tarjeta not in (select a.TIPO_TARJETA 
										from TJD_TIPO_TARJETA A with(nolock))
			)	
				SELECT   ''Tabla PROD_RELTARJETAS no se ajusta a la integridad referencial con TJD_TIPO_TARJETA '',*
				from PROD_RELTARJETAS b with(nolock) 
				where b.tarjeta not in (select a.TIPO_TARJETA 
										from TJD_TIPO_TARJETA A with(nolock))
	else
	print ''Comprobación OK.Tabla PROD_RELTARJETAS con TJD_TIPO_TARJETA ''
----------------------------------------31
	if exists (select b.TARJETA 
				from PROD_RELTARJETAS b with(nolock) 
				where b.PRODUCTO not in (select a.c6250 
										from PRODUCTOS a with(nolock))
				)	
				SELECT   ''Tabla PROD_RELTARJETAS no se ajusta a la integridad referencial con PRODUCTOS '',*
				from PROD_RELTARJETAS b with(nolock) 
				where b.PRODUCTO not in (select a.c6250 
										from PRODUCTOS a with(nolock))
	else
	print ''Comprobación OK.Tabla PROD_RELTARJETAS con PRODUCTOS ''
----------------------------------------32
	if exists (select a.PRODUCTO 
				from PROD_RELSECTORES a with(nolock) 
				where a.PRODUCTO not in( select b.C6250
										from PRODUCTOS b with(nolock))
				)	
				SELECT   ''Tabla PROD_RELSECTORES no se ajusta a la integridad referencial con PRODUCTOS '',*
				from PROD_RELSECTORES a with(nolock)
				where a.PRODUCTO not in( select b.C6250
										from PRODUCTOS b with(nolock))
	else
	print ''Comprobación OK.Tabla PROD_RELSECTORES con PRODUCTOS ''
----------------------------------------33
	if exists (	select a.sector 
				from PROD_RELSECTORES a with(nolock) 
				where a.sector not in(	select b.SECTOR 
										from CLI_SECTORES   b with(nolock))
			)	
				SELECT   ''Tabla PROD_RELSECTORES no se ajusta a la integridad referencial con CLI_SECTORES '',*
				from PROD_RELSECTORES a with(nolock) 
				where a.sector not in(	select b.SECTOR 
										from CLI_SECTORES   b with(nolock))
	else
	print ''Comprobación OK.Tabla PROD_RELSECTORES con CLI_SECTORES ''
----------------------------------------34
	if exists (select a.CODPRODUCTO,*
				from TOPESPRODUCTO a with(nolock) 
				where a.CODPRODUCTO not in (select b.C6250
										from PRODUCTOS b with(nolock))
				)	
				SELECT   ''Tabla TOPESPRODUCTO no se ajusta a la integridad referencial con PRODUCTOS '',*
				from TOPESPRODUCTO a with(nolock) 
				where a.CODPRODUCTO not in (select b.C6250
										from PRODUCTOS b with(nolock))
	else
	print ''Comprobación OK.Tabla TOPESPRODUCTO con PRODUCTOS ''
----------------------------------------35
	if exists (	select a.PRODUCTO 
				from VTA_DEFINICION_VISTA a with(nolock) 
				where a.PRODUCTO not in (select b.c6250 
										from PRODUCTOS b with(nolock))
			)	
				SELECT   ''Tabla VTA_DEFINICION_VISTA no se ajusta a la integridad referencial con PRODUCTOS '',*
				from VTA_DEFINICION_VISTA a with(nolock) 
				where a.PRODUCTO not in (select b.c6250 
										from PRODUCTOS b with(nolock))
	else
	print ''Comprobación OK.Tabla VTA_DEFINICION_VISTA con PRODUCTOS ''
----------------------------------------36
	if exists (	select a.CODIGORANGOPAGO 
				from VTA_DEFINICION_VISTA a with(nolock)
				where a.CODIGORANGOPAGO not in (select b.CODIGORANGO 
												from VTA_DEFINICION_TASAS b with(nolock))
			)	
				select    ''Tabla VTA_DEFINICION_VISTA no se ajusta a la integridad referencial con VTA_DEFINICION_TASAS '',*
				from VTA_DEFINICION_VISTA a with(nolock)
				where a.CODIGORANGOPAGO not in (select b.CODIGORANGO 
												from VTA_DEFINICION_TASAS b with(nolock))
	else
	print ''Comprobación OK.Tabla VTA_DEFINICION_VISTA con VTA_DEFINICION_TASAS ''
----------------------------------------37
	if exists (	select a.JTSOID 
				from GRL_DET_ENVIO_ESTCTA a with(nolock)
				where a.JTSOID not in (	select b.JTSOID 
												from GRL_CAB_ENVIO_ESTCTA b with(nolock))
			)	
				select     ''Tabla GRL_DET_ENVIO_ESTCTA no se ajusta a la integridad referencial con GRL_CAB_ENVIO_ESTCTA '',*
				from GRL_DET_ENVIO_ESTCTA a with(nolock)
				where a.JTSOID not in (	select b.JTSOID 
												from GRL_CAB_ENVIO_ESTCTA b with(nolock))
	else
	print ''Comprobación OK.Tabla GRL_DET_ENVIO_ESTCTA con GRL_CAB_ENVIO_ESTCTA ''

----------------------------------------38
----------------------------------------39
	if exists (	select a.COMERCIALIZADORA 
				from SOLICAPERTCTAVISTA a with(nolock)
				where a.COMERCIALIZADORA not in (select b.ID 
												from VTA_COMERCIALIZADORAS b with(nolock))

				)	
				SELECT   ''Tabla SOLICAPERTCTAVISTA no se ajusta a la integridad referencial con VTA_COMERCIALIZADORAS '',*
				from SOLICAPERTCTAVISTA a with(nolock)
				where a.COMERCIALIZADORA not in (select b.ID 
												from VTA_COMERCIALIZADORAS b with(nolock))				
	else
	print ''Comprobación OK. Tabla SOLICAPERTCTAVISTA con VTA_COMERCIALIZADORAS ''
----------------------------------------40
	if exists (	select a.SALDO_JTS_OID 
				from VTA_RESERVAS a with(nolock) 
				where a.SALDO_JTS_OID not in (	select b.JTS_OID 
													from SALDOS b with(nolock))
			)	
				SELECT    ''Tabla VTA_RESERVAS no se ajusta a la integridad referencial con SALDOS '',*
				from VTA_RESERVAS a with(nolock) 
				where a.SALDO_JTS_OID not in (	select b.JTS_OID 
													from SALDOS b with(nolock))
	else
	print ''Comprobación OK.Tabla VTA_RESERVAS con SALDOS ''

----------------------------------------41
	if exists (	select a.CODAPODERAMIENTO 
				from PYF_APODERAMIENTO a with(nolock) 
				where a.CODAPODERAMIENTO not in (	select b.CODAPODERAMIENTO 
													from PYF_TIPOAPODERAMIENTO b with(nolock))
			)	
				SELECT    ''Tabla PYF_APODERAMIENTO no se ajusta a la integridad referencial con PYF_TIPOAPODERAMIENTO '',*
				from PYF_APODERAMIENTO a with(nolock) 
				where a.CODAPODERAMIENTO not in (	select b.CODAPODERAMIENTO 
													from PYF_TIPOAPODERAMIENTO b with(nolock))
	else
	print ''Comprobación OK.Tabla PYF_APODERAMIENTO con PYF_TIPOAPODERAMIENTO ''
----------------------------------------42
	if exists (select a.CODPODER 
				from PYF_APODERAMIENTO a with(nolock) 
				where a.CODPODER not in( select b.TIPO_PODER
											from PYF_TIPOPODERES b with(nolock))
				)	
				SELECT   ''Tabla PYF_APODERAMIENTO no se ajusta a la integridad referencial con PYF_TIPOPODERES '',*
				from PYF_APODERAMIENTO a with(nolock) 
				where a.CODPODER not in( select b.TIPO_PODER
											from PYF_TIPOPODERES b with(nolock))
	else
	print ''Comprobación OK. Tabla PYF_APODERAMIENTO con PYF_TIPOPODERES ''
----------------------------------------43
	if exists (	select a.TIPO_PODER 
				from PYF_TIPOPODER_X_TIPOENTIDAD a with(nolock) 
				where a.TIPO_PODER not in( select b.TIPO_PODER 
											from PYF_TIPOPODERES B with(nolock))
			)	
				SELECT   ''Tabla PYF_TIPOPODER_X_TIPOENTIDAD no se ajusta a la integridad referencial con PYF_TIPOPODERES '',*
				from PYF_TIPOPODER_X_TIPOENTIDAD a with(nolock) 
				where a.TIPO_PODER not in( select b.TIPO_PODER 
											from PYF_TIPOPODERES B with(nolock))
	else
	print ''Comprobación OK.Tabla PYF_TIPOPODER_X_TIPOENTIDAD con PYF_TIPOPODERES ''
----------------------------------------44
	if exists (	select a.TIPO_ENTIDAD 
				from PYF_TIPOPODER_X_TIPOENTIDAD a with(nolock) 
				where a.TIPO_ENTIDAD not in( select b.TIPO_ENTIDAD 
											from PYF_TIPOENTIDAD b with(nolock))
			)	
				SELECT   ''Tabla PYF_TIPOPODER_X_TIPOENTIDAD no se ajusta a la integridad referencial con PYF_TIPOENTIDAD '',*
				from PYF_TIPOPODER_X_TIPOENTIDAD a with(nolock) 
				where a.TIPO_ENTIDAD not in( select b.TIPO_ENTIDAD 
											from PYF_TIPOENTIDAD b with(nolock))
	else
	print ''Comprobación OK.Tabla PYF_TIPOPODER_X_TIPOENTIDAD con PYF_TIPOENTIDAD ''
----------------------------------------45
	if exists (	select a.COD_PAQUETE 
				from CLI_PAQUETE_PRODUCTOS a with(nolock) 
				where a.cod_paquete not in (select b.COD_PAQUETE 
											from CLI_PAQUETES b with(nolock))
			)	
				SELECT   ''Tabla CLI_PAQUETE_PRODUCTOS no se ajusta a la integridad referencial con CLI_PAQUETES '',*
				from CLI_PAQUETE_PRODUCTOS a with(nolock) 
				where a.cod_paquete not in (select b.COD_PAQUETE 
											from CLI_PAQUETES b with(nolock))
	else
	print ''Comprobación OK.Tabla CLI_PAQUETE_PRODUCTOS con CLI_PAQUETES ''
----------------------------------------46
	if exists (	select a.COD_PAQUETE 
				from CLI_PAQUETE_BENEFICIOS a with(nolock) 
				where a.COD_PAQUETE not in (select b.COD_PAQUETE 
											from CLI_PAQUETES b with(nolock))
			)	
				SELECT   ''Tabla CLI_PAQUETE_BENEFICIOS no se ajusta a la integridad referencial con CLI_PAQUETES '',*
				from CLI_PAQUETE_BENEFICIOS a with(nolock) 
				where a.COD_PAQUETE not in (select b.COD_PAQUETE 
											from CLI_PAQUETES b with(nolock))
	else
	print ''Comprobación OK.Tabla CLI_PAQUETE_BENEFICIOS con CLI_PAQUETES ''
----------------------------------------47
	if exists (select a.COD_PAQUETE 
				from CLI_CLIENTES_PAQUETES a with(nolock) 
				where a.COD_PAQUETE not in (select b.COD_PAQUETE 
											from CLI_PAQUETES B with(nolock))
				)	
				SELECT    ''Tabla CLI_CLIENTES_PAQUETES no se ajusta a la integridad referencial con CLI_PAQUETES '',*
				from CLI_CLIENTES_PAQUETES a with(nolock) 
				where a.COD_PAQUETE not in (select b.COD_PAQUETE 
											from CLI_PAQUETES B with(nolock))
	else
	print ''Comprobación OK. Tabla CLI_CLIENTES_PAQUETES con CLI_PAQUETES ''
----------------------------------------48
	if exists (	select a.COD_BENEFICIO 
				from CLI_PAQUETE_BENEFICIOS a with(nolock) 
				where a.COD_BENEFICIO not in (select b.cod_beneficio 
												from CLI_BENEFICIOS b with(nolock))
			)	
				SELECT   ''Tabla CLI_PAQUETE_BENEFICIOS no se ajusta a la integridad referencial con CLI_BENEFICIOS '',*
				from CLI_PAQUETE_BENEFICIOS a with(nolock) 
				where a.COD_BENEFICIO not in (select b.cod_beneficio 
												from CLI_BENEFICIOS b with(nolock))
	else
	print ''Comprobación OK.Tabla CLI_PAQUETE_BENEFICIOS con CLI_BENEFICIOS ''
----------------------------------------49
	if exists (select a.COD_CLIENTE 
				from CLI_CLIENTES_PAQUETES a with(nolock) 
				where a.COD_CLIENTE not in (select b.CODIGOCLIENTE 
											from CLI_clientes B with(nolock))
				)	
				SELECT   ''Tabla CLI_CLIENTES_PAQUETES no se ajusta a la integridad referencial con CLI_clientes '',*
				from CLI_CLIENTES_PAQUETES a with(nolock) 
				where a.COD_CLIENTE not in (select b.CODIGOCLIENTE 
											from CLI_clientes B with(nolock))
	else
	print ''Comprobación OK.Tabla CLI_CLIENTES_PAQUETES con CLI_clientes ''
----------------------------------------50
	if exists (	select a.PRODUCTO 
				from cli_paquete_productos a with(nolock) 
				where a.PRODUCTO not in (select b.c6250 
										from PRODUCTOS b with(nolock))
			)	
				SELECT   ''Tabla cli_paquete_productos no se ajusta a la integridad referencial con PRODUCTOS '',*
				from cli_paquete_productos a with(nolock) 
				where a.PRODUCTO not in (select b.c6250 
										from PRODUCTOS b with(nolock))
	else
	print ''Comprobación OK.Tabla cli_paquete_productos con PRODUCTOS ''
----------------------------------------51
	if exists (	select a.GRUPO 
				from DSP_GRUPOS_CUENTAS  a with(nolock) 
				where a.GRUPO not in(	select b.GRUPO
											from DSP_DEFINICION_GRUPOS B with(nolock))
			)	
				SELECT   ''Tabla DSP_GRUPOS_CUENTAS no se ajusta a la integridad referencial con DSP_DEFINICION_GRUPOS '',*
				from DSP_GRUPOS_CUENTAS  a with(nolock) 
				where a.GRUPO not in(	select b.GRUPO
											from DSP_DEFINICION_GRUPOS B with(nolock))
	else
	print ''Comprobación OK.Tabla DSP_GRUPOS_CUENTAS con DSP_DEFINICION_GRUPOS ''
----------------------------------------52
	if exists (select a.NUMEROPERSONAFISICA 
				from CLI_PERSONAS_FOTOS a with(nolock) 
				where a.NUMEROPERSONAFISICA not in (select b.NUMEROPERSONAFISICA 
													from CLI_PERSONASFISICAS b with(nolock))
				)	
				SELECT   ''Tabla CLI_PERSONAS_FOTOS no se ajusta a la integridad referencial con CLI_PERSONASFISICAS '',*
				from CLI_PERSONAS_FOTOS a with(nolock) 
				where a.NUMEROPERSONAFISICA not in (select b.NUMEROPERSONAFISICA 
													from CLI_PERSONASFISICAS b with(nolock))
	else
	print ''Comprobación OK.Tabla CLI_PERSONAS_FOTOS con CLI_PERSONASFISICAS ''
----------------------------------------53
	if exists (select a.NUMEROPERSONAFISICA 
				from CLI_PERSONAS_IMAGEN_DOC a with(nolock) 
				where a.NUMEROPERSONAFISICA not in (select b.NUMEROPERSONAFISICA 
													from CLI_PERSONASFISICAS b with(nolock))
				)	
				SELECT   ''Tabla CLI_PERSONAS_IMAGEN_DOC no se ajusta a la integridad referencial con CLI_PERSONASFISICAS '',*
				from CLI_PERSONAS_IMAGEN_DOC a with(nolock) 
				where a.NUMEROPERSONAFISICA not in (select b.NUMEROPERSONAFISICA 
													from CLI_PERSONASFISICAS b with(nolock))
	else
	print ''Comprobación OK. Tabla CLI_PERSONAS_IMAGEN_DOC con CLI_PERSONASFISICAS ''
----------------------------------------54
	if exists (	select a.NUMEROPERSONAFISICA 
				from CLI_PERSONAS_FIRMAS a with(nolock) 
				where a.NUMEROPERSONAFISICA not in (select b.NUMEROPERSONAFISICA
													from CLI_PERSONASFISICAS b with(nolock))
				)	
				SELECT   ''Tabla CLI_PERSONAS_FIRMAS no se ajusta a la integridad referencial con CLI_PERSONASFISICAS '',*
				from CLI_PERSONAS_FIRMAS a with(nolock) 
				where a.NUMEROPERSONAFISICA not in (select b.NUMEROPERSONAFISICA
													from CLI_PERSONASFISICAS b with(nolock))
	else
	print ''Comprobación OK.Tabla CLI_PERSONAS_FIRMAS con CLI_PERSONASFISICAS ''
----------------------------------------55
	if exists (	select a.CODIGOCLIENTE 
				from CLI_ClientePersona a with(nolock) 
				where a.CODIGOCLIENTE not in (	select b.CODIGOCLIENTE 
												from CLI_clientes b with(nolock))
			)	
				SELECT    ''Tabla CLI_ClientePersona no se ajusta a la integridad referencial con CLI_clientes '',*
				from CLI_ClientePersona a with(nolock) 
				where a.CODIGOCLIENTE not in (	select b.CODIGOCLIENTE 
												from CLI_clientes b with(nolock))
	else
	print ''Comprobación OK.Tabla CLI_ClientePersona con CLI_clientes ''
----------------------------------------56
	if exists (	select b.producto 
				from saldos b with(nolock) 
				where b.producto not in (	select a.c6250 
												from productos a with(nolock))
			)	
				SELECT     ''Tabla SALDOS no se ajusta a la integridad referencial con PRODUCTOS '',*
				from saldos b with(nolock) 
				where b.producto not in (	select a.c6250 
												from productos a with(nolock))
	else
	print ''Comprobación OK.Tabla SALDOS con PRODUCTOS ''
----------------------------------------57
	if exists (	select b.SALDO_JTS_OID 
				from GRL_EMBARGO b with(nolock) 
				where b.SALDO_JTS_OID not in (	select a.saldo_jts_oid 
												from grl_bloqueos a with(nolock))
			)	
				SELECT     ''Tabla GRL_EMBARGO no se ajusta a la integridad referencial con grl_bloqueos '',*
				from GRL_EMBARGO b with(nolock) 
				where b.SALDO_JTS_OID not in (	select a.saldo_jts_oid 
												from grl_bloqueos a with(nolock))
	else
	print ''Comprobación OK.Tabla GRL_EMBARGO con grl_bloqueos ''
----------------------------------------58
	if exists (	select b.TIPO_RESERVA 
				from VTA_RESERVAS b with(nolock) 
				where b.TIPO_RESERVA not in (	select a.TIPO 
												from VTA_TIPO_RESERVAS a with(nolock))
			)	
				SELECT     ''Tabla VTA_RESERVAS no se ajusta a la integridad referencial con VTA_TIPO_RESERVAS '',*
				from VTA_RESERVAS b with(nolock) 
				where b.TIPO_RESERVA not in (	select a.TIPO 
												from VTA_TIPO_RESERVAS a with(nolock))
	else
	print ''Comprobación OK.Tabla VTA_RESERVAS con VTA_TIPO_RESERVAS ''

----------------------------------------59
	if exists (	select b.MONEDA 
				from PROD_RELCANALES b with(nolock) 
				where b.MONEDA not in (	select a.C6399 
												from monedas a with(nolock))
			)	
				SELECT     ''Tabla PROD_RELCANALES no se ajusta a la integridad referencial con MONEDAS '',*
				from PROD_RELCANALES b with(nolock) 
				where b.MONEDA not in (	select a.C6399 
												from monedas a with(nolock))
	else
	print ''Comprobación OK.Tabla PROD_RELCANALES con MONEDAS ''
----------------------------------------60
	if exists (	select b.MONEDA 
				from TOPESPRODUCTO b with(nolock) 
				where b.MONEDA not in (	select a.C6399 
												from monedas a with(nolock))
			)	
				SELECT     ''Tabla TOPESPRODUCTO no se ajusta a la integridad referencial con MONEDAS '',*
				from TOPESPRODUCTO b with(nolock) 
				where b.MONEDA not in (	select a.C6399 
												from monedas a with(nolock))
	else
	print ''Comprobación OK.Tabla TOPESPRODUCTO con MONEDAS ''
----------------------------------------61
	if exists (select a.codproducto 
				from PROD_RESTRICCIONES a with(nolock) 
				where a.codproducto not in (select b.C6250
										from PRODUCTOS b with(nolock))
				)	
				SELECT   ''Tabla PROD_RESTRICCIONES no se ajusta a la integridad referencial con PRODUCTOS '',*
				from PROD_RESTRICCIONES a with(nolock) 
				where a.codproducto not in (select b.C6250
										from PRODUCTOS b with(nolock))
	else
	print ''Comprobación OK. Tabla PROD_RESTRICCIONES con PRODUCTOS ''
----------------------------------------62
	if exists (select a.SEGMENTO 
				from PROD_RELSEGMENTOS a with(nolock) 
				where a.SEGMENTO not in (select b.COD_SEGMENTO
										from CLI_SEGMENTOS b with(nolock))
				)	
				SELECT   ''Tabla PROD_RELSEGMENTOS no se ajusta a la integridad referencial con CLI_SEGMENTOS '',*
				from PROD_RELSEGMENTOS a with(nolock) 
				where a.SEGMENTO not in (select b.COD_SEGMENTO
										from CLI_SEGMENTOS b with(nolock))
	else
	print ''Comprobación OK. Tabla PROD_RELSEGMENTOS con CLI_SEGMENTOS ''
----------------------------------------63
	if exists (select a.JTS_OID_CTA_DESTINO 
				from CV_TRANSFERENCIA a with(nolock) 
				where	a.JTS_OID_CTA_DESTINO not in (	select b.JTS_OID
														from SALDOS b with(nolock))
					or
						a.JTS_OID_CTA_FUENTE not in  (	select b.JTS_OID
														from SALDOS b with(nolock))
				)	
				SELECT   ''Tabla CV_TRANSFERENCIA no se ajusta a la integridad referencial con SALDOS '',*
				from CV_TRANSFERENCIA a with(nolock) 
				where	a.JTS_OID_CTA_DESTINO not in (	select b.JTS_OID
														from SALDOS b with(nolock))
					or
						a.JTS_OID_CTA_FUENTE not in  (	select b.JTS_OID
														from SALDOS b with(nolock))
	else
	print ''Comprobación OK. Tabla CV_TRANSFERENCIA con SALDOS ''


	END
ELSE
	print ''NO CORRESPONDE LA BASE DE DATOS''
END
; ')
