execute('DROP TABLE IF EXISTS dbo.ITF_AFIP_RG17_INCONSISTENCIAS


CREATE TABLE dbo.ITF_AFIP_RG17_INCONSISTENCIAS
	(
	ID               INT IDENTITY NOT NULL,
	COD_CLIENTE      NUMERIC (11),
	NRO_PERSONA      NUMERIC (11),
	CUIT             VARCHAR (11),
	RAZON_SOCIAL     VARCHAR (80),
	CONDICION_IVA    VARCHAR (2),
	TIPO_CERTIFICADO VARCHAR (10),
	PORCENTAJE       VARCHAR (10),
	FECHA_DESDE      VARCHAR (10),
	FECHA_HASTA      VARCHAR (10),
	COMENTARIO       VARCHAR (200),
	CONSTRAINT PK_AFIP_INCONSIS2 PRIMARY KEY (ID)
	)

');

execute('DROP TABLE IF EXISTS dbo.ITF_AFIP_RG18_INCONSISTENCIAS


CREATE TABLE dbo.ITF_AFIP_RG18_INCONSISTENCIAS
	(
	ID               INT IDENTITY NOT NULL,
	COD_CLIENTE      NUMERIC (11),
	NRO_PERSONA      NUMERIC (11),
	CUIT             VARCHAR (11),
	RAZON_SOCIAL     VARCHAR (80),
	CONDICION_IVA    VARCHAR (2),
	TIPO_CERTIFICADO VARCHAR (10),
	PORCENTAJE       VARCHAR (10),
	FECHA_DESDE      VARCHAR (10),
	FECHA_HASTA      VARCHAR (10),
	COMENTARIO       VARCHAR (200),
	CONSTRAINT PK_AFIP_INCONSIS PRIMARY KEY (ID)
	)');
execute('CREATE OR ALTER     	PROCEDURE dbo.[SP_AFIP_IVA_RG17]
--Fabio Menendez: 13/06/2023
--JI: 08/09/2023
	@periodo VARCHAR(11),
	@reproceso VARCHAR(1)
AS
BEGIN 

IF TRY_CONVERT(DATE, @periodo, 120) IS NULL OR UPPER(LTRIM(RTRIM(@reproceso))) NOT IN (''S'', ''N'')
BEGIN
    THROW 50000, ''Periodo y/o reproceso invalido.'', 1;
END	

--NUEVO BLOQUE JI 6/9/2023--
-- Damos de "baja" los certificados que estaban en el padrón anterior y no en el que se
--Esta tratando de importar

UPDATE CI_CARGOS_TARIFAS 
SET FECHA_HASTA = (SELECT FECHAPROCESO 
				     FROM PARAMETROS (nolock))
WHERE ID_CLIENTE IN (
						SELECT ID_CLIENTE
						FROM ITF_IVARG17_PERCEPCION_ULT_PADRON_AUX A
						WHERE ID_CLIENTE NOT IN (SELECT VW.CODIGOCLIENTE
						 						 FROM VW_CLIENTES_PERSONAS VW, ITF_AFIP_IVA_RG17 RG
						 						 WHERE VW.NUMERODOC=RG.CUIT
						 						 AND VW.TITULARIDAD=''T'')
					  )
					  
UPDATE CI_IMPUESTOS_TARIFAS
SET FECHA_HASTA = (SELECT FECHAPROCESO 
				     FROM PARAMETROS (nolock))
WHERE ID_CLIENTE IN (
						SELECT ID_CLIENTE
						FROM ITF_IVARG17_PERCEPCION_ULT_PADRON_AUX A
						WHERE ID_CLIENTE NOT IN (SELECT VW.CODIGOCLIENTE
						 						 FROM VW_CLIENTES_PERSONAS VW, ITF_AFIP_IVA_RG17 RG
						 						 WHERE VW.NUMERODOC=RG.CUIT
						 						 AND VW.TITULARIDAD=''T'')
					  )
					  
-- Si dimos de baja, grabar bitacora, Recomiendo el uso de la variable @@rowcount que te va a decir si realizo algun cambio

TRUNCATE TABLE ITF_IVARG17_PERCEPCION_ULT_PADRON_AUX

INSERT INTO ITF_IVARG17_PERCEPCION_ULT_PADRON_AUX (PERIODO_DESDE, 
											   	   PERIODO_HASTA, 
											   	   PORCENTAJE, 
											   	   ID_CLIENTE)
SELECT RG.PERIODO_DESDE, 
	   RG.PERIODO_HASTA, 
	   RG.PORCENTAJE, 
	   VW.CODIGOCLIENTE
FROM VW_CLIENTES_PERSONAS VW, ITF_AFIP_IVA_RG17 RG
WHERE VW.NUMERODOC=RG.CUIT
AND VW.TITULARIDAD=''T''
--HASTA ACA--

CREATE TABLE #ClientesTmp3 (
    CODIGOCLIENTE NUMERIC(12),
    NUMEROPERSONA NUMERIC(12)
);  

SET @periodo = REPLACE(@periodo, ''-'', '''');

--Logica de Reproceso
IF @reproceso=''S''
BEGIN

DELETE FROM ITF_LOG_CARGOS_IMPUESTOS 
WHERE FECHA_EJECUCION=@periodo ;

--CARGOS--
INSERT INTO dbo.CON_BITACORA_IMPUESTOS (JTS_NOVEDAD, 
										TIPO_NOVEDAD, 
										FECHA_PROCESO, 
										HORA, 
										ID_CLIENTE, 
										ID_PERSONA,
										TIPO_ID, 
										CUIT, 
										TIPO_CARGO_IMPOSITIVO, 
										VALOR_EXCLUSION, 
										FECHA_INICIO, 
										FECHA_FIN)
								SELECT ISNULL((SELECT MAX(JTS_NOVEDAD) FROM CON_BITACORA_IMPUESTOS),0)+ (ROW_NUMBER() OVER (ORDER BY c.ID_CARGO)), 
									   ''B'', 
									   (SELECT FECHAPROCESO FROM PARAMETROS (NOLOCK)), 
									   (select convert(varchar,getdate(),108)), 
									   c.ID_CLIENTE, 
									   w.NUMEROPERSONA, 
									   ''C'', 
									   w.NUMERODOC, 
									   (SELECT TIPOCARGO 
									    FROM  VW_CARGOS_IMPUESTOS (nolock) 
									    WHERE ID_CARGO=c.ID_CARGO ), 
									   c.TASA, 
									   c.FECHA_DESDE, 
									   (SELECT FECHAPROCESO 
									   	FROM PARAMETROS)
FROM CI_CARGOS_TARIFAS c LEFT JOIN VW_CLIENTES_PERSONAS w ON c.ID_CLIENTE=w.CODIGOCLIENTE 
AND w.TITULARIDAD=''T''
WHERE -- c.TASA <> 0 AND COMENTE ESTO
 c.ID_CARGO IN (SELECT ID_CARGO 
				   FROM  VW_CARGOS_IMPUESTOS (nolock) )

--CARGOS--
UPDATE c 
SET c.fecha_hasta = (SELECT FECHAPROCESO 
					 FROM PARAMETROS)
FROM CI_CARGOS_TARIFAS c
WHERE c.TASA <> 0 -- OJO CON ESTO, FILTRAR POR LA FECHA HASTA
AND c.ID_CARGO IN (SELECT ID_CARGO 
				   FROM  VW_CARGOS (nolock) ) 
AND c.FECHA_HASTA>(SELECT FECHAPROCESO 
				   FROM PARAMETROS (NOLOCK))
--IMPUESTOS--
UPDATE i 
SET i.fecha_hasta = (SELECT FECHAPROCESO 
					 FROM PARAMETROS)
FROM CI_IMPUESTOS_TARIFAS i
WHERE i.TASA <> 0 -- OJO CON ESTO, FILTRAR POR LA FECHA HASTA
AND i.ID_IMPUESTO IN (SELECT ID_IMPUESTO 
					  FROM  VW_IMPUESTOS (nolock) ) 
AND I.FECHA_HASTA>(SELECT FECHAPROCESO 
				   FROM PARAMETROS (NOLOCK))

END --fin reproceso

--variables clave
DECLARE @cuit VARCHAR(11),@razonSocial VARCHAR(80), @fechaDesde DATETIME, @fechaHasta DATETIME, @porcentaje NUMERIC(7,4), @resGeneral VARCHAR(19), @tipoCertificado VARCHAR(11);

--var de cursor
DECLARE @C_idCargo NUMERIC(10), @C_descripcion VARCHAR (80), @C_tipoCargo NUMERIC(3), @C_tasa NUMERIC (4,4), @C_moneda NUMERIC(1)  ;		

--variables aux
DECLARE @codCli NUMERIC (10), @nroPersona NUMERIC(10), @condIVA VARCHAR(2);
DECLARE @inserts NUMERIC(6), @actualizados NUMERIC(6), @hayTemporales INT, @hayUpdate INT, @faltanCargos INT;


--limpio la tabla de inconsistencias(ya no se usa mas, se trunca desde kettle. J.I.)
--TRUNCATE TABLE ITF_AFIP_RG17_INCONSISTENCIAS;


DECLARE @idCount INT = 1;
--recorro padron de entrada
SELECT @cuit = CUIT, @razonSocial= RAZON_SOCIAL, @fechaDesde = PERIODO_DESDE, @fechaHasta = PERIODO_HASTA, @porcentaje = PORCENTAJE, @resGeneral = RES_GENERAL, @tipoCertificado = TIPO_CERTIFICADO
FROM ITF_AFIP_IVA_RG17 (nolock) 
WHERE ID=@idCount;

WHILE @cuit IS NOT NULL 
BEGIN	     		
  		--recorro clientes solo si la persona es titular
		INSERT INTO #ClientesTmp3 (CODIGOCLIENTE,NUMEROPERSONA)
		SELECT DISTINCT
		    cp.CODIGOCLIENTE,
		    cp.NUMEROPERSONA
		FROM CLI_DocumentosPFPJ pfj (nolock)
		JOIN CLI_ClientePersona cp (nolock) ON pfj.NUMEROPERSONAFJ = cp.NUMEROPERSONA
		WHERE cp.TZ_LOCK = 0 AND cp.TITULARIDAD = ''T'' AND pfj.NUMERODOCUMENTO = @cuit;
		
  		WHILE EXISTS (SELECT 1 FROM #ClientesTmp3)
		BEGIN
		
	    -- Obtener el siguiente registro de #ClientesTmp
	    SELECT TOP 1 @codCli = CODIGOCLIENTE, @nroPersona = NUMEROPERSONA 
	    FROM #ClientesTmp3;

			--inserto en el log 1 reg por cada tipo de cargo (2 y 3)
			INSERT INTO dbo.ITF_LOG_CARGOS_IMPUESTOS (COD_IMPUESTO,
													  PERIODO_DESDE,  
													  PERIODO_HASTA, 
													  COD_CLIENTE, 
													  ID_PERSONA, 
													  FECHA_PROCESO, 
													  FECHA_EJECUCION, 
													  CONDICION, 
													  ALICUOTA)
											   SELECT c.TIPOCARGO, 
											   		  @fechaDesde, 
											   		  @fechaHasta,
											   		  @codCli, 
											   		  @nroPersona, 
											   		  CONVERT(VARCHAR(8), (SELECT FECHAPROCESO FROM PARAMETROS (NOLOCK)), 112), 
											   		  @periodo,
											   		  '''',
											   		  (c.TASA-(c.TASA*@porcentaje/100))
			FROM VW_CARGOS_IMPUESTOS c 
			WHERE c.ID_CARGO NOT IN (SELECT ID_CARGO 
									 FROM  CI_CARGOS_TARIFAS 
									 WHERE id_cliente = @codCli  
									 AND TZ_LOCK = 0 
									 AND fecha_hasta >= (SELECT fechaproceso 
									 					 FROM PARAMETROS (nolock)) 
			AND ID_CARGO IN (SELECT ID_CARGO FROM VW_CARGOS_IMPUESTOS)) 
			AND c.ID_CARGO NOT IN (SELECT ID_CARGO 
								   FROM  CI_CARGOS_TARIFAS 
								   WHERE id_cliente = @codCli 
								   AND TASA <> 0 AND TZ_LOCK = 0 
								   AND fecha_hasta = @fechaHasta 
								   AND ID_CARGO IN (SELECT ID_CARGO FROM VW_CARGOS_IMPUESTOS))
			GROUP BY c.TIPOCARGO, c.TASA
			
			--inserto en bitacora 1 reg por cada tipo de cargo (2 y 3)
			INSERT INTO dbo.CON_BITACORA_IMPUESTOS (JTS_NOVEDAD,
													TIPO_NOVEDAD, 
													FECHA_PROCESO, 
													HORA, 
													ID_CLIENTE, 
													ID_PERSONA,
													TIPO_ID, 
													CUIT, 
													TIPO_CARGO_IMPOSITIVO, 
													VALOR_EXCLUSION, 
													FECHA_INICIO, 
													FECHA_FIN)
											 SELECT ISNULL((SELECT MAX(JTS_NOVEDAD) 
											 				FROM CON_BITACORA_IMPUESTOS),0)+ (ROW_NUMBER() OVER (ORDER BY c.TIPOCARGO)),
											 				''A'', 
											 				(SELECT FECHAPROCESO 
											 				 FROM PARAMETROS (NOLOCK)), 
											 				(select convert(varchar,getdate(),108)), 
											 				@codCli, 
											 				@nroPersona, 
											 				''C'', 
											 				@cuit, 
											 				c.TIPOCARGO, 
											 				(c.TASA-(c.TASA*@porcentaje/100)), 
											 				@fechaDesde, 
											 				@fechaHasta
			FROM VW_CARGOS_IMPUESTOS c
			WHERE c.ID_CARGO NOT IN (SELECT ID_CARGO 
									 FROM  CI_CARGOS_TARIFAS 
									 WHERE id_cliente = @codCli  
									 AND TZ_LOCK = 0 AND fecha_hasta >= (SELECT fechaproceso 
									 									 FROM PARAMETROS (nolock)) 
									 AND ID_CARGO IN (SELECT ID_CARGO 
									  				  FROM VW_CARGOS_IMPUESTOS)) 
			AND	c.ID_CARGO NOT IN (SELECT ID_CARGO 
								   FROM  CI_CARGOS_TARIFAS 
								   WHERE id_cliente = @codCli 
								   AND TASA <> 0 AND TZ_LOCK = 0 
								   AND (fecha_hasta = @fechaHasta 
								   AND TASA=((SELECT TASA 
								   			  FROM VW_CARGOS_IMPUESTOS 
								   			  WHERE ID_CARGO=c.ID_CARGO) -((SELECT TASA 
								   			  								FROM VW_CARGOS_IMPUESTOS 
								   			  								WHERE ID_CARGO=c.ID_CARGO)*@porcentaje/100)) )
								   AND ID_CARGO IN (SELECT ID_CARGO 
								   					FROM VW_CARGOS_IMPUESTOS))
			GROUP BY TIPOCARGO, TASA
			
			--Cubrimos casos donde se modifiquen valores del certificado
			--update temporales existentes			
			UPDATE c 
			SET c.fecha_hasta = @fechaHasta, 
				c.TASA = ((SELECT TASA 
						   FROM VW_CARGOS 
						   WHERE ID_CARGO=c.ID_CARGO) -((SELECT TASA 
						   								 FROM VW_CARGOS 
						   								 WHERE ID_CARGO=c.ID_CARGO)*@porcentaje/100))
			FROM CI_CARGOS_TARIFAS c
			WHERE c.id_cliente = @codCli 
			--AND c.TASA <> 0 
			AND c.TZ_LOCK = 0 
			AND (c.fecha_hasta <> @fechaHasta OR (c.TASA<> ((SELECT TASA 
															 FROM VW_CARGOS 
															 WHERE ID_CARGO=c.ID_CARGO) -((SELECT TASA 
															 							   FROM VW_CARGOS 
															 							   WHERE ID_CARGO=c.ID_CARGO)*@porcentaje/100))) ) 
			AND c.ID_CARGO IN (SELECT ID_CARGO 
							   FROM VW_CARGOS)
							   
							   
							   
							   
			UPDATE I 
			SET I.fecha_hasta = @fechaHasta, 
				I.TASA = ((SELECT TASA 
						   FROM VW_IMPUESTOS 
 						   WHERE ID_IMPUESTO=I.ID_IMPUESTO) -((SELECT TASA 
						   								 	   FROM VW_IMPUESTOS 
						   								 	   WHERE ID_IMPUESTO=I.ID_IMPUESTO)*@porcentaje/100))
			FROM CI_IMPUESTOS_TARIFAS I
			WHERE I.id_cliente = @codCli 
			--AND I.TASA <> 0 
			AND I.TZ_LOCK = 0 
			AND (I.fecha_hasta <> @fechaHasta OR (I.TASA<> ((SELECT TASA 
															 FROM VW_IMPUESTOS 
															 WHERE ID_IMPUESTO=I.ID_IMPUESTO) -((SELECT TASA 
															 							   FROM VW_IMPUESTOS 
															 							   WHERE ID_IMPUESTO=I.ID_IMPUESTO)*@porcentaje/100))) ) 
			AND I.ID_IMPUESTO IN (SELECT ID_IMPUESTO 
							   FROM VW_IMPUESTOS)	

            -- Deberiamos de grabar bitacora si algun certificado tuvo cambios.
			
			--FIN casos donde se modifiquen valores del certificado
		
		-- Casos nuevos y que no fueron actualizados en los 2 updates anteriores
		--inserto solo si fecha hasta es mayor a la fecha de proceso JI 01/09/2023-- 
		if	@fechaHasta>(SELECT fechaproceso FROM PARAMETROS)
		BEGIN
			--inserto los certificados que no tiene	
			
			--CARGOS--			 
			INSERT INTO dbo.CI_CARGOS_TARIFAS (ID_CARGO, 
											   MONEDA, 
											   ID_CLIENTE, 
											   SEGMENTO, 
											   FECHA_DESDE, 
											   FECHA_HASTA, 
											   TASA) 
										SELECT ID_CARGO, 
											   MONEDA, 
											   @codCli, 
											   segmento, 
											   @fechaDesde, 
											   @fechaHasta, 
											   (TASA-(TASA*@porcentaje/100))
												FROM VW_CARGOS 
												WHERE ID_CARGO NOT IN (SELECT ID_CARGO 
																	   FROM  CI_CARGOS_TARIFAS 
																	   WHERE id_cliente = @codCli  
																	   AND TZ_LOCK = 0  
																	   AND ID_CARGO IN (SELECT ID_CARGO 
																	   					FROM VW_CARGOS))
			--IMPUESTOS--
			INSERT INTO dbo.CI_IMPUESTOS_TARIFAS (ID_IMPUESTO, 
											   MONEDA, 
											   ID_CLIENTE, 
											   SEGMENTO, 
											   FECHA_DESDE, 
											   FECHA_HASTA, 
											   TASA) 
										SELECT ID_IMPUESTO, 
											   MONEDA, 
											   @codCli, 
											   segmento, 
											   @fechaDesde, 
											   @fechaHasta, 
											   (TASA-(TASA*@porcentaje/100))
												FROM VW_IMPUESTOS 
												WHERE ID_IMPUESTO NOT IN (SELECT ID_IMPUESTO 
																	   FROM  CI_IMPUESTOS_TARIFAS 
																	   WHERE id_cliente = @codCli  
																	   AND TZ_LOCK = 0  
																	   AND ID_IMPUESTO IN (SELECT ID_IMPUESTO 
																	   					FROM VW_IMPUESTOS))	 	

		    -- Deberiamos de grabar bitacora si algun certificado tuvo cambios.																			
			
			
			--para el reporte de inconsistencias
			SET @condIVA = (SELECT IVA 
							FROM CLI_CLIENTES 
							WHERE CODIGOCLIENTE = @codCli);			
			IF @condIVA <> ''AC''			 
			   	INSERT INTO ITF_AFIP_RG17_INCONSISTENCIAS (COD_CLIENTE, 
			   											   NRO_PERSONA, 
			   											   CUIT, 
			   											   RAZON_SOCIAL, 
			   											   CONDICION_IVA, 
			   											   TIPO_CERTIFICADO,	
			   											   PORCENTAJE,	
			   											   FECHA_DESDE,
			   											   FECHA_HASTA,
			   											   COMENTARIO)
												   VALUES (@codCli, 
												   		   @nroPersona, 
												   		   @cuit, 
												   		   @razonSocial,  
												   		   @condIVA,
												   		   ''RG17'' , 
												   		   @porcentaje,
												   		   @fechaDesde, 
												   		   @fechaHasta,
												   		   ''INCONSISTENCIA'');
		END	   				   		
		-- Eliminar el registro procesado
    	DELETE FROM #ClientesTmp3 
    	WHERE CODIGOCLIENTE = @codCli 
    	AND NUMEROPERSONA = @nroPersona;
		END --Fin del WHILE    	

SET @idCount = @idCount+1;
SET @cuit = NULL;
SELECT @cuit = CUIT, @razonSocial= RAZON_SOCIAL, @fechaDesde = PERIODO_DESDE, @fechaHasta = PERIODO_HASTA, @porcentaje = PORCENTAJE, @resGeneral = RES_GENERAL, @tipoCertificado = TIPO_CERTIFICADO
FROM ITF_AFIP_IVA_RG17 (nolock) 
WHERE ID=@idCount;

END

DROP TABLE #ClientesTmp3;
	
END

');

execute('CREATE OR ALTER   PROCEDURE dbo.[SP_AFIP_IVA_RG18]
--Juan Pedrozo: 26/05/2023
--JI: 08/09/2023
AS
BEGIN

--NUEVO BLOQUE JI 6/9/2023--

UPDATE CI_CARGOS_TARIFAS 
SET FECHA_HASTA = (SELECT FECHAPROCESO 
				     FROM PARAMETROS (nolock))
WHERE ID_CLIENTE IN (
						SELECT ID_CLIENTE
						FROM ITF_IVARG18_PERCEPCION_ULT_PADRON_AUX A
						WHERE ID_CLIENTE NOT IN (SELECT VW.CODIGOCLIENTE
						 						 FROM VW_CLIENTES_PERSONAS VW, ITF_AFIP_IVA_RG18 RG
						 						 WHERE VW.NUMERODOC=RG.CUIT
						 						 AND VW.TITULARIDAD=''T'')
					  )
					  
UPDATE CI_IMPUESTOS_TARIFAS
SET FECHA_HASTA = (SELECT FECHAPROCESO 
				     FROM PARAMETROS (nolock))
WHERE ID_CLIENTE IN (
						SELECT ID_CLIENTE
						FROM ITF_IVARG18_PERCEPCION_ULT_PADRON_AUX A
						WHERE ID_CLIENTE NOT IN (SELECT VW.CODIGOCLIENTE
						 						 FROM VW_CLIENTES_PERSONAS VW, ITF_AFIP_IVA_RG18 RG
						 						 WHERE VW.NUMERODOC=RG.CUIT
						 						 AND VW.TITULARIDAD=''T'')
					  )

TRUNCATE TABLE ITF_IVARG18_PERCEPCION_ULT_PADRON_AUX

INSERT INTO ITF_IVARG18_PERCEPCION_ULT_PADRON_AUX (PERIODO_DESDE, 
											   	   PERIODO_HASTA, 
											   	   INCISO_RESOLUCION_GRAL,
											   	   RAZON_SOCIAL, 
											   	   ID_CLIENTE)
SELECT RG.PERIODO_DESDE, 
	   RG.PERIODO_HASTA, 
	   RG.INCISO_RESOLUCION_GRAL, 
	   RG.RAZON_SOCIAL,
	   VW.CODIGOCLIENTE
FROM VW_CLIENTES_PERSONAS VW, ITF_AFIP_IVA_RG18 RG
WHERE VW.NUMERODOC=RG.CUIT
AND VW.TITULARIDAD=''T''
--HASTA ACA--

--variables clave
DECLARE @cuit VARCHAR(11),@razonSocial VARCHAR(80), @fechaDesde VARCHAR(8), @fechaHasta VARCHAR(8), @incisoRG varchar(10);

--var de cursor
DECLARE @C_idCargo NUMERIC(10), @C_descripcion VARCHAR (80), @C_tipoCargo NUMERIC(3), @C_tasa NUMERIC (4,4), @C_moneda NUMERIC(1)  ;		

--variables aux
DECLARE @codCli NUMERIC (10), @nroPersona NUMERIC(10), @condIVA VARCHAR(2);
DECLARE @inserts NUMERIC(6), @actualizados NUMERIC(6), @hayTemporales INT, @hayUpdate INT, @faltanCargos INT;





--recorro padron de entrada
DECLARE cursorOk CURSOR forward_only fast_forward read_only   
FOR 
SELECT CUIT, RAZON_SOCIAL, PERIODO_DESDE, PERIODO_HASTA, INCISO_RESOLUCION_GRAL 
FROM ITF_AFIP_IVA_RG18
OPEN cursorOk
    FETCH NEXT FROM cursorOk INTO @cuit, @razonSocial, @fechaDesde, @fechaHasta, @incisoRG
    WHILE @@FETCH_STATUS = 0 
    BEGIN	     		
  		--recorro clientes solo si la persona es titular
  		DECLARE cursorCli CURSOR forward_only fast_forward read_only   
  		FOR 
		SELECT DISTINCT 
			cp.CODIGOCLIENTE, cp.NUMEROPERSONA FROM CLI_DocumentosPFPJ pfj 
				JOIN CLI_ClientePersona cp ON pfj.NUMEROPERSONAFJ = cp.NUMEROPERSONA 
					WHERE cp.TZ_LOCK = 0 AND cp.TITULARIDAD = ''T'' AND pfj.NUMERODOCUMENTO = @cuit 
		OPEN cursorCli 
		FETCH NEXT FROM cursorCli INTO @codCli, @nroPersona
		WHILE @@FETCH_STATUS = 0 
		BEGIN  	
		
			SET @hayTemporales = (SELECT count(*) 
								  FROM  CI_CARGOS_TARIFAS 
								  WHERE id_cliente = @codCli 
								  AND TASA <> 0 AND TZ_LOCK = 0 
								  AND fecha_hasta <= (SELECT fechaproceso 
								  					  FROM PARAMETROS (nolock)) 
								  					  AND ID_CARGO IN (SELECT ID_CARGO 
								  					  				   FROM VW_CARGOS_IMPUESTOS));
		   
			IF @hayTemporales > 0 --chequeo certificados temporales


			
		   	BEGIN

				--update fecha solo si son certificados temporales	
				--cargos--			
				UPDATE CI_CARGOS_TARIFAS 
				SET fecha_hasta = (SELECT fechaproceso FROM PARAMETROS (nolock))
				WHERE id_cliente = @codCli 
				AND TASA <> 0 
				AND TZ_LOCK = 0 
				AND fecha_hasta <= (SELECT fechaproceso 
									FROM PARAMETROS (nolock)) 
				AND ID_CARGO IN (SELECT ID_CARGO 
								 FROM VW_CARGOS)
				
				--impuestos--			
				UPDATE CI_IMPUESTOS_TARIFAS 
				SET fecha_hasta = (SELECT fechaproceso 
								   FROM PARAMETROS (nolock))
				WHERE id_cliente = @codCli 
				AND TASA <> 0 
				AND TZ_LOCK = 0 
				AND fecha_hasta <= (SELECT fechaproceso 
									FROM PARAMETROS (nolock)) 
				AND ID_IMPUESTO IN (SELECT ID_IMPUESTO 
								    FROM VW_IMPUESTOS)				
								
				BEGIN TRY
				BEGIN	
				--inserto un nuevo certificado tasa 0					 
				INSERT INTO dbo.CI_CARGOS_TARIFAS (ID_CARGO, 
												   MONEDA, 
												   ID_CLIENTE, 
												   SEGMENTO, 
												   FECHA_DESDE, 
												   FECHA_HASTA) 
				SELECT ID_CARGO, 
					   MONEDA, 
					   @codCli, 
					   segmento, 
					   @fechaDesde, 
					   @fechaHasta
				FROM VW_CARGOS
				END
				END TRY
				BEGIN CATCH
    				-- Código para manejar el error
				END CATCH
				
								BEGIN TRY
				BEGIN	
				--inserto un nuevo certificado tasa 0					 
				INSERT INTO dbo.CI_IMPUESTOS_TARIFAS (ID_IMPUESTO, 
												      MONEDA, 
												      ID_CLIENTE, 
												      SEGMENTO, 
												      FECHA_DESDE, 
												      FECHA_HASTA) 
				SELECT ID_IMPUESTO, 
					   MONEDA, 
					   @codCli, 
					   segmento, 
					   @fechaDesde, 
					   @fechaHasta
				FROM VW_IMPUESTOS
				END
				END TRY
				BEGIN CATCH
    				-- Código para manejar el error
				END CATCH
				--inserto en el log 1 reg por cada tipo de cargo (2 y 3)
				INSERT INTO dbo.ITF_LOG_CARGOS_IMPUESTOS (COD_IMPUESTO,
														  PERIODO_DESDE,  
														  PERIODO_HASTA, 
														  COD_CLIENTE, 
														  ID_PERSONA, 
														  FECHA_PROCESO, 
														  FECHA_EJECUCION, 
														  CONDICION, 
														  ALICUOTA)
				SELECT TIPOCARGO, 
					   @fechaDesde, 
					   @fechaHasta,
					   @codCli, 
					   @nroPersona, 
					   CONVERT(VARCHAR(8), 
					   (SELECT FECHAPROCESO 
					   	FROM PARAMETROS (NOLOCK)), 112), 
					   CONVERT(VARCHAR(8), GETDATE(), 112),
					   '''',
					   0
				FROM VW_CARGOS_IMPUESTOS GROUP BY TIPOCARGO	   

				--inserto en bitacora 1 reg por cada tipo de cargo (2 y 3)
				INSERT INTO dbo.CON_BITACORA_IMPUESTOS (JTS_NOVEDAD, FECHA_PROCESO, HORA, ID_CLIENTE, ID_PERSONA,TIPO_ID, CUIT, TIPO_CARGO_IMPOSITIVO, ALICUOTA, FECHA_INICIO, FECHA_FIN)
				SELECT  ISNULL((SELECT MAX(JTS_NOVEDAD) FROM CON_BITACORA_IMPUESTOS),0)+ (ROW_NUMBER() OVER (ORDER BY TIPOCARGO)), (SELECT FECHAPROCESO FROM PARAMETROS (NOLOCK)), (select convert(varchar,getdate(),108)), @codCli, @nroPersona, ''C'', @cuit, TIPOCARGO, 0, @fechaDesde, @fechaHasta
				FROM VW_CARGOS_IMPUESTOS GROUP BY TIPOCARGO
				
			END		
		
			-- para el caso de que se haya agregado un nuevo cargo y no haya sido insertado		  		
		   	SET @faltanCargos = (SELECT count(*) 
		   						 FROM VW_CARGOS B 
		   						 WHERE NOT EXISTS (SELECT * 
		   						 				   FROM CI_CARGOS_TARIFAS A 
		   						 				   WHERE A.ID_CARGO = B.ID_CARGO 
		   						 				   AND A.ID_CLIENTE = @codCli)) + 
		   						(SELECT count(*) 
		   						 FROM VW_IMPUESTOS I 
		   						 WHERE NOT EXISTS (SELECT * 
		   						 				   FROM CI_IMPUESTOS_TARIFAS II 
		   						 				   WHERE II.ID_IMPUESTO = I.ID_IMPUESTO 
		   						 				   AND II.ID_CLIENTE = @codCli));
			
			IF @faltanCargos > 0
			BEGIN
			
			--cambiar aca JI
			PRINT @faltanCargos
			--hasta aca
			
				--inserto en la bitacora los cargos faltantes SE INSERTA UNO POR TIPO DE CARGO AGRUPAR POR CARGO
				INSERT INTO dbo.CON_BITACORA_IMPUESTOS (JTS_NOVEDAD, FECHA_PROCESO, HORA, ID_CLIENTE, ID_PERSONA,TIPO_ID, CUIT, TIPO_CARGO_IMPOSITIVO, ALICUOTA, FECHA_INICIO, FECHA_FIN)
				SELECT  ISNULL((SELECT MAX(JTS_NOVEDAD) FROM CON_BITACORA_IMPUESTOS),0)+ (ROW_NUMBER() OVER (ORDER BY TIPOCARGO)), (SELECT FECHAPROCESO FROM PARAMETROS (NOLOCK)), (select convert(varchar,getdate(),108)), @codCli, @nroPersona, ''C'', @cuit, TIPOCARGO, 0, @fechaDesde, @fechaHasta
				FROM VW_CARGOS_IMPUESTOS B
				WHERE NOT EXISTS (SELECT * FROM CI_CARGOS_TARIFAS A WHERE A.ID_CARGO = B.ID_CARGO AND A.ID_CLIENTE = @codCli);
								
					--inserto en el log los cargos faltantes	SE INSERTA UNO POR TIPO DE CARGO AGRUPAR POR CARGO
				INSERT INTO dbo.ITF_LOG_CARGOS_IMPUESTOS (COD_IMPUESTO,PERIODO_DESDE,  PERIODO_HASTA, COD_CLIENTE, ID_PERSONA, FECHA_PROCESO, FECHA_EJECUCION, CONDICION, ALICUOTA)
				SELECT TIPOCARGO, @fechaDesde, @fechaHasta,@codCli, @nroPersona, CONVERT(VARCHAR(8), (SELECT FECHAPROCESO FROM PARAMETROS (NOLOCK)), 112), CONVERT(VARCHAR(8), GETDATE(), 112),'''',0 
				FROM VW_CARGOS_IMPUESTOS B
				WHERE NOT EXISTS (SELECT * FROM CI_CARGOS_TARIFAS A WHERE A.ID_CARGO = B.ID_CARGO AND A.ID_CLIENTE = @codCli);				
				
				--inserto los cargos faltantes en la tabla de tarifarios
				--CARGOS--
				INSERT INTO dbo.CI_CARGOS_TARIFAS (ID_CARGO, 
												   MONEDA, 
												   ID_CLIENTE, 
												   SEGMENTO, 
												   FECHA_DESDE, 
												   FECHA_HASTA) 
				SELECT ID_CARGO, 
					   MONEDA, 
					   @codCli, 
					   segmento, 
					   @fechaDesde, 
					   @fechaHasta 
				FROM VW_CARGOS B
				WHERE NOT EXISTS (SELECT * 
								  FROM CI_CARGOS_TARIFAS A 
								  WHERE A.ID_CARGO = B.ID_CARGO 
								  AND A.ID_CLIENTE = @codCli);	  
								  
				--CARGOS--
				INSERT INTO dbo.CI_IMPUESTOS_TARIFAS (ID_IMPUESTO, 
												      MONEDA, 
												      ID_CLIENTE, 
											   	      SEGMENTO, 
												      FECHA_DESDE, 
												      FECHA_HASTA) 
				SELECT ID_IMPUESTO, 
					   MONEDA, 
					   @codCli, 
					   segmento, 
					   @fechaDesde, 
					   @fechaHasta 
				FROM VW_IMPUESTOS B
				WHERE NOT EXISTS (SELECT * 
								  FROM CI_IMPUESTOS_TARIFAS A 
								  WHERE A.ID_IMPUESTO = B.ID_IMPUESTO 
								  AND A.ID_CLIENTE = @codCli);								
			END
			
			
			-- para el caso de que para un cert permanente, haya cambiado algun dato				
			SET @hayUpdate = (SELECT COUNT(*) 
							  FROM CI_CARGOS_TARIFAS A JOIN VW_CARGOS_IMPUESTOS B ON A.ID_CARGO = B.ID_CARGO  
							  WHERE a.id_cliente = @codCli 
							  AND a.TASA = 0 
							  AND TZ_LOCK = 0 
							  AND (ISNULL(fecha_hasta, ''19000101'') <>  ISNULL(@fechaHasta, ''19000101'') or ISNULL(fecha_desde, ''19000101'') <> ISNULL(@fechaDesde, ''19000101'')) And a.ID_CARGO IN (SELECT ID_CARGO FROM VW_CARGOS_IMPUESTOS));				
												
			IF @hayUpdate > 0
			
			
			BEGIN													
				--inserto en el log	
				INSERT INTO dbo.ITF_LOG_CARGOS_IMPUESTOS (COD_IMPUESTO,PERIODO_DESDE,  PERIODO_HASTA, COD_CLIENTE, ID_PERSONA, FECHA_PROCESO, FECHA_EJECUCION, CONDICION, ALICUOTA)
				SELECT TIPOCARGO, @fechaDesde, @fechaHasta, @codCli, @nroPersona, CONVERT(VARCHAR(8), (SELECT FECHAPROCESO FROM PARAMETROS (NOLOCK)), 112), CONVERT(VARCHAR(8), GETDATE(), 112),'''',0 
				FROM CI_CARGOS_TARIFAS A JOIN VW_CARGOS_IMPUESTOS B ON A.ID_CARGO = B.ID_CARGO 
				WHERE a.id_cliente = @codCli AND a.TASA = 0 AND TZ_LOCK = 0 AND (ISNULL(fecha_hasta, ''19000101'') <>  ISNULL(@fechaHasta, ''19000101'') or ISNULL(fecha_desde, ''19000101'') <> ISNULL(@fechaDesde, ''19000101'')) And a.ID_CARGO IN (SELECT ID_CARGO FROM VW_CARGOS_IMPUESTOS);				
							
				--a la bitacora
				INSERT INTO dbo.CON_BITACORA_IMPUESTOS (JTS_NOVEDAD, FECHA_PROCESO, HORA, ID_CLIENTE, ID_PERSONA,TIPO_ID, CUIT, TIPO_CARGO_IMPOSITIVO, ALICUOTA, FECHA_INICIO, FECHA_FIN)
				SELECT  ISNULL((SELECT MAX(JTS_NOVEDAD) FROM CON_BITACORA_IMPUESTOS),0)+ (ROW_NUMBER() OVER (ORDER BY TIPOCARGO)), (SELECT FECHAPROCESO FROM PARAMETROS (NOLOCK)), (select convert(varchar,getdate(),108)), @codCli, @nroPersona, ''C'', @cuit, TIPOCARGO, 0, @fechaDesde, @fechaHasta
				FROM CI_CARGOS_TARIFAS A JOIN VW_CARGOS_IMPUESTOS B ON A.ID_CARGO = B.ID_CARGO 
				WHERE a.id_cliente = @codCli AND a.TASA = 0 AND TZ_LOCK = 0 AND (ISNULL(fecha_hasta, ''19000101'') <>  ISNULL(@fechaHasta, ''19000101'') or ISNULL(fecha_desde, ''19000101'') <> ISNULL(@fechaDesde, ''19000101'')) And a.ID_CARGO IN (SELECT ID_CARGO FROM VW_CARGOS_IMPUESTOS);				
				
							
				--luego de guardar en el log y bitacora, updateo
				--CARGOS--
				UPDATE CI_CARGOS_TARIFAS 
				SET fecha_hasta = @fechaHasta, fecha_desde = @fechaDesde
				WHERE id_cliente = @codCli 
				AND TASA = 0 
				AND TZ_LOCK = 0 
				AND (ISNULL(fecha_hasta, ''19000101'') <>  ISNULL(@fechaHasta, ''19000101'') 
				or ISNULL(fecha_desde, ''19000101'') <> ISNULL(@fechaDesde, ''19000101''))	
				And ID_CARGO IN (SELECT ID_CARGO 
								 FROM VW_CARGOS);
				--IMPUESTOS--
				UPDATE CI_IMPUESTOS_TARIFAS 
				SET fecha_hasta = @fechaHasta, fecha_desde = @fechaDesde
				WHERE id_cliente = @codCli 
				AND TASA = 0 
				AND TZ_LOCK = 0 
				AND (ISNULL(fecha_hasta, ''19000101'') <>  ISNULL(@fechaHasta, ''19000101'') 
				or ISNULL(fecha_desde, ''19000101'') <> ISNULL(@fechaDesde, ''19000101''))	
				And ID_IMPUESTO IN (SELECT ID_IMPUESTO 
								    FROM VW_IMPUESTOS);
		   	END
		   	  
			   			 		   
			--para el reporte de inconsistencias
			SET @condIVA = (SELECT IVA FROM CLI_CLIENTES WHERE CODIGOCLIENTE = @codCli);			
			IF @condIVA <> ''AC''			 
			   	INSERT INTO ITF_AFIP_RG18_INCONSISTENCIAS (COD_CLIENTE, 
			   											   NRO_PERSONA, 
			   											   CUIT, 
			   											   RAZON_SOCIAL, 
			   											   CONDICION_IVA, 
			   											   TIPO_CERTIFICADO,	
			   											   PORCENTAJE,	
			   											   FECHA_DESDE,
			   											   FECHA_HASTA,
			   											   COMENTARIO)
				VALUES (@codCli, 
						@nroPersona, 
						@cuit, 
						@razonSocial,  
						@condIVA,
						''RG18'' , 
						0,
						@fechaDesde, 
						@fechaHasta,
						''INCONSISTENCIA'');
		   				   		
		FETCH NEXT FROM cursorCli INTO @codCli, @nroPersona
		END --Fin del WHILE    	
		CLOSE cursorCli --Cerrar el CURSOR cli
		DEALLOCATE cursorCli	   
  		
   	FETCH NEXT FROM cursorOk INTO @cuit, @razonSocial, @fechaDesde, @fechaHasta, @incisoRG
   	END --Fin del WHILE
	CLOSE cursorOk --Cerrar el CURSOR ok
	DEALLOCATE cursorOk

	
END
');

execute('DROP TABLE IF EXISTS  dbo.ITF_IVARG17_PERCEPCION_ULT_PADRON_AUX


CREATE TABLE dbo.ITF_IVARG17_PERCEPCION_ULT_PADRON_AUX
	(
	ID            INT IDENTITY NOT NULL,
	PERIODO_DESDE DATETIME,
	PERIODO_HASTA DATETIME,
	PORCENTAJE    NUMERIC (7, 4),
	ID_CLIENTE    NUMERIC (12),
	CONSTRAINT ITF_IVARG17_PERCEPCION_ULT_PADRON PRIMARY KEY (ID)
	)');
execute('
	DROP TABLE IF EXISTS dbo.ITF_IVARG18_PERCEPCION_ULT_PADRON_AUX


CREATE TABLE dbo.ITF_IVARG18_PERCEPCION_ULT_PADRON_AUX
	(
	ID                     INT IDENTITY NOT NULL,
	PERIODO_DESDE          DATETIME,
	PERIODO_HASTA          DATETIME,
	INCISO_RESOLUCION_GRAL VARCHAR (10),
	ID_CLIENTE             NUMERIC (12),
	RAZON_SOCIAL           VARCHAR (80),
	CONSTRAINT ITF_IVARG18_PERCEPCION_ULT_PADRON PRIMARY KEY (ID)
	)
');

execute('CREATE OR ALTER VIEW dbo.[VW_IMPUESTOS]
AS
SELECT 
TIPOCARGO,
cct.SEGMENTO,
ID_IMPUESTO,
DESCRIPCION,
TASA,
MONEDA 
FROM CI_impuestos_TARIFAS CCT
JOIN 
	(

	  SELECT ID_IMPUESTO AS idCargo, DESCRIPCION,TIPO_IMPUESTO AS TipoCargo,MONEDA_IMPORTE
	  FROM CI_IMPUESTOS
	  WHERE TIPO_IMPUESTO IN (2,3)
	) AS Impuesto
ON CCT.ID_IMPUESTO = Impuesto.idCargo
AND CCT.MONEDA=IMPUESTO.MONEDA_IMPORTE
WHERE (TipoCargo = 2 AND SEGMENTO = ''AC'' OR TipoCargo = 3 AND SEGMENTO = ''0'') AND id_cliente = 0 AND TZ_LOCK = 0');

execute('CREATE VIEW dbo.[VW_CARGOS]
AS
SELECT 
TIPOCARGO,
cct.SEGMENTO,
ID_CARGO,
DESCRIPCION,
TASA,
MONEDA 
FROM CI_CARGOS_TARIFAS CCT
JOIN 
	(
	  SELECT Id_cargo AS idCargo, DESCRIPCION,TIPO_CARGO_IMPOSITIVO AS TipoCargo,MONEDA_IMPORTE
	  FROM CI_CARGOS
	  WHERE TIPO_CARGO_IMPOSITIVO IN (2,3)

	) AS Cargo
ON CCT.Id_Cargo = Cargo.idCargo
WHERE (TipoCargo = 2 AND SEGMENTO = ''AC'' OR TipoCargo = 3 AND SEGMENTO = ''0'') AND id_cliente = 0 AND TZ_LOCK = 0');