
EXECUTE('
CREATE OR ALTER  PROCEDURE [dbo].[SP_ITF_COELSA_DPF_TERCEROS_PRESENTADOS_ENVIADOS]
@TICKET NUMERIC(16)
AS

BEGIN

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- Modified : 09/09/2022.
--- Autor: Juan Pedrozo 
--- Se ajusta el sp en base a formato NACHA y nuevo diseños de campos
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- Modified : 04/10/2021 10:00 a.m.
--- Autor: Luis Etchebarne 
--- Se ajusta el sp para controlar los maximos por lote y archivo.
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- Modified : 28/09/2021 10:00 a.m.
--- Autor: Luis Etchebarne 
--- Se ajusta el sp agregando el parametro ticket para poder grabar la traza de la tabla ITF_COELSA_CHEQUES_OTROS.
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- Modified : 20/09/2021 10:00 a.m.
--- Autor: Luis Etchebarne 
--- Se ajusta el sp con el fin de generar el tracknumber y grabar campos necesarios en las tablas de clearing.
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- Created : 13/09/2021 10:00 a.m.
--- Autor: Luis Etchebarne 
--- Se crea el sp con el fin de generar la información de los dpf en dólares de terceros presentados a informar a COELSA.
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Limpiar Tabla auxiliar ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
TRUNCATE TABLE ITF_DPFD_SALIDA_AUX;
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Variables Cabecera Archivo ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DECLARE @CA_ID_REG VARCHAR(1) = ''1'';
DECLARE @CA_CODIGO_PRIORIDAD VARCHAR(2) = ''01'';
DECLARE @CA_DESTINO_INMEDIATO VARCHAR(10) = '' 000000010''; --borre espacios y cambie el largo (preguntar) 
DECLARE @CA_ORIGEN_INMEDIATO VARCHAR(10) = '' 031100970''; 
DECLARE @CA_FECHA_PRESENTACION VARCHAR(6) = convert(VARCHAR,(SELECT FECHAPROCESO FROM PARAMETROS WITH (NOLOCK)), 12); 
DECLARE @CA_HORA_PRESENTACION VARCHAR(4) = concat(SUBSTRING((SELECT CONVERT (VARCHAR(8), SYSDATETIME(),24)),1,2), SUBSTRING((SELECT CONVERT (VARCHAR(8), SYSDATETIME(),24)),4,2));
DECLARE @CA_IDENTIFICADOR_ARCHIVO VARCHAR(1) = ''1''; 
DECLARE @CA_TAMANNO_REGISTRO VARCHAR(3) = ''094'';
DECLARE @CA_FACTOR_BLOQUE VARCHAR(2) = ''10'';
DECLARE @CA_CODIGO_FORMATO VARCHAR(1) = ''1'';
DECLARE @CA_NOMBRE_DEST_INMEDIATO VARCHAR(23) = concat(''COELSA'',replicate('' '', 17));  -- completo con espacios a la derecha
DECLARE @CA_NOMBRE_ORIG_INMEDIATO VARCHAR(23) = ''NUEVO BANCO DEL CHACO S''; 
DECLARE @CA_CODIGO_REFERENCIA VARCHAR(8) = replicate('' '', 8);  
DECLARE @CA_CABECERA VARCHAR(200);

SET @CA_CABECERA = concat(@CA_ID_REG, @CA_CODIGO_PRIORIDAD, @CA_DESTINO_INMEDIATO, @CA_ORIGEN_INMEDIATO, @CA_FECHA_PRESENTACION, @CA_HORA_PRESENTACION, @CA_IDENTIFICADOR_ARCHIVO, @CA_TAMANNO_REGISTRO, @CA_FACTOR_BLOQUE, @CA_CODIGO_FORMATO, @CA_NOMBRE_DEST_INMEDIATO, @CA_NOMBRE_ORIG_INMEDIATO, @CA_CODIGO_REFERENCIA);
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Variables Cabecera Lote ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DECLARE @CL_ID_REG VARCHAR(1) = ''5''; 
DECLARE @CL_CODIGO_CLASE_TRANSAC VARCHAR(3) = ''200''; 
DECLARE @CL_RESERVADO VARCHAR(46) = replicate('' '', 46);  
DECLARE @CL_TIPO_REGISTRO VARCHAR(3) = ''TRC''; 
DECLARE @CL_DESCRIP_TRANSAC VARCHAR(10) = ''CHEQUESPRE'' ; 
DECLARE @CL_FECHA_PRESENTACION VARCHAR(6) = convert(VARCHAR,(SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)), 12);
DECLARE @CL_FECHA_VENCIMIENTO VARCHAR(6) = convert(VARCHAR, dbo.diaHabil(DATEADD(day,1,(SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK))),''A''), 12); 
DECLARE @CL_RESERVADO_CL VARCHAR(3) = ''000''; 
DECLARE @CL_CODIGO_ORIGEN VARCHAR(1) = ''1''; 
DECLARE @CL_ID_ENTIDAD_ORIGEN VARCHAR(8) = ''03110097''; 
DECLARE @CL_NUMERO_LOTE VARCHAR(7) = ''0000001'';
DECLARE @CL_CABECERA VARCHAR(200);


