EXECUTE('
ALTER   PROCEDURE SP_CATEGORIZACION_SINCAT
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
	@numcli NUMERIC(12), -- numero de cliente
	@categoriacliente VARCHAR(1),
	@catnueva VARCHAR(1),
	@contador NUMERIC(10),
	@f_proceso DATE;
	
	SET @contador = 0;
	------- Campos para el LOG --------
	SET @c_log_tipo_error = ''E'';
	SET @c_log_tipo_informacion = ''I'';
	-----------------------------------	

	BEGIN TRY
        	  
	      SET @contador =	(SELECT count(1)
							FROM dbo.CLI_CLIENTES WITH(NOLOCK) WHERE CODIGOCLIENTE NOT IN
																			(SELECT COD_CLIENTE 
																			FROM dbo.CRE_CATEGORIA_COMERCIAL_BITACORA WITH(NOLOCK) 
																			WHERE	F_PROCESO = (SELECT FECHAPROCESO FROM PARAMETROS with (nolock))
																				AND TZ_LOCK=0));
		  INSERT INTO dbo.CRE_CATEGORIA_COMERCIAL_BITACORA (COD_CLIENTE, 
															F_PROCESO, 
															CATEG_ANTERIOR, 
															CATEG_NUEVA, 
															TZ_LOCK)
		  SELECT	CODIGOCLIENTE,
					F_PROCESO = (SELECT FECHAPROCESO FROM PARAMETROS with (nolock)),
					CATEGORIA_COMERCIAL,
					'' '',
					0
		  FROM dbo.CLI_CLIENTES WITH(NOLOCK) WHERE CODIGOCLIENTE NOT in
															(SELECT COD_CLIENTE 
															FROM dbo.CRE_CATEGORIA_COMERCIAL_BITACORA WITH(NOLOCK) 
															WHERE	F_PROCESO = (SELECT FECHAPROCESO FROM PARAMETROS with (nolock))
																AND TZ_LOCK=0);

		  
	      UPDATE CLI
		  SET CATEGORIA_COMERCIAL = CAT.CATEG_NUEVA
		  FROM dbo.CLI_CLIENTES CLI WITH(NOLOCK)
		  INNER JOIN dbo.CRE_CATEGORIA_COMERCIAL_BITACORA CAT WITH(NOLOCK)
		  ON CLI.CODIGOCLIENTE = CAT.COD_CLIENTE 
		  WHERE		CAT.F_PROCESO =(SELECT FECHAPROCESO FROM PARAMETROS with (nolock))
				AND CAT.CATEG_NUEVA = '' ''

		    SET @p_msg_proceso = ''El Proceso de Cateorización de Clientes Sin Categoria ha finalizado correctamente. Registros procesados: ''+ CONVERT(VARCHAR(10), @contador)
			SET @p_ret_proceso = 1 		
			
			-- Logueo de información
			EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso 
				@p_id_proceso,
		    	@p_dt_proceso,
		    	''SP_CATEGORIZACION_SINCAT'',
		    	@p_cod_error = @p_ret_proceso, 
				@p_msg_error = @p_msg_proceso, 
				@p_tipo_error = @c_log_tipo_informacion
		END TRY
							             
		BEGIN CATCH
	
	        SET @p_ret_proceso = ERROR_NUMBER()
	        SET @p_msg_proceso = ''Ocurrió un error en el Proceso de Cateorización de Clientes Sin Categoria: '' + ERROR_MESSAGE()
	
			EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso 
	        	@p_id_proceso = @p_id_proceso, 
	        	@p_fch_proceso = @p_dt_proceso, 
	        	@p_nom_package = ''SP_CATEGORIZACION_SINCAT'', 
	        	@p_cod_error = @p_ret_proceso, 
	        	@p_msg_error = @p_msg_proceso, 
	       		@p_tipo_error = @c_log_tipo_informacion
		END CATCH
END
')