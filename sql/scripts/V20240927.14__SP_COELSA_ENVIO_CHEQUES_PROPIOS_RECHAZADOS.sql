ALTER PROCEDURE [dbo].[SP_COELSA_ENVIO_CHEQUES_PROPIOS_RECHAZADOS]
   @TICKET NUMERIC(16)
--   ,
--   @msj VARCHAR(500) output
AS 
BEGIN
--	BEGIN TRY 
	-- Limpieza de tabla auxiliar --
	TRUNCATE TABLE dbo.ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX;


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
	DECLARE @CL_FECHA_VENCIMIENTO VARCHAR(6) = convert(VARCHAR,(SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)), 12); 
	DECLARE @CL_RESERVADO_CL VARCHAR(3) = '000'; -- fijo
	DECLARE @CL_CODIGO_ORIGEN VARCHAR(1) = '1'; -- fijo
	DECLARE @CL_ID_ENTIDAD_ORIGEN VARCHAR(8) = (SELECT '031100'+CAST((SELECT NUMERICO FROM PARAMETROSGENERALES WHERE CODIGO=40) AS VARCHAR)); 
	DECLARE @CL_NUMERO_LOTE VARCHAR(7) =RIGHT(concat(replicate('0', 7), (SELECT COUNT(*) + 1 FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '5%' AND ID>(SELECT max(id) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '1%'))), 7);
-- numero del lote

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


	---------------- Grabar Cabecera Archivo ---------------------------
	INSERT INTO dbo.ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX (LINEA) VALUES (@CA_CABECERA);
	--------------------------------------------------------------------
	---------------- Grabar Cabecera Lote ---------------------------
	SET @CL_NUMERO_LOTE =RIGHT(concat(replicate('0', 7), (SELECT COUNT(*) + 1 FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '5%' AND ID>(SELECT max(id) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '1%'))), 7);
	SET @CL_CABECERA = concat(@CL_ID_REG, @CL_CODIGO_CLASE_TRANSAC, @CL_RESERVADO, @CL_TIPO_REGISTRO, @CL_DESCRIP_TRANSAC, @CL_FECHA_PRESENTACION, @CL_FECHA_VENCIMIENTO, @CL_RESERVADO_CL, @CL_CODIGO_ORIGEN, @CL_ID_ENTIDAD_ORIGEN, @CL_NUMERO_LOTE);
	INSERT INTO dbo.ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX (LINEA) VALUES (@CL_CABECERA);
	-----------------------------------------------------------------


	------ Variables registro individual ( RI) ------------
	DECLARE @RI_ID_REG VARCHAR(1) = '6'; -- fijo  
	DECLARE @RI_CODIGO_TRANSAC VARCHAR(2) = '26'; -- fijo
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
	DECLARE @FL_CONTADOR_AL_INICIAR NUMERIC(20,0) = (SELECT NUMERICO_1 FROM ITF_MASTER_PARAMETROS WHERE CODIGO = 138);
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
	DECLARE @SumaImportes NUMERIC(20,2) = 0;
	DECLARE @TotalesControl NUMERIC(10) = 0;
	DECLARE @TotalesDebitos NUMERIC(20,2) = 0;
	DECLARE @TotalesCreditos NUMERIC(20,2) = 0;
	DECLARE @CantRegistros NUMERIC(15) = 0;
	DECLARE @CantRegistrosPrev NUMERIC(6)= 0;
	DECLARE @Cant_Reg_Individual_Adicional VARCHAR(6)= 0;
	
	DECLARE @SumaEntidad NUMERIC(10,0) = 0;
	DECLARE @SumaSucursal NUMERIC(10,0) = 0;
	DECLARE @SobranteSucursal NUMERIC(10,0) = 0;
	DECLARE @Excedente NUMERIC(20,2) = 0;
	DECLARE @CountExcedente INT = 0;

	------- Variables para registro adicional rechazo -------

	DECLARE @CODIGO_RECHAZO VARCHAR(3);
	DECLARE @TRACE_NUMBER VARCHAR(15); 
	DECLARE @OTRO_RECHAZO VARCHAR(44);
	DECLARE @RI_REGISTRO_INDIVIDUAL_ADICIONAL VARCHAR(100);

	------------------------------------------
	
    --Condicion de reset del contador de reg individual
	IF ISNULL((SELECT a.FECHA FROM ITF_MASTER_PARAMETROS a WHERE a.CODIGO = 138), CAST('01-01-1800' AS DATETIME)) <> (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK))
    	UPDATE dbo.ITF_MASTER_PARAMETROS SET NUMERICO_1 = 1, FECHA = (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)) WHERE CODIGO = 138;
 



	-- Variables Cursor cursor_che_rechazados --
	DECLARE @ID INT;  
	DECLARE @CheFechaProceso DATE;
	DECLARE @CheCodigoTransaccion NUMERIC(2,0);
	DECLARE @CheEntidadDebitar NUMERIC(8,0);
	DECLARE @CheEntidadDebitarV VARCHAR(8);
	DECLARE @CheCuentaDebitar NUMERIC(17);
	DECLARE @CheImporte NUMERIC(15, 2);
	DECLARE @CheCodigoPostal VARCHAR(6);
	DECLARE @CheFechaPresentado DATE;
	DECLARE @CheFechaVencimiento DATE;
	DECLARE @CheNroCheque NUMERIC(15);
	DECLARE @ChePuntoIntercambio VARCHAR(16);
	DECLARE @CheTraceNumber NUMERIC(15);
	DECLARE @CheEstado VARCHAR(1);
	DECLARE @CheTipo VARCHAR(1);
	DECLARE @CheCodRechazo NUMERIC(2); 	 
	DECLARE @CheInfoAdicional VARCHAR(2); 	  
	-- Fin Variables Cursor --

	DECLARE cursor_che_rechazados CURSOR FOR

	SELECT ID, 
		   FECHAPROCESO, 
		   CODIGO_TRANSACCION, 
		   ENTIDAD_DEBITAR, 
		   CUENTA_DEBITAR, 
		   IMPORTE, 
		   FECHA_PRESENTADO, 
		   CODIGO_POSTAL, 
		   FECHA_VENCIMIENTO, 
		   NRO_CHEQUE, 
		   PUNTO_INTERCAMBIO, 
		   TRACE_NUMBER, 
		   ESTADO, 
		   TIPO, 
		   COD_RECHAZO, 
		   INFO_ADICIONAL 
	FROM ITF_COELSA_CHEQUES_RECHAZO
	WHERE TIPO IN ('C', 'A') 
	AND ESTADO = 'P' 
	AND FECHAPROCESO = (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK));


	OPEN cursor_che_rechazados
	  
	FETCH NEXT FROM cursor_che_rechazados INTO @ID
											, @CheFechaProceso
											, @CheCodigoTransaccion
											, @CheEntidadDebitar
											, @CheCuentaDebitar
											, @CheImporte
											, @CheFechaPresentado
											, @CheCodigoPostal
											, @CheFechaVencimiento
											, @CheNroCheque
											, @ChePuntoIntercambio
											, @CheTraceNumber
											, @CheEstado
											, @CheTipo
											, @CheCodRechazo
											, @CheInfoAdicional
	  
	WHILE @@FETCH_STATUS = 0 
	BEGIN
	Start_1:
PRINT 'cheques 1'
		IF (@SumaImportes > 999999999999999999.99 OR @SumaEntidad > 999999)-- 9999 millones
		BEGIN
PRINT @SumaImportes
			IF @SumaSucursal > 9999
			BEGIN
				SET @SobranteSucursal = CAST(substring(CAST(@SumaSucursal AS VARCHAR), 1, (len(@SumaSucursal) - 4)) AS NUMERIC);
				SET @SumaEntidad += @SobranteSucursal;
				SET @SumaSucursal = CAST(RIGHT(@SumaSucursal, 4) AS NUMERIC);
			END

	   		SET @TotalesControl += @SumaEntidad + @SumaSucursal;
	   		SET @FL_TOTALES_DE_CONTROL =RIGHT(concat(replicate('0', 10), (SELECT sum(convert(bigINT,substring(t.LINEA,4,8))) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX t WHERE t.ID>(SELECT max(tt.id) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX tt WHERE tt.LINEA LIKE '5%') AND substring(t.LINEA,1,1) IN ('6'))), 10);
	   		SET @FL_SUMA_TOTAL_DEBITO_LOTE =  RIGHT(concat(replicate('0', 20), (replace((SELECT sum(convert(bigint, substring(linea,61,16))) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '6%' AND LINEA NOT LIKE '622%' AND id>(SELECT max(id) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '5%')), '.', ''))), 20); 
	   		SET @FL_SUMA_TOTAL_CREDITO_LOTE = RIGHT(concat(replicate('0', 20), (replace((SELECT sum(convert(bigint, substring(linea,61,16))) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '622%' AND id>(SELECT max(id) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '5%')), '.', ''))), 20); 
	   		SET @TotalesDebitos += @SumaImportes;
	   		SET @FL_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate('0', 6), (SELECT count(id) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX t WHERE t.ID>(SELECT max(tt.id) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX tt WHERE tt.LINEA LIKE '5%') AND substring(t.LINEA,1,1) IN ('6','7'))), 6);	   	
			SET @FL_NUMERO_LOTE= @CL_NUMERO_LOTE 
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

		
			INSERT INTO dbo.ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX (LINEA) VALUES (replace(@FL_FIN_LOTE, '.', ''));
			-------------------------------------------------------------------
			-------------Grabamos el Fin de Archivo ----------------------------------------------------------------------------------------------------------------------
			SET @FA_CANT_LOTES = RIGHT(concat(replicate('0', 6), @FL_NUMERO_LOTE), 6);
			SET @CantRegistrosPrev = (SELECT (CASE WHEN (@CantRegistros + 4) % 10 = 0 THEN ((@CantRegistros + 4)/10) ELSE (FLOOR((@CantRegistros + 4)/10) + 1) END));
			SET @FA_NUMERO_BLOQUES = RIGHT(concat(replicate('0', 6), @CantRegistrosPrev ), 6);

			SET @FA_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate('0', 8), (SELECT count(id) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX t WHERE t.ID>(SELECT max(tt.id) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX tt WHERE tt.LINEA LIKE '1%') AND substring(t.LINEA,1,1) IN ('6','7'))), 8);
		
			SET @FA_TOTALES_DE_CONTROL =  RIGHT(concat(replicate('0', 10), (SELECT sum(convert(bigINT,substring(t.LINEA,4,8))) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX t WHERE t.ID>(SELECT max(tt.id) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX tt WHERE tt.LINEA LIKE '1%') AND substring(t.LINEA,1,1) IN ('6'))), 10);
		
			SET @FA_SUMA_TOTAL_DEBITOS = RIGHT(concat(replicate('0', 20), (replace((SELECT sum(convert(bigint, substring(linea,61,16))) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '6%' AND LINEA NOT LIKE '622%' AND id>(SELECT max(id) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '1%')), '.', ''))), 20);
		
			SET @FA_SUMA_TOTAL_CREDITOS = RIGHT(concat(replicate('0', 20), (replace((SELECT sum(convert(bigint, substring(linea,61,16))) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '622%' AND id>(SELECT max(id) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '1%')), '.', ''))), 20);
			
			
			SET @FA_CANT_LOTES = RIGHT(concat(replicate('0', 6), (SELECT count(ID) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '5%'AND id>(SELECT max(ID) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '1%'))), 6);

			--SET @FA_NUMERO_BLOQUES = RIGHT(concat(replicate('0', 6), @CantRegistrosPrev ), 6);
			
			SET @FA_NUMERO_BLOQUES = RIGHT(concat(replicate('0', 6), (SELECT CEILING((count(*)+1) / CONVERT(FLOAT, 10))
																  FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX 
																  WHERE  ID>=(SELECT max(id) 
																  		  		FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX 
																  		  		WHERE LINEA LIKE '1%'))), 6);
			

			SET @FA_FIN_ARCHIVO = concat(@FA_ID_REG, @FA_CANT_LOTES, @FA_NUMERO_BLOQUES, @FA_CANT_REG_INDIVIDUAL_ADICIONAL, @FA_TOTALES_DE_CONTROL, @FA_SUMA_TOTAL_DEBITOS, @FA_SUMA_TOTAL_CREDITOS, @FA_RESERVADO);
		
			INSERT INTO dbo.ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX (LINEA) VALUES (@FA_FIN_ARCHIVO);
		
