ALTER   PROCEDURE [dbo].[SP_DD_ENVIO_PRESENTADOS_RECIVIDOS]
   @TICKET NUMERIC(16)
AS 
BEGIN

	--- Autor: Fabio Alexis Menendez --------------------

	------------ Limpieza de tabla auxiliar --------------------
	TRUNCATE TABLE dbo.ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX;
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
	DECLARE @CA_CODIGO_REFERENCIA VARCHAR(8) = '        '; --Se conforma con espacios vacíos.
	
	DECLARE @CA_CABECERA VARCHAR(200);
	
	SET @CA_CABECERA = concat(@CA_ID_REG, @CA_CODIGO_PRIORIDAD, @CA_DESTINO_INMEDIATO, @CA_ORIGEN_INMEDIATO, @CA_FECHA_PRESENTACION, @CA_HORA_PRESENTACION, @CA_IDENTIFICADOR_ARCHIVO, @CA_TAMANNO_REGISTRO, @CA_FACTOR_BLOQUE, @CA_CODIGO_FORMATO, @CA_NOMBRE_DEST_INMEDIATO, @CA_NOMBRE_ORIG_INMEDIATO, @CA_CODIGO_REFERENCIA);
	
	
	--- Variables cabecera lote (CL)
	DECLARE @CL_ID_REG VARCHAR(1) = '5'; -- fijo
	DECLARE @CL_CODIGO_CLASE_TRANSAC VARCHAR(3) = '200'; -- fijo 
	--DECLARE @CL_RESERVADO VARCHAR(46) = replicate(' ', 46); -- 3 campos reservados
	DECLARE @CL_NOM_EMPRESA VARCHAR(16);
	DECLARE @CL_CRITERIO_EMPRESA VARCHAR(20);
	DECLARE @CL_ID_EMPRESA VARCHAR(10);
	DECLARE @CL_TIPO_REGISTRO VARCHAR(3) = 'PPD'; -- fijo 
	DECLARE @CL_DESCRIP_TRANSAC VARCHAR(10) = 'SERVICIOS '; -- fijo
	DECLARE @CL_FECHA_VENCIMIENTO VARCHAR(6) = convert(VARCHAR,(SELECT FECHAproximoPROCESO FROM PARAMETROS WITH(NOLOCK)), 12);
	DECLARE @CL_FECHA_COMPENSACION VARCHAR(6) = convert(VARCHAR,(SELECT dbo.AgregarDiasHabiles(fechaproximoproceso,1) FROM PARAMETROS WITH(NOLOCK)), 12);
	DECLARE @CL_RESERVADO_CL VARCHAR(3) = '000'; -- fijo
	DECLARE @CL_CODIGO_ORIGEN VARCHAR(1) = '0'; -- fijo
	DECLARE @CL_ID_ENTIDAD_ORIGEN VARCHAR(8) = (SELECT '031100'+CAST((SELECT NUMERICO FROM PARAMETROSGENERALES WHERE CODIGO=40) AS VARCHAR)); 
	DECLARE @CL_NUMERO_LOTE VARCHAR(7) = RIGHT(concat(replicate('0', 7), 0), 7); -- numero del lote
	
	DECLARE @CL_CABECERA VARCHAR(200);
	
	
	
	--SET @CL_CABECERA = concat(@CL_ID_REG, @CL_CODIGO_CLASE_TRANSAC, @CL_RESERVADO, @CL_TIPO_REGISTRO, @CL_DESCRIP_TRANSAC, @CL_FECHA_VENCIMIENTO, @CL_FECHA_COMPENSACION, @CL_RESERVADO_CL, @CL_CODIGO_ORIGEN, @CL_ID_ENTIDAD_ORIGEN, @CL_NUMERO_LOTE);
	
	---------------- Grabar Cabecera Archivo ---------------------------
	INSERT INTO dbo.ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX (LINEA) VALUES (@CA_CABECERA);
	--------------------------------------------------------------------
			
	------ Variables registro individual ( RI) ------------
	DECLARE @RI_ID_REG VARCHAR(1) = '6'; -- fijo  
	DECLARE @RI_ENTIDAD_DEBITAR VARCHAR(8);
	DECLARE @RI_RESERVADO VARCHAR(1) = '0'; -- fijo 
	DECLARE @RI_CUENTA_DEBITAR VARCHAR(17); 
	DECLARE @RI_IMPORTE VARCHAR(11); 
	DECLARE @RI_REFERENCIA_UNIVOCA VARCHAR(15);
	DECLARE @RI_CLIENTE_PAGADOR VARCHAR(22); 
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
	DECLARE @FL_SUMA_TOTAL_DEBITO_LOTE VARCHAR(12); 
	DECLARE @FL_SUMA_TOTAL_CREDITO_LOTE VARCHAR(12); 
