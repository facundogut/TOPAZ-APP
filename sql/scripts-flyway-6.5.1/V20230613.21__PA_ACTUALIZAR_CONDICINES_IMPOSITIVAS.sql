
EXECUTE('
CREATE OR ALTER PROCEDURE PA_ACTUALIZAR_CONDICINES_IMPOSITIVAS
   @P_ID_PROCESO 	         FLOAT(53),
   @P_DT_PROCESO	         DATETIME2(0),
   @P_NRO_OPERACION		     NUMERIC(5), --para grabar en bitácora
   @P_CODIGO_CLIENTE	     NUMERIC(12),--cliente y cargo o tipo de cargo para consultar
   @P_NUM_PERSONA            NUMERIC(12),--Numero de persona para conseguir todos los clientes asociados
   @P_TIPO_CARGO_IMPOSITIVO	 NUMERIC(2), --evaluar si tipo de cargo, o directamente el cargo o impuesto y lo obtenemos
   @P_CARGO_O_IMPUESTO		 VARCHAR(6),
   @P_ALICUOTA               NUMERIC(11,7), --para saber si buscar por cargo o impuesto. No tienen por que ser iguales los tipos.
   @P_RET_PROCESO	         NUMERIC(20)  OUTPUT,
   @P_MSG_PROCESO	         varchar(max)  OUTPUT,
   @P_ACTUALIZO              VARCHAR(1) OUTPUT,
   @P_CARGO_O_IMPUESTO_NUEVO VARCHAR(6) OUTPUT,
   @P_ALICUOTA_MAS_ALTA      NUMERIC(11,7) OUTPUT,
   @P_PERSONA_MG			 NUMERIC(12) OUTPUT -- Persona mas Gravosa
   
AS 

   BEGIN

      SET @P_RET_PROCESO = NULL
      SET @P_MSG_PROCESO = NULL
      
      SELECT @P_DT_PROCESO = FECHAPROCESO FROM PARAMETROS;
      
      DECLARE
      
      	@v_constante VARCHAR(1), --ESTA VARIABLE SE DEVUELVE COMO TIPO DE ERROR EN EL CATCH. 
      							 --SE SUPONE QUE NOSOTROS LA MODIFIQUEMOS? VER USO EN OTROS SP
      
      --DECLARE Y SET DE VARIABLES
        
        @v_regimen_actual VARCHAR(2),
        @v_tasa_actual    NUMERIC(11,6),
        @v_regimen_gravoso VARCHAR(2),
        @v_tasa_gravoso    NUMERIC(11,6),
        @v_persona_gravosa       NUMERIC(12),
        @v_regimen_nuevo VARCHAR(2),
        @v_tasa_nueva    NUMERIC(11,6),
        @v_persona       NUMERIC(12),
        @v_fecha         DATETIME,
        @v_hora			 VARCHAR(8),
        @CANT            NUMERIC(10)
      ------------------------------------------------------------
      
      --BÚSQUEDA DE DATOS Y USO DE TABLAS TEMPORALES     
      		
      		--si parámetro de cargo es el impuesto, buscar el tipo cargo impositivo que le corresponde
      		--si no se ingresa uno (parámetro = -1), hacer los siguientes puntos para todos los tipos cargo impositivos del cliente
      		--si no se ingresa cliente (parámetro = -1), hacerlo para todos los clientes
      		--determinar, para el tipo_cargo_impositivo, cuál es la condición que le corresponde y cuál es la persona que le da esa condición
      		--buscar, para el tipo_Cargo_impositivo, el último registro en la bitácora para saber cuál es la condición y la persona que le da esa condición
      		--si cambia la condición, o la persona, ingresar un nuevo registro en la bitácora.
      		--si cambia la condición, evaluar si el registro de CLI_CLIENTES, CLI_PERSONASFISICAS/JURIDICAS o de SALDOS está actualizado, o necesita un update.
           
            -- IMPUESTOS DONDE SE BUSCA POR MAS GRAVOSO     SIRCREB 05 - IIBB 08, 09
      
    --  BEGIN
      
        IF @P_TIPO_CARGO_IMPOSITIVO = 5
        
        
         BEGIN 
        --  SET @v_sircreb_nuevo=@P_CARGO_O_IMPUESTO
         --consulto tasa del valor que vien de la ope
            SELECT DISTINCT @v_tasa_nueva=CT.TASA, @v_regimen_nuevo=CT.SEGMENTO
              FROM CI_CARGOS_TARIFAS CT 
              INNER JOIN CI_CARGOS H ON H.ID_CARGO = CT.ID_CARGO
                                   AND H.TIPO_CARGO_IMPOSITIVO = 5
                                   AND H.TZ_LOCK = 0
              AND CT.SEGMENTO = @P_CARGO_O_IMPUESTO                     
              AND CT.TZ_LOCK = 0
              
         --consulto valores mas gravosos de la Persona y cliente previo al cambio
         
           SELECT TOP 1 @v_tasa_gravoso=t.tasa, @v_regimen_gravoso=T.SIRCREB, @v_persona_gravosa=T.PERSONA,
                        @v_fecha = T.FECHA_PROCESO, @v_hora=T.HORA FROM
				(
				  (
				    SELECT DISTINCT CF.SIRCREB, CF.NUMEROPERSONAFISICA AS "PERSONA", CT.TASA, CBI.FECHA_PROCESO, CBI.HORA 
				     FROM CLI_PERSONASFISICAS CF WITH (NOLOCK)
				     INNER JOIN CLI_ClientePersona CP ON CP.NUMEROPERSONA = cf.NUMEROPERSONAFISICA
				                                  AND CP.CODIGOCLIENTE = @P_CODIGO_CLIENTE
				                                  AND CP.TZ_LOCK = 0
				                                  
				     INNER JOIN CI_CARGOS_TARIFAS CT  ON CF.SIRCREB = CT.SEGMENTO
				                                     AND CT.TZ_LOCK = 0
				                                     AND CT.ID_CLIENTE=0
				                                     AND CT.ID_CARGO = (SELECT ID_CARGO FROM CI_CARGOS
				                                                            WHERE TIPO_CARGO_IMPOSITIVO = 5
				                                                              AND TZ_LOCK = 0)
				           JOIN con_bitacora_impuestos CBI ON CBI.ID_PERSONA = cf.NUMEROPERSONAFISICA
				                                       AND CBI.ID_CARGO_IMPUESTO IS NULL                                                    
				     WHERE CF.TZ_LOCK = 0
				       AND CF.SIRCREB !=''''
				  )
				  UNION ALL
				  (
				    SELECT distinct CJ.SIRCREB, CJ.NUMEROPERSONAJURIDICA AS "PERSONA", CT.TASA, CBI.FECHA_PROCESO, CBI.HORA 
				  FROM CLI_PERSONASJURIDICAS CJ WITH (NOLOCK)
				   
				 INNER JOIN CLI_ClientePersona CP ON CP.NUMEROPERSONA = CJ.NUMEROPERSONAJURIDICA 
				                                  AND CP.CODIGOCLIENTE = @P_CODIGO_CLIENTE
				                                  AND CP.TZ_LOCK = 0
				 INNER JOIN CI_CARGOS_TARIFAS CT  ON CJ.SIRCREB = CT.SEGMENTO
				                                  AND CT.TZ_LOCK = 0
				                                  AND CT.ID_CLIENTE=0
				                                            AND CT.ID_CARGO = (SELECT ID_CARGO FROM CI_CARGOS
				                                                            WHERE TIPO_CARGO_IMPOSITIVO = 5
				                                                              AND TZ_LOCK = 0)
				        JOIN con_bitacora_impuestos CBI ON CBI.ID_PERSONA = CJ.NUMEROPERSONAJURIDICA
				                                       AND CBI.ID_CARGO_IMPUESTO IS NULL
				 WHERE CJ.TZ_LOCK = 0
				   AND CJ.SIRCREB !=''''
				                                                          
				  )
				)t
				GROUP BY t.tasa,T.sircreb,T.PERSONA, T.FECHA_PROCESO, T.HORA 
				ORDER BY 1 DESC, 4 DESC, 5 DESC
         
         
         
         --consulto valores sircreb personas del cliente y me quedo con el mas gravoso
            
            SELECT TOP 1 @v_tasa_actual=t.tasa, @v_regimen_actual=T.SIRCREB, @v_persona=T.PERSONA FROM
				(
				  (
				    SELECT DISTINCT CF.SIRCREB, CF.NUMEROPERSONAFISICA AS "PERSONA", CT.TASA
				     FROM CLI_PERSONASFISICAS CF WITH (NOLOCK)
				     INNER JOIN CLI_ClientePersona CP ON CP.NUMEROPERSONA = cf.NUMEROPERSONAFISICA
				                                  AND CP.CODIGOCLIENTE = @P_CODIGO_CLIENTE
				                                  AND CP.TZ_LOCK = 0
				                                  AND CP.NUMEROPERSONA NOT IN (@P_NUM_PERSONA)
				     INNER JOIN CI_CARGOS_TARIFAS CT  ON CF.SIRCREB = CT.SEGMENTO
				                                     AND CT.TZ_LOCK = 0
				                                     AND CT.ID_CLIENTE=0
				                                     AND CT.ID_CARGO = (SELECT ID_CARGO FROM CI_CARGOS
				                                                            WHERE TIPO_CARGO_IMPOSITIVO = 5
				                                                              AND TZ_LOCK = 0)
				     WHERE CF.TZ_LOCK = 0
				       AND CF.SIRCREB !=''''
				  )
				  UNION ALL
				  (
				    SELECT distinct CJ.SIRCREB, CJ.NUMEROPERSONAJURIDICA AS "PERSONA", CT.TASA 
				  FROM CLI_PERSONASJURIDICAS CJ WITH (NOLOCK)
				   
				 INNER JOIN CLI_ClientePersona CP ON CP.NUMEROPERSONA = CJ.NUMEROPERSONAJURIDICA 
				                                  AND CP.CODIGOCLIENTE = @P_CODIGO_CLIENTE
				                                  AND CP.NUMEROPERSONA NOT IN (@P_NUM_PERSONA)
				                                  AND CP.TZ_LOCK = 0
				 INNER JOIN CI_CARGOS_TARIFAS CT  ON CJ.SIRCREB = CT.SEGMENTO
				                                  AND CT.TZ_LOCK = 0
				                                  AND CT.ID_CLIENTE=0
				                                            AND CT.ID_CARGO = (SELECT ID_CARGO FROM CI_CARGOS
				                                                            WHERE TIPO_CARGO_IMPOSITIVO = 5
				                                                              AND TZ_LOCK = 0)
				 WHERE CJ.TZ_LOCK = 0
				   AND CJ.SIRCREB !=''''
				                                                          
				  )
				)t
				GROUP BY t.tasa,T.sircreb,T.PERSONA
				ORDER BY 1 DESC
          
          
          
          
        BEGIN  
        
               

         IF @v_tasa_nueva > @v_tasa_actual
          BEGIN
            SET @P_ACTUALIZO = ''S'';
            SET @P_CARGO_O_IMPUESTO_NUEVO = @v_regimen_nuevo;
            SET @P_ALICUOTA_MAS_ALTA = NULL;
            SET @P_PERSONA_MG = @P_NUM_PERSONA;
          END
         ELSE
          BEGIN
           IF @v_persona = @v_persona_gravosa 
            BEGIN
	            SET @P_ACTUALIZO = ''X'';
	            SET @P_CARGO_O_IMPUESTO_NUEVO = @v_regimen_actual;
	            SET @P_ALICUOTA_MAS_ALTA = NULL;
	            SET @P_PERSONA_MG = @v_persona;
	          END 
	         ELSE 
	            SET @P_ACTUALIZO = ''N'';
	            SET @P_CARGO_O_IMPUESTO_NUEVO = @v_regimen_actual;
	            SET @P_ALICUOTA_MAS_ALTA = NULL;
	            SET @P_PERSONA_MG = @v_persona;  
          END
         END
          
        END--END DEL BEGIN IMPUESTO 5-SIRCREB
        
       -- BEGIN  
         IF @P_TIPO_CARGO_IMPOSITIVO = 9
          
          BEGIN 
            IF @P_CARGO_O_IMPUESTO != ''AC'' 
               BEGIN
                SET @v_tasa_nueva = 0
               END
            ELSE 
               BEGIN
                SET @v_tasa_nueva = @P_ALICUOTA
               END   
            
            -- Consulto IIBB_CORRIENTES MAS GRAVOSO
            
            SELECT TOP 1 @v_tasa_actual=t.IIBB_CORRIENTES_ALI, @v_regimen_actual=T.IIBB_CORRIENTES_RECAUD, @v_persona=T.PERSONA FROM
				(
				  (
				    SELECT DISTINCT CF.IIBB_CORRIENTES_RECAUD, CF.NUMEROPERSONAFISICA AS "PERSONA", CF.IIBB_CORRIENTES_ALI
				     FROM CLI_PERSONASFISICAS CF WITH (NOLOCK)
				     INNER JOIN CLI_ClientePersona CP ON CP.NUMEROPERSONA = cf.NUMEROPERSONAFISICA
				                                  AND CP.CODIGOCLIENTE = @P_CODIGO_CLIENTE
				                                  AND CP.NUMEROPERSONA NOT IN (@P_NUM_PERSONA)
				                                  AND CP.TZ_LOCK = 0
				     
				     WHERE CF.TZ_LOCK = 0
				       AND CF.IIBB_CORRIENTES_RECAUD !=''''
				  )
				  UNION ALL
				  (
				    SELECT DISTINCT CJ.IIBB_CORRIENTES_RECAUD, CJ.NUMEROPERSONAJURIDICA AS "PERSONA", CJ.IIBB_CORRIENTES_ALI
				  FROM CLI_PERSONASJURIDICAS CJ WITH (NOLOCK)
				   
				 INNER JOIN CLI_ClientePersona CP ON CP.NUMEROPERSONA = CJ.NUMEROPERSONAJURIDICA 
				                                  AND CP.CODIGOCLIENTE = @P_CODIGO_CLIENTE
				                                  AND CP.NUMEROPERSONA NOT IN (@P_NUM_PERSONA)
				                                  AND CP.TZ_LOCK = 0
				 
				 WHERE CJ.TZ_LOCK = 0
				   AND CJ.IIBB_CORRIENTES_RECAUD !=''''
				                                                          
				  )
				)t
				GROUP BY t.IIBB_CORRIENTES_ALI,T.IIBB_CORRIENTES_RECAUD, T.PERSONA
				ORDER BY 1 DESC 
				
			   BEGIN  
        
				               
				      IF @P_CARGO_O_IMPUESTO = ''AC''
				       BEGIN  
				         IF @v_tasa_nueva > @v_tasa_actual
				          BEGIN
				            SET @P_ACTUALIZO = ''S'';
				            SET @P_CARGO_O_IMPUESTO_NUEVO = @P_CARGO_O_IMPUESTO;
				            SET @P_ALICUOTA_MAS_ALTA = @v_tasa_nueva;
				            SET @P_PERSONA_MG = @P_NUM_PERSONA;
				          END
				         ELSE
				          BEGIN
				            SET @P_ACTUALIZO = ''N'';
				            SET @P_CARGO_O_IMPUESTO_NUEVO = @v_regimen_actual;
				            SET @P_ALICUOTA_MAS_ALTA = @v_tasa_actual;
				            SET @P_PERSONA_MG = @v_persona;
				          END
				        END   
				      ELSE   
				         BEGIN  
				         IF @P_CARGO_O_IMPUESTO != @v_regimen_actual
				          BEGIN
				            SET @P_ACTUALIZO = ''S'';
				            SET @P_CARGO_O_IMPUESTO_NUEVO = @P_CARGO_O_IMPUESTO;
				            SET @P_ALICUOTA_MAS_ALTA = 0;
				            SET @P_PERSONA_MG = NULL;
				          END
				         ELSE
				          BEGIN
				            SET @P_ACTUALIZO = ''N'';
				            SET @P_CARGO_O_IMPUESTO_NUEVO = @v_regimen_actual;
				            SET @P_ALICUOTA_MAS_ALTA = @v_tasa_actual;
				            SET @P_PERSONA_MG = NULL;
				          END
				        END  
      
      
       
          
          
             END	
				
				
           
          END
        IF @P_TIPO_CARGO_IMPOSITIVO = 8
          
          BEGIN 
            IF @P_CARGO_O_IMPUESTO != ''AC'' 
               BEGIN
                SET @v_tasa_nueva = 0
               END
            ELSE 
               BEGIN
                SET @v_tasa_nueva = @P_ALICUOTA
               END   
            
            -- Consulto IIBB_CORRIENTES MAS GRAVOSO
            
            SELECT TOP 1 @v_tasa_actual=t.IIBB_CABA_PERCEPCION_ALI, @v_regimen_actual=T.IIBB_CABA_PERCEPCION_COND,@v_persona=T.PERSONA FROM
				(
				  (
				    SELECT DISTINCT CF.IIBB_CABA_PERCEPCION_COND, CF.NUMEROPERSONAFISICA AS "PERSONA", CF.IIBB_CABA_PERCEPCION_ALI
				     FROM CLI_PERSONASFISICAS CF WITH (NOLOCK)
				     INNER JOIN CLI_ClientePersona CP ON CP.NUMEROPERSONA = cf.NUMEROPERSONAFISICA
				                                  AND CP.CODIGOCLIENTE = @P_CODIGO_CLIENTE
				                                  AND CP.NUMEROPERSONA NOT IN (@P_NUM_PERSONA)
				                                  AND CP.TZ_LOCK = 0
				     
				     WHERE CF.TZ_LOCK = 0
				       AND CF.IIBB_CABA_PERCEPCION_COND !=''''
				  )
				  UNION ALL
				  (
				    SELECT DISTINCT CJ.IIBB_CABA_PERCEPCION_COND, CJ.NUMEROPERSONAJURIDICA AS "PERSONA", CJ.IIBB_CABA_PERCEPCION_ALI
				  FROM CLI_PERSONASJURIDICAS CJ WITH (NOLOCK)
				   
				 INNER JOIN CLI_ClientePersona CP ON CP.NUMEROPERSONA = CJ.NUMEROPERSONAJURIDICA 
				                                  AND CP.CODIGOCLIENTE = @P_CODIGO_CLIENTE
				                                  AND CP.NUMEROPERSONA NOT IN (@P_NUM_PERSONA)
				                                  AND CP.TZ_LOCK = 0
				 
				 WHERE CJ.TZ_LOCK = 0
				   AND CJ.IIBB_CABA_PERCEPCION_COND !=''''
				                                                          
				  )
				)t
				GROUP BY t.IIBB_CABA_PERCEPCION_ALI,T.IIBB_CABA_PERCEPCION_COND, T.PERSONA
				ORDER BY 1 DESC 
				
			   BEGIN  
        
				               
				      IF @P_CARGO_O_IMPUESTO = ''AC''
				       BEGIN  
				         IF @v_tasa_nueva > @v_tasa_actual
				          BEGIN
				            SET @P_ACTUALIZO = ''S'';
				            SET @P_CARGO_O_IMPUESTO_NUEVO = @P_CARGO_O_IMPUESTO;
				            SET @P_ALICUOTA_MAS_ALTA = @v_tasa_nueva;
				            SET @P_PERSONA_MG = @P_NUM_PERSONA;
				          END
				         ELSE
				          BEGIN
				            SET @P_ACTUALIZO = ''N'';
				            SET @P_CARGO_O_IMPUESTO_NUEVO = @v_regimen_actual;
				            SET @P_ALICUOTA_MAS_ALTA = @v_tasa_actual;
				            SET @P_PERSONA_MG = @v_persona;
				          END
				        END   
				      ELSE   
				         BEGIN  
				         IF @P_CARGO_O_IMPUESTO != @v_regimen_actual
				          BEGIN
				            SET @P_ACTUALIZO = ''S'';
				            SET @P_CARGO_O_IMPUESTO_NUEVO = @P_CARGO_O_IMPUESTO;
				            SET @P_ALICUOTA_MAS_ALTA = 0;
				            SET @P_PERSONA_MG = NULL;
				          END
				         ELSE
				          BEGIN
				            SET @P_ACTUALIZO = ''N'';
				            SET @P_CARGO_O_IMPUESTO_NUEVO = @v_regimen_actual;
				            SET @P_ALICUOTA_MAS_ALTA = @v_tasa_actual;
				            SET @P_PERSONA_MG = NULL;
				          END
				        END  
      
      
       
          
          
             END	
				
				
           
          END    
          
          IF @P_TIPO_CARGO_IMPOSITIVO = 12
          
          BEGIN 
            IF @P_CARGO_O_IMPUESTO != ''AC'' 
               BEGIN
                SET @v_tasa_nueva = 0
               END
            ELSE 
               BEGIN
                SET @v_tasa_nueva = @P_ALICUOTA
               END   
            
            -- Consulto IIBB_CORRIENTES MAS GRAVOSO
            
            SELECT TOP 1 @v_tasa_actual=t.IIBB_CABA_RETENCION_ALI, @v_regimen_actual=T.IIBB_CABA_RETENCION_COND,@v_persona=T.PERSONA FROM
				(
				  (
				    SELECT DISTINCT CF.IIBB_CABA_RETENCION_COND, CF.NUMEROPERSONAFISICA AS "PERSONA", CF.IIBB_CABA_RETENCION_ALI
				     FROM CLI_PERSONASFISICAS CF WITH (NOLOCK)
				     INNER JOIN CLI_ClientePersona CP ON CP.NUMEROPERSONA = cf.NUMEROPERSONAFISICA
				                                  AND CP.CODIGOCLIENTE = @P_CODIGO_CLIENTE
				                                  AND CP.NUMEROPERSONA NOT IN (@P_NUM_PERSONA)
				                                  AND CP.TZ_LOCK = 0
				     
				     WHERE CF.TZ_LOCK = 0
				       AND CF.IIBB_CABA_RETENCION_COND !=''''
				  )
				  UNION ALL
				  (
				    SELECT DISTINCT CJ.IIBB_CABA_RETENCION_COND, CJ.NUMEROPERSONAJURIDICA AS "PERSONA", CJ.IIBB_CABA_RETENCION_ALI
				  FROM CLI_PERSONASJURIDICAS CJ WITH (NOLOCK)
				   
				 INNER JOIN CLI_ClientePersona CP ON CP.NUMEROPERSONA = CJ.NUMEROPERSONAJURIDICA 
				                                  AND CP.CODIGOCLIENTE = @P_CODIGO_CLIENTE
				                                  AND CP.NUMEROPERSONA NOT IN (@P_NUM_PERSONA)
				                                  AND CP.TZ_LOCK = 0
				 
				 WHERE CJ.TZ_LOCK = 0
				   AND CJ.IIBB_CABA_RETENCION_COND !=''''                                                       
				  )
				)t
				GROUP BY t.IIBB_CABA_RETENCION_ALI,T.IIBB_CABA_RETENCION_COND, t.PERSONA
				ORDER BY 1 DESC 
				
			   BEGIN  
        
				 				               
				      IF @P_CARGO_O_IMPUESTO = ''AC''
				       BEGIN  
				         IF @v_tasa_nueva > @v_tasa_actual
				          BEGIN
				            SET @P_ACTUALIZO = ''S'';
				            SET @P_CARGO_O_IMPUESTO_NUEVO = @P_CARGO_O_IMPUESTO;
				            SET @P_ALICUOTA_MAS_ALTA = @v_tasa_nueva;
				            SET @P_PERSONA_MG = @P_NUM_PERSONA;
				          END
				         ELSE
				          BEGIN
				            SET @P_ACTUALIZO = ''N'';
				            SET @P_CARGO_O_IMPUESTO_NUEVO = @v_regimen_actual;
				            SET @P_ALICUOTA_MAS_ALTA = @v_tasa_actual;
				            SET @P_PERSONA_MG = @v_persona;
				          END
				        
				        END   
				      ELSE   
				         BEGIN  
				         IF @P_CARGO_O_IMPUESTO != @v_regimen_actual
				          BEGIN
				            SET @P_ACTUALIZO = ''S'';
				            SET @P_CARGO_O_IMPUESTO_NUEVO = @P_CARGO_O_IMPUESTO;
				            SET @P_ALICUOTA_MAS_ALTA = 0;
				            SET @P_PERSONA_MG = NULL;
				          END
				         ELSE
				          BEGIN
				            SET @P_ACTUALIZO = ''N'';
				            SET @P_CARGO_O_IMPUESTO_NUEVO = @v_regimen_actual;
				            SET @P_ALICUOTA_MAS_ALTA = @v_tasa_actual;
				            SET @P_PERSONA_MG = NULL;
				          END
				        END  
      
            END
          END 
       --END--END IF IMPUESTO
         
        
         
      
      ---------------------------------

      BEGIN TRANSACTION

      BEGIN TRY

      
      
      SET @P_RET_PROCESO = 1;
	  SET @P_MSG_PROCESO = ''Se evaluo la condicion del impuesto''
	  
	  EXECUTE dbo.pkg_constantes$VarcharConstantes ''C_LOG_TIPO_INFORMACION'', @v_constante OUTPUT;
	  
	  EXECUTE dbo.PKG_LOG_PROCESO$PROC_INS_LOG_PROCESO 
	       @P_ID_PROCESO =  123456,--@P_ID_PROCESO, --,
	       @P_FCH_PROCESO = @P_DT_PROCESO, --''20231004'',
	       @P_NOM_PACKAGE = ''PA_ACTUALIZAR_CONDICINES_IMPOSITIVAS'', 
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
               @p_nom_package = ''PA_ACTUALIZAR_CONDICIONES_IMPOSITIVAS'', 
               @p_cod_error = @p_ret_proceso, 
               @p_msg_error = @p_msg_proceso, 
               @p_tipo_error = @v_constante

         END

      END CATCH

   
   END

')
