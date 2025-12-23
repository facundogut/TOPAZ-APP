EXECUTE('
ALTER PROCEDURE OBTENER_TAMANO_EMPRESA
  
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
               AND F_INICIO >= (SELECT (fechaproceso-1260) FROM PARAMETROS) -- anexado segun jira NBCHSEG-2202, evaluar refactor con parametros
       
      /*
      IF  @CANTIDAD_BALANCES > 3
          BEGIN
           SET @CANTIDAD_BALANCES = 3
          END */ -- bloque comentado pór jira NBCHSEG-2202 dado que ahora nos quedamos con todos los balances existentes en los ulitmos 42 meses (1260 dias)
       
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
				
				-- Buscar para 3 balances y quedarse con el mayor promedio de venta
				-- Buscar para 3 balances y quedarse con la persona con el mayor promedio de venta
				SELECT TOP 1 @NUMEROPERSONA = ID_PERSONA FROM (
				SELECT ID_PERSONA, round(avg(a.TOTAL_VENTAS),2) AS PROMEDIO
				FROM CRE_TAM_EMP_BALANCE a WITH(NOLOCK)
				INNER JOIN CLI_CLIENTEPERSONA cp WITH(NOLOCK) ON a.ID_PERSONA = cp.NUMEROPERSONA AND cp.TITULARIDAD = ''T'' AND cp.TZ_LOCK = 0
				INNER JOIN CLI_GRUPOSECONOMICOSCLIENTE g WITH(NOLOCK) ON cp.CODIGOCLIENTE = g.CODIGOCLIENTE AND g.TZ_LOCK = 0 AND g.CODIGOGRUPOECONOMICO = @COD_GRUPO_ECONOMICO
				where a.f_inicio IN (SELECT top 3 f_inicio 
								FROM CRE_TAM_EMP_BALANCE b WITH(NOLOCK)
								WHERE b.DOCUMENTO = a.DOCUMENTO
								AND b.TIPO_DOCUMENTO = a.TIPO_DOCUMENTO
								AND b.TZ_LOCK = 0
								ORDER BY b.f_inicio DESC) 
				GROUP BY ID_PERSONA) sub
				ORDER BY sub.PROMEDIO DESC
   				
				-- Obtengo Actividad AFIP
				SELECT TOP 1 @CODIGO_ACT_AFIP = CODIGO_ACTIVIDAD FROM CLI_ACTIVIDAD_ECONOMICA WITH(NOLOCK)
				WHERE CODIGO_PERSONA_CLIENTE = @NUMEROPERSONA 
				AND TZ_LOCK = 0
				AND ORDEN_AFIP IN (SELECT TOP 1 ORDEN_AFIP FROM CLI_ACTIVIDAD_ECONOMICA WITH(NOLOCK)
									WHERE CODIGO_PERSONA_CLIENTE = @NUMEROPERSONA
									AND TZ_LOCK = 0
									ORDER BY ORDEN_AFIP)	
				
				-- quedarse con los ultimos 3 y hacerle el promedio, luego sumar el promedio de todas las personas del grupo
				SELECT @PROM_TOTAL_VENTAS = sum(PROMEDIO) FROM (
				SELECT ID_PERSONA, round(avg(a.TOTAL_VENTAS),2) AS PROMEDIO
				FROM CRE_TAM_EMP_BALANCE a WITH(NOLOCK)
				INNER JOIN CLI_CLIENTEPERSONA cp WITH(NOLOCK) ON a.ID_PERSONA = cp.NUMEROPERSONA AND cp.TITULARIDAD = ''T'' AND cp.TZ_LOCK = 0
				INNER JOIN CLI_GRUPOSECONOMICOSCLIENTE g WITH(NOLOCK) ON cp.CODIGOCLIENTE = g.CODIGOCLIENTE AND g.TZ_LOCK = 0 AND g.CODIGOGRUPOECONOMICO = @COD_GRUPO_ECONOMICO
				where a.f_inicio IN (SELECT top 3 f_inicio 
								FROM CRE_TAM_EMP_BALANCE b WITH(NOLOCK)
								WHERE b.DOCUMENTO = a.DOCUMENTO
								AND b.TIPO_DOCUMENTO = a.TIPO_DOCUMENTO
								AND b.TZ_LOCK = 0
								ORDER BY b.f_inicio DESC) 
				GROUP BY ID_PERSONA) sub
								
				-- Obtengo el personal Ocupado de todo el grupo				
				SELECT @PROM_PERSONAL_OCUPADO = sum(PROMEDIO) FROM (
				SELECT ID_PERSONA, round(avg(a.PERSONAL_OCUPADO),2) AS PROMEDIO
				FROM CRE_TAM_EMP_BALANCE a WITH(NOLOCK)
				INNER JOIN CLI_CLIENTEPERSONA cp WITH(NOLOCK) ON a.ID_PERSONA = cp.NUMEROPERSONA AND cp.TITULARIDAD = ''T'' AND cp.TZ_LOCK = 0
				INNER JOIN CLI_GRUPOSECONOMICOSCLIENTE g WITH(NOLOCK) ON cp.CODIGOCLIENTE = g.CODIGOCLIENTE AND g.TZ_LOCK = 0 AND g.CODIGOGRUPOECONOMICO = @COD_GRUPO_ECONOMICO
				where a.f_inicio IN (SELECT top 3 f_inicio 
								FROM CRE_TAM_EMP_BALANCE b WITH(NOLOCK)
								WHERE b.DOCUMENTO = a.DOCUMENTO
								AND b.TIPO_DOCUMENTO = a.TIPO_DOCUMENTO
								AND b.TZ_LOCK = 0
								ORDER BY b.f_inicio DESC) 
				GROUP BY ID_PERSONA) sub
												
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
        
        /*IF (@TIENE_BALANCE = 0) AND (@ANTIGUEDAD > 540) AND (@VALIDACION IS NULL) AND (@TIENE_GRUPO_ECONOMICO = 0) AND (@TIENE_CERTIFICADO_MIPYME = 0)
       */ -- por el jira NBCHSEG-2203 se quita de la condicion que no sea grupo economico, dado que en esos casos igual el cliente tiene que tener cargado los balances
       IF (@TIENE_BALANCE = 0) AND (@ANTIGUEDAD > 540) AND (@VALIDACION IS NULL)  AND (@TIENE_CERTIFICADO_MIPYME = 0)
       
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
        
     
      BEGIN -- ajuste por jira NBCHSEG-2169 AND @CANTIDAD_BALANCES =0
      IF @ANTIGUEDAD < 540 AND (@TIENE_GRUPO_ECONOMICO = 0) AND (@TIENE_CERTIFICADO_MIPYME = 0)  AND @CANTIDAD_BALANCES =0 
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