--	DECLARE @FL_RESERVADO1 VARCHAR(10) = '          '; -- fijo
	DECLARE @FL_RESERVADO2 VARCHAR(19) = '                   '; -- fijo
	DECLARE @FL_RESERVADO3 VARCHAR(6) = '      '; -- fijo
	DECLARE @FL_REG_ENTIDAD_ORIGEN VARCHAR(8) = (SELECT '0311'+ RIGHT(concat(replicate('0', 4), CAST((SELECT NUMERICO FROM PARAMETROSGENERALES WHERE CODIGO=40) AS VARCHAR)), 4)); 
	DECLARE @FL_NUMERO_LOTE VARCHAR(7) = '0000001'; 
	
	DECLARE @FL_FIN_LOTE VARCHAR(200);
	
	--- Variables fin de Archivo FA
	DECLARE @FA_ID_REG VARCHAR(1) = '9'; -- fijo  
	DECLARE @FA_CANT_LOTES VARCHAR(6);-- total de lotes que contiene el archivo
	DECLARE @FA_NUMERO_BLOQUES VARCHAR(8);-- ver detalles en doc pdf
	DECLARE @FA_CANT_REG_INDIVIDUAL_ADICIONAL VARCHAR(8); --total de registros individuales y adicionales que existen en el archivo
	DECLARE @FA_TOTALES_DE_CONTROL VARCHAR(10);
	DECLARE @FA_SUMA_TOTAL_DEBITOS VARCHAR(12);
	DECLARE @FA_SUMA_TOTAL_CREDITOS VARCHAR(12);
	DECLARE @FA_RESERVADO  VARCHAR(100) = replicate(' ', 39); -- fijo
	
	DECLARE @FA_FIN_ARCHIVO VARCHAR (200);
	
	------- Variables para registro adicional rechazo -------
	
	DECLARE @CODIGO_RECHAZO VARCHAR(3);
	DECLARE @TRACE_NUMBER VARCHAR(15); 
	DECLARE @OTRO_RECHAZO VARCHAR(44);
	DECLARE @RI_REGISTRO_INDIVIDUAL_ADICIONAL VARCHAR(100);
	
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
	
	DECLARE @SumaEntidad_TOT NUMERIC = 0;
	DECLARE @SumaSucursal_TOT NUMERIC = 0;
	
	DECLARE @SobranteSucursal NUMERIC = 0;
	DECLARE @Excedente NUMERIC(15,2) = 0;
	DECLARE @CountExcedente INT = 0;
	DECLARE @MONEDA INT=0;
	------------------------------------------
	
	
	DECLARE @T_JTS_OID NUMERIC(10,0);
	DECLARE @T_MONEDA NUMERIC(4,0);
	DECLARE @T_ENTIDAD_DEBITAR VARCHAR(8);
	DECLARE @T_CODIGO_CLIENTE varchar(22);
	DECLARE @T_IMPORTE NUMERIC(15,2);
	DECLARE @T_FECHA_VTO DATETIME;
	DECLARE @T_FECHA_COMP DATETIME;
	DECLARE @T_CBU VARCHAR(22);
	DECLARE @T_REFERENCIA VARCHAR(15);
--	DECLARE @T_CUENTA NUMERIC(12,0);
	DECLARE @T_SUCURSAL NUMERIC(5,0);
	DECLARE @T_COD_BANCO NUMERIC(4,0);
	DECLARE @T_CODIGO_TRANSACCION NUMERIC(3,0);
	DECLARE @T_ID_DEBITO NUMERIC(15,0);
	DECLARE @T_CUIT NUMERIC(11,0)=0;
	DECLARE @CUIT NUMERIC(11,0)=0;
	DECLARE @T_MOTIVO_RECHAZO VARCHAR(3);
	DECLARE @T_PRESTACION VARCHAR(10);


  	IF((SELECT COUNT(1)FROM SNP_DEBITOS WHERE ESTADO = 'RC' AND fecha_vto=(SELECT fechaproceso FROM PARAMETROS))=0 AND (SELECT COUNT(1) FROM ITF_DD_PRESENT_RECIB_RECHAZOS WHERE ESTADO='I' AND fecha_vto=(SELECT fechaproceso FROM PARAMETROS))=0)
	BEGIN
		---------------- Grabar Cabecera Lote ---------------------------
		SET @CL_NUMERO_LOTE = RIGHT(concat(replicate('0', 7), (@CL_NUMERO_LOTE + 1)), 7);
		SET @CL_NOM_EMPRESA =  LEFT(concat('',replicate(' ', 16)),16);
		SET @CL_CRITERIO_EMPRESA = replicate(' ', 20); -- AUN NO EXISTE AUTONUMERICO, FALTA DEFINIR 
		SET @CL_ID_EMPRESA = LEFT(concat(@T_CUIT,replicate('0', 10)),10);
		SET @CL_CODIGO_ORIGEN = RIGHT(concat(replicate('0', 1),@T_CUIT),1);
		SET @CL_DESCRIP_TRANSAC=replicate(' ',10)
		SET @CL_CABECERA = concat(@CL_ID_REG
									, @CL_CODIGO_CLASE_TRANSAC
									, @CL_NOM_EMPRESA
									, @CL_CRITERIO_EMPRESA
									, @CL_ID_EMPRESA
									, @CL_TIPO_REGISTRO
									, @CL_DESCRIP_TRANSAC
									, @CL_FECHA_VENCIMIENTO
									, @CL_FECHA_COMPENSACION
									, @CL_RESERVADO_CL
									, @CL_CODIGO_ORIGEN
									, @CL_ID_ENTIDAD_ORIGEN
									, @CL_NUMERO_LOTE);
		INSERT INTO dbo.ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX (LINEA) VALUES (@CL_CABECERA);
	END 


    --Condicion de reset del contador de reg individual
	IF ISNULL((SELECT a.FECHA FROM ITF_MASTER_PARAMETROS a WHERE a.CODIGO = 147), CAST('01-01-1800' AS DATETIME)) <> (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK))
    UPDATE dbo.ITF_MASTER_PARAMETROS SET NUMERICO_1 = 1, FECHA = (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)) WHERE CODIGO = 147;
 

	
	DECLARE CursorDD CURSOR FOR
				
	SELECT ID_DEBITO
			, SALDO_JTS_OID
			, MONEDA
			, IMPORTE
			, FECHA_VTO
			, FECHA_COMP
			, CBU
			, replace(REFERENCIA,'.','')
			, convert(VARCHAR(22),CODIGO_CLIENTE)
			, CUIT_EO
			, MOTIVO_RECHAZO
			, PRESTACION
			, isnull(INFO_ADICIONAL,'00')
	FROM SNP_DEBITOS  
	WHERE ESTADO = 'RC'
	AND fecha_vto=(SELECT fechaproceso FROM PARAMETROS)
	
	UNION 
	
	SELECT ID
			, SALDO_JTS_OID
			, MONEDA
			, IMPORTE
			, FECHA_VTO
			, FECHA_COMP
			, CBU
			, replace(REFERENCIA,'.','')
			, id_cliente_pagador
			, CUIT_EO
			, MOTIVO_RECHAZO
			, PRESTACION
			, isnull(INFO_ADICIONAL,'00')
	FROM ITF_DD_PRESENT_RECIB_RECHAZOS 
	WHERE ESTADO='I'
	AND fecha_vto=(SELECT fechaproceso FROM PARAMETROS)
	ORDER BY CUIT_EO, MONEDA
	
					        		
	OPEN CursorDD
	FETCH NEXT FROM CursorDD INTO @T_ID_DEBITO
									, @T_JTS_OID
									, @T_MONEDA
									, @T_IMPORTE
									, @T_FECHA_VTO
									, @T_FECHA_COMP
									, @T_CBU
									, @T_REFERENCIA
									, @T_CODIGO_CLIENTE
									, @T_CUIT
									, @T_MOTIVO_RECHAZO
									, @T_PRESTACION
									, @RI_INFO_ADICIONAL
	
	WHILE @@FETCH_STATUS = 0
	BEGIN
		Start:
		IF (@SumaImportes > 9999999999.99 OR @SumaEntidad > 999999) -- 99 millones
		BEGIN
