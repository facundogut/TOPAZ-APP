EXECUTE('
ALTER PROCEDURE dbo.[SP_CATEGORIZACION]
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
	@maxcategoria VARCHAR(1),
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
		
		DELETE FROM CRE_CATEGORIA_COMERCIAL_BITACORA WHERE F_PROCESO=  @f_proceso;

		DECLARE cursor1 CURSOR FOR 
			SELECT CODIGOCLIENTE, CATEGORIA_COMERCIAL, MAX(CATEGORIA)  FROM(
			SELECT  C.CODIGOCLIENTE,  C.CATEGORIA_COMERCIAL, -- Limite de Credito
					CASE L.CATEGORIA_COMERCIAL 
						 WHEN ''C'' THEN 1
			        	 WHEN ''S'' THEN 2
			        	 WHEN ''M'' THEN 3
			        	 ELSE ''3''
			    	END AS CATEGORIA 
			FROM CLI_CLIENTES C WITH (nolock)
			JOIN CRE_LIMITECLIENTE L WITH (nolock) ON C.CODIGOCLIENTE = L.CLIENTE AND PLAZO > @f_proceso AND L.ESTADO=''A'' 
			WHERE (C.TZ_LOCK = 0 AND L.TZ_LOCK = 0)
			UNION ALL
			SELECT  C.CODIGOCLIENTE,   C.CATEGORIA_COMERCIAL,
					CASE VTA.CATEGORIA_COMERCIAL 
						 WHEN ''C'' THEN 1
			        	 WHEN ''S'' THEN 2
			        	 WHEN ''M'' THEN 3
			        	 ELSE ''3''
			    	END AS CATEGORIA 
			FROM CLI_CLIENTES C WITH (nolock)
			JOIN SALDOS S WITH (nolock) ON C.CODIGOCLIENTE = S.C1803 AND S.C1785= 2 
			JOIN VTA_SOBREGIROS VTA WITH (nolock) ON S.JTS_OID = VTA.JTS_OID_SALDO AND VTA.FECHA_VENCIMIENTO > @f_proceso 
			WHERE (C.TZ_LOCK = 0 AND VTA.TZ_LOCK = 0)
			UNION ALL -- Asistencias y Descuentos
			SELECT  C.CODIGOCLIENTE,  C.CATEGORIA_COMERCIAL,
					CASE CRE.CATEGORIA_COMERCIAL 
						 WHEN ''C'' THEN 1
			        	 WHEN ''S'' THEN 2
			        	 WHEN ''M'' THEN 3
			        	 ELSE ''1''
			    	END AS CATEGORIA 
			FROM CLI_CLIENTES C WITH (nolock)
			JOIN SALDOS S WITH (nolock) ON C.CODIGOCLIENTE = S.C1803 AND (S.C1785= 5 OR S.C1785= 6) AND S.C1604<0
			JOIN CRE_SALDOS CRE WITH (nolock) ON S.JTS_OID = CRE.SALDOS_JTS_OID 
			JOIN PRODUCTOS P WITH (nolock) ON P.C6250=S.PRODUCTO
			WHERE (C.TZ_LOCK = 0 AND CRE.TZ_LOCK = 0)
			UNION ALL -- Tarjetas
			SELECT  C.CODIGOCLIENTE,  C.CATEGORIA_COMERCIAL,
					CASE P.C6825
					WHEN ''C'' THEN 1
			        WHEN ''S'' THEN 2
			        WHEN ''M'' THEN 3
			        ELSE ''1''
					END AS CATEGORIA 
			FROM CLI_CLIENTES C WITH (nolock)
			JOIN SALDOS S WITH (nolock) ON C.CODIGOCLIENTE = S.C1803 AND S.C1785=1
			JOIN PRODUCTOS P WITH (nolock) ON P.C6250=S.PRODUCTO AND P.C6800=''T''
			WHERE C.TZ_LOCK = 0
			
			) AS SUBQUERY GROUP BY CODIGOCLIENTE, CATEGORIA_COMERCIAL

	OPEN cursor1 
	FETCH NEXT FROM cursor1 INTO @numcli,  @categoriacliente,  @maxcategoria
	
	WHILE @@FETCH_STATUS = 0  
	BEGIN  
	  	  
	   	  SET @catnueva = CASE @maxcategoria
	                       WHEN 1 THEN ''C''
	        	 		   WHEN 2 THEN ''S''
	        	 		   WHEN 3 THEN ''M''
	        	 		   ELSE ''C''
	                  	  END 
	                  
	                  	  
	      PRINT ''Numero Cliente:'' + CAST(@numcli AS VARCHAR) 
	   	  PRINT ''Categoria Actual:'' + @categoriacliente            	  
	      PRINT ''Nueva Categoria:'' + @catnueva   
	                	  
	      INSERT INTO dbo.CRE_CATEGORIA_COMERCIAL_BITACORA (COD_CLIENTE, F_PROCESO, CATEG_ANTERIOR, CATEG_NUEVA, TZ_LOCK)
		  VALUES (@numcli, @f_proceso, @categoriacliente, @catnueva, 0)
	      
	      UPDATE dbo.CLI_CLIENTES
		  SET CATEGORIA_COMERCIAL = @catnueva
		  WHERE CODIGOCLIENTE = @numcli
		 	      
	      
	      SET @contador=@contador+1
	       
	       
	             
	      FETCH NEXT FROM cursor1 INTO @numcli, @categoriacliente, @maxcategoria
	END 
	
	CLOSE cursor1  
	DEALLOCATE cursor1 
	
	
		    SET @p_msg_proceso = ''El Proceso de Cateorización de Clientes ha finalizado correctamente. Registros procesados: ''+ CONVERT(VARCHAR(10), @contador)
			SET @p_ret_proceso = 1 		
			
			-- Logueo de información
			EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso 
				@p_id_proceso,
		    	@p_dt_proceso,
		    	''SP_CATEGORIZACION'',
		    	@p_cod_error = @p_ret_proceso, 
				@p_msg_error = @p_msg_proceso, 
				@p_tipo_error = @c_log_tipo_informacion
		END TRY
							             
		BEGIN CATCH
	
	        SET @p_ret_proceso = ERROR_NUMBER()
	        SET @p_msg_proceso = ''Ocurrió un error en el Proceso de Cateorización de Clientes: '' + ERROR_MESSAGE()
	
			EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso 
	        	@p_id_proceso = @p_id_proceso, 
	        	@p_fch_proceso = @p_dt_proceso, 
	        	@p_nom_package = ''SP_CATEGORIZACION'', 
	        	@p_cod_error = @p_ret_proceso, 
	        	@p_msg_error = @p_msg_proceso, 
	       		@p_tipo_error = @c_log_tipo_informacion
		END CATCH
END
')
