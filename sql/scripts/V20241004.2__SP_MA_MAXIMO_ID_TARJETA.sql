EXECUTE('


CREATE  PROCEDURE SP_MA_MAXIMO_ID_TARJETA
    @P_PERSONA NUMERIC (12),
    @P_CLIENTE NUMERIC (12),
    @P_SALDO NUMERIC (12),
    @TIPO_TARJETA VARCHAR (2),
    @P_RET_PROCESO FLOAT OUT,
    @P_MSG_PROCESO VARCHAR(MAX) OUT,
    @P_ID_TARJETA VARCHAR(19) OUT
AS
BEGIN
    SET @P_RET_PROCESO = NULL;
    SET @P_MSG_PROCESO = NULL;
	
		
    BEGIN TRY
        
        DECLARE 
        @FECHA DATETIME;
		          
        SELECT @FECHA = FECHAPROCESO FROM PARAMETROS WITH (NOLOCK);

		  -- DECLARO TABLAS AUXILIARES --
        DECLARE @TMP_ID_TARJETA_CON_SALDO TABLE (
            ID_TARJETA VARCHAR(19)
            );


		 DECLARE @TMP_ID_TARJETA_SIN_SALDO TABLE (
            ID_TARJETA VARCHAR(19)
            );
          
        -- VERIFICO TABLA AUXILIAR CON SALDO --
        
        INSERT INTO @TMP_ID_TARJETA_CON_SALDO (ID_TARJETA)
        SELECT TJ.ID_TARJETA
        FROM TJD_TARJETAS TJ WITH (NOLOCK)
        INNER JOIN TJD_REL_TARJETA_CUENTA RT WITH (NOLOCK) ON RT.ID_TARJETA=TJ.ID_TARJETA
        WHERE TJ.NRO_CLIENTE=@P_CLIENTE
        AND TJ.NRO_PERSONA=@P_PERSONA
        AND RT.SALDO_JTS_OID=@P_SALDO
        AND TJ.VENCIMIENTO > @FECHA
        AND (RT.ESTADO NOT IN (SELECT REPLACE(value, '''''''', '''') 
		FROM STRING_SPLIT((SELECT alfa FROM PARAMETROSGENERALES  WITH (NOLOCK) WHERE CODIGO =101),'','')))
        AND TJ.TZ_LOCK=0
        AND RT.TZ_LOCK=0
       
       
        IF EXISTS (SELECT 1 FROM @TMP_ID_TARJETA_CON_SALDO)
	        BEGIN
	            SET @P_ID_TARJETA = (
	                SELECT TOP 1 ts.ID_TARJETA
	                FROM @TMP_ID_TARJETA_CON_SALDO ts
	                ORDER BY ts.ID_TARJETA DESC
	            );
	            
	        SET @P_MSG_PROCESO = ''Validaciones - Persona tiene tarjeta para el Saldo'';
		    SET @P_RET_PROCESO = 1;  
	         
	                     
	    	END
	    	
    	ELSE
    	
    		-- EN CASO QUE NO EXISTA, VERIFICO TABLA AUXILIAR SIN SALDO --
    	
		    	BEGIN
		    	        
		        INSERT INTO @TMP_ID_TARJETA_SIN_SALDO (ID_TARJETA)
		        SELECT v.ID_TARJETA  FROM VW_DSCCLASETARJETAS v  WITH (NOLOCK)
		        WHERE NRO_CLIENTE = @P_CLIENTE AND NRO_PERSONA = @P_PERSONA
		        	AND ESTADO = ''1'' AND TIPO_TARJETA = @TIPO_TARJETA
				      
		
				        IF EXISTS (SELECT 1 FROM @TMP_ID_TARJETA_SIN_SALDO)
						        BEGIN
						            SET @P_ID_TARJETA = (
						                SELECT TOP 1 ts.ID_TARJETA
						                FROM @TMP_ID_TARJETA_SIN_SALDO ts
						                ORDER BY ts.ID_TARJETA DESC
						            );
						            
						     		 SET @P_MSG_PROCESO = ''Validacion - La persona cuenta con una tarjeta valida'';
		                  			 SET @P_RET_PROCESO = 2;                
						    	END
						      						    	
						 ELSE
						    	
						    	BEGIN
						    		 SET @P_ID_TARJETA = NULL;
						    	     SET @P_RET_PROCESO = 0;
       								 SET @P_MSG_PROCESO = ''No se encontro Id_tarjeta'';
						        END
						        	
		        END


    END TRY
    
    BEGIN CATCH
        SET @P_ID_TARJETA = NULL;
        SET @P_RET_PROCESO = ERROR_NUMBER();
        SET @P_MSG_PROCESO = ''El Proceso terminó con errores'';
    END CATCH;
END;
')