PRINT 'SUPERA IMPORTES'	
			IF @SumaSucursal > 9999
			BEGIN
				SET @SobranteSucursal = CAST(substring(CAST(@SumaSucursal AS VARCHAR), 1, (len(@SumaSucursal) - 4)) AS NUMERIC);
				SET @SumaEntidad += @SobranteSucursal;
				SET @SumaSucursal = CAST(RIGHT(@SumaSucursal, 4) AS NUMERIC);
			END
			
	
		   	--SET @FL_TOTALES_DE_CONTROL = concat((RIGHT(concat(replicate('0', 6), @SumaEntidad), 6)), (RIGHT(concat(replicate('0', 4), @SumaSucursal), 4)));
		   	--SET @FL_SUMA_TOTAL_DEBITO_LOTE = RIGHT(concat(replicate('0', 12), (replace(@SumaImportes, '.', ''))), 12); 
		   	SET @FL_SUMA_TOTAL_DEBITO_LOTE = RIGHT(concat(replicate('0', 12), (replace((SELECT sum(convert(bigint, substring(linea,30,10))) FROM ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX WHERE LINEA LIKE '6%' AND id>(SELECT max(id) FROM ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX WHERE LINEA LIKE '5%')), '.', ''))), 12); 

		   	SET @FL_SUMA_TOTAL_CREDITO_LOTE = RIGHT(replicate('0', 12), 12);
		   	SET @TotalesDebitos += @SumaImportes;
--		   	SET @FL_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate('0', 6), @Cant_Reg_Individual_Adicional+@CantRegistros), 6); 
			SET @FL_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate('0', 6), (SELECT COUNT(*) FROM ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX WHERE (LINEA LIKE '6%' or linea like '7%') and id>(select max(id) from ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX where linea like '5%'))), 6); 
		   	
		   	   	--nuevo
	   		SET @FL_TOTALES_DE_CONTROL = (RIGHT(concat(replicate('0', 10), (SELECT sum(convert(numeric,substring(linea,4,8)))
																			FROM ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX
																			WHERE LINEA LIKE '6%' 
																			AND ID>(SELECT max(id) 
																					FROM ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX 
																					WHERE LINEA LIKE '5%'))), 10))
	
		   	
		   	SET @FL_FIN_LOTE = concat(@FL_ID_REG, @FL_CODIGO_CLASE_TRANSAC, @FL_CANT_REG_INDIVIDUAL_ADICIONAL, @FL_TOTALES_DE_CONTROL, @FL_SUMA_TOTAL_DEBITO_LOTE, @FL_SUMA_TOTAL_CREDITO_LOTE, @CL_ID_EMPRESA, @FL_RESERVADO2, @FL_RESERVADO3, @FL_REG_ENTIDAD_ORIGEN, @FL_NUMERO_LOTE);
			
