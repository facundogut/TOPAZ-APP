execute('create or ALTER    PROCEDURE [dbo].[SP_ITF_COELSA_CHE_PRESENTADOS_ENVIADOS]
@TICKET NUMERIC(16)
AS 
BEGIN
	SET NOCOUNT ON;
	--- 2.8.22

	---limpio tabla auxiliar ---
	TRUNCATE TABLE dbo.ITF_CHEQUES_SALIDA_AUX;

	--- Variables para chequear que se traiga algo
	DECLARE @hayCHEQUES INTEGER = 0;
	DECLARE @hayAJUSTES INTEGER = 0;
	DECLARE @hayDPF INTEGER = 0;

	--- Variables Cabecera Archivo (CA)
	DECLARE @CA_ID_REG VARCHAR(1) = ''1''; -- fijo
	DECLARE @CA_CODIGO_PRIORIDAD VARCHAR (2)= ''01''; -- fijo
	DECLARE @CA_DESTINO_INMEDIATO VARCHAR (10)= '' 000000010''; --fijo
	DECLARE @CA_ORIGEN_INMEDIATO VARCHAR(10) = (SELECT '' 031100''+CAST((SELECT NUMERICO FROM PARAMETROSGENERALES WHERE CODIGO=40) AS VARCHAR)+''0''); 
	DECLARE @CA_FECHA_PRESENTACION VARCHAR(6)= convert(VARCHAR,(SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)), 12); -- fijo
	DECLARE @CA_HORA_PRESENTACION VARCHAR(4)= concat (SUBSTRING((SELECT CONVERT (VARCHAR(8), SYSDATETIME(),24)),1,2), SUBSTRING((SELECT CONVERT (VARCHAR(8), SYSDATETIME(),24)),4,5)); -- fijo
	DECLARE @CA_IDENTIFICADOR_ARCHIVO VARCHAR(1) = ''1''; --
	DECLARE @CA_TAMANNO_REGISTRO VARCHAR(3)= ''094''; -- fijo
	DECLARE @CA_FACTOR_BLOQUE VARCHAR(2)= ''10''; -- fijo
	DECLARE @CA_CODIGO_FORMATO VARCHAR(1)= ''1''; -- fijo
	DECLARE @CA_NOMBRE_DEST_INMEDIATO VARCHAR(23)= ''COELSA                 ''; -- fijo
	DECLARE @CA_NOMBRE_ORIG_INMEDIATO VARCHAR(23)=''NUEVO BANCO DEL CHACO S''; -- fijo
	DECLARE @CA_CODIGO_REFERENCIA VARCHAR(8) = replicate('' '', 8); --Se conforma con espacios vacíos.

	DECLARE @CA_CABECERA VARCHAR(200);

	SET @CA_CABECERA = concat(@CA_ID_REG, @CA_CODIGO_PRIORIDAD, @CA_DESTINO_INMEDIATO, @CA_ORIGEN_INMEDIATO, @CA_FECHA_PRESENTACION, @CA_HORA_PRESENTACION, @CA_IDENTIFICADOR_ARCHIVO, @CA_TAMANNO_REGISTRO, @CA_FACTOR_BLOQUE, @CA_CODIGO_FORMATO, @CA_NOMBRE_DEST_INMEDIATO, @CA_NOMBRE_ORIG_INMEDIATO, @CA_CODIGO_REFERENCIA);


	--- Variables cabecera lote (CL)
	DECLARE @CL_ID_REG VARCHAR(1) = ''5''; -- fijo
	DECLARE @CL_CODIGO_CLASE_TRANSAC VARCHAR(3) = ''200''; -- fijo 
	DECLARE @CL_RESERVADO VARCHAR(46) = replicate('' '', 46); -- 3 campos reservados
	DECLARE @CL_TIPO_REGISTRO VARCHAR(3) = ''TRC''; -- fijo 
	DECLARE @CL_DESCRIP_TRANSAC VARCHAR(10) = ''CHEQUESPRE''; -- fijo
	DECLARE @CL_FECHA_PRESENTACION VARCHAR(6) = convert(VARCHAR,(SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)), 12);
	DECLARE @CL_FECHA_VENCIMIENTO VARCHAR(6) = convert(VARCHAR,(SELECT FECHAPROXIMOPROCESO FROM PARAMETROS WITH(NOLOCK)), 12); 
	DECLARE @CL_RESERVADO_CL VARCHAR(3) = ''000''; -- fijo
	DECLARE @CL_CODIGO_ORIGEN VARCHAR(1) = ''1''; -- fijo
	DECLARE @CL_ID_ENTIDAD_ORIGEN VARCHAR(8) = (SELECT ''031100''+CAST((SELECT NUMERICO FROM PARAMETROSGENERALES WHERE CODIGO=40) AS VARCHAR)); 
	DECLARE @CL_NUMERO_LOTE VARCHAR(7) = RIGHT(concat(replicate(''0'', 7), 1), 7); -- numero del lote

	DECLARE @CL_CABECERA VARCHAR(200);

	SET @CL_CABECERA = concat(@CL_ID_REG, @CL_CODIGO_CLASE_TRANSAC, @CL_RESERVADO, @CL_TIPO_REGISTRO, @CL_DESCRIP_TRANSAC, @CL_FECHA_PRESENTACION, @CL_FECHA_VENCIMIENTO, @CL_RESERVADO_CL, @CL_CODIGO_ORIGEN, @CL_ID_ENTIDAD_ORIGEN, @CL_NUMERO_LOTE);

	---- Grabamos cabecera de lote y archivo SIEMPRE

	---------------- Grabar Cabecera Archivo ---------------------------
	INSERT INTO dbo.ITF_CHEQUES_SALIDA_AUX (LINEA) VALUES (@CA_CABECERA);
	--------------------------------------------------------------------
	---------------- Grabar Cabecera Lote ---------------------------
	INSERT INTO dbo.ITF_CHEQUES_SALIDA_AUX (LINEA) VALUES (@CL_CABECERA);
	-----------------------------------------------------------------

	--Verifico que existan registros
	SELECT @hayCHEQUES = COUNT(*) FROM CLE_CHEQUES_ENVIADOS;
	SELECT @hayAJUSTES = COUNT(*) FROM CLE_CHEQUES_AJUSTE WITH(NOLOCK) WHERE ENVIADO_RECIBIDO = ''E'' AND ESTADO = ''I'' AND TZ_LOCK = 0 AND FECHA_ALTA = (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK));
	SELECT @hayDPF = COUNT(*) FROM CLE_DPF_SALIENTE WHERE TZ_LOCK = 0 AND ESTADO = 1 AND MONEDA = 1 AND FECHA_ALTA = (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)) ; 


	------ Variables registro individual ( RI) ------------
	DECLARE @RI_ID_REG VARCHAR(1) = ''6''; -- fijo  
	DECLARE @RI_CODIGO_TRANSAC VARCHAR(2) = ''27''; -- fijo
	DECLARE @RI_ENTIDAD_DEBITAR VARCHAR(8);
	DECLARE @RI_RESERVADO VARCHAR(1) = ''0''; -- fijo 
	DECLARE @RI_CUENTA_DEBITAR VARCHAR(17); 
	DECLARE @RI_IMPORTE VARCHAR(11); 
	DECLARE @RI_NUMERO_CHEQUE VARCHAR(15);
	DECLARE @RI_CODIGO_POSTAL VARCHAR(6); 
	DECLARE @RI_PUNTO_INTERCAMBIO VARCHAR(16) = ''0000            '';
	DECLARE @RI_INFO_ADICIONAL VARCHAR(2);
	DECLARE @RI_REGISTRO_ADICIONAL VARCHAR(1); 
	DECLARE @RI_CONTADOR_REGISTRO VARCHAR(15);
								
	DECLARE @RI_REGISTRO_INDIVIDUAL VARCHAR (200);

	------ Variables registro ajuste ( RA) ------------

	DECLARE @RA_ID_REG_ADICIONAL VARCHAR(6) = ''799   '';
	DECLARE @RA_CONTADOR_REGISTRO_ORIGEN VARCHAR(15);
	DECLARE @RA_NUMERO_CERTIFIFADO VARCHAR(6) = ''      '';
	DECLARE @RA_ENTIDAD_ORIGINAL VARCHAR(8) = ''        '';
	DECLARE @RA_OTRO_MOTIVO_RECH VARCHAR(44) = ''                                             '';

	--- Variables fin de lote FL
	DECLARE @FL_ID_REG VARCHAR(1) = ''8''; -- fijo 
	DECLARE @FL_CODIGO_CLASE_TRANSAC VARCHAR(3) = ''200''; -- fijo 
	DECLARE @FL_CANT_REG_INDIVIDUAL_ADICIONAL VARCHAR(6) = 0; --registros individuales y adicionales que existen en el lote
	DECLARE @FL_TOTALES_DE_CONTROL VARCHAR(10) = 0;
	DECLARE @FL_SUMA_TOTAL_DEBITO_LOTE VARCHAR(12); 
	DECLARE @FL_SUMA_TOTAL_CREDITO_LOTE VARCHAR(12); 
	DECLARE @FL_RESERVADO1 VARCHAR(10) = ''          ''; -- fijo
	DECLARE @FL_RESERVADO2 VARCHAR(19) = ''                   ''; -- fijo
	DECLARE @FL_RESERVADO3 VARCHAR(6) = ''      ''; -- fijo
	DECLARE @FL_REG_ENTIDAD_ORIGEN VARCHAR(8) = (SELECT ''0311''+ RIGHT(concat(replicate(''0'', 4), CAST((SELECT NUMERICO FROM PARAMETROSGENERALES WHERE CODIGO=40) AS VARCHAR)), 4)); 
	DECLARE @FL_NUMERO_LOTE VARCHAR(7) = ''0000001''; 

	DECLARE @FL_FIN_LOTE VARCHAR(200);

	--- Variables fin de Archivo FA
	DECLARE @FA_ID_REG VARCHAR(1) = ''9''; -- fijo  
	DECLARE @FA_CANT_LOTES VARCHAR(6) = ''000001'';-- total de lotes que contiene el archivo (se decidio 1 lote por archivo)
	DECLARE @FA_NUMERO_BLOQUES VARCHAR(8);-- ver detalles en doc pdf
	DECLARE @FA_CANT_REG_INDIVIDUAL_ADICIONAL VARCHAR(8); --total de registros individuales y adicionales que existen en el archivo
	DECLARE @FA_TOTALES_DE_CONTROL VARCHAR(10);
	DECLARE @FA_SUMA_TOTAL_DEBITOS VARCHAR(12);
	DECLARE @FA_SUMA_TOTAL_CREDITOS VARCHAR(12);
	DECLARE @FA_RESERVADO  VARCHAR(100) = replicate('' '', 39); -- fijo

	DECLARE @FA_FIN_ARCHIVO VARCHAR (200);

	--- Variables CLE_CHEQUES_ENVIADOS ---
	DECLARE @T_COD_BANCO NUMERIC(12,0);
	DECLARE @T_SUCURSAL NUMERIC(5,0);
	DECLARE @T_SERIE_DEL_CHEQUE VARCHAR(6);
	DECLARE @T_NUMERO_DEL_CHEQUE NUMERIC(12,0);
	DECLARE @T_MONEDA NUMERIC(4,0);
	DECLARE @T_IMPORTE NUMERIC(15,2);
	DECLARE @T_FECHA_DEL_CHEQUE DATETIME;
	DECLARE @T_FECHA_VALOR DATETIME;
	DECLARE @T_CODIGO_BANCO_CAMARA NUMERIC(4,0);
	DECLARE @T_TIPO_DOCUMENTO NUMERIC(4,0);
	DECLARE @T_CODIGO_PLAZA NUMERIC(4,0);
	DECLARE @T_CODIGO_CAMARA NUMERIC(4,0);
	DECLARE @T_NUMERO_CUENTA_GIRADORA NUMERIC(12,0);
	DECLARE @T_TIPO_MONEDA VARCHAR(1);
	DECLARE @T_SUCURSAL_DE_INGRESO NUMERIC(5,0);

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


	--- Chequeo de que venga ALGO, en caso contrario devuelvo archivo vacio de una
	IF(@hayCHEQUES + @hayAJUSTES + @hayDPF = 0)
	BEGIN
		--SET @FL_TOTALES_DE_CONTROL = concat((RIGHT(concat(replicate(''0'', 6), ''0''), 6)), (RIGHT(concat(replicate(''0'', 4), ''0''), 4)));
		
			   	   	--nuevo
   		SET @FL_TOTALES_DE_CONTROL = (RIGHT(concat(replicate(''0'', 10), (SELECT sum(convert(numeric,substring(linea,4,8)))
																	FROM ITF_CHEQUES_SALIDA_AUX
																	WHERE LINEA LIKE ''6%'' 
																	AND ID>(SELECT max(id) 
																			FROM ITF_CHEQUES_SALIDA_AUX 
																			WHERE LINEA LIKE ''5%''))), 10))
		
		SET @FL_SUMA_TOTAL_DEBITO_LOTE = (RIGHT(concat(replicate(''0'', 12), (SELECT sum(convert(numeric,substring(linea,30,10)))
																	FROM ITF_CHEQUES_SALIDA_AUX
																	WHERE LINEA LIKE ''6%'' 
																	AND ID>(SELECT max(id) 
																			FROM ITF_CHEQUES_SALIDA_AUX 
																			WHERE LINEA LIKE ''5%''))), 12))
   	
		SET @FL_SUMA_TOTAL_CREDITO_LOTE = RIGHT(replicate(''0'', 12), 12);
		SET @TotalesDebitos += @SumaImportes;
		SET @FL_NUMERO_LOTE = RIGHT(concat(replicate(''0'', 7), (SELECT count(ID) FROM ITF_CHEQUES_SALIDA_AUX WHERE LINEA LIKE ''5%'' AND id>(SELECT max(id) FROM ITF_CHEQUES_SALIDA_AUX WHERE LINEA LIKE ''1%''))), 7); 		
		SET @FL_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 6), ''0''), 6); 
		SET @FL_FIN_LOTE = concat(@FL_ID_REG, @FL_CODIGO_CLASE_TRANSAC, @FL_CANT_REG_INDIVIDUAL_ADICIONAL, @FL_TOTALES_DE_CONTROL, @FL_SUMA_TOTAL_DEBITO_LOTE, @FL_SUMA_TOTAL_CREDITO_LOTE, @FL_RESERVADO1, @FL_RESERVADO2, @FL_RESERVADO3, @FL_REG_ENTIDAD_ORIGEN, @FL_NUMERO_LOTE);
		
		INSERT INTO dbo.ITF_CHEQUES_SALIDA_AUX (LINEA) VALUES (replace(@FL_FIN_LOTE, ''.'', ''''));

		--SET @FA_CANT_LOTES = RIGHT(concat(replicate(''0'', 6), @FL_NUMERO_LOTE), 6);
		SET @CantRegistrosPrev = (SELECT (CASE WHEN (@CantRegistros + 4) % 10 = 0 THEN ((@CantRegistros + 4)/10) ELSE (FLOOR((@CantRegistros + 4)/10) + 1) END));
		--SET @FA_NUMERO_BLOQUES = RIGHT(concat(replicate(''0'', 6), @CantRegistrosPrev ), 6);
		
		SET @FA_NUMERO_BLOQUES = RIGHT(concat(replicate(''0'', 6), (SELECT CEILING((count(*)+1) / CONVERT(FLOAT, 10))
																  FROM ITF_CHEQUES_SALIDA_AUX 
																  WHERE  ID>=(SELECT max(id) 
																  		  		FROM ITF_CHEQUES_SALIDA_AUX 
																  		  		WHERE LINEA LIKE ''1%''))), 6);
		
		--SET @FA_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 8), @CantRegistros), 8);
		
		SET @FA_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 8), (SELECT count(*)
																				 FROM ITF_CHEQUES_SALIDA_AUX
																				 WHERE (LINEA LIKE ''6%'' OR LINEA LIKE ''7%'')
																				 AND ID>(SELECT max(id) 
																				 		 FROM ITF_CHEQUES_SALIDA_AUX 
																				 		 WHERE LINEA LIKE ''1%''))), 8);
		--SET @FA_TOTALES_DE_CONTROL =  @FL_TOTALES_DE_CONTROL;
		
		SET @FA_TOTALES_DE_CONTROL = (RIGHT(concat(replicate(''0'', 10), (SELECT sum(convert(numeric,substring(linea,4,8)))
																	FROM ITF_CHEQUES_SALIDA_AUX
																	WHERE LINEA LIKE ''6%'' 
																	AND ID>(SELECT max(id) 
																			FROM ITF_CHEQUES_SALIDA_AUX 
																			WHERE LINEA LIKE ''1%''))), 10))
		
		--SET @FA_SUMA_TOTAL_DEBITOS = RIGHT(concat(replicate(''0'', 12), (replace(@TotalesDebitos, ''.'', ''''))), 12);

		SET @FA_SUMA_TOTAL_DEBITOS = (RIGHT(concat(replicate(''0'', 12), (SELECT sum(convert(numeric,substring(linea,21,12)))
																	FROM ITF_CHEQUES_SALIDA_AUX
																	WHERE LINEA LIKE ''8%'' 
																	AND ID>(SELECT max(id) 
																			FROM ITF_CHEQUES_SALIDA_AUX 
																			WHERE LINEA LIKE ''1%''))), 12))



		SET @FA_SUMA_TOTAL_CREDITOS = RIGHT(concat(replicate(''0'', 12), (replace(@TotalesCreditos, ''.'', ''''))),12);
		SET @FA_FIN_ARCHIVO = concat(@FA_ID_REG, @FA_CANT_LOTES, @FA_NUMERO_BLOQUES, @FA_CANT_REG_INDIVIDUAL_ADICIONAL, @FA_TOTALES_DE_CONTROL, @FA_SUMA_TOTAL_DEBITOS, @FA_SUMA_TOTAL_CREDITOS, @FA_RESERVADO);
		
		INSERT INTO dbo.ITF_CHEQUES_SALIDA_AUX (LINEA) VALUES (@FA_FIN_ARCHIVO);
		
		
		----------------------------- Seteo el control de reproceso -------------------------------------
		UPDATE dbo.ITF_MASTER_PARAMETROS SET FECHA = (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)) WHERE CODIGO = 139;
		-----------------------------------------------------------------------------------------------
		

	END
	ELSE
	BEGIN
		------------------------------------------
	
		---------------------------------------------- Seteo el control de reproceso -------------------------------------
		UPDATE dbo.ITF_MASTER_PARAMETROS SET FECHA = (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)) WHERE CODIGO = 139;
		------------------------------------------------------------------------------------------------------------------
		
		--Condicion de reset del contador de reg individual
		IF ISNULL((SELECT a.FECHA FROM ITF_MASTER_PARAMETROS a WHERE a.CODIGO = 136), CAST(''01-01-1800'' AS DATETIME)) <> (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK))
			UPDATE dbo.ITF_MASTER_PARAMETROS SET NUMERICO_1 = 1, FECHA = (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)) WHERE CODIGO = 136;
	 
		---------------- CHEQUES -------------------------------------------------------------------------------------------------
		DECLARE CursorCheques CURSOR FOR
				
		SELECT  COD_BANCO
				, SUCURSAL
				, SERIE_DEL_CHEQUE
				, NUMERO_DEL_CHEQUE
				, MONEDA
				, IMPORTE
				, FECHA_DEL_CHEQUE
				, FECHA_VALOR
				, CODIGO_BANCO_CAMARA
				, TIPO_DOCUMENTO
				, CODIGO_PLAZA
				, CODIGO_CAMARA
				, NUMERO_CUENTA_GIRADORA
				, TIPO_MONEDA
				, SUCURSAL_DE_INGRESO
		FROM CLE_CHEQUES_ENVIADOS
					   				
		OPEN CursorCheques
		FETCH NEXT FROM CursorCheques INTO @T_COD_BANCO
											, @T_SUCURSAL
											, @T_SERIE_DEL_CHEQUE
											, @T_NUMERO_DEL_CHEQUE
											, @T_MONEDA
											, @T_IMPORTE
											, @T_FECHA_DEL_CHEQUE
											, @T_FECHA_VALOR
											, @T_CODIGO_BANCO_CAMARA
											, @T_TIPO_DOCUMENTO
											, @T_CODIGO_PLAZA
											, @T_CODIGO_CAMARA
											, @T_NUMERO_CUENTA_GIRADORA
											, @T_TIPO_MONEDA
											, @T_SUCURSAL_DE_INGRESO
													
		WHILE @@FETCH_STATUS = 0 
		BEGIN
			SET @ri_info_adicional=''00'';
			Start_1:
			IF (@SumaImportes > 9999999999.99 OR @SumaEntidad > 999999) -- 9999 millones
				BEGIN
			
					IF @SumaSucursal > 9999
					BEGIN
						SET @SobranteSucursal = CAST(substring(CAST(@SumaSucursal AS VARCHAR), 1, (len(@SumaSucursal) - 4)) AS NUMERIC);
						SET @SumaEntidad += @SobranteSucursal;
						SET @SumaSucursal = CAST(RIGHT(@SumaSucursal, 4) AS NUMERIC);
					END

				SET @TotalesControl += @SumaEntidad + @SumaSucursal;
				--SET @FL_TOTALES_DE_CONTROL = concat((RIGHT(concat(replicate(''0'', 6), @SumaEntidad), 6)), (RIGHT(concat(replicate(''0'', 4), @SumaSucursal), 4)));
			
				   	   	--nuevo
   				SET @FL_TOTALES_DE_CONTROL = (RIGHT(concat(replicate(''0'', 10), (SELECT sum(convert(numeric,substring(linea,4,8)))
																				FROM ITF_CHEQUES_SALIDA_AUX
																				WHERE LINEA LIKE ''6%'' 
																				AND ID>(SELECT max(id) 
																						FROM ITF_CHEQUES_SALIDA_AUX 
																						WHERE LINEA LIKE ''5%''))), 10))
			
			
				--SET @FL_SUMA_TOTAL_DEBITO_LOTE = RIGHT(concat(replicate(''0'', 12), (replace(@SumaImportes, ''.'', ''''))), 12); 
			
			
				SET @FL_SUMA_TOTAL_DEBITO_LOTE = (RIGHT(concat(replicate(''0'', 12), (SELECT sum(convert(numeric,substring(linea,30,10)))
																					FROM ITF_CHEQUES_SALIDA_AUX
																					WHERE LINEA LIKE ''6%'' 
																					AND ID>(SELECT max(id) 
																							FROM ITF_CHEQUES_SALIDA_AUX 
																							WHERE LINEA LIKE ''5%''))), 12))
			
			
			
			
				SET @FL_SUMA_TOTAL_CREDITO_LOTE = RIGHT(replicate(''0'', 12), 12); 
				SET @TotalesDebitos += @SumaImportes;
				SET @FL_NUMERO_LOTE = RIGHT(concat(replicate(''0'', 7), (SELECT count(ID) FROM ITF_CHEQUES_SALIDA_AUX WHERE LINEA LIKE ''5%'' AND id>(SELECT max(id) FROM ITF_CHEQUES_SALIDA_AUX WHERE LINEA LIKE ''1%''))), 7); 		
				SET @FL_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 6), (SELECT count(*) FROM ITF_CHEQUES_SALIDA_AUX WHERE (LINEA LIKE ''6%'' OR LINEA LIKE ''7%'') AND ID>(SELECT max(id) FROM ITF_CHEQUES_SALIDA_AUX WHERE LINEA LIKE ''5%''))), 6);

				SET @FL_FIN_LOTE = concat(@FL_ID_REG, @FL_CODIGO_CLASE_TRANSAC, @FL_CANT_REG_INDIVIDUAL_ADICIONAL, @FL_TOTALES_DE_CONTROL, @FL_SUMA_TOTAL_DEBITO_LOTE, @FL_SUMA_TOTAL_CREDITO_LOTE, @FL_RESERVADO1, @FL_RESERVADO2, @FL_RESERVADO3, @FL_REG_ENTIDAD_ORIGEN, @FL_NUMERO_LOTE);
			
			
				INSERT INTO dbo.ITF_CHEQUES_SALIDA_AUX (LINEA) VALUES (replace(@FL_FIN_LOTE, ''.'', ''''));
			

				-------------------------------------------------------------------
				-------------Grabamos el Fin de Archivo ----------------------------------------------------------------------------------------------------------------------
				--SET @FA_CANT_LOTES = RIGHT(concat(replicate(''0'', 6), @FL_NUMERO_LOTE), 6);
				SET @CantRegistrosPrev = (SELECT (CASE WHEN (@CantRegistros + 4) % 10 = 0 THEN ((@CantRegistros + 4)/10) ELSE (FLOOR((@CantRegistros + 4)/10) + 1) END));
				--SET @FA_NUMERO_BLOQUES = RIGHT(concat(replicate(''0'', 6), @CantRegistrosPrev ), 6);
			
				SET @FA_NUMERO_BLOQUES = RIGHT(concat(replicate(''0'', 6), (SELECT CEILING((count(*)+1) / CONVERT(FLOAT, 10))
																  			FROM ITF_CHEQUES_SALIDA_AUX 
																  			WHERE  ID>=(SELECT max(id) 
																  		  				FROM ITF_CHEQUES_SALIDA_AUX 
																  		  				WHERE LINEA LIKE ''1%''))), 6);

				--SET @FA_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 8), @CantRegistros), 8);
			
				SET @FA_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 8), (SELECT count(*)
																				 			FROM ITF_CHEQUES_SALIDA_AUX
																				 			WHERE (LINEA LIKE ''6%'' OR LINEA LIKE ''7%'')
																				 			AND ID>(SELECT max(id) 
																				 		 			FROM ITF_CHEQUES_SALIDA_AUX 
																				 		 			WHERE LINEA LIKE ''1%''))), 8);
			
				--SET @FA_TOTALES_DE_CONTROL =  @FL_TOTALES_DE_CONTROL;
			
			   	SET @FA_TOTALES_DE_CONTROL = (RIGHT(concat(replicate(''0'', 10), (SELECT sum(convert(numeric,substring(linea,4,8)))
																				FROM ITF_CHEQUES_SALIDA_AUX
																				WHERE LINEA LIKE ''6%'' 
																				AND ID>(SELECT max(id) 
																						FROM ITF_CHEQUES_SALIDA_AUX 
																						WHERE LINEA LIKE ''1%''))), 10))
			
				--SET @FA_SUMA_TOTAL_DEBITOS = RIGHT(concat(replicate(''0'', 12), (replace(@TotalesDebitos, ''.'', ''''))), 12);

				SET @FA_SUMA_TOTAL_DEBITOS = (RIGHT(concat(replicate(''0'', 12), (SELECT sum(convert(numeric,substring(linea,21,12)))
																				FROM ITF_CHEQUES_SALIDA_AUX
																				WHERE LINEA LIKE ''8%'' 
																				AND ID>(SELECT max(id) 
																						FROM ITF_CHEQUES_SALIDA_AUX 
																						WHERE LINEA LIKE ''1%''))), 12))
			
				SET @FA_SUMA_TOTAL_CREDITOS = RIGHT(concat(replicate(''0'', 12), (replace(@TotalesCreditos, ''.'', ''''))),12);

				SET @FA_FIN_ARCHIVO = concat(@FA_ID_REG, @FA_CANT_LOTES, @FA_NUMERO_BLOQUES, @FA_CANT_REG_INDIVIDUAL_ADICIONAL, @FA_TOTALES_DE_CONTROL, @FA_SUMA_TOTAL_DEBITOS, @FA_SUMA_TOTAL_CREDITOS, @FA_RESERVADO);
			
				INSERT INTO dbo.ITF_CHEQUES_SALIDA_AUX (LINEA) VALUES (@FA_FIN_ARCHIVO);
			
				--SET @FL_NUMERO_LOTE = CAST(@FL_NUMERO_LOTE AS NUMERIC) + 1;
				--SET @FL_NUMERO_LOTE = RIGHT(concat(replicate(''0'', 7), @FL_NUMERO_LOTE), 7);
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
				SET @SumaSucursal = 0;
				-------------------------------------------------------------------------------------------------------------------------------------------------------------------
				--------- Grabamos nueva Cabecera de Archivo ----------------------------------------------------------------------------------------------------------------------
				SET @CA_CABECERA = concat(@CA_ID_REG, @CA_CODIGO_PRIORIDAD, @CA_DESTINO_INMEDIATO, @CA_ORIGEN_INMEDIATO, @CA_FECHA_PRESENTACION, @CA_HORA_PRESENTACION, @CA_IDENTIFICADOR_ARCHIVO, @CA_TAMANNO_REGISTRO, @CA_FACTOR_BLOQUE, @CA_CODIGO_FORMATO, @CA_NOMBRE_DEST_INMEDIATO, @CA_NOMBRE_ORIG_INMEDIATO, @CA_CODIGO_REFERENCIA);
			
				INSERT INTO dbo.ITF_CHEQUES_SALIDA_AUX (LINEA) VALUES (@CA_CABECERA);
				----------------------------------------------------------------------------------------------------------------------------------------------------------------------
				--------- Grabamos nueva Cabecera Lote ------------------------------------------------------------------------------------------------------------------------------------------------------
				SET @CL_NUMERO_LOTE = RIGHT(concat(replicate(''0'', 7), (SELECT count(ID)+1 FROM ITF_CHEQUES_SALIDA_AUX WHERE LINEA LIKE ''5%'' AND id>(SELECT max(id) FROM ITF_CHEQUES_SALIDA_AUX WHERE LINEA LIKE ''1%''))), 7); 		
   
				SET @CL_CABECERA = concat(@CL_ID_REG, @CL_CODIGO_CLASE_TRANSAC, @CL_RESERVADO, @CL_TIPO_REGISTRO, @CL_DESCRIP_TRANSAC, @CL_FECHA_PRESENTACION, @CL_FECHA_VENCIMIENTO, @CL_RESERVADO_CL, @CL_CODIGO_ORIGEN, @CL_ID_ENTIDAD_ORIGEN, @CL_NUMERO_LOTE);
				INSERT INTO dbo.ITF_CHEQUES_SALIDA_AUX (LINEA) VALUES (@CL_CABECERA);
				---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
			
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
				--SET @RA_CONTADOR_REGISTRO_ORIGEN = @RI_CONTADOR_REGISTRO;
			END
			ELSE
			BEGIN
		   		SET @Excedente = 0;
			END
			
		
			IF(@CountExcedente>1)
			BEGIN
				SET @SumaSucursal += 0888; --sumo la sucursal que hay que harcodear
				SET @SumaEntidad += @T_COD_BANCO;
				SET @SumaImportes += @T_IMPORTE;

				SET @RI_ENTIDAD_DEBITAR = concat(RIGHT(concat(replicate(''0'', 4), @T_COD_BANCO), 4), ''0888'');
				SET @RI_CUENTA_DEBITAR = RIGHT(concat(replicate(''0'', 17), ''88888888888''), 17);
				SET @RI_NUMERO_CHEQUE = ''000088888888888'';  --ACA SE SETEAN LOS 8


			END
			ELSE --la razon de este else, es que SumaSucursal, cuando hay excedente tiene que acumular 0888
			BEGIN
				SET @SumaSucursal += @T_SUCURSAL; 
				SET @SumaEntidad += @T_COD_BANCO;
				SET @SumaImportes += @T_IMPORTE;

				SET @RI_ENTIDAD_DEBITAR = concat(RIGHT(concat(replicate(''0'', 4), @T_COD_BANCO), 4), RIGHT(concat(replicate(''0'', 4), @T_SUCURSAL), 4)); 
			
				SET @RI_CUENTA_DEBITAR = RIGHT(concat(replicate(''0'', 17), @T_NUMERO_CUENTA_GIRADORA), 17);
		
				SET @RI_NUMERO_CHEQUE = concat(''00'', RIGHT(concat(replicate(''0'', 13), @T_NUMERO_DEL_CHEQUE), 13));

			END	
			
			IF @SumaImportes>9999999999.99 GOTO Start_1
		
			SET @RI_IMPORTE = RIGHT(concat(replicate(''0'', 10), replace(CAST(@T_IMPORTE AS VARCHAR),''.'','''')), 10);			
			SET @RI_CODIGO_POSTAL =  concat(''00'', RIGHT(concat(replicate(''0'', 4), (SELECT s.COD_POSTAL FROM CLE_CHEQUES_SALIENTE s WITH(NOLOCK) WHERE s.SERIE_DEL_CHEQUE = @T_SERIE_DEL_CHEQUE AND s.NUMERO_CHEQUE = @T_NUMERO_DEL_CHEQUE AND s.BANCO_GIRADO = @T_COD_BANCO AND s.SUCURSAL_BANCO_GIRADO = @T_SUCURSAL AND s.NUMERICO_CUENTA_GIRADORA = @T_NUMERO_CUENTA_GIRADORA)), 4));		
			SET @RI_INFO_ADICIONAL = ''00'';
			SET @RI_REGISTRO_ADICIONAL = ''0'';			
			SET @RI_CONTADOR_REGISTRO = concat(''0311'', RIGHT(concat(replicate(''0'', 4), (@T_SUCURSAL_DE_INGRESO)), 4),RIGHT(concat(replicate(''0'', 7), (SELECT NUMERICO_1 FROM ITF_MASTER_PARAMETROS WHERE CODIGO = 136)), 7));
		
			SET @RI_REGISTRO_INDIVIDUAL = concat(@RI_ID_REG, @RI_CODIGO_TRANSAC, @RI_ENTIDAD_DEBITAR, @RI_RESERVADO, @RI_CUENTA_DEBITAR, @RI_IMPORTE, @RI_NUMERO_CHEQUE, @RI_CODIGO_POSTAL, @RI_PUNTO_INTERCAMBIO, @RI_INFO_ADICIONAL, @RI_REGISTRO_ADICIONAL, @RI_CONTADOR_REGISTRO);
			
			INSERT INTO dbo.ITF_CHEQUES_SALIDA_AUX (LINEA) VALUES (replace(@RI_REGISTRO_INDIVIDUAL, ''.'', ''''));
			
			---------------------------- Actualizar contador unico ----------------------------------------
			UPDATE dbo.ITF_MASTER_PARAMETROS SET NUMERICO_1 = (NUMERICO_1 + 1) WHERE CODIGO = 136;
			------------------------------------------------------------------------------------------------
			---------- Grabar historial ----------------------------------------------------------------------------------------------------------------------------------------------------------------------
			INSERT INTO ITF_COELSA_CHEQUES_OTROS (ID_TICKET, ID_PROCESO, FECHAPROCESO, CODIGO_TRANSACCION, BANCO, SUCURSAL, CUENTA, IMPORTE, CODIGO_POSTAL, FECHA_PRESENTADO, FECHA_VENCIMIENTO, NRO_CHEQUE, PUNTO_INTERCAMBIO, TRACE_NUMBER, ESTADO, TIPO, MONEDA, TIPO_DOCUMENTO, SERIE_DEL_CHEQUE)
			VALUES (@TICKET, @TICKET, (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)), @RI_CODIGO_TRANSAC, @T_COD_BANCO, @T_SUCURSAL, @T_NUMERO_CUENTA_GIRADORA, @T_IMPORTE, @RI_CODIGO_POSTAL, @T_FECHA_DEL_CHEQUE, @T_FECHA_VALOR, @T_NUMERO_DEL_CHEQUE, @RI_PUNTO_INTERCAMBIO, @RI_CONTADOR_REGISTRO, ''P'', ''C'', @T_MONEDA, @T_TIPO_DOCUMENTO, @T_SERIE_DEL_CHEQUE);
			-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

			IF (@Excedente = 0)
			BEGIN		     	       				
				FETCH NEXT FROM CursorCheques INTO @T_COD_BANCO
												, @T_SUCURSAL
												, @T_SERIE_DEL_CHEQUE
												, @T_NUMERO_DEL_CHEQUE
												, @T_MONEDA,@T_IMPORTE
												, @T_FECHA_DEL_CHEQUE
												, @T_FECHA_VALOR
												, @T_CODIGO_BANCO_CAMARA
												, @T_TIPO_DOCUMENTO
												, @T_CODIGO_PLAZA
												, @T_CODIGO_CAMARA
												, @T_NUMERO_CUENTA_GIRADORA
												, @T_TIPO_MONEDA
												, @T_SUCURSAL_DE_INGRESO
				SET @CountExcedente = 0;
			END
								   
		END 
		CLOSE CursorCheques 
		DEALLOCATE CursorCheques 

		IF @SumaSucursal > 9999
		BEGIN
			SET @SobranteSucursal = 0;
			SET @SobranteSucursal = CAST(substring(CAST(@SumaSucursal AS VARCHAR), 1, (len(@SumaSucursal) - 4)) AS NUMERIC);
			SET @SumaEntidad += @SobranteSucursal;
			SET @SumaSucursal = CAST(RIGHT(@SumaSucursal, 4) AS NUMERIC);
		END
	   	   	--nuevo
   		SET @FL_TOTALES_DE_CONTROL = (RIGHT(concat(replicate(''0'', 10), (SELECT sum(convert(numeric,substring(linea,4,8)))
																		FROM ITF_CHEQUES_SALIDA_AUX
																		WHERE LINEA LIKE ''6%'' 
																		AND ID>(SELECT max(id) 
																				FROM ITF_CHEQUES_SALIDA_AUX 
																				WHERE LINEA LIKE ''5%''))), 10))


		--SET @TotalesControl += CAST(@FL_TOTALES_DE_CONTROL AS INTEGER);
	
		--SET @FL_SUMA_TOTAL_DEBITO_LOTE = RIGHT(concat(replicate(''0'', 12), (replace(@SumaImportes, ''.'', ''''))), 12); 
	
	
		SET @FL_SUMA_TOTAL_DEBITO_LOTE = (RIGHT(concat(replicate(''0'', 12), (SELECT sum(convert(numeric,substring(linea,30,10)))
																			FROM ITF_CHEQUES_SALIDA_AUX
																			WHERE LINEA LIKE ''6%'' 
																			AND ID>(SELECT max(id) 
																					FROM ITF_CHEQUES_SALIDA_AUX 
																					WHERE LINEA LIKE ''5%''))), 12))
	
	
		SET @FL_SUMA_TOTAL_CREDITO_LOTE = RIGHT(replicate(''0'', 12), 12);
		SET @TotalesDebitos += @SumaImportes;
		--SET @FL_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 6), @Cant_Reg_Individual_Adicional), 6); 
		SET @FL_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 6), (SELECT count(*)
																				 FROM ITF_CHEQUES_SALIDA_AUX
																				 WHERE (LINEA LIKE ''6%'' OR LINEA LIKE ''7%'')
																				 AND ID>(SELECT max(id) 
																				 		 FROM ITF_CHEQUES_SALIDA_AUX 
																				 		 WHERE LINEA LIKE ''5%''))), 6);

		SET @FL_NUMERO_LOTE = RIGHT(concat(replicate(''0'', 7), (SELECT count(ID) FROM ITF_CHEQUES_SALIDA_AUX WHERE LINEA LIKE ''5%'' AND id>(SELECT max(id) FROM ITF_CHEQUES_SALIDA_AUX WHERE LINEA LIKE ''1%''))), 7); 		

			
		SET @FL_FIN_LOTE = concat(@FL_ID_REG, @FL_CODIGO_CLASE_TRANSAC, @FL_CANT_REG_INDIVIDUAL_ADICIONAL, @FL_TOTALES_DE_CONTROL, @FL_SUMA_TOTAL_DEBITO_LOTE, @FL_SUMA_TOTAL_CREDITO_LOTE, @FL_RESERVADO1, @FL_RESERVADO2, @FL_RESERVADO3, @FL_REG_ENTIDAD_ORIGEN, @FL_NUMERO_LOTE);

		---- Grabamos FIN de lote solo si hay registros individuales ingresados
		IF(0<(SELECT COUNT(*) FROM CLE_CHEQUES_ENVIADOS))
		BEGIN		
				  
			INSERT INTO dbo.ITF_CHEQUES_SALIDA_AUX (LINEA) VALUES (replace(@FL_FIN_LOTE, ''.'', ''''));
		END
			

		-------------------------------------------------------------------
		-------------Grabamos el Fin de Archivo ----------------------------------------------------------------------------------------------------------------------
		--SET @FA_CANT_LOTES = RIGHT(concat(replicate(''0'', 6), @FL_NUMERO_LOTE), 6);
		SET @CantRegistrosPrev = (SELECT (CASE WHEN (@CantRegistros + 4) % 10 = 0 THEN ((@CantRegistros + 4)/10) ELSE (FLOOR((@CantRegistros + 4)/10) + 1) END));
		--SET @FA_NUMERO_BLOQUES = RIGHT(concat(replicate(''0'', 6), @CantRegistrosPRev), 6);
		
		SET @FA_NUMERO_BLOQUES = RIGHT(concat(replicate(''0'', 6), (SELECT CEILING((count(*)+1) / CONVERT(FLOAT, 10))
																  FROM ITF_CHEQUES_SALIDA_AUX 
																  WHERE  ID>=(SELECT max(id) 
																  		  		FROM ITF_CHEQUES_SALIDA_AUX 
																  		  		WHERE LINEA LIKE ''1%''))), 6);

		--SET @FA_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 8), @CantRegistros), 8);
	
		SET @FA_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 8), (SELECT count(*)
																				 FROM ITF_CHEQUES_SALIDA_AUX
																				 WHERE (LINEA LIKE ''6%'' OR LINEA LIKE ''7%'')
																				 AND ID>(SELECT max(id) 
																				 		 FROM ITF_CHEQUES_SALIDA_AUX 
																				 		 WHERE LINEA LIKE ''1%''))), 8);
			
		--SET @FA_TOTALES_DE_CONTROL =  @FL_TOTALES_DE_CONTROL;
		--RIGHT(concat(replicate(''0'', 10), @TotalesControl), 10);
			
		SET @FA_TOTALES_DE_CONTROL = (RIGHT(concat(replicate(''0'', 10), (SELECT sum(convert(numeric,substring(linea,4,8)))
																		FROM ITF_CHEQUES_SALIDA_AUX
																		WHERE LINEA LIKE ''6%'' 
																		AND ID>(SELECT max(id) 
																				FROM ITF_CHEQUES_SALIDA_AUX 
																				WHERE LINEA LIKE ''1%''))), 10))
			
			
		--SET @FA_SUMA_TOTAL_DEBITOS = RIGHT(concat(replicate(''0'', 12), (replace(@TotalesDebitos, ''.'', ''''))), 12);

		SET @FA_SUMA_TOTAL_DEBITOS = (RIGHT(concat(replicate(''0'', 12), (SELECT sum(convert(numeric,substring(linea,21,12)))
																		FROM ITF_CHEQUES_SALIDA_AUX
																		WHERE LINEA LIKE ''8%'' 
																		AND ID>(SELECT max(id) 
																				FROM ITF_CHEQUES_SALIDA_AUX 
																				WHERE LINEA LIKE ''1%''))), 12))

		SET @FA_SUMA_TOTAL_CREDITOS = RIGHT(concat(replicate(''0'', 12), (replace(@TotalesCreditos, ''.'', ''''))),12);

		SET @FA_FIN_ARCHIVO = concat(@FA_ID_REG, @FA_CANT_LOTES, @FA_NUMERO_BLOQUES, @FA_CANT_REG_INDIVIDUAL_ADICIONAL, @FA_TOTALES_DE_CONTROL, @FA_SUMA_TOTAL_DEBITOS, @FA_SUMA_TOTAL_CREDITOS, @FA_RESERVADO);

		---- Grabamos FIN de Cabezal solo si hay registros individuales ingresados
		IF(0<(SELECT COUNT(*) FROM CLE_CHEQUES_ENVIADOS))
		BEGIN	
			INSERT INTO dbo.ITF_CHEQUES_SALIDA_AUX (LINEA) VALUES (@FA_FIN_ARCHIVO);
		END 
		
		--SET @FL_NUMERO_LOTE = CAST(@FL_NUMERO_LOTE AS NUMERIC) + 1;
		--SET @FL_NUMERO_LOTE = RIGHT(concat(replicate(''0'', 7), @FL_NUMERO_LOTE), 7);
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

		-- REVISAR
		SET @Cant_Reg_Individual_Adicional = 0;
		SET @FL_TOTALES_DE_CONTROL = ''0'';
		SET @FA_SUMA_TOTAL_DEBITOS = ''0'';
		SET @FA_SUMA_TOTAL_CREDITOS = ''0'';
		-- ESTO VER

		---- Grabamos cabecera de lote y archivo solo si hay registros individuales ingresados
		--COMENTO POR LAS DUDAS
		IF(0<(SELECT COUNT(*) FROM CLE_CHEQUES_AJUSTE WITH(NOLOCK) WHERE ENVIADO_RECIBIDO = ''E'' AND ESTADO = ''I'' AND TZ_LOCK = 0 AND FECHA_ALTA = (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)) ))
		BEGIN
			------- AJUSTES -------------
			SET @CA_CABECERA = concat(@CA_ID_REG, @CA_CODIGO_PRIORIDAD, @CA_DESTINO_INMEDIATO, @CA_ORIGEN_INMEDIATO, @CA_FECHA_PRESENTACION, @CA_HORA_PRESENTACION, @CA_IDENTIFICADOR_ARCHIVO, @CA_TAMANNO_REGISTRO, @CA_FACTOR_BLOQUE, @CA_CODIGO_FORMATO, @CA_NOMBRE_DEST_INMEDIATO, @CA_NOMBRE_ORIG_INMEDIATO, @CA_CODIGO_REFERENCIA);
		
	   		---------------- Grabar Cabecera Archivo ----------------------------------------------
			INSERT INTO ITF_CHEQUES_SALIDA_AUX (LINEA) VALUES (replace(@CA_CABECERA, ''.'', ''''));
			---------------------------------------------------------------------------------------
			SET @CL_NUMERO_LOTE = RIGHT(concat(replicate(''0'', 7), (SELECT count(ID)+1 FROM ITF_CHEQUES_SALIDA_AUX WHERE LINEA LIKE ''5%'' AND id>(SELECT max(id) FROM ITF_CHEQUES_SALIDA_AUX WHERE LINEA LIKE ''1%''))), 7); 		

			SET @CL_CABECERA = concat(@CL_ID_REG, @CL_CODIGO_CLASE_TRANSAC, @CL_RESERVADO, @CL_TIPO_REGISTRO, @CL_DESCRIP_TRANSAC, @CL_FECHA_PRESENTACION, @CL_FECHA_VENCIMIENTO, @CL_RESERVADO_CL, @CL_CODIGO_ORIGEN, @CL_ID_ENTIDAD_ORIGEN, @CL_NUMERO_LOTE);
		
			---------------- Grabar Cabecera Lote -------------------------------------------------
			INSERT INTO dbo.ITF_CHEQUES_SALIDA_AUX (LINEA) VALUES (replace(@CL_CABECERA, ''.'', ''''));
			---------------------------------------------------------------------------------------
		END
		------ Variables Cursor Ajustes --------
		DECLARE @A_ORDINAL NUMERIC(12);
		DECLARE @A_NUMERO_CHEQUE NUMERIC(12);
		DECLARE @A_BANCO NUMERIC(5);
		DECLARE @A_SUCURSAL NUMERIC(5);
		DECLARE @A_NUMERO_CUENTA NUMERIC(12);
		DECLARE @A_CODIGO_POSTAL NUMERIC(4);
		DECLARE @A_FECHA_ALTA DATETIME;
		DECLARE @A_IMPORTE NUMERIC(15,2);
		DECLARE @A_MONEDA NUMERIC(4);
		DECLARE @A_SUCURSAL_DE_INGRESO NUMERIC(5,0);

		DECLARE CursorAjustes CURSOR FOR

		SELECT ORDINAL
				, NUMERO_CHEQUE
				, BANCO
				, SUCURSAL_BANCO_GIRADO
				, NUMERO_CUENTA
				, CODIGO_POSTAL
				, FECHA_ALTA
				, IMPORTE
				, MONEDA
				, SUCURSAL_DE_INGRESO
			
		FROM CLE_CHEQUES_AJUSTE WITH(NOLOCK) 
		WHERE ENVIADO_RECIBIDO = ''E'' 
		AND ESTADO = ''I'' 
		AND TZ_LOCK = 0 
		AND FECHA_ALTA = (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)) 			
		ORDER BY NUMERO_CHEQUE;

		OPEN CursorAjustes

		FETCH NEXT FROM CursorAjustes INTO @A_ORDINAL
											, @A_NUMERO_CHEQUE
											, @A_BANCO
											, @A_SUCURSAL											
											, @A_NUMERO_CUENTA
											, @A_CODIGO_POSTAL
											, @A_FECHA_ALTA
											, @A_IMPORTE
											, @A_MONEDA
											, @A_SUCURSAL_DE_INGRESO

		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @ri_info_adicional=''01'';
			Start_2:
			IF (@SumaImportes > 9999999999.99 OR @SumaEntidad > 999999) 
			BEGIN
			
				IF @SumaSucursal > 9999
				BEGIN
					SET @SobranteSucursal = CAST(substring(CAST(@SumaSucursal AS VARCHAR), 1, (len(@SumaSucursal) - 4)) AS NUMERIC);
					SET @SumaEntidad += @SobranteSucursal;
					SET @SumaSucursal = CAST(RIGHT(@SumaSucursal, 4) AS NUMERIC);
				END
			
		  		-- 	SET @TotalesControl += @SumaEntidad + @SumaSucursal;
				--SET @FL_TOTALES_DE_CONTROL = concat((RIGHT(concat(replicate(''0'', 6), @SumaEntidad), 6)), (RIGHT(concat(replicate(''0'', 4), @SumaSucursal), 4)));
			
			
				   	   	--nuevo
   				SET @FL_TOTALES_DE_CONTROL = (RIGHT(concat(replicate(''0'', 10), (SELECT sum(convert(numeric,substring(linea,4,8)))
																				FROM ITF_CHEQUES_SALIDA_AUX
																				WHERE LINEA LIKE ''6%'' 
																				AND ID>(SELECT max(id) 
																						FROM ITF_CHEQUES_SALIDA_AUX 
																						WHERE LINEA LIKE ''5%''))), 10))
	
				SET @FL_SUMA_TOTAL_DEBITO_LOTE = (RIGHT(concat(replicate(''0'', 12), (SELECT sum(convert(numeric,substring(linea,30,10)))
																					FROM ITF_CHEQUES_SALIDA_AUX
																					WHERE LINEA LIKE ''6%'' 
																					AND ID>(SELECT max(id) 
																							FROM ITF_CHEQUES_SALIDA_AUX 
																							WHERE LINEA LIKE ''5%''))), 12))
			
			
				SET @FL_SUMA_TOTAL_CREDITO_LOTE = RIGHT(replicate(''0'', 12), 12);
				SET @TotalesDebitos += @SumaImportes;
				--SET @FL_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 6), @Cant_Reg_Individual_Adicional), 6);
				SET @FL_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 6), (SELECT count(*)
																						 FROM ITF_CHEQUES_SALIDA_AUX
																						 WHERE (LINEA LIKE ''6%'' OR LINEA LIKE ''7%'')
																						 AND ID>(SELECT max(id) 
																						 		 FROM ITF_CHEQUES_SALIDA_AUX 
																						 		 WHERE LINEA LIKE ''5%''))), 6); 
			
				SET @FL_NUMERO_LOTE = RIGHT(concat(replicate(''0'', 7), (SELECT count(ID) FROM ITF_CHEQUES_SALIDA_AUX WHERE LINEA LIKE ''5%'' AND id>(SELECT max(id) FROM ITF_CHEQUES_SALIDA_AUX WHERE LINEA LIKE ''1%''))), 7); 		

				SET @FL_FIN_LOTE = concat(@FL_ID_REG, @FL_CODIGO_CLASE_TRANSAC, @FL_CANT_REG_INDIVIDUAL_ADICIONAL, @FL_TOTALES_DE_CONTROL, @FL_SUMA_TOTAL_DEBITO_LOTE, @FL_SUMA_TOTAL_CREDITO_LOTE, @FL_RESERVADO1, @FL_RESERVADO2, @FL_RESERVADO3, @FL_REG_ENTIDAD_ORIGEN, @FL_NUMERO_LOTE);
						
				INSERT INTO dbo.ITF_CHEQUES_SALIDA_AUX (LINEA) VALUES (replace(@FL_FIN_LOTE, ''.'', ''''));
			
				---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
				-------------Grabamos el Fin de Archivo -----------------------------------------------------------------------------------------------------------------------------------------------------
				--SET @FA_CANT_LOTES = RIGHT(concat(replicate(''0'', 6), @FL_NUMERO_LOTE), 6);
				SET @CantRegistrosPrev = (SELECT (CASE WHEN (@CantRegistros + 4) % 10 = 0 THEN ((@CantRegistros + 4)/10) ELSE (FLOOR((@CantRegistros + 4)/10) + 1) END));
				--SET @FA_NUMERO_BLOQUES = RIGHT(concat(replicate(''0'', 6), @CantRegistrosPrev), 6);
			
			
				SET @FA_NUMERO_BLOQUES = RIGHT(concat(replicate(''0'', 6), (SELECT CEILING((count(*)+1) / CONVERT(FLOAT, 10))
																		  FROM ITF_CHEQUES_SALIDA_AUX 
																		  WHERE  ID>=(SELECT max(id) 
																		  		  		FROM ITF_CHEQUES_SALIDA_AUX 
																		  		  		WHERE LINEA LIKE ''1%''))), 6);

				--SET @FA_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 8), @CantRegistros), 8);
			
				SET @FA_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 8), (SELECT count(*)
																						 FROM ITF_CHEQUES_SALIDA_AUX
																						 WHERE (LINEA LIKE ''6%'' OR LINEA LIKE ''7%'')
																						 AND ID>(SELECT max(id) 
																						 		 FROM ITF_CHEQUES_SALIDA_AUX 
																						 		 WHERE LINEA LIKE ''1%''))), 8);
			
				--SET @FA_TOTALES_DE_CONTROL = @FL_TOTALES_DE_CONTROL; --igualo al totales de control de fin de lote pq tiene que ser igual
			
			   	SET @FA_TOTALES_DE_CONTROL = (RIGHT(concat(replicate(''0'', 10), (SELECT sum(convert(numeric,substring(linea,4,8)))
																				FROM ITF_CHEQUES_SALIDA_AUX
																				WHERE LINEA LIKE ''6%'' 
																				AND ID>(SELECT max(id) 
																						FROM ITF_CHEQUES_SALIDA_AUX 
																						WHERE LINEA LIKE ''1%''))), 10))
			

				SET @FA_SUMA_TOTAL_DEBITOS = (RIGHT(concat(replicate(''0'', 12), (SELECT sum(convert(numeric,substring(linea,21,12)))
																				FROM ITF_CHEQUES_SALIDA_AUX
																				WHERE LINEA LIKE ''8%'' 
																				AND ID>(SELECT max(id) 
																						FROM ITF_CHEQUES_SALIDA_AUX 
																						WHERE LINEA LIKE ''1%''))), 12))
		
				SET @FA_SUMA_TOTAL_CREDITOS = RIGHT(concat(replicate(''0'', 12), (replace(@TotalesCreditos, ''.'', ''''))),12);

				SET @FA_FIN_ARCHIVO = concat(@FA_ID_REG, @FA_CANT_LOTES, @FA_NUMERO_BLOQUES, @FA_CANT_REG_INDIVIDUAL_ADICIONAL, @FA_TOTALES_DE_CONTROL, @FA_SUMA_TOTAL_DEBITOS, @FA_SUMA_TOTAL_CREDITOS, @FA_RESERVADO);
			
				INSERT INTO dbo.ITF_CHEQUES_SALIDA_AUX (LINEA) VALUES (@FA_FIN_ARCHIVO);
			
				--SET @FL_NUMERO_LOTE = CAST(@FL_NUMERO_LOTE AS NUMERIC) + 1;
				--SET @FL_NUMERO_LOTE = RIGHT(concat(replicate(''0'', 7), @FL_NUMERO_LOTE), 7);
				-----------------------------------------------------------------------------------------------------------------------------------------------------------------
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
				SET @SumaSucursal = 0;
				-------------------------------------------------------------------------------------------------------------------------------------------------------------------
				--------- Grabamos nueva Cabecera de Archivo ----------------------------------------------------------------------------------------------------------------------
				SET @CA_CABECERA = concat(@CA_ID_REG, @CA_CODIGO_PRIORIDAD, @CA_DESTINO_INMEDIATO, @CA_ORIGEN_INMEDIATO, @CA_FECHA_PRESENTACION, @CA_HORA_PRESENTACION, @CA_IDENTIFICADOR_ARCHIVO, @CA_TAMANNO_REGISTRO, @CA_FACTOR_BLOQUE, @CA_CODIGO_FORMATO, @CA_NOMBRE_DEST_INMEDIATO, @CA_NOMBRE_ORIG_INMEDIATO, @CA_CODIGO_REFERENCIA);
			
				INSERT INTO dbo.ITF_CHEQUES_SALIDA_AUX (LINEA) VALUES (@CA_CABECERA);
				----------------------------------------------------------------------------------------------------------------------------------------------------------------------
				--------- Grabamos nueva Cabecera Lote ------------------------------------------------------------------------------------------------------------------------------------------------------
				SET @CL_NUMERO_LOTE = RIGHT(concat(replicate(''0'', 7), (SELECT count(ID)+1 FROM ITF_CHEQUES_SALIDA_AUX WHERE LINEA LIKE ''5%'' AND id>(SELECT max(id) FROM ITF_CHEQUES_SALIDA_AUX WHERE LINEA LIKE ''1%''))), 7); 		

				SET @CL_CABECERA = concat(@CL_ID_REG, @CL_CODIGO_CLASE_TRANSAC, @CL_RESERVADO, @CL_TIPO_REGISTRO, @CL_DESCRIP_TRANSAC, @CL_FECHA_PRESENTACION, @CL_FECHA_VENCIMIENTO, @CL_RESERVADO_CL, @CL_CODIGO_ORIGEN, @CL_ID_ENTIDAD_ORIGEN, @CL_NUMERO_LOTE);
				INSERT INTO dbo.ITF_CHEQUES_SALIDA_AUX (LINEA) VALUES (@CL_CABECERA);
				---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

			END
		
			SET @CantRegistros += 1;
		
			SET @Cant_Reg_Individual_Adicional += 1;
		
			
			IF	(@Excedente<>0)
			BEGIN
				SET @A_IMPORTE = @Excedente;
				SET @CountExcedente += 1;
			END
			IF	(@A_IMPORTE>99999999.99)
			BEGIN
				SET @Excedente = (@A_IMPORTE - 99999999.99);
				SET @A_IMPORTE = 99999999.99;
				SET @CountExcedente += 1;
				--SET @RA_CONTADOR_REGISTRO_ORIGEN = @RI_CONTADOR_REGISTRO;
			END
			ELSE
			BEGIN
		   		SET @Excedente = 0;
			END
--***************************************************************************************--		
-- puede que aca falte la condicion que se usa para los otros casos IF(@CountExcedente>1)--
--***************************************************************************************--	
			SET @SumaSucursal += 0888;  --sumo la sucursal que hay que harcodear
			SET @SumaEntidad +=  @A_BANCO;
			SET @SumaImportes += @A_IMPORTE;

			SET @RI_ENTIDAD_DEBITAR = concat(RIGHT(concat(replicate(''0'', 4), @A_BANCO), 4), ''0888'');
			SET @RI_CUENTA_DEBITAR = RIGHT(concat(replicate(''0'', 17), ''88888888888''), 17);
			SET @RI_NUMERO_CHEQUE = ''000088888888888'';

			IF @SumaImportes>9999999999.99 GOTO Start_2

			SET @RI_IMPORTE = RIGHT(concat(replicate(''0'', 10), replace(CAST(@A_IMPORTE AS VARCHAR),''.'','''')), 10);
			SET @RI_CODIGO_POSTAL = RIGHT(concat(''00'', replicate(''0'', 4), @A_CODIGO_POSTAL), 6);
			SET @RI_INFO_ADICIONAL = ''01'';
			SET @RI_REGISTRO_ADICIONAL = ''0'';
			SET @RI_CONTADOR_REGISTRO = concat(''0311'', RIGHT(concat(replicate(''0'', 4), (@A_SUCURSAL_DE_INGRESO)), 4), RIGHT(concat(replicate(''0'', 7), (SELECT NUMERICO_1 FROM ITF_MASTER_PARAMETROS WHERE CODIGO = 136)), 7)); 
			
			SET @RI_REGISTRO_INDIVIDUAL = concat(@RI_ID_REG, @RI_CODIGO_TRANSAC, @RI_ENTIDAD_DEBITAR, @RI_RESERVADO, @RI_CUENTA_DEBITAR, @RI_IMPORTE, @RI_NUMERO_CHEQUE, @RI_CODIGO_POSTAL, @RI_PUNTO_INTERCAMBIO, @RI_INFO_ADICIONAL, @RI_REGISTRO_ADICIONAL, @RI_CONTADOR_REGISTRO);
	   											
	   		INSERT INTO dbo.ITF_CHEQUES_SALIDA_AUX (LINEA) VALUES (replace(@RI_REGISTRO_INDIVIDUAL, ''.'', ''''));
		
			----------------------------- Grabar historial --------------------------------------------------------------------------------------------------------------------------------------------------
			INSERT INTO ITF_COELSA_CHEQUES_OTROS (ID_TICKET, ID_PROCESO, FECHAPROCESO, CODIGO_TRANSACCION, BANCO, SUCURSAL, CUENTA, IMPORTE, CODIGO_POSTAL, FECHA_PRESENTADO, FECHA_VENCIMIENTO, NRO_CHEQUE, PUNTO_INTERCAMBIO, TRACE_NUMBER, ESTADO, TIPO, MONEDA, ORDINAL)
			VALUES (@TICKET, @TICKET, (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)), @RI_CODIGO_TRANSAC, @A_BANCO, @A_SUCURSAL, @A_NUMERO_CUENTA, @A_IMPORTE, @A_CODIGO_POSTAL, @A_FECHA_ALTA, @A_FECHA_ALTA, @A_NUMERO_CHEQUE, @RI_PUNTO_INTERCAMBIO, @RI_CONTADOR_REGISTRO, ''P'', ''A'', @A_MONEDA, @A_ORDINAL);
			-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
			---------------------------- Actualizar secuenciador unico -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
			UPDATE dbo.ITF_MASTER_PARAMETROS SET NUMERICO_1 = (NUMERICO_1 + 1) WHERE CODIGO = 136;
			-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------    	
			---------------------------------------------- Actualizar atributos del ajuste -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
			UPDATE dbo.CLE_CHEQUES_AJUSTE SET TRACKNUMBER = @RI_CONTADOR_REGISTRO, ESTADO = ''P'', FECHA_ENVIO_CAMARA = (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)) WHERE BANCO = @A_BANCO AND ORDINAL = @A_ORDINAL AND  ENVIADO_RECIBIDO = ''E'' AND ESTADO = ''I'' AND TZ_LOCK = 0 AND FECHA_ALTA = @A_FECHA_ALTA;
			-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------   	
			IF (@Excedente = 0)
			BEGIN		     	       				
		
				FETCH NEXT FROM CursorAjustes INTO @A_ORDINAL
													, @A_NUMERO_CHEQUE
													, @A_BANCO
													, @A_SUCURSAL
													, @A_NUMERO_CUENTA
													, @A_CODIGO_POSTAL
													, @A_FECHA_ALTA
													, @A_IMPORTE
													, @A_MONEDA
													, @A_SUCURSAL_DE_INGRESO

				SET @CountExcedente = 0;
	   			--SET @RA_CONTADOR_REGISTRO_ORIGEN = '''';
			END
			
		END -- While Ajustes

		CLOSE CursorAjustes
		DEALLOCATE CursorAjustes

		IF @SumaSucursal > 9999
		BEGIN
			SET @SobranteSucursal = CAST(substring(CAST(@SumaSucursal AS VARCHAR), 1, (len(@SumaSucursal) - 4)) AS NUMERIC);
			SET @SumaEntidad += @SobranteSucursal;
			SET @SumaSucursal = CAST(RIGHT(@SumaSucursal, 4) AS NUMERIC);
		END
		
		--SET @TotalesControl += @SumaEntidad + @SumaSucursal;
		--SET @FL_TOTALES_DE_CONTROL = concat((RIGHT(concat(replicate(''0'', 6), @SumaEntidad), 6)), (RIGHT(concat(replicate(''0'', 4), @SumaSucursal), 4)));
	
		   	   	--nuevo
   		SET @FL_TOTALES_DE_CONTROL = (RIGHT(concat(replicate(''0'', 10), (SELECT sum(convert(numeric,substring(linea,4,8)))
																		FROM ITF_CHEQUES_SALIDA_AUX
																		WHERE LINEA LIKE ''6%'' 
																		AND ID>(SELECT max(id) 
																				FROM ITF_CHEQUES_SALIDA_AUX 
																				WHERE LINEA LIKE ''5%''))), 10))
	
		SET @FL_SUMA_TOTAL_DEBITO_LOTE = (RIGHT(concat(replicate(''0'', 12), (SELECT sum(convert(numeric,substring(linea,30,10)))
																			FROM ITF_CHEQUES_SALIDA_AUX
																			WHERE LINEA LIKE ''6%'' 
																			AND ID>(SELECT max(id) 
																					FROM ITF_CHEQUES_SALIDA_AUX 
																					WHERE LINEA LIKE ''5%''))), 12))
		SET @FL_SUMA_TOTAL_CREDITO_LOTE = RIGHT(replicate(''0'', 12), 12);
		SET @TotalesDebitos += @SumaImportes;
		--SET @FL_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 6), @Cant_Reg_Individual_Adicional), 6);
		SET @FL_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 6), (SELECT count(*)
																				 FROM ITF_CHEQUES_SALIDA_AUX
																				 WHERE (LINEA LIKE ''6%'' OR LINEA LIKE ''7%'')
																				 AND ID>(SELECT max(id) 
																				 		 FROM ITF_CHEQUES_SALIDA_AUX 
																				 		 WHERE LINEA LIKE ''5%''))), 6);	 
		SET @FL_NUMERO_LOTE = RIGHT(concat(replicate(''0'', 7), (SELECT count(ID) FROM ITF_CHEQUES_SALIDA_AUX WHERE LINEA LIKE ''5%'' AND id>(SELECT max(id) FROM ITF_CHEQUES_SALIDA_AUX WHERE LINEA LIKE ''1%''))), 7); 		

		-- Grabamos fin de lote y archivo solo si hay registros individuales ingresados
		IF(0< @Cant_Reg_Individual_Adicional)
		BEGIN
			SET @FL_FIN_LOTE = concat(@FL_ID_REG, @FL_CODIGO_CLASE_TRANSAC, @FL_CANT_REG_INDIVIDUAL_ADICIONAL, @FL_TOTALES_DE_CONTROL, @FL_SUMA_TOTAL_DEBITO_LOTE, @FL_SUMA_TOTAL_CREDITO_LOTE, @FL_RESERVADO1, @FL_RESERVADO2, @FL_RESERVADO3, @FL_REG_ENTIDAD_ORIGEN, @FL_NUMERO_LOTE);
				
			INSERT INTO dbo.ITF_CHEQUES_SALIDA_AUX (LINEA) VALUES (replace(@FL_FIN_LOTE, ''.'', ''''));

			-------------------------------------------------------------------
			-------------Grabamos el Fin de Archivo ----------------------------------------------------------------------------------------------------------------------
			--SET @FA_CANT_LOTES = RIGHT(concat(replicate(''0'', 6), @FL_NUMERO_LOTE), 6);
			SET @CantRegistrosPrev = (SELECT (CASE WHEN (@CantRegistros + 4) % 10 = 0 THEN ((@CantRegistros + 4)/10) ELSE (FLOOR((@CantRegistros + 4)/10) + 1) END));
			--SET @FA_NUMERO_BLOQUES = RIGHT(concat(replicate(''0'', 6), @CantRegistrosPrev), 6);
		
			SET @FA_NUMERO_BLOQUES = RIGHT(concat(replicate(''0'', 6), (SELECT CEILING((count(*)+1) / CONVERT(FLOAT, 10))
																	  FROM ITF_CHEQUES_SALIDA_AUX 
																	  WHERE  ID>=(SELECT max(id) 
																	  		  		FROM ITF_CHEQUES_SALIDA_AUX 
																	  		  		WHERE LINEA LIKE ''1%''))), 6);
		
			SET @FA_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 8), (SELECT count(*)
																					 FROM ITF_CHEQUES_SALIDA_AUX
																					 WHERE (LINEA LIKE ''6%'' OR LINEA LIKE ''7%'')
																					 AND ID>(SELECT max(id) 
																					 		 FROM ITF_CHEQUES_SALIDA_AUX 
																					 		 WHERE LINEA LIKE ''1%''))), 8);
				
			--SET @FA_TOTALES_DE_CONTROL = @FL_TOTALES_DE_CONTROL; --igualo al totales de control de fin de lote pq tiene que ser igual
		
		
		   	SET @FA_TOTALES_DE_CONTROL = (RIGHT(concat(replicate(''0'', 10), (SELECT sum(convert(numeric,substring(linea,4,8)))
																			FROM ITF_CHEQUES_SALIDA_AUX
																			WHERE LINEA LIKE ''6%'' 
																			AND ID>(SELECT max(id) 
																					FROM ITF_CHEQUES_SALIDA_AUX 
																					WHERE LINEA LIKE ''1%''))), 10))
		

			SET @FA_SUMA_TOTAL_DEBITOS = (RIGHT(concat(replicate(''0'', 12), (SELECT sum(convert(numeric,substring(linea,21,12)))
			 																FROM ITF_CHEQUES_SALIDA_AUX
																			WHERE LINEA LIKE ''8%'' 
																			AND ID>(SELECT max(id) 
																					FROM ITF_CHEQUES_SALIDA_AUX 
																					WHERE LINEA LIKE ''1%''))), 12))
			
			SET @FA_SUMA_TOTAL_CREDITOS = RIGHT(concat(replicate(''0'', 12), (replace(@TotalesCreditos, ''.'', ''''))),12);
		
			SET @FA_FIN_ARCHIVO = concat(@FA_ID_REG, @FA_CANT_LOTES, @FA_NUMERO_BLOQUES, @FA_CANT_REG_INDIVIDUAL_ADICIONAL, @FA_TOTALES_DE_CONTROL, @FA_SUMA_TOTAL_DEBITOS, @FA_SUMA_TOTAL_CREDITOS, @FA_RESERVADO);
				
			INSERT INTO dbo.ITF_CHEQUES_SALIDA_AUX (LINEA) VALUES (@FA_FIN_ARCHIVO);
				
			--SET @FL_NUMERO_LOTE = CAST(@FL_NUMERO_LOTE AS NUMERIC) + 1;
			--SET @FL_NUMERO_LOTE = RIGHT(concat(replicate(''0'', 7), @FL_NUMERO_LOTE), 7);
		END
		--------------- DPF PESOS ----------------------------------------------------------------------------------------------------------------------------------------
		------------ Variables CursorDPF ---------------------
		DECLARE @D_TIPO_DOCUMENTO VARCHAR(4);
		DECLARE @D_BANCO NUMERIC(4);
		DECLARE @D_SUCURSAL NUMERIC(5);
		DECLARE @D_CUENTA NUMERIC(12);
		DECLARE @D_IMPORTE NUMERIC(15,2);
		DECLARE @D_NUMERO_DPF NUMERIC(12);
		DECLARE @D_CODIGO_POSTAL NUMERIC(4);
		DECLARE @D_MONEDA NUMERIC(4);
		DECLARE @D_FECHA DATETIME;
		DECLARE @D_SUCURSAL_DE_INGRESO NUMERIC(5,0);

		-------------------------------------------------------

		---- Grabamos cabecera de lote y archivo solo si hay registros individuales ingresados
		--COMENTO POR LAS DUDAS
		IF(0<(SELECT COUNT(*) FROM CLE_DPF_SALIENTE WITH(NOLOCK) WHERE TZ_LOCK = 0 AND ESTADO = 1 AND MONEDA = 1 AND FECHA_ALTA = (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK))  ))
		BEGIN
			------- AJUSTES -------------
			SET @CA_CABECERA = concat(@CA_ID_REG, @CA_CODIGO_PRIORIDAD, @CA_DESTINO_INMEDIATO, @CA_ORIGEN_INMEDIATO, @CA_FECHA_PRESENTACION, @CA_HORA_PRESENTACION, @CA_IDENTIFICADOR_ARCHIVO, @CA_TAMANNO_REGISTRO, @CA_FACTOR_BLOQUE, @CA_CODIGO_FORMATO, @CA_NOMBRE_DEST_INMEDIATO, @CA_NOMBRE_ORIG_INMEDIATO, @CA_CODIGO_REFERENCIA);
		
			---------------- Grabar Cabecera Archivo ----------------------------------------------
			INSERT INTO dbo.ITF_CHEQUES_SALIDA_AUX (LINEA) VALUES (replace(@CA_CABECERA, ''.'', ''''));
			---------------------------------------------------------------------------------------
			SET @CL_NUMERO_LOTE = RIGHT(concat(replicate(''0'', 7), (SELECT count(ID)+1 FROM ITF_CHEQUES_SALIDA_AUX WHERE LINEA LIKE ''5%'' AND id>(SELECT max(id) FROM ITF_CHEQUES_SALIDA_AUX WHERE LINEA LIKE ''1%''))), 7); 		
			SET @CL_CABECERA = concat(@CL_ID_REG, @CL_CODIGO_CLASE_TRANSAC, @CL_RESERVADO, @CL_TIPO_REGISTRO, @CL_DESCRIP_TRANSAC, @CL_FECHA_PRESENTACION, @CL_FECHA_VENCIMIENTO, @CL_RESERVADO_CL, @CL_CODIGO_ORIGEN, @CL_ID_ENTIDAD_ORIGEN, @CL_NUMERO_LOTE);
		
			---------------- Grabar Cabecera Lote -------------------------------------------------
			INSERT INTO dbo.ITF_CHEQUES_SALIDA_AUX (LINEA) VALUES (replace(@CL_CABECERA, ''.'', ''''));
			---------------------------------------------------------------------------------------
		END

		DECLARE CursorDPF CURSOR FOR

		SELECT TIPO_DOCUMENTO
				, BANCO_GIRADO
				, SUCURSAL_BANCO_GIRADO
				, NUMERICO_CUENTA_GIRADORA
				, IMPORTE, NUMERO_DPF 
				, COD_POSTAL
				, MONEDA
				, FECHA_ALTA
				, SUCURSAL_DE_INGRESO
		FROM CLE_DPF_SALIENTE
		WHERE TZ_LOCK = 0 
		AND ESTADO = 1 
		AND MONEDA = 1 
		AND FECHA_ALTA = (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK))  

		OPEN CursorDPF FETCH NEXT FROM CursorDPF INTO @D_TIPO_DOCUMENTO
														, @D_BANCO
														, @D_SUCURSAL
														, @D_CUENTA
														, @D_IMPORTE
														, @D_NUMERO_DPF
														, @D_CODIGO_POSTAL
														, @D_MONEDA
														, @D_FECHA
														, @D_SUCURSAL_DE_INGRESO

		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @ri_info_adicional=''00''
			Start_3:
			IF (@SumaImportes > 9999999999.99 OR @SumaEntidad > 999999) -- 99 millones
			BEGIN
			
				IF @SumaSucursal > 9999
				BEGIN
					SET @SobranteSucursal = CAST(substring(CAST(@SumaSucursal AS VARCHAR), 1, (len(@SumaSucursal) - 4)) AS NUMERIC);
					SET @SumaEntidad += @SobranteSucursal;
					SET @SumaSucursal = CAST(RIGHT(@SumaSucursal, 4) AS NUMERIC);
				END
			
		   		--	SET @TotalesControl += @SumaEntidad + @SumaSucursal;
				--SET @FL_TOTALES_DE_CONTROL = concat((RIGHT(concat(replicate(''0'', 6), @SumaEntidad), 6)), (RIGHT(concat(replicate(''0'', 4), @SumaSucursal), 4)));
			
			
				   	   	--nuevo
   				SET @FL_TOTALES_DE_CONTROL = (RIGHT(concat(replicate(''0'', 10), (SELECT sum(convert(numeric,substring(linea,4,8)))
																				FROM ITF_CHEQUES_SALIDA_AUX
																				WHERE LINEA LIKE ''6%'' 
																				AND ID>(SELECT max(id) 
																						FROM ITF_CHEQUES_SALIDA_AUX 
																						WHERE LINEA LIKE ''5%''))), 10))
			
				--SET @FL_SUMA_TOTAL_DEBITO_LOTE = RIGHT(concat(replicate(''0'', 12), (replace(@SumaImportes, ''.'', ''''))), 12); 
				SET @FL_SUMA_TOTAL_DEBITO_LOTE = (RIGHT(concat(replicate(''0'', 12), (SELECT sum(convert(numeric,substring(linea,30,10)))
																					FROM ITF_CHEQUES_SALIDA_AUX
																					WHERE LINEA LIKE ''6%'' 
																					AND ID>(SELECT max(id) 
																							FROM ITF_CHEQUES_SALIDA_AUX 
																							WHERE LINEA LIKE ''5%''))), 12))

				SET @FL_SUMA_TOTAL_CREDITO_LOTE = RIGHT(replicate(''0'', 12), 12);
				SET @TotalesDebitos += @SumaImportes;
				--SET @FL_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 6), @Cant_Reg_Individual_Adicional), 6); 
				SET @FL_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 6), (SELECT count(*) FROM ITF_CHEQUES_SALIDA_AUX WHERE (LINEA LIKE ''6%'' OR LINEA LIKE ''7%'') AND ID>(SELECT max(id) FROM ITF_CHEQUES_SALIDA_AUX WHERE LINEA LIKE ''5%''))), 6);
				SET @FL_NUMERO_LOTE = RIGHT(concat(replicate(''0'', 7), (SELECT count(ID) FROM ITF_CHEQUES_SALIDA_AUX WHERE LINEA LIKE ''5%'' AND id>(SELECT max(id) FROM ITF_CHEQUES_SALIDA_AUX WHERE LINEA LIKE ''1%''))), 7); 		

				SET @FL_FIN_LOTE = concat(@FL_ID_REG, @FL_CODIGO_CLASE_TRANSAC, @FL_CANT_REG_INDIVIDUAL_ADICIONAL, @FL_TOTALES_DE_CONTROL, @FL_SUMA_TOTAL_DEBITO_LOTE, @FL_SUMA_TOTAL_CREDITO_LOTE, @FL_RESERVADO1, @FL_RESERVADO2, @FL_RESERVADO3, @FL_REG_ENTIDAD_ORIGEN, @FL_NUMERO_LOTE);
			
				INSERT INTO dbo.ITF_CHEQUES_SALIDA_AUX (LINEA) VALUES (replace(@FL_FIN_LOTE, ''.'', ''''));
			
				--SET @FL_NUMERO_LOTE = CAST(@FL_NUMERO_LOTE AS NUMERIC) + 1;
				--SET @FL_NUMERO_LOTE = RIGHT(concat(replicate(''0'', 7), @FL_NUMERO_LOTE), 7);
				-------------------------------------------------------------------
				-------------Grabamos el Fin de Archivo ----------------------------------------------------------------------------------------------------------------------
				--	SET @FA_CANT_LOTES = RIGHT(concat(replicate(''0'', 6), @FL_NUMERO_LOTE), 6);
				SET @CantRegistrosPrev = (SELECT (CASE WHEN (@CantRegistros + 4) % 10 = 0 THEN ((@CantRegistros + 4)/10) ELSE (FLOOR((@CantRegistros + 4)/10) + 1) END));
				--SET @FA_NUMERO_BLOQUES = RIGHT(concat(replicate(''0'', 6), @CantRegistrosPrev), 6);
			
			
				SET @FA_NUMERO_BLOQUES = RIGHT(concat(replicate(''0'', 6), (SELECT CEILING((count(*)+1) / CONVERT(FLOAT, 10))
																		  FROM ITF_CHEQUES_SALIDA_AUX 
																		  WHERE  ID>=(SELECT max(id) 
																		  		  		FROM ITF_CHEQUES_SALIDA_AUX 
																		  		  		WHERE LINEA LIKE ''1%''))), 6);

				--SET @FA_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 8), @CantRegistros), 8);
			
				SET @FA_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 8), (SELECT count(*)
																						 FROM ITF_CHEQUES_SALIDA_AUX
																						 WHERE (LINEA LIKE ''6%'' OR LINEA LIKE ''7%'')
																						 AND ID>(SELECT max(id) 
																						 		 FROM ITF_CHEQUES_SALIDA_AUX 
																						 		 WHERE LINEA LIKE ''1%''))), 8);
			
				--SET @FA_TOTALES_DE_CONTROL = @FL_TOTALES_DE_CONTROL; --igualo al totales de control de fin de lote pq tiene que ser igual
			
			   	SET @FA_TOTALES_DE_CONTROL = (RIGHT(concat(replicate(''0'', 10), (SELECT sum(convert(numeric,substring(linea,4,8)))
																				FROM ITF_CHEQUES_SALIDA_AUX
																				WHERE LINEA LIKE ''6%'' 
																				AND ID>(SELECT max(id) 
																						FROM ITF_CHEQUES_SALIDA_AUX 
																						WHERE LINEA LIKE ''1%''))), 10))
			
				--SET @FA_SUMA_TOTAL_DEBITOS = RIGHT(concat(replicate(''0'', 12), (replace(@TotalesDebitos, ''.'', ''''))), 12);
			
				SET @FA_SUMA_TOTAL_DEBITOS = (RIGHT(concat(replicate(''0'', 12), (SELECT sum(convert(numeric,substring(linea,21,12)))
																				FROM ITF_CHEQUES_SALIDA_AUX
																				WHERE LINEA LIKE ''8%'' 
																				AND ID>(SELECT max(id) 
																						FROM ITF_CHEQUES_SALIDA_AUX 
																						WHERE LINEA LIKE ''1%''))), 12))
			
			
				SET @FA_SUMA_TOTAL_CREDITOS = RIGHT(concat(replicate(''0'', 12), (replace(@TotalesCreditos, ''.'', ''''))),12);

				SET @FA_FIN_ARCHIVO = concat(@FA_ID_REG, @FA_CANT_LOTES, @FA_NUMERO_BLOQUES, @FA_CANT_REG_INDIVIDUAL_ADICIONAL, @FA_TOTALES_DE_CONTROL, @FA_SUMA_TOTAL_DEBITOS, @FA_SUMA_TOTAL_CREDITOS, @FA_RESERVADO);
			
				INSERT INTO dbo.ITF_CHEQUES_SALIDA_AUX (LINEA) VALUES (@FA_FIN_ARCHIVO);
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
			
				INSERT INTO dbo.ITF_CHEQUES_SALIDA_AUX (LINEA) VALUES (@CA_CABECERA);
				----------------------------------------------------------------------------------------------------------------------------------------------------------------------
				--------- Grabamos nueva Cabecera Lote ------------------------------------------------------------------------------------------------------------------------------------------------------
				SET @CL_NUMERO_LOTE = RIGHT(concat(replicate(''0'', 7), (SELECT count(ID)+1 FROM ITF_CHEQUES_SALIDA_AUX WHERE LINEA LIKE ''5%'' AND id>(SELECT max(id) FROM ITF_CHEQUES_SALIDA_AUX WHERE LINEA LIKE ''1%''))), 7); 		
				SET @CL_CABECERA = concat(@CL_ID_REG, @CL_CODIGO_CLASE_TRANSAC, @CL_RESERVADO, @CL_TIPO_REGISTRO, @CL_DESCRIP_TRANSAC, @CL_FECHA_PRESENTACION, @CL_FECHA_VENCIMIENTO, @CL_RESERVADO_CL, @CL_CODIGO_ORIGEN, @CL_ID_ENTIDAD_ORIGEN, @CL_NUMERO_LOTE);
				INSERT INTO dbo.ITF_CHEQUES_SALIDA_AUX (LINEA) VALUES (@CL_CABECERA);
				---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

			END
		
			SET @CantRegistros += 1;
			SET @Cant_Reg_Individual_Adicional += 1;
		
			IF	(@Excedente<>0)
			BEGIN
				SET @D_IMPORTE = @Excedente;
				SET @CountExcedente += 1;
			END
			IF	(@D_IMPORTE>99999999.99)
			BEGIN
				SET @Excedente = (@D_IMPORTE - 99999999.99);
				SET @D_IMPORTE = 99999999.99;
				SET @CountExcedente += 1;
				--SET @RA_CONTADOR_REGISTRO_ORIGEN = @RI_CONTADOR_REGISTRO;
			END
			ELSE
			BEGIN
				SET @Excedente = 0;
			END
		
		
			SET @SumaSucursal += @D_SUCURSAL;
			SET @SumaEntidad += @D_BANCO;
			SET @SumaImportes += @D_IMPORTE;
		
			---------------------------- Grabar Registro Individual -----------------------------------------------------------------------------------------------------------------------------------------
			SET @RI_ENTIDAD_DEBITAR = concat(RIGHT(concat(replicate(''0'', 4), @D_BANCO), 4), RIGHT(concat(replicate(''0'', 4), @D_SUCURSAL), 4));
			SET @RI_CUENTA_DEBITAR = RIGHT(concat(replicate(''0'', 17), @D_CUENTA), 17);
			SET @RI_NUMERO_CHEQUE = concat(''00'', RIGHT(concat(replicate(''0'', 13), @D_NUMERO_DPF), 13));
		
			IF(@CountExcedente>1)
			BEGIN
				SET @SumaSucursal += 0888;  --sumo la sucursal que hay que harcodear
				SET @SumaEntidad +=  @D_BANCO;
				SET @SumaImportes += @D_IMPORTE;

				SET @RI_ENTIDAD_DEBITAR = concat(RIGHT(concat(replicate(''0'', 4), @D_BANCO), 4), ''0888'');
				SET @RI_CUENTA_DEBITAR = RIGHT(concat(replicate(''0'', 17), ''88888888888''), 17);
				SET @RI_NUMERO_CHEQUE = ''000088888888888'';   
			END
			ELSE --la razon de este else, es que SumaSucursal, cuando hay excedente tiene que acumular 0888
			BEGIN
				SET @SumaSucursal += @D_SUCURSAL;
				SET @SumaEntidad +=  @D_BANCO;
				SET @SumaImportes += @D_IMPORTE;

				SET @RI_ENTIDAD_DEBITAR = concat(RIGHT(concat(replicate(''0'', 4), @D_BANCO), 4), RIGHT(concat(replicate(''0'', 4), @D_SUCURSAL), 4));
			
				SET @RI_CUENTA_DEBITAR = RIGHT(concat(replicate(''0'', 17), @D_CUENTA), 17);
			
				SET @RI_NUMERO_CHEQUE = concat(''00'', RIGHT(concat(replicate(''0'', 13), @D_NUMERO_DPF), 13));
	 
			END

			IF @SumaImportes>9999999999.99 GOTO Start_3
			
			SET @RI_IMPORTE = RIGHT(concat(replicate(''0'', 10), replace(CAST(@D_IMPORTE AS VARCHAR),''.'','''')), 10);
			SET @RI_CODIGO_POSTAL = concat(''00'',RIGHT(concat( replicate(''0'', 4), @D_CODIGO_POSTAL), 4));
			SET @RI_INFO_ADICIONAL = ''00'';
			SET @RI_REGISTRO_ADICIONAL = ''0'';
			SET @RI_CONTADOR_REGISTRO = concat(''0311'', RIGHT(concat(replicate(''0'', 4), (@D_SUCURSAL_DE_INGRESO)), 4), RIGHT(concat(replicate(''0'', 7), (SELECT NUMERICO_1 FROM ITF_MASTER_PARAMETROS WHERE CODIGO = 136)), 7)); 
		
PRINT ''1:''
PRINT @RI_REGISTRO_INDIVIDUAL

PRINT ''8:''
PRINT @RI_CODIGO_POSTAL

				
			SET @RI_REGISTRO_INDIVIDUAL = concat(@RI_ID_REG, 
												 @RI_CODIGO_TRANSAC, 
											 @RI_ENTIDAD_DEBITAR, 
											 @RI_RESERVADO, 
											 @RI_CUENTA_DEBITAR, 
											 @RI_IMPORTE, 
											 @RI_NUMERO_CHEQUE, 
											 @RI_CODIGO_POSTAL, 
											 @RI_PUNTO_INTERCAMBIO, 
											 @RI_INFO_ADICIONAL, 
											 @RI_REGISTRO_ADICIONAL, 
											 @RI_CONTADOR_REGISTRO);
	 
		
			INSERT INTO dbo.ITF_CHEQUES_SALIDA_AUX (LINEA) VALUES (replace(@RI_REGISTRO_INDIVIDUAL, ''.'', ''''));
			-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		   
			----------------------------- Actualizar secuencial unico -------------------------------------
			UPDATE dbo.ITF_MASTER_PARAMETROS SET NUMERICO_1 = (NUMERICO_1 + 1) WHERE CODIGO = 136;
			-----------------------------------------------------------------------------------------------
		
			----------------------------- Grabar historial ---------------------------------------------------------------------------------------------------------------------------------------------------------------
			INSERT INTO ITF_COELSA_CHEQUES_OTROS (ID_TICKET, ID_PROCESO, FECHAPROCESO, CODIGO_TRANSACCION, BANCO, SUCURSAL, CUENTA, IMPORTE, CODIGO_POSTAL, FECHA_PRESENTADO, FECHA_VENCIMIENTO, NRO_CHEQUE, PUNTO_INTERCAMBIO, TRACE_NUMBER, ESTADO, TIPO, MONEDA, TIPO_DOCUMENTO)
			VALUES (@TICKET, @TICKET, (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)), @RI_CODIGO_TRANSAC, @D_BANCO, @D_SUCURSAL, @D_CUENTA, @D_IMPORTE, @D_CODIGO_POSTAL, @D_FECHA, @D_FECHA, @D_NUMERO_DPF, @RI_PUNTO_INTERCAMBIO, @RI_CONTADOR_REGISTRO, ''P'', ''D'', @D_MONEDA, @D_TIPO_DOCUMENTO);
			--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		
			---------------- Actualizar informacion del dpf --------------------------------------------------------------------------------------------------------------------------------------
			UPDATE dbo.CLE_DPF_SALIENTE SET TRACKNUMBER = @RI_CONTADOR_REGISTRO, ESTADO = 2, FECHA_ENVIO_COMPENSACION = (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK))
			WHERE TIPO_DOCUMENTO = @D_TIPO_DOCUMENTO AND NUMERO_DPF = @D_NUMERO_DPF AND BANCO_GIRADO = @D_BANCO AND SUCURSAL_BANCO_GIRADO = @D_SUCURSAL AND FECHA_ALTA = @D_FECHA AND TZ_LOCK = 0;
			--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------    	
			IF (@Excedente = 0)
			BEGIN		     	       				
		
				FETCH NEXT FROM CursorDPF INTO @D_TIPO_DOCUMENTO
											, @D_BANCO
											, @D_SUCURSAL
											, @D_CUENTA
											, @D_IMPORTE
											, @D_NUMERO_DPF
											, @D_CODIGO_POSTAL
											, @D_MONEDA
											, @D_FECHA
											, @D_SUCURSAL_DE_INGRESO
		
				SET @CountExcedente = 0;
				--SET @RA_CONTADOR_REGISTRO_ORIGEN = '''';
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

		-- Grabamos fin de lote y archivo solo si hay registros individuales ingresados
		IF(@hayDPF > 0)
		BEGIN
				
			--SET @TotalesControl += @SumaEntidad + @SumaSucursal;
			--SET @FL_TOTALES_DE_CONTROL = concat((RIGHT(concat(replicate(''0'', 6), @SumaEntidad), 6)), (RIGHT(concat(replicate(''0'', 4), @SumaSucursal), 4)));
		
		
			   	   	--nuevo
   			SET @FL_TOTALES_DE_CONTROL = (RIGHT(concat(replicate(''0'', 10), (SELECT sum(convert(numeric,substring(linea,4,8)))
																			FROM ITF_CHEQUES_SALIDA_AUX
																			WHERE LINEA LIKE ''6%'' 
																			AND ID>(SELECT max(id) 
																					FROM ITF_CHEQUES_SALIDA_AUX 
																					WHERE LINEA LIKE ''5%''))), 10))
		
		
		
			--SET @FL_SUMA_TOTAL_DEBiTO_LOTE = RIGHT(concat(replicate(''0'', 12), (replace(@SumaImportes, ''.'', ''''))), 12); 
		
					   	   	--nuevo
	   		SET @FL_SUMA_TOTAL_DEBITO_LOTE = (RIGHT(concat(replicate(''0'', 12), (SELECT sum(convert(numeric,substring(linea,30,10))) FROM ITF_CHEQUES_SALIDA_AUX WHERE LINEA LIKE ''6%'' AND ID>(SELECT max(id) FROM ITF_CHEQUES_SALIDA_AUX WHERE LINEA LIKE ''5%''))), 12))
			SET @FL_SUMA_TOTAL_CREDITO_LOTE = RIGHT(replicate(''0'', 12), 12);
			SET @FL_NUMERO_LOTE = RIGHT(concat(replicate(''0'', 7), (SELECT count(ID) FROM ITF_CHEQUES_SALIDA_AUX WHERE LINEA LIKE ''5%'' AND id>(SELECT max(id) FROM ITF_CHEQUES_SALIDA_AUX WHERE LINEA LIKE ''1%''))), 7); 		

			SET @TotalesDebitos += @SumaImportes;
			SET @FL_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 6), (SELECT count(*) FROM ITF_CHEQUES_SALIDA_AUX WHERE (LINEA LIKE ''6%'' OR LINEA LIKE ''7%'') AND ID>(SELECT max(id) FROM ITF_CHEQUES_SALIDA_AUX WHERE LINEA LIKE ''5%''))), 6); 

			SET @FL_FIN_LOTE = concat(@FL_ID_REG, @FL_CODIGO_CLASE_TRANSAC, @FL_CANT_REG_INDIVIDUAL_ADICIONAL, @FL_TOTALES_DE_CONTROL, @FL_SUMA_TOTAL_DEBITO_LOTE, @FL_SUMA_TOTAL_CREDITO_LOTE, @FL_RESERVADO1, @FL_RESERVADO2, @FL_RESERVADO3, @FL_REG_ENTIDAD_ORIGEN, @FL_NUMERO_LOTE);
				
			INSERT INTO dbo.ITF_CHEQUES_SALIDA_AUX (LINEA) VALUES (replace(@FL_FIN_LOTE, ''.'', ''''));

			---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
			-------------Grabamos el Fin de Archivo ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

			SET @CantRegistrosPrev = (SELECT (CASE WHEN (@CantRegistros + 4) % 10 = 0 THEN ((@CantRegistros + 4)/10) ELSE (FLOOR((@CantRegistros + 4)/10) + 1) END));

		
			SET @FA_CANT_LOTES = RIGHT(concat(replicate(''0'', 6), (SELECT count(ID) FROM ITF_CHEQUES_SALIDA_AUX WHERE LINEA LIKE ''5%'' AND id>(SELECT max(id) FROM ITF_CHEQUES_SALIDA_AUX WHERE LINEA LIKE ''1%''))), 6); 		
			SET @FA_NUMERO_BLOQUES = RIGHT(concat(replicate(''0'', 6), (SELECT CEILING((count(*)+1) / CONVERT(FLOAT, 10)) FROM ITF_CHEQUES_SALIDA_AUX WHERE  ID>=(SELECT max(id) FROM ITF_CHEQUES_SALIDA_AUX WHERE LINEA LIKE ''1%''))), 6);
			SET @FA_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 8), (SELECT count(id) FROM ITF_CHEQUES_SALIDA_AUX WHERE (LINEA LIKE ''6%'' OR LINEA LIKE ''7%'') AND id>(SELECT max(id) FROM ITF_CHEQUES_SALIDA_AUX WHERE LINEA LIKE ''1%''))), 8);
	   		SET @FA_TOTALES_DE_CONTROL = (RIGHT(concat(replicate(''0'', 10), (SELECT sum(convert(numeric,substring(linea,4,8))) FROM ITF_CHEQUES_SALIDA_AUX WHERE LINEA LIKE ''6%'' AND ID>(SELECT max(id) FROM ITF_CHEQUES_SALIDA_AUX WHERE LINEA LIKE ''1%''))), 10))
			SET @FA_SUMA_TOTAL_DEBITOS = (RIGHT(concat(replicate(''0'', 12), (SELECT sum(convert(numeric,substring(linea,21,12)))	FROM ITF_CHEQUES_SALIDA_AUX	WHERE LINEA LIKE ''8%'' AND ID>(SELECT max(id) FROM ITF_CHEQUES_SALIDA_AUX WHERE LINEA LIKE ''1%''))), 12))
			SET @FA_SUMA_TOTAL_CREDITOS = RIGHT(concat(replicate(''0'', 12), (replace(@TotalesCreditos, ''.'', ''''))),12);				
			SET @FA_FIN_ARCHIVO = concat(@FA_ID_REG, @FA_CANT_LOTES, @FA_NUMERO_BLOQUES, @FA_CANT_REG_INDIVIDUAL_ADICIONAL, @FA_TOTALES_DE_CONTROL, @FA_SUMA_TOTAL_DEBITOS, @FA_SUMA_TOTAL_CREDITOS, @FA_RESERVADO);
					
			INSERT INTO dbo.ITF_CHEQUES_SALIDA_AUX (LINEA) VALUES (@FA_FIN_ARCHIVO);
			------------------------------------------------------------------------------------------------------------------------------------------------------------------
		END
	END

END');
