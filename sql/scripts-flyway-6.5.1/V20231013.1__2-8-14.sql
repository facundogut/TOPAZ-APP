EXECUTE('

ALTER TABLE VTA_TRANSFERENCIAS ALTER COLUMN OP_INFO_REF  VARCHAR (15); 

INSERT INTO dbo.ITF_MASTER (TZ_LOCK, ID, DESCRIPCION, OBJ_KETTLE, P0_MODO, P0_TIPO, P0_CAPTION, P0_CONSTANTE, P1_MODO, P1_TIPO, P1_CAPTION, P1_CONSTANTE, P2_MODO, P2_TIPO, P2_CAPTION, P2_CONSTANTE, P3_MODO, P3_TIPO, P3_CAPTION, P3_CONSTANTE, P4_MODO, P4_TIPO, P4_CAPTION, P4_CONSTANTE, P5_MODO, P5_TIPO, P5_CAPTION, P5_CONSTANTE, P6_MODO, P6_TIPO, P6_CAPTION, P6_CONSTANTE, P7_MODO, P7_TIPO, P7_CAPTION, P7_CONSTANTE, P8_MODO, P8_TIPO, P8_CONSTANTE, P8_CAPTION, P9_MODO, P9_TIPO, P9_CAPTION, P9_CONSTANTE, TIPO_OBJ, COMENTARIO, ID_REPORTE, MODO_EJECUCION)
VALUES (0, 222, ''TRANSFERENCIA MP0'', ''ITF_TRANSFERENCIA_MINORISTA_RECIBIDAS.kjb'', '''', '''', '''', '' '', '''', '''', '''', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', ''J'', '' '', 0, ''M'')

INSERT INTO dbo.ITF_MASTER (TZ_LOCK, ID, DESCRIPCION, OBJ_KETTLE, P0_MODO, P0_TIPO, P0_CAPTION, P0_CONSTANTE, P1_MODO, P1_TIPO, P1_CAPTION, P1_CONSTANTE, P2_MODO, P2_TIPO, P2_CAPTION, P2_CONSTANTE, P3_MODO, P3_TIPO, P3_CAPTION, P3_CONSTANTE, P4_MODO, P4_TIPO, P4_CAPTION, P4_CONSTANTE, P5_MODO, P5_TIPO, P5_CAPTION, P5_CONSTANTE, P6_MODO, P6_TIPO, P6_CAPTION, P6_CONSTANTE, P7_MODO, P7_TIPO, P7_CAPTION, P7_CONSTANTE, P8_MODO, P8_TIPO, P8_CONSTANTE, P8_CAPTION, P9_MODO, P9_TIPO, P9_CAPTION, P9_CONSTANTE, TIPO_OBJ, COMENTARIO, ID_REPORTE, MODO_EJECUCION)
VALUES (0, 224, ''TRANSFERENCIA MPP'', ''ITF_TRANSFERENCIA_MINORISTA_PRESENTADAS.kjb'', '''', '''', '''', '' '', '''', '''', '''', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', ''J'', '' '', 0, ''M'')

INSERT INTO dbo.ITF_MASTER_PARAMETROS (CODIGO, CODIGO_INTERFACE, FUNCIONALIDAD, ALFA_1, ALFA_2, ALFA_3, NUMERICO_1, NUMERICO_2, FECHA, IMPORTE_1, IMPORTE_2, TZ_LOCK)
VALUES (149, 11, ''Sec COELSA 2.8.13'', '' '', '' '', '' '', 3, 0, ''2033-07-08'', 0, 0, 0)

INSERT INTO dbo.ITF_MASTER_PARAMETROS (CODIGO, CODIGO_INTERFACE, FUNCIONALIDAD, ALFA_1, ALFA_2, ALFA_3, NUMERICO_1, NUMERICO_2, FECHA, IMPORTE_1, IMPORTE_2, TZ_LOCK)
VALUES (176, 0, ''Cont Arch. COELSAMPP'', '' '', '' '', '' '', 1, 0, ''2033-07-07'', 0, 0, 0)

')


EXECUTE('

CREATE TABLE dbo.ITF_TRAN_MINORISTA_PRESENTADAS_AUX
	(
	ID          INT IDENTITY NOT NULL,
	LINEA       VARCHAR (200),
	CORRELATIVO NUMERIC (12),
	PRIMARY KEY (ID)
	)

CREATE TABLE dbo.ITF_TRAN_MINORISTA_RECIBIDAS_AUX
	(
	ID    INT IDENTITY NOT NULL,
	LINEA VARCHAR (200)
	)
	
')

EXECUTE('
CREATE   PROCEDURE [dbo].[SP_TRAN_MINORISTA_PRESENTADAS]
   @TICKET NUMERIC(16)
AS 
BEGIN

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- Autor: Fabio Alexis Menendez
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

------------ Limpieza de tabla auxiliar --------------------
TRUNCATE TABLE dbo.ITF_TRAN_MINORISTA_PRESENTADAS_AUX;
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
DECLARE @CA_CODIGO_REFERENCIA VARCHAR(8) = ''MIN     ''; --Se conforma con espacios vacíos.

DECLARE @CA_CABECERA VARCHAR(200);

SET @CA_CABECERA = concat(@CA_ID_REG, @CA_CODIGO_PRIORIDAD, @CA_DESTINO_INMEDIATO, @CA_ORIGEN_INMEDIATO, @CA_FECHA_PRESENTACION, @CA_HORA_PRESENTACION, @CA_IDENTIFICADOR_ARCHIVO, @CA_TAMANNO_REGISTRO, @CA_FACTOR_BLOQUE, @CA_CODIGO_FORMATO, @CA_NOMBRE_DEST_INMEDIATO, @CA_NOMBRE_ORIG_INMEDIATO, @CA_CODIGO_REFERENCIA);


--- Variables cabecera lote (CL)
DECLARE @CL_ID_REG VARCHAR(1) = ''5''; -- fijo
DECLARE @CL_CODIGO_CLASE_TRANSAC VARCHAR(3) = ''220''; -- fijo 
DECLARE @CL_NOM_EMPRESA VARCHAR(16) = ''PARTICULARES    '';
DECLARE @CL_CRITERIO_EMPRESA VARCHAR(20) = ''TRANSFERENCIAS      '';
DECLARE @CL_ID_EMPRESA VARCHAR(10);
DECLARE @CL_TIPO_REGISTRO VARCHAR(3) = ''CTX''; -- fijo 
DECLARE @CL_DESCRIP_TRANSAC VARCHAR(10) = ''          ''; -- fijo
DECLARE @CL_FECHA_PRESENTACION VARCHAR(6) = convert(VARCHAR,(SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)), 12);
DECLARE @CL_FECHA_VENCIMIENTO VARCHAR(6) = convert(VARCHAR,(SELECT FECHAPROXIMOPROCESO FROM PARAMETROS WITH(NOLOCK)), 12); 
DECLARE @CL_RESERVADO_CL VARCHAR(3) = ''003''; -- fijo
DECLARE @CL_CODIGO_ORIGEN VARCHAR(1) = ''0''; -- fijo
DECLARE @CL_ID_ENTIDAD_ORIGEN VARCHAR(8) = (SELECT ''031100''+CAST((SELECT NUMERICO FROM PARAMETROSGENERALES WHERE CODIGO=40) AS VARCHAR)); 
DECLARE @CL_NUMERO_LOTE VARCHAR(7) = RIGHT(concat(replicate(''0'', 7), 0), 7); -- numero del lote

DECLARE @CL_CABECERA VARCHAR(200);

	---------------- Grabar Cabecera Archivo ---------------------------
	INSERT INTO dbo.ITF_TRAN_MINORISTA_PRESENTADAS_AUX (LINEA) VALUES (@CA_CABECERA);
	--------------------------------------------------------------------

------ Variables registro individual ( RI) ------------
DECLARE @RI_ID_REG VARCHAR(1) = ''6''; -- fijo  
DECLARE @RI_ENTIDAD_CREDITO VARCHAR(8);
DECLARE @RI_RESERVADO VARCHAR(1) = ''0''; -- fijo 
DECLARE @RI_CUENTA_CREDITO VARCHAR(17); 
DECLARE @RI_IMPORTE VARCHAR(11); 
DECLARE @RI_REFERENCIA_UNIVOCA VARCHAR(15);
DECLARE @RI_CLIENTE_PAGADOR VARCHAR(22); 
DECLARE @RI_INFO_ADICIONAL VARCHAR(2);
DECLARE @RI_REGISTRO_ADICIONAL VARCHAR(1); 
DECLARE @RI_CONTADOR_REGISTRO VARCHAR(15);
							
DECLARE @RI_REGISTRO_INDIVIDUAL VARCHAR (200);


------ Variables registro ajuste ( RA) ------------

DECLARE @RA_ID_REG_ADICIONAL VARCHAR(6) = ''705   '';
DECLARE @RA_CONTADOR_REGISTRO_ORIGEN VARCHAR(15);
DECLARE @RA_NUMERO_CERTIFIFADO VARCHAR(6) = ''      '';
DECLARE @RA_ENTIDAD_ORIGINAL VARCHAR(8) = ''        '';
DECLARE @RA_OTRO_MOTIVO_RECH VARCHAR(44) = ''                                             '';

--- Variables fin de lote FL
DECLARE @FL_ID_REG VARCHAR(1) = ''8''; -- fijo 
DECLARE @FL_CODIGO_CLASE_TRANSAC VARCHAR(3) = ''220''; -- fijo 
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
DECLARE @T_ENTIDAD_ACREDITAR VARCHAR(8);
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
DECLARE @T_ID_CREDITO NUMERIC(15,0);
DECLARE @T_CUIT_ORD NUMERIC(11,0)=0;
DECLARE @CUIT NUMERIC(11,0)=0;
DECLARE @T_ID_ARCHIVO_REVERSADO NUMERIC(9,0);
DECLARE @T_REVERSADO INT=0;
DECLARE @T_NOMBRE_ORDENANTE VARCHAR(70);
DECLARE @T_CUIT_BEN NUMERIC(11,0)=0;
DECLARE @T_NOMBRE_BENEFICIARIO VARCHAR(70);
DECLARE @T_TIPO_DOC VARCHAR(4);

	IF((SELECT COUNT(1) FROM VTA_TRANSFERENCIAS WHERE OP_CLASE_TRANS=''E'' AND OP_MONEDA=1 AND ESTADO=''PP'')=0)
	BEGIN
	---------------- Grabar Cabecera Lote ---------------------------
	SET @CL_NUMERO_LOTE = RIGHT(concat(replicate(''0'', 7), (@CL_NUMERO_LOTE + 1)), 7);
	SET @CL_NOM_EMPRESA =  LEFT(concat('''',replicate('' '', 16)),16);
	SET @CL_CRITERIO_EMPRESA = replicate('' '', 20); -- AUN NO EXISTE AUTONUMERICO, FALTA DEFINIR 
	SET @CL_ID_EMPRESA = LEFT(concat(@T_CUIT_ORD,replicate('' '', 10)),10);
	SET @CL_CABECERA = concat(@CL_ID_REG, @CL_CODIGO_CLASE_TRANSAC, @CL_NOM_EMPRESA,@CL_CRITERIO_EMPRESA,@CL_ID_EMPRESA, @CL_TIPO_REGISTRO, @CL_DESCRIP_TRANSAC, @CL_FECHA_PRESENTACION, @CL_FECHA_VENCIMIENTO, @CL_RESERVADO_CL, @CL_CODIGO_ORIGEN, @CL_ID_ENTIDAD_ORIGEN, @CL_NUMERO_LOTE);
	INSERT INTO dbo.ITF_TRAN_MINORISTA_PRESENTADAS_AUX (LINEA) VALUES (@CL_CABECERA);
	END 
		
    --Condicion de reset del contador de reg individual
	IF ISNULL((SELECT a.FECHA FROM ITF_MASTER_PARAMETROS a WHERE a.CODIGO = 149), CAST(''01-01-1800'' AS DATETIME)) <> (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK))
    UPDATE dbo.ITF_MASTER_PARAMETROS SET NUMERICO_1 = 1, FECHA = (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)) WHERE CODIGO = 149;

SET @T_FECHA_COMP = (SELECT CONVERT(DATETIME, dbo.diaHabil ((SELECT (FECHAPROCESO + 1) FROM PARAMETROS WITH(NOLOCK)),''A'')) AS A);
SET @T_FECHA_VTO =  @T_FECHA_COMP;

DECLARE CursorTM CURSOR FOR

SELECT t.OP_NUMERO, v.JTS_OID_SALDO, t.OP_MONEDA, t.OP_IMPORTE, @T_FECHA_VTO, @T_FECHA_COMP, t.ORD_CBU, t.OP_NUMERO, s.C1803, t.ORD_NRO_DOC, t.ORD_NOMBRE, t.BEN_NRO_DOC, t.BEN_NOMBRE, t.BEN_TIPO_DOC
FROM VTA_TRANSFERENCIAS t INNER JOIN VTA_SALDOS v ON t.ORD_CBU=v.CTA_CBU AND t.OP_CLASE_TRANS=''E'' AND t.OP_MONEDA=1 AND t.ESTADO=''PP'' INNER JOIN SALDOS s ON v.JTS_OID_SALDO=s.JTS_OID
WHERE t.OP_CLASE_TRANS=''E'' AND t.OP_MONEDA=1 AND t.ESTADO=''PP''
ORDER BY t.ORD_NRO_DOC, t.OP_MONEDA

OPEN CursorTM
FETCH NEXT FROM CursorTM INTO @T_ID_CREDITO, @T_JTS_OID, @T_MONEDA, @T_IMPORTE, @T_FECHA_VTO,@T_FECHA_COMP,@T_CBU, @T_REFERENCIA, @T_CODIGO_CLIENTE, @T_CUIT_ORD, @T_NOMBRE_ORDENANTE, @T_CUIT_BEN, @T_NOMBRE_BENEFICIARIO, @T_TIPO_DOC

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
	   	SET @FL_SUMA_TOTAL_DEBITO_LOTE = RIGHT(replicate(''0'', 12), 12);
	   	SET @FL_SUMA_TOTAL_CREDITO_LOTE = RIGHT(concat(replicate(''0'', 12), (replace(@SumaImportes, ''.'', ''''))), 12); 
	   	SET @TotalesCreditos += @SumaImportes;
	   	SET @FL_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 6), @Cant_Reg_Individual_Adicional), 6); 
	   	
	   	SET @FL_FIN_LOTE = concat(@FL_ID_REG, @FL_CODIGO_CLASE_TRANSAC, @FL_CANT_REG_INDIVIDUAL_ADICIONAL, @FL_TOTALES_DE_CONTROL, @FL_SUMA_TOTAL_DEBITO_LOTE, @FL_SUMA_TOTAL_CREDITO_LOTE, @FL_RESERVADO1, @FL_RESERVADO2, @FL_RESERVADO3, @FL_REG_ENTIDAD_ORIGEN, @FL_NUMERO_LOTE);
		
    
	
		INSERT INTO dbo.ITF_TRAN_MINORISTA_PRESENTADAS_AUX (LINEA) VALUES (replace(@FL_FIN_LOTE, ''.'', ''''));
		
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
		
		INSERT INTO dbo.ITF_TRAN_MINORISTA_PRESENTADAS_AUX (LINEA) VALUES (@FA_FIN_ARCHIVO);
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
		
		INSERT INTO dbo.ITF_TRAN_MINORISTA_PRESENTADAS_AUX (LINEA) VALUES (@CA_CABECERA);
		----------------------------------------------------------------------------------------------------------------------------------------------------------------------
		--------- Grabamos nueva Cabecera Lote ------------------------------------------------------------------------------------------------------------------------------------------------------

		SET @CUIT = @T_CUIT_ORD;
		SET @CL_NUMERO_LOTE = RIGHT(concat(replicate(''0'', 7), (@CL_NUMERO_LOTE + 1)), 7);
		SET @CL_NOM_EMPRESA =  LEFT(@T_NOMBRE_ORDENANTE,16);
		SET @CL_CRITERIO_EMPRESA = replicate('' '', 20); -- AUN NO EXISTE AUTONUMERICO, FALTA DEFINIR 
		SET @CL_ID_EMPRESA = LEFT(@T_CUIT_ORD,10);
		SET @CL_CABECERA = concat(@CL_ID_REG, @CL_CODIGO_CLASE_TRANSAC, @CL_NOM_EMPRESA,@CL_CRITERIO_EMPRESA,@CL_ID_EMPRESA, @CL_TIPO_REGISTRO, @CL_DESCRIP_TRANSAC, @CL_FECHA_PRESENTACION, @CL_FECHA_VENCIMIENTO, @CL_RESERVADO_CL, @CL_CODIGO_ORIGEN, @CL_ID_ENTIDAD_ORIGEN, @CL_NUMERO_LOTE);
		INSERT INTO dbo.ITF_TRAN_MINORISTA_PRESENTADAS_AUX (LINEA) VALUES (@CL_CABECERA);
		---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	END
	
   
	IF(@T_MONEDA=(SELECT C6399 FROM MONEDAS WHERE C6403=''N''))
	SET @CL_ID_ENTIDAD_ORIGEN  = (SELECT ''031100''+CAST((SELECT NUMERICO FROM PARAMETROSGENERALES WHERE CODIGO=40) AS VARCHAR));
	ELSE
	SET @CL_ID_ENTIDAD_ORIGEN  = (SELECT ''081100''+CAST((SELECT NUMERICO FROM PARAMETROSGENERALES WHERE CODIGO=40) AS VARCHAR));
	
	/* LOGICA PARA GRABAR LA CABECERA DE LOTE*/
	IF(@CUIT!=@T_CUIT_ORD OR @T_MONEDA!=@MONEDA )
	BEGIN
	
	IF(@CUIT!=0)
	BEGIN
	SET @FL_TOTALES_DE_CONTROL = concat((RIGHT(concat(replicate(''0'', 6), @SumaEntidad), 6)), (RIGHT(concat(replicate(''0'', 4), @SumaSucursal), 4)));
   	SET @FL_SUMA_TOTAL_DEBITO_LOTE = RIGHT(replicate(''0'', 12), 12); 
   	SET @FL_SUMA_TOTAL_CREDITO_LOTE = RIGHT(concat(replicate(''0'', 12), (replace(@SumaImportes, ''.'', ''''))), 12); 
   	SET @TotalesCreditos += @SumaImportes;
   	SET @FL_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 6), @Cant_Reg_Individual_Adicional), 6); 
   	
   	SET @FL_FIN_LOTE = concat(@FL_ID_REG, @FL_CODIGO_CLASE_TRANSAC, @FL_CANT_REG_INDIVIDUAL_ADICIONAL, @FL_TOTALES_DE_CONTROL, @FL_SUMA_TOTAL_DEBITO_LOTE, @FL_SUMA_TOTAL_CREDITO_LOTE, @FL_RESERVADO1, @FL_RESERVADO2, @FL_RESERVADO3, @FL_REG_ENTIDAD_ORIGEN, @FL_NUMERO_LOTE);

	INSERT INTO dbo.ITF_TRAN_MINORISTA_PRESENTADAS_AUX (LINEA) VALUES (replace(@FL_FIN_LOTE, ''.'', ''''));
	
	SET @SumaImportes = 0;
	SET @SumaEntidad = 0;
	SET @SumaSucursal = 0;
	
	END
	
	SET @CUIT = @T_CUIT_ORD;
	SET @MONEDA = @T_MONEDA;
	SET @CL_NUMERO_LOTE = RIGHT(concat(replicate(''0'', 7), (@CL_NUMERO_LOTE + 1)), 7);
	SET @CL_NOM_EMPRESA =  LEFT(concat(@T_NOMBRE_ORDENANTE,replicate('' '', 16)),16);
	SET @CL_CRITERIO_EMPRESA = replicate('' '', 20); -- AUN NO EXISTE AUTONUMERICO, FALTA DEFINIR 
	SET @CL_ID_EMPRESA = LEFT(concat(@T_CUIT_ORD,replicate('' '', 10)),10);
		SET @CL_CABECERA = concat(@CL_ID_REG, @CL_CODIGO_CLASE_TRANSAC, @CL_NOM_EMPRESA,@CL_CRITERIO_EMPRESA,@CL_ID_EMPRESA, @CL_TIPO_REGISTRO, @CL_DESCRIP_TRANSAC, @CL_FECHA_PRESENTACION, @CL_FECHA_VENCIMIENTO, @CL_RESERVADO_CL, @CL_CODIGO_ORIGEN, @CL_ID_ENTIDAD_ORIGEN, @CL_NUMERO_LOTE);
		INSERT INTO dbo.ITF_TRAN_MINORISTA_PRESENTADAS_AUX (LINEA) VALUES (@CL_CABECERA);
	
	IF(@T_MONEDA=(SELECT C6399 FROM MONEDAS WHERE C6403=''N''))	
	SET @FL_REG_ENTIDAD_ORIGEN = (SELECT ''0311''+ RIGHT(concat(replicate(''0'', 4), CAST((SELECT NUMERICO FROM PARAMETROSGENERALES WHERE CODIGO=40) AS VARCHAR)), 4)); 
	ELSE
	SET @FL_REG_ENTIDAD_ORIGEN = (SELECT ''0811''+ RIGHT(concat(replicate(''0'', 4), CAST((SELECT NUMERICO FROM PARAMETROSGENERALES WHERE CODIGO=40) AS VARCHAR)), 4)); 
	END
		
	SELECT @T_SUCURSAL=SUCURSAL, @T_CUENTA=CUENTA FROM SALDOS WHERE JTS_OID=@T_JTS_OID;

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
	SET @RI_ENTIDAD_CREDITO = CONCAT(RIGHT(concat(replicate(''0'', 4), @T_COD_BANCO),4) , RIGHT(concat(replicate(''0'', 4), @T_SUCURSAL),4));
    SET @RI_CUENTA_CREDITO = RIGHT(concat(replicate(''0'', 17), @T_CUENTA), 17);
    SET @RI_REFERENCIA_UNIVOCA = RIGHT(concat(replicate(''0'', 15), @T_REFERENCIA), 15);
    
    IF(@T_TIPO_DOC =''CUIT'')
    SET @RI_CLIENTE_PAGADOR = CONCAT(''1'',@T_CUIT_BEN,''       073'');
    IF(@T_TIPO_DOC =''CUIL'')
    SET @RI_CLIENTE_PAGADOR = CONCAT(''2'',@T_CUIT_BEN,''       073'');
    IF(@T_TIPO_DOC =''CDI'')
    SET @RI_CLIENTE_PAGADOR = CONCAT(''3'',@T_CUIT_BEN,''       073'');
    
	SET @T_CODIGO_TRANSACCION = ''32'';
	
    IF(@CountExcedente>1)
	BEGIN
        SET @SumaSucursal += 0888;  --sumo la sucursal que hay que harcodear
        SET @SumaEntidad +=  @T_COD_BANCO;
        SET @SumaImportes += @T_IMPORTE;

        SET @RI_ENTIDAD_CREDITO = concat(replicate(''0'', 4), @T_COD_BANCO, ''0888'');
        SET @RI_CUENTA_CREDITO = RIGHT(concat(replicate(''0'', 17), ''88888888888''), 17);
        SET @RI_REFERENCIA_UNIVOCA = ''000088888888888'';

   
   	END
    ELSE --la razon de este else, es que SumaSucursal, cuando hay excedente tiene que acumular 0888
    BEGIN
        SET @SumaSucursal += @T_SUCURSAL;
		SET @SumaEntidad += @T_COD_BANCO;
		SET @SumaImportes += @T_IMPORTE;

	SET @RI_ENTIDAD_CREDITO = CONCAT(RIGHT(concat(replicate(''0'', 4), @T_COD_BANCO),4) , RIGHT(concat(replicate(''0'', 4), @T_SUCURSAL),4));
    SET @RI_CUENTA_CREDITO = RIGHT(concat(replicate(''0'', 17), @T_CUENTA), 17);
    SET @RI_REFERENCIA_UNIVOCA =  CONCAT(''VAR'',RIGHT(concat(replicate(''0'', 12), @T_REFERENCIA), 12));
    
    IF(@T_TIPO_DOC =''CUIT'')
    SET @RI_CLIENTE_PAGADOR = CONCAT(''1'',@T_CUIT_BEN,''       073'');
    IF(@T_TIPO_DOC =''CUIL'')
    SET @RI_CLIENTE_PAGADOR = CONCAT(''2'',@T_CUIT_BEN,''       073'');
    IF(@T_TIPO_DOC =''CDI'')
    SET @RI_CLIENTE_PAGADOR = CONCAT(''3'',@T_CUIT_BEN,''       073'');
 
    END

    
    SET @RI_IMPORTE = RIGHT(concat(replicate(''0'', 10), replace(CAST(@T_IMPORTE AS VARCHAR),''.'','''')), 10);
    --SET @RI_CODIGO_POSTAL = RIGHT(concat(''00'', replicate(''0'', 6), @T_CODIGO_POSTAL), 6);

    SET @RI_REGISTRO_ADICIONAL = ''0'';
    
    IF(@MONEDA=(SELECT C6399 FROM MONEDAS WHERE C6403=''N''))
    SET @RI_CONTADOR_REGISTRO = concat(''0311'', RIGHT(concat(replicate(''0'', 4), (''97'')), 4), RIGHT(concat(replicate(''0'', 7), (SELECT NUMERICO_1 FROM ITF_MASTER_PARAMETROS WHERE CODIGO = 149)), 7)); 
    ELSE
    SET @RI_CONTADOR_REGISTRO = concat(''0811'', RIGHT(concat(replicate(''0'', 4), (''97'')), 4), RIGHT(concat(replicate(''0'', 7), (SELECT NUMERICO_1 FROM ITF_MASTER_PARAMETROS WHERE CODIGO = 149)), 7)); 
     
        	
	SET @RI_REGISTRO_INDIVIDUAL = concat(@RI_ID_REG, @T_CODIGO_TRANSACCION, @RI_ENTIDAD_CREDITO, @RI_RESERVADO, @RI_CUENTA_CREDITO, @RI_IMPORTE, @RI_REFERENCIA_UNIVOCA, @RI_CLIENTE_PAGADOR, @RI_INFO_ADICIONAL, @RI_REGISTRO_ADICIONAL, @RI_CONTADOR_REGISTRO);
 
    INSERT INTO dbo.ITF_TRAN_MINORISTA_PRESENTADAS_AUX (LINEA, CORRELATIVO) VALUES (replace(@RI_REGISTRO_INDIVIDUAL, ''.'', ''''),@T_ID_CREDITO);
    UPDATE dbo.VTA_TRANSFERENCIAS SET ESTADO=''PR'' WHERE OP_NUMERO=@T_REFERENCIA;
	-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	/* Logica para agregar el registro adicional*/	
	IF(@CountExcedente<1) --@T_ID_ARCHIVO_REVERSADO=0 OR @T_ID_ARCHIVO_REVERSADO IS NULL
	BEGIN
	
	SET @RO_CONCEPTO = LEFT(CONCAT(@T_CUIT_BEN, @T_NOMBRE_BENEFICIARIO, REPLICATE('' '',80)),80);
	SET @RO_NUM_SECUENCIA_ADICIONAL= RIGHT(concat(replicate(''0'', 4), (@RO_NUM_SECUENCIA_ADICIONAL + 1)), 4);

	SET @RI_REGISTRO_INDIVIDUAL = concat(''705'',@RO_CONCEPTO,@RO_NUM_SECUENCIA_ADICIONAL,RIGHT(concat(replicate(''0'', 7), (SELECT NUMERICO_1 FROM ITF_MASTER_PARAMETROS WHERE CODIGO = 149)), 7));
	INSERT INTO dbo.ITF_TRAN_MINORISTA_PRESENTADAS_AUX (LINEA) VALUES (replace(@RI_REGISTRO_INDIVIDUAL, ''.'', ''''));
	END  
	/*ELSE 
	BEGIN 
	SET @RO_NUM_SECUENCIA_ADICIONAL= RIGHT(concat(replicate(''0'', 4), (@RO_NUM_SECUENCIA_ADICIONAL + 1)), 4);
	SET @RI_REGISTRO_INDIVIDUAL = concat(''705'',(SELECT CONVERT(VARCHAR(6), FECHA_VENCIMIENTO, 12) FROM SNP_MSG_ORDENES WHERE CORRELATIVO=@T_ID_ARCHIVO_REVERSADO), LEFT(CONCAT(@T_ID_ARCHIVO_REVERSADO,REPLICATE('' '',74)),74),@RO_NUM_SECUENCIA_ADICIONAL,RIGHT(concat(replicate(''0'', 7), (SELECT NUMERICO_1 FROM ITF_MASTER_PARAMETROS WHERE CODIGO = 149)), 7));
	INSERT INTO dbo.ITF_TRAN_MINORISTA_PRESENTADAS_AUX (LINEA) VALUES (replace(@RI_REGISTRO_INDIVIDUAL, ''.'', ''''));
	END */


	----------------------------- Actualizar secuencial unico -------------------------------------
	UPDATE dbo.ITF_MASTER_PARAMETROS SET NUMERICO_1 = (NUMERICO_1 + 1) WHERE CODIGO = 149;
	-----------------------------------------------------------------------------------------------

	
	IF (@Excedente = 0)
	BEGIN		     	       				
	
	FETCH NEXT FROM CursorTM INTO @T_ID_CREDITO, @T_JTS_OID, @T_MONEDA, @T_IMPORTE, @T_FECHA_VTO,@T_FECHA_COMP,@T_CBU, @T_REFERENCIA, @T_CODIGO_CLIENTE, @T_CUIT_ORD, @T_NOMBRE_ORDENANTE, @T_CUIT_BEN, @T_NOMBRE_BENEFICIARIO, @T_TIPO_DOC
	
	SET @CountExcedente = 0;

	END
	
END

CLOSE CursorTM
DEALLOCATE CursorTM


IF @SumaSucursal > 9999
BEGIN
	SET @SobranteSucursal = CAST(substring(CAST(@SumaSucursal AS VARCHAR), 1, (len(@SumaSucursal) - 4)) AS NUMERIC);
  	SET @SumaEntidad += @SobranteSucursal;
	SET @SumaSucursal = CAST(RIGHT(@SumaSucursal, 4) AS NUMERIC);
END

	SET @FL_TOTALES_DE_CONTROL = concat((RIGHT(concat(replicate(''0'', 6), @SumaEntidad), 6)), (RIGHT(concat(replicate(''0'', 4), @SumaSucursal), 4)));
	SET @FL_SUMA_TOTAL_DEBITO_LOTE =  RIGHT(replicate(''0'', 12), 12);
	SET @FL_SUMA_TOTAL_CREDITO_LOTE = RIGHT(concat(replicate(''0'', 12), (replace(@SumaImportes, ''.'', ''''))), 12);
	SET @TotalesCreditos += @SumaImportes;
	SET @FL_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 6), @Cant_Reg_Individual_Adicional), 6); 
	
	
	
	
	SET @FL_FIN_LOTE = concat(@FL_ID_REG, @FL_CODIGO_CLASE_TRANSAC, @FL_CANT_REG_INDIVIDUAL_ADICIONAL, @FL_TOTALES_DE_CONTROL, @FL_SUMA_TOTAL_DEBITO_LOTE, @FL_SUMA_TOTAL_CREDITO_LOTE, @FL_RESERVADO1, @FL_RESERVADO2, @FL_RESERVADO3, @FL_REG_ENTIDAD_ORIGEN, @FL_NUMERO_LOTE);
			
	INSERT INTO dbo.ITF_TRAN_MINORISTA_PRESENTADAS_AUX (LINEA) VALUES (replace(@FL_FIN_LOTE, ''.'', ''''));

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
			
	
	
	INSERT INTO dbo.ITF_TRAN_MINORISTA_PRESENTADAS_AUX (LINEA) VALUES (@FA_FIN_ARCHIVO);
	
				
	SET @FL_NUMERO_LOTE = CAST(@FL_NUMERO_LOTE AS NUMERIC) + 1;
	SET @FL_NUMERO_LOTE = RIGHT(concat(replicate(''0'', 7), @FL_NUMERO_LOTE), 7);
	------------------------------------------------------------------------------------------------------------------------------------------------------------------

END

')

EXECUTE('
CREATE   PROCEDURE [dbo].[SP_TRAN_MINORISTA_RECIBIDAS]
	@TICKET NUMERIC(16),
	@MONEDA_IN NUMERIC(1),
	@CODREGISTRO_IN VARCHAR(3),
	@MSJ 	VARCHAR(500) OUTPUT
AS
BEGIN 
    
    
    -- Cerrar el cursor si está abierto
	IF CURSOR_STATUS(''global'', ''tran_cursor'') >= 0
	BEGIN
	    IF CURSOR_STATUS(''global'', ''tran_cursor'') = 1
	    BEGIN
	        CLOSE tran_cursor;
	    	DEALLOCATE tran_cursor;
	    END
    END 
    
    
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
	DECLARE @VFechaVencimientoCA VARCHAR(6);
	DECLARE @FechaVencimientoCA DATE;

	/******** Variables Cabecera de Lote **********************************/
	DECLARE @FechaVencimiento DATE;
	DECLARE @FechaCompensacion DATE;
	DECLARE @VFechaVencimiento VARCHAR(6);
	DECLARE @VFechaCompensacion VARCHAR(6);
	DECLARE @ClaseTransaccion VARCHAR(3);
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
	DECLARE @VImporte VARCHAR(10);     
	DECLARE @Importe NUMERIC(10) = 0;     
	DECLARE @ReferenciaUnivoca VARCHAR(15);
	DECLARE @IdClientePegador VARCHAR(22);
	DECLARE @InfoAdicional VARCHAR(2);
	DECLARE @RegistrosAdicionales VARCHAR(1);
	DECLARE @ContadorRegistros VARCHAR(15);
	DECLARE @CBU VARCHAR(22);
	DECLARE @CUIL VARCHAR(11);
	DECLARE @Tipo_transferencia NUMERIC(3,0);
	DECLARE @CodRechazo VARCHAR (3);

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
	
	
	DECLARE @ESTADOSUC VARCHAR(1);
	DECLARE @SFecVenc VARCHAR(6)
	DECLARE @SFecComp VARCHAR(6)
	DECLARE @SFecVencCA VARCHAR(6)
	      
	      
	/*Validaciones generales */
	
	DECLARE @updRecepcion VARCHAR(1);
	DECLARE @correlativo NUMERIC(10,0)=0;
	DECLARE @Reverso_Directo NUMERIC(1);
	
	SET @MSJ = '''';
	
	------------Inicio Primera Validacion ----------------
	
	IF(0=(SELECT COUNT(*) FROM ITF_TRAN_MINORISTA_RECIBIDAS_AUX
	WHERE LINEA LIKE ''1%''))
	BEGIN
	  SET @MSJ = ''Error - Falta registro Cabecera de Archivo'';
	  RETURN
	END
	
	IF(0=(SELECT COUNT(*) FROM ITF_TRAN_MINORISTA_RECIBIDAS_AUX
	WHERE LINEA LIKE ''5%''))
	BEGIN
	  SET @MSJ = ''Error - Falta registro Cabecera de Lote.'';
	  RETURN
	END
	
	IF(0=(SELECT COUNT(*) FROM ITF_TRAN_MINORISTA_RECIBIDAS_AUX
	WHERE LINEA LIKE ''8%''))
	BEGIN
	  SET @MSJ = ''Error - Falta registro Control Fin de Lote.'';
	  RETURN
	END
	
	IF(0=(SELECT COUNT(*) FROM ITF_TRAN_MINORISTA_RECIBIDAS_AUX
	WHERE LINEA LIKE ''9%''))
	BEGIN
	  SET @MSJ = ''Error - Falta registro Control Fin de Archivo.'';
	  RETURN
	END
	
	IF ((SELECT COUNT(1) FROM ITF_TRAN_MINORISTA_RECIBIDAS_AUX
		WHERE SUBSTRING(LINEA,1,1) NOT IN(''1'',''5'',''6'',''7'',''8'',''9'')) > 0) --validacion de id reg
  	BEGIN
  	  SET @MSJ = ''Id Registro invalido'';
	  RETURN
    END

	--#validacion2
	IF ((SELECT COUNT(*)
	FROM ITF_TRAN_MINORISTA_RECIBIDAS_AUX
	WHERE LINEA LIKE ''1%'' OR LINEA LIKE ''9%'') > 2 )
	BEGIN
	  SET @MSJ = ''Error - Deben haber solo 1 reg CA y 1 reg FA'';
	  RETURN
	END

	
	--#validacion3
	IF(
	(SELECT COUNT(1) as Orden
	WHERE 1=(
	SELECT count(1)
		WHERE EXISTS
	(SELECT CONVERT(INT,SUBSTRING(LINEA,1,1))
		FROM ITF_TRAN_MINORISTA_RECIBIDAS_AUX
		WHERE ID IN
	(SELECT ID-1
			FROM ITF_TRAN_MINORISTA_RECIBIDAS_AUX
			WHERE LINEA LIKE ''8%'')
			AND CONVERT(INT,SUBSTRING(LINEA,1,1)) NOT IN (5,6,7)
	))
		OR 1=(
	SELECT count(1)
		WHERE
	EXISTS
	(SELECT CONVERT(INT,SUBSTRING(LINEA,1,1))
		FROM ITF_TRAN_MINORISTA_RECIBIDAS_AUX
		WHERE ID IN
	(SELECT ID+1
			FROM ITF_TRAN_MINORISTA_RECIBIDAS_AUX
			WHERE LINEA LIKE ''8%'')
			AND CONVERT(INT,SUBSTRING(LINEA,1,1)) NOT IN (5,9)
	))
		OR 1=(
	SELECT count(1)
		WHERE
	EXISTS
	(SELECT CONVERT(INT,SUBSTRING(LINEA,1,1))
		FROM ITF_TRAN_MINORISTA_RECIBIDAS_AUX
		WHERE ID IN
	(SELECT ID-1
			FROM ITF_TRAN_MINORISTA_RECIBIDAS_AUX
			WHERE LINEA LIKE ''5%'')
			AND CONVERT(INT,SUBSTRING(LINEA,1,1)) NOT IN (1,8)
	))
		OR 1=(
	SELECT count(1)
		WHERE
	EXISTS
	(SELECT CONVERT(INT,SUBSTRING(LINEA,1,1))
		FROM ITF_TRAN_MINORISTA_RECIBIDAS_AUX
		WHERE ID IN
	(SELECT ID+1
			FROM ITF_TRAN_MINORISTA_RECIBIDAS_AUX
			WHERE LINEA LIKE ''5%'')
			AND CONVERT(INT,SUBSTRING(LINEA,1,1)) NOT IN (6,7,8)
	))) <> 0
	)
	BEGIN
	  SET @MSJ = ''El orden de los registros NACHA es incorrecto'';
	  RETURN
	END

	
	IF (SELECT COUNT(1)
			FROM ITF_TRAN_MINORISTA_RECIBIDAS_AUX
			WHERE LINEA LIKE ''5%'') <> (SELECT COUNT(1)
			FROM ITF_TRAN_MINORISTA_RECIBIDAS_AUX
			WHERE LINEA LIKE ''8%'')
	BEGIN
	  SET @MSJ = ''Nro de Registros de Cabecera de Lote es distinto al Final de Lote'';
	  RETURN
	END 
	
	IF( (SELECT COUNT(1) FROM ITF_TRAN_MINORISTA_RECIBIDAS_AUX
		 WHERE LEN(LINEA) <> 94) > 0)
	BEGIN
	  SET @MSJ = ''Existe(n) fila(s) con longitud incorrecta'';
	  RETURN
	END 
	------validaciones #5 #6 #7 y #8
	
	IF ((select count(1)
		FROM ITF_TRAN_MINORISTA_RECIBIDAS_AUX
		WHERE LINEA LIKE ''6%''
		  AND IsNumeric(substring(LINEA, 30, 10)) = 0) > 0)
	BEGIN
	  SET @MSJ = ''Importe Incorrecto en el Registro Individual'';
	  RETURN
	END 
	
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
	SELECT -- creditos
		@sumaCreditos_RI = sum(CAST(substring(LINEA, 30, 10) AS NUMERIC)),
		@sumaEntidades_RI = sum(CAST(substring(LINEA, 4, 4) AS NUMERIC)),
		@sumaSucursales_RI = sum(CAST(substring(LINEA, 8, 4) AS NUMERIC))
	FROM ITF_TRAN_MINORISTA_RECIBIDAS_AUX
	WHERE LINEA LIKE ''6%''

	SET @sumaEntidades_RI += isNull(@sumaEntidades_RIaux,0);
	SET @sumaSucursales_RI += isNull(@sumaSucursales_RIaux,0);
	
	--seteo total control y total de importes FA
	SELECT
		@totControl_FA = CAST(substring(linea, 22, 10) AS NUMERIC),
		@totalDebitos_FA = CAST(substring(linea, 32, 12) AS NUMERIC),
		@totalCreditos_FA = CAST(substring(linea, 44, 12) AS NUMERIC)
	FROM ITF_TRAN_MINORISTA_RECIBIDAS_AUX
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
	FROM ITF_TRAN_MINORISTA_RECIBIDAS_AUX
	WHERE LINEA LIKE ''8%'';


	--#validacion5
	IF(CONCAT(@sumaEntidades_RI, RIGHT(CONCAT(REPLICATE(''0'',3), @sumaSucursales_RI),4)) <> @sumaTotalCtrl_FL)
	BEGIN
	    SET @MSJ = ''No concuerda la suma Ent/Suc con control FL'';
		RETURN
	END
	
	--#validacion7
	IF(RIGHT(@sumaTotalCtrl_FL,10) <> @totControl_FA)
	BEGIN
		SET @MSJ = ''No concuerda la suma de Totales Control de FL con control FA'';
		RETURN
	END
	

	--#validacion6 debitos
	IF(@sumaDebitos_RI  <> @controlDebitos_FL /*AND @sumaDebitos_RI <> @totalDebitos_FA*/)
	BEGIN
		SET @MSJ = ''No concuerda la suma de Debitos individuales con el Total Debitos Fin Lote'';
		RETURN
	END
	
	IF(/*@sumaDebitos_RI  <> @controlDebitos_FL AND*/ @sumaDebitos_RI <> @totalDebitos_FA)
	BEGIN
		SET @MSJ = ''No concuerda la suma de Debitos individuales con el Total Debitos Fin Archivo'';
		RETURN
	END
	
	--#validacion6 creditos
	IF( @sumaCreditos_RI <> @controlCreditos_FL /*AND @sumaCreditos_RI <> @totalCreditos_FA*/)
	BEGIN
		SET @MSJ = ''No concuerda la suma de Creditos individuales con el Total Creditos Fin Lote'';
		RETURN
	END
	
	IF( /*@sumaCreditos_RI <> @controlCreditos_FL AND*/ @sumaCreditos_RI <> @totalCreditos_FA)
	BEGIN
		SET @MSJ = ''No concuerda la suma de Creditos individuales con el Total Creditos Fin Archivo'';
		RETURN
	END
	
	DECLARE @LINEA VARCHAR(95);
	DECLARE @ID VARCHAR(95);
	
	DECLARE @NroArchivo NUMERIC(15,0)
	
	DECLARE tran_cursor CURSOR FOR 
	SELECT ID, LINEA
	FROM dbo.ITF_TRAN_MINORISTA_RECIBIDAS_AUX
	
	OPEN tran_cursor

	FETCH NEXT FROM tran_cursor INTO @ID, @LINEA

	WHILE @@FETCH_STATUS = 0  
	BEGIN

		--SET @NroArchivo = (SELECT ISNULL(MAX(ID_DEBITO),0) FROM dbo.SNP_DEBITOS)+1;
		
		SET @IdRegistro = substring(@LINEA, 1, 1);
		
		/* Cabecera de Archivo */
		IF (@IdRegistro = ''1'') 
      BEGIN
			--variables de cabecera de archivo
			SET @CodigoPrioridad = substring(@LINEA,2,2);
			SET @DestinoInmediato = substring(@LINEA,4 ,10);
			SET @VFechaVencimientoCA = substring(@LINEA, 24, 6);
			SET @HoraPresentacion = substring(@LINEA, 30, 4);
			SET @IdentificadorArchivo = substring(@LINEA, 34, 1);
			SET @TamanoRegistro = substring(@LINEA, 35, 3);
			SET @FactorBloque = substring(@LINEA, 38, 2);
			SET @CodigoFormato = substring(@LINEA, 40, 1);
			SET @NombreDestinoInmediato = substring(@LINEA, 41, 23);
			SET @NombreOrigenInmediato = substring(@LINEA, 64, 23);
			SET @CodigoReferencia = substring(@LINEA, 87, 8);


			IF(@CodigoPrioridad<>''01'')
			BEGIN
				SET @MSJ = ''Codigo Prioridad debe ser 01'';
				RETURN
			END
			

			IF(@TamanoRegistro<>''094'')
			BEGIN
				SET @MSJ =  ''Tamaño registro debe ser 094'';
				RETURN
			END
			
			IF(@FactorBloque<>''10'')
			BEGIN
				SET @MSJ =  ''Factor Bloque debe ser 10'';
				RETURN
			END
			
						
			IF(@CodigoFormato<>''1'')
			BEGIN
				SET @MSJ =  ''Codigo Formato debe ser 1'';
				RETURN
			END
			
			--#validacion11
			/*IF(substring(@DestinoInmediato, 2, 4) <> ''0311'')
			BEGIN
				SET @MSJ = ''Destino inmediato debe ser 0311'';
				RETURN
			END*/
			
		END

		IF (@IdRegistro = ''5'') 
      BEGIN

			--variables cabecera de lote
			SET @ClaseTransaccion = substring(@LINEA, 2, 3);
			SET @ReservadoLote = substring(@LINEA, 5, 46);
			--VALIDACION RESERVADO VACIO
			SET @CodigoRegistro = substring(@LINEA, 51, 3);

			SET @VFechaVencimiento = substring(@LINEA, 64, 6);
			--VALIDACION FECHAS
			SET @VFechaCompensacion = substring(@LINEA, 70, 6);
			SET @ReservadoLoteCeros = substring(@LINEA, 76, 3);
			--VALIDACION RESERVADO 000
			SET @CodigoOrigen = substring(@LINEA, 79, 1);

			SET @IdEntidadOrigen = substring(@LINEA, 80, 8);

			SET @NumeroLote = substring(@LINEA, 88, 7);

			IF (@ClaseTransaccion <> ''220'') 
			BEGIN
				SET @MSJ = ''Codigo de clase de transaccion debe ser 220'' ;
				RETURN
			END

			IF (@CodigoRegistro <> @CODREGISTRO_IN) 
			BEGIN
				SET @MSJ =  CONCAT(''Codigo de registro debe ser '', @CODREGISTRO_IN);
				RETURN;
			END
			
			IF LTRIM(@VFechaVencimiento) = '''' OR @VFechaVencimiento IS NULL
			BEGIN
				SET @MSJ =  ''Fecha Presentacion es obligatorio'';
				RETURN;
			END
			
			IF LTRIM(@VFechaCompensacion) = '''' OR @VFechaCompensacion IS NULL
			BEGIN
				SET @MSJ =  ''Fecha Compensacion es obligatorio'';
				RETURN;
			END

			IF LTRIM(@VFechaVencimientoCA) = '''' OR @VFechaVencimientoCA IS NULL
			BEGIN
				SET @MSJ =  ''Fecha Presentación es obligatorio'';
				RETURN;
			END
			
			IF ISDATE(@VFechaVencimiento) = 1 AND ISDATE(@VFechaCompensacion) = 1
			BEGIN
				SET @FechaVencimiento = convert(DATE, @VFechaVencimiento);
				SET @FechaCompensacion = convert(DATE, @VFechaCompensacion);
				
				IF (@FechaVencimiento > @FechaCompensacion) 
				BEGIN
					SET @MSJ =  ''Fecha Presentacion debe ser anterior a Compensacion'';
					RETURN;
				END
			END
			
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


			IF (@ClaseTransaccion <> ''220'') 
			BEGIN
				SET @MSJ =  ''Codigo de clase de transaccion debe ser 220'';
				RETURN
			END
		
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
			IF(@ExisteRI = 1 AND (SELECT COUNT(*) FROM ITF_TRAN_MINORISTA_RECIBIDAS_AUX WHERE LINEA LIKE ''5%'') <> @CantLotesFA)
			BEGIN
				SET @MSJ = ''No coincide la cantidad de LOTES con la informada en el reg FA'';
				RETURN
			END
			
			--#validacion10
			IF((SELECT count(*) FROM ITF_TRAN_MINORISTA_RECIBIDAS_AUX WHERE LINEA LIKE ''6%'' OR LINEA LIKE ''7%'') <> @CantRegAdFA)
			BEGIN
				SET @MSJ = ''No coincide la cantidad de registros ind y ad con la informada en el reg FA'';
				RETURN
			END

		END

		/* Registro Individual */
		IF (@IdRegistro = ''6'') 
      BEGIN
      		SET @ExisteRI = 1;
      		
			SET @CodTransaccion = substring(@LINEA, 2, 2);
			SET @EntidadDebitar = substring(@LINEA, 4, 8);
			SET @ReservadoRI = substring(@LINEA, 12, 1);
			SET @CuentaDebitar = substring(@LINEA, 13, 17);
			SET @VImporte = substring(@LINEA, 30, 10);
			--SET @Importe = CONVERT(NUMERIC(15,2),substring(@LINEA, 30, 10))/100;
			SET @ReferenciaUnivoca = substring(@LINEA, 40, 15);
			SET @IdClientePegador = substring(@LINEA, 55, 22);
			SET @InfoAdicional = substring(@LINEA, 77, 2);
			SET @RegistrosAdicionales = substring(@LINEA, 79, 1);
			SET @ContadorRegistros = substring(@LINEA, 80, 15);
			SET @Tipo_transferencia = (SELECT  ID_TIPO FROM VTA_TRANSFERENCIAS_TIPOS WHERE ADICIONAL_PRESENT=@InfoAdicional AND tz_lock=0);
			/* Trace Number */
			IF(@RegistrosAdicionales=''1'')
			BEGIN
			SET @CBU = CONCAT(substring(@LINEA, 5, 7), substring(@LINEA, 16, 12));
			SET @CUIL = (SELECT TOP 1 SUBSTRING(LINEA,4,11) FROM ITF_TRAN_MINORISTA_RECIBIDAS_AUX WHERE ID>@ID AND LINEA=''7%'');
			SET @CodRechazo = (SELECT TOP 1 SUBSTRING(LINEA,4,3) FROM ITF_TRAN_MINORISTA_RECIBIDAS_AUX WHERE ID>@ID AND LINEA=''7%'');
			END
			
			SET @Entidad_RI = substring(@ContadorRegistros, 1, 4);
			SET @Sucursal_RI = substring(@ContadorRegistros, 5, 4);
			SET @IdClientePegador_RI = RIGHT(@IdClientePegador, 4);
			SET @NumeroCuenta_RI = RIGHT(@CuentaDebitar, 12);
			SET @ReferenciaUnivoca_RI = RIGHT(@ReferenciaUnivoca, 12);

			IF(@MONEDA_IN=0)
			BEGIN
				IF(LEFT(@EntidadDebitar,4)<>''0311'')
				BEGIN
      			SET @MSJ =  ''Entidad no valida con moneda'';
				RETURN
				END
				IF(LEFT(@InfoAdicional,1)<>''0'')
				BEGIN
      			SET @MSJ =  ''Registro no valida con moneda'';
				RETURN
				END
			END
			
			IF(@MONEDA_IN=1)
			BEGIN
				IF(LEFT(@EntidadDebitar,4)<>''0811'')
				BEGIN
      			SET @MSJ =  ''Entidad no valida con moneda'';
				RETURN
				END
				IF(LEFT(@InfoAdicional,1)<>''1'')
				BEGIN
      			SET @MSJ =  ''Registro no valida con moneda'';
				RETURN
				END
			END

			IF (@RegistrosAdicionales NOT IN(''1'',''0'')) 
      		BEGIN
      			SET @MSJ =  ''Campo Registro adicional invalido'';
      			PRINT @LINEA;
				RETURN
			END
	 		
	 		DECLARE @Moneda INT;
		      IF(LEFT(@InfoAdicional,1)=''0'')
				SET @Moneda = (SELECT C6399 FROM MONEDAS WHERE C6403=''N'');
		      IF(LEFT(@InfoAdicional,1)=''1'')
				SET @Moneda = (SELECT C6399 FROM MONEDAS WHERE C6403=''D'');
	
	------------Fin Primera Validacion ----------------
	 	
	IF(@TICKET>0)
	BEGIN TRY
		
	   	  DECLARE @FECHADATE DATETIME;
		  SET @FECHADATE = (SELECT FECHAPROCESO FROM PARAMETROS);
		  DECLARE @JTS_OID NUMERIC(10,0) = (SELECT JTS_OID_SALDO FROM VTA_SALDOS WHERE CTA_CBU=@CBU AND tz_lock=0);
	      
	      ----------------------- VALIDACIONES INCLUYENTES------------------------
	      ------------------------------------------------------------------------
	      
	      --Rechazos
	      IF @CodTransaccion=''31''
	      BEGIN
	      
	      	UPDATE dbo.VTA_TRANSFERENCIAS
			SET ESTADO = ''RC'' , FECHA_ESTADO=@FECHADATE , NUMERO_ASIENTO=@TICKET, MOTIVO_RECHAZO=@CodRechazo
			WHERE OP_CLASE_TRANS = ''E'' AND BEN_CBU = @CBU  AND OP_MONEDA=@Moneda AND OP_IMPORTE=@VImporte AND  OP_NUMERO=RIGHT(@ReferenciaUnivoca,12)			

			GOTO Final
	      END
	      
	      
		  --------------
		  ----NACHA R17
		  --------------
		  

		  IF ISNUMERIC(@CodTransaccion) = 0 or ISNUMERIC(@EntidadDebitar) = 0  OR ISNUMERIC(@ReservadoRI) = 0 OR ISNUMERIC(@CuentaDebitar) = 0
			 OR ISNUMERIC(@Importe) = 0 OR ISNUMERIC(@InfoAdicional) = 0 OR ISNUMERIC(@RegistrosAdicionales) = 0 OR ISNUMERIC(@ContadorRegistros) = 0
	      BEGIN
	      		INSERT INTO dbo.VTA_TRANSFERENCIAS (OP_NUMERO, NUMERO_ASIENTO,  OP_FECHA_PRES, OP_CLASE_TRANS, ESTADO, OP_MONEDA, OP_TIPO, BEN_CBU, OP_IMPORTE, BEN_JTS_OID_CUENTA, BEN_NRO_DOC, MOTIVO_RECHAZO, OP_FORMA_ING, FECHA_ESTADO, CONTABILIZADA, OP_INFO_REF )
				VALUES ((SELECT MAX(OP_NUMERO)+1 FROM VTA_TRANSFERENCIAS WHERE OP_CLASE_TRANS=''R''),@TICKET, @FECHADATE, ''R'', ''RC'', @Moneda, @Tipo_transferencia, @CBU, @VImporte, @JTS_OID, @CUIL,(SELECT CODIGO_NACHA FROM CLE_TIPO_CAUSAL WHERE CODIGO_DE_CAUSAL = 32), ''C'' , @FECHADATE, ''N'', RTRIM(LTRIM(@ReferenciaUnivoca)));
	      	GOTO Final
	      END

		  SET @Importe = CONVERT(NUMERIC(15,2),@VImporte)/100;
		  --------------
		  ----NACHA R93
		  --------------
		  
		  DECLARE @V93 NUMERIC(2);
	      DECLARE @FechaPro VARCHAR(10);
	      
	      SET @FechaPro = CONVERT(VARCHAR(10),(SELECT FECHAPROCESO FROM PARAMETROS),103);
	      SET @V93 = (SELECT COUNT(1) FROM FERIADOS WHERE (SUCURSAL=CONVERT(INT,RIGHT(@EntidadDebitar,4)) OR SUCURSAL=-1) AND DIA=FORMAT(@FECHADATE,''dd'') AND MES=FORMAT(@FECHADATE,''MM'') AND (ANIO=FORMAT(@FECHADATE,''yyyy'') OR ANIO=0)); 
	      
	      IF (@V93 > 0)
	      BEGIN
	      		INSERT INTO dbo.VTA_TRANSFERENCIAS (OP_NUMERO, NUMERO_ASIENTO,  OP_FECHA_PRES, OP_CLASE_TRANS, ESTADO, OP_MONEDA, OP_TIPO, BEN_CBU, OP_IMPORTE, BEN_JTS_OID_CUENTA, BEN_NRO_DOC, MOTIVO_RECHAZO, OP_FORMA_ING, FECHA_ESTADO, CONTABILIZADA, OP_INFO_REF )
				VALUES ((SELECT MAX(OP_NUMERO)+1 FROM VTA_TRANSFERENCIAS WHERE OP_CLASE_TRANS=''R''),@TICKET, @FECHADATE, ''R'', ''RC'', @Moneda, @Tipo_transferencia, @CBU, @VImporte, @JTS_OID, @CUIL,(SELECT CODIGO_NACHA FROM CLE_TIPO_CAUSAL WHERE CODIGO_DE_CAUSAL = 76), ''C'' , @FECHADATE, ''N'', RTRIM(LTRIM(@ReferenciaUnivoca)));
	      	GOTO Final
	      END
		  
		  --------------
		  ----NACHA R04
		  --------------
		  
		  DECLARE @V04 NUMERIC(2);
	      DECLARE @NumCuenta NUMERIC(20);
	      
	   	  
		  IF (ISNUMERIC(@CuentaDebitar) = 0)
	      BEGIN
	      		INSERT INTO dbo.VTA_TRANSFERENCIAS (OP_NUMERO, NUMERO_ASIENTO,  OP_FECHA_PRES, OP_CLASE_TRANS, ESTADO, OP_MONEDA, OP_TIPO, BEN_CBU, OP_IMPORTE, BEN_JTS_OID_CUENTA, BEN_NRO_DOC, MOTIVO_RECHAZO, OP_FORMA_ING, FECHA_ESTADO, CONTABILIZADA , OP_INFO_REF )
				VALUES ((SELECT MAX(OP_NUMERO)+1 FROM VTA_TRANSFERENCIAS WHERE OP_CLASE_TRANS=''R''), @TICKET, @FECHADATE, ''R'', ''RC'', @Moneda, @Tipo_transferencia, @CBU, @VImporte, @JTS_OID, @CUIL,(SELECT CODIGO_NACHA FROM CLE_TIPO_CAUSAL WHERE CODIGO_DE_CAUSAL = 4), ''C'' , @FECHADATE, ''N'', RTRIM(LTRIM(@ReferenciaUnivoca)));

	      	GOTO Final
	      END
	      
	      --------------
	      ----NACHA R15
	      --------------
	      /*
	      DECLARE @V15 NUMERIC(3);
	      
	      SELECT @V15 = COUNT(1)
		  FROM SNP_PRESTACIONES_EMPRESAS
		  WHERE ENTIDAD = @IdEntidadOrigen;
		  
	      IF (@V15 = 0)
	      BEGIN
	      		INSERT INTO dbo.VTA_TRANSFERENCIAS (OP_NUMERO, NUMERO_ASIENTO,  OP_FECHA_PRES, OP_CLASE_TRANS, ESTADO, OP_MONEDA, OP_TIPO, BEN_CBU, OP_IMPORTE, BEN_JTS_OID_CUENTA, BEN_NRO_DOC, MOTIVO_RECHAZO, OP_FORMA_ING, FECHA_ESTADO, CONTABILIZADA, OP_INFO_REF )
				VALUES ((SELECT MAX(OP_NUMERO)+1 FROM VTA_TRANSFERENCIAS), @TICKET, @FECHADATE, ''R'', ''RC'', 1, @Tipo_transferencia, @CBU, @VImporte, @JTS_OID, @CUIL,(SELECT CODIGO_NACHA FROM CLE_TIPO_CAUSAL WHERE CODIGO_DE_CAUSAL = 92), ''C'' , @FECHADATE, ''N'', RTRIM(LTRIM(@ReferenciaUnivoca)));

	      	GOTO Final
	      END
	      */
	      --------------
	      ----NACHA R19
	      --------------
	      
	      IF (@Importe <= 0 OR IsNumeric(@Importe) = 0)
	      BEGIN
	      		INSERT INTO dbo.VTA_TRANSFERENCIAS (OP_NUMERO, NUMERO_ASIENTO,  OP_FECHA_PRES, OP_CLASE_TRANS, ESTADO, OP_MONEDA, OP_TIPO, BEN_CBU, OP_IMPORTE, BEN_JTS_OID_CUENTA, BEN_NRO_DOC, MOTIVO_RECHAZO, OP_FORMA_ING, FECHA_ESTADO, CONTABILIZADA, OP_INFO_REF  )
				VALUES ((SELECT MAX(OP_NUMERO)+1 FROM VTA_TRANSFERENCIAS WHERE OP_CLASE_TRANS=''R''),@TICKET, @FECHADATE, ''R'', ''RC'', @Moneda, @Tipo_transferencia, @CBU, @VImporte, @JTS_OID, @CUIL,(SELECT CODIGO_NACHA FROM CLE_TIPO_CAUSAL WHERE CODIGO_DE_CAUSAL = 93), ''C'' , @FECHADATE, ''N'', RTRIM(LTRIM(@ReferenciaUnivoca)));

	      	GOTO Final
	      END
	      
	      --------------
	      ----NACHA R20
	      --------------
	      
	      DECLARE @MonedaCta NUMERIC(2);
	      DECLARE @TipoCuenta VARCHAR(2);
	      --DECLARE @NroCuenta NUMERIC(11);
		  DECLARE @Cod_Cliente NUMERIC(20);
		  DECLARE @saldo_jts_oid NUMERIC(15);
	      
	      --SET @NumCuenta = CAST(@CuentaDebitar AS NUMERIC);
	      SET @NumCuenta = CAST(SUBSTRING(@CuentaDebitar,6,11) AS NUMERIC);
	      SET @TipoCuenta = SUBSTRING(@CuentaDebitar,4,2);
	      
	      SELECT @MonedaCta = MONEDA,
	      	@Cod_Cliente = C1803,
			@saldo_jts_oid = JTS_OID
	      FROM SALDOS 
	      WHERE CUENTA = @NumCuenta 
	        AND SUCURSAL = CONVERT(INT,RIGHT(@EntidadDebitar,4))
	        --AND C1785 = @TipoCuenta
	        AND C1785 = (CASE WHEN @TipoCuenta = ''11'' OR @TipoCuenta = ''15'' THEN 3 
	        				  WHEN @TipoCuenta = ''01'' OR @TipoCuenta = ''07'' THEN 2
	        			 END)
            AND MONEDA = (CASE WHEN @TipoCuenta = ''11'' OR @TipoCuenta = ''01'' THEN 1 
            				   WHEN @TipoCuenta = ''15'' OR @TipoCuenta = ''07'' THEN 2 END)
	        AND TZ_LOCK = 0;
	      
	      IF( @Moneda <> ISNULL(@MonedaCta,99) )
	      BEGIN
	      		INSERT INTO dbo.VTA_TRANSFERENCIAS (OP_NUMERO, NUMERO_ASIENTO,  OP_FECHA_PRES, OP_CLASE_TRANS, ESTADO, OP_MONEDA, OP_TIPO, BEN_CBU, OP_IMPORTE, BEN_JTS_OID_CUENTA, BEN_NRO_DOC, MOTIVO_RECHAZO, OP_FORMA_ING, FECHA_ESTADO, CONTABILIZADA, OP_INFO_REF )
				VALUES ((SELECT MAX(OP_NUMERO)+1 FROM VTA_TRANSFERENCIAS WHERE OP_CLASE_TRANS=''R''), @TICKET, @FECHADATE, ''R'', ''RC'', @Moneda, @Tipo_transferencia, @CBU, @VImporte, @JTS_OID, @CUIL,(SELECT CODIGO_NACHA FROM CLE_TIPO_CAUSAL WHERE CODIGO_DE_CAUSAL = 94), ''C'' , @FECHADATE, ''N'', RTRIM(LTRIM(@ReferenciaUnivoca)));

	      	GOTO Final
	      END
	      
	      --------------
	      ----NACHA R23
	      --------------
	      
	      SELECT @ESTADOSUC = ESTADO 
	      FROM SUCURSALESSC
	      WHERE SUCURSAL = CONVERT(INT,RIGHT(@EntidadDebitar,4));
	      
	      IF @ESTADOSUC <> ''A''
	      BEGIN
	      		INSERT INTO dbo.VTA_TRANSFERENCIAS (OP_NUMERO, NUMERO_ASIENTO,  OP_FECHA_PRES, OP_CLASE_TRANS, ESTADO, OP_MONEDA, OP_TIPO, BEN_CBU, OP_IMPORTE, BEN_JTS_OID_CUENTA, BEN_NRO_DOC, MOTIVO_RECHAZO, OP_FORMA_ING, FECHA_ESTADO, CONTABILIZADA, OP_INFO_REF )
				VALUES ((SELECT MAX(OP_NUMERO)+1 FROM VTA_TRANSFERENCIAS WHERE OP_CLASE_TRANS=''R''), @TICKET, @FECHADATE, ''R'', ''RC'', @Moneda, @Tipo_transferencia, @CBU, @VImporte, @JTS_OID, @CUIL,(SELECT CODIGO_NACHA FROM CLE_TIPO_CAUSAL WHERE CODIGO_DE_CAUSAL = 95), ''C'' , @FECHADATE, ''N'', RTRIM(LTRIM(@ReferenciaUnivoca)));
	      	GOTO Final
	      END
	      
	      --------------
	      ----NACHA R75
	      --------------
	      
	      SET @FechaVencimientoCA = convert(DATE, @VFechaVencimientoCA);
	      
		  IF ISDATE(@VFechaVencimiento) = 0 OR ISDATE(@VFechaCompensacion) = 0 OR ISDATE(@VFechaVencimientoCA) = 0
	      BEGIN
	             
	      		INSERT INTO dbo.VTA_TRANSFERENCIAS (OP_NUMERO, NUMERO_ASIENTO,  OP_FECHA_PRES, OP_CLASE_TRANS, ESTADO, OP_MONEDA, OP_TIPO, BEN_CBU, OP_IMPORTE, BEN_JTS_OID_CUENTA, BEN_NRO_DOC, MOTIVO_RECHAZO, OP_FORMA_ING, FECHA_ESTADO, CONTABILIZADA, OP_INFO_REF )
				VALUES ((SELECT MAX(OP_NUMERO)+1 FROM VTA_TRANSFERENCIAS WHERE OP_CLASE_TRANS=''R''),@TICKET, @FECHADATE, ''R'', ''RC'', @Moneda, @Tipo_transferencia, @CBU, @VImporte, @JTS_OID, @CUIL,(SELECT CODIGO_NACHA FROM CLE_TIPO_CAUSAL WHERE CODIGO_DE_CAUSAL = 58), ''C'' , @FECHADATE, ''N'', RTRIM(LTRIM(@ReferenciaUnivoca)));
	      	GOTO Final
	      END
	      
	      --------------
	      ----NACHA R24
	      --------------
	      
		  DECLARE @V24 NUMERIC(3);
	      
	      DECLARE @NIdClientePegador NUMERIC(12);
	      
	      SET @NIdClientePegador = convert(NUMERIC(12),substring(@IdClientePegador, 2, 11));
	      
	      
	      SET @V24 = (SELECT COUNT(1) FROM dbo.VTA_TRANSFERENCIAS 
	      			  WHERE OP_INFO_REF=RTRIM(LTRIM(@ReferenciaUnivoca))
	      			    AND FECHA_ESTADO=@FECHADATE
	      			    AND OP_FECHA_PRES=@FECHADATE 
	      			    AND OP_TIPO=@Tipo_transferencia 
	      			    AND BEN_CBU= @CBU);
		  
		  
		  IF (@V24 > 0)
	      BEGIN
	      		INSERT INTO dbo.VTA_TRANSFERENCIAS (OP_NUMERO, NUMERO_ASIENTO,  OP_FECHA_PRES, OP_CLASE_TRANS, ESTADO, OP_MONEDA, OP_TIPO, BEN_CBU, OP_IMPORTE, BEN_JTS_OID_CUENTA, BEN_NRO_DOC, MOTIVO_RECHAZO, OP_FORMA_ING, FECHA_ESTADO, CONTABILIZADA, OP_INFO_REF )
				VALUES ((SELECT MAX(OP_NUMERO)+1 FROM VTA_TRANSFERENCIAS WHERE OP_CLASE_TRANS=''R''),@TICKET, @FECHADATE, ''R'', ''RC'', @Moneda, @Tipo_transferencia, @CBU, @VImporte, @JTS_OID, @CUIL,(SELECT CODIGO_NACHA FROM CLE_TIPO_CAUSAL WHERE CODIGO_DE_CAUSAL = 36), ''C'' , @FECHADATE, ''N'', RTRIM(LTRIM(@ReferenciaUnivoca)));
	      	GOTO Final
	      END
	     
	      
	      --------------
	      ----NACHA R91
	      --------------
	      
		  IF((LEFT(@EntidadDebitar,4)=''0311'' AND LEFT(@InfoAdicional,1)<>0) OR (LEFT(@EntidadDebitar,4)=''0811'' AND LEFT(@InfoAdicional,1)<>''1''))
	      BEGIN
	      	    INSERT INTO dbo.VTA_TRANSFERENCIAS (OP_NUMERO, NUMERO_ASIENTO,  OP_FECHA_PRES, OP_CLASE_TRANS, ESTADO, OP_MONEDA, OP_TIPO, BEN_CBU, OP_IMPORTE, BEN_JTS_OID_CUENTA, BEN_NRO_DOC, MOTIVO_RECHAZO, OP_FORMA_ING, FECHA_ESTADO, CONTABILIZADA, OP_INFO_REF )
				VALUES ((SELECT MAX(OP_NUMERO)+1 FROM VTA_TRANSFERENCIAS WHERE OP_CLASE_TRANS=''R''), @TICKET, @FECHADATE, ''R'', ''RC'', @Moneda, @Tipo_transferencia, @CBU, @VImporte, @JTS_OID, @CUIL,(SELECT CODIGO_NACHA FROM CLE_TIPO_CAUSAL WHERE CODIGO_DE_CAUSAL = 74), ''C'' , @FECHADATE, ''N'', RTRIM(LTRIM(@ReferenciaUnivoca)));
	      	GOTO Final
	      END
	      
		SET @correlativo = @correlativo +1;
		DECLARE @Tipo_Documento VARCHAR(4);
		DECLARE @Nro_Documento NUMERIC(15,0);
		  
		SELECT @Tipo_Documento=TIPODOCUMENTO, 
		  @Nro_Documento=NUMERODOCUMENTO 
		FROM CLI_DocumentosPFPJ 
		WHERE NUMEROPERSONAFJ = (SELECT TOP 1 NUMEROPERSONA FROM CLI_ClientePersona 
								 WHERE CODIGOCLIENTE= @NIdClientePegador--@Cod_Cliente 
								   AND ((TZ_LOCK < 300000000000000 OR TZ_LOCK >= 400000000000000) 
								   		AND (TZ_LOCK < 100000000000000 OR TZ_LOCK >= 200000000000000)))
		
		
		DECLARE @CUIT_EO NUMERIC(11,0);
		DECLARE @PRESTACION VARCHAR(10);
		DECLARE @CTA_CBU VARCHAR(22);
		
		SELECT @CUIT_EO = CUIT_EO,
			@PRESTACION = PRESTACION
		FROM SNP_PRESTACIONES_EMPRESAS
		WHERE ENTIDAD = @IdEntidadOrigen
		
		SELECT @CTA_CBU = CTA_CBU
		FROM VTA_SALDOS
		WHERE JTS_OID_SALDO = @saldo_jts_oid
	
		INSERT INTO dbo.VTA_TRANSFERENCIAS (OP_NUMERO, NUMERO_ASIENTO,  OP_FECHA_PRES, OP_CLASE_TRANS, ESTADO, OP_MONEDA, OP_TIPO, BEN_CBU, OP_IMPORTE, BEN_JTS_OID_CUENTA, BEN_NRO_DOC, OP_FORMA_ING, FECHA_ESTADO, CONTABILIZADA, OP_INFO_REF )
				VALUES ((SELECT MAX(OP_NUMERO)+1 FROM VTA_TRANSFERENCIAS WHERE OP_CLASE_TRANS=''R''), @TICKET, @FECHADATE, ''R'', ''PR'', @Moneda, @Tipo_transferencia, @CBU, @VImporte, @JTS_OID, @CUIL, ''C'' , @FECHADATE, ''N'', RTRIM(LTRIM(@ReferenciaUnivoca)));
	
		
		END TRY
		BEGIN CATCH  
		  CLOSE tran_cursor
		  DEALLOCATE tran_cursor
		  
		  SET @MSJ = ''Linea Error: '' + CONVERT(VARCHAR,ERROR_LINE()) + '' Mensaje Error: '' +  ERROR_MESSAGE();
		  RETURN
		  
		END CATCH; 
		
	END
		Final:
		FETCH NEXT FROM tran_cursor INTO @ID, @LINEA
	END

	CLOSE tran_cursor
	DEALLOCATE tran_cursor

END


')