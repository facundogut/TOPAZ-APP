EXECUTE('DROP PROCEDURE IF EXISTS [dbo].[SP_ITF_COELSA_DPF_TERCEROS_PRESENTADOS_ENVIADOS];')

EXECUTE('
CREATE PROCEDURE [dbo].[SP_ITF_COELSA_DPF_TERCEROS_PRESENTADOS_ENVIADOS]
@TICKET NUMERIC(16)
AS

BEGIN

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
TRUNCATE TABLE ITF_CHEQUES_SALIDA_AUX;
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Variables Cabecera Archivo ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DECLARE @CA_ID_REG VARCHAR(1) = ''1'';
DECLARE @CA_CODIGO_PRIORIDAD VARCHAR(2) = ''01'';
DECLARE @CA_DESTINO_INMEDIATO VARCHAR(10) = '' 000000010'';
DECLARE @CA_ORIGEN_INMEDIATO VARCHAR(10) = '' 031100970''; 
DECLARE @CA_FECHA_PRESENTACION VARCHAR(6) = convert(VARCHAR,(SELECT FECHAPROCESO FROM PARAMETROS WITH (NOLOCK)), 12); 
DECLARE @CA_HORA_PRESENTACION VARCHAR(4) = concat(SUBSTRING((SELECT CONVERT (VARCHAR(8), SYSDATETIME(),24)),1,2), SUBSTRING((SELECT CONVERT (VARCHAR(8), SYSDATETIME(),24)),4,2));
DECLARE @CA_IDENTIFICADOR_ARCHIVO VARCHAR(1) = ''A''; 
DECLARE @CA_TAMANNO_REGISTRO VARCHAR(3) = ''094'';
DECLARE @CA_FACTOR_BLOQUE VARCHAR(2) = ''10'';
DECLARE @CA_CODIGO_FORMATO VARCHAR(1) = ''1'';
DECLARE @CA_NOMBRE_DEST_INMEDIATO VARCHAR(6) = ''COELSA'';
DECLARE @CA_NOMBRE_ORIG_INMEDIATO VARCHAR(23) =''NUEVO BANCO DEL CHACO S'';
DECLARE @CA_CODIGO_REFERENCIA VARCHAR(8) = replicate('' '', 8);
DECLARE @CA_COMPLETO VARCHAR(200) = concat(@CA_ID_REG, @CA_CODIGO_PRIORIDAD, @CA_DESTINO_INMEDIATO, @CA_ORIGEN_INMEDIATO, @CA_FECHA_PRESENTACION, @CA_HORA_PRESENTACION, @CA_IDENTIFICADOR_ARCHIVO, @CA_TAMANNO_REGISTRO, @CA_FACTOR_BLOQUE, @CA_CODIGO_FORMATO, @CA_NOMBRE_DEST_INMEDIATO, @CA_NOMBRE_ORIG_INMEDIATO, @CA_CODIGO_REFERENCIA);
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Grabamos la cabecera del archivo ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
INSERT INTO ITF_CHEQUES_SALIDA_AUX (LINEA) VALUES (@CA_COMPLETO);
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Variables Cabecera Lote ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DECLARE @CL_ID_REG VARCHAR(1) = ''5''; 
DECLARE @CL_CODIGO_CLASE_TRANSAC VARCHAR(3) = ''200''; 
DECLARE @CL_RESERVADO VARCHAR(46) = replicate('' '', 46);  
DECLARE @CL_TIPO_REGISTRO VARCHAR(3) = ''TRC''; 
DECLARE @CL_DESCRIP_TRANSAC VARCHAR(10) = ''CHEQUESPRE'' ; 
DECLARE @CL_FECHA_PRESENTACION VARCHAR(6) = convert(VARCHAR,(SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)), 12);
DECLARE @CL_FECHA_VENCIMIENTO VARCHAR(6) = convert(VARCHAR,(SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)), 12); 
DECLARE @CL_RESERVADO_CL VARCHAR(3) = ''000''; 
DECLARE @CL_CODIGO_ORIGEN VARCHAR(1) = ''1''; 
DECLARE @CL_ID_ENTIDAD_ORIGEN VARCHAR(8) = ''03110097''; 
DECLARE @CL_NUMERO_LOTE VARCHAR(7) = ''0000001'';
DECLARE @CL_COMPLETO VARCHAR(200) = concat(@CL_ID_REG, @CL_CODIGO_CLASE_TRANSAC, @CL_RESERVADO, @CL_TIPO_REGISTRO, @CL_DESCRIP_TRANSAC, @CL_FECHA_PRESENTACION, @CL_FECHA_VENCIMIENTO, @CL_RESERVADO_CL, @CL_CODIGO_ORIGEN, @CL_ID_ENTIDAD_ORIGEN, @CL_NUMERO_LOTE);
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Grabar la cabecera de lote ---------------------------------------------------------------------------------------------------------------------------------------------------------------
INSERT INTO ITF_CHEQUES_SALIDA_AUX (LINEA) VALUES (@CL_COMPLETO);
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Variables Registro Individual -------------------------------------------------------------------------------------------------------------------------------------------------------------
DECLARE @RI_ID_REG VARCHAR(1) = ''6'';  
DECLARE @RI_CODIGO_TRANSAC VARCHAR(2) = ''27'';
DECLARE @RI_ENTIDAD_DEBITAR VARCHAR(8);
DECLARE @RI_RESERVADO VARCHAR(1) = ''0'';
DECLARE @RI_CUENTA_DEBITAR VARCHAR(17); 
DECLARE @RI_IMPORTE NUMERIC(10); 
DECLARE @RI_NUMERO_CHEQUE VARCHAR(15);
DECLARE @RI_CODIGO_POSTAL VARCHAR(6); 
DECLARE @RI_PUNTO_INTERCAMBIO VARCHAR(16) = ''0000            '';
DECLARE @RI_INFO_ADICIONAL VARCHAR(2);
DECLARE @RI_REGISTRO_ADICIONAL VARCHAR(1) = ''0''; 
DECLARE @RI_CONTADOR_REGISTRO VARCHAR(15);