SET @CL_CABECERA = concat(@CL_ID_REG, @CL_CODIGO_CLASE_TRANSAC, @CL_RESERVADO, @CL_TIPO_REGISTRO, @CL_DESCRIP_TRANSAC, @CL_FECHA_PRESENTACION, @CL_FECHA_VENCIMIENTO, @CL_RESERVADO_CL, @CL_CODIGO_ORIGEN, @CL_ID_ENTIDAD_ORIGEN, @CL_NUMERO_LOTE);
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


--- Grabamos la cabecera del archivo ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
INSERT INTO ITF_DPFD_SALIDA_AUX (LINEA) VALUES (@CA_CABECERA);
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Grabar la cabecera de lote ---------------------------------------------------------------------------------------------------------------------------------------------------------------
INSERT INTO ITF_DPFD_SALIDA_AUX (LINEA) VALUES (@CL_CABECERA);
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


--- Variables Registro Individual -------------------------------------------------------------------------------------------------------------------------------------------------------------
DECLARE @RI_ID_REG VARCHAR(1) = ''6'';  
DECLARE @RI_CODIGO_TRANSAC VARCHAR(2) = ''27'';
DECLARE @RI_ENTIDAD_DEBITAR VARCHAR(8);
DECLARE @RI_RESERVADO VARCHAR(1) = ''0'';
DECLARE @RI_CUENTA_DEBITAR VARCHAR(17); 
DECLARE @RI_IMPORTE VARCHAR(20);  --LARGO 25 CONTEMPLANDO PUNTOS AL MOMENTO DE CASTEAR NUMERIC A VARCHAR
DECLARE @RI_NUMERO_CHEQUE VARCHAR(15);
DECLARE @RI_CODIGO_POSTAL VARCHAR(6); 
DECLARE @RI_PUNTO_INTERCAMBIO VARCHAR(16) = ''0000            '';
DECLARE @RI_INFO_ADICIONAL VARCHAR(2);
DECLARE @RI_REGISTRO_ADICIONAL VARCHAR(1) = ''0''; 
DECLARE @RI_CONTADOR_REGISTRO VARCHAR(15);


DECLARE @RI_REGISTRO_INDIVIDUAL VARCHAR (200);
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Variables Fin de Lote ---------------------------------------------------------------------------------------------------------------------------------------------------------------
DECLARE @FL_ID_REG VARCHAR(1) = ''8'';  
DECLARE @FL_CODIGO_CLASE_TRANSAC VARCHAR(3) = ''200''; 
DECLARE @FL_CANT_REG_INDIVIDUAL_ADICIONAL VARCHAR(6) = replicate(''0'',6); 
DECLARE @FL_TOTALES_DE_CONTROL VARCHAR(10) = replicate(''0'',10); 
DECLARE @FL_SUMA_TOTAL_DEBITO_LOTE VARCHAR(12); --cambio el largo a 12
DECLARE @FL_SUMA_TOTAL_CREDITO_LOTE VARCHAR(12); --cambio el largo a 12
DECLARE @FL_RESERVADO1 VARCHAR(10) = replicate('' '', 10);
DECLARE @FL_RESERVADO2 VARCHAR(19) = replicate('' '', 19); --cambio largo a 19
DECLARE @FL_RESERVADO3 VARCHAR(6) = replicate('' '', 6); --cambio largo a 6
DECLARE @FL_REG_ENTIDAD_ORIGEN VARCHAR(8) = ''03110030''; 
DECLARE @FL_NUMERO_LOTE VARCHAR(7) = ''0000001'';