--			SET @FL_NUMERO_LOTE = CAST(@FL_NUMERO_LOTE AS NUMERIC) + 1;
--			SET @FL_NUMERO_LOTE = RIGHT(concat(replicate('0', 7), @FL_NUMERO_LOTE), 7);
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
		
			INSERT INTO dbo.ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX (LINEA) VALUES (@CA_CABECERA);
			----------------------------------------------------------------------------------------------------------------------------------------------------------------------
			--------- Grabamos nueva Cabecera Lote ------------------------------------------------------------------------------------------------------------------------------------------------------
			SET @CL_NUMERO_LOTE  =RIGHT(concat(replicate('0', 7), (SELECT COUNT(*) + 1 FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '5%' AND ID>(SELECT max(id) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '1%'))), 7);  
			SET @CL_CABECERA = concat(@CL_ID_REG, @CL_CODIGO_CLASE_TRANSAC, @CL_RESERVADO, @CL_TIPO_REGISTRO, @CL_DESCRIP_TRANSAC, @CL_FECHA_PRESENTACION, @CL_FECHA_VENCIMIENTO, @CL_RESERVADO_CL, @CL_CODIGO_ORIGEN, @CL_ID_ENTIDAD_ORIGEN, @CL_NUMERO_LOTE);
			INSERT INTO dbo.ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX (LINEA) VALUES (@CL_CABECERA);
			---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		
		END
 --@ID, @CheFechaProceso, @CheCodigoTransaccion, @CheEntidadDebitar, @CheCuentaDebitar, @CheImporte, @CheFechaPresentado, @CheCodigoPostal, @CheFechaVencimiento, @CheNroCheque, @ChePuntoIntercambio, @CheTraceNumber, @CheEstado, @CheTipo, @CheCodRechazo
		SET @CheEntidadDebitarV = RIGHT(concat(replicate('0', 8), @CheEntidadDebitar), 8);
		SET @CantRegistros += 1;	
		SET @Cant_Reg_Individual_Adicional += 1;	
		
		IF	(@Excedente<>0)
		BEGIN
			SET @CheImporte = @Excedente;
			SET @CountExcedente += 1;
		END
		IF	(@CheImporte>99999999999999.99)
		BEGIN            
			SET @Excedente = (@CheImporte - 99999999999999.99);
			SET @CheImporte = 99999999999999.99;
			SET @CountExcedente += 1;
		END
		ELSE
    	BEGIN
       		SET @Excedente = 0;
    	END
PRINT 	@CountExcedente	
	
		IF(@CountExcedente>1 AND @CheImporte = 99999999999999.99)
		BEGIN
        	SET @SumaSucursal += 0888; --sumo la sucursal que hay que harcodear
        	SET @SumaEntidad += LEFT(@CheEntidadDebitarV,4);
        	SET @SumaImportes += @CheImporte;
PRINT @SumaImportes		
        	SET @RI_ENTIDAD_DEBITAR = concat(RIGHT(concat(replicate('0', 4), LEFT(@CheEntidadDebitarV,4)), 4), '0888');
        	SET @RI_CUENTA_DEBITAR = RIGHT(concat(replicate('0', 17), '88888888888'), 17);
        	SET @RI_NUMERO_CHEQUE = '000088888888888';  --ACA SE SETEAN LOS 8
			SET @RI_INFO_ADICIONAL = '01';

		END
    	ELSE --la razon de este else, es que SumaSucursal, cuando hay excedente tiene que acumular 0888
    	BEGIN
        	SET @SumaSucursal += RIGHT(@CheEntidadDebitarV,4); 
        	SET @SumaEntidad += LEFT(@CheEntidadDebitarV,4);
        	SET @SumaImportes += @CheImporte;

        	SET @RI_ENTIDAD_DEBITAR = RIGHT(concat(replicate('0', 8), @CheEntidadDebitar), 8);
		
	        SET @RI_CUENTA_DEBITAR = RIGHT(concat(replicate('0', 17), @CheCuentaDebitar), 17);
	
    	    SET @RI_NUMERO_CHEQUE = concat('00', RIGHT(concat(replicate('0', 13), @CheNroCheque), 13));
        
	        IF (@CheInfoAdicional IS NOT NULL )
    		    SET @RI_INFO_ADICIONAL = @CheInfoAdicional;
        	ELSE
        		SET @RI_INFO_ADICIONAL = '00';

    	END
			
		IF @SumaImportes>999999999999999999.99 GOTO Start_1
		
		SET @RI_IMPORTE = RIGHT(concat(replicate('0', 16), replace(CAST(@CheImporte AS VARCHAR),'.','')), 16);
			
		SET @RI_CODIGO_POSTAL =  concat('00', RIGHT(concat(replicate('0', 4), @CheCodigoPostal), 4));
			
		SET @RI_REGISTRO_ADICIONAL = '1';
	   	
		SET @RI_CONTADOR_REGISTRO = concat('0311', RIGHT(concat(replicate('0', 4), ('0097')), 4),RIGHT(concat(replicate('0', 7), (SELECT NUMERICO_1 FROM ITF_MASTER_PARAMETROS WHERE CODIGO = 138)), 7));
	
		SET @RI_REGISTRO_INDIVIDUAL = concat(@RI_ID_REG
											, @RI_CODIGO_TRANSAC
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
PRINT 'hola'	
		INSERT INTO dbo.ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX (LINEA) VALUES (replace(@RI_REGISTRO_INDIVIDUAL, '.', ''));
	
		/* Logica para agregar el registro adicional con el motivo del rechazo*/	
		IF(@Excedente=0 OR @Excedente<99999999999999.99 AND @CheImporte < 99999999999999.99)
		BEGIN
	  		SET @CODIGO_RECHAZO = 'R' + RIGHT(CONCAT('00',@CheCodRechazo),2);
			SET @TRACE_NUMBER=  RIGHT(CONCAT('000000000000000',@CheTraceNumber),15); 
			SET @OTRO_RECHAZO = REPLICATE(' ',44);
	
			SET @RI_REGISTRO_INDIVIDUAL_ADICIONAL = concat('799',@CODIGO_RECHAZO,@TRACE_NUMBER,'      ',@CheEntidadDebitarV,@OTRO_RECHAZO,@RI_CONTADOR_REGISTRO);
PRINT 'hola'
			INSERT INTO dbo.ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX (LINEA) VALUES (replace(@RI_REGISTRO_INDIVIDUAL_ADICIONAL, '.', ''));
		END
	
		---------------------------- Actualizar contador unico ----------------------------------------
    	UPDATE dbo.ITF_MASTER_PARAMETROS SET NUMERICO_1 = (NUMERICO_1 + 1) WHERE CODIGO = 138;
    	------------------------------------------------------------------------------------------------
    	/*---------- Grabar historial ----------------------------------------------------------------------------------------------------------------------------------------------------------------------
    	INSERT INTO ITF_COELSA_CHEQUES_OTROS (ID_TICKET, ID_PROCESO, FECHAPROCESO, CODIGO_TRANSACCION, BANCO, SUCURSAL, CUENTA, IMPORTE, CODIGO_POSTAL, FECHA_PRESENTADO, FECHA_VENCIMIENTO, NRO_CHEQUE, PUNTO_INTERCAMBIO, TRACE_NUMBER, ESTADO, TIPO, MONEDA, TIPO_DOCUMENTO, SERIE_DEL_CHEQUE)
    	VALUES (@TICKET, @TICKET, (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)), @RI_CODIGO_TRANSAC, @T_COD_BANCO, @T_SUCURSAL, @T_NUMERO_CUENTA_GIRADORA, @T_IMPORTE, @RI_CODIGO_POSTAL, @T_FECHA_DEL_CHEQUE, @T_FECHA_VALOR, @T_NUMERO_DEL_CHEQUE, @RI_PUNTO_INTERCAMBIO, @RI_CONTADOR_REGISTRO, 'P', 'C', @T_MONEDA, @T_TIPO_DOCUMENTO, @T_SERIE_DEL_CHEQUE);
    	-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		*/
		IF (@Excedente = 0)
		BEGIN		     	       				
			FETCH NEXT FROM cursor_che_rechazados INTO @ID, @CheFechaProceso, @CheCodigoTransaccion, @CheEntidadDebitar, @CheCuentaDebitar, @CheImporte, @CheFechaPresentado, @CheCodigoPostal, @CheFechaVencimiento, @CheNroCheque, @ChePuntoIntercambio, @CheTraceNumber, @CheEstado, @CheTipo, @CheCodRechazo, @CheInfoAdicional
			SET @CountExcedente = 0;

		END
				               
	END 
	CLOSE cursor_che_rechazados 
	DEALLOCATE cursor_che_rechazados 

	IF @SumaSucursal > 9999
	BEGIN
		SET @SobranteSucursal = 0;
		SET @SobranteSucursal = CAST(substring(CAST(@SumaSucursal AS VARCHAR), 1, (len(@SumaSucursal) - 4)) AS NUMERIC);
		SET @SumaEntidad += @SobranteSucursal;
		SET @SumaSucursal = CAST(RIGHT(@SumaSucursal, 4) AS NUMERIC);
	END
		


	SET @FL_TOTALES_DE_CONTROL =RIGHT(concat(replicate('0', 10), (SELECT sum(convert(bigINT,substring(t.LINEA,4,8))) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX t WHERE t.ID>(SELECT max(tt.id) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX tt WHERE tt.LINEA LIKE '5%') AND substring(t.LINEA,1,1) IN ('6'))), 10);


	--SET @TotalesControl += CAST(@FL_TOTALES_DE_CONTROL AS INTEGER);
SET @FL_SUMA_TOTAL_DEBITO_LOTE =  RIGHT(concat(replicate('0', 20), (replace((SELECT sum(convert(bigint, substring(linea,61,16))) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '6%' AND LINEA NOT LIKE '622%' AND id>(SELECT max(id) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '5%')), '.', ''))), 20); 
	SET @FL_SUMA_TOTAL_CREDITO_LOTE = RIGHT(concat(replicate('0', 20), (replace((SELECT sum(convert(bigint, substring(linea,61,16))) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '622%' AND id>(SELECT max(id) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '5%')), '.', ''))), 20);
	--SET @TotalesDebitos += @SumaImportes;
SET @FL_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate('0', 6), (SELECT count(id) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX t WHERE t.ID>(SELECT max(tt.id) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX tt WHERE tt.LINEA LIKE '5%') AND substring(t.LINEA,1,1) IN ('6','7'))), 6);	
	SET @FL_NUMERO_LOTE= @CL_NUMERO_LOTE 
	SET @FL_FIN_LOTE = concat(@FL_ID_REG, @FL_CODIGO_CLASE_TRANSAC, @FL_CANT_REG_INDIVIDUAL_ADICIONAL, @FL_TOTALES_DE_CONTROL, @FL_SUMA_TOTAL_DEBITO_LOTE, @FL_SUMA_TOTAL_CREDITO_LOTE, @FL_RESERVADO1, @FL_RESERVADO2, @FL_RESERVADO3, @FL_REG_ENTIDAD_ORIGEN, @FL_NUMERO_LOTE);

	---- Grabamos FIN de lote solo si hay registros individuales ingresados
	IF(0<(SELECT COUNT(*) FROM ITF_COELSA_CHEQUES_RECHAZO WHERE TIPO IN ('C', 'A') AND ESTADO = 'P' AND FECHAPROCESO = (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK))))
	BEGIN		

		INSERT INTO dbo.ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX (LINEA) VALUES (replace(@FL_FIN_LOTE, '.', ''));
	END
		
	IF(0<(SELECT COUNT(*) FROM CLE_CHEQUES_CLEARING CC,CLE_CHEQUES_CLEARING_RECIBIDO CR WHERE CC.CMC7 = CR.MICRLINE AND CR.FECHA = CC.FECHA_VALOR AND (CR.CANJE_INTERNO='N' OR CR.CANJE_INTERNO IS NULL) AND CC.FECHA_VALOR = (SELECT FECHAPROCESO FROM PARAMETROS) AND CR.ESTADO_DEVOLUCION<>0 AND CC.TZ_LOCK = 0 AND CR.TZ_LOCK = 0) AND (@FL_CONTADOR_AL_INICIAR<>(SELECT NUMERICO_1 FROM ITF_MASTER_PARAMETROS WHERE CODIGO = 138)))
	BEGIN  
	