--	    	--OJO CON ESTO-- comentado el 28/8
--	    	SET @CantRegistros = 0;
--			SET @Cant_Reg_Individual_Adicional = 0;
--			
--			SET @SumaEntidad_TOT += @SumaEntidad;
--			SET @SumaSucursal_TOT += @SumaSucursal;
--		
--				--OJO CON ESTO X2--
--			SET @SumaEntidad = 0;
--			SET @SumaSucursal = 0;
--			SET @SumaImportes=0;
			
	
		
			INSERT INTO dbo.ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX (LINEA) VALUES (replace(@FL_FIN_LOTE, '.', ''));
			
			SET @FL_NUMERO_LOTE = CAST(@FL_NUMERO_LOTE AS NUMERIC) + 1;
	
			SET @FL_NUMERO_LOTE = RIGHT(concat(replicate('0', 7), @FL_NUMERO_LOTE), 7);
			-------------------------------------------------------------------
			-------------Grabamos el Fin de Archivo ----------------------------------------------------------------------------------------------------------------------
			--SET @FA_CANT_LOTES = RIGHT(concat(replicate('0', 6), @FL_NUMERO_LOTE), 6);
			
			
		   	SET @FA_CANT_LOTES = RIGHT(concat(replicate('0', 6), (SELECT count(*) --le su,o uno al count por la linea que estamos por insertar (9%)
																	FROM ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX 
																	WHERE  LINEA LIKE '5%' AND ID>=(SELECT max(id) 
																					  		  		FROM ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX 
																	  		  						WHERE LINEA LIKE '1%'))), 6);
			
			
			
			SET @CantRegistrosPrev = (SELECT (CASE WHEN (@CantRegistros + 4) % 10 = 0 THEN ((@CantRegistros + 4)/10) ELSE (FLOOR((@CantRegistros + 4)/10) + 1) END));
	
			
			SET @FA_NUMERO_BLOQUES = RIGHT(concat(replicate('0', 6), (SELECT CEILING((count(*)+1) / CONVERT(FLOAT, 10))
																	  FROM ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX 
																	  WHERE  ID>=(SELECT max(id) 
																	  		  		FROM ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX 
																	  		  		WHERE LINEA LIKE '1%'))), 6);
		
	
			
			
	
			--SET @FA_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate('0', 8), @CantRegistros), 8);
	
			SET @FA_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate('0', 8), (SELECT sum(convert(numeric,substring(linea,5,6)))
		  																		 	FROM ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX 
																				 	WHERE LINEA LIKE '8%'
																				 	AND ID>(SELECT max(ID) FROM ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX WHERE LINEA LIKE '1%'))), 8);
	
	
	
PRINT @FA_CANT_REG_INDIVIDUAL_ADICIONAL
			
			--SET @FA_TOTALES_DE_CONTROL = @FL_TOTALES_DE_CONTROL; --igualo al totales de control de fin de lote pq tiene que ser igual
	
	
	
		   	SET @FA_TOTALES_DE_CONTROL = (RIGHT(concat(replicate('0', 10), (SELECT sum(convert(numeric,substring(linea,4,8)))
																			FROM ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX
																			WHERE LINEA LIKE '6%' 
																			AND ID>(SELECT max(id) 
																					FROM ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX 
																					WHERE LINEA LIKE '1%'))), 10))
		
				
			
			SET @FA_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate('0', 8), (SELECT sum(convert(numeric,substring(linea,5,6)))
		  																		 	FROM ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX 
																				 	WHERE LINEA LIKE '8%'
																				 	AND ID>(SELECT max(ID) FROM ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX WHERE LINEA LIKE '1%'))), 8);
	
			
			
			
--			SET @FA_SUMA_TOTAL_DEBITOS = RIGHT(concat(replicate('0', 12), (replace(@TotalesDebitos, '.', ''))), 12);
			SET @FA_SUMA_TOTAL_DEBITOS = RIGHT(concat(replicate('0', 12), (replace((SELECT convert(NUMERIC(15,2),sum(convert(NUMERIC,substring(linea,30,10)))/100) FROM ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX WHERE LINEA LIKE '6%' AND ID>(SELECT max(id) FROM ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX WHERE LINEA LIKE '1%') ), '.', ''))), 12); 

			
			SET @FA_SUMA_TOTAL_CREDITOS = RIGHT(concat(replicate('0', 12), (replace(@TotalesCreditos, '.', ''))),12);
	
	
			
			
			
			SET @FA_FIN_ARCHIVO = concat(@FA_ID_REG, @FA_CANT_LOTES, @FA_NUMERO_BLOQUES, @FA_CANT_REG_INDIVIDUAL_ADICIONAL, @FA_TOTALES_DE_CONTROL, @FA_SUMA_TOTAL_DEBITOS, @FA_SUMA_TOTAL_CREDITOS, @FA_RESERVADO);
			
	
	
			
			INSERT INTO dbo.ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX (LINEA) VALUES (@FA_FIN_ARCHIVO);
			

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
			
			INSERT INTO dbo.ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX (LINEA) VALUES (@CA_CABECERA);
			----------------------------------------------------------------------------------------------------------------------------------------------------------------------
			--------- Grabamos nueva Cabecera Lote ------------------------------------------------------------------------------------------------------------------------------------------------------
	
			SET @CUIT = @T_CUIT;
			SET @CL_NUMERO_LOTE = RIGHT(concat(replicate('0', 7), (@CL_NUMERO_LOTE + 1)), 7);
			SET @CL_NOM_EMPRESA =  LEFT(concat((SELECT NOMBRE_EMPRESA FROM SNP_PRESTACIONES_EMPRESAS WHERE CUIT_EO=@T_CUIT AND PRESTACION=@T_PRESTACION),replicate(' ', 16)),16);
			SET @CL_DESCRIP_TRANSAC=LEFT(concat(@T_PRESTACION,replicate(' ', 10)),10);

			SET @CL_CRITERIO_EMPRESA = replicate(' ', 20); -- AUN NO EXISTE AUTONUMERICO, FALTA DEFINIR 
			SET @CL_ID_EMPRESA = LEFT(@T_CUIT,10);
			
			PRINT 'CASO 1'
			PRINT @T_CUIT
			SET @CL_CODIGO_ORIGEN = RIGHT(concat(replicate('0', 1),@T_CUIT),1);
			PRINT @CL_CODIGO_ORIGEN
			
			SET @CL_NUMERO_LOTE='0000001'
			SET @FL_NUMERO_LOTE='0000001'
			
			SET @CL_CABECERA = concat(@CL_ID_REG, @CL_CODIGO_CLASE_TRANSAC, @CL_NOM_EMPRESA,@CL_CRITERIO_EMPRESA,@CL_ID_EMPRESA, @CL_TIPO_REGISTRO, @CL_DESCRIP_TRANSAC, @CL_FECHA_VENCIMIENTO, @CL_FECHA_COMPENSACION, @CL_RESERVADO_CL, @CL_CODIGO_ORIGEN, @CL_ID_ENTIDAD_ORIGEN, @CL_NUMERO_LOTE);
			
			INSERT INTO dbo.ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX (LINEA) VALUES (@CL_CABECERA);
			---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
		END
		
		IF(@T_MONEDA=(SELECT C6399 FROM MONEDAS WHERE C6403='N'))
			SET @CL_ID_ENTIDAD_ORIGEN  = (SELECT '031100'+CAST((SELECT NUMERICO FROM PARAMETROSGENERALES WHERE CODIGO=40) AS VARCHAR));
		ELSE
			SET @CL_ID_ENTIDAD_ORIGEN  = (SELECT '081100'+CAST((SELECT NUMERICO FROM PARAMETROSGENERALES WHERE CODIGO=40) AS VARCHAR));
		
		/* LOGICA PARA GRABAR LA CABECERA DE LOTE*/
		IF(@CUIT!=@T_CUIT OR @T_MONEDA!=@MONEDA)
		BEGIN
		
			IF(@CUIT!=0)
			BEGIN
				--SET @FL_TOTALES_DE_CONTROL = concat((RIGHT(concat(replicate('0', 6), @SumaEntidad), 6)), (RIGHT(concat(replicate('0', 4), @SumaSucursal), 4)));
