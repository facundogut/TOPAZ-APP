EXECUTE('
CREATE OR ALTER    PROCEDURE [dbo].[SP_RCTES_PADRON_IMPUESTOS]
--Juan Pedrozo 22/05/2023 - ITF 2.21.1

  	@perParam VARCHAR(6),
  	@reproceso VARCHAR(1)
  	
AS
BEGIN


DECLARE @periodoActual DATETIME = CAST(CONCAT(SUBSTRING(@perParam,3,4),SUBSTRING(@perParam,1,2),''01'') AS DATETIME);
DECLARE @periodoAcomparar DATETIME = (SELECT CASE WHEN @reproceso = ''S'' OR @reproceso = ''s''  THEN @periodoActual ELSE dateadd(month,-1,@periodoActual) END); --si hay reproceso se compara con el mes actual, sino, se compara con el mes anterior


--var generales
DECLARE @reg VARCHAR(70);
DECLARE @cantImp INT = (SELECT COUNT(*) FROM ITF_PADRON_IMPUESTOS); --caso base, si es 0 solo hay que grabar porque es la primer ejecucion y no se compara
DECLARE @codCli NUMERIC(20);
DECLARE @cuit VARCHAR(11),@razonSocial VARCHAR(44), @periodo VARCHAR(6), @alicuota NUMERIC(11,7);

--var auxiliares
DECLARE @alicuotaAux NUMERIC(11,7), @alicuotaMax NUMERIC(11,7), @alicuotaVIEJA NUMERIC(11,7), @recaudAux VARCHAR (2), @vinoEnPadron INT;
DECLARE @personaMasGravosa NUMERIC(12), @condicionMax VARCHAR(2);
DECLARE @numeroPersona NUMERIC(20), @numeroCliente NUMERIC(20);
DECLARE @actualizaCli VARCHAR(1),  @restaurarCliente VARCHAR(1);

--comparo para ver que registros no vinieron en el padron
DECLARE cursorOk CURSOR FOR 
SELECT cuit 
FROM ITF_PADRON_IMPUESTOS WHERE CAST(CONCAT(SUBSTRING(PERIODO_ARCHIVO,3,4),SUBSTRING(PERIODO_ARCHIVO,1,2),''01'') AS DATETIME)  = @periodoAcomparar;
OPEN cursorOk
    FETCH NEXT FROM cursorOk INTO @cuit
    WHILE @@FETCH_STATUS = 0 
    BEGIN
    	SET @vinoEnPadron = (SELECT COUNT(*) FROM ITF_PADRON_IMPUESTOS_AUX WHERE SUBSTRING(REGISTRO, 1, 11) = @cuit);
    	
    	SET @alicuotaAux = 0;
    	SELECT @alicuotaAux = CAST(substring(REGISTRO, 62,6) AS NUMERIC)/1000000 FROM ITF_PADRON_IMPUESTOS_AUX WHERE SUBSTRING(REGISTRO, 1, 11) = @cuit;       
    	
    	SET @recaudAux = (SELECT CASE WHEN @vinoEnPadron < 1 THEN ''NA'' WHEN (@vinoEnPadron >= 1 AND @alicuotaAux = 0) THEN ''EX'' ELSE ''AC'' END);    
    	  	
     	--persona fisica  
	    IF(@cuit < ''30000000000'')	    
			UPDATE CLI_PersonasFisicas SET IIBB_CORRIENTES_ALI = @alicuotaAux , IIBB_CORRIENTES_RECAUD = @recaudAux
				FROM CLI_PersonasFisicas pf JOIN CLI_DocumentosPFPJ cliDoc ON cliDoc.NUMEROPERSONAFJ = pf.NUMEROPERSONAFISICA WHERE cliDoc.NUMERODOCUMENTO  = @cuit; 	   
  		
   	 	--persona juridica
		IF(@cuit >= ''30000000000'')
			UPDATE CLI_PERSONASJURIDICAS SET IIBB_CORRIENTES_RECAUD = @recaudAux, IIBB_CORRIENTES_ALI = @alicuotaAux 
				FROM CLI_PERSONASJURIDICAS pj JOIN CLI_DocumentosPFPJ cliDoc ON cliDoc.NUMEROPERSONAFJ = pj.NUMEROPERSONAJURIDICA WHERE cliDoc.NUMERODOCUMENTO  = @cuit;
		
		
		
		----------------------------------------
		
			--en caso de haber reproceso hay que dejar como estaban los clientes procesados que no vinieron en el ultimo padron
		SET @restaurarCliente = (SELECT COUNT(*) FROM ITF_PADRON_IMPUESTOS_AUX WHERE SUBSTRING(REGISTRO, 1, 11) = @cuit);
		IF(@reproceso = ''S'' AND @restaurarCliente = 0)  --si no vino en el padron nuevo, hay que ajustar la condicion del cliente
		BEGIN
			DECLARE cursorRep CURSOR FOR 
			SELECT DISTINCT 
				cp.CODIGOCLIENTE FROM CLI_DocumentosPFPJ pfj 
					JOIN CLI_ClientePersona cp ON pfj.NUMEROPERSONAFJ = cp.NUMEROPERSONA 
						WHERE pfj.NUMERODOCUMENTO =  @cuit AND cp.TZ_LOCK=0
			OPEN cursorRep
			FETCH NEXT FROM cursorRep INTO @codCli
			WHILE @@FETCH_STATUS = 0 
			BEGIN
			
			   

 			SELECT TOP 1 @personaMasGravosa = persona, @alicuotaMax = alicuotaMax, @condicionMax = condicion  FROM --necesito quedarme con el numero de persona para guardar el log y tambien con la max alicuota

					(
					SELECT b.NUMEROPERSONAFISICA AS persona, b.IIBB_CORRIENTES_ALI AS alicuotaMax , b.IIBB_CORRIENTES_RECAUD AS condicion FROM 
					CLI_ClientePersona a 
					JOIN CLI_PERSONASFISICAS b ON a.NUMEROPERSONA = b.NUMEROPERSONAFISICA 
						WHERE a.TZ_LOCK = 0 AND a.TZ_LOCK = 0 AND a.CODIGOCLIENTE = @codCli
					UNION ALL 
					SELECT 	j.NUMEROPERSONAJURIDICA AS persona , j.IIBB_CORRIENTES_ALI AS alicuotaMax, j.IIBB_CORRIENTES_RECAUD AS condicion FROM 
					CLI_ClientePersona a 
					JOIN CLI_PERSONASJURIDICAS j ON a.NUMEROPERSONA = j.NUMEROPERSONAJURIDICA 
						WHERE a.TZ_LOCK = 0 AND j.TZ_LOCK = 0 AND  a.CODIGOCLIENTE = @codCli
					) AS xd
					ORDER BY alicuotaMax DESC
								 
	  		   					   	 
			   	 SET @actualizaCli = (SELECT CASE WHEN IIBB_CORRIENTES_ALI = @alicuotaMax THEN ''N'' ELSE ''S'' END FROM CLI_CLIENTES WHERE CODIGOCLIENTE = @codCli);
			   	 
			   	 IF(@actualizaCli = ''S'') --guardo en la bitacora solo si hubieron cambios
			   	 BEGIN				   	 
			   	 	INSERT INTO ITF_LOG_PADRON_IMPUESTOS (COD_IMPUESTO, PERIODO_PADRON, COD_CLIENTE, ID_PERSONA, FECHA_PROCESO, FECHA_EJECUCION, CONDICION, ALICUOTA)
				 		VALUES (''09'', @perParam, @codCli, @personaMasGravosa, CONVERT(VARCHAR(8), (SELECT FECHAPROCESO FROM PARAMETROS (NOLOCK)), 112), CONVERT(VARCHAR(8), (SELECT FECHAPROCESO FROM PARAMETROS (NOLOCK)), 112) , @condicionMax, @alicuotaMax);
			   		
			   	 	UPDATE CLI_CLIENTES SET IIBB_CORRIENTES_ALI = @alicuotaMax, IIBB_CORRIENTES_RECAUD = @condicionMax  WHERE CODIGOCLIENTE = @codCli;
				 	
				 	INSERT INTO CON_BITACORA_IMPUESTOS (JTS_NOVEDAD, TIPO_NOVEDAD, OPERACION_TOPAZ, FECHA_PROCESO, HORA, ASIENTO, COD_USUARIO, ARCHIVO_PADRON, NUM_CERTIFICADO, F_EMISION, SUCURSAL, ID_CLIENTE, ID_PERSONA, TIPO_ID, CUIT, TIPO_CARGO_IMPOSITIVO, TABLA_CARGOS_IMPUESTOS, ID_CARGO_IMPUESTO, CONDICION, VALOR_EXCLUSION, ALICUOTA, VALOR_ALICUOTA_IIBB, FECHA_INICIO, FECHA_FIN, COMENTARIOS, CBU)
						VALUES (ISNULL((SELECT MAX(JTS_NOVEDAD)+1 FROM CON_BITACORA_IMPUESTOS (NOLOCK)),1), '''', 0,(SELECT FECHAPROCESO FROM PARAMETROS (NOLOCK)), concat(DATEPART(HOUR, GETDATE()),'':'', DATEPART(MINUTE, GETDATE()),'':'',DATEPART(SECOND, GETDATE())), 0, ''ES'', '''', '''', NULL, 1, @codCli , @numeroPersona  , '''', @cuit, 0, NULL, NULL, @recaudAux , 0, '''', @alicuota , '''', NULL, '''', ''''); 
		  		 END
		  		 
			  	
			FETCH NEXT FROM cursorRep INTO @codCli
			END --Fin del WHILE    	
			CLOSE cursorRep --Cerrar el CURSOR cli
			DEALLOCATE cursorRep
		END
		
		
		
		-------------------------------
	  
  
   	FETCH NEXT FROM cursorOk INTO @cuit
   	END --Fin del WHILE

    	
CLOSE cursorOk --Cerrar el CURSOR ok
DEALLOCATE cursorOk


--recorro padron nuevo
DECLARE cursorAux CURSOR FOR --Declarar el CURSOR aux
SELECT REGISTRO
FROM ITF_PADRON_IMPUESTOS_AUX 
OPEN cursorAux
    FETCH NEXT FROM cursorAux INTO @reg
 
    WHILE @@FETCH_STATUS = 0 
    BEGIN
    	SET @cuit = substring(@reg, 1,11);
    	SET @razonSocial = substring(@reg, 12,44);
    	SET @periodo = substring(@reg, 56,6);
    	SET @alicuota = CAST(substring(@reg, 62,6) AS NUMERIC)/1000000;
    	
        SET @recaudAux = (SELECT CASE WHEN @alicuota = 0 THEN ''EX'' ELSE ''AC'' END);
        
        SET @numeroPersona = 0;
        SELECT @numeroPersona = NUMEROPERSONAFJ FROM CLI_DocumentosPFPJ WHERE NUMERODOCUMENTO = @cuit;

     	--caso base
   		IF(@cantImp = 0) INSERT INTO ITF_PADRON_IMPUESTOS VALUES (@cuit,@razonSocial, @periodo,@alicuota); 

		SET @vinoEnPadron  = 0;
		SET @alicuotaVieja = 0;
		
		IF(@cantImp <> 0)
			SELECT @vinoEnPadron = COUNT(*), @alicuotaVieja = alicuota 
			FROM ITF_PADRON_IMPUESTOS 
			WHERE cuit = @cuit 
			AND CAST(CONCAT(SUBSTRING(PERIODO_ARCHIVO,3,4),SUBSTRING(PERIODO_ARCHIVO,1,2),''01'') AS DATETIME) = @periodoAcomparar 
			GROUP BY ALICUOTA;
		
		
		--no hubieron cambios individuales respecto al mes anterior
		IF (@vinoEnPadron > 0 AND @alicuotaVieja = @alicuota)
			UPDATE ITF_PADRON_IMPUESTOS_AUX SET AFECTA_CLIENTE = ''N'' WHERE substring(REGISTRO, 1,11) = @cuit;
			
     	ELSE --hubieron cambios, van a la bitacora con cod_cliente = 0     		
     	   INSERT INTO CON_BITACORA_IMPUESTOS (JTS_NOVEDAD, TIPO_NOVEDAD, OPERACION_TOPAZ, FECHA_PROCESO, HORA, ASIENTO, COD_USUARIO, ARCHIVO_PADRON, NUM_CERTIFICADO, F_EMISION, SUCURSAL, ID_CLIENTE, ID_PERSONA, TIPO_ID, CUIT, TIPO_CARGO_IMPOSITIVO, TABLA_CARGOS_IMPUESTOS, ID_CARGO_IMPUESTO, CONDICION, VALOR_EXCLUSION, ALICUOTA, VALOR_ALICUOTA_IIBB, FECHA_INICIO, FECHA_FIN, COMENTARIOS, CBU)
				VALUES (ISNULL((SELECT MAX(JTS_NOVEDAD)+1 FROM CON_BITACORA_IMPUESTOS (NOLOCK)),1), '''', 0,(SELECT FECHAPROCESO FROM PARAMETROS (NOLOCK)), concat(DATEPART(HOUR, GETDATE()),'':'', DATEPART(MINUTE, GETDATE()),'':'',DATEPART(SECOND, GETDATE())), 0, ''ES'', '''', '''', NULL, 1, 0 , @numeroPersona  , ''C'', @cuit, 0, NULL, NULL, @recaudAux , 0, '''', @alicuota , '''', NULL, '''', '''');


	 	--persona fisica  
	    IF(@cuit < ''30000000000'')	    
			UPDATE CLI_PersonasFisicas SET IIBB_CORRIENTES_ALI = @alicuota , IIBB_CORRIENTES_RECAUD = @recaudAux
				FROM CLI_PersonasFisicas pf JOIN CLI_DocumentosPFPJ cliDoc ON cliDoc.NUMEROPERSONAFJ = pf.NUMEROPERSONAFISICA WHERE cliDoc.NUMERODOCUMENTO  = @cuit; 	   
  		
   	 	--persona juridica
		IF(@cuit >= ''30000000000'')
			UPDATE CLI_PERSONASJURIDICAS SET IIBB_CORRIENTES_RECAUD = @recaudAux, IIBB_CORRIENTES_ALI = @alicuota
				FROM CLI_PERSONASJURIDICAS pj JOIN CLI_DocumentosPFPJ cliDoc ON cliDoc.NUMEROPERSONAFJ = pj.NUMEROPERSONAJURIDICA WHERE cliDoc.NUMERODOCUMENTO  = @cuit;


		--solo actualizo cliente si hubo modificacion respecto al mes anterior
		IF((SELECT AFECTA_CLIENTE FROM ITF_PADRON_IMPUESTOS_AUX WHERE substring(REGISTRO, 1,11) = @cuit) = ''S'')
		BEGIN
			DECLARE cursorCli CURSOR FOR 
			SELECT DISTINCT 
				cp.CODIGOCLIENTE FROM CLI_DocumentosPFPJ pfj 
					JOIN CLI_ClientePersona cp ON pfj.NUMEROPERSONAFJ = cp.NUMEROPERSONA 
						WHERE pfj.NUMERODOCUMENTO =  @cuit AND cp.TZ_LOCK=0
			OPEN cursorCli 
			FETCH NEXT FROM cursorCli INTO @codCli
			WHILE @@FETCH_STATUS = 0 
			BEGIN
			
			   

 			SELECT TOP 1 @personaMasGravosa = persona, @alicuotaMax = alicuotaMax, @condicionMax = condicion  FROM --necesito quedarme con el numero de persona para guardar el log y tambien con la max alicuota

					(
					SELECT b.NUMEROPERSONAFISICA AS persona, b.IIBB_CORRIENTES_ALI AS alicuotaMax , b.IIBB_CORRIENTES_RECAUD AS condicion FROM 
					CLI_ClientePersona a 
					JOIN CLI_PERSONASFISICAS b ON a.NUMEROPERSONA = b.NUMEROPERSONAFISICA 
						WHERE a.TZ_LOCK = 0 AND a.TZ_LOCK = 0 AND a.CODIGOCLIENTE = @codCli
					UNION ALL 
					SELECT 	j.NUMEROPERSONAJURIDICA AS persona , j.IIBB_CORRIENTES_ALI AS alicuotaMax, j.IIBB_CORRIENTES_RECAUD AS condicion FROM 
					CLI_ClientePersona a 
					JOIN CLI_PERSONASJURIDICAS j ON a.NUMEROPERSONA = j.NUMEROPERSONAJURIDICA 
						WHERE a.TZ_LOCK = 0 AND j.TZ_LOCK = 0 AND  a.CODIGOCLIENTE = @codCli
					) AS xd
					ORDER BY alicuotaMax DESC
								 
	  		   					   	 
			   	 SET @actualizaCli = (SELECT CASE WHEN IIBB_CORRIENTES_ALI = @alicuotaMax THEN ''N'' ELSE ''S'' END FROM CLI_CLIENTES WHERE CODIGOCLIENTE = @codCli);
			   	 
			   	 IF(@actualizaCli = ''S'') --guardo en la bitacora solo si hubieron cambios
			   	 BEGIN				   	 
			   	 	INSERT INTO ITF_LOG_PADRON_IMPUESTOS (COD_IMPUESTO, PERIODO_PADRON, COD_CLIENTE, ID_PERSONA, FECHA_PROCESO, FECHA_EJECUCION, CONDICION, ALICUOTA)
				 		VALUES (''09'', @perParam, @codCli, @personaMasGravosa, CONVERT(VARCHAR(8), (SELECT FECHAPROCESO FROM PARAMETROS (NOLOCK)), 112), CONVERT(VARCHAR(8), (SELECT FECHAPROCESO FROM PARAMETROS (NOLOCK)), 112) , @condicionMax, @alicuotaMax);
			   		
			   	 	UPDATE CLI_CLIENTES SET IIBB_CORRIENTES_ALI = @alicuotaMax, IIBB_CORRIENTES_RECAUD = @condicionMax  WHERE CODIGOCLIENTE = @codCli;
				 	
				 	INSERT INTO CON_BITACORA_IMPUESTOS (JTS_NOVEDAD, TIPO_NOVEDAD, OPERACION_TOPAZ, FECHA_PROCESO, HORA, ASIENTO, COD_USUARIO, ARCHIVO_PADRON, NUM_CERTIFICADO, F_EMISION, SUCURSAL, ID_CLIENTE, ID_PERSONA, TIPO_ID, CUIT, TIPO_CARGO_IMPOSITIVO, TABLA_CARGOS_IMPUESTOS, ID_CARGO_IMPUESTO, CONDICION, VALOR_EXCLUSION, ALICUOTA, VALOR_ALICUOTA_IIBB, FECHA_INICIO, FECHA_FIN, COMENTARIOS, CBU)
						VALUES (ISNULL((SELECT MAX(JTS_NOVEDAD)+1 FROM CON_BITACORA_IMPUESTOS (NOLOCK)),1), '''', 0,(SELECT FECHAPROCESO FROM PARAMETROS (NOLOCK)), concat(DATEPART(HOUR, GETDATE()),'':'', DATEPART(MINUTE, GETDATE()),'':'',DATEPART(SECOND, GETDATE())), 0, ''ES'', '''', '''', NULL, 1, @codCli , @numeroPersona  , '''', @cuit, 0, NULL, NULL, @recaudAux , 0, '''', @alicuota , '''', NULL, '''', ''''); 
		  		 END
		  		 
			  	
			FETCH NEXT FROM cursorCli INTO @codCli
			END --Fin del WHILE    	
			CLOSE cursorCli --Cerrar el CURSOR cli
			DEALLOCATE cursorCli
		END
		
	
	--inserto en el padron
	IF(@cantImp <> 0 AND @vinoEnPadron = 0)
  		INSERT INTO ITF_PADRON_IMPUESTOS VALUES (@cuit, @razonSocial, @periodo, @alicuota);  
	
	IF(@cantImp <> 0 AND @vinoEnPadron > 0)
	  UPDATE ITF_PADRON_IMPUESTOS
	  SET RAZON_SOCIAL = @razonSocial,
	    ALICUOTA = @alicuota
	  WHERE CUIT = @cuit
	    AND PERIODO_ARCHIVO = @periodo
	    
   	FETCH NEXT FROM cursorAux INTO @reg
   	END --Fin del WHILE
   
CLOSE cursorAux --Cerrar el CURSOR
DEALLOCATE cursorAux 

--borro los que estan fuera del rango de 6 meses para atras
DELETE FROM ITF_PADRON_IMPUESTOS 
	WHERE CAST(CONCAT(SUBSTRING(PERIODO_ARCHIVO,3,4),SUBSTRING(PERIODO_ARCHIVO,1,2),''01'') AS DATETIME) 
	NOT BETWEEN dateadd(month, -6, CAST(CONCAT(SUBSTRING(@perParam,3,4),SUBSTRING(@perParam,1,2),''01'') AS DATETIME)) 
	AND CAST(CONCAT(SUBSTRING(@perParam,3,4),SUBSTRING(@perParam,1,2),''01'') AS DATETIME);



END
')