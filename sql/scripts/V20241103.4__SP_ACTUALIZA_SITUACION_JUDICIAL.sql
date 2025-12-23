EXECUTE('
ALTER PROCEDURE [dbo].[SP_ACTUALIZA_SITUACION_JUDICIAL]
	@p_id_proceso FLOAT(53),     /* Identificador de proceso */
	@p_dt_proceso DATETIME,   /* Fecha de proceso */
	@p_ret_proceso FLOAT OUT, /* Estado de ejecucion SQL(0:Correcto, 2: Error) */
	@p_msg_proceso VARCHAR(MAX) OUT
AS
BEGIN
	DECLARE 
	------- Campos para el LOG --------
	@c_log_tipo_error varchar(30),
	@c_log_tipo_informacion VARCHAR(30),
	-----------------------------------	
	@contador NUMERIC(10)
	SET @contador = 0;
	------- Campos para el LOG --------
	SET @c_log_tipo_error = ''E'';
	SET @c_log_tipo_informacion = ''I'';
	-----------------------------------	

	BEGIN TRY
        	  
		SET @contador =	(SELECT count(1)
			FROM VW_CLI_X_DOC c WITH (NOLOCK)
			INNER JOIN CLI_CLIENTES cli WITH (NOLOCK) ON cli.CODIGOCLIENTE = c.CODIGOCLIENTE AND cli.TZ_LOCK = 0
			INNER JOIN CLI_ClientePersona cp WITH (NOLOCK) ON c.CODIGOCLIENTE = cp.CODIGOCLIENTE AND cp.TITULARIDAD = ''T'' AND cp.TZ_LOCK = 0
			INNER JOIN (SELECT pf.NUMEROPERSONAFISICA AS PERSONA FROM CLI_PERSONASFISICAS pf WITH (NOLOCK) WHERE pf.CONC_ACREEDORES = ''S'' AND pf.TZ_LOCK = 0
						UNION
						SELECT pj.NUMEROPERSONAJURIDICA AS PERSONA FROM CLI_PERSONASJURIDICAS pj WITH (NOLOCK) WHERE pj.CONC_ACREEDORES = ''S'' AND pj.TZ_LOCK = 0) p 
			ON cp.NUMEROPERSONA = p.PERSONA 
			INNER JOIN CLI_CONCURSO_ACREEDORES ca WITH (NOLOCK) ON c.TIPODOC = ca.TIPODOCUMENTO AND c.NUMERODOC = ca.CUIT_CUIL AND ca.CONC_ACREEDORES = ''S'' AND ca.TZ_LOCK = 0 AND
			ca.FECHA_INGRESO <= (SELECT FECHAPROCESO FROM PARAMETROS WITH (NOLOCK)) AND ((CA.FECHA_FIN IS NOT NULL AND ca.FECHA_FIN >= (SELECT FECHAPROCESO FROM PARAMETROS WITH (NOLOCK))) OR ca.FECHA_FIN IS NULL)				
			WHERE (cli.CATEGORIAOBJETIVA <> '' '' AND cli.OBJETIVA_REFINANCIADO <> '' ''))
			
		IF @contador > 0
		BEGIN
			UPDATE c
			SET c.SITUACION_JUDICIAL = a.CALIF
			FROM CLI_CLIENTES c WITH (NOLOCK)
			INNER JOIN (SELECT CASE WHEN datediff(DAY,ca.FECHA_INGRESO,(SELECT FECHAPROCESO FROM PARAMETROS WITH (NOLOCK))) > (SELECT DIASINMOVILIZADA FROM CRE_PARAMETROS WITH (NOLOCK) WHERE CODIGO = 166) THEN ''5'' ELSE ''4'' END AS CALIF, c.CODIGOCLIENTE
			FROM VW_CLI_X_DOC c WITH (NOLOCK)
			INNER JOIN CLI_ClientePersona cp WITH (NOLOCK) ON c.CODIGOCLIENTE = cp.CODIGOCLIENTE AND cp.TITULARIDAD = ''T'' AND cp.TZ_LOCK = 0
			INNER JOIN (SELECT pf.NUMEROPERSONAFISICA AS PERSONA FROM CLI_PERSONASFISICAS pf WITH (NOLOCK) WHERE pf.CONC_ACREEDORES = ''S'' AND pf.TZ_LOCK = 0
						UNION
						SELECT pj.NUMEROPERSONAJURIDICA AS PERSONA FROM CLI_PERSONASJURIDICAS pj WITH (NOLOCK) WHERE pj.CONC_ACREEDORES = ''S'' AND pj.TZ_LOCK = 0) p 
			ON cp.NUMEROPERSONA = p.PERSONA 
			INNER JOIN CLI_CONCURSO_ACREEDORES ca WITH (NOLOCK) ON c.TIPODOC = ca.TIPODOCUMENTO AND c.NUMERODOC = ca.CUIT_CUIL AND ca.CONC_ACREEDORES = ''S'' AND ca.TZ_LOCK = 0 AND
			ca.FECHA_INGRESO <= (SELECT FECHAPROCESO FROM PARAMETROS WITH (NOLOCK)) AND ((CA.FECHA_FIN IS NOT NULL AND ca.FECHA_FIN >= (SELECT FECHAPROCESO FROM PARAMETROS WITH (NOLOCK))) OR ca.FECHA_FIN IS NULL)) a
			ON a.CODIGOCLIENTE = c.CODIGOCLIENTE
			WHERE (c.CATEGORIAOBJETIVA <> '' '' AND c.OBJETIVA_REFINANCIADO <> '' '') AND c.TZ_LOCK = 0		END
		  
		    SET @p_msg_proceso = ''El Proceso de Actualización de Situacion Judicial ha finalizado correctamente. Registros procesados: ''+ CONVERT(VARCHAR(10), @contador)
			SET @p_ret_proceso = 1 		
			
			-- Logueo de información
			EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso 
				@p_id_proceso,
		    	@p_dt_proceso,
		    	''SP_ACTUALIZA_SITUACION_JUDICIAL'',
		    	@p_cod_error = @p_ret_proceso, 
				@p_msg_error = @p_msg_proceso, 
				@p_tipo_error = @c_log_tipo_informacion
		END TRY
							             
		BEGIN CATCH
	
	        SET @p_ret_proceso = ERROR_NUMBER()
	        SET @p_msg_proceso = ''Ocurrió un error en el Proceso de Actualización de Situacion Judicial: '' + ERROR_MESSAGE()
	
			EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso 
	        	@p_id_proceso = @p_id_proceso, 
	        	@p_fch_proceso = @p_dt_proceso, 
	        	@p_nom_package = ''SP_ACTUALIZA_SITUACION_JUDICIAL'', 
	        	@p_cod_error = @p_ret_proceso, 
	        	@p_msg_error = @p_msg_proceso, 
	       		@p_tipo_error = @c_log_tipo_informacion
		END CATCH
END
')