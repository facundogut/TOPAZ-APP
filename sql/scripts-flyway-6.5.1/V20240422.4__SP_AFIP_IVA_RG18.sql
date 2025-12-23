execute ('
create or ALTER     PROCEDURE dbo.[SP_AFIP_IVA_RG18]
--Juan Pedrozo: 26/05/2023
--J. Izquierdo: 03/11/2023

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
DECLARE @cuit VARCHAR(11),@razonSocial VARCHAR(80), @fechaDesde DATETIME, @fechaHasta DATETIME, @incisoRG varchar(10);

--var de cursor
DECLARE @C_idCargo NUMERIC(10), @C_descripcion VARCHAR (80), @C_tipoCargo NUMERIC(3), @C_tasa NUMERIC (4,4), @C_moneda NUMERIC(1)  ;		

--variables aux
DECLARE @codCli NUMERIC (10), @nroPersona NUMERIC(10), @condIVA VARCHAR(2);
DECLARE @inserts NUMERIC(6), @actualizados NUMERIC(6), @hayTemporales INT, @hayUpdateCargos INT,@hayUpdateImpuestos INT, @faltanCargos INT;




--recorro padron de entrada
DECLARE cursorOk CURSOR forward_only fast_forward read_only   
FOR 
SELECT rg.CUIT, rg.RAZON_SOCIAL, rg.PERIODO_DESDE, rg.PERIODO_HASTA, rg.INCISO_RESOLUCION_GRAL,cp.CODIGOCLIENTE, cp.NUMEROPERSONA
FROM ITF_AFIP_IVA_RG18 rg
INNER JOIN CLI_DocumentosPFPJ pfj ON rg.CUIT=pfj.NUMERODOCUMENTO
INNER JOIN CLI_ClientePersona cp ON pfj.NUMEROPERSONAFJ = cp.NUMEROPERSONA
WHERE cp.TZ_LOCK = 0 
AND cp.TITULARIDAD = ''T''
OPEN cursorOk
    FETCH NEXT FROM cursorOk INTO @cuit, @razonSocial, @fechaDesde, @fechaHasta, @incisoRG, @codCli, @nroPersona
    WHILE @@FETCH_STATUS = 0 
    BEGIN
    
    		
  		--recorro clientes solo si la persona es titular
--  		DECLARE cursorCli CURSOR forward_only fast_forward read_only   
--  		FOR 
-- 		SELECT DISTINCT 
--			cp.CODIGOCLIENTE, cp.NUMEROPERSONA FROM CLI_DocumentosPFPJ pfj 
--				JOIN CLI_ClientePersona cp ON pfj.NUMEROPERSONAFJ = cp.NUMEROPERSONA 
--					WHERE cp.TZ_LOCK = 0 AND cp.TITULARIDAD = ''T'' AND pfj.NUMERODOCUMENTO = @cuit 
--		OPEN cursorCli 
--		FETCH NEXT FROM cursorCli INTO @codCli, @nroPersona
--		WHILE @@FETCH_STATUS = 0 
--		BEGIN  	
		
			SET @hayTemporales = (SELECT count(*) 
								  FROM  CI_CARGOS_TARIFAS 
								  WHERE id_cliente = @codCli 
								  AND TASA <> 0 AND TZ_LOCK = 0 
								  AND fecha_hasta <= (SELECT fechaproceso FROM PARAMETROS (nolock)) 
								  AND ID_CARGO IN (SELECT ID_CARGO FROM VW_CARGOS_IMPUESTOS));
		   

			IF @hayTemporales > 0 --chequeo certificados temporales


			
		   	BEGIN

			PRINT @hayTemporales
			PRINT @codCli
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
    				PRINT ''catch 1''
    				PRINT ''Error durante la inserción: '' + ERROR_MESSAGE();
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
    				PRINT ''catch 2''
    				PRINT ''Error durante la inserción: '' + ERROR_MESSAGE();
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
					   CONVERT(VARCHAR(8), @fechaDesde, 112), 
					   CONVERT(VARCHAR(8), @fechaHasta, 112),
					   @codCli, 
					   @nroPersona, 
					   CONVERT(VARCHAR(8), 
					   (SELECT FECHAPROCESO 
					   	FROM PARAMETROS (NOLOCK)), 112), 
					   CONVERT(VARCHAR(8), GETDATE(), 112),
					   segmento,
					   0
				FROM VW_CARGOS_IMPUESTOS GROUP BY TIPOCARGO,segmento	   

				--inserto en bitacora 1 reg por cada tipo de cargo (2 y 3)
				INSERT INTO dbo.CON_BITACORA_IMPUESTOS (JTS_NOVEDAD, 
														FECHA_PROCESO, 
														HORA, 
														ID_CLIENTE, 
														ID_PERSONA,
														TIPO_ID, 
														CUIT, 
														TIPO_CARGO_IMPOSITIVO, 
														ALICUOTA, 
														FECHA_INICIO, 
														FECHA_FIN,
														id_cargo_impuesto,
														sucursal,
														tipo_novedad)
												SELECT  ISNULL((SELECT MAX(JTS_NOVEDAD) FROM CON_BITACORA_IMPUESTOS),0)+ (ROW_NUMBER() OVER (ORDER BY TIPOCARGO)), 
														(SELECT FECHAPROCESO FROM PARAMETROS (NOLOCK)), 
														(select convert(varchar,getdate(),108)), 
														@codCli, 
														@nroPersona, 
														''C'', 
														@cuit, 
														TIPOCARGO, 
														0, 
														@fechaDesde, 
														@fechaHasta,
														id_cargo,
														(SELECT SUCURSALvinculada FROM CLI_CLIENTES WHERE codigocliente=@codCli AND TZ_LOCK=0),
														''A''
												FROM VW_CARGOS_IMPUESTOS GROUP BY TIPOCARGO, ID_CARGO
				
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
			PRINT ''faltancargos''
			--cambiar aca JI

			--hasta aca

				--inserto en la bitacora los cargos faltantes SE INSERTA UNO POR TIPO DE CARGO AGRUPAR POR CARGO
				INSERT INTO dbo.CON_BITACORA_IMPUESTOS (JTS_NOVEDAD, 
														FECHA_PROCESO, 
														HORA, 
														ID_CLIENTE, 
														ID_PERSONA,
														TIPO_ID, 
														CUIT, 
														TIPO_CARGO_IMPOSITIVO, 
														ALICUOTA, 
														FECHA_INICIO, 
														FECHA_FIN,
														id_cargo_impuesto,
														sucursal,
														tipo_novedad)
												SELECT  ISNULL((SELECT MAX(JTS_NOVEDAD) FROM CON_BITACORA_IMPUESTOS),0)+ (ROW_NUMBER() OVER (ORDER BY TIPOCARGO)), 
														(SELECT FECHAPROCESO FROM PARAMETROS (NOLOCK)), 
														(select convert(varchar,getdate(),108)), 
														@codCli, 
														@nroPersona, 
														''C'', 
														@cuit, 
														TIPOCARGO, 
														0, 
														@fechaDesde, 
														@fechaHasta,
														b.id_cargo,
														(SELECT SUCURSALvinculada FROM CLI_CLIENTES WHERE codigocliente=@codCli AND TZ_LOCK=0),
														''A''
												FROM VW_CARGOS_IMPUESTOS B
												WHERE NOT EXISTS (SELECT * FROM CI_CARGOS_TARIFAS A WHERE A.ID_CARGO = B.ID_CARGO AND A.ID_CLIENTE = @codCli);
								
					--inserto en el log los cargos faltantes	SE INSERTA UNO POR TIPO DE CARGO AGRUPAR POR CARGO
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
					   CONVERT(VARCHAR(8), @fechaDesde, 112), 
					   CONVERT(VARCHAR(8), @fechaHasta, 112),
												   		  @codCli, 
												   		  @nroPersona, 
												   		  CONVERT(VARCHAR(8), 
												   		  (SELECT FECHAPROCESO FROM PARAMETROS (NOLOCK)), 112), 
												   		  CONVERT(VARCHAR(8), GETDATE(), 112),
												   		  B.SEGMENTO,
												   		  0 
												   FROM VW_CARGOS_IMPUESTOS B
												   WHERE NOT EXISTS (SELECT * FROM CI_CARGOS_TARIFAS A WHERE A.ID_CARGO = B.ID_CARGO AND A.ID_CLIENTE = @codCli);				
				
				BEGIN TRY 
				--inserto los cargos faltantes en la tabla de tarifarios
				--CARGOS--
				PRINT @codCli
				INSERT INTO dbo.CI_CARGOS_TARIFAS (ID_CARGO, 
												   MONEDA, 
												   ID_CLIENTE, 
												   SEGMENTO, 
												   FECHA_DESDE, 
												   FECHA_HASTA,
												   TASA,
												   RANGO_HASTA,
												   IMPORTE_APLICAR,
												   MONEDA_IMPORTE) 
				SELECT B.ID_CARGO, 
					   B.MONEDA, 
					   @codCli, 
					   B.segmento, 
					   @fechaDesde, 
					   @fechaHasta,
					   B.TASA,
					   C.RANGO_HASTA,
					   C.IMPORTE_APLICAR,
					   C.MONEDA_IMPORTE 
				FROM VW_CARGOS_IMPUESTOS B
				INNER JOIN CI_CARGOS_TARIFAS C ON B.ID_CARGO=C.ID_CARGO AND B.SEGMENTO=C.SEGMENTO AND B.MONEDA=C.MONEDA 
				WHERE C.ID_CLIENTE=0
--				WHERE NOT EXISTS (SELECT * 
--								  FROM CI_CARGOS_TARIFAS A 
--								  WHERE A.ID_CARGO = B.ID_CARGO 
--								  AND A.ID_CLIENTE = @codCli);	  
								  
				PRINT @codCli
				--IMPUESTOS--
				INSERT INTO dbo.CI_IMPUESTOS_TARIFAS (ID_IMPUESTO, 
												      MONEDA, 
												      ID_CLIENTE, 
											   	      SEGMENTO, 
												      FECHA_DESDE, 
												      FECHA_HASTA,
												      TASA,
												   RANGO_HASTA,
												   IMPORTE_APLICAR,
												   MONEDA_IMPORTE) 
				SELECT B.ID_IMPUESTO, 
					   B.MONEDA, 
					   @codCli, 
					   B.segmento, 
					   @fechaDesde, 
					   @fechaHasta,
					   B.TASA,
					   C.RANGO_HASTA,
					   C.IMPORTE_APLICAR,
					   C.MONEDA_IMPORTE
				FROM VW_IMPUESTOS B
				INNER JOIN CI_IMPUESTOS_TARIFAS C ON B.ID_IMPUESTO=C.ID_IMPUESTO AND B.SEGMENTO=C.SEGMENTO AND B.MONEDA=C.MONEDA
				WHERE C.ID_CLIENTE=0
--				WHERE NOT EXISTS (SELECT * 
--								  FROM CI_IMPUESTOS_TARIFAS A 
--								  WHERE A.ID_IMPUESTO = B.ID_IMPUESTO 
--								  AND A.ID_CLIENTE = @codCli);	
			   END TRY
				BEGIN CATCH
					PRINT ''catch 3''
					PRINT ''Error durante la inserción: '' + ERROR_MESSAGE();
				END CATCH 								
			END
			
			
			-- para el caso de que para un cert permanente, haya cambiado algun dato				
			SET @hayUpdateCargos = (SELECT COUNT(*) 
							  FROM CI_CARGOS_TARIFAS A JOIN VW_CARGOS_IMPUESTOS B ON A.ID_CARGO = B.ID_CARGO  
							  WHERE a.id_cliente = @codCli 
							  AND a.TASA = 0 
							  AND TZ_LOCK = 0 
							  AND (ISNULL(fecha_hasta, ''19000101'') <>  ISNULL(@fechaHasta, ''19000101'') 
							  OR ISNULL(fecha_desde, ''19000101'') <> ISNULL(@fechaDesde, ''19000101'')) 
							  AND a.ID_CARGO IN (SELECT ID_CARGO FROM VW_CARGOS_IMPUESTOS));				
												
			IF @hayUpdateCargos > 0
			

			
			BEGIN  
			PRINT ''hay update cargos''													
				--inserto en el log	
--				INSERT INTO dbo.ITF_LOG_CARGOS_IMPUESTOS (COD_IMPUESTO,PERIODO_DESDE,  PERIODO_HASTA, COD_CLIENTE, ID_PERSONA, FECHA_PROCESO, FECHA_EJECUCION, CONDICION, ALICUOTA)
--				SELECT TIPOCARGO, CONVERT(VARCHAR(8), @fechaDesde, 112), CONVERT(VARCHAR(8), @fechaHasta, 112), @codCli, @nroPersona, CONVERT(VARCHAR(8), (SELECT FECHAPROCESO FROM PARAMETROS (NOLOCK)), 112), CONVERT(VARCHAR(8), GETDATE(), 112),'''',0 
--				FROM CI_CARGOS_TARIFAS A JOIN VW_CARGOS_IMPUESTOS B ON A.ID_CARGO = B.ID_CARGO 
--				WHERE a.id_cliente = @codCli AND a.TASA = 0 AND TZ_LOCK = 0 AND (ISNULL(fecha_hasta, ''19000101'') <>  ISNULL(@fechaHasta, ''19000101'') or ISNULL(fecha_desde, ''19000101'') <> ISNULL(@fechaDesde, ''19000101'')) And a.ID_CARGO IN (SELECT ID_CARGO FROM VW_CARGOS_IMPUESTOS);				
							
				--a la bitacora
--				INSERT INTO dbo.CON_BITACORA_IMPUESTOS (JTS_NOVEDAD, FECHA_PROCESO, HORA, ID_CLIENTE, ID_PERSONA,TIPO_ID, CUIT, TIPO_CARGO_IMPOSITIVO, ALICUOTA, FECHA_INICIO, FECHA_FIN)
--				SELECT  ISNULL((SELECT MAX(JTS_NOVEDAD) FROM CON_BITACORA_IMPUESTOS),0)+ (ROW_NUMBER() OVER (ORDER BY TIPOCARGO)), (SELECT FECHAPROCESO FROM PARAMETROS (NOLOCK)), (select convert(varchar,getdate(),108)), @codCli, @nroPersona, ''C'', @cuit, TIPOCARGO, 0, @fechaDesde, @fechaHasta
--				FROM CI_CARGOS_TARIFAS A JOIN VW_CARGOS_IMPUESTOS B ON A.ID_CARGO = B.ID_CARGO 
--				WHERE a.id_cliente = @codCli AND a.TASA = 0 AND TZ_LOCK = 0 AND (ISNULL(fecha_hasta, ''19000101'') <>  ISNULL(@fechaHasta, ''19000101'') or ISNULL(fecha_desde, ''19000101'') <> ISNULL(@fechaDesde, ''19000101'')) And a.ID_CARGO IN (SELECT ID_CARGO FROM VW_CARGOS_IMPUESTOS);				
				
							
				--luego de guardar en el log y bitacora, updateo
				--CARGOS--
				BEGIN TRY
				
				UPDATE C 
				SET c.fecha_hasta = @fechaHasta, c.fecha_desde = @fechaDesde,c.TASA=v.TASA,c.MONEDA=v.MONEDA
				FROM CI_cargos_TARIFAS c INNER JOIN vw_CARGOS_IMPUESTOS v ON c.ID_cargo=v.ID_cargo AND c.SEGMENTO=v.SEGMENTO AND c.MONEDA=v.MONEDA 
				WHERE c.id_cliente = @codCli 
				AND c.TASA = 0 
				AND c.TZ_LOCK = 0 
				AND (ISNULL(c.fecha_hasta, ''19000101'') <>  ISNULL(@fechaHasta, ''19000101'') 
				or ISNULL(c.fecha_desde, ''19000101'') <> ISNULL(@fechaDesde, ''19000101''))	
				And c.ID_cargo IN (SELECT ID_cargo 
								    FROM VW_CARGOS_IMPUESTOS);
								    
				--inserto en el log	
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
												   		  CONVERT(VARCHAR(8), @fechaDesde, 112), 
												   		  CONVERT(VARCHAR(8), @fechaHasta, 112), 
												   		  @codCli, 
												   		  @nroPersona, 
												   		  CONVERT(VARCHAR(8), 
												   		  (SELECT FECHAPROCESO FROM PARAMETROS (NOLOCK)), 112), 
												   		  CONVERT(VARCHAR(8), GETDATE(), 112),
												   		  a.SEGMENTO,
												   		  0 
 				FROM CI_CARGOS_TARIFAS A JOIN VW_CARGOS_IMPUESTOS B ON A.ID_CARGO = B.ID_CARGO 
				WHERE a.id_cliente = @codCli AND a.TASA = 0 AND TZ_LOCK = 0 AND (ISNULL(fecha_hasta, ''19000101'') <>  ISNULL(@fechaHasta, ''19000101'') or ISNULL(fecha_desde, ''19000101'') <> ISNULL(@fechaDesde, ''19000101'')) And a.ID_CARGO IN (SELECT ID_CARGO FROM VW_CARGOS_IMPUESTOS);				
							
				--a la bitacora
				INSERT INTO dbo.CON_BITACORA_IMPUESTOS (JTS_NOVEDAD, 
														FECHA_PROCESO, 
														HORA, 
														ID_CLIENTE, 
														ID_PERSONA,
														TIPO_ID, 
														CUIT, 
														TIPO_CARGO_IMPOSITIVO, 
														ALICUOTA, 
														FECHA_INICIO, 
														FECHA_FIN,
														id_Cargo_impuesto,
														sucursal,
														tipo_novedad)
												SELECT  ISNULL((SELECT MAX(JTS_NOVEDAD) FROM CON_BITACORA_IMPUESTOS),0)+ (ROW_NUMBER() OVER (ORDER BY TIPOCARGO)), 
														(SELECT FECHAPROCESO FROM PARAMETROS (NOLOCK)), 
														(select convert(varchar,getdate(),108)), 
														@codCli, 
														@nroPersona, 
														''C'', 
														@cuit, 
														TIPOCARGO, 
														0, 
														@fechaDesde, 
														@fechaHasta,
														a.id_cargo,
														c.sucursalvinculada,
														''A''
				FROM CI_CARGOS_TARIFAS a JOIN VW_CARGOS_IMPUESTOS B ON A.ID_CARGO = B.ID_CARGO 
				INNER JOIN CLI_CLIENTES C ON c.codigocliente=a.id_cliente
				WHERE a.id_cliente = @codCli AND a.TASA = 0 AND a.TZ_LOCK = 0 AND C.tz_lock=0 AND (ISNULL(fecha_hasta, ''19000101'') <>  ISNULL(@fechaHasta, ''19000101'') or ISNULL(fecha_desde, ''19000101'') <> ISNULL(@fechaDesde, ''19000101'')) And a.ID_CARGO IN (SELECT ID_CARGO FROM VW_CARGOS_IMPUESTOS);				

								    
				END TRY
				BEGIN CATCH
					PRINT ''catch 4''
					PRINT ''Error durante la inserción: '' + ERROR_MESSAGE();
				END CATCH 				    
				
				
		   	END
		   	  
		   	  
		   	SET @hayUpdateimpuestos = (SELECT COUNT(*) 
							  FROM CI_impuestos_TARIFAS A JOIN VW_IMPUESTOS B ON A.ID_impuesto = B.ID_impuesto  
							  WHERE a.id_cliente = @codCli 
							  AND a.TASA = 0 
							  AND TZ_LOCK = 0 
							  AND (ISNULL(fecha_hasta, ''19000101'') <>  ISNULL(@fechaHasta, ''19000101'') 
							  OR ISNULL(fecha_desde, ''19000101'') <> ISNULL(@fechaDesde, ''19000101'')) 
							  AND a.ID_impuestO IN (SELECT ID_impuesto FROM VW_IMPUESTOS));				
												
			IF @hayUpdateimpuestos > 0
			

			
			BEGIN													
				
			PRINT ''hay update impuestos''				
				--luego de guardar en el log y bitacora, updateo

				BEGIN TRY
				

				--IMPUESTOS--
				UPDATE C 
				SET c.fecha_hasta = @fechaHasta, c.fecha_desde = @fechaDesde,c.TASA=v.TASA,c.MONEDA=v.MONEDA
				FROM CI_IMPUESTOS_TARIFAS c INNER JOIN VW_IMPUESTOS v ON c.ID_impuesto=v.ID_impuesto AND c.SEGMENTO=v.SEGMENTO AND c.MONEDA=v.MONEDA 
				WHERE c.id_cliente = @codCli 
				AND c.TASA = 0 
				AND c.TZ_LOCK = 0 
				AND (ISNULL(c.fecha_hasta, ''19000101'') <>  ISNULL(@fechaHasta, ''19000101'') 
				or ISNULL(c.fecha_desde, ''19000101'') <> ISNULL(@fechaDesde, ''19000101''))	
				And c.ID_IMPUESTO IN (SELECT ID_IMPUESTO 
								    FROM VW_IMPUESTOS);
								    
								    
								--inserto en el log	
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
												   		  CONVERT(VARCHAR(8), @fechaDesde, 112), 
												   		  CONVERT(VARCHAR(8), @fechaHasta, 112), 
												   		  @codCli, 
												   		  @nroPersona, 
												   		  CONVERT(VARCHAR(8), (SELECT FECHAPROCESO FROM PARAMETROS (NOLOCK)), 112), 
												   		  CONVERT(VARCHAR(8), GETDATE(), 112),
												   		  a.SEGMENTO,
												   		  0 
 												   FROM CI_impuestos_TARIFAS A JOIN VW_IMPUESTOS B ON A.ID_impuesto = B.ID_impuesto 
												   WHERE a.id_cliente = @codCli AND a.TASA = 0 AND TZ_LOCK = 0 AND (ISNULL(fecha_hasta, ''19000101'') <>  ISNULL(@fechaHasta, ''19000101'') or ISNULL(fecha_desde, ''19000101'') <> ISNULL(@fechaDesde, ''19000101'')) And a.ID_impuesto IN (SELECT ID_impuesto FROM VW_IMPUESTOS);				
							
				--a la bitacora
				INSERT INTO dbo.CON_BITACORA_IMPUESTOS (JTS_NOVEDAD, 
														FECHA_PROCESO, 
														HORA, 
														ID_CLIENTE, 
														ID_PERSONA,
														TIPO_ID, 
														CUIT, 
														TIPO_CARGO_IMPOSITIVO, 
														ALICUOTA, 
														FECHA_INICIO, 
														FECHA_FIN,
														id_Cargo_impuesto,
														sucursal,
														tipo_novedad)
												SELECT  ISNULL((SELECT MAX(JTS_NOVEDAD) FROM CON_BITACORA_IMPUESTOS),0)+ (ROW_NUMBER() OVER (ORDER BY TIPOCARGO)), 
														(SELECT FECHAPROCESO FROM PARAMETROS (NOLOCK)), 
														(select convert(varchar,getdate(),108)), 
														@codCli, 
														@nroPersona, 
														''C'', 
														@cuit, 
														TIPOCARGO, 
														0, 
														@fechaDesde, 
														@fechaHasta,
														a.id_impuesto,
														c.sucursalvinculada,
														''A''
												FROM CI_impuestos_TARIFAS A JOIN VW_IMPUESTOS B ON A.ID_impuesto = B.ID_impuesto 
												INNER JOIN CLI_CLIENTES C ON c.codigocliente=a.id_cliente
												WHERE a.id_cliente = @codCli AND a.TASA = 0 AND a.TZ_LOCK = 0 AND c.TZ_LOCK = 0 AND (ISNULL(fecha_hasta, ''19000101'') <>  ISNULL(@fechaHasta, ''19000101'') or ISNULL(fecha_desde, ''19000101'') <> ISNULL(@fechaDesde, ''19000101'')) And a.ID_impuestO IN (SELECT ID_impuesto FROM VW_IMPUESTOS);				

								    
				END TRY
				BEGIN CATCH
					PRINT ''catch 5''
					PRINT ''Error durante la inserción: '' + ERROR_MESSAGE();
				END CATCH 				    
				
				
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
						CONVERT(VARCHAR(10),@fechaDesde, 103), 
						CONVERT(VARCHAR(10),@fechaHasta, 103),
						''INCONSISTENCIA'');
		   				   		
--		FETCH NEXT FROM cursorCli INTO @codCli, @nroPersona
--		END --Fin del WHILE    	
--		CLOSE cursorCli --Cerrar el CURSOR cli
--		DEALLOCATE cursorCli	   
  		
   	FETCH NEXT FROM cursorOk INTO @cuit, @razonSocial, @fechaDesde, @fechaHasta, @incisoRG, @codCli, @nroPersona
   	END --Fin del WHILE
	CLOSE cursorOk --Cerrar el CURSOR ok
	DEALLOCATE cursorOk

	
END
');

