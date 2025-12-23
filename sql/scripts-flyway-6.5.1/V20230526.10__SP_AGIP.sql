EXECUTE('
CREATE OR ALTER    PROCEDURE [dbo].[SP_AGIP_PADRON_IMPUESTOS] 
 	@perParam VARCHAR(6),
 	@reproceso VARCHAR(1) --mostrar error en caso de que la fecha en el padron no sea la misma que la fecha proceso
AS



BEGIN

DECLARE @fecha datetime = CONVERT(DATETIME, (SELECT FECHAPROCESO FROM PARAMETROS), 103);

DECLARE @periodoActual DATETIME = CAST(CONCAT(SUBSTRING(@perParam,3,4),SUBSTRING(@perParam,1,2),''01'') AS DATETIME);
DECLARE @anio INT 
DECLARE @mes INT 

SET @mes = (SELECT CASE WHEN @reproceso = ''S'' THEN MONTH(dateadd(month,0,@periodoActual)) ELSE MONTH(dateadd(month,-1,@periodoActual)) END);
SET @anio = (SELECT CASE WHEN @reproceso = ''S'' THEN YEAR(dateadd(month,0,@periodoActual)) ELSE YEAR(dateadd(month,-1,@periodoActual)) END);


DECLARE @fechaInicio DATETIME; 
DECLARE @fechaFin DATETIME; 



--var generales

DECLARE @id NUMERIC(20);
DECLARE @reg VARCHAR(70);
DECLARE @cantImp INT = (SELECT COUNT(*) FROM ITF_AGIP_PADRON); --caso base, si es 0 solo hay que grabar porque es la primer ejecucion y no se compara
DECLARE @codCli NUMERIC(20);
DECLARE @cuit VARCHAR(11),@cuitAux VARCHAR(11),@razonSocial VARCHAR(44), @periodo VARCHAR(6), @alicuota VARCHAR(6);
DECLARE @actualizaCliPer VARCHAR(1);
DECLARE @actualizaCliRet VARCHAR(1);

--var auxiliares
DECLARE @alicuota_perc_Aux NUMERIC(4,4), @alicuotaPercMax NUMERIC(4,4), @alicuotaPercVIEJA NUMERIC(4,4), @recaud_perc_Aux VARCHAR (2),
 @vinoEnPadron INT;
DECLARE @personaMasGravosaPerc NUMERIC(12), @condicionPercMax VARCHAR(2);
DECLARE @numeroPersonaPerc NUMERIC(20), @numeroClientePerc NUMERIC(20);

DECLARE @alicuota_rete_Aux NUMERIC(4,4), @alicuotaRetenMax NUMERIC(4,4), @alicuotaRetenVIEJA NUMERIC(4,4),
 @recaud_rete_Aux VARCHAR (2);
DECLARE @personaMasGravosaReten NUMERIC(12), @condicionRetenMax VARCHAR(2);
DECLARE @numeroPersona NUMERIC(20), @numeroCliente NUMERIC(20);

DECLARE @fecha_public VARCHAR(8),@fecha_vig_desde VARCHAR(8),
@fecha_vig_hasta VARCHAR(8),@Tipo_Contr_Insc VARCHAR(1),@Marca_alta_sujeto VARCHAR(1),
@Marca_alicuota VARCHAR(1),@Alicuota_Percepcion NUMERIC(6,2),@Alicuota_Retencion NUMERIC(6,2),@Nro_Grupo_Percepcion VARCHAR(2),
@Nro_Grupo_Retencion VARCHAR(2);
DECLARE @TEST VARCHAR(2);

--comparo para ver que registros no vinieron en el padron
DECLARE cursorOk CURSOR FOR 
SELECT cuit 
FROM ITF_AGIP_PADRON WHERE @anio = YEAR(CONVERT(DATETIME, STUFF(STUFF(Fecha_Publicacion, 5, 0, ''-''), 3, 0, ''-''), 105)) AND @mes = MONTH(CONVERT(DATETIME, STUFF(STUFF(Fecha_Publicacion, 5, 0, ''-''), 3, 0, ''-''), 105)) OPEN cursorOk
    FETCH NEXT FROM cursorOk INTO @cuit
    WHILE @@FETCH_STATUS = 0 
    BEGIN
  		SET @vinoEnPadron=0;
    	SELECT @vinoEnPadron=COUNT(*),
    	@fechaInicio=CONVERT(datetime, SUBSTRING(fecha_vig_desde, 5, 4) + SUBSTRING(fecha_vig_desde, 3, 2) + SUBSTRING(fecha_vig_desde, 1, 2), 112),
    	@fechaFin=CONVERT(datetime, SUBSTRING(fecha_vig_hasta, 5, 4) + SUBSTRING(fecha_vig_hasta, 3, 2) + SUBSTRING(fecha_vig_hasta, 1, 2), 112)
    	 FROM ITF_AGIP_PADRON_IMPUESTOS_AUX WHERE cuit = @cuit GROUP BY fecha_vig_desde,fecha_vig_hasta;

    	IF @vinoEnPadron>0 AND dateadd(DAY,1,@fecha) >= @fechaInicio AND dateadd(DAY,1,@fecha) <= @fechaFin
  		   	BEGIN

    		SET @alicuota_perc_Aux = (SELECT  Alicuota_Percepcion FROM ITF_AGIP_PADRON_IMPUESTOS_AUX WHERE cuit = @cuit);       
    		SET @alicuota_rete_Aux = (SELECT  Alicuota_Retencion FROM ITF_AGIP_PADRON_IMPUESTOS_AUX WHERE cuit = @cuit); 
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


    	SET @numeroPersona = 0;
    	SET @numeroCliente = 0 ;

		
		--persona fisica  
	    IF(@cuit < ''30000000000'')	    
			UPDATE CLI_PersonasFisicas SET IIBB_CABA_PERCEPCION_ALI = @alicuota_perc_Aux , IIBB_CABA_PERCEPCION_COND = @recaud_perc_Aux,
				IIBB_CABA_RETENCION_ALI=@alicuota_rete_Aux,IIBB_CABA_RETENCION_COND=@recaud_rete_Aux
				FROM CLI_PersonasFisicas pf JOIN VW_CLI_X_DOC cliDoc ON cliDoc.NUMEROPERSONA = pf.NUMEROPERSONAFISICA WHERE cliDoc.NUMERODOC  = @cuit; 	   
  		
   	 	--persona juridica
		IF(@cuit >= ''30000000000'')
			UPDATE CLI_PERSONASJURIDICAS SET IIBB_CABA_PERCEPCION_ALI = @alicuota_perc_Aux , IIBB_CABA_PERCEPCION_COND = @recaud_perc_Aux,
				IIBB_CABA_RETENCION_ALI=@alicuota_rete_Aux,IIBB_CABA_RETENCION_COND=@recaud_rete_Aux
				FROM CLI_PERSONASJURIDICAS pj JOIN VW_CLI_X_DOC cliDoc ON cliDoc.NUMEROPERSONA = pj.NUMEROPERSONAJURIDICA WHERE cliDoc.NUMERODOC  = @cuit;
		
    
   	FETCH NEXT FROM cursorOk INTO @cuit
   	END --Fin del WHILE

    	
CLOSE cursorOk --Cerrar el CURSOR ok
DEALLOCATE cursorOk


--recorro padron nuevo
DECLARE cursorAux CURSOR FOR --Declarar el CURSOR aux
SELECT ID
FROM ITF_AGIP_PADRON_IMPUESTOS_AUX WHERE YEAR(@periodoActual) = YEAR(CONVERT(DATETIME, STUFF(STUFF(fecha_public, 5, 0, ''-''), 3, 0, ''-''), 105)) AND MONTH(@periodoActual) = MONTH(CONVERT(DATETIME, STUFF(STUFF(fecha_public, 5, 0, ''-''), 3, 0, ''-''), 105))
OPEN cursorAux
    FETCH NEXT FROM cursorAux INTO @id
 
    WHILE @@FETCH_STATUS = 0 
    BEGIN
		SELECT @fecha_public=fecha_public,@fecha_vig_desde=fecha_vig_desde,@fecha_vig_hasta=fecha_vig_hasta,
		@cuitAux=cuit,@Tipo_Contr_Insc=Tipo_Contr_Insc ,@Marca_alta_sujeto=Marca_alta_sujeto,
		@Marca_alicuota=Marca_alicuota,@Alicuota_Percepcion=Alicuota_Percepcion,
		@Alicuota_Retencion=Alicuota_Retencion,@Nro_Grupo_Percepcion=Nro_Grupo_Percepcion,@Nro_Grupo_Retencion=Nro_Grupo_Retencion,
		@razonSocial=Razon_Social FROM ITF_AGIP_PADRON_IMPUESTOS_AUX WHERE ID = @id  ;
		
        SET @recaud_rete_Aux = (SELECT CASE WHEN @Alicuota_Retencion = 0.0 THEN ''EX'' ELSE ''AC'' END);
        SET @recaud_perc_Aux = (SELECT CASE WHEN @Alicuota_Percepcion = 0.0 THEN ''EX'' ELSE ''AC'' END);


		
     	--caso base
   		IF(@cantImp = 0) INSERT INTO ITF_AGIP_PADRON VALUES (@fecha_vig_desde,@fecha_public, @fecha_vig_hasta,@cuitAux,@razonSocial,@Tipo_Contr_Insc,@Marca_alta_sujeto,@Alicuota_Percepcion,@Alicuota_Retencion,@Nro_Grupo_Percepcion,@Marca_alicuota,@Nro_Grupo_Retencion); 

		SET @vinoEnPadron  = 0;
		SET @alicuotaPercVIEJA = 0;
		SET @alicuotaRetenVIEJA = 0;
		SELECT @vinoEnPadron = COUNT(*), @alicuotaRetenVIEJA = Alicuota_Retencion ,@alicuotaPercVIEJA= Alicuota_Percepcion FROM ITF_AGIP_PADRON WHERE cuit = @cuit AND YEAR(dateadd(month,-1,@periodoActual)) = YEAR(CONVERT(DATETIME, STUFF(STUFF(Fecha_Publicacion, 5, 0, ''-''), 3, 0, ''-''), 105)) AND MONTH(dateadd(month,-1,@periodoActual)) = MONTH(CONVERT(DATETIME, STUFF(STUFF(Fecha_Publicacion, 5, 0, ''-''), 3, 0, ''-''), 105)) GROUP BY Alicuota_Retencion, Alicuota_Percepcion;
		
		
		--no hubieron cambios respecto al mes anterior
		IF (@vinoEnPadron > 0 AND @alicuotaPercVIEJA = @Alicuota_Percepcion)
			UPDATE ITF_AGIP_PADRON_IMPUESTOS_AUX SET AFECTA_CLIENTE = ''N'' WHERE cuit = @cuitAux;
		ELSE --hubieron cambios, van a la bitacora con cod_cliente = 0     		
     	   INSERT INTO CON_BITACORA_IMPUESTOS (JTS_NOVEDAD, TIPO_NOVEDAD, OPERACION_TOPAZ, FECHA_PROCESO, HORA, ASIENTO, COD_USUARIO, ARCHIVO_PADRON, NUM_CERTIFICADO, F_EMISION, SUCURSAL, ID_CLIENTE, ID_PERSONA, TIPO_ID, CUIT, TIPO_CARGO_IMPOSITIVO, TABLA_CARGOS_IMPUESTOS, ID_CARGO_IMPUESTO, CONDICION, VALOR_EXCLUSION, ALICUOTA, VALOR_ALICUOTA_IIBB, FECHA_INICIO, FECHA_FIN, COMENTARIOS, CBU)
				VALUES (ISNULL((SELECT MAX(JTS_NOVEDAD)+1 FROM CON_BITACORA_IMPUESTOS (NOLOCK)),1), '''', 0,(SELECT FECHAPROCESO FROM PARAMETROS (NOLOCK)), concat(DATEPART(HOUR, GETDATE()),'':'', DATEPART(MINUTE, GETDATE()),'':'',DATEPART(SECOND, GETDATE())), 0, ''ES'', '''', '''', NULL, 1, 0 , @numeroPersona  , ''C'', @cuit, 0, NULL, NULL, @recaud_perc_Aux , 0, '''', @Alicuota_Percepcion , '''', NULL, '''', '''');

			
		IF (@vinoEnPadron > 0 AND @alicuotaRetenVIEJA = @Alicuota_Retencion)
			UPDATE ITF_AGIP_PADRON_IMPUESTOS_AUX SET AFECTA_CLIENTE = ''N'' WHERE cuit = @cuitAux;
		ELSE --hubieron cambios, van a la bitacora con cod_cliente = 0     		
     	   INSERT INTO CON_BITACORA_IMPUESTOS (JTS_NOVEDAD, TIPO_NOVEDAD, OPERACION_TOPAZ, FECHA_PROCESO, HORA, ASIENTO, COD_USUARIO, ARCHIVO_PADRON, NUM_CERTIFICADO, F_EMISION, SUCURSAL, ID_CLIENTE, ID_PERSONA, TIPO_ID, CUIT, TIPO_CARGO_IMPOSITIVO, TABLA_CARGOS_IMPUESTOS, ID_CARGO_IMPUESTO, CONDICION, VALOR_EXCLUSION, ALICUOTA, VALOR_ALICUOTA_IIBB, FECHA_INICIO, FECHA_FIN, COMENTARIOS, CBU)
				VALUES (ISNULL((SELECT MAX(JTS_NOVEDAD)+1 FROM CON_BITACORA_IMPUESTOS (NOLOCK)),1), '''', 0,(SELECT FECHAPROCESO FROM PARAMETROS (NOLOCK)), concat(DATEPART(HOUR, GETDATE()),'':'', DATEPART(MINUTE, GETDATE()),'':'',DATEPART(SECOND, GETDATE())), 0, ''ES'', '''', '''', NULL, 1, 0 , @numeroPersona  , ''C'', @cuit, 0, NULL, NULL, @recaud_rete_Aux , 0, '''', @Alicuota_Retencion , '''', NULL, '''', '''');
	
			
		--persona fisica  
	    
	   	IF(@cuitAux < ''30000000000'')	    
			UPDATE CLI_PersonasFisicas SET IIBB_CABA_PERCEPCION_ALI = @Alicuota_Percepcion , IIBB_CABA_PERCEPCION_COND = @recaud_Perc_Aux,
				IIBB_CABA_RETENCION_ALI=@Alicuota_Retencion,IIBB_CABA_RETENCION_COND=@recaud_rete_Aux
				FROM CLI_PersonasFisicas pf JOIN VW_CLI_X_DOC cliDoc ON cliDoc.NUMEROPERSONA = pf.NUMEROPERSONAFISICA WHERE cliDoc.NUMERODOC  = @cuitAux; 	   
  		
   	 	--persona juridica
		IF(@cuitAux >= ''30000000000'')
			UPDATE CLI_PERSONASJURIDICAS SET IIBB_CABA_PERCEPCION_ALI = @Alicuota_Percepcion , IIBB_CABA_PERCEPCION_COND = @recaud_Perc_Aux,
				IIBB_CABA_RETENCION_ALI=@Alicuota_Retencion,IIBB_CABA_RETENCION_COND=@recaud_rete_Aux
				FROM CLI_PERSONASJURIDICAS pj JOIN VW_CLI_X_DOC cliDoc ON cliDoc.NUMEROPERSONA = pj.NUMEROPERSONAJURIDICA WHERE cliDoc.NUMERODOC  = @cuitAux;
		
		

		--solo actualizo cliente si hubo modificacion respecto al mes anterior
		IF((SELECT AFECTA_CLIENTE FROM ITF_AGIP_PADRON_IMPUESTOS_AUX WHERE cuit = @cuitAux) = ''S'')
		BEGIN
			DECLARE cursorCli CURSOR FOR 
			SELECT DISTINCT 
				cp.CODIGOCLIENTE FROM CLI_DocumentosPFPJ pfj 
					JOIN CLI_ClientePersona cp ON pfj.NUMEROPERSONAFJ = cp.NUMEROPERSONA 
						WHERE pfj.NUMERODOCUMENTO =  @cuitAux
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
			   	 	UPDATE CLI_CLIENTES SET IIBB_CABA_PERCEPCION_ALI = @alicuotaPercMax, IIBB_CABA_PERCEPCION_COND  = @recaud_perc_Aux  WHERE CODIGOCLIENTE = @codCli;
				END
			   	 IF(@actualizaCliRet = ''S'') --guardo en la bitacora solo si hubieron cambios
			   	 BEGIN				   	 
			   	 	INSERT INTO ITF_LOG_PADRON_IMPUESTOS (COD_IMPUESTO, PERIODO_PADRON, COD_CLIENTE, ID_PERSONA, FECHA_PROCESO, FECHA_EJECUCION, CONDICION, ALICUOTA)
				 		VALUES (''12'', @perParam, @codCli, @personaMasGravosaReten, CONVERT(VARCHAR(8), (SELECT FECHAPROCESO FROM PARAMETROS (NOLOCK)), 112), CONVERT(VARCHAR(8), (SELECT FECHAPROCESO FROM PARAMETROS (NOLOCK)), 112) , @condicionPercMax, @alicuotaRetenMax);
			   	 	UPDATE CLI_CLIENTES SET IIBB_CABA_RETENCION_ALI  = @alicuotaRetenMax, IIBB_CABA_RETENCION_COND  = @recaud_rete_Aux  WHERE CODIGOCLIENTE = @codCli;
				END
				
			FETCH NEXT FROM cursorCli INTO @codCli
			END --Fin del WHILE    	
			CLOSE cursorCli --Cerrar el CURSOR cli
			DEALLOCATE cursorCli
		END
		
	--inserto en el padron
   IF(@cantImp <> 0)  
	  INSERT INTO ITF_AGIP_PADRON VALUES (@fecha_vig_desde,@fecha_public, @fecha_vig_hasta,@cuitAux,@razonSocial,@Tipo_Contr_Insc,@Marca_alta_sujeto,@Alicuota_Percepcion,@Alicuota_Retencion,@Nro_Grupo_Percepcion,@Marca_alicuota,@Nro_Grupo_Retencion); 

		
   	FETCH NEXT FROM cursorAux INTO @id
   	END --Fin del WHILE
   
CLOSE cursorAux --Cerrar el CURSOR
DEALLOCATE cursorAux 


--Calcular la fecha límite	
DECLARE @FechaLimite VARCHAR(8);
DECLARE @perParDATATIME DATETIME = CAST(CONCAT(SUBSTRING(@perParam,3,4),SUBSTRING(@perParam,1,2),''01'') AS DATETIME);
SET @FechaLimite = CONVERT(VARCHAR(8), DATEADD(MONTH, -6, @perParDATATIME),112);

-- Eliminar los registros anteriores a la fecha límite
DELETE FROM ITF_AGIP_PADRON
WHERE CONVERT(DATE, SUBSTRING(Fecha_Publicacion, 5, 4) + SUBSTRING(Fecha_Publicacion, 3, 2) + SUBSTRING(Fecha_Publicacion, 1, 2), 112) < CONVERT(DATE, @FechaLimite, 112);

END

')