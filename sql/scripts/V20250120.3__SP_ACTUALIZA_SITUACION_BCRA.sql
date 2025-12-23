EXECUTE('
ALTER PROCEDURE [dbo].[SP_ACTUALIZA_SITUACION_BCRA]
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
	@contador_BCRA NUMERIC(10)
	
	SET @contador = 0;
	SET @contador_BCRA = 0;
	------- Campos para el LOG --------
	SET @c_log_tipo_error = ''E'';
	SET @c_log_tipo_informacion = ''I'';
	-----------------------------------	

	BEGIN TRY
	   	
	   	-- Verificamos si hay novedad del BCRA
	   	-- Seleccionamos solo registros que no sean de novedad para que no se elimine la categoria si no vino el padron completo,
	   	-- Es decir que cuando hay clientes nuevos, no debemos eliminar, solo cuando es un nuevo padron
	    SET @contador_BCRA = (SELECT count(1) FROM CRE_BCRA_CENDEU WHERE FECHA_PROCESO = (SELECT FECHAPROCESO FROM PARAMETROS WITH (NOLOCK)) AND TZ_LOCK = 0 AND COD_ENTIDAD <> right(''000000'' + CAST((SELECT NUMERICO FROM PARAMETROSGENERALES WITH (NOLOCK) WHERE CODIGO = 2) AS VARCHAR(5)),5));
	    -- Si hay novedad del BCRA reseteamos CATEGORIA_OFICIAL
		IF @contador_BCRA > 0
			BEGIN
		   		UPDATE CLI_CLIENTES SET CATEGORIA_OFICIAL = '' '';
		   	END
        
        --Verificamos si hay novedad del BCRA para clientes del NBCH	  
		SET @contador =	(SELECT count(1)			
		FROM CLI_CLIENTES c WITH (NOLOCK)
		INNER JOIN (SELECT CODIGOCLIENTE, max(SITUACION_ENTIDAD) AS CALIFICACION FROM CRE_BCRA_CENDEU WHERE FECHA_PROCESO = (SELECT FECHAPROCESO FROM PARAMETROS WITH (NOLOCK)) AND TZ_LOCK = 0 AND COD_ENTIDAD <> right(''000000'' + CAST((SELECT NUMERICO FROM PARAMETROSGENERALES WITH (NOLOCK) WHERE CODIGO = 2) AS VARCHAR(5)),5) GROUP BY CODIGOCLIENTE) a
		ON a.CODIGOCLIENTE = c.CODIGOCLIENTE
		WHERE c.TZ_LOCK = 0)				
		
		IF @contador > 0
		BEGIN
			--Si hay novedad del BCRA para clientes del NBCH actualizamos
			UPDATE c
			SET c.CATEGORIA_OFICIAL = a.CALIFICACION
			FROM CLI_CLIENTES c WITH (NOLOCK)
			INNER JOIN (SELECT CODIGOCLIENTE, max(SITUACION_ENTIDAD) AS CALIFICACION FROM CRE_BCRA_CENDEU WHERE FECHA_PROCESO = (SELECT FECHAPROCESO FROM PARAMETROS WITH (NOLOCK)) AND TZ_LOCK = 0 AND COD_ENTIDAD <> right(''000000'' + CAST((SELECT NUMERICO FROM PARAMETROSGENERALES WITH (NOLOCK) WHERE CODIGO = 2) AS VARCHAR(5)),5) GROUP BY CODIGOCLIENTE) a
			ON a.CODIGOCLIENTE = c.CODIGOCLIENTE
			WHERE c.TZ_LOCK = 0
		END
		  
		    SET @p_msg_proceso = ''El Proceso de Actualización de Situacion de BCRA ha finalizado correctamente. Registros procesados: ''+ CONVERT(VARCHAR(10), @contador)
			SET @p_ret_proceso = 1 		
			
			-- Logueo de información
			EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso 
				@p_id_proceso,
		    	@p_dt_proceso,
		    	''SP_ACTUALIZA_SITUACION_BCRA'',
		    	@p_cod_error = @p_ret_proceso, 
				@p_msg_error = @p_msg_proceso, 
				@p_tipo_error = @c_log_tipo_informacion
		END TRY
							             
		BEGIN CATCH
	
	        SET @p_ret_proceso = ERROR_NUMBER()
	        SET @p_msg_proceso = ''Ocurrió un error en el Proceso de Actualización de Situacion de BCRA: '' + ERROR_MESSAGE()
	
			EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso 
	        	@p_id_proceso = @p_id_proceso, 
	        	@p_fch_proceso = @p_dt_proceso, 
	        	@p_nom_package = ''SP_ACTUALIZA_SITUACION_BCRA'', 
	        	@p_cod_error = @p_ret_proceso, 
	        	@p_msg_error = @p_msg_proceso, 
	       		@p_tipo_error = @c_log_tipo_informacion
		END CATCH
END
')