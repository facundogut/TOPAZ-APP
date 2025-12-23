EXECUTE('
CREATE OR ALTER PROCEDURE SP_DEBITOS_DIRECTOS_RENDIDOS
/*	EL STORED PROCEDURE SE LLAMARÁ DESDE LAS OPERACIONES 2636 Y 2664
	Marcando o desmarcando los registros como rendidos, según el parámetro funcionalidad
	con el que se lo llame */

	@P_ID_PROCESO FLOAT(53), /* Identificador de proceso */
	@P_DT_PROCESO DATETIME,	/* Fecha de proceso */
	@P_CONVENIO NUMERIC(15), /* Número del convenio que está siendo rendido o reversado */
	@P_FUNCIONALIDAD NUMERIC(1), /* 1: Marcar como rendidos, 2: Desmarcar registros rendidos */
	@P_FECHA_RENDIDO DATETIME, /* Fecha en que se hizo la rendición, para reversa */
	@P_RET_PROCESO FLOAT(53) OUTPUT, /* Estado de ejecucion del PL/SQL(1:Correcto, 2: Error) */
	@P_MSG_PROCESO VARCHAR(max) OUTPUT /* Mensaje para el usuario */

AS

BEGIN

	DECLARE
	--CONSTANTE PARA SP MENSAJE DE ERROR
	--CONTADOR PARA MENSAJE INFORMATIVO
		@v_constante VARCHAR(1),
		@contador_registros INT

	--TABLA AUXILIAR--
	DECLARE @TMPOrdenesAProcesar TABLE (
		CUIT_EO NUMERIC (11, 0),
		ID_ARCHIVO VARCHAR (30),
		NRO_ARCHIVO NUMERIC (15, 0),
		CORRELATIVO NUMERIC (9, 0)
	)
	
	BEGIN TRY
	
		IF @P_FUNCIONALIDAD = 1 
			BEGIN
				--***FUNCIONALIDAD 1 DE MARCAR COMO RENDIDOS***--
				--CARGAMOS TABLA TEMPORAL--
				INSERT INTO @TMPOrdenesAProcesar
				SELECT
					O.CUIT_EO,
					O.ID_ARCHIVO,
					O.NRO_ARCHIVO,
					O.CORRELATIVO
				FROM SNP_MSG_ORDENES AS O WITH (nolock)
				WHERE 
					O.TIPO_ORDEN = ''DEBREC''
					AND O.ESTADO = ''PR''
					AND O.RENDIDA <> ''S''
					AND O.FECHA_COMPENSACION <= (SELECT FECHAPROCESO FROM PARAMETROS WITH (nolock))
					AND O.CONVENIO = @P_CONVENIO
					AND O.TZ_LOCK = 0
				
				SET @contador_registros = ISNULL((SELECT COUNT(*) FROM @TMPOrdenesAProcesar),0)
		
				BEGIN
					--MARCAMOS REGISTROS COMO RENDIDOS Y ACTUALIZAMOS LA FECHA DE RENDIDO
					UPDATE SNP_MSG_ORDENES
					SET RENDIDA = ''S'',
						FECHA_RENDIDA = (SELECT FECHAPROCESO FROM PARAMETROS WITH (nolock))
					FROM SNP_MSG_ORDENES AS O WITH (nolock)
					INNER JOIN @TMPOrdenesAProcesar AS T ON
						T.CUIT_EO = O.CUIT_EO
						AND T.ID_ARCHIVO = O.ID_ARCHIVO
						AND T.NRO_ARCHIVO = O.NRO_ARCHIVO
						AND T.CORRELATIVO = O.CORRELATIVO
				END
		
				SET @P_MSG_PROCESO = ''Se han marcado correctamente como rendidas ''+ CONVERT(VARCHAR(10), @contador_registros) + 
					'' ordenes de débito directo para el convenio '' + CONVERT(VARCHAR(15), @P_CONVENIO)
			END
	
		ELSE IF @P_FUNCIONALIDAD = 2
			BEGIN
				--***FUNCIONALIDAD 2 DE DESMARCAR COMO RENDIDOS***--
				--CARGAMOS TABLA TEMPORAL--
				INSERT INTO @TMPOrdenesAProcesar
				SELECT
					O.CUIT_EO,
					O.ID_ARCHIVO,
					O.NRO_ARCHIVO,
					O.CORRELATIVO
				FROM SNP_MSG_ORDENES AS O WITH (nolock)
				WHERE 
					O.TIPO_ORDEN = ''DEBREC''
					AND O.ESTADO = ''PR''
					AND O.RENDIDA = ''S''
					AND O.FECHA_RENDIDA = @P_FECHA_RENDIDO
					AND O.CONVENIO = @P_CONVENIO
					AND O.TZ_LOCK = 0
	
				SET @contador_registros = ISNULL((SELECT COUNT(*) FROM @TMPOrdenesAProcesar),0)
				
				BEGIN				
				--DESMARCAMOS REGISTROS COMO RENDIDOS Y QUITAMOS LA FECHA DE RENDIDO
					UPDATE SNP_MSG_ORDENES
					SET RENDIDA = ''N'',
						FECHA_RENDIDA = NULL
					FROM SNP_MSG_ORDENES AS O WITH (nolock)
					INNER JOIN @TMPOrdenesAProcesar AS T ON
						T.CUIT_EO = O.CUIT_EO
						AND T.ID_ARCHIVO = O.ID_ARCHIVO
						AND T.NRO_ARCHIVO = O.NRO_ARCHIVO
						AND T.CORRELATIVO = O.CORRELATIVO
				END
	
				SET @P_MSG_PROCESO = ''Se han desmarcado como rendidas correctamente ''+ CONVERT(VARCHAR(10), @contador_registros) + 
					'' ordenes de débito directo para el convenio '' + CONVERT(VARCHAR(15), @P_CONVENIO)

			END
			
		ELSE
			--***SI VIENE OTRA FUNCIONALIDAD COMO PARÁMETRO, ARROJO UN ERROR***--
			BEGIN
				THROW 50000, ''Error - Código de funcionalidad incorrecto, se esperaba 1 o 2.'', 1
			END

		SET @P_RET_PROCESO = 1
	
		DECLARE
	       @PKG_CONSTANTES$C_LOG_TIPO_INFORMACION varchar(30)
	    SET @PKG_CONSTANTES$C_LOG_TIPO_INFORMACION = ''I''
	
	    EXECUTE dbo.PKG_LOG_PROCESO$PROC_INS_LOG_PROCESO 
	       @P_ID_PROCESO = @P_ID_PROCESO, 
	       @P_FCH_PROCESO = @P_DT_PROCESO, 
	       @P_NOM_PACKAGE = ''SP_DEBITOS_DIRECTOS_RENDIDOS'', 
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
           IF @P_FUNCIONALIDAD = 2
           	BEGIN
           		SET @P_MSG_PROCESO = ''Error en la reversa de rendición convenio débitos directos. '' + @errormessage
           	END
           ELSE
           	BEGIN
           		SET @P_MSG_PROCESO = ''Error en la rendición convenio débitos directos. '' + @errormessage
           	END
           DECLARE
              @PKG_CONSTANTES$C_LOG_TIPO_ERROR varchar(30)
           SET @PKG_CONSTANTES$C_LOG_TIPO_ERROR = ''E''
           EXECUTE dbo.PKG_LOG_PROCESO$PROC_INS_LOG_PROCESO 
              @P_ID_PROCESO = @P_ID_PROCESO, 
              @P_FCH_PROCESO = @P_DT_PROCESO, 
              @P_NOM_PACKAGE = ''SP_DEBITOS_DIRECTOS_RENDIDOS'', 
              @P_COD_ERROR = @P_RET_PROCESO, 
              @P_MSG_ERROR = @P_MSG_PROCESO, 
              @P_TIPO_ERROR = @PKG_CONSTANTES$C_LOG_TIPO_ERROR
        END
     END CATCH
END
')

