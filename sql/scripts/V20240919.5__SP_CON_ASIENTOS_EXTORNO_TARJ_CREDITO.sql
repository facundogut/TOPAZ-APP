EXECUTE('
CREATE OR ALTER PROCEDURE SP_CON_ASINETOS_EXTORNO_TRAJ_CREDITO
   (@P_ASIENTO  NUMERIC(10),
   @P_OPERACION NUMERIC(5),
   @P_SUCURSAL NUMERIC(5),
   @P_FECHA  DATETIME,
   

   @P_RET_PROCESO float(53)  OUTPUT,
   @P_MSG_PROCESO varchar(max)  OUTPUT
   )
      
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
			
			INSERT INTO ASIENTOS_A_EXTORNAR (ASIENTO, OPERACION, SUCURSAL, FECHA, PROCESADO)
			VALUES (@P_ASIENTO , @P_OPERACION, @P_SUCURSAL, @P_FECHA, ''N'')
				
			COMMIT TRANSACTION;
			
			SET @P_RET_PROCESO = 1
		    SET @P_MSG_PROCESO = ''Se ejecuto el SP correctamente''
			 
				
		END TRY     
		
		BEGIN CATCH
			ROLLBACK TRANSACTION
			SET @P_RET_PROCESO = ERROR_NUMBER()
			SET @P_MSG_PROCESO = ERROR_MESSAGE()
			EXECUTE dbo.pkg_constantes$VarcharConstantes ''C_LOG_TIPO_ERROR'', @v_constante OUTPUT;
		END CATCH
		 	      
 END
')