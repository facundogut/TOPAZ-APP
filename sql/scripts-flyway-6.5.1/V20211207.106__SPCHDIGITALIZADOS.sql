EXECUTE('
CREATE PROCEDURE [dbo].[PA_CONTROL_CH_DIGITALIZACION]
   @P_ID_PROCESO float(53),
   @P_DT_PROCESO datetime2(0),
   @P_RET_PROCESO float(53) OUTPUT,
   @P_MSG_PROCESO varchar(max) OUTPUT
AS
BEGIN
      SET @P_RET_PROCESO = NULL
      SET @P_MSG_PROCESO = NULL
      
      DECLARE 
      @CantidadSinDigitalizar NUMERIC(10)
      
     SELECT
	@CantidadSinDigitalizar = COUNT(*)
FROM
	CLE_CHEQUES_SALIENTE CS WITH (nolock),
	PARAMETROS P WITH (nolock)
WHERE
	CS.FECHA_ENVIO_COMPENSACION IS NULL
	AND CS.FECHA_ENVIO_CAMARA <= P.FECHAPROCESO
	AND CS.CODIGO_CAMARA = 1
	AND CS.FECHA_RECEP_CENTRAL_CLEAR IS NOT NULL
	AND CS.ESTADO = 2
      
      IF @CantidadSinDigitalizar = 0
      BEGIN
      
            SET @P_RET_PROCESO = 1

            SET @P_MSG_PROCESO = ''No hay cheques sin digitalizar''
      END
      
            IF @CantidadSinDigitalizar > 0
      BEGIN
      
               DECLARE
               @PKG_CONSTANTES$C_LOG_TIPO_INFORMACION$6 varchar(8000)

      
            SET @P_RET_PROCESO = 2

            SET @P_MSG_PROCESO = ''Hay ''+ CONVERT(VARCHAR, @CantidadSinDigitalizar) +'' cheques sin digitalizar''
      		
      		SET @PKG_CONSTANTES$C_LOG_TIPO_INFORMACION$6 = ''Hay ''+ CONVERT(VARCHAR, @CantidadSinDigitalizar) +'' cheques sin digitalizar''
      		                           
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

