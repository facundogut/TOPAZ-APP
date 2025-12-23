EXECUTE('
DROP PROCEDURE IF EXISTS [dbo].[SP_COMARB_PADRON]
')
EXECUTE('
CREATE PROCEDURE [dbo].[SP_COMARB_PADRON] 
 	@perParam VARCHAR(6),
 	@reproceso VARCHAR(1) --mostrar error en caso de que la fecha en el padron no sea la misma que la fecha proceso
AS


BEGIN

DECLARE 
@fecha DATETIME = CONVERT(DATETIME, (SELECT FECHAPROCESO FROM PARAMETROS), 103),
@periodoActual DATETIME = CAST(CONCAT(@perParam,''01'') AS DATETIME);

DECLARE @anio INT = (SELECT CASE WHEN @reproceso = ''S'' THEN YEAR(dateadd(month,0,@periodoActual)) ELSE YEAR(dateadd(month,-1,@periodoActual)) END),
@mes INT = (SELECT CASE WHEN @reproceso = ''S'' THEN MONTH(dateadd(month,0,@periodoActual)) ELSE MONTH(dateadd(month,-1,@periodoActual)) END);

--var generales
DECLARE 
@id NUMERIC(20), 
@reg VARCHAR(70),

@cantImp INT = (SELECT COUNT(*) FROM ITF_COMARB_PADRON), --caso base, si es 0 solo hay que grabar porque es la primer ejecucion y no se compara

@codCli NUMERIC(20),
@cuit VARCHAR(11),
@cuitAux VARCHAR(11),
@razonSocial VARCHAR(44), 
@periodo VARCHAR(6), 
@alicuota VARCHAR(6),
@crc_contrib VARCHAR(2),
@letraAlicuota VARCHAR(1),
@periodoApli VARCHAR(8),
@periodo_aplicacion  VARCHAR(8),
@jurisdiccion VARCHAR (3),
@actualizaCliSir VARCHAR(1);

--var auxiliares
DECLARE 
@letraAli VARCHAR(1), 
@letraAlicuota_Aux VARCHAR(1), 
@letraAlicuotaVIEJA VARCHAR(1),
@letraAlicuotaMAX VARCHAR(1),
@vinoEnPadron INT,
@numeroPerCuit NUMERIC(12),  

@personaMasGravosaSircreb NUMERIC(12), 
@letraAlicuotaPersonaMAX VARCHAR(1),

@numeroPersona NUMERIC(20), 
@numeroCliente NUMERIC(20),

@TEST VARCHAR(2);

--comparo para ver que registros no vinieron en el padron
DECLARE cursorOk CURSOR FOR 
SELECT DISTINCT cuit 
FROM ITF_COMARB_PADRON 
WHERE @anio = YEAR(CAST(CONCAT(PERIODO_APLICACION,''01'') AS DATETIME)) 
AND @mes = MONTH(CAST(CONCAT(PERIODO_APLICACION,''01'') AS DATETIME)) 
OPEN cursorOk
    FETCH NEXT FROM cursorOk INTO @cuit
    WHILE @@FETCH_STATUS = 0 
    BEGIN
  		
    	SELECT @vinoEnPadron=COUNT(*)
    	FROM ITF_COMARB_PADRON_IMPUESTOS_AUX WHERE cuit = @cuit ;

    	IF @vinoEnPadron>0 
  		   	BEGIN   	
    		SET @letraAli = (SELECT LETRA_ALICUOTA FROM ITF_COMARB_PADRON_IMPUESTOS_AUX WHERE cuit = @cuit);       
     		END
     	ELSE 
     		BEGIN		
    	    SET @letraAli = ''''      
   			END

    	SET @numeroPersona = 0;
    	SET @numeroCliente = 0 ;
    			
		--persona fisica  
	    IF(@cuit < ''30000000000'')	    
			UPDATE CLI_PersonasFisicas 
			SET SIRCREB = @letraAli 
			FROM CLI_PersonasFisicas pf 
			JOIN CLI_DocumentosPFPJ cliDoc ON cliDoc.NUMEROPERSONAFJ = pf.NUMEROPERSONAFISICA 
			WHERE cliDoc.NUMERODOCUMENTO  = @cuit 	   
			AND cliDoc.TZ_LOCK=0;
			
  		
   	 	--persona juridica
		IF(@cuit >= ''30000000000'')
			UPDATE CLI_PERSONASJURIDICAS 
			SET SIRCREB=@letraAli
			FROM CLI_PERSONASJURIDICAS pj 
			JOIN CLI_DocumentosPFPJ cliDoc ON cliDoc.NUMEROPERSONAFJ = pj.NUMEROPERSONAJURIDICA 
			WHERE cliDoc.NUMERODOCUMENTO  = @cuit
		 	AND cliDoc.TZ_LOCK=0;
		 	
		SET @numeroPerCuit = (SELECT TOP 1 NUMEROPERSONAFJ FROM VW_CLI_DOCUMENTOSPFPJ WHERE NUMERODOCUMENTO=@cuit);
		
		
	  	IF (@numeroPerCuit IS NOT NULL AND @numeroPerCuit>0)
		INSERT INTO CON_BITACORA_IMPUESTOS (JTS_NOVEDAD, TIPO_NOVEDAD, OPERACION_TOPAZ, FECHA_PROCESO, HORA, ASIENTO, COD_USUARIO, ARCHIVO_PADRON, NUM_CERTIFICADO, F_EMISION, SUCURSAL, ID_CLIENTE, ID_PERSONA, TIPO_ID, CUIT, TIPO_CARGO_IMPOSITIVO, TABLA_CARGOS_IMPUESTOS, ID_CARGO_IMPUESTO, CONDICION, VALOR_EXCLUSION, ALICUOTA, VALOR_ALICUOTA_IIBB, FECHA_INICIO, FECHA_FIN, COMENTARIOS, CBU)
		VALUES (ISNULL((SELECT MAX(JTS_NOVEDAD)+1 
		FROM CON_BITACORA_IMPUESTOS (NOLOCK)),1),'''',0, (SELECT FECHAPROCESO FROM PARAMETROS (NOLOCK)), concat(DATEPART(HOUR, GETDATE()), '':'', DATEPART(MINUTE, GETDATE()),'':'',DATEPART(SECOND, GETDATE())),0,''ES'','''','''',NULL,1,0,@numeroPerCuit,''C'',@cuit,5,NULL,NULL,@letraAli,0,'''', 0,@periodoActual, NULL,'''','''');
		
		   
    
        BEGIN

			
			DECLARE cursorCli1 CURSOR FOR 
			SELECT DISTINCT 
				cp.CODIGOCLIENTE FROM CLI_DocumentosPFPJ pfj 
					JOIN CLI_ClientePersona cp ON pfj.NUMEROPERSONAFJ = cp.NUMEROPERSONA 
						WHERE pfj.NUMERODOCUMENTO =  @cuit
			OPEN cursorCli1 
			FETCH NEXT FROM cursorCli1 INTO @codCli
			WHILE @@FETCH_STATUS = 0 
			BEGIN
				SELECT TOP 1 @personaMasGravosaSircreb =persona, @letraAlicuotaPersonaMAX=letraAlicuotaMAX  FROM --necesito quedarme con el numero de persona para guardar el log y tambien con la max alicuota
				(
				SELECT b.NUMEROPERSONAFISICA AS persona, 
				b.SIRCREB  AS letraAlicuotaMAX 
				FROM CLI_ClientePersona a 
				JOIN CLI_PERSONASFISICAS b 
				ON a.NUMEROPERSONA = b.NUMEROPERSONAFISICA 
				WHERE a.TZ_LOCK = 0 
				AND a.TZ_LOCK = 0 
				AND  a.CODIGOCLIENTE = @codCli
				
				UNION ALL 
				
				SELECT j.NUMEROPERSONAJURIDICA AS persona ,  
				j.SIRCREB  AS letraAlicuotaMAX  
				FROM CLI_ClientePersona a 
				JOIN CLI_PERSONASJURIDICAS j 
				ON a.NUMEROPERSONA = j.NUMEROPERSONAJURIDICA 
				WHERE a.TZ_LOCK = 0 
				AND j.TZ_LOCK = 0  
				AND  a.CODIGOCLIENTE = @codCli) AS xd
				ORDER BY letraAlicuotaMAX DESC
				
				SET @actualizaCliSir = (SELECT   CASE 
										WHEN SIRCREB  = @letraAlicuotaMAX THEN ''N'' 
										ELSE ''S'' END FROM CLI_CLIENTES 
										WHERE CODIGOCLIENTE = @codCli);
				
			   	IF(@actualizaCliSir = ''S'') --guardo en la bitacora solo si hubieron cambios
			   	 BEGIN				   	 
			   	 	INSERT INTO ITF_LOG_PADRON_IMPUESTOS (COD_IMPUESTO, PERIODO_PADRON, COD_CLIENTE, ID_PERSONA, FECHA_PROCESO, FECHA_EJECUCION, CONDICION, ALICUOTA)
				 		VALUES (''05'', @perParam, @codCli, @personaMasGravosaSircreb, CONVERT(VARCHAR(8), (SELECT FECHAPROCESO FROM PARAMETROS (NOLOCK)), 112), CONVERT(VARCHAR(8), (SELECT FECHAPROCESO FROM PARAMETROS (NOLOCK)), 112) , @letraAlicuotaPersonaMAX, 0);
			   	 	UPDATE CLI_CLIENTES SET SIRCREB = @letraAlicuotaPersonaMAX WHERE CODIGOCLIENTE = @codCli;
					
					INSERT INTO CON_BITACORA_IMPUESTOS (JTS_NOVEDAD, TIPO_NOVEDAD, OPERACION_TOPAZ, FECHA_PROCESO, HORA, ASIENTO, COD_USUARIO, ARCHIVO_PADRON, NUM_CERTIFICADO, F_EMISION, SUCURSAL, ID_CLIENTE, ID_PERSONA, TIPO_ID, CUIT, TIPO_CARGO_IMPOSITIVO, TABLA_CARGOS_IMPUESTOS, ID_CARGO_IMPUESTO, CONDICION, VALOR_EXCLUSION, ALICUOTA, VALOR_ALICUOTA_IIBB, FECHA_INICIO, FECHA_FIN, COMENTARIOS, CBU)
		   			VALUES (ISNULL((SELECT MAX(JTS_NOVEDAD)+1 
		   			FROM CON_BITACORA_IMPUESTOS (NOLOCK)),1),'''',0, (SELECT FECHAPROCESO FROM PARAMETROS (NOLOCK)), concat(DATEPART(HOUR, GETDATE()), '':'', DATEPART(MINUTE, GETDATE()),'':'',DATEPART(SECOND, GETDATE())),0,''ES'','''','''',NULL,1,@codCli,@personaMasGravosaSircreb,''C'',@cuit,5,NULL,NULL,@letraAlicuotaPersonaMAX,0,'''', 0,@periodoActual, NULL,'''','''');
		   
				 END


				
			FETCH NEXT FROM cursorCli1 INTO @codCli
			END --Fin del WHILE    	
			CLOSE cursorCli1 --Cerrar el CURSOR cli
			DEALLOCATE cursorCli1
		END

    
   	FETCH NEXT FROM cursorOk INTO @cuit
   	END --Fin del WHILE

    	
CLOSE cursorOk --Cerrar el CURSOR ok
DEALLOCATE cursorOk


--recorro padron nuevo
DECLARE cursorAux CURSOR FOR --Declarar el CURSOR aux
SELECT ID
FROM ITF_COMARB_PADRON_IMPUESTOS_AUX 
WHERE YEAR(@periodoActual) = YEAR(CAST(CONCAT(PERIODO_APLICACION,''01'') AS DATETIME)) 
AND  MONTH(@periodoActual) = MONTH(CAST(CONCAT(PERIODO_APLICACION,''01'') AS DATETIME))

OPEN cursorAux
    FETCH NEXT FROM cursorAux INTO @id
 
    WHILE @@FETCH_STATUS = 0 
    BEGIN
		SELECT 
		@periodo_aplicacion=PERIODO_APLICACION,
		@cuitAux=CUIT, 
		@razonSocial=RAZON_SOCIAL,
		@jurisdiccion=JURISDICCION,
		@periodoApli=PERIODO_APLICACION,
		@crc_contrib=CRC_CONTRIBUYENTE,
		@letraAlicuota=LETRA_ALICUOTA
		FROM ITF_COMARB_PADRON_IMPUESTOS_AUX WHERE ID = @id;
		
        SET @letraAlicuota_Aux = @letraAlicuota;

     	--caso base
   		IF(@cantImp = 0) 
		INSERT INTO ITF_COMARB_PADRON VALUES (@cuitAux,@razonSocial, @jurisdiccion,@periodoApli,@crc_contrib,@letraAlicuota); 

		SET @vinoEnPadron  = 0;
		SET @letraAlicuotaVIEJA = '''';

		SELECT @vinoEnPadron = COUNT(*), 
		@letraAlicuotaVIEJA= LETRA_ALICUOTA 
		FROM ITF_COMARB_PADRON 
		WHERE cuit = @cuitAux 
		AND YEAR(dateadd(month,-1,@periodoActual)) = YEAR(CAST(CONCAT(PERIODO_APLICACION,''01'') AS DATETIME)) 
		AND MONTH(dateadd(month,-1,@periodoActual)) = MONTH(CAST(CONCAT(PERIODO_APLICACION,''01'') AS DATETIME)) 
		GROUP BY LETRA_ALICUOTA;
		
		--PRINT @vinoEnPadron;
		--PRINT @cuitAux;

    	SET @numeroPersona = 0;
    	SET @numeroCliente = 0 ;
		--no hubieron cambios respecto al mes anterior
		IF (@vinoEnPadron > 0 AND @letraAlicuotaVIEJA = @letraAlicuota)
			UPDATE ITF_COMARB_PADRON_IMPUESTOS_AUX SET AFECTA_CLIENTE = ''N'' WHERE cuit = @cuitAux;
		ELSE IF (@vinoEnPadron > 0 AND @letraAlicuotaVIEJA != @letraAlicuota)
			UPDATE ITF_COMARB_PADRON_IMPUESTOS_AUX SET AFECTA_CLIENTE = ''S'' WHERE cuit = @cuitAux;
		ELSE --hubieron cambios, van a la bitacora con cod_cliente = 0     
		 BEGIN		
     	   INSERT INTO CON_BITACORA_IMPUESTOS (JTS_NOVEDAD, TIPO_NOVEDAD, OPERACION_TOPAZ, FECHA_PROCESO, HORA, ASIENTO, COD_USUARIO, ARCHIVO_PADRON, NUM_CERTIFICADO, F_EMISION, SUCURSAL, ID_CLIENTE, ID_PERSONA, TIPO_ID, CUIT, TIPO_CARGO_IMPOSITIVO, TABLA_CARGOS_IMPUESTOS, ID_CARGO_IMPUESTO, CONDICION, VALOR_EXCLUSION, ALICUOTA, VALOR_ALICUOTA_IIBB, FECHA_INICIO, FECHA_FIN, COMENTARIOS, CBU)
		   VALUES (ISNULL((SELECT MAX(JTS_NOVEDAD)+1 
		   FROM CON_BITACORA_IMPUESTOS (NOLOCK)),1),'''',0, (SELECT FECHAPROCESO FROM PARAMETROS (NOLOCK)), concat(DATEPART(HOUR, GETDATE()), '':'', DATEPART(MINUTE, GETDATE()),'':'',DATEPART(SECOND, GETDATE())),0,''ES'','''','''',NULL,1,0 ,@numeroPersona,''C'',@cuitAux,5,NULL,NULL,@letraAlicuota_Aux,0,'''', 0,CAST(CONCAT(@periodoApli,''01'') AS DATETIME), NULL,'''','''');
		   
		   UPDATE ITF_COMARB_PADRON_IMPUESTOS_AUX SET AFECTA_CLIENTE = ''S'' WHERE cuit = @cuitAux;
		 END
		--persona fisica  
	    IF(@cuitAux < ''30000000000'')	    
			UPDATE CLI_PersonasFisicas 
			SET SIRCREB = @letraAlicuota_Aux 
			FROM CLI_PersonasFisicas pf 
			JOIN CLI_DocumentosPFPJ cliDoc ON cliDoc.NUMEROPERSONAFJ = pf.NUMEROPERSONAFISICA 
			WHERE cliDoc.NUMERODOCUMENTO  = @cuitAux   
  			AND cliDoc.TZ_LOCK=0;
   	 	--persona juridica
		IF(@cuitAux >= ''30000000000'')
			UPDATE CLI_PERSONASJURIDICAS 
			SET SIRCREB=@letraAlicuota_Aux
			FROM CLI_PERSONASJURIDICAS pj 
			JOIN CLI_DocumentosPFPJ cliDoc ON cliDoc.NUMEROPERSONAFJ = pj.NUMEROPERSONAJURIDICA 
			WHERE cliDoc.NUMERODOCUMENTO  = @cuitAux
			AND cliDoc.TZ_LOCK=0;

	   
		--solo actualizo cliente si hubo modificacion respecto al mes anterior
		IF((SELECT AFECTA_CLIENTE FROM ITF_COMARB_PADRON_IMPUESTOS_AUX WHERE cuit = @cuitAux) = ''S'')
		
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
				SELECT TOP 1 @personaMasGravosaSircreb =persona, @letraAlicuotaPersonaMAX=letraAlicuotaMAX  FROM --necesito quedarme con el numero de persona para guardar el log y tambien con la max alicuota
				(
				SELECT b.NUMEROPERSONAFISICA AS persona, 
				b.SIRCREB  AS letraAlicuotaMAX 
				FROM CLI_ClientePersona a 
				JOIN CLI_PERSONASFISICAS b 
				ON a.NUMEROPERSONA = b.NUMEROPERSONAFISICA 
				WHERE a.TZ_LOCK = 0 
				AND a.TZ_LOCK = 0 
				AND  a.CODIGOCLIENTE = @codCli
				
				UNION ALL 
				
				SELECT j.NUMEROPERSONAJURIDICA AS persona ,  
				j.SIRCREB  AS letraAlicuotaMAX  
				FROM CLI_ClientePersona a 
				JOIN CLI_PERSONASJURIDICAS j 
				ON a.NUMEROPERSONA = j.NUMEROPERSONAJURIDICA 
				WHERE a.TZ_LOCK = 0 
				AND j.TZ_LOCK = 0  
				AND  a.CODIGOCLIENTE = @codCli) AS xd
				ORDER BY letraAlicuotaMAX DESC
				
				SET @actualizaCliSir = (SELECT   CASE 
										WHEN SIRCREB  = @letraAlicuotaMAX THEN ''N'' 
										ELSE ''S'' END FROM CLI_CLIENTES 
										WHERE CODIGOCLIENTE = @codCli);
				--PRINT @actualizaCliSir;
			   	IF(@actualizaCliSir = ''S'') --guardo en la bitacora solo si hubieron cambios
			   	 BEGIN				   	 
			   	 	INSERT INTO ITF_LOG_PADRON_IMPUESTOS (COD_IMPUESTO, PERIODO_PADRON, COD_CLIENTE, ID_PERSONA, FECHA_PROCESO, FECHA_EJECUCION, CONDICION, ALICUOTA)
				 		VALUES (''05'', @perParam, @codCli, @personaMasGravosaSircreb, CONVERT(VARCHAR(8), (SELECT FECHAPROCESO FROM PARAMETROS (NOLOCK)), 112), CONVERT(VARCHAR(8), (SELECT FECHAPROCESO FROM PARAMETROS (NOLOCK)), 112) , @letraAlicuotaPersonaMAX, 0);
			   	 	UPDATE CLI_CLIENTES SET SIRCREB = @letraAlicuotaPersonaMAX WHERE CODIGOCLIENTE = @codCli;
					
					INSERT INTO CON_BITACORA_IMPUESTOS (JTS_NOVEDAD, TIPO_NOVEDAD, OPERACION_TOPAZ, FECHA_PROCESO, HORA, ASIENTO, COD_USUARIO, ARCHIVO_PADRON, NUM_CERTIFICADO, F_EMISION, SUCURSAL, ID_CLIENTE, ID_PERSONA, TIPO_ID, CUIT, TIPO_CARGO_IMPOSITIVO, TABLA_CARGOS_IMPUESTOS, ID_CARGO_IMPUESTO, CONDICION, VALOR_EXCLUSION, ALICUOTA, VALOR_ALICUOTA_IIBB, FECHA_INICIO, FECHA_FIN, COMENTARIOS, CBU)
		   			VALUES (ISNULL((SELECT MAX(JTS_NOVEDAD)+1 
		   			FROM CON_BITACORA_IMPUESTOS (NOLOCK)),1),'''',0, (SELECT FECHAPROCESO FROM PARAMETROS (NOLOCK)), concat(DATEPART(HOUR, GETDATE()), '':'', DATEPART(MINUTE, GETDATE()),'':'',DATEPART(SECOND, GETDATE())),0,''ES'','''','''',NULL,1,@codCli,@personaMasGravosaSircreb,''C'',@cuit,5,NULL,NULL,@letraAlicuotaPersonaMAX,0,'''', 0,@periodoActual, NULL,'''','''');
		   
				END

				
			FETCH NEXT FROM cursorCli INTO @codCli
			END --Fin del WHILE    	
			CLOSE cursorCli --Cerrar el CURSOR cli
			DEALLOCATE cursorCli
		END
		
	
	--inserto en el padron
   IF(@cantImp <> 0)  
	  INSERT INTO ITF_COMARB_PADRON VALUES (@cuitAux, @razonSocial,@jurisdiccion,@periodo_aplicacion ,@crc_contrib,@letraAlicuota); 
   FETCH NEXT FROM cursorAux INTO @id
   END --Fin del WHILE
   
CLOSE cursorAux --Cerrar el CURSOR
DEALLOCATE cursorAux 


--Calcular la fecha límite	
DECLARE @FechaLimite VARCHAR(8);
DECLARE @perParDATATIME DATETIME = CAST(CONCAT(@perParam,''01'') AS DATETIME);
SET @FechaLimite = CONVERT(VARCHAR(8), DATEADD(MONTH, -6, @perParDATATIME),112);

-- Eliminar los registros anteriores a la fecha límite
DELETE FROM ITF_COMARB_PADRON
WHERE CAST(CONCAT(PERIODO_APLICACION,''01'') AS DATETIME) < CONVERT(DATE, @FechaLimite, 112);

END
')
