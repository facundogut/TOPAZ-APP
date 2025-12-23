EXECUTE('
DELETE FROM dbo.ITF_MASTER_PARAMETROS
WHERE CODIGO = 138

INSERT INTO dbo.ITF_MASTER_PARAMETROS (CODIGO, CODIGO_INTERFACE, FUNCIONALIDAD, ALFA_1, ALFA_2, ALFA_3, NUMERICO_1, NUMERICO_2, FECHA, IMPORTE_1, IMPORTE_2, TZ_LOCK)
VALUES (138, 11, ''Sec COELSA 2.8.1'', '' '', '' '', '' '', 171449, 0, ''20281219'', 0, 0, 0)
')

EXECUTE('
IF OBJECT_ID (''dbo.SP_COELSA_ENVIO_CHEQUES_PROPIOS_RECHAZADOS'') IS NOT NULL
	DROP PROCEDURE dbo.SP_COELSA_ENVIO_CHEQUES_PROPIOS_RECHAZADOS
')
EXECUTE('

CREATE PROCEDURE [dbo].[SP_COELSA_ENVIO_CHEQUES_PROPIOS_RECHAZADOS]
   @TICKET NUMERIC(16)
AS 
BEGIN
-- Limpieza de tabla auxiliar --
TRUNCATE TABLE dbo.ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX;


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
DECLARE @CA_NOMBRE_ORIG_INMEDIATO VARCHAR(23)=''NUEVO BCO CHACO S.A.   ''; -- fijo
DECLARE @CA_CODIGO_REFERENCIA VARCHAR(8) = ''CHQ.RECH''; --Se conforma con espacios vacíos.

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
DECLARE @CL_NUMERO_LOTE VARCHAR(7) = RIGHT(concat(replicate(''0'', 7), 0), 7); -- numero del lote

DECLARE @CL_CABECERA VARCHAR(200);

SET @CL_CABECERA = concat(@CL_ID_REG, @CL_CODIGO_CLASE_TRANSAC, @CL_RESERVADO, @CL_TIPO_REGISTRO, @CL_DESCRIP_TRANSAC, @CL_FECHA_PRESENTACION, @CL_FECHA_VENCIMIENTO, @CL_RESERVADO_CL, @CL_CODIGO_ORIGEN, @CL_ID_ENTIDAD_ORIGEN, @CL_NUMERO_LOTE);


		---------------- Grabar Cabecera Archivo ---------------------------
		INSERT INTO dbo.ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX (LINEA) VALUES (@CA_CABECERA);
		--------------------------------------------------------------------
		---------------- Grabar Cabecera Lote ---------------------------
		SET @CL_NUMERO_LOTE = RIGHT(concat(replicate(''0'', 7), (@CL_NUMERO_LOTE + 1)), 7); 
		SET @CL_CABECERA = concat(@CL_ID_REG, @CL_CODIGO_CLASE_TRANSAC, @CL_RESERVADO, @CL_TIPO_REGISTRO, @CL_DESCRIP_TRANSAC, @CL_FECHA_PRESENTACION, @CL_FECHA_VENCIMIENTO, @CL_RESERVADO_CL, @CL_CODIGO_ORIGEN, @CL_ID_ENTIDAD_ORIGEN, @CL_NUMERO_LOTE);
		INSERT INTO dbo.ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX (LINEA) VALUES (@CL_CABECERA);
		-----------------------------------------------------------------


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

DECLARE @SumaEntidad NUMERIC(10,0) = 0;
DECLARE @SumaSucursal NUMERIC(10,0) = 0;
DECLARE @SobranteSucursal NUMERIC(10,0) = 0;
DECLARE @Excedente NUMERIC(15,2) = 0;
DECLARE @CountExcedente INT = 0;

------------------------------------------
	
    --Condicion de reset del contador de reg individual
IF ISNULL((SELECT a.FECHA FROM ITF_MASTER_PARAMETROS a WHERE a.CODIGO = 136), CAST(''01-01-1800'' AS DATETIME)) <> (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK))
    UPDATE dbo.ITF_MASTER_PARAMETROS SET NUMERICO_1 = 1, FECHA = (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)) WHERE CODIGO = 136;
 


DECLARE cursor_che_rechazados CURSOR FOR

SELECT ID, FECHAPROCESO, CODIGO_TRANSACCION, ENTIDAD_DEBITAR, CUENTA_DEBITAR, IMPORTE, FECHA_PRESENTADO, CODIGO_POSTAL, FECHA_VENCIMIENTO, NRO_CHEQUE, PUNTO_INTERCAMBIO, TRACE_NUMBER, ESTADO, TIPO, COD_RECHAZO FROM ITF_COELSA_CHEQUES_RECHAZO WHERE TIPO IN (''C'', ''A'') AND ESTADO = ''P'' AND FECHAPROCESO = (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK));

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
-- Fin Variables Cursor --


OPEN cursor_che_rechazados
	  
FETCH NEXT FROM cursor_che_rechazados INTO @ID, @CheFechaProceso, @CheCodigoTransaccion, @CheEntidadDebitar, @CheCuentaDebitar, @CheImporte, @CheFechaPresentado, @CheCodigoPostal, @CheFechaVencimiento, @CheNroCheque, @ChePuntoIntercambio, @CheTraceNumber, @CheEstado, @CheTipo, @CheCodRechazo
	  