--			   	SET @FL_SUMA_TOTAL_DEBITO_LOTE = RIGHT(concat(replicate('0', 12), (replace(@SumaImportes, '.', ''))), 12); 
			   	SET @FL_SUMA_TOTAL_DEBITO_LOTE = RIGHT(concat(replicate('0', 12), (replace((SELECT convert(NUMERIC(15,2),sum(convert(NUMERIC,substring(linea,30,10)))/100) FROM ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX WHERE LINEA LIKE '6%' AND ID>(SELECT max(id) FROM ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX WHERE LINEA LIKE '5%') ), '.', ''))), 12); 

			   	SET @FL_SUMA_TOTAL_CREDITO_LOTE = RIGHT(replicate('0', 12), 12);
			   	SET @TotalesDebitos += @SumaImportes;
--			   	SET @FL_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate('0', 6), @Cant_Reg_Individual_Adicional+@CantRegistros), 6); 
			   	SET @FL_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate('0', 6), (SELECT COUNT(*) FROM ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX WHERE (LINEA LIKE '6%' or linea like '7%') and id>(select max(id) from ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX where linea like '5%'))), 6); 

			   	--nuevo
			   	SET @FL_TOTALES_DE_CONTROL = (RIGHT(concat(replicate('0', 10), (SELECT sum(convert(numeric,substring(linea,4,8)))
																				FROM ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX
																				WHERE LINEA LIKE '6%' 
																				AND ID>(SELECT max(id) 
																						FROM ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX 
																						WHERE LINEA LIKE '5%'))), 10))
			   	
			   	
			   	SET @FL_FIN_LOTE = concat(@FL_ID_REG
			   								, @FL_CODIGO_CLASE_TRANSAC
			   								, @FL_CANT_REG_INDIVIDUAL_ADICIONAL
			   								, @FL_TOTALES_DE_CONTROL
			   								, @FL_SUMA_TOTAL_DEBITO_LOTE
			   								, @FL_SUMA_TOTAL_CREDITO_LOTE
			   								, @CL_ID_EMPRESA
			   								, @FL_RESERVADO2
			   								, @FL_RESERVADO3
			   								, @FL_REG_ENTIDAD_ORIGEN
			   								, @FL_NUMERO_LOTE);
			
