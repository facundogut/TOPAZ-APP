EXECUTE('
/****** Object:  StoredProcedure [dbo].[SP_PROD_OBTENGO_APODERAMIENTO]    Script Date: 01/06/2021 16:57:45 ******/
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
')
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

  DECLARE @NUMEROPERSONAREC AS NUMERIC(12,0)=0, 
   @EDADREC				AS float=0,
   @TIPOPERSONAREG		AS VARCHAR(1),
   @INTEGRACLIENTEREG	AS VARCHAR(1),
   @ESTADOCIVILREG		AS VARCHAR (1),
   @CANTIDAD_INTEG		AS float=0,
   @MAYOR_EDAD			AS VARCHAR(1)=''N'',
   @MAYOR_EDAD_FINAL		AS VARCHAR(1)=''N'',
   @MENOR_ADOLE			AS VARCHAR(1)=''N'',
   @MENOR_ADOLE_FINAL	AS VARCHAR(1)=''N'',
   @MENOR_EMANCIPADO_FINAL AS VARCHAR(1)=''N'',
   @MENOR_AUTORIZ		AS VARCHAR(1)=''N'',
   @MENOR_AUTORIZ_FINAL	AS VARCHAR(1)=''N'',
   @TIPO_CLIENTE			AS VARCHAR(1)=''F'',
   @TIPO_CLIENTE_FINAL	AS VARCHAR(1)=''F'',
   @ENCONTROEMANCIPADO_	as float(53),
  
   @APODER				AS VARCHAR(max)='''',
   @CANT_MIN_REG			AS float,
   @CANT_MAX_REG			AS float,
   @MAYOR_EDAD_REG		AS VARCHAR,
   @MENOR_ADOLESC_REG	AS VARCHAR,
   @MENOR_EMANCIPADO_REG AS VARCHAR,
   @MENOR_AUTORIZADO_REG AS VARCHAR,
   @TIPO_CLIENTE_REG		AS VARCHAR,
   @ARRAY_APODERAMIENTOS AS VARCHAR(255)=NULL,
   @MSGAUX				AS VARCHAR(999),
   @FLAG_MAYOREDAD		AS FLOAT=0,
   @FLAG_MENORADOL		AS FLOAT=0,
   @FLAG_MENOREMAN		AS FLOAT=0,
   @FLAG_MENORAUTO		AS FLOAT=0
  
  -- Msg por default
  SET @MSGAUX=''No existe parametría definida para Apoderados. Prod.: '' + convert(VARCHAR(5), @CodProducto) 

  SELECT	
  @TIPO_CLIENTE =(CASE 
					WHEN c.tipo =''F'' 
						THEN
  							''F''
  						ELSE
  							''J'' 
					END)
  FROM CLI_CLIENTES as c with (nolock)
  INNER JOIN SALDOS as s with (nolock) ON s.C1803=c.CODIGOCLIENTE
  WHERE JTS_OID= @Jts_oid
    

		-- Me van a pasar el prod, la persona y si integra el mismo para ir determinando el Apoderamiento
	   		
	    -- Analizo los integrantes y apoderados 
	    
   
   
   
		SET @CANTIDAD_INTEG = (SELECT count(*) AS CANTIDAD_APODERADOS
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
								b)

    DECLARE EdadesIntegrantesCur CURSOR FOR
  
						--************NO INTEGRA CLIENTE (Apoderado)****************
						
						SELECT	cp.NUMEROPERSONA, 
								cp.TIPOPERSONA,
								''A'' AS INTEGRA_CLIENTE,
				  
						-- INTEGRANTE DEL CLIENTE ES UNA PERSONA FISICA
						-- Muestro edad del mismo
								CASE 
									WHEN cp.tipopersona=''F - PERSONA HUMANA'' 
									THEN
										(SELECT FLOOR(DATEDIFF(month, FECHANACIMIENTO, (SELECT FECHAPROCESO 
																						FROM PARAMETROS with (nolock))) / CONVERT(FLOAT, 12))
										 FROM CLI_PERSONASFISICAS f with (nolock)
										 WHERE f.NUMEROPERSONAFISICA=cp.NUMEROPERSONA AND f.TZ_LOCK=0)
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
								 														AND f.TZ_LOCK=0 AND i.TZ_LOCK=0
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
																			AND f.TZ_LOCK=0 
																			AND i.TZ_LOCK=0)
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
																									AND i.NUMEROPERSONAJURIDICA=cp.NUMEROPERSONA
														 											AND f.TZ_LOCK=0 
																									AND i.TZ_LOCK=0 
																									AND [CODIGOCARGO]=''REP'')
												 ELSE
								    				-- Sino Muestro edad de Persona Física Integrante
									    			 (SELECT TOP (1) FLOOR(DATEDIFF(month, F.FECHANACIMIENTO, (	SELECT FECHAPROCESO 
																												FROM PARAMETROS with (nolock))) / CONVERT(FLOAT, 12))
													  FROM CLI_PERSONASFISICAS f with (nolock) 
													  INNER JOIN CLI_INTEGRANTESPJ i with (nolock)ON
																									f.NUMEROPERSONAFISICA=i.NUMEROPERSONAFISICA 
																									AND i.TIPO_PERSONA=''F'' 
																									AND i.NUMEROPERSONAJURIDICA=cp.NUMEROPERSONA
																									AND f.TZ_LOCK=0 
																									AND i.TZ_LOCK=0 
																									AND [CODIGOCARGO]<>''REP''
														)						 	
									    		 END	
									     END
							 END
									
						END AS EDAD,
						CASE WHEN cp.tipopersona=''F - PERSONA HUMANA'' THEN
						  (	SELECT F.ESTADOCIVIL 
							FROM CLI_PERSONASFISICAS f with (nolock)
							WHERE f.NUMEROPERSONAFISICA=cp.NUMEROPERSONA 
									AND f.TZ_LOCK=0
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
								 												AND f.TZ_LOCK=0 
																				AND i.TZ_LOCK=0)
								ELSE
						     	-- Sino Si el titular es una PJ 
								  -- Y a su vez no hay un Representante Legal
										CASE WHEN (	SELECT count (*) 
													FROM CLI_INTEGRANTESPJ with (nolock) 
													WHERE NUMEROPERSONAJURIDICA=cp.NUMEROPERSONA 
															AND [CODIGOCARGO]=''REP'')=0 THEN
										-- Se muestra Edad Persona Física Integrante
											(SELECT TOP (1) F.ESTADOCIVIL
											 FROM CLI_PERSONASFISICAS f WITH (NOLOCK)
											 INNER JOIN CLI_INTEGRANTESPJ i WITH (NOLOCK)ON
																					 f.NUMEROPERSONAFISICA=i.NUMEROPERSONAFISICA 
																						AND i.TIPO_PERSONA=''F'' 
																						AND i.NUMEROPERSONAJURIDICA=cp.NUMEROPERSONA
																						AND i.TIPOVINCULACION =''C'' 
																						AND f.TZ_LOCK=0 
																						AND i.TZ_LOCK=0
											)
										ELSE	 
									    -- Pero si hay un representante Legal
									          -- Y no hay otra PF como integrante
									    		CASE WHEN (	SELECT count (*) 
															FROM CLI_INTEGRANTESPJ with (nolock)
															WHERE NUMEROPERSONAJURIDICA=cp.NUMEROPERSONA 
																	AND [CODIGOCARGO]<>''REP'' 
																	AND TIPO_PERSONA=''F'')=0 THEN
									    			-- Muestro edad del RL
									    			 (
														SELECT F.ESTADOCIVIL
														FROM CLI_PERSONASFISICAS f with (nolock)
														INNER JOIN CLI_INTEGRANTESPJ i with (nolock)ON
																								 f.NUMEROPERSONAFISICA=i.NUMEROPERSONAFISICA 
																									AND i.TIPO_PERSONA=''F'' 
																									AND i.NUMEROPERSONAJURIDICA=cp.NUMEROPERSONA
														 											AND f.TZ_LOCK=0 
																									AND i.TZ_LOCK=0 
																									AND [CODIGOCARGO]=''REP''
														)
												 ELSE
								    				-- Sino Muestro edad de Persona Física Integrante
									    			 (SELECT TOP (1) F.ESTADOCIVIL
													  FROM CLI_PERSONASFISICAS f with (nolock)
													  INNER JOIN CLI_INTEGRANTESPJ i with (nolock)ON
																								 f.NUMEROPERSONAFISICA = i.NUMEROPERSONAFISICA 
																									AND i.NUMEROPERSONAJURIDICA=cp.NUMEROPERSONA
																									AND i.TIPO_PERSONA = ''F''
																									AND f.TZ_LOCK=0 
																									AND i.TZ_LOCK=0 
																									AND [CODIGOCARGO]<>''REP'')						 	
									    		 END	
									     END
							 END
									
						END AS ESTADO_CIVIL
						FROM VW_PERSONAS_F_Y_J cp  WITH (NOLOCK)
						WHERE cp.NUMEROPERSONA = @CodPersona
					
  ;

  OPEN EdadesIntegrantesCur;

			FETCH NEXT FROM EdadesIntegrantesCur  
					INTO @NUMEROPERSONAREC,@TIPOPERSONAREG,@INTEGRACLIENTEREG,@EDADREC,@ESTADOCIVILREG;
					WHILE @@FETCH_STATUS = 0 
		    	BEGIN
		    	
				
				-- Evaluamos si es mayor de edad
	   		
				IF @EDADREC>= (	SELECT numerico 
								FROM PARAMETROSGENERALES with (nolock) 
								WHERE [CODIGO]=13 ) 
							AND @Integra_Cliente=@INTEGRACLIENTEREG
							AND @TIPO_CLIENTE_FINAL=''F''
					SET @MAYOR_EDAD=''S''
					
				IF @MAYOR_EDAD=''S''
					SET @MAYOR_EDAD_FINAL=''S''
		
				-- Evaluamos si es menor emancipado
				
				SET @ENCONTROEMANCIPADO_ = 0
				
					SELECT @ENCONTROEMANCIPADO_ = count_big(*)
	            	FROM CLI_ACTIVIDAD_ECONOMICA with (nolock)
	           	    WHERE TZ_LOCK=0
	           	    AND CODIGO_PERSONA_CLIENTE= @NUMEROPERSONAREC
	           	    AND CODIGO_ACTIVIDAD NOT IN (''000008'', ''000012'')

				
			    IF (@ENCONTROEMANCIPADO_ > 0 OR @ESTADOCIVILREG <> ''S'') 
					AND @Integra_Cliente=@INTEGRACLIENTEREG 
					AND @EDADREC< (	SELECT numerico 
									FROM PARAMETROSGENERALES with (nolock) 
									WHERE [CODIGO]=13 
								  )
			    	AND @TIPO_CLIENTE_FINAL=''F''
			   		 SET @MENOR_EMANCIPADO_FINAL=''S'' 
					
			    -- Evaluamos si es menor adolescente, si es menor emancipado condiciona a que este campo sea N
			
				IF @EDADREC> (	SELECT numerico 
								FROM PARAMETROSGENERALES with (nolock) 
								WHERE [CODIGO]=14 
							  ) AND @EDADREC< (	SELECT importe 
												FROM PARAMETROSGENERALES with (nolock) 
												WHERE [CODIGO]=13 
											  )
						AND @Integra_Cliente=@INTEGRACLIENTEREG --AND @MENOR_EMANCIPADO_FINAL<>''S''
						AND @TIPO_CLIENTE_FINAL=''F''
					SET @MENOR_ADOLE=''S''
					
				IF @MENOR_ADOLE=''S''
					SET @MENOR_ADOLE_FINAL=''S''
					
			   	-- Evaluamos si es menor autorizado, si es menor emancipado condiciona a que este campo sea N
			
				IF @EDADREC<= (	SELECT numerico 
								FROM PARAMETROSGENERALES with (nolock) 
								WHERE [CODIGO]=14 ) 
					AND @Integra_Cliente=@INTEGRACLIENTEREG
						--AND @MENOR_EMANCIPADO_FINAL<>''S'' 
					AND @TIPO_CLIENTE_FINAL=''F''
					SET @MENOR_AUTORIZ=''S''
					
				IF @MENOR_AUTORIZ=''S''
					SET @MENOR_AUTORIZ_FINAL=''S''
				 
			   		 
			    -- Cantidad de Integrantes
			    IF @TIPO_CLIENTE_FINAL = ''F''
			    SET @CANTIDAD_INTEG=@CANTIDAD_INTEG+1
				 	   
	    		FETCH NEXT	FROM EdadesIntegrantesCur 
							INTO @NUMEROPERSONAREC,@TIPOPERSONAREG,@INTEGRACLIENTEREG,@EDADREC,@ESTADOCIVILREG;
	    			   
		    	END
		   
		 CLOSE EdadesIntegrantesCur;
         
         DEALLOCATE EdadesIntegrantesCur;
         
        PRINT  @CANTIDAD_INTEG;
        PRINT  @MAYOR_EDAD_FINAL;
        PRINT  @MENOR_EMANCIPADO_FINAL;
        PRINT  @MENOR_AUTORIZ_FINAL;
        PRINT  @MENOR_ADOLE_FINAL;
        PRINT  @TIPO_CLIENTE_FINAL;
        PRINT  @INTEGRACLIENTEREG;
   
   
     DECLARE ApoderamientosCur CURSOR FOR  
     
 	SELECT	pd.APODERAMIENTO, pd.CANT_MIN, pd.CANT_MAX, pd.MAYOR_EDAD,
     		PD.MENOR_ADOLESCENTE, pd.MENOR_EMANCIPADO, pd.MENOR_AUTORIZADO,pd.TIPO_CLIENTE
     	FROM PROD_RELCLIENTE pd with (nolock)
		INNER JOIN PRODUCTOS p with (nolock) ON p.C6250=pd.PRODUCTO 
												AND p.TZ_LOCK=0
		INNER JOIN PYF_TIPOAPODERAMIENTO a with (nolock) ON a.CODAPODERAMIENTO=pd.APODERAMIENTO 
															AND a.TZ_LOCK=0
		WHERE pd.PRODUCTO=@CodProducto 
				AND pd.TITULAR_APODERADO=@Integra_Cliente
				AND pd.TIPO_CLIENTE=@TIPO_CLIENTE 
				AND pd.CANT_MIN<=@CANTIDAD_INTEG 
				AND pd.CANT_MAX>=@CANTIDAD_INTEG 

			 	
	;
		
		
     OPEN ApoderamientosCur;
     
     		FETCH NEXT	FROM ApoderamientosCur 
						INTO @APODER, @CANT_MIN_REG, @CANT_MAX_REG, @MAYOR_EDAD_REG, @MENOR_ADOLESC_REG ,
 												 @MENOR_EMANCIPADO_REG, @MENOR_AUTORIZADO_REG, @TIPO_CLIENTE_REG;
     					WHILE @@FETCH_STATUS=0
			BEGIN
			   
			    PRINT @APODER;
			    SET @FLAG_MAYOREDAD=0
			    SET @FLAG_MENORADOL=0
			    SET @FLAG_MENOREMAN=0
			    SET @FLAG_MENORAUTO=0

					  
			    -- Evaluamos si la parametría respeta característica de la persona
						
				IF (@MAYOR_EDAD_FINAL=''S''AND @MAYOR_EDAD_REG=''S'') 
					SET @FLAG_MAYOREDAD=1
				IF (@MENOR_ADOLE_FINAL=''S''AND @MENOR_ADOLESC_REG=''S'')
					SET @FLAG_MENORADOL=1
				IF (@MENOR_EMANCIPADO_FINAL=''S''AND @MENOR_EMANCIPADO_REG =''S'') 
					SET @FLAG_MENOREMAN=1	
				IF (@MENOR_AUTORIZ_FINAL =''S'' AND @MENOR_AUTORIZADO_REG =''S'')
					SET @FLAG_MENORAUTO=1
				
				IF 	@FLAG_MAYOREDAD = 0 AND @FLAG_MENORADOL =0 AND  @FLAG_MENOREMAN=0 AND @FLAG_MENORAUTO=0			
				   	SET @APODER=0
			   	    	   
	    	   IF @APODER<>0 
	    	   BEGIN	       
			        SET @ARRAY_APODERAMIENTOS=ISNULL(@ARRAY_APODERAMIENTOS+'','', '''')+ISNULL(@APODER, '''');
			        SET @MSGAUX=''Apoderamientos Ok''
	           END
	        
	    	FETCH NEXT FROM ApoderamientosCur INTO @APODER, @CANT_MIN_REG, @CANT_MAX_REG, @MAYOR_EDAD_REG, @MENOR_ADOLESC_REG ,
 												 @MENOR_EMANCIPADO_REG, @MENOR_AUTORIZADO_REG,  @TIPO_CLIENTE_REG;     	   	    			   
		   	END

		   
		 CLOSE ApoderamientosCur;
         
         DEALLOCATE ApoderamientosCur;
    
		;
  
  SET @Apoderamientos=@ARRAY_APODERAMIENTOS;
  SET @MSG=@MSGAUX;
  SET NOCOUNT OFF;
END
')