PRINT 'cheques 2'			
		---------------- Grabar Cabecera Lote ---------------------------
		SET @CL_NUMERO_LOTE  =RIGHT(concat(replicate('0', 7), (SELECT COUNT(*) + 1 FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '5%' AND ID>(SELECT max(id) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '1%'))), 7);
		SET @CL_CABECERA = concat(@CL_ID_REG, @CL_CODIGO_CLASE_TRANSAC, @CL_RESERVADO, @CL_TIPO_REGISTRO, @CL_DESCRIP_TRANSAC, @CL_FECHA_PRESENTACION, @CL_FECHA_VENCIMIENTO, @CL_RESERVADO_CL, @CL_CODIGO_ORIGEN, @CL_ID_ENTIDAD_ORIGEN, @CL_NUMERO_LOTE);
		INSERT INTO dbo.ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX (LINEA) VALUES (@CL_CABECERA);
		-----------------------------------------------------------------
	END

	-- Variables Cursor cursor_che_devueltos --
	DECLARE @CheEntidadDebitarCD VARCHAR(8);
	DECLARE @CheBancoCD NUMERIC(6,0);
	DECLARE @CheSucursalCD NUMERIC(5,0);
	DECLARE @CheCuentaDebitarCD VARCHAR(12);
	DECLARE @CheImporteCD NUMERIC(15,2);
	DECLARE @CheCodigoPostalCD VARCHAR(6);
	DECLARE @CheNroChequeCD NUMERIC(12,0);
	DECLARE @ChePuntoIntercambioCD VARCHAR(16);
	DECLARE @CheCodigoCausalCD NUMERIC(3,0);
	DECLARE @CheTraceNumberCD VARCHAR(15);
	DECLARE @CheInfoAdicionalCD VARCHAR(2);
	DECLARE @CheRegistrosAdicionalesCD VARCHAR(1);
	-- Fin Variables Cursor --

	DECLARE cursor_che_rechazados CURSOR FOR

	SELECT DISTINCT concat(RIGHT(concat(replicate('0', 4), CC.NUMERO_BANCO), 4), RIGHT(concat(replicate('0',4), CC.NUMERO_DEPENDENCIA), 4)) AS EntidadDebitar,
		   CC.NUMERO_BANCO AS CODBANCO, 
	   		CC.NUMERO_DEPENDENCIA AS SUCURSAL,  
	   		RIGHT(concat(replicate('0', 12), CC.CUENTA), 12) AS CuentaDebitar,
	   		CC.IMPORTE AS Importe,  
	   		CC.NUMERO_CHEQUE AS NroCheque,
	   		concat('00', RIGHT(concat(replicate('0', 4), substring(cc.CMC7,7,4)), 4)) AS CodigoPostal, 
	   		concat('0000', RIGHT(concat('0000', CR.CODIGO_CAUSAL_DEVOLUCION), 4), replicate(' ', 8)) AS PtoIntercambio,
	   		concat(CASE WHEN CC.MONEDA = 1 THEN '0' ELSE '1' END, CASE WHEN CC.SERIE_CHEQUE='E' THEN '2' ELSE '0' end) AS InfoAdicional,
	   		CC.TRACKNUMBER,
	   		CR.CODIGO_CAUSAL_DEVOLUCION

	FROM  CLE_CHEQUES_CLEARING CC,CLE_CHEQUES_CLEARING_RECIBIDO CR 
	WHERE CC.CMC7 = CR.MICRLINE 
	AND CR.FECHA = CC.FECHA_VALOR
	AND (CR.CANJE_INTERNO='N' OR CR.CANJE_INTERNO IS NULL) 
	AND CC.FECHA_VALOR = (SELECT FECHAPROCESO FROM PARAMETROS) 
	AND CR.ESTADO_DEVOLUCION<>0 
	AND CC.TZ_LOCK = 0 
	AND CR.TZ_LOCK = 0;

	OPEN cursor_che_rechazados
	  
	FETCH NEXT FROM cursor_che_rechazados INTO @CheEntidadDebitarCD, @CheBancoCD, @CheSucursalCD, @CheCuentaDebitarCD, @CheImporteCD, @CheNroChequeCD, @CheCodigoPostalCD, @ChePuntoIntercambioCD, @CheInfoAdicionalCD, @CheTraceNumberCD, @CheCodigoCausalCD
	  
	WHILE @@FETCH_STATUS = 0 
	BEGIN

	Start_2:
		IF (@SumaImportes > 999999999999999999.99 OR @SumaEntidad > 999999) -- 9999 millones
		BEGIN
		
			IF @SumaSucursal > 9999
			BEGIN
				SET @SobranteSucursal = CAST(substring(CAST(@SumaSucursal AS VARCHAR), 1, (len(@SumaSucursal) - 4)) AS NUMERIC);
				SET @SumaEntidad += @SobranteSucursal;
				SET @SumaSucursal = CAST(RIGHT(@SumaSucursal, 4) AS NUMERIC);
			END

	   		SET @TotalesControl += @SumaEntidad + @SumaSucursal;
	   		SET @FL_TOTALES_DE_CONTROL =RIGHT(concat(replicate('0', 10), (SELECT sum(convert(bigINT,substring(t.LINEA,4,8))) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX t WHERE t.ID>(SELECT max(tt.id) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX tt WHERE tt.LINEA LIKE '5%') AND substring(t.LINEA,1,1) IN ('6'))), 10);
			SET @FL_SUMA_TOTAL_DEBITO_LOTE =  RIGHT(concat(replicate('0', 20), (replace((SELECT sum(convert(bigint, substring(linea,61,16))) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '6%' AND LINEA NOT LIKE '622%' AND id>(SELECT max(id) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '5%')), '.', ''))), 20); 
	   		SET @FL_SUMA_TOTAL_CREDITO_LOTE = RIGHT(concat(replicate('0', 20), (replace((SELECT sum(convert(bigint, substring(linea,61,16))) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '622%' AND id>(SELECT max(id) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '5%')), '.', ''))), 20); 
	   		SET @TotalesDebitos += @SumaImportes;
			SET @FL_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate('0', 6), (SELECT count(id) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX t WHERE t.ID>(SELECT max(tt.id) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX tt WHERE tt.LINEA LIKE '5%') AND substring(t.LINEA,1,1) IN ('6','7'))), 6);	   	
			SET @FL_NUMERO_LOTE= @CL_NUMERO_LOTE 
	   		SET @FL_FIN_LOTE = concat(@FL_ID_REG, @FL_CODIGO_CLASE_TRANSAC, @FL_CANT_REG_INDIVIDUAL_ADICIONAL, @FL_TOTALES_DE_CONTROL, @FL_SUMA_TOTAL_DEBITO_LOTE, @FL_SUMA_TOTAL_CREDITO_LOTE, @FL_RESERVADO1, @FL_RESERVADO2, @FL_RESERVADO3, @FL_REG_ENTIDAD_ORIGEN, @FL_NUMERO_LOTE);

		
			INSERT INTO dbo.ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX (LINEA) VALUES (replace(@FL_FIN_LOTE, '.', ''));
		

			-------------------------------------------------------------------
			-------------Grabamos el Fin de Archivo ----------------------------------------------------------------------------------------------------------------------
			SET @FA_CANT_LOTES = RIGHT(concat(replicate('0', 6), @FL_NUMERO_LOTE), 6);
			SET @CantRegistrosPrev = (SELECT (CASE WHEN (@CantRegistros + 4) % 10 = 0 THEN ((@CantRegistros + 4)/10) ELSE (FLOOR((@CantRegistros + 4)/10) + 1) END));
			SET @FA_NUMERO_BLOQUES = RIGHT(concat(replicate('0', 6), @CantRegistrosPrev ), 6);

			SET @FA_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate('0', 8), (SELECT count(id) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX t WHERE t.ID>(SELECT max(tt.id) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX tt WHERE tt.LINEA LIKE '1%') AND substring(t.LINEA,1,1) IN ('6','7'))), 8);	   	

		
			SET @FA_TOTALES_DE_CONTROL =  RIGHT(concat(replicate('0', 10), (SELECT sum(convert(bigINT,substring(t.LINEA,4,8))) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX t WHERE t.ID>(SELECT max(tt.id) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX tt WHERE tt.LINEA LIKE '1%') AND substring(t.LINEA,1,1) IN ('6'))), 10);
		
			SET @FA_SUMA_TOTAL_DEBITOS = RIGHT(concat(replicate('0', 20), (replace((SELECT sum(convert(bigint, substring(linea,61,16))) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '6%' AND LINEA NOT LIKE '622%' AND id>(SELECT max(id) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '1%')), '.', ''))), 20);
		
			SET @FA_SUMA_TOTAL_CREDITOS = RIGHT(concat(replicate('0', 20), (replace((SELECT sum(convert(bigint, substring(linea,61,16))) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '622%' AND id>(SELECT max(id) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '1%')), '.', ''))), 20);


			SET @FA_CANT_LOTES = RIGHT(concat(replicate('0', 6), (SELECT count(ID) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '5%'AND id>(SELECT max(ID) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '1%'))), 6);

			--SET @FA_NUMERO_BLOQUES = RIGHT(concat(replicate('0', 6), @CantRegistrosPrev ), 6);
			
			 SET @FA_NUMERO_BLOQUES = RIGHT(concat(replicate('0', 6), (SELECT CEILING((count(*)+1) / CONVERT(FLOAT, 10))
																  FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX 
																  WHERE  ID>=(SELECT max(id) 
																  		  		FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX 
																  		  		WHERE LINEA LIKE '1%'))), 6);



			SET @FA_FIN_ARCHIVO = concat(@FA_ID_REG, @FA_CANT_LOTES, @FA_NUMERO_BLOQUES, @FA_CANT_REG_INDIVIDUAL_ADICIONAL, @FA_TOTALES_DE_CONTROL, @FA_SUMA_TOTAL_DEBITOS, @FA_SUMA_TOTAL_CREDITOS, @FA_RESERVADO);
		
			INSERT INTO dbo.ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX (LINEA) VALUES (@FA_FIN_ARCHIVO);
		
