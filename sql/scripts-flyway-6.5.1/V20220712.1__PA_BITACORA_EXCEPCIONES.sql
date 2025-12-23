EXECUTE('
CREATE OR ALTER  PROCEDURE [dbo].[PA_BITACORA_EXCEPCIONES] 
											   @P_ID_PROCESO float(53),
											   @P_DT_PROCESO DATETIME,
											   @P_RET_PROCESO float(53)  OUTPUT,
											   @P_MSG_PROCESO varchar(max)  OUTPUT
   
AS 
   BEGIN
	   
	  DECLARE @MSG_MAIL_INICIADOS  varchar(MAX)
	  DECLARE @MSG_MAIL_FINALIZADOS  varchar(MAX)
	  DECLARE @MAIL_TO   varchar(MAX)
	  DECLARE @MAIL_FROM varchar(MAX)
	  DECLARE @SUBJECT   varchar(MAX)
	  DECLARE @MAIL_OID  numeric(38)
	  DECLARE @FECHA     date
	  DECLARE @FECHASTR  varchar(MAX)
	  DECLARE @TEXTO_INICIADOS NVARCHAR(MAX)
	  DECLARE @TEXTO_FINALIZADOS NVARCHAR(MAX)


      SET @P_RET_PROCESO = NULL

      SET @P_MSG_PROCESO = NULL

      BEGIN

         BEGIN TRY
         
            SET @FECHA     = (SELECT FECHAPROCESO FROM PARAMETROS)
            SET @FECHASTR = convert(varchar, @FECHA, 3)
            
            -- MAIL DE RESTRICCIONES FINALIZADAS
			SET @TEXTO_FINALIZADOS = N''<table>''
			    + N''<tr><th>Grupo</th><th>Título</th><th>Operación</th><th>Descripción</th><th>Tipo de Excepción</th><th>Fecha Inicio</th><th>Fecha Fin</th></tr>''
			    + CAST((
					SELECT  CONCAT(p.GRUPO_CODIGO , 
							'' - '', (SELECT DESCRIPCION FROM GRUPOS WITH (NOLOCK) WHERE GRUPO = p.GRUPO_CODIGO), ''  '') AS td,
							CONCAT(SUBSTRING(p.IDENTIFICACION_RESTRICCION, 1,4), ''  '') AS td,
							CONCAT(SUBSTRING(p.IDENTIFICACION_RESTRICCION, 5,4), ''  '') AS td,
							CONCAT(p.DESCRIPCION_RESTRICCION, ''  '') AS td,
							CASE
								WHEN p.PERMITE_RESTRICCION = 0 THEN ''Deshabilitación''
								WHEN p.PERMITE_RESTRICCION = 1 THEN ''Habilitación''
								WHEN p.PERMITE_RESTRICCION = 2 THEN ''Liberación''
							END as td,--END as Tipo,
							CONCAT(convert(varchar, p.FECHA_HORA_MODIFICADO , 3), ''  '') AS td,
							convert(varchar, p.FECHA_HABILITACION_RESTRICCION, 3) AS td
			        FROM    BITACORA_RESTRICCIONES p WITH (NOLOCK)
			        WHERE   p.TIPO_RESTRICCION = ''O'' 
							AND CAST(p.FECHA_HABILITACION_RESTRICCION AS DATE) = @FECHA
			        ORDER BY p.USUARIORED 
			        FOR XML RAW(''tr''), ELEMENTS
			    ) AS NVARCHAR(MAX))
			    + N''</table>''
			
	        IF @TEXTO_FINALIZADOS IS NULL
	    		SET @TEXTO_FINALIZADOS = ''No hay registros.''
            
			SET @MSG_MAIL_FINALIZADOS = ''Html=BitacoraRestriccionesFinalizadas.html;Variables=Dia::''+@FECHASTR+'';Variables=Texto::''+@TEXTO_FINALIZADOS+'';''
			SET @MAIL_TO  = (SELECT ALFA FROM PARAMETROSGENERALES WITH (NOLOCK) WHERE CODIGO = 206)
			SET @MAIL_FROM = (SELECT ALFA FROM PARAMETROSGENERALES WITH (NOLOCK) WHERE CODIGO = 205)
			SET @SUBJECT   = ''Finalizacion Excepciones''
			SET @MAIL_OID  = (	SELECT TOP 1 MAIL_OID F
								FROM CORREOS_A_ENVIAR WITH (NOLOCK)
								ORDER BY MAIL_OID DESC) + 1

            INSERT INTO CORREOS_A_ENVIAR VALUES(@MAIL_OID, @MAIL_TO, @MAIL_FROM, @MSG_MAIL_FINALIZADOS, 0, @SUBJECT, @FECHA, 0)
            
            -- MAIL DE RESTRICCIONES INICIALIZADAS
			SET @TEXTO_INICIADOS = N''<table>''
			    + N''<tr><th>Grupo</th><th>Título</th><th>Operación</th><th>Descripción</th><th>Tipo de Excepción</th><th>Fecha Inicio</th><th>Fecha Fin</th></tr>''
			    + CAST((
					SELECT  CONCAT(p.GRUPO_CODIGO , 
							'' - '', (SELECT DESCRIPCION 
									FROM GRUPOS WITH (NOLOCK)
									WHERE GRUPO = p.GRUPO_CODIGO), ''  '') AS td,
							CONCAT(SUBSTRING(p.IDENTIFICACION_RESTRICCION, 1,4), ''  '') AS td,
							CONCAT(SUBSTRING(p.IDENTIFICACION_RESTRICCION, 5,4), ''  '') AS td,
							CONCAT(p.DESCRIPCION_RESTRICCION, ''  '') AS td,
							CASE
								WHEN p.PERMITE_RESTRICCION = 0 THEN ''Deshabilitación''
								WHEN p.PERMITE_RESTRICCION = 1 THEN ''Habilitación''
								WHEN p.PERMITE_RESTRICCION = 2 THEN ''Liberación''
							END as td,--END as Tipo, generaba etiqueta HTML erronea
							CONCAT(convert(varchar, p.FECHA_HORA_MODIFICADO , 3), ''  '') AS td,
							convert(varchar, p.FECHA_HABILITACION_RESTRICCION, 3) AS td
			        FROM    BITACORA_RESTRICCIONES p WITH (NOLOCK)
			        WHERE   p.TIPO_RESTRICCION = ''O'' 
							AND CAST(p.FECHA_HORA_MODIFICADO AS DATE) = @FECHA
			        FOR XML RAW(''tr''), ELEMENTS
			    ) AS NVARCHAR(MAX))
			    + N''</table>''
			    
		    IF @TEXTO_INICIADOS IS NULL
		    	SET @TEXTO_INICIADOS = ''No hay registros.''
			   
			SET @MSG_MAIL_INICIADOS = ''Html=BitacoraRestriccionesIniciadas.html;Variables=Dia::''+@FECHASTR+'';Variables=Texto::''+@TEXTO_INICIADOS+'';''
			SET @MAIL_OID = @MAIL_OID+1
			SET @SUBJECT  = ''Inicio Excepciones''
			    
            INSERT INTO CORREOS_A_ENVIAR VALUES(@MAIL_OID, @MAIL_TO, @MAIL_FROM, @MSG_MAIL_INICIADOS, 0, @SUBJECT, @FECHA, 0)		   

            SET @P_RET_PROCESO = 1

            SET @P_MSG_PROCESO = ''Generación del Mail Exepciones de bitácora Finalizo Correctamente''

            DECLARE
               @PKG_CONSTANTES$C_LOG_TIPO_INFORMACION varchar(30)
            SET @PKG_CONSTANTES$C_LOG_TIPO_INFORMACION = ''I''

            EXECUTE dbo.PKG_LOG_PROCESO$PROC_INS_LOG_PROCESO 
               @P_ID_PROCESO = @P_ID_PROCESO, 
               @P_FCH_PROCESO = @P_DT_PROCESO, 
               @P_NOM_PACKAGE = ''PA_BITACORA_EXCEPCIONES'', 
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

               SET @P_MSG_PROCESO = ''Error en la Generación del Mail Exepciones de bitácora''

               DECLARE
                  @PKG_CONSTANTES$C_LOG_TIPO_ERROR varchar(30)

               SET @PKG_CONSTANTES$C_LOG_TIPO_ERROR = ''I''

               EXECUTE dbo.PKG_LOG_PROCESO$PROC_INS_LOG_PROCESO 
                  @P_ID_PROCESO = @P_ID_PROCESO, 
                  @P_FCH_PROCESO = @P_DT_PROCESO, 
                  @P_NOM_PACKAGE = ''PA_BITACORA_EXCEPCIONES'', 
                  @P_COD_ERROR = @P_RET_PROCESO, 
                  @P_MSG_ERROR = @P_MSG_PROCESO, 
                  @P_TIPO_ERROR = @PKG_CONSTANTES$C_LOG_TIPO_ERROR

            END

         END CATCH

      END

   END
')