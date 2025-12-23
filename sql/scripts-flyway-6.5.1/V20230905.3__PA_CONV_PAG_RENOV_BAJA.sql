
EXECUTE('
CREATE OR ALTER PROCEDURE [dbo].[PA_CONV_PAG_RENOV_BAJA]
	/*ADAPTADO SIN CURSORES POR JMB*/
	@P_ID_PROCESO  float(53),
	@P_DT_PROCESO  datetime2(0),
	@P_RET_PROCESO float(53)  OUTPUT,
	@P_MSG_PROCESO varchar(max)  OUTPUT
AS
BEGIN

	SET @P_RET_PROCESO = NULL
	SET @P_MSG_PROCESO = NULL
	
	DECLARE @P_CLAVE       varchar(max),
	        @P_SUCURSAL    float(53)
	
	SELECT @P_CLAVE = USERNAME FROM PM_BTPROCESS WHERE EXECUTION_ID = @P_ID_PROCESO
	
	SELECT @P_SUCURSAL = NROSUCURSAL FROM USUARIOS WHERE CLAVE = @P_CLAVE
	
	
	--VARIABLES AUXILIARES--
	DECLARE @FECHAPROCESO DATETIME
			,@v_constante VARCHAR(1)

	SET @FECHAPROCESO = (SELECT FECHAPROCESO FROM PARAMETROS WITH (NOLOCK))

	--DECLARO TABLA AUXILIAR--
	DECLARE @TablaAuxiliar TABLE(
		ID_CONVENIO_PAG NUMERIC	(15, 0),
		FECHA_VTO DATETIME,
		ESTADO VARCHAR (1),
		FECHA_ULT_ACT DATETIME,
		FECHA_CBIO_EST DATETIME,
		RENOV_AUT VARCHAR (1),
		PLAZO NUMERIC (4, 0)
	)

	--COMPLETO TABLA AUXILIAR--
	INSERT INTO
		@TablaAuxiliar
	SELECT
		P.ID_ConvPago,
		P.FecVto,
		P.Estado,
		P.FecUltAct,
		P.FecCamEst,
		P.RenAuto,
		P.Plazo
	FROM
		CONV_CONVENIOS_PAG AS P
	WHERE
		P.Estado = ''A''
		AND P.FecVto = @FECHAPROCESO
		AND P.TZ_LOCK = 0

	BEGIN TRANSACTION

	BEGIN TRY

		--ACTUALIZO FECHA DE VENCIMIENTO DEL CONVENIO--
		UPDATE P
		SET
			P.FecVto = DATEADD(MM,T.PLAZO,T.FECHA_VTO),
			P.FecUltAct = @FECHAPROCESO
		FROM
			CONV_CONVENIOS_PAG AS P
		INNER JOIN @TablaAuxiliar AS T ON
			T.ID_CONVENIO_PAG = P.ID_ConvPago
			AND T.RENOV_AUT IN (''S'')
		-----------------------------------------------

		--GRABO REGISTRO DE BITÁCORA ALTA--
		INSERT INTO
			CONV_BITACORA
		SELECT
			T.ID_CONVENIO_PAG,
			''P'',
			(SELECT ISNULL(MAX(Bit_Corr), 0) + 1 FROM CONV_BITACORA WITH (NOLOCK) WHERE Id_Convenio=T.ID_CONVENIO_PAG AND TpoConv=''P''),
			''A'',
			@FECHAPROCESO,
			NULL,
			0,
			@P_SUCURSAL,
			@P_CLAVE,
			CONCAT(''Se renueva automáticamente el convenio: '',T.ID_CONVENIO_PAG,'' con fecha: '',DATEADD(MM,T.PLAZO,T.FECHA_VTO)),
			0
		FROM @TablaAuxiliar AS T
		WHERE T.RENOV_AUT IN (''S'')
		-----------------------------------

		--ACTUALIZO ESTADO DE BAJA Y FECHAS--
		UPDATE P
		SET
			P.Estado = ''B'',
			--P.FecUltAct = @FECHAPROCESO,
			P.FecCamEst = @FECHAPROCESO
		FROM
			CONV_CONVENIOS_PAG AS P
		INNER JOIN @TablaAuxiliar AS T ON
			T.ID_CONVENIO_PAG = P.ID_ConvPago
			AND T.RENOV_AUT NOT IN (''S'')
		-------------------------------------

		--GRABO REGISTRO DE BITÁCORA BAJA--
		INSERT INTO
			CONV_BITACORA
		SELECT
			T.ID_CONVENIO_PAG,
			''P'',
			(SELECT ISNULL(MAX(Bit_Corr), 0) + 1 FROM CONV_BITACORA WITH (NOLOCK) WHERE Id_Convenio=T.ID_CONVENIO_PAG AND TpoConv=''P''),
			''B'',
			@FECHAPROCESO,
			NULL,
			0,
			@P_SUCURSAL,
			@P_CLAVE,
			CONCAT(''Se da de baja el convenio: '',T.ID_CONVENIO_PAG,'' por fecha de Vencimiento''),
			0
		FROM @TablaAuxiliar AS T
		WHERE T.RENOV_AUT NOT IN (''S'')
		-----------------------------------

		--FINALIZA PROCESO--
		SET @P_RET_PROCESO = 1
		SET @P_MSG_PROCESO = ''Renovación automática / Baja funcionó correctamente. Se renovaron '' + ISNULL(CAST((SELECT COUNT(1) FROM @TablaAuxiliar WHERE RENOV_AUT IN (''S'')) AS NVARCHAR(max)), '''') + '' Convenios y se dieron de baja ''+ ISNULL(CAST((SELECT COUNT(1) FROM @TablaAuxiliar WHERE RENOV_AUT NOT IN (''S'')) AS NVARCHAR(max)), '''') + '' Convenios.''

		EXECUTE dbo.pkg_constantes$VarcharConstantes ''C_LOG_TIPO_INFORMACION'', @v_constante OUTPUT;

		EXECUTE PKG_LOG_PROCESO$PROC_INS_LOG_PROCESO
			@P_ID_PROCESO = @P_ID_PROCESO,
			@P_FCH_PROCESO = @P_DT_PROCESO,
			@P_NOM_PACKAGE = ''PA_CONV_PAG_RENOV_AUTO_BAJA'',
			@P_COD_ERROR = @P_RET_PROCESO,
			@P_MSG_ERROR = @P_MSG_PROCESO,
			@P_TIPO_ERROR = @v_constante
		--------------------

		COMMIT TRANSACTION;

	END TRY

	BEGIN CATCH

		BEGIN
   
         	ROLLBACK TRANSACTION

         	--Valores de Retorno.--
            SET @P_RET_PROCESO = ERROR_NUMBER()

            SET @P_MSG_PROCESO = ERROR_MESSAGE()

            EXECUTE dbo.pkg_constantes$VarcharConstantes ''C_LOG_TIPO_ERROR'', @v_constante OUTPUT;

            EXECUTE dbo.PKG_LOG_PROCESO$proc_ins_log_proceso
				@p_id_proceso = @P_ID_PROCESO,
				@p_fch_proceso = @P_DT_PROCESO,
				@p_nom_package = ''PA_CONV_PAG_RENOV_AUTO_BAJA'',
				@p_cod_error = @P_RET_PROCESO,
				@p_msg_error = @P_MSG_PROCESO,
				@p_tipo_error = @v_constante

		END

	END CATCH

END

')