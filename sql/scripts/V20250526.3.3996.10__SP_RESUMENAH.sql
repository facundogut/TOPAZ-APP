EXECUTE('
CREATE OR ALTER PROCEDURE dbo.SP_GENERO_RESUMEN_AH 
    @P_ID_PROCESO FLOAT(53),
    @P_DT_PROCESO DATETIME2(0),
    @P_RET_PROCESO FLOAT(53) OUTPUT,
    @P_MSG_PROCESO VARCHAR(MAX) OUTPUT
AS 
BEGIN 
    SET NOCOUNT ON;

    DECLARE @RETORNO_CON_REGISTRO NUMERIC(12);
    DECLARE @p_tipo_error VARCHAR(8000);

   BEGIN TRY
   BEGIN
        -- Insertamos en resumen
        INSERT INTO dbo.CRE_ADELANTOS_HABERES_RESUMEN (
            JTS_OID_CV,
            FECHA,
            IMPORTE,
            PRODUCTO,
            CUOTAS,
            PERIODICIDAD,
            CANAL,
            TZ_LOCK,
            ESTADO,
            NRO_RESERVA,
            ID_CONVENIO,
            CUOTA_CALCULADA,
            CLIENTE,
            FECHA_PROCESADO
        )
        SELECT
            JTS_OID_CV,
            FECHA,
            SUM(IMPORTE),
            PRODUCTO,
            MAX(CUOTAS),
            MAX(PERIODICIDAD),
            CANAL,
            MAX(TZ_LOCK),
            MAX(ESTADO),
            MAX(NRO_RESERVA),
            MAX(ID_CONVENIO),
            SUM(CUOTA_CALCULADA),
            MAX(CLIENTE),
            NULL
        FROM dbo.CRE_ADELANTOS_HABERES WITH (NOLOCK)
        WHERE ESTADO = ''I''
        GROUP BY 
            JTS_OID_CV,
            FECHA,
            PRODUCTO,
            CANAL;

        -- Contamos registros
        SELECT @RETORNO_CON_REGISTRO = COUNT(1)
        FROM CRE_ADELANTOS_HABERES_RESUMEN WITH (NOLOCK)
        WHERE ESTADO = ''I'';
	
		BEGIN
        -- Seteamos mensajes
        SET @P_MSG_PROCESO = ''Se procesaron '' + CONVERT(VARCHAR, @RETORNO_CON_REGISTRO) + '' registros'';
        SET @P_RET_PROCESO = 1;
        SET @p_tipo_error = ''I'';
		
        -- Ejecutamos log
        EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso 
            @P_ID_PROCESO,
            @P_DT_PROCESO,
            ''SP_GENERO_RESUMEN_AH'',
            @P_RET_PROCESO,
            @P_MSG_PROCESO,
            @p_tipo_error;
            
		END
	END
    END TRY
    BEGIN CATCH
		BEGIN
        SET @P_RET_PROCESO = 3;
        SET @P_MSG_PROCESO = ''Proceso finalizado con errores: '' + ERROR_MESSAGE();
        SET @p_tipo_error = ''E'';

        -- Log del error
        EXECUTE dbo.PKG_LOG_PROCESO$PROC_INS_LOG_PROCESO 
            @P_ID_PROCESO = @P_ID_PROCESO, 
            @P_FCH_PROCESO = @P_DT_PROCESO, 
            @P_NOM_PACKAGE = ''SP_GENERO_RESUMEN_AH - Error'', 
            @P_COD_ERROR = @P_RET_PROCESO, 
            @P_MSG_ERROR = @P_MSG_PROCESO, 
            @P_TIPO_ERROR = @p_tipo_error;
		END
    END CATCH;
END
')