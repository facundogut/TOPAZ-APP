
EXECUTE('

CREATE PROCEDURE [SP_CONTROL_DPF_CONFIRMADOS]
   @P_ID_PROCESO float(53),
   @P_DT_PROCESO datetime2(0),
   @P_RET_PROCESO float(53) OUTPUT,
   @P_MSG_PROCESO varchar(max) OUTPUT
AS
BEGIN
      SET @P_RET_PROCESO = NULL
      SET @P_MSG_PROCESO = NULL
      
      DECLARE 
      @CantidadSinConfirmar NUMERIC(10)
      
SELECT
	@CantidadSinConfirmar = COUNT(*)
FROM
	CLE_DPF_RECIBIDO DR WITH (nolock),
	PARAMETROS P WITH (nolock)
WHERE
	DR.ESTADO_DPF = ''C''
	AND DR.FECHA_VALOR = P.FECHAPROCESO
    AND DR.TZ_LOCK = 0
	  
      IF @CantidadSinConfirmar = 0
      BEGIN
      
            SET @P_RET_PROCESO = 1

            SET @P_MSG_PROCESO = ''No hay DPF aceptados sin confirmar''
      END
      
            IF @CantidadSinConfirmar > 0
      BEGIN
      
               DECLARE
               @PKG_CONSTANTES$C_LOG_TIPO_INFORMACION$6 varchar(8000)

      
            SET @P_RET_PROCESO = 2

            SET @P_MSG_PROCESO = ''Hay ''+ CONVERT(VARCHAR, @CantidadSinConfirmar) +'' DPF aceptados sin confirmación manual''
      		
      		SET @PKG_CONSTANTES$C_LOG_TIPO_INFORMACION$6 = ''Hay ''+ CONVERT(VARCHAR, @CantidadSinConfirmar) +'' DPF aceptados sin confirmación manual''
      		                           
      		    EXECUTE dbo.PKG_LOG_PROCESO$PROC_INS_LOG_PROCESO 
               @P_ID_PROCESO, 
               @P_DT_PROCESO, 
               ''CONTROLDPFCONFIRMADO'', 
               @P_RET_PROCESO, 
               @P_MSG_PROCESO, 
               @PKG_CONSTANTES$C_LOG_TIPO_INFORMACION$6
      
      END
      
      
END

')