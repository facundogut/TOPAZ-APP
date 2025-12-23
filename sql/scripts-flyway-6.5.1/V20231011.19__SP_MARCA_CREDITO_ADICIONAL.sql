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
	@contador NUMERIC(10),
	@capital_CA NUMERIC(15,2)
	
	SET @contador = 0;
	SET @capital_CA = 0;
	
	DECLARE @CREDITO_ADICIONAL TABLE (JTS_OID NUMERIC(12),C1695 VARCHAR(1))
	------- Campos para el LOG --------
	SET @c_log_tipo_error = ''E'';
	SET @c_log_tipo_informacion = ''I'';
	-----------------------------------	

	BEGIN TRY
	
		INSERT INTO @CREDITO_ADICIONAL
        SELECT s.JTS_OID,s.C1695
		FROM SALDOS s WITH (NOLOCK)
		INNER JOIN (SELECT count(*) AS CANTIDAD, C1803 AS CLIENTE 
					FROM SALDOS WITH (NOLOCK)
					WHERE C1604 < 0 AND C1785 = 5 AND C1695 = '' '' AND TZ_LOCK = 0 
					GROUP BY C1803) sc ON s.C1803 = sc.CLIENTE AND sc.CANTIDAD > 1							
		INNER JOIN (SELECT sum(SALDO_DEUDA) AS DEUDA, CLIENTE AS CLIENTE 
					FROM VW_DEUDA_CLIENTES WITH (NOLOCK)
					WHERE SALDO_DEUDA > 0 AND CREDITO_ADICIONAL =''N'' 
					GROUP BY CLIENTE) sd ON s.C1803 = sd.CLIENTE 	
		LEFT JOIN (SELECT SUM(C1604*-1) AS SALDO_CAPITAL, C1803 AS CLIENTE 
					FROM SALDOS WITH (NOLOCK)
					WHERE C1604 < 0 AND C1785 = 5 AND C1695 = ''S'' AND TZ_LOCK = 0 
					GROUP BY C1803) sc1 ON s.C1803 = sc1.CLIENTE							
		INNER JOIN CLI_CLIENTES c WITH (NOLOCK) ON s.C1803 = c.CODIGOCLIENTE AND c.TZ_LOCK = 0
		INNER JOIN CLI_CLASUBJETIVA co WITH (NOLOCK) ON c.CATEGORIARESULTANTE = co.CATEGORIASUB AND co.TZ_LOCK = 0		
		WHERE s.C1604 < 0 AND s.C1785 = 5 AND s.C8748=''N'' AND s.C1695 = '' '' 
		AND round((((round(isnull(sd.DEUDA,0),2)*co.PORCENTAJE_SF)/100) - isnull(sc1.SALDO_CAPITAL,0)),2) >= s.C1604*-1 
	    AND s.C1621 = (SELECT FECHAPROCESO FROM PARAMETROS WITH (NOLOCK))		   
		AND s.TZ_LOCK = 0 		

		BEGIN
			UPDATE s
			SET s.C1695 = ''S''
			FROM SALDOS s WITH (NOLOCK)
			INNER JOIN @CREDITO_ADICIONAL a
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