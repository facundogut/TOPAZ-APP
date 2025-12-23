EXECUTE('
ALTER PROCEDURE [dbo].[SP_MARCA_CREDITO_ADICIONAL]
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
		FROM SALDOS s WITH (NOLOCK)
		INNER JOIN (SELECT count(*) AS CANTIDAD, C1803 AS CLIENTE 
					FROM SALDOS WITH (NOLOCK)
					WHERE C1604 < 0 AND C1785 = 5 AND C1695 = '' '' AND TZ_LOCK = 0 
					GROUP BY C1803) sc ON s.C1803 = sc.CLIENTE AND sc.CANTIDAD > 1
		INNER JOIN (SELECT sum(SALDO) AS DEUDA, CLIENTE AS CLIENTE 
					FROM VW_ASISTENCIAS WITH (NOLOCK)
					WHERE SALDO > 0
					GROUP BY CLIENTE) sd ON s.C1803 = sd.CLIENTE 			
		INNER JOIN CLI_CLIENTES c WITH (NOLOCK) ON s.C1803 = c.CODIGOCLIENTE AND c.TZ_LOCK = 0
		INNER JOIN CLI_CLASUBJETIVA co WITH (NOLOCK) ON c.CATEGORIARESULTANTE = co.CATEGORIASUB AND co.TZ_LOCK = 0 AND 
		round(((s.C1604*-1)*100/NULLIF((sd.DEUDA - (s.C1604*-1)),0)),2) <= co.PORCENTAJE_SF  
		WHERE s.C1604 < 0 AND s.C1785 = 5 AND s.C1695 = '' '' AND s.TZ_LOCK = 0 AND s.C1621 = (SELECT FECHAPROCESO FROM PARAMETROS WITH (NOLOCK)))				
		
		IF @contador > 0
		BEGIN
			UPDATE s
			SET s.C1695 = ''S''
			FROM SALDOS s WITH (NOLOCK)
			INNER JOIN (
			SELECT s.JTS_OID
			FROM SALDOS s WITH (NOLOCK)
			INNER JOIN (SELECT count(*) AS CANTIDAD, C1803 AS CLIENTE 
						FROM SALDOS WITH (NOLOCK)
						WHERE C1604 < 0 AND C1785 = 5 AND C1695 = '' '' AND TZ_LOCK = 0 
						GROUP BY C1803) sc ON s.C1803 = sc.CLIENTE AND sc.CANTIDAD > 1
			INNER JOIN (SELECT sum(SALDO) AS DEUDA, CLIENTE AS CLIENTE 
						FROM VW_ASISTENCIAS WITH (NOLOCK)
						WHERE SALDO > 0
						GROUP BY CLIENTE) sd ON s.C1803 = sd.CLIENTE INNER JOIN CLI_CLIENTES c WITH (NOLOCK) ON s.C1803 = c.CODIGOCLIENTE AND c.TZ_LOCK = 0
			INNER JOIN CLI_CLASUBJETIVA co WITH (NOLOCK) ON c.CATEGORIARESULTANTE = co.CATEGORIASUB AND co.TZ_LOCK = 0 AND 
			round(((s.C1604*-1)*100/NULLIF((sd.DEUDA - (s.C1604*-1)),0)),2) <= co.PORCENTAJE_SF  
			WHERE s.C1604 < 0 AND s.C1785 = 5 AND s.C1695 = '' '' AND s.TZ_LOCK = 0 AND s.C1621 = (SELECT FECHAPROCESO FROM PARAMETROS WITH (NOLOCK))) a
			ON a.JTS_OID = s.JTS_OID					
		END
		  
		    SET @p_msg_proceso = ''El Proceso de Marca de Credito Adicional ha finalizado correctamente. Registros procesados: ''+ CONVERT(VARCHAR(10), @contador)
			SET @p_ret_proceso = 1 		
			
			-- Logueo de información
			EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso 
				@p_id_proceso,
		    	@p_dt_proceso,
		    	''SP_MARCA_CREDITO_ADICIONAL'',
		    	@p_cod_error = @p_ret_proceso, 
				@p_msg_error = @p_msg_proceso, 
				@p_tipo_error = @c_log_tipo_informacion
		END TRY
							             
		BEGIN CATCH
	
	        SET @p_ret_proceso = ERROR_NUMBER()
	        SET @p_msg_proceso = ''Ocurrió un error en el Proceso de Marca de Credito Adicional: '' + ERROR_MESSAGE()
	
			EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso 
	        	@p_id_proceso = @p_id_proceso, 
	        	@p_fch_proceso = @p_dt_proceso, 
	        	@p_nom_package = ''SP_MARCA_CREDITO_ADICIONAL'', 
	        	@p_cod_error = @p_ret_proceso, 
	        	@p_msg_error = @p_msg_proceso, 
	       		@p_tipo_error = @c_log_tipo_informacion
		END CATCH
END
')