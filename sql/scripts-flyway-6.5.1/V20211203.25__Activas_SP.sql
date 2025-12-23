EXECUTE('
IF OBJECT_ID (''OBTENER_TAMANO_EMPRESA'') IS NOT NULL
	DROP  PROCEDURE OBTENER_TAMANO_EMPRESA
')
EXECUTE('
CREATE PROCEDURE OBTENER_TAMANO_EMPRESA
  
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
      @FECHA_PROCESO DATE,
      @NUMEROPERSONA NUMERIC (12),
      @INICIO_ACTIVIDAD VARCHAR(10),
      @INICIO_ACTIVIDAD_CONVERT VARCHAR(20),
      @FECHA_INICIO_ACTIVADAD DATE,
      @TIPO_PERSONA VARCHAR(1)
    
      
      -- BEGIN
     
        
        BEGIN TRY
      
        SELECT @FECHA_PROCESO = a.FECHAPROCESO 
          FROM PARAMETROS a WITH(NOLOCK)
         
      
            SELECT @TIENE_BALANCE = count(*)
              FROM dbo.CRE_TAM_EMP_BALANCE WITH(NOLOCK)
             WHERE DOCUMENTO = @P_CUIT
               AND TIPO_DOCUMENTO = @P_TIPO_DOCUMENTO
               AND TZ_LOCK = 0
               AND F_FINAL >= @FECHA_PROCESO
               
      
      -- cantidad balances presentados
      
      SELECT @CANTIDAD_BALANCES = count(*)
              FROM dbo.CRE_TAM_EMP_BALANCE WITH(NOLOCK)
             WHERE DOCUMENTO = @P_CUIT
               AND TIPO_DOCUMENTO = @P_TIPO_DOCUMENTO
               AND TZ_LOCK = 0
       
      IF  @CANTIDAD_BALANCES > 3
          BEGIN
           SET @CANTIDAD_BALANCES = 3
          END 
       
      -- promedio ventas totales
				SELECT @PROM_TOTAL_VENTAS = sum (a.total_ventas)/@CANTIDAD_BALANCES
				  FROM CRE_TAM_EMP_BALANCE a WITH(NOLOCK)
				 WHERE a.DOCUMENTO = @P_CUIT 
				   AND a.TIPO_DOCUMENTO = @P_TIPO_DOCUMENTO
				   AND a.TZ_LOCK = 0
				   AND f_inicio IN ( SELECT TOP (@CANTIDAD_BALANCES) f_inicio 
				                       FROM CRE_TAM_EMP_BALANCE b WITH(NOLOCK)
				                      WHERE b.DOCUMENTO = a.DOCUMENTO
				                        AND b.TIPO_DOCUMENTO = a.TIPO_DOCUMENTO
				                        AND b.TZ_LOCK = 0
				                      ORDER BY b.f_inicio DESC
				                   )  
				
	--	promedio personal ocupado
				SELECT @PROM_PERSONAL_OCUPADO = sum (a.PERSONAL_OCUPADO)/@CANTIDAD_BALANCES
				  FROM CRE_TAM_EMP_BALANCE a WITH(NOLOCK)
				 WHERE a.DOCUMENTO = @P_CUIT 
				   AND a.TIPO_DOCUMENTO = @P_TIPO_DOCUMENTO
				   AND a.TZ_LOCK = 0
				   AND f_inicio IN ( SELECT TOP (@CANTIDAD_BALANCES) f_inicio 
				                       FROM CRE_TAM_EMP_BALANCE b WITH(NOLOCK)
				                      WHERE b.DOCUMENTO = a.DOCUMENTO
				                        AND b.TIPO_DOCUMENTO = a.TIPO_DOCUMENTO
				        AND b.TZ_LOCK = 0
				                      ORDER BY b.f_inicio DESC
				                   ) 
				
			 --	VALOR activo
				
				SELECT TOP 1
					   @ULTIMO_VALOR_ACTIVO = a.VALOR_ACTIVO,
				       @P_F_INICIO          = a.F_INICIO, 
				       @P_F_FINAL           = a.F_FINAL,   
				       @P_TOTAL_VENTAS      = a.TOTAL_VENTAS, 
				       @P_RPC 				= a.RPC, 
				       @P_PERSONAL_OCUPADO  = a.PERSONAL_OCUPADO, 	
				       @P_VALOR_ACTIVO      = a.VALOR_ACTIVO 
				  FROM CRE_TAM_EMP_BALANCE a WITH(NOLOCK)
				 WHERE a.DOCUMENTO = @P_CUIT 
				   AND a.TIPO_DOCUMENTO = @P_TIPO_DOCUMENTO
				   AND a.f_final >= @FECHA_PROCESO
				   AND a.TZ_LOCK = 0
				 ORDER BY a.F_FINAL   
				       
			-- Antiguedad
			SELECT TOP 1 @NUMEROPERSONA = NUMEROPERSONA FROM CLI_ClientePersona WITH(NOLOCK) WHERE TITULARIDAD = ''T'' AND TZ_LOCK = 0 AND CODIGOCLIENTE = @P_CODIGO_CLIENTE       
       
       		-- Busco Tipo Persona
       		SELECT TOP 1 @TIPO_PERSONA = TIPO FROM CLI_CLIENTES WITH(NOLOCK) WHERE CODIGOCLIENTE = @P_CODIGO_CLIENTE AND TZ_LOCK = 0
       		
       		IF @TIPO_PERSONA = ''F''
       			BEGIN
			 		SELECT TOP 1 @INICIO_ACTIVIDAD = ''01''+INICIO_ACTIVIDAD
			 		FROM CLI_ACTIVIDAD_ECONOMICA WITH(NOLOCK)
			 		WHERE CODIGO_PERSONA_CLIENTE = @NUMEROPERSONA AND 
			 		CODIGO_ACTIVIDAD = @CODIGO_ACT_AFIP AND TZ_LOCK = 0 
			 		ORDER BY substring(INICIO_ACTIVIDAD,3,4), substring(INICIO_ACTIVIDAD,1,2)		       
		       
		       		SET @INICIO_ACTIVIDAD_CONVERT = SUBSTRING(@INICIO_ACTIVIDAD, 1, 2) + ''-'' + SUBSTRING(@INICIO_ACTIVIDAD, 3, 2) + ''-'' + SUBSTRING(@INICIO_ACTIVIDAD, 5, 4) 
		    	END
		    ELSE
		    	BEGIN
		    		SELECT @INICIO_ACTIVIDAD_CONVERT = FECHACONSTITUCION FROM CLI_PERSONASJURIDICAS WITH(NOLOCK) WHERE NUMEROPERSONAJURIDICA = @NUMEROPERSONA AND TZ_LOCK = 0
		    	END 
		    	 		       		
       		SET @FECHA_INICIO_ACTIVADAD = TRY_CONVERT(DATETIME, @INICIO_ACTIVIDAD_CONVERT, 103)  
       		
       		IF  @FECHA_INICIO_ACTIVADAD IS NULL 
       			BEGIN    		   
			   		SET @ANTIGUEDAD = 99999999
			   	END
			ELSE 
				BEGIN
					SELECT @ANTIGUEDAD = DATEDIFF(DAY, @FECHA_INICIO_ACTIVADAD , @FECHA_PROCESO)
				END   
			
			--Hacemos SET de @TIENE_BALANCE en 0 para que entre por excepcion de vigencia de balance si no cumple con las condiciones			
			IF (@CANTIDAD_BALANCES < 2) AND (@ANTIGUEDAD > 900) AND (@ANTIGUEDAD <= 1260) 
				BEGIN
					SET @TIENE_BALANCE = 0;
				END				
			IF (@CANTIDAD_BALANCES < 3) AND (@ANTIGUEDAD > 1260) 
				BEGIN
					SET @TIENE_BALANCE = 0;					
				END				
				
			--tamaño actual				
		    SELECT @P_TAM_ACTUAL = b.OPCIONINTERNA
			  FROM CRE_TAM_EMP_BITACORA A WITH(NOLOCK),
			       OPCIONES b WITH(NOLOCK)
				 WHERE a.TAM_ACTUAL = b.OPCIONINTERNA
				   AND b.NUMERODECAMPO = 43106
				   AND b.IDIOMA = ''E''
				   AND A.TZ_LOCK = 0
			       AND A.CLIENTE = @P_CODIGO_CLIENTE 
			       AND A.JTS_BITACORA = (SELECT   max(a.JTS_BITACORA) 
										  FROM CRE_TAM_EMP_BITACORA A WITH(NOLOCK),
										       OPCIONES b WITH(NOLOCK)
											 WHERE a.TAM_ACTUAL = b.OPCIONINTERNA
											   AND b.NUMERODECAMPO = 43106
											   AND b.IDIOMA = ''E''
											   AND A.TZ_LOCK = 0
										       AND A.CLIENTE = @P_CODIGO_CLIENTE ) 			             
        
        	SELECT @ES_GRAN_EMPRESA = COUNT(a.CODIGO_ACT_AFIP)
			  FROM CLI_Cod_Act_AFIP A WITH(NOLOCK)
			 WHERE a.TZ_LOCK = 0 AND A.Cat_Por_GEM=''S''
		       AND CODIGO_ACT_AFIP = @CODIGO_ACT_AFIP                                                           
      
		--Analizo si tiene Grupo Economico      
		BEGIN
           SET @TIENE_GRUPO_ECONOMICO = 0
          
            	SELECT @TIENE_GRUPO_ECONOMICO = count(a.CODIGOGRUPOECONOMICO)
				  FROM dbo.CLI_GRUPOSECONOMICOSCLIENTE A WITH(NOLOCK)
				  INNER JOIN  dbo.CLI_CLIENTES B WITH(NOLOCK) ON A.CODIGOCLIENTE = B.CODIGOCLIENTE AND B.CODIGOCLIENTE = @P_CODIGO_CLIENTE AND B.TZ_LOCK = 0				   
				 WHERE A.TZ_LOCK = 0
		   
		END   
		
		-- Busco la actividad AFIP del cliente del grupo con las mayores ventas
		IF (@TIENE_GRUPO_ECONOMICO <> 0)   
			BEGIN
				-- Obtengo Codigo de Grupo
				SELECT @COD_GRUPO_ECONOMICO = a.CODIGOGRUPOECONOMICO
				  FROM dbo.CLI_GRUPOSECONOMICOSCLIENTE A WITH(NOLOCK)
				  INNER JOIN  dbo.CLI_CLIENTES B WITH(NOLOCK) ON A.CODIGOCLIENTE = B.CODIGOCLIENTE AND B.CODIGOCLIENTE = @P_CODIGO_CLIENTE AND B.TZ_LOCK = 0				      
				 WHERE A.TZ_LOCK = 0 
				
				-- Busco persona con mayor venta				 
				SELECT TOP 1 @NUMEROPERSONA = ID_PERSONA
				FROM CRE_TAM_EMP_BALANCE a WITH(NOLOCK)
				INNER JOIN CLI_CLIENTEPERSONA cp WITH(NOLOCK) ON a.ID_PERSONA = cp.NUMEROPERSONA AND cp.TITULARIDAD = ''T'' AND cp.TZ_LOCK = 0
				INNER JOIN CLI_GRUPOSECONOMICOSCLIENTE g WITH(NOLOCK) ON cp.CODIGOCLIENTE = g.CODIGOCLIENTE AND g.TZ_LOCK = 0 AND g.CODIGOGRUPOECONOMICO = @COD_GRUPO_ECONOMICO
				where a.f_inicio IN (SELECT top 1 f_inicio 
								FROM CRE_TAM_EMP_BALANCE b WITH(NOLOCK)
								WHERE b.DOCUMENTO = a.DOCUMENTO
								AND b.TIPO_DOCUMENTO = a.TIPO_DOCUMENTO
								AND b.TZ_LOCK = 0
								ORDER BY b.f_inicio DESC) 
				ORDER BY a.TOTAL_VENTAS	DESC	 
				
				-- Obtengo Actividad AFIP
				SELECT TOP 1 @CODIGO_ACT_AFIP = CODIGO_ACTIVIDAD FROM CLI_ACTIVIDAD_ECONOMICA WITH(NOLOCK)
				WHERE CODIGO_PERSONA_CLIENTE = @NUMEROPERSONA 
				AND TZ_LOCK = 0
				AND ORDEN_AFIP IN (SELECT TOP 1 ORDEN_AFIP FROM CLI_ACTIVIDAD_ECONOMICA WITH(NOLOCK)
									WHERE CODIGO_PERSONA_CLIENTE = @NUMEROPERSONA
									AND TZ_LOCK = 0
									ORDER BY ORDEN_AFIP)	
				
				-- Obtengo total de ventas de todo el grupo				
				SELECT @PROM_TOTAL_VENTAS = sum (a.total_ventas)
				FROM CRE_TAM_EMP_BALANCE a WITH(NOLOCK)
				INNER JOIN CLI_CLIENTEPERSONA cp WITH(NOLOCK) ON a.ID_PERSONA = cp.NUMEROPERSONA AND cp.TITULARIDAD = ''T'' AND cp.TZ_LOCK = 0
				INNER JOIN CLI_GRUPOSECONOMICOSCLIENTE g WITH(NOLOCK) ON cp.CODIGOCLIENTE = g.CODIGOCLIENTE AND g.TZ_LOCK = 0 AND g.CODIGOGRUPOECONOMICO = @COD_GRUPO_ECONOMICO
				where a.f_inicio IN (SELECT top 1 f_inicio 
								FROM CRE_TAM_EMP_BALANCE b WITH(NOLOCK)
								WHERE b.DOCUMENTO = a.DOCUMENTO
								AND b.TIPO_DOCUMENTO = a.TIPO_DOCUMENTO
								AND b.TZ_LOCK = 0
								ORDER BY b.f_inicio DESC) 
								
				-- Obtengo el personal Ocupado de todo el grupo				
				SELECT @PROM_PERSONAL_OCUPADO = sum (a.PERSONAL_OCUPADO)
				FROM CRE_TAM_EMP_BALANCE a WITH(NOLOCK)
				INNER JOIN CLI_CLIENTEPERSONA cp WITH(NOLOCK) ON a.ID_PERSONA = cp.NUMEROPERSONA AND cp.TITULARIDAD = ''T'' AND cp.TZ_LOCK = 0
				INNER JOIN CLI_GRUPOSECONOMICOSCLIENTE g WITH(NOLOCK) ON cp.CODIGOCLIENTE = g.CODIGOCLIENTE AND g.TZ_LOCK = 0 AND g.CODIGOGRUPOECONOMICO = @COD_GRUPO_ECONOMICO
				where a.f_inicio IN (SELECT top 1 f_inicio 
								FROM CRE_TAM_EMP_BALANCE b WITH(NOLOCK)
								WHERE b.DOCUMENTO = a.DOCUMENTO
								AND b.TIPO_DOCUMENTO = a.TIPO_DOCUMENTO
								AND b.TZ_LOCK = 0
								ORDER BY b.f_inicio DESC)  
								
				-- Obtengo el valor activo total de todo el grupo				
				SELECT @ULTIMO_VALOR_ACTIVO = sum (a.VALOR_ACTIVO)
				FROM CRE_TAM_EMP_BALANCE a WITH(NOLOCK)
				INNER JOIN CLI_CLIENTEPERSONA cp WITH(NOLOCK) ON a.ID_PERSONA = cp.NUMEROPERSONA AND cp.TITULARIDAD = ''T'' AND cp.TZ_LOCK = 0
				INNER JOIN CLI_GRUPOSECONOMICOSCLIENTE g WITH(NOLOCK) ON cp.CODIGOCLIENTE = g.CODIGOCLIENTE AND g.TZ_LOCK = 0 AND g.CODIGOGRUPOECONOMICO = @COD_GRUPO_ECONOMICO
				where a.f_inicio IN (SELECT top 1 f_inicio 
								FROM CRE_TAM_EMP_BALANCE b WITH(NOLOCK)
								WHERE b.DOCUMENTO = a.DOCUMENTO
								AND b.TIPO_DOCUMENTO = a.TIPO_DOCUMENTO
								AND b.TZ_LOCK = 0
								ORDER BY b.f_inicio DESC)																															 
			END		
		
       --analiza valores cod actividad                                                  
       SELECT @AnalizaVentas = CASE WHEN EXISTS (
       
            SELECT cat_por_vta 
              FROM CLI_Cod_Act_AFIP WITH(NOLOCK)
             WHERE CODIGO_ACT_AFIP = @CODIGO_ACT_AFIP
               AND cat_por_vta = ''N''
               
            )
         THEN CAST(0 AS BIT) 
         ELSE CAST(1 AS BIT) END     
       
       
        SELECT @AnalizaPersonal = CASE WHEN EXISTS (
       
            SELECT cat_por_per 
              FROM CLI_Cod_Act_AFIP WITH(NOLOCK)
             WHERE CODIGO_ACT_AFIP = @CODIGO_ACT_AFIP
               AND cat_por_per = ''N''
               
            )
         THEN CAST(0 AS BIT) 
         ELSE CAST(1 AS BIT) end 
         
         SELECT @AnalisaValActivo = CASE WHEN EXISTS (
       
            SELECT cat_por_act 
              FROM CLI_Cod_Act_AFIP WITH(NOLOCK)
             WHERE CODIGO_ACT_AFIP = @CODIGO_ACT_AFIP
               AND cat_por_act = ''N''
               
            )
         THEN CAST(0 AS BIT) 
         ELSE CAST(1 AS BIT) end                                            
       
		-- Analizo si alguno de los integrantes del Grupo tiene como tamaño Gran Empresa (G)       
        IF (@TIENE_GRUPO_ECONOMICO <> 0)                  
         
         BEGIN
          
          DECLARE 
            @V_TAMANIO VARCHAR(3) = NULL
			
			SELECT TOP 1 @V_TAMANIO = B.TAM_ACTUAL 
			  FROM CRE_TAM_EMP_BITACORA B WITH(NOLOCK)
			 WHERE B.CLIENTE IN (SELECT a.CODIGOCLIENTE
								 FROM CLI_GRUPOSECONOMICOSCLIENTE A WITH(NOLOCK)
								 WHERE A.CODIGOGRUPOECONOMICO = @COD_GRUPO_ECONOMICO AND A.TZ_LOCK = 0)
			   AND b.TAM_ACTUAL = ''G''
			   ORDER BY B.JTS_BITACORA DESC			
			        
         END         
        
        IF (@TIENE_GRUPO_ECONOMICO = 0)
        DECLARE 
        
          @TIENE_CERTIFICADO_MIPYME NUMERIC (2)
        
        BEGIN 
                        
            	SELECT @TIENE_CERTIFICADO_MIPYME = count(a.NRO_REGISTRO)
            	  FROM CRE_TAM_EMP_CER_MIPYMES A WITH(NOLOCK)
				 WHERE A.CUIT = @P_CUIT
				   AND A.TZ_LOCK = 0
				   AND A.F_INICIO + a.PLAZO_VIGENCIA > @FECHA_PROCESO
				   AND A.ESTADO = ''V''
				            	
                	SELECT @P_NRO_REGISTRO = a.NRO_REGISTRO
				  FROM CRE_TAM_EMP_CER_MIPYMES A WITH(NOLOCK)
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
				  FROM CRE_TAM_EMP_CER_MIPYMES A WITH(NOLOCK),
     				   OPCIONES b WITH(NOLOCK)
				 WHERE a.CATEGORIA = b.OPCIONINTERNA
				   AND b.NUMERODECAMPO = 43106
				   AND b.IDIOMA = ''E''
				   AND A.TZ_LOCK = 0
				   AND A.CUIT = @P_CUIT
				   AND A.F_INICIO + a.PLAZO_VIGENCIA > @FECHA_PROCESO
				   AND A.ESTADO = ''V''
                      
          END                  
               
      BEGIN
      
        ----------------------------------------------
     
     BEGIN
     
   --mz   IF @AnalizaVentas = 0 AND @AnalizaPersonal = 0 AND @AnalisaValActivo = 0
       
       BEGIN
       --VALIDACION 1
        
        IF (@TIENE_BALANCE = 0) AND (@ANTIGUEDAD > 540) AND (@VALIDACION IS NULL) AND (@TIENE_GRUPO_ECONOMICO = 0) AND (@TIENE_CERTIFICADO_MIPYME = 0)
       
       
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
      IF @ANTIGUEDAD < 540 AND (@TIENE_GRUPO_ECONOMICO = 0) AND (@TIENE_CERTIFICADO_MIPYME = 0)
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
		             FROM CRE_TAM_EMP_VTAS a WITH(NOLOCK),
		                  OPCIONES b WITH(NOLOCK)
					WHERE a.TAMANIO = b.OPCIONINTERNA
					  AND b.DESCRIPCION IS NOT NULL
					  AND b.NUMERODECAMPO = 44003
					  AND a.SECTOR = (SELECT codigo_sector 
					                    FROM CLI_Cod_Act_AFIP WITH(NOLOCK)
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
		                  FROM CRE_TAM_EMP_PERS a WITH(NOLOCK),
		                       OPCIONES b WITH(NOLOCK)
						 WHERE a.TAMANIO = b.OPCIONINTERNA
						   AND b.DESCRIPCION IS NOT NULL
						   AND b.NUMERODECAMPO = 43303
						   AND a.SECTOR = (SELECT codigo_sector 
						                    FROM CLI_Cod_Act_AFIP WITH(NOLOCK)
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
                         FROM CRE_PARAMETROS WITH(NOLOCK)
						WHERE CODIGO = 500
						  AND @ULTIMO_VALOR_ACTIVO <= importe  
						  AND TZ_LOCK = 0 
						  
						  
					
						 IF @cantidad <> 0  
						  
						  BEGIN
						  
						   SELECT TOP 1 @TAMANIO = b.OPCIONINTERNA 
				             FROM CRE_TAM_EMP_VTAS a WITH(NOLOCK),
				                  OPCIONES b WITH(NOLOCK)
							WHERE a.TAMANIO = b.OPCIONINTERNA
							  AND b.DESCRIPCION IS NOT NULL
							  AND b.NUMERODECAMPO = 44003
							  AND a.SECTOR = (SELECT codigo_sector 
							                    FROM CLI_Cod_Act_AFIP WITH(NOLOCK) 
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


            IF (@exceptionidentifier LIKE N''SQL-00100%'')
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
EXECUTE('

IF OBJECT_ID (''SP_CALCULA_ADELANTO'') IS NOT NULL
	DROP  PROCEDURE SP_CALCULA_ADELANTO
')
EXECUTE('

CREATE PROCEDURE dbo.SP_CALCULA_ADELANTO
   @P_SOLICITUD numeric(15),
   @P_CLIENTE numeric(15),
   @P_DOCUMENTO varchar(20)
AS 
   BEGIN

      DECLARE
         @V_MONTO_CALCULADO NUMERIC(15,2) = 0,
         @V_MONTO_SUELDO NUMERIC(15,2) = 0,
         @V_MONTO_SINEQUIV NUMERIC(15,2) = 0, 
         @V_MONTO_TARJETA NUMERIC(15,2) = 0, 
         @V_MONTO_CONEQUIV NUMERIC(15,2) = 0,
         @V_MONTO_MISMOPROD NUMERIC(15,2) = 0,
         @V_SUBTOTAL NUMERIC(15,2) = 0,
         @V_CAPACIDAD NUMERIC(15,2) = 0,
         @V_COEFICIENTE NUMERIC(11,7) = 0

      BEGIN
      
      	 DELETE FROM CRE_AUX_SOL_CALCULO_ADELANTO WHERE NUMERO_SOLICITUD = 0 AND CLIENTE = @P_CLIENTE
      
         DECLARE
         @LINEA_REG$PRODUCTO numeric(5), 
         @LINEA_REG$CONVENIO numeric(15),         
         @LINEA_REG$JTS_SALDO numeric(15),
         @LINEA_REG$CANT_SUELDO INT,
         @LINEA_REG$JURISDICCION varchar(20),
         @LINEA_REG$TIPO_SCORING numeric(1),
         @LINEA_REG$AFECTACION numeric(5,2),
         @LINEA_REG$AFECTACIONCANAL numeric(5,2),
         @LINEA_REG$CANAL varchar(20)
         
         /*
         *   -----------------------------
         *    CURSOR REGISTROS obtengo productos
         *   -----------------------------
         */
         
         DECLARE
             CUR_REGISTROS CURSOR LOCAL FOR 
               SELECT DISTINCT Producto, Convenio, JTS_OID, CantidadSueldo, Jurisdiccion, Canal, TipoScoring, Afectacion, AfectacionCanal FROM VW_PRODUCTOS_CONVENIOS_AH WHERE Cliente = @P_CLIENTE

         OPEN CUR_REGISTROS

         WHILE 1 = 1
         
            BEGIN

               /*Lotes*/
               FETCH CUR_REGISTROS
                   INTO 
			         @LINEA_REG$PRODUCTO, 
			         @LINEA_REG$CONVENIO,
			         @LINEA_REG$JTS_SALDO,
			         @LINEA_REG$CANT_SUELDO,
			         @LINEA_REG$JURISDICCION,
			         @LINEA_REG$CANAL,
			         @LINEA_REG$TIPO_SCORING,
			         @LINEA_REG$AFECTACION,
			         @LINEA_REG$AFECTACIONCANAL
			         
               IF @@FETCH_STATUS <> 0
               	BREAK
               	
               	SET @V_MONTO_SUELDO = 0
               	SET @V_MONTO_SINEQUIV = 0
               	SET @V_MONTO_CONEQUIV = 0
               	SET @V_SUBTOTAL = 0
               	SET @V_MONTO_CALCULADO = 0
               	SET @V_MONTO_MISMOPROD = 0
                  
                IF @LINEA_REG$TIPO_SCORING = 4
                	BEGIN
                		SELECT @V_MONTO_CALCULADO = isnull(MONTO_MAXIMO,0) FROM CRE_SCORINGPORLISTA WHERE PRODUCTO = @LINEA_REG$PRODUCTO AND CONVENIO = @LINEA_REG$CONVENIO 
                		AND JURISDICCION = @LINEA_REG$JURISDICCION AND CUIT = @P_DOCUMENTO AND TZ_LOCK = 0
                		
                		SET @V_CAPACIDAD = @V_MONTO_CALCULADO
                	END
                IF @LINEA_REG$TIPO_SCORING IN (0,1)
                	BEGIN
                		SELECT @V_MONTO_SUELDO = isnull(round(avg(t.MONTO),2),0)
						FROM (SELECT TOP (@LINEA_REG$CANT_SUELDO) *
								FROM CRE_SOL_ACREDITACIONES_SUELDOS WHERE TIPO = ''S'' AND SALDO_JTS_OID = @LINEA_REG$JTS_SALDO AND CONVENIO = @LINEA_REG$CONVENIO
								AND ID_JURISDICCION = @LINEA_REG$JURISDICCION AND TZ_LOCK = 0
								ORDER BY FECHA DESC) t
                		
						SELECT @V_MONTO_SINEQUIV = isnull(sum(s.C1612),0)
						FROM SALDOS s
						WHERE s.C1785 IN (5,6) AND s.TZ_LOCK = 0 AND s.C1604 < 0 AND s.PRODUCTO <> @LINEA_REG$PRODUCTO
						AND s.C1803 IN (SELECT C1803 FROM SALDOS WHERE JTS_OID = @LINEA_REG$JTS_SALDO AND TZ_LOCK = 0) 
						AND s.PRODUCTO IN (SELECT C6250 FROM PRODUCTOS WHERE TZ_LOCK = 0 AND C6800 <> ''AH'')
						
						SELECT @V_MONTO_TARJETA = isnull(sum(s.C1832 - s.AJUSTEINFLACION),0)
						FROM SALDOS s
						WHERE s.C1785 = 1 AND s.TZ_LOCK = 0
						AND s.C1803 IN (SELECT C1803 FROM SALDOS WHERE JTS_OID = @LINEA_REG$JTS_SALDO AND TZ_LOCK = 0) 
						AND s.PRODUCTO IN (SELECT C6250 FROM PRODUCTOS WHERE TZ_LOCK = 0 AND C6800 = ''T'')  
						AND s.C1832 - s.AJUSTEINFLACION < s.C1685						 
						
						SET @V_SUBTOTAL = (@V_MONTO_SUELDO - @V_MONTO_SINEQUIV - @V_MONTO_TARJETA) * @LINEA_REG$AFECTACION / 100
						SET @V_SUBTOTAL = @V_SUBTOTAL * @LINEA_REG$AFECTACIONCANAL / 100
						
						SELECT @V_MONTO_CONEQUIV = isnull(sum(s.C1612),0)
						FROM SALDOS s
						WHERE s.C1785 IN (5,6) AND s.TZ_LOCK = 0 AND s.C1604 < 0 AND s.PRODUCTO <> @LINEA_REG$PRODUCTO
						AND s.C1803 IN (SELECT C1803 FROM SALDOS WHERE JTS_OID = @LINEA_REG$JTS_SALDO AND TZ_LOCK = 0) 
						AND s.PRODUCTO IN (SELECT PRODUCTO_EQUIVALENTE FROM CRE_PRODUCTOSEQUIVALENTES WHERE PRODUCTO = @LINEA_REG$PRODUCTO AND EQUIV_SCORING = ''S'' AND TZ_LOCK = 0)
						
						SELECT @V_MONTO_MISMOPROD = isnull(sum(s.C1612),0)
						FROM SALDOS s
						WHERE s.C1785 IN (5,6) AND s.TZ_LOCK = 0 AND s.C1604 < 0 AND s.PRODUCTO = @LINEA_REG$PRODUCTO
						AND s.C1803 IN (SELECT C1803 FROM SALDOS WHERE JTS_OID = @LINEA_REG$JTS_SALDO) 						
												
						IF @LINEA_REG$TIPO_SCORING = 0	 
							BEGIN			
								SET @V_MONTO_CALCULADO = @V_SUBTOTAL - @V_MONTO_CONEQUIV - @V_MONTO_MISMOPROD
								SET @V_CAPACIDAD = @V_MONTO_CALCULADO
							END		 
						ELSE
							BEGIN		   
								SELECT TOP (1) @V_COEFICIENTE = isnull(COEFICIENTE,0) FROM CRE_SCORINGPORCUOTAS WHERE PRODUCTO = @LINEA_REG$PRODUCTO AND TZ_LOCK = 0 ORDER BY CANTIDAD_CUOTAS DESC	
								
								SET @V_MONTO_CALCULADO = (@V_SUBTOTAL - @V_MONTO_CONEQUIV - @V_MONTO_MISMOPROD) * @V_COEFICIENTE 
								SET @V_CAPACIDAD = @V_SUBTOTAL - @V_MONTO_CONEQUIV - @V_MONTO_MISMOPROD
							END								                		
                	END                
                IF @LINEA_REG$TIPO_SCORING = 2
                	BEGIN
                		SELECT @V_MONTO_SUELDO = isnull(round(avg(t.MONTO),2),0)
						FROM (SELECT TOP (@LINEA_REG$CANT_SUELDO) *
								FROM CRE_SOL_ACREDITACIONES_SUELDOS WHERE TIPO = ''A'' AND SALDO_JTS_OID = @LINEA_REG$JTS_SALDO AND CONVENIO = @LINEA_REG$CONVENIO
								AND ID_JURISDICCION = @LINEA_REG$JURISDICCION AND TZ_LOCK = 0
								ORDER BY FECHA DESC) t
                		
                		SET @V_SUBTOTAL = @V_MONTO_SUELDO * @LINEA_REG$AFECTACION / 100
                		SET @V_SUBTOTAL = @V_SUBTOTAL * @LINEA_REG$AFECTACIONCANAL / 100
                		
						SELECT @V_MONTO_CONEQUIV = isnull(sum(s.C1612),0)
						FROM SALDOS s
						WHERE s.C1785 IN (5,6) AND s.TZ_LOCK = 0 AND s.C1604 < 0 AND s.PRODUCTO <> @LINEA_REG$PRODUCTO
						AND s.C1803 IN (SELECT C1803 FROM SALDOS WHERE JTS_OID = @LINEA_REG$JTS_SALDO AND TZ_LOCK = 0) 						
						AND s.PRODUCTO IN (SELECT PRODUCTO_EQUIVALENTE FROM CRE_PRODUCTOSEQUIVALENTES WHERE PRODUCTO = @LINEA_REG$PRODUCTO AND EQUIV_SCORING = ''S'' AND TZ_LOCK = 0)                		
                		
						SELECT @V_MONTO_MISMOPROD = isnull(sum(s.C1612),0)
						FROM SALDOS s
						WHERE s.C1785 IN (5,6) AND s.TZ_LOCK = 0 AND s.C1604 < 0 AND s.PRODUCTO = @LINEA_REG$PRODUCTO
						AND s.C1803 IN (SELECT C1803 FROM SALDOS WHERE JTS_OID = @LINEA_REG$JTS_SALDO AND TZ_LOCK = 0) 	
						                		
                		SET @V_MONTO_CALCULADO = @V_SUBTOTAL - @V_MONTO_CONEQUIV - @V_MONTO_MISMOPROD
                		
                		SET @V_CAPACIDAD = @V_MONTO_CALCULADO
                	END 
                IF @LINEA_REG$TIPO_SCORING = 3  
                	BEGIN  
                		SET @V_MONTO_CALCULADO = 0 
                		SET @V_CAPACIDAD = @V_MONTO_CALCULADO    
                	END                	                      
				
				IF @V_MONTO_CALCULADO < 0
					SET @V_MONTO_CALCULADO = 0
					
				IF @V_CAPACIDAD < 0
					SET @V_CAPACIDAD = 0
										
                INSERT INTO dbo.CRE_AUX_SOL_CALCULO_ADELANTO (NUMERO_SOLICITUD, CLIENTE, PRODUCTO, CONVENIO, ID_JURIDICCION, CANAL, MONTO_CALCULADO, CAPACIDAD_PAGO, TZ_LOCK)
				VALUES (0, @P_CLIENTE, @LINEA_REG$PRODUCTO, @LINEA_REG$CONVENIO, @LINEA_REG$JURISDICCION, @LINEA_REG$CANAL, @V_MONTO_CALCULADO, @V_CAPACIDAD, 0)     

            END

         CLOSE CUR_REGISTROS

         DEALLOCATE CUR_REGISTROS

      END

   END
')
EXECUTE('

IF OBJECT_ID (''SP_CASTIGOCARTERA'') IS NOT NULL
	DROP  PROCEDURE SP_CASTIGOCARTERA

')
EXECUTE('
CREATE PROCEDURE dbo.SP_CASTIGOCARTERA
   @P_NUMEROCASTIGO numeric(10)
AS 
	BEGIN            	 
      
      INSERT INTO dbo.CRE_DET_CASTIGOCARTERA (NUMERO_LISTA, CLIENTE, ESTADO, TZ_LOCK)
      SELECT @P_NUMEROCASTIGO, CODIGOCLIENTE, ''A'', 0
      FROM VW_CLI_X_DOC WITH(NOLOCK)
      WHERE CODIGOCLIENTE IN (SELECT Cliente FROM VW_CASTIGOCARTERA WHERE Cliente NOT IN (SELECT CLIENTE FROM CRE_DET_CASTIGOCARTERA WHERE TZ_LOCK=0 AND NUMERO_LISTA IN (SELECT NUMERO_LISTA FROM CRE_CAB_CASTIGOCARTERA WHERE ESTADO IN (''I'',''C'') AND TZ_LOCK=0)))

    END
')
EXECUTE('

IF OBJECT_ID (''SP_CATEGORIZACION'') IS NOT NULL
	DROP  PROCEDURE SP_CATEGORIZACION
')
EXECUTE('
CREATE PROCEDURE dbo.[SP_CATEGORIZACION]
@p_id_proceso FLOAT(53),     /* Identificador de proceso */
@p_dt_proceso DATETIME,   /* Fecha de proceso */
@p_ret_proceso FLOAT OUT, /* Estado de ejecucion del PL/SQL(0:Correcto, 2: Error) */
@p_msg_proceso VARCHAR(MAX) OUT
AS
BEGIN
	DECLARE 
	------- Campos para el LOG --------
	@c_log_tipo_error varchar(30),
	@c_log_tipo_informacion VARCHAR(30),
	-----------------------------------
	@numcli NUMERIC(12), -- numero de cliente
	@categoriacliente VARCHAR(1),
	@maxcategoria VARCHAR(1),
	@catnueva VARCHAR(1),
	@contador NUMERIC(10),
	@f_proceso DATE;
	
	SET @contador = 0;
	------- Campos para el LOG --------
	SET @c_log_tipo_error = ''E'';
	SET @c_log_tipo_informacion = ''I'';
	-----------------------------------	

	BEGIN TRY
		SET @f_proceso =(SELECT FECHAPROCESO FROM PARAMETROS with (nolock));
		
		DELETE FROM CRE_CATEGORIA_COMERCIAL_BITACORA WHERE F_PROCESO=  @f_proceso;

		DECLARE cursor1 CURSOR FOR 
			SELECT CODIGOCLIENTE, CATEGORIA_COMERCIAL, MAX(CATEGORIA)  FROM(
			SELECT  C.CODIGOCLIENTE,  C.CATEGORIA_COMERCIAL,
					CASE L.CATEGORIA_COMERCIAL 
						 WHEN ''C'' THEN 1
			        	 WHEN ''S'' THEN 2
			        	 WHEN ''M'' THEN 3
			        	 ELSE '' ''
			    	END AS CATEGORIA 
			FROM CLI_CLIENTES C WITH (nolock)
			JOIN CRE_LIMITECLIENTE L ON C.CODIGOCLIENTE = L.CLIENTE AND PLAZO > @f_proceso AND L.ESTADO=''A'' 
			WHERE (C.TZ_LOCK = 0 AND L.TZ_LOCK = 0)
			UNION ALL
			SELECT  C.CODIGOCLIENTE,   C.CATEGORIA_COMERCIAL,
					CASE VTA.CATEGORIA_COMERCIAL 
						 WHEN ''C'' THEN 1
			        	 WHEN ''S'' THEN 2
			        	 WHEN ''M'' THEN 3
			        	 ELSE '' ''
			    	END AS CATEGORIA 
			FROM CLI_CLIENTES C WITH (nolock)
			JOIN SALDOS S ON C.CODIGOCLIENTE = S.C1803 AND S.C1785= 2 
			JOIN VTA_SOBREGIROS VTA ON S.JTS_OID = VTA.JTS_OID_SALDO AND VTA.FECHA_VENCIMIENTO > @f_proceso 
			WHERE (C.TZ_LOCK = 0 AND VTA.TZ_LOCK = 0)
			UNION ALL
			SELECT  C.CODIGOCLIENTE,  C.CATEGORIA_COMERCIAL,
					CASE CRE.CATEGORIA_COMERCIAL 
						 WHEN ''C'' THEN 1
			        	 WHEN ''S'' THEN 2
			        	 WHEN ''M'' THEN 3
			        	 ELSE '' ''
			    	END AS CATEGORIA 
			FROM CLI_CLIENTES C WITH (nolock)
			JOIN SALDOS S ON C.CODIGOCLIENTE = S.C1803 AND (S.C1785= 5 OR S.C1785= 6) AND S.C1604<0
			JOIN CRE_SALDOS CRE ON S.JTS_OID = CRE.SALDOS_JTS_OID 
			WHERE (C.TZ_LOCK = 0 AND CRE.TZ_LOCK = 0)
			) AS SUBQUERY GROUP BY CODIGOCLIENTE, CATEGORIA_COMERCIAL

	OPEN cursor1 
	FETCH NEXT FROM cursor1 INTO @numcli,  @categoriacliente,  @maxcategoria
	
	WHILE @@FETCH_STATUS = 0  
	BEGIN  
	  	  
	   	  SET @catnueva = CASE @maxcategoria
	                       WHEN 1 THEN ''C''
	        	 		   WHEN 2 THEN ''S''
	        	 		   WHEN 3 THEN ''M''
	        	 		   ELSE '' ''
	                  	  END 
	                  
	                  	  
	      PRINT ''Numero Cliente:'' + CAST(@numcli AS VARCHAR) 
	   	  PRINT ''Categoria Actual:'' + @categoriacliente            	  
	      PRINT ''Nueva Categoria:'' + @catnueva   
	                	  
	      INSERT INTO dbo.CRE_CATEGORIA_COMERCIAL_BITACORA (COD_CLIENTE, F_PROCESO, CATEG_ANTERIOR, CATEG_NUEVA, TZ_LOCK)
		  VALUES (@numcli, @f_proceso, @categoriacliente, @catnueva, 0)
	      
	      UPDATE dbo.CLI_CLIENTES
		  SET CATEGORIA_COMERCIAL = @catnueva
		  WHERE CODIGOCLIENTE = @numcli
		 	      
	      
	      SET @contador=@contador+1
	       
	       
	             
	      FETCH NEXT FROM cursor1 INTO @numcli, @categoriacliente, @maxcategoria
	END 
	
	CLOSE cursor1  
	DEALLOCATE cursor1 
	
	
		    SET @p_msg_proceso = ''El Proceso de Cateorización de Clientes ha finalizado correctamente. Registros procesados: ''+ CONVERT(VARCHAR(10), @contador)
			SET @p_ret_proceso = 1 		
			
			-- Logueo de información
			EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso 
				@p_id_proceso,
		    	@p_dt_proceso,
		    	''SP_CATEGORIZACION'',
		    	@p_cod_error = @p_ret_proceso, 
				@p_msg_error = @p_msg_proceso, 
				@p_tipo_error = @c_log_tipo_informacion
		END TRY
							             
		BEGIN CATCH
	
	        SET @p_ret_proceso = ERROR_NUMBER()
	        SET @p_msg_proceso = ''Ocurrió un error en el Proceso de Cateorización de Clientes: '' + ERROR_MESSAGE()
	
			EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso 
	        	@p_id_proceso = @p_id_proceso, 
	        	@p_fch_proceso = @p_dt_proceso, 
	        	@p_nom_package = ''SP_CATEGORIZACION'', 
	        	@p_cod_error = @p_ret_proceso, 
	        	@p_msg_error = @p_msg_proceso, 
	       		@p_tipo_error = @c_log_tipo_informacion
		END CATCH
END
')
EXECUTE('
IF OBJECT_ID (''SP_RIESGOSENDOL'') IS NOT NULL
	DROP  PROCEDURE SP_RIESGOSENDOL
')
EXECUTE('
CREATE   PROCEDURE [dbo].[SP_RIESGOSENDOL]
	@p_id_proceso FLOAT(53),     /* Identificador de proceso */
	@p_dt_proceso DATETIME,   /* Fecha de proceso */
	@p_ret_proceso FLOAT OUT, /* Estado de ejecucion SQL(0:Correcto, 2: Error) */
	@p_msg_proceso VARCHAR(MAX) OUT
AS
BEGIN
	DECLARE 
	------- Campos para el LOG --------
	@c_log_tipo_error varchar(30),
	@c_log_tipo_informacion VARCHAR(30),
	-----------------------------------
	@cot_dolares NUMERIC(15,9); -- cotizacion dolares del dia
   
	
	------- Campos para el LOG --------
	SET @c_log_tipo_error = ''E'';
	SET @c_log_tipo_informacion = ''I'';
	-----------------------------------	
	SET @cot_dolares = (SELECT TOP 1 C6440 FROM MONEDAS WITH(NOLOCK) WHERE C6403=''D'' AND TZ_LOCK=0);

	BEGIN TRY
        	  
			UPDATE r
					SET MONTO=(MONTODOL*@cot_dolares)
					FROM CRE_RIESGOLIC r WITH(NOLOCK) INNER JOIN CRE_LIMITECLIENTE c 
					ON c.IDLIMITE=r.IDLIMITE WHERE c.TZ_LOCK=0 AND r.TZ_LOCK=0 AND
 					MONTODOL>0 AND c.ESTADO =''A''
		  
		   			
			UPDATE f
					SET MONTO=(MONTODOL*@cot_dolares) 	
					FROM CRE_FAMILIALIC f WITH(NOLOCK) INNER JOIN CRE_LIMITECLIENTE c 
					ON c.IDLIMITE=f.IDLIMITE WHERE c.TZ_LOCK=0 AND f.TZ_LOCK=0 AND
 					MONTODOL>0 AND c.ESTADO =''A''	

			UPDATE p
					SET MONTO=(MONTODOL*@cot_dolares)
					FROM CRE_PRODUCTOLIC p WITH(NOLOCK) INNER JOIN CRE_LIMITECLIENTE c WITH(NOLOCK)
					ON c.IDLIMITE=p.IDLIMITE WHERE c.TZ_LOCK=0 AND p.TZ_LOCK=0 AND
 					MONTODOL>0 AND c.ESTADO =''A''
		  
		    SET @p_msg_proceso = ''El Proceso ha finalizado correctamente. ''
			SET @p_ret_proceso = 1 		
			
			-- Logueo de información
			EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso 
				@p_id_proceso,
		    	@p_dt_proceso,
		    	''SP_RIESGOENDOL'',
		    	@p_cod_error = @p_ret_proceso, 
				@p_msg_error = @p_msg_proceso, 
				@p_tipo_error = @c_log_tipo_informacion
	END TRY
							             
	BEGIN CATCH
	
	        SET @p_ret_proceso = ERROR_NUMBER()
	        SET @p_msg_proceso = ''Ocurrió un error en el Proceso: '' + ERROR_MESSAGE()
	
			EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso 
	        	@p_id_proceso = @p_id_proceso, 
	        	@p_fch_proceso = @p_dt_proceso, 
	        	@p_nom_package = ''SP_RIESGOENDOL'', 
	        	@p_cod_error = @p_ret_proceso, 
	        	@p_msg_error = @p_msg_proceso, 
	       		@p_tipo_error = @c_log_tipo_informacion
		END CATCH
END
')
EXECUTE('
IF OBJECT_ID (''SP_RIESGOCLIENTEENDOL'') IS NOT NULL
	DROP  PROCEDURE SP_RIESGOCLIENTEENDOL
')
EXECUTE('
CREATE   PROCEDURE [dbo].[SP_RIESGOCLIENTEENDOL]
	@p_id_proceso FLOAT(53),     /* Identificador de proceso */
	@p_dt_proceso DATETIME,   /* Fecha de proceso */
	@p_ret_proceso FLOAT OUT, /* Estado de ejecucion SQL(0:Correcto, 2: Error) */
	@p_msg_proceso VARCHAR(MAX) OUT
AS
BEGIN
	DECLARE 
	------- Campos para el LOG --------
	@c_log_tipo_error varchar(30),
	@c_log_tipo_informacion VARCHAR(30);
	-----------------------------------
	
	------- Campos para el LOG --------
	SET @c_log_tipo_error = ''E'';
	SET @c_log_tipo_informacion = ''I'';
	-----------------------------------	

	BEGIN TRY
        	-- una vez finalizado el  SP_RIESGOSENDOL, y para los clientes que tengan almenos un riesgo, familia o producto "dolarizado"
        	-- se actualiza el limite del cliente con la suma de todos sus riesgos
        	-- 
			UPDATE c 
				SET MONTO=(SELECT SUM(MONTO) FROM CRE_RIESGOLIC r WITH(NOLOCK) WHERE TZ_LOCK=0 AND r.IDLIMITE=c.IDLIMITE)
		  			FROM CRE_LIMITECLIENTE c WITH(NOLOCK) 
					WHERE c.TZ_LOCK= 0 AND c.ESTADO =''A'' AND 
							(c.IDLIMITE IN(SELECT IDLIMITE FROM CRE_RIESGOLIC WITH(NOLOCK) WHERE TZ_LOCK=0 AND MONTODOL>0) 
									OR IDLIMITE IN(SELECT IDLIMITE FROM CRE_FAMILIALIC WITH(NOLOCK) WHERE TZ_LOCK=0 AND MONTODOL>0)
										OR IDLIMITE IN(SELECT IDLIMITE FROM CRE_PRODUCTOLIC WITH(NOLOCK) WHERE TZ_LOCK=0 AND MONTODOL>0)
							)
		    SET @p_msg_proceso = ''El Proceso ha finalizado correctamente. ''
			SET @p_ret_proceso = 1 		
			
			-- Logueo de información
			EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso 
				@p_id_proceso,
		    	@p_dt_proceso,
		    	''SP_RIESGOCLIENTEENDOL'',
		    	@p_cod_error = @p_ret_proceso, 
				@p_msg_error = @p_msg_proceso, 
				@p_tipo_error = @c_log_tipo_informacion
	END TRY
							             
	BEGIN CATCH
	
	        SET @p_ret_proceso = ERROR_NUMBER()
	        SET @p_msg_proceso = ''Ocurrió un error en el Proceso: '' + ERROR_MESSAGE()
	
			EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso 
	        	@p_id_proceso = @p_id_proceso, 
	        	@p_fch_proceso = @p_dt_proceso, 
	        	@p_nom_package = ''SP_RIESGOCLIENTEENDOL'', 
	        	@p_cod_error = @p_ret_proceso, 
	        	@p_msg_error = @p_msg_proceso, 
	       		@p_tipo_error = @c_log_tipo_informacion
		END CATCH
END
')
EXECUTE('

IF OBJECT_ID (''SP_CESIONCARTERA'') IS NOT NULL
	DROP  PROCEDURE SP_CESIONCARTERA

')
EXECUTE('
CREATE PROCEDURE SP_CESIONCARTERA
   @P_NUMEROCESION numeric(10),
   @P_USAFAMILIA varchar(1),
   @P_FAMILIA numeric(12),
   @P_USAPRODUCTO varchar(1),
   @P_PRODUCTO numeric(5),
   @P_USASUCURSAL varchar(1),
   @P_SUCURSAL numeric(5),
   @P_USASITUACION varchar(1),
   @P_SITUACION varchar(3),      
   @P_USAGARANTIA varchar(1),
   @P_GARANTIA varchar(1),      
   @P_USATASA varchar(1), 
   @P_TASADESDE numeric(15,2),
   @P_TASAHASTA numeric(15,2),
   @P_USAPORCENTAJE varchar(1),
   @P_PORCENTAJEPAGO numeric(5,2),
   @P_USAVENCIMIENTO varchar(1),
   @P_VENCIMIENTO datetime
AS 
      BEGIN            	 
      
         DECLARE         
         @LINEA_REG$JTS_SALDO numeric(15)
         
         /*
         *   -----------------------------
         *    CURSOR REGISTROS obtengo productos
         *   -----------------------------
         */
         
         DECLARE
             CUR_REGISTROS CURSOR LOCAL FOR 
               SELECT a.JTS_OID 
               FROM VW_ASISTENCIAS a
               WHERE a.SALDO > 0 AND a.TIPO = 5 AND a.JTS_OID NOT IN (SELECT JTS_OID_ASISTENCIA FROM CRE_DET_CESIONCARTERA WHERE TZ_LOCK = 0 AND NUMERO_CESION NOT IN (SELECT NUMERO_CESION FROM CRE_CAB_CESIONCARTERA WHERE TZ_LOCK = 0 AND ESTADO IN (''I'',''C''))) AND
               ((a.FAMILIA = @P_FAMILIA AND @P_USAFAMILIA = ''S'') OR @P_USAFAMILIA = ''N'') AND
               ((a.PRODUCTO = @P_PRODUCTO AND @P_USAPRODUCTO = ''S'') OR @P_USAPRODUCTO = ''N'') AND
               ((a.SUCURSAL = @P_SUCURSAL AND @P_USASUCURSAL = ''S'') OR @P_USASUCURSAL = ''N'') AND
               ((a.SITUACION = @P_SITUACION AND @P_USASITUACION = ''S'') OR @P_USASITUACION = ''N'') AND
               ((a.GARANTIA_DESEMBOLSO = @P_GARANTIA AND @P_USAGARANTIA = ''S'') OR @P_USAGARANTIA = ''N'') AND
               ((a.TASA >= @P_TASADESDE AND a.TASA <= @P_TASAHASTA AND @P_USATASA = ''S'') OR @P_USATASA = ''N'') AND
               ((a.PORCENTAJE_PAGO >= @P_PORCENTAJEPAGO AND @P_USAPORCENTAJE = ''S'') OR @P_USAPORCENTAJE = ''N'') AND
               ((a.VENCIMIENTO >= CONVERT(datetime, @P_VENCIMIENTO, 103) AND @P_USAVENCIMIENTO = ''S'') OR @P_USAVENCIMIENTO = ''N'')
                              

         OPEN CUR_REGISTROS

         WHILE 1 = 1
         
            BEGIN

               FETCH CUR_REGISTROS
                   INTO 
		 	         @LINEA_REG$JTS_SALDO
		 	         
               IF @@FETCH_STATUS <> 0
               	BREAK
               	
               	INSERT INTO dbo.CRE_DET_CESIONCARTERA (NUMERO_CESION, JTS_OID_ASISTENCIA, ESTADO, TZ_LOCK)
				VALUES (@P_NUMEROCESION, @LINEA_REG$JTS_SALDO, ''A'', 0)
               	
            END

         CLOSE CUR_REGISTROS

         DEALLOCATE CUR_REGISTROS

      END


')
EXECUTE('
IF OBJECT_ID (''SP_VALIDO_PRESTAMOS_SPNF'') IS NOT NULL
	DROP  PROCEDURE SP_VALIDO_PRESTAMOS_SPNF

')
EXECUTE('
CREATE PROCEDURE SP_VALIDO_PRESTAMOS_SPNF
   @P_CLIENTE numeric(15),
   @P_SALIDA NUMERIC(1)
AS 
   BEGIN
   
   	  DECLARE @P_VIGENTES NUMERIC (3) = (SELECT DIASINMOVILIZADA FROM CRE_PARAMETROS WHERE CODIGO = 164)
   	  DECLARE @P_MESES NUMERIC (3) = (SELECT DIASINMOVILIZADA FROM CRE_PARAMETROS WHERE CODIGO = 163)
   	  DECLARE @P_DIASHABILES NUMERIC (3) = (SELECT DIASINMOVILIZADA FROM CRE_PARAMETROS WHERE CODIGO = 162)
   	  DECLARE @P_CANTVIVOS NUMERIC (3) = (SELECT count(*) FROM SALDOS WHERE C1604 < 0 AND TZ_LOCK = 0 AND C1785 = 5 AND C1803 = @P_CLIENTE AND PRODUCTO IN (SELECT C6250 FROM PRODUCTOS WHERE TZ_LOCK = 0 AND C6800 = ''SP''))
   	  DECLARE @P_CANTCANCELADOS NUMERIC (3) = 0
   
   	  SET @P_SALIDA = 0
   	  
   	  IF (@P_CANTVIVOS > 0)
   	  	SET @P_SALIDA = 1
   	  	
   	  IF (@P_SALIDA = 0)
   	  	BEGIN
   	  	
			SELECT @P_CANTCANCELADOS = count(*)
			FROM SALDOS 
			WHERE C1604 = 0 AND TZ_LOCK = 0 AND C1785 = 5 AND C1803 = @P_CLIENTE AND 
			PRODUCTO IN (SELECT C6250 FROM PRODUCTOS WHERE TZ_LOCK = 0 AND C6800 = ''SP'') AND
			C1621 >= (SELECT DATEADD(MONTH,-@P_MESES,FECHAPROCESO) FROM PARAMETROS) AND 
			C1629 > (SELECT dbo.sumarDiasHabiles (C1621, @P_DIASHABILES))   	  	
			
			IF (@P_CANTCANCELADOS > @P_VIGENTES)
				SET @P_SALIDA = 1
				
   	  	END
   END

')
EXECUTE('
IF OBJECT_ID (''sumarDiasHabiles'') IS NOT NULL
	DROP  FUNCTION sumarDiasHabiles


')
EXECUTE('
CREATE FUNCTION sumarDiasHabiles (@fch1 DATE, @dias NUMERIC(3)) RETURNS DATE
AS

BEGIN
	DECLARE @fchAux DATE = @fch1
	DECLARE @fchHabil DATE
	DECLARE @contador INT
	DECLARE @sumarizador NUMERIC(3) = 0
	
		
	WHILE @sumarizador < @dias+1
		BEGIN
			SET @contador = 0
			SET @contador = (SELECT count(*) FROM FERIADOS WHERE TZ_LOCK = 0 AND TIPO != ''S'' AND (anio = year(@fchAux) OR anio = 0) AND mes = month(@fchAux) AND dia = day(@fchAux))
			
			IF @contador = 0
				BEGIN
					SET @contador = (SELECT count(*) FROM FERIADOS WHERE TZ_LOCK = 0 AND TIPO = ''S'' AND DESCRIPCION LIKE UPPER(DATENAME(dw, @fchAux)))
					
					IF @contador = 0
						BEGIN
							SET @fchAux = dateadd(DAY,1,@fchAux) 
							SET @sumarizador = @sumarizador + 1
						END
					ELSE
						SET @fchAux = dateadd(DAY,1,@fchAux)   
				END		
			ELSE		  
				SET @fchAux = dateadd(DAY,1,@fchAux)		
		END	
	
	SET @fchHabil = @fchAux
	RETURN @fchHabil
	
END
')

