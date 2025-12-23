EXECUTE('

ALTER PROCEDURE PA_CONV_PAGO_INACT 
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
      
      DECLARE

         @ID_CONVENIO NUMERIC(15),
         @NOM_CONVENIO VARCHAR(40),
         @TIPO_CONVENIO NUMERIC(5),
         @TIPO VARCHAR(1),
         @FECHA DATETIME,
         @CANT	NUMERIC(10),
         @v_constante VARCHAR(1),
         @v_mail VARCHAR(2048),
         @v_mail_to VARCHAR(128),
         @v_numerador NUMERIC,
         @v_correlativo NUMERIC(10)
      
      SET @CANT = 0
      SET @v_mail = ''''
      SET @v_mail_to = NULL
      SELECT @FECHA= FECHAPROCESO FROM PARAMETROS
      
      DECLARE
         CUR_REGISTROS CURSOR 
         FOR 
           SELECT Id_ConvPago,r.NomConvPago,r.Id_TpoConv,
			CASE WHEN ((r.FecVto <=@FECHA AND r.RenAuto = ''N'')OR 
				(DATEDIFF(month,r.FecUltAct , @FECHA) > r.InactAuto) OR
				(DATEDIFF(month,r.FecUltAct , @FECHA) = r.InactAuto AND DAY(r.FecUltAct)<= DAY(@FECHA))) THEN ''I''
				
	 			WHEN ((r.FecVto <=(@FECHA + pg.NUMERICO) AND r.RenAuto = ''N'')OR 
				(DATEDIFF(month,r.FecUltAct , (@FECHA + pg.NUMERICO)) > r.InactAuto) OR
				(DATEDIFF(month,r.FecUltAct , (@FECHA + pg.NUMERICO)) = r.InactAuto AND DAY(r.FecUltAct)<= DAY((@FECHA + pg.NUMERICO)))) THEN ''M''
				ELSE ''N'' END AS TIPO
			FROM CONV_CONVENIOS_PAG r, PARAMETROSGENERALES pg
			WHERE r.ESTADO=''A'' AND r.TZ_LOCK=0 AND pg.CODIGO=202
				
      OPEN CUR_REGISTROS
      FETCH NEXT FROM CUR_REGISTROS INTO @ID_CONVENIO,@NOM_CONVENIO,@TIPO_CONVENIO,@TIPO
      
      BEGIN TRANSACTION
      
      BEGIN TRY
      
      WHILE @@FETCH_STATUS = 0 
 
      BEGIN
      		/* ACTUALIZO EL ESTADO DEL CONVENIO A INACTIVO Y INSERTO EN BITACORA*/
     		IF @TIPO = ''I''	
     			BEGIN
     				UPDATE CONV_CONVENIOS_PAG SET Estado=''I'',FecCamEst=@FECHA WHERE Id_ConvPago=@ID_CONVENIO AND Id_TpoConv=@TIPO_CONVENIO
     				
     				--BUSCO EL CORRELATIVO PARA INSERTAR EN BITACORA
     				
     				SELECT @v_correlativo=ISNULL(MAX(Bit_Corr),0) +1 FROM CONV_BITACORA WHERE Id_Convenio=@ID_CONVENIO AND TpoConv=''P''
     				
     				INSERT INTO CONV_BITACORA(Id_Convenio, TpoConv,Bit_Corr, Bit_Estado, Bit_Fecha, Bit_Hora, Bit_Asiento, Bit_Sucursal, Bit_Usuario, Bit_Com, TZ_LOCK)
					VALUES(@ID_CONVENIO,''P'',@v_correlativo,''I'',@FECHA,NULL,0,@P_SUCURSAL,@P_CLAVE,''Inactiva Convenio PA'',0)

     				SET @CANT = @CANT + 1
     			END;
     			
     		ELSE
     		/* SE AGREGA A LA LISTA DEL MAIL*/
     			IF @TIPO=''M''
   
     			   SET @v_mail = @v_mail +CAST(@ID_CONVENIO AS nvarchar(max)) + '' ''+ ISNULL(@NOM_CONVENIO,'''') +'';'' 
	  	            	                  
            FETCH NEXT FROM CUR_REGISTROS INTO @ID_CONVENIO,@NOM_CONVENIO,@TIPO_CONVENIO,@TIPO 
             
      END
      
      IF @v_mail <>''''
            
         /* Se envia el MAIL*/
      	BEGIN
	      	SELECT @v_mail_to= ALFA FROM PARAMETROSGENERALES WHERE CODIGO=204
	      	
	      	EXECUTE SP_GET_NUMERADOR_TOPAZ 3042, @v_numerador OUTPUT;
	      	      	
	      	INSERT INTO CORREOS_A_ENVIAR (MAIL_OID, MAIL_TO, MAIL_FROM, DATA, INTENTOS, SUBJECT, FECHA_INGRESO, TZ_LOCK)
			VALUES (@v_numerador, @v_mail_to, ''topaz@gmail.com'', @v_mail, 0, ''Lista Convenios Pago proximos a Inactivar'', @FECHA, 0)
		END
      
      SET @P_RET_PROCESO = 1
	  SET @P_MSG_PROCESO = ''Actualización de Estado Funcionó correctamente. Se Inactivaron ''+ ISNULL(CAST(@CANT AS nvarchar(max)), '''') + '' Convenios.''
	  
	  EXECUTE pkg_constantes$VarcharConstantes ''C_LOG_TIPO_INFORMACION'', @v_constante OUTPUT;
	  
	  EXECUTE PKG_LOG_PROCESO$PROC_INS_LOG_PROCESO 
	       @P_ID_PROCESO = @P_ID_PROCESO, 
	       @P_FCH_PROCESO = @P_DT_PROCESO, 
	       @P_NOM_PACKAGE = ''PA_CONV_PAGO_INACT'', 
	       @P_COD_ERROR = @P_RET_PROCESO, 
	       @P_MSG_ERROR = @P_MSG_PROCESO, 
	       @P_TIPO_ERROR = @v_constante
	  
	  COMMIT TRANSACTION;     
         
      END TRY
      
      BEGIN CATCH

         
         BEGIN
         
         	ROLLBACK TRANSACTION

            /* Valores de Retorno.*/
            SET @p_ret_proceso = ERROR_NUMBER()

            SET @p_msg_proceso = ERROR_MESSAGE()
            
            EXECUTE pkg_constantes$VarcharConstantes ''C_LOG_TIPO_ERROR'', @v_constante OUTPUT;

            EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso 
               @p_id_proceso = @p_id_proceso, 
               @p_fch_proceso = @p_dt_proceso, 
               @p_nom_package = ''PA_CONV_PAGO_INACT'', 
               @p_cod_error = @p_ret_proceso, 
               @p_msg_error = @p_msg_proceso, 
               @p_tipo_error = @v_constante

         END

      END CATCH
      
      CLOSE CUR_REGISTROS

      DEALLOCATE CUR_REGISTROS
      
   END
   ')
   
   EXECUTE('
   -- PA de Baja e Inactivación Convenios Recaudación y Pago
   ALTER PROCEDURE PA_CONV_REC_INACT 
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
      
      DECLARE

         @ID_CONVENIO NUMERIC(15),
         @NOM_CONVENIO VARCHAR(40),
         @TIPO_CONVENIO NUMERIC(5),
         @TIPO VARCHAR(1),
         @FECHA DATETIME,
         @CANT	NUMERIC(10),
         @v_constante VARCHAR(1),
         @v_mail VARCHAR(2048),
         @v_mail_to VARCHAR(128),
         @v_numerador NUMERIC,
         @v_correlativo NUMERIC(10)
      
      SET @CANT = 0
      SET @v_mail = ''''
      SET @v_mail_to = NULL
      SELECT @FECHA= FECHAPROCESO FROM PARAMETROS WITH (NOLOCK)
      
      DECLARE
         CUR_REGISTROS CURSOR 
         FOR 
           SELECT Id_ConvRec,r.NomConvRec,r.Id_TpoConv,
			CASE WHEN ((r.FecVto <=@FECHA AND r.RenAuto = ''N'')OR 
				(DATEDIFF(month,r.FecUltAct , @FECHA) > r.InactAuto) OR
				(DATEDIFF(month,r.FecUltAct , @FECHA) = r.InactAuto AND DAY(r.FecUltAct)<= DAY(@FECHA))) THEN ''I''
				
	 			WHEN ((r.FecVto <=(@FECHA + pg.NUMERICO) AND r.RenAuto = ''N'')OR 
				(DATEDIFF(month,r.FecUltAct , (@FECHA + pg.NUMERICO)) > r.InactAuto) OR
				(DATEDIFF(month,r.FecUltAct , (@FECHA + pg.NUMERICO)) = r.InactAuto AND DAY(r.FecUltAct)<= DAY((@FECHA + pg.NUMERICO)))) THEN ''M''
				ELSE ''N'' END AS TIPO
			FROM CONV_CONVENIOS_REC r, PARAMETROSGENERALES pg WITH (NOLOCK)
			WHERE r.ESTADO=''A'' AND r.TZ_LOCK=0 AND pg.CODIGO=202
				
      OPEN CUR_REGISTROS
      FETCH NEXT FROM CUR_REGISTROS INTO @ID_CONVENIO,@NOM_CONVENIO,@TIPO_CONVENIO,@TIPO
      
      BEGIN TRANSACTION
      
      BEGIN TRY
      
      WHILE @@FETCH_STATUS = 0 
 
      BEGIN
      		/* ACTUALIZO EL ESTADO DEL CONVENIO A INACTIVO Y INSERTO EN BITACORA*/
     		IF @TIPO = ''I''	
     			BEGIN
     			 	UPDATE CONV_CONVENIOS_REC SET Estado=''I'',FecCamEst=@FECHA WHERE Id_ConvRec=@ID_CONVENIO 
     				
     				--BUSCO EL CORRELATIVO PARA INSERTAR EN BITACORA
     				
     			 	SELECT @v_correlativo=ISNULL(MAX(Bit_Corr),0) +1 FROM CONV_BITACORA WITH (NOLOCK) WHERE Id_Convenio=@ID_CONVENIO AND TpoConv=''R''
     				
     			 	INSERT INTO CONV_BITACORA(Id_Convenio, TpoConv,Bit_Corr, Bit_Estado, Bit_Fecha, Bit_Hora, Bit_Asiento, Bit_Sucursal, Bit_Usuario, Bit_Com, TZ_LOCK)
				 	VALUES(@ID_CONVENIO,''R'',@v_correlativo,''I'',@FECHA,NULL,0,@P_SUCURSAL,@P_CLAVE,''Inactiva Convenio PA'',0)

     				SET @CANT = @CANT + 1
     			END;
     			
     		ELSE
     		/* SE AGREGA A LA LISTA DEL MAIL*/
     			IF @TIPO=''M''
   
     			   SET @v_mail = @v_mail +CAST(@ID_CONVENIO AS nvarchar(max)) + '' ''+ ISNULL(@NOM_CONVENIO,'''') +'';'' 
	  	            	                  
            FETCH NEXT FROM CUR_REGISTROS INTO @ID_CONVENIO,@NOM_CONVENIO,@TIPO_CONVENIO,@TIPO 
             
      END
      
      IF @v_mail <>''''
            
         /* Se envia el MAIL*/
      	BEGIN
	      	SELECT @v_mail_to= ALFA FROM PARAMETROSGENERALES WITH (NOLOCK) WHERE CODIGO=204
	      	
			--GLens no corre mas el numerador.
	      	--EXECUTE SP_GET_NUMERADOR_TOPAZ 3042, @v_numerador OUTPUT;
	      	      	
			/*
	      	INSERT INTO CORREOS_A_ENVIAR (MAIL_OID, MAIL_TO, MAIL_FROM, DATA, INTENTOS, SUBJECT, FECHA_INGRESO, TZ_LOCK)
			VALUES (@v_numerador, @v_mail_to, ''topaz@gmail.com'', @v_mail, 0, ''Lista Convenios Recaudación proximos a Inactivar'', @FECHA, 0)
			*/
	      	INSERT INTO CORREOS_A_ENVIAR (MAIL_TO, MAIL_FROM, DATA, INTENTOS, SUBJECT, FECHA_INGRESO, TZ_LOCK)
			VALUES (@v_mail_to, ''topaz@gmail.com'', @v_mail, 0, ''Lista Convenios Recaudación proximos a Inactivar'', @FECHA, 0)
		END
      
      SET @P_RET_PROCESO = 1
	  SET @P_MSG_PROCESO = ''Actualización de Estado Funcionó correctamente. Se Inactivaron ''+ ISNULL(CAST(@CANT AS nvarchar(max)), '''') + '' Convenios.''
	  
	  EXECUTE pkg_constantes$VarcharConstantes ''C_LOG_TIPO_INFORMACION'', @v_constante OUTPUT;
	  
	  EXECUTE PKG_LOG_PROCESO$PROC_INS_LOG_PROCESO 
	       @P_ID_PROCESO = @P_ID_PROCESO, 
	       @P_FCH_PROCESO = @P_DT_PROCESO, 
	       @P_NOM_PACKAGE = ''CONV_REC_INACT'', 
	       @P_COD_ERROR = @P_RET_PROCESO, 
	       @P_MSG_ERROR = @P_MSG_PROCESO, 
	       @P_TIPO_ERROR = @v_constante
	  
	  COMMIT TRANSACTION;     
         
      END TRY
      
      BEGIN CATCH

         
         BEGIN
         
         	ROLLBACK TRANSACTION

            /* Valores de Retorno.*/
            SET @p_ret_proceso = ERROR_NUMBER()

            SET @p_msg_proceso = ERROR_MESSAGE()
            
            EXECUTE pkg_constantes$VarcharConstantes ''C_LOG_TIPO_ERROR'', @v_constante OUTPUT;

            EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso 
               @p_id_proceso = @p_id_proceso, 
               @p_fch_proceso = @p_dt_proceso, 
               @p_nom_package = ''CONV_REC_INACT'', 
               @p_cod_error = @p_ret_proceso, 
               @p_msg_error = @p_msg_proceso, 
               @p_tipo_error = @v_constante

         END

      END CATCH
      
      CLOSE CUR_REGISTROS

   END
      DEALLOCATE CUR_REGISTROS
')

EXECUTE('
	  
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
      
      DECLARE

         @ID_CONVENIO NUMERIC(15),
         @NOM_CONVENIO VARCHAR(40),
         @TIPO_CONVENIO NUMERIC(5),
         @TIPO VARCHAR(1),
         @FECHA DATETIME,
         @CANT	NUMERIC(10),
         @v_constante VARCHAR(1),
         @v_mail_baja VARCHAR(2048),
         @v_mail_prox VARCHAR(2048),
         @v_mail_to VARCHAR(60),
         @v_numerador NUMERIC,
         @v_correlativo NUMERIC(10)
      
      SET @CANT = 0
      SET @v_mail_baja = ''''
      SET @v_mail_prox = ''''
      SELECT @v_mail_to = ALFA FROM PARAMETROSGENERALES WITH (NOLOCK) WHERE CODIGO=204
      SELECT @FECHA= FECHAPROCESO FROM PARAMETROS WITH (NOLOCK)
      
      DECLARE
         CUR_REGISTROS CURSOR 
         FOR 
           SELECT Id_ConvRec,r.NomConvRec,r.Id_TpoConv,
			CASE WHEN r.Estado=''B'' THEN ''H''
			
				WHEN((DATEDIFF(month,r.FecCamEst , @FECHA) > r.BajaAuto) OR
				(DATEDIFF(month,r.FecCamEst , @FECHA) = r.BajaAuto AND DAY(r.FecCamEst)<= DAY(@FECHA))) THEN ''B''
				
	 			WHEN ( 
				(DATEDIFF(month,r.FecCamEst , (@FECHA + pg.NUMERICO)) > r.BajaAuto) OR
				(DATEDIFF(month,r.FecCamEst , (@FECHA + pg.NUMERICO)) = r.BajaAuto AND DAY(r.FecCamEst)<= DAY((@FECHA + pg.NUMERICO)))) THEN ''M''
				ELSE ''N'' END AS TIPO
			FROM CONV_CONVENIOS_REC r, PARAMETROS p, PARAMETROSGENERALES pg WITH (NOLOCK)
			WHERE (r.ESTADO=''I'' OR (r.Estado=''B'' AND r.FecCamEst=@FECHA)) AND r.TZ_LOCK=0 AND pg.CODIGO=203
				
      OPEN CUR_REGISTROS
      FETCH NEXT FROM CUR_REGISTROS INTO @ID_CONVENIO,@NOM_CONVENIO,@TIPO_CONVENIO,@TIPO
      
      BEGIN TRANSACTION
      
      BEGIN TRY
      
      WHILE @@FETCH_STATUS = 0 
 
      BEGIN
      		/* ACTUALIZO EL ESTADO DEL CONVENIO A BAJA,INSERTO EN BITACORA Y EN MAIL DE BAJA*/
     		IF @TIPO = ''B''	
     			BEGIN
     				UPDATE CONV_CONVENIOS_REC SET Estado=''B'' WHERE Id_ConvRec=@ID_CONVENIO 
     				
     				--BUSCO EL CORRELATIVO PARA INSERTAR EN BITACORA
     				
     				SELECT @v_correlativo=ISNULL(MAX(Bit_Corr),0) +1 FROM CONV_BITACORA WITH (NOLOCK) WHERE Id_Convenio=@ID_CONVENIO AND TpoConv=''R''
     				
     				INSERT INTO CONV_BITACORA(Id_Convenio, TpoConv,Bit_Corr, Bit_Estado, Bit_Fecha, Bit_Hora, Bit_Asiento, Bit_Sucursal, Bit_Usuario, Bit_Com, TZ_LOCK)
					VALUES(@ID_CONVENIO,''R'',@v_correlativo,''B'',@FECHA,NULL,0,@P_SUCURSAL,@P_CLAVE,''Baja Convenio PA'',0)
					
					SET @v_mail_baja = @v_mail_baja +CAST(@ID_CONVENIO AS nvarchar(max)) + '' ''+ ISNULL(@NOM_CONVENIO,'''') +'';'' 

     				SET @CANT = @CANT + 1
     			END;
     		ELSE
     		
     		/* SE DIO DE BAJA HOY, SE AGREGA A LA LISTA DE MAILS DE BAJA*/
     			IF @TIPO=''H''
   
     			   SET @v_mail_baja = @v_mail_baja +CAST(@ID_CONVENIO AS nvarchar(max)) + '' ''+ ISNULL(@NOM_CONVENIO,'''') +'';'' 
     		
     			
     		ELSE
     		
     		/* PROXIMO A DARSE DE BAJA,SE AGREGA A LA LISTA DEL MAIL DE PROX*/
     			IF @TIPO=''M''
   
     			   SET @v_mail_prox = @v_mail_prox +CAST(@ID_CONVENIO AS nvarchar(max)) + '' ''+ ISNULL(@NOM_CONVENIO,'''') +'';'' 
	  	            	                  
            FETCH NEXT FROM CUR_REGISTROS INTO @ID_CONVENIO,@NOM_CONVENIO,@TIPO_CONVENIO,@TIPO 
             
      END
      
      IF @v_mail_baja <>''''
            
        BEGIN
        	--GLens no corre mas el numerador.
        	--EXECUTE SP_GET_NUMERADOR_TOPAZ 3042, @v_numerador OUTPUT;
        	    
	         /* Se envia el MAIL  de Baja*/      	      	
			/* 
			INSERT INTO CORREOS_A_ENVIAR (MAIL_OID, MAIL_TO, MAIL_FROM, DATA, INTENTOS, SUBJECT, FECHA_INGRESO, TZ_LOCK)
			VALUES (@v_numerador, @v_mail_to, ''topaz@gmail.com'', @v_mail_baja, 0, ''Lista Convenios Recaudación dados de Baja'', @FECHA, 0)

			*/
	      	INSERT INTO CORREOS_A_ENVIAR (MAIL_TO, MAIL_FROM, DATA, INTENTOS, SUBJECT, FECHA_INGRESO, TZ_LOCK)
			VALUES (@v_mail_to, ''topaz@gmail.com'', @v_mail_baja, 0, ''Lista Convenios Recaudación dados de Baja'', @FECHA, 0)
		
		END
      
      IF @v_mail_prox <>''''
         
        BEGIN
			--GLens no corre mas el numerador.
         	--EXECUTE SP_GET_NUMERADOR_TOPAZ 3042, @v_numerador OUTPUT;
				/*
	      	INSERT INTO CORREOS_A_ENVIAR (MAIL_OID, MAIL_TO, MAIL_FROM, DATA, INTENTOS, SUBJECT, FECHA_INGRESO, TZ_LOCK)
			VALUES (@v_numerador, @v_mail_to, ''topaz@gmail.com'', @v_mail_prox, 0, ''Lista Convenios Recaudación proximos a Baja'', @FECHA, 0)
				
				*/
			  
	         /* Se envia el MAIL Proximos a dar de Baja*/      	      	
	      	INSERT INTO CORREOS_A_ENVIAR (MAIL_TO, MAIL_FROM, DATA, INTENTOS, SUBJECT, FECHA_INGRESO, TZ_LOCK)
			VALUES (@v_mail_to, ''topaz@gmail.com'', @v_mail_prox, 0, ''Lista Convenios Recaudación proximos a Baja'', @FECHA, 0)
		
		END
	      
      SET @P_RET_PROCESO = 1
	  SET @P_MSG_PROCESO = ''Actualización de Estado Funcionó correctamente. Se dieron de Baja ''+ ISNULL(CAST(@CANT AS nvarchar(max)), '''') + '' Convenios.''
	  
	  EXECUTE pkg_constantes$VarcharConstantes ''C_LOG_TIPO_INFORMACION'', @v_constante OUTPUT;
	  
	  EXECUTE PKG_LOG_PROCESO$PROC_INS_LOG_PROCESO 
	       @P_ID_PROCESO = @P_ID_PROCESO, 
	       @P_FCH_PROCESO = @P_DT_PROCESO, 
	       @P_NOM_PACKAGE = ''PA_CONV_REC_BAJA'', 
	       @P_COD_ERROR = @P_RET_PROCESO, 
	       @P_MSG_ERROR = @P_MSG_PROCESO, 
	       @P_TIPO_ERROR = @v_constante
	  
	  COMMIT TRANSACTION;     
         
      END TRY
      
      BEGIN CATCH

         
         BEGIN
         
         	ROLLBACK TRANSACTION

            /* Valores de Retorno.*/
            SET @p_ret_proceso = ERROR_NUMBER()

            SET @p_msg_proceso = ERROR_MESSAGE()
            
            EXECUTE pkg_constantes$VarcharConstantes ''C_LOG_TIPO_ERROR'', @v_constante OUTPUT;

            EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso 
               @p_id_proceso = @p_id_proceso, 
               @p_fch_proceso = @p_dt_proceso, 
               @p_nom_package = ''PA_CONV_REC_BAJA'', 
               @p_cod_error = @p_ret_proceso, 
               @p_msg_error = @p_msg_proceso, 
               @p_tipo_error = @v_constante

         END

      END CATCH
      
      CLOSE CUR_REGISTROS

      DEALLOCATE CUR_REGISTROS
      
   END
')

EXECUTE('

ALTER PROCEDURE PA_CONV_PAGO_INACT 
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
      
      DECLARE

         @ID_CONVENIO NUMERIC(15),
         @NOM_CONVENIO VARCHAR(40),
         @TIPO_CONVENIO NUMERIC(5),
         @TIPO VARCHAR(1),
         @FECHA DATETIME,
         @CANT	NUMERIC(10),
         @v_constante VARCHAR(1),
         @v_mail VARCHAR(2048),
         @v_mail_to VARCHAR(128),
         @v_numerador NUMERIC,
         @v_correlativo NUMERIC(10)
      
      SET @CANT = 0
      SET @v_mail = ''''
      SET @v_mail_to = NULL
      SELECT @FECHA= FECHAPROCESO FROM PARAMETROS WITH (NOLOCK)
      
      DECLARE
         CUR_REGISTROS CURSOR 
         FOR 
           SELECT Id_ConvPago,r.NomConvPago,r.Id_TpoConv,
			CASE WHEN ((r.FecVto <=@FECHA AND r.RenAuto = ''N'')OR 
				(DATEDIFF(month,r.FecUltAct , @FECHA) > r.InactAuto) OR
				(DATEDIFF(month,r.FecUltAct , @FECHA) = r.InactAuto AND DAY(r.FecUltAct)<= DAY(@FECHA))) THEN ''I''
				
	 			WHEN ((r.FecVto <=(@FECHA + pg.NUMERICO) AND r.RenAuto = ''N'')OR 
				(DATEDIFF(month,r.FecUltAct , (@FECHA + pg.NUMERICO)) > r.InactAuto) OR
				(DATEDIFF(month,r.FecUltAct , (@FECHA + pg.NUMERICO)) = r.InactAuto AND DAY(r.FecUltAct)<= DAY((@FECHA + pg.NUMERICO)))) THEN ''M''
				ELSE ''N'' END AS TIPO
			FROM CONV_CONVENIOS_PAG r, PARAMETROSGENERALES pg WITH (NOLOCK)
			WHERE r.ESTADO=''A'' AND r.TZ_LOCK=0 AND pg.CODIGO=202
				
      OPEN CUR_REGISTROS
      FETCH NEXT FROM CUR_REGISTROS INTO @ID_CONVENIO,@NOM_CONVENIO,@TIPO_CONVENIO,@TIPO
      
      BEGIN TRANSACTION
      
      BEGIN TRY
      
      WHILE @@FETCH_STATUS = 0 
 
      BEGIN
      		/* ACTUALIZO EL ESTADO DEL CONVENIO A INACTIVO Y INSERTO EN BITACORA*/
     		IF @TIPO = ''I''	
     			BEGIN
     				UPDATE CONV_CONVENIOS_PAG SET Estado=''I'',FecCamEst=@FECHA WHERE Id_ConvPago=@ID_CONVENIO AND Id_TpoConv=@TIPO_CONVENIO
     				
     				--BUSCO EL CORRELATIVO PARA INSERTAR EN BITACORA
     				
     				SELECT @v_correlativo=ISNULL(MAX(Bit_Corr),0) +1 FROM CONV_BITACORA WITH (NOLOCK) WHERE Id_Convenio=@ID_CONVENIO AND TpoConv=''P''
     				
     				INSERT INTO CONV_BITACORA(Id_Convenio, TpoConv,Bit_Corr, Bit_Estado, Bit_Fecha, Bit_Hora, Bit_Asiento, Bit_Sucursal, Bit_Usuario, Bit_Com, TZ_LOCK)
					VALUES(@ID_CONVENIO,''P'',@v_correlativo,''I'',@FECHA,NULL,0,@P_SUCURSAL,@P_CLAVE,''Inactiva Convenio PA'',0)

     				SET @CANT = @CANT + 1
     			END;
     			
     		ELSE
     		/* SE AGREGA A LA LISTA DEL MAIL*/
     			IF @TIPO=''M''
   
     			   SET @v_mail = @v_mail +CAST(@ID_CONVENIO AS nvarchar(max)) + '' ''+ ISNULL(@NOM_CONVENIO,'''') +'';'' 
	  	            	                  
            FETCH NEXT FROM CUR_REGISTROS INTO @ID_CONVENIO,@NOM_CONVENIO,@TIPO_CONVENIO,@TIPO 
             
      END
      
      IF @v_mail <>''''
            
         /* Se envia el MAIL*/
      	BEGIN
	      	SELECT @v_mail_to= ALFA FROM PARAMETROSGENERALES WHERE CODIGO=204
	      	
			--GLens no corre mas el numerador.
	      	--EXECUTE SP_GET_NUMERADOR_TOPAZ 3042, @v_numerador OUTPUT;
	      	/*
			INSERT INTO CORREOS_A_ENVIAR (MAIL_OID, MAIL_TO, MAIL_FROM, DATA, INTENTOS, SUBJECT, FECHA_INGRESO, TZ_LOCK)
			VALUES (@v_numerador, @v_mail_to, ''topaz@gmail.com'', @v_mail, 0, ''Lista Convenios Pago proximos a Inactivar'', @FECHA, 0)
			*/      	
	      	INSERT INTO CORREOS_A_ENVIAR (MAIL_TO, MAIL_FROM, DATA, INTENTOS, SUBJECT, FECHA_INGRESO, TZ_LOCK)
			VALUES (@v_mail_to, ''topaz@gmail.com'', @v_mail, 0, ''Lista Convenios Pago proximos a Inactivar'', @FECHA, 0)
		END
      
      SET @P_RET_PROCESO = 1
	  SET @P_MSG_PROCESO = ''Actualización de Estado Funcionó correctamente. Se Inactivaron ''+ ISNULL(CAST(@CANT AS nvarchar(max)), '''') + '' Convenios.''
	  
	  EXECUTE pkg_constantes$VarcharConstantes ''C_LOG_TIPO_INFORMACION'', @v_constante OUTPUT;
	  
	  EXECUTE PKG_LOG_PROCESO$PROC_INS_LOG_PROCESO 
	       @P_ID_PROCESO = @P_ID_PROCESO, 
	       @P_FCH_PROCESO = @P_DT_PROCESO, 
	       @P_NOM_PACKAGE = ''PA_CONV_PAGO_INACT'', 
	       @P_COD_ERROR = @P_RET_PROCESO, 
	       @P_MSG_ERROR = @P_MSG_PROCESO, 
	       @P_TIPO_ERROR = @v_constante
	  
	  COMMIT TRANSACTION;     
         
      END TRY
      
      BEGIN CATCH

         
         BEGIN
         
         	ROLLBACK TRANSACTION

            /* Valores de Retorno.*/
            SET @p_ret_proceso = ERROR_NUMBER()

            SET @p_msg_proceso = ERROR_MESSAGE()
            
            EXECUTE pkg_constantes$VarcharConstantes ''C_LOG_TIPO_ERROR'', @v_constante OUTPUT;

            EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso 
               @p_id_proceso = @p_id_proceso, 
               @p_fch_proceso = @p_dt_proceso, 
               @p_nom_package = ''PA_CONV_PAGO_INACT'', 
               @p_cod_error = @p_ret_proceso, 
               @p_msg_error = @p_msg_proceso, 
               @p_tipo_error = @v_constante

         END

      END CATCH
      
      CLOSE CUR_REGISTROS

      DEALLOCATE CUR_REGISTROS
      
   END
')

EXECUTE('

ALTER PROCEDURE PA_CONV_PAGO_BAJA 
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
      
      DECLARE

         @ID_CONVENIO NUMERIC(15),
         @NOM_CONVENIO VARCHAR(40),
         @TIPO_CONVENIO NUMERIC(5),
         @TIPO VARCHAR(1),
         @FECHA DATETIME,
         @CANT	NUMERIC(10),
         @v_constante VARCHAR(1),
         @v_mail_baja VARCHAR(2048),
         @v_mail_prox VARCHAR(2048),
         @v_mail_to VARCHAR(60),
         @v_numerador NUMERIC,
         @v_correlativo NUMERIC(10)
      
      SET @CANT = 0
      SET @v_mail_baja = ''''
      SET @v_mail_prox = ''''
      SELECT @v_mail_to = ALFA FROM PARAMETROSGENERALES WITH (NOLOCK) WHERE CODIGO=204
      SELECT @FECHA= FECHAPROCESO FROM PARAMETROS WITH (NOLOCK)
      
      DECLARE
         CUR_REGISTROS CURSOR 
         FOR 
           SELECT Id_ConvPago,r.NomConvPago,r.Id_TpoConv,
			CASE WHEN r.Estado=''B'' THEN ''H''
			
				WHEN((DATEDIFF(month,r.FecCamEst , @FECHA) > r.BajaAuto) OR
				(DATEDIFF(month,r.FecCamEst , @FECHA) = r.BajaAuto AND DAY(r.FecCamEst)<= DAY(@FECHA))) THEN ''B''
				
	 			WHEN ( 
				(DATEDIFF(month,r.FecCamEst , (@FECHA + pg.NUMERICO)) > r.BajaAuto) OR
				(DATEDIFF(month,r.FecCamEst , (@FECHA + pg.NUMERICO)) = r.BajaAuto AND DAY(r.FecCamEst)<= DAY((@FECHA + pg.NUMERICO)))) THEN ''M''
				ELSE ''N'' END AS TIPO
			FROM CONV_CONVENIOS_PAG r, PARAMETROS p, PARAMETROSGENERALES pg WITH (NOLOCK)
			WHERE (r.ESTADO=''I'' OR (r.Estado=''B'' AND r.FecCamEst=@FECHA)) AND r.TZ_LOCK=0 AND pg.CODIGO=203
				
      OPEN CUR_REGISTROS
      FETCH NEXT FROM CUR_REGISTROS INTO @ID_CONVENIO,@NOM_CONVENIO,@TIPO_CONVENIO,@TIPO
      
      BEGIN TRANSACTION
      
      BEGIN TRY
      
      WHILE @@FETCH_STATUS = 0 
 
      BEGIN
      		/* ACTUALIZO EL ESTADO DEL CONVENIO A BAJA,INSERTO EN BITACORA Y EN MAIL DE BAJA*/
     		IF @TIPO = ''B''	
     			BEGIN
     				UPDATE CONV_CONVENIOS_PAG SET Estado=''B'' WHERE Id_ConvPago=@ID_CONVENIO AND Id_TpoConv=@TIPO_CONVENIO
     				
     				--BUSCO EL CORRELATIVO PARA INSERTAR EN BITACORA
     				
     				SELECT @v_correlativo=ISNULL(MAX(Bit_Corr),0) +1 FROM CONV_BITACORA WITH (NOLOCK) WHERE Id_Convenio=@ID_CONVENIO AND TpoConv=''P''
     				
     				INSERT INTO CONV_BITACORA(Id_Convenio, TpoConv,Bit_Corr, Bit_Estado, Bit_Fecha, Bit_Hora, Bit_Asiento, Bit_Sucursal, Bit_Usuario, Bit_Com, TZ_LOCK)
					VALUES(@ID_CONVENIO,''P'',@v_correlativo, ''B'',@FECHA,NULL,0,@P_SUCURSAL,@P_CLAVE,''Baja Convenio PA'',0)

					SET @v_mail_baja = @v_mail_baja +CAST(@ID_CONVENIO AS nvarchar(max)) + '' ''+ ISNULL(@NOM_CONVENIO,'''') +'';'' 

     				SET @CANT = @CANT + 1
     			END;
     		ELSE
     		
     		/* SE DIO DE BAJA HOY, SE AGREGA A LA LISTA DE MAILS DE BAJA*/
     			IF @TIPO=''H''
   
     			   SET @v_mail_baja = @v_mail_baja +CAST(@ID_CONVENIO AS nvarchar(max)) + '' ''+ ISNULL(@NOM_CONVENIO,'''') +'';'' 
     		
     			
     		ELSE
     		
     		/* PROXIMO A DARSE DE BAJA,SE AGREGA A LA LISTA DEL MAIL DE PROX*/
     			IF @TIPO=''M''
   
     			   SET @v_mail_prox = @v_mail_prox +CAST(@ID_CONVENIO AS nvarchar(max)) + '' ''+ ISNULL(@NOM_CONVENIO,'''') +'';'' 
	  	            	                  
            FETCH NEXT FROM CUR_REGISTROS INTO @ID_CONVENIO,@NOM_CONVENIO,@TIPO_CONVENIO,@TIPO 
             
      END
      
      IF @v_mail_baja <>''''
         
        BEGIN    
			--GLens no corre mas el numerador
	        --EXECUTE SP_GET_NUMERADOR_TOPAZ 3042, @v_numerador OUTPUT;    
	         /* Se envia el MAIL  de Baja*/      	    
				/*
				INSERT INTO CORREOS_A_ENVIAR (MAIL_OID, MAIL_TO, MAIL_FROM, DATA, INTENTOS, SUBJECT, FECHA_INGRESO, TZ_LOCK)
			VALUES (@v_numerador, @v_mail_to, ''topaz@gmail.com'', @v_mail_baja, 0, ''Lista Convenios Pago dados de Baja'', @FECHA, 0)
				*/
	      	INSERT INTO CORREOS_A_ENVIAR (MAIL_TO, MAIL_FROM, DATA, INTENTOS, SUBJECT, FECHA_INGRESO, TZ_LOCK)
			VALUES (@v_mail_to, ''topaz@gmail.com'', @v_mail_baja, 0, ''Lista Convenios Pago dados de Baja'', @FECHA, 0)
		END
      
      IF @v_mail_prox <>''''
        BEGIN
			--GLens no corre mas el numerador
        	--EXECUTE SP_GET_NUMERADOR_TOPAZ 3042, @v_numerador OUTPUT;    
	         /* Se envia el MAIL Proximos a dar de Baja*/      	 
				/*
				INSERT INTO CORREOS_A_ENVIAR (MAIL_OID, MAIL_TO, MAIL_FROM, DATA, INTENTOS, SUBJECT, FECHA_INGRESO, TZ_LOCK)
			VALUES (@v_numerador, @v_mail_to, ''topaz@gmail.com'', @v_mail_prox, 0, ''Lista Convenios Pago proximos a Baja'', @FECHA, 0)
				*/
	      	INSERT INTO CORREOS_A_ENVIAR (MAIL_TO, MAIL_FROM, DATA, INTENTOS, SUBJECT, FECHA_INGRESO, TZ_LOCK)
			VALUES (@v_mail_to, ''topaz@gmail.com'', @v_mail_prox, 0, ''Lista Convenios Pago proximos a Baja'', @FECHA, 0)
      
      	END
      	
      SET @P_RET_PROCESO = 1
	  SET @P_MSG_PROCESO = ''Actualización de Estado Funcionó correctamente. Se dieron de Baja ''+ ISNULL(CAST(@CANT AS nvarchar(max)), '''') + '' Convenios.''
	  
	  EXECUTE pkg_constantes$VarcharConstantes ''C_LOG_TIPO_INFORMACION'', @v_constante OUTPUT;
	  
	  EXECUTE PKG_LOG_PROCESO$PROC_INS_LOG_PROCESO 
	       @P_ID_PROCESO = @P_ID_PROCESO, 
	       @P_FCH_PROCESO = @P_DT_PROCESO, 
	       @P_NOM_PACKAGE = ''PA_CONV_PAGO_BAJA'', 
	       @P_COD_ERROR = @P_RET_PROCESO, 
	       @P_MSG_ERROR = @P_MSG_PROCESO, 
	       @P_TIPO_ERROR = @v_constante
	  
	  COMMIT TRANSACTION;     
         
      END TRY
      
      BEGIN CATCH

         
         BEGIN
         
         	ROLLBACK TRANSACTION

            /* Valores de Retorno.*/
            SET @p_ret_proceso = ERROR_NUMBER()

            SET @p_msg_proceso = ERROR_MESSAGE()
            
            EXECUTE pkg_constantes$VarcharConstantes ''C_LOG_TIPO_ERROR'', @v_constante OUTPUT;

            EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso 
               @p_id_proceso = @p_id_proceso, 
               @p_fch_proceso = @p_dt_proceso, 
               @p_nom_package = ''PA_CONV_PAGO_BAJA'', 
               @p_cod_error = @p_ret_proceso, 
               @p_msg_error = @p_msg_proceso, 
               @p_tipo_error = @v_constante

         END

      END CATCH
      
      CLOSE CUR_REGISTROS

      DEALLOCATE CUR_REGISTROS
      
   END

	  
')	