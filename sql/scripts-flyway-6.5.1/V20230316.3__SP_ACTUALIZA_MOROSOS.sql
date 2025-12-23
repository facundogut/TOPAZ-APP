EXECUTE('
ALTER PROCEDURE [dbo].[SP_ACTUALIZA_MOROSOS]
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
			FROM ITF_BCRA_MOREXENT b WITH (NOLOCK)
			INNER JOIN (SELECT DISTINCT doc.TIPODOCUMENTO, doc.NUMERODOCUMENTO, c.CODIGOCLIENTE
			FROM CLI_CLIENTES c WITH (NOLOCK) 
			INNER JOIN CLI_CLIENTEPERSONA cp WITH (NOLOCK) ON c.CODIGOCLIENTE = cp.CODIGOCLIENTE AND cp.TITULARIDAD = ''T'' AND cp.TZ_LOCK = 0
			INNER JOIN CLI_DocumentosPFPJ doc WITH (NOLOCK) ON cp.NUMEROPERSONA = doc.NUMEROPERSONAFJ AND doc.TZ_LOCK = 0
			WHERE c.TZ_LOCK = 0) a ON b.NRO_IDENTIFICACION = a.NUMERODOCUMENTO 
			WHERE b.TPO_IDENTIFICACION = 11 AND b.TZ_LOCK = 0)				
		
		-- Si se carga un nuevo padron pero no tenemos clientes dentro del mismo, se limpia la tabla para que la calificacion sea
		-- reseteada por el sp SP_ACTUALIZA_MOROSOS_SITUACION
		IF @contador = 0
		BEGIN
	   		TRUNCATE TABLE CRE_BCRA_MOREXENT
		END
		
		IF @contador > 0
		BEGIN
			TRUNCATE TABLE CRE_BCRA_MOREXENT	
		
			INSERT INTO CRE_BCRA_MOREXENT (FECHA_PROCESO, CODIGOCLIENTE, FECHA, DENOMINACION, TPO_IDENTIFICACION, NRO_IDENTIFICACION, PROC_JUDICIAL, TZ_LOCK)
			SELECT (SELECT FECHAPROCESO FROM PARAMETROS WITH (NOLOCK)), a.CODIGOCLIENTE, b.FECHA, b.DENOMINACION, b.TPO_IDENTIFICACION, b.NRO_IDENTIFICACION, b.PROC_JUDICIAL, b.TZ_LOCK
			FROM ITF_BCRA_MOREXENT b WITH (NOLOCK)
			INNER JOIN (SELECT DISTINCT doc.TIPODOCUMENTO, doc.NUMERODOCUMENTO, c.CODIGOCLIENTE
			FROM CLI_CLIENTES c WITH (NOLOCK) 
			INNER JOIN CLI_CLIENTEPERSONA cp WITH (NOLOCK) ON c.CODIGOCLIENTE = cp.CODIGOCLIENTE AND cp.TITULARIDAD = ''T'' AND cp.TZ_LOCK = 0
			INNER JOIN CLI_DocumentosPFPJ doc WITH (NOLOCK) ON cp.NUMEROPERSONA = doc.NUMEROPERSONAFJ AND doc.TZ_LOCK = 0
			WHERE c.TZ_LOCK = 0) a ON b.NRO_IDENTIFICACION = a.NUMERODOCUMENTO 
			WHERE b.TPO_IDENTIFICACION = 11 AND b.TZ_LOCK = 0
		END
		  
		    SET @p_msg_proceso = ''El Proceso de Actualización de Morosos ex Entidades ha finalizado correctamente. Registros procesados: ''+ CONVERT(VARCHAR(10), @contador)
			SET @p_ret_proceso = 1 		
			
			-- Logueo de información
			EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso 
				@p_id_proceso,
		    	@p_dt_proceso,
		    	''SP_ACTUALIZA_MOROSOS'',
		    	@p_cod_error = @p_ret_proceso, 
				@p_msg_error = @p_msg_proceso, 
				@p_tipo_error = @c_log_tipo_informacion
		END TRY
							             
		BEGIN CATCH
	
	        SET @p_ret_proceso = ERROR_NUMBER()
	        SET @p_msg_proceso = ''Ocurrió un error en el Proceso de Actualización de Morosos ex Entidades: '' + ERROR_MESSAGE()
	
			EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso 
	        	@p_id_proceso = @p_id_proceso, 
	        	@p_fch_proceso = @p_dt_proceso, 
	        	@p_nom_package = ''SP_ACTUALIZA_MOROSOS'', 
	        	@p_cod_error = @p_ret_proceso, 
	        	@p_msg_error = @p_msg_proceso, 
	       		@p_tipo_error = @c_log_tipo_informacion
		END CATCH
END
')

