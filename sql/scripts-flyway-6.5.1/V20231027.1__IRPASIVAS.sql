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

	END
ELSE
	print ''NO CORRESPONDE LA BASE DE DATOS''
END

; ')