DECLARE @FL_FIN_LOTE VARCHAR(200);
--------------------------------------------------------------------------------------------------------------------------------------------- 		
--- Variables Fin de Archivo ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DECLARE @FA_ID_REG VARCHAR(1) = ''9'';  
DECLARE @FA_CANT_LOTES VARCHAR(6);
DECLARE @FA_NUMERO_BLOQUES VARCHAR(6);
DECLARE @FA_CANT_REG_INDIVIDUAL_ADICIONAL VARCHAR(8);
DECLARE @FA_TOTALES_DE_CONTROL VARCHAR(10); 
DECLARE @FA_SUMA_TOTAL_DEBITOS VARCHAR(12);--cambio largo a 12
DECLARE @FA_SUMA_TOTAL_CREDITOS VARCHAR(12);
DECLARE @FA_RESERVADO  VARCHAR(39) = replicate('' '', 39);

DECLARE @FA_FIN_ARCHIVO VARCHAR(200);
-----------------------------------------------------------------------------------------------------------------------------------------------------
--- Grabar registro individual ---------------------------------------------------------------------------------------------------------------------------------------------------------------
DECLARE @DP_TIPO_DOCUMENTO VARCHAR(4); 
DECLARE @DP_MONEDA NUMERIC(4);
DECLARE @DP_NUMERO_DPF NUMERIC(12);
DECLARE @DP_BANCO NUMERIC(5);
DECLARE @DP_SUCURSAL NUMERIC(5);
DECLARE @DP_NUMERO_CUENTA NUMERIC(12);
DECLARE @DP_FECHA_ALTA DATETIME;
DECLARE @DP_IMPORTE NUMERIC(15,2);
DECLARE @DP_CODIGO_POSTAL NUMERIC(4);
DECLARE @DP_ORDINAL NUMERIC(12);
DECLARE @DP_NUMERO_CHEQUE NUMERIC(12);

------- Variables generales ------------
DECLARE @SumaImportes NUMERIC(15) = 0;
DECLARE @TotalesControl NUMERIC(10) = 0;
DECLARE @TotalesDebitos NUMERIC(15) = 0;
DECLARE @TotalesCreditos NUMERIC(15) = 0;
DECLARE @CantRegistros NUMERIC(15) = 0; 
DECLARE @CantRegistrosTotal NUMERIC(15) = 4; --seteo 4, cuento la cabecera de archivo, cabecera lote, fin de lote y el fin de archivo 

DECLARE @SumaEntidad NUMERIC = 0;
DECLARE @SumaSucursal NUMERIC = 0;
DECLARE @SobranteSucursal NUMERIC = 0;
DECLARE @Excedente NUMERIC(15,2) = 0;
DECLARE @CountExcedente INT = 0;
------------------------------------------  
DECLARE CursorDPFDolares CURSOR FOR

SELECT TIPO_DOCUMENTO, MONEDA, NUMERO_DPF, BANCO_GIRADO, SUCURSAL_BANCO_GIRADO, NUMERICO_CUENTA_GIRADORA, FECHA_ALTA, IMPORTE, COD_POSTAL 
FROM dbo.CLE_DPF_SALIENTE  
WHERE TZ_LOCK = 0 AND ESTADO = 1 AND MONEDA = 2 AND FECHA_ALTA = (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)) 
ORDER BY NUMERO_DPF 

OPEN CursorDPFDolares
        
