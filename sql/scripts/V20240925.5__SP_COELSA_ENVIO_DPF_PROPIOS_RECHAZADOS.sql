ALTER PROCEDURE [dbo].[SP_COELSA_ENVIO_DPF_PROPIOS_RECHAZADOS]
   @TICKET NUMERIC(16),
   @MONEDA NUMERIC(4)
AS 
BEGIN
	
	------------ Limpieza de tabla auxiliar --------------------
	TRUNCATE TABLE dbo.ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX;
	------------------------------------------------------------
	
	--- Variables Cabecera Archivo (CA)
	DECLARE @CA_ID_REG VARCHAR(1) = '1'; -- fijo
	DECLARE @CA_CODIGO_PRIORIDAD VARCHAR (2)= '01'; -- fijo
	DECLARE @CA_DESTINO_INMEDIATO VARCHAR (10)= ' 000000010'; --fijo
	DECLARE @CA_ORIGEN_INMEDIATO VARCHAR(10) = (SELECT ' 031100'+CAST((SELECT NUMERICO FROM PARAMETROSGENERALES WHERE CODIGO=40) AS VARCHAR)+'0'); 
	DECLARE @CA_FECHA_PRESENTACION VARCHAR(6)= convert(VARCHAR,(SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)), 12); -- fijo
	DECLARE @CA_HORA_PRESENTACION VARCHAR(4)= concat (SUBSTRING((SELECT CONVERT (VARCHAR(8), SYSDATETIME(),24)),1,2), SUBSTRING((SELECT CONVERT (VARCHAR(8), SYSDATETIME(),24)),4,5)); -- fijo
	DECLARE @CA_IDENTIFICADOR_ARCHIVO VARCHAR(1) = '1'; --
	DECLARE @CA_TAMANNO_REGISTRO VARCHAR(3)= '094'; -- fijo
	DECLARE @CA_FACTOR_BLOQUE VARCHAR(2)= '10'; -- fijo
	DECLARE @CA_CODIGO_FORMATO VARCHAR(1)= '1'; -- fijo
	DECLARE @CA_NOMBRE_DEST_INMEDIATO VARCHAR(23)= 'COELSA                 '; -- fijo
	DECLARE @CA_NOMBRE_ORIG_INMEDIATO VARCHAR(23)='NUEVO BCO CHACO S.A.   '; -- fijo
	DECLARE @CA_CODIGO_REFERENCIA VARCHAR(8) = 'CHQ.RECH'; --Se conforma con espacios vacíos.
	
	DECLARE @CA_CABECERA VARCHAR(200);
	
	SET @CA_CABECERA = concat(@CA_ID_REG
							, @CA_CODIGO_PRIORIDAD
							, @CA_DESTINO_INMEDIATO
							, @CA_ORIGEN_INMEDIATO
							, @CA_FECHA_PRESENTACION
							, @CA_HORA_PRESENTACION
							, @CA_IDENTIFICADOR_ARCHIVO
							, @CA_TAMANNO_REGISTRO
							, @CA_FACTOR_BLOQUE
							, @CA_CODIGO_FORMATO
							, @CA_NOMBRE_DEST_INMEDIATO
							, @CA_NOMBRE_ORIG_INMEDIATO
							, @CA_CODIGO_REFERENCIA);
	
	
	--- Variables cabecera lote (CL)
	DECLARE @CL_ID_REG VARCHAR(1) = '5'; -- fijo
	DECLARE @CL_CODIGO_CLASE_TRANSAC VARCHAR(3) = '200'; -- fijo 
	DECLARE @CL_RESERVADO VARCHAR(46) = replicate(' ', 46); -- 3 campos reservados
	DECLARE @CL_TIPO_REGISTRO VARCHAR(3) = 'TRC'; -- fijo 
	DECLARE @CL_DESCRIP_TRANSAC VARCHAR(10) = '          '; -- fijo
	DECLARE @CL_FECHA_PRESENTACION VARCHAR(6) = convert(VARCHAR,(SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)), 12);
	DECLARE @CL_FECHA_VENCIMIENTO VARCHAR(6) = convert(VARCHAR,(SELECT FECHAPROXIMOPROCESO FROM PARAMETROS WITH(NOLOCK)), 12); 
	DECLARE @CL_RESERVADO_CL VARCHAR(3) = '000'; -- fijo
	DECLARE @CL_CODIGO_ORIGEN VARCHAR(1) = '1'; -- fijo
	DECLARE @CL_ID_ENTIDAD_ORIGEN VARCHAR(8) = (SELECT '031100'+CAST((SELECT NUMERICO FROM PARAMETROSGENERALES WHERE CODIGO=40) AS VARCHAR)); 
	DECLARE @CL_NUMERO_LOTE VARCHAR(7) = RIGHT(concat(replicate('0', 7), 1), 7); -- numero del lote
	
	DECLARE @CL_CABECERA VARCHAR(200);
	
	SET @CL_CABECERA = concat(@CL_ID_REG
							, @CL_CODIGO_CLASE_TRANSAC
							, @CL_RESERVADO
							, @CL_TIPO_REGISTRO
							, @CL_DESCRIP_TRANSAC
							, @CL_FECHA_PRESENTACION
							, @CL_FECHA_VENCIMIENTO
							, @CL_RESERVADO_CL
							, @CL_CODIGO_ORIGEN
							, @CL_ID_ENTIDAD_ORIGEN
							, @CL_NUMERO_LOTE);
	
	/*---- Grabamos cabecera de lote y archivo solo si hay registros individuales ingresados
	IF(0<(SELECT COUNT(*) FROM ITF_COELSA_CHEQUES_RECHAZO WHERE ESTADO = 'P' AND TIPO = 'D' AND SUBSTRING(INFO_ADICIONAL, 1, 1) = @MONEDA  AND FECHAPROCESO = (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK))))
		BEGIN*/
			---------------- Grabar Cabecera Archivo ---------------------------
			INSERT INTO dbo.ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX (LINEA) VALUES (@CA_CABECERA);
			--------------------------------------------------------------------
			---------------- Grabar Cabecera Lote ---------------------------
			INSERT INTO dbo.ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX (LINEA) VALUES (@CL_CABECERA);
			-----------------------------------------------------------------
		--END
	
	------ Variables registro individual ( RI) ------------
	DECLARE @RI_ID_REG VARCHAR(1) = '6'; -- fijo  
	DECLARE @RI_ENTIDAD_DEBITAR VARCHAR(8);
	DECLARE @RI_RESERVADO VARCHAR(1) = '0'; -- fijo 
	DECLARE @RI_CUENTA_DEBITAR VARCHAR(17); 
	DECLARE @RI_IMPORTE VARCHAR(16); 
	DECLARE @RI_NUMERO_CHEQUE VARCHAR(15);
	DECLARE @RI_CODIGO_POSTAL VARCHAR(6); 
	DECLARE @RI_PUNTO_INTERCAMBIO VARCHAR(10) = '0000      ';
	DECLARE @RI_INFO_ADICIONAL VARCHAR(2);
	DECLARE @RI_REGISTRO_ADICIONAL VARCHAR(1); 
	DECLARE @RI_CONTADOR_REGISTRO VARCHAR(15);
								
	DECLARE @RI_REGISTRO_INDIVIDUAL VARCHAR (200);
	
	------ Variables registro ajuste ( RA) ------------
	
	DECLARE @RA_ID_REG_ADICIONAL VARCHAR(6) = '799   ';
	DECLARE @RA_CONTADOR_REGISTRO_ORIGEN VARCHAR(15);
	DECLARE @RA_NUMERO_CERTIFIFADO VARCHAR(6) = '      ';
	DECLARE @RA_ENTIDAD_ORIGINAL VARCHAR(8) = '        ';
	DECLARE @RA_OTRO_MOTIVO_RECH VARCHAR(44) = '                                             ';
	
	--- Variables fin de lote FL
	DECLARE @FL_ID_REG VARCHAR(1) = '8'; -- fijo 
	DECLARE @FL_CODIGO_CLASE_TRANSAC VARCHAR(3) = '200'; -- fijo 
	DECLARE @FL_CANT_REG_INDIVIDUAL_ADICIONAL VARCHAR(6) = 0; --registros individuales y adicionales que existen en el lote
	DECLARE @FL_TOTALES_DE_CONTROL VARCHAR(10) = 0;
	DECLARE @FL_SUMA_TOTAL_DEBITO_LOTE VARCHAR(20); 
	DECLARE @FL_SUMA_TOTAL_CREDITO_LOTE VARCHAR(20); 
	DECLARE @FL_RESERVADO1 VARCHAR(10) = '          '; -- fijo
	DECLARE @FL_RESERVADO2 VARCHAR(5) = '     '; -- fijo
	DECLARE @FL_RESERVADO3 VARCHAR(4) = '    '; -- fijo
	DECLARE @FL_REG_ENTIDAD_ORIGEN VARCHAR(8) = (SELECT '0311'+ RIGHT(concat(replicate('0', 4), CAST((SELECT NUMERICO FROM PARAMETROSGENERALES WHERE CODIGO=40) AS VARCHAR)), 4)); 
	DECLARE @FL_NUMERO_LOTE VARCHAR(7) = '0000001'; 
	DECLARE @FL_FIN_LOTE VARCHAR(200);
	
	--- Variables fin de Archivo FA
	DECLARE @FA_ID_REG VARCHAR(1) = '9'; -- fijo  
	DECLARE @FA_CANT_LOTES VARCHAR(6);-- total de lotes que contiene el archivo
	DECLARE @FA_NUMERO_BLOQUES VARCHAR(6);-- ver detalles en doc pdf
	DECLARE @FA_CANT_REG_INDIVIDUAL_ADICIONAL VARCHAR(8); --total de registros individuales y adicionales que existen en el archivo
	DECLARE @FA_TOTALES_DE_CONTROL VARCHAR(10);
	DECLARE @FA_SUMA_TOTAL_DEBITOS VARCHAR(20);
	DECLARE @FA_SUMA_TOTAL_CREDITOS VARCHAR(20);
	DECLARE @FA_RESERVADO  VARCHAR(100) = replicate(' ', 23); -- fijo
	
	DECLARE @FA_FIN_ARCHIVO VARCHAR (200);
	
	
	
	------- Variables generales ------------
	DECLARE @SumaImportes NUMERIC(15,2) = 0;
	DECLARE @TotalesControl NUMERIC(10) = 0;
	DECLARE @TotalesDebitos NUMERIC(15,2) = 0;
	DECLARE @TotalesCreditos NUMERIC(15,2) = 0;
	DECLARE @CantRegistros NUMERIC(15) = 0;
	DECLARE @CantRegistrosPrev NUMERIC(6)= 0;
	DECLARE @Cant_Reg_Individual_Adicional VARCHAR(6)= 0;
	
	DECLARE @SumaEntidad NUMERIC = 0;
	DECLARE @SumaSucursal NUMERIC = 0;
	DECLARE @SobranteSucursal NUMERIC = 0;
	DECLARE @Excedente NUMERIC(15,2) = 0;
	DECLARE @CountExcedente INT = 0;
	
	------------------------------------------
	
	DECLARE @T_ENTIDAD_DEBITAR VARCHAR(8);
	DECLARE @T_CODIGO_TRANSACCION VARCHAR(2);
	DECLARE @T_CUENTA_DEBITAR VARCHAR(17);
	DECLARE @T_IMPORTE NUMERIC(15,2);
	DECLARE @T_NRO_CHEQUE VARCHAR(15);
	DECLARE @T_CODIGO_POSTAL VARCHAR(6);
	DECLARE @T_PUNTO_INTERCAMBIO VARCHAR(16);
	DECLARE @T_TRACE_NUMBER VARCHAR(15);
	
	    --Condicion de reset del contador de reg individual
	IF ISNULL((SELECT a.FECHA FROM ITF_MASTER_PARAMETROS a WHERE a.CODIGO = 137), CAST('01-01-1800' AS DATETIME)) <> (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK))
	    UPDATE dbo.ITF_MASTER_PARAMETROS SET NUMERICO_1 = 1, FECHA = (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)) WHERE CODIGO = 137;
	 
	
	
	DECLARE CursorDPF CURSOR FOR
				
	SELECT ENTIDAD_DEBITAR
			, CODIGO_TRANSACCION
			, CUENTA_DEBITAR
			, IMPORTE
			, NRO_CHEQUE
			, CODIGO_POSTAL
			, isnull(RIGHT('00'+INFO_ADICIONAL,2),'00')
			, PUNTO_INTERCAMBIO
			, TRACE_NUMBER
	FROM ITF_COELSA_CHEQUES_RECHAZO 
	WHERE ESTADO = 'P' 
	AND TIPO = 'D' 
	AND SUBSTRING(INFO_ADICIONAL, 1, 1) = @MONEDA  
	AND FECHAPROCESO = (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK))
	
					        		
	OPEN CursorDPF
	FETCH NEXT FROM CursorDPF INTO @T_ENTIDAD_DEBITAR
									, @T_CODIGO_TRANSACCION
									, @T_CUENTA_DEBITAR
									, @T_IMPORTE
									, @T_NRO_CHEQUE
									, @T_CODIGO_POSTAL
									, @RI_INFO_ADICIONAL
									, @T_PUNTO_INTERCAMBIO
									, @T_TRACE_NUMBER
	
	WHILE @@FETCH_STATUS = 0
	BEGIN
		Start_1:
		IF (@SumaImportes > 999999999999999999.99 OR @SumaEntidad > 999999) -- 99 millones
		BEGIN
			
			IF @SumaSucursal > 9999
			BEGIN
				SET @SobranteSucursal = CAST(substring(CAST(@SumaSucursal AS VARCHAR), 1, (len(@SumaSucursal) - 4)) AS NUMERIC);
				SET @SumaEntidad += @SobranteSucursal;
				SET @SumaSucursal = CAST(RIGHT(@SumaSucursal, 4) AS NUMERIC);
			END
			
		   --	SET @TotalesControl += @SumaEntidad + @SumaSucursal;
	   		SET @FL_TOTALES_DE_CONTROL =RIGHT(concat(replicate('0', 10), (SELECT sum(convert(bigINT,substring(t.LINEA,4,8))) FROM ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX t WHERE t.ID>(SELECT max(tt.id) FROM ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX tt WHERE tt.LINEA LIKE '5%') AND substring(t.LINEA,1,1) IN ('6'))), 10);
	   		SET @FL_SUMA_TOTAL_DEBITO_LOTE =  RIGHT(concat(replicate('0', 20), (replace((SELECT sum(convert(bigint, substring(linea,61,16))) FROM ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '6%' AND LINEA NOT LIKE '622%' AND id>(SELECT max(id) FROM ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '5%')), '.', ''))), 20); 
	   		SET @FL_SUMA_TOTAL_CREDITO_LOTE = RIGHT(concat(replicate('0', 20), (replace((SELECT sum(convert(bigint, substring(linea,61,16))) FROM ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '622%' AND id>(SELECT max(id) FROM ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '5%')), '.', ''))), 20); 
	   		SET @TotalesDebitos += @SumaImportes;
	   		SET @FL_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate('0', 6), (SELECT count(id) FROM ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX t WHERE t.ID>(SELECT max(tt.id) FROM ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX tt WHERE tt.LINEA LIKE '5%') AND substring(t.LINEA,1,1) IN ('6','7'))), 6);	
		   	
		   	SET @FL_FIN_LOTE = concat(@FL_ID_REG
										, @FL_CODIGO_CLASE_TRANSAC
										, @FL_CANT_REG_INDIVIDUAL_ADICIONAL
										, @FL_TOTALES_DE_CONTROL
										, @FL_SUMA_TOTAL_DEBITO_LOTE
										, @FL_SUMA_TOTAL_CREDITO_LOTE
										, @FL_RESERVADO1
										, @FL_RESERVADO2
										, @FL_RESERVADO3
										, @FL_REG_ENTIDAD_ORIGEN
										, @FL_NUMERO_LOTE);
			
	    
		
			INSERT INTO dbo.ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX (LINEA) VALUES (replace(@FL_FIN_LOTE, '.', ''));
			
			SET @FL_NUMERO_LOTE = CAST(@FL_NUMERO_LOTE AS NUMERIC) + 1;
			SET @FL_NUMERO_LOTE = RIGHT(concat(replicate('0', 7), @FL_NUMERO_LOTE), 7);
			-------------------------------------------------------------------
			-------------Grabamos el Fin de Archivo ----------------------------------------------------------------------------------------------------------------------
			SET @FA_CANT_LOTES = RIGHT(concat(replicate('0', 6), (SELECT count(ID) FROM ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '5%'AND id>(SELECT max(ID) FROM ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '1%'))), 6);
			SET @CantRegistrosPrev = (SELECT (CASE WHEN (@CantRegistros + 4) % 10 = 0 THEN ((@CantRegistros + 4)/10) ELSE (FLOOR((@CantRegistros + 4)/10) + 1) END));
			SET @FA_NUMERO_BLOQUES = RIGHT(concat(replicate('0', 6), (SELECT CEILING((count(*)+1) / CONVERT(FLOAT, 10)) FROM ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX WHERE  ID>=(SELECT max(id) FROM ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '1%'))), 6);
	
			SET @FA_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate('0', 8), (SELECT count(id) FROM ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX t WHERE t.ID>(SELECT max(tt.id) FROM ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX tt WHERE tt.LINEA LIKE '1%') AND substring(t.LINEA,1,1) IN ('6','7'))), 8);
			
			SET @FA_TOTALES_DE_CONTROL =  RIGHT(concat(replicate('0', 10), (SELECT sum(convert(bigINT,substring(t.LINEA,4,8))) FROM ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX t WHERE t.ID>(SELECT max(tt.id) FROM ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX tt WHERE tt.LINEA LIKE '1%') AND substring(t.LINEA,1,1) IN ('6'))), 10);
			
			SET @FA_SUMA_TOTAL_DEBITOS = RIGHT(concat(replicate('0', 20), (replace((SELECT sum(convert(bigint, substring(linea,61,16))) FROM ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '6%' AND LINEA NOT LIKE '622%' AND id>(SELECT max(id) FROM ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '1%')), '.', ''))), 20);
		
			SET @FA_SUMA_TOTAL_CREDITOS = RIGHT(concat(replicate('0', 20), (replace((SELECT sum(convert(bigint, substring(linea,61,16))) FROM ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '622%' AND id>(SELECT max(id) FROM ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '1%')), '.', ''))), 20);
	
			SET @FA_FIN_ARCHIVO = concat(@FA_ID_REG, @FA_CANT_LOTES, @FA_NUMERO_BLOQUES, @FA_CANT_REG_INDIVIDUAL_ADICIONAL, @FA_TOTALES_DE_CONTROL, @FA_SUMA_TOTAL_DEBITOS, @FA_SUMA_TOTAL_CREDITOS, @FA_RESERVADO);
			
			INSERT INTO dbo.ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX (LINEA) VALUES (@FA_FIN_ARCHIVO);
			------------------------------------------------------------------------------------------------------------------------------------------------------------------
			---------- Limpiamos variables -----------------------------------------------------------------------------------------------------------------------------------
			SET @SumaImportes = 0;
			SET @CantRegistros = 0;
			SET @CantRegistrosPrev = 0;
			
			SET @TotalesControl = 0;
			SET @TotalesDebitos = 0;
			SET @TotalesCreditos = 0;
	
			SET @SumaEntidad = 0;
			SET @SumaSucursal = 0;
			SET @Cant_Reg_Individual_Adicional = 0;
			SET @FL_TOTALES_DE_CONTROL = 0;
			SET @FA_SUMA_TOTAL_DEBITOS = 0;
			SET @FA_SUMA_TOTAL_CREDITOS = 0;
			SET @SumaSucursal =0;
			-------------------------------------------------------------------------------------------------------------------------------------------------------------------
			--------- Grabamos nueva Cabecera de Archivo ----------------------------------------------------------------------------------------------------------------------
			SET @CA_CABECERA = concat(@CA_ID_REG, @CA_CODIGO_PRIORIDAD, @CA_DESTINO_INMEDIATO, @CA_ORIGEN_INMEDIATO, @CA_FECHA_PRESENTACION, @CA_HORA_PRESENTACION, @CA_IDENTIFICADOR_ARCHIVO, @CA_TAMANNO_REGISTRO, @CA_FACTOR_BLOQUE, @CA_CODIGO_FORMATO, @CA_NOMBRE_DEST_INMEDIATO, @CA_NOMBRE_ORIG_INMEDIATO, @CA_CODIGO_REFERENCIA);
			
			INSERT INTO dbo.ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX (LINEA) VALUES (@CA_CABECERA);
			----------------------------------------------------------------------------------------------------------------------------------------------------------------------
			--------- Grabamos nueva Cabecera Lote ------------------------------------------------------------------------------------------------------------------------------------------------------
			SET @CL_NUMERO_LOTE = RIGHT(concat(replicate('0', 7), (@CL_NUMERO_LOTE + 1)), 7);
			SET @CL_CABECERA = concat(@CL_ID_REG, @CL_CODIGO_CLASE_TRANSAC, @CL_RESERVADO, @CL_TIPO_REGISTRO, @CL_DESCRIP_TRANSAC, @CL_FECHA_PRESENTACION, @CL_FECHA_VENCIMIENTO, @CL_RESERVADO_CL, @CL_CODIGO_ORIGEN, @CL_ID_ENTIDAD_ORIGEN, @CL_NUMERO_LOTE);
			INSERT INTO dbo.ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX (LINEA) VALUES (@CL_CABECERA);
			---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
		END
		
		SET @CantRegistros += 1;
		SET @Cant_Reg_Individual_Adicional += 1;
		
		IF	(@Excedente<>0)
		BEGIN
			SET @T_IMPORTE = @Excedente;
			SET @CountExcedente += 1;
		END
		IF	(@T_IMPORTE>99999999999999.99)
		BEGIN
			SET @Excedente = (@T_IMPORTE - 99999999999999.99);
			SET @T_IMPORTE = 99999999999999.99;
			SET @CountExcedente += 1;
			--SET @RA_CONTADOR_REGISTRO_ORIGEN = @RI_CONTADOR_REGISTRO;
		END
		ELSE
	    BEGIN
	       SET @Excedente = 0;
	    END
		
		/*
		SET @SumaSucursal += CONVERT(NUMERIC(4),RIGHT(@T_ENTIDAD_DEBITAR,4));
		SET @SumaEntidad += CONVERT(NUMERIC(4),LEFT(RIGHT(concat(replicate('0', 8), @T_ENTIDAD_DEBITAR), 8),4));
		SET @SumaImportes += @T_IMPORTE;
		*/
		---------------------------- Grabar Registro Individual -----------------------------------------------------------------------------------------------------------------------------------------
		SET @RI_ENTIDAD_DEBITAR = RIGHT(concat(replicate('0', 8), @T_ENTIDAD_DEBITAR), 8);
	    SET @RI_CUENTA_DEBITAR = RIGHT(concat(replicate('0', 17), @T_CUENTA_DEBITAR), 17);
	    SET @RI_NUMERO_CHEQUE = concat('00', RIGHT(concat(replicate('0', 13), @T_NRO_CHEQUE), 13));
	    
	    IF(@CountExcedente>1)
		BEGIN
	        SET @SumaSucursal += 0888;  --sumo la sucursal que hay que harcodear
	        SET @SumaEntidad +=  CONVERT(NUMERIC(4),LEFT(RIGHT(concat(replicate('0', 8), @T_ENTIDAD_DEBITAR), 8),4));
	        SET @SumaImportes += @T_IMPORTE;
	
	        SET @RI_ENTIDAD_DEBITAR = concat(LEFT(RIGHT(concat(replicate('0', 8), @T_ENTIDAD_DEBITAR), 8),4), '0888');
	        SET @RI_CUENTA_DEBITAR = RIGHT(concat(replicate('0', 17), '88888888888'), 17);
	        SET @RI_NUMERO_CHEQUE = '000088888888888';
	
	   
	   	END
	    ELSE --la razon de este else, es que SumaSucursal, cuando hay excedente tiene que acumular 0888
	    BEGIN
	        SET @SumaSucursal += CONVERT(NUMERIC(4),RIGHT(@T_ENTIDAD_DEBITAR,4));
			SET @SumaEntidad += CONVERT(NUMERIC(4),LEFT(RIGHT(concat(replicate('0', 8), @T_ENTIDAD_DEBITAR), 8),4));
			SET @SumaImportes += @T_IMPORTE;
	
	        SET @RI_ENTIDAD_DEBITAR = RIGHT(concat(replicate('0', 8), @T_ENTIDAD_DEBITAR), 8);
	        
	        SET @RI_CUENTA_DEBITAR = RIGHT(concat(replicate('0', 17), @T_CUENTA_DEBITAR), 17);
	        
	        SET @RI_NUMERO_CHEQUE = concat('00', RIGHT(concat(replicate('0', 13), @T_NRO_CHEQUE), 13));
	 
	    END
	
		IF @SumaImportes>999999999999999999.99 GOTO Start_1

	    SET @RI_IMPORTE = RIGHT(concat(replicate('0', 16), replace(CAST(@T_IMPORTE AS VARCHAR),'.','')), 16);
	    SET @RI_CODIGO_POSTAL = RIGHT(concat('00', replicate('0', 6), @T_CODIGO_POSTAL), 6);
	    --SET @RI_INFO_ADICIONAL = @MONEDA;
	    SET @RI_REGISTRO_ADICIONAL = '0';
	    
	    IF(@MONEDA=1)
	    SET @RI_CONTADOR_REGISTRO = concat('0811', RIGHT(concat(replicate('0', 4), ('97')), 4), RIGHT(concat(replicate('0', 7), (SELECT NUMERICO_1 FROM ITF_MASTER_PARAMETROS WHERE CODIGO = 137)), 7)); 
	    ELSE
	    SET @RI_CONTADOR_REGISTRO = concat('0311', RIGHT(concat(replicate('0', 4), ('97')), 4), RIGHT(concat(replicate('0', 7), (SELECT NUMERICO_1 FROM ITF_MASTER_PARAMETROS WHERE CODIGO = 137)), 7)); 
	     
	        	
		SET @RI_REGISTRO_INDIVIDUAL = concat(@RI_ID_REG
											, @T_CODIGO_TRANSACCION
											, @RI_ENTIDAD_DEBITAR
											, @RI_RESERVADO
											, @RI_CUENTA_DEBITAR
											, @RI_PUNTO_INTERCAMBIO											
											, @RI_NUMERO_CHEQUE
											, @RI_CODIGO_POSTAL
											, @RI_IMPORTE
											, @RI_INFO_ADICIONAL
											, @RI_REGISTRO_ADICIONAL
											, @RI_CONTADOR_REGISTRO);
	 
	    
	    INSERT INTO dbo.ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX (LINEA) VALUES (@RI_REGISTRO_INDIVIDUAL);
		-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		----------------------------- Actualizar secuencial unico -------------------------------------
		UPDATE dbo.ITF_MASTER_PARAMETROS SET NUMERICO_1 = (NUMERICO_1 + 1) WHERE CODIGO = 137;
		-----------------------------------------------------------------------------------------------
		/*
		----------------------------- Grabar historial ---------------------------------------------------------------------------------------------------------------------------------------------------------------
	    INSERT INTO ITF_COELSA_CHEQUES_OTROS (ID_TICKET, ID_PROCESO, FECHAPROCESO, CODIGO_TRANSACCION, BANCO, SUCURSAL, CUENTA, IMPORTE, CODIGO_POSTAL, FECHA_PRESENTADO, FECHA_VENCIMIENTO, NRO_CHEQUE, PUNTO_INTERCAMBIO, TRACE_NUMBER, ESTADO, TIPO, MONEDA, TIPO_DOCUMENTO)
	    VALUES (@TICKET, @TICKET, (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)), @RI_CODIGO_TRANSAC, @D_BANCO, @D_SUCURSAL, @D_CUENTA, @D_IMPORTE, @D_CODIGO_POSTAL, @D_FECHA, @D_FECHA, @D_NUMERO_DPF, @RI_PUNTO_INTERCAMBIO, @RI_CONTADOR_REGISTRO, 'P', 'D', @D_MONEDA, @D_TIPO_DOCUMENTO);
	    --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		
		---------------- Actualizar informacion del dpf --------------------------------------------------------------------------------------------------------------------------------------
		UPDATE dbo.CLE_DPF_SALIENTE SET TRACKNUMBER = @RI_CONTADOR_REGISTRO, ESTADO = 2, FECHA_ENVIO_COMPENSACION = (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK))
	    WHERE TIPO_DOCUMENTO = @D_TIPO_DOCUMENTO AND NUMERO_DPF = @D_NUMERO_DPF AND BANCO_GIRADO = @D_BANCO AND SUCURSAL_BANCO_GIRADO = @D_SUCURSAL AND FECHA_ALTA = @D_FECHA AND TZ_LOCK = 0;
		--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------    	
		*/
		
		IF (@Excedente = 0)
		BEGIN		     	       				
		
		FETCH NEXT FROM CursorDPF INTO @T_ENTIDAD_DEBITAR, @T_CODIGO_TRANSACCION, @T_CUENTA_DEBITAR, @T_IMPORTE, @T_NRO_CHEQUE,@T_CODIGO_POSTAL,@RI_INFO_ADICIONAL,@T_PUNTO_INTERCAMBIO,@T_TRACE_NUMBER
		
		SET @CountExcedente = 0;
		--SET @RA_CONTADOR_REGISTRO_ORIGEN = '';
		END
		
	END
	
	CLOSE CursorDPF
	DEALLOCATE CursorDPF
	
	
	IF @SumaSucursal > 9999
	BEGIN
		SET @SobranteSucursal = CAST(substring(CAST(@SumaSucursal AS VARCHAR), 1, (len(@SumaSucursal) - 4)) AS NUMERIC);
	  	SET @SumaEntidad += @SobranteSucursal;
		SET @SumaSucursal = CAST(RIGHT(@SumaSucursal, 4) AS NUMERIC);
	END
	
	/*-- Grabamos fin de lote y archivo solo si hay registros individuales ingresados
	IF(0<(SELECT COUNT(*) FROM ITF_COELSA_CHEQUES_RECHAZO WHERE ESTADO = 'P' AND TIPO = 'D' AND SUBSTRING(INFO_ADICIONAL, 1, 1) = @MONEDA  AND FECHAPROCESO = (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK))))
	BEGIN
		  */	
	--SET @TotalesControl += @SumaEntidad + @SumaSucursal;
	SET @FL_TOTALES_DE_CONTROL =RIGHT(concat(replicate('0', 10), (SELECT sum(convert(bigINT,substring(t.LINEA,4,8))) FROM ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX t WHERE t.ID>(SELECT max(tt.id) FROM ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX tt WHERE tt.LINEA LIKE '5%') AND substring(t.LINEA,1,1) IN ('6'))), 10);
	--SET @TotalesControl += CAST(@FL_TOTALES_DE_CONTROL AS INTEGER);
	SET @FL_SUMA_TOTAL_DEBITO_LOTE =  RIGHT(concat(replicate('0', 20), (replace((SELECT sum(convert(bigint, substring(linea,61,16))) FROM ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '6%' AND LINEA NOT LIKE '622%' AND id>(SELECT max(id) FROM ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '5%')), '.', ''))), 20); 
	SET @FL_SUMA_TOTAL_CREDITO_LOTE = RIGHT(concat(replicate('0', 20), (replace((SELECT sum(convert(bigint, substring(linea,61,16))) FROM ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '622%' AND id>(SELECT max(id) FROM ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '5%')), '.', ''))), 20);	
	SET @FL_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate('0', 6), (SELECT count(id) FROM ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX t WHERE t.ID>(SELECT max(tt.id) FROM ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX tt WHERE tt.LINEA LIKE '5%') AND substring(t.LINEA,1,1) IN ('6','7'))), 6);	
	
	
	
	SET @FL_FIN_LOTE = concat(@FL_ID_REG
							, @FL_CODIGO_CLASE_TRANSAC
							, @FL_CANT_REG_INDIVIDUAL_ADICIONAL
							, @FL_TOTALES_DE_CONTROL
							, @FL_SUMA_TOTAL_DEBITO_LOTE
							, @FL_SUMA_TOTAL_CREDITO_LOTE
							, @FL_RESERVADO1
							, @FL_RESERVADO2
							, @FL_RESERVADO3
							, @FL_REG_ENTIDAD_ORIGEN
							, @FL_NUMERO_LOTE);
			
	INSERT INTO dbo.ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX (LINEA) VALUES (@FL_FIN_LOTE);

	---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-------------Grabamos el Fin de Archivo ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	SET @FA_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate('0', 8), (SELECT count(id) FROM ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX t WHERE t.ID>(SELECT max(tt.id) FROM ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX tt WHERE tt.LINEA LIKE '1%') AND substring(t.LINEA,1,1) IN ('6','7'))), 8);
			
	SET @FA_TOTALES_DE_CONTROL =RIGHT(concat(replicate('0', 10), (SELECT sum(convert(bigINT,substring(t.LINEA,4,8))) FROM ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX t WHERE t.ID>(SELECT max(tt.id) FROM ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX tt WHERE tt.LINEA LIKE '1%') AND substring(t.LINEA,1,1) IN ('6'))), 10); --igualo al totales de control de fin de lote pq tiene que ser igual
			
	SET @FA_SUMA_TOTAL_DEBITOS = RIGHT(concat(replicate('0', 20), (replace((SELECT sum(convert(bigint, substring(linea,61,16))) FROM ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '6%' AND LINEA NOT LIKE '622%' AND id>(SELECT max(id) FROM ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '1%')), '.', ''))), 20);
			
	SET @FA_SUMA_TOTAL_CREDITOS = RIGHT(concat(replicate('0', 20), (replace((SELECT sum(convert(bigint, substring(linea,61,16))) FROM ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '622%' AND id>(SELECT max(id) FROM ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '1%')), '.', ''))), 20);
	

	SET @FA_CANT_LOTES = RIGHT(concat(replicate('0', 6), (SELECT count(ID) FROM ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '5%'AND id>(SELECT max(ID) FROM ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '1%'))), 6);

	--SET @FA_NUMERO_BLOQUES = RIGHT(concat(replicate('0', 6), @CantRegistrosPrev ), 6);
			
	SET @FA_NUMERO_BLOQUES = RIGHT(concat(replicate('0', 6), (SELECT CEILING((count(*)+1) / CONVERT(FLOAT, 10))
																  FROM ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX 
																  WHERE  ID>=(SELECT max(id) 
																  		  		FROM ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX 
																  		  		WHERE LINEA LIKE '1%'))), 6);

	SET @FA_FIN_ARCHIVO = concat(@FA_ID_REG, @FA_CANT_LOTES, @FA_NUMERO_BLOQUES, @FA_CANT_REG_INDIVIDUAL_ADICIONAL, @FA_TOTALES_DE_CONTROL, @FA_SUMA_TOTAL_DEBITOS, @FA_SUMA_TOTAL_CREDITOS, @FA_RESERVADO);

	INSERT INTO dbo.ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX (LINEA) VALUES (@FA_FIN_ARCHIVO);
	
				
	SET @FL_NUMERO_LOTE = CAST(@FL_NUMERO_LOTE AS NUMERIC) + 1;
	SET @FL_NUMERO_LOTE = RIGHT(concat(replicate('0', 7), @FL_NUMERO_LOTE), 7);
	------------------------------------------------------------------------------------------------------------------------------------------------------------------
--END
END
GO

                      