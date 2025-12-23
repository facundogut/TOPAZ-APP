EXECUTE('DROP PROCEDURE IF EXISTS [dbo].[SP_ITF_COELSA_DPF_TERCEROS_PRESENTADOS_ENVIADOS];')

EXECUTE('
CREATE PROCEDURE [dbo].[SP_ITF_COELSA_DPF_TERCEROS_PRESENTADOS_ENVIADOS]

AS

BEGIN
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

--- Grabar registro individual ---------------------------------------------------------------------------------------------------------------------------------------------------------------
INSERT INTO ITF_CHEQUES_SALIDA_AUX (LINEA) 

SELECT
concat(
@RI_ID_REG,
@RI_CODIGO_TRANSAC,
concat(RIGHT(concat(replicate(''0'', 4), BANCO_GIRADO), 4), RIGHT(concat(replicate(''0'', 4), SUCURSAL_BANCO_GIRADO), 4)),
@RI_RESERVADO,
RIGHT(concat(replicate(''0'', 17), NUMERICO_CUENTA_GIRADORA), 17),
RIGHT(concat(replicate(0, 10), CAST(IMPORTE AS NUMERIC(8,2))), 10),
RIGHT(concat(''01'', RIGHT(concat(replicate(''0'', 13), NUMERO_DPF), 13)), 15),
RIGHT(concat(''00'', RIGHT(concat(replicate(''0'', 6), COD_POSTAL), 4)), 6),
@RI_PUNTO_INTERCAMBIO,
RIGHT(concat(replicate(''0'', 2), (CASE WHEN MONEDA = 1 THEN ''0'' ELSE ''1'' END) , ''0''), 2),
@RI_REGISTRO_ADICIONAL,
RIGHT(concat(concat(RIGHT(concat(replicate(''0'', 4), BANCO_GIRADO), 4), RIGHT(concat(replicate(''0'', 4), SUCURSAL_BANCO_GIRADO), 4)), RIGHT( concat( replicate(''0'', 7) , (SELECT COUNT(*) FROM CLE_DPF_SALIENTE WHERE  ESTADO = 1 AND MONEDA = 2 AND TZ_LOCK = 0 AND FECHA_ALTA = (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)) ) ) , 7) ), 15)
)

FROM CLE_DPF_SALIENTE

WHERE FECHA_ALTA = (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)) AND TZ_LOCK = 0 AND ESTADO = 1 AND MONEDA = 2
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Variables Fin de Lote ---------------------------------------------------------------------------------------------------------------------------------------------------------------
DECLARE @FL_ID_REG VARCHAR(1) = ''8'';  
DECLARE @FL_CODIGO_CLASE_TRANSAC VARCHAR(3) = ''200''; 
DECLARE @FL_CANT_REG_INDIVIDUAL_ADICIONAL VARCHAR(6) = ISNULL((SELECT COUNT(*) FROM CLE_DPF_SALIENTE WHERE TZ_LOCK = 0 AND ESTADO = 1 AND MONEDA = 2 AND FECHA_ALTA = (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK))), 0); 
DECLARE @FL_TOTALES_DE_CONTROL VARCHAR(10) = ''0'';
DECLARE @FL_SUMA_TOTAL_DEBITO_LOTE NUMERIC(12,2) = 0; 
DECLARE @FL_SUMA_TOTAL_CREDITO_LOTE NUMERIC(12,2) = ISNULL((SELECT SUM(IMPORTE) FROM CLE_DPF_SALIENTE WHERE TZ_LOCK = 0 AND ESTADO = 1 AND MONEDA = 2 AND FECHA_ALTA = (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK))), 0); 
DECLARE @FL_RESERVADO1 VARCHAR(10) = replicate('' '', 10);
DECLARE @FL_RESERVADO2 VARCHAR(10) = replicate('' '', 10);
DECLARE @FL_RESERVADO3 VARCHAR(15) = replicate('' '', 15);
DECLARE @FL_REG_ENTIDAD_ORIGEN VARCHAR(8) = ''03110030''; 
DECLARE @FL_NUMERO_LOTE VARCHAR(7) = (concat(replicate(''0'', 6), ''1'')); 

--- Totales para el fin de lote ---------------------------------------------------------------------------------------------------------------------------------------------------------------

DECLARE @SumaEntidad NUMERIC(15) = ISNULL((SELECT SUM(BANCO_GIRADO) FROM CLE_DPF_SALIENTE WHERE TZ_LOCK = 0 AND ESTADO = 1 AND MONEDA = 2 AND FECHA_ALTA = (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK))), 0);

DECLARE @SumaSucursal NUMERIC(15) = ISNULL((SELECT SUM(SUCURSAL_BANCO_GIRADO) FROM CLE_DPF_SALIENTE WHERE TZ_LOCK = 0 AND ESTADO = 1 AND MONEDA = 2 AND FECHA_ALTA = (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK))), 0);

DECLARE @SumatoriaSignificativaSucursal VARCHAR(4) = RIGHT(concat(replicate(''0'', 4), @SumaSucursal), 4);

DECLARE @SobranteSumatoriaSucursal VARCHAR(4) = ''0'';

IF len(@SumaSucursal) > 4
BEGIN
	SET @SobranteSumatoriaSucursal = (substring(CAST(@SumaSucursal AS VARCHAR), 1, (len(@SumaSucursal) - 4)));
END

SET @SumaEntidad += CAST(@SobranteSumatoriaSucursal AS NUMERIC);

SET @FL_TOTALES_DE_CONTROL = RIGHT(concat(replicate(''0'', 10), @SumatoriaSignificativaSucursal, @SumaEntidad), 10);

SET @FL_SUMA_TOTAL_DEBITO_LOTE = RIGHT(replicate(''0'', 12), 12);
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Grabar fin de lote ---------------------------------------------------------------------------------------------------------------------------------------------------------------
INSERT INTO ITF_CHEQUES_SALIDA_AUX (LINEA) VALUES (concat(@FL_ID_REG, @FL_CODIGO_CLASE_TRANSAC, @FL_CANT_REG_INDIVIDUAL_ADICIONAL, @FL_TOTALES_DE_CONTROL, @FL_SUMA_TOTAL_DEBITO_LOTE, @FL_SUMA_TOTAL_CREDITO_LOTE, @FL_RESERVADO1, @FL_RESERVADO2, @FL_RESERVADO3, @FL_REG_ENTIDAD_ORIGEN, @FL_NUMERO_LOTE));
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Variables Fin de Archivo ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DECLARE @CantRegistrosAux NUMERIC(6) = (ISNULL((SELECT COUNT(ID) FROM ITF_CHEQUES_SALIDA_AUX WITH(NOLOCK)), 0));
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

--- Actualizar el estado de los dpf a procesado ----------------------------------------------------------------------------------------------------------------
UPDATE CLE_DPF_SALIENTE SET ESTADO = 2 WHERE FECHA_ALTA = (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)) AND TZ_LOCK = 0 AND ESTADO = 1 AND MONEDA = 2;
------------------------------------------------------------------------------------------------------------------------------------------------------------------
END;')