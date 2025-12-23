EXECUTE('
IF OBJECT_ID (''dbo.SP_ACTUALIZA_DEVENGA_SUSPENSO'') IS NOT NULL
	DROP PROCEDURE dbo.SP_ACTUALIZA_DEVENGA_SUSPENSO
')

EXECUTE('
CREATE PROCEDURE [dbo].[SP_ACTUALIZA_DEVENGA_SUSPENSO]
	@p_id_proceso FLOAT(53), /* Identificador de proceso */
	@p_dt_proceso DATETIME, /* Fecha de proceso */
	@p_ret_proceso FLOAT OUT, /* Estado de ejecucion SQL(0:Correcto, 2: Error) */
	@p_msg_proceso VARCHAR(MAX) OUT
AS
BEGIN
	DECLARE 
	------- Campos para el LOG --------
	@c_log_tipo_error varchar(30),
	@c_log_tipo_informacion VARCHAR(30),
	-----------------------------------	
	@contador NUMERIC(10),
	@contadorDos NUMERIC(10),
	@contadorTotal NUMERIC(10)
	SET @contador = 0;	
	SET @contadorDos = 0;
	SET @contadorTotal = 0;
	------- Campos para el LOG --------
	SET @c_log_tipo_error = ''E'';
	SET @c_log_tipo_informacion = ''I'';
	-----------------------------------	

	BEGIN TRY
	
		UPDATE CLI_CLIENTES SET CLIENTE_DEVENGA_SUSPENSO = 0 WHERE CLIENTE_DEVENGA_SUSPENSO = 2 OR CLIENTE_DEVENGA_SUSPENSO IS NULL;		
        	  
		SET @contador =	(SELECT count(1) FROM CLI_CLIENTES WHERE MOTIVO_INHABILITADO = 2 AND CLIENTE_DEVENGA_SUSPENSO <> 1)				
		
		SET @contadorDos = (SELECT count(1)
			FROM VW_CLI_X_DOC c WITH (NOLOCK)
			INNER JOIN CLI_ClientePersona cp WITH (NOLOCK) ON c.CODIGOCLIENTE = cp.CODIGOCLIENTE AND cp.TITULARIDAD = ''T'' AND cp.TZ_LOCK = 0
			INNER JOIN (SELECT pf.NUMEROPERSONAFISICA AS PERSONA FROM CLI_PERSONASFISICAS pf WITH (NOLOCK) WHERE pf.CONC_ACREEDORES = ''S'' AND pf.TZ_LOCK = 0
			UNION
			SELECT pj.NUMEROPERSONAJURIDICA AS PERSONA FROM CLI_PERSONASJURIDICAS pj WITH (NOLOCK) WHERE pj.CONC_ACREEDORES = ''S'' AND pj.TZ_LOCK = 0) p 
			ON cp.NUMEROPERSONA = p.PERSONA 
			INNER JOIN CLI_CONCURSO_ACREEDORES ca WITH (NOLOCK) ON c.TIPODOC = ca.TIPODOCUMENTO AND c.NUMERODOC = ca.CUIT_CUIL AND ca.CONC_ACREEDORES = ''S'' AND ca.TZ_LOCK = 0 AND
			ca.FECHA_INGRESO <= (SELECT FECHAPROCESO FROM PARAMETROS WITH (NOLOCK)) AND ((CA.FECHA_FIN IS NOT NULL AND ca.FECHA_FIN >= (SELECT FECHAPROCESO FROM PARAMETROS WITH (NOLOCK))) OR ca.FECHA_FIN IS NULL))				
		
		IF @contador > 0
		BEGIN
			UPDATE CLI_CLIENTES SET CLIENTE_DEVENGA_SUSPENSO = 1 WHERE MOTIVO_INHABILITADO = 2 AND CLIENTE_DEVENGA_SUSPENSO <> 1
	
		END
		
		IF @contadorDos > 0
		BEGIN			
			UPDATE c
			SET c.CLIENTE_DEVENGA_SUSPENSO = a.CALIF
			FROM CLI_CLIENTES c WITH (NOLOCK)
			INNER JOIN (SELECT 2 AS CALIF, c.CODIGOCLIENTE
			FROM VW_CLI_X_DOC c WITH (NOLOCK)
			INNER JOIN CLI_ClientePersona cp WITH (NOLOCK) ON c.CODIGOCLIENTE = cp.CODIGOCLIENTE AND cp.TITULARIDAD = ''T'' AND cp.TZ_LOCK = 0
			INNER JOIN (SELECT pf.NUMEROPERSONAFISICA AS PERSONA FROM CLI_PERSONASFISICAS pf WITH (NOLOCK) WHERE pf.CONC_ACREEDORES = ''S'' AND pf.TZ_LOCK = 0
			UNION
			SELECT pj.NUMEROPERSONAJURIDICA AS PERSONA FROM CLI_PERSONASJURIDICAS pj WITH (NOLOCK) WHERE pj.CONC_ACREEDORES = ''S'' AND pj.TZ_LOCK = 0) p 
			ON cp.NUMEROPERSONA = p.PERSONA 
			INNER JOIN CLI_CONCURSO_ACREEDORES ca WITH (NOLOCK) ON c.TIPODOC = ca.TIPODOCUMENTO AND c.NUMERODOC = ca.CUIT_CUIL AND ca.CONC_ACREEDORES = ''S'' AND ca.TZ_LOCK = 0 AND
			ca.FECHA_INGRESO <= (SELECT FECHAPROCESO FROM PARAMETROS WITH (NOLOCK)) AND ((CA.FECHA_FIN IS NOT NULL AND ca.FECHA_FIN >= (SELECT FECHAPROCESO FROM PARAMETROS WITH (NOLOCK))) OR ca.FECHA_FIN IS NULL)) a
			ON a.CODIGOCLIENTE = c.CODIGOCLIENTE
			WHERE c.TZ_LOCK = 0		
		END	
		
		SET @contadorTotal = @contador + @contadorDos;	
		  
		SET @p_msg_proceso = ''El Proceso de Marca de Cliente Devenga en Suspenso ha finalizado correctamente. Registros procesados: ''+ CONVERT(VARCHAR(10), @contadorTotal)
		SET @p_ret_proceso = 1 		
			
		-- Logueo de información
		EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso 
			@p_id_proceso,
	    	@p_dt_proceso,
		   	''SP_ACTUALIZA_DEVENGA_SUSPENSO'',
		   	@p_cod_error = @p_ret_proceso, 
			@p_msg_error = @p_msg_proceso, 
			@p_tipo_error = @c_log_tipo_informacion
	END TRY
							             
	BEGIN CATCH
	
        SET @p_ret_proceso = ERROR_NUMBER()
        SET @p_msg_proceso = ''Ocurrió un error en el Proceso de Marca de Cliente Devenga en Suspenso: '' + ERROR_MESSAGE()
	
		EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso 
        	@p_id_proceso = @p_id_proceso, 
        	@p_fch_proceso = @p_dt_proceso, 
        	@p_nom_package = ''SP_ACTUALIZA_DEVENGA_SUSPENSO'', 
        	@p_cod_error = @p_ret_proceso, 
        	@p_msg_error = @p_msg_proceso, 
       		@p_tipo_error = @c_log_tipo_informacion
	END CATCH
END
')



EXECUTE('
IF OBJECT_ID (''dbo.OBTENER_TAMANO_EMPRESA'') IS NOT NULL
	DROP PROCEDURE dbo.OBTENER_TAMANO_EMPRESA ')

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


EXECUTE('
IF OBJECT_ID (''dbo.SP_ACTUALIZA_DISCREPANCIA'') IS NOT NULL
	DROP PROCEDURE dbo.SP_ACTUALIZA_DISCREPANCIA ')

EXECUTE('
CREATE PROCEDURE [dbo].[SP_ACTUALIZA_DISCREPANCIA]
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
	@contador NUMERIC(10)
	SET @contador = 0;
	------- Campos para el LOG --------
	SET @c_log_tipo_error = ''E'';
	SET @c_log_tipo_informacion = ''I'';
	-----------------------------------	

	BEGIN TRY
        	  
		SET @contador =	(SELECT count(1)
		FROM CLI_CLIENTES c WITH (NOLOCK)
		-- Deuda fuera de la institucion que supere total de niveles peores
		INNER JOIN (SELECT cen.CODIGOCLIENTE, sum(cen.DEUDA_TOTAL) AS DEUDA 
				FROM CRE_BCRA_CENDEU cen WITH (NOLOCK)
				INNER JOIN CLI_CLIENTES cli WITH (NOLOCK) ON cen.CODIGOCLIENTE = cli.CODIGOCLIENTE AND cli.TZ_LOCK = 0
				INNER JOIN CLI_CLASUBJETIVA pon1 WITH (NOLOCK) ON pon1.CATEGORIASUB = CAST(cen.SITUACION_ENTIDAD AS VARCHAR(2)) AND pon1.TZ_LOCK = 0
				INNER JOIN CLI_CLASUBJETIVA pon2 WITH (NOLOCK) ON pon2.CATEGORIASUB = (CASE WHEN (SELECT PONDERACION FROM CLI_CLASUBJETIVA WITH (NOLOCK) WHERE CATEGORIASUB = isnull(cli.CATEGORIAOBJETIVA, '' '')) >= (SELECT PONDERACION FROM CLI_CLASUBJETIVA WITH (NOLOCK) WHERE CATEGORIASUB = isnull(cli.OBJETIVA_REFINANCIADO,'' '')) THEN cli.CATEGORIAOBJETIVA ELSE cli.OBJETIVA_REFINANCIADO END)
																AND pon2.TZ_LOCK = 0 AND pon2.PONDERACION + (SELECT DIASINMOVILIZADA FROM CRE_PARAMETROS WITH (NOLOCK) WHERE CODIGO = 170) < pon1.PONDERACION 
				WHERE cen.COD_ENTIDAD <> right(''00000'' + CAST((SELECT NUMERICO FROM PARAMETROSGENERALES WITH (NOLOCK) WHERE CODIGO = 2) AS VARCHAR(5)),5) AND cen.TZ_LOCK = 0 AND cen.SITUACION_ENTIDAD <> ''6'' AND
				cen.COD_ENTIDAD NOT IN (SELECT right(''00000'' + CAST(ENTIDAD AS VARCHAR(5)),5) FROM CRE_Excep_Ent_Discrepancia WITH (NOLOCK) WHERE TZ_LOCK = 0 AND (CARTERA = ''T'' OR CARTERA = cli.CATEGORIA_COMERCIAL OR (CARTERA = ''C'' AND cli.CATEGORIA_COMERCIAL = ''S'')))		
				GROUP BY cen.CODIGOCLIENTE) d ON c.CODIGOCLIENTE = d.CODIGOCLIENTE 
		-- Deuda TOTAL fuera de la institucion
		INNER JOIN (SELECT cen.CODIGOCLIENTE, sum(cen.DEUDA_TOTAL) AS DEUDA 
				FROM CRE_BCRA_CENDEU cen WITH (NOLOCK)
				INNER JOIN CLI_CLIENTES cli WITH (NOLOCK) ON cen.CODIGOCLIENTE = cli.CODIGOCLIENTE AND cli.TZ_LOCK = 0
				WHERE cen.COD_ENTIDAD <> right(''00000'' + CAST((SELECT NUMERICO FROM PARAMETROSGENERALES WITH (NOLOCK) WHERE CODIGO = 2) AS VARCHAR(5)),5) AND cen.TZ_LOCK = 0 AND cen.SITUACION_ENTIDAD <> ''6'' AND
				cen.COD_ENTIDAD NOT IN (SELECT right(''00000'' + CAST(ENTIDAD AS VARCHAR(5)),5) FROM CRE_Excep_Ent_Discrepancia WITH (NOLOCK) WHERE TZ_LOCK = 0 AND (CARTERA = ''T'' OR CARTERA = cli.CATEGORIA_COMERCIAL OR (CARTERA = ''C'' AND cli.CATEGORIA_COMERCIAL = ''S'')))				
				GROUP BY cen.CODIGOCLIENTE) dt ON c.CODIGOCLIENTE = dt.CODIGOCLIENTE 
		-- Busco deuda con la institucion		
		INNER JOIN (SELECT CODIGOCLIENTE, sum(DEUDA_TOTAL) AS DEUDA 
				FROM CRE_BCRA_CENDEU WITH (NOLOCK)
				WHERE COD_ENTIDAD = right(''00000'' + CAST((SELECT NUMERICO FROM PARAMETROSGENERALES WITH (NOLOCK) WHERE CODIGO = 2) AS VARCHAR(5)),5) AND TZ_LOCK = 0 				
				GROUP BY CODIGOCLIENTE) dm ON c.CODIGOCLIENTE = dm.CODIGOCLIENTE				
		/*INNER JOIN (SELECT sum(SALDO) AS DEUDA, CLIENTE 
				FROM VW_ASISTENCIAS WITH (NOLOCK)
				WHERE SALDO > 0
				GROUP BY CLIENTE ) dm ON c.CODIGOCLIENTE = dm.CLIENTE */
		-- Cantidad de entidades con niveles peores que el actual
		INNER JOIN (SELECT cen.CODIGOCLIENTE, count(cen.CODIGOCLIENTE) AS CANTIDAD
				FROM CRE_BCRA_CENDEU cen WITH (NOLOCK)
				INNER JOIN CLI_CLIENTES cli WITH (NOLOCK) ON cen.CODIGOCLIENTE = cli.CODIGOCLIENTE AND cli.TZ_LOCK = 0
				INNER JOIN CLI_CLASUBJETIVA pon1 WITH (NOLOCK) ON pon1.CATEGORIASUB = CAST(cen.SITUACION_ENTIDAD AS VARCHAR(2)) AND pon1.TZ_LOCK = 0
				INNER JOIN CLI_CLASUBJETIVA pon2 WITH (NOLOCK) ON pon2.CATEGORIASUB = (CASE WHEN (SELECT PONDERACION FROM CLI_CLASUBJETIVA WITH (NOLOCK) WHERE CATEGORIASUB = isnull(cli.CATEGORIAOBJETIVA, '' '')) >= (SELECT PONDERACION FROM CLI_CLASUBJETIVA WITH (NOLOCK) WHERE CATEGORIASUB = isnull(cli.OBJETIVA_REFINANCIADO,'' '')) THEN cli.CATEGORIAOBJETIVA ELSE cli.OBJETIVA_REFINANCIADO END)
																AND pon2.TZ_LOCK = 0 AND pon2.PONDERACION + (SELECT DIASINMOVILIZADA FROM CRE_PARAMETROS WITH (NOLOCK) WHERE CODIGO = 170) < pon1.PONDERACION 
				WHERE cen.COD_ENTIDAD <> right(''00000'' + CAST((SELECT NUMERICO FROM PARAMETROSGENERALES WITH (NOLOCK) WHERE CODIGO = 2) AS VARCHAR(5)),5) AND cen.TZ_LOCK = 0  AND cen.SITUACION_ENTIDAD <> ''6'' AND
				cen.COD_ENTIDAD NOT IN (SELECT right(''00000'' + CAST(ENTIDAD AS VARCHAR(5)),5) FROM CRE_Excep_Ent_Discrepancia WITH (NOLOCK) WHERE TZ_LOCK = 0 AND (CARTERA = ''T'' OR CARTERA = cli.CATEGORIA_COMERCIAL OR (CARTERA = ''C'' AND cli.CATEGORIA_COMERCIAL = ''S'')))
				GROUP BY cen.CODIGOCLIENTE) cant ON c.CODIGOCLIENTE = cant.CODIGOCLIENTE AND cant.CANTIDAD >= (SELECT DIASINMOVILIZADA FROM CRE_PARAMETROS WITH (NOLOCK) WHERE CODIGO = 169)			
		-- Busco peor nivel con mayor deuda			   
		INNER JOIN (SELECT b.CODIGOCLIENTE, b.PONDERACION 
					FROM (
						SELECT a.CODIGOCLIENTE, a.PONDERACION,
						ROW_NUMBER() OVER(PARTITION BY a.CODIGOCLIENTE ORDER BY a.DEUDA_TOTAL DESC) AS CANTIDAD
						FROM(
							SELECT cen.CODIGOCLIENTE, pon1.PONDERACION, sum(cen.DEUDA_TOTAL) AS DEUDA_TOTAL
							FROM CRE_BCRA_CENDEU cen WITH (NOLOCK)
							INNER JOIN CLI_CLIENTES cli WITH (NOLOCK) ON cen.CODIGOCLIENTE = cli.CODIGOCLIENTE AND cli.TZ_LOCK = 0
							INNER JOIN CLI_CLASUBJETIVA pon1 WITH (NOLOCK) ON pon1.CATEGORIASUB = CAST(cen.SITUACION_ENTIDAD AS VARCHAR(2)) AND pon1.TZ_LOCK = 0
							INNER JOIN CLI_CLASUBJETIVA pon2 WITH (NOLOCK) ON pon2.CATEGORIASUB = (CASE WHEN (SELECT PONDERACION FROM CLI_CLASUBJETIVA WITH (NOLOCK) WHERE CATEGORIASUB = isnull(cli.CATEGORIAOBJETIVA, '' '')) >= (SELECT PONDERACION FROM CLI_CLASUBJETIVA WITH (NOLOCK) WHERE CATEGORIASUB = isnull(cli.OBJETIVA_REFINANCIADO,'' '')) THEN cli.CATEGORIAOBJETIVA ELSE cli.OBJETIVA_REFINANCIADO END)
																			AND pon2.TZ_LOCK = 0 AND pon2.PONDERACION + (SELECT DIASINMOVILIZADA FROM CRE_PARAMETROS WITH (NOLOCK) WHERE CODIGO = 170) < pon1.PONDERACION 
							WHERE cen.COD_ENTIDAD <> right(''00000'' + CAST((SELECT NUMERICO FROM PARAMETROSGENERALES WITH (NOLOCK) WHERE CODIGO = 2) AS VARCHAR(5)),5) AND cen.TZ_LOCK = 0  AND cen.SITUACION_ENTIDAD <> ''6'' AND
							cen.COD_ENTIDAD NOT IN (SELECT right(''00000'' + CAST(ENTIDAD AS VARCHAR(5)),5) FROM CRE_Excep_Ent_Discrepancia WITH (NOLOCK) WHERE TZ_LOCK = 0 AND (CARTERA = ''T'' OR CARTERA = cli.CATEGORIA_COMERCIAL OR (CARTERA = ''C'' AND cli.CATEGORIA_COMERCIAL = ''S'')))
							GROUP BY cen.CODIGOCLIENTE, pon1.PONDERACION) a 
						) b
					WHERE b.CANTIDAD = 1) pn ON c.CODIGOCLIENTE = pn.CODIGOCLIENTE	
		WHERE c.TZ_LOCK = 0 AND
		round(( d.DEUDA / (dt.DEUDA + dm.DEUDA) ),2) * 100  >= (SELECT IMPORTE FROM CRE_PARAMETROS WITH (NOLOCK) WHERE CODIGO = 168))				
		
		IF @contador > 0
		BEGIN
			UPDATE c
			SET c.DISCREPANCIA = a.CATEGORIASUB
			FROM CLI_CLIENTES c WITH (NOLOCK)
			INNER JOIN (SELECT c.CODIGOCLIENTE, p.CATEGORIASUB
				FROM CLI_CLIENTES c WITH (NOLOCK)
				-- Deuda fuera de la institucion que supere total de niveles peores
				INNER JOIN (SELECT cen.CODIGOCLIENTE, sum(cen.DEUDA_TOTAL) AS DEUDA 
						FROM CRE_BCRA_CENDEU cen WITH (NOLOCK)
						INNER JOIN CLI_CLIENTES cli WITH (NOLOCK) ON cen.CODIGOCLIENTE = cli.CODIGOCLIENTE AND cli.TZ_LOCK = 0
						INNER JOIN CLI_CLASUBJETIVA pon1 WITH (NOLOCK) ON pon1.CATEGORIASUB = CAST(cen.SITUACION_ENTIDAD AS VARCHAR(2)) AND pon1.TZ_LOCK = 0
						INNER JOIN CLI_CLASUBJETIVA pon2 WITH (NOLOCK) ON pon2.CATEGORIASUB = (CASE WHEN (SELECT PONDERACION FROM CLI_CLASUBJETIVA WITH (NOLOCK) WHERE CATEGORIASUB = isnull(cli.CATEGORIAOBJETIVA, '' '')) >= (SELECT PONDERACION FROM CLI_CLASUBJETIVA WITH (NOLOCK) WHERE CATEGORIASUB = isnull(cli.OBJETIVA_REFINANCIADO,'' '')) THEN cli.CATEGORIAOBJETIVA ELSE cli.OBJETIVA_REFINANCIADO END)
																		AND pon2.TZ_LOCK = 0 AND pon2.PONDERACION + (SELECT DIASINMOVILIZADA FROM CRE_PARAMETROS WITH (NOLOCK) WHERE CODIGO = 170) < pon1.PONDERACION 
						WHERE cen.COD_ENTIDAD <> right(''00000'' + CAST((SELECT NUMERICO FROM PARAMETROSGENERALES WITH (NOLOCK) WHERE CODIGO = 2) AS VARCHAR(5)),5) AND cen.TZ_LOCK = 0 AND cen.SITUACION_ENTIDAD <> ''6'' AND
						cen.COD_ENTIDAD NOT IN (SELECT right(''00000'' + CAST(ENTIDAD AS VARCHAR(5)),5) FROM CRE_Excep_Ent_Discrepancia WITH (NOLOCK) WHERE TZ_LOCK = 0 AND (CARTERA = ''T'' OR CARTERA = cli.CATEGORIA_COMERCIAL OR (CARTERA = ''C'' AND cli.CATEGORIA_COMERCIAL = ''S'')))		
						GROUP BY cen.CODIGOCLIENTE) d ON c.CODIGOCLIENTE = d.CODIGOCLIENTE 
				-- Deuda TOTAL fuera de la institucion
				INNER JOIN (SELECT cen.CODIGOCLIENTE, sum(cen.DEUDA_TOTAL) AS DEUDA 
						FROM CRE_BCRA_CENDEU cen WITH (NOLOCK)
						INNER JOIN CLI_CLIENTES cli WITH (NOLOCK) ON cen.CODIGOCLIENTE = cli.CODIGOCLIENTE AND cli.TZ_LOCK = 0
						WHERE cen.COD_ENTIDAD <> right(''00000'' + CAST((SELECT NUMERICO FROM PARAMETROSGENERALES WITH (NOLOCK) WHERE CODIGO = 2) AS VARCHAR(5)),5) AND cen.TZ_LOCK = 0 AND cen.SITUACION_ENTIDAD <> ''6'' AND
						cen.COD_ENTIDAD NOT IN (SELECT right(''00000'' + CAST(ENTIDAD AS VARCHAR(5)),5) FROM CRE_Excep_Ent_Discrepancia WITH (NOLOCK) WHERE TZ_LOCK = 0 AND (CARTERA = ''T'' OR CARTERA = cli.CATEGORIA_COMERCIAL OR (CARTERA = ''C'' AND cli.CATEGORIA_COMERCIAL = ''S'')))				
						GROUP BY cen.CODIGOCLIENTE) dt ON c.CODIGOCLIENTE = dt.CODIGOCLIENTE 
				-- Busco deuda con la institucion		
				INNER JOIN (SELECT CODIGOCLIENTE, sum(DEUDA_TOTAL) AS DEUDA 
						FROM CRE_BCRA_CENDEU WITH (NOLOCK)
						WHERE COD_ENTIDAD = right(''00000'' + CAST((SELECT NUMERICO FROM PARAMETROSGENERALES WITH (NOLOCK) WHERE CODIGO = 2) AS VARCHAR(5)),5) AND TZ_LOCK = 0 				
						GROUP BY CODIGOCLIENTE) dm ON c.CODIGOCLIENTE = dm.CODIGOCLIENTE				
				/*INNER JOIN (SELECT sum(SALDO) AS DEUDA, CLIENTE 
						FROM VW_ASISTENCIAS WITH (NOLOCK)
						WHERE SALDO > 0
						GROUP BY CLIENTE ) dm ON c.CODIGOCLIENTE = dm.CLIENTE */
				-- Cantidad de entidades con niveles peores que el actual
				INNER JOIN (SELECT cen.CODIGOCLIENTE, count(cen.CODIGOCLIENTE) AS CANTIDAD
						FROM CRE_BCRA_CENDEU cen WITH (NOLOCK)
						INNER JOIN CLI_CLIENTES cli WITH (NOLOCK) ON cen.CODIGOCLIENTE = cli.CODIGOCLIENTE AND cli.TZ_LOCK = 0
						INNER JOIN CLI_CLASUBJETIVA pon1 WITH (NOLOCK) ON pon1.CATEGORIASUB = CAST(cen.SITUACION_ENTIDAD AS VARCHAR(2)) AND pon1.TZ_LOCK = 0
						INNER JOIN CLI_CLASUBJETIVA pon2 WITH (NOLOCK) ON pon2.CATEGORIASUB = (CASE WHEN (SELECT PONDERACION FROM CLI_CLASUBJETIVA WITH (NOLOCK) WHERE CATEGORIASUB = isnull(cli.CATEGORIAOBJETIVA, '' '')) >= (SELECT PONDERACION FROM CLI_CLASUBJETIVA WITH (NOLOCK) WHERE CATEGORIASUB = isnull(cli.OBJETIVA_REFINANCIADO,'' '')) THEN cli.CATEGORIAOBJETIVA ELSE cli.OBJETIVA_REFINANCIADO END)
																		AND pon2.TZ_LOCK = 0 AND pon2.PONDERACION + (SELECT DIASINMOVILIZADA FROM CRE_PARAMETROS WITH (NOLOCK) WHERE CODIGO = 170) < pon1.PONDERACION 
						WHERE cen.COD_ENTIDAD <> right(''00000'' + CAST((SELECT NUMERICO FROM PARAMETROSGENERALES WITH (NOLOCK) WHERE CODIGO = 2) AS VARCHAR(5)),5) AND cen.TZ_LOCK = 0  AND cen.SITUACION_ENTIDAD <> ''6'' AND
						cen.COD_ENTIDAD NOT IN (SELECT right(''00000'' + CAST(ENTIDAD AS VARCHAR(5)),5) FROM CRE_Excep_Ent_Discrepancia WITH (NOLOCK) WHERE TZ_LOCK = 0 AND (CARTERA = ''T'' OR CARTERA = cli.CATEGORIA_COMERCIAL OR (CARTERA = ''C'' AND cli.CATEGORIA_COMERCIAL = ''S'')))
						GROUP BY cen.CODIGOCLIENTE) cant ON c.CODIGOCLIENTE = cant.CODIGOCLIENTE AND cant.CANTIDAD >= (SELECT DIASINMOVILIZADA FROM CRE_PARAMETROS WITH (NOLOCK) WHERE CODIGO = 169)			
				-- Busco peor nivel con mayor deuda			   
				INNER JOIN (SELECT b.CODIGOCLIENTE, b.PONDERACION FROM (
								SELECT a.CODIGOCLIENTE, a.PONDERACION,
								ROW_NUMBER() OVER(PARTITION BY a.CODIGOCLIENTE ORDER BY a.DEUDA_TOTAL DESC) AS CANTIDAD
								FROM(
									SELECT cen.CODIGOCLIENTE, pon1.PONDERACION, sum(cen.DEUDA_TOTAL) AS DEUDA_TOTAL
									FROM CRE_BCRA_CENDEU cen WITH (NOLOCK)
									INNER JOIN CLI_CLIENTES cli WITH (NOLOCK) ON cen.CODIGOCLIENTE = cli.CODIGOCLIENTE AND cli.TZ_LOCK = 0
									INNER JOIN CLI_CLASUBJETIVA pon1 WITH (NOLOCK) ON pon1.CATEGORIASUB = CAST(cen.SITUACION_ENTIDAD AS VARCHAR(2)) AND pon1.TZ_LOCK = 0
									INNER JOIN CLI_CLASUBJETIVA pon2 WITH (NOLOCK) ON pon2.CATEGORIASUB = (CASE WHEN (SELECT PONDERACION FROM CLI_CLASUBJETIVA WITH (NOLOCK) WHERE CATEGORIASUB = isnull(cli.CATEGORIAOBJETIVA, '' '')) >= (SELECT PONDERACION FROM CLI_CLASUBJETIVA WITH (NOLOCK) WHERE CATEGORIASUB = isnull(cli.OBJETIVA_REFINANCIADO,'' '')) THEN cli.CATEGORIAOBJETIVA ELSE cli.OBJETIVA_REFINANCIADO END)
																					AND pon2.TZ_LOCK = 0 AND pon2.PONDERACION + (SELECT DIASINMOVILIZADA FROM CRE_PARAMETROS WITH (NOLOCK) WHERE CODIGO = 170) < pon1.PONDERACION 
									WHERE cen.COD_ENTIDAD <> right(''00000'' + CAST((SELECT NUMERICO FROM PARAMETROSGENERALES WITH (NOLOCK) WHERE CODIGO = 2) AS VARCHAR(5)),5) AND cen.TZ_LOCK = 0  AND cen.SITUACION_ENTIDAD <> ''6'' AND
									cen.COD_ENTIDAD NOT IN (SELECT right(''00000'' + CAST(ENTIDAD AS VARCHAR(5)),5) FROM CRE_Excep_Ent_Discrepancia WITH (NOLOCK) WHERE TZ_LOCK = 0 AND (CARTERA = ''T'' OR CARTERA = cli.CATEGORIA_COMERCIAL OR (CARTERA = ''C'' AND cli.CATEGORIA_COMERCIAL = ''S'')))
									GROUP BY cen.CODIGOCLIENTE, pon1.PONDERACION) a ) b
								WHERE b.CANTIDAD = 1) pn ON c.CODIGOCLIENTE = pn.CODIGOCLIENTE	
				INNER JOIN CLI_CLASUBJETIVA p ON pn.PONDERACION - (SELECT DIASINMOVILIZADA FROM CRE_PARAMETROS WITH (NOLOCK) WHERE CODIGO = 171) = p.PONDERACION AND p.TZ_LOCK = 0
				WHERE c.TZ_LOCK = 0 AND
				round((d.DEUDA / (dt.DEUDA + dm.DEUDA) ),2) * 100 >= (SELECT IMPORTE FROM CRE_PARAMETROS WITH (NOLOCK) WHERE CODIGO = 168)) a
			ON a.CODIGOCLIENTE = c.CODIGOCLIENTE
			WHERE c.TZ_LOCK = 0		
		END
		  
		SET @p_msg_proceso = ''El Proceso de Actualización de Discrepancia ha finalizado correctamente. Registros procesados: ''+ CONVERT(VARCHAR(10), @contador)
		SET @p_ret_proceso = 1 		
			
		-- Logueo de información
		EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso 
			@p_id_proceso,
		   	@p_dt_proceso,
		   	''SP_ACTUALIZA_DISCREPANCIA'',
		   	@p_cod_error = @p_ret_proceso, 
			@p_msg_error = @p_msg_proceso, 
			@p_tipo_error = @c_log_tipo_informacion
	END TRY
							             
	BEGIN CATCH
	
	    SET @p_ret_proceso = ERROR_NUMBER()
	    SET @p_msg_proceso = ''Ocurrió un error en el Proceso de Actualización de Discrepancia: '' + ERROR_MESSAGE()
	
		EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso 
	       	@p_id_proceso = @p_id_proceso, 
	       	@p_fch_proceso = @p_dt_proceso, 
	       	@p_nom_package = ''SP_ACTUALIZA_DISCREPANCIA'', 
	       	@p_cod_error = @p_ret_proceso, 
	       	@p_msg_error = @p_msg_proceso, 
	  		@p_tipo_error = @c_log_tipo_informacion
	END CATCH
END
')


EXECUTE('
IF OBJECT_ID (''dbo.SP_ACTUALIZA_SITUACION_BCRA'') IS NOT NULL
	DROP PROCEDURE dbo.SP_ACTUALIZA_SITUACION_BCRA ')


EXECUTE('
CREATE PROCEDURE [dbo].[SP_ACTUALIZA_SITUACION_BCRA]
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
	@contador NUMERIC(10)
	SET @contador = 0;
	------- Campos para el LOG --------
	SET @c_log_tipo_error = ''E'';
	SET @c_log_tipo_informacion = ''I'';
	-----------------------------------	

	BEGIN TRY
	
	    BEGIN
	    	UPDATE CLI_CLIENTES SET CATEGORIA_OFICIAL = '' ''
	    END
        	  
		SET @contador =	(SELECT count(1)			
		FROM CLI_CLIENTES c WITH (NOLOCK)
		INNER JOIN (SELECT CODIGOCLIENTE, max(SITUACION_ENTIDAD) AS CALIFICACION FROM CRE_BCRA_CENDEU WHERE FECHA_PROCESO = (SELECT FECHAPROCESO FROM PARAMETROS WITH (NOLOCK)) AND TZ_LOCK = 0 AND COD_ENTIDAD <> right(''000000'' + CAST((SELECT NUMERICO FROM PARAMETROSGENERALES WITH (NOLOCK) WHERE CODIGO = 2) AS VARCHAR(5)),5) GROUP BY CODIGOCLIENTE) a
		ON a.CODIGOCLIENTE = c.CODIGOCLIENTE
		WHERE c.TZ_LOCK = 0)				
		
		IF @contador > 0
		BEGIN
			UPDATE c
			SET c.CATEGORIA_OFICIAL = a.CALIFICACION
			FROM CLI_CLIENTES c WITH (NOLOCK)
			INNER JOIN (SELECT CODIGOCLIENTE, max(SITUACION_ENTIDAD) AS CALIFICACION FROM CRE_BCRA_CENDEU WHERE FECHA_PROCESO = (SELECT FECHAPROCESO FROM PARAMETROS WITH (NOLOCK)) AND TZ_LOCK = 0 AND COD_ENTIDAD <> right(''000000'' + CAST((SELECT NUMERICO FROM PARAMETROSGENERALES WITH (NOLOCK) WHERE CODIGO = 2) AS VARCHAR(5)),5) GROUP BY CODIGOCLIENTE) a
			ON a.CODIGOCLIENTE = c.CODIGOCLIENTE
			WHERE c.TZ_LOCK = 0
		END
		  
		    SET @p_msg_proceso = ''El Proceso de Actualización de Situacion de BCRA ha finalizado correctamente. Registros procesados: ''+ CONVERT(VARCHAR(10), @contador)
			SET @p_ret_proceso = 1 		
			
			-- Logueo de información
			EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso 
				@p_id_proceso,
		    	@p_dt_proceso,
		    	''SP_ACTUALIZA_SITUACION_BCRA'',
		    	@p_cod_error = @p_ret_proceso, 
				@p_msg_error = @p_msg_proceso, 
				@p_tipo_error = @c_log_tipo_informacion
		END TRY
							             
		BEGIN CATCH
	
	        SET @p_ret_proceso = ERROR_NUMBER()
	        SET @p_msg_proceso = ''Ocurrió un error en el Proceso de Actualización de Situacion de BCRA: '' + ERROR_MESSAGE()
	
			EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso 
	        	@p_id_proceso = @p_id_proceso, 
	        	@p_fch_proceso = @p_dt_proceso, 
	        	@p_nom_package = ''SP_ACTUALIZA_SITUACION_BCRA'', 
	        	@p_cod_error = @p_ret_proceso, 
	        	@p_msg_error = @p_msg_proceso, 
	       		@p_tipo_error = @c_log_tipo_informacion
		END CATCH
END
')


EXECUTE('
IF OBJECT_ID (''dbo.SP_CESIONCARTERA'') IS NOT NULL
	DROP PROCEDURE dbo.SP_CESIONCARTERA ')


EXECUTE('
CREATE PROCEDURE dbo.SP_CESIONCARTERA
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
   @P_VENCIMIENTO DATETIME,
   @P_CUOTADESDE numeric(3),
   @P_CUOTAHASTA numeric(3)
AS 
	BEGIN            	 
      
      INSERT INTO dbo.CRE_DET_CESIONCARTERA (NUMERO_CESION, JTS_OID_ASISTENCIA, ESTADO, TZ_LOCK)
      SELECT @P_NUMEROCESION, a.JTS_OID, ''A'', 0
      FROM VW_ASISTENCIAS a
      WHERE a.SALDO > 0 AND a.TIPO = 5 AND a.JTS_OID NOT IN (SELECT JTS_OID_ASISTENCIA FROM CRE_DET_CESIONCARTERA WHERE TZ_LOCK = 0 AND NUMERO_CESION NOT IN (SELECT NUMERO_CESION FROM CRE_CAB_CESIONCARTERA WHERE TZ_LOCK = 0 AND ESTADO IN (''I'',''C''))) AND
      JTS_OID NOT IN (SELECT JTS_OID_ASISTENCIA FROM CRE_DET_CESIONCARTERA WHERE TZ_LOCK = 0 AND NUMERO_CESION IN (SELECT NUMERO_CESION FROM CRE_CAB_CESIONCARTERA WHERE TZ_LOCK = 0 AND TIPO_CESION = ''P'' AND ESTADO IN (''I'',''C'') AND CUOTA_DESDE >= @P_CUOTADESDE AND CUOTA_DESDE <= @P_CUOTADESDE AND CUOTA_HASTA >= @P_CUOTAHASTA AND CUOTA_HASTA <= @P_CUOTAHASTA)) AND
      ((a.FAMILIA = @P_FAMILIA AND @P_USAFAMILIA = ''S'') OR @P_USAFAMILIA = ''N'') AND
      ((a.PRODUCTO = @P_PRODUCTO AND @P_USAPRODUCTO = ''S'') OR @P_USAPRODUCTO = ''N'') AND
      ((a.SUCURSAL = @P_SUCURSAL AND @P_USASUCURSAL = ''S'') OR @P_USASUCURSAL = ''N'') AND
      ((a.SITUACION = @P_SITUACION AND @P_USASITUACION = ''S'') OR @P_USASITUACION = ''N'') AND
      ((a.GARANTIA_DESEMBOLSO = @P_GARANTIA AND @P_USAGARANTIA = ''S'') OR @P_USAGARANTIA = ''N'') AND
      ((a.TASA >= @P_TASADESDE AND a.TASA <= @P_TASAHASTA AND @P_USATASA = ''S'') OR @P_USATASA = ''N'') AND
      ((a.PORCENTAJE_PAGO >= @P_PORCENTAJEPAGO AND @P_USAPORCENTAJE = ''S'') OR @P_USAPORCENTAJE = ''N'') AND
      ((a.VENCIMIENTO >= CONVERT(datetime, @P_VENCIMIENTO, 103) AND @P_USAVENCIMIENTO = ''S'') OR @P_USAVENCIMIENTO = ''N'')
      
    END ')


EXECUTE('
IF OBJECT_ID (''dbo.SP_ACTUALIZA_MOROSOS_SITUACION'') IS NOT NULL
	DROP PROCEDURE dbo.SP_ACTUALIZA_MOROSOS_SITUACION')


EXECUTE('
CREATE PROCEDURE [dbo].[SP_ACTUALIZA_MOROSOS_SITUACION]
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
	@contador NUMERIC(10),
	@contadorLimpiar NUMERIC(10),
	@contadorNoDatos NUMERIC(10)
	SET @contador = 0;
	SET @contadorLimpiar = 0;
	SET @contadorNoDatos = 0;
	------- Campos para el LOG --------
	SET @c_log_tipo_error = ''E'';
	SET @c_log_tipo_informacion = ''I'';
	-----------------------------------	

	BEGIN TRY

		SET @contadorLimpiar =(SELECT count(1) FROM CRE_BCRA_MOREXENT WITH (NOLOCK) WHERE FECHA_PROCESO <> (SELECT FECHAPROCESO FROM PARAMETROS WITH (NOLOCK)) AND TZ_LOCK = 0)   

		SET @contador =	(SELECT count(1)			
		FROM CLI_CLIENTES c WITH (NOLOCK)
		INNER JOIN (SELECT CODIGOCLIENTE FROM CRE_BCRA_MOREXENT WITH (NOLOCK) WHERE FECHA_PROCESO = (SELECT FECHAPROCESO FROM PARAMETROS WITH (NOLOCK)) AND TZ_LOCK = 0) a
		ON a.CODIGOCLIENTE = c.CODIGOCLIENTE
		WHERE c.TZ_LOCK = 0)				
		
		SET @contadorNoDatos = (SELECT count(1) FROM CRE_BCRA_MOREXENT WITH (NOLOCK))   
		
		IF (@contadorLimpiar = 0 AND @contador > 0) OR @contadorNoDatos = 0
		BEGIN		   	
			UPDATE CLI_CLIENTES SET Sit_MorExEnt = '' ''
		END					
        	  				
		IF @contador > 0
		BEGIN		   	
			UPDATE c
			SET c.Sit_MorExEnt  = ''6''
			FROM CLI_CLIENTES c WITH (NOLOCK)
			INNER JOIN (SELECT CODIGOCLIENTE FROM CRE_BCRA_MOREXENT WITH (NOLOCK) WHERE FECHA_PROCESO = (SELECT FECHAPROCESO FROM PARAMETROS WITH (NOLOCK)) AND TZ_LOCK = 0) a
			ON a.CODIGOCLIENTE = c.CODIGOCLIENTE
			WHERE c.TZ_LOCK = 0	
		END
				  
		    SET @p_msg_proceso = ''El Proceso de Actualización de Situacion de Morosos ex Entidades ha finalizado correctamente. Registros procesados: ''+ CONVERT(VARCHAR(10), @contador)
			SET @p_ret_proceso = 1 		
			
			-- Logueo de información
			EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso 
				@p_id_proceso,
		    	@p_dt_proceso,
		    	''SP_ACTUALIZA_MOROSOS_SITUACION'',
		    	@p_cod_error = @p_ret_proceso, 
				@p_msg_error = @p_msg_proceso, 
				@p_tipo_error = @c_log_tipo_informacion
		END TRY
							             
		BEGIN CATCH
	
	        SET @p_ret_proceso = ERROR_NUMBER()
	        SET @p_msg_proceso = ''Ocurrió un error en el Proceso de Actualización de Situacion de Morosos ex Entidades: '' + ERROR_MESSAGE()
	
			EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso 
	        	@p_id_proceso = @p_id_proceso, 
	        	@p_fch_proceso = @p_dt_proceso, 
	        	@p_nom_package = ''SP_ACTUALIZA_MOROSOS_SITUACION'', 
	        	@p_cod_error = @p_ret_proceso, 
	        	@p_msg_error = @p_msg_proceso, 
	       		@p_tipo_error = @c_log_tipo_informacion
		END CATCH
END
')









