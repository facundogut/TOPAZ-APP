EXECUTE('
ALTER PROCEDURE [dbo].[SP_PROD_OBTENGO_APODERAMIENTO]
  @CodPersona		NUMERIC(12,0),
  @CodProducto		NUMERIC(5, 0),
  @Integra_Cliente	VARCHAR(1),
  @Jts_oid			numeric (12),    
  @Apoderamientos	VARCHAR(999) OUTPUT,
  @Msg				VARCHAR (999) OUTPUT
  
AS
BEGIN


  ------------Tablas auxiliares--------------
  
		  	DECLARE @TMPEdadesIntegrantes TABLE(
				    NUMEROPERSONA NUMERIC (12, 0),
					TIPOPERSONA VARCHAR(50),
					TITULARIDAD VARCHAR(1),
					EDAD FLOAT,
					ESTADOCIVIL VARCHAR(1)
					)
  
			DECLARE @TMPApoderamientos TABLE(
				    APODERAMIENTO FLOAT,
					CANT_MIN FLOAT,
					CANT_MAX FLOAT,
					MAYOR_EDAD VARCHAR(1),
					MENOR_ADOLESC VARCHAR(1),
					MENOR_EMANCIPADO VARCHAR(1),
					MENOR_AUTORIZADO VARCHAR(1),
					TIPO_CLIENTE VARCHAR(1)
					)
					
	
	------------Cargo Tablas auxiliares--------------
	
	--************NO INTEGRA CLIENTE (Apoderado)****************
		
		-- Me van a pasar el prod, la persona y si integra el mismo para ir determinando el Apoderamiento
	   		
	    -- Analizo apoderado y cargo tabla temporal de edad
	
				INSERT INTO @TMPEdadesIntegrantes
					SELECT		cp.NUMEROPERSONA, 
								cp.TIPOPERSONA,
								''A'' AS TITULARIDAD,
				  
						-- INTEGRANTE DEL CLIENTE ES UNA PERSONA FISICA
						-- Muestro edad del mismo
								CASE 
									WHEN cp.tipopersona=''F - PERSONA HUMANA'' 
									THEN
										(SELECT FLOOR(DATEDIFF(month, FECHANACIMIENTO, (SELECT FECHAPROCESO 
																						FROM PARAMETROS with (nolock))) / CONVERT(FLOAT, 12))
										 FROM CLI_PERSONASFISICAS f with (nolock)
										 WHERE f.NUMEROPERSONAFISICA=cp.NUMEROPERSONA 
										 AND (f.TZ_LOCK < 300000000000000 OR f.TZ_LOCK >= 400000000000000) 
										 AND (f.TZ_LOCK < 100000000000000 OR f.TZ_LOCK >= 200000000000000))
								ELSE
										-- INTEGRANTE DEL CLIENTE ES UNA PERSONA JURÍDICA
										-- Si el titular de esa PJ es una PF se muestra la edad de ella.
									CASE WHEN (	SELECT count (*) 
												FROM CLI_INTEGRANTESPJ with (nolock) 
												WHERE TIPOVINCULACION =''T'' 
													AND TIPO_PERSONA=''F'' 
													AND NUMEROPERSONAJURIDICA=cp.NUMEROPERSONA) > 0 THEN 
										(	SELECT FLOOR(DATEDIFF(month, F.FECHANACIMIENTO, (SELECT FECHAPROCESO FROM PARAMETROS with (nolock))) / CONVERT(FLOAT, 12))
											FROM CLI_PERSONASFISICAS f with (nolock) 
											INNER JOIN CLI_INTEGRANTESPJ i with (nolock)ON f.NUMEROPERSONAFISICA=i.NUMEROPERSONAFISICA 
																						AND i.TIPOVINCULACION =''T'' 
																						AND i.TIPO_PERSONA=''F'' 
																						AND i.NUMEROPERSONAJURIDICA=cp.NUMEROPERSONA
								 														AND i.TZ_LOCK=0
								 														AND (f.TZ_LOCK < 300000000000000 OR f.TZ_LOCK >= 400000000000000) 
										 												AND (f.TZ_LOCK < 100000000000000 OR f.TZ_LOCK >= 200000000000000) 
										)
									ELSE
						     	-- Sino Si el titular es una PJ 
								  -- Y a su vez no hay un Representante Legal
										CASE WHEN (SELECT count (*) 
													FROM CLI_INTEGRANTESPJ WITH (NOLOCK) 
													WHERE NUMEROPERSONAJURIDICA=cp.NUMEROPERSONA 
														AND CODIGOCARGO=''REP'')=0 
										THEN
										-- Se muestra Edad Persona Física Integrante
										(SELECT TOP (1) FLOOR(DATEDIFF(month, F.FECHANACIMIENTO, (	SELECT FECHAPROCESO 
																									FROM PARAMETROS with (nolock))) / CONVERT(FLOAT, 12))
										FROM CLI_PERSONASFISICAS f with (nolock) 
										INNER JOIN CLI_INTEGRANTESPJ i with (nolock)ON
																	f.NUMEROPERSONAFISICA=i.NUMEROPERSONAFISICA 
																	AND i.TIPO_PERSONA=''F'' 
																	AND i.NUMEROPERSONAJURIDICA=cp.NUMEROPERSONA
																	AND i.TIPOVINCULACION =''C'' 
																	AND i.TZ_LOCK=0
																	AND (f.TZ_LOCK < 300000000000000 OR f.TZ_LOCK >= 400000000000000) 
								 									AND (f.TZ_LOCK < 100000000000000 OR f.TZ_LOCK >= 200000000000000))
										ELSE	 
									    -- Pero si hay un representante Legal
									          -- Y no hay otra PF como integrante
									    		CASE WHEN (	SELECT count (*) 
															FROM CLI_INTEGRANTESPJ with (nolock) 
															WHERE NUMEROPERSONAJURIDICA=cp.NUMEROPERSONA 
																AND CODIGOCARGO<>''REP'' 
																AND TIPO_PERSONA=''F'')=0 THEN
									    			-- Muestro edad del RL
									    			(SELECT FLOOR(DATEDIFF(month, F.FECHANACIMIENTO, (	SELECT FECHAPROCESO 
																										FROM PARAMETROS with (nolock))) / CONVERT(FLOAT, 12))
													FROM CLI_PERSONASFISICAS f with (nolock)
													INNER JOIN CLI_INTEGRANTESPJ i with (nolock) ON
																							f.NUMEROPERSONAFISICA=i.NUMEROPERSONAFISICA 
																							AND i.TIPO_PERSONA=''F'' 
																							AND i.NUMEROPERSONAJURIDICA=22274--cp.NUMEROPERSONA
																							AND i.TZ_LOCK=0 
																							AND CODIGOCARGO=''REP''
												 											AND (f.TZ_LOCK < 300000000000000 OR f.TZ_LOCK >= 400000000000000) 
																							AND (f.TZ_LOCK < 100000000000000 OR f.TZ_LOCK >= 200000000000000))
												 ELSE
								    				-- Sino Muestro edad de Persona Física Integrante
									    			(SELECT TOP (1) FLOOR(DATEDIFF(month, F.FECHANACIMIENTO, (	SELECT FECHAPROCESO 
																												FROM PARAMETROS with (nolock))) / CONVERT(FLOAT, 12))
													FROM CLI_PERSONASFISICAS f with (nolock) 
													INNER JOIN CLI_INTEGRANTESPJ i with (nolock)ON
																							f.NUMEROPERSONAFISICA=i.NUMEROPERSONAFISICA 
																							AND i.TIPO_PERSONA=''F'' 
																							AND i.NUMEROPERSONAJURIDICA=cp.NUMEROPERSONA
																							AND i.TZ_LOCK=0 
																							AND CODIGOCARGO<>''REP''
																							AND (f.TZ_LOCK < 300000000000000 OR f.TZ_LOCK >= 400000000000000) 
																							AND (f.TZ_LOCK < 100000000000000 OR f.TZ_LOCK >= 200000000000000)
													)						 	
									    		 END	
									      END
							 		END
							 	
								END AS EDAD,
								
								CASE WHEN cp.tipopersona=''F - PERSONA HUMANA'' THEN
								  (	SELECT F.ESTADOCIVIL 
									FROM CLI_PERSONASFISICAS f with (nolock)
									WHERE 
										f.NUMEROPERSONAFISICA=cp.NUMEROPERSONA 
										AND (f.TZ_LOCK < 300000000000000 OR f.TZ_LOCK >= 400000000000000) 
										AND (f.TZ_LOCK < 100000000000000 OR f.TZ_LOCK >= 200000000000000)
								  )
								ELSE
										-- INTEGRANTE DEL CLIENTE ES UNA PERSONA JURÍDICA
										-- Si el titular de esa PJ es una PF se muestra la edad de ella.
										CASE WHEN (	SELECT count (*) 
													FROM CLI_INTEGRANTESPJ with (nolock) 
													WHERE TIPOVINCULACION =''T'' 
															AND TIPO_PERSONA=''F'' 
															AND NUMEROPERSONAJURIDICA=cp.NUMEROPERSONA)>0 THEN 
											 (	SELECT F.ESTADOCIVIL
												FROM CLI_PERSONASFISICAS f WITH (NOLOCK)
												INNER JOIN CLI_INTEGRANTESPJ i WITH (NOLOCK) ON
																						f.NUMEROPERSONAFISICA=i.NUMEROPERSONAFISICA 
																						AND i.TIPOVINCULACION =''T'' 
																						AND i.TIPO_PERSONA=''F'' 
																						AND i.NUMEROPERSONAJURIDICA=cp.NUMEROPERSONA
																						AND i.TZ_LOCK=0
										 												AND (f.TZ_LOCK < 300000000000000 OR f.TZ_LOCK >= 400000000000000) 
																						AND (f.TZ_LOCK < 100000000000000 OR f.TZ_LOCK >= 200000000000000) 
																						)
										ELSE
								     	-- Sino Si el titular es una PJ 
										  -- Y a su vez no hay un Representante Legal
												CASE WHEN (	SELECT count (*) 
															FROM CLI_INTEGRANTESPJ with (nolock) 
															WHERE NUMEROPERSONAJURIDICA=cp.NUMEROPERSONA 
																	AND CODIGOCARGO=''REP'')=0 THEN
												-- Se muestra Edad Persona Física Integrante
													(SELECT TOP (1) F.ESTADOCIVIL
													 FROM CLI_PERSONASFISICAS f WITH (NOLOCK)
													 INNER JOIN CLI_INTEGRANTESPJ i WITH (NOLOCK)ON
																							f.NUMEROPERSONAFISICA=i.NUMEROPERSONAFISICA 
																							AND i.TIPO_PERSONA=''F'' 
																							AND i.NUMEROPERSONAJURIDICA=cp.NUMEROPERSONA
																							AND i.TIPOVINCULACION =''C'' 
																							AND i.TZ_LOCK=0
																							AND (f.TZ_LOCK < 300000000000000 OR f.TZ_LOCK >= 400000000000000) 
																							AND (f.TZ_LOCK < 100000000000000 OR f.TZ_LOCK >= 200000000000000)
													)
												ELSE	 
											    -- Pero si hay un representante Legal
											          -- Y no hay otra PF como integrante
											    		CASE WHEN (	SELECT count (*) 
																	FROM CLI_INTEGRANTESPJ with (nolock)
																	WHERE NUMEROPERSONAJURIDICA=cp.NUMEROPERSONA 
																			AND CODIGOCARGO<>''REP'' 
																			AND TIPO_PERSONA=''F'')=0 THEN
											    			-- Muestro edad del RL
											    			 (
																SELECT F.ESTADOCIVIL
																FROM CLI_PERSONASFISICAS f with (nolock)
																INNER JOIN CLI_INTEGRANTESPJ i with (nolock)ON
																							f.NUMEROPERSONAFISICA=i.NUMEROPERSONAFISICA 
																							AND i.TIPO_PERSONA=''F'' 
																							AND i.NUMEROPERSONAJURIDICA=cp.NUMEROPERSONA
																							AND i.TZ_LOCK=0 
																							AND CODIGOCARGO=''REP''
												 											AND (f.TZ_LOCK < 300000000000000 OR f.TZ_LOCK >= 400000000000000) 
																							AND (f.TZ_LOCK < 100000000000000 OR f.TZ_LOCK >= 200000000000000)
																)
														 ELSE
										    				-- Sino Muestro edad de Persona Física Integrante
											    			 (SELECT TOP (1) F.ESTADOCIVIL
															  FROM CLI_PERSONASFISICAS f with (nolock)
															  INNER JOIN CLI_INTEGRANTESPJ i with (nolock)ON
																							f.NUMEROPERSONAFISICA = i.NUMEROPERSONAFISICA 
																							AND i.NUMEROPERSONAJURIDICA=cp.NUMEROPERSONA
																							AND i.TIPO_PERSONA = ''F''
																							AND i.TZ_LOCK=0 
																							AND CODIGOCARGO<>''REP''						 	
																							AND (f.TZ_LOCK < 300000000000000 OR f.TZ_LOCK >= 400000000000000) 
																							AND (f.TZ_LOCK < 100000000000000 OR f.TZ_LOCK >= 200000000000000)
															)
											    		 END	
											END
									 END
								END AS ESTADO_CIVIL
								FROM VW_PERSONAS_F_Y_J cp  WITH (NOLOCK)
								WHERE cp.NUMEROPERSONA = @CodPersona
	
				-- Tipo de cliente	
 			  	
				DECLARE @TIPO_CLIENTE_FINAL AS VARCHAR
							 
							  SELECT @TIPO_CLIENTE_FINAL =(CASE 
															WHEN c.tipo =''F'' 
																THEN
										  							''F''
										  						ELSE
										  							''J'' 
												     		END)
							  FROM CLI_CLIENTES as c with (nolock)
								  	INNER JOIN SALDOS as s with (nolock) ON s.C1803=c.CODIGOCLIENTE
								    WHERE JTS_OID= @Jts_oid
								    
				-- Cantidad de Integrantes 
				
				DECLARE @CANTIDAD_INTEG AS FLOAT
						   
				SET @CANTIDAD_INTEG = ISNULL((SELECT count(*) AS CANTIDAD_APODERADOS
											  FROM 
													(
													SELECT ID_PERSONA 
													FROM VW_APODERADOS WITH (NOLOCK)
													WHERE ID_ENTIDAD=CAST(@Jts_oid AS VARCHAR) 
													AND TIPO_ENTIDAD=2 
													AND ID_PERSONA <> @CodPersona
													AND NOT exists (SELECT * 
																	from cli_clientepersona with (nolock)
																	WHERE NUMEROPERSONA=ID_PERSONA AND
																			CODIGOCLIENTE IN (	SELECT C1803 
																								FROM SALDOS with (nolock) 
																								WHERE JTS_OID = @Jts_oid))
													GROUP BY ID_PERSONA
													) 
												b)+1,0)
												
				-- Tabla temporal de Apoderamientos disponibles
				
				INSERT INTO @TMPApoderamientos
							 	SELECT	pd.APODERAMIENTO, pd.CANT_MIN, pd.CANT_MAX, pd.MAYOR_EDAD,
								     		PD.MENOR_ADOLESCENTE, pd.MENOR_EMANCIPADO, pd.MENOR_AUTORIZADO,pd.TIPO_CLIENTE
								     	FROM PROD_RELCLIENTE pd with (nolock)
										INNER JOIN PRODUCTOS p with (nolock) ON p.C6250=pd.PRODUCTO 
																				AND p.TZ_LOCK=0
										INNER JOIN PYF_TIPOAPODERAMIENTO a with (nolock) ON a.CODAPODERAMIENTO=pd.APODERAMIENTO 
																							AND a.TZ_LOCK=0
										WHERE 
											pd.PRODUCTO=@CodProducto 
											AND pd.TITULAR_APODERADO=@Integra_Cliente
											AND pd.TIPO_CLIENTE=@TIPO_CLIENTE_FINAL 
											AND pd.CANT_MIN<=@CANTIDAD_INTEG 
											AND pd.CANT_MAX>=@CANTIDAD_INTEG 
			
				-- Variables para utilizar únicamente en el análisis de integrantes y concluir resultados finales
								
				DECLARE
					@MAYOR_EDAD AS float(53)=0,
					@MENOR_ADOLE AS float(53)=0,
					@MENOR_AUTORIZ AS float(53)=0,
					@MENOR_EMANCIPADO AS float(53)=0,
						   
					@MAYOR_EDAD_FINAL	AS VARCHAR(1),
					@MENOR_ADOLE_FINAL	AS VARCHAR(1),
					@MENOR_EMANCIPADO_FINAL AS VARCHAR(1),
					@MENOR_AUTORIZ_FINAL	AS VARCHAR(1),
			  			
					@MSGAUX			AS VARCHAR(999)

			  
			  	-- Msg por default
			 	 SET @MSGAUX=''No existe parametría definida para Apoderados. Prod.: '' + convert(VARCHAR(5), @CodProducto) 
 

		    	 BEGIN
		    	
							-- Evaluamos si es mayor de edad
				   		
									SET @MAYOR_EDAD = ISNULL((SELECT COUNT(*) FROM @TMPEdadesIntegrantes 
													  		  WHERE TITULARIDAD = @Integra_Cliente 
													  		  	AND EDAD >= ( SELECT numerico FROM PARAMETROSGENERALES with (nolock) 
													  		  	WHERE CODIGO=13 )), 0)
	   							
									IF @MAYOR_EDAD > 0
										SET @MAYOR_EDAD_FINAL=''S''
									ELSE
										SET @MAYOR_EDAD_FINAL=''N'';
					
							-- Evaluamos si es menor emancipado
									
						           			
					           	 	SET @MENOR_EMANCIPADO =	ISNULL((SELECT count_big(*) FROM @TMPEdadesIntegrantes e
												            		INNER JOIN CLI_ACTIVIDAD_ECONOMICA a ON a.CODIGO_PERSONA_CLIENTE=e.NUMEROPERSONA
												           			WHERE ((a.TZ_LOCK=0 AND a.CODIGO_ACTIVIDAD NOT IN (''000008'', ''000012'')) 
												           				  OR (e.ESTADOCIVIL<>''S''))
												           				  AND e.EDAD < (SELECT numerico FROM PARAMETROSGENERALES with (nolock) 
												           				  WHERE CODIGO=13)),0)	

								   	IF @MENOR_EMANCIPADO > 0
										SET @MENOR_EMANCIPADO_FINAL=''S''
									ELSE
										SET @MENOR_EMANCIPADO_FINAL=''N''; 
								
						    -- Evaluamos si es menor adolescente
						
									SET @MENOR_ADOLE = ISNULL((SELECT COUNT(*) FROM @TMPEdadesIntegrantes 
													  		   WHERE TITULARIDAD=''T''
													  		   		AND EDAD > (SELECT numerico FROM PARAMETROSGENERALES  with (nolock) 
													  		  	    WHERE CODIGO=14 ) 
													  		   		AND EDAD < (SELECT importe 	FROM PARAMETROSGENERALES with (nolock) 	
													  		   		WHERE CODIGO=14 )), 0)
						   							
									IF @MENOR_ADOLE > 0
										SET @MENOR_ADOLE_FINAL=''S''
									ELSE
										SET @MENOR_ADOLE_FINAL=''N'';
								
						   	-- Evaluamos si es menor autorizado

									SET @MENOR_AUTORIZ = ISNULL((SELECT COUNT(*) FROM @TMPEdadesIntegrantes 
													  			 WHERE TITULARIDAD = ''T'' 
													  				AND EDAD <=	(SELECT numerico FROM PARAMETROSGENERALES with (nolock) 
																	WHERE CODIGO=14 ) ), 0)
	   							
									IF @MENOR_AUTORIZ > 0
										SET @MENOR_AUTORIZ_FINAL=''S''
									ELSE
										SET @MENOR_AUTORIZ_FINAL=''N'';
											    			   
		    	END		
  
				BEGIN
				
				-- Variables para utilizar únicamente en el análisis de integrantes y concluir resultados finales
			   		   DECLARE
			   		   		   @Apoder				AS VARCHAR(max)='''',
					   		   @FLAG_APODER			AS FLOAT=0, 
					   		   @FLAG_MAYOREDAD		AS FLOAT=0,
							   @FLAG_MENORADOL		AS FLOAT=0,
							   @FLAG_MENOREMAN		AS FLOAT=0,
							   @FLAG_MENORAUTO		AS FLOAT=0,
					   		   @ARRAY_APODERAMIENTOS AS VARCHAR(255)=NULL

    		    -- Evaluamos si la parametría respeta característica de la persona
				 					
							IF (@MAYOR_EDAD_FINAL=''S''AND (SELECT Count(*) FROM @TMPApoderamientos WHERE MAYOR_EDAD=''S'')>0) 
								SET @FLAG_MAYOREDAD=1
								SET @FLAG_APODER=1
							IF (@MENOR_ADOLE_FINAL=''S''AND (SELECT Count(*) FROM @TMPApoderamientos WHERE MENOR_ADOLESC=''S'')>0)
								SET @FLAG_MENORADOL=1
								SET @FLAG_APODER=1
							IF (@MENOR_EMANCIPADO_FINAL=''S''AND (SELECT Count(*) FROM @TMPApoderamientos WHERE MENOR_EMANCIPADO=''S'')>0) 
								SET @FLAG_MENOREMAN=1 
								SET @FLAG_APODER=1	
							IF (@MENOR_AUTORIZ_FINAL =''S'' AND (SELECT Count(*) FROM @TMPApoderamientos WHERE MENOR_AUTORIZADO=''S'')>0)
								SET @FLAG_MENORAUTO=1
								SET @FLAG_APODER=1
							
							IF 	@FLAG_MAYOREDAD = 0 AND @FLAG_MENORADOL =0 AND  @FLAG_MENOREMAN=0 AND @FLAG_MENORAUTO=0			
							   	SET @FLAG_APODER=0
   	
  		   	    	   
					    	IF @FLAG_APODER<>0 
					    	
					    	   BEGIN 
					    	   			--Recorro tabla Temporal ya que necesito armar un array para la operación con los Apoderamientos--
											
											WHILE EXISTS (SELECT * FROM @TMPApoderamientos)
												BEGIN
													SELECT
														TOP 1 @Apoder=APODERAMIENTO
													FROM @TMPApoderamientos
													ORDER BY 
														APODERAMIENTO
				
												    SET @ARRAY_APODERAMIENTOS=ISNULL(@ARRAY_APODERAMIENTOS+'','', '''')+ISNULL(@Apoder, '''');	
													
													DELETE FROM @TMPApoderamientos WHERE APODERAMIENTO=@Apoder
												END		
											    	   		
					    	   		 		SET @MSGAUX=''Apoderamientos Ok''
					           END
 	   	    			   
		   		 END
		   	
  -- DEVOLUCIÓN DEL SP: Apoderamientos en cadena y mensaje final
  
  SET @Apoderamientos=@ARRAY_APODERAMIENTOS;
  SET @MSG=@MSGAUX;
  

END
')

