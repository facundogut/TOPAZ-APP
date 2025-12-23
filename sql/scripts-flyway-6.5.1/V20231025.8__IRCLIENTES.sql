execute('
----------------------------------------CLIENTES.-----------------------------------------------------------
--exec [dbo].[SP_INTEGRIDAD_REFERENCIAL_CLIENTES] NBCH_tunning
---drop procedure SP_INTEGRIDAD_REFERENCIAL

CREATE OR ALTER  procedure [dbo].[SP_INTEGRIDAD_REFERENCIAL_CLIENTES] 
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
			select  ''Tabla CLI_INSTITUCIONFINANCIERA no se ajusta a la integridad referencial con CLI_CLIENTES '',*
			from CLI_INSTITUCIONFINANCIERA b with(nolock)
			where b.CODIGOCLIENTE not in ( 
										select a.CODIGOCLIENTE 
										from CLI_CLIENTES a with(nolock) )
	ELSE 
			print ''Comprobación OK. Tabla CLI_INSTITUCIONFINANCIERA con CLI_CLIENTES ''
	if exists (
				select b.ENTIDADCALIFICADORA 
				from CLI_CLIENTES b with(nolock)
				where b.ENTIDADCALIFICADORA  not in ( 
											select a.ENTIDAD 
											from CLI_ENTIDAD_CALIFICADORA a with(nolock) )
				)
				select   ''Tabla CLI_CLIENTES no se ajusta a la integridad referencial con CLI_ENTIDAD_CALIFICADORA '',*
				from CLI_CLIENTES b with(nolock)
				where b.ENTIDADCALIFICADORA  not in ( 
											select a.ENTIDAD 
											from CLI_ENTIDAD_CALIFICADORA a with(nolock) )
	ELSE 
			print ''Comprobación OK. Tabla CLI_CLIENTES con CLI_ENTIDAD_CALIFICADORA ''

	if exists (	select a.NROCLIENTE   
				from CLI_BLOQUEOS a with(nolock)
				where a.NROCLIENTE not in (	select b.CODIGOCLIENTE 
											from CLI_CLIENTES b with(nolock))
				)	
			select   ''Tabla CLI_BLOQUEOS no se ajusta a la integridad referencial con CLI_CLIENTES '',*
			from CLI_BLOQUEOS a with(nolock)
			where a.NROCLIENTE not in (	select b.CODIGOCLIENTE 
										from CLI_CLIENTES b with(nolock))
	else
	print ''Comprobación OK. Tabla CLI_BLOQUEOS con CLI_CLIENTES ''

	if exists (	select a.SEGMENTOCLIENTE  
				from CLI_CLIENTES a with(nolock)
				where a.SEGMENTOCLIENTE  not in (select b.COD_SEGMENTO 
											from CLI_SEGMENTOS b with(nolock))
				)	
				select   ''Tabla CLI_CLIENTES no se ajusta a la integridad referencial con CLI_SEGMENTOS '',*
				from CLI_CLIENTES a with(nolock)
				where a.SEGMENTOCLIENTE not in (select b.COD_SEGMENTO 
											from CLI_SEGMENTOS b with(nolock))
	else
	print ''Comprobación OK. Tabla CLI_CLIENTES con CLI_SEGMENTOS ''

	if exists (select a.COD_SUBSEGMENTO  
				from CLI_SUBSEGMENTOS a with(nolock)
				where a.COD_SEGMENTO not in (select b.COD_SEGMENTO  
											from CLI_SEGMENTOS b with(nolock))
				)	
			select   ''Tabla CLI_SUBSEGMENTOS no se ajusta a la integridad referencial con CLI_SEGMENTOS '',*
			from CLI_SUBSEGMENTOS a with(nolock)
			where a.COD_SEGMENTO not in (select b.COD_SEGMENTO  
										from CLI_SEGMENTOS b with(nolock))
	else
	print ''Comprobación OK. Tabla CLI_SUBSEGMENTOS con CLI_SEGMENTOS ''

	if exists (select * 
				from BITACORA_PERSONAS_JURIDICAS a with(nolock)
				where a.NUMEROPERSONAJURIDICA not in (	select b.NUMEROPERSONAJURIDICA 
														from CLI_PERSONASJURIDICAS b with(nolock)) 
				)	
			select   ''Tabla BITACORA_PERSONAS_JURIDICAS no se ajusta a la integridad referencial con CLI_PERSONASJURIDICAS '',*
			from BITACORA_PERSONAS_JURIDICAS a with(nolock)
			where a.NUMEROPERSONAJURIDICA not in (	select b.NUMEROPERSONAJURIDICA 
													from CLI_PERSONASJURIDICAS b with(nolock))
	else
	print ''Comprobación OK. Tabla BITACORA_PERSONAS_JURIDICAS con CLI_PERSONASJURIDICAS ''

	if exists (select b.TIPOSOCIEDAD 
				from CLI_PERSONASJURIDICAS b  with(nolock)
				where b.TIPOSOCIEDAD not in (	select a.CODIGO_SOCIEDAD 
												from CLI_TIPO_SOCIEDAD a with(nolock)) 
				)	
			select   ''Tabla CLI_PERSONASJURIDICAS no se ajusta a la integridad referencial con CLI_TIPO_SOCIEDAD '',*
			from CLI_PERSONASJURIDICAS b  with(nolock)
			where b.TIPOSOCIEDAD not in (	select a.CODIGO_SOCIEDAD 
											from CLI_TIPO_SOCIEDAD a with(nolock)) 
	else
	print ''Comprobación OK. Tabla CLI_PERSONASJURIDICAS con CLI_TIPO_SOCIEDAD ''

	if exists ( select a.CODIGO_ACTIVIDAD 
				from cli_actividad_economica a with(nolock)
				where a.CODIGO_ACTIVIDAD not in (select b.CODIGO_ACT_AFIP 
												 from CLI_Cod_Act_AFIP b with(nolock))
				)	
			select   ''Tabla cli_actividad_economica no se ajusta a la integridad referencial con CLI_Cod_Act_AFIP '',*
			from cli_actividad_economica a with(nolock)
			where a.CODIGO_ACTIVIDAD not in (select b.CODIGO_ACT_AFIP 
											 from CLI_Cod_Act_AFIP b with(nolock))
	else
	print ''Comprobación OK. Tabla cli_actividad_economica con CLI_Cod_Act_AFIP ''

	if exists (select a.CODIGO_SECCION 
				from CLI_Cod_Act_AFIP a with(nolock)
				where a.CODIGO_SECCION not in (select b.CODIGO_SECCION 
												from CLI_SECCION  b with(nolock))
				)	
			select   ''Tabla CLI_Cod_Act_AFIP no se ajusta a la integridad referencial con CLI_SECCION '',*
			from CLI_Cod_Act_AFIP a with(nolock)
			where a.CODIGO_SECCION not in (select b.CODIGO_SECCION 
											from CLI_SECCION b with(nolock))
	else
	print ''Comprobación OK. Tabla CLI_Cod_Act_AFIP con CLI_SECCION ''

	if exists (select a.CODIGO_BCRA 
				from CLI_Cod_Act_AFIP a with(nolock)
				where a.CODIGO_BCRA not in (select b.CODIGO_BCRA 
											from CLI_Cod_Act_BCRA b with(nolock))
				)	
			select   ''Tabla CLI_Cod_Act_AFIP no se ajusta a la integridad referencial con CLI_Cod_Act_BCRA '',*
			from CLI_Cod_Act_AFIP a with(nolock)
			where a.CODIGO_BCRA not in (select b.CODIGO_BCRA 
										from CLI_Cod_Act_BCRA b with(nolock))
	else
	print ''Comprobación OK. Tabla CLI_Cod_Act_AFIP con CLI_Cod_Act_BCRA ''

	if exists (select a.CODIGO_SECTOR 
				from CLI_Cod_Act_AFIP a with(nolock) 
				where a.CODIGO_SECTOR not in (	select b.CODIGO_SECTOR 
												from CLI_ACTIVIDAD_SECTOR  b with(nolock))
				)	
			select   ''Tabla CLI_Cod_Act_AFIP no se ajusta a la integridad referencial con CLI_ACTIVIDAD_SECTOR '',*
			from CLI_Cod_Act_AFIP a with(nolock) 
			where a.CODIGO_SECTOR not in (	select b.CODIGO_SECTOR 
											from CLI_ACTIVIDAD_SECTOR b with(nolock))
	else
	print ''Comprobación OK. Tabla CLI_Cod_Act_AFIP con CLI_ACTIVIDAD_SECTOR ''

	if exists ( select a.PAIS 
				from CLI_DIRECCIONES a with(nolock)
				left join cli_localidades b on a.PROVINCIA = b.DIM1
												and a.DEPARTAMENTO = b.DIM2
												and a.LOCALIDAD = b.DIM3
												and a.PAIS = b.CODIGOPAIS

				where	b.DIM1 is null
					and b.DIM2 is null
					and b.DIM3 is null	
					and b.CODIGOPAIS is null
				)	
				select  ''Tabla CLI_DIRECCIONES no se ajusta a la integridad referencial con cli_localidades '',*
				from CLI_DIRECCIONES a with(nolock)
				left join cli_localidades b on a.PROVINCIA = b.DIM1
												and a.DEPARTAMENTO = b.DIM2
												and a.LOCALIDAD = b.DIM3


				where	b.DIM1 is null
					and b.DIM2 is null
					and b.DIM3 is null
					and b.CODIGOPAIS is null
	else
	print ''Comprobación OK. Tabla CLI_DIRECCIONES con cli_localidades ''
	

	if exists ( select	a.DIM2 
				from	cli_localidades a with(nolock)
				where	A.DIM2 NOT IN (SELECT b.departamento FROM cli_departamentos b with(nolock))			
				)	
			select  ''Tabla cli_localidades no se ajusta a la integridad referencial con cli_departamentos '',*
			from	cli_localidades a with(nolock)
			where	A.DIM2 NOT IN (SELECT b.departamento FROM cli_departamentos b with(nolock))
	else
	print ''Comprobación OK. Tabla cli_localidades con cli_departamentos ''

	if exists ( select	a.PAIS 
				from	cli_DIRECCIONES a with(nolock)
				where	A.PAIS NOT IN (SELECT b.codigoPAIS FROM CLI_PAISES b with(nolock))			
				)	
			select   ''Tabla CLI_DIRECCIONES no se ajusta a la integridad referencial con cli_Paises '',*
			from	cli_DIRECCIONES a with(nolock)
			where	A.PAIS NOT IN (SELECT b.codigoPAIS FROM CLI_PAISES b with(nolock))	
	else
	print ''Comprobación OK. Tabla CLI_DIRECCIONES con cli_Paises ''

	if exists ( select	a.provincia 
				from	cli_DIRECCIONES a with(nolock)
				where	A.provincia NOT IN (SELECT b.dim1 FROM CLI_PROVINCIAS b with(nolock))			
				)	
			select   ''Tabla CLI_DIRECCIONES no se ajusta a la integridad referencial con CLI_PROVINCIAS '',*
			from	cli_DIRECCIONES a with(nolock)
			where	A.provincia NOT IN (SELECT b.dim1 FROM CLI_PROVINCIAS b with(nolock))	
	else
	print ''Comprobación OK. Tabla CLI_DIRECCIONES con CLI_PROVINCIAS ''

	if exists ( select	a.departamento 
				from	cli_DIRECCIONES a with(nolock)
				where	A.departamento NOT IN (SELECT b.departamento FROM CLI_DEPARTAMENTOS b with(nolock))			
				)	
			select   ''Tabla CLI_DIRECCIONES no se ajusta a la integridad referencial con CLI_DEPARTAMENTOS '',*
			from	cli_DIRECCIONES a with(nolock)
			where	A.PAIS NOT IN (SELECT b.departamento FROM CLI_DEPARTAMENTOS b with(nolock))	
	else
	print ''Comprobación OK. Tabla CLI_DIRECCIONES con CLI_DEPARTAMENTOS ''

	if exists (select a.CODIGOPAIS 
				from CLI_PROVINCIAS a with(nolock)
				where a.CODIGOPAIS not in (	select b.CODIGOPAIS 
											from CLI_PAISES b with(nolock))
				)	
			select   ''Tabla CLI_PROVINCIAS no se ajusta a la integridad referencial con CLI_PAISES '',*
			from CLI_PROVINCIAS a with(nolock)
			where a.CODIGOPAIS not in (select b.CODIGOPAIS 
										from CLI_PAISES b with(nolock))
	else
	print ''Comprobación OK. Tabla CLI_PROVINCIAS con CLI_PAISES ''

	if exists ( select a.PROVINCIA 
				from cli_departamentos a with(nolock)
				where a.PROVINCIA not in (	select b.DIM1 
										from CLI_PROVINCIAs b with(nolock))
				)	
				select   ''Tabla cli_departamentos no se ajusta a la integridad referencial con CLI_PROVINCIAs '',*
				from cli_departamentos a with(nolock)
				where a.PROVINCIA not in (	select b.DIM1 
										from CLI_PROVINCIAs b with(nolock))
	else
	print ''Comprobación OK. Tabla cli_departamentos con CLI_PROVINCIAs ''

	if exists (select a.TIPO_ROL 
				from cli_vinculos a with(nolock)
				where a.TIPO_ROL not in (select b.TIPO_ROL 
										from CLI_ROLES b with(nolock))
				)	
				select   ''Tabla cli_vinculos no se ajusta a la integridad referencial con CLI_ROLES '',*
				from cli_vinculos a with(nolock)
				where a.TIPO_ROL not in (select b.TIPO_ROL 
										from CLI_ROLES b with(nolock))
	else
	print ''Comprobación OK. Tabla cli_vinculos con CLI_ROLES ''

	if exists (select a.VINCULO 
				from CLI_VINCULACIONES a with(nolock)
				where a.VINCULO not in (select b.ID 
										from CLI_VINCULOS b with(nolock))
				)	
			select   ''Tabla CLI_VINCULACIONES no se ajusta a la integridad referencial con CLI_VINCULOS '',*
			from CLI_VINCULACIONES a with(nolock)
			where a.VINCULO not in (select b.ID 
									from CLI_VINCULOS b with(nolock))
	else
	print ''Comprobación OK. Tabla CLI_VINCULACIONES con CLI_VINCULOS ''

	if exists (select a.ID 
				from CLI_VINCULOS a with(nolock)
				where a.VINCULO_PRIMARIO not in (select b.ID 
									from CLI_VINCULOS_PRIMARIOS  b with(nolock))
				)	
			select   ''Tabla CLI_VINCULOS no se ajusta a la integridad referencial con CLI_VINCULOS_PRIMARIOS '',*
			from CLI_VINCULOS a with(nolock)
			where a.VINCULO_PRIMARIO not in (select b.ID 
								from CLI_VINCULOS_PRIMARIOS b with(nolock))
	else
	print ''Comprobación OK. Tabla CLI_VINCULOS con CLI_VINCULOS_PRIMARIOS ''

	if exists (select a.ID 
				from CLI_VINCULOS a with(nolock)
				where a.VINCULO_SECUNDARIO not in (select b.ID 
									from CLI_VINCULOS_SECUNDARIOS b with(nolock))
				)	
			select   ''Tabla CLI_VINCULOS no se ajusta a la integridad referencial con CLI_VINCULOS_SECUNDARIOS '',*
			from CLI_VINCULOS a with(nolock)
			where a.VINCULO_SECUNDARIO not in (select b.ID 
								from CLI_VINCULOS_SECUNDARIOS b with(nolock))
	else
	print ''Comprobación OK. Tabla CLI_VINCULOS con CLI_VINCULOS_SECUNDARIOS ''

	if exists (	select a.NUMEROPERSONAFISICA 
				from CLI_PFCONYUGE a with(nolock)
				where a.NUMEROPERSONAFISICA not in (select b.PERSONA_VINCULADA 
													from CLI_VINCULACIONES b with(nolock))
				)	
			select   ''Tabla CLI_PFCONYUGE no se ajusta a la integridad referencial con CLI_VINCULACIONES '',*
			from CLI_PFCONYUGE a with(nolock)
			where a.NUMEROPERSONAFISICA not in (select b.PERSONA_VINCULADA 
												from CLI_VINCULACIONES b with(nolock))
	else
	print ''Comprobación OK. Tabla CLI_PFCONYUGE con CLI_VINCULACIONES ''

	if exists (	select a.NUMEROPERSONAFISICA 
				FROM CLI_INTEGRANTESPJ a with(nolock)
				WHERE a.NUMEROPERSONAFISICA NOT IN (	SELECT b.NUMEROPERSONAFISICA 
														FROM CLI_PERSONASFISICAS b with(nolock))
					AND
					  a.NUMEROPERSONAJURIDICA NOT IN(	SELECT b.NUMEROPERSONAJURIDICA 
														FROM CLI_PERSONASJURIDICAS b with(nolock))
				)	
				select   ''Tabla CLI_INTEGRANTESPJ no se ajusta a la integridad referencial con CLI_PERSONASFISICAS y CLI_PERSONASJURIDICAS''
				FROM CLI_INTEGRANTESPJ a with(nolock)
				WHERE a.NUMEROPERSONAFISICA NOT IN (	SELECT b.NUMEROPERSONAFISICA 
														FROM CLI_PERSONASFISICAS b with(nolock))
					AND
						a.NUMEROPERSONAJURIDICA NOT IN( SELECT b.NUMEROPERSONAJURIDICA 
														FROM CLI_PERSONASJURIDICAS b with(nolock))
	else
	print ''Comprobación OK. Tabla CLI_INTEGRANTESPJ con CLI_PERSONASFISICAS y CLI_PERSONASJURIDICAS ''

	if exists (	SELECT * 
				FROM CLI_PERSONASJURIDICAS b with(nolock)
				WHERE b.SECTOR NOT IN (	select a.SECTOR 
										FROM CLI_SECTORES a with(nolock))
				)	
			select   ''Tabla CLI_PERSONASJURIDICAS no se ajusta a la integridad referencial con CLI_SECTORES '',*
			FROM CLI_PERSONASJURIDICAS b with(nolock)
			WHERE b.SECTOR NOT IN (	select a.SECTOR 
									FROM CLI_SECTORES a with(nolock))
	else
			print ''Comprobación OK. Tabla CLI_PERSONASJURIDICAS con CLI_SECTORES ''

	if exists (	SELECT b.SECTOR 
				FROM CLI_PERSONASFISICAS b with(nolock)
				WHERE b.SECTOR NOT IN (	select a.SECTOR 
										FROM CLI_SECTORES a with(nolock))
				)	
			select   ''Tabla CLI_PERSONASFISICAS no se ajusta a la integridad referencial con CLI_SECTORES '',*
			FROM CLI_PERSONASFISICAS b with(nolock)
			WHERE b.SECTOR NOT IN (	select a.SECTOR 
									FROM CLI_SECTORES a with(nolock))
	else
	print ''Comprobación OK. Tabla CLI_PERSONASFISICAS con CLI_SECTORES ''

	if exists (	select a.ID_PERSONA 
				from CLI_INGRESOS_ANUALES a with(nolock)
				where a.ID_PERSONA not in (	select b.NUMEROPERSONAJURIDICA 
											from CLI_PERSONASJURIDICAS b with(nolock))
				)	
				select   ''Tabla CLI_INGRESOS_ANUALES no se ajusta a la integridad referencial con CLI_PERSONASJURIDICAS '',*
				from CLI_INGRESOS_ANUALES a with(nolock)
				where a.ID_PERSONA not in (	select b.NUMEROPERSONAJURIDICA 
											from CLI_PERSONASJURIDICAS b with(nolock))
	else
	print ''Comprobación OK. Tabla CLI_INGRESOS_ANUALES con CLI_PERSONASJURIDICAS ''

	if exists (	select a.NUMERO_PERSONA 
				from ITF_MATRIZ_IGR a with(nolock) 
				where a.NUMERO_PERSONA not in (	select b.NUMEROPERSONAJURIDICA  
												from CLI_PERSONASJURIDICAS b with(nolock)
												union all 
												select c.numeropersonafisica
												from cli_personasfisicas c with(nolock))
				)	
			select   ''Tabla ITF_MATRIZ_IGR no se ajusta a la integridad referencial con CLI_PERSONASJURIDICAS y CLI_PERSONASFISICAS '',*
			from ITF_MATRIZ_IGR a with(nolock) 
			where a.NUMERO_PERSONA not in (	select b.NUMEROPERSONAJURIDICA  
											from CLI_PERSONASJURIDICAS b with(nolock)
											union all 
											select c.numeropersonafisica
											from cli_personasfisicas c with(nolock)
											)
	else
		print ''Comprobación OK. Tabla ITF_MATRIZ_IGR con CLI_PERSONASJURIDICAS y CLI_PERSONASFISICAS ''


	if exists (	select a.ID_PERSONA
		from CLI_PERFILDOCUMENTAL  a with(nolock)
		where a.ID_PERSONA not in (	select b.NUMEROPERSONAJURIDICA
									from CLI_PERSONASJURIDICAS b with(nolock)
									union all 
									select c.NUMEROPERSONAFISICA
									from CLI_PERSONASFISICAS c with(nolock))

				)	
		select   ''Tabla CLI_PERFILDOCUMENTAL no se ajusta a la integridad referencial con CLI_PERSONASJURIDICAS o CLI_PERSONASFISICAS '',*
		from CLI_PERFILDOCUMENTAL  a with(nolock)
		where a.ID_PERSONA not in (	select b.NUMEROPERSONAJURIDICA
									from CLI_PERSONASJURIDICAS b with(nolock)
									union all 
									select c.NUMEROPERSONAFISICA
									from CLI_PERSONASFISICAS c with(nolock))
	else
	print ''Comprobación OK. Tabla CLI_PERFILDOCUMENTAL con CLI_PERSONASJURIDICAS o CLI_PERSONASFISICAS ''

	if exists (	select a.TIPODOCUMENTO 
				from CLI_DocumentosPFPJ a with(nolock)
				where a.TIPODOCUMENTO not in (select b.TIPODOCUMENTO 
											from CLI_TIPOSDOCUMENTOS b with(nolock))
				)	
			select   ''Tabla CLI_DocumentosPFPJ no se ajusta a la integridad referencial con CLI_TIPOSDOCUMENTOS '',*
			from CLI_DocumentosPFPJ a with(nolock)
			where a.TIPODOCUMENTO not in (	select b.TIPODOCUMENTO 
											from CLI_TIPOSDOCUMENTOS b with(nolock))
	else
	print ''Comprobación OK. Tabla CLI_DocumentosPFPJ con CLI_TIPOSDOCUMENTOS ''


	if exists (	select a.TIPODOC_IDENT 
				from CLI_TIPOS_DOC_FISICOS  a with(nolock)
				where a.TIPODOC_IDENT not in (	select b.TIPODOCUMENTO
												from CLI_TIPOSDOCUMENTOS b with(nolock))
				)	
				select   ''Tabla CLI_TIPOS_DOC_FISICOS no se ajusta a la integridad referencial con CLI_TIPOSDOCUMENTOS '',*
				from CLI_TIPOS_DOC_FISICOS  a with(nolock)
				where a.TIPODOC_IDENT not in (	select b.TIPODOCUMENTO
												from CLI_TIPOSDOCUMENTOS b with(nolock))
	else
			print ''Comprobación OK. Tabla CLI_TIPOS_DOC_FISICOS con CLI_TIPOSDOCUMENTOS ''
	if exists (	select a.CODIGO_DOCUMENTO
				from CLI_DOCUMENTOS_PERSONAS a with(nolock)
				where a.CODIGO_DOCUMENTO not in (	select b.CODIGO_DOCUMENTO
													from CLI_DOCUMENTOS  b with(nolock))
				)	
				select    ''Tabla CLI_DOCUMENTOS_PERSONAS no se ajusta a la integridad referencial con CLI_DOCUMENTOS '',*
				from CLI_DOCUMENTOS_PERSONAS a with(nolock)
				where a.CODIGO_DOCUMENTO not in (	select b.CODIGO_DOCUMENTO
													from CLI_DOCUMENTOS  b with(nolock))
	else
		print ''Comprobación OK. Tabla CLI_DOCUMENTOS_PERSONAS con CLI_DOCUMENTOS ''

	if exists (	select a.NUMEROPERSONAFJ 
				from CLI_DocumentosPFPJ  a  with(nolock)
				where a.NUMEROPERSONAFJ not in (select b.NUMEROPERSONAJURIDICA
												from CLI_PERSONASJURIDICAS b with(nolock)
												union all
												select c.NUMEROPERSONAFISICA 
												from CLI_PERSONASFISICAS c with(nolock))
				)	
			select   ''Tabla CLI_DocumentosPFPJ no se ajusta a la integridad referencial con CLI_PERSONASJURIDICAS O CLI_PERSONASFISICAS '',*
			from CLI_DocumentosPFPJ  a  with(nolock)
			where a.NUMEROPERSONAFJ not in (select b.NUMEROPERSONAJURIDICA
											from CLI_PERSONASJURIDICAS b with(nolock)
											union all
											select c.NUMEROPERSONAFISICA 
											from CLI_PERSONASFISICAS c with(nolock))
	else
			print ''Comprobación OK. Tabla CLI_DocumentosPFPJ con CLI_PERSONASJURIDICAS O CLI_PERSONASFISICAS ''

	if exists (	select A.COD_PROFESION 
				from CLI_PERSONASFISICAS A with(nolock)
				WHERE A.COD_PROFESION NOT IN (	select B.PROFESION 
												from CLI_PROFESIONES B with(nolock))
				)	
			select   ''Tabla CLI_PERSONASFISICAS no se ajusta a la integridad referencial con CLI_PROFESIONES '',*
			from CLI_PERSONASFISICAS A with(nolock)
			WHERE A.COD_PROFESION NOT IN (	select B.PROFESION 
											from CLI_PROFESIONES B with(nolock))
	else
			print ''Comprobación OK. Tabla CLI_PERSONASFISICAS con CLI_PROFESIONES ''

	if exists (	select a.SUCURSALVINCULADA
				from CLI_CLIENTES  a with(nolock)
				where a.SUCURSALVINCULADA not in (	select b.SUCURSAL
													from SUCURSALES b with(nolock))
				)	
				select    ''Tabla CLI_CLIENTES no se ajusta a la integridad referencial con SUCURSALES '',*
				from CLI_CLIENTES  a with(nolock)
				where a.SUCURSALVINCULADA not in (	select b.SUCURSAL
													from SUCURSALES b with(nolock))
	else
	print ''Comprobación OK. Tabla CLI_CLIENTES con SUCURSALES ''

	if exists (	select a.GRUPOAFINIDAD
				from CLI_CLIENTES  a with(nolock)
				where a.GRUPOAFINIDAD not in (	select b.CODIGOGRUPOAFINIDAD
												from CLI_GRUPOSAFINIDAD b with(nolock))
				)	
				select    ''Tabla CLI_CLIENTES no se ajusta a la integridad referencial con CLI_GRUPOSAFINIDAD '',*
				from CLI_CLIENTES  a with(nolock)
				where a.GRUPOAFINIDAD not in (	select b.CODIGOGRUPOAFINIDAD
												from CLI_GRUPOSAFINIDAD b with(nolock))
	else
	print ''Comprobación OK. Tabla CLI_CLIENTES con CLI_GRUPOSAFINIDAD ''

	if exists (	select a.CODIGOCLIENTE
				from CLI_SUCESIONES  a  with(nolock)
				where a.CODIGOCLIENTE not in (	select b.CODIGOCLIENTE
												from CLI_CLIENTES b with(nolock))
				)	
				select   ''Tabla CLI_SUCESIONES no se ajusta a la integridad referencial con CLI_CLIENTES '',*
				from CLI_SUCESIONES  a  with(nolock)
				where a.CODIGOCLIENTE not in (	select b.CODIGOCLIENTE
												from CLI_CLIENTES b with(nolock))
	else
	print ''Comprobación OK. Tabla CLI_SUCESIONES con CLI_CLIENTES ''

	if exists (	select a.NUMEROPERSONAFJ 
				from CLI_DocumentosPFPJ  a with(nolock)
				inner join CLI_CONCURSO_ACREEDORES b with(nolock)
					on b.CUIT_CUIL = a.NUMERODOCUMENTO
				where  a.NUMEROPERSONAFJ not in (select c.NUMEROPERSONAFISICA 
												from CLI_PERSONASFISICAS c with(nolock)
												union all
												select c.NUMEROPERSONAJURIDICA 
												from CLI_PERSONASJURIDICAS c with(nolock)
												)
				)	
				select   ''Tabla CLI_CONCURSO_ACREEDORES no se ajusta a la integridad referencial con CLI_PERSONASFISICAS O CLI_PERSONASJURIDICAS '',*
				from CLI_DocumentosPFPJ  a with(nolock)
				inner join CLI_CONCURSO_ACREEDORES b with(nolock)
					on b.CUIT_CUIL = a.NUMERODOCUMENTO
				where  a.NUMEROPERSONAFJ not in (	select c.NUMEROPERSONAFISICA 
													from CLI_PERSONASFISICAS c with(nolock)
													union all
													select c.NUMEROPERSONAJURIDICA 
													from CLI_PERSONASJURIDICAS c with(nolock)
												)
	else
	print ''Comprobación OK. Tabla CLI_CONCURSO_ACREEDORES con CLI_PERSONASFISICAS O CLI_PERSONASJURIDICAS ''

	if exists (	select a.CUIT 
				from ITF_BCRA_PADFYJ a with(nolock)
				inner join CLI_DocumentosPFPJ b with(nolock) on a.cuit = b.NUMERODOCUMENTO
				where b.NUMEROPERSONAFJ not in (select b.NUMEROPERSONAFISICA 
												from CLI_PERSONASFISICAS b with(nolock)
											UNION ALL 
												SELECT C.NUMEROPERSONAJURIDICA 
												FROM CLI_PERSONASJURIDICAS C WITH (NOLOCK))
								
				)	
			select   ''Tabla ITF_BCRA_PADFYJ no se ajusta a la integridad referencial con CLI_PERSONASFISICAS o CLI_PERSONASJURIDICAS '',*
				from ITF_BCRA_PADFYJ a with(nolock)
				inner join CLI_DocumentosPFPJ b with(nolock) on a.cuit = b.NUMERODOCUMENTO
				where b.NUMEROPERSONAFJ not in (	select b.NUMEROPERSONAFISICA 
													from CLI_PERSONASFISICAS b with(nolock)
												UNION ALL 
													SELECT C.NUMEROPERSONAJURIDICA 
													FROM CLI_PERSONASJURIDICAS C WITH (NOLOCK))
	else
	print ''Comprobación OK. Tabla ITF_BCRA_PADFYJ con CLI_PERSONASFISICAS o CLI_PERSONASJURIDICAS''

	if exists (	SELECT A.CUIT 
				FROM CLI_INHABILITADOS_INAES A with(nolock)
				INNER JOIN CLI_DocumentosPFPJ B with(nolock) ON A.CUIT = B.NUMERODOCUMENTO
				WHERE B.NUMERODOCUMENTO NOT IN (	select b.NUMEROPERSONAJURIDICA
													from CLI_PERSONASJURIDICAS b with(nolock)
												union all 
													select c.NUMEROPERSONAFISICA
													from CLI_PERSONASFISICAS c with(nolock))
				)	
				select   ''Tabla CLI_INHABILITADOS_INAES no se ajusta a la integridad referencial con CLI_PERSONASFISICAS o CLI_PERSONASJURIDICAS'',*
				FROM CLI_INHABILITADOS_INAES A with(nolock)
				INNER JOIN CLI_DocumentosPFPJ B with(nolock) ON A.CUIT = B.NUMERODOCUMENTO
				WHERE B.NUMERODOCUMENTO NOT IN (	select b.NUMEROPERSONAJURIDICA
														from CLI_PERSONASJURIDICAS b with(nolock)
													union all 
														select c.NUMEROPERSONAFISICA
														from CLI_PERSONASFISICAS c with(nolock))
	else
	print ''Comprobación OK. Tabla CLI_INHABILITADOS_INAES con CLI_PERSONASFISICAS o CLI_PERSONASJURIDICAS ''

	if exists (	SELECT A.CUIT_CUIL
				FROM CLI_INHABILITADOS_UIF A with(nolock)
				INNER JOIN CLI_DocumentosPFPJ B with(nolock) ON A.CUIT_CUIL = B.NUMERODOCUMENTO 
																AND A.TIPODOCUMENTO= B.TIPODOCUMENTO 
																AND  A.TIPOPERSONA = B.TIPOPERSONA
				WHERE B.NUMERODOCUMENTO NOT IN (	select b.NUMEROPERSONAJURIDICA
													from CLI_PERSONASJURIDICAS b with(nolock)
												union all 
													select c.NUMEROPERSONAFISICA
													from CLI_PERSONASFISICAS c with(nolock))
				)	
			select    ''Tabla CLI_INHABILITADOS_UIF no se ajusta a la integridad referencial con CLI_PERSONASJURIDICAS o CLI_PERSONASFISICAS '',*
			FROM CLI_INHABILITADOS_UIF A with(nolock)
			INNER JOIN CLI_DocumentosPFPJ B with(nolock) ON A.CUIT_CUIL = B.NUMERODOCUMENTO 
															AND A.TIPODOCUMENTO= B.TIPODOCUMENTO 
															AND  A.TIPOPERSONA = B.TIPOPERSONA
			WHERE B.NUMERODOCUMENTO NOT IN (		select b.NUMEROPERSONAJURIDICA
													from CLI_PERSONASJURIDICAS b with(nolock)
												union all 
													select c.NUMEROPERSONAFISICA
													from CLI_PERSONASFISICAS c with(nolock))
	else
	print ''Comprobación OK. Tabla CLI_INHABILITADOS_UIF con CLI_PERSONASJURIDICAS o CLI_PERSONASFISICAS ''

	if exists (	select a.DOCUMENTO 
				from CLI_LISTA_BLANCA a with(nolock)
				inner join CLI_DocumentosPFPJ b on a.TIPO_DOCUMENTO = b.tipodocumento 
												and a.DOCUMENTO = b.NUMERODOCUMENTO
				where b.NUMEROPERSONAFJ not in (	select b.NUMEROPERSONAJURIDICA
													from CLI_PERSONASJURIDICAS b with(nolock)
												union all 
													select c.NUMEROPERSONAFISICA
													from CLI_PERSONASFISICAS c with(nolock))
				)	
		select   ''Tabla CLI_LISTA_BLANCA no se ajusta a la integridad referencial con CLI_PERSONASFISICAS o CLI_PERSONASJURIDICAS '',*
		from CLI_LISTA_BLANCA a with(nolock)
		inner join CLI_DocumentosPFPJ b on a.TIPO_DOCUMENTO = b.tipodocumento 
										and a.DOCUMENTO = b.NUMERODOCUMENTO
		where b.NUMEROPERSONAFJ not in (	select b.NUMEROPERSONAJURIDICA
											from CLI_PERSONASJURIDICAS b with(nolock)
										union all 
											select c.NUMEROPERSONAFISICA
											from CLI_PERSONASFISICAS c with(nolock))
	else
	print ''Comprobación OK. Tabla CLI_LISTA_BLANCA con CLI_PERSONASFISICAS o CLI_PERSONASJURIDICAS''

/*  ''Maestro fallecidos son todos y pueden haber personas sin ser clientes''
	if exists (	select a.CUIL 
				from CLI_MAESTRO_FALLECIDOS a with(nolock)
				inner join CLI_DocumentosPFPJ b with(nolock)on a.CUIL = b.NUMERODOCUMENTO
				where b.NUMEROPERSONAFJ not in (select c.NUMEROPERSONAFISICA
												from CLI_PERSONASFISICAS c with(nolock))
				)	
		select   ''Tabla CLI_MAESTRO_FALLECIDOS no se ajusta a la integridad referencial con CLI_PERSONASFISICAS '',*
		from CLI_MAESTRO_FALLECIDOS a with(nolock)
					inner join CLI_DocumentosPFPJ b with(nolock)on a.CUIL = b.NUMERODOCUMENTO
					where b.NUMEROPERSONAFJ not in (select c.NUMEROPERSONAFISICA
													from CLI_PERSONASFISICAS c with(nolock))
	else
	print ''Comprobación OK. Tabla CLI_MAESTRO_FALLECIDOS con CLI_PERSONASFISICAS ''
*/ 

	if exists (select a.CODIGOCLIENTE 
				from CLI_ClientePersona a with(nolock) 
				where a.CODIGOCLIENTE not in (select b.CODIGOCLIENTE 
												from CLI_clientes b with(nolock))

				)	
		select   ''Tabla CLI_ClientePersona no se ajusta a la integridad referencial con CLI_clientes '',*
		from CLI_ClientePersona a with(nolock) 
		where a.CODIGOCLIENTE not in (select b.CODIGOCLIENTE 
										from CLI_clientes b with(nolock))
	else
	print ''Comprobación OK. Tabla CLI_ClientePersona con CLI_clientes ''

	if exists (select b.CODIGOCLIENTE 
				from CLI_clientes b with(nolock)
				where b.CODIGOCLIENTE not in (select a.CODIGOCLIENTE 
												from CLI_ClientePersona a with(nolock))
				)	
		select   ''Tabla CLI_clientes no se ajusta a la integridad referencial con CLI_ClientePersona '',* 
		from CLI_clientes b with(nolock)
		where b.CODIGOCLIENTE not in (select a.CODIGOCLIENTE 
										from CLI_ClientePersona a with(nolock))
	else
	print ''Comprobación OK. Tabla CLI_clientes con CLI_ClientePersona ''

	if exists (select a.numeropersona 
				from CLI_ClientePersona a with(nolock) 
				where a.numeropersona not in (	select b.NUMEROPERSONAFISICA 
												from CLI_PERSONASFISICAS b with(nolock)
											UNION ALL 
												SELECT C.NUMEROPERSONAJURIDICA 
												FROM CLI_PERSONASJURIDICAS C WITH (NOLOCK))
				)	
				select   ''Tabla CLI_ClientePersona no se ajusta a la integridad referencial con CLI_PERSONASFISICAS O CLI_PERSONASJURIDICAS '',*
				from CLI_ClientePersona a with(nolock) 
				where a.numeropersona not in (	select b.NUMEROPERSONAFISICA 
												from CLI_PERSONASFISICAS b with(nolock)
											UNION ALL 
												SELECT C.NUMEROPERSONAJURIDICA 
												FROM CLI_PERSONASJURIDICAS C WITH (NOLOCK))
	else
	print ''Comprobación OK. Tabla CLI_ClientePersona con CLI_PERSONASFISICAS O CLI_PERSONASJURIDICAS ''

	if exists (	select a.COD_CLIENTE
				from CLI_CORRESPONSALES a
				where a.COD_CLIENTE not in (select b.CODIGOCLIENTE 
											from CLI_INSTITUCIONFINANCIERA b)
				)
		select    ''Tabla CLI_CORRESPONSALES no cumple la integridad referencial con CLI_INSTITUCIONFINANCIERA  '',* 
		from CLI_CORRESPONSALES a
		where a.COD_CLIENTE not in (select b.CODIGOCLIENTE 
									from CLI_INSTITUCIONFINANCIERA b)
	else
	print ''Comprobación OK. Tabla CLI_CORRESPONSALES con CLI_INSTITUCIONFINANCIERA ''

	if exists (	select a.EJECUTIVOCLIENTE
				from cli_clientes a
				where a.EJECUTIVOCLIENTE not in (select b.CODOFICIAL
											from cli_oficuenta  b)
				)
				select    ''Tabla cli_clientes no cumple la integridad referencial con cli_oficuenta  '',* 
				from cli_clientes a
				where a.EJECUTIVOCLIENTE not in (	select b.CODOFICIAL
													from cli_oficuenta  b)
	else
	print ''Comprobación OK. Tabla cli_clientes con cli_oficuenta ''

	if exists (	select a.ID 
				from cli_vinculaciones a with(nolock) 
				where a.id not in (
				select b.id 
				from CLI_RIESGOS_CREDITICIOS b with(nolock))
				)
				select    ''Tabla cli_vinculaciones no cumple la integridad referencial con CLI_RIESGOS_CREDITICIOS  '',* 
				from cli_vinculaciones a with(nolock) 
				where a.id not in (
				select b.id 
				from CLI_RIESGOS_CREDITICIOS b with(nolock))
	else
	print ''Comprobación OK. Tabla cli_vinculaciones con CLI_RIESGOS_CREDITICIOS ''

	if exists (	select a.CALIFICACION_EXTERNA 
				from CLI_CLIENTES a with(nolock) 
				where a.CALIFICACION_EXTERNA not in (
													select b.CALIFICADORA
													from CRE_CALIF_CALIFICADORAS b with(nolock))
				)
				select  ''Tabla CLI_CLIENTES no cumple la integridad referencial con CRE_CALIF_CALIFICADORAS  '',* 
				from CLI_CLIENTES a with(nolock) 
				where a.CALIFICACION_EXTERNA not in (
													select b.CALIFICADORA
													from CRE_CALIF_CALIFICADORAS b with(nolock))
	else
	print ''Comprobación OK. Tabla CLI_CLIENTES con CRE_CALIF_CALIFICADORAS ''

	if exists (	select a.CALIFICACION_EXTERNA 
				from CLI_CLIENTES a with(nolock) 
				where a.GRUPOECONOMICO not in (	select b.CODIGOGRUPOECONOMICO
												from CLI_GruposEconomicos b with(nolock))
				)
				select  ''Tabla CLI_CLIENTES no cumple la integridad referencial con CLI_GruposEconomicos  '',* 
				from CLI_CLIENTES a with(nolock) 
				where a.GRUPOECONOMICO not in (
													select b.CODIGOGRUPOECONOMICO
													from CLI_GruposEconomicos b with(nolock))
	else
	print ''Comprobación OK. Tabla CLI_CLIENTES con CLI_GruposEconomicos ''

	if exists (	select a.CODIGOCLIENTE 
				from CLI_GruposEconomicosCliente a with(nolock) 
				where a.CODIGOCLIENTE not in (	select b.CODIGOCLIENTE
												from CLI_CLIENTES b with(nolock))
				)
				select  ''Tabla CLI_GruposEconomicosCliente no cumple la integridad referencial con CLI_CLIENTES  '',* 
				from CLI_GruposEconomicosCliente a with(nolock) 
				where a.CODIGOCLIENTE not in (
													select b.CODIGOCLIENTE
													from CLI_CLIENTES b with(nolock))
	else
	print ''Comprobación OK. Tabla CLI_GruposEconomicosCliente con CLI_CLIENTES ''

	if exists (	select a.CATEGORIASUBJETIVA 
				from CLI_CLIENTES a with(nolock) 
				where a.CATEGORIASUBJETIVA not in (	select b.categoriasub
												from CLI_CLASubjetiva b with(nolock))
				)
				select  ''Tabla CLI_Cliente no cumple la integridad referencial con CLI_CLASubjetiva  '',* 
				from CLI_CLIENTES a with(nolock) 
				where a.CODIGOCLIENTE not in (
													select b.categoriasub
													from CLI_CLASubjetiva b with(nolock))
	else
	print ''Comprobación OK. Tabla CLI_Cliente con CLI_CLASubjetiva ''

	if exists (	select a.INTERMEDIACIONFINANCIERA 
				from CLI_CLIENTES a with(nolock) 
				where a.INTERMEDIACIONFINANCIERA not in (	select b.INTERMED
												from CLI_INTERMED_FINANC b with(nolock))
				)
				select  ''Tabla CLI_Cliente no cumple la integridad referencial con CLI_INTERMED_FINANC  '',* 
				from CLI_CLIENTES a with(nolock) 
				where a.INTERMEDIACIONFINANCIERA not in (
													select b.INTERMED
													from CLI_INTERMED_FINANC b with(nolock))
	else
	print ''Comprobación OK. Tabla CLI_Cliente con CLI_INTERMED_FINANC ''
	if exists (	select a.numeropersonafisica 
				from CLI_HIST_FALLECIDOS a with(nolock) 
				where a.numeropersonafisica not in (	select b.NUMEROPERSONAFISICA
												from CLI_PERSONASFISICAS b with(nolock))
				)
				select  ''Tabla CLI_Cliente no cumple la integridad referencial con CLI_INTERMED_FINANC  '',* 
				from CLI_HIST_FALLECIDOS a with(nolock) 
				where a.numeropersonafisica not in (
													select b.NUMEROPERSONAFISICA
													from CLI_PERSONASFISICAS b with(nolock))
	else
	print ''Comprobación OK. Tabla CLI_Cliente con CLI_INTERMED_FINANC ''

	if exists (	select a.TIPOSOCIEDAD 
				from CLI_PERSONASJURIDICAS a with(nolock) 
				where a.TIPOSOCIEDAD not in (	select b.TIPO_SOCIEDAD
												from CLI_ROLES_OBL_CARGO b with(nolock))
				)
				select  ''Tabla CLI_PERSONASJURIDICAS no cumple la integridad referencial con CLI_ROLES_OBL_CARGO  '',* 
				from CLI_PERSONASJURIDICAS a with(nolock) 
				where a.TIPOSOCIEDAD not in (
													select b.TIPO_SOCIEDAD
													from CLI_ROLES_OBL_CARGO b with(nolock))
	else
	print ''Comprobación OK. Tabla CLI_PERSONASJURIDICAS con CLI_ROLES_OBL_CARGO ''

	if exists (	select a.CARGO_CONTACTO 
				from CLI_PERSONASJURIDICAS a with(nolock) 
				where a.CARGO_CONTACTO not in (	select b.CARGO
												from CLI_CARGOS_PERSONAS b with(nolock))
				)
				select  ''Tabla CLI_PERSONASJURIDICAS no cumple la integridad referencial con CLI_CARGOS_PERSONAS  '',* 
				from CLI_PERSONASJURIDICAS a with(nolock) 
				where a.CARGO_CONTACTO not in (
													select b.CARGO
													from CLI_CARGOS_PERSONAS b with(nolock))
	else
	print ''Comprobación OK. Tabla CLI_PERSONASJURIDICAS con CLI_CARGOS_PERSONAS ''

	---------------------------------------------------------------------------------------------------
	END
ELSE
	print ''NO CORRESPONDE LA BASE DE DATOS''
END
; ')