--			SET @FL_NUMERO_LOTE = CAST(@FL_NUMERO_LOTE AS NUMERIC) + 1;
--			SET @FL_NUMERO_LOTE = RIGHT(concat(replicate('0', 7), @FL_NUMERO_LOTE), 7);
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
		
			INSERT INTO dbo.ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX (LINEA) VALUES (@CA_CABECERA);
			----------------------------------------------------------------------------------------------------------------------------------------------------------------------
			--------- Grabamos nueva Cabecera Lote ------------------------------------------------------------------------------------------------------------------------------------------------------
			SET @CL_NUMERO_LOTE  =RIGHT(concat(replicate('0', 7), (SELECT COUNT(*) + 1 FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '5%' AND ID>(SELECT max(id) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '1%'))), 7);   
			SET @CL_CABECERA = concat(@CL_ID_REG, @CL_CODIGO_CLASE_TRANSAC, @CL_RESERVADO, @CL_TIPO_REGISTRO, @CL_DESCRIP_TRANSAC, @CL_FECHA_PRESENTACION, @CL_FECHA_VENCIMIENTO, @CL_RESERVADO_CL, @CL_CODIGO_ORIGEN, @CL_ID_ENTIDAD_ORIGEN, @CL_NUMERO_LOTE);
			INSERT INTO dbo.ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX (LINEA) VALUES (@CL_CABECERA);
			---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		
		END

		SET @CantRegistros += 1;
	
		SET @Cant_Reg_Individual_Adicional += 1;
	
	
		IF	(@Excedente<>0)
		BEGIN
			SET @CheImporteCD = @Excedente;
			SET @CountExcedente += 1;
		END
		IF	(@CheImporteCD>99999999999999.99)
		BEGIN
			SET @Excedente = (@CheImporteCD - 99999999999999.99);
			SET @CheImporteCD = 99999999999999.99;
			SET @CountExcedente += 1;
		END
		ELSE
    	BEGIN
       		SET @Excedente = 0;
    	END
		
PRINT @CountExcedente	
		IF(@CountExcedente>0 AND @CheImporteCD = 99999999999999.99)
		BEGIN
        	SET @SumaSucursal += 0888; --sumo la sucursal que hay que harcodear
        	SET @SumaEntidad += LEFT(@CheBancoCD,4);
        	SET @SumaImportes += @CheImporteCD;
		
        	SET @RI_ENTIDAD_DEBITAR = concat(RIGHT(concat(replicate('0', 4), LEFT(@CheBancoCD,4)), 4), '0888');
        	SET @RI_CUENTA_DEBITAR = RIGHT(concat(replicate('0', 17), '88888888888'), 17);
        	SET @RI_NUMERO_CHEQUE = '000088888888888';  --ACA SE SETEAN LOS 8
			--SET @RI_INFO_ADICIONAL = '01';
			SET @RI_INFO_ADICIONAL = @CheInfoAdicionalCD;
			PRINT @RI_CUENTA_DEBITAR

		END
    	ELSE --la razon de este else, es que SumaSucursal, cuando hay excedente tiene que acumular 0888
    	BEGIN
        	SET @SumaSucursal += RIGHT(concat(replicate('0', 4), @CheSucursalCD),4);
        	SET @SumaEntidad += RIGHT(concat(replicate('0', 4), @CheBancoCD),4);
        	SET @SumaImportes += @CheImporteCD;

        	SET @RI_ENTIDAD_DEBITAR = @CheEntidadDebitarCD;
		
        	SET @RI_CUENTA_DEBITAR = RIGHT(concat(replicate('0', 17), @CheCuentaDebitarCD), 17);
	
        	SET @RI_NUMERO_CHEQUE = concat('00', RIGHT(concat(replicate('0', 13), @CheNroChequeCD), 13));

			--SET @RI_INFO_ADICIONAL = '00';
			SET @RI_INFO_ADICIONAL = @CheInfoAdicionalCD;
  
    	END
    	
    	IF @SumaImportes>999999999999999999.99 GOTO Start_2
