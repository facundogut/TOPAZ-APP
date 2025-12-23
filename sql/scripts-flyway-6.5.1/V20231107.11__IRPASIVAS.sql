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
if exists (select a.ESTADO 
				from CHE_CHEQUERAS a with(nolock) 
				where a.ESTADO not in  (select b.CODIGO 
										from CHE_ESTADOSCHEQUERAS b with(nolock))
				)	
				SELECT    ''Tabla CHE_CHEQUERAS no se ajusta a la integridad referencial con CHE_ESTADOSCHEQUERAS '',*
				from CHE_CHEQUERAS a with(nolock) 
				where a.ESTADO not in  (select b.CODIGO 
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
								inner join Che_CheqSolicitud b with(nolock) on a.NroSolicitud	= b.NroSolicitud
																			and a.Sucursal=b.SUCURSAL)
	else
	print ''Comprobación OK.Tabla CHE_CHEQUESIMPRENTA con Che_CheqSolicitud ''
---------------------------------------------4	
	if exists (select b.CODIGO_BCRA 
				from CHE_MOTIVOS_RECHAZO b with(nolock) 
				where b.CODIGO_BCRA not in (select a.codigo_motivo_rechazo 
											from CHE_CHEQUESDENUNCIADOS a with(nolock)) 
				)	
				SELECT   ''Tabla CHE_MOTIVOS_RECHAZO no se ajusta a la integridad referencial con CHE_CHEQUESDENUNCIADOS '',*
				from CHE_MOTIVOS_RECHAZO b with(nolock) 
				where b.CODIGO_BCRA not in (select a.codigo_motivo_rechazo 
											from CHE_CHEQUESDENUNCIADOS a with(nolock)) 
	else
	print ''Comprobación OK.Tabla CHE_MOTIVOS_RECHAZO con CHE_CHEQUESDENUNCIADOS ''
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
	
	if exists (	select b.CUENTA
					from che_cheques b with(nolock) 
					left join che_chequeras a with(nolock) on a.sucursal = b.SUCURSAL
																and a.cuenta = b.CUENTA
																and a.MONEDA = b.MONEDA
																and a.OPERACION = b.OPERACION
																and a.ORDINAL = b.ORDINAL
																and a.PRODUCTO = b.PRODUCTO
																and a.SERIE = b.SERIE
					where a.sucursal is null
						and a.cuenta is null
						and a.moneda is null
						and a.operacion is null
						and a.serie is null
						and a.chequedesde is null
						and a.chequehasta is null
						and a.ordinal is null
						and a.producto is null
				)	
					SELECT   ''Tabla che_cheques no se ajusta a la integridad referencial con che_chequeras '',*
					from che_cheques b with(nolock) 
					left join che_chequeras a with(nolock)    on a.sucursal = b.SUCURSAL
																and a.cuenta = b.CUENTA
																and a.MONEDA = b.MONEDA
																and a.OPERACION = b.OPERACION
																and a.ORDINAL = b.ORDINAL
																and a.PRODUCTO = b.PRODUCTO
																and a.SERIE = b.SERIE
					where a.sucursal is null
						and a.cuenta is null
						and a.moneda is null
						and a.operacion is null
						and a.serie is null
						and a.chequedesde is null
						and a.chequehasta is null
						and a.ordinal is null
						and a.producto is null
		else
		print ''Comprobación OK.Tabla che_cheques con che_chequeras ''
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
	if exists (	select a.CANTIDADCHEQUES 
				from CHE_CHEQUERAS a with(nolock) 
				left join CHE_CHEQUESIMPRENTA b on a.SUCURSAL = B.Sucursal
													AND A.CUENTA = B.Cuenta
													AND A.MONEDA = B.Moneda
													AND A.CLIENTE = B.Cliente
													AND A.NROSOLICCHEQ = B.NroSolicitud


				where B.Sucursal IS NULL
				AND B.CUENTA IS NULL
				AND B.MONEDA IS NULL
				AND B.CLIENTE IS NULL
				AND B.NroSolicitud IS NULL
			)	
				SELECT   ''Tabla CHE_CHEQUERAS no se ajusta a la integridad referencial con CHE_CHEQUESIMPRENTA '',*
				from CHE_CHEQUERAS a with(nolock) 
				left join CHE_CHEQUESIMPRENTA b on a.SUCURSAL = B.Sucursal
													AND A.CUENTA = B.Cuenta
													AND A.MONEDA = B.Moneda
													AND A.CLIENTE = B.Cliente
													AND A.NROSOLICCHEQ = B.NroSolicitud


				where B.Sucursal IS NULL
				AND B.CUENTA IS NULL
				AND B.MONEDA IS NULL
				AND B.CLIENTE IS NULL
				AND B.NroSolicitud IS NULL
	else
	print ''Comprobación OK.Tabla CHE_CHEQUERAS con CHE_CHEQUESIMPRENTA ''
