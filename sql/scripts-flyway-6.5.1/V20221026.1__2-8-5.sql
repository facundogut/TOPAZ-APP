EXECUTE('

IF OBJECT_ID (''dbo.ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX'') IS NOT NULL
	DROP TABLE dbo.ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX

CREATE TABLE dbo.ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX
	(
	ID    INT IDENTITY NOT NULL,
	LINEA VARCHAR (200)
	)
	
IF OBJECT_ID (''[dbo].[SP_COELSA_ENVIO_DPF_PROPIOS_RECHAZADOS]'') IS NOT NULL
	DROP PROCEDURE [dbo].[SP_COELSA_ENVIO_DPF_PROPIOS_RECHAZADOS]
')
EXECUTE('
CREATE PROCEDURE [dbo].[SP_COELSA_ENVIO_DPF_PROPIOS_RECHAZADOS]
   @TICKET NUMERIC(16),
   @MONEDA NUMERIC(4)
AS 
BEGIN

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- Created : 20/05/2021 10:00 a.m.
--- Autor: Luis Etchebarne 
--- Se crea el sp con el fin de generar la información de los dpf propios rechazados a informar a COELSA.
--- Mediante el parametro MONEDA se filtra los dpf en pesos o dolares.
--- 0 pesos , 1 dolares
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

------------ Limpieza de tabla auxiliar --------------------
TRUNCATE TABLE dbo.ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX;
------------------------------------------------------------

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

---- Grabamos cabecera de lote y archivo solo si hay registros individuales ingresados
IF(0<(SELECT COUNT(*) FROM ITF_COELSA_CHEQUES_RECHAZO WHERE ESTADO = ''P'' AND TIPO = ''D'' AND SUBSTRING(INFO_ADICIONAL, 1, 1) = @MONEDA  AND FECHAPROCESO = (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK))))
	BEGIN
		---------------- Grabar Cabecera Archivo ---------------------------
		INSERT INTO dbo.ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX (LINEA) VALUES (@CA_CABECERA);
		--------------------------------------------------------------------
		---------------- Grabar Cabecera Lote ---------------------------
		INSERT INTO dbo.ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX (LINEA) VALUES (@CL_CABECERA);
		-----------------------------------------------------------------
	END

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
DECLARE @FA_CANT_LOTES VARCHAR(6);-- total de lotes que contiene el archivo
DECLARE @FA_NUMERO_BLOQUES VARCHAR(8);-- ver detalles en doc pdf
DECLARE @FA_CANT_REG_INDIVIDUAL_ADICIONAL VARCHAR(8); --total de registros individuales y adicionales que existen en el archivo
DECLARE @FA_TOTALES_DE_CONTROL VARCHAR(10);
DECLARE @FA_SUMA_TOTAL_DEBITOS VARCHAR(12);
DECLARE @FA_SUMA_TOTAL_CREDITOS VARCHAR(12);
DECLARE @FA_RESERVADO  VARCHAR(100) = replicate('' '', 39); -- fijo

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
DECLARE @T_CUENTA_DEBITAR VARCHAR(17);
DECLARE @T_IMPORTE NUMERIC(15,2);
DECLARE @T_NRO_CHEQUE VARCHAR(15);
DECLARE @T_CODIGO_POSTAL VARCHAR(6);
DECLARE @T_PUNTO_INTERCAMBIO VARCHAR(16);
DECLARE @T_TRACE_NUMBER VARCHAR(15);

    --Condicion de reset del contador de reg individual
IF ISNULL((SELECT a.FECHA FROM ITF_MASTER_PARAMETROS a WHERE a.CODIGO = 137), CAST(''01-01-1800'' AS DATETIME)) <> (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK))
    UPDATE dbo.ITF_MASTER_PARAMETROS SET NUMERICO_1 = 1, FECHA = (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)) WHERE CODIGO = 137;
 


DECLARE CursorDPF CURSOR FOR
			
