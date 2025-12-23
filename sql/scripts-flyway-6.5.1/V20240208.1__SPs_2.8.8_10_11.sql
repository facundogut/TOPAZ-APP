execute('
CREATE or ALTER   PROCEDURE [dbo].[SP_DD_ENVIO_PRESENTADOS_RECIVIDOS]
   @TICKET NUMERIC(16)
AS 
BEGIN

--- Autor: Fabio Alexis Menendez --------------------

------------ Limpieza de tabla auxiliar --------------------
--TRUNCATE TABLE dbo.ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX;
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
DECLARE @CA_NOMBRE_ORIG_INMEDIATO VARCHAR(23)=''NUEVO BCO CHACO S.A.   ''; -- fijo
DECLARE @CA_CODIGO_REFERENCIA VARCHAR(8) = ''        ''; --Se conforma con espacios vacíos.

DECLARE @CA_CABECERA VARCHAR(200);

SET @CA_CABECERA = concat(@CA_ID_REG, @CA_CODIGO_PRIORIDAD, @CA_DESTINO_INMEDIATO, @CA_ORIGEN_INMEDIATO, @CA_FECHA_PRESENTACION, @CA_HORA_PRESENTACION, @CA_IDENTIFICADOR_ARCHIVO, @CA_TAMANNO_REGISTRO, @CA_FACTOR_BLOQUE, @CA_CODIGO_FORMATO, @CA_NOMBRE_DEST_INMEDIATO, @CA_NOMBRE_ORIG_INMEDIATO, @CA_CODIGO_REFERENCIA);


--- Variables cabecera lote (CL)
DECLARE @CL_ID_REG VARCHAR(1) = ''5''; -- fijo
DECLARE @CL_CODIGO_CLASE_TRANSAC VARCHAR(3) = ''200''; -- fijo 
--DECLARE @CL_RESERVADO VARCHAR(46) = replicate('' '', 46); -- 3 campos reservados
DECLARE @CL_NOM_EMPRESA VARCHAR(16);
DECLARE @CL_CRITERIO_EMPRESA VARCHAR(20);
DECLARE @CL_ID_EMPRESA VARCHAR(10);
DECLARE @CL_TIPO_REGISTRO VARCHAR(3) = ''PPD''; -- fijo 
DECLARE @CL_DESCRIP_TRANSAC VARCHAR(10) = ''SERVICIOS ''; -- fijo
DECLARE @CL_FECHA_PRESENTACION VARCHAR(6) = convert(VARCHAR,(SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)), 12);
DECLARE @CL_FECHA_VENCIMIENTO VARCHAR(6) = convert(VARCHAR,(SELECT FECHAPROXIMOPROCESO FROM PARAMETROS WITH(NOLOCK)), 12); 
DECLARE @CL_RESERVADO_CL VARCHAR(3) = ''R  ''; -- fijo
DECLARE @CL_CODIGO_ORIGEN VARCHAR(1) = ''1''; -- fijo
DECLARE @CL_ID_ENTIDAD_ORIGEN VARCHAR(8) = (SELECT ''031100''+CAST((SELECT NUMERICO FROM PARAMETROSGENERALES WHERE CODIGO=40) AS VARCHAR)); 
DECLARE @CL_NUMERO_LOTE VARCHAR(7) = RIGHT(concat(replicate(''0'', 7), 0), 7); -- numero del lote

DECLARE @CL_CABECERA VARCHAR(200);



--SET @CL_CABECERA = concat(@CL_ID_REG, @CL_CODIGO_CLASE_TRANSAC, @CL_RESERVADO, @CL_TIPO_REGISTRO, @CL_DESCRIP_TRANSAC, @CL_FECHA_PRESENTACION, @CL_FECHA_VENCIMIENTO, @CL_RESERVADO_CL, @CL_CODIGO_ORIGEN, @CL_ID_ENTIDAD_ORIGEN, @CL_NUMERO_LOTE);

		---------------- Grabar Cabecera Archivo ---------------------------
		INSERT INTO dbo.ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX (LINEA) VALUES (@CA_CABECERA);
		--------------------------------------------------------------------
		
