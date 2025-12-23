EXECUTE('
ALTER PROCEDURE PA_ACTUALIZAR_CONDICINES_IMPOSITIVAS
   @P_ID_PROCESO 	         FLOAT(53),
   @P_DT_PROCESO	         DATETIME2(0),
   @P_NRO_OPERACION		     NUMERIC(5), --para grabar en bitácora
   @P_CODIGO_CLIENTE	     NUMERIC(12),--cliente y cargo o tipo de cargo para consultar
   @P_NUM_PERSONA            NUMERIC(12),--Numero de persona para conseguir todos los clientes asociados
   @P_TIPO_CARGO_IMPOSITIVO	 NUMERIC(2), --evaluar si tipo de cargo, o directamente el cargo o impuesto y lo obtenemos
   @P_CARGO_O_IMPUESTO		 VARCHAR(6), -- Las que son con letras ingreso esta?
   @P_ALICUOTA               NUMERIC(11,7), --para saber si buscar por cargo o impuesto. No tienen por que ser iguales los tipos.
   @P_RET_PROCESO	         NUMERIC(20)  OUTPUT,
   @P_MSG_PROCESO	         VARCHAR(MAX)  OUTPUT,
   @P_ACTUALIZO_CLIENTE      VARCHAR(1) OUTPUT, --Actualizo Cliente
   @P_CARGO_O_IMPUESTO_NUEVO VARCHAR(6) OUTPUT, --Regimen de impuesto nuevo
   @P_ALICUOTA_MAS_ALTA      NUMERIC(11,7) OUTPUT, --Valor de Alicuota mas alta que tenía la persona
   @P_PERSONA_MG			 NUMERIC(12) OUTPUT -- Persona mas Gravosa
AS 
BEGIN
    SET @P_RET_PROCESO = NULL;
    SET @P_MSG_PROCESO = NULL;

    SELECT @P_DT_PROCESO = FECHAPROCESO FROM PARAMETROS;

    DECLARE
        @v_constante VARCHAR(1), 
        @v_persona       NUMERIC(12),
		@aliMaxAntSIRCREB VARCHAR (1),
		@aliMaxAntIIBB NUMERIC(11,7),
		@condMaxAntIIBB VARCHAR(2);

-- SIRCREB
    IF @P_TIPO_CARGO_IMPOSITIVO = 5
    BEGIN 
		-- Obtener la alícuota máxima actual de todas las personas del cliente
		SELECT TOP 1 
			@aliMaxAntSIRCREB = MAX(PF.SIRCREB), 
			@v_persona = CP.NUMEROPERSONA 
		FROM 
			CLI_ClientePersona CP WITH (NOLOCK)
		INNER JOIN 
			CLI_PERSONASFISICAS PF WITH (NOLOCK) 
			ON CP.NUMEROPERSONA = PF.NUMEROPERSONAFISICA 
			AND PF.TZ_LOCK = 0
		WHERE 
			CP.CODIGOCLIENTE = @P_CODIGO_CLIENTE
			AND CP.TZ_LOCK = 0
		GROUP BY 
			CP.NUMEROPERSONA
		ORDER BY 
			MAX(PF.SIRCREB) DESC;
			
		
		-- Verificar si la alícuota ingresada es diferente a la alícuota máxima actual
		IF @P_CARGO_O_IMPUESTO <> @aliMaxAntSIRCREB
		BEGIN
			IF @P_CARGO_O_IMPUESTO != ''''
			BEGIN
				IF @P_CARGO_O_IMPUESTO >= @aliMaxAntSIRCREB 
				BEGIN 
					SET @P_ACTUALIZO_CLIENTE = ''S'';
					SET @P_CARGO_O_IMPUESTO_NUEVO = @P_CARGO_O_IMPUESTO 
					SET @P_ALICUOTA_MAS_ALTA = NULL;
					SET @P_PERSONA_MG = @P_NUM_PERSONA 
				END
				ELSE -- Alicuota nueva es menor a la actual
				BEGIN
					SET @P_ACTUALIZO_CLIENTE = CASE WHEN @v_persona = @P_NUM_PERSONA THEN ''S'' ELSE ''N'' END;
					SET @P_CARGO_O_IMPUESTO_NUEVO = (SELECT CASE WHEN @v_persona = @P_NUM_PERSONA THEN ISNULL((
													SELECT TOP 1
														MAX(PF.SIRCREB)
													FROM 
														CLI_ClientePersona CP WITH (NOLOCK)
													INNER JOIN 
														CLI_PERSONASFISICAS PF WITH (NOLOCK) 
														ON CP.NUMEROPERSONA = PF.NUMEROPERSONAFISICA 
														AND PF.TZ_LOCK = 0
													WHERE 
														CP.CODIGOCLIENTE = @P_CODIGO_CLIENTE
														AND CP.NUMEROPERSONA != @v_persona
														AND PF.SIRCREB <= @aliMaxAntSIRCREB
														AND PF.SIRCREB > @P_CARGO_O_IMPUESTO 
														AND CP.TZ_LOCK = 0
													GROUP BY 
														CP.NUMEROPERSONA
													ORDER BY 
														MAX(PF.SIRCREB) DESC),@P_CARGO_O_IMPUESTO)
													ELSE
														@aliMaxAntSIRCREB
													END);
					SET @P_ALICUOTA_MAS_ALTA = NULL;
					SET @P_PERSONA_MG = (SELECT CASE WHEN @v_persona = @P_NUM_PERSONA THEN ISNULL((
													SELECT TOP 1
														CP.NUMEROPERSONA 
													FROM 
														CLI_ClientePersona CP WITH (NOLOCK)
													INNER JOIN 
														CLI_PERSONASFISICAS PF WITH (NOLOCK) 
														ON CP.NUMEROPERSONA = PF.NUMEROPERSONAFISICA 
														AND PF.TZ_LOCK = 0
													WHERE 
														CP.CODIGOCLIENTE = @P_CODIGO_CLIENTE
														AND CP.NUMEROPERSONA != @v_persona
														AND PF.SIRCREB <= @aliMaxAntSIRCREB
														AND PF.SIRCREB > @P_CARGO_O_IMPUESTO
														AND CP.TZ_LOCK = 0
													GROUP BY 
														CP.NUMEROPERSONA
													ORDER BY 
														MAX(PF.SIRCREB) DESC),@v_persona)
										ELSE 
											@v_persona
										END); 
				END
			END
			ELSE -- Si es igual a vacio
			BEGIN
				SET @P_ACTUALIZO_CLIENTE = CASE WHEN @v_persona = @P_NUM_PERSONA THEN ''S'' ELSE ''N'' END;
				SET @P_CARGO_O_IMPUESTO_NUEVO = (SELECT CASE WHEN @v_persona = @P_NUM_PERSONA THEN (
												SELECT TOP 1
													MAX(PF.SIRCREB)
												FROM 
													CLI_ClientePersona CP WITH (NOLOCK)
												INNER JOIN 
													CLI_PERSONASFISICAS PF WITH (NOLOCK) 
													ON CP.NUMEROPERSONA = PF.NUMEROPERSONAFISICA 
													AND PF.TZ_LOCK = 0
												WHERE 
													CP.CODIGOCLIENTE = @P_CODIGO_CLIENTE
													AND CP.NUMEROPERSONA != @v_persona
													AND PF.SIRCREB <= @aliMaxAntSIRCREB
													AND CP.TZ_LOCK = 0
												GROUP BY 
													CP.NUMEROPERSONA
												ORDER BY 
													MAX(PF.SIRCREB) DESC) 
			
												WHEN @v_persona != @P_NUM_PERSONA 
												AND 
												(
													SELECT COUNT(*)  
													FROM CLI_ClientePersona CPP WITH(NOLOCK)
													INNER JOIN CLI_PERSONASFISICAS PFF WITH(NOLOCK) 
														ON PFF.NUMEROPERSONAFISICA = CPP.NUMEROPERSONA
														AND PFF.TZ_LOCK = 0
													WHERE CPP.CODIGOCLIENTE = @P_CODIGO_CLIENTE 
													AND CPP.TZ_LOCK = 0 
													AND PFF.NUMEROPERSONAFISICA != @P_NUM_PERSONA 
													AND PFF.SIRCREB != ''''  -- Asegurar que la alícuota sea mayor que 0
												) > 0 
												THEN
														(SELECT TOP 1
														MAX(PF2.SIRCREB)
														FROM CLI_ClientePersona CP2 WITH(NOLOCK)
														INNER JOIN CLI_PERSONASFISICAS PF2 WITH(NOLOCK) ON
															PF2.NUMEROPERSONAFISICA = CP2.NUMEROPERSONA
															AND PF2.TZ_LOCK=0
														WHERE CP2.CODIGOCLIENTE = @P_CODIGO_CLIENTE AND
														CP2.TZ_LOCK = 0 AND 
														PF2.NUMEROPERSONAFISICA != @P_NUM_PERSONA AND
														PF2.SIRCREB!=''''
														GROUP BY 
															CP2.NUMEROPERSONA
														ORDER BY
															MAX(PF2.SIRCREB) DESC)									
												ELSE
													''''
												END);
				SET @P_ALICUOTA_MAS_ALTA = NULL;
				SET @P_PERSONA_MG = (SELECT CASE WHEN @v_persona = @P_NUM_PERSONA THEN (
												SELECT TOP 1
													CP.NUMEROPERSONA 
												FROM 
													CLI_ClientePersona CP WITH (NOLOCK)
												INNER JOIN 
													CLI_PERSONASFISICAS PF WITH (NOLOCK) 
													ON CP.NUMEROPERSONA = PF.NUMEROPERSONAFISICA 
													AND PF.TZ_LOCK = 0
												WHERE 
													CP.CODIGOCLIENTE = @P_CODIGO_CLIENTE
													AND CP.NUMEROPERSONA != @v_persona
													AND PF.SIRCREB <= @aliMaxAntSIRCREB
													AND CP.TZ_LOCK = 0
												GROUP BY 
													CP.NUMEROPERSONA
												ORDER BY 
													MAX(PF.SIRCREB) DESC)
											WHEN @v_persona != @P_NUM_PERSONA 
												AND 
												(
													SELECT COUNT(*)  
													FROM CLI_ClientePersona CPP WITH(NOLOCK)
													INNER JOIN CLI_PERSONASFISICAS PFF WITH(NOLOCK) 
														ON PFF.NUMEROPERSONAFISICA = CPP.NUMEROPERSONA
														AND PFF.TZ_LOCK = 0
													WHERE CPP.CODIGOCLIENTE = @P_CODIGO_CLIENTE 
													AND CPP.TZ_LOCK = 0 
													AND PFF.NUMEROPERSONAFISICA != @P_NUM_PERSONA 
													AND PFF.SIRCREB !=''''  -- Asegurar que la alícuota sea mayor que 0
												) > 0 THEN
												(SELECT TOP 1
														CP2.NUMEROPERSONA
														FROM CLI_ClientePersona CP2 WITH(NOLOCK)
														INNER JOIN CLI_PERSONASFISICAS PF2 WITH(NOLOCK) ON
															PF2.NUMEROPERSONAFISICA = CP2.NUMEROPERSONA
															AND PF2.TZ_LOCK=0
														WHERE CP2.CODIGOCLIENTE = @P_CODIGO_CLIENTE AND
														CP2.TZ_LOCK = 0 AND 
														PF2.NUMEROPERSONAFISICA != @P_NUM_PERSONA AND
														PF2.IIBB_CORRIENTES_ALI > 0
														GROUP BY 
															CP2.NUMEROPERSONA
														ORDER BY 
														MAX(PF2.SIRCREB) DESC)
												ELSE 
													@v_persona
												END); 
			END
		END
		ELSE --Sino hubo cambios, no actualizo el cliente
		BEGIN
			SET @P_ACTUALIZO_CLIENTE = ''N'';
			SET @P_CARGO_O_IMPUESTO_NUEVO = @P_CARGO_O_IMPUESTO;
			SET @P_ALICUOTA_MAS_ALTA = NULL;
			SET @P_PERSONA_MG = @v_persona;
		END
	END --SIRCREB


	-- IIBB CORRIENTES 
    IF @P_TIPO_CARGO_IMPOSITIVO = 9
    BEGIN 		

		-- Obtener la alícuota máxima actual de todas las personas del cliente
		SELECT TOP 1 
			@aliMaxAntIIBB = MAX(PF.IIBB_CORRIENTES_ALI), 
			@v_persona = CP.NUMEROPERSONA,
			@condMaxAntIIBB = PF.IIBB_CORRIENTES_RECAUD
		FROM 
			CLI_ClientePersona CP WITH (NOLOCK)
		INNER JOIN 
			CLI_PERSONASFISICAS PF WITH (NOLOCK) 
			ON CP.NUMEROPERSONA = PF.NUMEROPERSONAFISICA 
			AND PF.TZ_LOCK = 0
		WHERE 
			CP.CODIGOCLIENTE = @P_CODIGO_CLIENTE
			AND CP.TZ_LOCK = 0
		GROUP BY 
			CP.NUMEROPERSONA, PF.IIBB_CORRIENTES_RECAUD
		ORDER BY 
			MAX(PF.IIBB_CORRIENTES_ALI) DESC;
		

		-- Verificar si la alícuota ingresada es diferente a la alícuota máxima actual
			IF @P_ALICUOTA <> @aliMaxAntIIBB
			BEGIN
				IF @P_ALICUOTA > 0
				BEGIN
					IF @P_ALICUOTA >= @aliMaxAntIIBB 
					BEGIN 
						SET @P_ACTUALIZO_CLIENTE = ''S'';
						SET @P_CARGO_O_IMPUESTO_NUEVO = @P_CARGO_O_IMPUESTO 
						SET @P_ALICUOTA_MAS_ALTA = @P_ALICUOTA;
						SET @P_PERSONA_MG = @P_NUM_PERSONA 
					END
					ELSE --Si la alícuota es menor, pero es distinta a cero
					BEGIN 
						SET @P_ACTUALIZO_CLIENTE = CASE WHEN @v_persona = @P_NUM_PERSONA THEN ''S'' ELSE ''N'' END;
						SET @P_CARGO_O_IMPUESTO_NUEVO = ''AC''
						SET @P_ALICUOTA_MAS_ALTA = (SELECT CASE WHEN @v_persona = @P_NUM_PERSONA THEN ISNULL((
															SELECT TOP 1
																ISNULL(MAX(PF.IIBB_CORRIENTES_ALI),@P_ALICUOTA)
															FROM 
																CLI_ClientePersona CP WITH (NOLOCK)
															INNER JOIN 
																CLI_PERSONASFISICAS PF WITH (NOLOCK) 
																ON CP.NUMEROPERSONA = PF.NUMEROPERSONAFISICA 
																AND PF.TZ_LOCK = 0
															WHERE 
																CP.CODIGOCLIENTE = @P_CODIGO_CLIENTE
																AND CP.NUMEROPERSONA != @v_persona
																AND PF.IIBB_CORRIENTES_ALI <= @aliMaxAntIIBB
																AND PF.IIBB_CORRIENTES_ALI > @P_ALICUOTA
																AND CP.TZ_LOCK = 0
															GROUP BY 
																CP.NUMEROPERSONA
															ORDER BY 
																MAX(PF.IIBB_CORRIENTES_ALI) DESC),@P_ALICUOTA) 
															ELSE
																@aliMaxAntIIBB
															END);
						SET @P_PERSONA_MG = (SELECT CASE WHEN @v_persona = @P_NUM_PERSONA THEN ISNULL((
		                                                SELECT TOP 1
		                                                    CP.NUMEROPERSONA 
		                                                FROM 
		                                                    CLI_ClientePersona CP WITH (NOLOCK)
		                                                INNER JOIN 
		                                                    CLI_PERSONASFISICAS PF WITH (NOLOCK) 
		                                                    ON CP.NUMEROPERSONA = PF.NUMEROPERSONAFISICA 
		                                                    AND PF.TZ_LOCK = 0
		                                                WHERE 
		                                                    CP.CODIGOCLIENTE = @P_CODIGO_CLIENTE
		                                                    AND CP.NUMEROPERSONA != @v_persona
		                                                    AND PF.IIBB_CORRIENTES_ALI <= @aliMaxAntIIBB
															AND PF.IIBB_CORRIENTES_ALI > @P_ALICUOTA
		                                                    AND CP.TZ_LOCK = 0
		                                                GROUP BY 
		                                                    CP.NUMEROPERSONA
		                                                ORDER BY 
		                                                    MAX(PF.IIBB_CORRIENTES_ALI) DESC),@v_persona)
		                                            ELSE 
		                                                @v_persona
		                                            END); 
		            END
				END 
		        ELSE -- Si la alícuota es igual a cero, surgen 2 casos, o actualizo el cliente o no, si era la persona mg actualizo, sino no
		        --Caso 1 y 2
		        BEGIN
		            SET @P_ACTUALIZO_CLIENTE = CASE WHEN @v_persona = @P_NUM_PERSONA THEN ''S'' ELSE ''N'' END
					SET @P_CARGO_O_IMPUESTO_NUEVO = (SELECT CASE 
												    WHEN @v_persona = @P_NUM_PERSONA THEN 
												    (SELECT TOP 1
												            PF.IIBB_CORRIENTES_RECAUD
												        FROM 
												            CLI_ClientePersona CP WITH (NOLOCK)
												        INNER JOIN 
												            CLI_PERSONASFISICAS PF WITH (NOLOCK) 
												            ON CP.NUMEROPERSONA = PF.NUMEROPERSONAFISICA 
												            AND PF.TZ_LOCK = 0
												        WHERE 
												            CP.CODIGOCLIENTE = @P_CODIGO_CLIENTE
												            AND CP.NUMEROPERSONA != @P_NUM_PERSONA  -- Excluir la persona ingresada por parámetro
												            AND PF.IIBB_CORRIENTES_ALI <= @aliMaxAntIIBB  -- Verificar que la alícuota sea menor o igual a la alícuota máxima anterior
												            AND CP.TZ_LOCK = 0
												        ORDER BY 
												            PF.IIBB_CORRIENTES_ALI DESC) -- Ordenar por alícuota en orden descendente
												    ELSE (SELECT TOP 1
												            PF2.IIBB_CORRIENTES_RECAUD
					    									FROM CLI_ClientePersona CP2 WITH(NOLOCK)
					    									INNER JOIN CLI_PERSONASFISICAS PF2 WITH(NOLOCK) ON
					    										PF2.NUMEROPERSONAFISICA = CP2.NUMEROPERSONA
					    										AND PF2.TZ_LOCK=0
					    									WHERE CP2.CODIGOCLIENTE = @P_CODIGO_CLIENTE AND
					    										CP2.TZ_LOCK = 0 AND 
					    										PF2.NUMEROPERSONAFISICA = @v_persona 
					    									ORDER BY
					    										PF2.IIBB_CORRIENTES_ALI DESC)											    												    
												END);
					SET @P_ALICUOTA_MAS_ALTA = (SELECT CASE WHEN @v_persona = @P_NUM_PERSONA THEN (
														SELECT TOP 1
															MAX(PF.IIBB_CORRIENTES_ALI)
														FROM 
															CLI_ClientePersona CP WITH (NOLOCK)
														INNER JOIN 
															CLI_PERSONASFISICAS PF WITH (NOLOCK) 
															ON CP.NUMEROPERSONA = PF.NUMEROPERSONAFISICA 
															AND PF.TZ_LOCK = 0
														WHERE 
															CP.CODIGOCLIENTE = @P_CODIGO_CLIENTE
															AND CP.NUMEROPERSONA != @v_persona
															AND PF.IIBB_CORRIENTES_ALI <= @aliMaxAntIIBB
															AND CP.TZ_LOCK = 0
														GROUP BY 
															CP.NUMEROPERSONA
														ORDER BY 
															MAX(PF.IIBB_CORRIENTES_ALI) DESC)
													ELSE 
												    		(SELECT TOP 1
												            MAX(PF2.IIBB_CORRIENTES_ALI)
					    									FROM CLI_ClientePersona CP2 WITH(NOLOCK)
					    									INNER JOIN CLI_PERSONASFISICAS PF2 WITH(NOLOCK) ON
					    										PF2.NUMEROPERSONAFISICA = CP2.NUMEROPERSONA
					    										AND PF2.TZ_LOCK=0
					    									WHERE CP2.CODIGOCLIENTE = @P_CODIGO_CLIENTE AND
					    									CP2.TZ_LOCK = 0 AND 
					    									PF2.NUMEROPERSONAFISICA = @v_persona AND
					    									PF2.IIBB_CORRIENTES_ALI > 0
					    									GROUP BY 
																CP2.NUMEROPERSONA
					    									ORDER BY 
															MAX(PF2.IIBB_CORRIENTES_ALI) DESC) 
														END);
					SET @P_PERSONA_MG = (SELECT CASE WHEN @v_persona = @P_NUM_PERSONA THEN (
		                                            SELECT TOP 1
		                                                CP.NUMEROPERSONA 
		                                            FROM 
		                                                CLI_ClientePersona CP WITH (NOLOCK)
		                                            INNER JOIN 
		                                                CLI_PERSONASFISICAS PF WITH (NOLOCK) 
		                                                ON CP.NUMEROPERSONA = PF.NUMEROPERSONAFISICA 
		                                                AND PF.TZ_LOCK = 0
		                                            WHERE 
		                                                CP.CODIGOCLIENTE = @P_CODIGO_CLIENTE
		                                                AND CP.NUMEROPERSONA != @v_persona
		                                                AND PF.IIBB_CORRIENTES_ALI <= @aliMaxAntIIBB
		                                                AND CP.TZ_LOCK = 0
		                                            GROUP BY 
		                                                CP.NUMEROPERSONA
		                                            ORDER BY 
		                                                MAX(PF.IIBB_CORRIENTES_ALI) DESC)
		                                        ELSE @v_persona
		                                        END); 
				END
			END
            ELSE --Sino hubo cambios, no actualizo el cliente
            BEGIN
                SET @P_ACTUALIZO_CLIENTE = CASE WHEN @condMaxAntIIBB <> @P_CARGO_O_IMPUESTO THEN ''S'' ELSE ''N'' END;
                SET @P_CARGO_O_IMPUESTO_NUEVO = CASE WHEN @condMaxAntIIBB <> @P_CARGO_O_IMPUESTO THEN @P_CARGO_O_IMPUESTO ELSE @condMaxAntIIBB END;
                SET @P_ALICUOTA_MAS_ALTA = @P_ALICUOTA;
                SET @P_PERSONA_MG = @v_persona;
            END  
    END --IIBB CORRIENTES    	
-- IIBB CABA PERCEPCION              
	IF @P_TIPO_CARGO_IMPOSITIVO = 8 
	BEGIN
		-- Obtener la alícuota máxima actual de todas las personas del cliente
		SELECT TOP 1 
			@aliMaxAntIIBB = MAX(PF.IIBB_CABA_PERCEPCION_ALI), 
			@v_persona = CP.NUMEROPERSONA,
			@condMaxAntIIBB = PF.IIBB_CABA_PERCEPCION_COND
		FROM 
			CLI_ClientePersona CP WITH (NOLOCK)
		INNER JOIN 
			CLI_PERSONASFISICAS PF WITH (NOLOCK) 
			ON CP.NUMEROPERSONA = PF.NUMEROPERSONAFISICA 
			AND PF.TZ_LOCK = 0
		WHERE 
			CP.CODIGOCLIENTE = @P_CODIGO_CLIENTE
			AND CP.TZ_LOCK = 0
		GROUP BY 
			CP.NUMEROPERSONA, PF.IIBB_CABA_PERCEPCION_COND
		ORDER BY 
			MAX(PF.IIBB_CABA_PERCEPCION_ALI) DESC;
			
		-- Verificar si la alícuota ingresada es diferente a la alícuota máxima actual

			IF @P_ALICUOTA <> @aliMaxAntIIBB
			BEGIN
				IF @P_ALICUOTA > 0
				BEGIN
					IF @P_ALICUOTA >= @aliMaxAntIIBB 
					BEGIN 
						SET @P_ACTUALIZO_CLIENTE = ''S'';
						SET @P_CARGO_O_IMPUESTO_NUEVO = @P_CARGO_O_IMPUESTO 
						SET @P_ALICUOTA_MAS_ALTA = @P_ALICUOTA;
						SET @P_PERSONA_MG = @P_NUM_PERSONA 
					END
					ELSE --Si la alícuota es menor, pero es distinta a cero
					BEGIN 
						SET @P_ACTUALIZO_CLIENTE = CASE WHEN @v_persona = @P_NUM_PERSONA THEN ''S'' ELSE ''N'' END
						SET @P_CARGO_O_IMPUESTO_NUEVO = ''AC''
						SET @P_ALICUOTA_MAS_ALTA = (SELECT CASE WHEN @v_persona = @P_NUM_PERSONA THEN (
															SELECT TOP 1
																MAX(PF.IIBB_CABA_PERCEPCION_ALI)
															FROM 
																CLI_ClientePersona CP WITH (NOLOCK)
															INNER JOIN 
																CLI_PERSONASFISICAS PF WITH (NOLOCK) 
																ON CP.NUMEROPERSONA = PF.NUMEROPERSONAFISICA 
																AND PF.TZ_LOCK = 0
															WHERE 
																CP.CODIGOCLIENTE = @P_CODIGO_CLIENTE
																AND CP.NUMEROPERSONA != @v_persona
																AND PF.IIBB_CABA_PERCEPCION_ALI <= @aliMaxAntIIBB
																AND CP.TZ_LOCK = 0
															GROUP BY 
																CP.NUMEROPERSONA
															ORDER BY 
																MAX(PF.IIBB_CABA_PERCEPCION_ALI) DESC) 
															ELSE
																@aliMaxAntIIBB
															END);
						SET @P_PERSONA_MG = (SELECT CASE WHEN @v_persona = @P_NUM_PERSONA THEN (
		                                                SELECT TOP 1
		                                                    CP.NUMEROPERSONA 
		                                                FROM 
		                                                    CLI_ClientePersona CP WITH (NOLOCK)
		                                                INNER JOIN 
		                                                    CLI_PERSONASFISICAS PF WITH (NOLOCK) 
		                                                    ON CP.NUMEROPERSONA = PF.NUMEROPERSONAFISICA 
		                                                    AND PF.TZ_LOCK = 0
		                                                WHERE 
		                                                    CP.CODIGOCLIENTE = @P_CODIGO_CLIENTE
		                                                    AND CP.NUMEROPERSONA != @v_persona
		                                                    AND PF.IIBB_CABA_PERCEPCION_ALI <= @aliMaxAntIIBB
		                                                    AND CP.TZ_LOCK = 0
		                                                GROUP BY 
		                                                    CP.NUMEROPERSONA
		                                                ORDER BY 
		                                                    MAX(PF.IIBB_CABA_PERCEPCION_ALI) DESC)
		                                            ELSE 
		                                                @v_persona
		                                            END); 
		            END
				END 
		        ELSE -- Si la alícuota es igual a cero, surgen 2 casos, o actualizo el cliente o no, si era la persona mg actualizo, sino no
		        --Caso 1 y 2
		        BEGIN
		            SET @P_ACTUALIZO_CLIENTE = CASE WHEN @v_persona = @P_NUM_PERSONA THEN ''S'' ELSE ''N'' END;
					SET @P_CARGO_O_IMPUESTO_NUEVO = (SELECT CASE WHEN @v_persona = @P_NUM_PERSONA THEN (
														SELECT TOP 1
															PF.IIBB_CABA_PERCEPCION_COND
														FROM 
															CLI_ClientePersona CP WITH (NOLOCK)
														INNER JOIN 
															CLI_PERSONASFISICAS PF WITH (NOLOCK) 
															ON CP.NUMEROPERSONA = PF.NUMEROPERSONAFISICA 
															AND PF.TZ_LOCK = 0
														WHERE 
															CP.CODIGOCLIENTE = @P_CODIGO_CLIENTE
															AND CP.NUMEROPERSONA != @v_persona
															AND PF.IIBB_CABA_PERCEPCION_ALI <= @aliMaxAntIIBB
															AND CP.TZ_LOCK = 0
														GROUP BY 
															PF.IIBB_CABA_PERCEPCION_COND
														ORDER BY 
															MAX(PF.IIBB_CABA_PERCEPCION_ALI) DESC) 
														ELSE
															''EX''
														END);
					SET @P_ALICUOTA_MAS_ALTA = (SELECT CASE WHEN @v_persona = @P_NUM_PERSONA THEN (
														SELECT TOP 1
															MAX(PF.IIBB_CABA_PERCEPCION_ALI)
														FROM 
															CLI_ClientePersona CP WITH (NOLOCK)
														INNER JOIN 
															CLI_PERSONASFISICAS PF WITH (NOLOCK) 
															ON CP.NUMEROPERSONA = PF.NUMEROPERSONAFISICA 
															AND PF.TZ_LOCK = 0
														WHERE 
															CP.CODIGOCLIENTE = @P_CODIGO_CLIENTE
															AND CP.NUMEROPERSONA != @v_persona
															AND PF.IIBB_CABA_PERCEPCION_ALI <= @aliMaxAntIIBB
															AND CP.TZ_LOCK = 0
														GROUP BY 
															CP.NUMEROPERSONA
														ORDER BY 
															MAX(PF.IIBB_CABA_PERCEPCION_ALI) DESC) 
														ELSE
															0
														END);
					SET @P_PERSONA_MG = (SELECT CASE WHEN @v_persona = @P_NUM_PERSONA THEN (
		                                            SELECT TOP 1
		                                                CP.NUMEROPERSONA 
		                                            FROM 
		                                                CLI_ClientePersona CP WITH (NOLOCK)
		                                            INNER JOIN 
		                                                CLI_PERSONASFISICAS PF WITH (NOLOCK) 
		                                                ON CP.NUMEROPERSONA = PF.NUMEROPERSONAFISICA 
		                                                AND PF.TZ_LOCK = 0
		                                            WHERE 
		                                                CP.CODIGOCLIENTE = @P_CODIGO_CLIENTE
		                                                AND CP.NUMEROPERSONA != @v_persona
		                                                AND PF.IIBB_CABA_PERCEPCION_ALI <= @aliMaxAntIIBB
		                                                AND CP.TZ_LOCK = 0
		                                            GROUP BY 
		                                                CP.NUMEROPERSONA
		                                            ORDER BY 
		                                                MAX(PF.IIBB_CABA_PERCEPCION_ALI) DESC)
		                                        ELSE 
		                                            @v_persona
		                                        END); 
				END
			END
            ELSE --Sino hubo cambios, no actualizo el cliente
            BEGIN
                SET @P_ACTUALIZO_CLIENTE = CASE WHEN @condMaxAntIIBB <> @P_CARGO_O_IMPUESTO THEN ''S'' ELSE ''N'' END;
                SET @P_CARGO_O_IMPUESTO_NUEVO = CASE WHEN @condMaxAntIIBB <> @P_CARGO_O_IMPUESTO THEN @P_CARGO_O_IMPUESTO ELSE @condMaxAntIIBB END;
                SET @P_ALICUOTA_MAS_ALTA = @P_ALICUOTA;
                SET @P_PERSONA_MG = @v_persona;
            END  
    END --IIBB CABA PERCEPCION

	--IIBB CABA RETENCION	
	IF @P_TIPO_CARGO_IMPOSITIVO = 12 
	BEGIN
		-- Obtener la alícuota máxima actual de todas las personas del cliente
		SELECT TOP 1 
			@aliMaxAntIIBB = MAX(PF.IIBB_CABA_RETENCION_ALI), 
			@v_persona = CP.NUMEROPERSONA,
			@condMaxAntIIBB = PF.IIBB_CABA_RETENCION_COND
		FROM 
			CLI_ClientePersona CP WITH (NOLOCK)
		INNER JOIN 
			CLI_PERSONASFISICAS PF WITH (NOLOCK) 
			ON CP.NUMEROPERSONA = PF.NUMEROPERSONAFISICA 
			AND PF.TZ_LOCK = 0
		WHERE 
			CP.CODIGOCLIENTE = @P_CODIGO_CLIENTE
			AND CP.TZ_LOCK = 0
		GROUP BY 
			CP.NUMEROPERSONA, PF.IIBB_CABA_RETENCION_COND
		ORDER BY 
			MAX(PF.IIBB_CABA_RETENCION_ALI) DESC;

		-- Verificar si la alícuota ingresada es diferente a la alícuota máxima actual

			IF @P_ALICUOTA <> @aliMaxAntIIBB
			BEGIN
				IF @P_ALICUOTA > 0
				BEGIN
					IF @P_ALICUOTA >= @aliMaxAntIIBB 
					BEGIN 
						SET @P_ACTUALIZO_CLIENTE = ''S'';
						SET @P_CARGO_O_IMPUESTO_NUEVO = @P_CARGO_O_IMPUESTO 
						SET @P_ALICUOTA_MAS_ALTA = @P_ALICUOTA;
						SET @P_PERSONA_MG = @P_NUM_PERSONA 
					END
					ELSE --Si la alícuota es menor, pero es distinta a cero
					BEGIN 
						SET @P_ACTUALIZO_CLIENTE = CASE WHEN @v_persona = @P_NUM_PERSONA THEN ''S'' ELSE ''N'' END;
						SET @P_CARGO_O_IMPUESTO_NUEVO = ''AC''
						SET @P_ALICUOTA_MAS_ALTA = (SELECT CASE WHEN @v_persona = @P_NUM_PERSONA THEN (
															SELECT TOP 1
																MAX(PF.IIBB_CABA_RETENCION_ALI)
															FROM 
																CLI_ClientePersona CP WITH (NOLOCK)
															INNER JOIN 
																CLI_PERSONASFISICAS PF WITH (NOLOCK) 
																ON CP.NUMEROPERSONA = PF.NUMEROPERSONAFISICA 
																AND PF.TZ_LOCK = 0
															WHERE 
																CP.CODIGOCLIENTE = @P_CODIGO_CLIENTE
																AND CP.NUMEROPERSONA != @v_persona
																AND PF.IIBB_CABA_RETENCION_ALI <= @aliMaxAntIIBB
																AND CP.TZ_LOCK = 0
															GROUP BY 
																CP.NUMEROPERSONA
															ORDER BY 
																MAX(PF.IIBB_CABA_RETENCION_ALI) DESC) 
															ELSE
																@aliMaxAntIIBB
															END);
						SET @P_PERSONA_MG = (SELECT CASE WHEN @v_persona = @P_NUM_PERSONA THEN (
		                                                SELECT TOP 1
		                                                    CP.NUMEROPERSONA 
		                                                FROM 
		                                                    CLI_ClientePersona CP WITH (NOLOCK)
		                                                INNER JOIN 
		                                                    CLI_PERSONASFISICAS PF WITH (NOLOCK) 
		                                                    ON CP.NUMEROPERSONA = PF.NUMEROPERSONAFISICA 
		                                                    AND PF.TZ_LOCK = 0
		                                                WHERE 
		                                                    CP.CODIGOCLIENTE = @P_CODIGO_CLIENTE
		                                                    AND CP.NUMEROPERSONA != @v_persona
		                                                    AND PF.IIBB_CABA_RETENCION_ALI <= @aliMaxAntIIBB
		                                                    AND CP.TZ_LOCK = 0
		                                                GROUP BY 
		                                                    CP.NUMEROPERSONA
		                                                ORDER BY 
		                                                    MAX(PF.IIBB_CABA_RETENCION_ALI) DESC)
		                                            ELSE 
		                                                @v_persona
		                                            END); 
		            END
				END 
		        ELSE -- Si la alícuota es igual a cero, surgen 2 casos, o actualizo el cliente o no, si era la persona mg actualizo, sino no
		        --Caso 1 y 2
		        BEGIN
		            SET @P_ACTUALIZO_CLIENTE = CASE WHEN @v_persona = @P_NUM_PERSONA THEN ''S'' ELSE ''N'' END;
					SET @P_CARGO_O_IMPUESTO_NUEVO = (SELECT CASE WHEN @v_persona = @P_NUM_PERSONA THEN (
														SELECT TOP 1
															PF.IIBB_CABA_RETENCION_COND
														FROM 
															CLI_ClientePersona CP WITH (NOLOCK)
														INNER JOIN 
															CLI_PERSONASFISICAS PF WITH (NOLOCK) 
															ON CP.NUMEROPERSONA = PF.NUMEROPERSONAFISICA 
															AND PF.TZ_LOCK = 0
														WHERE 
															CP.CODIGOCLIENTE = @P_CODIGO_CLIENTE
															AND CP.NUMEROPERSONA != @v_persona
															AND PF.IIBB_CABA_RETENCION_ALI <= @aliMaxAntIIBB
															AND CP.TZ_LOCK = 0
														GROUP BY 
															PF.IIBB_CABA_RETENCION_COND
														ORDER BY 
															MAX(PF.IIBB_CABA_RETENCION_ALI) DESC) 
														ELSE
															''EX''
														END);
					SET @P_ALICUOTA_MAS_ALTA = (SELECT CASE WHEN @v_persona = @P_NUM_PERSONA THEN (
														SELECT TOP 1
															MAX(PF.IIBB_CABA_RETENCION_ALI)
														FROM 
															CLI_ClientePersona CP WITH (NOLOCK)
														INNER JOIN 
															CLI_PERSONASFISICAS PF WITH (NOLOCK) 
															ON CP.NUMEROPERSONA = PF.NUMEROPERSONAFISICA 
															AND PF.TZ_LOCK = 0
														WHERE 
															CP.CODIGOCLIENTE = @P_CODIGO_CLIENTE
															AND CP.NUMEROPERSONA != @v_persona
															AND PF.IIBB_CABA_RETENCION_ALI <= @aliMaxAntIIBB
															AND CP.TZ_LOCK = 0
														GROUP BY 
															CP.NUMEROPERSONA
														ORDER BY 
															MAX(PF.IIBB_CABA_RETENCION_ALI) DESC) 
														ELSE
															0
														END);
					SET @P_PERSONA_MG = (SELECT CASE WHEN @v_persona = @P_NUM_PERSONA THEN (
		                                            SELECT TOP 1
		                                                CP.NUMEROPERSONA 
		                                            FROM 
		                                                CLI_ClientePersona CP WITH (NOLOCK)
		                                            INNER JOIN 
		                                                CLI_PERSONASFISICAS PF WITH (NOLOCK) 
		                                                ON CP.NUMEROPERSONA = PF.NUMEROPERSONAFISICA 
		                                                AND PF.TZ_LOCK = 0
		                                            WHERE 
		                                                CP.CODIGOCLIENTE = @P_CODIGO_CLIENTE
		                                                AND CP.NUMEROPERSONA != @v_persona
		                                                AND PF.IIBB_CABA_RETENCION_ALI <= @aliMaxAntIIBB
		                                                AND CP.TZ_LOCK = 0
		                                            GROUP BY 
		                                                CP.NUMEROPERSONA
		                                            ORDER BY 
		                                                MAX(PF.IIBB_CABA_RETENCION_ALI) DESC)
		                                        ELSE 
		                                            @v_persona
		                                        END); 
				END
			END
            ELSE --Sino hubo cambios, no actualizo el cliente
            BEGIN
                SET @P_ACTUALIZO_CLIENTE = CASE WHEN @condMaxAntIIBB <> @P_CARGO_O_IMPUESTO THEN ''S'' ELSE ''N'' END;
                SET @P_CARGO_O_IMPUESTO_NUEVO = CASE WHEN @condMaxAntIIBB <> @P_CARGO_O_IMPUESTO THEN @P_CARGO_O_IMPUESTO ELSE @condMaxAntIIBB END;
                SET @P_ALICUOTA_MAS_ALTA = @P_ALICUOTA;
                SET @P_PERSONA_MG = @v_persona;
            END  
    END --IIBB CABA RETENCION
    
	BEGIN TRANSACTION

    BEGIN TRY
        SET @P_RET_PROCESO = 1;
        SET @P_MSG_PROCESO = ''Se evaluó la condición del impuesto'';
    
        EXECUTE dbo.pkg_constantes$VarcharConstantes ''C_LOG_TIPO_INFORMACION'', @v_constante OUTPUT;
    
        EXECUTE dbo.PKG_LOG_PROCESO$PROC_INS_LOG_PROCESO 
            @P_ID_PROCESO = @P_ID_PROCESO, 
            @P_FCH_PROCESO = @P_DT_PROCESO, 
            @P_NOM_PACKAGE = ''PA_ACTUALIZAR_CONDICINES_IMPOSITIVAS'', 
            @P_COD_ERROR = @P_RET_PROCESO, 
            @P_MSG_ERROR = @P_MSG_PROCESO, 
            @P_TIPO_ERROR = @v_constante;
        COMMIT TRANSACTION;     
    END TRY
    
    BEGIN CATCH
        ROLLBACK TRANSACTION;

        -- Valores de Retorno
        SET @P_RET_PROCESO = ERROR_NUMBER();
        SET @P_MSG_PROCESO = ERROR_MESSAGE();
        
        EXECUTE dbo.pkg_constantes$VarcharConstantes ''C_LOG_TIPO_ERROR'', @v_constante OUTPUT;

        EXECUTE dbo.PKG_LOG_PROCESO$PROC_INS_LOG_PROCESO 
            @P_ID_PROCESO = @P_ID_PROCESO, 
            @P_FCH_PROCESO = @P_DT_PROCESO, 
            @P_NOM_PACKAGE = ''PA_ACTUALIZAR_CONDICIONES_IMPOSITIVAS'', 
            @P_COD_ERROR = @P_RET_PROCESO, 
            @P_MSG_ERROR = @P_MSG_PROCESO, 
            @P_TIPO_ERROR = @v_constante;
    END CATCH
END
')

