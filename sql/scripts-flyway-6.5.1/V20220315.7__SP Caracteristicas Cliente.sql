EXECUTE('
ALTER PROCEDURE [dbo].[SP_PROD_CARACTERISTICAS_CLIENTE]
  @CodCliente			NUMERIC(12, 0),
  @CANTIDAD_INTEG		FLOAT OUTPUT,
  @MAYOR_EDAD_FINAL		VARCHAR(1) OUTPUT,
  @MENOR_ADOLE_FINAL	VARCHAR (1) OUTPUT,
  @MENOR_EMANCIPADO_FINAL VARCHAR (1) OUTPUT,
  @MENOR_AUTORIZ_FINAL	VARCHAR (1) OUTPUT,
  @TIPO_CLIENTE_FINAL	VARCHAR (1) OUTPUT
  AS
  
BEGIN
 

  ------------Tabla auxiliar--------------
  
		  	DECLARE @TMPEdadesIntegrantes TABLE(
				    NUMEROPERSONA NUMERIC (12, 0),
					TIPOPERSONA VARCHAR(1),
					TITULARIDAD VARCHAR(1),
					EDAD FLOAT,
					ESTADOCIVIL VARCHAR(1)
					)
  
  ------------Cargo tabla auxiliar--------------   		
	    -- Analizo los integrantes que integran Cliente

   	 		INSERT INTO @TMPEdadesIntegrantes			
				 SELECT cp.NUMEROPERSONA, 
						cp.TIPOPERSONA,
						cp.TITULARIDAD,
				  
						-- INTEGRANTE DEL CLIENTE ES UNA PERSONA FISICA
											
						CASE WHEN cp.tipopersona=''F'' THEN
						(SELECT FLOOR(DATEDIFF(month, FECHANACIMIENTO, (SELECT FECHAPROCESO 
																		FROM PARAMETROS with (nolock))) / CONVERT(FLOAT, 12))
						 FROM CLI_PERSONASFISICAS f  with (nolock)
						 WHERE f.NUMEROPERSONAFISICA=cp.NUMEROPERSONA 
								AND f.TZ_LOCK=0)		
						END AS EDAD,
						CASE WHEN cp.tipopersona=''F'' THEN
						  (	SELECT F.ESTADOCIVIL 
							FROM CLI_PERSONASFISICAS f with (nolock) 
							WHERE f.NUMEROPERSONAFISICA=cp.NUMEROPERSONA 
								 AND f.TZ_LOCK=0
							)
									
						END AS ESTADOCIVIL
						FROM VW_CLIENTES_PERSONAS cp with (nolock) 
						WHERE cp.CODIGOCLIENTE = @CodCliente

				-- Variables para utilizar únicamente en el análisis de integrantes y concluir resultados finales

					  DECLARE 
					  
					  @MAYOR_EDAD AS float(53)=0,
					  @MENOR_ADOLE AS float(53)=0,
					  @MENOR_AUTORIZ AS float(53)=0,
					  @MENOR_EMANCIPADO AS float(53)=0
					
					    
					  
					  SET @MAYOR_EDAD_FINAL=''N''  
					  SET @MENOR_ADOLE_FINAL =''N''
					  SET @MENOR_EMANCIPADO_FINAL =''N''
					  SET @MENOR_AUTORIZ_FINAL =''N''

				
  				-- Determino características del cliente
  				
					    BEGIN	  
					    			--Tipo Cliente
					    			
					    			SELECT @TIPO_CLIENTE_FINAL=(CASE WHEN TIPO =''F'' THEN ''F'' ELSE ''J'' END) FROM CLI_CLIENTES with (nolock)
  																	WHERE CODIGOCLIENTE=@CodCliente AND TZ_LOCK=0
  												
					  				-- Cantidad de Integrantes
					  				
					  				IF @TIPO_CLIENTE_FINAL = ''F''
								   	    SET @CANTIDAD_INTEG = ISNULL((SELECT COUNT(*) FROM @TMPEdadesIntegrantes),0)	 
								   	ELSE
								   		SET @CANTIDAD_INTEG = 0; 
								   	    					    										
									-- Evaluamos si son mayores de edad
								
									IF @TIPO_CLIENTE_FINAL = ''F''
										SET @MAYOR_EDAD = ISNULL((SELECT COUNT(*) FROM @TMPEdadesIntegrantes 
														  		  WHERE TITULARIDAD = ''T'' 
														  		  	AND EDAD >= ( SELECT numerico FROM PARAMETROSGENERALES with (nolock) 
														  		  	WHERE CODIGO=13 )), 0)
									ELSE 
										SET @MAYOR_EDAD = 0;
														   
								   							   							
									IF @MAYOR_EDAD > 0
										SET @MAYOR_EDAD_FINAL=''S''
									ELSE
										SET @MAYOR_EDAD_FINAL=''N'';
										
									-- Evaluamos si son menores emancipados
									
									IF @TIPO_CLIENTE_FINAL = ''F''									
						           			
						           	 	SET @MENOR_EMANCIPADO =	ISNULL((SELECT count_big(*) FROM @TMPEdadesIntegrantes e
													            		INNER JOIN CLI_ACTIVIDAD_ECONOMICA a ON a.CODIGO_PERSONA_CLIENTE=e.NUMEROPERSONA
													           			WHERE ((a.TZ_LOCK=0 AND a.CODIGO_ACTIVIDAD NOT IN (''000008'', ''000012'')) 
													           				  OR (e.ESTADOCIVIL<>''S''))
													           				  AND e.EDAD < (SELECT numerico FROM PARAMETROSGENERALES with (nolock) 
													           				  WHERE CODIGO=13)),0)
	
					
									ELSE
										SET @MENOR_EMANCIPADO=0

								   	IF @MENOR_EMANCIPADO > 0
										SET @MENOR_EMANCIPADO_FINAL=''S''
									ELSE
										SET @MENOR_EMANCIPADO_FINAL=''N''; 														
								   		
										
								    -- Evaluamos si son menores adolescentes
								    
								    IF @TIPO_CLIENTE_FINAL = ''F''
										SET @MENOR_ADOLE = ISNULL((SELECT COUNT(*) FROM @TMPEdadesIntegrantes 
														  		   WHERE TITULARIDAD=''T''
														  		   		AND EDAD > (SELECT numerico FROM PARAMETROSGENERALES  with (nolock) 
														  		  	    WHERE CODIGO=14 ) 
														  		   		AND EDAD < (SELECT importe 	FROM PARAMETROSGENERALES with (nolock) 	
														  		   		WHERE CODIGO=14 )), 0)
									ELSE 
										SET @MENOR_ADOLE = 0;
														   
								   							   							
									IF @MENOR_ADOLE > 0
										SET @MENOR_ADOLE_FINAL=''S''
									ELSE
										SET @MENOR_ADOLE_FINAL=''N'';
								
										
								   	-- Evaluamos si son menores autorizados
								   	
									IF @TIPO_CLIENTE_FINAL = ''F''
										SET @MENOR_AUTORIZ = ISNULL((SELECT COUNT(*) FROM @TMPEdadesIntegrantes 
														  			 WHERE TITULARIDAD = ''T'' 
														  				AND EDAD <=	(SELECT numerico FROM PARAMETROSGENERALES with (nolock) 
																		WHERE CODIGO=14 ) ), 0)
									ELSE 
										SET @MENOR_AUTORIZ = 0;
														   
								   							   							
									IF @MENOR_AUTORIZ > 0
										SET @MENOR_AUTORIZ_FINAL=''S''
									ELSE
										SET @MENOR_AUTORIZ_FINAL=''N'';							
						 						    			   
					    END
					         
  
END
')