--			    --OJO CON ESTO--
--			    SET @CantRegistros = 0;
--				SET @Cant_Reg_Individual_Adicional = 0;
--				
--				SET @SumaEntidad_TOT += @SumaEntidad;
--				SET @SumaSucursal_TOT += @SumaSucursal;
--			
--					--OJO CON ESTO X2--
--				SET @SumaEntidad = 0;
--				SET @SumaSucursal = 0;
--				SET @SumaImportes=0;
--			
				SET @FL_NUMERO_LOTE = CAST(@FL_NUMERO_LOTE AS NUMERIC) + 1;
			
				SET @FL_NUMERO_LOTE = RIGHT(concat(replicate('0', 7), @FL_NUMERO_LOTE), 7);
				
				INSERT INTO dbo.ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX (LINEA) VALUES (replace(@FL_FIN_LOTE, '.', ''));
					
				
		
			END
		
			SET @CUIT = @T_CUIT;
			SET @MONEDA = @T_MONEDA;
			
			SET @CL_NUMERO_LOTE = RIGHT(concat(replicate('0', 7), (@CL_NUMERO_LOTE + 1)), 7);
			SET @CL_NOM_EMPRESA =  LEFT(concat((SELECT NOMBRE_EMPRESA FROM SNP_PRESTACIONES_EMPRESAS WHERE CUIT_EO=@T_CUIT AND PRESTACION=@T_PRESTACION),replicate(' ', 16)),16);
			SET @CL_DESCRIP_TRANSAC=LEFT(concat(@T_PRESTACION,replicate(' ', 10)),10);
			SET @CL_CRITERIO_EMPRESA = replicate(' ', 20); -- AUN NO EXISTE AUTONUMERICO, FALTA DEFINIR 
			SET @CL_ID_EMPRESA = LEFT(concat(@T_CUIT,replicate('0', 10)),10);
			
			PRINT 'CASO 1'
			PRINT @T_CUIT
			SET @CL_CODIGO_ORIGEN = RIGHT(concat(replicate('0', 1),@T_CUIT),1);
			PRINT @CL_CODIGO_ORIGEN
		
			SET @CL_CABECERA = concat(@CL_ID_REG, @CL_CODIGO_CLASE_TRANSAC, @CL_NOM_EMPRESA,@CL_CRITERIO_EMPRESA,@CL_ID_EMPRESA, @CL_TIPO_REGISTRO, @CL_DESCRIP_TRANSAC, @CL_FECHA_VENCIMIENTO, @CL_FECHA_COMPENSACION, @CL_RESERVADO_CL, @CL_CODIGO_ORIGEN, @CL_ID_ENTIDAD_ORIGEN, @CL_NUMERO_LOTE);
			
	
			
			INSERT INTO dbo.ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX (LINEA) VALUES (@CL_CABECERA);
		
			IF(@T_MONEDA=(SELECT C6399 FROM MONEDAS WHERE C6403='N'))	
				SET @FL_REG_ENTIDAD_ORIGEN = (SELECT '0311'+ RIGHT(concat(replicate('0', 4), CAST((SELECT NUMERICO FROM PARAMETROSGENERALES WHERE CODIGO=40) AS VARCHAR)), 4)); 
			ELSE
				SET @FL_REG_ENTIDAD_ORIGEN = (SELECT '0811'+ RIGHT(concat(replicate('0', 4), CAST((SELECT NUMERICO FROM PARAMETROSGENERALES WHERE CODIGO=40) AS VARCHAR)), 4)); 
		END
		
--  		IF (@T_JTS_OID IS NOT NULL)
-- 		BEGIN
--		   	SELECT @T_SUCURSAL=SUCURSAL, @T_CUENTA=CUENTA FROM SALDOS WHERE JTS_OID=@T_JTS_OID;
--		END
--		ELSE
--		BEGIN
		  	SET @T_SUCURSAL=convert(NUMERIC(5,0),substring(@T_CBU,4,4));
