EXECUTE('
CREATE OR ALTER PROCEDURE PA_BLOQUEAR_INMOVILIZADOS_VISTA
/*	EL STORED PROCEDURE CORRERÁ LUEGO DEL PA CBL - Cambio de Rubro Vista
	en la cadena de cierre, generando un bloqueo código 19 para cada saldo
	de cuenta vista inmovilizado, que no tenga uno.	*/	

	@P_ID_PROCESO FLOAT(53), /* Identificador de proceso */
	@P_DT_PROCESO DATETIME,	/* Fecha de proceso */
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
	DECLARE @TMPSaldosInmovilizados TABLE (
			SALDO_JTS_OID NUMERIC (10, 0),
			ORDINAL_BLOQUEO NUMERIC (15, 0)
	)

	BEGIN TRANSACTION

	BEGIN TRY

		--CARGAMOS TABLA TEMPORAL--
		INSERT INTO @TMPSaldosInmovilizados
			SELECT 
				S.JTS_OID,
				(SELECT COUNT(*) + 1 
					FROM GRL_BLOQUEOS WITH (nolock)
					WHERE SALDO_JTS_OID = S.JTS_OID
						AND COD_BLOQUEO = (	SELECT NUMERICO 
											FROM PARAMETROSGENERALES WITH (nolock) 
											WHERE CODIGO = 237 AND TZ_LOCK = 0)
				) AS ORDINAL_BLOQUEO
			FROM SALDOS AS S WITH (nolock)
			WHERE 
				S.C1651 <> ''1'' --NO CANCELADO
				AND S.C1785 IN (2,3) --CUENTA VISTA
				AND S.C1734 = ''I'' --MARCADO PARA INMOVILIZAR
				AND S.C1734 = S.C1728 --CON CAMBIO DE RUBRO EFECTIVO
				--AND S.C3877 IN (SELECT FECHAPROCESO FROM PARAMETROS) --INMOVILIZADO HOY
				AND S.TZ_LOCK = 0
				AND S.JTS_OID NOT IN (SELECT B.SALDO_JTS_OID
									FROM GRL_BLOQUEOS AS B WITH (nolock)
									WHERE
										B.ESTADO = 1
										AND B.TZ_LOCK = 0
										AND B.COD_BLOQUEO IN (	SELECT NUMERICO 
																FROM PARAMETROSGENERALES WITH (nolock)
																WHERE CODIGO = 237 AND TZ_LOCK = 0
										)
				)

		SET @contador_registros = ISNULL((SELECT COUNT(*) FROM @TMPSaldosInmovilizados),0)
			
		BEGIN
			--ACTUALIZAMOS SALDOS
			UPDATE SALDOS
			SET C1679 = ''1''
			FROM SALDOS AS S WITH (nolock)
			INNER JOIN @TMPSaldosInmovilizados AS I ON
				I.SALDO_JTS_OID = S.JTS_OID

			--INSERTAMOS NUEVOS BLOQUEOS--
			INSERT INTO 
				GRL_BLOQUEOS
			SELECT
				I.SALDO_JTS_OID,
				(SELECT NUMERICO FROM PARAMETROSGENERALES WITH (nolock) WHERE CODIGO = 237 AND TZ_LOCK = 0) AS CODIGO,
				I.ORDINAL_BLOQUEO,
				(SELECT FECHAPROCESO FROM PARAMETROS) AS FECHA_VIGENCIA,
				NULL AS FECHA_VENCIMIENTO,
				0 AS MANEJA_VENCIMIENTO,
				''Bloqueo por inmovilizado'' AS DESCRIPCION,
				1 AS ESTADO, --ESTADO ACTIVO
				'''' AS USUARIO_INGRESO,
				(SELECT FECHAPROCESO FROM PARAMETROS) AS FECHA_GRABADA,
				NULL AS USUARIO_MODIFICACION,
				NULL AS FECHA_MODIFICACION,
				0 AS TZ_LOCK,
				''I'' AS PORORDEN, --INSTITUCION
				''Procedimiento innmovilización'' AS SOLICITADOPOR
			FROM @TMPSaldosInmovilizados AS I

		END

		SET @P_MSG_PROCESO = ''El proceso de bloqueo de cuentas vistas inmovilizadas ha culminado correctamente. '' + 
			''Saldos Inmovilizados: ''+ CONVERT(VARCHAR(10), @contador_registros)
		SET @P_RET_PROCESO = 1

		DECLARE
           @PKG_CONSTANTES$C_LOG_TIPO_INFORMACION varchar(30)
        SET @PKG_CONSTANTES$C_LOG_TIPO_INFORMACION = ''I''

        EXECUTE dbo.PKG_LOG_PROCESO$PROC_INS_LOG_PROCESO 
           @P_ID_PROCESO = @P_ID_PROCESO, 
           @P_FCH_PROCESO = @P_DT_PROCESO, 
           @P_NOM_PACKAGE = ''PA_BLOQUEAR_INMOVILIZADOS_VISTA'', 
           @P_COD_ERROR = @P_RET_PROCESO, 
           @P_MSG_ERROR = @P_MSG_PROCESO, 
           @P_TIPO_ERROR = @PKG_CONSTANTES$C_LOG_TIPO_INFORMACION

		COMMIT

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
           SET @P_MSG_PROCESO = ''Error en el bloqueo de cuentas vistas inmovilizadas''
           DECLARE
              @PKG_CONSTANTES$C_LOG_TIPO_ERROR varchar(30)
           SET @PKG_CONSTANTES$C_LOG_TIPO_ERROR = ''E''
           EXECUTE dbo.PKG_LOG_PROCESO$PROC_INS_LOG_PROCESO 
              @P_ID_PROCESO = @P_ID_PROCESO, 
              @P_FCH_PROCESO = @P_DT_PROCESO, 
              @P_NOM_PACKAGE = ''PA_BLOQUEAR_INMOVILIZADOS_VISTA'', 
              @P_COD_ERROR = @P_RET_PROCESO, 
              @P_MSG_ERROR = @P_MSG_PROCESO, 
              @P_TIPO_ERROR = @PKG_CONSTANTES$C_LOG_TIPO_ERROR
        END
     END CATCH
END
')