--PRINT @RI_CUENTA_DEBITAR
		SET @RI_IMPORTE = RIGHT(concat(replicate('0', 16), replace(CAST(@CheImporteCD AS VARCHAR),'.','')), 16);
			
		SET @RI_CODIGO_POSTAL =  concat('00', RIGHT(concat(replicate('0', 4), @CheCodigoPostalCD), 4));
		
		
		SET @RI_REGISTRO_ADICIONAL = '1';
	   	
		SET @RI_CONTADOR_REGISTRO = concat('0311', RIGHT(concat(replicate('0', 4), ('0097')), 4),RIGHT(concat(replicate('0', 7), (SELECT NUMERICO_1 FROM ITF_MASTER_PARAMETROS WHERE CODIGO = 138)), 7));
	
		SET @RI_REGISTRO_INDIVIDUAL = concat(@RI_ID_REG
											, @RI_CODIGO_TRANSAC
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
PRINT @RI_IMPORTE
PRINT @Excedente
PRINT @RI_REGISTRO_INDIVIDUAL
		INSERT INTO dbo.ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX (LINEA) VALUES (replace(@RI_REGISTRO_INDIVIDUAL, '.', ''));
		
		/* Logica para agregar el registro adicional con el motivo del rechazo*/	
		IF(@Excedente=0 OR @Excedente<99999999999999.99 AND @CheImporteCD < 99999999999999.99)
		BEGIN
			SET @CODIGO_RECHAZO = 'R' + RIGHT(CONCAT('00',(SELECT CODIGO_NACHA FROM CLE_TIPO_CAUSAL WHERE CODIGO_DE_CAUSAL=@CheCodigoCausalCD)),2);
			SET @TRACE_NUMBER=  RIGHT(CONCAT('000000000000000',@CheTraceNumberCD),15); 
			SET @OTRO_RECHAZO = REPLICATE(' ',44);
		
			SET @RI_REGISTRO_INDIVIDUAL_ADICIONAL = concat('799',@CODIGO_RECHAZO,@TRACE_NUMBER,'      ',@CheEntidadDebitarCD,@OTRO_RECHAZO,@RI_CONTADOR_REGISTRO);
			INSERT INTO dbo.ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX (LINEA) VALUES (replace(@RI_REGISTRO_INDIVIDUAL_ADICIONAL, '.', ''));
		END
	
		---------------------------- Actualizar contador unico ----------------------------------------
    	UPDATE dbo.ITF_MASTER_PARAMETROS SET NUMERICO_1 = (NUMERICO_1 + 1) WHERE CODIGO = 138;
    	------------------------------------------------------------------------------------------------
    	/*---------- Grabar historial ----------------------------------------------------------------------------------------------------------------------------------------------------------------------
    	INSERT INTO ITF_COELSA_CHEQUES_OTROS (ID_TICKET, ID_PROCESO, FECHAPROCESO, CODIGO_TRANSACCION, BANCO, SUCURSAL, CUENTA, IMPORTE, CODIGO_POSTAL, FECHA_PRESENTADO, FECHA_VENCIMIENTO, NRO_CHEQUE, PUNTO_INTERCAMBIO, TRACE_NUMBER, ESTADO, TIPO, MONEDA, TIPO_DOCUMENTO, SERIE_DEL_CHEQUE)
    	VALUES (@TICKET, @TICKET, (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)), @RI_CODIGO_TRANSAC, @T_COD_BANCO, @T_SUCURSAL, @T_NUMERO_CUENTA_GIRADORA, @T_IMPORTE, @RI_CODIGO_POSTAL, @T_FECHA_DEL_CHEQUE, @T_FECHA_VALOR, @T_NUMERO_DEL_CHEQUE, @RI_PUNTO_INTERCAMBIO, @RI_CONTADOR_REGISTRO, 'P', 'C', @T_MONEDA, @T_TIPO_DOCUMENTO, @T_SERIE_DEL_CHEQUE);
    	-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		*/
		IF (@Excedente = 0)
		BEGIN		     	       				
			FETCH NEXT FROM cursor_che_rechazados INTO @CheEntidadDebitarCD, @CheBancoCD, @CheSucursalCD, @CheCuentaDebitarCD, @CheImporteCD, @CheNroChequeCD, @CheCodigoPostalCD, @ChePuntoIntercambioCD, @CheInfoAdicionalCD, @CheTraceNumberCD, @CheCodigoCausalCD
			SET @CountExcedente = 0;
		
		END
				               
	END 
	CLOSE cursor_che_rechazados 
	DEALLOCATE cursor_che_rechazados 

	IF @SumaSucursal > 9999
	BEGIN
		SET @SobranteSucursal = 0;
		SET @SobranteSucursal = CAST(substring(CAST(@SumaSucursal AS VARCHAR), 1, (len(@SumaSucursal) - 4)) AS NUMERIC);
		SET @SumaEntidad += @SobranteSucursal;
		SET @SumaSucursal = CAST(RIGHT(@SumaSucursal, 4) AS NUMERIC);
	END
		


SET @FL_TOTALES_DE_CONTROL =RIGHT(concat(replicate('0', 10), (SELECT sum(convert(bigINT,substring(t.LINEA,4,8))) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX t WHERE t.ID>(SELECT max(tt.id) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX tt WHERE tt.LINEA LIKE '5%') AND substring(t.LINEA,1,1) IN ('6'))), 10);


	SET @FL_SUMA_TOTAL_DEBITO_LOTE =  RIGHT(concat(replicate('0', 20), (replace((SELECT sum(convert(bigint, substring(linea,61,16))) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '6%' AND LINEA NOT LIKE '622%' AND id>(SELECT max(id) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '5%')), '.', ''))), 20); 
	SET @FL_SUMA_TOTAL_CREDITO_LOTE = RIGHT(concat(replicate('0', 20), (replace((SELECT sum(convert(bigint, substring(linea,61,16))) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '622%' AND id>(SELECT max(id) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '5%')), '.', ''))), 20);
--SET @TotalesDebitos += @SumaImportes;
SET @FL_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate('0', 6), (SELECT count(id) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX t WHERE t.ID>(SELECT max(tt.id) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX tt WHERE tt.LINEA LIKE '5%') AND substring(t.LINEA,1,1) IN ('6','7'))), 6);

	SET @FL_NUMERO_LOTE= @CL_NUMERO_LOTE    	
	SET @FL_FIN_LOTE = concat(@FL_ID_REG, @FL_CODIGO_CLASE_TRANSAC, @FL_CANT_REG_INDIVIDUAL_ADICIONAL, @FL_TOTALES_DE_CONTROL, @FL_SUMA_TOTAL_DEBITO_LOTE, @FL_SUMA_TOTAL_CREDITO_LOTE, @FL_RESERVADO1, @FL_RESERVADO2, @FL_RESERVADO3, @FL_REG_ENTIDAD_ORIGEN, @FL_NUMERO_LOTE);

	---- Grabamos FIN de lote solo si hay registros individuales ingresados
	IF(0<(SELECT COUNT(*) FROM  CLE_CHEQUES_CLEARING CC,CLE_CHEQUES_CLEARING_RECIBIDO CR WHERE CC.CMC7 = CR.MICRLINE AND CR.FECHA = CC.FECHA_VALOR AND (CR.CANJE_INTERNO='N' OR CR.CANJE_INTERNO IS NULL) AND CC.FECHA_VALOR = (SELECT FECHAPROCESO FROM PARAMETROS) AND CR.ESTADO_DEVOLUCION<>0 AND CC.TZ_LOCK = 0 AND CR.TZ_LOCK = 0))
	BEGIN		

		INSERT INTO dbo.ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX (LINEA) VALUES (replace(@FL_FIN_LOTE, '.', ''));
	END
	
	IF(0<(SELECT COUNT(*) FROM CLE_CHEQUES_AJUSTE WHERE ESTADO = 'F' AND ENVIADO_RECIBIDO = 'R' AND ESTADO_AJUSTE = 'R') AND (@FL_CONTADOR_AL_INICIAR<>(SELECT NUMERICO_1 FROM ITF_MASTER_PARAMETROS WHERE CODIGO = 138)))
	BEGIN		
		---------------- Grabar Cabecera Lote ---------------------------
	   SET @CL_NUMERO_LOTE  =RIGHT(concat(replicate('0', 7), (SELECT COUNT(*) + 1 FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '5%' AND ID>(SELECT max(id) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '1%'))), 7);
		SET @CL_CABECERA = concat(@CL_ID_REG, @CL_CODIGO_CLASE_TRANSAC, @CL_RESERVADO, @CL_TIPO_REGISTRO, @CL_DESCRIP_TRANSAC, @CL_FECHA_PRESENTACION, @CL_FECHA_VENCIMIENTO, @CL_RESERVADO_CL, @CL_CODIGO_ORIGEN, @CL_ID_ENTIDAD_ORIGEN, @CL_NUMERO_LOTE);
		INSERT INTO dbo.ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX (LINEA) VALUES (@CL_CABECERA);
		-----------------------------------------------------------------

	END
	
	-- Variables cursor_che_ajustes --
	DECLARE @CheNroChequeAJ NUMERIC(12,0);
	DECLARE @CheBancoAJ NUMERIC(5,0);
	DECLARE @CheSucursalAJ NUMERIC(5,0);
	DECLARE @ChePostalAJ NUMERIC(4,0);
	DECLARE @CheImporteAJ NUMERIC(15,2);
	DECLARE @CheTrackNumberAJ VARCHAR(20);
	-----------------------------------

	-- Cursor de ajustes cheques --
	DECLARE cursor_che_rechazados CURSOR FOR

	SELECT NUMERO_CHEQUE, 
			IMPORTE, 
			BANCO, 
			SUCURSAL_BANCO_GIRADO, 
			CODIGO_POSTAL, 
			TRACKNUMBER 
	FROM CLE_CHEQUES_AJUSTE 
	WHERE ESTADO = 'F' 
	AND ENVIADO_RECIBIDO = 'R' 
	AND ESTADO_AJUSTE = 'R';

	OPEN cursor_che_rechazados

	FETCH NEXT FROM cursor_che_rechazados INTO @CheNroChequeAJ, 
												@CheImporteAJ, 
												@CheBancoAJ, 
												@CheSucursalAJ, 
												@ChePostalAJ, 
												@CheTrackNumberAJ

	WHILE @@FETCH_STATUS = 0 
	

		BEGIN
		
	Start_3:
  PRINT 'hola'
			IF (@SumaImportes > 999999999999999999.99 OR @SumaEntidad > 999999) -- 9999 millones
			BEGIN
		
				IF @SumaSucursal > 9999
				BEGIN
					SET @SobranteSucursal = CAST(substring(CAST(@SumaSucursal AS VARCHAR), 1, (len(@SumaSucursal) - 4)) AS NUMERIC);
					SET @SumaEntidad += @SobranteSucursal;
					SET @SumaSucursal = CAST(RIGHT(@SumaSucursal, 4) AS NUMERIC);
				END

	   			SET @TotalesControl += @SumaEntidad + @SumaSucursal;
	   			SET @FL_TOTALES_DE_CONTROL =RIGHT(concat(replicate('0', 10), (SELECT sum(convert(bigINT,substring(t.LINEA,4,8))) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX t WHERE t.ID>(SELECT max(tt.id) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX tt WHERE tt.LINEA LIKE '5%') AND substring(t.LINEA,1,1) IN ('6'))), 10);
	   			SET @FL_SUMA_TOTAL_DEBITO_LOTE =  RIGHT(concat(replicate('0', 20), (replace((SELECT sum(convert(bigint, substring(linea,61,16))) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '6%' AND LINEA NOT LIKE '622%' AND id>(SELECT max(id) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '5%')), '.', ''))), 20); 
	   			SET @FL_SUMA_TOTAL_CREDITO_LOTE = RIGHT(concat(replicate('0', 20), (replace((SELECT sum(convert(bigint, substring(linea,61,16))) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '622%' AND id>(SELECT max(id) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '5%')), '.', ''))), 20); 
	   			SET @TotalesDebitos += @SumaImportes;
	   			SET @FL_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate('0', 6), (SELECT count(id) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX t WHERE t.ID>(SELECT max(tt.id) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX tt WHERE tt.LINEA LIKE '5%') AND substring(t.LINEA,1,1) IN ('6','7'))), 6);	   	
	   			SET @FL_NUMERO_LOTE= @CL_NUMERO_LOTE 
	   			SET @FL_FIN_LOTE = concat(@FL_ID_REG, @FL_CODIGO_CLASE_TRANSAC, @FL_CANT_REG_INDIVIDUAL_ADICIONAL, @FL_TOTALES_DE_CONTROL, @FL_SUMA_TOTAL_DEBITO_LOTE, @FL_SUMA_TOTAL_CREDITO_LOTE, @FL_RESERVADO1, @FL_RESERVADO2, @FL_RESERVADO3, @FL_REG_ENTIDAD_ORIGEN, @FL_NUMERO_LOTE);
		
				INSERT INTO dbo.ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX (LINEA) VALUES (replace(@FL_FIN_LOTE, '.', ''));
		
				-------------------------------------------------------------------
				-------------Grabamos el Fin de Archivo ----------------------------------------------------------------------------------------------------------------------
				SET @FA_CANT_LOTES = RIGHT(concat(replicate('0', 6), @FL_NUMERO_LOTE), 6);
				SET @CantRegistrosPrev = (SELECT (CASE WHEN (@CantRegistros + 4) % 10 = 0 THEN ((@CantRegistros + 4)/10) ELSE (FLOOR((@CantRegistros + 4)/10) + 1) END));
				SET @FA_NUMERO_BLOQUES = RIGHT(concat(replicate('0', 6), @CantRegistrosPrev ), 6);
	
				SET @FA_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate('0', 8), (SELECT count(id) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX t WHERE t.ID>(SELECT max(tt.id) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX tt WHERE tt.LINEA LIKE '1%') AND substring(t.LINEA,1,1) IN ('6','7'))), 8);
		
				SET @FA_TOTALES_DE_CONTROL =  RIGHT(concat(replicate('0', 10), (SELECT sum(convert(bigINT,substring(t.LINEA,4,8))) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX t WHERE t.ID>(SELECT max(tt.id) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX tt WHERE tt.LINEA LIKE '1%') AND substring(t.LINEA,1,1) IN ('6'))), 10);
		
				SET @FA_SUMA_TOTAL_DEBITOS = RIGHT(concat(replicate('0', 20), (replace((SELECT sum(convert(bigint, substring(linea,61,16))) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '6%' AND LINEA NOT LIKE '622%' AND id>(SELECT max(id) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '1%')), '.', ''))), 20);
				SET @FA_SUMA_TOTAL_CREDITOS = RIGHT(concat(replicate('0', 20), (replace((SELECT sum(convert(bigint, substring(linea,61,16))) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '622%' AND id>(SELECT max(id) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '1%')), '.', ''))), 20);

		
				SET @FL_SUMA_TOTAL_CREDITO_LOTE = RIGHT(concat(replicate('0', 12), (replace((SELECT sum(convert(bigint, substring(linea,30,10))) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '622%' AND id>(SELECT max(id) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '5%')), '.', ''))), 12);


				SET @FA_CANT_LOTES = RIGHT(concat(replicate('0', 6), (SELECT count(ID) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '5%'AND id>(SELECT max(ID) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '1%'))), 6);

			--SET @FA_NUMERO_BLOQUES = RIGHT(concat(replicate('0', 6), @CantRegistrosPrev ), 6);
			
			 SET @FA_NUMERO_BLOQUES = RIGHT(concat(replicate('0', 6), (SELECT CEILING((count(*)+1) / CONVERT(FLOAT, 10))
																  FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX 
																  WHERE  ID>=(SELECT max(id) 
																  		  		FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX 
																  		  		WHERE LINEA LIKE '1%'))), 6);




				SET @FA_FIN_ARCHIVO = concat(@FA_ID_REG, @FA_CANT_LOTES, @FA_NUMERO_BLOQUES, @FA_CANT_REG_INDIVIDUAL_ADICIONAL, @FA_TOTALES_DE_CONTROL, @FA_SUMA_TOTAL_DEBITOS, @FA_SUMA_TOTAL_CREDITOS, @FA_RESERVADO);
		
				INSERT INTO dbo.ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX (LINEA) VALUES (@FA_FIN_ARCHIVO);
		
