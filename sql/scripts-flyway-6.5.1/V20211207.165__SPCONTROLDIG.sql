EXECUTE('
ALTER PROCEDURE [dbo].[PA_CONTROL_CH_DIGITALIZACION]
   @P_ID_PROCESO float(53),
   @P_DT_PROCESO datetime2(0),
   @P_RET_PROCESO float(53) OUTPUT,
   @P_MSG_PROCESO varchar(max) OUTPUT
AS
BEGIN
      SET @P_RET_PROCESO = NULL
      SET @P_MSG_PROCESO = NULL
      
      DECLARE @CantidadSinDigitalizarChe NUMERIC(10)
      DECLARE @CantidadSinDigitalizarDPF NUMERIC(10)
      DECLARE @PKG_CONSTANTES$C_LOG_TIPO_INFORMACION$6 varchar(8000)
      
     SELECT
	@CantidadSinDigitalizarChe = COUNT(*)
FROM
	CLE_CHEQUES_SALIENTE CS WITH (nolock),
	PARAMETROS P WITH (nolock)
WHERE
	CS.FECHA_ENVIO_COMPENSACION IS NULL
	AND CS.FECHA_ENVIO_CAMARA <= P.FECHAPROCESO
	AND CS.CODIGO_CAMARA = 1
	AND CS.FECHA_RECEP_CENTRAL_CLEAR IS NOT NULL
	AND CS.ESTADO = 2
	
	
	SELECT
	@CantidadSinDigitalizarDPF = COUNT(*)
FROM
	CLE_DPF_SALIENTE DS WITH (nolock),
	PARAMETROS P WITH (nolock)
WHERE
	DS.FECHA_ENVIO_COMPENSACION IS NULL
	AND DS.FECHA_ENVIO_CAMARA <= P.FECHAPROCESO
	AND DS.ESTADO = 4
      
      IF @CantidadSinDigitalizarChe = 0 AND @CantidadSinDigitalizarDPF = 0
      BEGIN
      
            SET @P_RET_PROCESO = 1

            SET @P_MSG_PROCESO = ''No hay cheques ni plazos fijos sin digitalizar''
      END
      
            IF @CantidadSinDigitalizarChe > 0 AND @CantidadSinDigitalizarDPF = 0
      BEGIN

      
            SET @P_RET_PROCESO = 2

            SET @P_MSG_PROCESO = ''Hay ''+ CONVERT(VARCHAR, @CantidadSinDigitalizarChe) +'' cheques sin digitalizar''
      		
      		SET @PKG_CONSTANTES$C_LOG_TIPO_INFORMACION$6 = ''Hay ''+ CONVERT(VARCHAR, @CantidadSinDigitalizarChe) +'' cheques sin digitalizar''
      		                           
      		    EXECUTE dbo.PKG_LOG_PROCESO$PROC_INS_LOG_PROCESO 
               @P_ID_PROCESO, 
               @P_DT_PROCESO, 
               ''CONTROLCHQDIGITALIZADO'', 
               @P_RET_PROCESO, 
               @P_MSG_PROCESO, 
               @PKG_CONSTANTES$C_LOG_TIPO_INFORMACION$6
      
      END
      
      IF @CantidadSinDigitalizarChe = 0 AND @CantidadSinDigitalizarDPF > 0
      BEGIN
      
            SET @P_RET_PROCESO = 2

            SET @P_MSG_PROCESO = ''Hay ''+ CONVERT(VARCHAR, @CantidadSinDigitalizarDPF) +'' plazos fijos sin digitalizar''
      		
      		SET @PKG_CONSTANTES$C_LOG_TIPO_INFORMACION$6 = ''Hay ''+ CONVERT(VARCHAR, @CantidadSinDigitalizarChe) +'' plazos fijos sin digitalizar''
      		                           
      		    EXECUTE dbo.PKG_LOG_PROCESO$PROC_INS_LOG_PROCESO 
               @P_ID_PROCESO, 
               @P_DT_PROCESO, 
               ''CONTROLCHQDIGITALIZADO'', 
               @P_RET_PROCESO, 
               @P_MSG_PROCESO, 
               @PKG_CONSTANTES$C_LOG_TIPO_INFORMACION$6
      
      END
      
      IF @CantidadSinDigitalizarChe > 0 AND @CantidadSinDigitalizarDPF > 0
      BEGIN
      
            SET @P_RET_PROCESO = 2

            SET @P_MSG_PROCESO = ''Hay ''+ CONVERT(VARCHAR, @CantidadSinDigitalizarChe) +'' cheques y '' + CONVERT(VARCHAR, @CantidadSinDigitalizarDPF) + '' plazos fijos sin digitalizar''
      		
      		SET @PKG_CONSTANTES$C_LOG_TIPO_INFORMACION$6 = ''Hay ''+ CONVERT(VARCHAR, @CantidadSinDigitalizarChe) +'' cheques y '' + CONVERT(VARCHAR, @CantidadSinDigitalizarDPF) + '' plazos fijos sin digitalizar''
      		                           
      		    EXECUTE dbo.PKG_LOG_PROCESO$PROC_INS_LOG_PROCESO 
               @P_ID_PROCESO, 
               @P_DT_PROCESO, 
               ''CONTROLCHQDIGITALIZADO'', 
               @P_RET_PROCESO, 
               @P_MSG_PROCESO, 
               @PKG_CONSTANTES$C_LOG_TIPO_INFORMACION$6
      
      END
      
      
END

')

