EXECUTE('IF OBJECT_ID (''ACTUALIZAR_TAMANO_EMPRESA'') IS NOT NULL
	DROP PROCEDURE ACTUALIZAR_TAMANO_EMPRESA')



EXECUTE(' CREATE PROCEDURE ACTUALIZAR_TAMANO_EMPRESA
   
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
         @V_CODIGO_CLIENTE NUMERIC (12),
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
	     @FECHA_PROCESO2 VARCHAR(8)
   
      BEGIN
      
      SELECT @FECHA_PROCESO = a.FECHAPROCESO 
        FROM PARAMETROS a



      --SET @FECHA_PROCESO = ''20201022''
           
         BEGIN 

		  DECLARE CUR_CLIENTES_PARA_ACTUALIZAR  CURSOR LOCAL FOR 	   

       								   
										
			SELECT DISTINCT c.TIPODOC, c.NUMERODOC, d.CODIGO_ACT_afip, a.CLIENTE,A.JTS_BITACORA, a.TAM_ACTUAL
			  FROM CRE_TAM_EMP_BITACORA A,
			       CRE_TAM_EMP_PERS B, 
			       VW_CLI_X_DOC C,
			       CLI_Cod_Act_AFIP D               
			 WHERE A.TZ_LOCK =0
			   AND A.TZ_LOCK = b.TZ_LOCK
			   AND A.TZ_LOCK = d.TZ_LOCK
			   AND A.CLIENTE = c.CODIGOCLIENTE
			   AND a.FECHA>=b.FECHA_VIGENCIA 
			   AND b.FECHA_ACTUALIZACION= @FECHA_PROCESO
			   AND d.CODIGO_ACT_afip=a.CODIGO_ACT_afip 
			   AND d.CODIGO_SECTOR=b.SECTOR
			   AND d.Cat_Por_Per=''S''
			   AND A.JTS_BITACORA = (SELECT MAX (JTS_BITACORA)
						                           FROM CRE_TAM_EMP_BITACORA
						                           WHERE CLIENTE = a.CLIENTE)
			UNION
			SELECT DISTINCT c.TIPODOC, c.NUMERODOC, d.CODIGO_ACT_afip, a.CLIENTE ,A.JTS_BITACORA, a.TAM_ACTUAL
			  FROM CRE_TAM_EMP_BITACORA A,
			       CRE_TAM_EMP_VTAS B, 
			       VW_CLI_X_DOC C,
			       CLI_Cod_Act_AFIP D               
			 WHERE A.TZ_LOCK =0
			   AND A.TZ_LOCK = b.TZ_LOCK
			   AND A.TZ_LOCK = d.TZ_LOCK
			   AND A.CLIENTE = c.CODIGOCLIENTE
			   AND a.FECHA>=b.FECHA_VIGENCIA 
			   AND b.FECHA_ACTUALIZACION= @FECHA_PROCESO
			   AND d.CODIGO_ACT_afip=a.CODIGO_ACT_afip 
			   AND d.CODIGO_SECTOR=b.SECTOR
			   AND d.Cat_Por_Vta=''S''
			   AND A.JTS_BITACORA = (SELECT MAX (JTS_BITACORA)
						                           FROM CRE_TAM_EMP_BITACORA
						                           WHERE CLIENTE = a.CLIENTE)
			 UNION
			 
			 SELECT DISTINCT c.TIPODOC, c.NUMERODOC, d.CODIGO_ACT_afip, a.CLIENTE ,A.JTS_BITACORA, a.TAM_ACTUAL
			  FROM CRE_TAM_EMP_BITACORA A,
			       CRE_PARAMETROS b,
			       VW_CLI_X_DOC c,
			       CLI_Cod_Act_AFIP D
			 WHERE A.TZ_LOCK =0
			   AND A.TZ_LOCK = b.TZ_LOCK
			   AND A.TZ_LOCK = d.TZ_LOCK
			   AND A.CLIENTE = c.CODIGOCLIENTE
			   AND d.CODIGO_ACT_afip=a.CODIGO_ACT_afip 
			   AND b.CODIGO = 500
			   AND b.UTILIZADO = ''S''
			   AND a.FECHA>=b.FECHA_CONTROL
			   AND D.Cat_Por_Act=''S''
			   AND b.PARAMETRO_ALFA= SUBSTRING(CONVERT(VARCHAR(8), @FECHA_PROCESO, 112),7,2)+SUBSTRING(CONVERT(VARCHAR(8),@FECHA_PROCESO, 112),5,2)+SUBSTRING(CONVERT(VARCHAR(8), @FECHA_PROCESO, 112),1,4)  
			  -- AND A.VALOR_ACTIVO<b.IMPORTE
			   -- AND b.PARAMETRO_ALFA = SUBSTRING(CONVERT(VARCHAR(8),a.FECHA, 112),7,2)+SUBSTRING(CONVERT(VARCHAR(8), a.FECHA, 112),5,2)+SUBSTRING(CONVERT(VARCHAR(8), a.FECHA, 112),1,4)  
			   AND A.JTS_BITACORA = (SELECT MAX (JTS_BITACORA)
						                           FROM CRE_TAM_EMP_BITACORA
						                           WHERE CLIENTE = a.CLIENTE)
						                           
		   			      
         
         
          BEGIN
			  OPEN CUR_CLIENTES_PARA_ACTUALIZAR;
		     FETCH NEXT FROM CUR_CLIENTES_PARA_ACTUALIZAR INTO @V_TIPO_DOCUMENTO,
		                                                       @V_CUIT,
		                                                       @V_Actividad_AFIP,
		                                                       @V_CODIGO_CLIENTE,
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
	     @V_CODIGO_CLIENTE,
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
			  FROM CRE_TAM_EMP_BITACORA
			  
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
		   INSERT INTO CRE_TAM_EMP_BITACORA (JTS_BITACORA, CLIENTE, FECHA, TOTAL_VENTAS, RPC, PERSONAL_OCUPADO, VALOR_ACTIVO, TAM_ACTUAL, TAM_ANTERIOR, NRO_REGISTRO, PROCESO, F_INICIO, F_FIN, TZ_LOCK, ASIENTO, SUCURSAL, CODIGO_ACT_AFIP, F_ALTA_BCO, F_HASTA_CER)
               VALUES (@NextID, @V_CODIGO_CLIENTE, @FECHA_PROCESO, ISNULL(@V_TOTAL_VENTAS,0), ISNULL(@V_RPC,0), ISNULL(@V_PERSONAL_OCUPADO,0), ISNULL(@V_VALOR_ACTIVO,0), @V_Tamaño_Calculado, @V_TAM_ANTERIOR, ISNULL(@V_NRO_REGISTRO,''''), ''A'', @V_F_INICIO, @V_F_FINAL, 0, 1003831, 1, @V_Actividad_AFIP, @V_F_ALTA_BCO, @V_F_HASTA_CER);
		  
		   SET @V_K_OK = @V_K_OK + 1  
		  
		  END 
		  
		 IF  @V_Tamaño_Calculado IS NULL
		 
		  BEGIN
		  
		   SET @V_K_SIN_CALCULAR = @V_K_SIN_CALCULAR + 1
		   
		    SET @p_ret_proceso = 0

            SET @p_msg_proceso = ''TAMAÑO NO CALCULADO, - CLIENTE: ''+ CAST(@V_CODIGO_CLIENTE AS nvarchar(max))+ '' - Descripcion: ''+CAST(@V_Descripcion AS nvarchar(max))
            
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
		                                                       @V_CODIGO_CLIENTE,
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

			  IF @V_K_OK>0
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

   END')


EXECUTE('IF OBJECT_ID (''OBTENER_TAMANO_EMPRESA'') IS NOT NULL
	DROP PROCEDURE OBTENER_TAMANO_EMPRESA')



EXECUTE('CREATE PROCEDURE OBTENER_TAMANO_EMPRESA
  
     @P_CUIT VARCHAR (20),
     @P_TIPO_DOCUMENTO VARCHAR (4),
     @P_Actividad_AFIP VARCHAR (12),
     @P_CODIGO_CLIENTE NUMERIC (12),
     @P_STATUS NUMERIC (1)  OUTPUT ,
     @P_Descripcion VARCHAR (100) OUTPUT , 
     @P_Tamaño_Calculado VARCHAR (50) OUTPUT,
     @P_PROCESO VARCHAR (30) OUTPUT,
     @P_F_INICIO DATE  OUTPUT,        
     @P_F_FINAL  DATE  OUTPUT,        
     @P_TOTAL_VENTAS NUMERIC (15,2)OUTPUT,      
     @P_RPC  NUMERIC (15,2) OUTPUT , 			
     @P_PERSONAL_OCUPADO NUMERIC (5) OUTPUT, 
     @P_VALOR_ACTIVO NUMERIC (15,2) OUTPUT,
     @P_NRO_REGISTRO VARCHAR (30) OUTPUT,
     @P_TAM_ACTUAL VARCHAR (40) OUTPUT,  
     @P_F_HASTA_CER DATE  OUTPUT,        
     @P_F_ALTA_BCO  DATE  OUTPUT

AS 
   
   --BEGIN
   
    
      SET @P_STATUS = NULL
      SET @P_Descripcion = NULL
      SET @P_PROCESO = NULL
     
      DECLARE
      @TIENE_BALANCE NUMERIC (1) = NULL,
      @ANTIGUEDAD    NUMERIC (20)= NULL,
     --@CODIGOCLIENTE NUMERIC (12)= NULL,
      @ES_GRAN_EMPRESA NUMERIC (3)= NULL,
      @PROM_TOTAL_VENTAS NUMERIC(15,2)= NULL,
      @PROM_PERSONAL_OCUPADO NUMERIC (5)= NULL,
      @ULTIMO_VALOR_ACTIVO NUMERIC(15,2)= NULL,
      @CANTIDAD_BALANCES INT= NULL,
      @CODIGO_ACT_AFIP VARCHAR (12)= @P_Actividad_AFIP,
      @TIENE_GRUPO_ECONOMICO NUMERIC (2) = NULL,
      @AnalizaVentas BIT =NULL, 
      @AnalizaPersonal BIT =NULL,
      @AnalisaValActivo BIT =NULL,
      @TAMANIO VARCHAR (60) = NULL,
      @TAMANIO_MIPYME VARCHAR (60) = NULL,
      @VALIDACION VARCHAR(80) = NULL,
      @cantidad NUMERIC(2),
      @COD_GRUPO_ECONOMICO NUMERIC (12),
      @FECHA_PROCESO DATE
    
      
      -- BEGIN
     
        
        BEGIN TRY
      
        SELECT @FECHA_PROCESO = a.FECHAPROCESO 
          FROM PARAMETROS a
         
      
            SELECT @TIENE_BALANCE = count(*)
              FROM dbo.CRE_TAM_EMP_BALANCE
             WHERE DOCUMENTO = @P_CUIT
               AND TIPO_DOCUMENTO = @P_TIPO_DOCUMENTO
               AND TZ_LOCK = 0
               AND F_FINAL > @FECHA_PROCESO
               
      
      -- cantidad balances presentados
      
      SELECT @CANTIDAD_BALANCES = count(*)
              FROM dbo.CRE_TAM_EMP_BALANCE
             WHERE DOCUMENTO = @P_CUIT
               AND TIPO_DOCUMENTO = @P_TIPO_DOCUMENTO
               AND TZ_LOCK = 0
       
      IF  @CANTIDAD_BALANCES > 3
          BEGIN
           SET @CANTIDAD_BALANCES = 3
          END 
       
      -- promedio ventas totales
				SELECT @PROM_TOTAL_VENTAS = sum (a.total_ventas)/@CANTIDAD_BALANCES
				  FROM CRE_TAM_EMP_BALANCE a
				 WHERE a.DOCUMENTO = @P_CUIT 
				   AND a.TIPO_DOCUMENTO = @P_TIPO_DOCUMENTO
				   AND a.TZ_LOCK = 0
				   AND f_inicio IN ( SELECT TOP (@CANTIDAD_BALANCES) f_inicio 
				                       FROM CRE_TAM_EMP_BALANCE b
				                      WHERE b.DOCUMENTO = a.DOCUMENTO
				                        AND b.TIPO_DOCUMENTO = a.TIPO_DOCUMENTO
				                        AND b.TZ_LOCK = 0
				                      ORDER BY b.f_inicio DESC
				                   )  
				
	--	promedio personal ocupado
				SELECT @PROM_PERSONAL_OCUPADO = sum (a.PERSONAL_OCUPADO)/@CANTIDAD_BALANCES
				  FROM CRE_TAM_EMP_BALANCE a
				 WHERE a.DOCUMENTO = @P_CUIT 
				   AND a.TIPO_DOCUMENTO = @P_TIPO_DOCUMENTO
				   AND a.TZ_LOCK = 0
				   AND f_inicio IN ( SELECT TOP (@CANTIDAD_BALANCES) f_inicio 
				                       FROM CRE_TAM_EMP_BALANCE b
				                      WHERE b.DOCUMENTO = a.DOCUMENTO
				                        AND b.TIPO_DOCUMENTO = a.TIPO_DOCUMENTO
				                        AND b.TZ_LOCK = 0
				                      ORDER BY b.f_inicio DESC
				                   ) 
				
			 --	VALOR activo
				
				SELECT @ULTIMO_VALOR_ACTIVO = a.VALOR_ACTIVO,
				       @P_F_INICIO          = a.F_INICIO, 
				       @P_F_FINAL           = a.F_FINAL,   
				       @P_TOTAL_VENTAS      = a.TOTAL_VENTAS, 
				       @P_RPC 				= a.RPC, 
				       @P_PERSONAL_OCUPADO  = a.PERSONAL_OCUPADO, 	
				       @P_VALOR_ACTIVO      = a.VALOR_ACTIVO 
				  FROM CRE_TAM_EMP_BALANCE a
				 WHERE a.DOCUMENTO = @P_CUIT 
				   AND a.TIPO_DOCUMENTO = @P_TIPO_DOCUMENTO
				   AND a.f_final > @FECHA_PROCESO
				   AND a.TZ_LOCK = 0
				       
				       
       
         	SELECT @ANTIGUEDAD = DATEDIFF(DAY, max(b.FECHAAPERTURA), @FECHA_PROCESO)
			  FROM CLI_CLIENTES B
			 WHERE B.TZ_LOCK = 0 AND b.CODIGOCLIENTE = @P_CODIGO_CLIENTE  
			   
		
			--tamaño actual
			
		    SELECT @P_TAM_ACTUAL = b.OPCIONINTERNA
			  FROM CRE_TAM_EMP_BITACORA A,
			       OPCIONES b
				 WHERE a.TAM_ACTUAL = b.OPCIONINTERNA
				   AND b.NUMERODECAMPO = 43106
				   AND b.IDIOMA = ''E''
				   AND A.TZ_LOCK = 0
			       AND A.CLIENTE = @P_CODIGO_CLIENTE 
			       AND A.JTS_BITACORA = (SELECT   max(a.JTS_BITACORA) 
										  FROM CRE_TAM_EMP_BITACORA A,
										       OPCIONES b
											 WHERE a.TAM_ACTUAL = b.OPCIONINTERNA
											   AND b.NUMERODECAMPO = 43106
											   AND b.IDIOMA = ''E''
											   AND A.TZ_LOCK = 0
										       AND A.CLIENTE = @P_CODIGO_CLIENTE ) 
			   
	    BEGIN
          SET  @CODIGO_ACT_AFIP = @P_Actividad_AFIP
         END
          
        
        	SELECT @ES_GRAN_EMPRESA = COUNT(a.CODIGO_ACT_AFIP)
			  FROM CLI_Cod_Act_AFIP A
			 WHERE a.TZ_LOCK = 0 AND A.Cat_Por_GEM=''S''
		       AND CODIGO_ACT_AFIP = @CODIGO_ACT_AFIP
               
               
                             
      
       --analiza valores cod actividad 
       
         
          
            
    
       
       SELECT @AnalizaVentas = CASE WHEN EXISTS (
       
            SELECT cat_por_vta 
              FROM CLI_Cod_Act_AFIP
             WHERE CODIGO_ACT_AFIP = @CODIGO_ACT_AFIP
               AND cat_por_vta = ''N''
               
            )
         THEN CAST(0 AS BIT) 
         ELSE CAST(1 AS BIT) END     
       
       
        SELECT @AnalizaPersonal = CASE WHEN EXISTS (
       
            SELECT cat_por_per 
              FROM CLI_Cod_Act_AFIP
             WHERE CODIGO_ACT_AFIP = @CODIGO_ACT_AFIP
               AND cat_por_per = ''N''
               
            )
         THEN CAST(0 AS BIT) 
         ELSE CAST(1 AS BIT) end 
         
         SELECT @AnalisaValActivo = CASE WHEN EXISTS (
       
            SELECT cat_por_act 
              FROM CLI_Cod_Act_AFIP
             WHERE CODIGO_ACT_AFIP = @CODIGO_ACT_AFIP
               AND cat_por_act = ''N''
               
            )
         THEN CAST(0 AS BIT) 
         ELSE CAST(1 AS BIT) end 
       
        
          
        
 
      
    BEGIN
           SET @TIENE_GRUPO_ECONOMICO = 0
         -- END 
       
     -- IF (@TIENE_BALANCE = 0) AND (@ANTIGUEDAD > 360)
                    
      --  BEGIN 
        
          
            	SELECT @TIENE_GRUPO_ECONOMICO = count(a.CODIGOGRUPOECONOMICO)
				  FROM dbo.CLI_GRUPOSECONOMICOSCLIENTE A,
				       dbo.CLI_CLIENTES B
				 WHERE A.CODIGOCLIENTE = b.CODIGOCLIENTE
				   AND A.TZ_LOCK = b.TZ_LOCK
				   AND A.TZ_LOCK = 0
				   AND B.CODIGOCLIENTE = @P_CODIGO_CLIENTE
				   
				   
		   
        END   
       
        IF (@TIENE_GRUPO_ECONOMICO <> 0)---- de aca
         
         SELECT @COD_GRUPO_ECONOMICO = a.CODIGOGRUPOECONOMICO
				  FROM dbo.CLI_GRUPOSECONOMICOSCLIENTE A,
				       dbo.CLI_CLIENTES B
				 WHERE A.CODIGOCLIENTE = b.CODIGOCLIENTE
				   AND A.TZ_LOCK = b.TZ_LOCK
				   AND A.TZ_LOCK = 0
				   AND B.CODIGOCLIENTE = @P_CODIGO_CLIENTE
         
         
         BEGIN
          
          DECLARE 
            @V_TAMANIO VARCHAR(3) = NULL
			
			
		  declare	C_CLIENTES_GRUPO CURSOR LOCAL FOR 
			
			SELECT TOP 1 B.TAM_ACTUAL 
			  FROM CRE_TAM_EMP_BITACORA B
			 WHERE B.CLIENTE IN (SELECT a.CODIGOCLIENTE
								   FROM CLI_GRUPOSECONOMICOSCLIENTE A
								  WHERE A.CODIGOGRUPOECONOMICO = @COD_GRUPO_ECONOMICO)
			   AND b.TAM_ACTUAL = ''G''
			   ORDER BY B.JTS_BITACORA DESC
   
			
		  
			BEGIN
			  OPEN C_CLIENTES_GRUPO;
		     FETCH NEXT FROM C_CLIENTES_GRUPO INTO @V_TAMANIO
              WHILE @V_TAMANIO <> ''G''

						
			CLOSE C_CLIENTES_GRUPO;
			DEALLOCATE C_CLIENTES_GRUPO;
			END
         
          
          
        
         END
         
        
        IF (@TIENE_GRUPO_ECONOMICO = 0)
        DECLARE 
        
          @TIENE_CERTIFICADO_MIPYME NUMERIC (2)
        
        BEGIN 
        
        
            	SELECT @TIENE_CERTIFICADO_MIPYME = count(a.NRO_REGISTRO)
            	  FROM CRE_TAM_EMP_CER_MIPYMES A
				 WHERE A.CUIT = @P_CUIT
				   AND A.TZ_LOCK = 0
				   AND A.F_INICIO + a.PLAZO_VIGENCIA > @FECHA_PROCESO
				   AND A.ESTADO = ''V''
				            	
                	SELECT @P_NRO_REGISTRO = a.NRO_REGISTRO
				  FROM CRE_TAM_EMP_CER_MIPYMES A
				 WHERE A.TZ_LOCK = 0
				   AND a.CUIT = @P_CUIT
				   AND A.F_INICIO + a.PLAZO_VIGENCIA > @FECHA_PROCESO
                   AND A.ESTADO = ''V''
       
        
        END 
        
        IF @TIENE_CERTIFICADO_MIPYME > 0
          BEGIN
           	
            
            SELECT @TAMANIO_MIPYME = b.OPCIONINTERNA,
                   @P_F_HASTA_CER = a.F_HASTA,        
                   @P_F_ALTA_BCO = a.F_ALTA_BCO
				  FROM CRE_TAM_EMP_CER_MIPYMES A,
     				   OPCIONES b
				 WHERE a.CATEGORIA = b.OPCIONINTERNA
				   AND b.NUMERODECAMPO = 43106
				   AND b.IDIOMA = ''E''
				   AND A.TZ_LOCK = 0
				   AND A.CUIT = @P_CUIT
				   AND A.F_INICIO + a.PLAZO_VIGENCIA > @FECHA_PROCESO
				   AND A.ESTADO = ''V''
            
          
          END
          
        
        
  
       /*PRINT @TIENE_GRUPO_ECONOMICO
       PRINT @TIENE_CERTIFICADO_MIPYME
       PRINT @TIENE_BALANCE 
       PRINT @ANTIGUEDAD 
       PRINT @P_CODIGO_CLIENTE
       PRINT @ES_GRAN_EMPRESA 
       
       PRINT @PROM_TOTAL_VENTAS
       PRINT @PROM_PERSONAL_OCUPADO 
       PRINT @ULTIMO_VALOR_ACTIVO 
       PRINT @CANTIDAD_BALANCES 
       PRINT @P_Actividad_AFIP
       PRINT @CODIGO_ACT_AFIP
       PRINT   @AnalizaVentas
       PRINT   @AnalizaPersonal 
       PRINT   @AnalisaValActivo
       PRINT  @TAMANIO*/
       
      BEGIN
      
      
     
     
        ----------------------------------------------
     
     BEGIN
     
   --mz   IF @AnalizaVentas = 0 AND @AnalizaPersonal = 0 AND @AnalisaValActivo = 0
       
       BEGIN
       --VALIDACION 1
        
        IF (@TIENE_BALANCE = 0) AND (@ANTIGUEDAD > 360) AND (@VALIDACION IS NULL) AND (@TIENE_GRUPO_ECONOMICO = 0) AND (@TIENE_CERTIFICADO_MIPYME = 0)
       
       
        BEGIN 
       
         SET @P_STATUS = 1
         SET @P_Descripcion = ''Verificar Vigencia del Balance''
         SET @P_PROCESO = ''FINALIZO OK'' 
         SET @VALIDACION = ''VALIDACION 1''
        
        END
        
       END --mz
        
     --VALIDACION 2 Y 3 
     
      BEGIN
      IF (@TIENE_GRUPO_ECONOMICO = 0) AND (@TIENE_CERTIFICADO_MIPYME <> 0 ) --AND (@VALIDACION IS NULL)
          BEGIN
             SET @P_STATUS = 0
             SET @P_Descripcion = ''Se pudo determinar tamaño empresa''
             SET @P_PROCESO = ''FINALIZO OK'' 
             SET @P_Tamaño_Calculado = @TAMANIO_MIPYME 
             SET @VALIDACION = ''VALIDACION 3''
           END
       
      END 
      
      BEGIN
      IF (@TIENE_GRUPO_ECONOMICO <> 0) AND (@TIENE_CERTIFICADO_MIPYME <> 0 ) --AND (@VALIDACION IS NULL)
          BEGIN     
             SET @P_STATUS = 0
             SET @P_Descripcion = ''Se pudo determinar tamaño empresa''
             SET @P_PROCESO = ''FINALIZO OK'' 
             SET @P_Tamaño_Calculado = @TAMANIO_MIPYME
             SET @VALIDACION = ''VALIDACION 3''
           END
        
      END
      
   BEGIN
      IF (@TIENE_GRUPO_ECONOMICO <> 0) AND (@TIENE_CERTIFICADO_MIPYME <> 0 ) AND (@V_TAMANIO <> ''G'')
          BEGIN
             SET @P_STATUS = 0
             SET @P_Descripcion = ''Se pudo determinar tamaño empresa''
             SET @P_PROCESO = ''FINALIZO OK'' 
             SET @P_Tamaño_Calculado = @TAMANIO_MIPYME
             SET @VALIDACION = ''VALIDACION 3''
           END
        
      END      
        
       BEGIN
       
       IF (@TIENE_GRUPO_ECONOMICO <> 0) AND (@TIENE_CERTIFICADO_MIPYME = 0 )  AND (@V_TAMANIO = ''G'')
            BEGIN
             SET @P_STATUS = 0
             SET @P_Descripcion = ''Se pudo determinar tamaño empresa''
             SET @P_PROCESO = ''FINALIZO OK''
             SET @P_Tamaño_Calculado = ''G''
             SET @VALIDACION = ''VALIDACION 2''
            END
       END
        
     
      BEGIN
      IF @ANTIGUEDAD < 360 AND (@TIENE_GRUPO_ECONOMICO = 0) AND (@TIENE_CERTIFICADO_MIPYME = 0)
       BEGIN
       IF @ES_GRAN_EMPRESA = 1
          BEGIN 
             SET @P_STATUS = 0
             SET @P_Descripcion = ''Se pudo determinar tamaño empresa''
             SET @P_PROCESO = ''FINALIZO OK''
             SET @P_Tamaño_Calculado = ''G''
             SET @VALIDACION = ''VALIDACION 4''
          
          END 
       ELSE
          BEGIN
             SET @P_STATUS = 0
             SET @P_Descripcion = ''Se pudo determinar tamaño empresa''
             SET @P_PROCESO = ''FINALIZO OK''
             SET @P_Tamaño_Calculado = ''MICRO''
             SET @VALIDACION = ''VALIDACION 4''
          END 
       END
      
      
     END
    -- END mz
     
    
     
        --------------------------------------------------
     IF (@VALIDACION IS NULL) 
     BEGIN
      IF @AnalizaVentas = 0 AND @AnalizaPersonal = 0 AND @AnalisaValActivo = 0
         BEGIN
             SET @P_STATUS = 0
             SET @P_Descripcion = ''Se pudo determinar tamaño empresa''
             SET @P_PROCESO = ''FINALIZO OK'' 
             SET @P_Tamaño_Calculado = ''G'' 
             SET @VALIDACION = ''VALIDACION 6''
          END
      
      
      
       --VALIDACION 7
		        IF (@AnalizaVentas = 1) AND (@AnalizaPersonal = 0) AND (@AnalisaValActivo = 0)
		         BEGIN 
		          SET @TAMANIO = NULL
		           
		           SELECT TOP 1 @TAMANIO = b.OPCIONINTERNA 
		             FROM CRE_TAM_EMP_VTAS a,
		                  OPCIONES b
					WHERE a.TAMANIO = b.OPCIONINTERNA
					  AND b.DESCRIPCION IS NOT NULL
					  AND b.NUMERODECAMPO = 44003
					  AND a.SECTOR = (SELECT codigo_sector 
					                    FROM CLI_Cod_Act_AFIP 
					                   WHERE CODIGO_ACT_AFIP = @CODIGO_ACT_AFIP)
					  AND @PROM_TOTAL_VENTAS <= a.IMPORTELIMITE
					  AND a.TZ_LOCK = 0 
					  AND b.IDIOMA = ''E''
					 order BY a.SECTOR, a.IMPORTELIMITE ASC
					
					
				  BEGIN
					IF (@TAMANIO IS NOT NULL) 
					 BEGIN 
					  SET @P_STATUS = 0
		              SET @P_Descripcion = ''Se pudo determinar tamaño empresa''
		              SET @P_PROCESO = ''FINALIZO OK''
		              SET @P_Tamaño_Calculado = @TAMANIO
					 END
					ELSE
					  BEGIN  
					   SET @P_STATUS = 0
				       SET @P_Descripcion = ''Se pudo determinar tamaño empresa''
				       SET @P_PROCESO = ''FINALIZO OK''
				       SET @P_Tamaño_Calculado = ''G''
				      END 
		           END
		         END
               
                 
                 BEGIN
                  IF (@AnalizaVentas = 0) AND (@AnalizaPersonal = 1) AND (@AnalisaValActivo = 0)
                   
                    
                                      
                    
					BEGIN
					  SET @TAMANIO = NULL
					                      
						SELECT TOP 1 @TAMANIO = b.OPCIONINTERNA
		                  FROM CRE_TAM_EMP_PERS a,
		                       OPCIONES b
						 WHERE a.TAMANIO = b.OPCIONINTERNA
						   AND b.DESCRIPCION IS NOT NULL
						   AND b.NUMERODECAMPO = 43303
						   AND a.SECTOR = (SELECT codigo_sector 
						                    FROM CLI_Cod_Act_AFIP
						                    WHERE CODIGO_ACT_AFIP = @CODIGO_ACT_AFIP)
						   AND @PROM_PERSONAL_OCUPADO <= a.PERSONALLIM
						   AND a.TZ_LOCK = 0 
						   AND b.IDIOMA = ''E''
						 order BY a.SECTOR, a.PERSONALLIM ASC
						 
						 
					
					     IF (@TAMANIO IS NOT NULL ) 
					     
						 -- PRINT ''@TAMANIO''+@TAMANIO
						 BEGIN 
						 
						  SET @P_STATUS = 0
			              SET @P_Descripcion = ''Se pudo determinar tamaño empresa''
			              SET @P_PROCESO = ''FINALIZO OK''
			              SET @P_Tamaño_Calculado = @TAMANIO
						 END
						 
						IF (@TAMANIO IS NULL ) 
						  BEGIN
						   
						   SET @P_STATUS = 0
					       SET @P_Descripcion = ''Se pudo determinar tamaño empresa''
					       SET @P_PROCESO = ''FINALIZO OK''
					       SET @P_Tamaño_Calculado = ''G''
                          END
                     END   
                  
                   END
                   
                   
                   BEGIN
                   IF (@AnalizaVentas = 0) AND (@AnalizaPersonal = 0) AND (@AnalisaValActivo = 1)
                   
                                      
                    BEGIN
                      
                      SET @TAMANIO = NULL
                     
                       SELECT @cantidad = count(DESCRIPCION)
                         FROM CRE_PARAMETROS
						WHERE CODIGO = 500
						  AND @ULTIMO_VALOR_ACTIVO <= importe  
						  AND TZ_LOCK = 0 
						  
						  
					
						 IF @cantidad <> 0  
						  
						  BEGIN
						  
						   SELECT TOP 1 @TAMANIO = b.OPCIONINTERNA 
				             FROM CRE_TAM_EMP_VTAS a,
				                  OPCIONES b
							WHERE a.TAMANIO = b.OPCIONINTERNA
							  AND b.DESCRIPCION IS NOT NULL
							  AND b.NUMERODECAMPO = 44003
							  AND a.SECTOR = (SELECT codigo_sector 
							                    FROM CLI_Cod_Act_AFIP 
							                   WHERE CODIGO_ACT_AFIP = @CODIGO_ACT_AFIP)
							  AND @PROM_TOTAL_VENTAS <= a.IMPORTELIMITE
							  AND a.TZ_LOCK = 0 
							  AND b.IDIOMA = ''E''
							 order BY a.SECTOR, a.IMPORTELIMITE
						   END
						   BEGIN	 
							 SET @P_STATUS = 0
				             SET @P_Descripcion = ''Se pudo determinar tamaño empresa''
				             SET @P_PROCESO = ''FINALIZO OK''
				             SET @P_Tamaño_Calculado = @TAMANIO
								  
						  END
					  	IF @cantidad = 0
						  BEGIN
						     
						     SET @P_STATUS = 0
				             SET @P_Descripcion = ''Se pudo determinar tamaño empresa''
				             SET @P_PROCESO = ''FINALIZO OK''
				             SET @P_Tamaño_Calculado = ''G''
						  END 
                    
                    END    
                   END   
     
     END   
     END  
      --PRINT @validacion
   
     END
     
        END TRY
     
       BEGIN CATCH
           SET @P_STATUS = 1
           SET @P_Descripcion = ''Verificar Vigencia del Balance''
           SET @P_PROCESO = ''Cancelado por error''
            DECLARE
               @errornumber int

            SET @errornumber = ERROR_NUMBER()

            DECLARE
               @errormessage nvarchar(4000)

            SET @errormessage = ERROR_MESSAGE()

            DECLARE
               @exceptionidentifier nvarchar(4000)

            SELECT @exceptionidentifier = ''SQL-00100''


            IF (@exceptionidentifier LIKE N''ORA-00100%'')
              BEGIN
               SET @P_STATUS = 1
               SET @P_Descripcion = CONVERT(VARCHAR,@errornumber)
               SET @P_PROCESO = ''Cancelado por error SQL-00100 ''+@errormessage
               
              END 
            ELSE 
               BEGIN
                  IF (@exceptionidentifier IS NOT NULL)
                     BEGIN
                        IF @errornumber = 99998
    BEGIN 
                           SET @P_STATUS = 1
                        SET @P_Descripcion = CONVERT(VARCHAR,@errornumber)
                           SET @P_PROCESO = ''Cancelado por error 99998''+@errormessage
 END 
                        ELSE 
                          BEGIN
            
                           SET @P_STATUS = 1
                           SET @P_Descripcion = CONVERT(VARCHAR,@errornumber)
                           SET @P_PROCESO = ''Cancelado por error 99998''+@errormessage
                          END
                     END
                  
               END

         END CATCH
         
         RETURN
')

