EXECUTE('
CREATE OR ALTER PROCEDURE [SP_ACTUALIZAR_NUMERADOR_TARJETA_RAIZ] 
	@p_id_proceso FLOAT(53),     /* Identificador de proceso */
	@p_dt_proceso DATETIME,
	@P_RET_PROCESO float(53)  OUTPUT,
    @P_MSG_PROCESO varchar(max)  OUTPUT


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

BEGIN TRY

	
	
		UPDATE NUMERATORDEFINITION
		SET INIVAL = (
		    SELECT 
		        CASE 
		            WHEN MAX(RIGHT(RTRIM(numraiz), LEN(numraiz) - LEN(prefijo))) IS NULL THEN 1
		            WHEN ISNUMERIC(MAX(RIGHT(RTRIM(numraiz), LEN(numraiz) - LEN(prefijo)))) = 1 
		                THEN CAST(MAX(CAST(RIGHT(RTRIM(numraiz), LEN(numraiz) - LEN(prefijo)) AS BIGINT)) + 1 AS BIGINT)
		            ELSE 1
		        END
		    FROM TJD_ITF_TARJETA_RAIZ AS R
		    WHERE prefijo = ''514365''
		    GROUP BY prefijo
		)
		WHERE NUMERO = 34291
		
		
		DELETE FROM NUMERATORASIGNED WHERE OID IN (SELECT OID FROM NUMERATORVALUES WHERE NUMERO = 34291)
		
		DELETE FROM NUMERATORVALUES WHERE NUMERO = 34291
		
		
		
		UPDATE NUMERATORDEFINITION
		SET INIVAL = (
		    SELECT 
		        CASE 
		            WHEN MAX(RIGHT(RTRIM(numraiz), LEN(numraiz) - LEN(prefijo))) IS NULL THEN 1
		            WHEN ISNUMERIC(MAX(RIGHT(RTRIM(numraiz), LEN(numraiz) - LEN(prefijo)))) = 1 
		                THEN CAST(MAX(CAST(RIGHT(RTRIM(numraiz), LEN(numraiz) - LEN(prefijo)) AS BIGINT)) + 1 AS BIGINT)
		            ELSE 1
		        END
		    FROM TJD_ITF_TARJETA_RAIZ AS R
		    WHERE prefijo = ''501056''
		    GROUP BY prefijo
		)
		WHERE NUMERO = 34290
		
		
		DELETE FROM NUMERATORASIGNED WHERE OID IN (SELECT OID FROM NUMERATORVALUES WHERE NUMERO = 34290)
		
		DELETE FROM NUMERATORVALUES WHERE NUMERO = 34290
	    
	
	
	SET @p_msg_proceso = ''El Proceso de Actualizaci�n del numerador finalizo correctamente''
	SET @p_ret_proceso = 1 		
			
	-- Logueo de informaci�n
	EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso 
	@p_id_proceso,
	@p_dt_proceso,
	''SP_ACTUALIZAR_NUMERADOR_TARJETA_RAIZ'',
	 @p_cod_error = @p_ret_proceso, 
	 @p_msg_error = @p_msg_proceso, 
	 @p_tipo_error = @c_log_tipo_informacion

END TRY

		BEGIN CATCH
	
	        SET @p_ret_proceso = ERROR_NUMBER()
	        SET @p_msg_proceso = ''Ocurri� un error en el Proceso de Actualizaci�n del numerador''
	
			EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso 
	        	@p_id_proceso = @p_id_proceso, 
	        	@p_fch_proceso = @p_dt_proceso, 
	        	@p_nom_package = ''SP_ACTUALIZAR_NUMERADOR_TARJETA_RAIZ'', 
	        	@p_cod_error = @p_ret_proceso, 
	        	@p_msg_error = @p_msg_proceso, 
	       		@p_tipo_error = @c_log_tipo_informacion
		END CATCH

END
')