--				SET @FL_NUMERO_LOTE = CAST(@FL_NUMERO_LOTE AS NUMERIC) + 1;
--				SET @FL_NUMERO_LOTE = RIGHT(concat(replicate('0', 7), @FL_NUMERO_LOTE), 7);
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
		
				INSERT INTO dbo.ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX (LINEA) VALUES (@CA_CABECERA);
				----------------------------------------------------------------------------------------------------------------------------------------------------------------------
				--------- Grabamos nueva Cabecera Lote ------------------------------------------------------------------------------------------------------------------------------------------------------
				SET @CL_NUMERO_LOTE  =RIGHT(concat(replicate('0', 7), (SELECT COUNT(*) + 1 FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '5%' AND ID>(SELECT max(id) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '1%'))), 7);   
				SET @CL_CABECERA = concat(@CL_ID_REG, @CL_CODIGO_CLASE_TRANSAC, @CL_RESERVADO, @CL_TIPO_REGISTRO, @CL_DESCRIP_TRANSAC, @CL_FECHA_PRESENTACION, @CL_FECHA_VENCIMIENTO, @CL_RESERVADO_CL, @CL_CODIGO_ORIGEN, @CL_ID_ENTIDAD_ORIGEN, @CL_NUMERO_LOTE);
				INSERT INTO dbo.ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX (LINEA) VALUES (@CL_CABECERA);
				---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		
			END

			SET @CantRegistros += 1;
	
			SET @Cant_Reg_Individual_Adicional += 1;
	
	
			IF	(@Excedente<>0)
			BEGIN
				SET @CheImporteAJ = @Excedente;
				SET @CountExcedente += 1;
			END
			IF	(@CheImporteAJ>99999999999999.99)
			BEGIN
				SET @Excedente = (@CheImporteAJ - 99999999999999.99);
				SET @CheImporteAJ = 99999999999999.99;
				SET @CountExcedente += 1;
			END
			ELSE
    		BEGIN
	       		SET @Excedente = 0;
    		END

        	SET @SumaSucursal += 0888; --sumo la sucursal que hay que harcodear
        	SET @SumaEntidad += LEFT(@CheBancoAJ,4);
        	SET @SumaImportes += @CheImporteAJ;
		
        	SET @RI_ENTIDAD_DEBITAR = concat(RIGHT(concat(replicate('0', 4), LEFT(@CheBancoAJ,4)), 4), '0888');
        	SET @RI_CUENTA_DEBITAR = RIGHT(concat(replicate('0', 17), '88888888888'), 17);
        	SET @RI_NUMERO_CHEQUE = '000088888888888';  --ACA SE SETEAN LOS 8
        	
        	IF @SumaImportes>999999999999999999.99 GOTO Start_3

			SET @RI_IMPORTE = RIGHT(concat(replicate('0', 16), replace(CAST(@CheImporteAJ AS VARCHAR),'.','')), 16);
			
			SET @RI_CODIGO_POSTAL =  concat('00', RIGHT(concat(replicate('0', 4), @ChePostalAJ), 4));
		
			SET @RI_INFO_ADICIONAL = '01';
		
			SET @RI_REGISTRO_ADICIONAL = '1';
	   	
			SET @RI_CONTADOR_REGISTRO = concat('0311', RIGHT(concat(replicate('0', 4), ('0097')), 4),RIGHT(concat(replicate('0', 7), (SELECT NUMERICO_1 FROM ITF_MASTER_PARAMETROS WHERE CODIGO = 138)), 7));
	
		SET @RI_REGISTRO_INDIVIDUAL = concat(@RI_ID_REG
											, @RI_CODIGO_TRANSAC
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
												
			INSERT INTO dbo.ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX (LINEA) VALUES (replace(@RI_REGISTRO_INDIVIDUAL, '.', ''));
		
			/* Logica para agregar el registro adicional con el motivo del rechazo*/	
			IF(@Excedente=0 OR @Excedente<99999999999999.99 AND @CheImporteAJ<99999999999999.99)
			BEGIN
				SET @CODIGO_RECHAZO = 'R' + RIGHT(CONCAT('00',81),2);
				SET @TRACE_NUMBER=  RIGHT(CONCAT('000000000000000',@CheTrackNumberAJ),15); 
				SET @OTRO_RECHAZO = REPLICATE(' ',44);
	
				SET @RI_REGISTRO_INDIVIDUAL_ADICIONAL = concat('799',@CODIGO_RECHAZO,@TRACE_NUMBER,'      ',@RI_ENTIDAD_DEBITAR,@OTRO_RECHAZO,@RI_CONTADOR_REGISTRO);
				INSERT INTO dbo.ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX (LINEA) VALUES (replace(@RI_REGISTRO_INDIVIDUAL_ADICIONAL, '.', ''));
			END
	
			---------------------------- Actualizar contador unico ----------------------------------------
    		UPDATE dbo.ITF_MASTER_PARAMETROS SET NUMERICO_1 = (NUMERICO_1 + 1) WHERE CODIGO = 138;
    		------------------------------------------------------------------------------------------------
    		/*---------- Grabar historial ----------------------------------------------------------------------------------------------------------------------------------------------------------------------
    		INSERT INTO ITF_COELSA_CHEQUES_OTROS (ID_TICKET, ID_PROCESO, FECHAPROCESO, CODIGO_TRANSACCION, BANCO, SUCURSAL, CUENTA, IMPORTE, CODIGO_POSTAL, FECHA_PRESENTADO, FECHA_VENCIMIENTO, NRO_CHEQUE, PUNTO_INTERCAMBIO, TRACE_NUMBER, ESTADO, TIPO, MONEDA, TIPO_DOCUMENTO, SERIE_DEL_CHEQUE)
    		VALUES (@TICKET, @TICKET, (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)), @RI_CODIGO_TRANSAC, @T_COD_BANCO, @T_SUCURSAL, @T_NUMERO_CUENTA_GIRADORA, @T_IMPORTE, @RI_CODIGO_POSTAL, @T_FECHA_DEL_CHEQUE, @T_FECHA_VALOR, @T_NUMERO_DEL_CHEQUE, @RI_PUNTO_INTERCAMBIO, @RI_CONTADOR_REGISTRO, 'P', 'C', @T_MONEDA, @T_TIPO_DOCUMENTO, @T_SERIE_DEL_CHEQUE);
    		-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
			*/
			IF (@Excedente = 0)
			BEGIN		     	       				
				FETCH NEXT FROM cursor_che_rechazados INTO @CheNroChequeAJ, @CheImporteAJ, @CheBancoAJ, @CheSucursalAJ, @ChePostalAJ, @CheTrackNumberAJ
				SET @CountExcedente = 0;
			END			               
		END 
		CLOSE cursor_che_rechazados 
		DEALLOCATE cursor_che_rechazados 

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
			SET @FL_TOTALES_DE_CONTROL =RIGHT(concat(replicate('0', 10), (SELECT sum(convert(bigINT,substring(t.LINEA,4,8))) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX t WHERE t.ID>(SELECT max(tt.id) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX tt WHERE tt.LINEA LIKE '5%') AND substring(t.LINEA,1,1) IN ('6'))), 10);
		SET @FL_SUMA_TOTAL_DEBITO_LOTE =  RIGHT(concat(replicate('0', 20), (replace((SELECT sum(convert(bigint, substring(linea,61,16))) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '6%' AND LINEA NOT LIKE '622%' AND id>(SELECT max(id) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '5%')), '.', ''))), 20); 
		SET @FL_SUMA_TOTAL_DEBITO_LOTE =  RIGHT(concat(replicate('0', 20), (replace((SELECT sum(convert(bigint, substring(linea,61,16))) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '622%' AND id>(SELECT max(id) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '5%')), '.', ''))), 20);
		SET @TotalesDebitos += @SumaImportes;
		SET @FL_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate('0', 6), (SELECT count(id) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX t WHERE t.ID>(SELECT max(tt.id) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX tt WHERE tt.LINEA LIKE '5%') AND substring(t.LINEA,1,1) IN ('6','7'))), 6); 
	
		---- Grabamos FIN de lote solo si hay registros individuales ingresados
		IF(0<(SELECT COUNT(*) FROM CLE_CHEQUES_AJUSTE WHERE ESTADO = 'F' AND ENVIADO_RECIBIDO = 'R' AND ESTADO_AJUSTE = 'R'))
		BEGIN		
			SET @FL_TOTALES_DE_CONTROL =RIGHT(concat(replicate('0', 10), (SELECT sum(convert(bigINT,substring(t.LINEA,4,8))) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX t WHERE t.ID>(SELECT max(tt.id) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX tt WHERE tt.LINEA LIKE '5%') AND substring(t.LINEA,1,1) IN ('6'))), 10);
			SET @FL_SUMA_TOTAL_DEBITO_LOTE =  RIGHT(concat(replicate('0', 20), (replace((SELECT sum(convert(bigint, substring(linea,61,16))) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '6%' AND LINEA NOT LIKE '622%' AND id>(SELECT max(id) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '5%')), '.', ''))), 20); 
			SET @FL_SUMA_TOTAL_CREDITO_LOTE = RIGHT(concat(replicate('0', 20), (replace((SELECT sum(convert(bigint, substring(linea,61,16))) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '622%' AND id>(SELECT max(id) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '5%')), '.', ''))), 20); 
			SET @FL_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate('0', 6), (SELECT count(id) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX t WHERE t.ID>(SELECT max(tt.id) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX tt WHERE tt.LINEA LIKE '5%') AND substring(t.LINEA,1,1) IN ('6','7'))), 6); 
			SET @FL_NUMERO_LOTE= @CL_NUMERO_LOTE 
			SET @FL_FIN_LOTE = concat(@FL_ID_REG, @FL_CODIGO_CLASE_TRANSAC, @FL_CANT_REG_INDIVIDUAL_ADICIONAL, @FL_TOTALES_DE_CONTROL, @FL_SUMA_TOTAL_DEBITO_LOTE, @FL_SUMA_TOTAL_CREDITO_LOTE, @FL_RESERVADO1, @FL_RESERVADO2, @FL_RESERVADO3, @FL_REG_ENTIDAD_ORIGEN, @FL_NUMERO_LOTE);

			INSERT INTO dbo.ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX (LINEA) VALUES (replace(@FL_FIN_LOTE, '.', ''));
		END
	
		--***BLOQUE DE CODIGO NUEVO PARA CLE_RECEPCION_CHEQUES_DEV 08/05/2024 JI***--

		SELECT NUMERICO_1 FROM ITF_MASTER_PARAMETROS WHERE CODIGO = 138
		IF(0<(SELECT count(*) 
			FROM CLE_RECEPCION_CHEQUES_DEV CD 
			LEFT JOIN CLI_DIRECCIONES DIR ON CD.BANCO_GIRADO=DIR.ID
--			JOIN ITF_COELSA_CHEQUES_PROPIOS CP ON CD.NUMERO_CHEQUE=CP.NRO_CHEQUE
			WHERE CD.ESTADO_DEVOLUCION=0 
			AND CD.TZ_LOCK=0 
			AND DIR.TZ_LOCK=0 ) AND (@FL_CONTADOR_AL_INICIAR<>(SELECT NUMERICO_1 FROM ITF_MASTER_PARAMETROS WHERE CODIGO = 138)))	
		BEGIN		
		
		---------------- Grabar Cabecera Lote ---------------------------
		SET @CL_NUMERO_LOTE  =RIGHT(concat(replicate('0', 7), (SELECT COUNT(*) + 1 FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '5%' AND ID>(SELECT max(id) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '1%'))), 7);
		SET @CL_CABECERA = concat(@CL_ID_REG, @CL_CODIGO_CLASE_TRANSAC, @CL_RESERVADO, @CL_TIPO_REGISTRO, @CL_DESCRIP_TRANSAC, @CL_FECHA_PRESENTACION, @CL_FECHA_VENCIMIENTO, @CL_RESERVADO_CL, @CL_CODIGO_ORIGEN, @CL_ID_ENTIDAD_ORIGEN, @CL_NUMERO_LOTE);
		INSERT INTO dbo.ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX (LINEA) VALUES (@CL_CABECERA);
		-----------------------------------------------------------------

	END
	
	-- Variables cursor_che_ajustes --
	DECLARE @CheNroChequeRCD NUMERIC(12,0);
	DECLARE @CheBancoRCD NUMERIC(5,0);
	DECLARE @CheSucursalRCD NUMERIC(5,0);
	DECLARE @ChePostalRCD NUMERIC(4,0);
	DECLARE @CheImporteRCD NUMERIC(15,2);
	DECLARE @CheTrackNumberRCD VARCHAR(20);
	declare @codRech numeric(3);
	DECLARE @sucursalRCD NUMERIC(5,0)
	DECLARE @numCuentaRCD NUMERIC(12,0)
	-----------------------------------

	-- Cursor de RCD --
	DECLARE cursor_che_rechazados CURSOR FOR

		SELECT CD.NUMERO_CHEQUE, 
			CD.IMPORTE_CHEQUE, 
			CD.BANCO_GIRADO, 
			CD.SUCURSAL_BANCO_GIRADO, 
			DIR.CPA_VIEJO,
--			CP.TRACE_NUMBER,
			CD.CODIGO_RECHAZO
			--, CD.BANCO_GIRADO 
			, CD.NUMERO_CUENTA_GIRADORA
			, concat('0' , CASE WHEN Cd.SERIE_del_CHEQUE='E' THEN '2' ELSE '0' end) AS InfoAdicional

		FROM CLE_RECEPCION_CHEQUES_DEV CD 
		LEFT JOIN CLI_DIRECCIONES DIR ON CD.BANCO_GIRADO=DIR.ID
