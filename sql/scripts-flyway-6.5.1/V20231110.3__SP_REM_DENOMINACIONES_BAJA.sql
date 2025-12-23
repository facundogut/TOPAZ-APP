EXECUTE('
CREATE OR ALTER  PROCEDURE SP_REM_DENOMINACIONES_BAJA
   @P_NRO_SOLICITUD NUMERIC(7,0),
   
   @P_RET_PROCESO float(53)  OUTPUT,
   @P_MSG_PROCESO varchar(max)  OUTPUT
      
AS 

   BEGIN

      SET @P_RET_PROCESO = NULL
      SET @P_MSG_PROCESO = NULL
      
      DECLARE

         @FECHA DATETIME,
         @FECHA_ANTERIOR DATETIME,
         @CANT NUMERIC(5),
         @row_number NUMERIC(6),
         @v_constante VARCHAR(1),
         @v_numerador NUMERIC,
         @v_correlativo NUMERIC(10)
      
      BEGIN TRANSACTION	
      
        BEGIN TRY
			
			DELETE FROM REM_DENOMINACIONREMESA WHERE NRO_SOLICITUD = @P_NRO_SOLICITUD
				
			COMMIT TRANSACTION;
			
			SET @P_RET_PROCESO = 1
		    SET @P_MSG_PROCESO = ''Se ejecuto el SP correctamente''
			 
				
		END TRY     
		
		BEGIN CATCH
			ROLLBACK TRANSACTION
			SET @P_RET_PROCESO = ERROR_NUMBER()
			SET @P_MSG_PROCESO = ERROR_MESSAGE()
			EXECUTE pkg_constantes$VarcharConstantes ''C_LOG_TIPO_ERROR'', @v_constante OUTPUT;
		END CATCH
		 	      
 END
')

