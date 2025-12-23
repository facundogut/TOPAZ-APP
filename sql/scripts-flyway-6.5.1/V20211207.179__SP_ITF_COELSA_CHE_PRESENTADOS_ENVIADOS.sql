EXECUTE('DROP PROCEDURE IF EXISTS [dbo].[SP_ITF_COELSA_CHE_PRESENTADOS_ENVIADOS];')

EXECUTE('
CREATE PROC [dbo].[SP_ITF_COELSA_CHE_PRESENTADOS_ENVIADOS]
@TICKET NUMERIC(16)
AS 
BEGIN TRY
	SET NOCOUNT ON;
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- Modified : 27/09/2021 10:00 a.m.
--- Autor: Luis Etchebarne 
--- Se ajusta el sp con el fin de grabar el historial de los cheques, dpf o ajustes procesados en la tabla ITF_COELSA_CHEQUES_OTROS.
--- Se agrega el parametro del id_ticket para tener traza de la ejecucion.
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- Modified : 24/09/2021 10:00 a.m.
--- Autor: Luis Etchebarne 
--- Se ajusta el sp con el fin de generar el tracknumber y grabar campos necesarios en las tablas de clearing.
--- Se agregan los DPF y Ajustes en pesos al plano final.
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

---limpio tabla auxiliar ---
TRUNCATE TABLE dbo.ITF_CHEQUES_SALIDA_AUX;
   
--variables CLE_CHEQUES_ENVIADOS
DECLARE @T_COD_BANCO NUMERIC(12,0);
DECLARE @T_SUCURSAL NUMERIC(5,0);
DECLARE @T_SERIE_DEL_CHEQUE VARCHAR(6);
DECLARE @T_NUMERO_DEL_CHEQUE NUMERIC(12,0);
DECLARE @T_MONEDA NUMERIC(4,0);
DECLARE @T_IMPORTE NUMERIC(15,2);
DECLARE @T_FECHA_DEL_CHEQUE DATETIME;
DECLARE @T_FECHA_VALOR DATETIME;
DECLARE @T_CODIGO_BANCO_CAMARA NUMERIC(4,0);
DECLARE @T_TIPO_DOCUMENTO NUMERIC(4,0);
DECLARE @T_CODIGO_PLAZA NUMERIC(4,0);
DECLARE @T_CODIGO_CAMARA NUMERIC(4,0);
DECLARE @T_NUMERO_CUENTA_GIRADORA NUMERIC(12,0);
DECLARE @T_TIPO_MONEDA VARCHAR(1);
DECLARE @T_SUCURSAL_DE_INGRESO NUMERIC(5,0);

--variables Cabecera Archivo (CA)
DECLARE @CA_ID_REG VARCHAR(1) = ''1'';
DECLARE @CA_CODIGO_PRIORIDAD VARCHAR (2)= ''01'';
DECLARE @CA_DESTINO_INMEDIATO VARCHAR (10)= '' 000000010'';
DECLARE @CA_ORIGEN_INMEDIATO VARCHAR(10) = '' 031100970''; 
DECLARE @CA_FECHA_PRESENTACION VARCHAR(6)= convert(VARCHAR,(SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)), 12); 
DECLARE @CA_HORA_PRESENTACION VARCHAR(4)= concat (SUBSTRING((SELECT CONVERT (VARCHAR(8), SYSDATETIME(),24)),1,2), SUBSTRING((SELECT CONVERT (VARCHAR(8), SYSDATETIME(),24)),4,5));
DECLARE @CA_IDENTIFICADOR_ARCHIVO VARCHAR(1) = ''A''; 
DECLARE @CA_TAMANNO_REGISTRO VARCHAR(3)= ''094'';
DECLARE @CA_FACTOR_BLOQUE VARCHAR(2)= ''10'';
DECLARE @CA_CODIGO_FORMATO VARCHAR(1)= ''1'';
DECLARE @CA_NOMBRE_DEST_INMEDIATO VARCHAR(6)= ''COELSA'';
DECLARE @CA_NOMBRE_ORIG_INMEDIATO VARCHAR(23)=''NUEVO BANCO DEL CHACO S'';
DECLARE @CA_CODIGO_REFERENCIA VARCHAR(8) = replicate('' '', 8); --Se conforma con espacios vacíos.
DECLARE @CA_CABECERA VARCHAR(200);

-- conformacion de cabecera archivo
SET @CA_CABECERA = @CA_ID_REG + @CA_CODIGO_PRIORIDAD + @CA_DESTINO_INMEDIATO + @CA_ORIGEN_INMEDIATO + @CA_FECHA_PRESENTACION
                  + @CA_HORA_PRESENTACION + @CA_IDENTIFICADOR_ARCHIVO + @CA_TAMANNO_REGISTRO + @CA_FACTOR_BLOQUE 
                  + @CA_CODIGO_FORMATO + @CA_NOMBRE_DEST_INMEDIATO + ''                 '' + @CA_NOMBRE_ORIG_INMEDIATO + @CA_CODIGO_REFERENCIA;


--variables cabecera lote (CL)
DECLARE @CL_ID_REG VARCHAR(1) = ''5''; 
DECLARE @CL_CODIGO_CLASE_TRANSAC VARCHAR(3) = ''200''; 
DECLARE @CL_RESERVADO VARCHAR(46) = ''                                              '';  
DECLARE @CL_TIPO_REGISTRO VARCHAR(3) = ''TRC''; 
DECLARE @CL_DESCRIP_TRANSAC VARCHAR(10) = ''CHEQUESPRE'' ; 
DECLARE @CL_FECHA_PRESENTACION VARCHAR(6) = convert(VARCHAR,(SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)), 12);
DECLARE @CL_FECHA_VENCIMIENTO VARCHAR(6) = convert(VARCHAR,(SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)), 12); 
DECLARE @CL_RESERVADO_CL VARCHAR(3) = ''000''; 
DECLARE @CL_CODIGO_ORIGEN VARCHAR(1) = ''1''; 
DECLARE @CL_ID_ENTIDAD_ORIGEN VARCHAR(8) = ''03110097''; 
DECLARE @CL_NUMERO_LOTE VARCHAR(7) = 0; 
DECLARE @CL_CONT_LOTE INT = 0;  -- VAR AUXILIAR
DECLARE @CL_CABECERA_LOTE VARCHAR(200);
DECLARE @CL_CABECERA VARCHAR(200);
SET @CL_CABECERA_LOTE = @CL_ID_REG + @CL_CODIGO_CLASE_TRANSAC + @CL_RESERVADO + @CL_TIPO_REGISTRO + @CL_DESCRIP_TRANSAC
                         + @CL_FECHA_PRESENTACION + @CL_FECHA_VENCIMIENTO + @CL_RESERVADO_CL + @CL_CODIGO_ORIGEN + @CL_ID_ENTIDAD_ORIGEN; 

