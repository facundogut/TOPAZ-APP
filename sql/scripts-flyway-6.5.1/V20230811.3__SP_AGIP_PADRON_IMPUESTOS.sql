EXECUTE('
CREATE OR ALTER PROCEDURE [dbo].[SP_AGIP_PADRON_IMPUESTOS] 
 	@perParam VARCHAR(6),
 	@reproceso VARCHAR(1) --mostrar error en caso de que la fecha en el padron no sea la misma que la fecha proceso
AS



BEGIN

DECLARE @fecha datetime = CONVERT(DATETIME, (SELECT FECHAPROCESO FROM PARAMETROS), 103);

DECLARE @periodoActual DATETIME = CAST(CONCAT(SUBSTRING(@perParam,3,4),SUBSTRING(@perParam,1,2),''01'') AS DATETIME);
DECLARE @periodoAnterior DATETIME = dateadd(month,-1, @periodoActual);
DECLARE @anio INT 
DECLARE @mes INT 
DECLARE @anio_ant INT 
DECLARE @mes_ant INT 

DECLARE @fechaInicio DATETIME; 
DECLARE @fechaFin DATETIME; 

SET @mes = MONTH(@periodoActual); 
SET @anio = YEAR(@periodoActual);

SET @mes_ant = MONTH(@periodoAnterior); 
SET @anio_ant = YEAR(@periodoAnterior);

--var generales
DECLARE @id NUMERIC(20);
DECLARE @reg VARCHAR(70);
DECLARE @cantImp INT; --caso base, si es 0 solo hay que grabar porque es la primer ejecucion y no se compara
DECLARE @codCli NUMERIC(20);
DECLARE @cuit VARCHAR(11),@cuitAux VARCHAR(11),@razonSocial VARCHAR(44), @periodo VARCHAR(6), @alicuota VARCHAR(6);
DECLARE @actualizaCliPer VARCHAR(1);
DECLARE @actualizaCliRet VARCHAR(1);

--var auxiliares
DECLARE @alicuota_perc_Aux NUMERIC(4,4), @alicuotaPercMax NUMERIC(11,7), @alicuotaPercVIEJA NUMERIC(4,4), @recaud_perc_Aux VARCHAR (2),
 @vinoEnPadron INT;
DECLARE @personaMasGravosaPerc NUMERIC(12), @condicionPercMax VARCHAR(2);
DECLARE @numeroPersonaPerc NUMERIC(20), @numeroClientePerc NUMERIC(20);

DECLARE @alicuota_rete_Aux NUMERIC(4,4), @alicuotaRetenMax NUMERIC(11,7), @alicuotaRetenVIEJA NUMERIC(4,4),
 @recaud_rete_Aux VARCHAR (2);
DECLARE @personaMasGravosaReten NUMERIC(12), @condicionRetenMax VARCHAR(2);
DECLARE @numeroPersona NUMERIC(20), @numeroCliente NUMERIC(20);

DECLARE @fecha_public VARCHAR(8),@fecha_vig_desde VARCHAR(8),
@fecha_vig_hasta VARCHAR(8),@Tipo_Contr_Insc VARCHAR(1),@Marca_alta_sujeto VARCHAR(1),
@Marca_alicuota VARCHAR(1),@Alicuota_Percepcion NUMERIC(6,2),@Alicuota_Retencion NUMERIC(6,2),@Nro_Grupo_Percepcion VARCHAR(2),
@Nro_Grupo_Retencion VARCHAR(2);
DECLARE @existe NUMERIC(5);


/*Limpiamos la tabla ITF_AGIP_PADRON cuando es reproceso*/
IF @reproceso = ''S''
BEGIN
  SELECT @existe = COUNT(1)
  FROM ITF_AGIP_PADRON
  WHERE SUBSTRING(Fecha_Publicacion,5,4) = @anio
    AND SUBSTRING(Fecha_Publicacion,3,2) = @mes
  
  IF @existe > 0
  BEGIN 
    DELETE FROM ITF_AGIP_PADRON
  	WHERE SUBSTRING(Fecha_Publicacion,5,4) = @anio
    AND SUBSTRING(Fecha_Publicacion,3,2) = @mes
  END;
  
END

	--comparo para ver que registros no vinieron en el padron con respecto al periodo anterior
	DECLARE cursorOk CURSOR FOR 
	SELECT a.cuit 
	FROM ITF_AGIP_PADRON a
	WHERE SUBSTRING(a.Fecha_Publicacion,5,4) = @anio_ant
	    AND SUBSTRING(a.Fecha_Publicacion,3,2) = @mes_ant
	OPEN cursorOk
  
    FETCH NEXT FROM cursorOk INTO @cuit
    WHILE @@FETCH_STATUS = 0 
    BEGIN
    
  		SET @vinoEnPadron=0;
  		SET @numeroPersona = 0;
    	SET @numeroCliente = 0 ;
    	
    	SELECT @vinoEnPadron=COUNT(1),
    	  @fechaInicio=CONVERT(datetime, SUBSTRING(fecha_vig_desde, 5, 4) + SUBSTRING(fecha_vig_desde, 3, 2) + SUBSTRING(fecha_vig_desde, 1, 2), 112),
    	  @fechaFin=CONVERT(datetime, SUBSTRING(fecha_vig_hasta, 5, 4) + SUBSTRING(fecha_vig_hasta, 3, 2) + SUBSTRING(fecha_vig_hasta, 1, 2), 112),
    	  @alicuota_perc_Aux = Replace(Alicuota_Percepcion,'','',''.''),
    	  @alicuota_rete_Aux = Replace(Alicuota_Retencion,'','',''.'')
    	 FROM ITF_AGIP_PADRON_IMPUESTOS_AUX 
    	 WHERE cuit = @cuit
    	   AND msj_error IS null
    	 GROUP BY fecha_vig_desde,fecha_vig_hasta, Alicuota_Percepcion, Alicuota_Retencion;

    	IF @vinoEnPadron > 0
			BEGIN

    		  SET @recaud_perc_Aux = (SELECT CASE WHEN @alicuota_perc_Aux = 0 THEN ''EX'' ELSE ''AC'' END);    
    		  SET @recaud_rete_Aux = (SELECT CASE WHEN @alicuota_rete_Aux = 0  THEN ''EX'' ELSE ''AC'' END);  	
     		END
     	ELSE 
     		BEGIN

    	      SET @alicuota_perc_Aux = 0      
    		  SET @alicuota_rete_Aux = 0 
    		  SET @recaud_perc_Aux =''NA''   
    		  SET @recaud_rete_Aux = ''NA''	
   			END

    	--persona fisica  
	    IF(@cuit < ''30000000000'')	    
			UPDATE CLI_PersonasFisicas 
			SET IIBB_CABA_PERCEPCION_ALI = @alicuota_perc_Aux , 
				IIBB_CABA_PERCEPCION_COND = @recaud_perc_Aux,
				IIBB_CABA_RETENCION_ALI=@alicuota_rete_Aux,
				IIBB_CABA_RETENCION_COND=@recaud_rete_Aux
			FROM CLI_PersonasFisicas pf 
			  JOIN CLI_DocumentosPFPJ cliDoc
			ON cliDoc.NUMEROPERSONAFJ = pf.NUMEROPERSONAFISICA  
			WHERE cliDoc.NUMERODOCUMENTO  = @cuit; 	   
  		
   	 	--persona juridica
		IF(@cuit >= ''30000000000'')
			UPDATE CLI_PERSONASJURIDICAS 
			SET IIBB_CABA_PERCEPCION_ALI = @alicuota_perc_Aux , 
			    IIBB_CABA_PERCEPCION_COND = @recaud_perc_Aux,
				IIBB_CABA_RETENCION_ALI=@alicuota_rete_Aux,
				IIBB_CABA_RETENCION_COND=@recaud_rete_Aux
			FROM CLI_PERSONASJURIDICAS pj 
			JOIN CLI_DocumentosPFPJ cliDoc 
			  ON cliDoc.NUMEROPERSONAFJ = pj.NUMEROPERSONAJURIDICA 
			WHERE cliDoc.NUMERODOCUMENTO  = @cuit;

		--si no vino en el padron hay que analizar nuevamente la persona mas gravosa
		IF( @vinoEnPadron = 0 )
		BEGIN
			DECLARE cursorCliAux CURSOR FOR 
			SELECT DISTINCT 
				cp.CODIGOCLIENTE FROM CLI_DocumentosPFPJ pfj 
					JOIN CLI_ClientePersona cp ON pfj.NUMEROPERSONAFJ = cp.NUMEROPERSONA 
						WHERE pfj.NUMERODOCUMENTO =  @cuit
						AND cp.TZ_LOCK = 0
						AND pfj.TZ_LOCK = 0
			OPEN cursorCliAux 
			FETCH NEXT FROM cursorCliAux INTO @codCli
			WHILE @@FETCH_STATUS = 0 
			BEGIN
				
				SELECT TOP 1 @personaMasGravosaPerc =persona,
					@alicuotaPercMax=alicuotaPercMax,
					@condicionPercMax=PercCondicion
				FROM --necesito quedarme con el numero de persona para guardar el log y tambien con la max alicuota
				(
				SELECT b.NUMEROPERSONAFISICA AS persona, b.IIBB_CABA_PERCEPCION_ALI  AS alicuotaPercMax , b.IIBB_CABA_PERCEPCION_COND  AS PercCondicion FROM 
				CLI_ClientePersona a 
				JOIN CLI_PERSONASFISICAS b ON a.NUMEROPERSONA = b.NUMEROPERSONAFISICA 
					WHERE a.TZ_LOCK = 0 AND a.TZ_LOCK = 0 AND  a.CODIGOCLIENTE = @codCli
				UNION ALL 
				SELECT 	j.NUMEROPERSONAJURIDICA AS persona , j.IIBB_CABA_PERCEPCION_ALI  AS alicuotaPercMax, j.IIBB_CABA_PERCEPCION_COND  AS PercCondicion FROM 
				CLI_ClientePersona a 
				JOIN CLI_PERSONASJURIDICAS j ON a.NUMEROPERSONA = j.NUMEROPERSONAJURIDICA 
					WHERE a.TZ_LOCK = 0 AND j.TZ_LOCK = 0  AND  a.CODIGOCLIENTE = @codCli
				) AS xd
				ORDER BY alicuotaPercMax DESC
				
				
				SELECT TOP 1 @personaMasGravosaReten=persona,@alicuotaRetenMax=alicuotaRetenMax, @condicionRetenMax=RetenCondicion  FROM --necesito quedarme con el numero de persona para guardar el log y tambien con la max alicuota
				(
				SELECT b.NUMEROPERSONAFISICA AS persona, b.IIBB_CABA_RETENCION_ALI  AS alicuotaRetenMax , b.IIBB_CABA_RETENCION_COND   AS RetenCondicion FROM 
				CLI_ClientePersona a 
				JOIN CLI_PERSONASFISICAS b ON a.NUMEROPERSONA = b.NUMEROPERSONAFISICA 
					WHERE a.TZ_LOCK = 0 AND a.TZ_LOCK = 0 AND  a.CODIGOCLIENTE = @codCli
				UNION ALL 
				SELECT 	j.NUMEROPERSONAJURIDICA AS persona , j.IIBB_CABA_RETENCION_ALI  AS alicuotaRetenMax, j.IIBB_CABA_RETENCION_COND   AS RetenCondicion FROM 
				CLI_ClientePersona a 
				JOIN CLI_PERSONASJURIDICAS j ON a.NUMEROPERSONA = j.NUMEROPERSONAJURIDICA 
					WHERE a.TZ_LOCK = 0 AND j.TZ_LOCK = 0  AND  a.CODIGOCLIENTE = @codCli 
				) AS xd
				ORDER BY alicuotaRetenMax DESC	
				 
			   	 SET @actualizaCliPer = (SELECT CASE WHEN IIBB_CABA_PERCEPCION_ALI  = @alicuotaPercMax THEN ''N'' ELSE ''S'' END FROM CLI_CLIENTES WHERE CODIGOCLIENTE = @codCli);
			   	 SET @actualizaCliRet = (SELECT CASE WHEN IIBB_CABA_RETENCION_ALI   = @alicuotaRetenMax THEN ''N'' ELSE ''S'' END FROM CLI_CLIENTES WHERE CODIGOCLIENTE = @codCli);

			   	 IF(@actualizaCliPer = ''S'') --guardo en la bitacora solo si hubieron cambios
			   	 BEGIN				   	 
			   	 	INSERT INTO ITF_LOG_PADRON_IMPUESTOS (COD_IMPUESTO, PERIODO_PADRON, COD_CLIENTE, ID_PERSONA, FECHA_PROCESO, FECHA_EJECUCION, CONDICION, ALICUOTA)
				 		VALUES (''08'', @perParam, @codCli, @personaMasGravosaPerc, CONVERT(VARCHAR(8), (SELECT FECHAPROCESO FROM PARAMETROS (NOLOCK)), 112), CONVERT(VARCHAR(8), (SELECT FECHAPROCESO FROM PARAMETROS (NOLOCK)), 112) , @condicionPercMax, @alicuotaPercMax);
			   	 	UPDATE CLI_CLIENTES SET IIBB_CABA_PERCEPCION_ALI = @alicuotaPercMax, IIBB_CABA_PERCEPCION_COND  = @condicionPercMax  WHERE CODIGOCLIENTE = @codCli;
				END
			   	 IF(@actualizaCliRet = ''S'') --guardo en la bitacora solo si hubieron cambios
			   	 BEGIN				   	 
			   	 	INSERT INTO ITF_LOG_PADRON_IMPUESTOS (COD_IMPUESTO, PERIODO_PADRON, COD_CLIENTE, ID_PERSONA, FECHA_PROCESO, FECHA_EJECUCION, CONDICION, ALICUOTA)
				 		VALUES (''12'', @perParam, @codCli, @personaMasGravosaReten, CONVERT(VARCHAR(8), (SELECT FECHAPROCESO FROM PARAMETROS (NOLOCK)), 112), CONVERT(VARCHAR(8), (SELECT FECHAPROCESO FROM PARAMETROS (NOLOCK)), 112) , @condicionPercMax, @alicuotaRetenMax);
			   	 	UPDATE CLI_CLIENTES SET IIBB_CABA_RETENCION_ALI  = @alicuotaRetenMax, IIBB_CABA_RETENCION_COND  = @condicionRetenMax  WHERE CODIGOCLIENTE = @codCli;
				END
				
			FETCH NEXT FROM cursorCliAux INTO @codCli
			END --Fin del WHILE    	
			CLOSE cursorCliAux --Cerrar el CURSOR cli
			DEALLOCATE cursorCliAux
		END
    
   	FETCH NEXT FROM cursorOk INTO @cuit
   	END --Fin del WHILE

    	
CLOSE cursorOk
DEALLOCATE cursorOk


--recorro padron nuevo
DECLARE cursorAux CURSOR FOR
SELECT b.ID, b.fecha_public, b.fecha_vig_desde, b.fecha_vig_hasta, b.cuit, b.Tipo_Contr_Insc,
	b.Marca_alta_sujeto, b.Marca_alicuota, REPLACE(b.Alicuota_Percepcion,'','',''.''), Replace(b.Alicuota_Retencion,'','',''.''),
	b.Nro_Grupo_Percepcion, b.Nro_Grupo_Retencion, b.Razon_Social
FROM ITF_AGIP_PADRON_IMPUESTOS_AUX b
WHERE SUBSTRING(b.Fecha_Public,5,4) = @anio
    AND SUBSTRING(b.Fecha_Public,3,2) = @mes
    AND msj_error IS null
    
OPEN cursorAux
    FETCH NEXT FROM cursorAux INTO @id, @fecha_public, @fecha_vig_desde, @fecha_vig_hasta, @cuitAux, @Tipo_Contr_Insc,
      @Marca_alta_sujeto, @Marca_alicuota, @Alicuota_Percepcion, @Alicuota_Retencion, 
      @Nro_Grupo_Percepcion, @Nro_Grupo_Retencion, @razonSocial
 
    WHILE @@FETCH_STATUS = 0 
    BEGIN;
		
        SET @recaud_rete_Aux = (SELECT CASE WHEN @Alicuota_Retencion = 0.0 THEN ''EX'' ELSE ''AC'' END);
        SET @recaud_perc_Aux = (SELECT CASE WHEN @Alicuota_Percepcion = 0.0 THEN ''EX'' ELSE ''AC'' END);
		
   		INSERT INTO ITF_AGIP_PADRON VALUES (@fecha_vig_desde,@fecha_public, @fecha_vig_hasta,@cuitAux,@razonSocial,@Tipo_Contr_Insc,@Marca_alta_sujeto,@Alicuota_Percepcion,@Alicuota_Retencion,@Nro_Grupo_Percepcion,@Marca_alicuota,@Nro_Grupo_Retencion); 

		SET @vinoEnPadron  = 0;
		SET @alicuotaPercVIEJA = 0;
		SET @alicuotaRetenVIEJA = 0;
		
		SELECT @vinoEnPadron = COUNT(1), 
		  @alicuotaRetenVIEJA = Alicuota_Retencion ,
		  @alicuotaPercVIEJA= Alicuota_Percepcion 
		FROM ITF_AGIP_PADRON 
		WHERE cuit = @cuitAux --@cuit 
		  AND SUBSTRING(Fecha_Publicacion,5,4) = @anio_ant
		  AND SUBSTRING(Fecha_Publicacion,3,2) = @mes_ant
		GROUP BY Alicuota_Retencion, Alicuota_Percepcion;
		
		
		--no hubieron cambios respecto al mes anterior
		IF (@vinoEnPadron > 0 AND @alicuotaPercVIEJA = @Alicuota_Percepcion)
			UPDATE ITF_AGIP_PADRON_IMPUESTOS_AUX SET AFECTA_CLIENTE = ''N'' WHERE cuit = @cuitAux;
		ELSE
		BEGIN
		 --hubieron cambios, van a la bitacora con cod_cliente = 0     		
     	   INSERT INTO CON_BITACORA_IMPUESTOS (JTS_NOVEDAD, TIPO_NOVEDAD, OPERACION_TOPAZ, FECHA_PROCESO, HORA, ASIENTO, COD_USUARIO, ARCHIVO_PADRON, NUM_CERTIFICADO, F_EMISION, SUCURSAL, ID_CLIENTE, ID_PERSONA, TIPO_ID, CUIT, TIPO_CARGO_IMPOSITIVO, TABLA_CARGOS_IMPUESTOS, ID_CARGO_IMPUESTO, CONDICION, VALOR_EXCLUSION, ALICUOTA, VALOR_ALICUOTA_IIBB, FECHA_INICIO, FECHA_FIN, COMENTARIOS, CBU)
				VALUES (ISNULL((SELECT MAX(JTS_NOVEDAD)+1 FROM CON_BITACORA_IMPUESTOS (NOLOCK)),1), '''', 0,(SELECT FECHAPROCESO FROM PARAMETROS (NOLOCK)), concat(DATEPART(HOUR, GETDATE()),'':'', DATEPART(MINUTE, GETDATE()),'':'',DATEPART(SECOND, GETDATE())), 0, ''ES'', '''', '''', NULL, 1, 0 , @numeroPersona  , ''C'', @cuit, 0, NULL, NULL, @recaud_perc_Aux , 0, '''', @Alicuota_Percepcion , '''', NULL, '''', '''');
		   UPDATE ITF_AGIP_PADRON_IMPUESTOS_AUX SET AFECTA_CLIENTE = ''S'' WHERE cuit = @cuitAux;
		END
			
		IF (@vinoEnPadron > 0 AND @alicuotaRetenVIEJA = @Alicuota_Retencion)
			UPDATE ITF_AGIP_PADRON_IMPUESTOS_AUX SET AFECTA_CLIENTE = ''N'' WHERE cuit = @cuitAux;
		ELSE
		BEGIN
		 --hubieron cambios, van a la bitacora con cod_cliente = 0     		
     	   INSERT INTO CON_BITACORA_IMPUESTOS (JTS_NOVEDAD, TIPO_NOVEDAD, OPERACION_TOPAZ, FECHA_PROCESO, HORA, ASIENTO, COD_USUARIO, ARCHIVO_PADRON, NUM_CERTIFICADO, F_EMISION, SUCURSAL, ID_CLIENTE, ID_PERSONA, TIPO_ID, CUIT, TIPO_CARGO_IMPOSITIVO, TABLA_CARGOS_IMPUESTOS, ID_CARGO_IMPUESTO, CONDICION, VALOR_EXCLUSION, ALICUOTA, VALOR_ALICUOTA_IIBB, FECHA_INICIO, FECHA_FIN, COMENTARIOS, CBU)
				VALUES (ISNULL((SELECT MAX(JTS_NOVEDAD)+1 FROM CON_BITACORA_IMPUESTOS (NOLOCK)),1), '''', 0,(SELECT FECHAPROCESO FROM PARAMETROS (NOLOCK)), concat(DATEPART(HOUR, GETDATE()),'':'', DATEPART(MINUTE, GETDATE()),'':'',DATEPART(SECOND, GETDATE())), 0, ''ES'', '''', '''', NULL, 1, 0 , @numeroPersona  , ''C'', @cuit, 0, NULL, NULL, @recaud_rete_Aux , 0, '''', @Alicuota_Retencion , '''', NULL, '''', '''');
			UPDATE ITF_AGIP_PADRON_IMPUESTOS_AUX SET AFECTA_CLIENTE = ''S'' WHERE cuit = @cuitAux;
		END
			
		--persona fisica  
	    
	   	IF(@cuitAux < ''30000000000'')	    
			UPDATE CLI_PersonasFisicas 
			SET IIBB_CABA_PERCEPCION_ALI = @Alicuota_Percepcion , 
				IIBB_CABA_PERCEPCION_COND = @recaud_Perc_Aux,
				IIBB_CABA_RETENCION_ALI=@Alicuota_Retencion,
				IIBB_CABA_RETENCION_COND=@recaud_rete_Aux
			FROM CLI_PersonasFisicas pf JOIN CLI_DocumentosPFPJ cliDoc 
			  ON cliDoc.NUMEROPERSONAFJ = pf.NUMEROPERSONAFISICA
			WHERE cliDoc.NUMERODOCUMENTO  = @cuitAux; 	   
  		
   	 	--persona juridica
		IF(@cuitAux >= ''30000000000'')
			UPDATE CLI_PERSONASJURIDICAS 
			SET IIBB_CABA_PERCEPCION_ALI = @Alicuota_Percepcion , 
				IIBB_CABA_PERCEPCION_COND = @recaud_Perc_Aux,
				IIBB_CABA_RETENCION_ALI=@Alicuota_Retencion,
				IIBB_CABA_RETENCION_COND=@recaud_rete_Aux
			FROM CLI_PERSONASJURIDICAS pj JOIN CLI_DocumentosPFPJ cliDoc 
			  ON cliDoc.NUMEROPERSONAFJ = pj.NUMEROPERSONAJURIDICA 
			WHERE cliDoc.NUMERODOCUMENTO  = @cuitAux;
		
		
		--solo actualizo cliente si hubo modificacion respecto al mes anterior
		IF((SELECT AFECTA_CLIENTE FROM ITF_AGIP_PADRON_IMPUESTOS_AUX WHERE cuit = @cuitAux) = ''S'' OR @cantImp = 0)
		BEGIN
			DECLARE cursorCli CURSOR FOR 
			SELECT DISTINCT 
				cp.CODIGOCLIENTE FROM CLI_DocumentosPFPJ pfj 
					JOIN CLI_ClientePersona cp ON pfj.NUMEROPERSONAFJ = cp.NUMEROPERSONA 
						WHERE pfj.NUMERODOCUMENTO =  @cuitAux
						AND cp.TZ_LOCK = 0
						AND pfj.TZ_LOCK = 0
			OPEN cursorCli 
			FETCH NEXT FROM cursorCli INTO @codCli
			WHILE @@FETCH_STATUS = 0 
			BEGIN
			
				SELECT TOP 1 @personaMasGravosaPerc =persona,@alicuotaPercMax=alicuotaPercMax, @condicionPercMax=PercCondicion  FROM --necesito quedarme con el numero de persona para guardar el log y tambien con la max alicuota
				(
				SELECT b.NUMEROPERSONAFISICA AS persona, b.IIBB_CABA_PERCEPCION_ALI  AS alicuotaPercMax , b.IIBB_CABA_PERCEPCION_COND  AS PercCondicion FROM 
				CLI_ClientePersona a 
				JOIN CLI_PERSONASFISICAS b ON a.NUMEROPERSONA = b.NUMEROPERSONAFISICA 
					WHERE a.TZ_LOCK = 0 AND a.TZ_LOCK = 0 AND  a.CODIGOCLIENTE = @codCli
				UNION ALL 
				SELECT 	j.NUMEROPERSONAJURIDICA AS persona , j.IIBB_CABA_PERCEPCION_ALI  AS alicuotaPercMax, j.IIBB_CABA_PERCEPCION_COND  AS PercCondicion FROM 
				CLI_ClientePersona a 
				JOIN CLI_PERSONASJURIDICAS j ON a.NUMEROPERSONA = j.NUMEROPERSONAJURIDICA 
					WHERE a.TZ_LOCK = 0 AND j.TZ_LOCK = 0  AND  a.CODIGOCLIENTE = @codCli
				) AS xd
				ORDER BY alicuotaPercMax DESC
				

				SELECT TOP 1 @personaMasGravosaReten=persona,@alicuotaRetenMax=alicuotaRetenMax, @condicionRetenMax=RetenCondicion  FROM --necesito quedarme con el numero de persona para guardar el log y tambien con la max alicuota
				(
				SELECT b.NUMEROPERSONAFISICA AS persona, b.IIBB_CABA_RETENCION_ALI  AS alicuotaRetenMax , b.IIBB_CABA_RETENCION_COND   AS RetenCondicion FROM 
				CLI_ClientePersona a 
				JOIN CLI_PERSONASFISICAS b ON a.NUMEROPERSONA = b.NUMEROPERSONAFISICA 
					WHERE a.TZ_LOCK = 0 AND a.TZ_LOCK = 0 AND  a.CODIGOCLIENTE = @codCli
				UNION ALL 
				SELECT 	j.NUMEROPERSONAJURIDICA AS persona , j.IIBB_CABA_RETENCION_ALI  AS alicuotaRetenMax, j.IIBB_CABA_RETENCION_COND   AS RetenCondicion FROM 
				CLI_ClientePersona a 
				JOIN CLI_PERSONASJURIDICAS j ON a.NUMEROPERSONA = j.NUMEROPERSONAJURIDICA 
					WHERE a.TZ_LOCK = 0 AND j.TZ_LOCK = 0  AND  a.CODIGOCLIENTE = @codCli 
				) AS xd
				ORDER BY alicuotaRetenMax DESC	
				
			   	 SET @actualizaCliPer = (SELECT CASE WHEN IIBB_CABA_PERCEPCION_ALI  = @alicuotaPercMax THEN ''N'' ELSE ''S'' END FROM CLI_CLIENTES WHERE CODIGOCLIENTE = @codCli);
			   	 SET @actualizaCliRet = (SELECT CASE WHEN IIBB_CABA_RETENCION_ALI   = @alicuotaRetenMax THEN ''N'' ELSE ''S'' END FROM CLI_CLIENTES WHERE CODIGOCLIENTE = @codCli);
				 
			   	 IF(@actualizaCliPer = ''S'') --guardo en la bitacora solo si hubieron cambios
			   	 BEGIN				   	 
			   	 	INSERT INTO ITF_LOG_PADRON_IMPUESTOS (COD_IMPUESTO, PERIODO_PADRON, COD_CLIENTE, ID_PERSONA, FECHA_PROCESO, FECHA_EJECUCION, CONDICION, ALICUOTA)
				 		VALUES (''08'', @perParam, @codCli, @personaMasGravosaPerc, CONVERT(VARCHAR(8), (SELECT FECHAPROCESO FROM PARAMETROS (NOLOCK)), 112), CONVERT(VARCHAR(8), (SELECT FECHAPROCESO FROM PARAMETROS (NOLOCK)), 112) , @condicionPercMax, @alicuotaPercMax);
			   	 	UPDATE CLI_CLIENTES SET IIBB_CABA_PERCEPCION_ALI = @alicuotaPercMax, IIBB_CABA_PERCEPCION_COND  = @condicionPercMax  WHERE CODIGOCLIENTE = @codCli;
				END
			   	 IF(@actualizaCliRet = ''S'') --guardo en la bitacora solo si hubieron cambios
			   	 BEGIN				   	 
			   	 	INSERT INTO ITF_LOG_PADRON_IMPUESTOS (COD_IMPUESTO, PERIODO_PADRON, COD_CLIENTE, ID_PERSONA, FECHA_PROCESO, FECHA_EJECUCION, CONDICION, ALICUOTA)
				 		VALUES (''12'', @perParam, @codCli, @personaMasGravosaReten, CONVERT(VARCHAR(8), (SELECT FECHAPROCESO FROM PARAMETROS (NOLOCK)), 112), CONVERT(VARCHAR(8), (SELECT FECHAPROCESO FROM PARAMETROS (NOLOCK)), 112) , @condicionPercMax, @alicuotaRetenMax);
			   	 	UPDATE CLI_CLIENTES SET IIBB_CABA_RETENCION_ALI  = @alicuotaRetenMax, IIBB_CABA_RETENCION_COND  = @condicionRetenMax  WHERE CODIGOCLIENTE = @codCli;
				END
				
			FETCH NEXT FROM cursorCli INTO @codCli
			END --Fin del WHILE    	
			CLOSE cursorCli --Cerrar el CURSOR cli
			DEALLOCATE cursorCli
		END
		
   	FETCH NEXT FROM cursorAux INTO @id, @fecha_public, @fecha_vig_desde, @fecha_vig_hasta, @cuitAux, @Tipo_Contr_Insc,
      @Marca_alta_sujeto, @Marca_alicuota, @Alicuota_Percepcion, @Alicuota_Retencion, 
      @Nro_Grupo_Percepcion, @Nro_Grupo_Retencion, @razonSocial
   	END --Fin del WHILE
   
CLOSE cursorAux --Cerrar el CURSOR
DEALLOCATE cursorAux 


--Calcular la fecha limite	
DECLARE @FechaLimite VARCHAR(8);
DECLARE @perParDATATIME DATE = CAST(CONCAT(SUBSTRING(@perParam,3,4),SUBSTRING(@perParam,1,2),''01'') AS DATE);
SET @FechaLimite = CONVERT(VARCHAR(8), DATEADD(MONTH, -6, @perParDATATIME),112);

-- Eliminar los registros anteriores a la fecha límite
DELETE FROM ITF_AGIP_PADRON
WHERE CONVERT(DATE, SUBSTRING(Fecha_Publicacion, 5, 4) + SUBSTRING(Fecha_Publicacion, 3, 2) + SUBSTRING(Fecha_Publicacion, 1, 2), 112) < CONVERT(DATE, @FechaLimite, 112);

END
')