--		JOIN ITF_COELSA_CHEQUES_PROPIOS CP ON CD.NUMERO_CHEQUE=CP.NRO_CHEQUE
		WHERE CD.ESTADO_DEVOLUCION=0 
		AND CD.TZ_LOCK=0 
		AND DIR.TZ_LOCK=0

	OPEN cursor_che_rechazados

	FETCH NEXT FROM cursor_che_rechazados INTO @CheNroChequeRCD, 
												@CheImporteRCD, 
												@CheBancoRCD, 
												@CheSucursalRCD, 
												@ChePostalRCD, 
												--@CheTrackNumberRCD,
												@codRech
												--, @sucursalRCD

												, @numCuentaRCD
												, @CheInfoAdicional

	WHILE @@FETCH_STATUS = 0 
	BEGIN
PRINT '4'
	SET @CL_DESCRIP_TRANSAC='REVERSAL  '
	Start_4:
		IF (@SumaImportes > 999999999999999999.99 OR @SumaEntidad > 999999) -- 9999 millones
		BEGIN
		
			IF @SumaSucursal > 9999
			BEGIN
				SET @SobranteSucursal = CAST(substring(CAST(@SumaSucursal AS VARCHAR), 1, (len(@SumaSucursal) - 4)) AS NUMERIC);
				SET @SumaEntidad += @SobranteSucursal;
				SET @SumaSucursal = CAST(RIGHT(@SumaSucursal, 4) AS NUMERIC);
			END

	   		SET @TotalesControl += @SumaEntidad + @SumaSucursal;
			SET @FL_TOTALES_DE_CONTROL =RIGHT(concat(replicate('0', 10), (SELECT sum(convert(bigINT,substring(t.LINEA,4,8))) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX t WHERE t.ID>(SELECT max(tt.id) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX tt WHERE tt.LINEA LIKE '5%') AND substring(t.LINEA,1,1) IN ('6'))), 10);
	   		SET @FL_SUMA_TOTAL_DEBITO_LOTE =  RIGHT(concat(replicate('0', 20), (replace((SELECT sum(convert(bigint, substring(linea,61,16))) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '6%' AND LINEA NOT LIKE '622%' AND id>(SELECT max(id) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '5%')), '.', ''))), 20); 
	   		SET @FL_SUMA_TOTAL_CREDITO_LOTE = RIGHT(concat(replicate('0', 20), (replace((SELECT sum(convert(bigint, substring(linea,61,16))) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '622%' AND id>(SELECT max(id) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '5%')), '.', ''))), 20); 
	   		SET @TotalesDebitos += @SumaImportes;
	   		SET @FL_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate('0', 6), (SELECT count(id) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX t WHERE t.ID>(SELECT max(tt.id) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX tt WHERE tt.LINEA LIKE '5%') AND substring(t.LINEA,1,1) IN ('6','7'))), 6); 
	   	
			SET @FL_NUMERO_LOTE= @CL_NUMERO_LOTE 
	   		SET @FL_FIN_LOTE = concat(@FL_ID_REG, @FL_CODIGO_CLASE_TRANSAC, @FL_CANT_REG_INDIVIDUAL_ADICIONAL, @FL_TOTALES_DE_CONTROL, @FL_SUMA_TOTAL_DEBITO_LOTE, @FL_SUMA_TOTAL_CREDITO_LOTE, @FL_RESERVADO1, @FL_RESERVADO2, @FL_RESERVADO3, @FL_REG_ENTIDAD_ORIGEN, @FL_NUMERO_LOTE);
		

			INSERT INTO dbo.ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX (LINEA) VALUES (replace(@FL_FIN_LOTE, '.', ''));
		

			-------------------------------------------------------------------
			-------------Grabamos el Fin de Archivo ----------------------------------------------------------------------------------------------------------------------
			SET @FA_CANT_LOTES = RIGHT(concat(replicate('0', 6), @FL_NUMERO_LOTE), 6);
			SET @CantRegistrosPrev = (SELECT (CASE WHEN (@CantRegistros + 4) % 10 = 0 THEN ((@CantRegistros + 4)/10) ELSE (FLOOR((@CantRegistros + 4)/10) + 1) END));
			SET @FA_NUMERO_BLOQUES = RIGHT(concat(replicate('0', 6), @CantRegistrosPrev ), 6);

			SET @FA_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate('0', 8), (SELECT count(id) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX t WHERE t.ID>(SELECT max(tt.id) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX tt WHERE tt.LINEA LIKE '1%') AND substring(t.LINEA,1,1) IN ('6','7'))), 8);
		
			SET @FA_TOTALES_DE_CONTROL =  RIGHT(concat(replicate('0', 10), (SELECT sum(convert(bigINT,substring(t.LINEA,4,8))) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX t WHERE t.ID>(SELECT max(tt.id) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX tt WHERE tt.LINEA LIKE '1%') AND substring(t.LINEA,1,1) IN ('6'))), 10);
		
			SET @FA_SUMA_TOTAL_DEBITOS = RIGHT(concat(replicate('0', 20), (replace((SELECT sum(convert(bigint, substring(linea,61,16))) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '6%' AND LINEA NOT LIKE '622%' AND id>(SELECT max(id) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '1%')), '.', ''))), 20);
		
			SET @FA_SUMA_TOTAL_CREDITOS = RIGHT(concat(replicate('0', 20), (replace((SELECT sum(convert(bigint, substring(linea,61,16))) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '622%' AND id>(SELECT max(id) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '1%')), '.', ''))), 20);
			

			SET @FA_CANT_LOTES = RIGHT(concat(replicate('0', 6), (SELECT count(ID) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '5%'AND id>(SELECT max(ID) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '1%'))), 6);

			--SET @FA_NUMERO_BLOQUES = RIGHT(concat(replicate('0', 6), @CantRegistrosPrev ), 6);
			
			 SET @FA_NUMERO_BLOQUES = RIGHT(concat(replicate('0', 6), (SELECT CEILING((count(*)+1) / CONVERT(FLOAT, 10))
																  FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX 
																  WHERE  ID>=(SELECT max(id) 
																  		  		FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX 
																  		  		WHERE LINEA LIKE '1%'))), 6);




			SET @FA_FIN_ARCHIVO = concat(@FA_ID_REG, @FA_CANT_LOTES, @FA_NUMERO_BLOQUES, @FA_CANT_REG_INDIVIDUAL_ADICIONAL, @FA_TOTALES_DE_CONTROL, @FA_SUMA_TOTAL_DEBITOS, @FA_SUMA_TOTAL_CREDITOS, @FA_RESERVADO);
		
			INSERT INTO dbo.ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX (LINEA) VALUES (@FA_FIN_ARCHIVO);
		
