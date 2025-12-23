EXECUTE('
CREATE OR ALTER PROCEDURE PA_ACTUASALDOSCAMPANIA
   @P_ID_PROCESO float(53), /* Identificador de proceso*/
   @P_DT_PROCESO datetime2(0), /* Fecha de proceso*/

   @P_RET_PROCESO float(53)  OUTPUT, /* Estado de ejecucion del PL/SQL(1:Correcto, 2: Error)*/
   @P_MSG_PROCESO varchar(max)  OUTPUT
AS 
   BEGIN
      SET @P_RET_PROCESO = NULL
      SET @P_MSG_PROCESO = NULL
     /*
      *    
      *   El proceso se queda con todos los saldos con campaña distinta de 0, y que ya esta vencida
      *
      */
      
      -- Tablas auxiliares --
      
	    DECLARE @TMPSaldosCampaniasPaqNoDefault      TABLE(
								    				   		JTS_OID 		FLOAT (53),
															CAMPANIA 		FLOAT (53),
													  		PAQUETE 		FLOAT (53),
											   				CAMPANIA_ANT 	FLOAT (53),
											   				GRUPO			FLOAT (53),
											   				CLIENTE			FLOAT (53),
											   				GRUPOCAMPANIA	VARCHAR (max),
											   				PRODUCTO		FLOAT (53),
											   				TIPOCTA			FLOAT (53),
											   				MONEDA	   		FLOAT (53)	
													  	  )
													  	  
		DECLARE @TMPSaldosCampaniasPaqDefault        TABLE(
								    				   		JTS_OID 		FLOAT (53),
															CAMPANIA 		FLOAT (53),
													  		PAQUETE 		FLOAT (53),
											   				CAMPANIA_ANT 	FLOAT (53),
											   				GRUPO			FLOAT (53),
											   				CLIENTE			FLOAT (53),
											   				GRUPOCAMPANIA	VARCHAR (max),
											   				PRODUCTO		FLOAT (53),
											   				TIPOCTA			FLOAT (53),
											   				MONEDA	   		FLOAT (53)	
													  	  )
													  	  
		
	 -- Cargo Tablas auxiliares --
	 
	 	INSERT INTO @TMPSaldosCampaniasPaqNoDefault
	 			    SELECT 
			               S.JTS_OID AS JTS_OID, 
			               S.C1771 AS CAMPANIA, 
			               S.C1770 AS PAQUETE, 
			               S.C1666 AS CAMPANIA_ANT, 
			               S.C1772 AS GRUPO, 
			               S.C1803 AS CLIENTE, 
			               C.GRUPO AS GRUPOCAMPANIA, 
			               S.PRODUCTO AS PRODUCTO, 
			               S.C1785 AS TIPOCTA, 
			               S.MONEDA AS MONEDA
			            FROM SALDOS  AS S with (nolock)
						INNER JOIN CLI_CAMPANIAS  AS C with (nolock)ON S.C1771 = C.COD_CAMPANIA
																		AND S.C1771 <> 0
																		AND (
																			  SELECT PARAMETROS.FECHAPROCESO
																			  FROM PARAMETROS with (nolock)
																		   	) > C.VIGENCIA_HASTA 
																		AND C.TZ_LOCK = 0 
																		AND S.TZ_LOCK = 0
																		AND S.C1770<>100
																		   
		INSERT INTO @TMPSaldosCampaniasPaqDefault
	 			    SELECT 
			               S.JTS_OID AS JTS_OID, 
			               S.C1771 AS CAMPANIA, 
			               S.C1770 AS PAQUETE, 
			               S.C1666 AS CAMPANIA_ANT, 
			               S.C1772 AS GRUPO, 
			               S.C1803 AS CLIENTE, 
			               C.GRUPO AS GRUPOCAMPANIA, 
			               S.PRODUCTO AS PRODUCTO, 
			               S.C1785 AS TIPOCTA, 
			               S.MONEDA AS MONEDA
			            FROM SALDOS  AS S with (nolock)
						INNER JOIN CLI_CAMPANIAS  AS C with (nolock)ON S.C1771 = C.COD_CAMPANIA
																		AND S.C1771 <> 0
																		AND (
																			  SELECT PARAMETROS.FECHAPROCESO
																			  FROM PARAMETROS with (nolock)
																		   	) > C.VIGENCIA_HASTA 
																		AND C.TZ_LOCK = 0 
																		AND S.TZ_LOCK = 0
																		AND S.C1770=100
		
	  -- Declaración de Variables para condicionar resultados
	  																	   
	  DECLARE
         @CAMPANIAAUX_ 			float(53),
         @GRUPOCAMPANIAAUX 		float(53),
         @GRUPOAUX_ 			float(53),
         @PROCESO_OK_ 			float(53),
         @CANTCAMPNODEF_ 		float(53),
         @CANTCAMPNODEF_CV 		float(53),
         @CANTCAMPNODEF_NOCV 	float(53),
         @CANTCAMPDEF_ 			float(53),
         @CANTCAMP_ 			FLOAT(53) = 0
         
         SET @CAMPANIAAUX_ = 0
                        
                        SELECT @CAMPANIAAUX_ = cp.COD_CAMPANIA
                        FROM CLI_CLIENTES_PAQUETES cp with (nolock)
                        INNER JOIN @TMPSaldosCampaniasPaqNoDefault sc ON sc.CLIENTE = cp.COD_CLIENTE
                        											 AND sc.PAQUETE = cp.COD_PAQUETE
                        WHERE cp.TZ_LOCK = 0  
                        
                        
		SET @GRUPOCAMPANIAAUX = ISNULL((SELECT COUNT(*) FROM @TMPSaldosCampaniasPaqNoDefault 
												WHERE GRUPOCAMPANIA=GRUPO),0)
      														   
	    SET @CANTCAMPNODEF_CV = ISNULL(( SELECT COUNT(*) FROM SALDOS s
                        		    	 INNER JOIN @TMPSaldosCampaniasPaqNoDefault sc ON sc.JTS_OID = s.JTS_OID
                        						WHERE s.C1785 IN ( 1, 2, 3 ) ),0)
      														      
        SET @CANTCAMPNODEF_NOCV = ISNULL(( SELECT COUNT(*) FROM SALDOS s
                        		      	   INNER JOIN @TMPSaldosCampaniasPaqNoDefault sc ON sc.JTS_OID = s.JTS_OID
                        			  	   		WHERE s.C1785 NOT IN ( 1, 2, 3 ) ),0)
                        			  
        SET @CANTCAMPDEF_ = ISNULL(( SELECT COUNT(*) FROM SALDOS s
                        		     INNER JOIN @TMPSaldosCampaniasPaqDefault sc ON sc.JTS_OID = s.JTS_OID),0)
                        			
        SET @CANTCAMPNODEF_ = @CANTCAMPNODEF_CV + @CANTCAMPNODEF_NOCV
        
        SET @CANTCAMP_= @CANTCAMPNODEF_ + @CANTCAMPDEF_

             		        			 
                BEGIN TRY
                
                	 BEGIN
                	 		/* Si el paquete no es default*/
		                     
		                        IF @CAMPANIAAUX_ = 0 OR @GRUPOCAMPANIAAUX>0
		                        
		                           SELECT @GRUPOAUX_ = pp.GRUPO
		                           FROM CLI_PAQUETE_PRODUCTOS pp with (nolock)
		                           INNER JOIN @TMPSaldosCampaniasPaqNoDefault sc ON sc.PRODUCTO = pp.PRODUCTO 
		                           			   									 AND sc.PAQUETE= pp.COD_PAQUETE 
		                         			   									 AND sc.MONEDA= pp.MONEDA
		                           WHERE 
		                              pp.TZ_LOCK = 0
		
			                    UPDATE pp
			                    SET pp.COD_CAMPANIA = 0
			                    FROM CLI_CLIENTES_PAQUETES pp
			                    INNER JOIN @TMPSaldosCampaniasPaqNoDefault sc ON sc.CLIENTE= pp.COD_CLIENTE 
			                           			   							 AND sc.PAQUETE= pp.COD_PAQUETE 
		                        WHERE 
			                          pp.TZ_LOCK = 0  

            
                     END
                       
                     BEGIN

		                        UPDATE s
		                           SET 
		                              s.C1666 = sc.CAMPANIA_ANT, 
		                              s.C1771 = 0, 
		                              s.C1772 = @GRUPOAUX_
		                         FROM SALDOS s
		                         INNER JOIN @TMPSaldosCampaniasPaqNoDefault sc ON sc.JTS_OID = s.JTS_OID
		                         WHERE s.C1785 IN ( 1, 2, 3 )  

  			  	 	 END

                 	 BEGIN
                        
                      		    UPDATE s
		                           SET 
		                              C1666 = sc.CAMPANIA_ANT, 
		                              C1771 = 0 
		                         FROM SALDOS s
		                         INNER JOIN @TMPSaldosCampaniasPaqNoDefault sc ON sc.JTS_OID = s.JTS_OID
		                         WHERE s.C1785 NOT IN ( 1, 2, 3 ) 

                	 END
                  
                 	 BEGIN
							/* Si el paquete es el por default*/
          
		                         UPDATE s
		                           SET 
		                              s.C1666 = sc.CAMPANIA_ANT, 
		                              s.C1771 = 0, 
		                              s.C1772 = 0
		                         FROM SALDOS s
		                         INNER JOIN @TMPSaldosCampaniasPaqDefault sc ON sc.JTS_OID = s.JTS_OID

                  	 END 
                  	 
			           BEGIN
			
			            SET @P_RET_PROCESO = 1
			
			            SET @P_MSG_PROCESO = ''Actualizacion de Saldos de Campaña Finalizo Correctamente''
			
			            DECLARE
			               @PKG_CONSTANTES$C_LOG_TIPO_INFORMACION$5 varchar(8000)
			               
			               SET @PKG_CONSTANTES$C_LOG_TIPO_INFORMACION$5 = ''I''
			
			            EXECUTE PKG_LOG_PROCESO$PROC_INS_LOG_PROCESO 
			               @P_ID_PROCESO = @P_ID_PROCESO, 
			               @P_FCH_PROCESO = @P_DT_PROCESO, 
			               @P_NOM_PACKAGE = ''ACTUASALDOSCAMPANIA'', 
			               @P_COD_ERROR = @P_RET_PROCESO, 
			               @P_MSG_ERROR = @P_MSG_PROCESO, 
			               @P_TIPO_ERROR = @PKG_CONSTANTES$C_LOG_TIPO_INFORMACION$5
			         END
			         
			         
					 BEGIN
					 
					   SET @P_RET_PROCESO = 1
					 
			           SET @P_MSG_PROCESO = ''Se actualizaron '' + ISNULL(CAST(@CANTCAMP_ AS nvarchar(max)), '''') + '' campañas en saldos''
			
			            DECLARE
			               @PKG_CONSTANTES$C_LOG_TIPO_INFORMACION$6 varchar(8000)
			               
			               SET @PKG_CONSTANTES$C_LOG_TIPO_INFORMACION$6 = ''I''
			
			    
			            EXECUTE PKG_LOG_PROCESO$PROC_INS_LOG_PROCESO 
			               @P_ID_PROCESO = @P_ID_PROCESO, 
			               @P_FCH_PROCESO = @P_DT_PROCESO, 
			               @P_NOM_PACKAGE = ''ACTUASALDOSCAMPANIA'', 
			               @P_COD_ERROR = @P_RET_PROCESO, 
			               @P_MSG_ERROR = @P_MSG_PROCESO, 
			               @P_TIPO_ERROR = @PKG_CONSTANTES$C_LOG_TIPO_INFORMACION$6
			
			         END          
            

              END TRY
              
              BEGIN CATCH
              	BEGIN	
         
				  SET @P_RET_PROCESO = 3
					
				  SET @P_MSG_PROCESO = ''Actualizacion de Saldos de Campaña Finalizo con Errores''
					         
				  DECLARE
					@PKG_CONSTANTES$C_LOG_TIPO_INFORMACION$4 varchar(8000)
					
					SET @PKG_CONSTANTES$C_LOG_TIPO_INFORMACION$4 = ''E''
							
				  EXECUTE dbo.PKG_LOG_PROCESO$PROC_INS_LOG_PROCESO 
					@P_ID_PROCESO = @P_ID_PROCESO, 
					@P_FCH_PROCESO = @P_DT_PROCESO, 
					@P_NOM_PACKAGE = ''ACTUASALDOSCAMPANIA - Error'', 
					@P_COD_ERROR = @P_RET_PROCESO, 
					@P_MSG_ERROR = @P_MSG_PROCESO, 
					@P_TIPO_ERROR = @PKG_CONSTANTES$C_LOG_TIPO_INFORMACION$4
					
				END
              END CATCH
																	  

   END
')

