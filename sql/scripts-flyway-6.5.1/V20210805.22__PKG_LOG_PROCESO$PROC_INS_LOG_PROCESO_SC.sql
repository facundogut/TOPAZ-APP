/****** Object:  StoredProcedure [dbo].[PKG_LOG_PROCESO$PROC_INS_LOG_PROCESO_SC]    Script Date: 18/06/2021 16:16:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[PKG_LOG_PROCESO$PROC_INS_LOG_PROCESO_SC]  
   @p_id_proceso float(53),
   @p_fch_proceso datetime,
   @p_nom_package varchar(max),
   @p_cod_error float(53),
   @p_msg_error varchar(max),
   @p_tipo_error varchar(max)
AS 
   BEGIN
      SET XACT_ABORT ON;
      BEGIN TRY
         BEGIN TRANSACTION
         INSERT LOG_PROCESO(
            ID_PROCESO, 
            FECHA_ERROR, 
            NOM_PACKAGE, 
            COD_ERROR, 
            MSG_ERROR, 
            TIPO_ERROR)
            VALUES (
               @p_id_proceso, 
               @p_fch_proceso, 
               @p_nom_package, 
               @p_cod_error, 
               @p_msg_error, 
               @p_tipo_error)
         COMMIT TRANSACTION
      END TRY

      BEGIN CATCH
         EXEC pkg_constantes$sp_GetErrorInfo;
         IF (XACT_STATE()) = -1
         BEGIN
            ROLLBACK TRANSACTION
         END
         IF (XACT_STATE()) = 1
         BEGIN
            COMMIT TRANSACTION
         END
         --
         BEGIN
            DECLARE
               @db_null_statement int
         END
      END CATCH
  
   END
GO

EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'BANKPROD.PKG_LOG_PROCESO.proc_ins_log_proceso_sc' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'PROCEDURE',@level1name=N'PKG_LOG_PROCESO$PROC_INS_LOG_PROCESO_SC'
GO


