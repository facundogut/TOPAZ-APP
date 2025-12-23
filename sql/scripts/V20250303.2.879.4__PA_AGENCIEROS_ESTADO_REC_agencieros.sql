EXECUTE('
CREATE OR ALTER PROCEDURE PA_AGENCIEROS_ESTADO_REC_agencieros
   @P_ID_PROCESO  float(53),
   @P_DT_PROCESO  datetime,
   @FECHA_REND    VARCHAR(8),
   @SIGNO         NUMERIC(1),
   @P_RET_PROCESO float(53)  OUTPUT,
   @P_MSG_PROCESO varchar(max)  OUTPUT
   
AS 

BEGIN

 SET @P_RET_PROCESO = NULL
 SET @P_MSG_PROCESO = NULL
 DECLARE @Fecha NUMERIC(8);
 SET @Fecha = @FECHA_REND;
 
 DECLARE  @v_constante VARCHAR(1)
 
 DECLARE @TablaAux TABLE(
        ID                       NUMERIC(15),
        FECHA_COBRO_PAGO         DATETIME2,
        SIGNO                    NUMERIC(1),
        ACREDITACION             VARCHAR(3),
        FECHA_REND               VARCHAR(8)
    )

 
   
	 BEGIN TRANSACTION
      
      BEGIN TRY
	   BEGIN 
		
	   INSERT INTO @TablaAux
        SELECT 
            ID, FECHA_COBRO_PAGO,SIGNO,ACREDITACION,FECHA_REND
        FROM VW_RENDICION_ID_AGENCIEROS2
        WHERE FECHA_REND =CONVERT(VARCHAR, @Fecha,112) 
        AND SIGNO = @SIGNO;
		
	END
	
    
	   -- Actualizar la tabla REC_Agencieros
        UPDATE REC_Agencieros
        SET
            ESTADO_REND = ''P'',
            ID_RENDICION = NULL
        FROM REC_Agencieros A
        JOIN @TablaAux C ON A.ID = C.ID
        WHERE A.TZ_LOCK = 0;
		
		
		SET @P_RET_PROCESO = 1
	    SET @P_MSG_PROCESO = ''Agencieros - Reversa REC_agencieros''
	  
	  EXECUTE dbo.pkg_constantes$VarcharConstantes ''C_LOG_TIPO_INFORMACION'', @v_constante OUTPUT;
	  
	  EXECUTE dbo.PKG_LOG_PROCESO$PROC_INS_LOG_PROCESO 
	       @P_ID_PROCESO = @P_ID_PROCESO, 
	       @P_FCH_PROCESO = @P_DT_PROCESO, 
	       @P_NOM_PACKAGE = ''PA_AGENCIEROS_ESTADO_REC_agencieros'', 
	       @P_COD_ERROR = @P_RET_PROCESO, 
	       @P_MSG_ERROR = @P_MSG_PROCESO, 
	       @P_TIPO_ERROR = @v_constante
		
	  COMMIT TRANSACTION;     
         
      END TRY	
	 	
	   BEGIN CATCH

         
         BEGIN
         
         	ROLLBACK TRANSACTION

            /* Valores de Retorno.*/
            SET @p_ret_proceso = ERROR_NUMBER()

            SET @p_msg_proceso = ERROR_MESSAGE()
            
            EXECUTE dbo.pkg_constantes$VarcharConstantes ''C_LOG_TIPO_ERROR'', @v_constante OUTPUT;

            EXECUTE dbo.PKG_LOG_PROCESO$proc_ins_log_proceso 
               @p_id_proceso = @p_id_proceso, 
               @p_fch_proceso = @p_dt_proceso, 
               @p_nom_package = ''PA_AGENCIEROS_ESTADO_REC_agencieros'', 
               @p_cod_error = @p_ret_proceso, 
               @p_msg_error = @p_msg_proceso, 
               @p_tipo_error = @v_constante

         END

      END CATCH
      
 END

')