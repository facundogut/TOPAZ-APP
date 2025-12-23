EXECUTE('
/****** Object:  StoredProcedure [dbo].[PA_GENERACIONAVISOSCOFRES]    Script Date: 01/06/2021 12:53:05 ******/
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

')
EXECUTE('

ALTER PROCEDURE [dbo].[PA_GENERACIONAVISOSCOFRES]  

   @P_ID_PROCESO float(53),
   @P_DT_PROCESO DATETIME,
   @P_RET_PROCESO float(53)  OUTPUT,
   @P_MSG_PROCESO varchar(max)  OUTPUT
   
AS 
   BEGIN

      SET @P_RET_PROCESO = NULL
      SET @P_MSG_PROCESO = NULL
      BEGIN
         BEGIN TRY
            UPDATE dbo.COF_COFRES_CONTRATOS
               SET 
                  AVISO_EMITIDO = 1
            WHERE 
               COF_COFRES_CONTRATOS.AVISO_EMITIDO = 0 AND 
               COF_COFRES_CONTRATOS.RETIENE_CORRESPONDENCIA = ''N'' AND 
               datediff(day, (SELECT PARAMETROS.FECHAPROCESO
                  				FROM dbo.PARAMETROS WITH (NOLOCK)), 
               (
                  COF_COFRES_CONTRATOS.FECHA_VENCIMIENTO
               )) <= 15 AND 
               datediff(day, (SELECT PARAMETROS$2.FECHAPROCESO
                  				FROM dbo.PARAMETROS AS PARAMETROS$2 WITH (NOLOCK)
							), 
               (
                  COF_COFRES_CONTRATOS.FECHA_VENCIMIENTO
               )) >= 0 AND 
               (COF_COFRES_CONTRATOS.TZ_LOCK < 300000000000000 OR COF_COFRES_CONTRATOS.TZ_LOCK >= 400000000000000)

            SET @P_RET_PROCESO = 1
            SET @P_MSG_PROCESO = ''Generación del Pre Aviso de Cofres Finalizo Correctamente ''
            DECLARE
               @PKG_CONSTANTES$C_LOG_TIPO_INFORMACION varchar(30)
            SET @PKG_CONSTANTES$C_LOG_TIPO_INFORMACION = ''I''

            EXECUTE dbo.PKG_LOG_PROCESO$PROC_INS_LOG_PROCESO 
               @P_ID_PROCESO = @P_ID_PROCESO, 
               @P_FCH_PROCESO = @P_DT_PROCESO, 
               @P_NOM_PACKAGE = ''GENERACIONAVISOCOFRES'', 
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
               SET @P_MSG_PROCESO = ''Error en la Generación del Pre Aviso de Cofres''
               DECLARE
                  @PKG_CONSTANTES$C_LOG_TIPO_ERROR varchar(30)
               SET @PKG_CONSTANTES$C_LOG_TIPO_ERROR = ''I''
               EXECUTE dbo.PKG_LOG_PROCESO$PROC_INS_LOG_PROCESO 
                  @P_ID_PROCESO = @P_ID_PROCESO, 
                  @P_FCH_PROCESO = @P_DT_PROCESO, 
                  @P_NOM_PACKAGE = ''PA_GENERACIONAVISOSCOFRES'', 
                  @P_COD_ERROR = @P_RET_PROCESO, 
                  @P_MSG_ERROR = @P_MSG_PROCESO, 
                  @P_TIPO_ERROR = @PKG_CONSTANTES$C_LOG_TIPO_ERROR
            END
         END CATCH
      END
   END
')