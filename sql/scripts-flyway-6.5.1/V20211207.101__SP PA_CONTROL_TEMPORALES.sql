EXECUTE('
CREATE PROCEDURE [PA_CONTROL_TEMPORALES]
   @P_ID_PROCESO float(53),
   @P_DT_PROCESO datetime2(0),
   @P_RET_PROCESO float(53)  OUTPUT,
   @P_MSG_PROCESO varchar(max)  OUTPUT
AS
BEGIN
      SET @P_RET_PROCESO = NULL
      SET @P_MSG_PROCESO = NULL
      
      DECLARE 
      @CantidadTemporales NUMERIC(10)
      
      SELECT @CantidadTemporales = COUNT(*) FROM CLE_CHEQUES_CLEARING_RECIBIDO WHERE 
      [CODIGO_CAUSAL_DEVOLUCION] IN (SELECT [CODIGO_DE_CAUSAL] FROM CLE_TIPO_CAUSAL WHERE MODIF_DURANTE_DIA = ''T'') AND
      FECHA = (SELECT FECHAPROCESO FROM PARAMETROS) AND ESTADO_DEVOLUCION IN (1,3)
      
      IF @CantidadTemporales = 0
      BEGIN
      
            SET @P_RET_PROCESO = 1

            SET @P_MSG_PROCESO = ''No hay cheques con motivo de rechazo temporal''
      END
      
            IF @CantidadTemporales > 0
      BEGIN
      
               DECLARE
               @PKG_CONSTANTES$C_LOG_TIPO_INFORMACION$6 varchar(8000)

      
            SET @P_RET_PROCESO = 2

            SET @P_MSG_PROCESO = ''Hay ''+ CONVERT(VARCHAR, @CantidadTemporales) +'' cheques con motivo de rechazo temporal, revisar reporte 3463 e ir por la operación 3925 para cambiar la causal''
      		
      		SET @PKG_CONSTANTES$C_LOG_TIPO_INFORMACION$6 = ''Hay ''+ CONVERT(VARCHAR, @CantidadTemporales) +'' cheques con motivo de rechazo temporal''
      		                           
      		    EXECUTE PKG_LOG_PROCESO$PROC_INS_LOG_PROCESO 
               @P_ID_PROCESO, 
               @P_DT_PROCESO, 
               ''CONTROLTEMPORAL'', 
               @P_RET_PROCESO, 
               @P_MSG_PROCESO, 
               @PKG_CONSTANTES$C_LOG_TIPO_INFORMACION$6
      
      END
      
      
END
')