--- Variables Fin de Lote ---------------------------------------------------------------------------------------------------------------------------------------------------------------
DECLARE @FL_ID_REG VARCHAR(1) = ''8'';  
DECLARE @FL_CODIGO_CLASE_TRANSAC VARCHAR(3) = ''200''; 
DECLARE @FL_CANT_REG_INDIVIDUAL_ADICIONAL VARCHAR(6); 
DECLARE @FL_TOTALES_DE_CONTROL VARCHAR(10) = ''0'';
DECLARE @FL_SUMA_TOTAL_DEBITO_LOTE NUMERIC(12,2) = 0; 
DECLARE @FL_SUMA_TOTAL_CREDITO_LOTE NUMERIC(12,2) = 0; 
DECLARE @FL_RESERVADO1 VARCHAR(10) = replicate('' '', 10);
DECLARE @FL_RESERVADO2 VARCHAR(10) = replicate('' '', 10);
DECLARE @FL_RESERVADO3 VARCHAR(15) = replicate('' '', 15);
DECLARE @FL_REG_ENTIDAD_ORIGEN VARCHAR(8) = ''03110030''; 
DECLARE @FL_NUMERO_LOTE VARCHAR(7) = RIGHT(concat(replicate(''0'', 7), ''1''), 7); 
--------------------------------------------------------------------------------------------------------------------------------------------- 		

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

DECLARE @CantidadDPF NUMERIC(15) = 0; -- cantidad de dpf pesos       
DECLARE @SumaEntidad NUMERIC(15);
DECLARE @SumaSucursal NUMERIC(15);
DECLARE @SumatoriaSignificativaSucursal VARCHAR(4);
DECLARE @SobranteSumatoriaSucursal VARCHAR(4);

DECLARE CursorDPFDolares CURSOR FOR

SELECT TIPO_DOCUMENTO, MONEDA, NUMERO_DPF, BANCO_GIRADO, SUCURSAL_BANCO_GIRADO, NUMERICO_CUENTA_GIRADORA, FECHA_ALTA, IMPORTE, COD_POSTAL 
FROM dbo.CLE_DPF_SALIENTE  
WHERE FECHA_ALTA = (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)) AND TZ_LOCK = 0 AND ESTADO = 1 AND MONEDA = 2
ORDER BY NUMERO_DPF 

OPEN CursorDPFDolares
        
FETCH NEXT FROM CursorDPFDolares INTO @DP_TIPO_DOCUMENTO, @DP_MONEDA, @DP_NUMERO_DPF, @DP_BANCO, @DP_SUCURSAL, @DP_NUMERO_CUENTA, @DP_FECHA_ALTA, @DP_IMPORTE, @DP_CODIGO_POSTAL
        
        
WHILE @@FETCH_STATUS = 0
BEGIN

