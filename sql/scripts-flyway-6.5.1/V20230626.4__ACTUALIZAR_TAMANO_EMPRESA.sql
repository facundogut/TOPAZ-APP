EXECUTE('
ALTER PROCEDURE [dbo].[ACTUALIZAR_TAMANO_EMPRESA]
   
   @P_ID_PROCESO  float(53),
   @P_DT_PROCESO  datetime2(0),
   --@P_CLAVE       varchar(max),
   --@P_SUCURSAL    float(53),
   --@P_NROMAQUINA  float(53),
   @P_RET_PROCESO float(53)  OUTPUT,
   @P_MSG_PROCESO varchar(max)  OUTPUT
    
AS 
  
   BEGIN
     
      SET @P_RET_PROCESO = NULL
      SET @P_MSG_PROCESO = NULL
 
      DECLARE
         
         @NextID NUMERIC (12),
         @V_CUIT VARCHAR (20),
         @V_TIPO_DOCUMENTO VARCHAR (4),
         @V_Actividad_AFIP VARCHAR (12),
         @V_CODIG_CLIENTE NUMERIC (12),
         @JTS_BITACORA NUMERIC (12), 
         @V_STATUS NUMERIC (1) ,
	     @V_Descripcion VARCHAR (100)  , 
	     @V_Tamaño_Calculado VARCHAR (50) ,
	     @V_PROCESO VARCHAR (30) ,
	     @V_F_INICIO DATE  ,        
	     @V_F_FINAL  DATE  ,        
	     @V_TOTAL_VENTAS NUMERIC (15,2) ,      
	     @V_RPC  NUMERIC (15,2)  , 			
	     @V_PERSONAL_OCUPADO NUMERIC (5) , 
	     @V_VALOR_ACTIVO NUMERIC (15,2) ,
	     @V_NRO_REGISTRO VARCHAR (30) ,
	     @V_TAM_ACTUAL VARCHAR (40) ,  
	     @V_F_HASTA_CER DATE  ,        
	     @V_F_ALTA_BCO  DATE ,
	     @FECHA_PROCESO DATE,
	     @V_TAM_ANTERIOR VARCHAR (100),
	     @V_K_SIN_CALCULAR NUMERIC (15) = 0,
	     @V_K_OK NUMERIC (15) = 0,
	     @V_K_TOTAL NUMERIC (15) = 0,
	     @v_constante VARCHAR(1),
	     @FECHA_PROCESO2 VARCHAR(8),
	     @V_Tamaño_Calculado_Desc VARCHAR (50) 
   
      BEGIN
      
      SELECT @FECHA_PROCESO = a.FECHAPROCESO 
        FROM PARAMETROS a WITH (NOLOCK)



      --SET @FECHA_PROCESO = ''20201022''
           
         BEGIN 

		  DECLARE CUR_CLIENTES_PARA_ACTUALIZAR  CURSOR LOCAL FOR 	   

       								   
										
			SELECT DISTINCT c.TIPODOC, c.NUMERODOC, d.[CODIGO_ACT_afip], a.CLIENTE,A.JTS_BITACORA, a.TAM_ACTUAL
			  FROM CRE_TAM_EMP_BITACORA A WITH (NOLOCK),
			       CRE_TAM_EMP_PERS B WITH (NOLOCK), 
			       VW_CLI_X_DOC C WITH (NOLOCK),
			       CLI_Cod_Act_AFIP D WITH (NOLOCK)              
			 WHERE A.TZ_LOCK =0
			   AND A.TZ_LOCK = b.TZ_LOCK
			   AND A.TZ_LOCK = d.TZ_LOCK
			   AND A.CLIENTE = c.[CODIGOCLIENTE]
			   AND a.FECHA>=b.FECHA_VIGENCIA 
			   AND b.FECHA_ACTUALIZACION= @FECHA_PROCESO
			   AND d.[CODIGO_ACT_afip]=a.[CODIGO_ACT_afip] 
			   AND d.[CODIGO_SECTOR]=b.SECTOR
			   AND d.Cat_Por_Per=''S''
			   AND A.JTS_BITACORA = (SELECT MAX (JTS_BITACORA)
						                           FROM CRE_TAM_EMP_BITACORA WITH (NOLOCK)
						                           WHERE CLIENTE = a.CLIENTE)
			UNION
			SELECT DISTINCT c.TIPODOC, c.NUMERODOC, d.[CODIGO_ACT_afip], a.CLIENTE ,A.JTS_BITACORA, a.TAM_ACTUAL
			  FROM CRE_TAM_EMP_BITACORA A WITH (NOLOCK),
			       CRE_TAM_EMP_VTAS B WITH (NOLOCK), 
			       VW_CLI_X_DOC C WITH (NOLOCK),
			       CLI_Cod_Act_AFIP D  WITH (NOLOCK)             
			 WHERE A.TZ_LOCK =0
			   AND A.TZ_LOCK = b.TZ_LOCK
			   AND A.TZ_LOCK = d.TZ_LOCK
			   AND A.CLIENTE = c.[CODIGOCLIENTE]
			   AND a.FECHA>=b.FECHA_VIGENCIA 
			   AND b.FECHA_ACTUALIZACION= @FECHA_PROCESO
			   AND d.[CODIGO_ACT_afip]=a.[CODIGO_ACT_afip] 
			   AND d.[CODIGO_SECTOR]=b.SECTOR
			   AND d.Cat_Por_Vta=''S''
			   AND A.JTS_BITACORA = (SELECT MAX (JTS_BITACORA)
						                           FROM CRE_TAM_EMP_BITACORA WITH (NOLOCK)
						                           WHERE CLIENTE = a.CLIENTE)
			 UNION
			 
			 SELECT DISTINCT c.TIPODOC, c.NUMERODOC, d.[CODIGO_ACT_afip], a.CLIENTE ,A.JTS_BITACORA, a.TAM_ACTUAL
			  FROM CRE_TAM_EMP_BITACORA A WITH (NOLOCK),
			       CRE_PARAMETROS b WITH (NOLOCK),
			       VW_CLI_X_DOC c WITH (NOLOCK),
			       CLI_Cod_Act_AFIP D WITH (NOLOCK)
			 WHERE A.TZ_LOCK =0
			   AND A.TZ_LOCK = b.TZ_LOCK
			   AND A.TZ_LOCK = d.TZ_LOCK
			   AND A.CLIENTE = c.[CODIGOCLIENTE]
			   AND d.[CODIGO_ACT_afip]=a.[CODIGO_ACT_afip] 
			   AND b.[CODIGO] = 500
			   AND b.UTILIZADO = ''S''
			   AND a.FECHA>=b.FECHA_CONTROL
			   AND D.Cat_Por_Act=''S''
			   AND b.PARAMETRO_ALFA= SUBSTRING(CONVERT(VARCHAR(8), @FECHA_PROCESO, 112),7,2)+SUBSTRING(CONVERT(VARCHAR(8),@FECHA_PROCESO, 112),5,2)+SUBSTRING(CONVERT(VARCHAR(8), @FECHA_PROCESO, 112),1,4)  
			  -- AND A.VALOR_ACTIVO<b.IMPORTE
			   -- AND b.PARAMETRO_ALFA = SUBSTRING(CONVERT(VARCHAR(8),a.FECHA, 112),7,2)+SUBSTRING(CONVERT(VARCHAR(8), a.FECHA, 112),5,2)+SUBSTRING(CONVERT(VARCHAR(8), a.FECHA, 112),1,4)  
			   AND A.JTS_BITACORA = (SELECT MAX (JTS_BITACORA)
						                           FROM CRE_TAM_EMP_BITACORA WITH (NOLOCK)
						                           WHERE CLIENTE = a.CLIENTE)
						                           
		   			      
         
         
          BEGIN
			  OPEN CUR_CLIENTES_PARA_ACTUALIZAR;
		     FETCH NEXT FROM CUR_CLIENTES_PARA_ACTUALIZAR INTO @V_TIPO_DOCUMENTO,
		                                                       @V_CUIT,
		                                                       @V_Actividad_AFIP,
		                                                       @V_CODIG_CLIENTE,
		                                                       @JTS_BITACORA,
		                                                       @V_TAM_ANTERIOR
              
              
            BEGIN TRANSACTION
      
             BEGIN TRY  
             
              WHILE @@FETCH_STATUS = 0
             
           BEGIN  
             
-- COMIENZA CALCULO NUEVO TAMAÑO

           
       SET  @V_STATUS  = NULL 
	   SET  @V_Descripcion  = NULL 
	   SET  @V_Tamaño_Calculado  = NULL
       SET  @V_PROCESO  = NULL
	   SET  @V_F_INICIO  = NULL    
	   SET  @V_F_FINAL   = NULL      
	   SET  @V_TOTAL_VENTAS  = NULL    
	   SET  @V_RPC   = NULL			
	   SET  @V_PERSONAL_OCUPADO  = NULL 
	   SET  @V_VALOR_ACTIVO  = NULL
	   SET  @V_NRO_REGISTRO  = NULL
	   SET  @V_TAM_ACTUAL  = NULL  
	   SET  @V_F_HASTA_CER  = NULL      
	   SET  @V_F_ALTA_BCO   = NULL
             
    EXECUTE dbo.OBTENER_TAMANO_EMPRESA
	     @V_CUIT,
	     @V_TIPO_DOCUMENTO,
	     @V_Actividad_AFIP,
	     @V_CODIG_CLIENTE,
         @V_STATUS OUTPUT ,
	     @V_Descripcion OUTPUT  , 
	     @V_Tamaño_Calculado OUTPUT ,
	     @V_PROCESO OUTPUT ,
	     @V_F_INICIO OUTPUT  ,        
	     @V_F_FINAL  OUTPUT  ,        
	     @V_TOTAL_VENTAS OUTPUT ,      
	     @V_RPC  OUTPUT , 			
	     @V_PERSONAL_OCUPADO OUTPUT , 
	     @V_VALOR_ACTIVO OUTPUT ,
	     @V_NRO_REGISTRO OUTPUT,
	     @V_TAM_ACTUAL OUTPUT ,  
	     @V_F_HASTA_CER OUTPUT  ,        
	     @V_F_ALTA_BCO  OUTPUT
     
				     				 
--- FIN CALCULO NUEVO TAMAÑO		 
	   		 
		   
			
		  
			 
			 
			SELECT @NextID =  max(JTS_BITACORA)
			  FROM CRE_TAM_EMP_BITACORA WITH (NOLOCK)
			  
			 SET @NextID = @NextID + 1
			 
			 
		   /*	 PRINT @V_Descripcion
			 PRINT @V_Tamaño_Calculado
			 PRINT @V_CUIT
			 PRINT @V_TIPO_DOCUMENTO
			 PRINT @FECHA_PROCESO
			 
			 PRINT @NextID 
			 PRINT @V_CODIGO_CLIENTE 
			 PRINT @FECHA_PROCESO 
			 PRINT @V_TOTAL_VENTAS  
			 PRINT @V_RPC
			 PRINT @V_PERSONAL_OCUPADO
			 PRINT @V_VALOR_ACTIVO
			 PRINT @V_TAM_ACTUAL
			 PRINT @V_TAM_ANTERIOR
			 PRINT @V_NRO_REGISTRO
			 PRINT @V_F_INICIO
			 PRINT @V_F_FINAL
			 PRINT @V_Actividad_AFIP
			 PRINT @V_F_ALTA_BCO
			 PRINT @V_F_HASTA_CER*/
			 
			 
		 IF (@V_Tamaño_Calculado IS NOT NULL) --AND (@V_Tamaño_Calculado != @V_TAM_ANTERIOR)
		  
		  BEGIN 
		  
		   -- Obtenemos descripcion de tamaño calculado 
		   SELECT @V_Tamaño_Calculado_Desc= DESCRIPCION FROM OPCIONES WHERE NUMERODECAMPO=43440 AND OPCIONINTERNA=@V_Tamaño_Calculado AND IDIOMA=''E''	  
		  	   
		   INSERT INTO CRE_TAM_EMP_BITACORA (JTS_BITACORA, CLIENTE, FECHA, TOTAL_VENTAS, RPC, PERSONAL_OCUPADO, VALOR_ACTIVO, TAM_ACTUAL, TAM_ANTERIOR, NRO_REGISTRO, PROCESO, F_INICIO, F_FIN, TZ_LOCK, ASIENTO, SUCURSAL, CODIGO_ACT_AFIP, F_ALTA_BCO, F_HASTA_CER)
               VALUES (@NextID, @V_CODIG_CLIENTE, @FECHA_PROCESO, ISNULL(@V_TOTAL_VENTAS,0), ISNULL(@V_RPC,0), ISNULL(@V_PERSONAL_OCUPADO,0), ISNULL(@V_VALOR_ACTIVO,0), @V_Tamaño_Calculado_Desc, @V_TAM_ANTERIOR, ISNULL(@V_NRO_REGISTRO,''''), ''A'', @V_F_INICIO, @V_F_FINAL, 0, 1003831, 1, @V_Actividad_AFIP, @V_F_ALTA_BCO, @V_F_HASTA_CER);
		  
		   SET @V_K_OK = @V_K_OK + 1  
		  
		  END 
		  
		 IF  @V_Tamaño_Calculado IS NULL
		 
		  BEGIN
		  
		  -- Obtenemos descripcion de tamaño calculado 
		   SELECT @V_Tamaño_Calculado_Desc= DESCRIPCION FROM OPCIONES WHERE NUMERODECAMPO=43440 AND OPCIONINTERNA=@V_Tamaño_Calculado AND IDIOMA=''E''	  
		  -- Insertamos aunque no se haya podido calcular tamaño para que quede registro de la accion	   
		   INSERT INTO CRE_TAM_EMP_BITACORA (JTS_BITACORA, CLIENTE, FECHA, TOTAL_VENTAS, RPC, PERSONAL_OCUPADO, VALOR_ACTIVO, TAM_ACTUAL, TAM_ANTERIOR, NRO_REGISTRO, PROCESO, F_INICIO, F_FIN, TZ_LOCK, ASIENTO, SUCURSAL, CODIGO_ACT_AFIP, F_ALTA_BCO, F_HASTA_CER)
           VALUES (@NextID, @V_CODIG_CLIENTE, @FECHA_PROCESO, ISNULL(@V_TOTAL_VENTAS,0), ISNULL(@V_RPC,0), ISNULL(@V_PERSONAL_OCUPADO,0), ISNULL(@V_VALOR_ACTIVO,0), @V_Tamaño_Calculado_Desc, @V_TAM_ANTERIOR, ISNULL(@V_NRO_REGISTRO,''''), ''A'', @V_F_INICIO, @V_F_FINAL, 0, 1003831, 1, @V_Actividad_AFIP, @V_F_ALTA_BCO, @V_F_HASTA_CER);
		  
		   SET @V_K_SIN_CALCULAR = @V_K_SIN_CALCULAR + 1
		   
		    SET @p_ret_proceso = 0

            SET @p_msg_proceso = ''TAMAÑO NO CALCULADO, - CLIENTE: ''+ CAST(@V_CODIG_CLIENTE AS nvarchar(max))+ '' - Descripcion: ''+CAST(@V_Descripcion AS nvarchar(max))
            
            EXECUTE dbo.pkg_constantes$VarcharConstantes ''C_LOG_TIPO_ERROR'', @v_constante OUTPUT;

            EXECUTE dbo.PKG_LOG_PROCESO$proc_ins_log_proceso 
               @p_id_proceso = @p_id_proceso, 
               @p_fch_proceso = @p_dt_proceso, 
               @p_nom_package = ''ACTUALIZAR_TAMANO_EMPRESA'', 
               @p_cod_error = @p_ret_proceso, 
               @p_msg_error = @p_msg_proceso, 
               @p_tipo_error = @v_constante
		   		   
		  
		  END
		  
		  SET @V_K_TOTAL = @V_K_SIN_CALCULAR + @V_K_OK
		  
		  /* PRINT @V_K_SIN_CALCULAR 
		   PRINT @V_K_OK
		   PRINT @V_K_TOTAL*/
		  	
		   	FETCH NEXT FROM CUR_CLIENTES_PARA_ACTUALIZAR INTO @V_TIPO_DOCUMENTO,
		                                                       @V_CUIT,
		                                                       @V_Actividad_AFIP,
		                                                       @V_CODIG_CLIENTE,
		                                                       @JTS_BITACORA,
		                                                       @V_TAM_ANTERIOR
            
            END 
            
            
            SET @P_RET_PROCESO = 1
	        SET @P_MSG_PROCESO = ''Actualización del Tamaño Funcionó correctamente. Se actualizaron ''+ ISNULL(CAST(@V_K_OK AS nvarchar(max)), '''') + '' registros.''+ ''Se han detectado ''+ ISNULL(CAST(@V_K_SIN_CALCULAR AS nvarchar(max)), '''')+'' registros sin procesar''
	  
			  EXECUTE dbo.pkg_constantes$VarcharConstantes ''C_LOG_TIPO_INFORMACION'', @v_constante OUTPUT;
			  
			  EXECUTE dbo.PKG_LOG_PROCESO$PROC_INS_LOG_PROCESO 
			       @P_ID_PROCESO = @P_ID_PROCESO, 
			       @P_FCH_PROCESO = @P_DT_PROCESO, 
			       @P_NOM_PACKAGE = ''ACTUALIZAR_TAMANO_EMPRESA'', 
			       @P_COD_ERROR = @P_RET_PROCESO, 
			       @P_MSG_ERROR = @P_MSG_PROCESO, 
			       @P_TIPO_ERROR = @v_constante
			  
			  -- actualizo numerador con ultimo registro insertado en bitacora

			  IF (@V_K_OK>0 OR @V_K_SIN_CALCULAR>0)
			  BEGIN
			  	UPDATE NUMERATORVALUES SET VALOR = @NextID + 1 WHERE NUMERO = 43217 
			  END
			  
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
               @p_nom_package = ''ACTUALIZAR_TAMANO_EMPRESA'', 
               @p_cod_error = @p_ret_proceso, 
               @p_msg_error = @p_msg_proceso, 
               @p_tipo_error = @v_constante

         END

      END CATCH
            
		  		
			CLOSE CUR_CLIENTES_PARA_ACTUALIZAR;
			DEALLOCATE CUR_CLIENTES_PARA_ACTUALIZAR;
			END
         
          
          
        
             
            
         END

      END

      

      RETURN 

   END
')

