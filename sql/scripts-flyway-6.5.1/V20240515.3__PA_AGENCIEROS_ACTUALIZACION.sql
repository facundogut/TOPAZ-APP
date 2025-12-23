EXECUTE('
CREATE OR ALTER PROCEDURE [dbo].[PA_AGENCIEROS_ACTUALIZACION]
   @P_ID_PROCESO  float(53),
   @P_DT_PROCESO  datetime2(0),
   @P_RET_PROCESO float(53)  OUTPUT,
   @P_MSG_PROCESO varchar(max)  OUTPUT
   
AS 

   BEGIN

      SET @P_RET_PROCESO = NULL
      SET @P_MSG_PROCESO = NULL
      
      DECLARE

         @CANT	NUMERIC(10),
         @v_constante VARCHAR(1),
         @v_numerador NUMERIC;
               
      SET @CANT = 0

      ---------------------------
      
      DECLARE @RegistrosBancarizados TABLE(
      ID NUMERIC(15),
      ESTADO VARCHAR(1),
      ASIENTO_PROCESADO NUMERIC(10),
      FECHA_PROCESADO DATETIME,
      Lista_Cod_Err VARCHAR(60),
      COMENTARIO VARCHAR(35));
         
      
      INSERT INTO @RegistrosBancarizados
                 SELECT a.ID,am.ESTADO,am.ASIENTO_PROCESADO,am.FECHA_PROCESADO,a.Lista_Cod_Err,am.COMENTARIO
		   	FROM REC_Agencieros a WITH (NOLOCK)
		   	JOIN GRL_ACREDITACIONES_MASIVAS am WITH (NOLOCK)
														ON a.ID=am.REFERENCIA_EXTERNA 
		   WHERE a.ESTADO=''R'' AND a.TZ_LOCK = 0 AND am.TZ_LOCK = 0;

      ---------------------------
      
      BEGIN TRANSACTION
      
      BEGIN TRY
      BEGIN
      		
			UPDATE REC_Agencieros 
			SET ESTADO = R.ESTADO, ASIENTO = R.ASIENTO_PROCESADO,
			FECHA_COBRO_PAGO = R.FECHA_PROCESADO, 
			DETALLE_ESTADO = (CASE WHEN R.ESTADO = ''P'' 
					THEN ''Pago''
				WHEN R.ESTADO = ''E'' 
					THEN ''Error'' ELSE '''' END),
			Lista_Cod_Err= (CASE WHEN R.ESTADO = ''P'' 
					THEN R.Lista_Cod_Err
				WHEN R.ESTADO = ''E'' AND R.COMENTARIO = ''SALDO DEBITO SIN DISPONIBLE''
					THEN concat(R.Lista_Cod_Err,'' '',''012'') ELSE '''' END)		
			
			FROM REC_Agencieros A JOIN @RegistrosBancarizados R ON A.ID = R.ID
			WHERE A.TZ_LOCK = 0
		
			SET @CANT = @@ROWCOUNT
    	                  
           
      END
      	
      SET @P_RET_PROCESO = 1
	  SET @P_MSG_PROCESO = ''Actualizacion Funcionó correctamente. Se actualizaron ''+ ISNULL(CAST(@CANT AS nvarchar(max)), '''') + '' registros.''
	  
	  EXECUTE dbo.pkg_constantes$VarcharConstantes ''C_LOG_TIPO_INFORMACION'', @v_constante OUTPUT;
	  
	  EXECUTE dbo.PKG_LOG_PROCESO$PROC_INS_LOG_PROCESO 
	       @P_ID_PROCESO = @P_ID_PROCESO, 
	       @P_FCH_PROCESO = @P_DT_PROCESO, 
	       @P_NOM_PACKAGE = ''PA_AGENCIEROS_ACTUALIZACION'', 
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
               @p_nom_package = ''PA_AGENCIEROS_ACTUALIZACION'', 
               @p_cod_error = @p_ret_proceso, 
               @p_msg_error = @p_msg_proceso, 
               @p_tipo_error = @v_constante

         END

      END CATCH
            
   END

')
