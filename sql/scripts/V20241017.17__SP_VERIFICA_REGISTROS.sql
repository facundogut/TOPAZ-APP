EXECUTE('
CREATE PROCEDURE SP_TLF_MOVIMIENTOS_NO_CONCILIADOS
	@p_id_proceso FLOAT(53),     /* Identificador de proceso */
	@p_dt_proceso DATETIME,   /* Fecha de proceso */
	@p_ret_proceso FLOAT OUT, /* Estado de ejecucion SQL(0:Correcto, 2: Error) */
	@p_msg_proceso VARCHAR(MAX) OUT
AS 
BEGIN
   DECLARE 
    @contador NUMERIC (12),
	------- Campos para el LOG --------
	@c_log_tipo_error varchar(30),
	@c_log_tipo_informacion VARCHAR(30)
	------- Campos para el LOG --------
	SET @c_log_tipo_error = ''E'';
	SET @c_log_tipo_informacion = ''I'';
	-----------------------------------	
    
   BEGIN TRY
   -- Cantidad de registros a procesar
   SELECT @contador=COUNT(*) 
   FROM TJD_TLF_SUMMARY s
   WHERE NOT EXISTS (
				        SELECT 1
				        FROM TP_TOPAZPOSCONTROL tp WITH (NOLOCK) 
				        WHERE tp.ELEMENT0 = ''0200''
				          AND tp.ELEMENT12 = s.HORATRANSACCION
				          AND tp.ELEMENT13 = s.FECHATRANSACCION
				          AND tp.ELEMENT37 = s.NUMEROTRANSACCION
				          AND tp.ELEMENT41 = s.IDENTIFICACIONCAJERO
    	   			);
	-- Actualizar campo "CONCILIACION" a ''N'' en la tabla TJD_TLF_SUMMARY
	-- para los registros que no existen en la tabla TP_TOPAZPOSCONTROL
	UPDATE s 
	SET s.CONCILIACION = ''N''
	FROM TJD_TLF_SUMMARY s
	WHERE NOT EXISTS (
	 		        SELECT 1
	  		        FROM TP_TOPAZPOSCONTROL tp WITH (NOLOCK) 
	  		        WHERE tp.ELEMENT0 = ''0200''
	        	    AND tp.ELEMENT12 = s.HORATRANSACCION
				    AND tp.ELEMENT13 = s.FECHATRANSACCION
				    AND tp.ELEMENT37 = s.NUMEROTRANSACCION
				    AND tp.ELEMENT41 = s.IDENTIFICACIONCAJERO
		    	    );
		
		     	SET @P_RET_PROCESO = 1 --OK
		     	SET @P_MSG_PROCESO = ''El proceso que identifica movimientos no conciliados, ha finalizado correctamente. Transacciones NO Conciliadas: ''+ CONVERT(VARCHAR(10), @contador)
			-- Logueo de información
			EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso 
				@p_id_proceso,
		    	@p_dt_proceso,
		    	''SP_TLF_MOVIMIENTOS_NO_CONCILIADOS'',
		    	@p_cod_error = @p_ret_proceso, 
				@p_msg_error = @p_msg_proceso, 
				@p_tipo_error = @c_log_tipo_informacion
	END TRY
	BEGIN CATCH
	
	        SET @p_ret_proceso = ERROR_NUMBER()
	        SET @p_msg_proceso = ''Ocurrió un error en el Proceso de identificacion de movimientos no conciliados: '' + ERROR_MESSAGE()
	
			EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso 
	        	@p_id_proceso = @p_id_proceso, 
	        	@p_fch_proceso = @p_dt_proceso, 
	        	@p_nom_package = ''SP_TLF_MOVIMIENTOS_NO_CONCILIADOS'', 
	        	@p_cod_error = @p_ret_proceso, 
	        	@p_msg_error = @p_msg_proceso, 
	       		@p_tipo_error = @c_log_tipo_informacion
	END CATCH   
END

')