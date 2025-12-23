execute('CREATE OR ALTER   PROCEDURE [dbo].[SP_TRAN_MINORISTA_PRESENTADAS]
   @TICKET NUMERIC(16)
AS 
BEGIN

	------------ Limpieza de tabla auxiliar --------------------
	TRUNCATE TABLE dbo.ITF_TRAN_MINORISTA_PRESENTADAS_AUX;
	------------------------------------------------------------
	DECLARE @i INT=0;
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
		SET @CL_ID_EMPRESA = replicate(''0'', 10);
			
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
	Start:
	
		SET @t_op_referencia=RIGHT(concat(replicate('' '',3),@t_op_referencia),3)
		SET @CL_RESERVADO_CL=(SELECT RIGHT(concat(''000'',adicional_present),3) FROM  vta_transferencias_tipos WHERE ID_TIPO=@t_op_tipo)
		SET @CL_NOM_EMPRESA =  LEFT(concat(''PARTICULARES'',replicate('' '', 16)),16);

	
		IF (@SumaImportes > 9999999999.99 OR @SumaEntidad > 999999)  -- 99 millones
		BEGIN
	
			IF @SumaSucursal > 9999
			BEGIN
				SET @SobranteSucursal = CAST(substring(CAST(@SumaSucursal AS VARCHAR), 1, (len(@SumaSucursal) - 4)) AS NUMERIC);
				SET @SumaEntidad += @SobranteSucursal;
				SET @SumaSucursal = CAST(RIGHT(@SumaSucursal, 4) AS NUMERIC);
			END
		

	   		SET @FL_TOTALES_DE_CONTROL = concat((RIGHT(concat(replicate(''0'', 6), @SumaEntidad), 6)), (RIGHT(concat(replicate(''0'', 4), @SumaSucursal), 4)));
	   		SET @FL_SUMA_TOTAL_DEBITO_LOTE = RIGHT(replicate(''0'', 12), 12);
	   		SET @FL_SUMA_TOTAL_CREDITO_LOTE = RIGHT(concat(replicate(''0'', 12), (replace((SELECT sum(convert(bigint, substring(linea,30,10))) FROM ITF_TRAN_MINORISTA_PRESENTADAS_AUX WHERE LINEA LIKE ''6%'' AND id>(SELECT max(id) FROM ITF_TRAN_MINORISTA_PRESENTADAS_AUX WHERE LINEA LIKE ''5%'')), ''.'', ''''))), 12); 
	   		SET @TotalesCreditos += @SumaImportes;
	   		SET @FL_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 6), @Cant_Reg_Individual_Adicional), 6); 
	   	 	
	   		SET @FL_FIN_LOTE = concat(@FL_ID_REG, @FL_CODIGO_CLASE_TRANSAC, @FL_CANT_REG_INDIVIDUAL_ADICIONAL, @FL_TOTALES_DE_CONTROL, @FL_SUMA_TOTAL_DEBITO_LOTE, @FL_SUMA_TOTAL_CREDITO_LOTE, @FL_RESERVADO1, @FL_RESERVADO2, @FL_RESERVADO3, @FL_REG_ENTIDAD_ORIGEN, @FL_NUMERO_LOTE);
		
    
	
			INSERT INTO dbo.ITF_TRAN_MINORISTA_PRESENTADAS_AUX (LINEA) VALUES (replace(@FL_FIN_LOTE, ''.'', ''''));
		
			SET @FL_NUMERO_LOTE = CAST(@FL_NUMERO_LOTE AS NUMERIC) + 1;
			SET @FL_NUMERO_LOTE = RIGHT(concat(replicate(''0'', 7), @FL_NUMERO_LOTE), 7);
			SET @CL_NUMERO_LOTE = RIGHT(concat(replicate(''0'', 7), (0)), 7);
PRINT ''cl nro lote''
PRINT @CL_NUMERO_LOTE
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
			SET @FA_SUMA_TOTAL_CREDITOS = RIGHT(concat(replicate(''0'', 12), (replace((SELECT sum(convert(bigint, substring(linea,30,10))) FROM ITF_TRAN_MINORISTA_PRESENTADAS_AUX WHERE LINEA LIKE ''6%'' AND id>(SELECT max(id) FROM ITF_TRAN_MINORISTA_PRESENTADAS_AUX WHERE LINEA LIKE ''1%'')), ''.'', ''''))),12);
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
			SET @CL_ID_EMPRESA = replicate(''0'', 10)
			SET @CL_NUMERO_LOTE = RIGHT(concat(replicate(''0'', 7), (@CL_NUMERO_LOTE + 1)), 7);
			
			IF @t_ord_tipo_doc NOT IN (SELECT tipodocumento FROM CLI_TIPOSDOCUMENTOS WHERE TIPOPERSONA=''F'') 
			BEGIN
				SET @CL_NOM_EMPRESA =  LEFT(concat(@T_NOMBRE_ORDENANTE,replicate('' '', 16)),16);
				SET @CL_ID_EMPRESA = right(concat(replicate(''0'', 10),LEFT(@T_CUIT_ORD,10)),10)
			END
			

			SET @CL_CRITERIO_EMPRESA = replicate('' '', 20); -- AUN NO EXISTE AUTONUMERICO, FALTA DEFINIR 
		
		
		

			IF @t_ord_tipo_doc NOT IN (SELECT tipodocumento FROM CLI_TIPOSDOCUMENTOS WHERE TIPOPERSONA=''F'') 
			BEGIN
				SET @CL_NOM_EMPRESA =  LEFT(concat(@T_NOMBRE_ORDENANTE,replicate('' '', 16)),16);
				SET @CL_ID_EMPRESA = right(concat(replicate(''0'', 10),LEFT(@T_CUIT_ORD,10)),10)
			END

			IF(try_convert(NUMERIC,@CL_ID_EMPRESA)!=0)
				SET @CL_CODIGO_ORIGEN=RIGHT(CONCAT(''0'',RIGHT(@T_CUIT_ORD,1)),1)	

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
	
			IF @t_ord_tipo_doc NOT IN (SELECT tipodocumento FROM CLI_TIPOSDOCUMENTOS WHERE TIPOPERSONA=''F'')
			BEGIN
				SET @CL_NOM_EMPRESA =  LEFT(concat(@T_NOMBRE_ORDENANTE,replicate('' '', 16)),16);
				SET @CL_ID_EMPRESA = right(concat(replicate(''0'', 10),LEFT(@T_CUIT_ORD,10)),10)
			END
			
			IF try_convert(NUMERIC,@CL_ID_EMPRESA)!=0
				SET @CL_CODIGO_ORIGEN=RIGHT(CONCAT(''0'',RIGHT(@T_CUIT_ORD,1)),1)			
	
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
		IF	(@T_IMPORTE>99999999.99)
		BEGIN
			SET @Excedente = (@T_IMPORTE - 99999999.99);
			SET @T_IMPORTE = 99999999.99;
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
--    		IF (RIGHT((SELECT TOP 1 adicional_present FROM vta_transferencias_tipos WHERE id_tipo=@t_op_tipo AND tz_lock=0),1)=''C'')
--    			SET @num_id=''075''
--    		IF (RIGHT((SELECT TOP 1 adicional_present FROM vta_transferencias_tipos WHERE id_tipo=@t_op_tipo AND tz_lock=0),1)=''C'')
--    			SET @num_id=''075''
    		IF(@T_TIPO_DOC =''CUIT'')
    			SET @RI_CLIENTE_PAGADOR = CONCAT(''1'',@T_CUIT_BEN,''       '',@num_id);
    		IF(@T_TIPO_DOC =''CUIL'')
    			SET @RI_CLIENTE_PAGADOR = CONCAT(''2'',@T_CUIT_BEN,''       '',@num_id);
    		IF(@T_TIPO_DOC =''CDI'')
    			SET @RI_CLIENTE_PAGADOR = CONCAT(''3'',@T_CUIT_BEN,''       '',@num_id);
 
    	END

		IF @SumaImportes>9999999999.99 GOTO Start
		
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
     	--PRINT LEFT(@T_ben_cbu,7)
     	SET @RI_ENTIDAD_CREDITO = RIGHT(concat(replicate(''0'', 8), LEFT(@T_ben_cbu,7)),8);
	 	SET @RI_CUENTA_CREDITO = RIGHT(concat(replicate(''0'', 17), right(@T_ben_cbu,14)),17);	
        	
		SET @RI_REGISTRO_INDIVIDUAL = concat(@RI_ID_REG, @T_CODIGO_TRANSACCION, @RI_ENTIDAD_CREDITO, @RI_RESERVADO, @RI_CUENTA_CREDITO, @RI_IMPORTE, @RI_REFERENCIA_UNIVOCA, @RI_CLIENTE_PAGADOR, @RI_INFO_ADICIONAL, @RI_REGISTRO_ADICIONAL, @RI_CONTADOR_REGISTRO);
 
 
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
	SET @FL_SUMA_TOTAL_CREDITO_LOTE = RIGHT(concat(replicate(''0'', 12), (replace((SELECT sum(convert(bigint, substring(linea,30,10))) FROM ITF_TRAN_MINORISTA_PRESENTADAS_AUX WHERE LINEA LIKE ''6%'' AND id>(SELECT max(id) FROM ITF_TRAN_MINORISTA_PRESENTADAS_AUX WHERE LINEA LIKE ''5%'')), ''.'', ''''))), 12);
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
			
	SET @FA_SUMA_TOTAL_CREDITOS = RIGHT(concat(replicate(''0'', 12), (replace((SELECT sum(convert(bigint, substring(linea,30,10))) FROM ITF_TRAN_MINORISTA_PRESENTADAS_AUX WHERE LINEA LIKE ''6%'' AND id>(SELECT max(id) FROM ITF_TRAN_MINORISTA_PRESENTADAS_AUX WHERE LINEA LIKE ''1%'')), ''.'', ''''))),12);
	
	
	
	SET @FA_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 8), (SELECT count(id) 
																			 FROM ITF_TRAN_MINORISTA_PRESENTADAS_AUX 
																			 WHERE (LINEA LIKE ''6%'' OR LINEA LIKE ''7%'')
																			 AND id>(SELECT max(id) FROM ITF_TRAN_MINORISTA_PRESENTADAS_AUX WHERE LINEA LIKE ''1%''))), 8);
	
	SET @FA_TOTALES_DE_CONTROL =RIGHT(concat(replicate(''0'', 10), (SELECT sum(convert(INT,substring(LINEA,4,8)))
																 FROM ITF_TRAN_MINORISTA_PRESENTADAS_AUX
														  		 WHERE LINEA LIKE ''6%'' AND ID >(SELECT max(tt.id) 
		  																  FROM ITF_TRAN_MINORISTA_PRESENTADAS_AUX tt
		  																  WHERE tt.LINEA LIKE ''1%''))), 10);
	
	PRINT ''sum tot d''
	PRINT @FA_SUMA_TOTAL_DEBITOS
	PRINT ''sum tot c''
	PRINT @FA_SUMA_TOTAL_credITOS
	
	PRINT @FA_CANT_REG_INDIVIDUAL_ADICIONAL
	
	SET @FA_CANT_LOTES = RIGHT(concat(replicate(''0'', 6), (SELECT count(ID) FROM ITF_TRAN_MINORISTA_PRESENTADAS_AUX WHERE LINEA LIKE ''5%'' AND id>(SELECT max(id) FROM ITF_TRAN_MINORISTA_PRESENTADAS_AUX WHERE LINEA LIKE ''1%''))), 6);
	PRINT @FA_CANT_LOTES
	SET @FA_FIN_ARCHIVO = concat(@FA_ID_REG, @FA_CANT_LOTES, @FA_NUMERO_BLOQUES, @FA_CANT_REG_INDIVIDUAL_ADICIONAL, @FA_TOTALES_DE_CONTROL, @FA_SUMA_TOTAL_DEBITOS, @FA_SUMA_TOTAL_CREDITOS, @FA_RESERVADO);
			
	INSERT INTO dbo.ITF_TRAN_MINORISTA_PRESENTADAS_AUX (LINEA,correlativo) VALUES (@FA_FIN_ARCHIVO,1);
	------------------------------------------------------------------------------------------------------------------------------------------------------------------

END');

EXECUTE('CREATE OR ALTER        PROCEDURE [dbo].[SP_DD_PRESENTADOS_EMITIDOS]
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

	DECLARE @T_PRESTACION VARCHAR(10);
	DECLARE @T_TIPO VARCHAR(1);
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
	DECLARE @CL_CODIGO_ORIGEN VARCHAR(1) = ''0''; -- fijo
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
	DECLARE @T_SEGUNDO_VTO DATETIME;
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
	DECLARE @T_ESTADO_PROCESO NUMERIC(1,0);



	IF((SELECT COUNT(1) 
		FROM SNP_MSG_ORDENES o 
		LEFT JOIN SNP_MSG_CABEZAL c ON o.CUIT_EO=c.CUIT_EO AND o.ID_ARCHIVO=c.ID_ARCHIVO AND o.NRO_ARCHIVO=c.NRO_ARCHIVO AND o.TZ_LOCK=0 AND c.TZ_LOCK=0 
		LEFT JOIN SNP_CUENTAS_RELACIONADAS r ON r.CUIT_EO=o.CUIT_EO AND r.PRESTACION=o.PRESTACION AND r.RELACION_CUENTA=1 and r.TZ_LOCK=0
 		WHERE ((o.ESTADO=''PP'' AND o.PRESENTACION_PRIMER_VTO=(SELECT fechaproceso FROM PARAMETROS)) OR (o.ESTADO=''RC'' AND o.PRESENTACION_SEGUNDO_VTO=(SELECT fechaproceso FROM PARAMETROS)))
		AND o.TZ_LOCK=0 ) 
		+ 
	   (SELECT COUNT(1) 
		FROM SNP_ADHESIONES o 
		LEFT JOIN SNP_CUENTAS_RELACIONADAS r ON r.CUIT_EO=o.CUIT_EO AND r.PRESTACION=o.PRESTACION AND r.RELACION_CUENTA=1 and r.TZ_LOCK=0
		WHERE o.TZ_LOCK=0 )
		=0)
	BEGIN
		---------------- Grabar Cabecera Lote ---------------------------
		SET @CL_NUMERO_LOTE = RIGHT(concat(replicate(''0'', 7), (SELECT COUNT(*) + 1 FROM ITF_DD_PRESENTADOS_EMITIDOS_AUX WHERE LINEA LIKE ''5%'')), 7);
		SET @CL_NOM_EMPRESA =  replicate('' '', 16);
		SET @CL_CRITERIO_EMPRESA = replicate('' '', 20); -- AUN NO EXISTE AUTONUMERICO, FALTA DEFINIR 
		SET @CL_ID_EMPRESA = LEFT(concat(@T_CUIT,replicate('' '', 10)),10);
		
		SET @CL_CABECERA = concat(@CL_ID_REG, @CL_CODIGO_CLASE_TRANSAC, @CL_NOM_EMPRESA,@CL_CRITERIO_EMPRESA,@CL_ID_EMPRESA, @CL_TIPO_REGISTRO, @CL_DESCRIP_TRANSAC, @CL_FECHA_PRESENTACION, @CL_FECHA_VENCIMIENTO, @CL_RESERVADO_CL, @CL_CODIGO_ORIGEN, @CL_ID_ENTIDAD_ORIGEN, @CL_NUMERO_LOTE);
		INSERT INTO dbo.ITF_DD_PRESENTADOS_EMITIDOS_AUX (LINEA) VALUES (@CL_CABECERA);
	END 
		
    --Condicion de reset del contador de reg individual
	IF ISNULL((SELECT a.FECHA FROM ITF_MASTER_PARAMETROS a WHERE a.CODIGO = 148), CAST(''01-01-1800'' AS DATETIME)) <> (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK))
    	UPDATE dbo.ITF_MASTER_PARAMETROS SET NUMERICO_1 = 1, FECHA = (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)) WHERE CODIGO = 148;
 
 


	DECLARE CursorDD CURSOR FOR

	SELECT o.CORRELATIVO AS CORRELATIVO,
			r.SALDO_JTS_OID AS SALDO_JTS_OID, 
			o.MONEDA AS MONEDA,
			o.IMPORTE AS IMPORTE, 
			o.FECHA_VENCIMIENTO AS FECHA_VENCIMIENTO,
			o.SEGUNDO_VTO AS SEGUNDO_VTO, 
			o.FECHA_COMPENSACION AS FECHA_COMPENSACION, 
			o.CBU AS CBU, 
			o.REFERENCIA AS REFERENCIA, 
			o.Codigo_Cliente AS CODIGO_CLIENTE, 
			o.CUIT_EO AS CUIT_EO, 
			o.ID_ARCHIVO_REVERSADO AS ID_ARCHIVO_REVERSADO,
			O.CLIENTE_PAGADOR AS CLIENTE_PAGADOR, 
			o.presentacion_primer_vto AS presentacion_primer_vto,
			o.presentacion_segundo_vto AS presentacion_segundo_vto,
			o.id_archivo AS id_archivo,
			o.nro_archivo AS nro_archivo,
			O.PRESTACION AS PRESTACION,
			''O'' AS TIPO,
			0 AS ESTADO_PROCESO
	FROM SNP_MSG_ORDENES o 
	LEFT JOIN SNP_MSG_CABEZAL c ON o.CUIT_EO=c.CUIT_EO AND o.ID_ARCHIVO=c.ID_ARCHIVO AND o.NRO_ARCHIVO=c.NRO_ARCHIVO AND o.TZ_LOCK=0 AND c.TZ_LOCK=0 
	LEFT JOIN SNP_CUENTAS_RELACIONADAS r ON r.CUIT_EO=o.CUIT_EO AND r.PRESTACION=o.PRESTACION AND r.RELACION_CUENTA=1 and r.TZ_LOCK=0
 	WHERE ((o.ESTADO=''PP'' AND o.PRESENTACION_PRIMER_VTO=(SELECT fechaproceso FROM PARAMETROS)) OR (o.ESTADO=''RC'' AND o.PRESENTACION_SEGUNDO_VTO=(SELECT fechaproceso FROM PARAMETROS)))
	AND o.TZ_LOCK=0 

	UNION

	SELECT NULL AS CORRELATIVO,
			r.SALDO_JTS_OID AS SALDO_JTS_OID, 
			o.MONEDA AS MONEDA,
			NULL AS IMPORTE, 
			o.FECHA_VENCIMIENTO AS FECHA_VENCIMIENTO,
			NULL AS SEGUNDO_VTO, 
			NULL AS FECHA_COMPENSACION, 
			o.CBU AS CBU, 
			NULL AS REFERENCIA, 
			o.Cliente_adherido AS codigo_cliente, 
			o.CUIT_EO AS CUIT_EO, 
			NULL AS ID_ARCHIVO_REVERSADO,
			NULL AS CLIENTE_PAGADOR, --posiblemente id cliente pagador
			NULL AS presentacion_primer_vto,
			NULL AS presentacion_segundo_vto,
			NULL AS id_archivo,
			NULL AS nro_archivo,
			O.PRESTACION AS PRESTACION,
			''A'' AS TIPO,
			ISNULL(o.estado_proceso,0) AS ESTADO_PROCESO
	FROM SNP_ADHESIONES o 
	LEFT JOIN SNP_CUENTAS_RELACIONADAS r ON r.CUIT_EO=o.CUIT_EO AND r.PRESTACION=o.PRESTACION AND r.RELACION_CUENTA=1 and r.TZ_LOCK=0
	WHERE o.TZ_LOCK=0 
	AND o.estado_proceso<>0
	ORDER BY CUIT_EO, MONEDA, ID_ARCHIVO_REVERSADO

				        		
	OPEN CursorDD
	FETCH NEXT FROM CursorDD INTO @T_ID_DEBITO, 
								  @T_JTS_OID, 
								  @T_MONEDA, 
								  @T_IMPORTE, 
								  @T_FECHA_VTO,
								  @T_SEGUNDO_VTO,
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
								  @T_NRO_ARCHIVO,
								  @T_PRESTACION,
								  @T_TIPO,
								  @T_ESTADO_PROCESO

	WHILE @@FETCH_STATUS = 0
	BEGIN

	
		SET @CL_DESCRIP_TRANSAC= RIGHT(concat(replicate('' '', 10), @T_PRESTACION), 10);
		IF @T_TIPO=''O''
		BEGIN	
			SET @CL_FECHA_PRESENTACION = CONVERT(VARCHAR, @T_PRES_1ER_VTO, 12);
			SET @CL_FECHA_VENCIMIENTO = convert(VARCHAR,dbo.diaHabil( dateadd(dd,1, @T_PRES_1ER_VTO),''A''), 12); 
		END
		ELSE 
		BEGIN
	  		SET @CL_FECHA_presentacion = convert(VARCHAR,dbo.ProximoDiaHabilDespuesNDias((SELECT fechaproceso FROM PARAMETROS (nolock)), 10), 12);
	 		SET @CL_FECHA_vencimiento = convert(VARCHAR,dbo.ProximoDiaHabilDespuesNDias((SELECT fechaproceso FROM PARAMETROS (nolock)), 11), 12);

		END

		SET @CL_CODIGO_ORIGEN = RIGHT(@T_CUIT,1);

	
		Start:
		IF (@SumaImportes > 9999999999.99 OR @SumaEntidad > 999999) -- 99 millones
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
PRINT @FL_NUMERO_LOTE
    
	
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
			SET @CL_NOM_EMPRESA = RIGHT(concat(replicate('' '', 16),(SELECT NOMBRE_EMPRESA 
																   FROM SNP_PRESTACIONES_EMPRESAS 
																   WHERE CUIT_EO=@T_CUIT 
																   AND PRESTACION=@T_PRESTACION))
																   ,16);
			SET @CL_CRITERIO_EMPRESA = replicate('' '', 20); -- AUN NO EXISTE AUTONUMERICO, FALTA DEFINIR 
			SET @CL_ID_EMPRESA = LEFT(concat(@T_CUIT,replicate('' '', 10)),10);
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
				--SET @FL_TOTALES_DE_CONTROL = concat((RIGHT(concat(replicate(''0'', 6), @SumaEntidad), 6)), (RIGHT(concat(replicate(''0'', 4), @SumaSucursal), 4)));
	
		   	   	SET @FL_TOTALES_DE_CONTROL = (RIGHT(concat(replicate(''0'', 10), (SELECT sum(convert(numeric,substring(linea,4,8)))
																				FROM ITF_DD_PRESENTADOS_EMITIDOS_AUX
																				WHERE LINEA LIKE ''6%'' 
																				AND ID>(SELECT max(id) 
																						FROM ITF_DD_PRESENTADOS_EMITIDOS_AUX 
																						WHERE LINEA LIKE ''5%''))), 10))
	
	
	
 				--SET @FL_SUMA_TOTAL_DEBITO_LOTE = RIGHT(concat(replicate(''0'', 12), (replace(@SumaImportes, ''.'', ''''))), 12); 
   	
   		   		SET @FL_SUMA_TOTAL_DEBITO_LOTE = RIGHT(concat(replicate(''0'', 12), (replace((SELECT convert(NUMERIC(15,2),sum(convert(NUMERIC,substring(linea,30,10)))/100) FROM ITF_DD_PRESENTADOS_EMITIDOS_AUX WHERE LINEA LIKE ''6%'' AND ID>(SELECT max(id) FROM ITF_DD_PRESENTADOS_EMITIDOS_AUX WHERE LINEA LIKE ''5%'') ), ''.'', ''''))), 12); 

   	
   				SET @FL_SUMA_TOTAL_CREDITO_LOTE = RIGHT(replicate(''0'', 12), 12);
   				SET @TotalesDebitos += @SumaImportes;
   				SET @FL_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 6), (SELECT COUNT(*) FROM ITF_DD_PRESENTADOS_EMITIDOS_AUX WHERE (LINEA LIKE ''6%'' or linea like ''7%'') and id>(select max(id) from ITF_DD_PRESENTADOS_EMITIDOS_AUX where linea like ''5%''))), 6); 
   	
   				SET @FL_FIN_LOTE = concat(@FL_ID_REG, @FL_CODIGO_CLASE_TRANSAC, @FL_CANT_REG_INDIVIDUAL_ADICIONAL, @FL_TOTALES_DE_CONTROL, @FL_SUMA_TOTAL_DEBITO_LOTE, @FL_SUMA_TOTAL_CREDITO_LOTE, @FL_RESERVADO1, @FL_RESERVADO2, @FL_RESERVADO3, @FL_REG_ENTIDAD_ORIGEN, @FL_NUMERO_LOTE);

				INSERT INTO dbo.ITF_DD_PRESENTADOS_EMITIDOS_AUX (LINEA) VALUES (replace(@FL_FIN_LOTE, ''.'', ''''));
PRINT @FL_NUMERO_LOTE

				SET @FL_NUMERO_LOTE = RIGHT(concat(replicate(''0'', 7), CAST(@FL_NUMERO_LOTE AS NUMERIC) + 1), 7);
			END
	
			SET @T_REVERSADO= @Reversado;
   			SET @CUIT = @T_CUIT;
			SET @MONEDA = @T_MONEDA;
			SET @CL_NUMERO_LOTE = RIGHT(concat(replicate(''0'', 7), (@CL_NUMERO_LOTE + 1)), 7);
	
			SET @CL_NOM_EMPRESA =  RIGHT(concat(replicate('' '', 16),(SELECT NOMBRE_EMPRESA FROM SNP_PRESTACIONES_EMPRESAS WHERE CUIT_EO=@T_CUIT AND PRESTACION=@T_PRESTACION)),16);

		--	SET @CL_NOM_EMPRESA =  LEFT((SELECT NOMBRE_EMPRESA FROM SNP_PRESTACIONES_EMPRESAS WHERE CUIT_EO=@T_CUIT AND PRESTACION=@T_PRESTACION),16);
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
	

		IF @T_PRES_1ER_VTO =(SELECT fechaproceso FROM PARAMETROS with (nolock))
		BEGIN
			SET @T_CONTADOR_1=@T_CONTADOR_1+1
			SET @T_TRACENUMBER = concat(''0311'', RIGHT(concat(replicate(''0'', 4), (@T_SUCURSAL_TN)), 4), RIGHT(concat(replicate(''0'', 7), @T_CONTADOR_1), 7)); 
			UPDATE SNP_MSG_ORDENES
			SET TRACE_N_1PRE=@T_TRACENUMBER,
				fecha_compensacion=DBO.diaHabil(dateadD(DAY,1,@T_FECHA_VTO),''A'')
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
			SET TRACE_N_2PRE=@T_TRACENUMBER,
				fecha_compensacion=DBO.diaHabil(dateadD(DAY,1,@T_SEGUNDO_VTO),''A'')
			WHERE CORRELATIVO=@T_ID_DEBITO 
			AND cuit_eo=@T_CUIT 
			AND ID_ARCHIVO=@T_ID_ARCHIVO 
			AND NRO_ARCHIVO=@T_NRO_ARCHIVO
		END 
	
		UPDATE SNP_ADHESIONES
		SET FECHA_PRESENTACION=(SELECT FECHAPROCESO FROM PARAMETROS (NOLOCK)),
			fecha_VENCIMIENTO=dbo.ProximoDiaHabilDespuesNDias((SELECT FECHAPROCESO FROM PARAMETROS (NOLOCK)), 10),
			fecha_ciclo_comp=dbo.ProximoDiaHabilDespuesNDias((SELECT FECHAPROCESO FROM PARAMETROS (NOLOCK)), 11),
			tracknumber=@T_TRACENUMBER
		WHERE CLIENTE_ADHERIDO=@T_CODIGO_CLIENTE 
		AND cuit_eo=@T_CUIT 
		AND PRESTACION=@T_PRESTACION 

		--HASTA ACA	

		IF(@T_MONEDA= (SELECT C6399 FROM MONEDAS WHERE C6403=''N''))
		BEGIN
			SET @T_COD_BANCO=311;
			SET @RI_INFO_ADICIONAL=CONCAT(''0'',@T_ESTADO_PROCESO);
		END
		ELSE
		BEGIN
	 		SET @T_COD_BANCO=811;
	 		SET @RI_INFO_ADICIONAL=CONCAT(''1'',@T_ESTADO_PROCESO);
	 	END
	
	 	SET @CantRegistros += 1;
	 	SET @Cant_Reg_Individual_Adicional += 1;
	
	 	IF	(@Excedente<>0)
	 	BEGIN
	 		SET @T_IMPORTE = @Excedente;
	 		SET @CountExcedente += 1;
	 	END
	 	IF	(@T_IMPORTE>99999999.99)
	 	BEGIN
	 		SET @Excedente = (@T_IMPORTE - 99999999.99);
	 		SET @T_IMPORTE = 99999999.99;
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
	 	IF @T_TIPO=''A''
	 		SET @T_CODIGO_TRANSACCION = ''38'';
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

		IF @SumaImportes>9999999999.99 GOTO Start
    
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
 
   		INSERT INTO dbo.ITF_DD_PRESENTADOS_EMITIDOS_AUX (LINEA, CORRELATIVO,ID_ARCHIVO,NRO_ARCHIVO,PRESTACION,CLIENTE_ADHERIDO) VALUES (replace(@RI_REGISTRO_INDIVIDUAL, ''.'', ''''),@T_ID_DEBITO,@T_ID_ARCHIVO,@T_NRO_ARCHIVO,@T_PRESTACION,@T_CODIGO_CLIENTE);
		-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		/* Logica para agregar el registro adicional*/	
		IF(@T_ID_ARCHIVO_REVERSADO=0 OR @T_ID_ARCHIVO_REVERSADO IS NULL)
		BEGIN
	
			SET @RO_CONCEPTO = REPLICATE('' '',80);
			SET @RO_NUM_SECUENCIA_ADICIONAL= RIGHT(concat(replicate(''0'', 4), (@RO_NUM_SECUENCIA_ADICIONAL + 1)), 4);
	
			SET @RI_REGISTRO_INDIVIDUAL = concat(''705'',@RO_CONCEPTO,@RO_NUM_SECUENCIA_ADICIONAL,RIGHT(@T_TRACENUMBER, 7));
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
	
 			FETCH NEXT FROM CursorDD INTO @T_ID_DEBITO, @T_JTS_OID, @T_MONEDA, @T_IMPORTE, @T_FECHA_VTO,@T_SEGUNDO_VTO,@T_FECHA_COMP,@T_CBU, @T_REFERENCIA, @T_CODIGO_CLIENTE, @T_CUIT, @T_ID_ARCHIVO_REVERSADO,@T_CLIENTE_PAGADOR,@T_PRES_1ER_VTO,@T_PRES_2DO_VTO,@T_ID_ARCHIVO,@T_NRO_ARCHIVO,@T_PRESTACION,@T_TIPO,@T_ESTADO_PROCESO
	
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

PRINT @FL_NUMERO_LOTE
	
 	INSERT INTO dbo.ITF_DD_PRESENTADOS_EMITIDOS_AUX (LINEA) VALUES (@FA_FIN_ARCHIVO);
	
				
 	SET @FL_NUMERO_LOTE = CAST(@FL_NUMERO_LOTE AS NUMERIC) + 1;
 	SET @FL_NUMERO_LOTE = RIGHT(concat(replicate(''0'', 7), @FL_NUMERO_LOTE), 7);
 	------------------------------------------------------------------------------------------------------------------------------------------------------------------

END');


EXECUTE('CREATE OR ALTER       PROCEDURE [dbo].[SP_COELSA_CHEQUES_TERCEROS_RECHAZADOS]

	@TICKET NUMERIC(16)

AS
BEGIN

	/******** Variables Cabecera de Archivo **********************************/
	DECLARE @IdRegistro NUMERIC(1);
	DECLARE @CodPrioridad NUMERIC(2);
	DECLARE @DestinoInmediato VARCHAR(10);
	DECLARE @OrigenInmediato VARCHAR(10);
	DECLARE @FechaPresentacion DATE;
	DECLARE @HoraPresentacion NUMERIC(4);
	DECLARE @IdArchivo VARCHAR(1);
	DECLARE @TamanioRegistro VARCHAR(3);
	DECLARE @FactorBloque VARCHAR(2);
	DECLARE @CodFormato NUMERIC(1);
	DECLARE @NomDestinoInmediato VARCHAR(23);
	DECLARE @NomOrigenInmediato VARCHAR(23);
	DECLARE @CodReferencia VARCHAR(8);
	/*************************************************************************/

	/******** Variables Cabecera de Lote **********************************/
	DECLARE @FechaVencimiento DATE;
	DECLARE @ClaseTransaccion NUMERIC(3);
	DECLARE @ReservadoLote VARCHAR(46);
	DECLARE @ReservadoLoteCeros NUMERIC(3);
	DECLARE @CodigoOrigen  NUMERIC(1);
	DECLARE @CodigoRegistro VARCHAR(3);
	DECLARE @IdEntidadOrigen NUMERIC(8);
	declare @NumeroLote NUMERIC(7);

	/******** Variables Registro Individual de Cheques y Ajustes *************/
	DECLARE @CodTransaccion VARCHAR(2);
	DECLARE @EntidadDebitar VARCHAR(8);
	DECLARE @ReservadoRI VARCHAR(1);
	DECLARE @CuentaDebitar VARCHAR(17);
	DECLARE @Importe VARCHAR(10);
	DECLARE @NumeroCheque VARCHAR(15);
	DECLARE @CodigoPostal VARCHAR(6);
	DECLARE @PuntoIntercambio VARCHAR(16);
	DECLARE @InfoAdicional VARCHAR(2);
	DECLARE @RegistrosAdicionales VARCHAR(2);
	DECLARE @ContadorRegistros VARCHAR(15);
	
	DECLARE @CodRechazo VARCHAR (2);
	DECLARE @CODCLI NUMERIC(12);
	DECLARE @PRODUCTO NUMERIC(5);
	DECLARE @ORDINAL NUMERIC(6);
	DECLARE @Entidad NUMERIC(4);

    
	--SE VAN A USAR ESTOS CAMPOS COMO CLAVE EN LUGAR DEL TRACENUMBER
	
	DECLARE @Entidad_RI VARCHAR(4);	-- SE CAMBIA TIPO A VARCHAR PORQUE AHORA NO SE VALIDA MAS EL REG INDIVIDUAL
	DECLARE @Sucursal_RI VARCHAR(4); -- SE CAMBIA TIPO A VARCHAR PORQUE AHORA NO SE VALIDA MAS EL REG INDIVIDUAL
	DECLARE @CodigoPostal_RI VARCHAR(4); -- SE CAMBIA TIPO A VARCHAR PORQUE AHORA NO SE VALIDA MAS EL REG INDIVIDUAL
	DECLARE @NumeroCuenta_RI VARCHAR(12); -- SE CAMBIA TIPO A VARCHAR PORQUE AHORA NO SE VALIDA MAS EL REG INDIVIDUAL
	DECLARE @NumeroCheque_RI VARCHAR(12); -- SE CAMBIA TIPO A VARCHAR PORQUE AHORA NO SE VALIDA MAS EL REG INDIVIDUAL

	DECLARE @ExisteRI NUMERIC(1) = 0; --para saber si hay al menos 1 lote
	
	/******** Variables FIN DE LOTE *************/
	DECLARE @RegIndivAdic NUMERIC(6);
	DECLARE @TotalesControl NUMERIC(10);
	DECLARE @ReservadoFL VARCHAR(40);

	/******** Variables FIN DE ARCHIVO *************/

	DECLARE @CantLotesFA NUMERIC(6);
	DECLARE @NumBloquesFA NUMERIC(6);
	DECLARE @CantRegAdFA NUMERIC (8);
	DECLARE @TotalesControlFA NUMERIC(10);

	DECLARE @ReservadoFA VARCHAR(39);
	/*************************************************************************/


	/*Validaciones generales */

	DECLARE @updRecepcion VARCHAR(1);

	--#validacion1
	IF(0=(SELECT COUNT(*) FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX WHERE LINEA LIKE ''1%''))
		RAISERROR (''Error - Faltan registros.'', 16, 1);
	IF(0=(SELECT COUNT(*) FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX WHERE LINEA LIKE ''5%''))
		RAISERROR (''Error - Faltan registros.'', 16, 1);
	IF(0=(SELECT COUNT(*) FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX WHERE LINEA LIKE ''8%''))
		RAISERROR (''Error - Faltan registros.'', 16, 1);
	IF(0=(SELECT COUNT(*) FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX WHERE LINEA LIKE ''9%''))
		RAISERROR (''Error - Faltan registros.'', 16, 1);

	--#validacion2
	IF ((SELECT COUNT(*) FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX WHERE LINEA LIKE ''1%'' OR LINEA LIKE ''9%'') > 2 )
		RAISERROR(''Error - Deben haber solo 1 reg CA y 1 reg FA'', 16, 1);

	--#validacion3
	IF(
	(SELECT COUNT(1) as Orden
	WHERE 1=(SELECT count(1)
			WHERE EXISTS (SELECT CONVERT(INT,SUBSTRING(LINEA,1,1))
							FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX
							WHERE ID IN	(SELECT ID-1
										FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX
										WHERE LINEA LIKE ''8%'')
							AND CONVERT(INT,SUBSTRING(LINEA,1,1)) NOT IN (5,6,7)
						)
			)
		OR 1=(SELECT count(1)
			WHERE EXISTS (SELECT CONVERT(INT,SUBSTRING(LINEA,1,1))
							FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX
							WHERE ID IN	(SELECT ID+1
										FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX
										WHERE LINEA LIKE ''8%'')
										AND CONVERT(INT,SUBSTRING(LINEA,1,1)) NOT IN (5,9)
							)
			)
		OR 1=(SELECT count(1)
			WHERE EXISTS (SELECT CONVERT(INT,SUBSTRING(LINEA,1,1))
						FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX
						WHERE ID IN	(SELECT ID-1
									FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX
									WHERE LINEA LIKE ''5%'')
						AND CONVERT(INT,SUBSTRING(LINEA,1,1)) NOT IN (1,8)
							)
					)
		OR 1=(SELECT count(1)
			WHERE EXISTS (SELECT CONVERT(INT,SUBSTRING(LINEA,1,1))
							FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX
							WHERE ID IN	(SELECT ID+1
										FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX
										WHERE LINEA LIKE ''5%'')
							AND CONVERT(INT,SUBSTRING(LINEA,1,1)) NOT IN (6,7,8)
							)
						)) <> 0
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
	FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX
	WHERE LINEA LIKE ''626%'';

	SELECT --creditos
		@sumaCreditos_RI = sum(CAST(substring(LINEA, 30, 10) AS NUMERIC)),
		@sumaEntidades_RIaux = sum(CAST(substring(LINEA, 4, 4) AS NUMERIC)),
		@sumaSucursales_RIaux = sum(CAST(substring(LINEA, 8, 4) AS NUMERIC))
	FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX
	WHERE LINEA LIKE ''622%'';

	SET @sumaEntidades_RI += isNull(@sumaEntidades_RIaux,0);
	SET @sumaSucursales_RI += isNull(@sumaSucursales_RIaux,0);
	

	--seteo total control y total de importes FA
	SELECT
		@totControl_FA = CAST(substring(linea, 22, 10) AS NUMERIC), --revisar acaaaa
		@totalDebitos_FA = CAST(substring(linea, 32, 12) AS NUMERIC),
		@totalCreditos_FA = CAST(substring(linea, 44, 12) AS NUMERIC)
	FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX
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
	FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX
	WHERE LINEA LIKE ''8%'';

--PRINT CONCAT(@sumaEntidades_RI, RIGHT(CONCAT(REPLICATE(''0'',3), @sumaSucursales_RI ),4))
--PRINT @sumaTotalCtrl_FL
	--#validacion5
	IF(CONCAT(@sumaEntidades_RI, RIGHT(CONCAT(REPLICATE(''0'',3), @sumaSucursales_RI ),4)) <> @sumaTotalCtrl_FL)
		RAISERROR(''No concuerda la suma Ent/Suc con control FL'', 16, 1);

	--#validacion7
	IF(@sumaTotalCtrl_FL <> @totControl_FA)
		RAISERROR(''No concuerda la suma de TotalesControl de FL con control FA'', 16, 1);

	--#validacion6 debitos
	IF(@sumaDebitos_RI  <> @controlDebitos_FL AND @sumaDebitos_RI <> @totalDebitos_FA)
		RAISERROR(''No concuerda la suma de Debitos individuales con el Total Debitos'', 16, 1);

	--#validacion6 creditos
	IF( @sumaCreditos_RI <> @controlCreditos_FL AND @sumaCreditos_RI <> @totalCreditos_FA)
		RAISERROR(''No concuerda la suma de Creditos individuales con el Total Creditos '', 16, 1);

	--#validacion8
	IF((@controlDebitos_FL + @controlCreditos_FL) <>  (@totalDebitos_FA + @totalCreditos_FA))
		RAISERROR(''No concuerda la suma de Debitos de FL con Total Importe FA'', 16, 1);


	--fin----validaciones #5 #6 #7 y #8

	DECLARE @LINEA VARCHAR(95);
	DECLARE che_cursor CURSOR FOR 
	SELECT LINEA
	FROM dbo.ITF_OTROS_CHEQUES_RESPUESTA_AUX

	OPEN che_cursor

	FETCH NEXT FROM che_cursor INTO @LINEA

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
			SET @CodPrioridad = substring(@LINEA, 2, 2);
			SET @DestinoInmediato = substring(@LINEA, 4, 10);
			SET @OrigenInmediato = substring(@LINEA, 14, 10);
			SET @FechaPresentacion = substring(@LINEA, 24, 6);
			SET @HoraPresentacion = substring(@LINEA, 30, 4);
			SET @IdArchivo = substring(@LINEA, 34, 1);
			SET @TamanioRegistro = substring(@LINEA, 35, 3);
			SET @FactorBloque = substring(@LINEA, 38, 2);
			SET @CodFormato = substring(@LINEA, 40, 1);
			SET @NomDestinoInmediato = substring(@LINEA, 41, 23);
			SET @NomOrigenInmediato = substring(@LINEA, 64, 23);
			SET @CodReferencia = substring(@LINEA, 87, 8);


			IF (@IdArchivo NOT IN (''A'',''B'',''C'',''D'',''E'',''F'',''G'',''H'',''I'',''J'',''K'',''L'',''M'',''N'',''O'',''P'',''Q'',''R'',''S'',''T'',''U'',''V'',''W'',''X'',''Y'',''Z'',''0'',''1'',''2'',''3'',''4'',''5'',''6'',''7'',''8'',''9'')) 	
				RAISERROR (''Identificador Archivo invalido'', 16, 1);

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

			SET @FechaPresentacion = CAST(substring(@LINEA, 64, 6) AS DATE);
			--VALIDACION FECHAS
			SET @FechaVencimiento = CAST(substring(@LINEA, 70, 6) AS DATE);
			SET @ReservadoLoteCeros = substring(@LINEA, 76, 3);
			--VALIDACION RESERVADO 000
			SET @CodigoOrigen = substring(@LINEA, 79, 1);

			SET @IdEntidadOrigen = substring(@LINEA, 80, 4);

			SET @NumeroLote = substring(@LINEA, 88, 7);

			IF (@ClaseTransaccion <> 200)     
    			RAISERROR (''Codigo de clase de transaccion debe ser 200'', 16, 1);

			IF (@CodigoOrigen <> 1)     	
    			RAISERROR (''Codigo origen debe ser 1'', 16, 1);


			IF (@CodigoRegistro <> ''TRC'')       
    			RAISERROR (''Codigo de registro debe ser TRC'', 16, 1);

			IF (@FechaPresentacion > @FechaVencimiento)      	
    			RAISERROR (''Fecha Presentacion debe ser anterior a vencimiento'', 16, 1);
		END

		/*FIN DE LOTE*/
		IF (@IdRegistro = ''8'') 
      	BEGIN
			SET @ClaseTransaccion = substring(@LINEA, 2, 3);
			--SET @RegIndivAdic = substring(@LINEA, 5, 6);
		--	SET @TotalesControl = substring(@LINEA, 11,10);
			SET @ReservadoFL = substring(@LINEA, 45, 35);
			SET @IdEntidadOrigen = substring(@LINEA, 80, 4);
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
			IF((SELECT COUNT(*)
			FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX
			WHERE LINEA LIKE ''5%'') <> @CantLotesFA)
			RAISERROR(''No coincide la cantidad de LOTES con la informada en el reg FA'', 16, 1);
			--#validacion10
			IF((SELECT count(*)
			FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX
			WHERE LINEA LIKE ''6%'' OR LINEA LIKE ''7%'') <> @CantRegAdFA)
			RAISERROR(''No coincide la cantidad de registros ind y ad con la informada en el reg FA'', 16, 1);

		END


		/*Registro ind adicional*/
		IF(@IdRegistro = ''7'')
		BEGIN
			
			SET @CodRechazo = substring(@LINEA, 5, 2);
--			PRINT @CodRechazo
	
			IF(ISNUMERIC(@Entidad_RI) = 1 AND ISNUMERIC(@Sucursal_RI) = 1 AND ISNUMERIC(@CodigoPostal_RI) = 1 AND ISNUMERIC(@NumeroCheque_RI) = 1 AND ISNUMERIC(@NumeroCuenta_RI ) = 1 )
			BEGIN			
			--actualizo el codigo de rechazo
				UPDATE ITF_COELSA_SESION_RECHAZADOS SET CODIGO_RECHAZO = @CodRechazo WHERE ID_TICKET = @TICKET AND BANCO = @Entidad_RI AND  SUCURSAL = @Sucursal_RI AND CUENTA = @NumeroCuenta_RI AND CODIGO_POSTAL = @CodigoPostal_RI AND NRO_CHEQUE = @NumeroCheque_RI;

				IF(@updRecepcion = ''D'')
					UPDATE CLE_RECEPCION_DPF_DEV SET CODIGO_RECHAZO = @CodRechazo WHERE NUMERO_DPF = @NumeroCheque_RI AND BANCO_GIRADO = @Entidad_RI AND SUCURSAL_BANCO_GIRADO = @Sucursal_RI;
			
				ELSE IF(@updRecepcion = ''C'' AND ISNUMERIC(@CodRechazo) = 1)
					UPDATE CLE_RECEPCION_CHEQUES_DEV SET CODIGO_RECHAZO = @CodRechazo WHERE NUMERO_CHEQUE = @NumeroCheque_RI AND BANCO_GIRADO = @Entidad_RI AND SUCURSAL_BANCO_GIRADO = @Sucursal_RI;
			END
			UPDATE RRII_CHE_RECHAZADOS
			SET CAUSAL=(
						SELECT TOP 1 CODIGO_DE_CAUSAL
						FROM CLE_TIPO_CAUSAL
						WHERE CODIGO_NACHA=@CodRechazo
						),
				CODIGO_MOTIVO=@CodRechazo
			WHERE cod_entidad = 311
    		AND Nro_sucursal = TRIM(''0'' FROM RIGHT(@EntidadDebitar, 3))
    		AND cuenta = @NumeroCuenta_RI
    		AND nro_cheque = @NumeroCheque_RI
    		AND fecha_registro_novedad = (SELECT fechaproceso FROM PARAMETROS);
		END

		/* Registro Individual*/
		IF (@IdRegistro = ''6'' ) 
      	BEGIN
			SET @ExisteRI = 1;

			SET @CodTransaccion = substring(@LINEA, 2, 2);
			SET @EntidadDebitar = substring(@LINEA, 4, 8);
			SET @ReservadoRI = substring(@LINEA, 12, 1);
			SET @CuentaDebitar = substring(@LINEA, 13, 17);
			SET @Importe = substring(@LINEA, 30, 10);
			SET @NumeroCheque = substring(@LINEA, 40, 15);
			SET @CodigoPostal = substring(@LINEA, 55, 6);
			SET @PuntoIntercambio = substring(@LINEA, 61, 16);
			SET @InfoAdicional = substring(@LINEA, 77, 2);
			SET @RegistrosAdicionales = substring(@LINEA, 79, 1);
			SET @ContadorRegistros = substring(@LINEA, 80, 15);
			/* Trace Number */

			SET @Entidad_RI = substring(@ContadorRegistros, 1, 4);
			SET @Sucursal_RI = substring(@ContadorRegistros, 5, 4);
			SET @CodigoPostal_RI = RIGHT(@CodigoPostal, 4);
			SET @NumeroCuenta_RI = RIGHT(@CuentaDebitar, 12);
			SET @NumeroCheque_RI = RIGHT(@NumeroCheque, 12);


			IF (@RegistrosAdicionales NOT IN(''1'',''0'')) 
    			RAISERROR (''Campo Registro adicional invalido'', 16, 1);



			--- Variables Generales ---
			DECLARE @NRO_DPF_CHEQUE NUMERIC(12);
			DECLARE @BANCO_GIRADO NUMERIC(4);
			DECLARE @SUCURSAL_BANCO NUMERIC(5);
			DECLARE @TIPO_DOCUMENTO VARCHAR(4);
			DECLARE @IMPORTE_TOTAL NUMERIC(10,2);
			DECLARE @MONEDA NUMERIC(1);
			DECLARE @SERIE_DEL_CHEQUE VARCHAR(6);
			DECLARE @NRO_CUENTA NUMERIC(12);
			DECLARE @CODIGO_POSTAL NUMERIC(4);
			DECLARE @EXISTE NUMERIC(4) = 0;

			IF(@TICKET<>0)
      		BEGIN
				--lo seteo en ''-'' y desp veo su hay que updatear CLE_RECEPCION_CHEQUES_DEV (''C'') o CLE_RECEPCION_DPF_DEV (''D'')
				SET @updRecepcion = ''-'';

				IF (ISNUMERIC(@CuentaDebitar) = 1 AND CAST(@CuentaDebitar AS NUMERIC) = 88888888888)
				BEGIN
					IF(ISNUMERIC(@Entidad_RI) = 1 AND ISNUMERIC(@Sucursal_RI) = 1 AND ISNUMERIC(@CodigoPostal_RI) = 1 AND ISNUMERIC(@NumeroCheque_RI) = 1 AND ISNUMERIC(@NumeroCuenta_RI ) = 1 )
					BEGIN
						-- La idea es actualizar los rechazados del plano con ESTADO_AJUSTE = ''R'' y el resto de cheques del historial con ESTADO_AJUSTE  = ''A''	
						UPDATE dbo.CLE_CHEQUES_AJUSTE 
						SET ESTADO_AJUSTE = ''R'' 
						WHERE TZ_LOCK = 0 
						AND @Entidad_RI = BANCO 
						AND @Sucursal_RI  = SUCURSAL_BANCO_GIRADO 
						AND @CodigoPostal_RI = CODIGO_POSTAL 
						AND @NumeroCheque_RI = NUMERO_CHEQUE 
						AND @NumeroCuenta_RI = NUMERO_CUENTA;

						-- Consulta Ajuste
						SELECT @EXISTE = 1, @ORDINAL = ORDINAL, @BANCO_GIRADO = BANCO, @NRO_DPF_CHEQUE = NUMERO_CHEQUE, @SUCURSAL_BANCO = SUCURSAL_BANCO_GIRADO, @NRO_CUENTA = NUMERO_CUENTA, @CODIGO_POSTAL = CODIGO_POSTAL, @IMPORTE_TOTAL = IMPORTE, @MONEDA = MONEDA
						FROM CLE_CHEQUES_AJUSTE WITH(NOLOCK)
						WHERE TZ_LOCK = 0 
						AND @Entidad_RI = BANCO 
						AND @Sucursal_RI  = SUCURSAL_BANCO_GIRADO 
						AND @CodigoPostal_RI = CODIGO_POSTAL 
						AND @NumeroCheque_RI = NUMERO_CHEQUE 
						AND @NumeroCuenta_RI = NUMERO_CUENTA;
					END

					IF @EXISTE > 0
					BEGIN
						
						-- Guardamos clave para update si hay reg adicional
						SET @Entidad_RI = @BANCO_GIRADO;
						SET @Sucursal_RI = @SUCURSAL_BANCO;
						SET @NumeroCuenta_RI = @NRO_CUENTA;
						SET @CodigoPostal_RI = @CODIGO_POSTAL;
						SET @NumeroCheque_RI = @NRO_DPF_CHEQUE;

						-- Insertamos en el historial
						INSERT INTO ITF_COELSA_SESION_RECHAZADOS (ID_TICKET, 
																	FECHA_ALTA, 
																	BANCO, 
																	SUCURSAL, 
																	CUENTA, 
																	IMPORTE, 
																	CODIGO_POSTAL, 
																	NRO_CHEQUE, 
																	PUNTO_INTERCAMBIO, 
																	TRACK_NUMBER, 
																	TIPO, 
																	MONEDA, 
																	TIPO_DOCUMENTO, 
																	CODIGO_RECHAZO, 
																	ORDINAL)
															VALUES(@TICKET, 
																	@FechaPresentacion, 
																	@BANCO_GIRADO, 
																	@SUCURSAL_BANCO, 
																	@NRO_CUENTA, 
																	@IMPORTE_TOTAL, 
																	@CODIGO_POSTAL, 
																	@NRO_DPF_CHEQUE, 
																	@PuntoIntercambio, 
																	@ContadorRegistros, 
																	''C'',  
																	@MONEDA, 
																	@TIPO_DOCUMENTO, 
																	@CodRechazo, 
																	@ORDINAL);
					
					PRINT concat(''Moneda-existe-ticket<>0: '',@moneda)
					END
					ELSE
					BEGIN
						-- Insertamos en el historial en caso de que no exista
						SET @moneda=1

						INSERT INTO ITF_COELSA_SESION_RECHAZADOS (ID_TICKET, 
																	FECHA_ALTA, 
																	BANCO, 
																	SUCURSAL, 
																	CUENTA, 
																	IMPORTE, 
																	CODIGO_POSTAL, 
																	NRO_CHEQUE, 
																	PUNTO_INTERCAMBIO, 
																	TRACK_NUMBER, 
																	TIPO, 
																	MONEDA, 
																	TIPO_DOCUMENTO)
						VALUES(@TICKET, 
							@FechaPresentacion, 
							CASE WHEN ISNUMERIC(@Entidad_RI) = 0 THEN -1 ELSE CAST(@Entidad_RI AS NUMERIC(4)) END ,
							CASE WHEN ISNUMERIC(@Sucursal_RI) = 0 THEN -1 ELSE CAST(@Sucursal_RI AS NUMERIC(5)) END, 
							CASE WHEN ISNUMERIC(@NumeroCuenta_RI) = 0 THEN -1 ELSE CAST(@NumeroCuenta_RI AS NUMERIC(12)) END, 
							@Importe, 
							CASE WHEN ISNUMERIC(@CodigoPostal_RI) = 0 THEN -1 ELSE CAST(@CodigoPostal_RI AS NUMERIC(4)) END, 
							CASE WHEN ISNUMERIC(@NumeroCheque_RI) = 0 THEN -1 ELSE CAST(@NumeroCheque_RI AS NUMERIC(12)) END ,
							@PuntoIntercambio, 
							@ContadorRegistros, 
							''C'',
							@moneda, 
							@TIPO_DOCUMENTO);

					END
				END			
				ELSE IF (ISNUMERIC(@CuentaDebitar) = 1 AND CAST(@CuentaDebitar AS NUMERIC) = 77777777777)
				BEGIN
					IF(ISNUMERIC(@Entidad_RI) = 1 AND ISNUMERIC(@Sucursal_RI) = 1 AND ISNUMERIC(@CodigoPostal_RI) = 1 AND ISNUMERIC(@NumeroCheque_RI) = 1 AND ISNUMERIC(@NumeroCuenta_RI ) = 1 )
					BEGIN
					 	-- Consulta DPF  			
					 	SELECT @EXISTE = 1, @TIPO_DOCUMENTO = TIPO_DOCUMENTO, @NRO_DPF_CHEQUE = NUMERO_DPF, @BANCO_GIRADO = BANCO_GIRADO, @SUCURSAL_BANCO = SUCURSAL_BANCO_GIRADO, @IMPORTE_TOTAL = IMPORTE, @CODIGO_POSTAL = COD_POSTAL, @MONEDA = MONEDA, @NRO_CUENTA = NUMERICO_CUENTA_GIRADORA
					 	FROM CLE_DPF_SALIENTE WITH(NOLOCK)
					 	WHERE TZ_LOCK = 0 
					 	AND @Entidad_RI = BANCO_GIRADO 
					 	AND @Sucursal_RI  = SUCURSAL_BANCO_GIRADO 
					 	AND @CodigoPostal_RI = COD_POSTAL 
					 	AND @NumeroCheque_RI = NUMERO_DPF 
					 	AND @NumeroCuenta_RI = NUMERICO_CUENTA_GIRADORA;
					END

					IF @EXISTE > 0
				    BEGIN
					 	-- Guardamos clave para update si hay reg adicional
					 	SET @Entidad_RI = @BANCO_GIRADO;
					 	SET @Sucursal_RI = @SUCURSAL_BANCO;
					 	SET @NumeroCuenta_RI = @NRO_CUENTA;
					 	SET @CodigoPostal_RI = @CODIGO_POSTAL;
					 	SET @NumeroCheque_RI = @NRO_DPF_CHEQUE;
							
					 	SET @updRecepcion = ''D''; --para saber si hay que updatear  CLE_RECEPCION_DPF_DEV

					 	INSERT INTO CLE_RECEPCION_DPF_DEV(NUMERO_DPF
					 										, BANCO_GIRADO
					 										, FECHA_ALTA
					 										, SUCURSAL_BANCO_GIRADO
					 										, TIPO_DOCUMENTO
					 										, IMPORTE_DPF
					 										, [CODIGO_CAMARA]
					 										, ESTADO_DEVOLUCION)
					 	VALUES (@NRO_DPF_CHEQUE
					 			, @BANCO_GIRADO
					 			, @FechaPresentacion
					 			, @SUCURSAL_BANCO
					 			, @TIPO_DOCUMENTO
					 			, @IMPORTE_TOTAL, 
					 			(SELECT [CODIGO_DE_CAMARA] FROM CLE_CAMARAS_COMPENSADORAS WITH (NOLOCK))
					 			, 1);

				   		-- Insertamos en el historial
				   		INSERT INTO ITF_COELSA_SESION_RECHAZADOS(ID_TICKET
				   												, FECHA_ALTA
				   												, BANCO
				   												, SUCURSAL
				   												, CUENTA
				   												, IMPORTE
				   												, CODIGO_POSTAL
				   												, NRO_CHEQUE
				   												, PUNTO_INTERCAMBIO
				   												, TRACK_NUMBER
				   												, TIPO
				   												, MONEDA
				   												, TIPO_DOCUMENTO
				   												, ORDINAL)
						VALUES(@TICKET
								, @FechaPresentacion
								, @BANCO_GIRADO
								, @SUCURSAL_BANCO
								, @NRO_CUENTA
								, @IMPORTE_TOTAL
								, @CODIGO_POSTAL
								, @NRO_DPF_CHEQUE
								, @PuntoIntercambio
								, @ContadorRegistros
								, ''C'',  @MONEDA
								, @TIPO_DOCUMENTO
								, @ORDINAL);

					END
					ELSE
					BEGIN
						SET @moneda=1
						-- Insertamos en el historial en caso de que no exista
						INSERT INTO ITF_COELSA_SESION_RECHAZADOS(ID_TICKET
																, FECHA_ALTA
																, BANCO
																, SUCURSAL
																, CUENTA
																, IMPORTE
																, CODIGO_POSTAL
																, NRO_CHEQUE
																, PUNTO_INTERCAMBIO
																, TRACK_NUMBER
																, TIPO
																, MONEDA
																, TIPO_DOCUMENTO)
						VALUES(@TICKET
								, @FechaPresentacion
								, CASE WHEN ISNUMERIC(@Entidad_RI) = 0 THEN -1 ELSE CAST(@Entidad_RI AS NUMERIC(4)) END 
								, CASE WHEN ISNUMERIC(@Sucursal_RI) = 0 THEN -1 ELSE CAST(@Sucursal_RI AS NUMERIC(5)) END
								, CASE WHEN ISNUMERIC(@NumeroCuenta_RI) = 0 THEN -1 ELSE CAST(@NumeroCuenta_RI AS NUMERIC(12)) END
								, @Importe
								, CASE WHEN ISNUMERIC(@CodigoPostal_RI) = 0 THEN -1 ELSE CAST(@CodigoPostal_RI AS NUMERIC(4)) END
								, CASE WHEN ISNUMERIC(@NumeroCheque_RI) = 0 THEN -1 ELSE CAST(@NumeroCheque_RI AS NUMERIC(12)) END 
								, @PuntoIntercambio
								, @ContadorRegistros
								, ''C''
								, @moneda
								, @TIPO_DOCUMENTO);			
					END
				END      	
				ELSE
				BEGIN

					IF(ISNUMERIC(@Entidad_RI) = 1 AND ISNUMERIC(@Sucursal_RI) = 1 AND ISNUMERIC(@CodigoPostal_RI) = 1 AND ISNUMERIC(@NumeroCheque_RI) = 1 AND ISNUMERIC(@NumeroCuenta_RI ) = 1 )
					BEGIN
						-- Consulta Cheque
						SELECT @EXISTE = 1
								, @NRO_DPF_CHEQUE = NRO_CHEQUE
								, @SERIE_DEL_CHEQUE = SERIE_DEL_CHEQUE
								, @BANCO_GIRADO = BANCO
								, @SUCURSAL_BANCO = SUCURSAL
								, @NRO_CUENTA = CUENTA
								, @TIPO_DOCUMENTO = TIPO_DOCUMENTO
								, @IMPORTE_TOTAL = IMPORTE
								, @CODIGO_POSTAL = CODIGO_POSTAL
								, @MONEDA = MONEDA
						FROM ITF_COELSA_CHEQUES_OTROS WITH(NOLOCK)
						WHERE @Entidad_RI = BANCO 
						AND @Sucursal_RI  = SUCURSAL 
						AND @CodigoPostal_RI = CODIGO_POSTAL 
						AND @NumeroCheque_RI = NRO_CHEQUE 
						AND @NumeroCuenta_RI = CUENTA;
					END

					IF @EXISTE > 0
					BEGIN
						-- Guardamos clave para update si hay reg adicional
						SET @Entidad_RI = @BANCO_GIRADO;
						SET @Sucursal_RI = @SUCURSAL_BANCO;
						SET @NumeroCuenta_RI = @NRO_CUENTA;
						SET @CodigoPostal_RI = @CODIGO_POSTAL;
						SET @NumeroCheque_RI = @NRO_DPF_CHEQUE;
						
						SET @updRecepcion = ''C''; --para saber si updatear el cod Rechazo de la tabla CLE_RECEPCION_CHEQUES_DEV

						INSERT INTO CLE_RECEPCION_CHEQUES_DEV(NUMERO_CHEQUE
															, SERIE_DEL_CHEQUE
															, BANCO_GIRADO
															, FECHA_ALTA
															, SUCURSAL_BANCO_GIRADO
															, NUMERO_CUENTA_GIRADORA
															, TIPO_DOCUMENTO
															, IMPORTE_CHEQUE
															, ESTADO_DEVOLUCION
															, CODIGO_CAMARA)
						VALUES (@NRO_DPF_CHEQUE
								, @SERIE_DEL_CHEQUE
								, @BANCO_GIRADO
								, @FechaPresentacion
								, @SUCURSAL_BANCO
								, @NRO_CUENTA
								, @TIPO_DOCUMENTO
								, @IMPORTE_TOTAL
								, 1
								, (SELECT [CODIGO_DE_CAMARA] FROM CLE_CAMARAS_COMPENSADORAS WITH(NOLOCK)));

						-- Insertamos en el historial
						INSERT INTO ITF_COELSA_SESION_RECHAZADOS(ID_TICKET
																, FECHA_ALTA
																, BANCO
																, SUCURSAL
																, CUENTA
																, IMPORTE
																, CODIGO_POSTAL
																, NRO_CHEQUE
																, PUNTO_INTERCAMBIO
																, TRACK_NUMBER
																, TIPO
																, MONEDA
																, TIPO_DOCUMENTO
																, SERIE_DEL_CHEQUE)
						VALUES(@TICKET
							, @FechaPresentacion
							, @BANCO_GIRADO
							, @SUCURSAL_BANCO
							, @NRO_CUENTA
							, @IMPORTE_TOTAL
							, @CODIGO_POSTAL
							, @NRO_DPF_CHEQUE
							, @PuntoIntercambio
							, @ContadorRegistros
							, ''C''
							, @MONEDA
							, @TIPO_DOCUMENTO
							, @SERIE_DEL_CHEQUE);
					
					
					
					END
					ELSE
					BEGIN
					  
						SET @moneda=1
							-- Insertamos en el historial en caso de que no exista
						INSERT INTO ITF_COELSA_SESION_RECHAZADOS(ID_TICKET
																, FECHA_ALTA
																, BANCO
																, SUCURSAL
																, CUENTA
																, IMPORTE
																, CODIGO_POSTAL
																, NRO_CHEQUE
																, PUNTO_INTERCAMBIO
																, TRACK_NUMBER
																, TIPO
																, MONEDA
																, TIPO_DOCUMENTO)
						VALUES(@TICKET, 
							@FechaPresentacion, 
							CASE WHEN ISNUMERIC(@Entidad_RI) = 0 THEN -1 ELSE CAST(@Entidad_RI AS NUMERIC(4)) END ,
							CASE WHEN ISNUMERIC(@Sucursal_RI) = 0 THEN -1 ELSE CAST(@Sucursal_RI AS NUMERIC(5)) END, 
							CASE WHEN ISNUMERIC(@NumeroCuenta_RI) = 0 THEN -1 ELSE CAST(@NumeroCuenta_RI AS NUMERIC(12)) END, 
							@Importe, 
							CASE WHEN ISNUMERIC(@CodigoPostal_RI) = 0 THEN -1 ELSE CAST(@CodigoPostal_RI AS NUMERIC(4)) END, 
							CASE WHEN ISNUMERIC(@NumeroCheque_RI) = 0 THEN -1 ELSE CAST(@NumeroCheque_RI AS NUMERIC(12)) END ,
							@PuntoIntercambio, 
							@ContadorRegistros, 
							''C'',
							@moneda, 
							@TIPO_DOCUMENTO);
							

					END

				END

		--***Bloque nuevo 13/05/2024 JI***--
				IF (try_convert(numeric,@codRechazo) IS null)
				BEGIN
					PRINT @linea
					PRINT @codRechazo
					SELECT convert(NUMERIC(15,2),substring(@linea,30,10))/100,substring(@linea,13,12),substring(@linea,40,2)
				END 
		--IF (@linea LIKE ''622%'')
		--BEGIN
		
				SELECT @CODCLI=c1803
						, @PRODUCTO=PRODUCTO
						, @ordinal=ordinal 
				FROM SALDOS 
				WHERE CUENTA = @NumeroCuenta_RI 
				AND SUCURSAL = TRIM(''0'' FROM RIGHT(@EntidadDebitar, 3)) 
				AND MONEDA = @MONEDA 
				AND C1785 = 2
		
		
		
--PRINT @linea
				IF TRY_CONVERT(INT,SUBSTRING(@LINEA,65,2))=0
				BEGIN
					SET @codRechazo=substring(@linea,67,2)
				END
				ELSE 
		   		BEGIN
					SET @codRechazo=substring(@linea,65,2)
				END
			
				SET @Entidad = CAST(LEFT( CAST(RIGHT(''0000'' + Ltrim(Rtrim(@EntidadDebitar)),8) AS VARCHAR ), 4) AS NUMERIC);
						---inserto en CLE_CHEQUES_CLEARING_RECH_DEV---
		   		BEGIN TRY
				INSERT INTO dbo.CLE_CHEQUES_CLEARING_RECH_DEPOSITARIA
							(
							CLIENTE
							, MONEDA
							, ORDINAL_LISTA
							, PRODUCTO
							, NUMERO_BANCO
							, NUMERO_DEPENDENCIA
							, NUMERO_CHEQUE
							, IMPORTE
							, SERIE_CHEQUE
							, FECHA_VALOR
							, ESTADO
							, CUENTA
							, CAMARA_COMPENSADORA
							, CMC7
							, TRACKNUMBER
							, TZ_LOCK
							, CODIGO_CAUSAL_DEVOLUCION
							)
				VALUES
							(
							@CODCLI
							, @MONEDA
							, @ORDINAL
							, @PRODUCTO
							, @Entidad_RI 
							, @Sucursal_RI
							, @NumeroCheque
							, convert(NUMERIC(15,2),substring(@linea,30,10))/100
							, ''''
							, @FechaPresentacion
							, ''0'' 
							, substring(@linea,13,12)
							, 1
							, (SELECT CONCAT( @Entidad, RIGHT(@EntidadDebitar, 3),RIGHT(@CodigoPostal,4),RIGHT(CONCAT(REPLICATE(''0'',8),RIGHT(@NumeroCheque, 8)),8), RIGHT(CONCAT(''00000000000'',RIGHT(@CuentaDebitar,11)),11) ))         										
							, @ContadorRegistros
							, 0
							, @codRechazo
							)
				END TRY 
			
				BEGIN CATCH
				END CATCH
							---***---
			
--PRINT @NumeroCheque 
   				IF ( SELECT count(*) 
					FROM CLE_RECEPCION_CHEQUES_DEV 
					WHERE NUMERO_CHEQUE= @NumeroCheque
			   		--AND SERIE_DEL_CHEQUE= @SERIE_DEL_CHEQUE
					AND BANCO_GIRADO= @Entidad_RI 
					AND FECHA_ALTA= @FechaPresentacion
					AND SUCURSAL_BANCO_GIRADO=@Sucursal_RI
					AND NUMERO_CUENTA_GIRADORA= substring(@linea,13,12)
					AND TIPO_DOCUMENTO=substring(@linea,40,2))>0
				BEGIN
--PRINT ''existe'' 
   					IF	(@codRechazo NOT IN (SELECT RIGHT(codigo_nacha,2) FROM CLE_PREVALENCIA_CAUSAL))
					BEGIN 
						UPDATE CLE_RECEPCION_CHEQUES_DEV
						SET CODIGO_RECHAZO=try_convert(NUMERIC(3),@codRechazo)
						WHERE NUMERO_CHEQUE= @NumeroCheque
						AND SERIE_DEL_CHEQUE= @SERIE_DEL_CHEQUE
						AND BANCO_GIRADO= @Entidad_RI 
						AND FECHA_ALTA= @FechaPresentacion
						AND SUCURSAL_BANCO_GIRADO=@Sucursal_RI
						AND NUMERO_CUENTA_GIRADORA= substring(@linea,13,12)
						AND TIPO_DOCUMENTO=substring(@linea,40,2) 		
					END
				END 
				ELSE
				BEGIN
			
--			PRINT @NRO_CUENTA
--PRINT @Entidad_RI
					INSERT INTO dbo.CLE_RECEPCION_CHEQUES_DEV
						(
						BANCO_GIRADO --num 4
						, SUCURSAL_BANCO_GIRADO --num 5
						, SERIE_DEL_CHEQUE --var 6
						, IMPORTE_CHEQUE  --num 15,2
						, CODIGO_RECHAZO --num 3
						, NUMERO_CHEQUE --num 12
						, ESTADO_DEVOLUCION --num 1
						, CODIGO_CAMARA  --num  4
						, TIPO_DOCUMENTO --var
 						, FECHA_ALTA  --date
						, NUMERO_CUENTA_GIRADORA  --num
						, TZ_LOCK
						)
					VALUES
						(
						@Entidad_RI
						, @Sucursal_RI
						, ''''
						, convert(NUMERIC(15,2),substring(@linea,30,10))/100
 						, try_convert(numeric,@codRechazo)
 						, @NumeroCheque
				  		, 0
						, (SELECT TOP 1 CODIGO_DE_CAMARA FROM CLE_CAMARAS_COMPENSADORAS WITH(NOLOCK))
						, substring(@linea,40,2)
 						, @FechaPresentacion
						, substring(@linea,13,12)
						, 0
						)
				END 
		--END 


			--***FIN***--
		
		
		
		
		
		
		
    -- Insertar en la tabla RRII_CHE_RECHAZADOS
    


				BEGIN TRY
					INSERT INTO dbo.RRII_CHE_RECHAZADOS (COD_ENTIDAD, 
									 NRO_SUCURSAL, 
									 CUENTA, 
									 NRO_CHEQUE, 
									 AVISO, 
									 COD_MOVIMIENTO, 
									 CLASE_REGISTRO, 
									 FECHA_NOTIF_O_DENUNCIA, 
									 MONEDA, 
									 IMPORTE, 
									 FECHA_RECHAZO_O_PRES_COBRO, 
									 FECHA_REGISTRACION, 
									 PLAZO_DIFERIMIENTO, 
									 FECHA_PAGO_CHEQUE, 
									 FECHA_PAGO_MULTA, 
									 FECHA_CIERRE_CTA, 
									 FECHA_REGISTRO_NOVEDAD, 
									 TZ_LOCK)
					SELECT 311, 
						TRIM(''0'' FROM RIGHT(@EntidadDebitar, 3)), 
	   					@NumeroCuenta_RI, 
	   					@NumeroCheque_RI,
	   					CONCAT(@Entidad_RI, @Sucursal_RI), 
						''A'', 
						1, 
						@FechaPresentacion, 
						@MONEDA,  
						@IMPORTE, 
						@FechaPresentacion, 
						(SELECT fechaproceso	FROM PARAMETROS), 
						NULL, 
						NULL, 
						NULL, 
						NULL,  
						(SELECT fechaproceso FROM PARAMETROS), 
						0;
		


		--agregamos los numeros de documento de los titulares y cotitulares		



				-- Crear una tabla temporal para almacenar los valores a actualizar
					CREATE TABLE #TempUpdate (
    							PRIMER_NRO_IDENTIFICATORIO NUMERIC(11, 0),
    							SEGUNDO_NRO_IDENTIFICATORIO NUMERIC(11, 0),
    							TERCER_NRO_IDENTIFICATORIO NUMERIC(11, 0),
    							CUARTO_NRO_IDENTIFICATORIO NUMERIC(11, 0),
    							QUINTO_NRO_IDENTIFICATORIO NUMERIC(11, 0),
    							SEXTO_NRO_IDENTIFICATORIO NUMERIC(11, 0),
    							SEPTIMO_NRO_IDENTIFICATORIO NUMERIC(11, 0),
    							OCTAVO_NRO_IDENTIFICATORIO NUMERIC(11, 0),
    							NOVENO_NRO_IDENTIFICATORIO NUMERIC(11, 0),
    							DECIMO_NRO_IDENTIFICATORIO NUMERIC(11, 0)
								);

					-- Insertar los valores condicionalmente en la tabla temporal
					INSERT INTO #TempUpdate (PRIMER_NRO_IDENTIFICATORIO, SEGUNDO_NRO_IDENTIFICATORIO, TERCER_NRO_IDENTIFICATORIO, CUARTO_NRO_IDENTIFICATORIO, QUINTO_NRO_IDENTIFICATORIO, SEXTO_NRO_IDENTIFICATORIO, SEPTIMO_NRO_IDENTIFICATORIO, OCTAVO_NRO_IDENTIFICATORIO, NOVENO_NRO_IDENTIFICATORIO, DECIMO_NRO_IDENTIFICATORIO)
					SELECT
    					MAX(CASE WHEN RN = 1 THEN CAST(RTRIM([NUMERO DE DOCUMENTO]) AS NUMERIC(11, 0)) END),
    					MAX(CASE WHEN RN = 2 THEN CAST(RTRIM([NUMERO DE DOCUMENTO]) AS NUMERIC(11, 0)) END),
    					MAX(CASE WHEN RN = 3 THEN CAST(RTRIM([NUMERO DE DOCUMENTO]) AS NUMERIC(11, 0)) END),
    					MAX(CASE WHEN RN = 4 THEN CAST(RTRIM([NUMERO DE DOCUMENTO]) AS NUMERIC(11, 0)) END),
    					MAX(CASE WHEN RN = 5 THEN CAST(RTRIM([NUMERO DE DOCUMENTO]) AS NUMERIC(11, 0)) END),
    					MAX(CASE WHEN RN = 6 THEN CAST(RTRIM([NUMERO DE DOCUMENTO]) AS NUMERIC(11, 0)) END),
    					MAX(CASE WHEN RN = 7 THEN CAST(RTRIM([NUMERO DE DOCUMENTO]) AS NUMERIC(11, 0)) END),
    					MAX(CASE WHEN RN = 8 THEN CAST(RTRIM([NUMERO DE DOCUMENTO]) AS NUMERIC(11, 0)) END),
    					MAX(CASE WHEN RN = 9 THEN CAST(RTRIM([NUMERO DE DOCUMENTO]) AS NUMERIC(11, 0)) END),
    					MAX(CASE WHEN RN = 10 THEN CAST(RTRIM([NUMERO DE DOCUMENTO]) AS NUMERIC(11, 0)) END)
					FROM (
    					SELECT
        						[Codigo de Cliente],
        						[Numero de Documento],
        						[Titularidad],
        						ROW_NUMBER() OVER (PARTITION BY [Codigo de Cliente] ORDER BY CASE WHEN [Titularidad] = ''T'' THEN 0 ELSE 1 END, [Numero de Documento]) AS RN
    					FROM VW_CLI_PERSONAS
    					WHERE [Codigo de Cliente] = (
													SELECT c1803 
													FROM SALDOS 
													WHERE CUENTA = @NumeroCuenta_RI 
													AND SUCURSAL = TRIM(''0'' FROM RIGHT(@EntidadDebitar, 3)) 
													AND MONEDA = @MONEDA 
													AND C1785 = 2
    												) 
							) Subquery;

					-- Realizar la actualización utilizando la tabla temporal
					UPDATE RRII_CHE_RECHAZADOS
					SET
    					PRIMER_NRO_IDENTIFICATORIO = #TempUpdate.PRIMER_NRO_IDENTIFICATORIO,
    					SEGUNDO_NRO_IDENTIFICATORIO = #TempUpdate.SEGUNDO_NRO_IDENTIFICATORIO,
    					TERCER_NRO_IDENTIFICATORIO = #TempUpdate.TERCER_NRO_IDENTIFICATORIO,
    					CUARTO_NRO_IDENTIFICATORIO = #TempUpdate.CUARTO_NRO_IDENTIFICATORIO,
    					QUINTO_NRO_IDENTIFICATORIO = #TempUpdate.QUINTO_NRO_IDENTIFICATORIO,
    					SEXTO_NRO_IDENTIFICATORIO = #TempUpdate.SEXTO_NRO_IDENTIFICATORIO,
    					SEPTIMO_NRO_IDENTIFICATORIO = #TempUpdate.SEPTIMO_NRO_IDENTIFICATORIO,
    					OCTAVO_NRO_IDENTIFICATORIO = #TempUpdate.OCTAVO_NRO_IDENTIFICATORIO,
    					NOVENO_NRO_IDENTIFICATORIO = #TempUpdate.NOVENO_NRO_IDENTIFICATORIO,
    					DECIMO_NRO_IDENTIFICATORIO = #TempUpdate.DECIMO_NRO_IDENTIFICATORIO
					FROM #TempUpdate
					WHERE cod_entidad = 311
    				AND Nro_sucursal = TRIM(''0'' FROM RIGHT(@EntidadDebitar, 3))
    				AND cuenta = @NumeroCuenta_RI
    				AND nro_cheque = @NumeroCheque_RI
    				AND fecha_registro_novedad = (SELECT fechaproceso FROM PARAMETROS);

					-- Eliminar la tabla temporal
					DROP TABLE #TempUpdate;


				END	TRY
				BEGIN CATCH
	--PRINT ''No se pudo insertar en tabla RRII_CHE_RECHAZADOS''
				END CATCH	
			END
		END --end RI id = 6
		FETCH NEXT FROM che_cursor INTO @LINEA
	END

	CLOSE che_cursor
	DEALLOCATE che_cursor

	--- Actualizar el estado de los ajustes no incluidos en el plano -------------------------------------------------------------
	UPDATE dbo.CLE_CHEQUES_AJUSTE 
	SET ESTADO_AJUSTE = ''A'' 
	WHERE ESTADO_AJUSTE IS NULL 
	AND ESTADO = ''P'' 
	AND FECHA_ACREDITACION = (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK));
------------------------------------------------------------------------------------------------------------------------------

END');