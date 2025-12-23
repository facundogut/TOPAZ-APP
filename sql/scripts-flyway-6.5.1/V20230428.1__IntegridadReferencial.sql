execute('
----------------------------------------CLIENTES.-----------------------------------------------------------
--exec SP_INTEGRIDAD_REFERENCIAL NBCH_tunning

CREATE OR ALTER  procedure [dbo].[SP_INTEGRIDAD_REFERENCIAL] 
						@BD varchar(20)
as
BEGIN
IF (SELECT DB_NAME()) = @BD
  BEGIN
	print ''-------------------CLIENTES--------------''
	print ''-----------------------------------------''
	if exists (
				select b.CODIGOCLIENTE 
				from CLI_INSTITUCIONFINANCIERA b with(nolock)
				where b.CODIGOCLIENTE not in ( 
											select a.CODIGOCLIENTE 
											from CLI_CLIENTES a with(nolock) )
				)
	PRINT ''Tabla CLI_INSTITUCIONFINANCIERA no se ajusta a la integridad referencial con CLI_CLIENTES ''
	ELSE 
	print ''Comprobación OK. Tabla CLI_INSTITUCIONFINANCIERA con CLI_CLIENTES ''

	if exists (	select a.NROCLIENTE   
				from CLI_BLOQUEOS a with(nolock)
				where a.NROCLIENTE not in (	select b.CODIGOCLIENTE 
											from CLI_CLIENTES b with(nolock))
				)	
	print ''Tabla CLI_BLOQUEOS no se ajusta a la integridad referencial con CLI_CLIENTES ''
	else
	print ''Comprobación OK. Tabla CLI_BLOQUEOS con CLI_CLIENTES ''

	if exists (	select a.COD_CLIENTE 
				from CLI_CORRESPONSALES a with(nolock)
				where a.COD_CLIENTE not in (select b.CODIGOCLIENTE 
											from CLI_INSTITUCIONFINANCIERA b with(nolock))
				)	
	print ''Tabla CLI_CORRESPONSALES no se ajusta a la integridad referencial con CLI_INSTITUCIONFINANCIERA ''
	else
	print ''Comprobación OK.Tabla CLI_CORRESPONSALES con CLI_INSTITUCIONFINANCIERA ''

	if exists (	select a.COD_SEGMENTO  
				from CLI_SEGMENTOS a with(nolock)
				where a.COD_SEGMENTO not in (select b.SEGMENTOCLIENTE 
											from CLI_CLIENTES b with(nolock))
				)	
	print ''Tabla CLI_SEGMENTOS no se ajusta a la integridad referencial con CLI_CLIENTES ''
	else
	print ''Comprobación OK.Tabla CLI_SEGMENTOS con CLI_CLIENTES ''

	if exists (select a.COD_SUBSEGMENTO  
				from CLI_SUBSEGMENTOS a with(nolock)
				where a.COD_SEGMENTO not in (select b.COD_SEGMENTO  
											from CLI_SEGMENTOS b with(nolock))
				)	
	print ''Tabla CLI_SUBSEGMENTOS no se ajusta a la integridad referencial con CLI_SEGMENTOS ''
	else
	print ''Comprobación OK. Tabla CLI_SUBSEGMENTOS con CLI_SEGMENTOS ''

	if exists (select * 
				from BITACORA_PERSONAS_JURIDICAS a with(nolock)
				where a.NUMEROPERSONAJURIDICA not in (	select b.NUMEROPERSONAJURIDICA 
														from CLI_PERSONASJURIDICAS b with(nolock)) 
				)	
	print ''Tabla BITACORA_PERSONAS_JURIDICAS no se ajusta a la integridad referencial con CLI_PERSONASJURIDICAS ''
	else
	print ''Comprobación OK. Tabla BITACORA_PERSONAS_JURIDICAS con CLI_PERSONASJURIDICAS ''

	if exists (select b.TIPOSOCIEDAD 
				from CLI_PERSONASJURIDICAS b  with(nolock)
				where b.TIPOSOCIEDAD not in (	select a.CODIGO_SOCIEDAD 
												from CLI_TIPO_SOCIEDAD a with(nolock)) 
				)	
	print ''Tabla CLI_PERSONASJURIDICAS no se ajusta a la integridad referencial con CLI_TIPO_SOCIEDAD ''
	else
	print ''Comprobación OK.Tabla CLI_PERSONASJURIDICAS con CLI_TIPO_SOCIEDAD ''

	if exists (select a.CODIGO_ACTIVIDAD 
				from cli_actividad_economica a with(nolock)
				where a.CODIGO_ACTIVIDAD not in (select b.CODIGO_ACT_AFIP 
												from CLI_Cod_Act_AFIP b with(nolock))
				)	
	print ''Tabla cli_actividad_economica no se ajusta a la integridad referencial con CLI_Cod_Act_AFIP ''
	else
	print ''Comprobación OK. Tabla cli_actividad_economica con CLI_Cod_Act_AFIP ''

	if exists (select a.CODIGO_SECCION 
				from CLI_SECCION a with(nolock)
				where a.CODIGO_SECCION not in (select b.CODIGO_SECCION 
												from CLI_Cod_Act_AFIP b with(nolock))
				)	
	print ''Tabla CLI_SECCION no se ajusta a la integridad referencial con CLI_Cod_Act_AFIP ''
	else
	print ''Comprobación OK. Tabla CLI_SECCION con CLI_Cod_Act_AFIP ''

	if exists (select a.CODIGO_BCRA 
				from CLI_Cod_Act_BCRA a with(nolock)
				where a.CODIGO_BCRA not in (select b.CODIGO_BCRA 
											from CLI_Cod_Act_AFIP b with(nolock))
				)	
	print ''Tabla CLI_Cod_Act_BCRA no se ajusta a la integridad referencial con CLI_Cod_Act_AFIP ''
	else
	print ''Comprobación OK. Tabla CLI_Cod_Act_BCRA con CLI_Cod_Act_AFIP ''

	if exists (select a.CODIGO_SECTOR 
				from CLI_ACTIVIDAD_SECTOR a with(nolock) 
				where a.CODIGO_SECTOR not in (	select b.CODIGO_SECTOR 
												from CLI_Cod_Act_AFIP b with(nolock))
				)	
	print ''Tabla CLI_ACTIVIDAD_SECTOR no se ajusta a la integridad referencial con CLI_Cod_Act_AFIP ''
	else
	print ''Comprobación OK. Tabla CLI_ACTIVIDAD_SECTOR con CLI_Cod_Act_AFIP ''

	if exists (select a.CODIGOPAIS 
				from cli_localidades a with(nolock)
				where a.CODIGOPAIS   not in (select b.pais 
											from CLI_DIRECCIONES b with(nolock))
				)	
	print ''Tabla cli_localidades no se ajusta a la integridad referencial con CLI_DIRECCIONES ''
	else
	print ''Comprobación OK. Tabla cli_localidades con CLI_DIRECCIONES ''

	if exists (select a.CODIGOPAIS 
				from CLI_PROVINCIAS a with(nolock)
				where a.CODIGOPAIS not in (select b.CODIGOPAIS 
											from CLI_PAISES b with(nolock))
				)	
	print ''Tabla CLI_PAISES no se ajusta a la integridad referencial con CLI_PROVINCIAS ''
	else
	print ''Comprobación OK. Tabla CLI_PAISES con CLI_PROVINCIAS ''

	if exists (select a.TIPO_ROL 
				from cli_vinculos a with(nolock)
				where a.TIPO_ROL not in (select b.TIPO_ROL 
										from CLI_ROLES b with(nolock))
				)	
	print ''Tabla CLI_PAISES no se ajusta a la integridad referencial con CLI_PROVINCIAS ''
	else
	print ''Comprobación OK.Tabla CLI_PAISES con CLI_PROVINCIAS ''

	if exists (select a.VINCULO 
				from CLI_VINCULACIONES a with(nolock)
				where a.VINCULO not in (select b.ID 
										from CLI_VINCULOS b with(nolock))
				)	
	print ''Tabla CLI_VINCULACIONES no se ajusta a la integridad referencial con CLI_VINCULOS ''
	else
	print ''Comprobación OK. Tabla CLI_VINCULACIONES con CLI_VINCULOS ''

	if exists (select a.ID 
				from CLI_VINCULOS_PRIMARIOS a with(nolock)
				where a.ID not in (select b.VINCULO_PRIMARIO 
									from CLI_VINCULOS b with(nolock))
				)	
	print ''Tabla CLI_VINCULOS_PRIMARIOS no se ajusta a la integridad referencial con CLI_VINCULOS ''
	else
	print ''Comprobación OK. Tabla CLI_VINCULOS_PRIMARIOS con CLI_VINCULOS ''

	if exists (select a.ID 
				from CLI_VINCULOS_SECUNDARIOS a with(nolock)
				where a.ID not in (select b.VINCULO_SECUNDARIO 
									from CLI_VINCULOS b with(nolock))
				)	
	print ''Tabla CLI_VINCULOS_SECUNDARIOS no se ajusta a la integridad referencial con CLI_VINCULOS ''
	else
	print ''Comprobación OK. Tabla CLI_VINCULOS_SECUNDARIOS con CLI_VINCULOS ''

	if exists (	select a.NUMEROPERSONAFISICA 
				from CLI_PFCONYUGE a with(nolock)
				where a.NUMEROPERSONAFISICA not in (select b.PERSONA_VINCULADA 
													from CLI_VINCULACIONES b with(nolock))
				)	
	print ''Tabla CLI_PFCONYUGE no se ajusta a la integridad referencial con CLI_VINCULACIONES ''
	else
	print ''Comprobación OK. Tabla CLI_PFCONYUGE con CLI_VINCULACIONES ''

	if exists (	select * 
				FROM CLI_INTEGRANTESPJ a with(nolock)
				WHERE a.NUMEROPERSONAJURIDICA NOT IN (	SELECT b.NUMEROPERSONAJURIDICA 
														FROM CLI_PERSONASJURIDICAS b with(nolock))
				)	
	print ''Tabla CLI_INTEGRANTESPJ no se ajusta a la integridad referencial con CLI_PERSONASJURIDICAS ''
	else
	print ''Comprobación OK.Tabla CLI_INTEGRANTESPJ con CLI_PERSONASJURIDICAS ''

	if exists (	SELECT * 
				FROM CLI_PERSONASJURIDICAS b with(nolock)
				WHERE b.SECTOR NOT IN (	select a.SECTOR 
										FROM CLI_SECTORES a with(nolock))
				)	
	print ''Tabla CLI_PERSONASJURIDICAS no se ajusta a la integridad referencial con CLI_SECTORES ''
	else
	print ''Comprobación OK. Tabla CLI_PERSONASJURIDICAS con CLI_SECTORES ''

	if exists (	SELECT * 
				FROM CLI_PERSONASFISICAS b with(nolock)
				WHERE b.SECTOR NOT IN (	select a.SECTOR 
										FROM CLI_SECTORES a with(nolock))
				)	
	print ''Tabla CLI_PERSONASFISICAS no se ajusta a la integridad referencial con CLI_SECTORES ''
	else
	print ''Comprobación OK. Tabla CLI_PERSONASFISICAS con CLI_SECTORES ''

	if exists (	select * 
				from CLI_INGRESOS_ANUALES a with(nolock)
				where a.ID_PERSONA not in (	select b.NUMEROPERSONAJURIDICA 
											from CLI_PERSONASJURIDICAS b with(nolock))
				)	
	print ''Tabla CLI_INGRESOS_ANUALES no se ajusta a la integridad referencial con CLI_PERSONASJURIDICAS ''
	else
	print ''Comprobación OK. Tabla CLI_INGRESOS_ANUALES con CLI_PERSONASJURIDICAS ''

	if exists (	select a.NUMERO_PERSONA 
				from ITF_MATRIZ_IGR a with(nolock) 
				where a.NUMERO_PERSONA in (select b.NUMEROPERSONAJURIDICA  
											from CLI_PERSONASJURIDICAS b with(nolock))
				)	
	print ''Tabla ITF_MATRIZ_IGR no se ajusta a la integridad referencial con CLI_PERSONASJURIDICAS ''
	else
	print ''Comprobación OK. Tabla ITF_MATRIZ_IGR con CLI_PERSONASJURIDICAS ''

	if exists (	select a.TIPODOCUMENTO 
				from CLI_DocumentosPFPJ a with(nolock)
				where a.TIPODOCUMENTO not in (select b.TIPODOCUMENTO 
											from CLI_TIPOSDOCUMENTOS b with(nolock))
				)	
	print ''Tabla CLI_DocumentosPFPJ no se ajusta a la integridad referencial con CLI_TIPOSDOCUMENTOS ''
	else
	print ''Comprobación OK. Tabla CLI_DocumentosPFPJ con CLI_TIPOSDOCUMENTOS ''

	if exists (	select a.TIPODOC_IDENT 
				from CLI_TIPOS_DOC_FISICOS  a with(nolock)
				where a.TIPODOC_IDENT not in (select b.TIPODOCUMENTO
												from CLI_TIPOSDOCUMENTOS b with(nolock))
				)	
	print ''Tabla CLI_TIPOS_DOC_FISICOS no se ajusta a la integridad referencial con CLI_TIPOSDOCUMENTOS ''
	else
	print ''Comprobación OK. Tabla CLI_TIPOS_DOC_FISICOS con CLI_TIPOSDOCUMENTOS ''

	if exists (	select a.NUMEROPERSONAFJ 
				from CLI_DocumentosPFPJ  a  with(nolock)
				where a.NUMEROPERSONAFJ not in (select b.NUMEROPERSONAJURIDICA
												from CLI_PERSONASJURIDICAS b with(nolock))
				)	
	print ''Tabla CLI_DocumentosPFPJ no se ajusta a la integridad referencial con CLI_PERSONASJURIDICAS ''
	else
	print ''Comprobación OK. Tabla CLI_DocumentosPFPJ con CLI_PERSONASJURIDICAS ''

	if exists (	select A.COD_PROFESION 
				from CLI_PERSONASFISICAS A with(nolock)
				WHERE A.COD_PROFESION NOT IN ( select B.PROFESION 
												from CLI_PROFESIONES B with(nolock))
				)	
	print ''Tabla CLI_PERSONASFISICAS no se ajusta a la integridad referencial con CLI_PROFESIONES ''
	else
	print ''Comprobación OK.Tabla CLI_PERSONASFISICAS con CLI_PROFESIONES ''
	if exists (	select a.SUCURSALVINCULADA
				from CLI_CLIENTES  a with(nolock)
				where a.SUCURSALVINCULADA not in (	select b.SUCURSAL
													from SUCURSALES b with(nolock))
				)	
	print ''Tabla CLI_CLIENTES no se ajusta a la integridad referencial con SUCURSALES ''
	else
	print ''Comprobación OK.Tabla CLI_CLIENTES con SUCURSALES ''

	if exists (	select a.CODIGOCLIENTE
				from CLI_SUCESIONES  a  with(nolock)
				where a.CODIGOCLIENTE not in (	select b.CODIGOBLOQUEO
												from CLI_CLIENTES b with(nolock))
				)	
	print ''Tabla CLI_SUCESIONES no se ajusta a la integridad referencial con CLI_CLIENTES ''
	else
	print ''Comprobación OK. Tabla CLI_SUCESIONES con CLI_CLIENTES ''

	if exists (	select a.NUMEROPERSONAFJ 
				from CLI_DocumentosPFPJ  a with(nolock)
				inner join CLI_CONCURSO_ACREEDORES b with(nolock)
					on b.CUIT_CUIL = a.NUMERODOCUMENTO

				where  a.NUMEROPERSONAFJ not in (select c.NUMEROPERSONAFISICA 
												from CLI_PERSONASFISICAS c with(nolock))
				)	
	print ''Tabla CLI_CONCURSO_ACREEDORES no se ajusta a la integridad referencial con CLI_PERSONASFISICAS ''
	else
	print ''Comprobación OK. Tabla CLI_CONCURSO_ACREEDORES con CLI_PERSONASFISICAS ''

	if exists (	select a.NUMEROPERSONAFJ 
				from CLI_DocumentosPFPJ  a with(nolock)
				inner join CLI_CONCURSO_ACREEDORES b with(nolock)
					on b.CUIT_CUIL = a.NUMERODOCUMENTO

				where  a.NUMEROPERSONAFJ not in (select c.NUMEROPERSONAJURIDICA 
												from CLI_PERSONASJURIDICAS c with(nolock))
				)	
	print ''Tabla CLI_CONCURSO_ACREEDORES no se ajusta a la integridad referencial con CLI_PERSONASJURIDICAS ''
	else
	print ''Comprobación OK. Tabla CLI_CONCURSO_ACREEDORES con CLI_PERSONASJURIDICAS ''

	if exists (	select b.id 
				from CORREOS_A_ENVIAR a with(nolock)
				inner join  CLI_EMAILS b with(nolock) on b.EMAIL = a.MAIL_TO
				where b.id not in (	select c.NUMEROPERSONAJURIDICA
									from CLI_PERSONASJURIDICAS c with(nolock))
				)	
	print ''Tabla CORREOS_A_ENVIAR no se ajusta a la integridad referencial con CLI_PERSONASJURIDICAS ''
	else
	print ''Comprobación OK.Tabla CORREOS_A_ENVIAR con CLI_PERSONASJURIDICAS ''

	if exists (select b.id 
				from CORREOS_A_ENVIAR a with(nolock)
				inner join  CLI_EMAILS b with(nolock) on b.EMAIL = a.MAIL_TO
				where b.id not in (select c.NUMEROPERSONAFISICA
									from CLI_PERSONASFISICAS c with(nolock))
				)	
	print ''Tabla CORREOS_A_ENVIAR no se ajusta a la integridad referencial con CLI_PERSONASFISICAS ''
	else
	print ''Comprobación OK. Tabla CORREOS_A_ENVIAR con CLI_PERSONASFISICAS ''

	if exists (	select a.CUIT 
				from ITF_BCRA_PADFYJ a with(nolock)
				inner join CLI_DocumentosPFPJ b with(nolock) on a.cuit = b.NUMERODOCUMENTO
				where b.NUMEROPERSONAFJ not in (select c.NUMEROPERSONAFISICA
												from CLI_PERSONASFISICAS c with(nolock))
								
				)	
	print ''Tabla ITF_BCRA_PADFYJ no se ajusta a la integridad referencial con CLI_PERSONASJURIDICAS ''
	else
	print ''Comprobación OK. Tabla ITF_BCRA_PADFYJ con CLI_PERSONASJURIDICAS ''

	if exists (	select a.CUIT 
				from ITF_BCRA_PADFYJ a with(nolock)
				inner join CLI_DocumentosPFPJ b with(nolock) on a.cuit = b.NUMERODOCUMENTO
				where b.NUMEROPERSONAFJ not in (select c.NUMEROPERSONAJURIDICA
												from CLI_PERSONASJURIDICAS c with(nolock))
				)	
	print ''Tabla ITF_BCRA_PADFYJ no se ajusta a la integridad referencial con CLI_PERSONASJURIDICAS ''
	else
	print ''Comprobación OK. Tabla ITF_BCRA_PADFYJ con CLI_PERSONASJURIDICAS ''

	if exists (	SELECT A.CUIT 
				FROM CLI_INHABILITADOS_INAES A with(nolock)
				INNER JOIN CLI_DocumentosPFPJ B with(nolock) ON A.CUIT = B.NUMERODOCUMENTO
				WHERE B.NUMERODOCUMENTO NOT IN (select c.NUMEROPERSONAJURIDICA
												from CLI_PERSONASJURIDICAS c with(nolock))
				)	
	print ''Tabla CLI_INHABILITADOS_INAES no se ajusta a la integridad referencial con CLI_PERSONASJURIDICAS ''
	else
	print ''Comprobación OK. Tabla CLI_INHABILITADOS_INAES con CLI_PERSONASJURIDICAS ''

	if exists (	SELECT A.CUIT 
				FROM CLI_INHABILITADOS_INAES A with(nolock)
				INNER JOIN CLI_DocumentosPFPJ B with(nolock) ON A.CUIT = B.NUMERODOCUMENTO
				WHERE B.NUMERODOCUMENTO NOT IN (select c.NUMEROPERSONAFISICA
												from CLI_PERSONASFISICAS c with(nolock))
				)	
	print ''Tabla CLI_INHABILITADOS_INAES no se ajusta a la integridad referencial con CLI_PERSONASFISICAS ''
	else
	print ''Comprobación OK.Tabla CLI_INHABILITADOS_INAES con CLI_PERSONASFISICAS ''

	if exists (	SELECT A.CUIT_CUIL
				FROM CLI_INHABILITADOS_UIF A with(nolock)
				INNER JOIN CLI_DocumentosPFPJ B with(nolock) ON A.CUIT_CUIL = B.NUMERODOCUMENTO 
																AND A.TIPODOCUMENTO= B.TIPODOCUMENTO 
																AND  A.TIPOPERSONA = B.TIPOPERSONA
				WHERE B.NUMERODOCUMENTO NOT IN (select c.NUMEROPERSONAJURIDICA
												from CLI_PERSONASJURIDICAS c with(nolock))
				)	
	print ''Tabla CLI_INHABILITADOS_UIF no se ajusta a la integridad referencial con CLI_PERSONASJURIDICAS ''
	else
	print ''Comprobación OK. Tabla CLI_INHABILITADOS_UIF con CLI_PERSONASJURIDICAS ''

	if exists (	SELECT A.CUIT_CUIL
				FROM CLI_INHABILITADOS_UIF A with(nolock)
				INNER JOIN CLI_DocumentosPFPJ B with(nolock) ON A.CUIT_CUIL = B.NUMERODOCUMENTO 
															AND A.TIPODOCUMENTO= B.TIPODOCUMENTO 
															AND  A.TIPOPERSONA = B.TIPOPERSONA
				WHERE B.NUMERODOCUMENTO NOT IN (select c.NUMEROPERSONAFISICA
												from CLI_PERSONASFISICAS c with(nolock))
				)	
	print ''Tabla CLI_INHABILITADOS_UIF no se ajusta a la integridad referencial con CLI_PERSONASFISICAS ''
	else
	print ''Comprobación OK. Tabla CLI_INHABILITADOS_UIF con CLI_PERSONASFISICAS ''

	if exists (	select a.DOCUMENTO 
				from CLI_LISTA_BLANCA a with(nolock)
				inner join CLI_DocumentosPFPJ b on a.TIPO_DOCUMENTO = b.tipodocumento 
												and a.DOCUMENTO = b.NUMERODOCUMENTO
				where b.NUMEROPERSONAFJ not in (select c.NUMEROPERSONAFISICA
												from CLI_PERSONASFISICAS c with(nolock))
				)	
	print ''Tabla CLI_LISTA_BLANCA no se ajusta a la integridad referencial con CLI_PERSONASFISICAS ''
	else
	print ''Comprobación OK. Tabla CLI_LISTA_BLANCA con CLI_PERSONASFISICAS ''

	if exists (	select a.DOCUMENTO 
				from CLI_LISTA_BLANCA a with(nolock)
				inner join CLI_DocumentosPFPJ b with(nolock)on a.TIPO_DOCUMENTO = b.tipodocumento 
												and a.DOCUMENTO = b.NUMERODOCUMENTO
				where b.NUMEROPERSONAFJ not in (select c.NUMEROPERSONAJURIDICA
												from CLI_PERSONASJURIDICAS c with(nolock))
				)	
	print ''Tabla CLI_LISTA_BLANCA no se ajusta a la integridad referencial con CLI_PERSONASJURIDICAS ''
	else
	print ''Comprobación OK. Tabla CLI_LISTA_BLANCA con CLI_PERSONASJURIDICAS ''

	if exists (	select a.CUIL 
				from CLI_MAESTRO_FALLECIDOS a with(nolock)
				inner join CLI_DocumentosPFPJ b with(nolock)on a.CUIL = b.NUMERODOCUMENTO
				where b.NUMEROPERSONAFJ not in (select c.NUMEROPERSONAFISICA
												from CLI_PERSONASFISICAS c with(nolock))
				)	
	print ''Tabla CLI_MAESTRO_FALLECIDOS no se ajusta a la integridad referencial con CLI_PERSONASFISICAS ''
	else
	print ''Comprobación OK. Tabla CLI_MAESTRO_FALLECIDOS con CLI_PERSONASFISICAS ''

	if exists (	select a.CUIL 
				from CLI_MAESTRO_FALLECIDOS a with(nolock)
				inner join CLI_DocumentosPFPJ b with(nolock)on a.CUIL = b.NUMERODOCUMENTO
				where b.NUMEROPERSONAFJ not in (select c.NUMEROPERSONAJURIDICA
												from CLI_PERSONASJURIDICAS c with(nolock))
				)	
	print ''Tabla CLI_MAESTRO_FALLECIDOS no se ajusta a la integridad referencial con CLI_PERSONASJURIDICAS ''
	else
	print ''Comprobación OK. Tabla CLI_MAESTRO_FALLECIDOS con CLI_PERSONASJURIDICAS ''
	
	if exists (select a.CODIGOCLIENTE 
				from CLI_ClientePersona a with(nolock) 
				where a.CODIGOCLIENTE not in (select b.CODIGOCLIENTE 
												from CLI_clientes b with(nolock))

				)	
	print ''Tabla CLI_ClientePersona no se ajusta a la integridad referencial con CLI_clientes ''
	else
	print ''Comprobación OK.Tabla CLI_ClientePersona con CLI_clientes ''

	if exists (select b.CODIGOCLIENTE 
				from CLI_clientes b with(nolock)
				where b.CODIGOCLIENTE not in (select a.CODIGOCLIENTE 
												from CLI_ClientePersona a with(nolock))
				)	
	print ''Tabla CLI_clientes no se ajusta a la integridad referencial con CLI_ClientePersona ''
	else
	print ''Comprobación OK.Tabla CLI_clientes con CLI_ClientePersona ''

	if exists (select a.NUMEROPERSONAFISICA 
				from CLI_PERSONASFISICAS a with(nolock) 
				where a.NUMEROPERSONAFISICA not in (select b.numeropersona 
													from CLI_ClientePersona b with(nolock))
				)	
	print ''Tabla CLI_PERSONASFISICAS no se ajusta a la integridad referencial con CLI_ClientePersona ''
	else
	print ''Comprobación OK.Tabla CLI_PERSONASFISICAS con CLI_ClientePersona ''
	---------------------------------------------------------------------------------------------------
	print ''--------------------PASIVAS---------------------''
	print ''------------------------------------------------''

	if exists (	select a.CODIGO_TRANSACCION 
				from TTR_CODIGO_TRANSACCION_DEF a with(nolock)
				where a.CODIGO_TRANSACCION not in (	select b.CODIGO_TRANSACCION 
													from CODIGO_TRANSACCIONES b with(nolock))

				)	
	print ''Tabla TTR_CODIGO_TRANSACCION_DEF no se ajusta a la integridad referencial con CODIGO_TRANSACCIONES ''
	else
	print ''Comprobación OK. Tabla TTR_CODIGO_TRANSACCION_DEF con CODIGO_TRANSACCIONES ''

	if exists (	select b.COD_TRANSACCION 
				from MOVIMIENTOS_CONTABLES b with(nolock) 
				where b.COD_TRANSACCION not in( select a.CODIGO_TRANSACCION 
										from codigo_transacciones a with(nolock))

				)	
	print ''Tabla MOVIMIENTOS_CONTABLES no se ajusta a la integridad referencial con codigo_transacciones ''
	else
	print ''Comprobación OK. Tabla MOVIMIENTOS_CONTABLES con codigo_transacciones''

	if exists (	select a.ASIENTO 
				from ASIENTOS a with(nolock)
				where a.ASIENTO not in (select b.ASIENTO 
										from MOVIMIENTOS_CONTABLES b with(nolock))
				)	
	print ''Tabla ASIENTOS no se ajusta a la integridad referencial con MOVIMIENTOS_CONTABLES ''
	else
	print ''Comprobación OK. Tabla ASIENTOS con MOVIMIENTOS_CONTABLES ''

	if exists (	select a.SUCURSAL 
				from SUCURSALESSC a with(nolock)
				where a.SUCURSAL not in (select b.SUCURSAL 
										from SUCURSALES b with(nolock))
				)	
	print ''Tabla SUCURSALESSC no se ajusta a la integridad referencial con SUCURSALES ''
	else
	print ''Comprobación OK. Tabla SUCURSALESSC con SUCURSALES ''

	if exists (	select a.SUCURSAL 
				from TABLA_CAJAS a with(nolock)
				where a.SUCURSAL not in (select b.SUCURSAL 
										from SUCURSALES b with(nolock))
				)	
	print ''Tabla TABLA_CAJAS no se ajusta a la integridad referencial con SUCURSALES ''
	else
	print ''Comprobación OK. Tabla TABLA_CAJAS con SUCURSALES ''

	if exists (	select a.NROCAJA 
				from SALDOSCAJA a with(nolock)
				where a.NROCAJA not in (select b.NRO_CAJA 
										from TABLA_CAJAS b with(nolock))
				)	
	print ''Tabla SALDOSCAJA no se ajusta a la integridad referencial con TABLA_CAJAS ''
	else
	print ''Comprobación OK. Tabla SALDOSCAJA con TABLA_CAJAS ''

	if exists (	select a.MONEDA 
				from SALDOSCAJA a with(nolock)
				where a.MONEDA not in (	select c2622 
										from  MONEDAS b with(nolock))
				)	
	print ''Tabla SALDOSCAJA no se ajusta a la integridad referencial con MONEDAS ''
	else
	print ''Comprobación OK. Tabla SALDOSCAJA con MONEDAS ''

	if exists (	select a.COMERCIALIZADORA 
				from SOLICAPERTCTAVISTA a with(nolock)
				where a.COMERCIALIZADORA not in (select b.ID 
												from VTA_COMERCIALIZADORAS b with(nolock))

				)	
	print ''Tabla SOLICAPERTCTAVISTA no se ajusta a la integridad referencial con VTA_COMERCIALIZADORAS ''
	else
	print ''Comprobación OK. Tabla SOLICAPERTCTAVISTA con VTA_COMERCIALIZADORAS ''

	if exists (	select a.CODIGORANGOPAGO 
				from VTA_DEFINICION_VISTA a with(nolock)
				where a.CODIGORANGOPAGO not in (select b.CODIGORANGO 
												from VTA_DEFINICION_TASAS b with(nolock))
				)	
	print ''Tabla VTA_DEFINICION_VISTA no se ajusta a la integridad referencial con VTA_DEFINICION_TASAS ''
	else
	print ''Comprobación OK. Tabla VTA_DEFINICION_VISTA con VTA_DEFINICION_TASAS ''

	if exists (	select a.CODIGOTASABASE 
				from VTA_DEFINICION_TASAS a with(nolock)
				where a.CODIGOTASABASE not in (	select b.TIPOTASABASE 
												from TASASBASE b with(nolock))
				)	
	print ''Tabla VTA_DEFINICION_TASAS no se ajusta a la integridad referencial con TASASBASE ''
	else
	print ''Comprobación OK. Tabla VTA_DEFINICION_TASAS con TASASBASE ''

	if exists (	select a.CODIGORANGO 
				from VTA_DEFINICION_TASAS a with(nolock)
				where a.CODIGORANGO not in (select b.CODIGORANGO 
											from VTA_RANGOS_TASAS b with(nolock))
				)	
	print ''Tabla VTA_DEFINICION_TASAS no se ajusta a la integridad referencial con VTA_RANGOS_TASAS ''
	else
	print ''Comprobación OK. Tabla VTA_DEFINICION_TASAS con VTA_RANGOS_TASAS ''

	if exists (select a.CUENTA  
				from SALDOS a with(nolock)
				where a.CUENTA not in (	select b.C6301 
										from PLANCTAS b with(nolock))
				)	
	print ''Tabla SALDOS no se ajusta a la integridad referencial con PLANCTAS ''
	else
	print ''Comprobación OK.Tabla SALDOS con PLANCTAS ''

	if exists (	select a.JTS_OID 
				from saldos a with(nolock)
				where a.JTS_OID not in (select b.saldos_jts_oid 
										from GRL_SALDOS_DIARIOS b with(nolock))
				)	
	print ''Tabla saldos no se ajusta a la integridad referencial con GRL_SALDOS_DIARIOS ''
	else
	print ''Comprobación OK. Tabla saldos con GRL_SALDOS_DIARIOS ''

	if exists (	select b.SALDO_JTS_OID 
				from CI_SOLICITUD b  with(nolock)
				where b.SALDO_JTS_OID not in(select a.JTS_OID 
												from SALDOS a  with(nolock))
				)	
	print ''Tabla CI_SOLICITUD no se ajusta a la integridad referencial con SALDOS ''
	else
	print ''Comprobación OK.Tabla CI_SOLICITUD con SALDOS ''


	if exists (	select a.JTS_OID 
				from SALDOS a  with(nolock) 
				where a.JTS_OID not in(	select b.SALDO_JTS_OID 
										from GRL_BLOQUEOS b  with(nolock))
				)	
	print ''Tabla SALDOS no se ajusta a la integridad referencial con GRL_BLOQUEOS ''
	else
	print ''Comprobación OK. Tabla SALDOS con GRL_BLOQUEOS ''

	if exists (	select b.JTS_OID_SALDO 
				from VTA_SALDOS b  with(nolock) 
				where b.JTS_OID_SALDO not in (	select a.JTS_OID 
												from SALDOS a with(nolock))
				)	
	print ''Tabla VTA_SALDOS no se ajusta a la integridad referencial con SALDOS ''
	else
	print ''Comprobación OK. Tabla VTA_SALDOS con SALDOS ''

	if exists (select b.SALDO_JTS_OID 
				from CV_CANCELACION_CUENTAS b  with(nolock)  
				where b.SALDO_JTS_OID not in (	select a.JTS_OID 
												from SALDOS a  with(nolock))
				)	
	print ''Tabla CV_CANCELACION_CUENTAS no se ajusta a la integridad referencial con SALDOS ''
	else
	print ''Comprobación OK. Tabla CV_CANCELACION_CUENTAS con SALDOS ''

	if exists (select a.CODIGO_MOTIVO 
				from CV_MOTIVOS_CANCELACION a  with(nolock) 
				where a.CODIGO_MOTIVO not in (	select b.CODIGO_MOTIVO 
												from CV_CANCELACION_CUENTAS b  with(nolock))
				)	
	print ''Tabla CV_MOTIVOS_CANCELACION no se ajusta a la integridad referencial con CV_CANCELACION_CUENTAS ''
	else
	print ''Comprobación OK.Tabla CV_MOTIVOS_CANCELACION con CV_CANCELACION_CUENTAS ''

	if exists (SELECT a.CANAL 
				FROM PROD_RELCANALES a with(nolock) 
				WHERE a.CANAL not in (SELECT b.COD_CANAL 
										FROM CLI_CANALES b  with(nolock))
				)	
	print ''Tabla PROD_RELCANALES no se ajusta a la integridad referencial con CLI_CANALES ''
	else
	print ''Comprobación OK.Tabla PROD_RELCANALES con CLI_CANALES ''

	if exists (select a.c6502 
				from CONCEPCONT a with(nolock) 
				where a.c6502 not in (	select b.C6301 
										from PLANCTAS b  with(nolock)) 
				)	
	print ''Tabla CONCEPCONT no se ajusta a la integridad referencial con PLANCTAS ''
	else
	print ''Comprobación OK.Tabla CONCEPCONT con PLANCTAS ''

	if exists (select a.jts_oid_cta_fuente 
				from CV_TRANSFERENCIA a with(nolock) 
				where a.JTS_OID_CTA_FUENTE not in (select b.JTS_OID 
													from SALDOS b  with(nolock))
				)	
	print ''Tabla CV_TRANSFERENCIA no se ajusta a la integridad referencial con SALDOS ''
	else
	print ''Comprobación OK.Tabla CV_TRANSFERENCIA con SALDOS ''

	if exists (select a.SALDO_JTS_OID 
				from VTA_RESERVAS a with(nolock) 
				where a.TIPO_RESERVA= 1 
					and a.SALDO_JTS_OID not in (select b.SALDO_JTS_OID 
												from CI_SOLICITUD b  with(nolock))
				)	
	print ''Tabla VTA_RESERVAS no se ajusta a la integridad referencial con CI_SOLICITUD ''
	else
	print ''Comprobación OK.Tabla VTA_RESERVAS con CI_SOLICITUD ''

	if exists (select b.TIPO_RESERVA 
				from VTA_RESERVAS b with(nolock) 
				where B.TIPO_RESERVA not in (select a.TIPO 
											from VTA_TIPO_RESERVAS a  with(nolock))
				)	
	print ''Tabla VTA_RESERVAS no se ajusta a la integridad referencial con VTA_TIPO_RESERVAS ''
	else
	print ''Comprobación OK.Tabla VTA_RESERVAS con VTA_TIPO_RESERVAS ''

	if exists (select a.COD_BLOQUEO 
				from GRL_REL_BLOQUEO_SEGURIDAD a with(nolock) 
				where a.COD_BLOQUEO not in (select b.COD_BLOQUEO 
											from GRL_COD_BLOQUEOS b  with(nolock))
				)	
	print ''Tabla GRL_REL_BLOQUEO_SEGURIDAD no se ajusta a la integridad referencial con GRL_COD_BLOQUEOS ''
	else
	print ''Comprobación OK.Tabla GRL_REL_BLOQUEO_SEGURIDAD con GRL_COD_BLOQUEOS ''

	if exists (select b.segmento 
				from PROD_RELSEGMENTOS b with(nolock) 
				where b.SEGMENTO not in(select a.COD_SEGMENTO 
										from CLI_SEGMENTOS a with(nolock))
				)	
	print ''Tabla PROD_RELSEGMENTOS no se ajusta a la integridad referencial con CLI_SEGMENTOS ''
	else
	print ''Comprobación OK.Tabla PROD_RELSEGMENTOS con CLI_SEGMENTOS ''

	if exists (select b.TARJETA 
				from PROD_RELTARJETAS b with(nolock) 
				where b.tarjeta not in (select a.TIPO_TARJETA 
										from TJD_TIPO_TARJETA a with(nolock))
				)	
	print ''Tabla PROD_RELTARJETAS no se ajusta a la integridad referencial con TJD_TIPO_TARJETA ''
	else
	print ''Comprobación OK.Tabla PROD_RELTARJETAS con TJD_TIPO_TARJETA ''

	if exists (select a.sector 
				from PROD_RELSECTORES a with(nolock) 
				where a.sector not in( select b.SECTOR 
										from CLI_SECtores b with(nolock))
				)	
	print ''Tabla PROD_RELSECTORES no se ajusta a la integridad referencial con CLI_SECtores ''
	else
	print ''Comprobación OK.Tabla PROD_RELSECTORES con CLI_SECtores ''

	if exists (select a.CODAPODERAMIENTO 
				from PYF_APODERAMIENTO a with(nolock) 
				where a.CODAPODERAMIENTO not in (select b.CODAPODERAMIENTO 
												from PYF_TIPOAPODERAMIENTO b with(nolock))
				)	
	print ''Tabla PYF_APODERAMIENTO no se ajusta a la integridad referencial con PYF_TIPOAPODERAMIENTO ''
	else
	print ''Comprobación OK.Tabla PYF_APODERAMIENTO con PYF_TIPOAPODERAMIENTO ''

	if exists (select a.TIPO_PODER 
				from PYF_TIPOPODER_X_TIPOENTIDAD a with(nolock) 
				where a.TIPO_PODER not in( select b.TIPO_PODER 
											from PYF_TIPOPODERES b with(nolock))
				)	
	print ''Tabla PYF_TIPOPODER_X_TIPOENTIDAD no se ajusta a la integridad referencial con PYF_TIPOPODERES ''
	else
	print ''Comprobación OK. Tabla PYF_TIPOPODER_X_TIPOENTIDAD con PYF_TIPOPODERES ''

	if exists (select a.TIPO_ENTIDAD 
				from PYF_TIPOPODER_X_TIPOENTIDAD a with(nolock) 
				where a.TIPO_ENTIDAD not in( select b.TIPO_ENTIDAD 
											from PYF_TIPOENTIDAD b with(nolock))
				)	
	print ''Tabla PYF_TIPOPODER_X_TIPOENTIDAD no se ajusta a la integridad referencial con PYF_TIPOENTIDAD ''
	else
	print ''Comprobación OK.Tabla PYF_TIPOPODER_X_TIPOENTIDAD con PYF_TIPOENTIDAD ''

	if exists (select a.COD_PAQUETE 
				from CLI_PAQUETE_PRODUCTOS a with(nolock) 
				where a.cod_paquete not in (select b.COD_PAQUETE 
											from CLI_PAQUETES b with(nolock))
				)	
	print ''Tabla CLI_PAQUETE_PRODUCTOS no se ajusta a la integridad referencial con CLI_PAQUETES ''
	else
	print ''Comprobación OK. Tabla PYF_TIPOPODER_X_TIPOENTIDAD con PYF_TIPOENTIDAD ''

	if exists (select a.COD_PAQUETE 
				from CLI_CLIENTES_PAQUETES a with(nolock) 
				where a.COD_PAQUETE not in (select b.COD_PAQUETE 
											from CLI_PAQUETES b with(nolock))
				)	
	print ''Tabla CLI_CLIENTES_PAQUETES no se ajusta a la integridad referencial con CLI_PAQUETES ''
	else
	print ''Comprobación OK. Tabla CLI_CLIENTES_PAQUETES con CLI_PAQUETES ''

	if exists (select a.COD_PAQUETE 
				from CLI_PAQUETE_BENEFICIOS a with(nolock) 
				where a.COD_PAQUETE not in (select b.COD_PAQUETE 
											from CLI_PAQUETES b with(nolock))
				)	
	print ''Tabla CLI_PAQUETE_BENEFICIOS no se ajusta a la integridad referencial con CLI_PAQUETES ''
	else
	print ''Comprobación OK.Tabla CLI_PAQUETE_BENEFICIOS con CLI_PAQUETES ''

	if exists (select a.COD_BENEFICIO 
				from CLI_PAQUETE_BENEFICIOS a with(nolock) 
				where a.COD_BENEFICIO not in (select b.cod_beneficio 
											from CLI_BENEFICIOS b with(nolock))
				)	
	print ''Tabla CLI_PAQUETE_BENEFICIOS no se ajusta a la integridad referencial con CLI_BENEFICIOS ''
	else
	print ''Comprobación OK. Tabla CLI_PAQUETE_BENEFICIOS con CLI_BENEFICIOS ''

	if exists (select a.PRODUCTO 
				from VTA_DEFINICION_VISTA a with(nolock) 
				where a.PRODUCTO not in (select b.c6250 
										from PRODUCTOS b with(nolock))
				)	
	print ''Tabla VTA_DEFINICION_VISTA no se ajusta a la integridad referencial con PRODUCTOS ''
	else
	print ''Comprobación OK.Tabla VTA_DEFINICION_VISTA con PRODUCTOS ''
	if exists (select a.MONEDA 
				from TOPESPRODUCTO a with(nolock) 
				where a.MONEDA not in (select b.C6399 
										from monedas b with(nolock))
				)	
	print ''Tabla TOPESPRODUCTO no se ajusta a la integridad referencial con monedas ''
	else
	print ''Comprobación OK.Tabla TOPESPRODUCTO con monedas ''

	if exists (select a.MONEDA 
				from PROD_RELCANALES a with(nolock) 
				where a.MONEDA not in (select b.C6399 
										from monedas b with(nolock))
				)	
	print ''Tabla PROD_RELCANALES no se ajusta a la integridad referencial con monedas ''
	else
	print ''Comprobación OK.Tabla PROD_RELCANALES con monedas ''

	if exists (select a.MONEDA 
				from PROD_RESTRICCIONES a with(nolock) 
				where a.MONEDA not in (select b.C6399 
										from monedas b with(nolock))
				)	
	print ''Tabla PROD_RESTRICCIONES no se ajusta a la integridad referencial con monedas ''
	else
	print ''Comprobación OK. Tabla PROD_RESTRICCIONES con monedas ''

	if exists (select a.CODPRODUCTO 
				from PROD_RESTRICCIONES a with(nolock) 
				where a.CODPRODUCTO not in (select b.c6250 
											from PRODUCTOS b with(nolock))
				)	
	print ''Tabla PROD_RESTRICCIONES no se ajusta a la integridad referencial con PRODUCTOS ''
	else
	print ''Comprobación OK.Tabla PROD_RESTRICCIONES con PRODUCTOS ''

	if exists (select a.PRODUCTO 
				from cli_paquete_productos a with(nolock) 
				where a.PRODUCTO not in (select b.c6250 
										from PRODUCTOS b with(nolock))
				)	
	print ''Tabla cli_paquete_productos no se ajusta a la integridad referencial con PRODUCTOS ''
	else
	print ''Comprobación OK.Tabla cli_paquete_productos con PRODUCTOS ''
	
	if exists (select a.COD_CLIENTE 
				from CLI_CLIENTES_PAQUETES a with(nolock) 
				where a.COD_CLIENTE not in (select b.CODIGOCLIENTE 
											from CLI_clientes b with(nolock))
				)	
	print ''Tabla CLI_CLIENTES_PAQUETES no se ajusta a la integridad referencial con CLI_clientes ''
	else
	print ''Comprobación OK.Tabla CLI_CLIENTES_PAQUETES con CLI_clientes ''
	
	if exists (select a.ID_PERSONA 
				from PYF_APODERADOS a with(nolock) 
				where a.ID_PERSONA not in (select b.NUMEROPERSONAFISICA 
											from CLI_PERSONASFISICAS b with(nolock))
				)	
	print ''Tabla PYF_APODERADOS no se ajusta a la integridad referencial con CLI_PERSONASFISICAS ''
	else
	print ''Comprobación OK.Tabla PYF_APODERADOS con CLI_PERSONASFISICAS ''

	if exists (	select a.CODAPODERAMIENTO
				from PYF_APODERAMIENTO a with(nolock) 
				where a.CODAPODERAMIENTO not in (select b.APODERAMIENTO
											from pyf_apoderados b with(nolock))
			)	
	print ''Tabla PYF_APODERAMIENTO no se ajusta a la integridad referencial con pyf_apoderados ''
	else
	print ''Comprobación OK.Tabla PYF_APODERAMIENTO con pyf_apoderados ''

	if exists (select a.NUMEROPERSONAFISICA 
				from CLI_PERSONAS_FIRMAS a with(nolock) 
				where a.NUMEROPERSONAFISICA not in (select b.numeropersona 
													from CLI_ClientePersona b with(nolock))
				)	
	print ''Tabla CLI_PERSONAS_FIRMAS no se ajusta a la integridad referencial con CLI_ClientePersona ''
	else
	print ''Comprobación OK.Tabla CLI_PERSONAS_FIRMAS con CLI_ClientePersona ''

	if exists (select a.NUMEROPERSONAFISICA 
				from CLI_PERSONAS_FOTOS a with(nolock) 
				where a.NUMEROPERSONAFISICA not in (select b.numeropersona 
													from CLI_ClientePersona b with(nolock))
				)	
	print ''Tabla CLI_PERSONAS_FOTOS no se ajusta a la integridad referencial con CLI_ClientePersona ''
	else
	print ''Comprobación OK.Tabla CLI_PERSONAS_FOTOS con CLI_ClientePersona ''
	
	if exists (select a.NUMEROPERSONAFISICA 
				from CLI_PERSONAS_IMAGEN_DOC a with(nolock) 
				where a.NUMEROPERSONAFISICA not in (select b.numeropersona 
													from CLI_ClientePersona b with(nolock))
				)	
	print ''Tabla CLI_PERSONAS_IMAGEN_DOC no se ajusta a la integridad referencial con CLI_ClientePersona ''
	else
	print ''Comprobación OK. Tabla CLI_PERSONAS_IMAGEN_DOC con CLI_ClientePersona ''
	
	if exists (select a.ESTADO 
				from CHE_CHEQUERAS a with(nolock) 
				where a.ESTADO not in  (select b.CODIGO 
										from CHE_ESTADOSCHEQUERAS b with(nolock))
				)	
	print ''Tabla CHE_CHEQUERAS no se ajusta a la integridad referencial con CHE_ESTADOSCHEQUERAS ''
	else
	print ''Comprobación OK.Tabla CHE_CHEQUERAS con CHE_ESTADOSCHEQUERAS ''
	
	if exists (select a.ESTADO 
				from CHE_CHEQUES a with(nolock) 
				where a.ESTADO not in  (select b.CODIGO 
										from CHE_ESTADOSCHEQUES b with(nolock))
				)	
	print ''Tabla CHE_CHEQUES no se ajusta a la integridad referencial con CHE_ESTADOSCHEQUERAS ''
	else
	print ''Comprobación OK.Tabla CHE_CHEQUES con CHE_ESTADOSCHEQUERAS ''
	
	if exists (	select c.NroSolicitud,c.Sucursal 
				from CHE_CHEQUESIMPRENTA c with(nolock) 
				where not exists
								(select A.NroSolicitud,a.Sucursal
								from CHE_CHEQUESIMPRENTA a with(nolock) 
								inner join Che_CheqSolicitud b with(nolock) on a.NroSolicitud	= b.NroSolicitud
																			and a.Sucursal=b.SUCURSAL)
				)	
	print ''Tabla CHE_CHEQUESIMPRENTA no se ajusta a la integridad referencial con Che_CheqSolicitud ''
	else
	print ''Comprobación OK.Tabla CHE_CHEQUESIMPRENTA con Che_CheqSolicitud ''
	
	if exists (select b.CODIGO_BCRA 
				from CHE_MOTIVOS_RECHAZO b with(nolock) 
				where b.CODIGO_BCRA not in (select a.codigo_motivo_rechazo 
											from CHE_CHEQUESDENUNCIADOS a with(nolock)) 
				)	
	print ''Tabla CHE_MOTIVOS_RECHAZO no se ajusta a la integridad referencial con CHE_CHEQUESDENUNCIADOS ''
	else
	print ''Comprobación OK.Tabla CHE_MOTIVOS_RECHAZO con CHE_CHEQUESDENUNCIADOS ''
	
	if exists (select b.NRO_SOLICITUD 
				from CHE_SOLICITUD_CANJE_INTERNO b  with(nolock)
				left join CHE_CHEQUES a  with(nolock)on a.NRO_SOLICITUD = b.NRO_SOLICITUD
														and a.serie = b.SERIE							
														and a.NUMEROCHEQUE = b.NRO_CHEQUE
				where a.NRO_SOLICITUD is null
						and a.SERIE is null
						and a.NUMEROCHEQUE is null 
				)	
	print ''Tabla CHE_SOLICITUD_CANJE_INTERNO no se ajusta a la integridad referencial con CHE_CHEQUES ''
	else
	print ''Comprobación OK.Tabla CHE_SOLICITUD_CANJE_INTERNO con CHE_CHEQUES ''

	-----------------------------------------------------------------------------------------------------------------------
	if exists (	select a.ASIENTO 
				from asientos a with(nolock)
				where a.asiento not in (select b.asiento 
										from MOVIMIENTOS b with(nolock)) 
			)	
	print ''Tabla asientos no se ajusta a la integridad referencial con MOVIMIENTOS ''
	else
	print ''Comprobación OK.Tabla asientos con MOVIMIENTOS ''

	if exists (	select b.COD_TRANSACCION 
				from MOVIMIENTOS_CONTABLES b with(nolock) 
				where b.COD_TRANSACCION not in( select a.CODIGO_TRANSACCION 
												from codigo_transacciones a with(nolock)) 
			)	
	print ''Tabla MOVIMIENTOS_CONTABLES no se ajusta a la integridad referencial con CODIGO_TRANSACCIONES ''
	else
	print ''Comprobación OK.Tabla MOVIMIENTOS_CONTABLES con CODIGO_TRANSACCIONES ''
	
	if exists (	select a.ASIENTO 
				from ASIENTOS a with(nolock)
				where a.ASIENTO not in (select b.ASIENTO 
										from MOVIMIENTOS_CONTABLES b with(nolock))
			)	
	print ''Tabla ASIENTOS no se ajusta a la integridad referencial con MOVIMIENTOS_CONTABLES ''
	else
	print ''Comprobación OK.Tabla ASIENTOS con MOVIMIENTOS_CONTABLES ''
	
	if exists (	select a.SUCURSAL 
				from SUCURSALESSC a with(nolock)
				where a.SUCURSAL not in (	select b.SUCURSAL 
											from SUCURSALES b with(nolock))
			)	
	print ''Tabla SUCURSALESSC no se ajusta a la integridad referencial con SUCURSALES ''
	else
	print ''Comprobación OK.Tabla SUCURSALESSC con SUCURSALES ''
	
	if exists (	select a.SUCURSAL 
				from TABLA_CAJAS a with(nolock)
				where a.SUCURSAL not in (select b.SUCURSAL 
										from SUCURSALES b with(nolock))
			)	
	print ''Tabla TABLA_CAJAS no se ajusta a la integridad referencial con SUCURSALES ''
	else
	print ''Comprobación OK.Tabla TABLA_CAJAS con SUCURSALES ''
	
	if exists (	select a.NROCAJA 
				from SALDOSCAJA a with(nolock)
				where a.NROCAJA not in (select b.NRO_CAJA 
										from TABLA_CAJAS b with(nolock))
			)	
	print ''Tabla SALDOSCAJA no se ajusta a la integridad referencial con TABLA_CAJAS ''
	else
	print ''Comprobación OK.Tabla SALDOSCAJA con TABLA_CAJAS ''
	
	if exists (	select a.MONEDA 
				from SALDOSCAJA a with(nolock)
				where a.MONEDA not in (	select c2622 
										from  MONEDAS b with(nolock))
			)	
	print ''Tabla SALDOSCAJA no se ajusta a la integridad referencial con MONEDAS ''
	else
	print ''Comprobación OK.Tabla SALDOSCAJA con MONEDAS ''
	
	if exists (	select a.COMERCIALIZADORA 
				from SOLICAPERTCTAVISTA a with(nolock)
				where a.COMERCIALIZADORA not in (	select b.ID 
													from VTA_COMERCIALIZADORAS b with(nolock))
			)	
	print ''Tabla SOLICAPERTCTAVISTA no se ajusta a la integridad referencial con VTA_COMERCIALIZADORAS ''
	else
	print ''Comprobación OK.Tabla SOLICAPERTCTAVISTA con VTA_COMERCIALIZADORAS ''
	
	if exists (	select a.CODIGORANGOPAGO 
				from VTA_DEFINICION_VISTA a with(nolock)
				where a.CODIGORANGOPAGO not in (select b.CODIGORANGO 
												from VTA_DEFINICION_TASAS b with(nolock))
			)	
	print ''Tabla VTA_DEFINICION_VISTA no se ajusta a la integridad referencial con VTA_DEFINICION_TASAS ''
	else
	print ''Comprobación OK.Tabla VTA_DEFINICION_VISTA con VTA_DEFINICION_TASAS ''
	
	if exists (	select a.CODIGOTASABASE 
				from VTA_DEFINICION_TASAS a with(nolock)
				where a.CODIGOTASABASE not in (	select b.TIPOTASABASE 
												from TASASBASE b with(nolock))
			)	
	print ''Tabla VTA_DEFINICION_TASAS no se ajusta a la integridad referencial con TASASBASE ''
	else
	print ''Comprobación OK.Tabla VTA_DEFINICION_TASAS con TASASBASE ''
	
	if exists (	select a.CODIGORANGO 
				from VTA_DEFINICION_TASAS a with(nolock)
				where a.CODIGORANGO not in (select b.CODIGORANGO 
											from VTA_RANGOS_TASAS b with(nolock))
			)	
	print ''Tabla VTA_DEFINICION_TASAS no se ajusta a la integridad referencial con VTA_RANGOS_TASAS ''
	else
	print ''Comprobación OK.Tabla VTA_DEFINICION_TASAS con VTA_RANGOS_TASAS ''
	
	if exists (	select a.CUENTA  
				from SALDOS a with(nolock)
				where a.CUENTA not in (select b.C6301 
										from PLANCTAS b with(nolock))
			)	
	print ''Tabla CUENTA no se ajusta a la integridad referencial con PLANCTAS ''
	else
	print ''Comprobación OK.Tabla CUENTA con PLANCTAS ''
	
	if exists (	select a.JTS_OID 
				from saldos a with(nolock)
				where a.JTS_OID not in (select b.saldos_jts_oid 
										from GRL_SALDOS_DIARIOS b with(nolock))
			)	
	print ''Tabla saldos no se ajusta a la integridad referencial con GRL_SALDOS_DIARIOS ''
	else
	print ''Comprobación OK.Tabla saldos con GRL_SALDOS_DIARIOS ''
	
	if exists (	select b.SALDO_JTS_OID 
				from CI_SOLICITUD b with(nolock) 
				where b.SALDO_JTS_OID not in(select a.JTS_OID 
											from SALDOS a with(nolock))
			)	
	print ''Tabla CI_SOLICITUD no se ajusta a la integridad referencial con SALDOS ''
	else
	print ''Comprobación OK.Tabla CI_SOLICITUD con SALDOS ''
	
	if exists (	select a.JTS_OID 
				from SALDOS a with(nolock) 
				where a.JTS_OID not in(	select b.SALDO_JTS_OID 
										from GRL_BLOQUEOS b with(nolock) )
			)	
	print ''Tabla SALDOS no se ajusta a la integridad referencial con GRL_BLOQUEOS ''
	else
	print ''Comprobación OK.Tabla SALDOS con GRL_BLOQUEOS ''
	
	if exists (	select b.JTS_OID_SALDO 
				from VTA_SALDOS b with(nolock)  
				where b.JTS_OID_SALDO not in (	select a.JTS_OID 
												from SALDOS a with(nolock))
			)	
	print ''Tabla VTA_SALDOS no se ajusta a la integridad referencial con SALDOS ''
	else
	print ''Comprobación OK.Tabla VTA_SALDOS con SALDOS ''
	
	if exists (	select b.SALDO_JTS_OID 
				from CV_CANCELACION_CUENTAS b with(nolock)  
				where b.SALDO_JTS_OID not in (	select a.JTS_OID 
												from SALDOS a with(nolock))
			)	
	print ''Tabla CV_CANCELACION_CUENTAS no se ajusta a la integridad referencial con SALDOS ''
	else
	print ''Comprobación OK.Tabla CV_CANCELACION_CUENTAS con SALDOS ''
	
	if exists (	select a.CODIGO_MOTIVO 
				from CV_MOTIVOS_CANCELACION a with(nolock) 
				where a.CODIGO_MOTIVO not in (	select b.CODIGO_MOTIVO 
												from CV_CANCELACION_CUENTAS b with(nolock))
			)	
	print ''Tabla CV_MOTIVOS_CANCELACION no se ajusta a la integridad referencial con CV_CANCELACION_CUENTAS ''
	else
	print ''Comprobación OK.Tabla CV_MOTIVOS_CANCELACION con CV_CANCELACION_CUENTAS ''
	
	if exists (	select a.COD_BLOQUEO 
				from GRL_REL_BLOQUEO_SEGURIDAD a with(nolock) 
				where a.COD_BLOQUEO not in (select b.COD_BLOQUEO 
											from GRL_COD_BLOQUEOS b with(nolock))
			)	
	print ''Tabla GRL_REL_BLOQUEO_SEGURIDAD no se ajusta a la integridad referencial con GRL_COD_BLOQUEOS ''
	else
	print ''Comprobación OK.Tabla GRL_REL_BLOQUEO_SEGURIDAD con GRL_COD_BLOQUEOS ''
	
	if exists (	select b.TIPO_RESERVA 
				from VTA_RESERVAS b with(nolock) 
				where B.TIPO_RESERVA not in (	select a.TIPO 
												from VTA_TIPO_RESERVAS a with(nolock))
			)	
	print ''Tabla VTA_RESERVAS no se ajusta a la integridad referencial con VTA_TIPO_RESERVAS ''
	else
	print ''Comprobación OK.Tabla VTA_RESERVAS con VTA_TIPO_RESERVAS ''
	
	if exists (	select a.SALDO_JTS_OID 
				from VTA_RESERVAS a with(nolock) 
				where a.SALDO_JTS_OID not in (	select b.SALDO_JTS_OID 
												from CI_SOLICITUD b with(nolock))
			)	
	print ''Tabla VTA_RESERVAS no se ajusta a la integridad referencial con CI_SOLICITUD ''
	else
	print ''Comprobación OK.Tabla VTA_RESERVAS con CI_SOLICITUD ''
	
	if exists (	select a.jts_oid_cta_fuente 
				from CV_TRANSFERENCIA a with(nolock) 
				where a.JTS_OID_CTA_FUENTE not in (	select b.JTS_OID 
													from SALDOS b with(nolock))
			)	
	print ''Tabla CV_TRANSFERENCIA no se ajusta a la integridad referencial con SALDOS ''
	else
	print ''Comprobación OK.Tabla CV_TRANSFERENCIA con SALDOS ''
	
	if exists (	select a.c6502 
				from CONCEPCONT a with(nolock) 
				where a.c6502 not in (	select b.C6301 
										from PLANCTAS b with(nolock))
			)	
	print ''Tabla CONCEPCONT no se ajusta a la integridad referencial con PLANCTAS ''
	else
	print ''Comprobación OK.Tabla CONCEPCONT con PLANCTAS ''
	
	if exists (	SELECT a.CANAL 
				FROM PROD_RELCANALES a with(nolock) 
				WHERE a.CANAL not in (	SELECT b.COD_CANAL 
										FROM CLI_CANALES b with(nolock))
			)	
	print ''Tabla PROD_RELCANALES no se ajusta a la integridad referencial con CLI_CANALES ''
	else
	print ''Comprobación OK.Tabla PROD_RELCANALES con CLI_CANALES ''
	
	if exists (	select b.segmento 
				from PROD_RELSEGMENTOS b with(nolock) 
				where b.SEGMENTO not in(select a.COD_SEGMENTO 
										from CLI_SEGMENTOS a with(nolock))
			)	
	print ''Tabla PROD_RELSEGMENTOS no se ajusta a la integridad referencial con CLI_SEGMENTOS ''
	else
	print ''Comprobación OK.Tabla PROD_RELSEGMENTOS con CLI_SEGMENTOS ''
	
	if exists (	select b.TARJETA 
				from PROD_RELTARJETAS b with(nolock) 
				where b.tarjeta not in (select a.TIPO_TARJETA 
										from TJD_TIPO_TARJETA a with(nolock))
			)	
	print ''Tabla PROD_RELTARJETAS no se ajusta a la integridad referencial con TJD_TIPO_TARJETA ''
	else
	print ''Comprobación OK.Tabla PROD_RELTARJETAS con TJD_TIPO_TARJETA ''
	
	if exists (	select a.sector 
				from PROD_RELSECTORES a with(nolock) 
				where a.sector not in(	select b.SECTOR 
										from CLI_SECtores b with(nolock))
			)	
	print ''Tabla PROD_RELSECTORES no se ajusta a la integridad referencial con CLI_SECtores ''
	else
	print ''Comprobación OK.Tabla PROD_RELSECTORES con CLI_SECtores ''
	
	if exists (	select a.CODAPODERAMIENTO 
				from PYF_APODERAMIENTO a with(nolock) 
				where a.CODAPODERAMIENTO not in (	select b.CODAPODERAMIENTO 
													from PYF_TIPOAPODERAMIENTO b with(nolock))
			)	
	print ''Tabla PYF_APODERAMIENTO no se ajusta a la integridad referencial con PYF_TIPOAPODERAMIENTO ''
	else
	print ''Comprobación OK.Tabla PYF_APODERAMIENTO con PYF_TIPOAPODERAMIENTO ''
	
	if exists (	select a.TIPO_PODER 
				from PYF_TIPOPODER_X_TIPOENTIDAD a with(nolock) 
				where a.TIPO_PODER not in( select b.TIPO_PODER 
											from PYF_TIPOPODERES b with(nolock))
			)	
	print ''Tabla PYF_TIPOPODER_X_TIPOENTIDAD no se ajusta a la integridad referencial con PYF_TIPOPODERES ''
	else
	print ''Comprobación OK.Tabla PYF_TIPOPODER_X_TIPOENTIDAD con PYF_TIPOPODERES ''
	
	if exists (	select a.TIPO_ENTIDAD 
				from PYF_TIPOPODER_X_TIPOENTIDAD a with(nolock) 
				where a.TIPO_ENTIDAD not in( select b.TIPO_ENTIDAD 
											from PYF_TIPOENTIDAD b with(nolock))
			)	
	print ''Tabla PYF_TIPOPODER_X_TIPOENTIDAD no se ajusta a la integridad referencial con PYF_TIPOENTIDAD ''
	else
	print ''Comprobación OK.Tabla PYF_TIPOPODER_X_TIPOENTIDAD con PYF_TIPOENTIDAD ''
	
	if exists (	select a.COD_PAQUETE 
				from CLI_PAQUETE_PRODUCTOS a with(nolock) 
				where a.cod_paquete not in (select b.COD_PAQUETE 
											from CLI_PAQUETES b with(nolock))
			)	
	print ''Tabla CLI_PAQUETE_PRODUCTOS no se ajusta a la integridad referencial con CLI_PAQUETES ''
	else
	print ''Comprobación OK.Tabla CLI_PAQUETE_PRODUCTOS con CLI_PAQUETES ''

	if exists (	select a.COD_PAQUETE 
				from CLI_PAQUETE_BENEFICIOS a with(nolock) 
				where a.COD_PAQUETE not in (select b.COD_PAQUETE 
											from CLI_PAQUETES b with(nolock))
			)	
	print ''Tabla CLI_PAQUETE_BENEFICIOS no se ajusta a la integridad referencial con CLI_PAQUETES ''
	else
	print ''Comprobación OK.Tabla CLI_PAQUETE_BENEFICIOS con CLI_PAQUETES ''
	
	if exists (	select a.COD_BENEFICIO 
				from CLI_PAQUETE_BENEFICIOS a with(nolock) 
				where a.COD_BENEFICIO not in (select b.cod_beneficio 
												from CLI_BENEFICIOS b with(nolock))
			)	
	print ''Tabla CLI_PAQUETE_BENEFICIOS no se ajusta a la integridad referencial con CLI_BENEFICIOS ''
	else
	print ''Comprobación OK.Tabla CLI_PAQUETE_BENEFICIOS con CLI_BENEFICIOS ''
	
	if exists (	select a.PRODUCTO 
				from VTA_DEFINICION_VISTA a with(nolock) 
				where a.PRODUCTO not in (select b.c6250 
										from PRODUCTOS b with(nolock))
			)	
	print ''Tabla VTA_DEFINICION_VISTA no se ajusta a la integridad referencial con PRODUCTOS ''
	else
	print ''Comprobación OK.Tabla VTA_DEFINICION_VISTA con PRODUCTOS ''
	
	if exists (	select a.MONEDA 
				from TOPESPRODUCTO a with(nolock) 
				where a.MONEDA not in (	select b.C6399 
										from monedas b with(nolock))
			)	
	print ''Tabla TOPESPRODUCTO no se ajusta a la integridad referencial con monedas ''
	else
	print ''Comprobación OK.Tabla TOPESPRODUCTO con monedas ''
	
	if exists (	select a.MONEDA 
				from PROD_RELCANALES a with(nolock) 
				where a.MONEDA not in (select b.C6399 
										from monedas b with(nolock))
			)	
	print ''Tabla PROD_RELCANALES no se ajusta a la integridad referencial con monedas ''
	else
	print ''Comprobación OK.Tabla PROD_RELCANALES con monedas ''
	
	if exists (	select a.MONEDA 
				from PROD_RESTRICCIONES a with(nolock) 
				where a.MONEDA not in (	select b.C6399 
										from monedas b with(nolock))
			)	
	print ''Tabla PROD_RESTRICCIONES no se ajusta a la integridad referencial con monedas ''
	else
	print ''Comprobación OK.Tabla PROD_RESTRICCIONES con monedas ''
	
	if exists (	select a.CODPRODUCTO 
				from PROD_RESTRICCIONES a with(nolock) 
				where a.CODPRODUCTO not in (select b.c6250 
											from PRODUCTOS b with(nolock))
			)	
	print ''Tabla PROD_RESTRICCIONES no se ajusta a la integridad referencial con PRODUCTOS ''
	else
	print ''Comprobación OK.Tabla PROD_RESTRICCIONES con PRODUCTOS ''
	
	if exists (	select a.PRODUCTO 
				from cli_paquete_productos a with(nolock) 
				where a.PRODUCTO not in (select b.c6250 
										from PRODUCTOS b with(nolock))
			)	
	print ''Tabla cli_paquete_productos no se ajusta a la integridad referencial con PRODUCTOS ''
	else
	print ''Comprobación OK.Tabla cli_paquete_productos con PRODUCTOS ''
	
	if exists (	select a.COD_CLIENTE 
				from CLI_CLIENTES_PAQUETES a with(nolock) 
				where a.COD_CLIENTE not in (select b.CODIGOCLIENTE 
											from CLI_clientes b with(nolock))
			)	
	print ''Tabla CLI_CLIENTES_PAQUETES no se ajusta a la integridad referencial con CLI_clientes ''
	else
	print ''Comprobación OK.Tabla CLI_CLIENTES_PAQUETES con CLI_clientes ''
	
	if exists (	select a.ID_PERSONA 
				from PYF_APODERADOS a with(nolock) 
				where a.ID_PERSONA not in (select b.NUMEROPERSONAFISICA 
											from CLI_PERSONASFISICAS b with(nolock))
			)	
	print ''Tabla PYF_APODERADOS no se ajusta a la integridad referencial con CLI_PERSONASFISICAS ''
	else
	print ''Comprobación OK.Tabla PYF_APODERADOS con CLI_PERSONASFISICAS ''
	
	if exists (	select a.CODIGOCLIENTE 
				from CLI_ClientePersona a with(nolock) 
				where a.CODIGOCLIENTE not in (	select b.CODIGOCLIENTE 
												from CLI_clientes b with(nolock))
			)	
	print ''Tabla CLI_ClientePersona no se ajusta a la integridad referencial con CLI_clientes ''
	else
	print ''Comprobación OK.Tabla CLI_ClientePersona con CLI_clientes ''
	
	if exists (	select b.CODIGOCLIENTE 
				from CLI_clientes b with(nolock) 
				where b.CODIGOCLIENTE not in (	select a.CODIGOCLIENTE 
												from CLI_ClientePersona a with(nolock))
			)	
	print ''Tabla CLI_clientes no se ajusta a la integridad referencial con CLI_ClientePersona ''
	else
	print ''Comprobación OK.Tabla CLI_clientes con CLI_ClientePersona ''
	
	if exists (	select a.NUMEROPERSONAFISICA 
				from CLI_PERSONASFISICAS a with(nolock) 
				where a.NUMEROPERSONAFISICA not in (select b.numeropersona 
													from CLI_ClientePersona b with(nolock))
			)	
	print ''Tabla CLI_PERSONASFISICAS no se ajusta a la integridad referencial con CLI_ClientePersona ''
	else
	print ''Comprobación OK.Tabla CLI_PERSONASFISICAS con CLI_ClientePersona ''
	
	if exists (	select a.NUMEROPERSONAFISICA 
				from CLI_PERSONAS_FIRMAS a with(nolock) 
				where a.NUMEROPERSONAFISICA not in (select b.numeropersona 
													from CLI_ClientePersona b with(nolock))
			)	
	print ''Tabla CLI_PERSONAS_FIRMAS no se ajusta a la integridad referencial con CLI_ClientePersona ''
	else
	print ''Comprobación OK.Tabla CLI_PERSONAS_FIRMAS con CLI_ClientePersona ''
	
	if exists (	select a.NUMEROPERSONAFISICA 
				from CLI_PERSONAS_FOTOS a with(nolock) 
				where a.NUMEROPERSONAFISICA not in (select b.numeropersona 
													from CLI_ClientePersona b with(nolock))
			)	
	print ''Tabla CLI_PERSONAS_FOTOS no se ajusta a la integridad referencial con CLI_ClientePersona ''
	else
	print ''Comprobación OK.Tabla CLI_PERSONAS_FOTOS con CLI_ClientePersona ''
	
	if exists (	select a.NUMEROPERSONAFISICA 
				from CLI_PERSONAS_IMAGEN_DOC a with(nolock) 
				where a.NUMEROPERSONAFISICA not in (select b.numeropersona 
													from CLI_ClientePersona b with(nolock))
			)	
	print ''Tabla CLI_PERSONAS_IMAGEN_DOC no se ajusta a la integridad referencial con CLI_ClientePersona ''
	else
	print ''Comprobación OK.Tabla CLI_PERSONAS_IMAGEN_DOC con CLI_ClientePersona ''
	
	if exists (	select a.ESTADO 
				from CHE_CHEQUERAS a with(nolock) 
				where a.ESTADO not in  (select b.CODIGO 
										from CHE_ESTADOSCHEQUERAS b with(nolock))
			)	
	print ''Tabla CHE_CHEQUERAS no se ajusta a la integridad referencial con CHE_ESTADOSCHEQUERAS ''
	else
	print ''Comprobación OK.Tabla CHE_CHEQUERAS con CHE_ESTADOSCHEQUERAS ''
	
	if exists (	select a.ESTADO 
				from CHE_CHEQUES a with(nolock) 
				where a.ESTADO not in  (select b.CODIGO 
										from CHE_ESTADOSCHEQUES b with(nolock))
			)	
	print ''Tabla CHE_CHEQUES no se ajusta a la integridad referencial con CHE_ESTADOSCHEQUES ''
	else
	print ''Comprobación OK.Tabla CHE_CHEQUES con CHE_ESTADOSCHEQUES ''
	
	if exists (	select c.NroSolicitud,c.Sucursal 
				from CHE_CHEQUESIMPRENTA c with(nolock) 
				where not exists
								(select A.NroSolicitud,a.Sucursal
								from CHE_CHEQUESIMPRENTA a with(nolock) 
								inner join Che_CheqSolicitud b with(nolock) on a.NroSolicitud	= b.NroSolicitud
																and a.Sucursal=b.SUCURSAL)
			)	
	print ''Tabla CHE_CHEQUESIMPRENTA no se ajusta a la integridad referencial con Che_CheqSolicitud ''
	else
	print ''Comprobación OK.Tabla CHE_CHEQUESIMPRENTA con Che_CheqSolicitud ''

	if exists (	select b.CODIGO_BCRA 
				from CHE_MOTIVOS_RECHAZO b with(nolock) 
				where b.CODIGO_BCRA not in (select a.codigo_motivo_rechazo 
											from CHE_CHEQUESDENUNCIADOS a with(nolock)) 
			)	
	print ''Tabla CHE_MOTIVOS_RECHAZO no se ajusta a la integridad referencial con CHE_CHEQUESDENUNCIADOS ''
	else
	print ''Comprobación OK.Tabla CHE_MOTIVOS_RECHAZO con CHE_CHEQUESDENUNCIADOS ''
	
	if exists (	select b.* 
				from CHE_SOLICITUD_CANJE_INTERNO b with(nolock) 
				left join CHE_CHEQUES a with(nolock) on a.NRO_SOLICITUD = b.NRO_SOLICITUD
											and a.serie = b.SERIE							
											and a.NUMEROCHEQUE = b.NRO_CHEQUE
				where a.NRO_SOLICITUD is null
						and a.SERIE is null
						and a.NUMEROCHEQUE is null 
			)	
	print ''Tabla CHE_SOLICITUD_CANJE_INTERNO no se ajusta a la integridad referencial con CHE_CHEQUES ''
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
	print ''Tabla Che_Cheques no se ajusta a la integridad referencial con SALDOS ''
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
	print ''Tabla Che_Chequeras no se ajusta a la integridad referencial con SALDOS ''
	else
	print ''Comprobación OK.Tabla Che_Chequeras con SALDOS ''

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
	print ''Tabla Che_CheqSolicitud no se ajusta a la integridad referencial con SALDOS ''
	else
	print ''Comprobación OK.Tabla Che_CheqSolicitud con SALDOS ''

	if exists (	select c.Cuenta
				from vta_cuentas_secretas c with(nolock) 
				where c.Cuenta not in(
										select a.CUENTA
										from SALDOS a with(nolock) 
										inner join vta_cuentas_secretas b with(nolock) on
											b.sucursal = a.SUCURSAL 
											and b.cuenta = a.CUENTA 
											and b.Moneda = a.MONEDA 
											and b.Operacion = a.OPERACION
											and b.ordinal = a.ORDINAL
											and b.Producto = a.PRODUCTO)
			)	
	print ''Tabla vta_cuentas_secretas no se ajusta a la integridad referencial con SALDOS ''
	else
	print ''Comprobación OK.Tabla vta_cuentas_secretas con SALDOS ''

	if exists (	select c.CUENTA
				from GRL_ESTADOS_DE_CUENTA c with(nolock) 
				where c.CUENTA not in(
									select a.CUENTA 
									from SALDOS a with(nolock) 
									inner join GRL_ESTADOS_DE_CUENTA b with(nolock) on
										b.sucursal = a.SUCURSAL 
										and b.Moneda = a.MONEDA 
										and b.Operacion = a.OPERACION
										and b.ordinal = a.ORDINAL
										and b.Producto = a.PRODUCTO
										and b.CUENTA = a.CUENTA)
			)	
	print ''Tabla GRL_ESTADOS_DE_CUENTA no se ajusta a la integridad referencial con SALDOS ''
	else
	print ''Comprobación OK.Tabla GRL_ESTADOS_DE_CUENTA con SALDOS''

	------------------------------------------------------------------------------------------------------------------------------------------
	if exists (	select b.CUENTA
				from che_cheques b with(nolock) 
				left join che_chequeras a with(nolock) 
				on a.sucursal = b.SUCURSAL
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
	print ''Tabla che_cheques no se ajusta a la integridad referencial con che_chequeras ''
	else
	print ''Comprobación OK.Tabla che_cheques con che_chequeras ''

	if exists (	select b.CUENTA 
				from CHE_CHEQUESDENUNCIADOS b with(nolock) 
				left join che_cheques a with(nolock) 
				on a.sucursal = b.SUCURSAL
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
	print ''Tabla CHE_CHEQUESDENUNCIADOS no se ajusta a la integridad referencial con che_cheques ''
	else
	print ''Comprobación OK.Tabla CHE_CHEQUESDENUNCIADOS con che_cheques ''

	if exists (	select a.CODIGO 
				from COF_COFRES a with(nolock) 
				where a.tipo not in (select b.TIPO 
									from COF_COFRES_TIPO b with(nolock))
			)	
	print ''Tabla COF_COFRES no se ajusta a la integridad referencial con COF_COFRES_TIPO ''
	else
	print ''Comprobación OK.Tabla COF_COFRES con COF_COFRES_TIPO ''

	if exists (	select a.CODIGO_COFRE 
				from COF_COFRES_CONTRATOS a with(nolock) 
				where a.CODIGO_COFRE not in (select b.codigo 
											from COF_COFRES b with(nolock))
			)	
	print ''Tabla COF_COFRES_CONTRATOS no se ajusta a la integridad referencial con COF_COFRES ''
	else
	print ''Comprobación OK.Tabla COF_COFRES_CONTRATOS con COF_COFRES ''

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
	print ''Tabla COF_COFRES_CONTRATOS no se ajusta a la integridad referencial con SALDOS ''
	else
	print ''Comprobación OK.Tabla COF_COFRES_CONTRATOS con SALDOS ''
	
	if exists (	select a.SUCURSAL 
				from BITACORA_CAJAS_SEGURIDAD a with(nolock) 
				where NRO_CAJA_SEGURIDAD not in (select b.CODIGO_COFRE 
												from COF_COFRES_CONTRATOS b with(nolock))
			)	
	print ''Tabla BITACORA_CAJAS_SEGURIDAD no se ajusta a la integridad referencial con COF_COFRES_CONTRATOS ''
	else
	print ''Comprobación OK.Tabla BITACORA_CAJAS_SEGURIDAD con COF_COFRES_CONTRATOS ''

	if exists (	select a.CODIGO_CONTRATO 
				from COF_COFRES_EVENTOS a with(nolock) 
				where a.CODIGO_CONTRATO not in (select b.CODIGO 
												from COF_COFRES_CONTRATOS b with(nolock))
			)	
	print ''Tabla COF_COFRES_EVENTOS no se ajusta a la integridad referencial con COF_COFRES_CONTRATOS ''
	else
	print ''Comprobación OK.Tabla COF_COFRES_EVENTOS con COF_COFRES_CONTRATOS ''

	if exists (	select a.CODIGO_EVENTO 
				from COF_COFRES_DETALLE_EVENTOS a with(nolock) 
				where a.CODIGO_EVENTO not in (	select b.codigo_contrato 
												from COF_COFRES_EVENTOS b with(nolock))
			)	
	print ''Tabla COF_COFRES_DETALLE_EVENTOS no se ajusta a la integridad referencial con COF_COFRES_EVENTOS ''
	else
	print ''Comprobación OK.Tabla COF_COFRES_DETALLE_EVENTOS con COF_COFRES_EVENTOS ''

	if exists (	select a.ID_CLIENTE 
				from CI_CARGOS_TARIFAS a with(nolock) 
				where a.ID_CARGO not in (	select b.ID_CARGO 
											from CI_CARGOS b with(nolock))
			)	
	print ''Tabla CI_CARGOS_TARIFAS no se ajusta a la integridad referencial con CI_CARGOS ''
	else
	print ''Comprobación OK.Tabla CI_CARGOS_TARIFAS con CI_CARGOS ''

	if exists (	select a.ID_PEDIDO 
				from DPF_DOCS_SOLICITUDES a with(nolock) 
				where a.DEPOSITO_SOLICITUD not in(	select b.codigo 
													from DPF_DOCS_DEPOSITOS b with(nolock))
			)	
	print ''Tabla DPF_DOCS_SOLICITUDES no se ajusta a la integridad referencial con DPF_DOCS_DEPOSITOS ''
	else
	print ''Comprobación OK.Tabla DPF_DOCS_SOLICITUDES con DPF_DOCS_DEPOSITOS ''

	if exists (	select 1 
				from DPF_DOCS_SOLICITUDES a with(nolock) 
				where a.CODIGO_TIPO not in(select b.CODIGO 
											from DPF_DOCS_TIPO b with(nolock))
			)	
	print ''Tabla DPF_DOCS_SOLICITUDES no se ajusta a la integridad referencial con DPF_DOCS_TIPO ''
	else
	print ''Comprobación OK.Tabla DPF_DOCS_SOLICITUDES con DPF_DOCS_TIPO ''

	if exists (	select 1 
				from BS_HISTORIA_PLAZO a with(nolock) 
				where a.SALDOS_JTS_OID not in(	select b.JTS_OID 
												from SALDOS B with(nolock))
			)	
	print ''Tabla BS_HISTORIA_PLAZO no se ajusta a la integridad referencial con SALDOS ''
	else
	print ''Comprobación OK.Tabla BS_HISTORIA_PLAZO con SALDOS ''

	if exists (	select 1 
				from GRL_BLOQUEOS a  with(nolock)
				where a.SALDO_JTS_OID not in(select b.JTS_OID 
											from SALDOS B with(nolock))
			)	
	print ''Tabla GRL_BLOQUEOS no se ajusta a la integridad referencial con SALDOS ''
	else
	print ''Comprobación OK.Tabla GRL_BLOQUEOS con SALDOS ''
	
	if exists (	select a.NRO_CLIENTE 
				from DPF_PRE_CANCELACION a with(nolock) 
				where a.JTSOID not in(	select b.jts_oid 
										from SALDOS B with(nolock))
			)	
	print ''Tabla DPF_PRE_CANCELACION no se ajusta a la integridad referencial con SALDOS ''
	else
	print ''Comprobación OK.Tabla DPF_PRE_CANCELACION  con SALDOS ''
	
	if exists (	select 1 
				from TJD_TIPO_TARJETA a with(nolock) 
				where a.CLASE not in(	select b.Clave 
										from TJD_CLASE  B with(nolock))
			)	
	print ''Tabla TJD_TIPO_TARJETA no se ajusta a la integridad referencial con TJD_CLASE ''
	else
	print ''Comprobación OK.Tabla TJD_TIPO_TARJETA con TJD_CLASE ''

	if exists (	select a.COD_OPERACION 
				from TJD_TIPO_COD_OPERACION a with(nolock) 
				where a.TIPO_TARJETA not in(select b.TIPO_TARJETA 
											from TJD_TIPO_TARJETA  B with(nolock))
			)	
	print ''Tabla TJD_TIPO_COD_OPERACION no se ajusta a la integridad referencial con TJD_TIPO_TARJETA ''
	else
	print ''Comprobación OK.Tabla TJD_TIPO_COD_OPERACION con TJD_TIPO_TARJETA ''

	if exists (	select a.PRODUCTO 
				from TJD_SOLICITUD_LINK a with(nolock) 
				where a.PRODUCTO not in(select CAST(b.PRODUCTO AS varchar(max)) 
										from PROD_RELTARJETAS  B with(nolock))
			)	
	print ''Tabla TJD_SOLICITUD_LINK no se ajusta a la integridad referencial con PROD_RELTARJETAS ''
	else
	print ''Comprobación OK.Tabla TJD_SOLICITUD_LINK con PROD_RELTARJETAS ''

	if exists (	select a.NRO_CUENTA 
				from TJD_SOLICITUD_CUENTAS_LINK a with(nolock) 
				where a.ID_SOLICITUD not in(select b.ID_SOLICITUD 
											from TJD_SOLICITUD_LINK  B with(nolock))
			)	
	print ''Tabla TJD_SOLICITUD_CUENTAS_LINK no se ajusta a la integridad referencial con TJD_SOLICITUD_LINK ''
	else
	print ''Comprobación OK.Tabla TJD_SOLICITUD_CUENTAS_LINK con TJD_SOLICITUD_LINK ''

	if exists (	select a.ID_TARJETA 
				from TJD_DIRECCIONES_LINK a with(nolock) 
				where a.ID_TARJETA not in(	select b.NRO_TARJETA_BASE 
											from TJD_SOLICITUD_LINK  B with(nolock))
			)	
	print ''Tabla TJD_DIRECCIONES_LINK no se ajusta a la integridad referencial con TJD_SOLICITUD_LINK ''
	else
	print ''Comprobación OK.Tabla TJD_DIRECCIONES_LINK con TJD_SOLICITUD_LINK ''

	if exists (	select a.ID_TARJETA 
				from TJD_TARJETAS a  with(nolock)
				where a.ID_TARJETA not in(	select b.NRO_TARJETA_COMPLETA 
											from TJD_SOLICITUD_LINK  B with(nolock))
			)	
	print ''Tabla TJD_TARJETAS no se ajusta a la integridad referencial con TJD_SOLICITUD_LINK ''
	else
	print ''Comprobación OK.Tabla TJD_TARJETAS con TJD_SOLICITUD_LINK ''

	if exists (	select a.JTS_OID_SALDO 
				from VTA_SALDOS a with(nolock) 
				where a.JTS_OID_SALDO not in(select b.JTS_OID 
											from SALDOS  B with(nolock))
			)	
	print ''Tabla VTA_SALDOS no se ajusta a la integridad referencial con SALDOS ''
	else
	print ''Comprobación OK.Tabla VTA_SALDOS con SALDOS ''

	if exists (	select * 
				from TJD_CANAL_ORIGEN a  with(nolock)
				where a.CANAL not in(select b.CODIGO 
									from TJD_CANAL  B with(nolock))
			)	
	print ''Tabla TJD_CANAL_ORIGEN no se ajusta a la integridad referencial con TJD_CANAL ''
	else
	print ''Comprobación OK.Tabla TJD_CANAL_ORIGEN con TJD_CANAL ''

	if exists (	select a.CANAL 
				from TJD_CANAL_ORIGEN a with(nolock) 
				where a.ORIGEN not in(	select b.CODIGO 
										from TJD_ORIGEN  B with(nolock))
			)	
	print ''Tabla TJD_CANAL_ORIGEN no se ajusta a la integridad referencial con TJD_ORIGEN ''
	else
	print ''Comprobación OK.Tabla TJD_CANAL_ORIGEN con TJD_ORIGEN''

	if exists (	select a.ID_TARJETA 
				from TJD_DATOS_AUDITORIA a with(nolock) 
				where a.ID_TARJETA not in(select b.ID_TARJETA 
											from TJD_TARJETAS B with(nolock))
			)	
	print ''Tabla TJD_DATOS_AUDITORIA no se ajusta a la integridad referencial con TJD_TARJETAS ''
	else
	print ''Comprobación OK.Tabla TJD_DATOS_AUDITORIA con TJD_TARJETAS ''
	
	if exists (	select a.ID_TARJETA 
				from BITACORA_TARJETA_DEBITO a with(nolock) 
				where a.ID_TARJETA not in(	select b.ID_TARJETA 
											from TJD_TARJETAS B with(nolock))
			)	
	print ''Tabla BITACORA_TARJETA_DEBITO no se ajusta a la integridad referencial con TJD_TARJETAS ''
	else
	print ''Comprobación OK.Tabla BITACORA_TARJETA_DEBITO con TJD_TARJETAS ''

	if exists (	select a.ID_TARJETA_BASE 
				from TJD_COBRO_COMISIONES a with(nolock) 
				where a.ID_TARJETA_BASE not in(select b.ID_TARJETA_BASE 
												from TJD_TARJETAS B with(nolock))
			)	
	print ''Tabla TJD_COBRO_COMISIONES no se ajusta a la integridad referencial con TJD_TARJETAS ''
	else
	print ''Comprobación OK.Tabla TJD_COBRO_COMISIONES con TJD_TARJETAS ''

	if exists (	select a.ID_TARJETA 
				from TJD_REL_TARJETA_CUENTA a with(nolock) 
				where a.ID_TARJETA not in(	select b.ID_TARJETA 
											from TJD_LINK_MAESTRO B with(nolock))
			)	
	print ''Tabla TJD_REL_TARJETA_CUENTA no se ajusta a la integridad referencial con TJD_LINK_MAESTRO ''
	else
	print ''Comprobación OK.Tabla TJD_REL_TARJETA_CUENTA con TJD_LINK_MAESTRO ''

	if exists (	select * 
				from TJD_LINK_MAESTRO_CUENTA a with(nolock) 
				where a.ID_TARJETA not in(	select b.ID_TARJETA 
											from TJD_LINK_MAESTRO B with(nolock))
			)	
	print ''Tabla TJD_LINK_MAESTRO_CUENTA no se ajusta a la integridad referencial con TJD_LINK_MAESTRO ''
	else
	print ''Comprobación OK.Tabla TJD_LINK_MAESTRO_CUENTA con TJD_LINK_MAESTRO ''

	if exists (	select a.ID_TARJETA 
				from TJD_LINK_MAESTRO a  with(nolock)
				where a.ID_TARJETA not in(	select b.ID_TARJETA 
											from TJD_TARJETAS B with(nolock))
			)	
	print ''Tabla TJD_LINK_MAESTRO no se ajusta a la integridad referencial con TJD_TARJETAS ''
	else
	print ''Comprobación OK.Tabla TJD_LINK_MAESTRO con TJD_TARJETAS ''

	------------------------------------------------------------------------------------------------------------------
	if exists (	select a.NUMERO_CHEQUE 
				from cle_cheques_clearing_recibido a with(nolock) 
				left join che_cheques B with(nolock) on a.NUMERO_SERIE = b.serie
											and a.numero_cheque = b.numerocheque
											and a.sucursal = b.sucursal
											and a.moneda = b.moneda
											and a.cuenta = b.cuenta
											and a.producto = b.producto
											and a.operacion = b.operacion
				where 
				a.numero_serie is null
				and numero_cheque is null
				and a.sucursal is null
				and a.moneda is null
				and a.cuenta is null
				and a.PRODUCTO is null
				and a.OPERACION is null
			)	
	print ''Tabla cle_cheques_clearing_recibido no se ajusta a la integridad referencial con che_cheques ''
	else
	print ''Comprobación OK.Tabla cle_cheques_clearing_recibido con che_cheques ''

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
	print ''Tabla CLE_CHEQUES_CLEARING_DEVUELTOS no se ajusta a la integridad referencial con CLE_CHEQUES_CLEARING_RECIBIDO ''
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
	print ''Tabla CHE_BCO_RECHAZADOS no se ajusta a la integridad referencial con CLE_CHEQUES_CLEARING_DEVUELTOS ''
	else
	print ''Comprobación OK.Tabla CHE_BCO_RECHAZADOS con CLE_CHEQUES_CLEARING_DEVUELTOS ''

	if exists (	select a.CUENTA
				from CLE_CHEQUES_RECIBIDOS_AUX a with(nolock)
				left join CLE_CHEQUES_CLEARING_RECIBIDO b with(nolock) on a.SERIE = b.NUMERO_SERIE
															and a.NRO_CHEQUE = b.NUMERO_CHEQUE
															and a.SUCURSAL_CHEQUE = b.SUCURSAL
															and a.MONEDA = b.MONEDA
															and a.PRODUCTO = b.PRODUCTO
															and a.OPERACION = b.OPERACION
															and a.SUCURSAL_ASIENTO = b.ASIENTO_SUCURSAL
				where
					a.SERIE is null
					and a.NRO_CHEQUE is null
					and a.SUCURSAL_CHEQUE is null
					and a.MONEDA is null
					and a.PRODUCTO is null
					and a.OPERACION is null
					and a.SUCURSAL_ASIENTO is null
			)	
	print ''Tabla CLE_CHEQUES_RECIBIDOS_AUX no se ajusta a la integridad referencial con CLE_CHEQUES_CLEARING_RECIBIDO ''
	else
	print ''Comprobación OK.Tabla CLE_CHEQUES_RECIBIDOS_AUX con CLE_CHEQUES_CLEARING_RECIBIDO ''

	if exists (	select a.NUMERO_CHEQUE 
				from cle_cheques_clearing_recibido a with(nolock) 
				where a.CODIGO_CAUSAL_devolucion   not in (	select b.CODIGO_de_CAUSAL 
															from cle_tipo_causal b with(nolock))

			)	
	print ''Tabla cle_cheques_clearing_recibido no se ajusta a la integridad referencial con cle_tipo_causal ''
	else
	print ''Comprobación OK.Tabla cle_cheques_clearing_recibido con cle_tipo_causal ''

	if exists (	select a.NRO_CHEQUE 
				from CHE_SOLICITUD_CANJE_INTERNO a with(nolock) 
				where a.SALDO_JTS_OID not in (	select b.jts_oid 
												from SALDOS b with(nolock))

			)	
	print ''Tabla CHE_SOLICITUD_CANJE_INTERNO no se ajusta a la integridad referencial con SALDOS ''
	else
	print ''Comprobación OK.Tabla CHE_SOLICITUD_CANJE_INTERNO con SALDOS ''

	if exists (	select a.NRO_CHEQUE 
				from CHE_SOLICITUD_CANJE_INTERNO a with(nolock) 
				left join CHE_CHEQUES b with(nolock) on a.NRO_CHEQUE = b.NUMEROCHEQUE
											and a.SERIE = b.SERIE
											and a.NRO_SOLICITUD = b.NRO_SOLICITUD
				where a.nro_cheque is null
					and a.serie is null
					and a.NRO_SOLICITUD is null

			)	
	print ''Tabla CHE_SOLICITUD_CANJE_INTERNO no se ajusta a la integridad referencial con CHE_CHEQUES ''
	else
	print ''Comprobación OK.Tabla CHE_SOLICITUD_CANJE_INTERNO con CHE_CHEQUES ''

	if exists (	select a.CODIGO_CAUSAL 
				from CLE_CONTROLES_RECIBIDO a with(nolock) 
				where  a.CODIGO_CAUSAL not in (	select b.CODIGO_DE_CAUSAL 
												from CLE_TIPO_CAUSAL b with(nolock))

			)	
	print ''Tabla CLE_CONTROLES_RECIBIDO no se ajusta a la integridad referencial con CLE_TIPO_CAUSAL ''
	else
	print ''Comprobación OK.Tabla CLE_CONTROLES_RECIBIDO con CLE_TIPO_CAUSAL ''

	if exists (	select a.NRO_ASIENTO 
				from CLE_CHEQUES_AJUSTE a with(nolock) 
				left join CLE_CHEQUES_AJUSTE_AUX b with(nolock) on a.ORDINAL = b.ORDINAL
													and a.BANCO = b.BANCO_GIRADO
													and a.FECHA_ALTA = b.FECHA_ALTA
				where a.ORDINAL is null
					and a.banco is null
					and a.FECHA_ALTA is null
			)	
	print ''Tabla CLE_CHEQUES_AJUSTE no se ajusta a la integridad referencial con CLE_CHEQUES_AJUSTE_AUX ''
	else
	print ''Comprobación OK.Tabla CLE_CHEQUES_AJUSTE con CLE_CHEQUES_AJUSTE_AUX ''

	if exists (	select a.NUMERO_CHEQUE 
				from CLE_CHEQUES_AJUSTE_AUX a with(nolock) 
				where a.JTS_OID_SALDO not in (	select b.JTS_OID 
												from saldos b with(nolock))
			)	
	print ''Tabla CLE_CHEQUES_AJUSTE_AUX no se ajusta a la integridad referencial con saldos ''
	else
	print ''Comprobación OK.Tabla CLE_CHEQUES_AJUSTE_AUX con saldos ''

	if exists (	select a.CODIGO_TRANSACCION 
				from ITF_COELSA_CHEQUES_PROPIOS a with(nolock) 
				left join CLE_CHEQUES_CLEARING b with(nolock) on a.NRO_CHEQUE = b.NUMERO_CHEQUE
													and a.CUENTA_DEBITAR = b.CUENTA
													and a.ENTIDAD_DEBITAR = b.NUMERO_BANCO
				where a.NRO_CHEQUE is null
					and a.CUENTA_DEBITAR is null
					and a.ENTIDAD_DEBITAR is null
			)	
	print ''Tabla ITF_COELSA_CHEQUES_PROPIOS no se ajusta a la integridad referencial con CLE_CHEQUES_CLEARING ''
	else
	print ''Comprobación OK.Tabla ITF_COELSA_CHEQUES_PROPIOS con CLE_CHEQUES_CLEARING ''

	if exists (	select a.CLIENTE
				from CLE_DPF_RECIBIDO a with(nolock) 
				left join saldos b with(nolock) on a.NUMERICO_CUENTA = b.CUENTA
									and a.MONEDA = b.MONEDA
									and a.OPERACION = b.OPERACION
									and a.ORDINAL = b.ORDINAL
									and a.PRODUCTO = b.PRODUCTO
				where a.NUMERICO_CUENTA is null
					and a.MONEDA is null
					and a.OPERACION is null
					and a.ORDINAL is null
					and a.PRODUCTO is null
			)	
	print ''Tabla CLE_DPF_RECIBIDO no se ajusta a la integridad referencial con saldos ''
	else
	print ''Comprobación OK.Tabla CLE_DPF_RECIBIDO con saldos ''

	if exists (	select a.NRO_CHEQUE 
				from ITF_COELSA_CHEQUES_RECHAZO a with(nolock)
				left join ITF_COELSA_CHEQUES_PROPIOS b with(nolock) on a.ID_TICKET = b.ID_TICKET
														and a.ID_PROCESO = b.ID_PROCESO
														AND A.FECHAPROCESO = B.FECHAPROCESO
														AND A.CODIGO_TRANSACCION = B.CODIGO_TRANSACCION
														AND A.CUENTA_DEBITAR = B.CUENTA_DEBITAR
														AND A.NRO_CHEQUE = B.NRO_CHEQUE
														AND A.TRACE_NUMBER = B.TRACE_NUMBER
				WHERE A.ID_TICKET IS NULL
					AND A.ID_PROCESO IS NULL
					AND A.FECHAPROCESO IS NULL
					AND A.CODIGO_TRANSACCION IS NULL
					AND A.CUENTA_DEBITAR IS NULL
					AND A.NRO_CHEQUE IS NULL
					AND A.TRACE_NUMBER IS NULL
			)	
	print ''Tabla ITF_COELSA_CHEQUES_RECHAZO no se ajusta a la integridad referencial con ITF_COELSA_CHEQUES_PROPIOS ''
	else
	print ''Comprobación OK.Tabla ITF_COELSA_CHEQUES_RECHAZO con ITF_COELSA_CHEQUES_PROPIOS ''

	if exists (	SELECT b.NUMERO_CHEQUE 
				FROM CLE_CHEQUES_CLEARING B with(nolock)
				LEFT JOIN CLE_CHEQUES_CLEARING_RECIBIDO A with(nolock) ON A.MONEDA = B.MONEDA
														AND A.NUMERO_CHEQUE = B.NUMERO_CHEQUE
														AND A.NUMERO_SERIE = B.SERIE_CHEQUE
														AND A.CUENTA = B.CUENTA
														AND A.SUCURSAL = B.NUMERO_DEPENDENCIA
				WHERE
						B.MONEDA IS NULL
						AND B.NUMERO_CHEQUE IS NULL
						AND B.SERIE_CHEQUE IS NULL
						AND B.CUENTA IS NULL
						AND B.NUMERO_DEPENDENCIA IS NULL
			)	
	print ''Tabla CLE_CHEQUES_CLEARING no se ajusta a la integridad referencial con CLE_CHEQUES_CLEARING_RECIBIDO ''
	else
	print ''Comprobación OK.Tabla CLE_CHEQUES_CLEARING con CLE_CHEQUES_CLEARING_RECIBIDO ''
	------------------------------------------------------------------------------------------------------------------

	if exists (	select a.CODIGO_RECHAZO  
				from CLE_RECEPCION_DPF_DEV a with(nolock)
				left join CLE_DPF_SALIENTE b with(nolock) on a.SUCURSAL_BANCO_GIRADO = b.SUCURSAL_BANCO_GIRADO
												and a.BANCO_GIRADO = b.BANCO_GIRADO
												and a.NUMERO_DPF = b.NUMERO_DPF
				where a.SUCURSAL_BANCO_GIRADO is null
					and a.BANCO_GIRADO is null
					and a.NUMERO_DPF is null

			)	
	print ''Tabla CLE_RECEPCION_DPF_DEV no se ajusta a la integridad referencial con CLE_DPF_SALIENTE ''
	else
	print ''Comprobación OK.Tabla CLE_RECEPCION_DPF_DEV con CLE_DPF_SALIENTE ''

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
	print ''Tabla CLE_CHEQUES_SALIENTE_HTO no se ajusta a la integridad referencial con CLE_CHEQUES_SALIENTE ''
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
	print ''Tabla ITF_COELSA_CHEQUES_OTROS no se ajusta a la integridad referencial con CLE_CHEQUES_SALIENTE ''
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
	print ''Tabla CLE_CHEQUES_ENVIADOS no se ajusta a la integridad referencial con CLE_CHEQUES_SALIENTE ''
	else
	print ''Comprobación OK.Tabla CLE_CHEQUES_ENVIADOS con CLE_CHEQUES_SALIENTE ''

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
	print ''Tabla CLE_RECEPCION_CHEQUES_DEV no se ajusta a la integridad referencial con CLE_CHEQUES_ENVIADOS ''
	else
	print ''Comprobación OK.Tabla CLE_RECEPCION_CHEQUES_DEV con CLE_CHEQUES_ENVIADOS ''


------------------------------------------OPERACIONES------------------------------------------------------------------------
	if exists (	SELECT * FROM CONV_CONVENIOS_REC b
				left join CLI_DIRECCIONES a on a.FORMATO = b.Dir_Formato 
												and a.ID = b.Dir_Id
				where a.FORMATO is null
				and a.ID is null
			)	
		print ''Tabla CONV_CONVENIOS_REC no se ajusta a la integridad referencial con CLI_DIRECCIONES ''
	else
		print ''Comprobación OK.Tabla CONV_CONVENIOS_REC con CLI_DIRECCIONES ''

	if exists (	SELECT * FROM CONV_CONVENIOS_REC b
				left join CONV_TIPOS a on a.Id_TpoConv = b.Id_TpoConv 
				where a.Id_TpoConv is null
			)	
		print ''Tabla CONV_CONVENIOS_REC no se ajusta a la integridad referencial con CONV_TIPOS ''
	else
		print ''Comprobación OK.Tabla CONV_CONVENIOS_REC con CONV_TIPOS ''

	if exists (	SELECT * FROM CONV_CONVENIOS_REC b
				left join CONV_FORMULAS_MORA a on a.ID_FORMULA = b.ID_Formula
				where a.ID_FORMULA is null
			)	
		print ''Tabla CONV_CONVENIOS_REC no se ajusta a la integridad referencial con CONV_FORMULAS_MORA ''
	else
		print ''Comprobación OK.Tabla CONV_CONVENIOS_REC con CONV_FORMULAS_MORA ''

	if exists (	SELECT * FROM CONV_CONVENIOS_MORA b
				left join CONV_CONVENIOS_REC a on a.Id_TpoConv = b.ID_CONVENIO
				where a.Id_TpoConv is null
			)	
		print ''Tabla CONV_CONVENIOS_MORA no se ajusta a la integridad referencial con CONV_CONVENIOS_REC ''
	else
		print ''Comprobación OK.Tabla CONV_CONVENIOS_MORA con CONV_CONVENIOS_REC ''

	if exists (	SELECT * FROM CONV_MEDIOPAGO b
				left join CONV_TIPOS a on a.Id_TpoConv = b.Id_TpoConv
				where a.Id_TpoConv is null
			)	
		print ''Tabla CONV_MEDIOPAGO no se ajusta a la integridad referencial con CONV_TIPOS ''
	else
		print ''Comprobación OK.Tabla CONV_MEDIOPAGO con CONV_TIPOS ''
	if exists (	SELECT * FROM CONV_BITACORA b
				left join CONV_CONVENIOS_REC a on a.Id_TpoConv = b.Id_Convenio
				where a.Id_TpoConv is null
			)	
		print ''Tabla CONV_BITACORA no se ajusta a la integridad referencial con CONV_CONVENIOS_REC ''
	else
		print ''Comprobación OK.Tabla CONV_BITACORA con CONV_CONVENIOS_REC ''
	if exists (	SELECT * FROM CONV_CB_ESTRUCTURA b
				left join CONV_CONVENIOS_REC a on a.Id_TpoConv = b.Id_Convenio
				where a.Id_TpoConv is null
			)	
		print ''Tabla CONV_CB_ESTRUCTURA no se ajusta a la integridad referencial con CONV_CONVENIOS_REC ''
	else
		print ''Comprobación OK.Tabla CONV_CB_ESTRUCTURA con CONV_CONVENIOS_REC ''
	if exists (	SELECT * FROM CONV_CB_CAMPOS b
			left join CONV_CB_ESTRUCTURA a on a.ID_REFERENCIA = b.ID_CODIGO_BARRAS
			where a.ID_REFERENCIA is null
		)	
		print ''Tabla CONV_CB_CAMPOS no se ajusta a la integridad referencial con CONV_CB_ESTRUCTURA ''
	else
		print ''Comprobación OK.Tabla CONV_CB_CAMPOS con CONV_CB_ESTRUCTURA ''
	if exists (	SELECT * FROM CONV_MEDIOPAGO b
			left join CONV_CONVENIOS_PAG a on a.ID_ConvPago = b.ID_ConvPago
			where a.ID_ConvPago is null
		)	
		print ''Tabla CONV_MEDIOPAGO no se ajusta a la integridad referencial con CONV_CONVENIOS_PAG ''
	else
		print ''Comprobación OK.Tabla CONV_MEDIOPAGO con CONV_CONVENIOS_PAG ''
	if exists (	SELECT * FROM REC_RENDICION b
			left join ASIENTOS a on a.ASIENTO = b.ASIENTO_RENDICION
									AND B.SUCURSAL_RENDICION = A.SUCURSAL
									AND B.FECHA = A.FECHAPROCESO
			where a.ASIENTO is null
					AND A.SUCURSAL IS NULL
					AND A.FECHAPROCESO IS NULL
		)	
		print ''Tabla CONV_MEDIOPAGO no se ajusta a la integridad referencial con CONV_CONVENIOS_PAG ''
	else
		print ''Comprobación OK.Tabla CONV_MEDIOPAGO con CONV_CONVENIOS_PAG ''
	if exists (	SELECT * FROM REC_CAB_RECAUDOS_CAJA b
			left join REC_LIQUIDACION a on a.ID_LIQUIDACION = b.ID_LIQUIDACION
			where a.ID_LIQUIDACION is null
		)	
		print ''Tabla REC_CAB_RECAUDOS_CAJA no se ajusta a la integridad referencial con REC_LIQUIDACION ''
	else
		print ''Comprobación OK.Tabla REC_CAB_RECAUDOS_CAJA con REC_LIQUIDACION ''
	if exists (	SELECT * FROM REC_CAB_RECAUDOS_CAJA b
			left join REC_DET_RECAUDOS_CAJA a on a.ID_CABEZAL = b.ID
			where a.ID_CABEZAL is null
		)	
		print ''Tabla REC_CAB_RECAUDOS_CAJA no se ajusta a la integridad referencial con REC_DET_RECAUDOS_CAJA ''
	else
		print ''Comprobación OK.Tabla REC_CAB_RECAUDOS_CAJA con REC_DET_RECAUDOS_CAJA ''
	if exists (	SELECT * FROM REC_CAB_RECAUDOS_CANAL b
			left join REC_LIQUIDACION a on a.ID_LIQUIDACION = b.ID_LIQUIDACION
			where a.ID_LIQUIDACION is null
		)	
		print ''Tabla REC_CAB_RECAUDOS_CANAL no se ajusta a la integridad referencial con REC_LIQUIDACION ''
	else
		print ''Comprobación OK.Tabla REC_CAB_RECAUDOS_CANAL con REC_LIQUIDACION ''
	if exists (	SELECT * FROM REC_CAB_RECAUDOS_CANAL b
			left join REC_DET_RECAUDOS_CANAL a on a.ID_CABEZAL = b.ID
			where a.ID_CABEZAL is null
		)	
		print ''Tabla REC_CAB_RECAUDOS_CANAL no se ajusta a la integridad referencial con REC_DET_RECAUDOS_CANAL ''
	else
		print ''Comprobación OK.Tabla REC_CAB_RECAUDOS_CANAL con REC_DET_RECAUDOS_CANAL ''
	if exists (	SELECT * FROM REC_LIQUIDACION b
			left join REC_RENDICION a on a.ID_RENDICION = b.ID_RENDICION
			where a.ID_RENDICION is null
		)	
		print ''Tabla REC_LIQUIDACION no se ajusta a la integridad referencial con REC_RENDICION ''
	else
		print ''Comprobación OK.Tabla REC_LIQUIDACION con REC_RENDICION ''
	if exists (	SELECT * FROM REC_LIQUIDACION b
			left join ASIENTOS a on a.ASIENTO = b.ASIENTO_LIQUIDACION
									and a.SUCURSAL = b.SUCURSAL_LIQUIDACION
									and a.FECHAPROCESO = b.FECHA
			where a.ASIENTO is null
				and a.SUCURSAL is null
				and a.FECHAPROCESO is null
		)	
		print ''Tabla REC_LIQUIDACION no se ajusta a la integridad referencial con ASIENTOS ''
	else
		print ''Comprobación OK.Tabla REC_LIQUIDACION con ASIENTOS ''
	if exists (	SELECT * FROM REC_RENDICION b
			left join ASIENTOS a on a.ASIENTO = b.ASIENTO_RENDICION
									and a.SUCURSAL = b.SUCURSAL_RENDICION
									and a.FECHAPROCESO = b.FECHA
			where a.ASIENTO is null
				and a.SUCURSAL is null
				and a.FECHAPROCESO is null
		)	
		print ''Tabla REC_RENDICION no se ajusta a la integridad referencial con ASIENTOS ''
	else
		print ''Comprobación OK.Tabla REC_RENDICION con ASIENTOS ''

	if exists (	SELECT * FROM CONV_CONVENIOS_PAG b
			left join CONV_TIPOS a on a.Id_TpoConv = b.Id_TpoConv

			where a.Id_TpoConv is null
		)	
		print ''Tabla CONV_CONVENIOS_PAG no se ajusta a la integridad referencial con CONV_TIPOS ''
	else
		print ''Comprobación OK.Tabla CONV_CONVENIOS_PAG con CONV_TIPOS ''

	if exists (	SELECT * FROM CONV_MEDIOPAGO b
			left join CONV_TIPOS a on a.Id_TpoConv = b.Id_TpoConv

			where a.Id_TpoConv is null
		)	
		print ''Tabla CONV_MEDIOPAGO no se ajusta a la integridad referencial con CONV_TIPOS ''
	else
		print ''Comprobación OK.Tabla CONV_MEDIOPAGO con CONV_TIPOS ''

	if exists (	SELECT * FROM CONV_DOMINIOS b
			left join CONV_CONVENIOS_REC a on a.Id_ConvRec = b.ID_CONVENIO
			where a.Id_ConvRec is null
		)	
		print ''Tabla CONV_DOMINIOS no se ajusta a la integridad referencial con CONV_CONVENIOS_REC ''
	else
		print ''Comprobación OK.Tabla CONV_DOMINIOS con CONV_CONVENIOS_REC ''
	if exists (	SELECT * FROM CONV_BITACORA b
			left join CONV_CONVENIOS_PAG a on a.ID_ConvPago = b.ID_CONVENIO
			where a.ID_ConvPago is null
		)	
		print ''Tabla CONV_BITACORA no se ajusta a la integridad referencial con CONV_CONVENIOS_PAG ''
	else
		print ''Comprobación OK.Tabla CONV_BITACORA con CONV_CONVENIOS_PAG ''
	if exists (	SELECT * FROM CONV_CONVENIOS_MORA b
			left join CONV_CONVENIOS_REC a on a.Id_ConvRec = b.ID_CONVENIO
			where a.Id_ConvRec is null
		)	
		print ''Tabla CONV_CONVENIOS_MORA no se ajusta a la integridad referencial con CONV_CONVENIOS_REC ''
	else
		print ''Comprobación OK.Tabla CONV_CONVENIOS_MORA con CONV_CONVENIOS_REC ''
	if exists (	SELECT * FROM CONV_CB_CAMPOS b
			left join CONV_CB_ESTRUCTURA a on a.ID_CODIGO_BARRAS = b.ID_CODIGO_BARRAS
			where a.ID_CODIGO_BARRAS is null
		)	
		print ''Tabla CONV_CB_CAMPOS no se ajusta a la integridad referencial con CONV_CB_ESTRUCTURA ''
	else
		print ''Comprobación OK.Tabla CONV_CB_CAMPOS con CONV_CB_ESTRUCTURA ''
	if exists (	SELECT * FROM CONV_CONVENIOS_MORA b
			left join CONV_CONVENIOS_PAG a on a.ID_ConvPago = b.ID_CONVENIO
			where a.ID_ConvPago is null
		)	
		print ''Tabla CONV_CONVENIOS_MORA no se ajusta a la integridad referencial con CONV_CONVENIOS_PAG ''
	else
		print ''Comprobación OK.Tabla CONV_CONVENIOS_MORA con CONV_CONVENIOS_PAG ''
	if exists (	SELECT * FROM REC_CAB_DEBITOSAUTOMATICOS b
			left join REC_LIQUIDACION a on a.ID_LIQUIDACION = b.ID_LIQUIDACION
			where a.ID_LIQUIDACION is null
		)	
		print ''Tabla REC_CAB_DEBITOSAUTOMATICOS no se ajusta a la integridad referencial con REC_LIQUIDACION ''
	else
		print ''Comprobación OK.Tabla REC_CAB_DEBITOSAUTOMATICOS con REC_LIQUIDACION ''
	if exists (	SELECT * FROM REC_LIQUIDACION b
			left join CONV_CONVENIOS_REC a on a.Id_ConvRec = b.CONVENIO
											and a.Id_ConvPadre = b.CONVENIO_PADRE
			where a.Id_ConvRec is null
			and a.Id_ConvPadre is null
		)	
		print ''Tabla REC_LIQUIDACION no se ajusta a la integridad referencial con CONV_CONVENIOS_REC ''
	else
		print ''Comprobación OK.Tabla REC_LIQUIDACION con CONV_CONVENIOS_REC ''
	if exists (	SELECT * FROM REC_DET_DEBITOSAUTOMATICOS b
			left join REC_CAB_DEBITOSAUTOMATICOS a on a.Id = b.ID_CABEZAL
	
			where a.Id is null
		)	
		print ''Tabla REC_DET_DEBITOSAUTOMATICOS no se ajusta a la integridad referencial con REC_CAB_DEBITOSAUTOMATICOS ''
	else
		print ''Comprobación OK.Tabla REC_DET_DEBITOSAUTOMATICOS con REC_CAB_DEBITOSAUTOMATICOS ''
	if exists (	SELECT * FROM SNP_PRESTACIONES_EMPRESAS b
			left join CONV_CONVENIOS_REC a on a.Id_ConvRec = b.ID_CONVENIO
	
			where a.Id_ConvRec is null
		)	
		print ''Tabla SNP_PRESTACIONES_EMPRESAS no se ajusta a la integridad referencial con CONV_CONVENIOS_REC ''
	else
		print ''Comprobación OK.Tabla SNP_PRESTACIONES_EMPRESAS con CONV_CONVENIOS_REC ''
	if exists (	SELECT * FROM SNP_CUENTAS_RELACIONADAS b
			left join SNP_PRESTACIONES_EMPRESAS a on a.CUIT_EO = b.CUIT_EO 
												and a.PRESTACION = b.PRESTACION
	where	a.CUIT_EO is null
		and a.prestacion is null
		)	
		print ''Tabla SNP_PRESTACIONES_EMPRESAS no se ajusta a la integridad referencial con CONV_CONVENIOS_REC ''
	else
		print ''Comprobación OK.Tabla SNP_PRESTACIONES_EMPRESAS con CONV_CONVENIOS_REC ''
	if exists (	SELECT * FROM SNP_ADHESIONES b
			left join CLI_CLIENTES a on a.CALIDADCLIENTE = b.CLIENTE_ADHERIDO
	where	a.CALIDADCLIENTE is null
		)	
		print ''Tabla SNP_ADHESIONES no se ajusta a la integridad referencial con CLI_CLIENTES ''
	else
		print ''Comprobación OK.Tabla SNP_ADHESIONES con CLI_CLIENTES ''
	if exists (	SELECT * FROM SNP_ADHESIONES b
			left join SNP_PRESTACIONES_EMPRESAS a on a.CUIT_EO = b.CUIT_EO
													and a.PRESTACION = b.PRESTACION
	where	a.CUIT_EO is null
	and		a.PRESTACION is null
		)	
		print ''Tabla SNP_ADHESIONES no se ajusta a la integridad referencial con SNP_PRESTACIONES_EMPRESAS ''
	else
		print ''Comprobación OK.Tabla SNP_ADHESIONES con SNP_PRESTACIONES_EMPRESAS ''
	if exists (	SELECT * FROM SNP_ADHESIONES b
			left join CLI_CLIENTES a on a.CODIGOCLIENTE = b.CODIGO_CLIENTE
	where	a.CODIGOCLIENTE is null
		)	
		print ''Tabla SNP_ADHESIONES no se ajusta a la integridad referencial con CLI_CLIENTES ''
	else
		print ''Comprobación OK.Tabla SNP_ADHESIONES con CLI_CLIENTES ''
	if exists (	SELECT * FROM SNP_DEBITOS b
			left join SNP_PRESTACIONES_EMPRESAS a on a.CUIT_EO = b.CUIT_EO
													AND A.PRESTACION= B.PRESTACION
	where	a.CUIT_EO is null
	AND A.PRESTACION IS NULL
		)	
		print ''Tabla SNP_DEBITOS no se ajusta a la integridad referencial con SNP_PRESTACIONES_EMPRESAS ''
	else
		print ''Comprobación OK.Tabla SNP_DEBITOS con SNP_PRESTACIONES_EMPRESAS ''
	if exists (	SELECT * FROM SNP_MSG_ORDENES b
			left join SNP_PRESTACIONES_EMPRESAS a on a.CUIT_EO = b.CUIT_EO
	where	a.CUIT_EO is null
		)	
		print ''Tabla SNP_MSG_ORDENES no se ajusta a la integridad referencial con SNP_PRESTACIONES_EMPRESAS ''
	else
		print ''Comprobación OK.Tabla SNP_MSG_ORDENES con SNP_PRESTACIONES_EMPRESAS ''
	if exists (	SELECT * FROM SNP_PRESTACIONES_EMPRESAS b
			left join CONV_CONVENIOS_REC a on a.Id_ConvRec = b.ID_CONVENIO
	where	a.Id_ConvRec is null
		)	
		print ''Tabla SNP_PRESTACIONES_EMPRESAS no se ajusta a la integridad referencial con CONV_CONVENIOS_REC ''
	else
		print ''Comprobación OK.Tabla SNP_PRESTACIONES_EMPRESAS con CONV_CONVENIOS_REC ''
	if exists (	SELECT * FROM SNP_STOP_DEBIT b
			left join CONV_CONVENIOS_REC a on a.Id_ConvRec = b.ID_CONVENIO
	where	a.Id_ConvRec is null
		)	
		print ''Tabla SNP_STOP_DEBIT no se ajusta a la integridad referencial con CONV_CONVENIOS_REC ''
	else
		print ''Comprobación OK.Tabla SNP_STOP_DEBIT con CONV_CONVENIOS_REC ''
	if exists (	SELECT * FROM SNP_STOP_DEBIT b
			left join CLI_CLIENTES a on a.CODIGOCLIENTE = b.CLIENTE_ADHERIDO
	where	a.CODIGOCLIENTE is null
		)	
		print ''Tabla SNP_STOP_DEBIT no se ajusta a la integridad referencial con CLI_CLIENTES ''
	else
		print ''Comprobación OK.Tabla SNP_STOP_DEBIT con CLI_CLIENTES ''
	if exists (	SELECT * FROM SNP_STOP_DEBIT b
			left join SNP_PRESTACIONES_EMPRESAS a on a.CUIT_EO = b.CUIT_EO
													AND A.PRESTACION = B.PRESTACION
	where	a.CUIT_EO is null
		AND A.PRESTACION IS NULL
		)	
		print ''Tabla SNP_STOP_DEBIT no se ajusta a la integridad referencial con SNP_PRESTACIONES_EMPRESAS ''
	else
		print ''Comprobación OK.Tabla SNP_STOP_DEBIT con SNP_PRESTACIONES_EMPRESAS ''
	if exists (	SELECT * FROM REC_Agencieros b
			left join GRL_ACREDITACIONES_MASIVAS a on a.REFERENCIA_EXTERNA = b.ID
	where	a.REFERENCIA_EXTERNA is null
		)	
		print ''Tabla REC_Agencieros no se ajusta a la integridad referencial con GRL_ACREDITACIONES_MASIVAS ''
	else
		print ''Comprobación OK.Tabla REC_Agencieros con GRL_ACREDITACIONES_MASIVAS ''
	if exists (	SELECT * FROM GRL_ACREDITACIONES_MASIVAS b
			left join ASIENTOS a on a.ASIENTO = b.ASIENTO_PROCESADO
								AND A.FECHAPROCESO = B.FECHA_PROCESADO
								AND A.SUCURSAL = B.SUC_PROCESADO
	where	a.ASIENTO is null
		AND A.FECHAPROCESO IS NULL
		AND A.SUCURSAL IS NULL
		)	
		print ''Tabla GRL_ACREDITACIONES_MASIVAS no se ajusta a la integridad referencial con ASIENTOS ''
	else
		print ''Comprobación OK.Tabla GRL_ACREDITACIONES_MASIVAS con ASIENTOS ''
	if exists (	SELECT * FROM REC_Agencieros b
			left join SALDOS a on a.JTS_OID = b.JTS_OID
	where	a.JTS_OID is null
		)	
		print ''Tabla REC_Agencieros no se ajusta a la integridad referencial con SALDOS ''
	else
		print ''Comprobación OK.Tabla REC_Agencieros con SALDOS ''
	if exists (	SELECT * FROM REC_Agencieros b
			left join ASIENTOS a on a.ASIENTO = b.ASIENTO
								AND A.FECHAPROCESO=B.FECHA_COBRO_PAGO
								AND A.SUCURSAL = B.SUCURSAL
	where	a.FECHAPROCESO is null
		AND A.ASIENTO IS NULL
		AND A.SUCURSAL IS NULL
		)	
		print ''Tabla REC_Agencieros no se ajusta a la integridad referencial con ASIENTOS ''
	else
		print ''Comprobación OK.Tabla REC_Agencieros con ASIENTOS ''
 END
ELSE
	print ''NO CORRESPONDE LA BASE DE DATOS''
END
; ')