------ Variables registro individual ( RI) ------------
DECLARE @RI_ID_REG VARCHAR(1) = ''6''; -- fijo  
DECLARE @RI_ENTIDAD_DEBITAR VARCHAR(8);
DECLARE @RI_RESERVADO VARCHAR(1) = ''0''; -- fijo 
DECLARE @RI_CUENTA_DEBITAR VARCHAR(17); 
DECLARE @RI_IMPORTE VARCHAR(11); 
DECLARE @RI_REFERENCIA_UNIVOCA VARCHAR(15);
DECLARE @RI_CLIENTE_PAGADOR VARCHAR(22); 
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
DECLARE @T_CUENTA NUMERIC(12,0);
DECLARE @T_SUCURSAL NUMERIC(5,0);
DECLARE @T_COD_BANCO NUMERIC(4,0);
DECLARE @T_CODIGO_TRANSACCION NUMERIC(3,0);
DECLARE @T_ID_DEBITO NUMERIC(15,0);
DECLARE @T_CUIT NUMERIC(11,0)=0;
DECLARE @CUIT NUMERIC(11,0)=0;
DECLARE @T_MOTIVO_RECHAZO VARCHAR(3);
DECLARE @T_PRESTACION VARCHAR(10);


		IF((SELECT COUNT(1)FROM SNP_DEBITOS WHERE ESTADO = ''RC'')=0 AND (SELECT COUNT(1) FROM ITF_DD_PRESENT_RECIB_RECHAZOS WHERE ESTADO=''I'')=0)
		BEGIN
		---------------- Grabar Cabecera Lote ---------------------------
		SET @CL_NUMERO_LOTE = RIGHT(concat(replicate(''0'', 7), (@CL_NUMERO_LOTE + 1)), 7);
		SET @CL_NOM_EMPRESA =  LEFT(concat('''',replicate('' '', 16)),16);
		SET @CL_CRITERIO_EMPRESA = replicate('' '', 20); -- AUN NO EXISTE AUTONUMERICO, FALTA DEFINIR 
		SET @CL_ID_EMPRESA = LEFT(concat(@T_CUIT,replicate('' '', 10)),10);
		SET @CL_CABECERA = concat(@CL_ID_REG, @CL_CODIGO_CLASE_TRANSAC, @CL_NOM_EMPRESA,@CL_CRITERIO_EMPRESA,@CL_ID_EMPRESA, @CL_TIPO_REGISTRO, @CL_DESCRIP_TRANSAC, @CL_FECHA_PRESENTACION, @CL_FECHA_VENCIMIENTO, @CL_RESERVADO_CL, @CL_CODIGO_ORIGEN, @CL_ID_ENTIDAD_ORIGEN, @CL_NUMERO_LOTE);
		INSERT INTO dbo.ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX (LINEA) VALUES (@CL_CABECERA);
		END 


    --Condicion de reset del contador de reg individual
IF ISNULL((SELECT a.FECHA FROM ITF_MASTER_PARAMETROS a WHERE a.CODIGO = 147), CAST(''01-01-1800'' AS DATETIME)) <> (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK))
    UPDATE dbo.ITF_MASTER_PARAMETROS SET NUMERICO_1 = 1, FECHA = (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)) WHERE CODIGO = 147;
 


DECLARE CursorDD CURSOR FOR
			
SELECT ID_DEBITO, SALDO_JTS_OID, MONEDA, IMPORTE, FECHA_VTO, FECHA_COMP, CBU, replace(REFERENCIA,''.'',''''), convert(VARCHAR(22),CODIGO_CLIENTE), CUIT_EO, MOTIVO_RECHAZO, PRESTACION
FROM SNP_DEBITOS  
WHERE ESTADO = ''RC''
AND fecha_vto=(SELECT fechaproceso FROM PARAMETROS)

UNION 

SELECT ID, SALDO_JTS_OID, MONEDA, IMPORTE, FECHA_VTO, FECHA_COMP, CBU, replace(REFERENCIA,''.'',''''), id_cliente_pagador, CUIT_EO, MOTIVO_RECHAZO, PRESTACION
FROM ITF_DD_PRESENT_RECIB_RECHAZOS 
WHERE ESTADO=''I''
AND fecha_vto=(SELECT fechaproceso FROM PARAMETROS)
ORDER BY CUIT_EO, MONEDA

				        		
OPEN CursorDD
FETCH NEXT FROM CursorDD INTO @T_ID_DEBITO, @T_JTS_OID, @T_MONEDA, @T_IMPORTE, @T_FECHA_VTO,@T_FECHA_COMP,@T_CBU, @T_REFERENCIA, @T_CODIGO_CLIENTE, @T_CUIT, @T_MOTIVO_RECHAZO,@T_PRESTACION

WHILE @@FETCH_STATUS = 0
BEGIN
	
	IF (@SumaImportes > 9909999999 OR @SumaEntidad > 999000) -- 99 millones
	BEGIN
	PRINT ''SUPERA IMPORTES''	
		IF @SumaSucursal > 9999
		BEGIN
			SET @SobranteSucursal = CAST(substring(CAST(@SumaSucursal AS VARCHAR), 1, (len(@SumaSucursal) - 4)) AS NUMERIC);
			SET @SumaEntidad += @SobranteSucursal;
			SET @SumaSucursal = CAST(RIGHT(@SumaSucursal, 4) AS NUMERIC);
		END
		

	   	--SET @FL_TOTALES_DE_CONTROL = concat((RIGHT(concat(replicate(''0'', 6), @SumaEntidad), 6)), (RIGHT(concat(replicate(''0'', 4), @SumaSucursal), 4)));
	   	SET @FL_SUMA_TOTAL_DEBITO_LOTE = RIGHT(concat(replicate(''0'', 12), (replace(@SumaImportes, ''.'', ''''))), 12); 
	   	SET @FL_SUMA_TOTAL_CREDITO_LOTE = RIGHT(replicate(''0'', 12), 12);
	   	SET @TotalesDebitos += @SumaImportes;
	   	SET @FL_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 6), @Cant_Reg_Individual_Adicional+@CantRegistros), 6); 
	   	
	   	   	--nuevo
   	SET @FL_TOTALES_DE_CONTROL = (RIGHT(concat(replicate(''0'', 10), (SELECT sum(convert(numeric,substring(linea,4,8)))
																	FROM ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX
																	WHERE LINEA LIKE ''6%'' 
																	AND ID>(SELECT max(id) 
																			FROM ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX 
																			WHERE LINEA LIKE ''5%''))), 10))

	   	
	   	SET @FL_FIN_LOTE = concat(@FL_ID_REG, @FL_CODIGO_CLASE_TRANSAC, @FL_CANT_REG_INDIVIDUAL_ADICIONAL, @FL_TOTALES_DE_CONTROL, @FL_SUMA_TOTAL_DEBITO_LOTE, @FL_SUMA_TOTAL_CREDITO_LOTE, @FL_RESERVADO1, @FL_RESERVADO2, @FL_RESERVADO3, @FL_REG_ENTIDAD_ORIGEN, @FL_NUMERO_LOTE);
		
    --OJO CON ESTO--
    SET @CantRegistros = 0;
	SET @Cant_Reg_Individual_Adicional = 0;
	
	SET @SumaEntidad_TOT += @SumaEntidad;
	SET @SumaSucursal_TOT += @SumaSucursal;

		--OJO CON ESTO X2--
	SET @SumaEntidad = 0;
	SET @SumaSucursal = 0;
	SET @SumaImportes=0;
	

	
		INSERT INTO dbo.ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX (LINEA) VALUES (replace(@FL_FIN_LOTE, ''.'', ''''));
		
		SET @FL_NUMERO_LOTE = CAST(@FL_NUMERO_LOTE AS NUMERIC) + 1;

		SET @FL_NUMERO_LOTE = RIGHT(concat(replicate(''0'', 7), @FL_NUMERO_LOTE), 7);
		-------------------------------------------------------------------
		-------------Grabamos el Fin de Archivo ----------------------------------------------------------------------------------------------------------------------
		--SET @FA_CANT_LOTES = RIGHT(concat(replicate(''0'', 6), @FL_NUMERO_LOTE), 6);
		
		
				 SET @FA_CANT_LOTES = RIGHT(concat(replicate(''0'', 6), (SELECT count(*) --le su,o uno al count por la linea que estamos por insertar (9%)
																  FROM ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX 
																  WHERE  LINEA LIKE ''5%'' AND ID>=(SELECT max(id) 
																  		  		FROM ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX 
																  		  		WHERE LINEA LIKE ''1%''))), 6);
		
		
		
		SET @CantRegistrosPrev = (SELECT (CASE WHEN (@CantRegistros + 4) % 10 = 0 THEN ((@CantRegistros + 4)/10) ELSE (FLOOR((@CantRegistros + 4)/10) + 1) END));
		--SET @FA_NUMERO_BLOQUES = RIGHT(concat(replicate(''0'', 6), @CantRegistrosPrev), 6);
		
		 SET @FA_NUMERO_BLOQUES = RIGHT(concat(replicate(''0'', 6), (SELECT ceiling (convert(NUMERIC,(count(*)+1))/10) --le su,o uno al count por la linea que estamos por insertar (9%)
																  FROM ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX 
																  WHERE  ID>=(SELECT max(id) 
																  		  		FROM ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX 
																  		  		WHERE LINEA LIKE ''1%''))), 6);

		
		

		--SET @FA_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 8), @CantRegistros), 8);

	SET @FA_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 8), (SELECT sum(convert(numeric,substring(linea,5,6)))
	  																		 FROM ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX 
																			 WHERE LINEA LIKE ''8%''
																			 AND ID>(SELECT max(ID) FROM ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX WHERE LINEA LIKE ''1%''))), 8);



PRINT @FA_CANT_REG_INDIVIDUAL_ADICIONAL
		
		--SET @FA_TOTALES_DE_CONTROL = @FL_TOTALES_DE_CONTROL; --igualo al totales de control de fin de lote pq tiene que ser igual



   	SET @FA_TOTALES_DE_CONTROL = (RIGHT(concat(replicate(''0'', 10), (SELECT sum(convert(numeric,substring(linea,4,8)))
																	FROM ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX
																	WHERE LINEA LIKE ''6%'' 
																	AND ID>(SELECT max(id) 
																			FROM ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX 
																			WHERE LINEA LIKE ''1%''))), 10))

		
		
			SET @FA_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 8), (SELECT sum(convert(numeric,substring(linea,5,6)))
	  																		 FROM ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX 
																			 WHERE LINEA LIKE ''8%''
																			 AND ID>(SELECT max(ID) FROM ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX WHERE LINEA LIKE ''1%''))), 8);

		
		
		
		SET @FA_SUMA_TOTAL_DEBITOS = RIGHT(concat(replicate(''0'', 12), (replace(@TotalesDebitos, ''.'', ''''))), 12);
		
		SET @FA_SUMA_TOTAL_CREDITOS = RIGHT(concat(replicate(''0'', 12), (replace(@TotalesCreditos, ''.'', ''''))),12);

			PRINT ''1:''
	PRINT @FA_ID_REG
	PRINT ''2:''
	PRINT @FA_CANT_LOTES
	PRINT ''3:''
	PRINT @FA_NUMERO_BLOQUES
	PRINT ''4:''
	PRINT @FA_CANT_REG_INDIVIDUAL_ADICIONAL
	PRINT ''5:''
	PRINT @FA_TOTALES_DE_CONTROL
	PRINT ''6:''
	PRINT @FA_SUMA_TOTAL_DEBITOS
	PRINT ''7:''
	PRINT @FA_SUMA_TOTAL_CREDITOS
	PRINT ''8:''
	PRINT @FA_RESERVADO
		
		
		
		SET @FA_FIN_ARCHIVO = concat(@FA_ID_REG, @FA_CANT_LOTES, @FA_NUMERO_BLOQUES, @FA_CANT_REG_INDIVIDUAL_ADICIONAL, @FA_TOTALES_DE_CONTROL, @FA_SUMA_TOTAL_DEBITOS, @FA_SUMA_TOTAL_CREDITOS, @FA_RESERVADO);
		
		PRINT @FA_NUMERO_BLOQUES

		
		INSERT INTO dbo.ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX (LINEA) VALUES (@FA_FIN_ARCHIVO);
		
		PRINT @FA_NUMERO_BLOQUES
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
		SET @CL_NUMERO_LOTE = RIGHT(concat(replicate(''0'', 7), (@CL_NUMERO_LOTE + 1)), 7);
		SET @CL_NOM_EMPRESA =  LEFT(concat(replicate('' '', 16), (SELECT NOMBRE_EMPRESA FROM SNP_PRESTACIONES_EMPRESAS WHERE CUIT_EO=@T_CUIT AND PRESTACION=@T_PRESTACION)),16);
		SET @CL_CRITERIO_EMPRESA = replicate('' '', 20); -- AUN NO EXISTE AUTONUMERICO, FALTA DEFINIR 
		SET @CL_ID_EMPRESA = LEFT(@T_CUIT,10);
		
		SET @CL_NUMERO_LOTE=''0000001''
		SET @FL_NUMERO_LOTE=''0000001''
		
		SET @CL_CABECERA = concat(@CL_ID_REG, @CL_CODIGO_CLASE_TRANSAC, @CL_NOM_EMPRESA,@CL_CRITERIO_EMPRESA,@CL_ID_EMPRESA, @CL_TIPO_REGISTRO, @CL_DESCRIP_TRANSAC, @CL_FECHA_PRESENTACION, @CL_FECHA_VENCIMIENTO, @CL_RESERVADO_CL, @CL_CODIGO_ORIGEN, @CL_ID_ENTIDAD_ORIGEN, @CL_NUMERO_LOTE);
		
		INSERT INTO dbo.ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX (LINEA) VALUES (@CL_CABECERA);
		---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	END
	
	IF(@T_MONEDA=(SELECT C6399 FROM MONEDAS WHERE C6403=''N''))
	SET @CL_ID_ENTIDAD_ORIGEN  = (SELECT ''031100''+CAST((SELECT NUMERICO FROM PARAMETROSGENERALES WHERE CODIGO=40) AS VARCHAR));
	ELSE
	SET @CL_ID_ENTIDAD_ORIGEN  = (SELECT ''081100''+CAST((SELECT NUMERICO FROM PARAMETROSGENERALES WHERE CODIGO=40) AS VARCHAR));
	
	/* LOGICA PARA GRABAR LA CABECERA DE LOTE*/
	IF(@CUIT!=@T_CUIT OR @T_MONEDA!=@MONEDA)
	BEGIN
	
	IF(@CUIT!=0)
	BEGIN
	--SET @FL_TOTALES_DE_CONTROL = concat((RIGHT(concat(replicate(''0'', 6), @SumaEntidad), 6)), (RIGHT(concat(replicate(''0'', 4), @SumaSucursal), 4)));
   	SET @FL_SUMA_TOTAL_DEBITO_LOTE = RIGHT(concat(replicate(''0'', 12), (replace(@SumaImportes, ''.'', ''''))), 12); 
   	SET @FL_SUMA_TOTAL_CREDITO_LOTE = RIGHT(replicate(''0'', 12), 12);
   	SET @TotalesDebitos += @SumaImportes;
   	SET @FL_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 6), @Cant_Reg_Individual_Adicional+@CantRegistros), 6); 
   	
   	--nuevo
   	SET @FL_TOTALES_DE_CONTROL = (RIGHT(concat(replicate(''0'', 10), (SELECT sum(convert(numeric,substring(linea,4,8)))
																	FROM ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX
																	WHERE LINEA LIKE ''6%'' 
																	AND ID>(SELECT max(id) 
																			FROM ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX 
																			WHERE LINEA LIKE ''5%''))), 10))
   	
   	
   	SET @FL_FIN_LOTE = concat(@FL_ID_REG, @FL_CODIGO_CLASE_TRANSAC, @FL_CANT_REG_INDIVIDUAL_ADICIONAL, @FL_TOTALES_DE_CONTROL, @FL_SUMA_TOTAL_DEBITO_LOTE, @FL_SUMA_TOTAL_CREDITO_LOTE, @FL_RESERVADO1, @FL_RESERVADO2, @FL_RESERVADO3, @FL_REG_ENTIDAD_ORIGEN, @FL_NUMERO_LOTE);

    --OJO CON ESTO--
    SET @CantRegistros = 0;
	SET @Cant_Reg_Individual_Adicional = 0;
	
	SET @SumaEntidad_TOT += @SumaEntidad;
	SET @SumaSucursal_TOT += @SumaSucursal;

		--OJO CON ESTO X2--
	SET @SumaEntidad = 0;
	SET @SumaSucursal = 0;
	SET @SumaImportes=0;

	SET @FL_NUMERO_LOTE = CAST(@FL_NUMERO_LOTE AS NUMERIC) + 1;

	SET @FL_NUMERO_LOTE = RIGHT(concat(replicate(''0'', 7), @FL_NUMERO_LOTE), 7);
	
	INSERT INTO dbo.ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX (LINEA) VALUES (replace(@FL_FIN_LOTE, ''.'', ''''));
		
	
	
	END
	
	SET @CUIT = @T_CUIT;
	SET @MONEDA = @T_MONEDA;
	SET @CL_NUMERO_LOTE = RIGHT(concat(replicate(''0'', 7), (@CL_NUMERO_LOTE + 1)), 7);
	SET @CL_NOM_EMPRESA =  LEFT(concat((SELECT NOMBRE_EMPRESA FROM SNP_PRESTACIONES_EMPRESAS WHERE CUIT_EO=@T_CUIT AND PRESTACION=@T_PRESTACION),replicate('' '', 16)),16);
	SET @CL_CRITERIO_EMPRESA = replicate('' '', 20); -- AUN NO EXISTE AUTONUMERICO, FALTA DEFINIR 
	SET @CL_ID_EMPRESA = LEFT(concat(@T_CUIT,replicate('' '', 10)),10);
		SET @CL_CABECERA = concat(@CL_ID_REG, @CL_CODIGO_CLASE_TRANSAC, @CL_NOM_EMPRESA,@CL_CRITERIO_EMPRESA,@CL_ID_EMPRESA, @CL_TIPO_REGISTRO, @CL_DESCRIP_TRANSAC, @CL_FECHA_PRESENTACION, @CL_FECHA_VENCIMIENTO, @CL_RESERVADO_CL, @CL_CODIGO_ORIGEN, @CL_ID_ENTIDAD_ORIGEN, @CL_NUMERO_LOTE);
		

		
		INSERT INTO dbo.ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX (LINEA) VALUES (@CL_CABECERA);
	
	IF(@T_MONEDA=(SELECT C6399 FROM MONEDAS WHERE C6403=''N''))	
	SET @FL_REG_ENTIDAD_ORIGEN = (SELECT ''0311''+ RIGHT(concat(replicate(''0'', 4), CAST((SELECT NUMERICO FROM PARAMETROSGENERALES WHERE CODIGO=40) AS VARCHAR)), 4)); 
	ELSE
	SET @FL_REG_ENTIDAD_ORIGEN = (SELECT ''0811''+ RIGHT(concat(replicate(''0'', 4), CAST((SELECT NUMERICO FROM PARAMETROSGENERALES WHERE CODIGO=40) AS VARCHAR)), 4)); 
	END
	
	IF (@T_JTS_OID IS NULL)
		BEGIN
			SELECT @T_SUCURSAL=SUCURSAL, @T_CUENTA=CUENTA FROM SALDOS WHERE JTS_OID=@T_JTS_OID;
		END
	ELSE
		BEGIN
			SET @T_SUCURSAL=convert(NUMERIC(5,0),substring(@T_CBU,4,4));
		END
		
	
	
	IF(@T_MONEDA= (SELECT C6399 FROM MONEDAS WHERE C6403=''N''))
	BEGIN
	SET @T_COD_BANCO=311;
	SET @RI_INFO_ADICIONAL=''00'';
	END
	ELSE
	BEGIN
	SET @T_COD_BANCO=811;
	SET @RI_INFO_ADICIONAL=''10'';
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
	END
	ELSE
    BEGIN
       SET @Excedente = 0;
    END
	

	---------------------------- Grabar Registro Individual -----------------------------------------------------------------------------------------------------------------------------------------
	SET @RI_ENTIDAD_DEBITAR = CONCAT(RIGHT(concat(replicate(''0'', 4), @T_COD_BANCO),4) , RIGHT(concat(replicate(''0'', 4), @T_SUCURSAL),4));
    SET @RI_CUENTA_DEBITAR = RIGHT(concat(replicate(''0'', 17), @T_CUENTA), 17);
    SET @RI_REFERENCIA_UNIVOCA = RIGHT(concat(replicate(''0'', 15), @T_REFERENCIA), 15);
    SET @RI_CLIENTE_PAGADOR = RIGHT(concat(replicate(''0'', 22), @T_CODIGO_CLIENTE), 22);
	SET @T_CODIGO_TRANSACCION = ''36'';
	
    IF(@CountExcedente>1)
	BEGIN
	

	
        SET @SumaSucursal += 0888;  --sumo la sucursal que hay que harcodear
        SET @SumaEntidad +=  @T_COD_BANCO;
        SET @SumaImportes += @T_IMPORTE;

        
        SET @RI_ENTIDAD_DEBITAR = CONCAT(RIGHT(concat(replicate(''0'', 4), @T_COD_BANCO),4) , RIGHT(concat(replicate(''0'', 4), ''0888''),4));

        
        SET @RI_CUENTA_DEBITAR = RIGHT(concat(replicate(''0'', 17), ''88888888888''), 17);
        SET @RI_REFERENCIA_UNIVOCA = ''000088888888888'';


   
   	END
    ELSE --la razon de este else, es que SumaSucursal, cuando hay excedente tiene que acumular 0888
    BEGIN
        SET @SumaSucursal += @T_SUCURSAL;
		SET @SumaEntidad += @T_COD_BANCO;
		SET @SumaImportes += @T_IMPORTE;



		SET @RI_ENTIDAD_DEBITAR = CONCAT(RIGHT(concat(replicate(''0'', 4), @T_COD_BANCO),4) , RIGHT(concat(replicate(''0'', 4), @T_SUCURSAL),4));
    	SET @RI_CUENTA_DEBITAR = RIGHT(concat(replicate(''0'', 17), @T_CUENTA), 17);
    	SET @RI_REFERENCIA_UNIVOCA =  RIGHT(concat(replicate(''0'', 15), @T_REFERENCIA), 15);
    	SET @RI_CLIENTE_PAGADOR = RIGHT(concat(replicate(''0'', 22), @T_CODIGO_CLIENTE), 22);
 

 			

 
    END

    
    SET @RI_IMPORTE = RIGHT(concat(replicate(''0'', 10), replace(CAST(@T_IMPORTE AS VARCHAR),''.'','''')), 10);
    --SET @RI_CODIGO_POSTAL = RIGHT(concat(''00'', replicate(''0'', 6), @T_CODIGO_POSTAL), 6);

    SET @RI_REGISTRO_ADICIONAL = ''1'';

    IF(@T_MONEDA=(SELECT C6399 FROM MONEDAS WHERE C6403=''N''))
    SET @RI_CONTADOR_REGISTRO = concat(''0311'', RIGHT(concat(replicate(''0'', 4), (''97'')), 4), RIGHT(concat(replicate(''0'', 7), (SELECT NUMERICO_1 FROM ITF_MASTER_PARAMETROS WHERE CODIGO = 147)), 7)); 
    ELSE
    SET @RI_CONTADOR_REGISTRO = concat(''0811'', RIGHT(concat(replicate(''0'', 4), (''97'')), 4), RIGHT(concat(replicate(''0'', 7), (SELECT NUMERICO_1 FROM ITF_MASTER_PARAMETROS WHERE CODIGO = 147)), 7)); 
     
        	
	SET @RI_REGISTRO_INDIVIDUAL = concat(@RI_ID_REG, @T_CODIGO_TRANSACCION, @RI_ENTIDAD_DEBITAR, @RI_RESERVADO, @RI_CUENTA_DEBITAR, @RI_IMPORTE, @RI_REFERENCIA_UNIVOCA, @RI_CLIENTE_PAGADOR, @RI_INFO_ADICIONAL, @RI_REGISTRO_ADICIONAL, @RI_CONTADOR_REGISTRO);





 
    INSERT INTO dbo.ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX (LINEA) VALUES (replace(@RI_REGISTRO_INDIVIDUAL, ''.'', ''''));
	-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	/* Logica para agregar el registro adicional con el motivo del rechazo*/	
	IF(@Excedente=0 OR @Excedente<90000000)
	BEGIN
	SET @CODIGO_RECHAZO = ''R'' + RIGHT(CONCAT(''00'',@T_MOTIVO_RECHAZO),2);
	SET @TRACE_NUMBER=  RIGHT(CONCAT(''000000000000000'',@T_ID_DEBITO),15); 
	SET @OTRO_RECHAZO = REPLICATE('' '',44);
	
	SET @RI_REGISTRO_INDIVIDUAL_ADICIONAL = concat(''799'',@CODIGO_RECHAZO,@TRACE_NUMBER,''      '',(''0''+LEFT(@T_CBU,7)),@OTRO_RECHAZO,@RI_CONTADOR_REGISTRO);
	INSERT INTO dbo.ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX (LINEA,idSNP_DEBITOS) VALUES (replace(@RI_REGISTRO_INDIVIDUAL_ADICIONAL, ''.'', ''''), @T_ID_DEBITO);
	END

	----------------------------- Actualizar secuencial unico -------------------------------------
	UPDATE dbo.ITF_MASTER_PARAMETROS SET NUMERICO_1 = (NUMERICO_1 + 1) WHERE CODIGO = 147;
	-----------------------------------------------------------------------------------------------

	
	IF (@Excedente = 0)
	BEGIN		     	       				
	
	FETCH NEXT FROM CursorDD INTO @T_ID_DEBITO, @T_JTS_OID, @T_MONEDA, @T_IMPORTE, @T_FECHA_VTO,@T_FECHA_COMP,@T_CBU, @T_REFERENCIA, @T_CODIGO_CLIENTE, @T_CUIT, @T_MOTIVO_RECHAZO,@T_PRESTACION
	
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

	--SET @FL_TOTALES_DE_CONTROL = concat((RIGHT(concat(replicate(''0'', 6), @SumaEntidad), 6)), (RIGHT(concat(replicate(''0'', 4), @SumaSucursal), 4)));
	SET @FL_SUMA_TOTAL_DEBITO_LOTE = RIGHT(concat(replicate(''0'', 12), (replace(@SumaImportes, ''.'', ''''))), 12); 
	SET @FL_SUMA_TOTAL_CREDITO_LOTE = RIGHT(replicate(''0'', 12), 12);
	SET @TotalesDebitos += @SumaImportes;
	SET @FL_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 6), @Cant_Reg_Individual_Adicional+@CantRegistros), 6); 
	
	   	--nuevo
   	SET @FL_TOTALES_DE_CONTROL = (RIGHT(concat(replicate(''0'', 10), (SELECT sum(convert(numeric,substring(linea,4,8)))
																	FROM ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX
																	WHERE LINEA LIKE ''6%'' 
																	AND ID>(SELECT max(id) 
																			FROM ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX 
																			WHERE LINEA LIKE ''5%''))), 10))
	
	
	
     --OJO CON ESTO--
--    SET @CantRegistros = 0;
	SET @Cant_Reg_Individual_Adicional = 0;	

	SET @SumaEntidad_TOT += @SumaEntidad;
	SET @SumaSucursal_TOT += @SumaSucursal;
	
	--OJO CON ESTO X2--
	SET @SumaEntidad = 0;
	SET @SumaSucursal = 0;	
	SET @SumaImportes=0;
	
	SET @FL_FIN_LOTE = concat(@FL_ID_REG, @FL_CODIGO_CLASE_TRANSAC, @FL_CANT_REG_INDIVIDUAL_ADICIONAL, @FL_TOTALES_DE_CONTROL, @FL_SUMA_TOTAL_DEBITO_LOTE, @FL_SUMA_TOTAL_CREDITO_LOTE, @FL_RESERVADO1, @FL_RESERVADO2, @FL_RESERVADO3, @FL_REG_ENTIDAD_ORIGEN, @FL_NUMERO_LOTE);
			
	INSERT INTO dbo.ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX (LINEA) VALUES (replace(@FL_FIN_LOTE, ''.'', ''''));

	---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-------------Grabamos el Fin de Archivo ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--SET @FA_CANT_LOTES = RIGHT(concat(replicate(''0'', 6), @FL_NUMERO_LOTE), 6);
	--SET @CantRegistrosPrev = (SELECT (CASE WHEN (@CantRegistros + 4) % 10 = 0 THEN ((@CantRegistros + 4)/10) ELSE (FLOOR((@CantRegistros + 4)/10) + 1) END));
	--SET @FA_NUMERO_BLOQUES = RIGHT(concat(replicate(''0'', 6), @CantRegistrosPrev+1), 6);

		 SET @FA_CANT_LOTES = RIGHT(concat(replicate(''0'', 6), (SELECT count(*) --le su,o uno al count por la linea que estamos por insertar (9%)
																  FROM ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX 
																  WHERE  LINEA LIKE ''5%'' AND ID>=(SELECT max(id) 
																  		  		FROM ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX 
																  		  		WHERE LINEA LIKE ''1%''))), 6);

	
		 SET @FA_NUMERO_BLOQUES = RIGHT(concat(replicate(''0'', 6), (SELECT ceiling (convert(NUMERIC,(count(*)+1))/10) --le su,o uno al count por la linea que estamos por insertar (9%)
																  FROM ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX 
																  WHERE  ID>=(SELECT max(id) 
																  		  		FROM ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX 
																  		  		WHERE LINEA LIKE ''1%''))), 6);
	
	
	
  --			SET @FA_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 8), @CantRegistros), 8);

	
	
	SET @FA_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 8), (SELECT sum(convert(numeric,substring(linea,5,6)))
	  																		 FROM ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX 
																			 WHERE LINEA LIKE ''8%''
																			 AND ID>(SELECT max(ID) FROM ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX WHERE LINEA LIKE ''1%''))), 8);

PRINT  @FA_CANT_REG_INDIVIDUAL_ADICIONAL			
--	SET @FA_TOTALES_DE_CONTROL = concat((RIGHT(concat(replicate(''0'', 6), @SumaEntidad_TOT), 6)), (RIGHT(concat(replicate(''0'', 4), @SumaSucursal_TOT), 4)));; --igualo al totales de control de fin de lote pq tiene que ser igual

   	SET @FA_TOTALES_DE_CONTROL = (RIGHT(concat(replicate(''0'', 10), (SELECT sum(convert(numeric,substring(linea,4,8)))
																	FROM ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX
																	WHERE LINEA LIKE ''6%'' 
																	AND ID>(SELECT max(id) 
																			FROM ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX 
																			WHERE LINEA LIKE ''1%''))), 10))
			
	SET @FA_SUMA_TOTAL_DEBITOS = RIGHT(concat(replicate(''0'', 12), (replace(@TotalesDebitos, ''.'', ''''))), 12);
			
	SET @FA_SUMA_TOTAL_CREDITOS = RIGHT(concat(replicate(''0'', 12), (replace(@TotalesCreditos, ''.'', ''''))),12);
	
	PRINT ''1:''
	PRINT @FA_ID_REG
	PRINT ''2:''
	PRINT @FA_CANT_LOTES
	PRINT ''3:''
	PRINT @FA_NUMERO_BLOQUES
	PRINT ''4:''
	PRINT @FA_CANT_REG_INDIVIDUAL_ADICIONAL
	PRINT ''5:''
	PRINT @FA_TOTALES_DE_CONTROL
	PRINT ''6:''
	PRINT @FA_SUMA_TOTAL_DEBITOS
	PRINT ''7:''
	PRINT @FA_SUMA_TOTAL_CREDITOS
	PRINT ''8:''
	PRINT @FA_RESERVADO

	
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
');

execute('create or ALTER     PROCEDURE [dbo].[SP_DD_PRESENTADOS_EMITIDOS]
   @TICKET NUMERIC(16)
AS 
BEGIN

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- Autor: Fabio Alexis Menendez
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--DECLARE @TICKET NUMERIC(16)
------------ Limpieza de tabla auxiliar --------------------
TRUNCATE TABLE dbo.ITF_DD_PRESENTADOS_EMITIDOS_AUX;
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
DECLARE @CA_NOMBRE_ORIG_INMEDIATO VARCHAR(23)=''NUEVO BCO CHACO S.A.   ''; -- fijo
DECLARE @CA_CODIGO_REFERENCIA VARCHAR(8) = ''        ''; --Se conforma con espacios vacíos.

DECLARE @CA_CABECERA VARCHAR(200);

SET @CA_CABECERA = concat(@CA_ID_REG, @CA_CODIGO_PRIORIDAD, @CA_DESTINO_INMEDIATO, @CA_ORIGEN_INMEDIATO, @CA_FECHA_PRESENTACION, @CA_HORA_PRESENTACION, @CA_IDENTIFICADOR_ARCHIVO, @CA_TAMANNO_REGISTRO, @CA_FACTOR_BLOQUE, @CA_CODIGO_FORMATO, @CA_NOMBRE_DEST_INMEDIATO, @CA_NOMBRE_ORIG_INMEDIATO, @CA_CODIGO_REFERENCIA);


--- Variables cabecera lote (CL)
DECLARE @CL_ID_REG VARCHAR(1) = ''5''; -- fijo
DECLARE @CL_CODIGO_CLASE_TRANSAC VARCHAR(3) = ''200''; -- fijo 
--DECLARE @CL_RESERVADO VARCHAR(46) = replicate('' '', 46); -- 3 campos reservados
DECLARE @CL_NOM_EMPRESA VARCHAR(16);
DECLARE @CL_CRITERIO_EMPRESA VARCHAR(20);
DECLARE @CL_ID_EMPRESA VARCHAR(10);
DECLARE @CL_TIPO_REGISTRO VARCHAR(3) = ''PPD''; -- fijo 
DECLARE @CL_DESCRIP_TRANSAC VARCHAR(10) = ''SERVICIOS ''; -- fijo
DECLARE @CL_FECHA_PRESENTACION VARCHAR(6) = convert(VARCHAR,(SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)), 12);
DECLARE @CL_FECHA_VENCIMIENTO VARCHAR(6) = convert(VARCHAR,(SELECT FECHAPROXIMOPROCESO FROM PARAMETROS WITH(NOLOCK)), 12); 
DECLARE @CL_RESERVADO_CL VARCHAR(3) = ''R  ''; -- fijo
DECLARE @CL_CODIGO_ORIGEN VARCHAR(1) = ''1''; -- fijo
DECLARE @CL_ID_ENTIDAD_ORIGEN VARCHAR(8) = (SELECT ''031100''+CAST((SELECT NUMERICO FROM PARAMETROSGENERALES WHERE CODIGO=40) AS VARCHAR)); 
DECLARE @CL_NUMERO_LOTE VARCHAR(7) = RIGHT(concat(replicate(''0'', 7), 0), 7); -- numero del lote

DECLARE @CL_CABECERA VARCHAR(200);

--SET @CL_CABECERA = concat(@CL_ID_REG, @CL_CODIGO_CLASE_TRANSAC, @CL_RESERVADO, @CL_TIPO_REGISTRO, @CL_DESCRIP_TRANSAC, @CL_FECHA_PRESENTACION, @CL_FECHA_VENCIMIENTO, @CL_RESERVADO_CL, @CL_CODIGO_ORIGEN, @CL_ID_ENTIDAD_ORIGEN, @CL_NUMERO_LOTE);

		---------------- Grabar Cabecera Archivo ---------------------------
		INSERT INTO dbo.ITF_DD_PRESENTADOS_EMITIDOS_AUX (LINEA) VALUES (@CA_CABECERA);
		--------------------------------------------------------------------
		/*---------------- Grabar Cabecera Lote ---------------------------
		INSERT INTO dbo.ITF_DD_PRESENTADOS_EMITIDOS_AUX (LINEA) VALUES (@CL_CABECERA);
		-----------------------------------------------------------------*/

------ Variables registro individual ( RI) ------------
DECLARE @RI_ID_REG VARCHAR(1) = ''6''; -- fijo  
DECLARE @RI_ENTIDAD_DEBITAR VARCHAR(8);
DECLARE @RI_RESERVADO VARCHAR(1) = ''0''; -- fijo 
DECLARE @RI_CUENTA_DEBITAR VARCHAR(17); 
DECLARE @RI_IMPORTE VARCHAR(11); 
DECLARE @RI_REFERENCIA_UNIVOCA VARCHAR(15);
DECLARE @RI_CLIENTE_PAGADOR VARCHAR(22); 
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

------ Variables Registro Opcional ------
DECLARE @RO_CONCEPTO VARCHAR(80);
DECLARE @RO_NUM_SECUENCIA_ADICIONAL VARCHAR(4)=''0'';

------- Variables generales ------------
DECLARE @SumaImportes NUMERIC(15,2) = 0;
DECLARE @TotalesControl NUMERIC(10) = 0;
DECLARE @TotalesDebitos NUMERIC(15,2) = 0;
DECLARE @TotalesCreditos NUMERIC(15,2) = 0;
DECLARE @CantRegistros NUMERIC(15) = 0;
DECLARE @CantRegistrosPrev NUMERIC(6)= 0;
DECLARE @Cant_Reg_Individual_Adicional VARCHAR(6)= 0;
DECLARE @Reversado INT=0;

DECLARE @SumaEntidad NUMERIC = 0;
DECLARE @SumaSucursal NUMERIC = 0;
DECLARE @SobranteSucursal NUMERIC = 0;
DECLARE @Excedente NUMERIC(15,2) = 0;
DECLARE @CountExcedente INT = 0;
DECLARE @MONEDA INT=0;
------------------------------------------


DECLARE @T_JTS_OID NUMERIC(10,0);
DECLARE @T_MONEDA NUMERIC(4,0);
DECLARE @T_ENTIDAD_DEBITAR VARCHAR(8);
DECLARE @T_CODIGO_CLIENTE VARCHAR(22);
DECLARE @T_IMPORTE NUMERIC(15,2);
DECLARE @T_FECHA_VTO DATETIME;
DECLARE @T_FECHA_COMP DATETIME;
DECLARE @T_CBU VARCHAR(22);
DECLARE @T_REFERENCIA VARCHAR(15);
DECLARE @T_CUENTA NUMERIC(12,0);
DECLARE @T_SUCURSAL NUMERIC(5,0);
DECLARE @T_COD_BANCO NUMERIC(4,0);
DECLARE @T_CODIGO_TRANSACCION NUMERIC(3,0);
DECLARE @T_ID_DEBITO NUMERIC(15,0);
DECLARE @T_CUIT NUMERIC(11,0)=0;
DECLARE @CUIT NUMERIC(11,0)=0;
DECLARE @T_ID_ARCHIVO_REVERSADO NUMERIC(9,0);
DECLARE @T_REVERSADO INT=0;
DECLARE @T_CLIENTE_PAGADOR VARCHAR(22);
DECLARE @T_TRACENUMBER VARCHAR(15);
DECLARE @T_CONTADOR_1 NUMERIC(7)=0;
DECLARE @T_CONTADOR_2 NUMERIC(7)=0;
DECLARE @T_PRES_1ER_VTO DATETIME;
DECLARE @T_PRES_2DO_VTO DATETIME;
DECLARE @T_SUCURSAL_TN VARCHAR(4)=''97'';
DECLARE @T_ID_ARCHIVO VARCHAR(30);
DECLARE @T_NRO_ARCHIVO NUMERIC(15,0);




		IF((SELECT COUNT(1) 
FROM SNP_MSG_ORDENES o LEFT JOIN SNP_MSG_CABEZAL c ON o.CUIT_EO=c.CUIT_EO AND o.ID_ARCHIVO=c.ID_ARCHIVO AND o.NRO_ARCHIVO=c.NRO_ARCHIVO
 AND o.TZ_LOCK=0 AND c.TZ_LOCK=0 LEFT JOIN SNP_CUENTAS_RELACIONADAS r ON r.CUIT_EO=o.CUIT_EO AND r.PRESTACION=o.PRESTACION AND r.RELACION_CUENTA=1 and r.TZ_LOCK=0
 WHERE ((o.ESTADO=''PP'' AND o.PRESENTACION_PRIMER_VTO=(SELECT dbo.diaHabil((SELECT dateadd(dd,1, fechaproceso) FROM PARAMETROS),''A''))) OR (o.ESTADO=''R'' AND o.PRESENTACION_SEGUNDO_VTO=(SELECT dbo.diaHabil((SELECT dateadd(dd,1, fechaproceso) FROM PARAMETROS),''A''))))
AND o.TZ_LOCK=0 )=0)
		BEGIN
		---------------- Grabar Cabecera Lote ---------------------------
		SET @CL_NUMERO_LOTE = RIGHT(concat(replicate(''0'', 7), (SELECT COUNT(*) + 1 FROM ITF_DD_PRESENTADOS_EMITIDOS_AUX WHERE LINEA LIKE ''5%'')), 7);
		SET @CL_NOM_EMPRESA =  LEFT(concat('''',replicate('' '', 16)),16);
		SET @CL_CRITERIO_EMPRESA = replicate('' '', 20); -- AUN NO EXISTE AUTONUMERICO, FALTA DEFINIR 
		SET @CL_ID_EMPRESA = LEFT(concat(@T_CUIT,replicate('' '', 10)),10);
		SET @CL_CABECERA = concat(@CL_ID_REG, @CL_CODIGO_CLASE_TRANSAC, @CL_NOM_EMPRESA,@CL_CRITERIO_EMPRESA,@CL_ID_EMPRESA, @CL_TIPO_REGISTRO, @CL_DESCRIP_TRANSAC, @CL_FECHA_PRESENTACION, @CL_FECHA_VENCIMIENTO, @CL_RESERVADO_CL, @CL_CODIGO_ORIGEN, @CL_ID_ENTIDAD_ORIGEN, @CL_NUMERO_LOTE);
		INSERT INTO dbo.ITF_DD_PRESENTADOS_EMITIDOS_AUX (LINEA) VALUES (@CL_CABECERA);
		END 
		
    --Condicion de reset del contador de reg individual
IF ISNULL((SELECT a.FECHA FROM ITF_MASTER_PARAMETROS a WHERE a.CODIGO = 148), CAST(''01-01-1800'' AS DATETIME)) <> (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK))
    UPDATE dbo.ITF_MASTER_PARAMETROS SET NUMERICO_1 = 1, FECHA = (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)) WHERE CODIGO = 148;
 
 


DECLARE CursorDD CURSOR FOR

SELECT o.CORRELATIVO,
		r.SALDO_JTS_OID, 
		o.MONEDA,
		o.IMPORTE, 
		o.FECHA_VENCIMIENTO, 
		o.FECHA_COMPENSACION, 
		o.CBU, 
		o.REFERENCIA, 
		o.Codigo_Cliente, 
		o.CUIT_EO, 
		o.ID_ARCHIVO_REVERSADO,
		O.CLIENTE_PAGADOR, 
		o.presentacion_primer_vto,
		o.presentacion_segundo_vto,
		o.id_archivo,
		o.nro_archivo
FROM SNP_MSG_ORDENES o LEFT JOIN SNP_MSG_CABEZAL c ON o.CUIT_EO=c.CUIT_EO AND o.ID_ARCHIVO=c.ID_ARCHIVO AND o.NRO_ARCHIVO=c.NRO_ARCHIVO
 AND o.TZ_LOCK=0 AND c.TZ_LOCK=0 LEFT JOIN SNP_CUENTAS_RELACIONADAS r ON r.CUIT_EO=o.CUIT_EO AND r.PRESTACION=o.PRESTACION AND r.RELACION_CUENTA=1 and r.TZ_LOCK=0
 WHERE ((o.ESTADO=''PP'' AND o.PRESENTACION_PRIMER_VTO=(SELECT dbo.diaHabil((SELECT dateadd(dd,1, fechaproceso) FROM PARAMETROS),''A''))) OR (o.ESTADO=''R'' AND o.PRESENTACION_SEGUNDO_VTO=(SELECT dbo.diaHabil((SELECT dateadd(dd,1, fechaproceso) FROM PARAMETROS),''A''))))
AND o.TZ_LOCK=0 

ORDER BY o.CUIT_EO, o.MONEDA, o.ID_ARCHIVO_REVERSADO
				        		
OPEN CursorDD
FETCH NEXT FROM CursorDD INTO @T_ID_DEBITO, 
							  @T_JTS_OID, 
							  @T_MONEDA, 
							  @T_IMPORTE, 
							  @T_FECHA_VTO,
							  @T_FECHA_COMP,
							  @T_CBU, 
							  @T_REFERENCIA, 
							  @T_CODIGO_CLIENTE, 
							  @T_CUIT, 
							  @T_ID_ARCHIVO_REVERSADO,
							  @T_CLIENTE_PAGADOR,
							  @T_PRES_1ER_VTO,
							  @T_PRES_2DO_VTO,
							  @T_ID_ARCHIVO,
							  @T_NRO_ARCHIVO

WHILE @@FETCH_STATUS = 0
BEGIN
	
	

	
	
	IF (@SumaImportes > 9909999999 OR @SumaEntidad > 999000) -- 99 millones
	BEGIN
		
		IF @SumaSucursal > 9999
		BEGIN
			SET @SobranteSucursal = CAST(substring(CAST(@SumaSucursal AS VARCHAR), 1, (len(@SumaSucursal) - 4)) AS NUMERIC);
			SET @SumaEntidad += @SobranteSucursal;
			SET @SumaSucursal = CAST(RIGHT(@SumaSucursal, 4) AS NUMERIC);
		END
		

	   	SET @FL_TOTALES_DE_CONTROL = concat((RIGHT(concat(replicate(''0'', 6), @SumaEntidad), 6)), (RIGHT(concat(replicate(''0'', 4), @SumaSucursal), 4)));
	   	SET @FL_SUMA_TOTAL_DEBITO_LOTE = RIGHT(concat(replicate(''0'', 12), (replace((SELECT convert(NUMERIC(15,2),sum(convert(NUMERIC,substring(linea,30,10)))/100) FROM ITF_DD_PRESENTADOS_EMITIDOS_AUX WHERE LINEA LIKE ''6%'' AND ID>(SELECT max(id) FROM ITF_DD_PRESENTADOS_EMITIDOS_AUX WHERE LINEA LIKE ''5%'') ), ''.'', ''''))), 12); 
	   	SET @FL_SUMA_TOTAL_CREDITO_LOTE = RIGHT(replicate(''0'', 12), 12);
	   	SET @TotalesDebitos += @SumaImportes;
	   	SET @FL_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 6), (SELECT COUNT(*) FROM ITF_DD_PRESENTADOS_EMITIDOS_AUX WHERE (LINEA LIKE ''6%'' or linea like ''7%'') and id>(select max(id) from ITF_DD_PRESENTADOS_EMITIDOS_AUX where linea like ''5%''))), 6); 
	   	
	   	   	SET @FL_TOTALES_DE_CONTROL = (RIGHT(concat(replicate(''0'', 10), (SELECT sum(convert(numeric,substring(linea,4,8)))
																	FROM ITF_DD_PRESENTADOS_EMITIDOS_AUX
																	WHERE LINEA LIKE ''6%'' 
																	AND ID>(SELECT max(id) 
																			FROM ITF_DD_PRESENTADOS_EMITIDOS_AUX 
																			WHERE LINEA LIKE ''5%''))), 10))
	   	
	   	SET @FL_FIN_LOTE = concat(@FL_ID_REG, @FL_CODIGO_CLASE_TRANSAC, @FL_CANT_REG_INDIVIDUAL_ADICIONAL, @FL_TOTALES_DE_CONTROL, @FL_SUMA_TOTAL_DEBITO_LOTE, @FL_SUMA_TOTAL_CREDITO_LOTE, @FL_RESERVADO1, @FL_RESERVADO2, @FL_RESERVADO3, @FL_REG_ENTIDAD_ORIGEN, @FL_NUMERO_LOTE);
		
    
	
		INSERT INTO dbo.ITF_DD_PRESENTADOS_EMITIDOS_AUX (LINEA) VALUES (replace(@FL_FIN_LOTE, ''.'', ''''));
		
		SET @FL_NUMERO_LOTE = CAST(@FL_NUMERO_LOTE AS NUMERIC) + 1;
		SET @FL_NUMERO_LOTE = RIGHT(concat(replicate(''0'', 7), (SELECT COUNT(*) FROM ITF_DD_PRESENTADOS_EMITIDOS_AUX WHERE LINEA LIKE ''5%'' and id>(select max(id) from ITF_DD_PRESENTADOS_EMITIDOS_AUX where linea like ''1%''))), 7);
		-------------------------------------------------------------------
		-------------Grabamos el Fin de Archivo ----------------------------------------------------------------------------------------------------------------------
		SET @FA_CANT_LOTES = RIGHT(concat(replicate(''0'', 6), @FL_NUMERO_LOTE), 6);
		SET @CantRegistrosPrev = (SELECT (CASE WHEN (@CantRegistros + 4) % 10 = 0 THEN ((@CantRegistros + 4)/10) ELSE (FLOOR((@CantRegistros + 4)/10) + 1) END));
		SET @FA_NUMERO_BLOQUES = RIGHT(concat(replicate(''0'', 6), @CantRegistrosPrev), 6);

		SET @FA_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 8), @CantRegistros), 8);
		
		SET @FA_TOTALES_DE_CONTROL = @FL_TOTALES_DE_CONTROL; --igualo al totales de control de fin de lote pq tiene que ser igual
		
		SET @FA_SUMA_TOTAL_DEBITOS = RIGHT(concat(replicate(''0'', 12), (replace((SELECT convert(NUMERIC(15,2),sum(convert(NUMERIC,substring(linea,30,10)))/100) FROM ITF_DD_PRESENTADOS_EMITIDOS_AUX WHERE LINEA LIKE ''6%'' AND ID>(SELECT max(id) FROM ITF_DD_PRESENTADOS_EMITIDOS_AUX WHERE LINEA LIKE ''5%'') ), ''.'', ''''))), 12);
		
		SET @FA_SUMA_TOTAL_CREDITOS = RIGHT(concat(replicate(''0'', 12), (replace(@TotalesCreditos, ''.'', ''''))),12);

		SET @FA_FIN_ARCHIVO = concat(@FA_ID_REG, @FA_CANT_LOTES, @FA_NUMERO_BLOQUES, @FA_CANT_REG_INDIVIDUAL_ADICIONAL, @FA_TOTALES_DE_CONTROL, @FA_SUMA_TOTAL_DEBITOS, @FA_SUMA_TOTAL_CREDITOS, @FA_RESERVADO);
		
		INSERT INTO dbo.ITF_DD_PRESENTADOS_EMITIDOS_AUX (LINEA) VALUES (@FA_FIN_ARCHIVO);
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
		
		INSERT INTO dbo.ITF_DD_PRESENTADOS_EMITIDOS_AUX (LINEA) VALUES (@CA_CABECERA);
		----------------------------------------------------------------------------------------------------------------------------------------------------------------------
		--------- Grabamos nueva Cabecera Lote ------------------------------------------------------------------------------------------------------------------------------------------------------

		SET @CUIT = @T_CUIT;
		SET @CL_NUMERO_LOTE = RIGHT(concat(replicate(''0'', 7), (@CL_NUMERO_LOTE + 1)), 7);
		SET @CL_NOM_EMPRESA =  LEFT((SELECT NOMBRE_EMPRESA FROM SNP_PRESTACIONES_EMPRESAS WHERE CUIT_EO=@T_CUIT),16);
		SET @CL_CRITERIO_EMPRESA = replicate('' '', 20); -- AUN NO EXISTE AUTONUMERICO, FALTA DEFINIR 
		SET @CL_ID_EMPRESA = LEFT(@T_CUIT,10);
		SET @CL_CABECERA = concat(@CL_ID_REG, @CL_CODIGO_CLASE_TRANSAC, @CL_NOM_EMPRESA,@CL_CRITERIO_EMPRESA,@CL_ID_EMPRESA, @CL_TIPO_REGISTRO, @CL_DESCRIP_TRANSAC, @CL_FECHA_PRESENTACION, @CL_FECHA_VENCIMIENTO, @CL_RESERVADO_CL, @CL_CODIGO_ORIGEN, @CL_ID_ENTIDAD_ORIGEN, @CL_NUMERO_LOTE);
		INSERT INTO dbo.ITF_DD_PRESENTADOS_EMITIDOS_AUX (LINEA) VALUES (@CL_CABECERA);
		---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	END
	
	IF @T_ID_ARCHIVO_REVERSADO IS NULL
	SET @Reversado=0;
	ELSE
	SET @Reversado=1;
	
	IF(@T_MONEDA=(SELECT C6399 FROM MONEDAS WHERE C6403=''N''))
	SET @CL_ID_ENTIDAD_ORIGEN  = (SELECT ''031100''+CAST((SELECT NUMERICO FROM PARAMETROSGENERALES WHERE CODIGO=40) AS VARCHAR));
	ELSE
	SET @CL_ID_ENTIDAD_ORIGEN  = (SELECT ''081100''+CAST((SELECT NUMERICO FROM PARAMETROSGENERALES WHERE CODIGO=40) AS VARCHAR));
	
	/* LOGICA PARA GRABAR LA CABECERA DE LOTE*/
	IF(@CUIT!=@T_CUIT OR @T_MONEDA!=@MONEDA OR @Reversado!=@T_REVERSADO)
	BEGIN
	
	IF(@CUIT!=0)
	BEGIN
	SET @FL_TOTALES_DE_CONTROL = concat((RIGHT(concat(replicate(''0'', 6), @SumaEntidad), 6)), (RIGHT(concat(replicate(''0'', 4), @SumaSucursal), 4)));
   	SET @FL_SUMA_TOTAL_DEBITO_LOTE = RIGHT(concat(replicate(''0'', 12), (replace(@SumaImportes, ''.'', ''''))), 12); 
   	SET @FL_SUMA_TOTAL_CREDITO_LOTE = RIGHT(replicate(''0'', 12), 12);
   	SET @TotalesDebitos += @SumaImportes;
   	SET @FL_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 6), (SELECT COUNT(*) FROM ITF_DD_PRESENTADOS_EMITIDOS_AUX WHERE (LINEA LIKE ''6%'' or linea like ''7%'') and id>(select max(id) from ITF_DD_PRESENTADOS_EMITIDOS_AUX where linea like ''5%''))), 6); 
   	
   	SET @FL_FIN_LOTE = concat(@FL_ID_REG, @FL_CODIGO_CLASE_TRANSAC, @FL_CANT_REG_INDIVIDUAL_ADICIONAL, @FL_TOTALES_DE_CONTROL, @FL_SUMA_TOTAL_DEBITO_LOTE, @FL_SUMA_TOTAL_CREDITO_LOTE, @FL_RESERVADO1, @FL_RESERVADO2, @FL_RESERVADO3, @FL_REG_ENTIDAD_ORIGEN, @FL_NUMERO_LOTE);

	INSERT INTO dbo.ITF_DD_PRESENTADOS_EMITIDOS_AUX (LINEA) VALUES (replace(@FL_FIN_LOTE, ''.'', ''''));
	END
	
	SET @T_REVERSADO= @Reversado;
	SET @CUIT = @T_CUIT;
	SET @MONEDA = @T_MONEDA;
	SET @CL_NUMERO_LOTE = RIGHT(concat(replicate(''0'', 7), (@CL_NUMERO_LOTE + 1)), 7);
	SET @CL_NOM_EMPRESA =  LEFT(concat((SELECT NOMBRE_EMPRESA FROM SNP_PRESTACIONES_EMPRESAS WHERE CUIT_EO=@T_CUIT),replicate('' '', 16)),16);
	SET @CL_CRITERIO_EMPRESA = replicate('' '', 20); -- AUN NO EXISTE AUTONUMERICO, FALTA DEFINIR 
	SET @CL_ID_EMPRESA = LEFT(concat(@T_CUIT,replicate('' '', 10)),10);
		SET @CL_CABECERA = concat(@CL_ID_REG, @CL_CODIGO_CLASE_TRANSAC, @CL_NOM_EMPRESA,@CL_CRITERIO_EMPRESA,@CL_ID_EMPRESA, @CL_TIPO_REGISTRO, @CL_DESCRIP_TRANSAC, @CL_FECHA_PRESENTACION, @CL_FECHA_VENCIMIENTO, @CL_RESERVADO_CL, @CL_CODIGO_ORIGEN, @CL_ID_ENTIDAD_ORIGEN, @CL_NUMERO_LOTE);
		INSERT INTO dbo.ITF_DD_PRESENTADOS_EMITIDOS_AUX (LINEA) VALUES (@CL_CABECERA);
	
	IF(@T_MONEDA=(SELECT C6399 FROM MONEDAS WHERE C6403=''N''))	
	SET @FL_REG_ENTIDAD_ORIGEN = (SELECT ''0311''+ RIGHT(concat(replicate(''0'', 4), CAST((SELECT NUMERICO FROM PARAMETROSGENERALES WHERE CODIGO=40) AS VARCHAR)), 4)); 
	ELSE
	SET @FL_REG_ENTIDAD_ORIGEN = (SELECT ''0811''+ RIGHT(concat(replicate(''0'', 4), CAST((SELECT NUMERICO FROM PARAMETROSGENERALES WHERE CODIGO=40) AS VARCHAR)), 4)); 
	END
		
	SELECT @T_SUCURSAL=SUCURSAL, @T_CUENTA=CUENTA FROM SALDOS WHERE JTS_OID=@T_JTS_OID;
	
	--cambio hecho 5/2/2024 ji 
	--DESDE ACA
	

	IF (@T_PRES_1ER_VTO =(SELECT dbo.diaHabil((SELECT dateadd(dd,1, fechaproceso) FROM PARAMETROS),''A'')))
	BEGIN

		
		SET @T_CONTADOR_1=@T_CONTADOR_1+1
		SET @T_TRACENUMBER = concat(''0311'', RIGHT(concat(replicate(''0'', 4), (@T_SUCURSAL_TN)), 4), RIGHT(concat(replicate(''0'', 7), @T_CONTADOR_1), 7)); 



		UPDATE SNP_MSG_ORDENES
		SET TRACE_N_1PRE=@T_TRACENUMBER
		WHERE CORRELATIVO=@T_ID_DEBITO 
		AND cuit_eo=@T_CUIT 
		AND ID_ARCHIVO=@T_ID_ARCHIVO 
		AND NRO_ARCHIVO=@T_NRO_ARCHIVO
	END
	ELSE 
	BEGIN


		
		
		SET @T_CONTADOR_2=@T_CONTADOR_2+1
		SET @T_TRACENUMBER = concat(''0311'', RIGHT(concat(replicate(''0'', 4), (@T_SUCURSAL_TN)), 4), RIGHT(concat(replicate(''0'', 7), @T_CONTADOR_2), 7)); 

		UPDATE SNP_MSG_ORDENES
		SET TRACE_N_2PRE=@T_TRACENUMBER
		WHERE CORRELATIVO=@T_ID_DEBITO 
		AND cuit_eo=@T_CUIT 
		AND ID_ARCHIVO=@T_ID_ARCHIVO 
		AND NRO_ARCHIVO=@T_NRO_ARCHIVO
	END 
	--HASTA ACA	

	IF(@T_MONEDA= (SELECT C6399 FROM MONEDAS WHERE C6403=''N''))
	BEGIN
	SET @T_COD_BANCO=311;
	SET @RI_INFO_ADICIONAL=''00'';
	END
	ELSE
	BEGIN
	SET @T_COD_BANCO=811;
	SET @RI_INFO_ADICIONAL=''10'';
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
	END
	ELSE
    BEGIN
       SET @Excedente = 0;
    END
	

	---------------------------- Grabar Registro Individual -----------------------------------------------------------------------------------------------------------------------------------------
	SET @RI_ENTIDAD_DEBITAR = CONCAT(RIGHT(concat(replicate(''0'', 4), @T_COD_BANCO),4) , RIGHT(concat(replicate(''0'', 4), @T_SUCURSAL),4));
    SET @RI_CUENTA_DEBITAR = RIGHT(concat(replicate(''0'', 17), @T_CUENTA), 17);
    SET @RI_REFERENCIA_UNIVOCA = RIGHT(concat(replicate(''0'', 15), @T_REFERENCIA), 15);
    SET @RI_CLIENTE_PAGADOR = RIGHT(concat(replicate(''0'', 22), @T_CLIENTE_PAGADOR), 22);
	SET @T_CODIGO_TRANSACCION = ''37'';
	
    IF(@CountExcedente>1)
	BEGIN
        SET @SumaSucursal += 0888;  --sumo la sucursal que hay que harcodear
        SET @SumaEntidad +=  @T_COD_BANCO;
        SET @SumaImportes += @T_IMPORTE;

        SET @RI_ENTIDAD_DEBITAR = concat(replicate(''0'', 4), @T_COD_BANCO, ''0888'');
        SET @RI_CUENTA_DEBITAR = RIGHT(concat(replicate(''0'', 17), ''88888888888''), 17);
        SET @RI_REFERENCIA_UNIVOCA = ''000088888888888'';

   
   	END
    ELSE --la razon de este else, es que SumaSucursal, cuando hay excedente tiene que acumular 0888
    BEGIN
        SET @SumaSucursal += @T_SUCURSAL;
		SET @SumaEntidad += @T_COD_BANCO;
		SET @SumaImportes += @T_IMPORTE;

	SET @RI_ENTIDAD_DEBITAR = CONCAT(RIGHT(concat(replicate(''0'', 4), @T_COD_BANCO),4) , RIGHT(concat(replicate(''0'', 4), @T_SUCURSAL),4));
    SET @RI_CUENTA_DEBITAR = RIGHT(concat(replicate(''0'', 17), @T_CUENTA), 17);
    SET @RI_REFERENCIA_UNIVOCA =  RIGHT(concat(replicate(''0'', 15), @T_REFERENCIA), 15);
    SET @RI_CLIENTE_PAGADOR = RIGHT(concat(replicate(''0'', 22), @T_CLIENTE_PAGADOR), 22);
 
    END

    
    SET @RI_IMPORTE = RIGHT(concat(replicate(''0'', 10), replace(CAST(@T_IMPORTE AS VARCHAR),''.'','''')), 10);
    --SET @RI_CODIGO_POSTAL = RIGHT(concat(''00'', replicate(''0'', 6), @T_CODIGO_POSTAL), 6);

    SET @RI_REGISTRO_ADICIONAL = ''1'';
    
    IF(@MONEDA=(SELECT C6399 FROM MONEDAS WHERE C6403=''N''))
    SET @RI_CONTADOR_REGISTRO = concat(''0311'', RIGHT(concat(replicate(''0'', 4), (''97'')), 4), RIGHT(concat(replicate(''0'', 7), (SELECT NUMERICO_1 FROM ITF_MASTER_PARAMETROS WHERE CODIGO = 148)), 7)); 
    ELSE
    SET @RI_CONTADOR_REGISTRO = concat(''0811'', RIGHT(concat(replicate(''0'', 4), (''97'')), 4), RIGHT(concat(replicate(''0'', 7), (SELECT NUMERICO_1 FROM ITF_MASTER_PARAMETROS WHERE CODIGO = 148)), 7)); 
    
    IF(@T_ID_ARCHIVO_REVERSADO<>0 OR @T_ID_ARCHIVO_REVERSADO IS NOT NULL)
	SET @T_CODIGO_TRANSACCION=''32'';
	
        	
	SET @RI_REGISTRO_INDIVIDUAL = concat(@RI_ID_REG, @T_CODIGO_TRANSACCION, @RI_ENTIDAD_DEBITAR, @RI_RESERVADO, @RI_CUENTA_DEBITAR, @RI_IMPORTE, @RI_REFERENCIA_UNIVOCA, @RI_CLIENTE_PAGADOR, @RI_INFO_ADICIONAL, @RI_REGISTRO_ADICIONAL, @T_TRACENUMBER); --antes el ultimo campo era:@RI_CONTADOR_REGISTRO
 
    INSERT INTO dbo.ITF_DD_PRESENTADOS_EMITIDOS_AUX (LINEA, CORRELATIVO) VALUES (replace(@RI_REGISTRO_INDIVIDUAL, ''.'', ''''),@T_ID_DEBITO);
	-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	/* Logica para agregar el registro adicional*/	
	IF(@T_ID_ARCHIVO_REVERSADO=0 OR @T_ID_ARCHIVO_REVERSADO IS NULL)
	BEGIN
	
		SET @RO_CONCEPTO = REPLICATE('' '',80);
		SET @RO_NUM_SECUENCIA_ADICIONAL= RIGHT(concat(replicate(''0'', 4), (@RO_NUM_SECUENCIA_ADICIONAL + 1)), 4);
	
		SET @RI_REGISTRO_INDIVIDUAL = concat(''705'',
										 @RO_CONCEPTO,
										 @RO_NUM_SECUENCIA_ADICIONAL,
										 RIGHT(@T_TRACENUMBER, 7)
										 );
		INSERT INTO dbo.ITF_DD_PRESENTADOS_EMITIDOS_AUX (LINEA) VALUES (replace(@RI_REGISTRO_INDIVIDUAL, ''.'', ''''));
	END  
	ELSE 
	BEGIN 
	
		PRINT ''reversa''
		SET @RO_NUM_SECUENCIA_ADICIONAL= RIGHT(concat(replicate(''0'', 4), (@RO_NUM_SECUENCIA_ADICIONAL + 1)), 4);
		
		

		
		SET @RI_REGISTRO_INDIVIDUAL = concat(''705'',
										 
										 RIGHT(concat(replicate(''0'', 6),(SELECT CONVERT(VARCHAR(6), FECHA_VENCIMIENTO, 12) FROM SNP_MSG_ORDENES WHERE CORRELATIVO=@T_ID_DEBITO AND cuit_eo=@T_CUIT AND ID_ARCHIVO=@T_ID_ARCHIVO AND NRO_ARCHIVO=@T_NRO_ARCHIVO)), 6), 
										 --LEFT(CONCAT(@T_TRACENUMBER,''BANCOR'',RIGHT(concat(replicate(''0'', 2),(SELECT CONVERT(VARCHAR(2), MOTIVO_RECHAZO) FROM SNP_MSG_ORDENES WHERE CORRELATIVO=@T_ID_DEBITO AND cuit_eo=@T_CUIT AND ID_ARCHIVO=@T_ID_ARCHIVO AND NRO_ARCHIVO=@T_NRO_ARCHIVO)), 2), REPLICATE('' '',74)),74),
										 LEFT(CONCAT(@T_TRACENUMBER,REPLICATE('' '',74)),74),
										 @RO_NUM_SECUENCIA_ADICIONAL,
										 RIGHT(@T_TRACENUMBER, 7)
										 );
		INSERT INTO dbo.ITF_DD_PRESENTADOS_EMITIDOS_AUX (LINEA) VALUES (replace(@RI_REGISTRO_INDIVIDUAL, ''.'', ''''));
	END 


	----------------------------- Actualizar secuencial unico -------------------------------------
	UPDATE dbo.ITF_MASTER_PARAMETROS SET NUMERICO_1 = (NUMERICO_1 + 1) WHERE CODIGO = 148;
	-----------------------------------------------------------------------------------------------

	
	IF (@Excedente = 0)
	BEGIN		     	       				
	
	FETCH NEXT FROM CursorDD INTO @T_ID_DEBITO, @T_JTS_OID, @T_MONEDA, @T_IMPORTE, @T_FECHA_VTO,@T_FECHA_COMP,@T_CBU, @T_REFERENCIA, @T_CODIGO_CLIENTE, @T_CUIT, @T_ID_ARCHIVO_REVERSADO,@T_CLIENTE_PAGADOR,@T_PRES_1ER_VTO,@T_PRES_2DO_VTO,@T_ID_ARCHIVO,@T_NRO_ARCHIVO
	
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

	SET @FL_TOTALES_DE_CONTROL = concat((RIGHT(concat(replicate(''0'', 6), @SumaEntidad), 6)), (RIGHT(concat(replicate(''0'', 4), @SumaSucursal), 4)));
	SET @FL_SUMA_TOTAL_DEBITO_LOTE = RIGHT(concat(replicate(''0'', 12), (replace((SELECT convert(NUMERIC(15,2),sum(convert(NUMERIC,substring(linea,30,10)))/100) FROM ITF_DD_PRESENTADOS_EMITIDOS_AUX WHERE LINEA LIKE ''6%'' AND ID>(SELECT max(id) FROM ITF_DD_PRESENTADOS_EMITIDOS_AUX WHERE LINEA LIKE ''5%'') ), ''.'', ''''))), 12); 
	SET @FL_SUMA_TOTAL_CREDITO_LOTE = RIGHT(replicate(''0'', 12), 12);

	SET @TotalesDebitos += @SumaImportes;
	
	
	SET @FL_NUMERO_LOTE = RIGHT(concat(replicate(''0'', 7), (SELECT COUNT(*) FROM ITF_DD_PRESENTADOS_EMITIDOS_AUX WHERE LINEA LIKE ''5%'' and id>(select max(id) from ITF_DD_PRESENTADOS_EMITIDOS_AUX where linea like ''1%''))), 7);

	SET @FL_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 6), (SELECT COUNT(*) FROM ITF_DD_PRESENTADOS_EMITIDOS_AUX WHERE (LINEA LIKE ''6%'' or linea like ''7%'') and id>(select max(id) from ITF_DD_PRESENTADOS_EMITIDOS_AUX where linea like ''5%''))), 6); 
   	
   	SET @FL_TOTALES_DE_CONTROL = (RIGHT(concat(replicate(''0'', 10), (SELECT sum(convert(numeric,substring(linea,4,8)))
																	FROM ITF_DD_PRESENTADOS_EMITIDOS_AUX
																	WHERE LINEA LIKE ''6%'' 
																	AND ID>(SELECT max(id) 
																			FROM ITF_DD_PRESENTADOS_EMITIDOS_AUX 
																			WHERE LINEA LIKE ''5%''))), 10))

	
	
	SET @FL_FIN_LOTE = concat(@FL_ID_REG, @FL_CODIGO_CLASE_TRANSAC, @FL_CANT_REG_INDIVIDUAL_ADICIONAL, @FL_TOTALES_DE_CONTROL, @FL_SUMA_TOTAL_DEBITO_LOTE, @FL_SUMA_TOTAL_CREDITO_LOTE, @FL_RESERVADO1, @FL_RESERVADO2, @FL_RESERVADO3, @FL_REG_ENTIDAD_ORIGEN, @FL_NUMERO_LOTE);
			
	INSERT INTO dbo.ITF_DD_PRESENTADOS_EMITIDOS_AUX (LINEA) VALUES (replace(@FL_FIN_LOTE, ''.'', ''''));

	---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-------------Grabamos el Fin de Archivo ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	SET @FA_CANT_LOTES = RIGHT(concat(replicate(''0'', 6), @FL_NUMERO_LOTE), 6);
	SET @CantRegistrosPrev = (SELECT (CASE WHEN (@CantRegistros + 4) % 10 = 0 THEN ((@CantRegistros + 4)/10) ELSE (FLOOR((@CantRegistros + 4)/10) + 1) END));
	SET @FA_NUMERO_BLOQUES = RIGHT(concat(replicate(''0'', 6), @CantRegistrosPrev), 6);
	
	SET @FA_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 8), @CantRegistros), 8);
			
	SET @FA_TOTALES_DE_CONTROL = @FL_TOTALES_DE_CONTROL; --igualo al totales de control de fin de lote pq tiene que ser igual
			
	SET @FA_SUMA_TOTAL_DEBITOS = RIGHT(concat(replicate(''0'', 12), (replace((SELECT convert(NUMERIC(15,2),sum(convert(NUMERIC,substring(linea,30,10)))/100) FROM ITF_DD_PRESENTADOS_EMITIDOS_AUX WHERE LINEA LIKE ''6%'' AND ID>(SELECT max(id) FROM ITF_DD_PRESENTADOS_EMITIDOS_AUX WHERE LINEA LIKE ''1%'') ), ''.'', ''''))), 12); 
			
	SET @FA_SUMA_TOTAL_CREDITOS = RIGHT(concat(replicate(''0'', 12), (replace(@TotalesCreditos, ''.'', ''''))),12);
	
			
	SET @FA_TOTALES_DE_CONTROL = (RIGHT(concat(replicate(''0'', 10), (SELECT sum(convert(numeric,substring(linea,4,8)))
																	FROM ITF_DD_PRESENTADOS_EMITIDOS_AUX
																	WHERE LINEA LIKE ''6%'' 
																	AND ID>(SELECT max(id) 
																			FROM ITF_DD_PRESENTADOS_EMITIDOS_AUX 
																			WHERE LINEA LIKE ''1%''))), 10))

	SET @FA_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 8), (SELECT sum(convert(numeric,substring(linea,5,6)))
	  																		 FROM ITF_DD_PRESENTADOS_EMITIDOS_AUX 
																			 WHERE LINEA LIKE ''8%''
																			 AND ID>(SELECT max(ID) FROM ITF_DD_PRESENTADOS_EMITIDOS_AUX WHERE LINEA LIKE ''1%''))), 8);
	

		 SET @FA_CANT_LOTES = RIGHT(concat(replicate(''0'', 6), (SELECT count(*) --le su,o uno al count por la linea que estamos por insertar (9%)
																  FROM ITF_DD_PRESENTADOS_EMITIDOS_AUX 
																  WHERE  LINEA LIKE ''5%'' AND ID>=(SELECT max(id) 
																  		  		FROM ITF_DD_PRESENTADOS_EMITIDOS_AUX 
																  		  		WHERE LINEA LIKE ''1%''))), 6);

	

	
	SET @FA_NUMERO_BLOQUES = RIGHT(concat(replicate(''0'', 6), (SELECT ceiling (convert(NUMERIC,(count(*)+1))/10) --le su,o uno al count por la linea que estamos por insertar (9%)
																  FROM ITF_DD_PRESENTADOS_EMITIDOS_AUX 
																  WHERE  ID>=(SELECT max(id) 
																  		  		FROM ITF_DD_PRESENTADOS_EMITIDOS_AUX 
																  		  		WHERE LINEA LIKE ''1%''))), 6);



	SET @FA_FIN_ARCHIVO = concat(@FA_ID_REG, @FA_CANT_LOTES, @FA_NUMERO_BLOQUES, @FA_CANT_REG_INDIVIDUAL_ADICIONAL, @FA_TOTALES_DE_CONTROL, @FA_SUMA_TOTAL_DEBITOS, @FA_SUMA_TOTAL_CREDITOS, @FA_RESERVADO);

	
	INSERT INTO dbo.ITF_DD_PRESENTADOS_EMITIDOS_AUX (LINEA) VALUES (@FA_FIN_ARCHIVO);
	
				
	SET @FL_NUMERO_LOTE = CAST(@FL_NUMERO_LOTE AS NUMERIC) + 1;
	SET @FL_NUMERO_LOTE = RIGHT(concat(replicate(''0'', 7), @FL_NUMERO_LOTE), 7);
	------------------------------------------------------------------------------------------------------------------------------------------------------------------

END
');


execute('
CREATE OR ALTER   PROCEDURE [dbo].[SP_DD_RECHAZADOS_RECIBIDOS]
	@TICKET NUMERIC(16)
AS
BEGIN 

 --	DECLARE 	@TICKET NUMERIC(16)=2
	/******** Variables Cabecera de Archivo **********************************/
	DECLARE @IdRegistro VARCHAR(1);
	DECLARE @CodigoPrioridad VARCHAR(2);
	DECLARE @DestinoInmediato VARCHAR(10);
	DECLARE @HoraPresentacion NUMERIC(4);
	DECLARE @IdentificadorArchivo VARCHAR(1);
	DECLARE @TamanoRegistro NUMERIC(3);
	DECLARE @CodigoFormato NUMERIC(1);
	DECLARE @FactorBloque NUMERIC(2);
	DECLARE @CodigoReferencia VARCHAR(8);
	DECLARE @NombreOrigenInmediato VARCHAR(23);
	DECLARE @NombreDestinoInmediato VARCHAR(23);

	/******** Variables Cabecera de Lote **********************************/
	DECLARE @FechaVencimiento DATE;
	DECLARE @FechaCompensacion DATE;
	DECLARE @ClaseTransaccion NUMERIC(3);
	DECLARE @ReservadoLote VARCHAR(46);
	DECLARE @ReservadoLoteCeros VARCHAR(3);
	DECLARE @CodigoOrigen  NUMERIC(1);
	DECLARE @CodigoRegistro VARCHAR(3);
	DECLARE @IdEntidadOrigen NUMERIC(8);
	declare @NumeroLote NUMERIC(7);

	/******** Variables Registro Individual de Cheques y Ajustes *************/
	DECLARE @CodTransaccion VARCHAR(2);
	DECLARE @EntidadDebitar VARCHAR(8);
	DECLARE @ReservadoRI VARCHAR(1);
	DECLARE @CuentaDebitar VARCHAR(17);
	DECLARE @Importe NUMERIC(10) = 0;     
	DECLARE @ReferenciaUnivoca VARCHAR(15);
	DECLARE @IdClientePegador VARCHAR(22);
	DECLARE @InfoAdicional VARCHAR(2);
	DECLARE @RegistrosAdicionales VARCHAR(1);
	DECLARE @ContadorRegistros VARCHAR(15);

	DECLARE @CodRechazo VARCHAR (2);

	--SE VAN A USAR ESTOS CAMPOS COMO CLAVE EN LUGAR DEL TRACENUMBER  
	
	DECLARE @Entidad_RI VARCHAR(4);	-- SE CAMBIA TIPO A VARCHAR PORQUE AHORA NO SE VALIDA MAS EL REG INDIVIDUAL
	DECLARE @Sucursal_RI VARCHAR(4); -- SE CAMBIA TIPO A VARCHAR PORQUE AHORA NO SE VALIDA MAS EL REG INDIVIDUAL
	DECLARE @IdClientePegador_RI VARCHAR(4); -- SE CAMBIA TIPO A VARCHAR PORQUE AHORA NO SE VALIDA MAS EL REG INDIVIDUAL
	DECLARE @NumeroCuenta_RI VARCHAR(12); -- SE CAMBIA TIPO A VARCHAR PORQUE AHORA NO SE VALIDA MAS EL REG INDIVIDUAL
	DECLARE @ReferenciaUnivoca_RI VARCHAR(12); -- SE CAMBIA TIPO A VARCHAR PORQUE AHORA NO SE VALIDA MAS EL REG INDIVIDUAL

	DECLARE @ExisteRI NUMERIC(1) = 0; --para saber si hay al menos 1 lote
	
	/******** Variables FIN DE LOTE *************/

	--DECLARE @RegIndivAdic NUMERIC(6);
	DECLARE @TotalesControl NUMERIC(10);
	DECLARE @SumaDebLote NUMERIC(12);
	DECLARE @SumaCredLote NUMERIC(12);
	DECLARE @ReservadoFL VARCHAR(40);

	/******** Variables FIN DE ARCHIVO *************/

	DECLARE @CantLotesFA NUMERIC(6);
	DECLARE @NumBloquesFA NUMERIC(6);
	DECLARE @CantRegAdFA NUMERIC (8);
	DECLARE @TotalesControlFA NUMERIC(10);
	DECLARE @ReservadoFA VARCHAR(39);

	/*Validaciones generales */
	
	DECLARE @updRecepcion VARCHAR(1);
	DECLARE @correlativo NUMERIC(10,0)=0;
	DECLARE @NroArchivo NUMERIC(15,0)= (SELECT ISNULL(MAX(NRO_ARCHIVO),0) FROM dbo.SNP_MSG_ORDENES)+1;

	IF(0=(SELECT COUNT(*) FROM ITF_DD_RECHAZADOS_RECIBIDOS_AUX
	WHERE LINEA LIKE ''1%''))
	RAISERROR (''Error - Faltan registros.'', 16, 1);
	IF(0=(SELECT COUNT(*) FROM ITF_DD_RECHAZADOS_RECIBIDOS_AUX
	WHERE LINEA LIKE ''5%''))
	RAISERROR (''Error - Faltan registros.'', 16, 1);
	IF(0=(SELECT COUNT(*) FROM ITF_DD_RECHAZADOS_RECIBIDOS_AUX
	WHERE LINEA LIKE ''8%''))
	RAISERROR (''Error - Faltan registros.'', 16, 1);
	IF(0=(SELECT COUNT(*) FROM ITF_DD_RECHAZADOS_RECIBIDOS_AUX
	WHERE LINEA LIKE ''9%''))
	RAISERROR (''Error - Faltan registros.'', 16, 1);


	--#validacion2
	IF ((SELECT COUNT(*)
	FROM ITF_DD_RECHAZADOS_RECIBIDOS_AUX
	WHERE LINEA LIKE ''1%'' OR LINEA LIKE ''9%'') > 2 )
	RAISERROR(''Error - Deben haber solo 1 reg CA y 1 reg FA'', 16, 1);


	--#validacion3
	IF(
	(SELECT COUNT(1) as Orden
	WHERE 1=(
	SELECT count(1)
		WHERE EXISTS
	(SELECT CONVERT(INT,SUBSTRING(LINEA,1,1))
		FROM ITF_DD_RECHAZADOS_RECIBIDOS_AUX
		WHERE ID IN
	(SELECT ID-1
			FROM ITF_DD_RECHAZADOS_RECIBIDOS_AUX
			WHERE LINEA LIKE ''8%'')
			AND CONVERT(INT,SUBSTRING(LINEA,1,1)) NOT IN (5,6,7)
	))
		OR 1=(
	SELECT count(1)
		WHERE
	EXISTS
	(SELECT CONVERT(INT,SUBSTRING(LINEA,1,1))
		FROM ITF_DD_RECHAZADOS_RECIBIDOS_AUX
		WHERE ID IN
	(SELECT ID+1
			FROM ITF_DD_RECHAZADOS_RECIBIDOS_AUX
			WHERE LINEA LIKE ''8%'')
			AND CONVERT(INT,SUBSTRING(LINEA,1,1)) NOT IN (5,9)
	))
		OR 1=(
	SELECT count(1)
		WHERE
	EXISTS
	(SELECT CONVERT(INT,SUBSTRING(LINEA,1,1))
		FROM ITF_DD_RECHAZADOS_RECIBIDOS_AUX
		WHERE ID IN
	(SELECT ID-1
			FROM ITF_DD_RECHAZADOS_RECIBIDOS_AUX
			WHERE LINEA LIKE ''5%'')
			AND CONVERT(INT,SUBSTRING(LINEA,1,1)) NOT IN (1,8)
	))
		OR 1=(
	SELECT count(1)
		WHERE
	EXISTS
	(SELECT CONVERT(INT,SUBSTRING(LINEA,1,1))
		FROM ITF_DD_RECHAZADOS_RECIBIDOS_AUX
		WHERE ID IN
	(SELECT ID+1
			FROM ITF_DD_RECHAZADOS_RECIBIDOS_AUX
			WHERE LINEA LIKE ''5%'')
			AND CONVERT(INT,SUBSTRING(LINEA,1,1)) NOT IN (6,7,8)
	))) <> 0
	)
	RAISERROR(''El orden de los registros NACHA es incorrecto'', 16, 1);



	------validaciones #5 #6 #7 y #8

	--#5 y 7
	DECLARE @sumaEntidades_RI NUMERIC = 0;
	DECLARE @sumaSucursales_RI NUMERIC = 0;
	DECLARE @sumaEntidades_RIaux NUMERIC = 0;
	DECLARE @sumaSucursales_RIaux NUMERIC = 0;

	DECLARE @sumaTotalCtrl_FL NUMERIC;
	DECLARE @totControl_FA NUMERIC;

	DECLARE @excedenteSuc NUMERIC = 0;

	--#6 y 8
	DECLARE @sumaDebitos_RI NUMERIC;
	DECLARE @sumaCreditos_RI NUMERIC;

	DECLARE @controlDebitos_FL NUMERIC;
	DECLARE @controlCreditos_FL NUMERIC;

	DECLARE @totalDebitos_FA NUMERIC;
	DECLARE @totalCreditos_FA NUMERIC;

--seteo suma deb y cred 

	SELECT -- debitos
		@sumaDebitos_RI = sum(CAST(substring(LINEA, 30, 10) AS NUMERIC)),
		@sumaEntidades_RI = sum(CAST(substring(LINEA, 4, 4) AS NUMERIC)),
		@sumaSucursales_RI = sum(CAST(substring(LINEA, 8, 4) AS NUMERIC))
	FROM ITF_DD_RECHAZADOS_RECIBIDOS_AUX
	WHERE LINEA LIKE ''6%'' --OR LINEA LIKE ''7%'';

	/*SELECT --creditos
		@sumaCreditos_RI = sum(CAST(substring(LINEA, 30, 10) AS NUMERIC)),
		@sumaEntidades_RIaux = sum(CAST(substring(LINEA, 4, 4) AS NUMERIC)),
		@sumaSucursales_RIaux = sum(CAST(substring(LINEA, 8, 4) AS NUMERIC))
	FROM ITF_DD_RECHAZADOS_RECIBIDOS_AUX
	WHERE LINEA LIKE ''622%'';*/

	SET @sumaEntidades_RI += isNull(@sumaEntidades_RIaux,0);
	SET @sumaSucursales_RI += isNull(@sumaSucursales_RIaux,0);
	
	--seteo total control y total de importes FA
	SELECT
		@totControl_FA = CAST(substring(linea, 22, 10) AS NUMERIC),
		@totalDebitos_FA = CAST(substring(linea, 32, 12) AS NUMERIC),
		@totalCreditos_FA = CAST(substring(linea, 44, 12) AS NUMERIC)
	FROM ITF_DD_RECHAZADOS_RECIBIDOS_AUX
	WHERE LINEA LIKE ''9%'';


	--CHEQUEO SI HAY EXCEDENTE #5 Y 7
	IF(LEN(@sumaSucursales_RI) > 4)
BEGIN
		SET @excedenteSuc = CAST(LEFT(@sumaSucursales_RI,len(@sumaSucursales_RI)-4) AS NUMERIC);
		SET @sumaSucursales_RI = RIGHT(@sumaSucursales_RI, 4);
	--ME QUEDO CON LAS 4 CIFRAS SIGNIFICATIVAS
	END
	SET @sumaEntidades_RI = @sumaEntidades_RI + @excedenteSuc;
	--LE SUMO EL EXCEDENTE, SI NO HAY SUMO 0

	--seteo suma totales control y debitos de FL
	SELECT
		@sumaTotalCtrl_FL = SUM(CAST(substring(linea, 11, 10) AS NUMERIC)),
		@controlDebitos_FL = sum(CAST(substring(LINEA, 21, 12) AS NUMERIC)),
		@controlCreditos_FL = sum(CAST(substring(LINEA, 33, 12) AS NUMERIC))
	FROM ITF_DD_RECHAZADOS_RECIBIDOS_AUX
	WHERE LINEA LIKE ''8%'';

	--#validacion5
	IF(CONCAT(@sumaEntidades_RI, RIGHT(CONCAT(REPLICATE(''0'',3), @sumaSucursales_RI ),4)) <> @sumaTotalCtrl_FL)
	RAISERROR(''No concuerda la suma Ent/Suc con control FL'', 16, 1);
	--#validacion7
	IF(RIGHT(@sumaTotalCtrl_FL,10) <> @totControl_FA)
	RAISERROR(''No concuerda la suma de TotalesControl de FL con control FA'', 16, 1);


	--#validacion6 debitos
	IF(@sumaDebitos_RI <> @totalDebitos_FA OR @controlDebitos_FL <> @totalDebitos_FA)
	RAISERROR(''No concuerda la suma de Debitos individuales con el Total Debitos'', 16, 1);

	--#validacion6 creditos
	IF( 0 <> @controlCreditos_FL OR 0 <> @totalCreditos_FA)
	RAISERROR('' Total Creditos incorrectos '', 16, 1);


	--#validacion8
   /*	IF((@controlDebitos_FL + @controlCreditos_FL) <>  (@totalDebitos_FA + @totalCreditos_FA))
	RAISERROR(''No concuerda la suma de Debitos de FL con Total Importe FA'', 16, 1);
*/

	--fin----validaciones #5 #6 #7 y #8





	DECLARE @LINEA VARCHAR(95);
	DECLARE deb_cursor CURSOR FOR 
SELECT LINEA
	FROM dbo.ITF_DD_RECHAZADOS_RECIBIDOS_AUX

	OPEN deb_cursor

	FETCH NEXT FROM deb_cursor INTO @LINEA

	WHILE @@FETCH_STATUS = 0  
BEGIN


		--#validacion4
		if(DATALENGTH(@LINEA) <> 94)
		RAISERROR(''Se encontraron registros de longitud incorrecta'', 16,1);

		SET @IdRegistro = substring(@LINEA, 1, 1);

		IF(@IdRegistro NOT IN(''1'',''5'',''6'',''7'',''8'',''9'') ) --validacion de id reg
      	 RAISERROR (''Id Registro invalido'', 16, 1);


		/* Cabecera de Archivo */
		IF (@IdRegistro = ''1'') 
      BEGIN
			--variables de cabecera de archivo
			SET @CodigoPrioridad = substring(@LINEA,2,2);
			SET @DestinoInmediato = substring(@LINEA,4 ,10);
			SET @FechaVencimiento = substring(@LINEA, 24, 6);
			SET @HoraPresentacion = substring(@LINEA, 30, 4);
			SET @IdentificadorArchivo = substring(@LINEA, 34, 1);
			SET @TamanoRegistro = substring(@LINEA, 35, 3);
			SET @FactorBloque = substring(@LINEA, 38, 2);
			SET @CodigoFormato = substring(@LINEA, 40, 1);
			SET @NombreDestinoInmediato = substring(@LINEA, 41, 23);
			SET @NombreOrigenInmediato = substring(@LINEA, 64, 23);
			SET @CodigoReferencia = substring(@LINEA, 87, 8);


			IF(@CodigoPrioridad<>''01'')
			RAISERROR (''Codigo Prioridad debe ser 01'', 16, 1);
			

			IF(@TamanoRegistro<>''094'')
			RAISERROR (''Tamaño registro debe ser 094'', 16, 1);
			
			IF(@FactorBloque<>''10'')
			RAISERROR (''Factor Bloque debe ser 10'', 16, 1);
			
						
			IF(@CodigoFormato<>''1'')
			RAISERROR (''Codigo Formato debe ser 1'', 16, 1);
			
			--#validacion11
			IF(substring(@DestinoInmediato, 2, 4) <> ''0311'')
			RAISERROR (''Destino inmediato debe ser 0311'', 16, 1);

		END

		IF (@IdRegistro = ''5'') 
      BEGIN

			--variables cabecera de lote
			SET @ClaseTransaccion = substring(@LINEA, 2, 3);
			SET @ReservadoLote = substring(@LINEA, 5, 46);
			--VALIDACION RESERVADO VACIO
			SET @CodigoRegistro = substring(@LINEA, 51, 3);

			SET @FechaVencimiento = CAST(substring(@LINEA, 64, 6) AS DATE);
			--VALIDACION FECHAS
			SET @FechaCompensacion = CAST(substring(@LINEA, 70, 6) AS DATE);
			SET @ReservadoLoteCeros = substring(@LINEA, 76, 3);
			--VALIDACION RESERVADO 000
			SET @CodigoOrigen = substring(@LINEA, 79, 1);

			SET @IdEntidadOrigen = substring(@LINEA, 80, 8);

			SET @NumeroLote = substring(@LINEA, 88, 7);

			IF (@ClaseTransaccion <> 200) 
      		RAISERROR (''Codigo de clase de transaccion debe ser 200'', 16, 1);
			

			IF (@CodigoRegistro <> ''PPD'') 
    		RAISERROR (''Codigo de registro debe ser TRC'', 16, 1);
			

			IF (@FechaVencimiento > @FechaCompensacion) 
      		RAISERROR (''Fecha Presentacion debe ser anterior a vencimiento'', 16, 1);
		
			
		END


		/*FIN DE LOTE*/
		IF (@IdRegistro = ''8'') 
      BEGIN
			SET @ClaseTransaccion = substring(@LINEA, 2, 3);
			--SET @RegIndivAdic = substring(@LINEA, 5, 6);
			--SET @TotalesControl = substring(@LINEA, 11,10);
			SET @ReservadoFL = substring(@LINEA, 45, 35);
			SET @IdEntidadOrigen = substring(@LINEA, 80, 8);
			SET @NumeroLote = substring(@LINEA, 88, 7);


			IF (@ClaseTransaccion <> 200) 
			RAISERROR (''Codigo de clase de transaccion debe ser 200'', 16, 1);
		
		END

		/*FIN DE ARCHIVO*/
		IF (@IdRegistro = ''9'') 
      BEGIN
			SET @CantLotesFA = substring(@LINEA, 2, 6);
			SET @NumBloquesFA = substring(@LINEA, 8, 6);
			SET @CantRegAdFA = substring(@LINEA, 14, 8);
			SET @TotalesControlFA  = substring(@LINEA, 22, 10);
			SET @ReservadoFA  = substring(@LINEA, 56, 39);

			--#validacion9
			IF(@ExisteRI = 1 AND (SELECT COUNT(*) FROM ITF_DD_RECHAZADOS_RECIBIDOS_AUX WHERE LINEA LIKE ''5%'') <> @CantLotesFA)
				RAISERROR(''No coincide la cantidad de LOTES con la informada en el reg FA'', 16, 1);
			
			--#validacion10
			IF((SELECT count(*) FROM ITF_DD_RECHAZADOS_RECIBIDOS_AUX WHERE LINEA LIKE ''6%'' OR LINEA LIKE ''7%'') <> @CantRegAdFA)
				RAISERROR(''No coincide la cantidad de registros ind y ad con la informada en el reg FA'', 16, 1);

		END


		/* Registro Individual */
		IF (@IdRegistro = ''6'') 
        BEGIN
      		SET @ExisteRI = 1;
      		
			SET @CodTransaccion = substring(@LINEA, 2, 2);
			SET @EntidadDebitar = substring(@LINEA, 4, 8);
			SET @ReservadoRI = substring(@LINEA, 12, 1);
			SET @CuentaDebitar = substring(@LINEA, 13, 16);
			SET @Importe = CONVERT(NUMERIC(15,2),substring(@LINEA, 30, 10))/100;
			SET @ReferenciaUnivoca = substring(@LINEA, 40, 15);
			SET @IdClientePegador = substring(@LINEA, 55, 22);
			SET @InfoAdicional = substring(@LINEA, 77, 2);
			SET @RegistrosAdicionales = substring(@LINEA, 79, 1);
			SET @ContadorRegistros = substring(@LINEA, 80, 15);
			/* Trace Number */


			SET @Entidad_RI = substring(@ContadorRegistros, 1, 4);
			SET @Sucursal_RI = substring(@ContadorRegistros, 5, 4);
			SET @IdClientePegador_RI = RIGHT(@IdClientePegador, 4);
			SET @NumeroCuenta_RI = RIGHT(@CuentaDebitar, 12);
			SET @ReferenciaUnivoca_RI = RIGHT(@ReferenciaUnivoca, 12);


			IF (@RegistrosAdicionales NOT IN(''1'',''0'')) 
      		BEGIN
				RAISERROR (''Campo Registro adicional invalido'', 16, 1);
			END
		END
		
				/* Registro Rechazo */
		IF (@IdRegistro = ''7'' AND substring(@LINEA, 2, 2)=''99'') 
      	BEGIN
      	
		IF(@TICKET>0)
		BEGIN
		
			
			  DECLARE @NumCuenta NUMERIC(20);
			  DECLARE @JTS_OID NUMERIC(20);
		      DECLARE @Moneda INT;
		      IF(LEFT(@InfoAdicional,1)=0)
				SET @Moneda = (SELECT C6399 FROM MONEDAS WHERE C6403=''N'');
		      IF(LEFT(@InfoAdicional,1)=1)
				SET @Moneda = (SELECT C6399 FROM MONEDAS WHERE C6403=''D'');
		   
		      SET @NumCuenta = CAST(@CuentaDebitar AS NUMERIC);
		      
		      SET @JTS_OID = (SELECT JTS_OID FROM SALDOS WHERE CUENTA = @NumCuenta AND SUCURSAL = CONVERT(INT,RIGHT(@EntidadDebitar,4)) AND MONEDA=@Moneda);
			  
			  --SELECT substring(@LINEA, 4, 3) AS LINEA,@NumCuenta AS NumCuenta, @JTS_OID AS JTS_OID, CONVERT(INT,RIGHT(@EntidadDebitar,4)) AS SUCURSAL,
			  --@Moneda AS Moneda

			 				
		      UPDATE dbo.SNP_DEBITOS
			  SET ESTADO = ''RC'', MOTIVO_RECHAZO = substring(@LINEA, 5, 2)
			  WHERE ID_DEBITO = (SELECT TOP 1 ID_DEBITO FROM SNP_DEBITOS WHERE SALDO_JTS_OID = @JTS_OID AND IMPORTE = @Importe AND MONEDA = @Moneda AND FECHA_VTO = @FechaVencimiento AND FECHA_COMP =@FechaCompensacion AND ESTADO<>''RC'');
			
			  UPDATE SNP_MSG_ORDENES
			  SET ESTADO=''RC'', MOTIVO_RECHAZO = substring(@LINEA, 5, 2)
			  WHERE (TRACE_N_1PRE=substring(@LINEA,80,15) OR TRACE_N_2PRE=substring(@LINEA,80,15))
			  AND CLIENTE_PAGADOR=@IdClientePegador
			  AND (PRESENTACION_PRIMER_VTO=@FechaVencimiento OR PRESENTACION_SEGUNDO_VTO=@FechaVencimiento)
			  AND ESTADO<>''RC''

			  INSERT INTO dbo.ITF_DD_RECHAZOS_RECIBIDOS (ID_TICKET,  FECHAPROCESO, CODIGO_TRANSACCION, SUCURSAL, MONEDA, CUENTA, IMPORTE,  REFERENCIA_UNIVOCA, ID_CLIENTE_PAGADOR,  MOTIVO_RECHAZO, INFO_ADICIONAL)
       		  VALUES (@TICKET, (SELECT FECHAPROCESO FROM PARAMETROS), @CodTransaccion, CONVERT(INT,RIGHT(@EntidadDebitar,4)), @Moneda, @CuentaDebitar, @Importe,  @ReferenciaUnivoca, @IdClientePegador,  substring(@LINEA, 4, 3) ,@InfoAdicional);

		END
		
		END
		

		Final:
		FETCH NEXT FROM deb_cursor INTO @LINEA
	END

	CLOSE deb_cursor
	DEALLOCATE deb_cursor
-- a ordenes entramos con cliente pagador, fecha presentacion 1 o 2 y tracenumber, estado rc y motivo rechazo
END;
');