--		  	SET @T_CUENTA = RIGHT(concat(replicate('0', 17), right(@T_cbu,14)),17);
--		END
				
			
			
		IF(@T_MONEDA= (SELECT C6399 FROM MONEDAS WHERE C6403='N'))
		BEGIN
			SET @T_COD_BANCO=311;
			--SET @RI_INFO_ADICIONAL='00';
		END
		ELSE
		BEGIN
			SET @T_COD_BANCO=811;
			--SET @RI_INFO_ADICIONAL='10';
		END
		
		SET @CantRegistros += 1;
		SET @Cant_Reg_Individual_Adicional += 1;
		
			
		IF	(@Excedente<>0)
		BEGIN
			SET @T_IMPORTE = @Excedente;
			SET @CountExcedente += 1;
		END
		IF	(@T_IMPORTE>99999999.99)
		BEGIN
			SET @Excedente = (@T_IMPORTE - 99999999.99);
			SET @T_IMPORTE = 99999999.99;
			SET @CountExcedente += 1;
		END
		ELSE
		BEGIN
			SET @Excedente = 0;
		END
			
		
		---------------------------- Grabar Registro Individual -----------------------------------------------------------------------------------------------------------------------------------------
		SET @RI_ENTIDAD_DEBITAR = CONCAT(RIGHT(concat(replicate('0', 4), @T_COD_BANCO),4) , RIGHT(concat(replicate('0', 4), @T_SUCURSAL),4));
		SET @RI_CUENTA_DEBITAR = RIGHT(concat(replicate('0', 17),  right(@T_cbu,14)), 17);
		SET @RI_REFERENCIA_UNIVOCA = RIGHT(concat(replicate('0', 15), @T_REFERENCIA), 15);
		SET @RI_CLIENTE_PAGADOR = RIGHT(concat(replicate('0', 22), @T_CODIGO_CLIENTE), 22);
		SET @T_CODIGO_TRANSACCION = '36';
			
		IF(@CountExcedente>1)
		BEGIN
			
		
			
			SET @SumaSucursal += 0888;  --sumo la sucursal que hay que harcodear
		    SET @SumaEntidad +=  @T_COD_BANCO;
		    SET @SumaImportes += @T_IMPORTE;
		
		        
		    SET @RI_ENTIDAD_DEBITAR = CONCAT(RIGHT(concat(replicate('0', 4), @T_COD_BANCO),4) , RIGHT(concat(replicate('0', 4), '0888'),4));
		
		        
		    SET @RI_CUENTA_DEBITAR = RIGHT(concat(replicate('0', 17), '88888888888'), 17);
		    SET @RI_REFERENCIA_UNIVOCA = '000088888888888';
		
		
		   
		END
		ELSE --la razon de este else, es que SumaSucursal, cuando hay excedente tiene que acumular 0888
		BEGIN
			SET @SumaSucursal += @T_SUCURSAL;
			SET @SumaEntidad += @T_COD_BANCO;
			SET @SumaImportes += @T_IMPORTE;
		
		
		
			SET @RI_ENTIDAD_DEBITAR = CONCAT(RIGHT(concat(replicate('0', 4), @T_COD_BANCO),4) , RIGHT(concat(replicate('0', 4), @T_SUCURSAL),4));
		    SET @RI_CUENTA_DEBITAR = RIGHT(concat(replicate('0', 17),  right(@T_cbu,14)), 17);
		    SET @RI_REFERENCIA_UNIVOCA =  RIGHT(concat(replicate('0', 15), @T_REFERENCIA), 15);
		    SET @RI_CLIENTE_PAGADOR = RIGHT(concat(replicate('0', 22), @T_CODIGO_CLIENTE), 22);
		 
		
		 			
		
		 
		END
		    
		IF @SumaImportes>9999999999.99 GOTO Start
		
		    
		SET @RI_IMPORTE = RIGHT(concat(replicate('0', 10), replace(CAST(@T_IMPORTE AS VARCHAR),'.','')), 10);
		--SET @RI_CODIGO_POSTAL = RIGHT(concat('00', replicate('0', 6), @T_CODIGO_POSTAL), 6);
		
		SET @RI_REGISTRO_ADICIONAL = '1';
		
		IF(@T_MONEDA=(SELECT C6399 FROM MONEDAS WHERE C6403='N'))
		    SET @RI_CONTADOR_REGISTRO = concat('0311', RIGHT(concat(replicate('0', 4), ('97')), 4), RIGHT(concat(replicate('0', 7), (SELECT NUMERICO_1 FROM ITF_MASTER_PARAMETROS WHERE CODIGO = 147)), 7)); 
		ELSE
		    SET @RI_CONTADOR_REGISTRO = concat('0811', RIGHT(concat(replicate('0', 4), ('97')), 4), RIGHT(concat(replicate('0', 7), (SELECT NUMERICO_1 FROM ITF_MASTER_PARAMETROS WHERE CODIGO = 147)), 7)); 
		     
		        	
		SET @RI_REGISTRO_INDIVIDUAL = concat(@RI_ID_REG
											, @T_CODIGO_TRANSACCION
											, @RI_ENTIDAD_DEBITAR
											, @RI_RESERVADO
											, @RI_CUENTA_DEBITAR
											, @RI_IMPORTE
											, @RI_REFERENCIA_UNIVOCA
											, @RI_CLIENTE_PAGADOR
											, @RI_INFO_ADICIONAL
											, @RI_REGISTRO_ADICIONAL
											, @RI_CONTADOR_REGISTRO);
		 
	    INSERT INTO dbo.ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX (LINEA) VALUES (replace(@RI_REGISTRO_INDIVIDUAL, '.', ''));
	   	-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	   	/* Logica para agregar el registro adicional con el motivo del rechazo*/	
		IF(@Excedente=0 OR @Excedente<99999999)
   		BEGIN
	 		SET @CODIGO_RECHAZO = 'R' + RIGHT(CONCAT('00',@T_MOTIVO_RECHAZO),2);
			SET @TRACE_NUMBER=  RIGHT(CONCAT('000000000000000',@T_ID_DEBITO),15); 
			SET @OTRO_RECHAZO = REPLICATE(' ',44);
			
   			SET @RI_REGISTRO_INDIVIDUAL_ADICIONAL = concat('799',@CODIGO_RECHAZO,@TRACE_NUMBER,'      ',('0'+LEFT(@T_CBU,7)),@OTRO_RECHAZO,@RI_CONTADOR_REGISTRO);
   			INSERT INTO dbo.ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX (LINEA,idSNP_DEBITOS) VALUES (replace(@RI_REGISTRO_INDIVIDUAL_ADICIONAL, '.', ''), @T_ID_DEBITO);
  		END
		
  		----------------------------- Actualizar secuencial unico -------------------------------------
  		UPDATE dbo.ITF_MASTER_PARAMETROS SET NUMERICO_1 = (NUMERICO_1 + 1) WHERE CODIGO = 147;
   		-----------------------------------------------------------------------------------------------
		
			
   		IF (@Excedente = 0)
		BEGIN		     	       				
		
  			FETCH NEXT FROM CursorDD INTO @T_ID_DEBITO, @T_JTS_OID, @T_MONEDA, @T_IMPORTE, @T_FECHA_VTO,@T_FECHA_COMP,@T_CBU, @T_REFERENCIA, @T_CODIGO_CLIENTE, @T_CUIT, @T_MOTIVO_RECHAZO,@T_PRESTACION,@RI_INFO_ADICIONAL
			
  			SET @CountExcedente = 0;
		
  		END	
  	END
	
	
	
	
	CLOSE CursorDD
	DEALLOCATE CursorDD
	
	
	IF @SumaSucursal > 9999
	BEGIN
		SET @SobranteSucursal = CAST(substring(CAST(@SumaSucursal AS VARCHAR), 1, (len(@SumaSucursal) - 4)) AS NUMERIC);
	  	SET @SumaEntidad += @SobranteSucursal;
		SET @SumaSucursal = CAST(RIGHT(@SumaSucursal, 4) AS NUMERIC);
	END
	
		--SET @FL_TOTALES_DE_CONTROL = concat((RIGHT(concat(replicate('0', 6), @SumaEntidad), 6)), (RIGHT(concat(replicate('0', 4), @SumaSucursal), 4)));
-- 	SET @FL_SUMA_TOTAL_DEBITO_LOTE = RIGHT(concat(replicate('0', 12), (replace(@SumaImportes, '.', ''))), 12); 
 	SET @FL_SUMA_TOTAL_DEBITO_LOTE = RIGHT(concat(replicate('0', 12), (replace((SELECT convert(NUMERIC(15,2),sum(convert(NUMERIC,substring(linea,30,10)))/100) FROM ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX WHERE LINEA LIKE '6%' AND ID>(SELECT max(id) FROM ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX WHERE LINEA LIKE '5%') ), '.', ''))), 12); 

  	SET @FL_SUMA_TOTAL_CREDITO_LOTE = RIGHT(replicate('0', 12), 12);
  	SET @TotalesDebitos += @SumaImportes;
