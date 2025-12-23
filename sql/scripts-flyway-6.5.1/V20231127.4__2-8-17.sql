EXECUTE('
CREATE TABLE dbo.ITF_TRAN_SUELDOS_PRESENTADAS_AUX
	(
	ID          INT IDENTITY NOT NULL,
	LINEA       VARCHAR (200),
	CORRELATIVO NUMERIC (12),
	PRIMARY KEY (ID)
	)

INSERT INTO dbo.ITF_MASTER_PARAMETROS (CODIGO, CODIGO_INTERFACE, FUNCIONALIDAD, ALFA_1, ALFA_2, ALFA_3, NUMERICO_1, NUMERICO_2, FECHA, IMPORTE_1, IMPORTE_2, TZ_LOCK)
VALUES (178, 0, ''Cont Arch. COELSASPP'', '' '', '' '', '' '', 1, 0, ''20001014'', 0, 0, 0)

INSERT INTO dbo.ITF_MASTER_PARAMETROS (CODIGO, CODIGO_INTERFACE, FUNCIONALIDAD, ALFA_1, ALFA_2, ALFA_3, NUMERICO_1, NUMERICO_2, FECHA, IMPORTE_1, IMPORTE_2, TZ_LOCK)
VALUES (179, 11, ''Sec COELSA 2.8.17'', '' '', '' '', '' '', 4, 0, ''20371014'', 0, 0, 0)

INSERT INTO dbo.ITF_MASTER (TZ_LOCK, ID, DESCRIPCION, OBJ_KETTLE, P0_MODO, P0_TIPO, P0_CAPTION, P0_CONSTANTE, P1_MODO, P1_TIPO, P1_CAPTION, P1_CONSTANTE, P2_MODO, P2_TIPO, P2_CAPTION, P2_CONSTANTE, P3_MODO, P3_TIPO, P3_CAPTION, P3_CONSTANTE, P4_MODO, P4_TIPO, P4_CAPTION, P4_CONSTANTE, P5_MODO, P5_TIPO, P5_CAPTION, P5_CONSTANTE, P6_MODO, P6_TIPO, P6_CAPTION, P6_CONSTANTE, P7_MODO, P7_TIPO, P7_CAPTION, P7_CONSTANTE, P8_MODO, P8_TIPO, P8_CONSTANTE, P8_CAPTION, P9_MODO, P9_TIPO, P9_CAPTION, P9_CONSTANTE, TIPO_OBJ, COMENTARIO, ID_REPORTE, MODO_EJECUCION)
VALUES (0, 238, ''TRANSFERENCIA SPP'', ''ITF_SUELDOS_PRESENTADOS_PESOS.kjb'', '''', '''', '''', '' '', '''', '''', '''', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', ''J'', '' '', 0, ''M'')

')

EXECUTE('

CREATE   PROCEDURE [dbo].[SP_TRAN_SUELDOS_PRESENTADAS]
   @TICKET NUMERIC(16)
AS 
BEGIN

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- Autor: Fabio Alexis Menendez
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

------------ Limpieza de tabla auxiliar --------------------
TRUNCATE TABLE dbo.ITF_TRAN_SUELDOS_PRESENTADAS_AUX;
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
DECLARE @CA_CODIGO_REFERENCIA VARCHAR(8) = ''SUE     ''; --Se conforma con espacios vacíos.

DECLARE @CA_CABECERA VARCHAR(200);

SET @CA_CABECERA = concat(@CA_ID_REG, @CA_CODIGO_PRIORIDAD, @CA_DESTINO_INMEDIATO, @CA_ORIGEN_INMEDIATO, @CA_FECHA_PRESENTACION, @CA_HORA_PRESENTACION, @CA_IDENTIFICADOR_ARCHIVO, @CA_TAMANNO_REGISTRO, @CA_FACTOR_BLOQUE, @CA_CODIGO_FORMATO, @CA_NOMBRE_DEST_INMEDIATO, @CA_NOMBRE_ORIG_INMEDIATO, @CA_CODIGO_REFERENCIA);


--- Variables cabecera lote (CL)
DECLARE @CL_ID_REG VARCHAR(1) = ''5''; -- fijo
DECLARE @CL_CODIGO_CLASE_TRANSAC VARCHAR(3) = ''220''; -- fijo 
DECLARE @CL_NOM_EMPRESA VARCHAR(16) = ''PARTICULARES    '';
DECLARE @CL_CRITERIO_EMPRESA VARCHAR(20) = ''TRANSFERENCIAS      '';
DECLARE @CL_ID_EMPRESA VARCHAR(10);
DECLARE @CL_TIPO_REGISTRO VARCHAR(3) = ''CCD''; -- fijo 
DECLARE @CL_DESCRIP_TRANSAC VARCHAR(10) = ''          ''; -- fijo
DECLARE @CL_FECHA_PRESENTACION VARCHAR(6) = convert(VARCHAR,(SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)), 12);
DECLARE @CL_FECHA_VENCIMIENTO VARCHAR(6) = convert(VARCHAR,(SELECT FECHAPROXIMOPROCESO FROM PARAMETROS WITH(NOLOCK)), 12); 
DECLARE @CL_RESERVADO_CL VARCHAR(3) = ''003''; -- fijo
DECLARE @CL_CODIGO_ORIGEN VARCHAR(1) = ''0''; -- fijo
DECLARE @CL_ID_ENTIDAD_ORIGEN VARCHAR(8) = (SELECT ''031100''+CAST((SELECT NUMERICO FROM PARAMETROSGENERALES WHERE CODIGO=40) AS VARCHAR)); 
DECLARE @CL_NUMERO_LOTE VARCHAR(7) = RIGHT(concat(replicate(''0'', 7), 0), 7); -- numero del lote

DECLARE @CL_CABECERA VARCHAR(200);

	---------------- Grabar Cabecera Archivo ---------------------------
	INSERT INTO dbo.ITF_TRAN_SUELDOS_PRESENTADAS_AUX (LINEA) VALUES (@CA_CABECERA);
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
DECLARE @T_CLASE VARCHAR(1);

	IF((SELECT COUNT(1) FROM VTA_TRANSFERENCIAS WHERE ((OP_CLASE_TRANS=''R'' AND ESTADO=''RC'') OR (OP_CLASE_TRANS=''E'' AND ESTADO=''PP'')) AND OP_MONEDA=1 AND OP_TIPO=2)=0)
	BEGIN
	---------------- Grabar Cabecera Lote ---------------------------
	SET @CL_NUMERO_LOTE = RIGHT(concat(replicate(''0'', 7), (@CL_NUMERO_LOTE + 1)), 7);
	SET @CL_NOM_EMPRESA =  LEFT(concat('''',replicate('' '', 16)),16);
	SET @CL_CRITERIO_EMPRESA = replicate('' '', 20); -- AUN NO EXISTE AUTONUMERICO, FALTA DEFINIR 
	SET @CL_ID_EMPRESA = LEFT(concat(@T_CUIT_ORD,replicate('' '', 10)),10);
	SET @CL_CABECERA = concat(@CL_ID_REG, @CL_CODIGO_CLASE_TRANSAC, @CL_NOM_EMPRESA,@CL_CRITERIO_EMPRESA,@CL_ID_EMPRESA, @CL_TIPO_REGISTRO, @CL_DESCRIP_TRANSAC, @CL_FECHA_PRESENTACION, @CL_FECHA_VENCIMIENTO, @CL_RESERVADO_CL, @CL_CODIGO_ORIGEN, @CL_ID_ENTIDAD_ORIGEN, @CL_NUMERO_LOTE);
	INSERT INTO dbo.ITF_TRAN_SUELDOS_PRESENTADAS_AUX (LINEA) VALUES (@CL_CABECERA);
	END 
		
    --Condicion de reset del contador de reg individual
	IF ISNULL((SELECT a.FECHA FROM ITF_MASTER_PARAMETROS a WHERE a.CODIGO = 149), CAST(''01-01-1800'' AS DATETIME)) <> (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK))
    UPDATE dbo.ITF_MASTER_PARAMETROS SET NUMERICO_1 = 1, FECHA = (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)) WHERE CODIGO = 179;

SET @T_FECHA_COMP = (SELECT CONVERT(DATETIME, dbo.diaHabil ((SELECT (FECHAPROCESO + 1) FROM PARAMETROS WITH(NOLOCK)),''A'')) AS A);
SET @T_FECHA_VTO =  @T_FECHA_COMP;

DECLARE CursorTM CURSOR FOR

SELECT t.OP_NUMERO, v.JTS_OID_SALDO, t.OP_MONEDA, t.OP_IMPORTE, @T_FECHA_VTO, @T_FECHA_COMP, t.ORD_CBU, t.OP_NUMERO, s.C1803, t.ORD_NRO_DOC, t.ORD_NOMBRE, t.BEN_NRO_DOC, t.BEN_NOMBRE, t.BEN_TIPO_DOC, t.OP_CLASE_TRANS
FROM VTA_TRANSFERENCIAS t INNER JOIN VTA_SALDOS v ON t.ORD_CBU=v.CTA_CBU AND ((t.OP_CLASE_TRANS=''R'' AND t.ESTADO=''RC'') OR (t.OP_CLASE_TRANS=''E'' AND t.ESTADO=''PP'')) AND t.OP_MONEDA=1 AND t.OP_TIPO=2 INNER JOIN SALDOS s ON v.JTS_OID_SALDO=s.JTS_OID
WHERE ((t.OP_CLASE_TRANS=''R'' AND t.ESTADO=''RC'') OR (t.OP_CLASE_TRANS=''E'' AND t.ESTADO=''PP'')) AND t.OP_MONEDA=1 AND t.OP_TIPO=2
ORDER BY t.ORD_NRO_DOC, t.OP_MONEDA

OPEN CursorTM
FETCH NEXT FROM CursorTM INTO @T_ID_CREDITO, @T_JTS_OID, @T_MONEDA, @T_IMPORTE, @T_FECHA_VTO,@T_FECHA_COMP,@T_CBU, @T_REFERENCIA, @T_CODIGO_CLIENTE, @T_CUIT_ORD, @T_NOMBRE_ORDENANTE, @T_CUIT_BEN, @T_NOMBRE_BENEFICIARIO, @T_TIPO_DOC, @T_CLASE

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
		
    
	
		INSERT INTO dbo.ITF_TRAN_SUELDOS_PRESENTADAS_AUX (LINEA) VALUES (replace(@FL_FIN_LOTE, ''.'', ''''));
		
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
		
		INSERT INTO dbo.ITF_TRAN_SUELDOS_PRESENTADAS_AUX (LINEA) VALUES (@FA_FIN_ARCHIVO);
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
		
		INSERT INTO dbo.ITF_TRAN_SUELDOS_PRESENTADAS_AUX (LINEA) VALUES (@CA_CABECERA);
		----------------------------------------------------------------------------------------------------------------------------------------------------------------------
		--------- Grabamos nueva Cabecera Lote ------------------------------------------------------------------------------------------------------------------------------------------------------

		SET @CUIT = @T_CUIT_ORD;
		SET @CL_NUMERO_LOTE = RIGHT(concat(replicate(''0'', 7), (@CL_NUMERO_LOTE + 1)), 7);
		SET @CL_NOM_EMPRESA =  LEFT(@T_NOMBRE_ORDENANTE,16);
		SET @CL_CRITERIO_EMPRESA = replicate('' '', 20); -- AUN NO EXISTE AUTONUMERICO, FALTA DEFINIR 
		SET @CL_ID_EMPRESA = LEFT(@T_CUIT_ORD,10);
		SET @CL_CABECERA = concat(@CL_ID_REG, @CL_CODIGO_CLASE_TRANSAC, @CL_NOM_EMPRESA,@CL_CRITERIO_EMPRESA,@CL_ID_EMPRESA, @CL_TIPO_REGISTRO, @CL_DESCRIP_TRANSAC, @CL_FECHA_PRESENTACION, @CL_FECHA_VENCIMIENTO, @CL_RESERVADO_CL, @CL_CODIGO_ORIGEN, @CL_ID_ENTIDAD_ORIGEN, @CL_NUMERO_LOTE);
		INSERT INTO dbo.ITF_TRAN_SUELDOS_PRESENTADAS_AUX (LINEA) VALUES (@CL_CABECERA);
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

	INSERT INTO dbo.ITF_TRAN_SUELDOS_PRESENTADAS_AUX (LINEA) VALUES (replace(@FL_FIN_LOTE, ''.'', ''''));
	
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
		INSERT INTO dbo.ITF_TRAN_SUELDOS_PRESENTADAS_AUX (LINEA) VALUES (@CL_CABECERA);
	
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


    SET @RI_REGISTRO_ADICIONAL = ''0'';
    
    IF(@MONEDA=(SELECT C6399 FROM MONEDAS WHERE C6403=''N''))
    SET @RI_CONTADOR_REGISTRO = concat(''0311'', RIGHT(concat(replicate(''0'', 4), (''97'')), 4), RIGHT(concat(replicate(''0'', 7), (SELECT NUMERICO_1 FROM ITF_MASTER_PARAMETROS WHERE CODIGO = 179)), 7)); 
    ELSE
    SET @RI_CONTADOR_REGISTRO = concat(''0811'', RIGHT(concat(replicate(''0'', 4), (''97'')), 4), RIGHT(concat(replicate(''0'', 7), (SELECT NUMERICO_1 FROM ITF_MASTER_PARAMETROS WHERE CODIGO = 179)), 7)); 
     
        	
	SET @RI_REGISTRO_INDIVIDUAL = concat(@RI_ID_REG, @T_CODIGO_TRANSACCION, @RI_ENTIDAD_CREDITO, @RI_RESERVADO, @RI_CUENTA_CREDITO, @RI_IMPORTE, @RI_REFERENCIA_UNIVOCA, @RI_CLIENTE_PAGADOR, @RI_INFO_ADICIONAL, @RI_REGISTRO_ADICIONAL, @RI_CONTADOR_REGISTRO);
 
    INSERT INTO dbo.ITF_TRAN_SUELDOS_PRESENTADAS_AUX (LINEA, CORRELATIVO) VALUES (replace(@RI_REGISTRO_INDIVIDUAL, ''.'', ''''),@T_ID_CREDITO);
    IF(@T_CLASE=''R'')
	BEGIN
    UPDATE dbo.VTA_TRANSFERENCIAS SET ESTADO=''RP'' WHERE OP_NUMERO=@T_REFERENCIA;
    END
    IF(@T_CLASE=''E'')
	BEGIN
    UPDATE dbo.VTA_TRANSFERENCIAS SET ESTADO=''PR'' WHERE OP_NUMERO=@T_REFERENCIA;
    END
	-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	/* Logica para agregar el registro adicional*/	
	IF(@CountExcedente<1) 
	BEGIN

		SET @RO_CONCEPTO = LEFT(CONCAT(@T_CUIT_BEN, @T_NOMBRE_BENEFICIARIO, REPLICATE('' '',80)),80);
		SET @RO_NUM_SECUENCIA_ADICIONAL= RIGHT(concat(replicate(''0'', 4), (@RO_NUM_SECUENCIA_ADICIONAL + 1)), 4);
	
		SET @RI_REGISTRO_INDIVIDUAL = concat(''705'',@RO_CONCEPTO,@RO_NUM_SECUENCIA_ADICIONAL,RIGHT(concat(replicate(''0'', 7), (SELECT NUMERICO_1 FROM ITF_MASTER_PARAMETROS WHERE CODIGO = 179)), 7));
		INSERT INTO dbo.ITF_TRAN_SUELDOS_PRESENTADAS_AUX (LINEA) VALUES (replace(@RI_REGISTRO_INDIVIDUAL, ''.'', ''''));

	END  



	----------------------------- Actualizar secuencial unico -------------------------------------
	UPDATE dbo.ITF_MASTER_PARAMETROS SET NUMERICO_1 = (NUMERICO_1 + 1) WHERE CODIGO = 179;
	-----------------------------------------------------------------------------------------------

	
	IF (@Excedente = 0)
	BEGIN		     	       				
	
	FETCH NEXT FROM CursorTM INTO @T_ID_CREDITO, @T_JTS_OID, @T_MONEDA, @T_IMPORTE, @T_FECHA_VTO,@T_FECHA_COMP,@T_CBU, @T_REFERENCIA, @T_CODIGO_CLIENTE, @T_CUIT_ORD, @T_NOMBRE_ORDENANTE, @T_CUIT_BEN, @T_NOMBRE_BENEFICIARIO, @T_TIPO_DOC, @T_CLASE
	
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
			
	INSERT INTO dbo.ITF_TRAN_SUELDOS_PRESENTADAS_AUX (LINEA) VALUES (replace(@FL_FIN_LOTE, ''.'', ''''));

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
			
	
	
	INSERT INTO dbo.ITF_TRAN_SUELDOS_PRESENTADAS_AUX (LINEA) VALUES (@FA_FIN_ARCHIVO);
	
				
	SET @FL_NUMERO_LOTE = CAST(@FL_NUMERO_LOTE AS NUMERIC) + 1;
	SET @FL_NUMERO_LOTE = RIGHT(concat(replicate(''0'', 7), @FL_NUMERO_LOTE), 7);
	------------------------------------------------------------------------------------------------------------------------------------------------------------------

END


')


