EXECUTE('
ALTER PROCEDURE [dbo].[SP_ACTUALIZA_MOROSOS_SITUACION]
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
	@contador NUMERIC(10),
	@contadorLimpiar NUMERIC(10),
	@contadorNoDatos NUMERIC(10)
	SET @contador = 0;
	SET @contadorLimpiar = 0;
	SET @contadorNoDatos = 0;
	------- Campos para el LOG --------
	SET @c_log_tipo_error = ''E'';
	SET @c_log_tipo_informacion = ''I'';
	-----------------------------------	

	BEGIN TRY

		SET @contadorLimpiar =(SELECT count(1) FROM CRE_BCRA_MOREXENT WITH (NOLOCK) WHERE FECHA_PROCESO <> (SELECT FECHAPROCESO FROM PARAMETROS WITH (NOLOCK)) AND TZ_LOCK = 0)   

		SET @contador =	(SELECT count(1)			
		FROM CLI_CLIENTES c WITH (NOLOCK)
		INNER JOIN (SELECT CODIGOCLIENTE FROM CRE_BCRA_MOREXENT WITH (NOLOCK) WHERE FECHA_PROCESO = (SELECT FECHAPROCESO FROM PARAMETROS WITH (NOLOCK)) AND TZ_LOCK = 0) a
		ON a.CODIGOCLIENTE = c.CODIGOCLIENTE
		WHERE (c.CATEGORIAOBJETIVA <> '' '' AND c.OBJETIVA_REFINANCIADO <> '' '') AND c.TZ_LOCK = 0)				
		
		SET @contadorNoDatos = (SELECT count(1) FROM CRE_BCRA_MOREXENT WITH (NOLOCK))   
		
		IF (@contadorLimpiar = 0 AND @contador > 0) OR @contadorNoDatos = 0
		BEGIN		   	
			UPDATE CLI_CLIENTES SET Sit_MorExEnt = '' ''
		END					
        	  				
		IF @contador > 0
		BEGIN		   	
			UPDATE c
			SET c.Sit_MorExEnt  = ''6''
			FROM CLI_CLIENTES c WITH (NOLOCK)
			INNER JOIN (SELECT CODIGOCLIENTE FROM CRE_BCRA_MOREXENT WITH (NOLOCK) WHERE FECHA_PROCESO = (SELECT FECHAPROCESO FROM PARAMETROS WITH (NOLOCK)) AND TZ_LOCK = 0) a
			ON a.CODIGOCLIENTE = c.CODIGOCLIENTE
			WHERE (c.CATEGORIAOBJETIVA <> '' '' AND c.OBJETIVA_REFINANCIADO <> '' '') AND c.TZ_LOCK = 0	
		END
				  
		    SET @p_msg_proceso = ''El Proceso de Actualización de Situacion de Morosos ex Entidades ha finalizado correctamente. Registros procesados: ''+ CONVERT(VARCHAR(10), @contador)
			SET @p_ret_proceso = 1 		
			
			-- Logueo de información
			EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso 
				@p_id_proceso,
		    	@p_dt_proceso,
		    	''SP_ACTUALIZA_MOROSOS_SITUACION'',
		    	@p_cod_error = @p_ret_proceso, 
				@p_msg_error = @p_msg_proceso, 
				@p_tipo_error = @c_log_tipo_informacion
		END TRY
							             
		BEGIN CATCH
	
	        SET @p_ret_proceso = ERROR_NUMBER()
	        SET @p_msg_proceso = ''Ocurrió un error en el Proceso de Actualización de Situacion de Morosos ex Entidades: '' + ERROR_MESSAGE()
	
			EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso 
	        	@p_id_proceso = @p_id_proceso, 
	        	@p_fch_proceso = @p_dt_proceso, 
	        	@p_nom_package = ''SP_ACTUALIZA_MOROSOS_SITUACION'', 
	        	@p_cod_error = @p_ret_proceso, 
	        	@p_msg_error = @p_msg_proceso, 
	       		@p_tipo_error = @c_log_tipo_informacion
		END CATCH
END
')