WHILE @@FETCH_STATUS = 0 
BEGIN
	IF (@SumaImportes > 9909999999 OR @SumaEntidad > 999000)-- 9999 millones
	BEGIN

		IF @SumaSucursal > 9999
		BEGIN
			SET @SobranteSucursal = CAST(substring(CAST(@SumaSucursal AS VARCHAR), 1, (len(@SumaSucursal) - 4)) AS NUMERIC);
			SET @SumaEntidad += @SobranteSucursal;
			SET @SumaSucursal = CAST(RIGHT(@SumaSucursal, 4) AS NUMERIC);
		END

	   	SET @TotalesControl += @SumaEntidad + @SumaSucursal;
	   	SET @FL_TOTALES_DE_CONTROL = concat((RIGHT(concat(replicate(''0'', 6), @SumaEntidad), 6)), (RIGHT(concat(replicate(''0'', 4), @SumaSucursal), 4)));
	   	SET @FL_SUMA_TOTAL_DEBITO_LOTE = RIGHT(concat(replicate(''0'', 12), (replace(@SumaImportes, ''.'', ''''))), 12); 
	   	SET @FL_SUMA_TOTAL_CREDITO_LOTE = RIGHT(replicate(''0'', 12), 12); 
	   	SET @TotalesDebitos += @SumaImportes;
	   	SET @FL_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 6), @Cant_Reg_Individual_Adicional), 6); 
	   	

	   	SET @FL_FIN_LOTE = concat(@FL_ID_REG, @FL_CODIGO_CLASE_TRANSAC, @FL_CANT_REG_INDIVIDUAL_ADICIONAL, @FL_TOTALES_DE_CONTROL, @FL_SUMA_TOTAL_DEBITO_LOTE, @FL_SUMA_TOTAL_CREDITO_LOTE, @FL_RESERVADO1, @FL_RESERVADO2, @FL_RESERVADO3, @FL_REG_ENTIDAD_ORIGEN, @FL_NUMERO_LOTE);
		
		
		INSERT INTO dbo.ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX (LINEA) VALUES (replace(@FL_FIN_LOTE, ''.'', ''''));
		

		-------------------------------------------------------------------
		-------------Grabamos el Fin de Archivo ----------------------------------------------------------------------------------------------------------------------
		SET @FA_CANT_LOTES = RIGHT(concat(replicate(''0'', 6), @FL_NUMERO_LOTE), 6);
		SET @CantRegistrosPrev = (SELECT (CASE WHEN (@CantRegistros + 4) % 10 = 0 THEN ((@CantRegistros + 4)/10) ELSE (FLOOR((@CantRegistros + 4)/10) + 1) END));
		SET @FA_NUMERO_BLOQUES = RIGHT(concat(replicate(''0'', 6), @CantRegistrosPrev ), 6);

		SET @FA_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 8), @CantRegistros), 8);
		
		SET @FA_TOTALES_DE_CONTROL =  @FL_TOTALES_DE_CONTROL;
		
		SET @FA_SUMA_TOTAL_DEBITOS = RIGHT(concat(replicate(''0'', 12), (replace(@TotalesDebitos, ''.'', ''''))), 12);
		
		SET @FA_SUMA_TOTAL_CREDITOS = RIGHT(concat(replicate(''0'', 12), (replace(@TotalesCreditos, ''.'', ''''))),12);

		SET @FA_FIN_ARCHIVO = concat(@FA_ID_REG, @FA_CANT_LOTES, @FA_NUMERO_BLOQUES, @FA_CANT_REG_INDIVIDUAL_ADICIONAL, @FA_TOTALES_DE_CONTROL, @FA_SUMA_TOTAL_DEBITOS, @FA_SUMA_TOTAL_CREDITOS, @FA_RESERVADO);
		
		INSERT INTO dbo.ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX (LINEA) VALUES (@FA_FIN_ARCHIVO);
		
		SET @FL_NUMERO_LOTE = CAST(@FL_NUMERO_LOTE AS NUMERIC) + 1;
		SET @FL_NUMERO_LOTE = RIGHT(concat(replicate(''0'', 7), @FL_NUMERO_LOTE), 7);
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
		SET @CL_NUMERO_LOTE = RIGHT(concat(replicate(''0'', 7), (@CL_NUMERO_LOTE + 1)), 7);   
		SET @CL_CABECERA = concat(@CL_ID_REG, @CL_CODIGO_CLASE_TRANSAC, @CL_RESERVADO, @CL_TIPO_REGISTRO, @CL_DESCRIP_TRANSAC, @CL_FECHA_PRESENTACION, @CL_FECHA_VENCIMIENTO, @CL_RESERVADO_CL, @CL_CODIGO_ORIGEN, @CL_ID_ENTIDAD_ORIGEN, @CL_NUMERO_LOTE);
		INSERT INTO dbo.ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX (LINEA) VALUES (@CL_CABECERA);
		---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		
	END
 --@ID, @CheFechaProceso, @CheCodigoTransaccion, @CheEntidadDebitar, @CheCuentaDebitar, @CheImporte, @CheFechaPresentado, @CheCodigoPostal, @CheFechaVencimiento, @CheNroCheque, @ChePuntoIntercambio, @CheTraceNumber, @CheEstado, @CheTipo, @CheCodRechazo
	SET @CheEntidadDebitarV = RIGHT(concat(replicate(''0'', 8), @CheEntidadDebitar), 8);
	SET @CantRegistros += 1;
	
	SET @Cant_Reg_Individual_Adicional += 1;
	
	
	IF	(@Excedente<>0)
		BEGIN
		SET @CheImporte = @Excedente;
		SET @CountExcedente += 1;
		END
	IF	(@CheImporte>90000000)
		BEGIN
		SET @Excedente = (@CheImporte - 90000000);
		SET @CheImporte = 90000000;
		SET @CountExcedente += 1;
		END
	ELSE
    BEGIN
       SET @Excedente = 0;
    END
		
	
	IF(@CountExcedente>1)
	BEGIN
        SET @SumaSucursal += 0888; --sumo la sucursal que hay que harcodear
        SET @SumaEntidad += LEFT(@CheEntidadDebitarV,4);
        SET @SumaImportes += @CheImporte;
		
        SET @RI_ENTIDAD_DEBITAR = concat(RIGHT(concat(replicate(''0'', 4), LEFT(@CheEntidadDebitarV,4)), 4), ''0888'');
        SET @RI_CUENTA_DEBITAR = RIGHT(concat(replicate(''0'', 17), ''88888888888''), 17);
        SET @RI_NUMERO_CHEQUE = ''000088888888888'';  --ACA SE SETEAN LOS 8


	END
    ELSE --la razon de este else, es que SumaSucursal, cuando hay excedente tiene que acumular 0888
    BEGIN
        SET @SumaSucursal += RIGHT(@CheEntidadDebitarV,4); 
        SET @SumaEntidad += LEFT(@CheEntidadDebitarV,4);
        SET @SumaImportes += @CheImporte;

        SET @RI_ENTIDAD_DEBITAR = RIGHT(concat(replicate(''0'', 8), @CheEntidadDebitar), 8);
		
        SET @RI_CUENTA_DEBITAR = RIGHT(concat(replicate(''0'', 17), @CheCuentaDebitar), 17);
	
        SET @RI_NUMERO_CHEQUE = concat(''00'', RIGHT(concat(replicate(''0'', 13), @CheNroCheque), 13));

    END

	
	SET @RI_IMPORTE = RIGHT(concat(replicate(''0'', 10), replace(CAST(@CheImporte AS VARCHAR),''.'','''')), 10);
			
	SET @RI_CODIGO_POSTAL =  concat(''00'', RIGHT(concat(replicate(''0'', 4), @CheCodigoPostal), 4));
		
	SET @RI_INFO_ADICIONAL = ''00'';
		
	SET @RI_REGISTRO_ADICIONAL = ''0'';
	   	
	SET @RI_CONTADOR_REGISTRO = concat(''0311'', RIGHT(concat(replicate(''0'', 4), (''0097'')), 4),RIGHT(concat(replicate(''0'', 7), (SELECT NUMERICO_1 FROM ITF_MASTER_PARAMETROS WHERE CODIGO = 138)), 7));
	
	SET @RI_REGISTRO_INDIVIDUAL = concat(@RI_ID_REG, @RI_CODIGO_TRANSAC, @RI_ENTIDAD_DEBITAR, @RI_RESERVADO, @RI_CUENTA_DEBITAR, @RI_IMPORTE, @RI_NUMERO_CHEQUE, @RI_CODIGO_POSTAL, @RI_PUNTO_INTERCAMBIO, @RI_INFO_ADICIONAL, @RI_REGISTRO_ADICIONAL, @RI_CONTADOR_REGISTRO);
		

	
	INSERT INTO dbo.ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX (LINEA) VALUES (replace(@RI_REGISTRO_INDIVIDUAL, ''.'', ''''));
		
	---------------------------- Actualizar contador unico ----------------------------------------
    UPDATE dbo.ITF_MASTER_PARAMETROS SET NUMERICO_1 = (NUMERICO_1 + 1) WHERE CODIGO = 138;
    ------------------------------------------------------------------------------------------------
    /*---------- Grabar historial ----------------------------------------------------------------------------------------------------------------------------------------------------------------------
    INSERT INTO ITF_COELSA_CHEQUES_OTROS (ID_TICKET, ID_PROCESO, FECHAPROCESO, CODIGO_TRANSACCION, BANCO, SUCURSAL, CUENTA, IMPORTE, CODIGO_POSTAL, FECHA_PRESENTADO, FECHA_VENCIMIENTO, NRO_CHEQUE, PUNTO_INTERCAMBIO, TRACE_NUMBER, ESTADO, TIPO, MONEDA, TIPO_DOCUMENTO, SERIE_DEL_CHEQUE)
    VALUES (@TICKET, @TICKET, (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)), @RI_CODIGO_TRANSAC, @T_COD_BANCO, @T_SUCURSAL, @T_NUMERO_CUENTA_GIRADORA, @T_IMPORTE, @RI_CODIGO_POSTAL, @T_FECHA_DEL_CHEQUE, @T_FECHA_VALOR, @T_NUMERO_DEL_CHEQUE, @RI_PUNTO_INTERCAMBIO, @RI_CONTADOR_REGISTRO, ''P'', ''C'', @T_MONEDA, @T_TIPO_DOCUMENTO, @T_SERIE_DEL_CHEQUE);
    -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	*/
IF (@Excedente = 0)
BEGIN		     	       				
FETCH NEXT FROM cursor_che_rechazados INTO @ID, @CheFechaProceso, @CheCodigoTransaccion, @CheEntidadDebitar, @CheCuentaDebitar, @CheImporte, @CheFechaPresentado, @CheCodigoPostal, @CheFechaVencimiento, @CheNroCheque, @ChePuntoIntercambio, @CheTraceNumber, @CheEstado, @CheTipo, @CheCodRechazo
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
		


SET @FL_TOTALES_DE_CONTROL = concat(right(concat(replicate(''0'', 6), @SumaEntidad), 6), right(concat(replicate(''0'', 4),@SumaSucursal), 4)); --relleno y separo con ceros



--SET @TotalesControl += CAST(@FL_TOTALES_DE_CONTROL AS INTEGER);
SET @FL_SUMA_TOTAL_DEBITO_LOTE = RIGHT(concat(replicate(''0'', 12), (replace(@SumaImportes, ''.'', ''''))), 12); 
SET @FL_SUMA_TOTAL_CREDITO_LOTE = RIGHT(replicate(''0'', 12), 12);
--SET @TotalesDebitos += @SumaImportes;
SET @FL_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 6), @Cant_Reg_Individual_Adicional), 6); 

	   	
SET @FL_FIN_LOTE = concat(@FL_ID_REG, @FL_CODIGO_CLASE_TRANSAC, @FL_CANT_REG_INDIVIDUAL_ADICIONAL, @FL_TOTALES_DE_CONTROL, @FL_SUMA_TOTAL_DEBITO_LOTE, @FL_SUMA_TOTAL_CREDITO_LOTE, @FL_RESERVADO1, @FL_RESERVADO2, @FL_RESERVADO3, @FL_REG_ENTIDAD_ORIGEN, @FL_NUMERO_LOTE);

---- Grabamos FIN de lote solo si hay registros individuales ingresados
IF(0<(SELECT COUNT(*) FROM ITF_COELSA_CHEQUES_RECHAZO WHERE TIPO IN (''C'', ''A'') AND ESTADO = ''P'' AND FECHAPROCESO = (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK))))
	BEGIN		
		
		INSERT INTO dbo.ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX (LINEA) VALUES (replace(@FL_FIN_LOTE, ''.'', ''''));
		
	END
		
IF(0<(SELECT COUNT(*) FROM CLE_CHEQUES_CLEARING_DEVUELTOS CD, CLE_CHEQUES_CLEARING CC,CLE_CHEQUES_CLEARING_RECIBIDO CR WHERE CD.NROCHEQUE = CC.NUMERO_CHEQUE AND CC.NUMERO_CHEQUE = CR.NUMERO_CHEQUE AND CR.CANJE_INTERNO IN (''N'', NULL) AND CD.FECHACHEQUE = (SELECT FECHAPROCESO FROM PARAMETROS) AND CD.TZ_LOCK = 0 AND CC.TZ_LOCK = 0 AND CR.TZ_LOCK = 0))
	BEGIN		
		
		---------------- Grabar Cabecera Lote ---------------------------
		SET @CL_NUMERO_LOTE = RIGHT(concat(replicate(''0'', 7), (@CL_NUMERO_LOTE + 1)), 7); 
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
DECLARE @CheTraceNumberCD VARCHAR(15);
DECLARE @CheInfoAdicionalCD VARCHAR(2);
DECLARE @CheRegistrosAdicionalesCD VARCHAR(1);
-- Fin Variables Cursor --

DECLARE cursor_che_rechazados CURSOR FOR

SELECT concat(RIGHT(concat(replicate(''0'', 4), CD.CODBANCO), 4), RIGHT(concat(replicate(''0'',4), CD.SUCURSAL), 4)) AS EntidadDebitar,CD.CODBANCO, CD.SUCURSAL,  RIGHT(concat(replicate(''0'', 12), CD.CUENTA), 12) AS CuentaDebitar,

 CD.IMPORTE AS Importe,  CD.NROCHEQUE AS NroCheque,

concat(''00'', RIGHT(concat(replicate(''0'', 4), CD.CODBANCO), 4)) AS CodigoPostal, concat(''0000'', RIGHT(concat(''0000'', CR.CODIGO_CAUSAL_DEVOLUCION), 4), replicate('' '', 8)) AS PtoIntercambio,

concat(CASE WHEN CD.MONEDA = 1 THEN ''0'' ELSE ''1'' END, ''0'') AS InfoAdicional

FROM CLE_CHEQUES_CLEARING_DEVUELTOS CD, CLE_CHEQUES_CLEARING CC,CLE_CHEQUES_CLEARING_RECIBIDO CR 

WHERE CD.NROCHEQUE = CC.NUMERO_CHEQUE AND CC.NUMERO_CHEQUE = CR.NUMERO_CHEQUE AND CR.CANJE_INTERNO IN (''N'', NULL) AND CD.FECHACHEQUE = (SELECT FECHAPROCESO FROM PARAMETROS) AND CD.TZ_LOCK = 0 AND CC.TZ_LOCK = 0 AND CR.TZ_LOCK = 0;

OPEN cursor_che_rechazados
	  
FETCH NEXT FROM cursor_che_rechazados INTO @CheEntidadDebitarCD, @CheBancoCD, @CheSucursalCD, @CheCuentaDebitarCD, @CheImporteCD, @CheNroChequeCD, @CheCodigoPostalCD, @ChePuntoIntercambioCD, @CheInfoAdicionalCD
	  
WHILE @@FETCH_STATUS = 0 
BEGIN
	IF (@SumaImportes > 9909999999 OR @SumaEntidad > 999000) -- 9999 millones
	BEGIN
		
		IF @SumaSucursal > 9999
		BEGIN
			SET @SobranteSucursal = CAST(substring(CAST(@SumaSucursal AS VARCHAR), 1, (len(@SumaSucursal) - 4)) AS NUMERIC);
			SET @SumaEntidad += @SobranteSucursal;
			SET @SumaSucursal = CAST(RIGHT(@SumaSucursal, 4) AS NUMERIC);
		END

	   	SET @TotalesControl += @SumaEntidad + @SumaSucursal;
	   	SET @FL_TOTALES_DE_CONTROL = concat((RIGHT(concat(replicate(''0'', 6), @SumaEntidad), 6)), (RIGHT(concat(replicate(''0'', 4), @SumaSucursal), 4)));
	   	SET @FL_SUMA_TOTAL_DEBITO_LOTE = RIGHT(concat(replicate(''0'', 12), (replace(@SumaImportes, ''.'', ''''))), 12); 
	   	SET @FL_SUMA_TOTAL_CREDITO_LOTE = RIGHT(replicate(''0'', 12), 12); 
	   	SET @TotalesDebitos += @SumaImportes;
	   	SET @FL_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 6), @Cant_Reg_Individual_Adicional), 6); 
	   	

	   	SET @FL_FIN_LOTE = concat(@FL_ID_REG, @FL_CODIGO_CLASE_TRANSAC, @FL_CANT_REG_INDIVIDUAL_ADICIONAL, @FL_TOTALES_DE_CONTROL, @FL_SUMA_TOTAL_DEBITO_LOTE, @FL_SUMA_TOTAL_CREDITO_LOTE, @FL_RESERVADO1, @FL_RESERVADO2, @FL_RESERVADO3, @FL_REG_ENTIDAD_ORIGEN, @FL_NUMERO_LOTE);
		
		
		INSERT INTO dbo.ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX (LINEA) VALUES (replace(@FL_FIN_LOTE, ''.'', ''''));
		

		-------------------------------------------------------------------
		-------------Grabamos el Fin de Archivo ----------------------------------------------------------------------------------------------------------------------
		SET @FA_CANT_LOTES = RIGHT(concat(replicate(''0'', 6), @FL_NUMERO_LOTE), 6);
		SET @CantRegistrosPrev = (SELECT (CASE WHEN (@CantRegistros + 4) % 10 = 0 THEN ((@CantRegistros + 4)/10) ELSE (FLOOR((@CantRegistros + 4)/10) + 1) END));
		SET @FA_NUMERO_BLOQUES = RIGHT(concat(replicate(''0'', 6), @CantRegistrosPrev ), 6);

		SET @FA_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 8), @CantRegistros), 8);
		
		SET @FA_TOTALES_DE_CONTROL =  @FL_TOTALES_DE_CONTROL;
		
		SET @FA_SUMA_TOTAL_DEBITOS = RIGHT(concat(replicate(''0'', 12), (replace(@TotalesDebitos, ''.'', ''''))), 12);
		
		SET @FA_SUMA_TOTAL_CREDITOS = RIGHT(concat(replicate(''0'', 12), (replace(@TotalesCreditos, ''.'', ''''))),12);

		SET @FA_FIN_ARCHIVO = concat(@FA_ID_REG, @FA_CANT_LOTES, @FA_NUMERO_BLOQUES, @FA_CANT_REG_INDIVIDUAL_ADICIONAL, @FA_TOTALES_DE_CONTROL, @FA_SUMA_TOTAL_DEBITOS, @FA_SUMA_TOTAL_CREDITOS, @FA_RESERVADO);
		
		INSERT INTO dbo.ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX (LINEA) VALUES (@FA_FIN_ARCHIVO);
		
		SET @FL_NUMERO_LOTE = CAST(@FL_NUMERO_LOTE AS NUMERIC) + 1;
		SET @FL_NUMERO_LOTE = RIGHT(concat(replicate(''0'', 7), @FL_NUMERO_LOTE), 7);
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
		SET @CL_NUMERO_LOTE = RIGHT(concat(replicate(''0'', 7), (@CL_NUMERO_LOTE + 1)), 7);   
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
	IF	(@CheImporteCD>90000000)
		BEGIN
		SET @Excedente = (@CheImporteCD - 90000000);
		SET @CheImporteCD = 90000000;
		SET @CountExcedente += 1;
		END
	ELSE
    BEGIN
       SET @Excedente = 0;
    END
		
	
	IF(@CountExcedente>1)
	BEGIN
        SET @SumaSucursal += 0888; --sumo la sucursal que hay que harcodear
        SET @SumaEntidad += LEFT(@CheBancoCD,4);
        SET @SumaImportes += @CheImporteCD;
		
        SET @RI_ENTIDAD_DEBITAR = concat(RIGHT(concat(replicate(''0'', 4), LEFT(@CheBancoCD,4)), 4), ''0888'');
        SET @RI_CUENTA_DEBITAR = RIGHT(concat(replicate(''0'', 17), ''88888888888''), 17);
        SET @RI_NUMERO_CHEQUE = ''000088888888888'';  --ACA SE SETEAN LOS 8


	END
    ELSE --la razon de este else, es que SumaSucursal, cuando hay excedente tiene que acumular 0888
    BEGIN
        SET @SumaSucursal += RIGHT(concat(replicate(''0'', 4), @CheSucursalCD),4);
        SET @SumaEntidad += RIGHT(concat(replicate(''0'', 4), @CheBancoCD),4);
        SET @SumaImportes += @CheImporteCD;

        SET @RI_ENTIDAD_DEBITAR = @CheEntidadDebitarCD;
		
        SET @RI_CUENTA_DEBITAR = RIGHT(concat(replicate(''0'', 17), @CheCuentaDebitarCD), 17);
	
        SET @RI_NUMERO_CHEQUE = concat(''00'', RIGHT(concat(replicate(''0'', 13), @CheNroChequeCD), 13));


  
    END

    
    
	
	SET @RI_IMPORTE = RIGHT(concat(replicate(''0'', 10), replace(CAST(@CheImporteCD AS VARCHAR),''.'','''')), 10);
			
	SET @RI_CODIGO_POSTAL =  concat(''00'', RIGHT(concat(replicate(''0'', 4), @CheCodigoPostalCD), 4));
		
	SET @RI_INFO_ADICIONAL = ''00'';
		
	SET @RI_REGISTRO_ADICIONAL = ''0'';
	   	
	SET @RI_CONTADOR_REGISTRO = concat(''0311'', RIGHT(concat(replicate(''0'', 4), (''0097'')), 4),RIGHT(concat(replicate(''0'', 7), (SELECT NUMERICO_1 FROM ITF_MASTER_PARAMETROS WHERE CODIGO = 138)), 7));
	
	SET @RI_REGISTRO_INDIVIDUAL = concat(@RI_ID_REG, @RI_CODIGO_TRANSAC, @RI_ENTIDAD_DEBITAR, @RI_RESERVADO, @RI_CUENTA_DEBITAR, @RI_IMPORTE, @RI_NUMERO_CHEQUE, @RI_CODIGO_POSTAL, @RI_PUNTO_INTERCAMBIO, @RI_INFO_ADICIONAL, @RI_REGISTRO_ADICIONAL, @RI_CONTADOR_REGISTRO);
		

	
	INSERT INTO dbo.ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX (LINEA) VALUES (replace(@RI_REGISTRO_INDIVIDUAL, ''.'', ''''));
		
	---------------------------- Actualizar contador unico ----------------------------------------
    UPDATE dbo.ITF_MASTER_PARAMETROS SET NUMERICO_1 = (NUMERICO_1 + 1) WHERE CODIGO = 138;
    ------------------------------------------------------------------------------------------------
    /*---------- Grabar historial ----------------------------------------------------------------------------------------------------------------------------------------------------------------------
    INSERT INTO ITF_COELSA_CHEQUES_OTROS (ID_TICKET, ID_PROCESO, FECHAPROCESO, CODIGO_TRANSACCION, BANCO, SUCURSAL, CUENTA, IMPORTE, CODIGO_POSTAL, FECHA_PRESENTADO, FECHA_VENCIMIENTO, NRO_CHEQUE, PUNTO_INTERCAMBIO, TRACE_NUMBER, ESTADO, TIPO, MONEDA, TIPO_DOCUMENTO, SERIE_DEL_CHEQUE)
    VALUES (@TICKET, @TICKET, (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)), @RI_CODIGO_TRANSAC, @T_COD_BANCO, @T_SUCURSAL, @T_NUMERO_CUENTA_GIRADORA, @T_IMPORTE, @RI_CODIGO_POSTAL, @T_FECHA_DEL_CHEQUE, @T_FECHA_VALOR, @T_NUMERO_DEL_CHEQUE, @RI_PUNTO_INTERCAMBIO, @RI_CONTADOR_REGISTRO, ''P'', ''C'', @T_MONEDA, @T_TIPO_DOCUMENTO, @T_SERIE_DEL_CHEQUE);
    -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	*/
IF (@Excedente = 0)
BEGIN		     	       				
FETCH NEXT FROM cursor_che_rechazados INTO @CheEntidadDebitarCD, @CheBancoCD, @CheSucursalCD, @CheCuentaDebitarCD, @CheImporteCD, @CheNroChequeCD, @CheCodigoPostalCD, @ChePuntoIntercambioCD, @CheInfoAdicionalCD
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
		


SET @FL_TOTALES_DE_CONTROL = concat(right(concat(replicate(''0'', 6), @SumaEntidad), 6), right(concat(replicate(''0'', 4),@SumaSucursal), 4)); --relleno y separo con ceros



--SET @TotalesControl += CAST(@FL_TOTALES_DE_CONTROL AS INTEGER);
SET @FL_SUMA_TOTAL_DEBITO_LOTE = RIGHT(concat(replicate(''0'', 12), (replace(@SumaImportes, ''.'', ''''))), 12); 
SET @FL_SUMA_TOTAL_CREDITO_LOTE = RIGHT(replicate(''0'', 12), 12);
--SET @TotalesDebitos += @SumaImportes;
SET @FL_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 6), @Cant_Reg_Individual_Adicional), 6); 

	   	
SET @FL_FIN_LOTE = concat(@FL_ID_REG, @FL_CODIGO_CLASE_TRANSAC, @FL_CANT_REG_INDIVIDUAL_ADICIONAL, @FL_TOTALES_DE_CONTROL, @FL_SUMA_TOTAL_DEBITO_LOTE, @FL_SUMA_TOTAL_CREDITO_LOTE, @FL_RESERVADO1, @FL_RESERVADO2, @FL_RESERVADO3, @FL_REG_ENTIDAD_ORIGEN, @FL_NUMERO_LOTE);

---- Grabamos FIN de lote solo si hay registros individuales ingresados
IF(0<(SELECT COUNT(*) FROM CLE_CHEQUES_CLEARING_DEVUELTOS CD, CLE_CHEQUES_CLEARING CC,CLE_CHEQUES_CLEARING_RECIBIDO CR WHERE CD.NROCHEQUE = CC.NUMERO_CHEQUE AND CC.NUMERO_CHEQUE = CR.NUMERO_CHEQUE AND CR.CANJE_INTERNO IN (''N'', NULL) AND CD.FECHACHEQUE = (SELECT FECHAPROCESO FROM PARAMETROS) AND CD.TZ_LOCK = 0 AND CC.TZ_LOCK = 0 AND CR.TZ_LOCK = 0))
	BEGIN		
		
		INSERT INTO dbo.ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX (LINEA) VALUES (replace(@FL_FIN_LOTE, ''.'', ''''));
		
	END
	
IF(0<(SELECT COUNT(*) FROM CLE_CHEQUES_AJUSTE WHERE ESTADO = ''F'' AND ENVIADO_RECIBIDO = ''R'' AND ESTADO_AJUSTE = ''R''))
	BEGIN		
		
		---------------- Grabar Cabecera Lote ---------------------------
		SET @CL_NUMERO_LOTE = RIGHT(concat(replicate(''0'', 7), (@CL_NUMERO_LOTE + 1)), 7); 
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
-----------------------------------

-- Cursor de ajustes cheques --
DECLARE cursor_che_rechazados CURSOR FOR

SELECT NUMERO_CHEQUE, IMPORTE, BANCO, SUCURSAL_BANCO_GIRADO, CODIGO_POSTAL FROM CLE_CHEQUES_AJUSTE WHERE ESTADO = ''F'' AND ENVIADO_RECIBIDO = ''R'' AND ESTADO_AJUSTE = ''R'';

OPEN cursor_che_rechazados

FETCH NEXT FROM cursor_che_rechazados INTO @CheNroChequeAJ, @CheImporteAJ, @CheBancoAJ, @CheSucursalAJ, @ChePostalAJ

WHILE @@FETCH_STATUS = 0 
BEGIN
	IF (@SumaImportes > 9909999999 OR @SumaEntidad > 999000) -- 9999 millones
	BEGIN
		
		IF @SumaSucursal > 9999
		BEGIN
			SET @SobranteSucursal = CAST(substring(CAST(@SumaSucursal AS VARCHAR), 1, (len(@SumaSucursal) - 4)) AS NUMERIC);
			SET @SumaEntidad += @SobranteSucursal;
			SET @SumaSucursal = CAST(RIGHT(@SumaSucursal, 4) AS NUMERIC);
		END

	   	SET @TotalesControl += @SumaEntidad + @SumaSucursal;
	   	SET @FL_TOTALES_DE_CONTROL = concat((RIGHT(concat(replicate(''0'', 6), @SumaEntidad), 6)), (RIGHT(concat(replicate(''0'', 4), @SumaSucursal), 4)));
	   	SET @FL_SUMA_TOTAL_DEBITO_LOTE = RIGHT(concat(replicate(''0'', 12), (replace(@SumaImportes, ''.'', ''''))), 12); 
	   	SET @FL_SUMA_TOTAL_CREDITO_LOTE = RIGHT(replicate(''0'', 12), 12); 
	   	SET @TotalesDebitos += @SumaImportes;
	   	SET @FL_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 6), @Cant_Reg_Individual_Adicional), 6); 
	   	

	   	SET @FL_FIN_LOTE = concat(@FL_ID_REG, @FL_CODIGO_CLASE_TRANSAC, @FL_CANT_REG_INDIVIDUAL_ADICIONAL, @FL_TOTALES_DE_CONTROL, @FL_SUMA_TOTAL_DEBITO_LOTE, @FL_SUMA_TOTAL_CREDITO_LOTE, @FL_RESERVADO1, @FL_RESERVADO2, @FL_RESERVADO3, @FL_REG_ENTIDAD_ORIGEN, @FL_NUMERO_LOTE);
		
		
		INSERT INTO dbo.ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX (LINEA) VALUES (replace(@FL_FIN_LOTE, ''.'', ''''));
		

		-------------------------------------------------------------------
		-------------Grabamos el Fin de Archivo ----------------------------------------------------------------------------------------------------------------------
		SET @FA_CANT_LOTES = RIGHT(concat(replicate(''0'', 6), @FL_NUMERO_LOTE), 6);
		SET @CantRegistrosPrev = (SELECT (CASE WHEN (@CantRegistros + 4) % 10 = 0 THEN ((@CantRegistros + 4)/10) ELSE (FLOOR((@CantRegistros + 4)/10) + 1) END));
		SET @FA_NUMERO_BLOQUES = RIGHT(concat(replicate(''0'', 6), @CantRegistrosPrev ), 6);

		SET @FA_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 8), @CantRegistros), 8);
		
		SET @FA_TOTALES_DE_CONTROL =  @FL_TOTALES_DE_CONTROL;
		
		SET @FA_SUMA_TOTAL_DEBITOS = RIGHT(concat(replicate(''0'', 12), (replace(@TotalesDebitos, ''.'', ''''))), 12);
		
		SET @FA_SUMA_TOTAL_CREDITOS = RIGHT(concat(replicate(''0'', 12), (replace(@TotalesCreditos, ''.'', ''''))),12);

		SET @FA_FIN_ARCHIVO = concat(@FA_ID_REG, @FA_CANT_LOTES, @FA_NUMERO_BLOQUES, @FA_CANT_REG_INDIVIDUAL_ADICIONAL, @FA_TOTALES_DE_CONTROL, @FA_SUMA_TOTAL_DEBITOS, @FA_SUMA_TOTAL_CREDITOS, @FA_RESERVADO);
		
		INSERT INTO dbo.ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX (LINEA) VALUES (@FA_FIN_ARCHIVO);
		
		SET @FL_NUMERO_LOTE = CAST(@FL_NUMERO_LOTE AS NUMERIC) + 1;
		SET @FL_NUMERO_LOTE = RIGHT(concat(replicate(''0'', 7), @FL_NUMERO_LOTE), 7);
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
		SET @CL_NUMERO_LOTE = RIGHT(concat(replicate(''0'', 7), (@CL_NUMERO_LOTE + 1)), 7);   
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
	IF	(@CheImporteAJ>90000000)
		BEGIN
		SET @Excedente = (@CheImporteAJ - 90000000);
		SET @CheImporteAJ = 90000000;
		SET @CountExcedente += 1;
		END
	ELSE
    BEGIN
       SET @Excedente = 0;
    END
		
	
	
        SET @SumaSucursal += 0888; --sumo la sucursal que hay que harcodear
        SET @SumaEntidad += LEFT(@CheBancoAJ,4);
        SET @SumaImportes += @CheImporteAJ;
		
        SET @RI_ENTIDAD_DEBITAR = concat(RIGHT(concat(replicate(''0'', 4), LEFT(@CheBancoAJ,4)), 4), ''0888'');
        SET @RI_CUENTA_DEBITAR = RIGHT(concat(replicate(''0'', 17), ''88888888888''), 17);
        SET @RI_NUMERO_CHEQUE = ''000088888888888'';  --ACA SE SETEAN LOS 8


	
	SET @RI_IMPORTE = RIGHT(concat(replicate(''0'', 10), replace(CAST(@CheImporteAJ AS VARCHAR),''.'','''')), 10);
			
	SET @RI_CODIGO_POSTAL =  concat(''00'', RIGHT(concat(replicate(''0'', 4), @ChePostalAJ), 4));
		
	SET @RI_INFO_ADICIONAL = ''00'';
		
	SET @RI_REGISTRO_ADICIONAL = ''0'';
	   	
	SET @RI_CONTADOR_REGISTRO = concat(''0311'', RIGHT(concat(replicate(''0'', 4), (''0097'')), 4),RIGHT(concat(replicate(''0'', 7), (SELECT NUMERICO_1 FROM ITF_MASTER_PARAMETROS WHERE CODIGO = 138)), 7));
	
	SET @RI_REGISTRO_INDIVIDUAL = concat(@RI_ID_REG, @RI_CODIGO_TRANSAC, @RI_ENTIDAD_DEBITAR, @RI_RESERVADO, @RI_CUENTA_DEBITAR, @RI_IMPORTE, @RI_NUMERO_CHEQUE, @RI_CODIGO_POSTAL, @RI_PUNTO_INTERCAMBIO, @RI_INFO_ADICIONAL, @RI_REGISTRO_ADICIONAL, @RI_CONTADOR_REGISTRO);
		

	
	INSERT INTO dbo.ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX (LINEA) VALUES (replace(@RI_REGISTRO_INDIVIDUAL, ''.'', ''''));
		
	---------------------------- Actualizar contador unico ----------------------------------------
    UPDATE dbo.ITF_MASTER_PARAMETROS SET NUMERICO_1 = (NUMERICO_1 + 1) WHERE CODIGO = 138;
    ------------------------------------------------------------------------------------------------
    /*---------- Grabar historial ----------------------------------------------------------------------------------------------------------------------------------------------------------------------
    INSERT INTO ITF_COELSA_CHEQUES_OTROS (ID_TICKET, ID_PROCESO, FECHAPROCESO, CODIGO_TRANSACCION, BANCO, SUCURSAL, CUENTA, IMPORTE, CODIGO_POSTAL, FECHA_PRESENTADO, FECHA_VENCIMIENTO, NRO_CHEQUE, PUNTO_INTERCAMBIO, TRACE_NUMBER, ESTADO, TIPO, MONEDA, TIPO_DOCUMENTO, SERIE_DEL_CHEQUE)
    VALUES (@TICKET, @TICKET, (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)), @RI_CODIGO_TRANSAC, @T_COD_BANCO, @T_SUCURSAL, @T_NUMERO_CUENTA_GIRADORA, @T_IMPORTE, @RI_CODIGO_POSTAL, @T_FECHA_DEL_CHEQUE, @T_FECHA_VALOR, @T_NUMERO_DEL_CHEQUE, @RI_PUNTO_INTERCAMBIO, @RI_CONTADOR_REGISTRO, ''P'', ''C'', @T_MONEDA, @T_TIPO_DOCUMENTO, @T_SERIE_DEL_CHEQUE);
    -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	*/
IF (@Excedente = 0)
BEGIN		     	       				
FETCH NEXT FROM cursor_che_rechazados INTO @CheNroChequeAJ, @CheImporteAJ, @CheBancoAJ, @CheSucursalAJ, @ChePostalAJ
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
IF(0<(SELECT COUNT(*) FROM ITF_COELSA_CHEQUES_RECHAZO WHERE ESTADO = ''P'' AND TIPO = ''D'' AND SUBSTRING(INFO_ADICIONAL, 1, 1) = @MONEDA  AND FECHAPROCESO = (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK))))
BEGIN
		  */	
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

')