--variables registro individual ( RI)
DECLARE @RI_ID_REG VARCHAR(1) = ''6'';  
DECLARE @RI_CODIGO_TRANSAC VARCHAR(2) = ''27'';
DECLARE @RI_ENTIDAD_DEBITAR VARCHAR(8);
DECLARE @RI_RESERVADO VARCHAR(1) = ''0''; 
DECLARE @RI_CUENTA_DEBITAR VARCHAR(17); 
DECLARE @RI_IMPORTE VARCHAR(11); 
DECLARE @RI_NUMERO_CHEQUE VARCHAR(15);
DECLARE @RI_CODIGO_POSTAL VARCHAR(6); 
DECLARE @RI_PUNTO_INTERCAMBIO VARCHAR(16) = ''0000            '';
DECLARE @RI_INFO_ADICIONAL VARCHAR(2);
DECLARE @RI_REGISTRO_ADICIONAL VARCHAR(1); 
DECLARE @RI_CONTADOR_REGISTRO VARCHAR(15); 								
DECLARE @RI_REGISTRO_INDIVIDUAL VARCHAR (200);
DECLARE @CMC7 VARCHAR(30);

---variables fin de lote FL
DECLARE @FL_ID_REG VARCHAR(1) = ''8'';  
DECLARE @FL_CODIGO_CLASE_TRANSAC VARCHAR(3) = ''200''; 
DECLARE @FL_CANT_REG_INDIVIDUAL_ADICIONAL VARCHAR(6) = 0;
DECLARE @FL_TOTALES_DE_CONTROL VARCHAR(10) = 0;
DECLARE @FL_SUMA_TOTAL_DEBITO_LOTE NUMERIC(12,2)=0; 
DECLARE @FL_SUMA_TOTAL_CREDITO_LOTE NUMERIC(12,2)=0; 
DECLARE @FL_RESERVADO1 VARCHAR(1) = '' '';
DECLARE @FL_RESERVADO2 VARCHAR(1) = '' '';
DECLARE @FL_RESERVADO3 VARCHAR(1) = '' '';
DECLARE @FL_REG_ENTIDAD_ORIGEN VARCHAR(8) = ''03110030''; 
DECLARE @FL_NUMERO_LOTE VARCHAR(7); 
DECLARE @FL_FIN_LOTE VARCHAR(200);

--variables fin de Archivo FA
DECLARE @FA_ID_REG VARCHAR(1) = ''9'';  
DECLARE @FA_CANT_LOTES VARCHAR(6);-- ver detalles en doc pdf
DECLARE @FA_NUMERO_BLOQUES VARCHAR(6);-- ver detalles en doc pdf
DECLARE @FA_CANT_REG_INDIVIDUAL_ADICIONAL VARCHAR(8);
DECLARE @FA_TOTALES_DE_CONTROL VARCHAR(10); -- ver detalles en doc pdf
DECLARE @FA_SUMA_TOTAL_DEBITOS VARCHAR(12);-- ver detalles en doc pdf
DECLARE @FA_SUMA_TOTAL_CREDITOS VARCHAR(12);-- ver detalles en doc pdf
DECLARE @FA_RESERVADO  VARCHAR(100) = ''                              ''; --ESPACIO EN BLANCO PARA COMPLETAR 
DECLARE @FA_FIN_ARCHIVO VARCHAR (200);

--variable de cursorUno
DECLARE @BANCO NUMERIC(4,0);

--Variables generales
DECLARE @CONT_REGISTROS VARCHAR(7)=0;
DECLARE @CONT_REGISTROS_RI INT =0;
DECLARE @CANT_LINES INT = 0;

DECLARE @SUM_ENTIDAD INT =0;
DECLARE @SUM_SUCURSAL INT =0;
DECLARE @SUM_ENT VARCHAR (10);
DECLARE @SUM_SUC VARCHAR (10);


--Insert cabecera en tabla auxiliar
INSERT INTO dbo.ITF_CHEQUES_SALIDA_AUX (LINEA) VALUES (@CA_CABECERA);


DECLARE CursorUno CURSOR FOR --Declarar el cursorUno

SELECT COD_BANCO FROM dbo.CLE_CHEQUES_ENVIADOS WITH(NOLOCK) WHERE TZ_LOCK=0 GROUP BY COD_BANCO 

---*****---
 --CURSOR1
