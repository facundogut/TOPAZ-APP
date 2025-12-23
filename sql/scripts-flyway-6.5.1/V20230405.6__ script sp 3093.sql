execute('
ALTER  PROCEDURE PA_LIQ_CONV_DEB_AUTOMATICO
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

         @ID NUMERIC(15),
         @FECHA DATETIME,
         @SUMA_IMPORTE NUMERIC(15,2),
         @CANTIDAD_LIQ NUMERIC(10),
         @CANT NUMERIC(5),
         @ARCHIVO VARCHAR(75),
         @CONVENIO NUMERIC(15),
         @MONEDA NUMERIC(4),
         @v_constante VARCHAR(1),
         @v_numerador NUMERIC,
         @v_correlativo NUMERIC(10),
         @NOM_CONV_PADRE VARCHAR(40),
         @CANT_CAB NUMERIC(5),
         
         --DECLARO VARIABLES TEMPORALES PARA RECORER TABLA AUXILIAR--
		 @IdTemp NUMERIC (15, 0),
   		 @ArchivoTemp VARCHAR (75),
   		 @ConvenioTemp  NUMERIC (15, 0), 
   		 @MonedaTemp NUMERIC (4, 0)
      
      SET @CANT = 0
      SELECT @FECHA= FECHAPROCESO FROM PARAMETROS
      
      --DECLARO TABLA AUXILIAR--
	  DECLARE @Tabla_CAB_DEBITOSAUTOMATICOS TABLE(
		ID NUMERIC (15, 0),
		ARCHIVO VARCHAR (75),
		CONVENIO NUMERIC (15, 0),
		MONEDA NUMERIC (4, 0)
	  )
      
      --COMPLETO TABLA AUXILIAR--
	  INSERT INTO 
		@Tabla_CAB_DEBITOSAUTOMATICOS
      SELECT distinct
      	cab.ID, 
      	cab.ARCHIVO, 
      	cab.CONVENIO, 
      	cab.MONEDA
      FROM REC_CAB_DEBITOSAUTOMATICOS AS cab
      WHERE (cab.FECHACORTE <= (SELECT FECHAPROCESO FROM PARAMETROS)
	  AND cab.ESTADO IN (''V'',''Z'') 
	  AND cab.ID IN (SELECT id_cabezal 
	         FROM REC_DET_DEBITOSAUTOMATICOS 
	        WHERE ID_CABEZAL = cab.ID 
	          AND ESTADO IN (''P'')))
	   OR (cab.CONVENIO IN (SELECT c.Id_ConvRec FROM CONV_CONVENIOS_REC c
	   				   		JOIN OPCIONES O ON c.Acreditacion = O.OPCIONINTERNA AND O.opcioninterna = ''DIA''
	                      	WHERE c.Id_ConvRec = cab.CONVENIO
	                			AND O.NUMERODECAMPO = 44755
	                        	AND c.Id_TpoConv = 2
	                        	AND c.TZ_LOCK = 0 
	                        	AND c.Estado = ''A'')
	  AND cab.FECHACORTE > (SELECT FECHAPROCESO FROM PARAMETROS)                      
	  AND cab.ESTADO IN (''V'',''Z'')
	  AND cab.ID IN (SELECT id_cabezal 
	         FROM REC_DET_DEBITOSAUTOMATICOS 
	        WHERE ID_CABEZAL = cab.ID 
	          AND ESTADO IN (''P''))) 


 
      BEGIN TRANSACTION
      
      BEGIN TRY
      		
		    --RECORRO LA TABLA AUXILIAR--
			WHILE EXISTS (SELECT * FROM @Tabla_CAB_DEBITOSAUTOMATICOS)
			BEGIN
				
				SELECT
				TOP 1
					@IdTemp = ID, 
	      			@ArchivoTemp = ARCHIVO, 
	      			@ConvenioTemp = CONVENIO, 
	      			@MonedaTemp = MONEDA
				FROM @Tabla_CAB_DEBITOSAUTOMATICOS
				ORDER BY 
				ID
				
				/* CALCULO IMPORTE Y CANTIDAD PAGA*/
	      		SELECT @SUMA_IMPORTE = sum(RDT.IMPORTE) , @CANTIDAD_LIQ = count(*) 
	      		FROM REC_DET_DEBITOSAUTOMATICOS RDT
	      		INNER JOIN @Tabla_CAB_DEBITOSAUTOMATICOS AS TA
	      			ON RDT.ID_CABEZAL = TA.ID
	      		WHERE RDT.ESTADO = ''P''
	      		AND TA.ID=@IdTemp 
				AND TA.ARCHIVO=@ArchivoTemp 
				AND TA.CONVENIO=@ConvenioTemp
				AND TA.MONEDA=@MonedaTemp 
				
				/*GLENS 18/11/2020 Obtengo nombre convenio padre para actualizar en rec_liquidacion */
	      		SELECT @NOM_CONV_PADRE = CCR.NomConvRec 
	      		FROM CONV_CONVENIOS_REC CCR
	      		INNER JOIN @Tabla_CAB_DEBITOSAUTOMATICOS AS TA
      			ON CCR.Id_ConvRec = TA.CONVENIO
      			WHERE TA.ID=@IdTemp 
				AND TA.ARCHIVO=@ArchivoTemp 
				AND TA.CONVENIO=@ConvenioTemp
				AND TA.MONEDA=@MonedaTemp 
      		     
      		     /*OBTENGO NUMERADOR PARA INSETR DE REC_LIQUIDACION*/		
	      		EXECUTE dbo.SP_GET_NUMERADOR_TOPAZ 45036, @v_numerador OUTPUT; 
	      		
	      		
	      		INSERT INTO REC_LIQUIDACION
				SELECT 
					@v_numerador,
					''L'',
					TA.ARCHIVO,
					TA.CONVENIO,
					TA.CONVENIO,
					@FECHA,
					TA.MONEDA,
					@CANTIDAD_LIQ,
					@SUMA_IMPORTE,
					'' '',
					0,
					0,
					0,
					@P_SUCURSAL,
					NULL,
					0,
					0,
					@NOM_CONV_PADRE,
					TA.ID					
				FROM @Tabla_CAB_DEBITOSAUTOMATICOS AS TA
				WHERE ID=@IdTemp 
				AND ARCHIVO=@ArchivoTemp 
				AND CONVENIO=@ConvenioTemp
				AND MONEDA=@MonedaTemp
				
				
				/* ACTUALIZO VALORES*/
				
				/*VAlido si el cab tiene detalles en V*/
				SELECT @CANT_CAB = count(cab.ID)
				  FROM REC_CAB_DEBITOSAUTOMATICOS cab 
				  JOIN REC_DET_DEBITOSAUTOMATICOS det
				  		ON cab.ID = det.ID_CABEZAL
				  JOIN @Tabla_CAB_DEBITOSAUTOMATICOS TA ON cab.ID = TA.ID
				 WHERE cab.ID = det.ID_CABEZAL
				   AND cab.ID = TA.ID 
				   AND cab.ESTADO IN (''V'',''Z'')
				   AND cab.CONVENIO IN (SELECT c.Id_ConvRec FROM CONV_CONVENIOS_REC c
				   							JOIN OPCIONES O ON c.Acreditacion = O.OPCIONINTERNA AND O.opcioninterna = ''DIA''
					                      	WHERE c.Id_ConvRec = cab.CONVENIO 
					                        	AND c.Id_TpoConv = 2
					                        	AND O.NUMERODECAMPO = 44755
					                        	AND c.TZ_LOCK = 0)
				   AND det.ESTADO IN (''V'')
				   AND TA.ID=@IdTemp 
				   AND TA.ARCHIVO=@ArchivoTemp 
				   AND TA.CONVENIO=@ConvenioTemp
				   AND TA.MONEDA=@MonedaTemp
				
				  
								
				/* si no hay detalles actualizo cabezal*/
			   
			   BEGIN	
				IF @CANT_CAB = 0  
				
				UPDATE dbo.REC_CAB_DEBITOSAUTOMATICOS
				SET ESTADO = ''L'', ID_LIQUIDACION = @v_numerador
				FROM REC_CAB_DEBITOSAUTOMATICOS rcd 
				INNER JOIN @Tabla_CAB_DEBITOSAUTOMATICOS AS TA
				ON rcd.ID = TA.ID
				WHERE TA.ID=@IdTemp 
				AND TA.ARCHIVO=@ArchivoTemp 
				AND TA.CONVENIO=@ConvenioTemp
				AND TA.MONEDA=@MonedaTemp 
				
				
				END 
				--Actualizo FechaUltActividad del convenio
				
			   	UPDATE CONV_CONVENIOS_REC
				   SET FecUltAct = @FECHA
				  FROM CONV_CONVENIOS_REC cr 
			      INNER JOIN @Tabla_CAB_DEBITOSAUTOMATICOS AS TA
				     ON cr.Id_ConvRec = TA.CONVENIO
				  WHERE TA.ID=@IdTemp 
				    AND TA.ARCHIVO=@ArchivoTemp 
				    AND TA.CONVENIO=@ConvenioTemp
				    AND TA.MONEDA=@MonedaTemp
				
				 /*BORRO REGISTRO UTILIZADO DE LA TABLA AUXILIAR PARA PROCEDER CON EL SIGUIENTE*/	
				DELETE FROM @Tabla_CAB_DEBITOSAUTOMATICOS 
				WHERE ID=@IdTemp 
				AND ARCHIVO=@ArchivoTemp 
				AND CONVENIO=@ConvenioTemp
				AND MONEDA=@MonedaTemp
				
				SET @CANT = @CANT + 1
				
			END
      		
                  	
	      SET @P_RET_PROCESO = 1
		  SET @P_MSG_PROCESO = ''Liquidacion Convenios Funcionó correctamente. Se Liquidaron ''+ ISNULL(CAST(@CANT AS nvarchar(max)), '''') + '' Convenios.''
		  
		  EXECUTE dbo.pkg_constantes$VarcharConstantes ''C_LOG_TIPO_INFORMACION'', @v_constante OUTPUT;
		  
		  EXECUTE dbo.PKG_LOG_PROCESO$PROC_INS_LOG_PROCESO 
		       @P_ID_PROCESO = @P_ID_PROCESO, 
		       @P_FCH_PROCESO = @P_DT_PROCESO, 
		       @P_NOM_PACKAGE = ''PA_LIQ_CONV_DEB_AUTOMATICO'', 
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
               @p_nom_package = ''PA_LIQ_CONV_DEB_AUTOMATICO'', 
               @p_cod_error = @p_ret_proceso, 
               @p_msg_error = @p_msg_proceso, 
               @p_tipo_error = @v_constante

         END

      END CATCH
      
      
   END
 ')
