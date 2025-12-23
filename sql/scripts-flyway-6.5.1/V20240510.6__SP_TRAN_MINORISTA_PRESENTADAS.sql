execute('
create or ALTER   PROCEDURE [dbo].[SP_TRAN_MINORISTA_PRESENTADAS]
   @TICKET NUMERIC(16)
AS 
BEGIN
	--DECLARE @TICKET NUMERIC(16)=5
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
DECLARE @CA_CODIGO_REFERENCIA VARCHAR(8) = ''MIN    0''; --Se conforma con espacios vacíos.

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
DECLARE @CL_FECHA_VENCIMIENTO VARCHAR(6) = convert(VARCHAR,(SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)), 12); 
DECLARE @CL_RESERVADO_CL VARCHAR(3) = ''003''; -- fijo
DECLARE @CL_CODIGO_ORIGEN VARCHAR(1) = ''0''; -- fijo
DECLARE @CL_ID_ENTIDAD_ORIGEN VARCHAR(8) = (SELECT ''031100''+CAST((SELECT NUMERICO FROM PARAMETROSGENERALES WHERE CODIGO=40) AS VARCHAR)); 
DECLARE @CL_NUMERO_LOTE VARCHAR(7) = RIGHT(concat(replicate(''0'', 7), 0), 7); -- numero del lote

DECLARE @CL_CABECERA VARCHAR(200);
DECLARE @t_ord_tipo_doc VARCHAR(4);

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
DECLARE @RI_CLIENTE_PAGADOR VARCHAR(22)=REPLICATE('' '',22); 
DECLARE @RI_INFO_ADICIONAL VARCHAR(2);
DECLARE @RI_REGISTRO_ADICIONAL VARCHAR(1); 
DECLARE @RI_CONTADOR_REGISTRO VARCHAR(15);
							
