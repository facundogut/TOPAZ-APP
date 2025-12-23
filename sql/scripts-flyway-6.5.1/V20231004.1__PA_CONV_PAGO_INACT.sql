EXECUTE('
CREATE OR ALTER   PROCEDURE PA_CONV_PAGO_INACT 
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

         
         @FECHA DATETIME,
         @CANT	NUMERIC(10),
         @v_constante VARCHAR(1),
         @v_mail VARCHAR(2048),
         @v_mail_to VARCHAR(128),
         @v_mail_from VARCHAR(128),
         @v_numerador NUMERIC,
         @v_correlativo NUMERIC(10),
         @cont_mail NUMERIC (10)
      
      SET @CANT = 0
      SET @v_mail = ''''
      SET @v_mail_to = NULL
      SELECT @v_mail_from = ALFA FROM PARAMETROSGENERALES WITH (NOLOCK) WHERE CODIGO=205
      SELECT @FECHA= FECHAPROCESO FROM PARAMETROS WITH (NOLOCK)
      
      
      ---------------------------
      
      DECLARE @ConveniosInact TABLE(
      	ID NUMERIC(15),
      	NOMBRE VARCHAR(40),
      	TIPOCONV NUMERIC(5),
      	TIPOINACT VARCHAR(1));
      	
      	
      
      DECLARE @ConveniosMails TABLE(
      	v_mail_to   VARCHAR(128),
      	v_mail_from VARCHAR(128),
      	v_mail      VARCHAR(2048),
      	intentos    NUMERIC(1),
      	subject     VARCHAR(255),
      	fecha_ingreso DATETIME,
      	tz_lock  NUMERIC(15));
     
      	
      	
      	---------------------------
      
      
      
    INSERT INTO @ConveniosInact
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
				
      ---------------------------
		BEGIN TRANSACTION
		
		BEGIN TRY
		
		BEGIN
      		/* ACTUALIZO EL ESTADO DEL CONVENIO A INACTIVO Y INSERTO EN BITACORA*/
     		
     		
     		UPDATE CONV_CONVENIOS_PAG 
     		   SET Estado = ''I'', 
     		       FecCamEst=@FECHA 
     		  FROM CONV_CONVENIOS_PAG A 
     		  JOIN @ConveniosInact C
		 		ON A.Id_ConvPago = C.ID 
		     WHERE A.TZ_LOCK = 0 AND C.TIPOINACT = ''I'';
				
     		
     	   --BUSCO EL CORRELATIVO PARA INSERTAR EN BITACORA
			INSERT INTO CONV_BITACORA
			SELECT 
				C.ID,
				''P'',
				(SELECT ISNULL(MAX(Bit_Corr), 0) + 1 FROM CONV_BITACORA WITH (NOLOCK) WHERE Id_Convenio=C.ID AND TpoConv=''P''),
				''I'',
				@FECHA,
				NULL,
				0,
				@P_SUCURSAL,
				@P_CLAVE,
				''Inactiva Convenio PA'',
				0
			FROM @ConveniosInact AS C
			WHERE C.TIPOINACT = ''I''
			
			SET @CANT = @@rowcount
  	
     		
     		/* SE AGREGA A LA LISTA DEL MAIL*/
     		--SET @v_mail = @v_mail + (SELECT CAST(C.ID AS NVARCHAR(MAX)) + '' '' +  ISNULL(C.NOMBRE,'''') + '';'' FROM @ConveniosInact C WHERE C.TIPOINACT = ''M'')
            
            SELECT @v_mail_to= ALFA FROM PARAMETROSGENERALES WHERE CODIGO=204
             
            INSERT INTO @ConveniosMails
                    select @v_mail_to,
					       @v_mail_from,
						   CAST(C.ID AS NVARCHAR(MAX)) + '' '' +  ISNULL(C.NOMBRE,'''') + '';'',
						   0,
						   ''Lista Convenios Pago proximos a Inactivar'', 
						   @FECHA, 
						   0
					 FROM @ConveniosInact C WHERE C.TIPOINACT = ''M''	
					             
      	END
     	   	
            
       SELECT @cont_mail= count(*) FROM @ConveniosInact 
        
        IF @cont_mail>0   
         /* Se envia el MAIL*/
      	BEGIN
	      	
	      	
			   	
	      	INSERT INTO CORREOS_A_ENVIAR (MAIL_TO, MAIL_FROM, DATA, INTENTOS, SUBJECT, FECHA_INGRESO, TZ_LOCK)
			     SELECT m.v_mail_to,
				      	m.v_mail_from,
				      	m.v_mail,
				      	m.intentos,
				      	m.subject,
				      	m.fecha_ingreso,
				      	m.tz_lock
			     FROM @ConveniosMails m
			     
		END
      
      SET @P_RET_PROCESO = 1
	  SET @P_MSG_PROCESO = ''Actualización de Estado Funcionó correctamente. Se Inactivaron ''+ ISNULL(CAST(@CANT AS nvarchar(max)), '''') + '' Convenios.''
	  
	  EXECUTE dbo.pkg_constantes$VarcharConstantes ''C_LOG_TIPO_INFORMACION'', @v_constante OUTPUT;
	  
	  EXECUTE dbo.PKG_LOG_PROCESO$PROC_INS_LOG_PROCESO 
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
            
            EXECUTE dbo.pkg_constantes$VarcharConstantes ''C_LOG_TIPO_ERROR'', @v_constante OUTPUT;

            EXECUTE dbo.PKG_LOG_PROCESO$proc_ins_log_proceso 
               @p_id_proceso = @p_id_proceso, 
               @p_fch_proceso = @p_dt_proceso, 
               @p_nom_package = ''PA_CONV_PAGO_INACT'', 
               @p_cod_error = @p_ret_proceso, 
               @p_msg_error = @p_msg_proceso, 
               @p_tipo_error = @v_constante

        END

      END CATCH
      
      END



')
