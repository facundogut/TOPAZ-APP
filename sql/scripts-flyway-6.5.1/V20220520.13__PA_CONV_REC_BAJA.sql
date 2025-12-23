EXECUTE('
----
ALTER PROCEDURE PA_CONV_REC_BAJA 
	@P_ID_PROCESO  float(53),
	@P_DT_PROCESO  datetime2(0),
	@P_CLAVE       varchar(max),
	@P_SUCURSAL    float(53),
	@P_NROMAQUINA  float(53),
	@P_RET_PROCESO float(53)  OUTPUT,
	@P_MSG_PROCESO varchar(max)  OUTPUT
   
AS 

	BEGIN
	
		SET @P_RET_PROCESO = NULL
	   	SET @P_MSG_PROCESO = NULL
	   	
		--VARIABLES AUXILIARES--
		DECLARE @FECHA DATETIME
				,@DIAS_MAIL NUMERIC(20,0)
				,@v_constante VARCHAR(1)
				,@v_mail_baja VARCHAR(2048)
	         	,@v_mail_prox VARCHAR(2048)
	         	,@v_mail_to VARCHAR(60)
	         	,@v_mail_from VARCHAR(60)
	         	
	    SET @v_mail_baja = ''''
	    SET @v_mail_prox = ''''
		
		SELECT @FECHA = FECHAPROCESO FROM PARAMETROS WITH (NOLOCK)
		SELECT @DIAS_MAIL = NUMERICO FROM PARAMETROSGENERALES WITH (NOLOCK) WHERE CODIGO = 203
		SELECT @v_mail_to = ALFA FROM PARAMETROSGENERALES WITH (NOLOCK) WHERE CODIGO=204
		SELECT @v_mail_from = ALFA FROM PARAMETROSGENERALES WITH (NOLOCK) WHERE CODIGO=205
		
		
		--DECLARO TABLA AUXILIAR--
		DECLARE @TablaAuxiliar TABLE(
			ID_CONVENIO_REC NUMERIC	(15, 0),
			NOMBRE_CONVENIO VARCHAR	(40),
			ID_TIPO_CONVENIO NUMERIC (5, 0),
			TIPO VARCHAR (1)
		)
		
		--COMPLETO TABLA AUXILIAR--
		INSERT INTO 
			@TablaAuxiliar
		SELECT
			R.Id_ConvRec,
			R.NomConvRec,
			R.Id_TpoConv,
			CASE
				WHEN 
					R.Estado = ''B'' THEN ''H''
				WHEN 
					DATEDIFF(MM, R.FecUltAct, @FECHA) > R.BajaAuto
					OR (DATEDIFF(MM, R.FecUltAct, @FECHA) = R.BajaAuto
						AND DAY(R.FecUltAct) <= DAY(@FECHA))
					THEN ''B''
				WHEN 
					DATEDIFF(MM, R.FecUltAct, (@FECHA + @DIAS_MAIL)) > R.BajaAuto
					OR (DATEDIFF(MM, R.FecUltAct, (@FECHA + @DIAS_MAIL)) = R.BajaAuto
						AND DAY(R.FecUltAct) <= DAY(@FECHA + @DIAS_MAIL))
					THEN ''M''
				ELSE ''N''		
			END AS TIPO
		FROM 
			CONV_CONVENIOS_REC AS R
		WHERE 
			(R.Estado = ''I''
			OR (R.Estado = ''B'' 
				AND R.FecCamEst = @FECHA))
			AND R.TZ_LOCK = 0
			
		--SELECT--
		BEGIN TRANSACTION
		
		BEGIN TRY
		
			--ACTUALIZO ESTADO DEL CONVENIO A BAJA--
			UPDATE R			 
			SET 
				R.Estado=''B'',
				R.FecCamEst = @FECHA
			FROM 
				CONV_CONVENIOS_REC AS R
			INNER JOIN @TablaAuxiliar AS T ON
				T.ID_CONVENIO_REC = R.Id_ConvRec
				AND T.TIPO IN (''B'')
			----------------------------------------
			
			--GRABO REGISTRO DE BITÁCORA--
			INSERT INTO 
				CONV_BITACORA 
			SELECT 
				T.ID_CONVENIO_REC,
				''R'',
				(SELECT ISNULL(MAX(Bit_Corr), 0) + 1 FROM CONV_BITACORA WITH (NOLOCK) WHERE Id_Convenio=T.ID_CONVENIO_REC AND TpoConv=''R''),
				''B'',
				@FECHA,
				NULL,
				0,
				@P_SUCURSAL,
				@P_CLAVE,
				''Baja Convenio PA'',
				0
			FROM @TablaAuxiliar AS T
			WHERE T.TIPO IN (''B'')
			------------------------------		
			
			--ARMO LISTAS DE MAILS--
			--DE BAJA--		
			SELECT @v_mail_baja = @v_mail_baja + CAST(T.ID_CONVENIO_REC AS nvarchar(max)) + '' '' + ISNULL(T.NOMBRE_CONVENIO,'''') + '';'' 
			FROM @TablaAuxiliar AS T
			WHERE T.TIPO IN (''B'', ''H'')
			
			IF @v_mail_baja <>''''
			BEGIN
				INSERT INTO CORREOS_A_ENVIAR (MAIL_TO, MAIL_FROM, DATA, INTENTOS, SUBJECT, FECHA_INGRESO, TZ_LOCK)
				VALUES (@v_mail_to, @v_mail_from, @v_mail_baja, 0, ''Lista Convenios Recaudación dados de Baja'', @FECHA, 0)
			END
			-----------
			
			--PROXIMOS--
			SELECT @v_mail_prox = @v_mail_prox + CAST(T.ID_CONVENIO_REC AS nvarchar(max)) + '' '' + ISNULL(T.NOMBRE_CONVENIO,'''') + '';'' 
			FROM @TablaAuxiliar AS T
			WHERE T.TIPO IN (''M'')
			
			IF @v_mail_prox <>''''         
			BEGIN
				INSERT INTO CORREOS_A_ENVIAR (MAIL_TO, MAIL_FROM, DATA, INTENTOS, SUBJECT, FECHA_INGRESO, TZ_LOCK)
				VALUES (@v_mail_to, @v_mail_from, @v_mail_prox, 0, ''Lista Convenios Recaudación próximos a Baja'', @FECHA, 0)
			END
			------------
			------------------------
			
			--FINALIZA PROCESO--
			SET @P_RET_PROCESO = 1
			SET @P_MSG_PROCESO = ''Actualización de Estado Funcionó correctamente. Se dieron de Baja '' + ISNULL(CAST((SELECT COUNT(1) FROM @TablaAuxiliar WHERE TIPO IN (''B'')) AS NVARCHAR(max)), '''') + '' Convenios.'' 
			
			EXECUTE dbo.pkg_constantes$VarcharConstantes ''C_LOG_TIPO_INFORMACION'', @v_constante OUTPUT;
			
			EXECUTE dbo.PKG_LOG_PROCESO$PROC_INS_LOG_PROCESO 
				@P_ID_PROCESO = @P_ID_PROCESO, 
				@P_FCH_PROCESO = @P_DT_PROCESO, 
				@P_NOM_PACKAGE = ''PA_CONV_REC_BAJA'', 
				@P_COD_ERROR = @P_RET_PROCESO, 
				@P_MSG_ERROR = @P_MSG_PROCESO, 
				@P_TIPO_ERROR = @v_constante
			
			COMMIT TRANSACTION;
			--------------------
		END TRY
		
		BEGIN CATCH	
		
			BEGIN 
			    
				ROLLBACK TRANSACTION
				
				/* Valores de Retorno.*/
				SET @p_ret_proceso = ERROR_NUMBER()
				
				SET @p_msg_proceso = ERROR_MESSAGE()
				
				EXECUTE dbo.pkg_constantes$VarcharConstantes ''C_LOG_TIPO_ERROR'', @v_constante OUTPUT;
				
				EXECUTE dbo.PKG_LOG_PROCESO$proc_ins_log_proceso 
					@p_id_proceso = @p_id_proceso, 
					@p_fch_proceso = @p_dt_proceso, 
					@p_nom_package = ''PA_CONV_REC_BAJA'', 
					@p_cod_error = @p_ret_proceso, 
					@p_msg_error = @p_msg_proceso, 
					@p_tipo_error = @v_constante
			
			END	
		
		END CATCH
	
	END
----
')