DECLARE @RI_REGISTRO_INDIVIDUAL VARCHAR (200);
DECLARE @t_op_referencia VARCHAR(3);
DECLARE @t_adicional_present VARCHAR(2); 
DECLARE @t_ben_cbu VARCHAR(22);
DECLARE @t_ben_mismo_titular VARCHAR(1);
DECLARE @num_id VARCHAR(3)=''000'';  
DECLARE @t_ben_banco NUMERIC(6);
DECLARE @ben_banco NUMERIC(6)=0;
DECLARE @t_op_tipo NUMERIC(3);
DECLARE @op_tipo NUMERIC(3)=0;
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
DECLARE @FA_RESERVADO  VARCHAR(100) = concat(replicate('' '', 38),''0''); -- fijo

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
DECLARE @T_CUENTA NUMERIC(14,0);
DECLARE @T_SUCURSAL NUMERIC(5,0);
DECLARE @T_COD_BANCO NUMERIC(4,0);
DECLARE @T_CODIGO_TRANSACCION varchar(2);
DECLARE @T_ID_CREDITO NUMERIC(15,0);
DECLARE @T_CUIT_ORD NUMERIC(11,0)=0;
DECLARE @CUIT NUMERIC(11,0)=0;
DECLARE @T_ID_ARCHIVO_REVERSADO NUMERIC(9,0);
DECLARE @T_REVERSADO INT=0;
DECLARE @T_NOMBRE_ORDENANTE VARCHAR(70);
DECLARE @T_CUIT_BEN NUMERIC(11,0)=0;
DECLARE @T_NOMBRE_BENEFICIARIO VARCHAR(70);
DECLARE @T_TIPO_DOC VARCHAR(4);


	IF((SELECT COUNT(1) FROM VTA_TRANSFERENCIAS WHERE OP_CLASE_TRANS=''E'' AND OP_MONEDA=1 AND ESTADO=''PP'' AND tz_lock=0)=0)
	BEGIN
	---------------- Grabar Cabecera Lote ---------------------------
	SET @CL_NUMERO_LOTE = RIGHT(concat(replicate(''0'', 7), (@CL_NUMERO_LOTE + 1)), 7);
	SET @CL_NOM_EMPRESA =  LEFT(concat('''',replicate('' '', 16)),16);
	SET @CL_CRITERIO_EMPRESA = replicate('' '', 20); -- AUN NO EXISTE AUTONUMERICO, FALTA DEFINIR 
	SET @CL_ID_EMPRESA = right(concat(replicate(''0'', 10),@T_CUIT_ORD),10);

	
	SET @CL_CABECERA = concat(@CL_ID_REG, @CL_CODIGO_CLASE_TRANSAC, @CL_NOM_EMPRESA,@CL_CRITERIO_EMPRESA,@CL_ID_EMPRESA, @CL_TIPO_REGISTRO, @CL_DESCRIP_TRANSAC, @CL_FECHA_PRESENTACION, @CL_FECHA_VENCIMIENTO, @CL_RESERVADO_CL, @CL_CODIGO_ORIGEN, @CL_ID_ENTIDAD_ORIGEN, @CL_NUMERO_LOTE);
	INSERT INTO dbo.ITF_TRAN_MINORISTA_PRESENTADAS_AUX (LINEA) VALUES (@CL_CABECERA);
	END 
		
    --Condicion de reset del contador de reg individual
	IF ISNULL((SELECT a.FECHA FROM ITF_MASTER_PARAMETROS a WHERE a.CODIGO = 149), CAST(''01-01-1800'' AS DATETIME)) <> (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK))
    UPDATE dbo.ITF_MASTER_PARAMETROS SET NUMERICO_1 = 1, FECHA = (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)) WHERE CODIGO = 149;

SET @T_FECHA_COMP = (SELECT CONVERT(DATETIME, dbo.diaHabil ((SELECT (FECHAPROCESO + 1) FROM PARAMETROS WITH(NOLOCK)),''A'')) AS A);
SET @T_FECHA_VTO =  @T_FECHA_COMP;

DECLARE CursorTM CURSOR FOR

SELECT t.OP_NUMERO, 
	   v.JTS_OID_SALDO, 
	   t.OP_MONEDA, 
	   t.OP_IMPORTE, 
	   @T_FECHA_VTO, 
	   @T_FECHA_COMP, 
	   t.ORD_CBU, 
	   t.OP_NUMERO, 
	   s.C1803, 
	   t.ORD_NRO_DOC, 
	   t.ORD_NOMBRE, 
	   RIGHT(''00000000000'' + CAST(t.BEN_NRO_DOC AS VARCHAR(11)), 11) AS BEN_NRO_DOC, 
	   t.BEN_NOMBRE, 
	   t.BEN_TIPO_DOC,
	   t.ORD_TIPO_DOC, 
	   t.OP_REFERENCIA,
	   TT.ADICIONAL_PRESENT,
	   t.BEN_CBU,
	   t.BEN_MISMO_TITULAR,
	   t.BEN_BANCO,
	   t.OP_TIPO
FROM VTA_TRANSFERENCIAS t 
INNER JOIN VTA_SALDOS v ON t.ORD_CBU=v.CTA_CBU AND t.OP_CLASE_TRANS=''E'' AND t.OP_MONEDA=1 AND t.ESTADO=''PP'' 
INNER JOIN SALDOS s ON v.JTS_OID_SALDO=s.JTS_OID
INNER JOIN VTA_TRANSFERENCIAS_TIPOS TT ON t.OP_TIPO=TT.ID_TIPO
WHERE t.OP_CLASE_TRANS=''E'' 
AND t.OP_MONEDA=1 
AND t.ESTADO=''PP''
AND t.TZ_LOCK=0
AND v.TZ_LOCK=0
AND s.TZ_LOCK=0
AND TT.TZ_LOCK=0
ORDER BY t.ORD_NRO_DOC,t.ben_banco,t.OP_TIPo, t.OP_MONEDA
OPEN CursorTM
FETCH NEXT FROM CursorTM INTO @T_ID_CREDITO, 
							  @T_JTS_OID, 
							  @T_MONEDA, 
							  @T_IMPORTE, 
							  @T_FECHA_VTO,
							  @T_FECHA_COMP,
							  @T_CBU, 
							  @T_REFERENCIA, 
							  @T_CODIGO_CLIENTE, 
							  @T_CUIT_ORD, 
							  @T_NOMBRE_ORDENANTE, 
							  @T_CUIT_BEN, 
							  @T_NOMBRE_BENEFICIARIO, 
							  @T_TIPO_DOC,
							  @t_ord_tipo_doc, 
							  @t_op_referencia, 
							  @t_adicional_present,
							  @t_ben_cbu,
							  @t_ben_mismo_titular,
							  @t_ben_banco,
							  @t_op_tipo 

WHILE @@FETCH_STATUS = 0
BEGIN

SET @t_op_referencia=RIGHT(concat(replicate('' '',3),@t_op_referencia),3)
SET @CL_RESERVADO_CL=(SELECT RIGHT(concat(''000'',adicional_present),3) FROM  vta_transferencias_tipos WHERE ID_TIPO=@t_op_tipo)
SET @CL_CODIGO_ORIGEN=RIGHT(CONCAT(''0'',RIGHT(@T_CUIT_ORD,1)),1)	
SET @CL_NOM_EMPRESA =  LEFT(concat(@T_NOMBRE_ORDENANTE,replicate('' '', 16)),16);



	IF (@SumaImportes > 9999999999 OR @SumaEntidad > 999000) -- 99 millones
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
		--SET @FA_NUMERO_BLOQUES = RIGHT(concat(replicate(''0'', 6), @CantRegistrosPrev), 6);
		
		
		 SET @FA_NUMERO_BLOQUES = RIGHT(concat(replicate(''0'', 6), (SELECT CEILING((count(*)+1) / CONVERT(FLOAT, 10))
																  FROM ITF_TRAN_MINORISTA_PRESENTADAS_AUX 
																  WHERE  ID>=(SELECT max(id) 
																  		  		FROM ITF_TRAN_MINORISTA_PRESENTADAS_AUX 
																  		  		WHERE LINEA LIKE ''1%''))), 6)
	
	

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
		SET @ben_banco=@t_ben_banco;
		SET @op_tipo=@t_op_tipo;
		
		SET @CL_NUMERO_LOTE = RIGHT(concat(replicate(''0'', 7), (@CL_NUMERO_LOTE + 1)), 7);
			SET @CL_NOM_EMPRESA =  LEFT(concat(@T_NOMBRE_ORDENANTE,replicate('' '', 16)),16);

		SET @CL_CRITERIO_EMPRESA = replicate('' '', 20); -- AUN NO EXISTE AUTONUMERICO, FALTA DEFINIR 
		SET @CL_ID_EMPRESA = right(concat(replicate(''0'', 10),@T_CUIT_ORD),10);
		--SET @CL_ID_EMPRESA = LEFT(@T_CUIT_ORD,10);
		
		IF @t_ord_tipo_doc<>''CUIL''
		BEGIN
			SET @CL_NOM_EMPRESA =  LEFT(concat(@T_NOMBRE_ORDENANTE,replicate('' '', 16)),16);
			SET @CL_ID_EMPRESA = right(concat(replicate(''0'', 10),@T_CUIT_ORD),10);
		END
		

		
		SET @CL_CABECERA = concat(@CL_ID_REG, @CL_CODIGO_CLASE_TRANSAC, @CL_NOM_EMPRESA,@CL_CRITERIO_EMPRESA,@CL_ID_EMPRESA, @CL_TIPO_REGISTRO, @CL_DESCRIP_TRANSAC, @CL_FECHA_PRESENTACION, @CL_FECHA_VENCIMIENTO, @CL_RESERVADO_CL, @CL_CODIGO_ORIGEN, @CL_ID_ENTIDAD_ORIGEN, @CL_NUMERO_LOTE);
		INSERT INTO dbo.ITF_TRAN_MINORISTA_PRESENTADAS_AUX (LINEA) VALUES (@CL_CABECERA);
		---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	END
	
   
	IF(@T_MONEDA=(SELECT C6399 FROM MONEDAS WHERE C6403=''N''))
	SET @CL_ID_ENTIDAD_ORIGEN  = (SELECT ''031100''+CAST((SELECT NUMERICO FROM PARAMETROSGENERALES WHERE CODIGO=40) AS VARCHAR));
	ELSE
	SET @CL_ID_ENTIDAD_ORIGEN  = (SELECT ''081100''+CAST((SELECT NUMERICO FROM PARAMETROSGENERALES WHERE CODIGO=40) AS VARCHAR));
	
	/* LOGICA PARA GRABAR LA CABECERA DE LOTE*/
	IF(@CUIT!=@T_CUIT_ORD OR @ben_banco!=@t_ben_banco OR @op_tipo!=@t_op_tipo OR @T_MONEDA!=@MONEDA)
	BEGIN
	

	
		IF(@CUIT!=0 or @ben_banco!=0 or @op_tipo!=0 OR @MONEDA!=0)
		BEGIN
			SET @FL_TOTALES_DE_CONTROL = concat((RIGHT(concat(replicate(''0'', 6), @SumaEntidad), 6)), (RIGHT(concat(replicate(''0'', 4), @SumaSucursal), 4)));
   			SET @FL_SUMA_TOTAL_DEBITO_LOTE = RIGHT(replicate(''0'', 12), 12); 
   			SET @FL_SUMA_TOTAL_CREDITO_LOTE = RIGHT(concat(replicate(''0'', 12), (replace(@SumaImportes, ''.'', ''''))), 12); 
   			SET @TotalesCreditos += @SumaImportes;
   			SET @FL_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 6), @Cant_Reg_Individual_Adicional), 6); 
   	
   			SET @FL_TOTALES_DE_CONTROL =RIGHT(concat(replicate(''0'', 10), (SELECT sum(convert(INT,substring(t.LINEA,4,8)))
															  FROM ITF_TRAN_MINORISTA_PRESENTADAS_AUX t
															  WHERE t.ID>(SELECT max(tt.id) 
		  																  FROM ITF_TRAN_MINORISTA_PRESENTADAS_AUX tt
		  																  WHERE tt.LINEA LIKE ''5%'')
																		  AND substring(t.LINEA,1,1) IN (''6''))), 10);
   	
   			SET @FL_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 6), (SELECT count(id) 
																			 FROM ITF_TRAN_MINORISTA_PRESENTADAS_AUX t
																			 WHERE t.ID>(SELECT max(tt.id) 
		  																				 FROM ITF_TRAN_MINORISTA_PRESENTADAS_AUX tt
		  																				 WHERE tt.LINEA LIKE ''5%'')	
																			 AND substring(t.LINEA,1,1) IN (''6'',''7''))), 6);
	
	
			SET @FL_RESERVADO1=@CL_ID_EMPRESA;
			SET @FL_NUMERO_LOTE=@CL_NUMERO_LOTE
	
	
	
   			SET @FL_FIN_LOTE = concat(@FL_ID_REG, @FL_CODIGO_CLASE_TRANSAC, @FL_CANT_REG_INDIVIDUAL_ADICIONAL, @FL_TOTALES_DE_CONTROL, @FL_SUMA_TOTAL_DEBITO_LOTE, @FL_SUMA_TOTAL_CREDITO_LOTE, @FL_RESERVADO1, @FL_RESERVADO2, @FL_RESERVADO3, @FL_REG_ENTIDAD_ORIGEN, @FL_NUMERO_LOTE);

			INSERT INTO dbo.ITF_TRAN_MINORISTA_PRESENTADAS_AUX (LINEA) VALUES (replace(@FL_FIN_LOTE, ''.'', ''''));
	
			SET @SumaImportes = 0;
			SET @SumaEntidad = 0;
			SET @SumaSucursal = 0;
	
		END
	
		SET @CUIT = @T_CUIT_ORD;
		SET @MONEDA = @T_MONEDA;
		SET @ben_banco=@t_ben_banco;
		SET @op_tipo=@t_op_tipo;
	
		SET @CL_NUMERO_LOTE = RIGHT(concat(replicate(''0'', 7), (@CL_NUMERO_LOTE + 1)), 7);
		SET @CL_ID_EMPRESA =replicate(''0'', 10);
	
	
		IF @t_ord_tipo_doc<>''CUIL''
			BEGIN
				SET @CL_NOM_EMPRESA =  LEFT(concat(@T_NOMBRE_ORDENANTE,replicate('' '', 16)),16);
				SET @CL_ID_EMPRESA = LEFT(concat(@T_CUIT_ORD,replicate('' '', 10)),10);
			END
	
	
	
		SET @CL_CRITERIO_EMPRESA = replicate('' '', 20); -- AUN NO EXISTE AUTONUMERICO, FALTA DEFINIR 
	

	
		SET @CL_CABECERA = concat(@CL_ID_REG, @CL_CODIGO_CLASE_TRANSAC, @CL_NOM_EMPRESA,@CL_CRITERIO_EMPRESA,@CL_ID_EMPRESA, @CL_TIPO_REGISTRO, @CL_DESCRIP_TRANSAC, @CL_FECHA_PRESENTACION, @CL_FECHA_VENCIMIENTO, @CL_RESERVADO_CL, @CL_CODIGO_ORIGEN, @CL_ID_ENTIDAD_ORIGEN, @CL_NUMERO_LOTE);
		

		INSERT INTO dbo.ITF_TRAN_MINORISTA_PRESENTADAS_AUX (LINEA) VALUES (@CL_CABECERA);
	
		IF(@T_MONEDA=(SELECT C6399 FROM MONEDAS WHERE C6403=''N''))	
			SET @FL_REG_ENTIDAD_ORIGEN = (SELECT ''0311''+ RIGHT(concat(replicate(''0'', 4), CAST((SELECT NUMERICO FROM PARAMETROSGENERALES WHERE CODIGO=40) AS VARCHAR)), 4)); 
		ELSE
			SET @FL_REG_ENTIDAD_ORIGEN = (SELECT ''0811''+ RIGHT(concat(replicate(''0'', 4), CAST((SELECT NUMERICO FROM PARAMETROSGENERALES WHERE CODIGO=40) AS VARCHAR)), 4)); 
	END
		
		SELECT @T_SUCURSAL=SUCURSAL FROM SALDOS WHERE JTS_OID=@T_JTS_OID AND TZ_LOCK=0;
	

	
		SELECT @T_CUENTA=TRY_CONVERT(NUMERIC,RIGHT(cta_cbu, 14)) from VTA_SALDOS where JTS_OID_SALDO=@T_JTS_OID AND TZ_LOCK=0;

		IF(@T_MONEDA= (SELECT C6399 FROM MONEDAS WHERE C6403=''N''))
		BEGIN
			SET @T_COD_BANCO=311;
			SET @RI_INFO_ADICIONAL= RIGHT(concat(replicate(''0'',4),@t_adicional_present),2);
		END
		ELSE
		BEGIN
			SET @T_COD_BANCO=811;
			SET @RI_INFO_ADICIONAL= RIGHT(concat(replicate(''0'',4),@t_adicional_present),2);
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
--    SET @RI_CUENTA_CREDITO = RIGHT(concat(replicate(''0'', 17), @T_CUENTA), 17);
    	SET @RI_REFERENCIA_UNIVOCA = RIGHT(concat(replicate(''0'', 15), @T_REFERENCIA), 15);
    
    	IF (@t_ben_mismo_titular=''S'') 
    		SET @num_id=''074''
    	IF (@t_ben_mismo_titular=''N'')
    		SET @num_id=''073''
    	IF(@T_TIPO_DOC =''CUIT'')
    		SET @RI_CLIENTE_PAGADOR = CONCAT(''1'',@T_CUIT_BEN,''       '',@num_id);
    	IF(@T_TIPO_DOC =''CUIL'')
    		SET @RI_CLIENTE_PAGADOR = CONCAT(''2'',@T_CUIT_BEN,''       '',@num_id);
    	IF(@T_TIPO_DOC =''CDI'')
    		SET @RI_CLIENTE_PAGADOR = CONCAT(''3'',@T_CUIT_BEN,''       '',@num_id);
    
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
--    SET @RI_CUENTA_CREDITO = RIGHT(concat(replicate(''0'', 17), @T_CUENTA), 17);
    		SET @RI_REFERENCIA_UNIVOCA =  CONCAT(@t_op_referencia,RIGHT(concat(replicate(''0'', 12), @T_REFERENCIA), 12));
    
    		IF (@t_ben_mismo_titular=''S'') 
    			SET @num_id=''074''
    		IF (@t_ben_mismo_titular=''N'')
    			SET @num_id=''073''
    		IF (RIGHT((SELECT TOP 1 adicional_present FROM vta_transferencias_tipos WHERE id_tipo=@t_op_tipo AND tz_lock=0),1)=''C'')
    			SET @num_id=''075''
    		IF (RIGHT((SELECT TOP 1 adicional_present FROM vta_transferencias_tipos WHERE id_tipo=@t_op_tipo AND tz_lock=0),1)=''C'')
    			SET @num_id=''075''
    		IF(@T_TIPO_DOC =''CUIT'')
    			SET @RI_CLIENTE_PAGADOR = CONCAT(''1'',@T_CUIT_BEN,''       '',@num_id);
    		IF(@T_TIPO_DOC =''CUIL'')
    			SET @RI_CLIENTE_PAGADOR = CONCAT(''2'',@T_CUIT_BEN,''       '',@num_id);
    		IF(@T_TIPO_DOC =''CDI'')
    			SET @RI_CLIENTE_PAGADOR = CONCAT(''3'',@T_CUIT_BEN,''       '',@num_id);
 
    	END

    
    	SET @RI_IMPORTE = RIGHT(concat(replicate(''0'', 10), replace(CAST(@T_IMPORTE AS VARCHAR),''.'','''')), 10);
    --SET @RI_CODIGO_POSTAL = RIGHT(concat(''00'', replicate(''0'', 6), @T_CODIGO_POSTAL), 6);

    	SET @RI_REGISTRO_ADICIONAL = ''0'';
    
    	IF(@MONEDA=(SELECT C6399 FROM MONEDAS WHERE C6403=''N''))
    		SET @RI_CONTADOR_REGISTRO = concat(''0311'', RIGHT(concat(replicate(''0'', 4), (''30'')), 4), RIGHT(concat(replicate(''0'', 7), (SELECT NUMERICO_1 FROM ITF_MASTER_PARAMETROS WHERE CODIGO = 149)), 7)); 
    	ELSE
   			SET @RI_CONTADOR_REGISTRO = concat(''0811'', RIGHT(concat(replicate(''0'', 4), (''30'')), 4), RIGHT(concat(replicate(''0'', 7), (SELECT NUMERICO_1 FROM ITF_MASTER_PARAMETROS WHERE CODIGO = 149)), 7)); 
     
    	IF(@CountExcedente<1)
    	BEGIN 
    		SET @RI_REGISTRO_ADICIONAL = ''1'';
    	END 
	
     	SET @RI_INFO_ADICIONAL= RIGHT(concat(replicate(''0'',4),@t_adicional_present),2)
     	PRINT LEFT(@T_ben_cbu,7)
     	SET @RI_ENTIDAD_CREDITO = RIGHT(concat(replicate(''0'', 8), LEFT(@T_ben_cbu,7)),8);
	 	SET @RI_CUENTA_CREDITO = RIGHT(concat(replicate(''0'', 17), right(@T_ben_cbu,14)),17);	
        	
		SET @RI_REGISTRO_INDIVIDUAL = concat(@RI_ID_REG, @T_CODIGO_TRANSACCION, @RI_ENTIDAD_CREDITO, @RI_RESERVADO, @RI_CUENTA_CREDITO, @RI_IMPORTE, @RI_REFERENCIA_UNIVOCA, @RI_CLIENTE_PAGADOR, @RI_INFO_ADICIONAL, @RI_REGISTRO_ADICIONAL, @RI_CONTADOR_REGISTRO);
 
-- 	PRINT @RI_ID_REG
-- 	PRINT @T_CODIGO_TRANSACCION
-- 	PRINT @RI_ENTIDAD_CREDITO
-- 	PRINT @RI_RESERVADO
-- 	PRINT @RI_CUENTA_CREDITO
-- 	PRINT @RI_IMPORTE
-- 	PRINT @RI_REFERENCIA_UNIVOCA
-- 	PRINT @RI_CLIENTE_PAGADOR
-- 	PRINT @RI_INFO_ADICIONAL
-- 	PRINT @RI_REGISTRO_ADICIONAL
-- 	PRINT @RI_CONTADOR_REGISTRO
-- 	PRINT @RI_REGISTRO_INDIVIDUAL
 
    	INSERT INTO dbo.ITF_TRAN_MINORISTA_PRESENTADAS_AUX (LINEA, CORRELATIVO) VALUES (replace(@RI_REGISTRO_INDIVIDUAL, ''.'', ''''),@T_ID_CREDITO);
    	UPDATE dbo.VTA_TRANSFERENCIAS SET ESTADO=''PR'' WHERE OP_NUMERO=@T_REFERENCIA;
    
    	SET @RO_NUM_SECUENCIA_ADICIONAL= ''0'';
	-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		/* Logica para agregar el registro adicional*/	
		IF(@CountExcedente<1) --@T_ID_ARCHIVO_REVERSADO=0 OR @T_ID_ARCHIVO_REVERSADO IS NULL
		BEGIN
	
			SET @RO_CONCEPTO = LEFT(CONCAT(@T_CUIT_ORD, @T_NOMBRE_ORDENANTE, REPLICATE('' '',80)),80);
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
	
		FETCH NEXT FROM CursorTM INTO @T_ID_CREDITO, 
								  @T_JTS_OID, 
								  @T_MONEDA, 
								  @T_IMPORTE, 
								  @T_FECHA_VTO,
								  @T_FECHA_COMP,
								  @T_CBU, 
								  @T_REFERENCIA, 
								  @T_CODIGO_CLIENTE, 
								  @T_CUIT_ORD, 
								  @T_NOMBRE_ORDENANTE, 
								  @T_CUIT_BEN, 
								  @T_NOMBRE_BENEFICIARIO, 
								  @T_TIPO_DOC,
								  @t_ord_tipo_doc, 
								  @t_op_referencia,
								  @t_adicional_present,
								  @t_ben_cbu,
								  @t_ben_mismo_titular,
								  @t_ben_banco,
								  @t_op_tipo
	
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
	
	
	SET @FL_TOTALES_DE_CONTROL =RIGHT(concat(replicate(''0'', 10), (SELECT sum(convert(INT,substring(t.LINEA,4,8)))
															  	  FROM ITF_TRAN_MINORISTA_PRESENTADAS_AUX t
															      WHERE t.ID>(SELECT max(tt.id) 
		  																  	  FROM ITF_TRAN_MINORISTA_PRESENTADAS_AUX tt
		  																      WHERE tt.LINEA LIKE ''5%'')
																		  	  AND substring(t.LINEA,1,1) IN (''6''))), 10);
	
	SET @FL_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 6), (SELECT count(id) 
																			 FROM ITF_TRAN_MINORISTA_PRESENTADAS_AUX t
																			 WHERE t.ID>(SELECT max(tt.id) 
		  																				 FROM ITF_TRAN_MINORISTA_PRESENTADAS_AUX tt
		  																				 WHERE tt.LINEA LIKE ''5%'')	
																			 AND substring(t.LINEA,1,1) IN (''6'',''7''))), 6);
	PRINT '' cant reg: ''	;	
	PRINT @FL_CANT_REG_INDIVIDUAL_ADICIONAL
	SET @FL_RESERVADO1=@CL_ID_EMPRESA;
	SET @FL_NUMERO_LOTE=@CL_NUMERO_LOTE
	
	SET @FL_FIN_LOTE = concat(@FL_ID_REG, @FL_CODIGO_CLASE_TRANSAC, @FL_CANT_REG_INDIVIDUAL_ADICIONAL, @FL_TOTALES_DE_CONTROL, @FL_SUMA_TOTAL_DEBITO_LOTE, @FL_SUMA_TOTAL_CREDITO_LOTE, @FL_RESERVADO1, @FL_RESERVADO2, @FL_RESERVADO3, @FL_REG_ENTIDAD_ORIGEN, @FL_NUMERO_LOTE);
			
	INSERT INTO dbo.ITF_TRAN_MINORISTA_PRESENTADAS_AUX (LINEA) VALUES (replace(@FL_FIN_LOTE, ''.'', ''''));
	
	SET @FL_NUMERO_LOTE = CAST(@FL_NUMERO_LOTE AS NUMERIC) + 1;
	SET @FL_NUMERO_LOTE = RIGHT(concat(replicate(''0'', 7), @FL_NUMERO_LOTE), 7);

	---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-------------Grabamos el Fin de Archivo ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	SET @FA_CANT_LOTES = RIGHT(concat(replicate(''0'', 6), @FL_NUMERO_LOTE), 6);
	SET @CantRegistrosPrev = (SELECT (CASE WHEN (@CantRegistros + 4) % 10 = 0 THEN ((@CantRegistros + 4)/10) ELSE (FLOOR((@CantRegistros + 4)/10) + 1) END));
	--SET @FA_NUMERO_BLOQUES = RIGHT(concat(replicate(''0'', 6), @CantRegistrosPrev), 6);
	
	
		    SET @FA_NUMERO_BLOQUES = RIGHT(concat(replicate(''0'', 6), (SELECT CEILING((count(*)+1) / CONVERT(FLOAT, 10))
																  FROM ITF_TRAN_MINORISTA_PRESENTADAS_AUX 
																  WHERE  ID>=(SELECT max(id) 
																  		  		FROM ITF_TRAN_MINORISTA_PRESENTADAS_AUX 
																  		  		WHERE LINEA LIKE ''1%''))), 6);
	
	
	
	
	
	SET @FA_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 8), @CantRegistros), 8);
			
	SET @FA_TOTALES_DE_CONTROL = @FL_TOTALES_DE_CONTROL; --igualo al totales de control de fin de lote pq tiene que ser igual
			
	SET @FA_SUMA_TOTAL_DEBITOS = RIGHT(concat(replicate(''0'', 12), (replace(@TotalesDebitos, ''.'', ''''))), 12);
			
	SET @FA_SUMA_TOTAL_CREDITOS = RIGHT(concat(replicate(''0'', 12), (replace(@TotalesCreditos, ''.'', ''''))),12);
	
	
	
	SET @FA_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 8), (SELECT count(id) 
																			 FROM ITF_TRAN_MINORISTA_PRESENTADAS_AUX 
																			 WHERE LINEA LIKE ''6%'' OR LINEA LIKE ''7%''
																			 AND ID >(SELECT max(tt.id) 
		  																  			  FROM ITF_TRAN_MINORISTA_PRESENTADAS_AUX tt
		  																  			  WHERE tt.LINEA LIKE ''1%''))), 8);
	
	SET @FA_TOTALES_DE_CONTROL =RIGHT(concat(replicate(''0'', 10), (SELECT sum(convert(INT,substring(LINEA,4,8)))
																 FROM ITF_TRAN_MINORISTA_PRESENTADAS_AUX
														  		 WHERE LINEA LIKE ''6%'' AND ID >(SELECT max(tt.id) 
		  																  FROM ITF_TRAN_MINORISTA_PRESENTADAS_AUX tt
		  																  WHERE tt.LINEA LIKE ''1%''))), 10);
	
	PRINT ''sum tot d''
	PRINT @FA_SUMA_TOTAL_DEBITOS
	PRINT ''sum tot c''
	PRINT @FA_SUMA_TOTAL_credITOS
	
	SET @FA_CANT_LOTES = RIGHT(concat(replicate(''0'', 6), (SELECT count(ID) FROM ITF_TRAN_MINORISTA_PRESENTADAS_AUX WHERE LINEA LIKE ''5%'')), 6);
	PRINT @FA_CANT_LOTES
	SET @FA_FIN_ARCHIVO = concat(@FA_ID_REG, @FA_CANT_LOTES, @FA_NUMERO_BLOQUES, @FA_CANT_REG_INDIVIDUAL_ADICIONAL, @FA_TOTALES_DE_CONTROL, @FA_SUMA_TOTAL_DEBITOS, @FA_SUMA_TOTAL_CREDITOS, @FA_RESERVADO);
			

	INSERT INTO dbo.ITF_TRAN_MINORISTA_PRESENTADAS_AUX (LINEA,correlativo) VALUES (@FA_FIN_ARCHIVO,1);
	

				

	------------------------------------------------------------------------------------------------------------------------------------------------------------------

END


');
execute('
create or ALTER PROCEDURE [dbo].[SP_COELSA_ENVIO_CHEQUES_PROPIOS_RECHAZADOS]
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
DECLARE @RI_CODIGO_TRANSAC VARCHAR(2) = ''26''; -- fijo
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
DECLARE @FL_CONTADOR_AL_INICIAR NUMERIC(20,0) = (SELECT NUMERICO_1 FROM ITF_MASTER_PARAMETROS WHERE CODIGO = 138);
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

------- Variables para registro adicional rechazo -------

DECLARE @CODIGO_RECHAZO VARCHAR(3);
DECLARE @TRACE_NUMBER VARCHAR(15); 
DECLARE @OTRO_RECHAZO VARCHAR(44);
DECLARE @RI_REGISTRO_INDIVIDUAL_ADICIONAL VARCHAR(100);

------------------------------------------
	
    --Condicion de reset del contador de reg individual
IF ISNULL((SELECT a.FECHA FROM ITF_MASTER_PARAMETROS a WHERE a.CODIGO = 138), CAST(''01-01-1800'' AS DATETIME)) <> (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK))
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
WHERE TIPO IN (''C'', ''A'') 
AND ESTADO = ''P'' 
AND FECHAPROCESO = (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK));


OPEN cursor_che_rechazados
	  
FETCH NEXT FROM cursor_che_rechazados INTO @ID, @CheFechaProceso, @CheCodigoTransaccion, @CheEntidadDebitar, @CheCuentaDebitar, @CheImporte, @CheFechaPresentado, @CheCodigoPostal, @CheFechaVencimiento, @CheNroCheque, @ChePuntoIntercambio, @CheTraceNumber, @CheEstado, @CheTipo, @CheCodRechazo, @CheInfoAdicional
	  
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
PRINT @FL_FIN_LOTE
		
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
		SET @RI_INFO_ADICIONAL = ''01'';

	END
    ELSE --la razon de este else, es que SumaSucursal, cuando hay excedente tiene que acumular 0888
    BEGIN
        SET @SumaSucursal += RIGHT(@CheEntidadDebitarV,4); 
        SET @SumaEntidad += LEFT(@CheEntidadDebitarV,4);
        SET @SumaImportes += @CheImporte;

        SET @RI_ENTIDAD_DEBITAR = RIGHT(concat(replicate(''0'', 8), @CheEntidadDebitar), 8);
		
        SET @RI_CUENTA_DEBITAR = RIGHT(concat(replicate(''0'', 17), @CheCuentaDebitar), 17);
	
        SET @RI_NUMERO_CHEQUE = concat(''00'', RIGHT(concat(replicate(''0'', 13), @CheNroCheque), 13));
        
        IF (@CheInfoAdicional IS NOT NULL )
        SET @RI_INFO_ADICIONAL = @CheInfoAdicional;
        ELSE
        SET @RI_INFO_ADICIONAL = ''00'';

    END
	
	SET @RI_IMPORTE = RIGHT(concat(replicate(''0'', 10), replace(CAST(@CheImporte AS VARCHAR),''.'','''')), 10);
			
	SET @RI_CODIGO_POSTAL =  concat(''00'', RIGHT(concat(replicate(''0'', 4), @CheCodigoPostal), 4));
		
	
		
	SET @RI_REGISTRO_ADICIONAL = ''1'';
	   	
	SET @RI_CONTADOR_REGISTRO = concat(''0311'', RIGHT(concat(replicate(''0'', 4), (''0097'')), 4),RIGHT(concat(replicate(''0'', 7), (SELECT NUMERICO_1 FROM ITF_MASTER_PARAMETROS WHERE CODIGO = 138)), 7));
	
	SET @RI_REGISTRO_INDIVIDUAL = concat(@RI_ID_REG, @RI_CODIGO_TRANSAC, @RI_ENTIDAD_DEBITAR, @RI_RESERVADO, @RI_CUENTA_DEBITAR, @RI_IMPORTE, @RI_NUMERO_CHEQUE, @RI_CODIGO_POSTAL, @RI_PUNTO_INTERCAMBIO, @RI_INFO_ADICIONAL, @RI_REGISTRO_ADICIONAL, @RI_CONTADOR_REGISTRO);
	


	
	INSERT INTO dbo.ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX (LINEA) VALUES (replace(@RI_REGISTRO_INDIVIDUAL, ''.'', ''''));
	
	/* Logica para agregar el registro adicional con el motivo del rechazo*/	
	IF(@Excedente=0 OR @Excedente<90000000)
	BEGIN
	SET @CODIGO_RECHAZO = ''R'' + RIGHT(CONCAT(''00'',@CheCodRechazo),2);
	SET @TRACE_NUMBER=  RIGHT(CONCAT(''000000000000000'',@CheTraceNumber),15); 
	SET @OTRO_RECHAZO = REPLICATE('' '',44);
	
	SET @RI_REGISTRO_INDIVIDUAL_ADICIONAL = concat(''799'',@CODIGO_RECHAZO,@TRACE_NUMBER,''      '',@CheEntidadDebitarV,@OTRO_RECHAZO,@RI_CONTADOR_REGISTRO);
	INSERT INTO dbo.ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX (LINEA) VALUES (replace(@RI_REGISTRO_INDIVIDUAL_ADICIONAL, ''.'', ''''));
	END
	
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
PRINT @FL_FIN_LOTE
		INSERT INTO dbo.ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX (LINEA) VALUES (replace(@FL_FIN_LOTE, ''.'', ''''));
		
	END
		
IF(0<(SELECT COUNT(*) FROM CLE_CHEQUES_CLEARING CC,CLE_CHEQUES_CLEARING_RECIBIDO CR WHERE CC.NUMERO_CHEQUE = CR.NUMERO_CHEQUE AND (CR.CANJE_INTERNO=''N'' OR CR.CANJE_INTERNO IS NULL) AND CC.FECHA_VALOR = (SELECT FECHAPROCESO FROM PARAMETROS) AND CR.ESTADO_DEVOLUCION<>0 AND CC.TZ_LOCK = 0 AND CR.TZ_LOCK = 0) AND (@FL_CONTADOR_AL_INICIAR<>(SELECT NUMERICO_1 FROM ITF_MASTER_PARAMETROS WHERE CODIGO = 138)))
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
DECLARE @CheCodigoCausalCD NUMERIC(3,0);
DECLARE @CheTraceNumberCD VARCHAR(15);
DECLARE @CheInfoAdicionalCD VARCHAR(2);
DECLARE @CheRegistrosAdicionalesCD VARCHAR(1);
-- Fin Variables Cursor --

DECLARE cursor_che_rechazados CURSOR FOR

SELECT concat(RIGHT(concat(replicate(''0'', 4), CC.NUMERO_BANCO), 4), RIGHT(concat(replicate(''0'',4), CC.NUMERO_DEPENDENCIA), 4)) AS EntidadDebitar,
	   CC.NUMERO_BANCO AS CODBANCO, 
	   CC.NUMERO_DEPENDENCIA AS SUCURSAL,  
	   RIGHT(concat(replicate(''0'', 12), CC.CUENTA), 12) AS CuentaDebitar,
	   CC.IMPORTE AS Importe,  
	   CC.NUMERO_CHEQUE AS NroCheque,
	   concat(''00'', RIGHT(concat(replicate(''0'', 4), CC.NUMERO_BANCO), 4)) AS CodigoPostal, 
	   concat(''0000'', RIGHT(concat(''0000'', CR.CODIGO_CAUSAL_DEVOLUCION), 4), replicate('' '', 8)) AS PtoIntercambio,
	   concat(CASE WHEN CC.MONEDA = 1 THEN ''0'' ELSE ''1'' END, ''0'') AS InfoAdicional,
	   CC.TRACKNUMBER,
	   CR.CODIGO_CAUSAL_DEVOLUCION
FROM  CLE_CHEQUES_CLEARING CC,CLE_CHEQUES_CLEARING_RECIBIDO CR 
WHERE CC.NUMERO_CHEQUE = CR.NUMERO_CHEQUE 
AND (CR.CANJE_INTERNO=''N'' OR CR.CANJE_INTERNO IS NULL) 
AND CC.FECHA_VALOR = (SELECT FECHAPROCESO FROM PARAMETROS) 
AND CR.ESTADO_DEVOLUCION<>0 
AND CC.TZ_LOCK = 0 
AND CR.TZ_LOCK = 0;

OPEN cursor_che_rechazados
	  
FETCH NEXT FROM cursor_che_rechazados INTO @CheEntidadDebitarCD, @CheBancoCD, @CheSucursalCD, @CheCuentaDebitarCD, @CheImporteCD, @CheNroChequeCD, @CheCodigoPostalCD, @ChePuntoIntercambioCD, @CheInfoAdicionalCD, @CheTraceNumberCD, @CheCodigoCausalCD
	  
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
PRINT @FL_FIN_LOTE
		
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
		SET @RI_INFO_ADICIONAL = ''01'';

	END
    ELSE --la razon de este else, es que SumaSucursal, cuando hay excedente tiene que acumular 0888
    BEGIN
        SET @SumaSucursal += RIGHT(concat(replicate(''0'', 4), @CheSucursalCD),4);
        SET @SumaEntidad += RIGHT(concat(replicate(''0'', 4), @CheBancoCD),4);
        SET @SumaImportes += @CheImporteCD;

        SET @RI_ENTIDAD_DEBITAR = @CheEntidadDebitarCD;
		
        SET @RI_CUENTA_DEBITAR = RIGHT(concat(replicate(''0'', 17), @CheCuentaDebitarCD), 17);
	
        SET @RI_NUMERO_CHEQUE = concat(''00'', RIGHT(concat(replicate(''0'', 13), @CheNroChequeCD), 13));

		SET @RI_INFO_ADICIONAL = ''00'';
  
    END

    
    
	
	SET @RI_IMPORTE = RIGHT(concat(replicate(''0'', 10), replace(CAST(@CheImporteCD AS VARCHAR),''.'','''')), 10);
			
	SET @RI_CODIGO_POSTAL =  concat(''00'', RIGHT(concat(replicate(''0'', 4), @CheCodigoPostalCD), 4));
		
		
	SET @RI_REGISTRO_ADICIONAL = ''1'';
	   	
	SET @RI_CONTADOR_REGISTRO = concat(''0311'', RIGHT(concat(replicate(''0'', 4), (''0097'')), 4),RIGHT(concat(replicate(''0'', 7), (SELECT NUMERICO_1 FROM ITF_MASTER_PARAMETROS WHERE CODIGO = 138)), 7));
	
	SET @RI_REGISTRO_INDIVIDUAL = concat(@RI_ID_REG, @RI_CODIGO_TRANSAC, @RI_ENTIDAD_DEBITAR, @RI_RESERVADO, @RI_CUENTA_DEBITAR, @RI_IMPORTE, @RI_NUMERO_CHEQUE, @RI_CODIGO_POSTAL, @RI_PUNTO_INTERCAMBIO, @RI_INFO_ADICIONAL, @RI_REGISTRO_ADICIONAL, @RI_CONTADOR_REGISTRO);
		

	
	INSERT INTO dbo.ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX (LINEA) VALUES (replace(@RI_REGISTRO_INDIVIDUAL, ''.'', ''''));
		
	/* Logica para agregar el registro adicional con el motivo del rechazo*/	
	IF(@Excedente=0 OR @Excedente<90000000)
	BEGIN
	SET @CODIGO_RECHAZO = ''R'' + RIGHT(CONCAT(''00'',(SELECT CODIGO_NACHA FROM CLE_TIPO_CAUSAL WHERE CODIGO_DE_CAUSAL=@CheCodigoCausalCD)),2);
	SET @TRACE_NUMBER=  RIGHT(CONCAT(''000000000000000'',@CheTraceNumberCD),15); 
	SET @OTRO_RECHAZO = REPLICATE('' '',44);
	
	SET @RI_REGISTRO_INDIVIDUAL_ADICIONAL = concat(''799'',@CODIGO_RECHAZO,@TRACE_NUMBER,''      '',@CheEntidadDebitarCD,@OTRO_RECHAZO,@RI_CONTADOR_REGISTRO);
	INSERT INTO dbo.ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX (LINEA) VALUES (replace(@RI_REGISTRO_INDIVIDUAL_ADICIONAL, ''.'', ''''));
	END
	
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
		


SET @FL_TOTALES_DE_CONTROL = concat(right(concat(replicate(''0'', 6), @SumaEntidad), 6), right(concat(replicate(''0'', 4),@SumaSucursal), 4)); --relleno y separo con ceros



--SET @TotalesControl += CAST(@FL_TOTALES_DE_CONTROL AS INTEGER);
SET @FL_SUMA_TOTAL_DEBITO_LOTE = RIGHT(concat(replicate(''0'', 12), (replace(@SumaImportes, ''.'', ''''))), 12); 
SET @FL_SUMA_TOTAL_CREDITO_LOTE = RIGHT(replicate(''0'', 12), 12);
--SET @TotalesDebitos += @SumaImportes;
SET @FL_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 6), @Cant_Reg_Individual_Adicional), 6); 

	   	
SET @FL_FIN_LOTE = concat(@FL_ID_REG, @FL_CODIGO_CLASE_TRANSAC, @FL_CANT_REG_INDIVIDUAL_ADICIONAL, @FL_TOTALES_DE_CONTROL, @FL_SUMA_TOTAL_DEBITO_LOTE, @FL_SUMA_TOTAL_CREDITO_LOTE, @FL_RESERVADO1, @FL_RESERVADO2, @FL_RESERVADO3, @FL_REG_ENTIDAD_ORIGEN, @FL_NUMERO_LOTE);

---- Grabamos FIN de lote solo si hay registros individuales ingresados
IF(0<(SELECT COUNT(*) FROM  CLE_CHEQUES_CLEARING CC,CLE_CHEQUES_CLEARING_RECIBIDO CR WHERE CC.NUMERO_CHEQUE = CR.NUMERO_CHEQUE AND (CR.CANJE_INTERNO=''N'' OR CR.CANJE_INTERNO IS NULL) AND CC.FECHA_VALOR = (SELECT FECHAPROCESO FROM PARAMETROS) AND CR.ESTADO_DEVOLUCION<>0 AND CC.TZ_LOCK = 0 AND CR.TZ_LOCK = 0))
	BEGIN		
PRINT @FL_FIN_LOTE
		INSERT INTO dbo.ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX (LINEA) VALUES (replace(@FL_FIN_LOTE, ''.'', ''''));
		
	END
	
	IF(0<(SELECT COUNT(*) FROM CLE_CHEQUES_AJUSTE WHERE ESTADO = ''F'' AND ENVIADO_RECIBIDO = ''R'' AND ESTADO_AJUSTE = ''R'') AND (@FL_CONTADOR_AL_INICIAR<>(SELECT NUMERICO_1 FROM ITF_MASTER_PARAMETROS WHERE CODIGO = 138)))
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
	WHERE ESTADO = ''F'' 
	AND ENVIADO_RECIBIDO = ''R'' 
	AND ESTADO_AJUSTE = ''R'';

	OPEN cursor_che_rechazados

	FETCH NEXT FROM cursor_che_rechazados INTO @CheNroChequeAJ, 
												@CheImporteAJ, 
												@CheBancoAJ, 
												@CheSucursalAJ, 
												@ChePostalAJ, 
												@CheTrackNumberAJ

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
		
		PRINT @FL_FIN_LOTE
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
		
		SET @RI_REGISTRO_ADICIONAL = ''1'';
	   	
		SET @RI_CONTADOR_REGISTRO = concat(''0311'', RIGHT(concat(replicate(''0'', 4), (''0097'')), 4),RIGHT(concat(replicate(''0'', 7), (SELECT NUMERICO_1 FROM ITF_MASTER_PARAMETROS WHERE CODIGO = 138)), 7));
	
		SET @RI_REGISTRO_INDIVIDUAL = concat(@RI_ID_REG, @RI_CODIGO_TRANSAC, @RI_ENTIDAD_DEBITAR, @RI_RESERVADO, @RI_CUENTA_DEBITAR, @RI_IMPORTE, @RI_NUMERO_CHEQUE, @RI_CODIGO_POSTAL, @RI_PUNTO_INTERCAMBIO, @RI_INFO_ADICIONAL, @RI_REGISTRO_ADICIONAL, @RI_CONTADOR_REGISTRO);
		

	
		INSERT INTO dbo.ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX (LINEA) VALUES (replace(@RI_REGISTRO_INDIVIDUAL, ''.'', ''''));
		
		
		/* Logica para agregar el registro adicional con el motivo del rechazo*/	
		IF(@Excedente=0 OR @Excedente<90000000)
		BEGIN
			SET @CODIGO_RECHAZO = ''R'' + RIGHT(CONCAT(''00'',81),2);
			SET @TRACE_NUMBER=  RIGHT(CONCAT(''000000000000000'',@CheTrackNumberAJ),15); 
			SET @OTRO_RECHAZO = REPLICATE('' '',44);
	
			SET @RI_REGISTRO_INDIVIDUAL_ADICIONAL = concat(''799'',@CODIGO_RECHAZO,@TRACE_NUMBER,''      '',@RI_ENTIDAD_DEBITAR,@OTRO_RECHAZO,@RI_CONTADOR_REGISTRO);
			INSERT INTO dbo.ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX (LINEA) VALUES (replace(@RI_REGISTRO_INDIVIDUAL_ADICIONAL, ''.'', ''''));
		END
	
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
IF(0<(SELECT COUNT(*) FROM ITF_COELSA_CHEQUES_RECHAZO WHERE ESTADO = ''P'' AND TIPO = ''D'' AND SUBSTRING(INFO_ADICIONAL, 1, 1) = @MONEDA  AND FECHAPROCESO = (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK))))
BEGIN
		  */	
	--SET @TotalesControl += @SumaEntidad + @SumaSucursal;
	SET @FL_TOTALES_DE_CONTROL = concat((RIGHT(concat(replicate(''0'', 6), @SumaEntidad), 6)), (RIGHT(concat(replicate(''0'', 4), @SumaSucursal), 4)));
	SET @FL_SUMA_TOTAL_DEBITO_LOTE = RIGHT(concat(replicate(''0'', 12), (replace(@SumaImportes, ''.'', ''''))), 12); 
	SET @FL_SUMA_TOTAL_CREDITO_LOTE = RIGHT(replicate(''0'', 12), 12);
	SET @TotalesDebitos += @SumaImportes;
	SET @FL_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 6), @Cant_Reg_Individual_Adicional), 6); 
	
	---- Grabamos FIN de lote solo si hay registros individuales ingresados
	IF(0<(SELECT COUNT(*) FROM CLE_CHEQUES_AJUSTE WHERE ESTADO = ''F'' AND ENVIADO_RECIBIDO = ''R'' AND ESTADO_AJUSTE = ''R''))
	BEGIN		
		SET @FL_TOTALES_DE_CONTROL = concat((RIGHT(concat(replicate(''0'', 6), @SumaEntidad), 6)), (RIGHT(concat(replicate(''0'', 4), @SumaSucursal), 4)));
		SET @FL_SUMA_TOTAL_DEBITO_LOTE = RIGHT(concat(replicate(''0'', 12), (replace(@SumaImportes, ''.'', ''''))), 12); 
		SET @FL_SUMA_TOTAL_CREDITO_LOTE = RIGHT(replicate(''0'', 12), 12); 
		SET @FL_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 6), @Cant_Reg_Individual_Adicional), 6); 
		SET @FL_FIN_LOTE = concat(@FL_ID_REG, @FL_CODIGO_CLASE_TRANSAC, @FL_CANT_REG_INDIVIDUAL_ADICIONAL, @FL_TOTALES_DE_CONTROL, @FL_SUMA_TOTAL_DEBITO_LOTE, @FL_SUMA_TOTAL_CREDITO_LOTE, @FL_RESERVADO1, @FL_RESERVADO2, @FL_RESERVADO3, @FL_REG_ENTIDAD_ORIGEN, @FL_NUMERO_LOTE);
PRINT @FL_FIN_LOTE
		INSERT INTO dbo.ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX (LINEA) VALUES (replace(@FL_FIN_LOTE, ''.'', ''''));
	END
	
	--***BLOQUE DE CODIGO NUEVO PARA CLE_RECEPCION_CHEQUES_DEV 08/05/2024 JI***--
   PRINT 	@FL_CONTADOR_AL_INICIAR
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
		SET @CL_NUMERO_LOTE = RIGHT(concat(replicate(''0'', 7), (@CL_NUMERO_LOTE + 1)), 7); 
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
		
PRINT @FL_FIN_LOTE	
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
			SET @CheImporteRCD = @Excedente;
			SET @CountExcedente += 1;
		END
		IF	(@CheImporteRCD>90000000)
		BEGIN
			SET @Excedente = (@CheImporteRCD - 90000000);
			SET @CheImporteRCD = 90000000;
			SET @CountExcedente += 1;
		END
		ELSE
    	BEGIN
       		SET @Excedente = 0;
    	END
		
	
	
        SET @SumaSucursal += 0888; --sumo la sucursal que hay que harcodear
        SET @SumaEntidad += LEFT(@CheBancoRCD,4);
        SET @SumaImportes += @CheImporteRCD;
		
        SET @RI_ENTIDAD_DEBITAR = concat(RIGHT(concat(replicate(''0'', 4), LEFT(@CheBancoRCD,4)), 4), ''0888'');
        SET @RI_CUENTA_DEBITAR = RIGHT(concat(replicate(''0'', 17), ''88888888888''), 17);
        SET @RI_NUMERO_CHEQUE = ''000088888888888'';  --ACA SE SETEAN LOS 8


	
		SET @RI_IMPORTE = RIGHT(concat(replicate(''0'', 10), replace(CAST(@CheImporteRCD AS VARCHAR),''.'','''')), 10);
			
		SET @RI_CODIGO_POSTAL =  concat(''00'', RIGHT(concat(replicate(''0'', 4), @ChePostalRCD), 4));
		
		SET @RI_INFO_ADICIONAL = ''00'';
		
		SET @RI_REGISTRO_ADICIONAL = ''0'';
	   	
		SET @RI_CONTADOR_REGISTRO = concat(''0311'', RIGHT(concat(replicate(''0'', 4), (''0097'')), 4),RIGHT(concat(replicate(''0'', 7), (SELECT NUMERICO_1 FROM ITF_MASTER_PARAMETROS WHERE CODIGO = 138)), 7));
	
		SET @RI_CODIGO_TRANSAC=''22'';
		
		SET @RI_REGISTRO_INDIVIDUAL = concat(@RI_ID_REG, @RI_CODIGO_TRANSAC, @RI_ENTIDAD_DEBITAR, @RI_RESERVADO, @RI_CUENTA_DEBITAR, @RI_IMPORTE, @RI_NUMERO_CHEQUE, @RI_CODIGO_POSTAL, @RI_PUNTO_INTERCAMBIO, @RI_INFO_ADICIONAL, @RI_REGISTRO_ADICIONAL, @RI_CONTADOR_REGISTRO);
		

		PRINT @RI_REGISTRO_INDIVIDUAL
		INSERT INTO dbo.ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX (LINEA) VALUES (replace(@RI_REGISTRO_INDIVIDUAL, ''.'', ''''));
		
		
		/* Logica para agregar el registro adicional con el motivo del rechazo*/	
--		IF(@Excedente=0 OR @Excedente<90000000)
--		BEGIN
--			SET @CODIGO_RECHAZO = ''R'' + RIGHT(CONCAT(''00'',@codRech),2);
--			SET @TRACE_NUMBER=  RIGHT(CONCAT(''000000000000000'',@CheTrackNumberRCD),15); 
--			SET @OTRO_RECHAZO = REPLICATE('' '',44);
	
--			SET @RI_REGISTRO_INDIVIDUAL_ADICIONAL = concat(''799'',@CODIGO_RECHAZO,@TRACE_NUMBER,''      '',@RI_ENTIDAD_DEBITAR,@OTRO_RECHAZO,@RI_CONTADOR_REGISTRO);
--			INSERT INTO dbo.ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX (LINEA) VALUES (replace(@RI_REGISTRO_INDIVIDUAL_ADICIONAL, ''.'', ''''));
--		END
	
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
			FETCH NEXT FROM cursor_che_rechazados INTO @CheNroChequeRCD, 
														@CheImporteRCD, 
														@CheBancoRCD, 
														@CheSucursalRCD, 
														@ChePostalRCD, 
														--@CheTrackNumberRCD,
														@codRech
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
	
	---- Grabamos FIN de lote solo si hay registros individuales ingresados
	IF(0<(SELECT count(*) 
			FROM CLE_RECEPCION_CHEQUES_DEV CD 
			LEFT JOIN CLI_DIRECCIONES DIR ON CD.BANCO_GIRADO=DIR.ID
--			JOIN ITF_COELSA_CHEQUES_PROPIOS CP ON CD.NUMERO_CHEQUE=CP.NRO_CHEQUE
			WHERE CD.ESTADO_DEVOLUCION=0 
			AND CD.TZ_LOCK=0 
			AND DIR.TZ_LOCK=0 ))
	BEGIN		
		SET @FL_TOTALES_DE_CONTROL = concat((RIGHT(concat(replicate(''0'', 6), @SumaEntidad), 6)), (RIGHT(concat(replicate(''0'', 4), @SumaSucursal), 4)));
		SET @FL_SUMA_TOTAL_DEBITO_LOTE = RIGHT(concat(replicate(''0'', 12), (replace(@SumaImportes, ''.'', ''''))), 12); 
		SET @FL_SUMA_TOTAL_CREDITO_LOTE = RIGHT(replicate(''0'', 12), 12); 
		SET @FL_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 6), @Cant_Reg_Individual_Adicional), 6); 
		
		SET @FL_FIN_LOTE = concat(@FL_ID_REG, @FL_CODIGO_CLASE_TRANSAC, @FL_CANT_REG_INDIVIDUAL_ADICIONAL, @FL_TOTALES_DE_CONTROL, @FL_SUMA_TOTAL_DEBITO_LOTE, @FL_SUMA_TOTAL_CREDITO_LOTE, @FL_RESERVADO1, @FL_RESERVADO2, @FL_RESERVADO3, @FL_REG_ENTIDAD_ORIGEN, @FL_NUMERO_LOTE);
PRINT @FL_FIN_LOTE
		INSERT INTO dbo.ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX (LINEA) VALUES (replace(@FL_FIN_LOTE, ''.'', ''''));
	END
	
	IF(@FL_CONTADOR_AL_INICIAR=(SELECT NUMERICO_1 FROM ITF_MASTER_PARAMETROS WHERE CODIGO = 138))
	BEGIN
PRINT @FL_FIN_LOTE
		SET @FL_FIN_LOTE = concat(@FL_ID_REG, @FL_CODIGO_CLASE_TRANSAC, @FL_CANT_REG_INDIVIDUAL_ADICIONAL, @FL_TOTALES_DE_CONTROL, @FL_SUMA_TOTAL_DEBITO_LOTE, @FL_SUMA_TOTAL_CREDITO_LOTE, @FL_RESERVADO1, @FL_RESERVADO2, @FL_RESERVADO3, @FL_REG_ENTIDAD_ORIGEN, @FL_NUMERO_LOTE);			
		INSERT INTO dbo.ITF_ENVIO_CHEQUES_PROPIOS_RECHAZADOS_AUX (LINEA) VALUES (replace(@FL_FIN_LOTE, ''.'', ''''));
	END
	
	
	--***¯\_(°.°)_/¯***--
	

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


');
