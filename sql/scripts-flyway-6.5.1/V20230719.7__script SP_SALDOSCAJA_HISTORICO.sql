EXECUTE('
CREATE PROCEDURE SP_SALDOSATM_HISTORICO
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
	
	DECLARE @tbl_aux_saldosatm TABLE (
	NRO_ATM NUMERIC(5)
	
	)
	
	INSERT INTO @tbl_aux_saldosatm
		SELECT S.NRO_ATM
			FROM SALDOSATM S JOIN TABLA_ATM A ON S.NRO_ATM = A.NRO_ATM 
			WHERE A.ESTADO = ''H'' AND S.TZ_LOCK = 0 AND A.TZ_LOCK = 0
	
	BEGIN TRY
	
	-- HISTORICO SALDOS ATM
	
	DELETE FROM dbo.SALDOSATM_HISTORICO WHERE FECHAPROCESO = (SELECT FECHAPROCESO FROM PARAMETROS)

	SET @contador = (SELECT COUNT(*) FROM SALDOSATM S 
									JOIN TABLA_ATM A ON S.NRO_ATM = A.NRO_ATM 
									WHERE A.ESTADO = ''H'' AND S.TZ_LOCK = 0 AND A.TZ_LOCK = 0);

	INSERT INTO dbo.SALDOSATM_HISTORICO (NRO_ATM, MONEDA, SALDO_INICIAL, ENTRADAS, SALIDAS, DEPOSITOS, RETIROS, TZ_LOCK, FECHAPROCESO)
		SELECT S.NRO_ATM, S.MONEDA, SALDO_INICIAL, ENTRADAS, SALIDAS, DEPOSITOS, 
	 			RETIROS, 0, (SELECT FECHAPROCESO FROM PARAMETROS) AS FECHAPROCESO 
			FROM SALDOSATM S 
				JOIN TABLA_ATM A ON S.NRO_ATM = A.NRO_ATM 
					WHERE A.ESTADO = ''H'' AND S.TZ_LOCK = 0 AND A.TZ_LOCK = 0;
	
	-- FIN HISTORICO SALDOS ATM
	
	-- RESET SALDOSATM
	
	UPDATE SALDOSATM 
		SET SALDO_INICIAL = ((SALDO_INICIAL + ENTRADAS) - SALIDAS),
		ENTRADAS = 0,
		SALIDAS = 0,
		DEPOSITOS = 0,
		RETIROS = 0
	
	WHERE NRO_ATM IN (SELECT NRO_ATM FROM @tbl_aux_saldosatm);
	
	-- FIN RESET SALDOSATM
	
  	SET @p_msg_proceso = ''El Proceso de Carga Saldos ATM Historico ha finalizado correctamente. Registros procesados: ''+ CONVERT(VARCHAR(10), @contador)
	SET @p_ret_proceso = 1 		
	
		-- Logueo de información
	EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso 
		@p_id_proceso,
    	@p_dt_proceso,
    	''SP_SALDOSATM_HISTORICO'',
    	@p_cod_error = @p_ret_proceso, 
		@p_msg_error = @p_msg_proceso, 
		@p_tipo_error = @c_log_tipo_informacion
	END TRY
	BEGIN CATCH
	
	        SET @p_ret_proceso = ERROR_NUMBER()
	        SET @p_msg_proceso = ''Ocurrió un error en el Proceso de Carga Saldos ATM Historico: '' + ERROR_MESSAGE()
	
			EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso 
	        	@p_id_proceso = @p_id_proceso, 
	        	@p_fch_proceso = @p_dt_proceso, 
	        	@p_nom_package = ''SP_SALDOSATM_HISTORICO'', 
	        	@p_cod_error = @p_ret_proceso, 
	        	@p_msg_error = @p_msg_proceso, 
	       		@p_tipo_error = @c_log_tipo_informacion
	END CATCH
END
')