SET @RI_ENTIDAD_DEBITAR = concat(RIGHT(concat(replicate(''0'', 4), @DP_BANCO), 4), RIGHT(concat(replicate(''0'', 4), @DP_SUCURSAL), 4));

SET @RI_CUENTA_DEBITAR = RIGHT(concat(replicate(''0'', 17), @DP_NUMERO_CUENTA), 17); 
SET @RI_IMPORTE = RIGHT(concat(replicate(0, 10), CAST(@DP_IMPORTE AS NUMERIC(8,2))), 10); 
SET @RI_NUMERO_CHEQUE = RIGHT(concat(''01'', RIGHT(concat(replicate(''0'', 13), @DP_NUMERO_DPF), 13)), 15);
SET @RI_CODIGO_POSTAL = RIGHT(concat(''00'', RIGHT(concat(replicate(''0'', 6), @DP_CODIGO_POSTAL), 4)), 6); 

SET @RI_INFO_ADICIONAL = RIGHT(concat(replicate(''0'', 2), (CASE WHEN @DP_MONEDA = 1 THEN ''0'' ELSE ''1'' END) , ''0''), 2);

SET @RI_CONTADOR_REGISTRO = concat(RIGHT(concat(replicate(''0'', 4), @DP_BANCO), 4), RIGHT(concat(replicate(''0'', 4), @DP_SUCURSAL), 4), RIGHT(concat(replicate(''0'', 7), (SELECT NUMERICO_1 FROM ITF_MASTER_PARAMETROS WHERE CODIGO_INTERFACE = 11)), 7)); 

INSERT INTO ITF_CHEQUES_SALIDA_AUX (LINEA) VALUES (concat(@RI_ID_REG, @RI_CODIGO_TRANSAC, @RI_RESERVADO, @RI_PUNTO_INTERCAMBIO, @RI_INFO_ADICIONAL, @RI_REGISTRO_ADICIONAL, @RI_CONTADOR_REGISTRO));

UPDATE dbo.ITF_MASTER_PARAMETROS SET NUMERICO_1 = (NUMERICO_1 + 1) WHERE CODIGO_INTERFACE = 11;

SET @CantidadDPF = @CantidadDPF + 1;

SET @SumaEntidad += CAST(substring(@RI_ENTIDAD_DEBITAR, 1, 4) AS NUMERIC);
SET @SumaSucursal += CAST(substring(@RI_ENTIDAD_DEBITAR, 5, 4) AS NUMERIC);

SET @FL_SUMA_TOTAL_CREDITO_LOTE += @DP_IMPORTE;

--- Grabar historial -----------------------------------------------------------------------------
INSERT INTO ITF_COELSA_CHEQUES_OTROS (ID_TICKET, ID_PROCESO, FECHAPROCESO, CODIGO_TRANSACCION, ENTIDAD_DEBITAR, CUENTA_DEBITAR, IMPORTE, CODIGO_POSTAL, FECHA_PRESENTADO, FECHA_VENCIMIENTO, NRO_CHEQUE, PUNTO_INTERCAMBIO, TRACE_NUMBER, ESTADO, TIPO, MONEDA)
VALUES (@TICKET, @TICKET, (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)), @RI_CODIGO_TRANSAC, CAST(@RI_ENTIDAD_DEBITAR AS NUMERIC), @DP_NUMERO_CUENTA, @DP_IMPORTE, @DP_CODIGO_POSTAL, @DP_FECHA_ALTA, @DP_FECHA_ALTA, @DP_NUMERO_DPF, @RI_PUNTO_INTERCAMBIO, @RI_CONTADOR_REGISTRO, ''P'', ''D'', @DP_MONEDA);
-----------------------------------------------------------------------------------------------------

UPDATE dbo.ITF_MASTER_PARAMETROS SET NUMERICO_1 = (NUMERICO_1 + 1) WHERE CODIGO_INTERFACE = 11;
        	
UPDATE dbo.CLE_DPF_SALIENTE SET TRACKNUMBER = @RI_CONTADOR_REGISTRO, ESTADO = 2, FECHA_ENVIO_COMPENSACION = (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK))
WHERE TIPO_DOCUMENTO = @DP_TIPO_DOCUMENTO AND NUMERO_DPF = @DP_NUMERO_DPF AND BANCO_GIRADO = @DP_BANCO AND SUCURSAL_BANCO_GIRADO = @DP_SUCURSAL AND FECHA_ALTA = @DP_FECHA_ALTA AND MONEDA = @DP_MONEDA AND TZ_LOCK = 0 AND ESTADO = 1;

