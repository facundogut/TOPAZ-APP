EXECUTE('
CREATE OR ALTER PROCEDURE SP_MODIFICAR_FECHA_PROXIMO_BALANCE
/*	Luego de hacer algunas verificaciones utilizando la vista
	VW_CO_PARAMETROSCONTABLES desde la operación 2103 
	el Stored Procedure modificará la fecha de próximo balance */

	@P_ID_PROCESO FLOAT(53), /* Identificador de proceso */
	@P_DT_PROCESO DATETIME,	/* Fecha de proceso */
	@P_FECHA_PROX_BALANCE DATETIME, /* Fecha para setear el parámetro de próximo balance */
	@P_RET_PROCESO FLOAT(53) OUTPUT, /* Estado de ejecucion del PL/SQL(1:Correcto, 2: Error) */
	@P_MSG_PROCESO VARCHAR(max) OUTPUT /* Mensaje para el usuario */

AS

BEGIN

	DECLARE
	--CONSTANTE PARA SP MENSAJE DE ERROR
		@v_constante VARCHAR(1)
	
	BEGIN TRY
	
		UPDATE CO_PARAMETROSCONTABLES
		SET FECHAPROXIMOBALANCE = @P_FECHA_PROX_BALANCE

		SET @P_MSG_PROCESO = ''Se ha modificado correctamente la fecha de próximo balance''
	
		SET @P_RET_PROCESO = 1
	
		DECLARE
	       @PKG_CONSTANTES$C_LOG_TIPO_INFORMACION varchar(30)
	    SET @PKG_CONSTANTES$C_LOG_TIPO_INFORMACION = ''I''
	
	    EXECUTE dbo.PKG_LOG_PROCESO$PROC_INS_LOG_PROCESO 
	       @P_ID_PROCESO = @P_ID_PROCESO, 
	       @P_FCH_PROCESO = @P_DT_PROCESO, 
	       @P_NOM_PACKAGE = ''SP_MODIFICAR_FECHA_PROXIMO_BALANCE'', 
	       @P_COD_ERROR = @P_RET_PROCESO, 
	       @P_MSG_ERROR = @P_MSG_PROCESO, 
	       @P_TIPO_ERROR = @PKG_CONSTANTES$C_LOG_TIPO_INFORMACION
 	
 	END TRY

	BEGIN CATCH
        DECLARE
           @errornumber int
        SET @errornumber = ERROR_NUMBER()
        DECLARE
           @errormessage nvarchar(4000)
        SET @errormessage = ERROR_MESSAGE()
        BEGIN
           SET @P_RET_PROCESO = ERROR_NUMBER()
           SET @P_MSG_PROCESO = ''Error en la modificación de fecha próximo balance. '' + @errormessage
           DECLARE
              @PKG_CONSTANTES$C_LOG_TIPO_ERROR varchar(30)
           SET @PKG_CONSTANTES$C_LOG_TIPO_ERROR = ''E''
           EXECUTE dbo.PKG_LOG_PROCESO$PROC_INS_LOG_PROCESO 
              @P_ID_PROCESO = @P_ID_PROCESO, 
              @P_FCH_PROCESO = @P_DT_PROCESO, 
              @P_NOM_PACKAGE = ''SP_MODIFICAR_FECHA_PROXIMO_BALANCE'', 
              @P_COD_ERROR = @P_RET_PROCESO, 
              @P_MSG_ERROR = @P_MSG_PROCESO, 
              @P_TIPO_ERROR = @PKG_CONSTANTES$C_LOG_TIPO_ERROR
        END
     END CATCH
END
')