FETCH NEXT FROM CursorDPFDolares INTO @DP_TIPO_DOCUMENTO, @DP_MONEDA, @DP_NUMERO_DPF, @DP_BANCO, @DP_SUCURSAL, @DP_NUMERO_CUENTA, @DP_FECHA_ALTA, @DP_IMPORTE, @DP_CODIGO_POSTAL
        
        
WHILE @@FETCH_STATUS = 0
BEGIN
	IF (@SumaImportes > 9909999999 OR @SumaEntidad > 999000)
	BEGIN
	
		IF @SumaSucursal > 9999
		BEGIN
			SET @SobranteSucursal = CAST(substring(CAST(@SumaSucursal AS VARCHAR), 1, (len(@SumaSucursal) - 4)) AS NUMERIC);
			SET @SumaEntidad += @SobranteSucursal;
			SET @SumaSucursal = CAST(RIGHT(@SumaSucursal, 4) AS NUMERIC);
		END
		
		SET @TotalesControl += @SumaEntidad + @SumaSucursal;
	   	SET @FL_TOTALES_DE_CONTROL = concat(right(concat(replicate(''0'', 6), @SumaEntidad), 6), right(concat(replicate(''0'', 4),@SumaSucursal), 4)); --relleno y separo con ceros
	   	SET @FL_SUMA_TOTAL_DEBITO_LOTE = RIGHT(concat(replicate(''0'',12),@SumaImportes), 12); 
	   	SET @FL_SUMA_TOTAL_CREDITO_LOTE = RIGHT(replicate(''0'', 12), 12);
	   	SET @TotalesDebitos += @SumaImportes
	   	
	   	SET @FL_FIN_LOTE = concat(@FL_ID_REG, @FL_CODIGO_CLASE_TRANSAC,RIGHT(CONCAT(REPLICATE(''0'',6),@FL_CANT_REG_INDIVIDUAL_ADICIONAL),6), @FL_TOTALES_DE_CONTROL, @FL_SUMA_TOTAL_DEBITO_LOTE, @FL_SUMA_TOTAL_CREDITO_LOTE, @FL_RESERVADO1, @FL_RESERVADO2, @FL_RESERVADO3, @FL_REG_ENTIDAD_ORIGEN, @FL_NUMERO_LOTE);
		
		
		INSERT INTO dbo.ITF_DPFD_SALIDA_AUX (LINEA) VALUES (replace(@FL_FIN_LOTE, ''.'', ''''));
		
		SET @FL_NUMERO_LOTE = RIGHT(CONCAT(REPLICATE(''0'',6), CAST(@FL_NUMERO_LOTE AS NUMERIC) + 1),7);
		-------------------------------------------------------------------
		-------------Grabamos el Fin de Archivo ----------------------------------------------------------------------------------------------------------------------
		SET @FA_CANT_LOTES = RIGHT(concat(replicate(''0'', 6), @FL_NUMERO_LOTE), 6);
        
        
     
		SET @FA_NUMERO_BLOQUES = RIGHT(concat(replicate(''0'', 6), (CASE WHEN (@CantRegistros + 4) % 10 = 0 THEN ((@CantRegistros + 4)/10) ELSE (FLOOR((@CantRegistros + 4)/10) + 1) END)), 6);

		SET @FA_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 8), @CantRegistros), 8);
		
		SET @FA_TOTALES_DE_CONTROL = RIGHT(concat(replicate(''0'', 10), @TotalesControl), 10);
		
		SET @FA_SUMA_TOTAL_DEBITOS = RIGHT(concat(replicate(''0'', 12), @TotalesDebitos), 12);
		
		SET @FA_SUMA_TOTAL_CREDITOS = RIGHT(concat(replicate(''0'', 12), @TotalesCreditos),12);

		SET @FA_FIN_ARCHIVO = concat(@FA_ID_REG, @FA_CANT_LOTES, @FA_NUMERO_BLOQUES, @FA_CANT_REG_INDIVIDUAL_ADICIONAL, @FA_TOTALES_DE_CONTROL, @FA_SUMA_TOTAL_DEBITOS, @FA_SUMA_TOTAL_CREDITOS, @FA_RESERVADO);


		INSERT INTO dbo.ITF_DPFD_SALIDA_AUX (LINEA) VALUES (@FA_FIN_ARCHIVO);
		------------------------------------------------------------------------------------------------------------------------------------------------------------------
		---------- Limpiamos variables -----------------------------------------------------------------------------------------------------------------------------------
		SET @SumaImportes = 0;
		SET @CantRegistros = 0; 
		SET @CantRegistrosTotal += 2; --le sumo 2, que corresponden a los registros CL y FL ya que en teoria se creo un nuevo lote

		SET @TotalesControl = 0;
		SET @TotalesDebitos = 0;
		SET @TotalesCreditos = 0;

		SET @SumaEntidad = 0;
		SET @SumaSucursal = 0;
		SET @FL_CANT_REG_INDIVIDUAL_ADICIONAL = 0;
		SET @FL_TOTALES_DE_CONTROL = 0;
		SET @FA_SUMA_TOTAL_DEBITOS = 0;
		SET @FA_SUMA_TOTAL_CREDITOS = 0;
		-------------------------------------------------------------------------------------------------------------------------------------------------------------------
		--------- Grabamos nueva Cabecera de Archivo ----------------------------------------------------------------------------------------------------------------------
	    SET @CA_CABECERA = concat(@CA_ID_REG, @CA_CODIGO_PRIORIDAD, @CA_DESTINO_INMEDIATO, @CA_ORIGEN_INMEDIATO, @CA_FECHA_PRESENTACION, @CA_HORA_PRESENTACION, @CA_IDENTIFICADOR_ARCHIVO, @CA_TAMANNO_REGISTRO, @CA_FACTOR_BLOQUE, @CA_CODIGO_FORMATO, @CA_NOMBRE_DEST_INMEDIATO, @CA_NOMBRE_ORIG_INMEDIATO, @CA_CODIGO_REFERENCIA);
		
		INSERT INTO dbo.ITF_DPFD_SALIDA_AUX (LINEA) VALUES (@CA_CABECERA);
		----------------------------------------------------------------------------------------------------------------------------------------------------------------------
		--------- Grabamos nueva Cabecera Lote ------------------------------------------------------------------------------------------------------------------------------------------------------
		SET @CL_NUMERO_LOTE += 1;
		SET @CL_CABECERA = concat(@CL_ID_REG, @CL_CODIGO_CLASE_TRANSAC, @CL_RESERVADO, @CL_TIPO_REGISTRO, @CL_DESCRIP_TRANSAC, @CL_FECHA_PRESENTACION, @CL_FECHA_VENCIMIENTO, @CL_RESERVADO_CL, @CL_CODIGO_ORIGEN, @CL_ID_ENTIDAD_ORIGEN, right(concat(replicate(''0'',7),@CL_NUMERO_LOTE),7));
		INSERT INTO dbo.ITF_DPFD_SALIDA_AUX (LINEA) VALUES (@CL_CABECERA);


		---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	END
	
	SET @CantRegistros += 1;
    SET @CantRegistrosTotal +=1;
	SET @FL_CANT_REG_INDIVIDUAL_ADICIONAL += 1;
		
	IF	(@Excedente<>0)
		BEGIN
		SET @DP_IMPORTE = @Excedente;
		SET @CountExcedente += 1;
		END
	IF	(@DP_IMPORTE > 90000000)
		BEGIN
		SET @Excedente = (@DP_IMPORTE - 90000000);
		SET @DP_IMPORTE = 90000000;
		SET @CountExcedente += 1;

		END
	ELSE
    BEGIN
       SET @Excedente = 0;
    END
	
	
	IF(@CountExcedente>1)
	BEGIN
        SET @SumaSucursal += 0888; --sumo la sucursal que hay que harcodear
        SET @SumaEntidad += @DP_BANCO;
        SET @SumaImportes += @DP_IMPORTE;

        SET @RI_ENTIDAD_DEBITAR = concat(RIGHT(concat(replicate(''0'', 4), @DP_BANCO), 4), ''0888'');
        SET @RI_CUENTA_DEBITAR = RIGHT(concat(replicate(''0'', 17), ''88888888888''), 17);
        SET @RI_NUMERO_CHEQUE = ''000088888888888'';  --ACA SE SETEAN LOS 8

	END
    ELSE --la razon de este else, es que SumaSucursal, cuando hay excedente tiene que acumular 0888
    BEGIN
		
		SET @SumaSucursal += @DP_SUCURSAL;
		SET @SumaEntidad += @DP_BANCO;
		SET @SumaImportes += @DP_IMPORTE;
		
		------ Registro Individual -------
		SET @RI_ENTIDAD_DEBITAR = concat(RIGHT(concat(replicate(''0'', 4), @DP_BANCO), 4), RIGHT(concat(replicate(''0'', 4), @DP_SUCURSAL), 4)); 
		SET @RI_CUENTA_DEBITAR = RIGHT(concat(replicate(''0'', 17), @DP_NUMERO_CUENTA), 17); 
		SET @RI_NUMERO_CHEQUE = RIGHT(concat(''00'', RIGHT(concat(replicate(''0'', 13), @DP_NUMERO_DPF), 13)), 15);
	END
	
	SET @RI_IMPORTE = RIGHT(concat(replicate(''0'', 10), replace(CAST(@DP_IMPORTE AS VARCHAR),''.'','''')), 10);
	
	SET @RI_CODIGO_POSTAL = RIGHT(concat(''00'', RIGHT(concat(replicate(''0'', 6), @DP_CODIGO_POSTAL), 4)), 6); 

	SET @RI_INFO_ADICIONAL = RIGHT(concat(replicate(''0'', 2), (CASE WHEN @DP_MONEDA = 1 THEN ''0'' ELSE ''1'' END) , ''0''), 2);

 	
    --Condicion de reset del contador de reg individual
 	IF ISNULL((SELECT a.FECHA FROM ITF_MASTER_PARAMETROS a WHERE a.CODIGO = 163), CAST(''01-01-1800'' AS DATETIME)) <> (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK))
  
	    UPDATE dbo.ITF_MASTER_PARAMETROS SET NUMERICO_1 = 1, FECHA = (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)) WHERE CODIGO = 163;
   
	SET @RI_CONTADOR_REGISTRO = concat(@RI_ENTIDAD_DEBITAR, RIGHT(concat(replicate(''0'', 7), (SELECT a.NUMERICO_1 FROM ITF_MASTER_PARAMETROS a WHERE CODIGO = 163)), 7)); 
		
    --Incremento el contador
    UPDATE dbo.ITF_MASTER_PARAMETROS SET NUMERICO_1 += 1 WHERE CODIGO = 163;

	
	SET @RI_REGISTRO_INDIVIDUAL = concat(@RI_ID_REG, @RI_CODIGO_TRANSAC, @RI_ENTIDAD_DEBITAR, @RI_RESERVADO, @RI_CUENTA_DEBITAR, @RI_IMPORTE, @RI_NUMERO_CHEQUE, @RI_CODIGO_POSTAL, @RI_PUNTO_INTERCAMBIO, @RI_INFO_ADICIONAL, @RI_REGISTRO_ADICIONAL, @RI_CONTADOR_REGISTRO);

	INSERT INTO ITF_DPFD_SALIDA_AUX (LINEA) VALUES (replace(@RI_REGISTRO_INDIVIDUAL, ''.'', ''''));
	
	--- Grabar historial -----------------------------------------------------------------------------
	INSERT INTO ITF_COELSA_CHEQUES_OTROS (ID_TICKET, ID_PROCESO, FECHAPROCESO, CODIGO_TRANSACCION, BANCO, SUCURSAL, CUENTA, IMPORTE, CODIGO_POSTAL, FECHA_PRESENTADO, FECHA_VENCIMIENTO, NRO_CHEQUE, PUNTO_INTERCAMBIO, TRACE_NUMBER, ESTADO, TIPO, MONEDA, TIPO_DOCUMENTO)
	VALUES (@TICKET, @TICKET, (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)), @RI_CODIGO_TRANSAC, @DP_BANCO, @DP_SUCURSAL, @DP_NUMERO_CUENTA, @DP_IMPORTE, @DP_CODIGO_POSTAL, @DP_FECHA_ALTA, @DP_FECHA_ALTA, @DP_NUMERO_DPF, @RI_PUNTO_INTERCAMBIO, @RI_CONTADOR_REGISTRO, ''P'', ''D'', @DP_MONEDA, @DP_TIPO_DOCUMENTO);
	-----------------------------------------------------------------------------------------------------


        	
	UPDATE dbo.CLE_DPF_SALIENTE SET TRACKNUMBER = @RI_CONTADOR_REGISTRO, ESTADO = 2, FECHA_ENVIO_COMPENSACION = (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK))
	WHERE TIPO_DOCUMENTO = @DP_TIPO_DOCUMENTO AND NUMERO_DPF = @DP_NUMERO_DPF AND BANCO_GIRADO = @DP_BANCO AND SUCURSAL_BANCO_GIRADO = @DP_SUCURSAL AND FECHA_ALTA = @DP_FECHA_ALTA AND MONEDA = @DP_MONEDA AND TZ_LOCK = 0 AND ESTADO = 1;

IF (@Excedente = 0)
BEGIN		     	

FETCH NEXT FROM CursorDPFDolares INTO @DP_TIPO_DOCUMENTO, @DP_MONEDA, @DP_NUMERO_DPF, @DP_BANCO, @DP_SUCURSAL, @DP_NUMERO_CUENTA, @DP_FECHA_ALTA, @DP_IMPORTE, @DP_CODIGO_POSTAL

SET @CountExcedente = 0;
END
	
END
        
CLOSE CursorDPFDolares
DEALLOCATE CursorDPFDolares

IF @SumaSucursal > 9999
BEGIN
	SET @SobranteSucursal = 0;
	SET @SobranteSucursal = CAST(substring(CAST(@SumaSucursal AS VARCHAR), 1, (len(@SumaSucursal) - 4)) AS NUMERIC);
	SET @SumaEntidad += @SobranteSucursal;
	SET @SumaSucursal = CAST(RIGHT(@SumaSucursal, 4) AS NUMERIC);
END
		

SET @FL_TOTALES_DE_CONTROL = concat(right(concat(replicate(''0'', 6), @SumaEntidad), 6), right(concat(replicate(''0'', 4),@SumaSucursal), 4)); --relleno y separo con ceros

SET @TotalesControl += CAST(@FL_TOTALES_DE_CONTROL AS INTEGER); --lo uso para armar el totalControl del reg FA

SET @FL_SUMA_TOTAL_DEBITO_LOTE = RIGHT(concat(replicate(''0'',12),@SumaImportes), 12); 
SET @FL_SUMA_TOTAL_CREDITO_LOTE = replicate(''0'', 12);
SET @TotalesDebitos += @SumaImportes;
	  

SET @FL_FIN_LOTE = concat(@FL_ID_REG, @FL_CODIGO_CLASE_TRANSAC, RIGHT(CONCAT(REPLICATE(''0'',6),@FL_CANT_REG_INDIVIDUAL_ADICIONAL),6) , @FL_TOTALES_DE_CONTROL, @FL_SUMA_TOTAL_DEBITO_LOTE, @FL_SUMA_TOTAL_CREDITO_LOTE, @FL_RESERVADO1, @FL_RESERVADO2, @FL_RESERVADO3, @FL_REG_ENTIDAD_ORIGEN, @FL_NUMERO_LOTE);
		
SET @FL_NUMERO_LOTE = RIGHT(CONCAT(REPLICATE(''0'',6), CAST(@FL_NUMERO_LOTE AS NUMERIC) ),7); --borro el +1
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------Grabamos el Fin de Archivo -------------------------------------------------------------------------------------------------------------------------------------
SET @FA_CANT_LOTES = RIGHT(concat(replicate(''0'', 6), CAST(@FL_NUMERO_LOTE AS NUMERIC)), 6);


SET @FA_NUMERO_BLOQUES = RIGHT(CONCAT(REPLICATE(''0'',6) , CAST((CASE WHEN @CantRegistrosTotal % 10 = 0 THEN (@CantRegistrosTotal/10) ELSE (FLOOR(@CantRegistrosTotal /10) + 1) END) AS INTEGER)),6);

SET @FA_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 8), @CantRegistros), 8);
		
SET @FA_TOTALES_DE_CONTROL = RIGHT(concat(replicate(''0'', 10), @TotalesControl), 10);
		
SET @FA_SUMA_TOTAL_DEBITOS = RIGHT(concat(replicate(''0'', 12), @TotalesDebitos), 12);
		
SET @FA_SUMA_TOTAL_CREDITOS = RIGHT(concat(replicate(''0'', 12), @TotalesCreditos),12);
 	
SET @FA_FIN_ARCHIVO = concat(@FA_ID_REG, @FA_CANT_LOTES, @FA_NUMERO_BLOQUES, @FA_CANT_REG_INDIVIDUAL_ADICIONAL, @FA_TOTALES_DE_CONTROL, @FA_SUMA_TOTAL_DEBITOS, @FA_SUMA_TOTAL_CREDITOS, @FA_RESERVADO);


--- Grabamos la fin de lote del archivo ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
INSERT INTO dbo.ITF_DPFD_SALIDA_AUX (LINEA) VALUES (replace(@FL_FIN_LOTE, ''.'', ''''));
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Grabar fin de archivo ---------------------------------------------------------------------------------------------------------------------------------------------------------------
INSERT INTO dbo.ITF_DPFD_SALIDA_AUX (LINEA) VALUES (@FA_FIN_ARCHIVO);
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

END;
')