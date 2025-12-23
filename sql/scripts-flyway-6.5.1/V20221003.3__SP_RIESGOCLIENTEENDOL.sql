EXECUTE('
ALTER   PROCEDURE [dbo].[SP_RIESGOCLIENTEENDOL]
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
	@cot_dolares NUMERIC(15,9); -- cotizacion dolares del dia
	
	------- Campos para el LOG --------
	SET @c_log_tipo_error = ''E'';
	SET @c_log_tipo_informacion = ''I'';
	-----------------------------------	
	SET @cot_dolares = (SELECT TOP 1 C6440 FROM MONEDAS WITH(NOLOCK) WHERE C6403=''D'' AND TZ_LOCK=0);

	BEGIN TRY
        	-- una vez finalizado el  SP_RIESGOSENDOL, y para los clientes que tengan almenos un riesgo, familia o producto "dolarizado"
        	-- se actualiza el limite del cliente con la suma de todos sus riesgos
        	-- se actualiza la cotizacion al momento de la dolarizacion
			UPDATE c 
				SET MONTO=(SELECT SUM(MONTO) FROM CRE_RIESGOLIC r WITH(NOLOCK) WHERE TZ_LOCK=0 AND r.IDLIMITE=c.IDLIMITE)
					,COTIZA_DOL=@cot_dolares
		  			FROM CRE_LIMITECLIENTE c WITH(NOLOCK) 
					WHERE c.TZ_LOCK= 0 AND c.ESTADO =''A'' AND 
							(c.IDLIMITE IN(SELECT IDLIMITE FROM CRE_RIESGOLIC WITH(NOLOCK) WHERE TZ_LOCK=0 AND MONTODOL>0) 
									OR IDLIMITE IN(SELECT IDLIMITE FROM CRE_FAMILIALIC WITH(NOLOCK) WHERE TZ_LOCK=0 AND MONTODOL>0)
										OR IDLIMITE IN(SELECT IDLIMITE FROM CRE_PRODUCTOLIC WITH(NOLOCK) WHERE TZ_LOCK=0 AND MONTODOL>0)
							)
		    SET @p_msg_proceso = ''El Proceso ha finalizado correctamente. ''
			SET @p_ret_proceso = 1 		
			
			-- Logueo de información
			EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso 
				@p_id_proceso,
		    	@p_dt_proceso,
		    	''SP_RIESGOCLIENTEENDOL'',
		    	@p_cod_error = @p_ret_proceso, 
				@p_msg_error = @p_msg_proceso, 
				@p_tipo_error = @c_log_tipo_informacion
	END TRY
							             
	BEGIN CATCH
	
	        SET @p_ret_proceso = ERROR_NUMBER()
	        SET @p_msg_proceso = ''Ocurrió un error en el Proceso: '' + ERROR_MESSAGE()
	
			EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso 
	        	@p_id_proceso = @p_id_proceso, 
	        	@p_fch_proceso = @p_dt_proceso, 
	        	@p_nom_package = ''SP_RIESGOCLIENTEENDOL'', 
	        	@p_cod_error = @p_ret_proceso, 
	        	@p_msg_error = @p_msg_proceso, 
	       		@p_tipo_error = @c_log_tipo_informacion
		END CATCH
END
')