SELECT ENTIDAD_DEBITAR, CUENTA_DEBITAR, IMPORTE, NRO_CHEQUE, CODIGO_POSTAL, PUNTO_INTERCAMBIO, TRACE_NUMBER
FROM ITF_COELSA_CHEQUES_RECHAZO 
WHERE ESTADO = ''P'' AND TIPO = ''D'' AND SUBSTRING(INFO_ADICIONAL, 1, 1) = @MONEDA  AND FECHAPROCESO = (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK))

				        		
OPEN CursorDPF
FETCH NEXT FROM CursorDPF INTO @T_ENTIDAD_DEBITAR, @T_CUENTA_DEBITAR, @T_IMPORTE, @T_NRO_CHEQUE,@T_CODIGO_POSTAL,@T_PUNTO_INTERCAMBIO,@T_TRACE_NUMBER

WHILE @@FETCH_STATUS = 0
BEGIN
	
	IF (@SumaImportes) > 9909999999 -- 99 millones
	BEGIN
		
		IF @SumaSucursal > 9999
		BEGIN
			SET @SobranteSucursal = CAST(substring(CAST(@SumaSucursal AS VARCHAR), 1, (len(@SumaSucursal) - 4)) AS NUMERIC);
			SET @SumaEntidad += @SobranteSucursal;
			SET @SumaSucursal = CAST(RIGHT(@SumaSucursal, 4) AS NUMERIC);
		END
		
	   --	SET @TotalesControl += @SumaEntidad + @SumaSucursal;
	   	SET @FL_TOTALES_DE_CONTROL = concat((RIGHT(concat(replicate(''0'', 6), @SumaEntidad), 6)), (RIGHT(concat(replicate(''0'', 4), @SumaSucursal), 4)));
	   	SET @FL_SUMA_TOTAL_DEBITO_LOTE = RIGHT(concat(replicate(''0'', 12), (replace(@SumaImportes, ''.'', ''''))), 12); 
	   	SET @FL_SUMA_TOTAL_CREDITO_LOTE = RIGHT(replicate(''0'', 12), 12);
	   	SET @TotalesDebitos += @SumaImportes;
	   	SET @FL_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 6), @Cant_Reg_Individual_Adicional), 6); 
	   	
	   	SET @FL_FIN_LOTE = concat(@FL_ID_REG, @FL_CODIGO_CLASE_TRANSAC, @FL_CANT_REG_INDIVIDUAL_ADICIONAL, @FL_TOTALES_DE_CONTROL, @FL_SUMA_TOTAL_DEBITO_LOTE, @FL_SUMA_TOTAL_CREDITO_LOTE, @FL_RESERVADO1, @FL_RESERVADO2, @FL_RESERVADO3, @FL_REG_ENTIDAD_ORIGEN, @FL_NUMERO_LOTE);
		
    
	
		INSERT INTO dbo.ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX (LINEA) VALUES (replace(@FL_FIN_LOTE, ''.'', ''''));
		
		SET @FL_NUMERO_LOTE = CAST(@FL_NUMERO_LOTE AS NUMERIC) + 1;
		SET @FL_NUMERO_LOTE = RIGHT(concat(replicate(''0'', 7), @FL_NUMERO_LOTE), 7);
		-------------------------------------------------------------------
		-------------Grabamos el Fin de Archivo ----------------------------------------------------------------------------------------------------------------------
		SET @FA_CANT_LOTES = RIGHT(concat(replicate(''0'', 6), @FL_NUMERO_LOTE), 6);
		SET @CantRegistrosPrev = (SELECT (CASE WHEN (@CantRegistros + 4) % 10 = 0 THEN ((@CantRegistros + 4)/10) ELSE (FLOOR((@CantRegistros + 4)/10) + 1) END));
		SET @FA_NUMERO_BLOQUES = RIGHT(concat(replicate(''0'', 6), @CantRegistrosPrev), 6);

		SET @FA_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 8), @CantRegistros), 8);
		
		SET @FA_TOTALES_DE_CONTROL = @FL_TOTALES_DE_CONTROL; --igualo al totales de control de fin de lote pq tiene que ser igual
		
		SET @FA_SUMA_TOTAL_DEBITOS = RIGHT(concat(replicate(''0'', 12), (replace(@TotalesDebitos, ''.'', ''''))), 12);
		
		SET @FA_SUMA_TOTAL_CREDITOS = RIGHT(concat(replicate(''0'', 12), (replace(@TotalesCreditos, ''.'', ''''))),12);

		SET @FA_FIN_ARCHIVO = concat(@FA_ID_REG, @FA_CANT_LOTES, @FA_NUMERO_BLOQUES, @FA_CANT_REG_INDIVIDUAL_ADICIONAL, @FA_TOTALES_DE_CONTROL, @FA_SUMA_TOTAL_DEBITOS, @FA_SUMA_TOTAL_CREDITOS, @FA_RESERVADO);
		
		INSERT INTO dbo.ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX (LINEA) VALUES (@FA_FIN_ARCHIVO);
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
		
		INSERT INTO dbo.ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX (LINEA) VALUES (@CA_CABECERA);
		----------------------------------------------------------------------------------------------------------------------------------------------------------------------
		--------- Grabamos nueva Cabecera Lote ------------------------------------------------------------------------------------------------------------------------------------------------------
		SET @CL_NUMERO_LOTE = RIGHT(concat(replicate(''0'', 7), (@CL_NUMERO_LOTE + 1)), 7);
		SET @CL_CABECERA = concat(@CL_ID_REG, @CL_CODIGO_CLASE_TRANSAC, @CL_RESERVADO, @CL_TIPO_REGISTRO, @CL_DESCRIP_TRANSAC, @CL_FECHA_PRESENTACION, @CL_FECHA_VENCIMIENTO, @CL_RESERVADO_CL, @CL_CODIGO_ORIGEN, @CL_ID_ENTIDAD_ORIGEN, @CL_NUMERO_LOTE);
		INSERT INTO dbo.ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX (LINEA) VALUES (@CL_CABECERA);
		---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	END
	
	SET @CantRegistros += 1;
	SET @Cant_Reg_Individual_Adicional += 1;
	
	IF	(@Excedente<>0)
	BEGIN
		SET @T_IMPORTE = @Excedente;
		SET @CountExcedente += 1;
	END
	IF	(@T_IMPORTE>90000000)
	BEGIN
		SET @Excedente = (@T_IMPORTE - 90000000);
		SET @T_IMPORTE = 90000000;
		SET @CountExcedente += 1;
		--SET @RA_CONTADOR_REGISTRO_ORIGEN = @RI_CONTADOR_REGISTRO;
	END
	ELSE
    BEGIN
       SET @Excedente = 0;
    END
	
	
	SET @SumaSucursal += CONVERT(NUMERIC(4),RIGHT(@T_ENTIDAD_DEBITAR,4));
	SET @SumaEntidad += CONVERT(NUMERIC(4),LEFT(RIGHT(concat(replicate(''0'', 8), @T_ENTIDAD_DEBITAR), 8),4));
	SET @SumaImportes += @T_IMPORTE;
	
	---------------------------- Grabar Registro Individual -----------------------------------------------------------------------------------------------------------------------------------------
	SET @RI_ENTIDAD_DEBITAR = RIGHT(concat(replicate(''0'', 8), @T_ENTIDAD_DEBITAR), 8);
    SET @RI_CUENTA_DEBITAR = RIGHT(concat(replicate(''0'', 17), @T_CUENTA_DEBITAR), 17);
    SET @RI_NUMERO_CHEQUE = concat(''00'', RIGHT(concat(replicate(''0'', 13), @T_NRO_CHEQUE), 13));
    
    IF(@CountExcedente>1)
	BEGIN
        SET @SumaSucursal += 0888;  --sumo la sucursal que hay que harcodear
        SET @SumaEntidad +=  CONVERT(NUMERIC(4),LEFT(RIGHT(concat(replicate(''0'', 8), @T_ENTIDAD_DEBITAR), 8),4));
        SET @SumaImportes += @T_IMPORTE;

        SET @RI_ENTIDAD_DEBITAR = concat(LEFT(RIGHT(concat(replicate(''0'', 8), @T_ENTIDAD_DEBITAR), 8),4), ''0888'');
        SET @RI_CUENTA_DEBITAR = RIGHT(concat(replicate(''0'', 17), ''88888888888''), 17);
        SET @RI_NUMERO_CHEQUE = ''000088888888888'';

   
   	END
    ELSE --la razon de este else, es que SumaSucursal, cuando hay excedente tiene que acumular 0888
    BEGIN
        SET @SumaSucursal += CONVERT(NUMERIC(4),RIGHT(@T_ENTIDAD_DEBITAR,4));
		SET @SumaEntidad += CONVERT(NUMERIC(4),LEFT(RIGHT(concat(replicate(''0'', 8), @T_ENTIDAD_DEBITAR), 8),4));
		SET @SumaImportes += @T_IMPORTE;

        SET @RI_ENTIDAD_DEBITAR = RIGHT(concat(replicate(''0'', 8), @T_ENTIDAD_DEBITAR), 8);
        
        SET @RI_CUENTA_DEBITAR = RIGHT(concat(replicate(''0'', 17), @T_CUENTA_DEBITAR), 17);
        
        SET @RI_NUMERO_CHEQUE = concat(''00'', RIGHT(concat(replicate(''0'', 13), @T_NRO_CHEQUE), 13));
 
    END

    
    SET @RI_IMPORTE = RIGHT(concat(replicate(''0'', 10), replace(CAST(@T_IMPORTE AS VARCHAR),''.'','''')), 10);
    SET @RI_CODIGO_POSTAL = RIGHT(concat(''00'', replicate(''0'', 4), @T_CODIGO_POSTAL), 4);
    SET @RI_INFO_ADICIONAL = ''01'';
    SET @RI_REGISTRO_ADICIONAL = ''0'';
    SET @RI_CONTADOR_REGISTRO = concat(''0311'', RIGHT(concat(replicate(''0'', 4), (''97'')), 4), RIGHT(concat(replicate(''0'', 7), (SELECT NUMERICO_1 FROM ITF_MASTER_PARAMETROS WHERE CODIGO = 137)), 7)); 
    
     
        	
	SET @RI_REGISTRO_INDIVIDUAL = concat(@RI_ID_REG, @RI_CODIGO_TRANSAC, @RI_ENTIDAD_DEBITAR, @RI_RESERVADO, @RI_CUENTA_DEBITAR, @RI_IMPORTE, @RI_NUMERO_CHEQUE, @RI_CODIGO_POSTAL, @RI_PUNTO_INTERCAMBIO, @RI_INFO_ADICIONAL, @RI_REGISTRO_ADICIONAL, @RI_CONTADOR_REGISTRO);
 
    
    INSERT INTO dbo.ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX (LINEA) VALUES (replace(@RI_REGISTRO_INDIVIDUAL, ''.'', ''''));
	-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	----------------------------- Actualizar secuencial unico -------------------------------------
	UPDATE dbo.ITF_MASTER_PARAMETROS SET NUMERICO_1 = (NUMERICO_1 + 1) WHERE CODIGO = 137;
	-----------------------------------------------------------------------------------------------
	/*
	----------------------------- Grabar historial ---------------------------------------------------------------------------------------------------------------------------------------------------------------
    INSERT INTO ITF_COELSA_CHEQUES_OTROS (ID_TICKET, ID_PROCESO, FECHAPROCESO, CODIGO_TRANSACCION, BANCO, SUCURSAL, CUENTA, IMPORTE, CODIGO_POSTAL, FECHA_PRESENTADO, FECHA_VENCIMIENTO, NRO_CHEQUE, PUNTO_INTERCAMBIO, TRACE_NUMBER, ESTADO, TIPO, MONEDA, TIPO_DOCUMENTO)
    VALUES (@TICKET, @TICKET, (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)), @RI_CODIGO_TRANSAC, @D_BANCO, @D_SUCURSAL, @D_CUENTA, @D_IMPORTE, @D_CODIGO_POSTAL, @D_FECHA, @D_FECHA, @D_NUMERO_DPF, @RI_PUNTO_INTERCAMBIO, @RI_CONTADOR_REGISTRO, ''P'', ''D'', @D_MONEDA, @D_TIPO_DOCUMENTO);
    --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
	---------------- Actualizar informacion del dpf --------------------------------------------------------------------------------------------------------------------------------------
	UPDATE dbo.CLE_DPF_SALIENTE SET TRACKNUMBER = @RI_CONTADOR_REGISTRO, ESTADO = 2, FECHA_ENVIO_COMPENSACION = (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK))
    WHERE TIPO_DOCUMENTO = @D_TIPO_DOCUMENTO AND NUMERO_DPF = @D_NUMERO_DPF AND BANCO_GIRADO = @D_BANCO AND SUCURSAL_BANCO_GIRADO = @D_SUCURSAL AND FECHA_ALTA = @D_FECHA AND TZ_LOCK = 0;
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------    	
	*/
	
	IF (@Excedente = 0)
	BEGIN		     	       				
	
	FETCH NEXT FROM CursorDPF INTO @T_ENTIDAD_DEBITAR, @T_CUENTA_DEBITAR, @T_IMPORTE, @T_NRO_CHEQUE,@T_CODIGO_POSTAL,@T_PUNTO_INTERCAMBIO,@T_TRACE_NUMBER
	
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
IF(0<(SELECT COUNT(*) FROM ITF_COELSA_CHEQUES_RECHAZO WHERE ESTADO = ''P'' AND TIPO = ''D'' AND SUBSTRING(INFO_ADICIONAL, 1, 1) = @MONEDA  AND FECHAPROCESO = (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK))))
BEGIN
			
	--SET @TotalesControl += @SumaEntidad + @SumaSucursal;
	SET @FL_TOTALES_DE_CONTROL = concat((RIGHT(concat(replicate(''0'', 6), @SumaEntidad), 6)), (RIGHT(concat(replicate(''0'', 4), @SumaSucursal), 4)));
	SET @FL_SUMA_TOTAL_DEBITO_LOTE = RIGHT(concat(replicate(''0'', 12), (replace(@SumaImportes, ''.'', ''''))), 12); 
	SET @FL_SUMA_TOTAL_CREDITO_LOTE = RIGHT(replicate(''0'', 12), 12);
	SET @TotalesDebitos += @SumaImportes;
	SET @FL_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 6), @Cant_Reg_Individual_Adicional), 6); 
	
	
	
	
	SET @FL_FIN_LOTE = concat(@FL_ID_REG, @FL_CODIGO_CLASE_TRANSAC, @FL_CANT_REG_INDIVIDUAL_ADICIONAL, @FL_TOTALES_DE_CONTROL, @FL_SUMA_TOTAL_DEBITO_LOTE, @FL_SUMA_TOTAL_CREDITO_LOTE, @FL_RESERVADO1, @FL_RESERVADO2, @FL_RESERVADO3, @FL_REG_ENTIDAD_ORIGEN, @FL_NUMERO_LOTE);
			
	INSERT INTO dbo.ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX (LINEA) VALUES (replace(@FL_FIN_LOTE, ''.'', ''''));

	---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-------------Grabamos el Fin de Archivo ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	SET @FA_CANT_LOTES = RIGHT(concat(replicate(''0'', 6), @FL_NUMERO_LOTE), 6);
	SET @CantRegistrosPrev = (SELECT (CASE WHEN (@CantRegistros + 4) % 10 = 0 THEN ((@CantRegistros + 4)/10) ELSE (FLOOR((@CantRegistros + 4)/10) + 1) END));
	SET @FA_NUMERO_BLOQUES = RIGHT(concat(replicate(''0'', 6), @CantRegistrosPrev), 6);
	
	SET @FA_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 8), @CantRegistros), 8);
			
	SET @FA_TOTALES_DE_CONTROL = @FL_TOTALES_DE_CONTROL; --igualo al totales de control de fin de lote pq tiene que ser igual
			
	SET @FA_SUMA_TOTAL_DEBITOS = RIGHT(concat(replicate(''0'', 12), (replace(@TotalesDebitos, ''.'', ''''))), 12);
			
	SET @FA_SUMA_TOTAL_CREDITOS = RIGHT(concat(replicate(''0'', 12), (replace(@TotalesCreditos, ''.'', ''''))),12);
	
	SET @FA_FIN_ARCHIVO = concat(@FA_ID_REG, @FA_CANT_LOTES, @FA_NUMERO_BLOQUES, @FA_CANT_REG_INDIVIDUAL_ADICIONAL, @FA_TOTALES_DE_CONTROL, @FA_SUMA_TOTAL_DEBITOS, @FA_SUMA_TOTAL_CREDITOS, @FA_RESERVADO);
			
	
	
	INSERT INTO dbo.ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX (LINEA) VALUES (@FA_FIN_ARCHIVO);
	
				
	SET @FL_NUMERO_LOTE = CAST(@FL_NUMERO_LOTE AS NUMERIC) + 1;
	SET @FL_NUMERO_LOTE = RIGHT(concat(replicate(''0'', 7), @FL_NUMERO_LOTE), 7);
	------------------------------------------------------------------------------------------------------------------------------------------------------------------
END
END

')

EXECUTE('

DELETE FROM dbo.ITF_MASTER
WHERE ID = 100

INSERT INTO dbo.ITF_MASTER (TZ_LOCK, ID, DESCRIPCION, OBJ_KETTLE, P0_MODO, P0_TIPO, P0_CAPTION, P0_CONSTANTE, P1_MODO, P1_TIPO, P1_CAPTION, P1_CONSTANTE, P2_MODO, P2_TIPO, P2_CAPTION, P2_CONSTANTE, P3_MODO, P3_TIPO, P3_CAPTION, P3_CONSTANTE, P4_MODO, P4_TIPO, P4_CAPTION, P4_CONSTANTE, P5_MODO, P5_TIPO, P5_CAPTION, P5_CONSTANTE, P6_MODO, P6_TIPO, P6_CAPTION, P6_CONSTANTE, P7_MODO, P7_TIPO, P7_CAPTION, P7_CONSTANTE, P8_MODO, P8_TIPO, P8_CONSTANTE, P8_CAPTION, P9_MODO, P9_TIPO, P9_CAPTION, P9_CONSTANTE, TIPO_OBJ, COMENTARIO, ID_REPORTE, MODO_EJECUCION)
VALUES (0, 100, ''COELSA ENVIO DPF PROPIOS RECHAZADOS 2.8.5'', ''ITF_COELSA_DPF_PROPIOS_RECHAZADOS.kjb'', '''', '''', '''', '' '', '''', '''', '''', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', ''J'', '' '', 0, ''M'')

INSERT INTO dbo.ITF_MASTER_PARAMETROS (CODIGO, CODIGO_INTERFACE, FUNCIONALIDAD, ALFA_1, ALFA_2, ALFA_3, NUMERICO_1, NUMERICO_2, FECHA, IMPORTE_1, IMPORTE_2, TZ_LOCK)
VALUES (137, 11, ''Sec COELSA 2.8.5'', '' '', '' '', '' '', 1, 0, ''20281219'', 0, 0, 0)

INSERT INTO dbo.ITF_MASTER_PARAMETROS (CODIGO, CODIGO_INTERFACE, FUNCIONALIDAD, ALFA_1, ALFA_2, ALFA_3, NUMERICO_1, NUMERICO_2, FECHA, IMPORTE_1, IMPORTE_2, TZ_LOCK)
VALUES (155, 0, ''Cont Arch. COELSACRD'', '' '', '' '', '' '', 9, 0, ''20281219'', 0, 0, 0)
')