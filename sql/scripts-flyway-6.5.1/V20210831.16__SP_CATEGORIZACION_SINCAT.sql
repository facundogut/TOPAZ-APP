EXECUTE('
CREATE PROCEDURE dbo.[SP_CATEGORIZACION_SINCAT]
@p_id_proceso FLOAT(53),     /* Identificador de proceso */
@p_dt_proceso DATETIME,   /* Fecha de proceso */
@p_ret_proceso FLOAT OUT, /* Estado de ejecucion del PL/SQL(0:Correcto, 2: Error) */
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
		SET @f_proceso =(SELECT FECHAPROCESO FROM PARAMETROS with (nolock));
		
	   
		DECLARE cursor1 CURSOR FOR 
		
		
		SELECT CODIGOCLIENTE, CATEGORIA_COMERCIAL FROM CLI_CLIENTES
		WHERE CODIGOCLIENTE IN(
			SELECT CODIGOCLIENTE FROM dbo.CLI_CLIENTES
			EXCEPT
			SELECT COD_CLIENTE FROM dbo.CRE_CATEGORIA_COMERCIAL_BITACORA WHERE F_PROCESO = @f_proceso AND TZ_LOCK=0
	    ) AND TZ_LOCK=0


	OPEN cursor1 
	FETCH NEXT FROM cursor1 INTO @numcli,  @categoriacliente
	
	WHILE @@FETCH_STATUS = 0  
	BEGIN  
	  	  
	   	  SET @catnueva = '' ''
	       		  
           	  
	      PRINT ''Numero Cliente:'' + CAST(@numcli AS VARCHAR) 
	   	  PRINT ''Categoria Actual:'' + @categoriacliente            	  
	      PRINT ''Nueva Categoria:'' + @catnueva   
	                	  
	      INSERT INTO dbo.CRE_CATEGORIA_COMERCIAL_BITACORA (COD_CLIENTE, F_PROCESO, CATEG_ANTERIOR, CATEG_NUEVA, TZ_LOCK)
		  VALUES (@numcli, @f_proceso, @categoriacliente, @catnueva, 0)
	      
	      UPDATE dbo.CLI_CLIENTES
		  SET CATEGORIA_COMERCIAL = @catnueva
		  WHERE CODIGOCLIENTE = @numcli
		 	      
	      
	      SET @contador=@contador+1
	       
	       	             
	      FETCH NEXT FROM cursor1 INTO @numcli, @categoriacliente
	END 
	
	CLOSE cursor1  
	DEALLOCATE cursor1 
	
	
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

