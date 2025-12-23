EXECUTE('
CREATE OR ALTER PROCEDURE PA_ACTUASALDOSPAQUETE
   @P_ID_PROCESO float(53), /* Identificador de proceso*/
   @P_DT_PROCESO datetime2(0),  /* Fecha de proceso*/

   @P_RET_PROCESO float(53)  OUTPUT, /* Estado de ejecucion del PL/SQL(1:Correcto, 2: Error)*/
   @P_MSG_PROCESO varchar(max)  OUTPUT
AS 
   BEGIN
      SET @P_RET_PROCESO = NULL
      SET @P_MSG_PROCESO = NULL
      /*
      *    
      *   El proceso se queda con todos los paquetes y productos activos del cliente
      *
      */
      
       -- Tablas auxiliares --
       
		DECLARE @TMPClientePaquete           TABLE(
							    					  PAQUETE FLOAT (53),
													  CLIENTE FLOAT (53),
													  PRODUCTO FLOAT (53),
													  MONEDA FLOAT (53)
												  )
										
		DECLARE @TMPSaldosADesactivarSinCamp TABLE(
							    					  JTS_OID FLOAT (53)
											 	  )   
											 	  								
	    DECLARE @TMPSaldosADesactivarConCamp TABLE(
							    					  JTS_OID FLOAT (53)
												  )
												   
       	
       -- Cargo tablas auxiliares --  
       	
        INSERT INTO @TMPClientePaquete
      				SELECT C.COD_PAQUETE AS PAQUETE, C.COD_CLIENTE AS CLIENTE, P.PRODUCTO AS PRODUCTO, P.MONEDA AS MONEDA
		            FROM dbo.CLI_CLIENTES_PAQUETES  AS C with (nolock)
					INNER JOIN 	dbo.CLI_PAQUETE_PRODUCTOS  AS P with (nolock) ON  P.COD_PAQUETE = C.COD_PAQUETE AND 
																				  P.ACTIVO = 1 AND P.TZ_LOCK = 0  
		            WHERE 
		               C.ACTIVO = 1 AND 
		               C.TZ_LOCK = 0  

		              
		               
	    INSERT INTO @TMPSaldosADesactivarConCamp
	   				SELECT DISTINCT s.JTS_OID
	   				FROM dbo.SALDOS s with (nolock) 
	   				INNER JOIN @TMPClientePaquete cp ON cp.CLIENTE=s.C1803 AND cp.PAQUETE=s.C1770 
   		            WHERE  s.C1771 <> 0 AND 
                           s.TZ_LOCK = 0  AND
                           NOT EXISTS (SELECT * FROM @TMPClientePaquete cp2 WHERE cp2.CLIENTE=s.C1803 AND cp2.PAQUETE=s.C1770 
		            							AND cp2.MONEDA = S.MONEDA
                        						AND cp2.PRODUCTO = S.PRODUCTO )

                           
        INSERT INTO @TMPSaldosADesactivarSinCamp
	   				SELECT distinct s.JTS_OID
		            FROM dbo.SALDOS s with (nolock)
		            INNER JOIN @TMPClientePaquete cp ON cp.CLIENTE=s.C1803 AND cp.PAQUETE=s.C1770  
		            WHERE  s.C1771 = 0 AND 
                           s.TZ_LOCK = 0 AND
                           NOT EXISTS (SELECT * FROM @TMPClientePaquete cp2 WHERE cp2.CLIENTE=s.C1803 AND cp2.PAQUETE=s.C1770 
		            							AND cp2.MONEDA = S.MONEDA
                        						AND cp2.PRODUCTO = S.PRODUCTO )
      
      
	    DECLARE
	         	@CANTPAQ_ float(53), 
	         	@CANTPAQADESACTCONCAMP float(53),
	         	@CANTPAQADESACTCSINCAMP float(53)
	    		
	    		SET @CANTPAQADESACTCONCAMP=ISNULL((SELECT COUNT(*) FROM @TMPSaldosADesactivarConCamp),0)
	    		SET @CANTPAQADESACTCSINCAMP=ISNULL((SELECT COUNT(*) FROM @TMPSaldosADesactivarSinCamp),0)
	    		SET @CANTPAQ_ = @CANTPAQADESACTCONCAMP+@CANTPAQADESACTCSINCAMP
	    		PRINT @CANTPAQADESACTCONCAMP;
	    		PRINT @CANTPAQADESACTCSINCAMP
	    		
	    BEGIN TRY   
	    		
	    			 BEGIN

                        /* Desactivo Saldos Con y sin (default) Campañas de clientes paquetes que no tenga relacion producto moneda */                
                        
                        
                        UPDATE s
                        SET s.C1770 = 0
                        FROM dbo.SALDOS s
                        INNER JOIN @TMPSaldosADesactivarConCamp sd ON sd.JTS_OID = s.JTS_OID 
                        										  

                        UPDATE s
                        SET 
                              s.C1770 = 0, 
                              s.C1772 = 0
                        FROM dbo.SALDOS s
 						INNER JOIN @TMPSaldosADesactivarSinCamp sd ON sd.JTS_OID = s.JTS_OID
 																   

                     END
               
         
			BEGIN
			
		      SET @P_RET_PROCESO = 1
		      SET @P_MSG_PROCESO = ''Actualizacion de Saldos de Paquete Finalizo Correctamente''
		      DECLARE
		         @PKG_CONSTANTES$C_LOG_TIPO_INFORMACION varchar(8000)
		      SET @PKG_CONSTANTES$C_LOG_TIPO_INFORMACION  = ''I''
		      EXECUTE dbo.PKG_LOG_PROCESO$PROC_INS_LOG_PROCESO 
		         @P_ID_PROCESO = @P_ID_PROCESO, 
		         @P_FCH_PROCESO = @P_DT_PROCESO, 
		        @P_NOM_PACKAGE = ''ACTUASALDOSPAQUETE'', 
		         @P_COD_ERROR = @P_RET_PROCESO, 
		         @P_MSG_ERROR = @P_MSG_PROCESO, 
		         @P_TIPO_ERROR = @PKG_CONSTANTES$C_LOG_TIPO_INFORMACION
		      SET @P_MSG_PROCESO = ''Se actualizaron '' + ISNULL(CAST(@CANTPAQ_ AS nvarchar(max)), '''') + '' paquetes en saldos''
		      DECLARE
		         @PKG_CONSTANTES$C_LOG_TIPO_INFORMACION$2 varchar(8000)
		      SET @PKG_CONSTANTES$C_LOG_TIPO_INFORMACION$2 = ''I''
		      EXECUTE dbo.PKG_LOG_PROCESO$PROC_INS_LOG_PROCESO 
		         @P_ID_PROCESO = @P_ID_PROCESO, 
		         @P_FCH_PROCESO = @P_DT_PROCESO, 
		         @P_NOM_PACKAGE = ''ACTUASALDOSPAQUETE'', 
		         @P_COD_ERROR = @P_RET_PROCESO, 
		         @P_MSG_ERROR = @P_MSG_PROCESO, 
		         @P_TIPO_ERROR = @PKG_CONSTANTES$C_LOG_TIPO_INFORMACION$2
		         
		   END
		         
	  END TRY
	  
	  BEGIN CATCH
	  
	  	BEGIN
	  	
	  		  SET @P_RET_PROCESO = 3
		      SET @P_MSG_PROCESO = ''Actualizacion de Saldos de Paquete Finalizo con Errores''
		      
		      DECLARE
				@PKG_CONSTANTES$C_LOG_TIPO_INFORMACION$4 varchar(1)
							
			  SET @PKG_CONSTANTES$C_LOG_TIPO_INFORMACION$4 = ''E''
							
			  EXECUTE dbo.PKG_LOG_PROCESO$PROC_INS_LOG_PROCESO 
			   @P_ID_PROCESO = @P_ID_PROCESO, 
			   @P_FCH_PROCESO = @P_DT_PROCESO, 
			   @P_NOM_PACKAGE = ''ACTUASALDOSPAQUETE - Error'', 
			   @P_COD_ERROR = @P_RET_PROCESO, 
			   @P_MSG_ERROR = @P_MSG_PROCESO, 
			   @P_TIPO_ERROR = @PKG_CONSTANTES$C_LOG_TIPO_INFORMACION$4
			   
	  	END
	  	
	  END CATCH
	  
   END
')