--  	SET @FL_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate('0', 6), @Cant_Reg_Individual_Adicional+@CantRegistros), 6); 
	SET @FL_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate('0', 6), (SELECT COUNT(*) FROM ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX WHERE (LINEA LIKE '6%' or linea like '7%') and id>(select max(id) from ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX where linea like '5%'))), 6); 
	
   	--nuevo
   	SET @FL_TOTALES_DE_CONTROL = (RIGHT(concat(replicate('0', 10), (SELECT sum(convert(numeric,substring(linea,4,8)))
																		FROM ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX
																		WHERE LINEA LIKE '6%' 
																		AND ID>(SELECT max(id) 
																				FROM ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX 
																				WHERE LINEA LIKE '5%'))), 10))
		
		
		
--    --OJO CON ESTO--
--   	--    SET @CantRegistros = 0;
--	SET @Cant_Reg_Individual_Adicional = 0;	
--
--	SET @SumaEntidad_TOT += @SumaEntidad;
--	SET @SumaSucursal_TOT += @SumaSucursal;
--		
--	--OJO CON ESTO X2--
--	SET @SumaEntidad = 0;
--	SET @SumaSucursal = 0;	
--	SET @SumaImportes=0;
	
	SET @FL_FIN_LOTE = concat(@FL_ID_REG, @FL_CODIGO_CLASE_TRANSAC, @FL_CANT_REG_INDIVIDUAL_ADICIONAL, @FL_TOTALES_DE_CONTROL, @FL_SUMA_TOTAL_DEBITO_LOTE, @FL_SUMA_TOTAL_CREDITO_LOTE, @CL_ID_EMPRESA, @FL_RESERVADO2, @FL_RESERVADO3, @FL_REG_ENTIDAD_ORIGEN, @FL_NUMERO_LOTE);
				
	INSERT INTO dbo.ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX (LINEA) VALUES (replace(@FL_FIN_LOTE, '.', ''));
	
	---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-------------Grabamos el Fin de Archivo ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
	
	SET @FA_CANT_LOTES = RIGHT(concat(replicate('0', 6), (SELECT count(*) --le su,o uno al count por la linea que estamos por insertar (9%)
																	  FROM ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX 
																	  WHERE  LINEA LIKE '5%' AND ID>=(SELECT max(id) 
																						  		  		FROM ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX 
																						  		  		WHERE LINEA LIKE '1%'))), 6);
	
	
		
	SET @FA_NUMERO_BLOQUES = RIGHT(concat(replicate('0', 6), (SELECT CEILING((count(*)+1) / CONVERT(FLOAT, 10))
															  FROM ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX 
															  WHERE  ID>=(SELECT max(id) 
															  		  		FROM ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX 
															  		  		WHERE LINEA LIKE '1%'))), 6);
		
	  --			SET @FA_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate('0', 8), @CantRegistros), 8);
	
		
		
	SET @FA_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate('0', 8), (SELECT sum(convert(numeric,substring(linea,5,6)))
		  								  									 FROM ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX 
										  									 WHERE LINEA LIKE '8%'
										  									 AND ID>(SELECT max(ID) FROM ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX WHERE LINEA LIKE '1%'))), 8);
	
PRINT  @FA_CANT_REG_INDIVIDUAL_ADICIONAL			
	--	SET @FA_TOTALES_DE_CONTROL = concat((RIGHT(concat(replicate('0', 6), @SumaEntidad_TOT), 6)), (RIGHT(concat(replicate('0', 4), @SumaSucursal_TOT), 4)));; --igualo al totales de control de fin de lote pq tiene que ser igual
	
	SET @FA_TOTALES_DE_CONTROL = (RIGHT(concat(replicate('0', 10), (SELECT sum(convert(numeric,substring(linea,4,8)))
																		FROM ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX
																		WHERE LINEA LIKE '6%' 
																		AND ID>(SELECT max(id) 
																				FROM ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX 
																				WHERE LINEA LIKE '1%'))), 10))
				
--	SET @FA_SUMA_TOTAL_DEBITOS = RIGHT(concat(replicate('0', 12), (replace(@TotalesDebitos, '.', ''))), 12);
	SET @FA_SUMA_TOTAL_DEBITOS = RIGHT(concat(replicate('0', 12), (replace((SELECT convert(NUMERIC(15,2),sum(convert(NUMERIC,substring(linea,30,10)))/100) FROM ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX WHERE LINEA LIKE '6%' AND ID>(SELECT max(id) FROM ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX WHERE LINEA LIKE '1%') ), '.', ''))), 12); 

				
	SET @FA_SUMA_TOTAL_CREDITOS = RIGHT(concat(replicate('0', 12), (replace(@TotalesCreditos, '.', ''))),12);
		
	
	
		
	SET @FA_FIN_ARCHIVO = concat(@FA_ID_REG, 
								 @FA_CANT_LOTES, 
								 @FA_NUMERO_BLOQUES, 
								 @FA_CANT_REG_INDIVIDUAL_ADICIONAL, 
								 @FA_TOTALES_DE_CONTROL, 
								 @FA_SUMA_TOTAL_DEBITOS, 
								 @FA_SUMA_TOTAL_CREDITOS, 
								 @FA_RESERVADO);
				
		
		
	INSERT INTO dbo.ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX (LINEA) VALUES (@FA_FIN_ARCHIVO);
		
					
	
	------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
END
GO