FETCH NEXT FROM CursorDPFDolares INTO @DP_TIPO_DOCUMENTO, @DP_MONEDA, @DP_NUMERO_DPF, @DP_BANCO, @DP_SUCURSAL, @DP_NUMERO_CUENTA, @DP_FECHA_ALTA, @DP_IMPORTE, @DP_CODIGO_POSTAL
        
END
        
CLOSE CursorDPFDolares
DEALLOCATE CursorDPFDolares



--- Totales para el fin de lote ---------------------------------------------------------------------------------------------------------------------------------------------------------------
SET @SumatoriaSignificativaSucursal = RIGHT(concat(replicate(''0'', 4), @SumaSucursal), 4);

SET @SobranteSumatoriaSucursal = ''0'';

IF len(@SumaSucursal) > 4
BEGIN
	SET @SobranteSumatoriaSucursal = (substring(CAST(@SumaSucursal AS VARCHAR), 1, (len(@SumaSucursal) - 4)));
END

SET @SumaEntidad += CAST(@SobranteSumatoriaSucursal AS NUMERIC);

SET @FL_TOTALES_DE_CONTROL = RIGHT(concat(replicate(''0'', 10), @SumatoriaSignificativaSucursal, @SumaEntidad), 10);

SET @FL_SUMA_TOTAL_CREDITO_LOTE = RIGHT(concat(replicate(''0'', 12), @FL_SUMA_TOTAL_CREDITO_LOTE), 12);

SET @FL_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 6), @CantidadDPF), 6)
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Grabar fin de lote ---------------------------------------------------------------------------------------------------------------------------------------------------------------
INSERT INTO ITF_CHEQUES_SALIDA_AUX (LINEA) VALUES (concat(@FL_ID_REG, @FL_CODIGO_CLASE_TRANSAC, @FL_CANT_REG_INDIVIDUAL_ADICIONAL, @FL_TOTALES_DE_CONTROL, @FL_SUMA_TOTAL_DEBITO_LOTE, @FL_SUMA_TOTAL_CREDITO_LOTE, @FL_RESERVADO1, @FL_RESERVADO2, @FL_RESERVADO3, @FL_REG_ENTIDAD_ORIGEN, @FL_NUMERO_LOTE));
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Variables Fin de Archivo ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DECLARE @CantRegistrosAux NUMERIC(6) = (ISNULL((SELECT COUNT(ID) + 1 FROM ITF_CHEQUES_SALIDA_AUX WITH(NOLOCK)), 0));
DECLARE @FA_ID_REG VARCHAR(1) = ''9'';  
DECLARE @FA_CANT_LOTES VARCHAR(6) = concat(replicate(''0'', 5), ''1'');
DECLARE @FA_NUMERO_BLOQUES VARCHAR(6) = RIGHT(concat(replicate(''0'', 6), (CASE WHEN (@CantRegistrosAux) % 10 = 0 THEN (@CantRegistrosAux/10) ELSE (FLOOR(@CantRegistrosAux/10) + 1) END)), 6);
DECLARE @FA_CANT_REG_INDIVIDUAL_ADICIONAL VARCHAR(8) = RIGHT(concat(replicate(''0'', 8), @FL_CANT_REG_INDIVIDUAL_ADICIONAL), 8);
DECLARE @FA_TOTALES_DE_CONTROL VARCHAR(10) = RIGHT(concat(replicate(''0'', 10), @FL_TOTALES_DE_CONTROL), 10); 
DECLARE @FA_SUMA_TOTAL_DEBITOS VARCHAR(12) = RIGHT(concat(replicate(''0'', 12), @FL_SUMA_TOTAL_DEBITO_LOTE), 12);
DECLARE @FA_SUMA_TOTAL_CREDITOS VARCHAR(12) = RIGHT(concat(replicate(''0'', 12), @FL_SUMA_TOTAL_CREDITO_LOTE), 12);
DECLARE @FA_RESERVADO  VARCHAR(30) = replicate('' '', 30);

--- Grabar fin del archivo -----------------------------------------------------------------------------------------------------------------------------------------------------------------
INSERT INTO ITF_CHEQUES_SALIDA_AUX (LINEA) VALUES (concat(@FA_ID_REG, @FA_CANT_LOTES, @FA_NUMERO_BLOQUES, @FA_CANT_REG_INDIVIDUAL_ADICIONAL, @FA_TOTALES_DE_CONTROL, @FA_SUMA_TOTAL_DEBITOS, @FA_SUMA_TOTAL_CREDITOS, @FA_RESERVADO));
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
END;')