--			SET @FL_NUMERO_LOTE = CAST(@FL_NUMERO_LOTE AS NUMERIC) + 1;
--			SET @FL_NUMERO_LOTE = RIGHT(concat(replicate('0', 7), @FL_NUMERO_LOTE), 7);
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
		
			INSERT INTO dbo.ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX (LINEA) VALUES (@CA_CABECERA);
			----------------------------------------------------------------------------------------------------------------------------------------------------------------------
			--------- Grabamos nueva Cabecera Lote ------------------------------------------------------------------------------------------------------------------------------------------------------
			SET @CL_NUMERO_LOTE  =RIGHT(concat(replicate('0', 7), (SELECT COUNT(*) + 1 FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '5%' AND ID>(SELECT max(id) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '1%'))), 7);   
			SET @CL_CABECERA = concat(@CL_ID_REG, @CL_CODIGO_CLASE_TRANSAC, @CL_RESERVADO, @CL_TIPO_REGISTRO, @CL_DESCRIP_TRANSAC, @CL_FECHA_PRESENTACION, @CL_FECHA_VENCIMIENTO, @CL_RESERVADO_CL, @CL_CODIGO_ORIGEN, @CL_ID_ENTIDAD_ORIGEN, @CL_NUMERO_LOTE);
			INSERT INTO dbo.ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX (LINEA) VALUES (@CL_CABECERA);
			---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		
		END

		SET @CantRegistros += 1;
	
		SET @Cant_Reg_Individual_Adicional += 1;
	
	
		IF	(@Excedente<>0)
		BEGIN
			SET @CheImporteRCD = @Excedente;
			SET @CountExcedente += 1;
		END
		IF	(@CheImporteRCD>99999999999999.99)
		BEGIN
			SET @Excedente = (@CheImporteRCD - 99999999999999.99);
			SET @CheImporteRCD = 99999999999999.99;
			SET @CountExcedente += 1;
		END
		ELSE
    	BEGIN
       		SET @Excedente = 0;
    	END
		
	
	
        SET @SumaSucursal += 0888; --sumo la sucursal que hay que harcodear
        SET @SumaEntidad += LEFT(@CheBancoRCD,4);
        SET @SumaImportes += @CheImporteRCD;
		
        SET @RI_ENTIDAD_DEBITAR = concat(RIGHT(concat(replicate('0', 4), LEFT(@CheBancoRCD,4)), 4), RIGHT(concat(replicate('0',4),@CheSucursalRCD),4));
        SET @RI_CUENTA_DEBITAR = RIGHT(concat(replicate('0', 17), @numCuentaRCD), 17);
        SET @RI_NUMERO_CHEQUE = RIGHT(concat(replicate('0',15),@CheNroChequeRCD),15);--antes era '000088888888888';  --ACA SE SETEAN LOS 8

		IF @SumaImportes>999999999999999999.99 GOTO Start_4
	
		SET @RI_IMPORTE = RIGHT(concat(replicate('0', 16), replace(CAST(@CheImporteRCD AS VARCHAR),'.','')), 16);
		
		SET @RI_CODIGO_POSTAL =  concat('00', RIGHT(concat(replicate('0', 4), @ChePostalRCD), 4));
		
		SET @RI_INFO_ADICIONAL = @CheInfoAdicional;;
		
		SET @RI_REGISTRO_ADICIONAL = '0';
	   	
		SET @RI_CONTADOR_REGISTRO = concat('0311', RIGHT(concat(replicate('0', 4), ('0097')), 4),RIGHT(concat(replicate('0', 7), (SELECT NUMERICO_1 FROM ITF_MASTER_PARAMETROS WHERE CODIGO = 138)), 7));
	
		SET @RI_CODIGO_TRANSAC='22';
		
		SET @RI_PUNTO_INTERCAMBIO=concat(RIGHT(concat(replicate('0',6),@codRech),6),'00',replicate(' ',8))
		
		SET @RI_REGISTRO_INDIVIDUAL = concat(@RI_ID_REG
											, @RI_CODIGO_TRANSAC
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
PRINT 'hola'

		INSERT INTO dbo.ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX (LINEA) VALUES (replace(@RI_REGISTRO_INDIVIDUAL, '.', ''));
		
		
		/* Logica para agregar el registro adicional con el motivo del rechazo*/	
--		IF(@Excedente=0 OR @Excedente<90000000)
--		BEGIN
--			SET @CODIGO_RECHAZO = 'R' + RIGHT(CONCAT('00',@codRech),2);
--			SET @TRACE_NUMBER=  RIGHT(CONCAT('000000000000000',@CheTrackNumberRCD),15); 
--			SET @OTRO_RECHAZO = REPLICATE(' ',44);
	
--			SET @RI_REGISTRO_INDIVIDUAL_ADICIONAL = concat('799',@CODIGO_RECHAZO,@TRACE_NUMBER,'      ',@RI_ENTIDAD_DEBITAR,@OTRO_RECHAZO,@RI_CONTADOR_REGISTRO);
--			INSERT INTO dbo.ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX (LINEA) VALUES (replace(@RI_REGISTRO_INDIVIDUAL_ADICIONAL, '.', ''));
--		END
	
		---------------------------- Actualizar contador unico ----------------------------------------
    	UPDATE dbo.ITF_MASTER_PARAMETROS SET NUMERICO_1 = (NUMERICO_1 + 1) WHERE CODIGO = 138;
    	------------------------------------------------------------------------------------------------
    	/*---------- Grabar historial ----------------------------------------------------------------------------------------------------------------------------------------------------------------------
    	INSERT INTO ITF_COELSA_CHEQUES_OTROS (ID_TICKET, ID_PROCESO, FECHAPROCESO, CODIGO_TRANSACCION, BANCO, SUCURSAL, CUENTA, IMPORTE, CODIGO_POSTAL, FECHA_PRESENTADO, FECHA_VENCIMIENTO, NRO_CHEQUE, PUNTO_INTERCAMBIO, TRACE_NUMBER, ESTADO, TIPO, MONEDA, TIPO_DOCUMENTO, SERIE_DEL_CHEQUE)
    	VALUES (@TICKET, @TICKET, (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)), @RI_CODIGO_TRANSAC, @T_COD_BANCO, @T_SUCURSAL, @T_NUMERO_CUENTA_GIRADORA, @T_IMPORTE, @RI_CODIGO_POSTAL, @T_FECHA_DEL_CHEQUE, @T_FECHA_VALOR, @T_NUMERO_DEL_CHEQUE, @RI_PUNTO_INTERCAMBIO, @RI_CONTADOR_REGISTRO, 'P', 'C', @T_MONEDA, @T_TIPO_DOCUMENTO, @T_SERIE_DEL_CHEQUE);
    	-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		*/
		IF (@Excedente = 0)
		BEGIN		     	       				
			FETCH NEXT FROM cursor_che_rechazados INTO @CheNroChequeRCD, 
														@CheImporteRCD, 
														@CheBancoRCD, 
														@CheSucursalRCD, 
														@ChePostalRCD, 
														--@CheTrackNumberRCD,
														@codRech
														--, @sucursalRCD
														, @numCuentaRCD
														, @CheInfoAdicional
			SET @CountExcedente = 0;

		END
				               
	END 
	CLOSE cursor_che_rechazados 
	DEALLOCATE cursor_che_rechazados 




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
	SET @FL_TOTALES_DE_CONTROL =RIGHT(concat(replicate('0', 10), (SELECT sum(convert(bigINT,substring(t.LINEA,4,8))) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX t WHERE t.ID>(SELECT max(tt.id) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX tt WHERE tt.LINEA LIKE '5%') AND substring(t.LINEA,1,1) IN ('6'))), 10);
	
	SET @FL_SUMA_TOTAL_DEBITO_LOTE =  RIGHT(concat(replicate('0', 20), (replace((SELECT sum(convert(bigint, substring(linea,61,16))) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '6%' AND LINEA NOT LIKE '622%' AND id>(SELECT max(id) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '5%')), '.', ''))), 20); 
	SET @FL_SUMA_TOTAL_CREDITO_LOTE = RIGHT(concat(replicate('0', 20), (replace((SELECT sum(convert(bigint, substring(linea,61,16))) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '622%' AND id>(SELECT max(id) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '5%')), '.', ''))), 20);
	SET @TotalesDebitos += @SumaImportes;
	SET @FL_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate('0', 6), (SELECT count(id) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX t WHERE t.ID>(SELECT max(tt.id) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX tt WHERE tt.LINEA LIKE '5%') AND substring(t.LINEA,1,1) IN ('6','7'))), 6); 
	
	---- Grabamos FIN de lote solo si hay registros individuales ingresados
	IF(0<(SELECT count(*) 
			FROM CLE_RECEPCION_CHEQUES_DEV CD 
			LEFT JOIN CLI_DIRECCIONES DIR ON CD.BANCO_GIRADO=DIR.ID
--			JOIN ITF_COELSA_CHEQUES_PROPIOS CP ON CD.NUMERO_CHEQUE=CP.NRO_CHEQUE
			WHERE CD.ESTADO_DEVOLUCION=0 
			AND CD.TZ_LOCK=0 
			AND DIR.TZ_LOCK=0 ))
	BEGIN		
		SET @FL_TOTALES_DE_CONTROL =RIGHT(concat(replicate('0', 10), (SELECT sum(convert(bigINT,substring(t.LINEA,4,8))) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX t WHERE t.ID>(SELECT max(tt.id) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX tt WHERE tt.LINEA LIKE '5%') AND substring(t.LINEA,1,1) IN ('6'))), 10);
		SET @FL_SUMA_TOTAL_DEBITO_LOTE =  RIGHT(concat(replicate('0', 20), (replace((SELECT sum(convert(bigint, substring(linea,61,16))) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '6%' AND LINEA NOT LIKE '622%' AND id>(SELECT max(id) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '5%')), '.', ''))), 20);  
		SET @FL_SUMA_TOTAL_CREDITO_LOTE = RIGHT(concat(replicate('0', 20), (replace((SELECT sum(convert(bigint, substring(linea,61,16))) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '622%' AND id>(SELECT max(id) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '5%')), '.', ''))), 20);
		SET @FL_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate('0', 6), (SELECT count(id) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX t WHERE t.ID>(SELECT max(tt.id) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX tt WHERE tt.LINEA LIKE '5%') AND substring(t.LINEA,1,1) IN ('6','7'))), 6); 
		SET @FL_NUMERO_LOTE= @CL_NUMERO_LOTE 
		SET @FL_FIN_LOTE = concat(@FL_ID_REG, @FL_CODIGO_CLASE_TRANSAC, @FL_CANT_REG_INDIVIDUAL_ADICIONAL, @FL_TOTALES_DE_CONTROL, @FL_SUMA_TOTAL_DEBITO_LOTE, @FL_SUMA_TOTAL_CREDITO_LOTE, @FL_RESERVADO1, @FL_RESERVADO2, @FL_RESERVADO3, @FL_REG_ENTIDAD_ORIGEN, @FL_NUMERO_LOTE);
		
		INSERT INTO dbo.ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX (LINEA) VALUES (replace(@FL_FIN_LOTE, '.', ''));
	END
	
PRINT 'aca'
	
	IF(@FL_CONTADOR_AL_INICIAR=(SELECT NUMERICO_1 FROM ITF_MASTER_PARAMETROS WHERE CODIGO = 138))
	BEGIN
		SET @FL_NUMERO_LOTE= @CL_NUMERO_LOTE 
		SET @FL_FIN_LOTE = concat(@FL_ID_REG, @FL_CODIGO_CLASE_TRANSAC, @FL_CANT_REG_INDIVIDUAL_ADICIONAL, @FL_TOTALES_DE_CONTROL, @FL_SUMA_TOTAL_DEBITO_LOTE, @FL_SUMA_TOTAL_CREDITO_LOTE, @FL_RESERVADO1, @FL_RESERVADO2, @FL_RESERVADO3, @FL_REG_ENTIDAD_ORIGEN, @FL_NUMERO_LOTE);			
		INSERT INTO dbo.ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX (LINEA) VALUES (replace(@FL_FIN_LOTE, '.', ''));
	END
	
	
	--***¯\_(°.°)_/¯***--
	

	---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-------------Grabamos el Fin de Archivo ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	SET @FA_CANT_LOTES = RIGHT(concat(replicate('0', 6), @FL_NUMERO_LOTE), 6);
	SET @CantRegistrosPrev = (SELECT (CASE WHEN (@CantRegistros + 4) % 10 = 0 THEN ((@CantRegistros + 4)/10) ELSE (FLOOR((@CantRegistros + 4)/10) + 1) END));
	SET @FA_NUMERO_BLOQUES = RIGHT(concat(replicate('0', 6), @CantRegistrosPrev), 6);
	
	SET @FA_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate('0', 8), (SELECT count(id) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX t WHERE t.ID>(SELECT max(tt.id) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX tt WHERE tt.LINEA LIKE '1%') AND substring(t.LINEA,1,1) IN ('6','7'))), 8);
			
	SET @FA_TOTALES_DE_CONTROL =RIGHT(concat(replicate('0', 10), (SELECT sum(convert(bigINT,substring(t.LINEA,4,8))) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX t WHERE t.ID>(SELECT max(tt.id) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX tt WHERE tt.LINEA LIKE '1%') AND substring(t.LINEA,1,1) IN ('6'))), 10); --igualo al totales de control de fin de lote pq tiene que ser igual
			
	SET @FA_SUMA_TOTAL_DEBITOS = RIGHT(concat(replicate('0', 20), (replace((SELECT sum(convert(bigint, substring(linea,61,16))) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '6%' AND LINEA NOT LIKE '622%' AND id>(SELECT max(id) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '1%')), '.', ''))), 20);
			
	SET @FA_SUMA_TOTAL_CREDITOS = RIGHT(concat(replicate('0', 20), (replace((SELECT sum(convert(bigint, substring(linea,61,16))) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '622%' AND id>(SELECT max(id) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '1%')), '.', ''))), 20);
	

	SET @FA_CANT_LOTES = RIGHT(concat(replicate('0', 6), (SELECT count(ID) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '5%'AND id>(SELECT max(ID) FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE '1%'))), 6);

	--SET @FA_NUMERO_BLOQUES = RIGHT(concat(replicate('0', 6), @CantRegistrosPrev ), 6);
			
	SET @FA_NUMERO_BLOQUES = RIGHT(concat(replicate('0', 6), (SELECT CEILING((count(*)+1) / CONVERT(FLOAT, 10))
																  FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX 
																  WHERE  ID>=(SELECT max(id) 
																  		  		FROM ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX 
																  		  		WHERE LINEA LIKE '1%'))), 6);
	
	
	
	SET @FA_FIN_ARCHIVO = concat(@FA_ID_REG, @FA_CANT_LOTES, @FA_NUMERO_BLOQUES, @FA_CANT_REG_INDIVIDUAL_ADICIONAL, @FA_TOTALES_DE_CONTROL, @FA_SUMA_TOTAL_DEBITOS, @FA_SUMA_TOTAL_CREDITOS, @FA_RESERVADO);
			
	
	
	INSERT INTO dbo.ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX (LINEA) VALUES (@FA_FIN_ARCHIVO);
   

--	END TRY
--	BEGIN CATCH  
--	    -- CERRAR CURSORES SI ESTAN ABIERTOS
--		IF CURSOR_STATUS('GLOBAL', 'CURSOR_CHE_RECHAZADOS') >= 0
--		BEGIN
--		    IF CURSOR_STATUS('GLOBAL', 'CURSOR_CHE_RECHAZADOS') = 1
--		    BEGIN
--		        CLOSE CURSOR_CHE_RECHAZADOS;
--		    	DEALLOCATE CURSOR_CHE_RECHAZADOS;
--		    END
--	    END 
--
--	 PRINT 'ERROR'	  
--		  SET @MSJ = 'Linea Error: ' + CONVERT(VARCHAR,ERROR_LINE()) + ' Mensaje Error: ' +  ERROR_MESSAGE();
--		  RETURN
--		  
--	END CATCH;
	
				
--	SET @FL_NUMERO_LOTE = CAST(@FL_NUMERO_LOTE AS NUMERIC) + 1;
--	SET @FL_NUMERO_LOTE = RIGHT(concat(replicate('0', 7), @FL_NUMERO_LOTE), 7);
	------------------------------------------------------------------------------------------------------------------------------------------------------------------


END
GO

