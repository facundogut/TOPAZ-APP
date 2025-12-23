EXECUTE('

ALTER PROCEDURE [dbo].[PA_ACTUASALDOSCAMPANIA]  
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
			            FROM dbo.SALDOS  AS S with (nolock)
						INNER JOIN dbo.CLI_CAMPANIAS  AS C with (nolock)ON S.C1771 = C.COD_CAMPANIA
																		AND S.C1771 <> 0
																		AND (
																			  SELECT PARAMETROS.FECHAPROCESO
																			  FROM dbo.PARAMETROS with (nolock)
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
			            FROM dbo.SALDOS  AS S with (nolock)
						INNER JOIN dbo.CLI_CAMPANIAS  AS C with (nolock)ON S.C1771 = C.COD_CAMPANIA
																		AND S.C1771 <> 0
																		AND (
																			  SELECT PARAMETROS.FECHAPROCESO
																			  FROM dbo.PARAMETROS with (nolock)
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
                        FROM dbo.CLI_CLIENTES_PAQUETES cp with (nolock)
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
        
        SET @PROCESO_OK_ = 0
             		        			 
                BEGIN
                
                	 BEGIN
                	 		/* Si el paquete no es default*/
                	 			
		                     BEGIN TRY
		                     
		                        IF @CAMPANIAAUX_ = 0 OR @GRUPOCAMPANIAAUX>0
		                        
		                           SELECT @GRUPOAUX_ = pp.GRUPO
		                           FROM dbo.CLI_PAQUETE_PRODUCTOS pp with (nolock)
		                           INNER JOIN @TMPSaldosCampaniasPaqNoDefault sc ON sc.PRODUCTO = pp.PRODUCTO 
		                           			   									 AND sc.PAQUETE= pp.COD_PAQUETE 
		                         			   									 AND sc.MONEDA= pp.MONEDA
		                           WHERE 
		                              pp.TZ_LOCK = 0
		
			                    UPDATE pp
			                    SET pp.COD_CAMPANIA = 0
			                    FROM dbo.CLI_CLIENTES_PAQUETES pp
			                    INNER JOIN @TMPSaldosCampaniasPaqNoDefault sc ON sc.CLIENTE= pp.COD_CLIENTE 
			                           			   							 AND sc.PAQUETE= pp.COD_PAQUETE 
		                        WHERE 
			                          pp.TZ_LOCK = 0  
		
		                     END TRY
		                     
		                     BEGIN CATCH
		                        DECLARE @errornumber int
		                        SET @errornumber = ERROR_NUMBER()
		               			DECLARE @errormessage nvarchar(4000)
		                        SET @errormessage = ERROR_MESSAGE()
								DECLARE @exceptionidentifier nvarchar(4000)
		                        SELECT @exceptionidentifier =  ssma_oracle.db_error_get_oracle_exception_id(@errormessage, @errornumber)
		
		                        BEGIN
		
		                           /* Valores de Retorno.*/
		                           SET @P_RET_PROCESO = 
		                              ssma_oracle.db_error_sqlcode(@exceptionidentifier, @errornumber)
		
		                           SET @P_MSG_PROCESO = 
		                              ssma_oracle.db_error_sqlerrm_0(@exceptionidentifier, @errornumber)
		
		                           SET @PROCESO_OK_ = 1
		
		                           DECLARE
		                              @PKG_CONSTANTES$C_LOG_TIPO_INFORMACION varchar(8000)
		
		                           SET @PKG_CONSTANTES$C_LOG_TIPO_INFORMACION = ssma_oracle.get_pv_varchar(''dbo'', ''PKG_CONSTANTES'', ''C_LOG_TIPO_INFORMACION'')
		
		                           EXECUTE dbo.PKG_LOG_PROCESO$PROC_INS_LOG_PROCESO 
		                              @P_ID_PROCESO = @P_ID_PROCESO, 
		                              @P_FCH_PROCESO = @P_DT_PROCESO, 
		                              @P_NOM_PACKAGE = ''ACTUASALDOSCAMPANIA - Error UPDATE CLI_CLIENTES_PAQUETES'', 
		                              @P_COD_ERROR = @P_RET_PROCESO, 
		                              @P_MSG_ERROR = @P_MSG_PROCESO, 
		                              @P_TIPO_ERROR = @PKG_CONSTANTES$C_LOG_TIPO_INFORMACION
		
		                        END
		
		                     END CATCH
                     
                     END  
                     BEGIN

                    	 BEGIN TRY
		                        UPDATE s
		                           SET 
		                              s.C1666 = sc.CAMPANIA_ANT, 
		                              s.C1771 = 0, 
		                              s.C1772 = @GRUPOAUX_
		                         FROM SALDOS s
		                         INNER JOIN @TMPSaldosCampaniasPaqNoDefault sc ON sc.JTS_OID = s.JTS_OID
		                         WHERE s.C1785 IN ( 1, 2, 3 )  
                        

                    	 END TRY

                    	 BEGIN CATCH

		                        DECLARE
		                           @errornumber$2 int
		
		                        SET @errornumber$2 = ERROR_NUMBER()
		
		                        DECLARE
		                           @errormessage$2 nvarchar(4000)
		
		                        SET @errormessage$2 = ERROR_MESSAGE()
		
		                        DECLARE
		                           @exceptionidentifier$2 nvarchar(4000)
		
		                        SELECT @exceptionidentifier$2 = 
		                           ssma_oracle.db_error_get_oracle_exception_id(@errormessage$2, @errornumber$2)
		
		                        BEGIN
		
		                           /* Valores de Retorno.*/
		                           SET @P_RET_PROCESO = 
		                              ssma_oracle.db_error_sqlcode(@exceptionidentifier$2, @errornumber$2)
		
		                           SET @P_MSG_PROCESO = 
		                              ssma_oracle.db_error_sqlerrm_0(@exceptionidentifier$2, @errornumber$2)
		
		                           SET @PROCESO_OK_ = 1
		
		                           DECLARE
		                              @PKG_CONSTANTES$C_LOG_TIPO_INFORMACION$2 varchar(8000)
		
		                           SET @PKG_CONSTANTES$C_LOG_TIPO_INFORMACION$2 = ssma_oracle.get_pv_varchar(''dbo'', ''PKG_CONSTANTES'', ''C_LOG_TIPO_INFORMACION'')
		
		                           EXECUTE dbo.PKG_LOG_PROCESO$PROC_INS_LOG_PROCESO 
		                              @P_ID_PROCESO = @P_ID_PROCESO, 
		                              @P_FCH_PROCESO = @P_DT_PROCESO, 
		                              @P_NOM_PACKAGE = ''ACTUASALDOSCAMPANIA - Error UPDATE SALDOS CAMPANIA SALDOS 1 2 3'', 
		                              @P_COD_ERROR = @P_RET_PROCESO, 
		                              @P_MSG_ERROR = @P_MSG_PROCESO, 
		                              @P_TIPO_ERROR = @PKG_CONSTANTES$C_LOG_TIPO_INFORMACION$2
		
		                        END

                    	 END CATCH

  			  	 	 END

                 	 BEGIN

                    		 BEGIN TRY
                        
                      		    UPDATE s
		                           SET 
		                              C1666 = sc.CAMPANIA_ANT, 
		                              C1771 = 0 
		                         FROM SALDOS s
		                         INNER JOIN @TMPSaldosCampaniasPaqNoDefault sc ON sc.JTS_OID = s.JTS_OID
		                         WHERE s.C1785 NOT IN ( 1, 2, 3 ) 
                         
                     		END TRY

                     		BEGIN CATCH

		                        DECLARE
		                           @errornumber$3 int
		
		                        SET @errornumber$3 = ERROR_NUMBER()
		
		                        DECLARE
		                           @errormessage$3 nvarchar(4000)
		
		                        SET @errormessage$3 = ERROR_MESSAGE()
		
		                        DECLARE
		                           @exceptionidentifier$3 nvarchar(4000)
		
		                        SELECT @exceptionidentifier$3 = 
		                           ssma_oracle.db_error_get_oracle_exception_id(@errormessage$3, @errornumber$3)
		
		                        BEGIN
		
		                           /* Valores de Retorno.*/
		                           SET @P_RET_PROCESO = 
		                              ssma_oracle.db_error_sqlcode(@exceptionidentifier$3, @errornumber$3)
		
		                           SET @P_MSG_PROCESO = 
		                              ssma_oracle.db_error_sqlerrm_0(@exceptionidentifier$3, @errornumber$3)
		
		                           SET @PROCESO_OK_ = 1
		
		                           DECLARE
		                              @PKG_CONSTANTES$C_LOG_TIPO_INFORMACION$3 varchar(8000)
		
		                           SET @PKG_CONSTANTES$C_LOG_TIPO_INFORMACION$3 = ssma_oracle.get_pv_varchar(''dbo'', ''PKG_CONSTANTES'', ''C_LOG_TIPO_INFORMACION'')
		
		                           EXECUTE dbo.PKG_LOG_PROCESO$PROC_INS_LOG_PROCESO 
		                              @P_ID_PROCESO = @P_ID_PROCESO, 
		                              @P_FCH_PROCESO = @P_DT_PROCESO, 
		                              @P_NOM_PACKAGE = ''ACTUASALDOSCAMPANIA - Error UPDATE SALDOS CAMPANIA SALDOS NO 1 2 3'', 
		                              @P_COD_ERROR = @P_RET_PROCESO, 
		                              @P_MSG_ERROR = @P_MSG_PROCESO, 
		                              @P_TIPO_ERROR = @PKG_CONSTANTES$C_LOG_TIPO_INFORMACION$3
		
		                        END

                   			  END CATCH

                	 END
                  
                 	 BEGIN
							/* Si el paquete es el por default*/
							
                     		BEGIN TRY
                     
		                         UPDATE s
		                           SET 
		                              s.C1666 = sc.CAMPANIA_ANT, 
		                              s.C1771 = 0, 
		                              s.C1772 = 0
		                         FROM SALDOS s
		                         INNER JOIN @TMPSaldosCampaniasPaqDefault sc ON sc.JTS_OID = s.JTS_OID
		                      
                     		END TRY

                     		BEGIN CATCH

		                        DECLARE
		                           @errornumber$4 int
		
		                        SET @errornumber$4 = ERROR_NUMBER()
		
		                        DECLARE
		                           @errormessage$4 nvarchar(4000)
		
		                        SET @errormessage$4 = ERROR_MESSAGE()
		
		                        DECLARE
		                           @exceptionidentifier$4 nvarchar(4000)
		
		                        SELECT @exceptionidentifier$4 = 
		                           ssma_oracle.db_error_get_oracle_exception_id(@errormessage$4, @errornumber$4)
		
		                        BEGIN
		
		                           /* Valores de Retorno.*/
		                           SET @P_RET_PROCESO = 
		                              ssma_oracle.db_error_sqlcode(@exceptionidentifier$4, @errornumber$4)
		
		                           SET @P_MSG_PROCESO = 
		                              ssma_oracle.db_error_sqlerrm_0(@exceptionidentifier$4, @errornumber$4)
		
		                           SET @PROCESO_OK_ = 1
		
		                           DECLARE
		                              @PKG_CONSTANTES$C_LOG_TIPO_INFORMACION$4 varchar(8000)
		
		                           SET @PKG_CONSTANTES$C_LOG_TIPO_INFORMACION$4 = ssma_oracle.get_pv_varchar(''dbo'', ''PKG_CONSTANTES'', ''C_LOG_TIPO_INFORMACION'')
		
		                           EXECUTE dbo.PKG_LOG_PROCESO$PROC_INS_LOG_PROCESO 
		                              @P_ID_PROCESO = @P_ID_PROCESO, 
		                              @P_FCH_PROCESO = @P_DT_PROCESO, 
		                              @P_NOM_PACKAGE = ''ACTUASALDOSCAMPANIA - Error UPDATE SALDOS GRUPO'', 
		                              @P_COD_ERROR = @P_RET_PROCESO, 
		                              @P_MSG_ERROR = @P_MSG_PROCESO, 
		                              @P_TIPO_ERROR = @PKG_CONSTANTES$C_LOG_TIPO_INFORMACION$4
		
		                        END

                   		 	 END CATCH

                  		END           
            

              END
																	   
	  
       IF @PROCESO_OK_ = 0
       
         BEGIN

            SET @P_RET_PROCESO = 1

            SET @P_MSG_PROCESO = ''Actualizacion de Saldos de Campaña Finalizo Correctamente''

            DECLARE
               @PKG_CONSTANTES$C_LOG_TIPO_INFORMACION$5 varchar(8000)

            EXECUTE dbo.PKG_LOG_PROCESO$PROC_INS_LOG_PROCESO 
               @P_ID_PROCESO = @P_ID_PROCESO, 
               @P_FCH_PROCESO = @P_DT_PROCESO, 
               @P_NOM_PACKAGE = ''ACTUASALDOSCAMPANIA'', 
               @P_COD_ERROR = @P_RET_PROCESO, 
               @P_MSG_ERROR = @P_MSG_PROCESO, 
               @P_TIPO_ERROR = @PKG_CONSTANTES$C_LOG_TIPO_INFORMACION$5

           SET @P_MSG_PROCESO = ''Se actualizaron '' + ISNULL(CAST(@CANTCAMP_ AS nvarchar(max)), '''') + '' campañas en saldos''

            DECLARE
               @PKG_CONSTANTES$C_LOG_TIPO_INFORMACION$6 varchar(8000)

    
            EXECUTE dbo.PKG_LOG_PROCESO$PROC_INS_LOG_PROCESO 
               @P_ID_PROCESO = @P_ID_PROCESO, 
               @P_FCH_PROCESO = @P_DT_PROCESO, 
               @P_NOM_PACKAGE = ''ACTUASALDOSCAMPANIA'', 
               @P_COD_ERROR = @P_RET_PROCESO, 
               @P_MSG_ERROR = @P_MSG_PROCESO, 
               @P_TIPO_ERROR = @PKG_CONSTANTES$C_LOG_TIPO_INFORMACION$6

         END
      ELSE 
         BEGIN

            SET @P_RET_PROCESO = 3

            SET @P_MSG_PROCESO = ''Actualizacion de Saldos de Campaña Finalizo con Errores''

         END

   END
')
