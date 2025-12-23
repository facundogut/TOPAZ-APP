EXECUTE('
CREATE OR ALTER PROCEDURE [SP_SALDOSCAJA_HISTORICO]  
  	@p_id_proceso FLOAT(53),     /* Identificador de proceso */
	@p_dt_proceso DATETIME,   /* Fecha de proceso */
	@p_ret_proceso FLOAT OUT, /* Estado de ejecucion SQL(0:Correcto, 2: Error) */
	@p_msg_proceso VARCHAR(MAX) OUT
AS 

BEGIN

	DECLARE 
	------- Campos para el LOG --------
	@c_log_tipo_error varchar(30),
	@contador NUMERIC(10),
	@c_log_tipo_informacion VARCHAR(30);
	
	BEGIN TRY
   
   	DELETE FROM dbo.SALDOSCAJA_HISTORICO WHERE FECHAPROCESO = (SELECT FECHAPROCESO FROM PARAMETROS);
	
	SET @contador = (SELECT COUNT(*) FROM SALDOSCAJA);
   	
	INSERT INTO dbo.SALDOSCAJA_HISTORICO (TZ_LOCK, FECHAPROCESO, NROCAJA, MONEDA, SALDOINICIAL, ENTRADAS, SALIDAS, MINIMOAVISO, MAXIMOAVISO, SUCURSAL)
	SELECT 0 ,(SELECT FECHAPROCESO FROM PARAMETROS), NROCAJA,MONEDA,SALDOINICIAL,ENTRADAS,SALIDAS,MINIMOAVISO,MAXIMOAVISO,SUCURSAL FROM SALDOSCAJA 


	INSERT INTO dbo.CAJ_HISTORIAL_BILLETAJE (SUCURSAL, ASIENTO, CAJA, FECHA, MONEDA, TIPO, DENOMINACION, DETERIORADO, CANTIDAD, TZ_LOCK)
		(	  
		SELECT h.SUCURSAL, h.ASIENTO, h.CAJA, (SELECT FECHAPROCESO FROM PARAMETROS) AS FECHA, h.MONEDA, h.TIPO, h.DENOMINACION, h.DETERIORADO, h.CANTIDAD, h.TZ_LOCK
		FROM CAJ_HISTORIAL_BILLETAJE h
		WHERE ((h.TZ_LOCK < 300000000000000 OR h.TZ_LOCK >= 400000000000000) AND (h.TZ_LOCK < 100000000000000 OR h.TZ_LOCK >= 200000000000000)) AND CAJA IN (
		SELECT s.NROCAJA
		FROM SALDOSCAJA_HISTORICO s
		WHERE s.SUCURSAL=h.SUCURSAL AND ((s.TZ_LOCK < 300000000000000 OR s.TZ_LOCK >= 400000000000000) AND (s.TZ_LOCK < 100000000000000 OR s.TZ_LOCK >= 200000000000000))
		AND (s.SALDOINICIAL+s.ENTRADAS-s.SALIDAS)>0
		AND s.FECHAPROCESO = ( SELECT FECHAPROCESO
		FROM PARAMETROS)
		AND s.NROCAJA NOT IN ( SELECT CAJA
		FROM CAJ_HISTORIAL_BILLETAJE
		WHERE SUCURSAL=s.SUCURSAL AND ((TZ_LOCK < 300000000000000 OR TZ_LOCK >= 400000000000000) AND (TZ_LOCK < 100000000000000 OR TZ_LOCK >= 200000000000000))
		AND FECHA=( SELECT FECHAPROCESO
		FROM PARAMETROS)
		))
		AND h.FECHA = (SELECT MAX(FECHA) FROM CAJ_HISTORIAL_BILLETAJE t WHERE t.SUCURSAL=h.SUCURSAL AND t.CAJA=h.CAJA AND ((h.TZ_LOCK < 300000000000000 OR h.TZ_LOCK >= 400000000000000) AND (h.TZ_LOCK < 100000000000000 OR h.TZ_LOCK >= 200000000000000)) )
		)
  	
  	SET @p_msg_proceso = ''El Proceso de Carga Saldos Caja Historico ha finalizado correctamente. Registros procesados: ''+ CONVERT(VARCHAR(10), @contador)
	SET @p_ret_proceso = 1 		
			
	-- Logueo de información
	EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso 
		@p_id_proceso,
    	@p_dt_proceso,
    	''SP_SALDOSCAJA_HISTORICO'',
    	@p_cod_error = @p_ret_proceso, 
		@p_msg_error = @p_msg_proceso, 
		@p_tipo_error = @c_log_tipo_informacion
	END TRY
	BEGIN CATCH
	
	        SET @p_ret_proceso = ERROR_NUMBER()
	        SET @p_msg_proceso = ''Ocurrió un error en el Proceso de Carga Saldos Caja Historico: '' + ERROR_MESSAGE()
	
			EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso 
	        	@p_id_proceso = @p_id_proceso, 
	        	@p_fch_proceso = @p_dt_proceso, 
	        	@p_nom_package = ''SP_SALDOSCAJA_HISTORICO'', 
	        	@p_cod_error = @p_ret_proceso, 
	        	@p_msg_error = @p_msg_proceso, 
	       		@p_tipo_error = @c_log_tipo_informacion
	END CATCH
	
END
')