----------------------------------------12
		if exists (	select a.Cantidad 
				from VTA_CANTIDADESCHEQUES a with(nolock) 
				left join Che_CheqSolicitud b on a.Cantidad = B.CantCheques
													AND A.tipo_encuadernacion = B.TipoChequera
				where B.CantCheques IS NULL
				AND B.TipoChequera IS NULL
			)	
				SELECT   ''Tabla VTA_CANTIDADESCHEQUES no se ajusta a la integridad referencial con Che_CheqSolicitud '',*
				from VTA_CANTIDADESCHEQUES a with(nolock) 
				left join Che_CheqSolicitud b on a.Cantidad = B.CantCheques
													AND A.tipo_encuadernacion = B.TipoChequera
				where B.CantCheques IS NULL
				AND B.TipoChequera IS NULL
	else
	print ''Comprobación OK.Tabla VTA_CANTIDADESCHEQUES con Che_CheqSolicitud ''
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
				where a.CODIGO_EVENTO not in (	select b.codigo_contrato 
												from COF_COFRES_EVENTOS b with(nolock))
			)	
				SELECT   ''Tabla COF_COFRES_DETALLE_EVENTOS no se ajusta a la integridad referencial con COF_COFRES_EVENTOS '',*
				from COF_COFRES_DETALLE_EVENTOS a with(nolock) 
				where a.CODIGO_EVENTO not in (	select b.codigo_contrato 
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
	if exists (	select a.ID_PEDIDO 
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
				from DPF_DOCS_RECEPCIONES a with(nolock) 
				where a.CODIGO_TIPO not in(select b.CODIGO_TIPO 
											from DPF_DOCS_SOLICITUDES b with(nolock))
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
				where a.CATEGORIA not in(select b.CODIGOCATEGORIA 
											from DPF_CATEGORIAS_ESPECIE b with(nolock))
			  )	
				SELECT   ''Tabla DPF_CODIGOS_ESPECIE no se ajusta a la integridad referencial con DPF_CATEGORIAS_ESPECIE '',*
				from DPF_CODIGOS_ESPECIE a with(nolock) 
				where a.CATEGORIA not in(select b.CODIGOCATEGORIA 
											from DPF_CATEGORIAS_ESPECIE b with(nolock))
	else
	print ''Comprobación OK.DPF_CODIGOS_ESPECIE TASAS con DPF_CATEGORIAS_ESPECIE ''

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
	print ''Comprobación OK.SOLICAPERTURADPF TASAS con DPF_RELPRODVISTA ''

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
				where a.JTS_OID not in(	select b.jts_oid 
												from SALDOS B with(nolock))
			  )	
				SELECT    ''Tabla BS_HISTORIA_PLAZO no se ajusta a la integridad referencial con SALDOS '',*
				from DPF_CAMBIO_VTO_POR_PARO a with(nolock) 
				where a.SALDO_JTS_OID not in(	select b.jts_oid 
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
				left join SALDOS B with(nolock) on a.cuenta = b.cuenta
													and b.sucursal = b.sucursal
				where b.cuenta is null
				and b.sucursal is null 
			  )	
				SELECT    ''Tabla DPF_RENOVACIONES no se ajusta a la integridad referencial con SALDOS '',*
				from DPF_RENOVACIONES a with(nolock) 
				left join SALDOS B with(nolock) on a.cuenta = b.cuenta
													and b.sucursal = b.sucursal
				where b.cuenta is null
				and b.sucursal is null 
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
	if exists (	select a.COD_BLOQUEO 
				from grl_bloqueos a with(nolock) 
				where a.COD_BLOQUEO not in(	select b.COD_BLOQUEO 
												from GRL_REL_BLOQUEO_SEGURIDAD B with(nolock))
			  )	
				SELECT    ''Tabla grl_bloqueos no se ajusta a la integridad referencial con GRL_REL_BLOQUEO_SEGURIDAD '',*
				from grl_bloqueos a with(nolock) 
				where a.COD_BLOQUEO not in(	select b.COD_BLOQUEO 
												from GRL_REL_BLOQUEO_SEGURIDAD B with(nolock))
	else
	print ''Comprobación OK.Tabla grl_bloqueos  con GRL_REL_BLOQUEO_SEGURIDAD ''
----------------------------------------18
	if exists (	select a.tasa_fondo_garantia 
				from SOLICAPERTURADPF a with(nolock) 
				where a.tasa_fondo_garantia not in(	select b.tasa_mn 
												from TASASFONDOGARANTIA B with(nolock))
			  )	
				SELECT    ''Tabla SOLICAPERTURADPF no se ajusta a la integridad referencial con TASASFONDOGARANTIA '',*
				from SOLICAPERTURADPF a with(nolock) 
				where a.tasa_fondo_garantia not in(	select b.tasa_mn 
												from TASASFONDOGARANTIA B with(nolock))
	else
	print ''Comprobación OK.Tabla SOLICAPERTURADPF  con TASASFONDOGARANTIA ''
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
	if exists (	select a.CLAVE 
				from USUARIOS a with(nolock) 
				where a.CLAVE not in(	select b.USUARIO 
												from NETMAP B with(nolock))
			  )	
				SELECT    ''Tabla USUARIOS no se ajusta a la integridad referencial con NETMAP '',*
				from USUARIOS a with(nolock) 
				where a.CLAVE not in(	select b.USUARIO 
												from NETMAP B with(nolock))
	else
	print ''Comprobación OK.Tabla USUARIOS  con NETMAP ''

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
	print ''Comprobación OK.Tabla CAJ_HISTORIAL_BILLETAJE  con ASIENTOS ''

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
	if exists (	select a.NRODECAJA 
				from USUARIOS a with(nolock) 
				where a.NRODECAJA not in(	select b.NRO_CAJA 
												from TABLA_CAJAS B with(nolock))
			  )	
				SELECT    ''Tabla USUARIOS no se ajusta a la integridad referencial con TABLA_CAJAS '',*
				from USUARIOS a with(nolock) 
				where a.NRODECAJA not in(	select b.NRO_CAJA 
												from TABLA_CAJAS B with(nolock))
	else
	print ''Comprobación OK.Tabla USUARIOS  con TABLA_CAJAS ''
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
	if exists (	select a.SUCURSAL 
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

	END
ELSE
	print ''NO CORRESPONDE LA BASE DE DATOS''
END
; ')
