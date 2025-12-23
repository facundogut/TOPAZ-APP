Execute('
CREATE  OR ALTER PROCEDURE dbo.[SP_AFIP_IVA_RG18]
--Juan Pedrozo: 26/05/2023
	@ID_TICKET NUMERIC(20) --no lo uso

AS
BEGIN


--variables clave
DECLARE @cuit VARCHAR(11),@razonSocial VARCHAR(80), @fechaDesde VARCHAR(8), @fechaHasta VARCHAR(8), @incisoRG varchar(10);

--var de cursor
DECLARE @C_idCargo NUMERIC(10), @C_descripcion VARCHAR (80), @C_tipoCargo NUMERIC(3), @C_tasa NUMERIC (4,4), @C_moneda NUMERIC(1)  ;		

--variables aux
DECLARE @codCli NUMERIC (10), @nroPersona NUMERIC(10), @condIVA VARCHAR(2);
DECLARE @inserts NUMERIC(6), @actualizados NUMERIC(6), @hayTemporales INT, @hayUpdate INT, @faltanCargos INT;


--limpio la tabla de inconsistencias
TRUNCATE TABLE ITF_AFIP_RG18_INCONSISTENCIAS;


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
		
			SET @hayTemporales = (SELECT count(*) FROM  CI_CARGOS_TARIFAS WHERE id_cliente = @codCli AND TASA <> 0 AND TZ_LOCK = 0 AND fecha_hasta <= (SELECT fechaproceso FROM PARAMETROS (nolock)) AND ID_CARGO IN (SELECT ID_CARGO FROM VW_CARGOS_IMPUESTOS));
		   
			IF @hayTemporales > 0 --chequeo certificados temporales
		   	BEGIN
				--update fecha solo si son certificados temporales				
				UPDATE CI_CARGOS_TARIFAS SET fecha_hasta = (SELECT fechaproceso FROM PARAMETROS (nolock))
				WHERE id_cliente = @codCli AND TASA <> 0 AND TZ_LOCK = 0 AND fecha_hasta <= (SELECT fechaproceso FROM PARAMETROS (nolock)) AND ID_CARGO IN (SELECT ID_CARGO FROM VW_CARGOS_IMPUESTOS)
					
				--inserto un nuevo certificado tasa 0					 
				INSERT INTO dbo.CI_CARGOS_TARIFAS (ID_CARGO, MONEDA, ID_CLIENTE, SEGMENTO, FECHA_DESDE, FECHA_HASTA) 
				SELECT ID_CARGO, MONEDA, @codCli, segmento, @fechaDesde, @fechaHasta
				FROM VW_CARGOS_IMPUESTOS
				
				--inserto en el log 1 reg por cada tipo de cargo (2 y 3)
				INSERT INTO dbo.ITF_LOG_CARGOS_IMPUESTOS (COD_IMPUESTO,PERIODO_DESDE,  PERIODO_HASTA, COD_CLIENTE, ID_PERSONA, FECHA_PROCESO, FECHA_EJECUCION, CONDICION, ALICUOTA)
				SELECT TIPOCARGO, @fechaDesde, @fechaHasta,@codCli, @nroPersona, CONVERT(VARCHAR(8), (SELECT FECHAPROCESO FROM PARAMETROS (NOLOCK)), 112), CONVERT(VARCHAR(8), GETDATE(), 112),'''',0
				FROM VW_CARGOS_IMPUESTOS GROUP BY TIPOCARGO	   

				--inserto en bitacora 1 reg por cada tipo de cargo (2 y 3)
				INSERT INTO dbo.CON_BITACORA_IMPUESTOS (JTS_NOVEDAD, FECHA_PROCESO, HORA, ID_CLIENTE, ID_PERSONA,TIPO_ID, CUIT, TIPO_CARGO_IMPOSITIVO, ALICUOTA, FECHA_INICIO, FECHA_FIN)
				SELECT ISNULL((SELECT MAX(JTS_NOVEDAD)+1 FROM CON_BITACORA_IMPUESTOS),0), (SELECT FECHAPROCESO FROM PARAMETROS (NOLOCK)), (select convert(varchar,getdate(),108)), @codCli, @nroPersona, ''C'', @cuit, TIPOCARGO, 0, @fechaDesde, @fechaHasta
				FROM VW_CARGOS_IMPUESTOS GROUP BY TIPOCARGO
				
			END		
		
			-- para el caso de que se haya agregado un nuevo cargo y no haya sido insertado		  		
		   	SET @faltanCargos = (SELECT count(*) FROM VW_CARGOS_IMPUESTOS B WHERE NOT EXISTS (SELECT * FROM CI_CARGOS_TARIFAS A WHERE A.ID_CARGO = B.ID_CARGO AND A.ID_CLIENTE = @codCli));
			
			IF @faltanCargos > 0
			BEGIN
				--inserto en la bitacora los cargos faltantes SE INSERTA UNO POR TIPO DE CARGO AGRUPAR POR CARGO
				INSERT INTO dbo.CON_BITACORA_IMPUESTOS (JTS_NOVEDAD, FECHA_PROCESO, HORA, ID_CLIENTE, ID_PERSONA,TIPO_ID, CUIT, TIPO_CARGO_IMPOSITIVO, ALICUOTA, FECHA_INICIO, FECHA_FIN)
				SELECT ISNULL((SELECT MAX(JTS_NOVEDAD)+1 FROM CON_BITACORA_IMPUESTOS),0), (SELECT FECHAPROCESO FROM PARAMETROS (NOLOCK)), (select convert(varchar,getdate(),108)), @codCli, @nroPersona, ''C'', @cuit, TIPOCARGO, 0, @fechaDesde, @fechaHasta
				FROM VW_CARGOS_IMPUESTOS B
				WHERE NOT EXISTS (SELECT * FROM CI_CARGOS_TARIFAS A WHERE A.ID_CARGO = B.ID_CARGO AND A.ID_CLIENTE = @codCli);
								
					--inserto en el log los cargos faltantes	SE INSERTA UNO POR TIPO DE CARGO AGRUPAR POR CARGO
				INSERT INTO dbo.ITF_LOG_CARGOS_IMPUESTOS (COD_IMPUESTO,PERIODO_DESDE,  PERIODO_HASTA, COD_CLIENTE, ID_PERSONA, FECHA_PROCESO, FECHA_EJECUCION, CONDICION, ALICUOTA)
				SELECT TIPOCARGO, @fechaDesde, @fechaHasta,@codCli, @nroPersona, CONVERT(VARCHAR(8), (SELECT FECHAPROCESO FROM PARAMETROS (NOLOCK)), 112), CONVERT(VARCHAR(8), GETDATE(), 112),'''',0 
				FROM VW_CARGOS_IMPUESTOS B
				WHERE NOT EXISTS (SELECT * FROM CI_CARGOS_TARIFAS A WHERE A.ID_CARGO = B.ID_CARGO AND A.ID_CLIENTE = @codCli);				
				
				--inserto los cargos faltantes en la tabla de tarifarios
				INSERT INTO dbo.CI_CARGOS_TARIFAS (ID_CARGO, MONEDA, ID_CLIENTE, SEGMENTO, FECHA_DESDE, FECHA_HASTA) 
				SELECT ID_CARGO, MONEDA, @codCli, segmento, @fechaDesde, @fechaHasta FROM VW_CARGOS_IMPUESTOS B
				WHERE NOT EXISTS (SELECT * FROM CI_CARGOS_TARIFAS A WHERE A.ID_CARGO = B.ID_CARGO AND A.ID_CLIENTE = @codCli);									
			END
			
			
			-- para el caso de que para un cert permanente, haya cambiado algun dato				
			SET @hayUpdate = (SELECT COUNT(*) FROM CI_CARGOS_TARIFAS A JOIN VW_CARGOS_IMPUESTOS B ON A.ID_CARGO = B.ID_CARGO  WHERE a.id_cliente = @codCli AND a.TASA = 0 AND TZ_LOCK = 0 AND (fecha_hasta <>  @fechaHasta or fecha_desde <> @fechaDesde) And a.ID_CARGO IN (SELECT ID_CARGO FROM VW_CARGOS_IMPUESTOS));				
												
			IF @hayUpdate > 0
			BEGIN													
				--inserto en el log	
				INSERT INTO dbo.ITF_LOG_CARGOS_IMPUESTOS (COD_IMPUESTO,PERIODO_DESDE,  PERIODO_HASTA, COD_CLIENTE, ID_PERSONA, FECHA_PROCESO, FECHA_EJECUCION, CONDICION, ALICUOTA)
				SELECT TIPOCARGO, @fechaDesde, @fechaHasta, @codCli, @nroPersona, CONVERT(VARCHAR(8), (SELECT FECHAPROCESO FROM PARAMETROS (NOLOCK)), 112), CONVERT(VARCHAR(8), GETDATE(), 112),'''',0 
				FROM CI_CARGOS_TARIFAS A JOIN VW_CARGOS_IMPUESTOS B ON A.ID_CARGO = B.ID_CARGO 
				WHERE a.id_cliente = @codCli AND a.TASA = 0 AND TZ_LOCK = 0 AND (fecha_hasta <>  @fechaHasta or fecha_desde <> @fechaDesde) And a.ID_CARGO IN (SELECT ID_CARGO FROM VW_CARGOS_IMPUESTOS);				
							
				--a la bitacora
				INSERT INTO dbo.CON_BITACORA_IMPUESTOS (JTS_NOVEDAD, FECHA_PROCESO, HORA, ID_CLIENTE, ID_PERSONA,TIPO_ID, CUIT, TIPO_CARGO_IMPOSITIVO, ALICUOTA, FECHA_INICIO, FECHA_FIN)
				SELECT ISNULL((SELECT MAX(JTS_NOVEDAD)+1 FROM CON_BITACORA_IMPUESTOS),0), (SELECT FECHAPROCESO FROM PARAMETROS (NOLOCK)), (select convert(varchar,getdate(),108)), @codCli, @nroPersona, ''C'', @cuit, TIPOCARGO, 0, @fechaDesde, @fechaHasta
				FROM CI_CARGOS_TARIFAS A JOIN VW_CARGOS_IMPUESTOS B ON A.ID_CARGO = B.ID_CARGO 
				WHERE a.id_cliente = @codCli AND a.TASA = 0 AND TZ_LOCK = 0 AND (fecha_hasta <>  @fechaHasta or fecha_desde <> @fechaDesde) And a.ID_CARGO IN (SELECT ID_CARGO FROM VW_CARGOS_IMPUESTOS);				
				
							
				--luego de guardar en el log y bitacora, updateo
				UPDATE CI_CARGOS_TARIFAS SET fecha_hasta = @fechaHasta, fecha_desde = @fechaDesde
				WHERE id_cliente = @codCli AND TASA = 0 AND TZ_LOCK = 0 AND (fecha_hasta <>  @fechaHasta or fecha_desde <> @fechaDesde)	And ID_CARGO IN (SELECT ID_CARGO FROM VW_CARGOS_IMPUESTOS);
		   	END
		   	  
			   			 		   
			--para el reporte de inconsistencias
			SET @condIVA = (SELECT IVA FROM CLI_CLIENTES WHERE CODIGOCLIENTE = @codCli);			
			IF @condIVA <> ''AC''			 
			   	INSERT INTO ITF_AFIP_RG18_INCONSISTENCIAS (COD_CLIENTE, NRO_PERSONA, CUIT, RAZON_SOCIAL, CONDICION_IVA, TIPO_CERTIFICADO,	PORCENTAJE,	FECHA_DESDE,FECHA_HASTA)
				VALUES (@codCli, @nroPersona, @cuit, @razonSocial,  @condIVA,''RG18'' , 0,@fechaDesde, @fechaHasta);
		   				   		
		FETCH NEXT FROM cursorCli INTO @codCli, @nroPersona
		END --Fin del WHILE    	
		CLOSE cursorCli --Cerrar el CURSOR cli
		DEALLOCATE cursorCli	   
  		
   	FETCH NEXT FROM cursorOk INTO @cuit, @razonSocial, @fechaDesde, @fechaHasta, @incisoRG
   	END --Fin del WHILE
	CLOSE cursorOk --Cerrar el CURSOR ok
	DEALLOCATE cursorOk

	
END
')