---*****---
OPEN CursorUno --Abrir el CURSOR
    FETCH NEXT FROM CursorUno INTO @BANCO

    WHILE @@FETCH_STATUS = 0 
    	BEGIN

    		SET @CL_CONT_LOTE =  @CL_CONT_LOTE + 1;
    		SET @CL_NUMERO_LOTE = RIGHT(concat(''0000000'', @CL_CONT_LOTE), 7);
			
			/*
    		DECLARE @TEMP2 VARCHAR(4)= (SELECT RIGHT(REPLICATE(''0'', 4)+ CAST(SUCURSAL AS VARCHAR(4)), 4) AS SUCURSAL 
    						            FROM dbo.CLE_CHEQUES_ENVIADOS 
    									WHERE COD_BANCO = @BANCO GROUP BY SUCURSAL)
    									
    		DECLARE @TEMP1 VARCHAR(4)= (SELECT RIGHT(REPLICATE(''0'', 4)+ CAST(COD_BANCO AS VARCHAR(4)), 4) AS COD_BANCO 
    									FROM dbo.CLE_CHEQUES_ENVIADOS 
    									WHERE COD_BANCO = @BANCO GROUP BY COD_BANCO)
  			 */ 
  			    
  									
			-- concateno cabecera lote e inserto
    		SET @CL_CABECERA = @CL_CABECERA_LOTE + @CL_NUMERO_LOTE;    
    				
			INSERT INTO dbo.ITF_CHEQUES_SALIDA_AUX (LINEA) VALUES (@CL_CABECERA);
		   
		    ---*****---
		    --CURSOR2
			---*****---
			DECLARE CursorDos CURSOR FOR --Declarar el CURSOR dos
			
				SELECT  COD_BANCO, SUCURSAL, SERIE_DEL_CHEQUE, NUMERO_DEL_CHEQUE, MONEDA, IMPORTE, FECHA_DEL_CHEQUE,
	   					FECHA_VALOR, CODIGO_BANCO_CAMARA, TIPO_DOCUMENTO, CODIGO_PLAZA, CODIGO_CAMARA, NUMERO_CUENTA_GIRADORA,
	   					TIPO_MONEDA, SUCURSAL_DE_INGRESO
				        FROM CLE_CHEQUES_ENVIADOS WITH(NOLOCK)
				        		
    	   	OPEN CursorDos --Abrir el CURSOR dos
    			FETCH NEXT FROM CursorDos INTO @T_COD_BANCO, @T_SUCURSAL, @T_SERIE_DEL_CHEQUE, @T_NUMERO_DEL_CHEQUE,@T_MONEDA,@T_IMPORTE,
    							   	           @T_FECHA_DEL_CHEQUE, @T_FECHA_VALOR, @T_CODIGO_BANCO_CAMARA, @T_TIPO_DOCUMENTO,@T_CODIGO_PLAZA, 
    							   	           @T_CODIGO_CAMARA, @T_NUMERO_CUENTA_GIRADORA, @T_TIPO_MONEDA, @T_SUCURSAL_DE_INGRESO
									            
    	   		WHILE @@FETCH_STATUS = 0 
    				BEGIN
    					 -- el if condiciona para solo insertar los RI del lote que esta siendo analizado
    					IF @T_COD_BANCO = @BANCO
    					BEGIN
    					
    					  -- (COD_BANCO, NUMERO_DEL_CHEQUE, NUMERO_CUENTA_GIRADORA, FECHA_DEL_CHEQUE, SUCURSAL, SERIE_DEL_CHEQUE, TIPO_DOCUMENTO)
    					   
    					   --Varibles para conformar @RI_ENTIDAD_DEBITAR
    						DECLARE @ENTIDAD VARCHAR(4) = RIGHT(concat(replicate(''0'', 4), @T_COD_BANCO), 4);
    						
				 			DECLARE @SUCURSAL VARCHAR(4) = RIGHT(concat(replicate(''0'', 4), @T_SUCURSAL), 4);

    						--ENTIDAD DEBITAR					 
    						SET @RI_ENTIDAD_DEBITAR = @ENTIDAD + @SUCURSAL;
				 		
				 			--CUENTA DEBITAR
				 			SET @CMC7 = (SELECT s.CMC7 FROM CLE_CHEQUES_SALIENTE s WITH(NOLOCK) WHERE s.SERIE_DEL_CHEQUE = @T_SERIE_DEL_CHEQUE AND s.NUMERO_CHEQUE = @T_NUMERO_DEL_CHEQUE AND s.BANCO_GIRADO = @BANCO AND s.SUCURSAL_BANCO_GIRADO = @T_SUCURSAL AND s.NUMERICO_CUENTA_GIRADORA = @T_NUMERO_CUENTA_GIRADORA);
							   				 
    				       	SET @RI_CUENTA_DEBITAR = RIGHT(concat(''00000000000000000'', substring(@CMC7,19,10)), 17);
				 			
	 
    					    --IMPORTE
    						SET @RI_IMPORTE = RIGHT(concat(replicate(''0'', 11), @T_IMPORTE) , 11); 
    					
    				   		SET @RI_IMPORTE=  concat (SUBSTRING(@RI_IMPORTE,1,8), SUBSTRING(@RI_IMPORTE,10,11));
    				   
    				  	
    				  		--NUEMERO CHEQUE			 
    				 		SET @RI_NUMERO_CHEQUE = concat(''00'', RIGHT(concat(replicate(''0'', 13), @T_NUMERO_DEL_CHEQUE), 13)); 
    				 		
    				 	 	--CODIGO POSTAL  		 
    				       	SET @RI_CODIGO_POSTAL =  ''00'' +  substring(@CMC7,7,4);
    				    	
    				    	SET @RI_INFO_ADICIONAL = ''00'';
    				   		SET @RI_REGISTRO_ADICIONAL = ''0'';
    				    
    				    	--CONTADOR DE REGISTRO RI
    				    	SET @CONT_REGISTROS_RI =  @CONT_REGISTROS_RI +1;
    				    	SET @RI_CONTADOR_REGISTRO = RIGHT(concat(''0000000'', @CONT_REGISTROS_RI), 7);
    				    	--SET @RI_CONTADOR_REGISTRO = ''03110097'' + @RI_CONTADOR_REGISTRO;
    				    	SET @RI_CONTADOR_REGISTRO = concat(@RI_ENTIDAD_DEBITAR, RIGHT(concat(replicate(''0'', 7), (SELECT NUMERICO_1 FROM ITF_MASTER_PARAMETROS WHERE CODIGO_INTERFACE = 11)), 7)); 
    			 
    			       		 -- Concateno registro individual
    				    	SET @RI_REGISTRO_INDIVIDUAL = @RI_ID_REG + @RI_CODIGO_TRANSAC + @RI_ENTIDAD_DEBITAR + @RI_RESERVADO 
    				    				            + @RI_CUENTA_DEBITAR +  @RI_IMPORTE + @RI_NUMERO_CHEQUE  + @RI_CODIGO_POSTAL 
    				    						    + @RI_PUNTO_INTERCAMBIO + @RI_INFO_ADICIONAL + @RI_REGISTRO_ADICIONAL 
    				    						   	+ @RI_CONTADOR_REGISTRO;
    			   
    						INSERT INTO dbo.ITF_CHEQUES_SALIDA_AUX (LINEA) VALUES (@RI_REGISTRO_INDIVIDUAL);
    						
    						SET @FL_CANT_REG_INDIVIDUAL_ADICIONAL = @FL_CANT_REG_INDIVIDUAL_ADICIONAL + 1;
    						
    						--- Actualizar contador unico ---
    						UPDATE dbo.ITF_MASTER_PARAMETROS SET NUMERICO_1 = (NUMERICO_1 + 1) WHERE CODIGO_INTERFACE = 11;
    						------------------------------------
    						
    						--- Grabar historial ---
    						INSERT INTO ITF_COELSA_CHEQUES_OTROS (ID_TICKET, ID_PROCESO, FECHAPROCESO, CODIGO_TRANSACCION, BANCO, SUCURSAL, CUENTA, IMPORTE, CODIGO_POSTAL, FECHA_PRESENTADO, FECHA_VENCIMIENTO, NRO_CHEQUE, PUNTO_INTERCAMBIO, TRACE_NUMBER, ESTADO, TIPO, MONEDA, TIPO_DOCUMENTO, SERIE_DEL_CHEQUE)
    						VALUES (@TICKET, @TICKET, (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)), @RI_CODIGO_TRANSAC, @T_COD_BANCO, @T_SUCURSAL, @T_NUMERO_CUENTA_GIRADORA, @T_IMPORTE, @RI_CODIGO_POSTAL, @T_FECHA_DEL_CHEQUE, @T_FECHA_VALOR, @T_NUMERO_DEL_CHEQUE, @RI_PUNTO_INTERCAMBIO, @RI_CONTADOR_REGISTRO, ''P'', ''C'', @T_MONEDA, @T_TIPO_DOCUMENTO, @T_SERIE_DEL_CHEQUE);
    						---------------------------
    						
    							--****************** FL			
    				   		--- vars para la suma de control
    						SET @SUM_ENTIDAD = @SUM_ENTIDAD + @T_COD_BANCO;
    				 	   	SET @SUM_ENT = RIGHT(concat(''0000000'',  CAST (@SUM_ENTIDAD AS VARCHAR(10)) ), 7);
    					
							SET @SUM_SUCURSAL = @SUM_SUCURSAL + @T_SUCURSAL;
					   		SET @SUM_SUC = RIGHT(concat(''0000000'',  CAST (@SUM_SUCURSAL AS VARCHAR(7)) ), 7);
					   		
					   		--****************** SUMA TOTAL DEBITO/CREDITO FL			
    				   		--- suma Debito
					   		SET @FL_SUMA_TOTAL_DEBITO_LOTE = @FL_SUMA_TOTAL_DEBITO_LOTE + @T_IMPORTE;
					   	 	DECLARE @TMPDEB1 VARCHAR(13)= RIGHT(concat(''0000000000000'',  CAST (@FL_SUMA_TOTAL_DEBITO_LOTE AS VARCHAR(13)) ), 13);
					   	 	DECLARE @TMPDEB2 VARCHAR(10) = SUBSTRING(@TMPDEB1,1,10);
					   	   	DECLARE @TMPDEB3 VARCHAR(2) = SUBSTRING(@TMPDEB1,12,13);
					   	   	DECLARE @FL_SUMA_TOTAL_DEBITO_LOTE_FINAL VARCHAR(12) = CONCAT(@TMPDEB2,@TMPDEB3);
					   		
					   		--- suma Credito
					   		SET @FL_SUMA_TOTAL_CREDITO_LOTE = @FL_SUMA_TOTAL_CREDITO_LOTE + @T_IMPORTE;
					   	 	DECLARE @TMPCRED1 VARCHAR(13)= RIGHT(concat(''0000000000000'',  CAST (@FL_SUMA_TOTAL_CREDITO_LOTE AS VARCHAR(13)) ), 13);
					   	 	DECLARE @TMPCRED2 VARCHAR(10) = SUBSTRING(@TMPCRED1,1,10);
					   	   	DECLARE @TMPCRED3 VARCHAR(2) = SUBSTRING(@TMPCRED1,12,13);
					   	   	DECLARE @FL_SUMA_TOTAL_CREDITO_LOTE_FINAL VARCHAR(12) = CONCAT(@TMPCRED2,@TMPCRED3);
					   	
					   	   --****************** SUMA TOTAL DEBITO/CREDITO FA
					   	   
					   	   SET @FA_SUMA_TOTAL_DEBITOS=@FL_SUMA_TOTAL_DEBITO_LOTE_FINAL
					   	   SET @FA_SUMA_TOTAL_CREDITOS=@FL_SUMA_TOTAL_CREDITO_LOTE_FINAL
					   	   
					   	   	
	
    					END  
    	       				
    				FETCH NEXT FROM CursorDos INTO @T_COD_BANCO, @T_SUCURSAL, @T_SERIE_DEL_CHEQUE, @T_NUMERO_DEL_CHEQUE,@T_MONEDA,@T_IMPORTE,
    							   	               @T_FECHA_DEL_CHEQUE, @T_FECHA_VALOR, @T_CODIGO_BANCO_CAMARA, @T_TIPO_DOCUMENTO,@T_CODIGO_PLAZA, 
    							   	               @T_CODIGO_CAMARA, @T_NUMERO_CUENTA_GIRADORA, @T_TIPO_MONEDA, @T_SUCURSAL_DE_INGRESO
					               
    				END 
    				CLOSE CursorDos --Cerrar el CURSOR
					DEALLOCATE CursorDos --Liberar recursos
				    
					--- linea fin lote 
					
						   		
					--Totales de control
					DECLARE @LEN_SUM_SUC INT;
					DECLARE @CANT_DESV INT;
					DECLARE @SUM_SUC_SIN_DESVORD VARCHAR(10);
					DECLARE @DESVORDE VARCHAR(10);
					DECLARE @TEMP INT;
					DECLARE @SUM_ENTTEMP INT;
					
					IF @SUM_SUCURSAL > 9999
						BEGIN  
							SET @LEN_SUM_SUC = LEN (@SUM_SUCURSAL)	;
						   	SET @CANT_DESV =   @LEN_SUM_SUC - 4 ;   	
						   	SET @SUM_SUC = CAST (@SUM_SUCURSAL AS VARCHAR(7)) ;	  				   				
							SET @SUM_SUC_SIN_DESVORD = SUBSTRING(@SUM_SUC,@CANT_DESV+1,4);   
							SET @DESVORDE = SUBSTRING(@SUM_SUC,1,@CANT_DESV);   							
						   	SET @TEMP = CAST (@DESVORDE AS INT);
						   	SET @SUM_ENTTEMP = CAST((@SUM_ENTIDAD + @TEMP) AS VARCHAR(7));
						   	
						   	SET @FL_TOTALES_DE_CONTROL = CONCAT(@SUM_ENTTEMP,@SUM_SUC_SIN_DESVORD) ;	
							SET @FL_TOTALES_DE_CONTROL = RIGHT(concat(''0000000000'', @FL_TOTALES_DE_CONTROL ), 10);
						END
				   	ELSE
						BEGIN
							SET @FL_TOTALES_DE_CONTROL = CONCAT(@SUM_ENTIDAD,@SUM_SUCURSAL) ;	
						   	SET @FL_TOTALES_DE_CONTROL = RIGHT(concat(''0000000000'', @FL_TOTALES_DE_CONTROL ), 10);
						END
						
							
					SET @FL_CANT_REG_INDIVIDUAL_ADICIONAL =  RIGHT(concat(''000000'', @FL_CANT_REG_INDIVIDUAL_ADICIONAL), 6) ;
					SET @FL_RESERVADO1 = ''          '';
					SET @FL_RESERVADO2 = ''          '';
					SET @FL_RESERVADO3 = ''               '';
					SET @FL_NUMERO_LOTE = @CL_NUMERO_LOTE;
                    
					
				   	SET @FL_FIN_LOTE = @FL_ID_REG + @FL_CODIGO_CLASE_TRANSAC + @FL_CANT_REG_INDIVIDUAL_ADICIONAL + @FL_TOTALES_DE_CONTROL 
					              + @FL_SUMA_TOTAL_DEBITO_LOTE_FINAL + @FL_SUMA_TOTAL_CREDITO_LOTE_FINAL + ''                                   ''
					              + @FL_REG_ENTIDAD_ORIGEN + @FL_NUMERO_LOTE 
					              
					         
					
					INSERT INTO dbo.ITF_CHEQUES_SALIDA_AUX (LINEA) VALUES (@FL_FIN_LOTE);
					
					--FA totales de control
					SET @FA_TOTALES_DE_CONTROL = @FL_TOTALES_DE_CONTROL;
					
					--limpio FL totales de contrl para proximo bloque
					SET @FL_TOTALES_DE_CONTROL=0;
					
					--cant de RI
					SET @FL_CANT_REG_INDIVIDUAL_ADICIONAL = 0;
					
					--limpio FL totales de debito/credito para proximo bloque
					SET @FL_SUMA_TOTAL_DEBITO_LOTE = 0;
					SET @FL_SUMA_TOTAL_CREDITO_LOTE = 0;
					
					
        FETCH NEXT FROM CursorUno INTO @BANCO
        END --Fin del WHILE
        
 		--- Cabecera de Lote Ajustes ---
        
        --- Grabar Cabecera de Lote ---
        SET @CL_CONT_LOTE =  @CL_CONT_LOTE + 1;
        SET @CL_NUMERO_LOTE += 1;
        SET @CL_CABECERA = @CL_CABECERA_LOTE + @CL_NUMERO_LOTE;
            
    	INSERT INTO dbo.ITF_CHEQUES_SALIDA_AUX (LINEA) VALUES (@CL_CABECERA);
		----------------------------------------------------------------------
        ---------------------------------- Grabar Registros Individuales de Ajustes --------------------------------------------------------------------------------------
        DECLARE @A_ORDINAL NUMERIC(12);
        DECLARE @A_NUMERO_CHEQUE NUMERIC(12);
        DECLARE @A_BANCO NUMERIC(5);
        DECLARE @A_SUCURSAL NUMERIC(5);
        DECLARE @A_NUMERO_CUENTA NUMERIC(12);
        DECLARE @A_CODIGO_POSTAL NUMERIC(4);
        DECLARE @A_FECHA_ALTA DATETIME;
        DECLARE @A_IMPORTE NUMERIC(15,2);
        DECLARE @A_MONEDA NUMERIC(4);
        
        DECLARE @CantidadAjustes NUMERIC(15) = 0; -- cantidad de ajustes
        DECLARE @CantidadDPF NUMERIC(15) = 0; -- cantidad de dpf pesos
        
        DECLARE @SumaEntidad NUMERIC(15);
		DECLARE @SumaSucursal NUMERIC(15);
		DECLARE @SumatoriaSignificativaSucursal VARCHAR(4);
		DECLARE @SobranteSumatoriaSucursal VARCHAR(4);
		DECLARE @SumaEntidad2 NUMERIC(15);
		DECLARE @SumaSucursal2 NUMERIC(15);
		DECLARE @SumatoriaSignificativaSucursal2 VARCHAR(4);
		DECLARE @SobranteSumatoriaSucursal2 VARCHAR(4);

        
        DECLARE CursorAjustes CURSOR FOR
        
        SELECT ORDINAL, NUMERO_CHEQUE, BANCO, SUCURSAL_BANCO_GIRADO, NUMERO_CUENTA, CODIGO_POSTAL, FECHA_ALTA, IMPORTE, MONEDA
        
        FROM CLE_CHEQUES_AJUSTE WITH(NOLOCK) WHERE ENVIADO_RECIBIDO = ''E'' AND ESTADO = ''I'' AND TZ_LOCK = 0 AND FECHA_ALTA = (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)) 
		
		ORDER BY NUMERO_CHEQUE; 
        
        OPEN CursorAjustes
        
        FETCH NEXT FROM CursorAjustes INTO @A_ORDINAL, @A_NUMERO_CHEQUE, @A_BANCO, @A_SUCURSAL, @A_NUMERO_CUENTA, @A_CODIGO_POSTAL, @A_FECHA_ALTA, @A_IMPORTE, @A_MONEDA
        
        
        WHILE @@FETCH_STATUS = 0
        BEGIN
        	SET @RI_ENTIDAD_DEBITAR = concat(RIGHT(concat(replicate(''0'', 4), @A_BANCO), 4), RIGHT(concat(replicate(''0'', 4), @A_SUCURSAL), 4));
        	SET @RI_CUENTA_DEBITAR = RIGHT(concat(replicate(''0'', 17), @A_NUMERO_CUENTA), 17);
        	SET @RI_IMPORTE = RIGHT(concat(replicate(''0'', 11), CAST(@A_IMPORTE AS NUMERIC)), 11);
        	SET @RI_NUMERO_CHEQUE = concat(''00'', RIGHT(concat(replicate(''0'', 13), @A_NUMERO_CHEQUE), 13));
        	SET @RI_CODIGO_POSTAL = RIGHT(concat(''00'', replicate(''0'', 4), @A_CODIGO_POSTAL), 4);
        	SET @RI_INFO_ADICIONAL = ''01'';
        	SET @RI_REGISTRO_ADICIONAL = ''0'';
        	SET @RI_CONTADOR_REGISTRO = concat(RIGHT(concat(replicate(''0'', 4), @A_BANCO), 4), RIGHT(concat(replicate(''0'', 4), @A_SUCURSAL), 4), RIGHT(concat(replicate(''0'', 7), (SELECT NUMERICO_1 FROM ITF_MASTER_PARAMETROS WHERE CODIGO_INTERFACE = 11)), 7)); 
        	
        	SET @RI_REGISTRO_INDIVIDUAL = @RI_ID_REG + @RI_CODIGO_TRANSAC + @RI_ENTIDAD_DEBITAR + @RI_RESERVADO + @RI_CUENTA_DEBITAR +  @RI_IMPORTE + @RI_NUMERO_CHEQUE  + @RI_CODIGO_POSTAL 
    				    						     + @RI_PUNTO_INTERCAMBIO + @RI_INFO_ADICIONAL + @RI_REGISTRO_ADICIONAL + @RI_CONTADOR_REGISTRO;
    				    						   	
        	INSERT INTO dbo.ITF_CHEQUES_SALIDA_AUX (LINEA) VALUES (@RI_REGISTRO_INDIVIDUAL);
        	
        	--- Grabar historial ---
    		INSERT INTO ITF_COELSA_CHEQUES_OTROS (ID_TICKET, ID_PROCESO, FECHAPROCESO, CODIGO_TRANSACCION, BANCO, SUCURSAL, CUENTA, IMPORTE, CODIGO_POSTAL, FECHA_PRESENTADO, FECHA_VENCIMIENTO, NRO_CHEQUE, PUNTO_INTERCAMBIO, TRACE_NUMBER, ESTADO, TIPO, MONEDA, ORDINAL)
    		VALUES (@TICKET, @TICKET, (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)), @RI_CODIGO_TRANSAC, @A_BANCO, @A_SUCURSAL, @A_NUMERO_CUENTA, @A_IMPORTE, @A_CODIGO_POSTAL, @A_FECHA_ALTA, @A_FECHA_ALTA, @A_NUMERO_CHEQUE, @RI_PUNTO_INTERCAMBIO, @RI_CONTADOR_REGISTRO, ''P'', ''A'', @A_MONEDA, @A_ORDINAL);
    	    ---------------------------
    						
        	
        	SET @CantidadAjustes = @CantidadAjustes + 1;
        	SET @SumaEntidad += CAST(substring(@RI_ENTIDAD_DEBITAR, 1, 4) AS NUMERIC);
			SET @SumaSucursal += CAST(substring(@RI_ENTIDAD_DEBITAR, 5, 4) AS NUMERIC);
			SET @FL_SUMA_TOTAL_DEBITO_LOTE += @A_IMPORTE;
        	
        	UPDATE dbo.ITF_MASTER_PARAMETROS SET NUMERICO_1 = (NUMERICO_1 + 1) WHERE CODIGO_INTERFACE = 11;
        	
        	UPDATE dbo.CLE_CHEQUES_AJUSTE SET TRACKNUMBER = @RI_CONTADOR_REGISTRO, ESTADO = ''P'', FECHA_ENVIO_CAMARA = (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)) WHERE BANCO = @A_BANCO AND ORDINAL = @A_ORDINAL AND  ENVIADO_RECIBIDO = ''E'' AND ESTADO = ''I'' AND TZ_LOCK = 0 AND FECHA_ALTA = @A_FECHA_ALTA;
        	
        
        FETCH NEXT FROM CursorAjustes INTO @A_ORDINAL, @A_NUMERO_CHEQUE, @A_BANCO, @A_SUCURSAL, @A_NUMERO_CUENTA, @A_CODIGO_POSTAL, @A_FECHA_ALTA, @A_IMPORTE, @A_MONEDA
        
        END
        
        CLOSE CursorAjustes
        DEALLOCATE CursorAjustes
		-------------------------------------------------------------------------------------------------------------------------------------------------
  		
  		--- Grabar Fin Lote para los Ajustes ------------------------------------------------------------------------------------------------------------
  		SET @FL_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 6), @CantidadAjustes), 6);
  		SET @FL_SUMA_TOTAL_DEBITO_LOTE = RIGHT(concat(replicate(''0'', 12), @FL_SUMA_TOTAL_DEBITO_LOTE), 12);
  		SET @FL_SUMA_TOTAL_CREDITO_LOTE = RIGHT(concat(replicate(''0'', 12), @FL_SUMA_TOTAL_CREDITO_LOTE), 12);
  		--- Calculo de totales de control ----------------------------------------------------------------------------------------------------------------
  		SET @SumatoriaSignificativaSucursal = RIGHT(@SumaSucursal , 4);
		SET @SobranteSumatoriaSucursal = substring(CAST(@SumaSucursal AS VARCHAR), 1, (len(@SumaSucursal) - 4));
		SET @SumaEntidad += CAST(@SobranteSumatoriaSucursal AS NUMERIC);
		SET @FL_TOTALES_DE_CONTROL = concat(@SumaEntidad, @SumaSucursal);
		SET @FL_NUMERO_LOTE = @CL_NUMERO_LOTE;
  		-------------------------------------------------------------------------------------------------------------------------------------------------
  		SET @FL_FIN_LOTE = concat(@FL_ID_REG, @FL_CODIGO_CLASE_TRANSAC, @FL_CANT_REG_INDIVIDUAL_ADICIONAL, @FL_TOTALES_DE_CONTROL, @FL_SUMA_TOTAL_DEBITO_LOTE, @FL_SUMA_TOTAL_CREDITO_LOTE, @FL_RESERVADO1, @FL_RESERVADO2, @FL_RESERVADO3, @FL_REG_ENTIDAD_ORIGEN, @FL_NUMERO_LOTE);
  		INSERT INTO dbo.ITF_CHEQUES_SALIDA_AUX (LINEA) VALUES (@FL_FIN_LOTE);
  		---------------------------------------------------------------------------------------------------------------------------------------------------
  	
		---------------------------------------------------------------------------------------------------------------------------------------------------
		--- Grabar Cabecera de Lote Dpf Pesos -------------------------------------------------------------------------------------------------------------
		SET @CL_CONT_LOTE =  @CL_CONT_LOTE + 1;
    	SET @CL_NUMERO_LOTE = RIGHT(concat(''0000000'', @CL_CONT_LOTE), 7);
  		SET @CL_CABECERA = @CL_CABECERA_LOTE + @CL_NUMERO_LOTE;    
    	INSERT INTO dbo.ITF_CHEQUES_SALIDA_AUX (LINEA) VALUES (@CL_CABECERA);
    	---------------------------------------------------------------------------------------------------------------------------------------------------
   
    	DECLARE @D_TIPO_DOCUMENTO VARCHAR(4);
    	DECLARE @D_BANCO NUMERIC(4);
    	DECLARE @D_SUCURSAL NUMERIC(5);
    	DECLARE @D_CUENTA NUMERIC(12);
    	DECLARE @D_IMPORTE NUMERIC(15,2);
    	DECLARE @D_NUMERO_DPF NUMERIC(12);
    	DECLARE @D_CODIGO_POSTAL NUMERIC(4);
    	DECLARE @D_MONEDA NUMERIC(4);
    	DECLARE @D_FECHA DATETIME;
    	
    	--limpio FL totales de debito/credito para proximo bloque
		SET @FL_SUMA_TOTAL_DEBITO_LOTE = 0;
		SET @FL_SUMA_TOTAL_CREDITO_LOTE = 0;
    	
		DECLARE CursorDPF CURSOR FOR
		
		SELECT TIPO_DOCUMENTO, BANCO_GIRADO, SUCURSAL_BANCO_GIRADO, NUMERICO_CUENTA_GIRADORA, IMPORTE, NUMERO_DPF , COD_POSTAL, MONEDA, FECHA_ALTA
		FROM CLE_DPF_SALIENTE WITH(NOLOCK)
		WHERE FECHA_ALTA = (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)) AND TZ_LOCK = 0 AND ESTADO = 1 AND MONEDA = 1
		
		OPEN CursorDPF FETCH NEXT FROM CursorDPF INTO @D_TIPO_DOCUMENTO, @D_BANCO, @D_SUCURSAL, @D_CUENTA, @D_IMPORTE, @D_NUMERO_DPF, @D_CODIGO_POSTAL, @D_MONEDA, @D_FECHA  
  
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
	       	SET @RI_ENTIDAD_DEBITAR = concat(RIGHT(concat(replicate(''0'', 4), @D_BANCO), 4), RIGHT(concat(replicate(''0'', 4), @D_SUCURSAL), 4));
        	SET @RI_CUENTA_DEBITAR = RIGHT(concat(replicate(''0'', 17), @D_CUENTA), 17);
        	SET @RI_IMPORTE = RIGHT(concat(replicate(''0'', 11), CAST(@D_IMPORTE AS NUMERIC)), 11);
        	SET @RI_NUMERO_CHEQUE = concat(''00'', RIGHT(concat(replicate(''0'', 13), @D_NUMERO_DPF), 13));
        	SET @RI_CODIGO_POSTAL = RIGHT(concat(''00'', replicate(''0'', 4), @D_CODIGO_POSTAL), 4);
        	SET @RI_INFO_ADICIONAL = ''01'';
        	SET @RI_REGISTRO_ADICIONAL = ''0'';
        	SET @RI_CONTADOR_REGISTRO = concat(RIGHT(concat(replicate(''0'', 4), @D_BANCO), 4), RIGHT(concat(replicate(''0'', 4), @D_SUCURSAL), 4), RIGHT(concat(replicate(''0'', 7), (SELECT NUMERICO_1 FROM ITF_MASTER_PARAMETROS WHERE CODIGO_INTERFACE = 11)), 7)); 
        	
        	SET @RI_REGISTRO_INDIVIDUAL = @RI_ID_REG + @RI_CODIGO_TRANSAC + @RI_ENTIDAD_DEBITAR + @RI_RESERVADO + @RI_CUENTA_DEBITAR +  @RI_IMPORTE + @RI_NUMERO_CHEQUE  + @RI_CODIGO_POSTAL 
    				    						     + @RI_PUNTO_INTERCAMBIO + @RI_INFO_ADICIONAL + @RI_REGISTRO_ADICIONAL + @RI_CONTADOR_REGISTRO;
    				    						   	
        	INSERT INTO dbo.ITF_CHEQUES_SALIDA_AUX (LINEA) VALUES (@RI_REGISTRO_INDIVIDUAL);
        	
        	--- Grabar historial ---
    		INSERT INTO ITF_COELSA_CHEQUES_OTROS (ID_TICKET, ID_PROCESO, FECHAPROCESO, CODIGO_TRANSACCION, BANCO, SUCURSAL, CUENTA, IMPORTE, CODIGO_POSTAL, FECHA_PRESENTADO, FECHA_VENCIMIENTO, NRO_CHEQUE, PUNTO_INTERCAMBIO, TRACE_NUMBER, ESTADO, TIPO, MONEDA, TIPO_DOCUMENTO)
    		VALUES (@TICKET, @TICKET, (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)), @RI_CODIGO_TRANSAC, @D_BANCO, @D_SUCURSAL, @D_CUENTA, @D_IMPORTE, @D_CODIGO_POSTAL, @D_FECHA, @D_FECHA, @D_NUMERO_DPF, @RI_PUNTO_INTERCAMBIO, @RI_CONTADOR_REGISTRO, ''P'', ''D'', @D_MONEDA, @D_TIPO_DOCUMENTO);
    	    ---------------------------
        	
        	SET @CantidadDPF = @CantidadDPF + 1;
        	SET @SumaEntidad2 += CAST(substring(@RI_ENTIDAD_DEBITAR, 1, 4) AS NUMERIC);
			SET @SumaSucursal2 += CAST(substring(@RI_ENTIDAD_DEBITAR, 5, 4) AS NUMERIC);
			SET @FL_SUMA_TOTAL_DEBITO_LOTE += @D_IMPORTE;
        	--TIPO_DOCUMENTO, NUMERO_DPF, BANCO_GIRADO, SUCURSAL_BANCO_GIRADO, FECHA_ALTA
        	UPDATE dbo.ITF_MASTER_PARAMETROS SET NUMERICO_1 = (NUMERICO_1 + 1) WHERE CODIGO_INTERFACE = 11;
        	
        	UPDATE dbo.CLE_DPF_SALIENTE SET TRACKNUMBER = @RI_CONTADOR_REGISTRO, ESTADO = 2, FECHA_ENVIO_COMPENSACION = (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK))
        	WHERE TIPO_DOCUMENTO = @D_TIPO_DOCUMENTO AND NUMERO_DPF = @D_NUMERO_DPF AND BANCO_GIRADO = @D_BANCO AND SUCURSAL_BANCO_GIRADO = @D_SUCURSAL AND FECHA_ALTA = @D_FECHA AND MONEDA = 1 AND TZ_LOCK = 0 AND ESTADO = 1;
	    
	    	FETCH NEXT FROM CursorDPF INTO @D_TIPO_DOCUMENTO, @D_BANCO, @D_SUCURSAL, @D_CUENTA, @D_IMPORTE, @D_NUMERO_DPF, @D_CODIGO_POSTAL, @D_MONEDA, @D_FECHA 
	    END
	    CLOSE CursorDPF
	    DEALLOCATE CursorDPF
	    -- cerramos y limpiamos el cursor --
	    
	    ----------- Grabar Fin Lote para los DPF en pesos ------------------------------------------------------------------------------------------------------------
  		SET @FL_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 6), @CantidadDPF), 6);
  		SET @FL_SUMA_TOTAL_DEBITO_LOTE = RIGHT(concat(replicate(''0'', 12), @FL_SUMA_TOTAL_DEBITO_LOTE), 12);
  		SET @FL_SUMA_TOTAL_CREDITO_LOTE = RIGHT(concat(replicate(''0'', 12), @FL_SUMA_TOTAL_CREDITO_LOTE), 12);
  		--- Calculo de totales de control ----------------------------------------------------------------------------------------------------------------
  		SET @SumatoriaSignificativaSucursal2 = RIGHT(@SumaSucursal2 , 4);
		SET @SobranteSumatoriaSucursal2 = substring(CAST(@SumaSucursal2 AS VARCHAR), 1, (len(@SumaSucursal2) - 4));
		SET @SumaEntidad2 += CAST(@SobranteSumatoriaSucursal2 AS NUMERIC);
		SET @FL_TOTALES_DE_CONTROL = concat(@SumaEntidad2, @SumaSucursal2);
		SET @FL_NUMERO_LOTE = @CL_NUMERO_LOTE;
  		-------------------------------------------------------------------------------------------------------------------------------------------------
  		SET @FL_FIN_LOTE = concat(@FL_ID_REG, @FL_CODIGO_CLASE_TRANSAC, @FL_CANT_REG_INDIVIDUAL_ADICIONAL, @FL_TOTALES_DE_CONTROL, @FL_SUMA_TOTAL_DEBITO_LOTE, @FL_SUMA_TOTAL_CREDITO_LOTE, @FL_RESERVADO1, @FL_RESERVADO2, @FL_RESERVADO3, @FL_REG_ENTIDAD_ORIGEN, @FL_NUMERO_LOTE);
  		INSERT INTO dbo.ITF_CHEQUES_SALIDA_AUX (LINEA) VALUES (@FL_FIN_LOTE);
  		---------------------------------------------------------------------------------------------------------------------------------------------------
  		
        --- fin archivo linea
        --cantidad Lotes
        SET @FA_CANT_LOTES = RIGHT(concat(''000000'', @CL_NUMERO_LOTE), 6);
        SET @CL_NUMERO_LOTE = RIGHT(concat(''0000000'', @CL_CONT_LOTE), 7);
        
        
        
        --Calculo de cantidad de Bloques
        SET @CANT_LINES = (@CL_CONT_LOTE * 2) + @CONT_REGISTROS_RI + 2 + @CantidadDPF + @CantidadAjustes;
        DECLARE @FA_AUX1 INT = @CANT_LINES/10;
        DECLARE @FA_AUX2 INT = @CANT_LINES%10;
        
        
	  	
		IF @FA_AUX2 = 0
			BEGIN
				SET @FA_NUMERO_BLOQUES = @FA_AUX1;
			END 
		ELSE 
			BEGIN
				
				SET @FA_NUMERO_BLOQUES = @FA_AUX1 + 1;
			END
			
		SET @FA_NUMERO_BLOQUES = RIGHT(concat(''000000'',  CAST (@FA_AUX1 AS VARCHAR(6)) ), 6);   
		
		--Cantidad de RI
		SET @FA_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(''00000000'', (@CONT_REGISTROS_RI + @CantidadDPF + @CantidadAjustes)), 8); 
			
        --concateno la linea fin de archivo e inserto
        SET @FA_FIN_ARCHIVO = @FA_ID_REG + @FA_CANT_LOTES +  @FA_NUMERO_BLOQUES + @FA_CANT_REG_INDIVIDUAL_ADICIONAL 
                            + @FA_TOTALES_DE_CONTROL  + @FA_SUMA_TOTAL_DEBITOS + @FA_SUMA_TOTAL_CREDITOS + @FA_RESERVADO


    	INSERT INTO dbo.ITF_CHEQUES_SALIDA_AUX (LINEA) VALUES (@FA_FIN_ARCHIVO);
    	
CLOSE CursorUno --Cerrar el CURSOR
DEALLOCATE CursorUno --Liberar recursos
 
END TRY 

BEGIN CATCH
	Print error_message()
END CATCH;')