EXECUTE('CREATE OR ALTER procedure [dbo].[SP_ITF_COELSA_TRANS_MPD_V2]
(
@TICKET NUMERIC(16)
)
AS

BEGIN

	BEGIN TRY  

	------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--- Created : 
	--- Autor: 
	--- Se crea el sp con el fin de generar la información de las transferencias rechazadas a informar a COELSA.
	------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	--- Limpiar Tabla auxiliar ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	TRUNCATE TABLE ITF_COELSA_MPD_TEMP;
	
	------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	DECLARE @T_REFERENCIA VARCHAR(15);
	--declare @TICKET NUMERIC(16) = 12346; --sacar despues de probar
	--- Variables Cabecera Archivo ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	DECLARE @CA_ID_REG VARCHAR(1) = ''1'';
	DECLARE @CA_CODIGO_PRIORIDAD VARCHAR(2) = ''01'';
	DECLARE @CA_DESTINO_INMEDIATO VARCHAR(10) = '' 050000010'';
	DECLARE @CA_ORIGEN_INMEDIATO VARCHAR(10) = '' 081100300'';
	DECLARE @CA_FECHA_PRESENTACION VARCHAR(6) = convert(VARCHAR,(SELECT FECHAPROCESO FROM PARAMETROS WITH (NOLOCK)), 12); 
	DECLARE @CA_HORA_PRESENTACION VARCHAR(4) = concat(SUBSTRING((SELECT CONVERT (VARCHAR(8), SYSDATETIME(),24)),1,2), SUBSTRING((SELECT CONVERT (VARCHAR(8), SYSDATETIME(),24)),4,2));

	DECLARE @CONT NUMERIC(5);
	DECLARE @AZ VARCHAR(1);

	SELECT @CONT =
			(CASE
				WHEN  ((SELECT a.NUMERICO_1 FROM ITF_MASTER_PARAMETROS a WHERE a.CODIGO=424) > 26) or (SELECT a.NUMERICO_1 FROM ITF_MASTER_PARAMETROS a WHERE a.CODIGO= 424 AND a.FECHA = (SELECT FECHAPROCESO FROM PARAMETROS)) IS NULL THEN 1
				ELSE (SELECT a.NUMERICO_1 FROM ITF_MASTER_PARAMETROS a WHERE a.CODIGO=424 AND a.FECHA = (SELECT FECHAPROCESO FROM PARAMETROS))+1
			END
			);

	SELECT @AZ = Char(64 + @CONT);

	DECLARE @CA_IDENTIFICADOR_ARCHIVO VARCHAR(1) = @AZ;
	DECLARE @CA_TAMANNO_REGISTRO VARCHAR(3) = ''094'';
	DECLARE @CA_FACTOR_BLOQUE VARCHAR(2) = ''10'';
	DECLARE @CA_CODIGO_FORMATO VARCHAR(1) = ''1'';
	DECLARE @CA_NOMBRE_DEST_INMEDIATO VARCHAR(23) = concat(''COELSA'',replicate('' '', 17));
	DECLARE @CA_NOMBRE_ORIG_INMEDIATO VARCHAR(23) =  concat(''NUEVO BCO CHACO S.A.'',replicate('' '', 3));
	DECLARE @CA_CODIGO_REFERENCIA VARCHAR(8) = concat(''MIN'', replicate('' '', 4),''0'');
	DECLARE @CA_CABECERA VARCHAR(200);

	SET @CA_CABECERA = concat(@CA_ID_REG, @CA_CODIGO_PRIORIDAD, @CA_DESTINO_INMEDIATO, @CA_ORIGEN_INMEDIATO, @CA_FECHA_PRESENTACION, @CA_HORA_PRESENTACION, @CA_IDENTIFICADOR_ARCHIVO, @CA_TAMANNO_REGISTRO, @CA_FACTOR_BLOQUE, @CA_CODIGO_FORMATO, @CA_NOMBRE_DEST_INMEDIATO, @CA_NOMBRE_ORIG_INMEDIATO, @CA_CODIGO_REFERENCIA);
	------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	--- Variables Cabecera Lote ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	DECLARE @CL_ID_REG VARCHAR(1) = ''5''; 
	DECLARE @CL_CODIGO_CLASE_TRANSAC VARCHAR(3) = ''220'';
	DECLARE @CL_NOMBRE_EMPRESA_INDIVIDUO VARCHAR(16) = LEFT(''PARTICULARES'' + REPLICATE('' '',16),16);
	DECLARE @RA_NOMBRE_EMPRESA_INDIVIDUO VARCHAR(16);
	DECLARE @CL_INFORMACION_DISCRECIONAL VARCHAR(20) = CONCAT(''TRANSFERENCIAS'',REPLICATE('' '',6));
	DECLARE @CL_IDENTIFICACION_EMP_IND VARCHAR(10);-- = ''3067015779'';--Por revisar
	DECLARE @CL_TIPO_REGISTRO VARCHAR(3) = RIGHT(''CTX'', 3);
	DECLARE @CL_RESERVADO VARCHAR(10) = REPLICATE('' '', 10);  
	DECLARE @CL_FECHA_PRESENTACION VARCHAR(6) = convert(VARCHAR,(SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)), 12);
	DECLARE @CL_FECHA_COMPENSACION VARCHAR(6) = convert(VARCHAR,(SELECT FECHAPROximoproceso FROM PARAMETROS WITH(NOLOCK)), 12);
	DECLARE @CL_MONEDA_TRANSACCION VARCHAR(3) = RIGHT(''010'', 3);
	DECLARE @CL_DIGITO_VERIFICADOR VARCHAR(1);-- = RIGHT(''9'', 1);--Para revisar
	DECLARE @CL_ID_ENTIDAD_ORIGEN VARCHAR(8) = ''08110030''; 
	
	DECLARE @CL_CABECERA VARCHAR(200);
	-----
	DECLARE @CL_ORD_NRO_DOC VARCHAR(11);
	DECLARE @CL_BEN_BANCO VARCHAR(6);
	DECLARE @CL_OP_CLASE_TRANS VARCHAR(1);

	DECLARE @CL_OP_TIPO NUMERIC(3);

	DECLARE @CL_NUM_LOTE_CAB VARCHAR(7);
	DECLARE @CL_NUM_LOTE_CAB_NEW NUMERIC(7)=0;
	DECLARE @FA_SUMA_ACUMULADA NUMERIC(15)=0;

	DECLARE @FA_SumaEntidad NUMERIC(12) = 0; --OPH02112023
	DECLARE @FA_SumaSucursal NUMERIC(12) = 0;--OPH02112023
	DECLARE @FA_TotalesCreditos NUMERIC(15) = 0;--OPH02112023

	DECLARE @FA_CANT_LOTES_ARCHIVO NUMERIC(6) = 0;
	DECLARE @FA_RESERVADO  VARCHAR(23) = concat(REPLICATE('' '', 22),''0'');
	DECLARE @FA_ID_REG VARCHAR(1) = ''9'';  
	DECLARE @FA_CANT_LOTES VARCHAR(6) = ''000001'';
	
		--- Variables Fin de Lote ---------------------------------------------------------------------------------------------------------------------------------------------------------------
		DECLARE @FL_ID_REG VARCHAR(1) = ''8'';
		DECLARE @FL_CODIGO_CLASE_TRANSAC VARCHAR(3) = ''220''; 
		DECLARE @FL_CANT_REG_INDIVIDUAL_ADICIONAL VARCHAR(6) = replicate(''0'',6); 
		DECLARE @FL_TOTALES_DE_CONTROL VARCHAR(10) = replicate(''0'',10); 
		--DECLARE @FL_SUMA_TOTAL_DEBITO_LOTE VARCHAR(12); --cambio el largo a 12
		--DECLARE @FL_SUMA_TOTAL_CREDITO_LOTE VARCHAR(12); --cambio el largo a 12
		DECLARE @FL_SUMA_TOTAL_DEBITO_LOTE VARCHAR(20); --cambio el largo a 20
		DECLARE @FL_SUMA_TOTAL_CREDITO_LOTE VARCHAR(20); --cambio el largo a 20
		DECLARE @FL_IDENTIFICACION_EMP_IND VARCHAR(10)= replicate('' '', 10) ;-- = ''3067015779'';--Por revisar
		--DECLARE @FL_RESERVADO2 VARCHAR(19) = replicate('' '', 19); --cambio largo a 19
		DECLARE @FL_RESERVADO2 VARCHAR(3) = replicate('' '', 3); --cambio largo a 3
		DECLARE @FL_RESERVADO3 VARCHAR(6) = replicate('' '', 6); --cambio largo a 6
		DECLARE @FL_REG_ENTIDAD_ORIGEN VARCHAR(8) = ''08110030''; 

		DECLARE @FL_FIN_LOTE VARCHAR(200);

	
	
	DECLARE @CantRegistrosTotal NUMERIC(15) = 2; --seteo 4, cuento la cabecera de archivo, cabecera lote, fin de lote y el fin de archivo 
	DECLARE @CantRegistros NUMERIC(15) = 0; 

	--- Grabamos la cabecera del archivo ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	INSERT INTO ITF_COELSA_MPD_TEMP (LINEA) VALUES (@CA_CABECERA);
	PRINT(@CA_CABECERA)
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	IF((SELECT count(1)	FROM VTA_TRANSFERENCIAS VT1 WHERE VT1.OP_CLASE_TRANS = ''E'' AND VT1.ESTADO=''PP'' AND VT1.OP_MONEDA = 2 AND VT1.TZ_LOCK=0)=0)
	BEGIN
		---------------- Grabar Cabecera Lote ---------------------------
		SET @CL_IDENTIFICACION_EMP_IND = replicate(''0'', 10);
		SET @CL_DIGITO_VERIFICADOR=''0''
		SET @CL_NOMBRE_EMPRESA_INDIVIDUO = REPLICATE('' '',16);	
		SET @CL_CABECERA = concat(@CL_ID_REG, @CL_CODIGO_CLASE_TRANSAC, @CL_NOMBRE_EMPRESA_INDIVIDUO, @CL_INFORMACION_DISCRECIONAL, @CL_IDENTIFICACION_EMP_IND, @CL_TIPO_REGISTRO, @CL_RESERVADO, @CL_FECHA_PRESENTACION, @CL_FECHA_COMPENSACION, @CL_MONEDA_TRANSACCION, @CL_DIGITO_VERIFICADOR, @CL_ID_ENTIDAD_ORIGEN, RIGHT(REPLICATE(''0'',7) + CAST(''1'' AS VARCHAR(7)),7));
		INSERT INTO dbo.ITF_COELSA_MPD_TEMP (LINEA) VALUES (@CL_CABECERA);
		SET @FL_FIN_LOTE = concat(@FL_ID_REG, @FL_CODIGO_CLASE_TRANSAC, RIGHT(CONCAT(REPLICATE(''0'',6),CAST(@FL_CANT_REG_INDIVIDUAL_ADICIONAL AS NUMERIC)),6), @FL_TOTALES_DE_CONTROL, replicate(''0'',20), replicate(''0'',20), @CL_IDENTIFICACION_EMP_IND, @FL_RESERVADO2, @FL_RESERVADO3, @FL_REG_ENTIDAD_ORIGEN, /*@CL_NUMERO_LOTE*/  RIGHT(REPLICATE(''0'',7) + CAST(''1'' AS VARCHAR(7)),7) );
		INSERT INTO dbo.ITF_COELSA_MPD_TEMP (LINEA) VALUES (@FL_FIN_LOTE);
	END 

	DECLARE CursorLote CURSOR FOR
	SELECT A.ORD_NRO_DOC, 
		   A.BEN_BANCO,
	   		A.OP_TIPO, 
	   		A.OP_CLASE_TRANS,
	   		RIGHT(REPLICATE(''0'',7) + CAST(ROW_NUMBER() OVER(ORDER BY A.ORD_NRO_DOC,A.BEN_BANCO,A.OP_TIPO,A.OP_CLASE_TRANS ASC) AS VARCHAR(10)), 7) AS NUM_LOTE_CAB,
	   		(CASE WHEN (A.ORD_TIPO_DOC NOT IN (SELECT TIPODOCUMENTO FROM CLI_TIPOSDOCUMENTOS WHERE TIPOPERSONA=''F'') AND OP_TIPO NOT IN (11,9) ) or OP_TIPO=8  THEN SUBSTRING(CAST(A.ORD_NRO_DOC AS VARCHAR(11)),1,10) ELSE REPLICATE(''0'',10) END) AS CL_IDENTIFICACION_EMP_IND,
			(CASE WHEN (A.ORD_TIPO_DOC NOT IN (SELECT TIPODOCUMENTO FROM CLI_TIPOSDOCUMENTOS WHERE TIPOPERSONA=''F'')AND OP_TIPO NOT IN (11,9) ) or OP_TIPO=8  THEN SUBSTRING(CAST(A.ORD_NRO_DOC AS VARCHAR(11)),11,1) ELSE ''0'' END) AS CL_DIGITO_VERIFICADOR,
			LEFT((CASE WHEN (A.ORD_TIPO_DOC NOT IN (SELECT TIPODOCUMENTO FROM CLI_TIPOSDOCUMENTOS WHERE TIPOPERSONA=''F'')AND OP_TIPO NOT IN (11,9)) or OP_TIPO=8 THEN ORD_NOMBRE ELSE ''PARTICULARES'' END) + REPLICATE('' '',16),16) AS CL_NOMBRE_EMPRESA_INDIVIDUO,	   		
	   		LEFT(ORD_NOMBRE + REPLICATE('' '',16),16) AS RA_NOMBRE_EMPRESA_INDIVIDUO    	  
	   			
	FROM 
		(
		SELECT DISTINCT VT1.ORD_NRO_DOC
						, VT1.BEN_BANCO
						, VT1.OP_CLASE_TRANS
						, VT1.OP_TIPO
						, VT1.ORD_NOMBRE
						, vt1.ORD_TIPO_DOC
		FROM VTA_TRANSFERENCIAS VT1
		WHERE VT1.OP_CLASE_TRANS = ''E'' 
		AND VT1.ESTADO=''PP'' 
		AND VT1.OP_MONEDA = 2 
		AND VT1.TZ_LOCK=0
		AND VT1.ORD_NRO_DOC!=0
		) A

	OPEN CursorLote

	FETCH NEXT FROM CursorLote INTO @CL_ORD_NRO_DOC, 
									@CL_BEN_BANCO, 
									@CL_OP_TIPO,
									@CL_OP_CLASE_TRANS, 
									@CL_NUM_LOTE_CAB, 
									@CL_IDENTIFICACION_EMP_IND, 
									@CL_DIGITO_VERIFICADOR, 
									@CL_NOMBRE_EMPRESA_INDIVIDUO,
									@RA_NOMBRE_EMPRESA_INDIVIDUO

	WHILE @@FETCH_STATUS = 0
	BEGIN
	PRINT(@@FETCH_STATUS)
		SET @CL_MONEDA_TRANSACCION =(SELECT TOP 1 concat(''01'',RIGHT(adicional_present,1)) FROM VTA_TRANSFERENCIAS_TIPOS WHERE id_tipo=@cl_op_tipo)
  		SET @FA_CANT_LOTES_ARCHIVO = @FA_CANT_LOTES_ARCHIVO + 1;
  		SET @CantRegistrosTotal +=1;
  		SET @CL_NUM_LOTE_CAB_NEW +=1;
  
		DECLARE @CL_NUMERO_LOTE VARCHAR(7) = @CL_NUM_LOTE_CAB;
		

		SET @CL_CABECERA = concat(@CL_ID_REG, @CL_CODIGO_CLASE_TRANSAC, @CL_NOMBRE_EMPRESA_INDIVIDUO, @CL_INFORMACION_DISCRECIONAL, @CL_IDENTIFICACION_EMP_IND, @CL_TIPO_REGISTRO, @CL_RESERVADO, @CL_FECHA_PRESENTACION, @CL_FECHA_COMPENSACION, @CL_MONEDA_TRANSACCION, @CL_DIGITO_VERIFICADOR, @CL_ID_ENTIDAD_ORIGEN, RIGHT(REPLICATE(''0'',7) + CAST(@CL_NUM_LOTE_CAB_NEW AS VARCHAR(7)),7));
		----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

		--- Grabar la cabecera de lote ---------------------------------------------------------------------------------------------------------------------------------------------------------------
		INSERT INTO ITF_COELSA_MPD_TEMP (LINEA) VALUES (@CL_CABECERA);
		----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

		--- Variables Registro Individual -------------------------------------------------------------------------------------------------------------------------------------------------------------
		DECLARE @RI_ID_REG VARCHAR(1) = ''6'';
		DECLARE @RI_CODIGO_TRANSAC VARCHAR(2) = ''32'';
		DECLARE @RI_ENTIDAD_AACREDITAR VARCHAR(8);
		--DECLARE @RI_RESERVADO VARCHAR(1) = ''0'';
		DECLARE @RI_CUENTA_AACREDITAR VARCHAR(14); 
		--DECLARE @RI_IMPORTE VARCHAR(10);
		DECLARE @RI_IMPORTE VARCHAR(14);
		DECLARE @RI_REFERENCIA_UNIVOCA VARCHAR(15); 
		DECLARE @RI_IDENTIFICACION_CLIENTE_BEN VARCHAR(22);
		DECLARE @RI_MONEDA VARCHAR(2);
		DECLARE @RI_REGISTRO_ADICIONAL VARCHAR(1) = ''1''; 
		DECLARE @RI_CONTADOR_REGISTRO VARCHAR(15);


		DECLARE @RI_REGISTRO_INDIVIDUAL VARCHAR (200);
	
		-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		--- Variables Registro Adicional------------------------------------------------------------------------------------------------------------------------------------------------------
		DECLARE @RA_ID_REG VARCHAR(1) = ''7''; 
		DECLARE @RA_CODIGO_TIPO_ADICIONAL VARCHAR(2) = ''05'';
		DECLARE @RA_CODIGO_CONCEPTO VARCHAR(80);
		DECLARE @RA_CODIGO_MOTIVO_RECHAZO VARCHAR(3);
		DECLARE @RA_NUM_SECUENCIA VARCHAR(4)=''0001'';	--Contador de registro de transacción original
		DECLARE @RA_ENTIDAD_TRAN_ORIGINAL VARCHAR(8);									
		DECLARE @RA_INFORMACION_ADICIONAL VARCHAR(44);
		DECLARE @RA_CONTADOR_REGISTRO VARCHAR(15);
		DECLARE @RA_CONTADOR_REG_ADICIONAL VARCHAR(7);

		DECLARE @RA_REGISTRO_ADICIONAL VARCHAR (200);

		-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------


		--------------------------------------------------------------------------------------------------------------------------------------------- 		
		--- Variables Fin de Archivo ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		DECLARE @FA_NUMERO_BLOQUES VARCHAR(6);
		DECLARE @FA_CANT_REG_INDIVIDUAL_ADICIONAL VARCHAR(8);
		DECLARE @FA_TOTALES_DE_CONTROL VARCHAR(10);  --NO LO VOY A NECESITAR MAS, EN SU LUGAR USO @FL_TOTALES_DE_CONTROL
		--DECLARE @FA_SUMA_TOTAL_DEBITOS VARCHAR(12);--cambio largo a 12
		--DECLARE @FA_SUMA_TOTAL_CREDITOS VARCHAR(12);
		DECLARE @FA_SUMA_TOTAL_DEBITOS VARCHAR(20);--cambio largo a 20
		DECLARE @FA_SUMA_TOTAL_CREDITOS VARCHAR(20);
		DECLARE @FA_FIN_ARCHIVO VARCHAR(200);

		-----------------------------------------------------------------------------------------------------------------------------------------------------
		--- Grabar registro individual ---------------------------------------------------------------------------------------------------------------------------------------------------------------
		DECLARE @DP_BANCO NUMERIC(5);
		DECLARE @DP_SUCURSAL NUMERIC(5);
		DECLARE @DP_NUMERO_CUENTA NUMERIC(20);
		DECLARE @DP_IMPORTE NUMERIC(15,2);

		------- Variables generales ------------
		DECLARE @SumaImportes NUMERIC(15,2) = 0;
		DECLARE @TotalesControl NUMERIC(10) = 0;
		DECLARE @TotalesDebitos NUMERIC(15) = 0;
		DECLARE @TotalesCreditos NUMERIC(15,2) = 0;



		DECLARE @SumaEntidad NUMERIC = 0;
		DECLARE @SumaSucursal NUMERIC = 0;
		DECLARE @SobranteSucursal NUMERIC = 0;
		DECLARE @Excedente NUMERIC(15,2) = 0;
		DECLARE @CountExcedente INT = 0;
		------------------------------------------  
		DECLARE CursorTransferencias CURSOR FOR

		SELECT
    	--3 Entidad a acreditar
    		RIGHT(CONCAT(replicate(''0'',8),convert(BIGINT,substring(TR.BEN_CBU,1,7))+5000000),8) AS RI_ENTIDAD_AACREDITAR --Numero de sucursal destino,
    		--, (CASE WHEN BEN_CBU='''' THEN replicate(''0'',17) ELSE right(concat(replicate(''0'',17),RIGHT(BEN_CBU,14)),17) END) AS DP_NUMERO_CUENTA --Cuenta a acreditar
			, (CASE WHEN BEN_CBU='''' THEN replicate(''0'',14) ELSE right(concat(replicate(''0'',14),RIGHT(BEN_CBU,14)),14) END) AS DP_NUMERO_CUENTA --Cuenta a acreditar
    		, TR.OP_IMPORTE AS IMPORTE --6 importe
     		, CONCAT(isnull(tr.OP_REFERENCIA,''   ''), RIGHT(REPLICATE(''0'',12) + CAST(TR.OP_NUMERO AS VARCHAR(12)) ,12)) AS RI_REFERENCIA_UNIVOCA--Referencia univoca de la transferencia
     		, LEFT(CAST(concat((CASE WHEN TR.BEN_TIPO_DOC = ''CUIT'' THEN ''1'' WHEN TR.BEN_TIPO_DOC = ''CUIL'' THEN ''2'' ELSE ''3'' END),RIGHT(REPLICATE(''0'',11) + CAST(TR.BEN_NRO_DOC AS VARCHAR(11)), 11),REPLICATE('' '',7), (CASE WHEN TR.BEN_MISMO_TITULAR=''N'' THEN ''073'' else ''074'' end)) AS VARCHAR(22)) + REPLICATE('' '',22),22) AS RI_IDENTIFICACION_CLIENTE_BEN --código de operatoria del BCRA:73,74,75 ...POR REVISAR Y COMPLETAR
     		, CONCAT((CASE WHEN TR.OP_MONEDA=1 THEN ''0'' WHEN TR.OP_MONEDA=2 THEN ''1'' ELSE ''2'' END), RIGHT(CAST(TR.OP_TIPO AS VARCHAR(3)), 1)) AS RI_MONEDA--Tipo de transferencia
	 		, TR.BEN_BANCO AS DP_BANCO
     		, RIGHT(BEN_SUCURSAL,3) AS DP_SUCURSAL
	 		, RIGHT(REPLICATE(''0'',3) + CAST(TR.MOTIVO_RECHAZO AS VARCHAR(10)), 3) AS RA_CODIGO_MOTIVO_RECHAZO
	 		, CONCAT(RIGHT(REPLICATE(''0'',4) + (CASE WHEN TR.OP_MONEDA=2 THEN CAST((TR.BEN_BANCO + 500) AS VARCHAR(10)) ELSE CAST(TR.BEN_BANCO AS VARCHAR(10)) END), 4), RIGHT(REPLICATE(''0'',4) + SUBSTRING(TR.BEN_CBU,4,4),4)) AS RA_ENTIDAD_TRAN_ORIGINAL
	 		, LEFT(UPPER(TR.OP_MOTIVO) + REPLICATE('' '',44),44) AS RA_INFORMACION_ADICIONAL
	 		, tR.OP_NUMERO	 
    	FROM VTA_TRANSFERENCIAS TR (NOLOCK)
    	WHERE TR.OP_CLASE_TRANS = ''E'' 
    	and TR.ESTADO=''PP'' 
    	AND TR.OP_MONEDA = 2 
    	AND TR.TZ_LOCK=0
    	AND TR.TZ_LOCK=0 
    	AND TR.ORD_NRO_DOC=@CL_ORD_NRO_DOC 
    	AND TR.BEN_BANCO=@CL_BEN_BANCO 
    	AND TR.OP_TIPO=@CL_OP_TIPO
    	AND TR.OP_CLASE_TRANS=@CL_OP_CLASE_TRANS
    	ORDER BY TR.ORD_NRO_DOC,TR.BEN_BANCO,TR.OP_TIPO ASC

		OPEN CursorTransferencias
		FETCH NEXT FROM CursorTransferencias INTO @RI_ENTIDAD_AACREDITAR, 
													@RI_CUENTA_AACREDITAR, 
													@DP_IMPORTE, 
													@RI_REFERENCIA_UNIVOCA, 
													@RI_IDENTIFICACION_CLIENTE_BEN, 
													@RI_MONEDA, 
													@DP_BANCO, 
													@DP_SUCURSAL, 
													@RA_CODIGO_MOTIVO_RECHAZO, 
													@RA_ENTIDAD_TRAN_ORIGINAL, 
													@RA_INFORMACION_ADICIONAL
													, @T_REFERENCIA
        
        
		WHILE @@FETCH_STATUS = 0
		BEGIN
	 	
	 	Start:
			--IF (@SumaImportes > 9999999999.99 OR @SumaEntidad > 999999 OR @FA_SUMA_ACUMULADA > 999999999999.99)
			IF (@SumaImportes > 999999999999.99 OR @SumaEntidad > 999999 OR @FA_SUMA_ACUMULADA > 999999999999999999.99)
			BEGIN
				PRINT @SumaImportes
				IF @SumaSucursal > 9999
				BEGIN
					SET @SobranteSucursal = CAST(substring(CAST(@SumaSucursal AS VARCHAR), 1, (len(@SumaSucursal) - 4)) AS NUMERIC);
					SET @SumaEntidad += @SobranteSucursal;
					SET @SumaSucursal = CAST(RIGHT(@SumaSucursal, 4) AS NUMERIC);
				END
		
				SET @TotalesControl += @SumaEntidad + @SumaSucursal;
	   			SET @FL_TOTALES_DE_CONTROL = right(concat(replicate(''0'', 10), (SELECT sum(convert(INT,substring(linea,4,8))) FROM ITF_COELSA_MPD_TEMP WHERE LINEA LIKE ''6%'' AND ID>(SELECT max(id) FROM ITF_COELSA_MPD_TEMP WHERE LINEA LIKE ''5%''))),10);
				--SET @FL_SUMA_TOTAL_DEBITO_LOTE  = RIGHT(replicate(''0'', 12), 12);
	   			--SET @FL_SUMA_TOTAL_CREDITO_LOTE = RIGHT(concat(replicate(''0'', 12), (replace(@SumaImportes, ''.'', ''''))), 12); 
				SET @FL_SUMA_TOTAL_DEBITO_LOTE  = RIGHT(replicate(''0'', 20), 20);
	   			SET @FL_SUMA_TOTAL_CREDITO_LOTE = RIGHT(concat(replicate(''0'', 20), (replace(@SumaImportes, ''.'', ''''))), 20); 
				SET @TotalesCreditos += @SumaImportes
				SET @FA_SumaEntidad = @FA_SumaEntidad + @SumaEntidad
				SET @FA_SumaSucursal = @FA_SumaSucursal + @SumaSucursal
				SET @FL_CANT_REG_INDIVIDUAL_ADICIONAL = (SELECT count(1) FROM ITF_COELSA_MPD_TEMP WHERE substring(linea,1,1) IN (''6'',''7'') AND ID>(SELECT max(id) FROM ITF_COELSA_MPD_TEMP WHERE LINEA LIKE ''5%'')) 
	   			SET @FL_FIN_LOTE = concat(@FL_ID_REG, @FL_CODIGO_CLASE_TRANSAC,RIGHT(CONCAT(REPLICATE(''0'',6),CAST(@FL_CANT_REG_INDIVIDUAL_ADICIONAL AS NUMERIC)),6), @FL_TOTALES_DE_CONTROL, @FL_SUMA_TOTAL_DEBITO_LOTE, @FL_SUMA_TOTAL_CREDITO_LOTE, @CL_IDENTIFICACION_EMP_IND, @FL_RESERVADO2, @FL_RESERVADO3, @FL_REG_ENTIDAD_ORIGEN, /*@CL_NUMERO_LOTE*/ RIGHT(REPLICATE(''0'',7) + CAST(@CL_NUM_LOTE_CAB_NEW AS VARCHAR(7)),7));	
		
				INSERT INTO dbo.ITF_COELSA_MPD_TEMP (LINEA) VALUES (replace(@FL_FIN_LOTE, ''.'', ''''));
		
				-------------------------------------------------------------------
				-------------Grabamos el Fin de Archivo ----------------------------------------------------------------------------------------------------------------------
		
				SET @FA_TOTALES_DE_CONTROL = right(concat(replicate(''0'', 10), (SELECT sum(convert(INT,substring(linea,4,8))) FROM ITF_COELSA_MPD_TEMP WHERE LINEA LIKE ''6%'' AND ID>(SELECT max(id) FROM ITF_COELSA_MPD_TEMP WHERE LINEA LIKE ''1%''))),10);
		
				SET @FA_CANT_LOTES = RIGHT(concat(replicate(''0'', 6), @FA_CANT_LOTES_ARCHIVO), 6);
        		
				SET @FA_NUMERO_BLOQUES = RIGHT(CONCAT(REPLICATE(''0'',6) , CAST((CASE WHEN @CantRegistrosTotal % 10 = 0 THEN (@CantRegistrosTotal/10) ELSE (FLOOR(@CantRegistrosTotal /10) + 1) END) AS INTEGER)),6);

				SET @FA_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 8), (SELECT count(id) FROM ITF_COELSA_MPD_TEMP WHERE (LINEA LIKE ''6%'' OR LINEA LIKE ''7%'') AND id>(SELECT max(id) FROM ITF_COELSA_MPD_TEMP WHERE LINEA LIKE ''1%''))), 8);
					
				--SET @FA_SUMA_TOTAL_DEBITOS = RIGHT(concat(replicate(''0'', 12), @TotalesDebitos), 12);
		        SET @FA_SUMA_TOTAL_DEBITOS = RIGHT(concat(replicate(''0'', 20), @TotalesDebitos), 20);
		        
				SET @FA_TotalesCreditos = @FA_TotalesCreditos + @SumaImportes		
				--SET @FA_SUMA_TOTAL_CREDITOS = RIGHT(concat(replicate(''0'', 12), (replace((SELECT convert(NUMERIC(15,2),sum(convert(NUMERIC,substring(linea,30,10)))/100) FROM ITF_COELSA_MPD_TEMP WHERE LINEA LIKE ''6%'' AND ID>(SELECT max(id) FROM ITF_COELSA_MPD_TEMP WHERE LINEA LIKE ''1%'') ), ''.'', ''''))), 12);
				SET @FA_SUMA_TOTAL_CREDITOS = RIGHT(concat(replicate(''0'', 20), (replace((SELECT convert(NUMERIC(15,2),sum(convert(NUMERIC,substring(linea,26,14)))/100) FROM ITF_COELSA_MPD_TEMP WHERE LINEA LIKE ''6%'' AND ID>(SELECT max(id) FROM ITF_COELSA_MPD_TEMP WHERE LINEA LIKE ''1%'') ), ''.'', ''''))), 20);

		
				SET @FA_FIN_ARCHIVO = concat(@FA_ID_REG, RIGHT(REPLICATE(''0'',6) + CAST(@CL_NUM_LOTE_CAB_NEW AS VARCHAR(6)),6), @FA_NUMERO_BLOQUES, @FA_CANT_REG_INDIVIDUAL_ADICIONAL, @FA_TOTALES_DE_CONTROL, @FA_SUMA_TOTAL_DEBITOS, @FA_SUMA_TOTAL_CREDITOS, @FA_RESERVADO);
		

				INSERT INTO dbo.ITF_COELSA_MPD_TEMP (LINEA) VALUES (@FA_FIN_ARCHIVO);
				------------------------------------------------------------------------------------------------------------------------------------------------------------------
				---------- Limpiamos variables -----------------------------------------------------------------------------------------------------------------------------------
				SET @SumaImportes = 0;
				SET @CantRegistros = 0; 
				SET @CantRegistrosTotal = 0; --le sumo 2, que corresponden a los registros CL y FL ya que en teoria se creo un nuevo lote

				SET @TotalesControl = 0;
				SET @TotalesDebitos = 0;
				SET @TotalesCreditos = 0;

				SET @SumaEntidad = 0;
				SET @SumaSucursal = 0;
				SET @FA_SumaEntidad = 0;
				SET @FA_SumaSucursal = 0;
		
				SET @FL_CANT_REG_INDIVIDUAL_ADICIONAL = 0;
				SET @FL_TOTALES_DE_CONTROL = 0;
				SET @FA_SUMA_TOTAL_DEBITOS = 0;
				SET @FA_SUMA_TOTAL_CREDITOS = 0;
				SET @FA_TotalesCreditos = 0;
				SET @CL_NUM_LOTE_CAB_NEW = 0
				SET @CL_NUM_LOTE_CAB_NEW +=1;
				SET @FA_SUMA_ACUMULADA = 0;
				-------------------------------------------------------------------------------------------------------------------------------------------------------------------
				--------- Grabamos nueva Cabecera de Archivo ----------------------------------------------------------------------------------------------------------------------
	    		SET @CA_CABECERA = concat(@CA_ID_REG, @CA_CODIGO_PRIORIDAD, @CA_DESTINO_INMEDIATO, @CA_ORIGEN_INMEDIATO, @CA_FECHA_PRESENTACION, @CA_HORA_PRESENTACION, @CA_IDENTIFICADOR_ARCHIVO, @CA_TAMANNO_REGISTRO, @CA_FACTOR_BLOQUE, @CA_CODIGO_FORMATO, @CA_NOMBRE_DEST_INMEDIATO, @CA_NOMBRE_ORIG_INMEDIATO, @CA_CODIGO_REFERENCIA);
		
				INSERT INTO dbo.ITF_COELSA_MPD_TEMP (LINEA) VALUES (@CA_CABECERA);
				----------------------------------------------------------------------------------------------------------------------------------------------------------------------
				--------- Grabamos nueva Cabecera Lote ------------------------------------------------------------------------------------------------------------------------------------------------------
		
				SET @CL_CABECERA = concat(@CL_ID_REG, @CL_CODIGO_CLASE_TRANSAC, @CL_NOMBRE_EMPRESA_INDIVIDUO, @CL_INFORMACION_DISCRECIONAL, @CL_IDENTIFICACION_EMP_IND, @CL_TIPO_REGISTRO, @CL_RESERVADO, @CL_FECHA_PRESENTACION, @CL_FECHA_COMPENSACION, @CL_MONEDA_TRANSACCION, @CL_DIGITO_VERIFICADOR, @CL_ID_ENTIDAD_ORIGEN, right(concat(replicate(''0'',7), @CL_NUM_LOTE_CAB_NEW),7));
		
				INSERT INTO dbo.ITF_COELSA_MPD_TEMP (LINEA) VALUES (@CL_CABECERA);


				---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
				SET @FA_CANT_LOTES_ARCHIVO = 0;
	
			END
	
			SET @CantRegistros += 1;
			SET @CantRegistrosTotal = @CantRegistrosTotal + 2;
			SET @FA_SUMA_ACUMULADA = @FA_SUMA_ACUMULADA + @RI_IMPORTE;
    
    		SET @FL_CANT_REG_INDIVIDUAL_ADICIONAL += 1;
		
			IF	(@Excedente<>0)
			BEGIN
				SET @DP_IMPORTE = @Excedente;
				SET @CountExcedente += 1;
			END
			--IF	(@DP_IMPORTE > 99999999.99)
			IF	(@DP_IMPORTE > 999999999999.99)
			BEGIN
				--SET @Excedente = (@DP_IMPORTE - 99999999.99);
				--SET @DP_IMPORTE = 99999999.99;
				SET @Excedente = (@DP_IMPORTE - 999999999999.99);
				SET @DP_IMPORTE = 999999999999.99;
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

				SET @RI_ENTIDAD_AACREDITAR= concat(RIGHT(concat(replicate(''0'', 4), @DP_BANCO+500), 4), ''0888''); --agregue el +500 aca
        		SET @RI_CUENTA_AACREDITAR = RIGHT(concat(replicate(''0'', 14), ''88888888888''), 14);
    
			END
    		ELSE --la razon de este else, es que SumaSucursal, cuando hay excedente tiene que acumular 0888
    		BEGIN
			
				SET @SumaSucursal += @DP_SUCURSAL;
				SET @SumaEntidad += @DP_BANCO;
				SET @SumaImportes += @DP_IMPORTE;
		
		
	
			END
			--IF @SumaImportes>9999999999.99
			IF @SumaImportes>999999999999999999.99
				GOTO Start
			SET @RI_IMPORTE = RIGHT(concat(replicate(''0'', 14), replace(CAST(@DP_IMPORTE AS VARCHAR),''.'','''')), 14);
	
	
		    --Condicion de reset del contador de reg individual
 			IF ISNULL((SELECT a.FECHA FROM ITF_MASTER_PARAMETROS a WHERE a.CODIGO = 442), CAST(''01-01-1800'' AS DATETIME)) <> (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK))
  
	    	UPDATE dbo.ITF_MASTER_PARAMETROS SET NUMERICO_1 = 1, FECHA = (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)) WHERE CODIGO = 442;
   
			SET @RI_MONEDA=(SELECT TOP 1 concat(''1'',RIGHT(adicional_present,1)) FROM VTA_TRANSFERENCIAS_TIPOS WHERE id_tipo=@cl_op_tipo)
			SET @RI_CONTADOR_REGISTRO = concat(@cl_id_entidad_origen, RIGHT(concat(replicate(''0'', 7), (SELECT a.NUMERICO_1 FROM ITF_MASTER_PARAMETROS a WHERE CODIGO = 442)), 7)); 

			--Incremento el contador
    		UPDATE dbo.ITF_MASTER_PARAMETROS SET NUMERICO_1 += 1 WHERE CODIGO = 442;
	
			--SET @RI_REGISTRO_INDIVIDUAL = concat(@RI_ID_REG, @RI_CODIGO_TRANSAC, @RI_ENTIDAD_AACREDITAR, @RI_RESERVADO, @RI_CUENTA_AACREDITAR, @RI_IMPORTE, @RI_REFERENCIA_UNIVOCA, @RI_IDENTIFICACION_CLIENTE_BEN, @RI_MONEDA, @RI_REGISTRO_ADICIONAL, @RI_CONTADOR_REGISTRO);
			SET @RI_REGISTRO_INDIVIDUAL = concat(@RI_ID_REG, @RI_CODIGO_TRANSAC, @RI_ENTIDAD_AACREDITAR,  @RI_CUENTA_AACREDITAR, @RI_IMPORTE, @RI_REFERENCIA_UNIVOCA, @RI_IDENTIFICACION_CLIENTE_BEN, @RI_MONEDA, @RI_REGISTRO_ADICIONAL, @RI_CONTADOR_REGISTRO);


			INSERT INTO ITF_COELSA_MPD_TEMP (LINEA) VALUES (replace(@RI_REGISTRO_INDIVIDUAL, ''.'', ''''));
			
			UPDATE dbo.VTA_TRANSFERENCIAS 
    		SET ESTADO=''PR'' 
    			, TRACENUMBER=@RI_CONTADOR_REGISTRO
    		WHERE OP_NUMERO=@T_REFERENCIA
    		AND OP_CLASE_TRANS=''E'';
	
			--- Grabar Registro Adicional -----------------------------------------------------------------------------

			SET @RA_CONTADOR_REG_ADICIONAL = RIGHT(@RI_CONTADOR_REGISTRO,7);
			SET @RA_CODIGO_CONCEPTO = CONCAT(@CL_ORD_NRO_DOC, LEFT(@RA_NOMBRE_EMPRESA_INDIVIDUO + REPLICATE('' '' ,69), 69));
	
			SET @RA_REGISTRO_ADICIONAL = concat(@RA_ID_REG, @RA_CODIGO_TIPO_ADICIONAL, @RA_CODIGO_CONCEPTO, @RA_NUM_SECUENCIA, @RA_CONTADOR_REG_ADICIONAL);	
	
			INSERT INTO ITF_COELSA_MPD_TEMP (LINEA) VALUES (@RA_REGISTRO_ADICIONAL);
	
			--- Grabar historial -----------------------------------------------------------------------------
			-----------------------------------------------------------------------------------------------------

			IF (@Excedente = 0)
			BEGIN		     	

				FETCH NEXT FROM CursorTransferencias INTO @RI_ENTIDAD_AACREDITAR
														, @RI_CUENTA_AACREDITAR
														, @DP_IMPORTE
														, @RI_REFERENCIA_UNIVOCA
														, @RI_IDENTIFICACION_CLIENTE_BEN
														, @RI_MONEDA
														, @DP_BANCO
														, @DP_SUCURSAL
														, @RA_CODIGO_MOTIVO_RECHAZO
														, @RA_ENTIDAD_TRAN_ORIGINAL
														, @RA_INFORMACION_ADICIONAL
														, @T_REFERENCIA
				SET @CountExcedente = 0;
			END
		END	--Fin del cursor CursorTransferencias
        
		CLOSE CursorTransferencias
		DEALLOCATE CursorTransferencias

		IF @SumaSucursal > 9999
		BEGIN
			SET @SobranteSucursal = 0;
			SET @SobranteSucursal = CAST(substring(CAST(@SumaSucursal AS VARCHAR), 1, (len(@SumaSucursal) - 4)) AS NUMERIC);
			SET @SumaEntidad += @SobranteSucursal;
			SET @SumaSucursal = CAST(RIGHT(@SumaSucursal, 4) AS NUMERIC);
		END
		

		SET @FL_TOTALES_DE_CONTROL = right(concat(replicate(''0'', 10), (SELECT sum(convert(INT,substring(linea,4,8))) FROM ITF_COELSA_MPD_TEMP WHERE LINEA LIKE ''6%'' AND ID>(SELECT max(id) FROM ITF_COELSA_MPD_TEMP WHERE LINEA LIKE ''5%''))),10); --relleno y separo con ceros

		SET @TotalesControl += CAST(@FL_TOTALES_DE_CONTROL AS INTEGER); --lo uso para armar el totalControl del reg FA

		--SET @FL_SUMA_TOTAL_DEBITO_LOTE  = replicate(''0'', 12);
		--SET @FL_SUMA_TOTAL_CREDITO_LOTE = RIGHT(concat(replicate(''0'', 12), (replace(@SumaImportes, ''.'', ''''))), 12);
		SET @FL_SUMA_TOTAL_DEBITO_LOTE  = replicate(''0'', 20);
		SET @FL_SUMA_TOTAL_CREDITO_LOTE = RIGHT(concat(replicate(''0'', 20), (replace(@SumaImportes, ''.'', ''''))), 20); 
		SET @TotalesCreditos += @SumaImportes;
      print(''dbl'')
	  print(@FL_SUMA_TOTAL_DEBITO_LOTE);
	  print(''crl'')
	  print(@FL_SUMA_TOTAL_CREDITO_LOTE)

		--SELECT @FL_SUMA_TOTAL_CREDITO_LOTE
		SET @CantRegistrosTotal +=1;
		SET @FL_CANT_REG_INDIVIDUAL_ADICIONAL = (SELECT count(1) FROM ITF_COELSA_MPD_TEMP WHERE substring(linea,1,1) IN (''6'',''7'') AND ID>(SELECT max(id) FROM ITF_COELSA_MPD_TEMP WHERE LINEA LIKE ''5%'')) 

		SET @FL_FIN_LOTE = concat(@FL_ID_REG, @FL_CODIGO_CLASE_TRANSAC, RIGHT(CONCAT(REPLICATE(''0'',6),CAST(@FL_CANT_REG_INDIVIDUAL_ADICIONAL AS NUMERIC)),6), @FL_TOTALES_DE_CONTROL, @FL_SUMA_TOTAL_DEBITO_LOTE, @FL_SUMA_TOTAL_CREDITO_LOTE, @CL_IDENTIFICACION_EMP_IND, @FL_RESERVADO2, @FL_RESERVADO3, @FL_REG_ENTIDAD_ORIGEN, /*@CL_NUMERO_LOTE*/  RIGHT(REPLICATE(''0'',7) + CAST(@CL_NUM_LOTE_CAB_NEW AS VARCHAR(7)),7) );
		-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------


		--- Grabamos la fin de lote del archivo ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		INSERT INTO dbo.ITF_COELSA_MPD_TEMP (LINEA) VALUES (replace(@FL_FIN_LOTE, ''.'', ''''));

		SET @FA_SumaEntidad = @FA_SumaEntidad + @SumaEntidad

		SET @FA_SumaSucursal = @FA_SumaSucursal + @SumaSucursal
		SET @FA_TotalesCreditos = @FA_TotalesCreditos + @SumaImportes
		--------------------------------------------------------------------------------------------------------------------
		FETCH NEXT FROM CursorLote INTO @CL_ORD_NRO_DOC
										, @CL_BEN_BANCO
										, @CL_OP_TIPO
										, @CL_OP_CLASE_TRANS
										, @CL_NUM_LOTE_CAB
										, @CL_IDENTIFICACION_EMP_IND
										, @CL_DIGITO_VERIFICADOR
										, @CL_NOMBRE_EMPRESA_INDIVIDUO
										, @RA_NOMBRE_EMPRESA_INDIVIDUO

	END --Fin del cursor CursoLote

	CLOSE CursorLote
	DEALLOCATE CursorLote

	--------------------------------------------------------------------------------------------------------------------

	-------------Grabamos el Fin de Archivo -------------------------------------------------------------------------------------------------------------------------------------


	SET @FA_TOTALES_DE_CONTROL = right(concat(replicate(''0'', 10), (SELECT sum(convert(INT,substring(linea,4,8))) FROM ITF_COELSA_MPD_TEMP WHERE LINEA LIKE ''6%'' AND ID>(SELECT max(id) FROM ITF_COELSA_MPD_TEMP WHERE LINEA LIKE ''1%''))),10);
	SET @FA_CANT_LOTES = RIGHT(concat(replicate(''0'', 6), (SELECT count(id) FROM ITF_COELSA_MPD_TEMP WHERE LINEA LIKE ''5%'' AND id>(SELECT max(id) FROM ITF_COELSA_MPD_TEMP WHERE LINEA LIKE ''1%''))), 6);
	SET @FA_NUMERO_BLOQUES = RIGHT(concat(replicate(''0'', 6), (SELECT CEILING((count(*)+1) / CONVERT(FLOAT, 10)) FROM ITF_COELSA_MPD_TEMP WHERE  ID>=(SELECT max(id) FROM ITF_COELSA_MPD_TEMP WHERE LINEA LIKE ''1%''))), 6);
	SET @FA_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 8), (SELECT count(id) FROM ITF_COELSA_MPD_TEMP WHERE (LINEA LIKE ''6%'' OR LINEA LIKE ''7%'') AND id>(SELECT max(id) FROM ITF_COELSA_MPD_TEMP WHERE LINEA LIKE ''1%''))), 8);
	--SET @FA_SUMA_TOTAL_DEBITOS = RIGHT(concat(replicate(''0'', 12), @TotalesDebitos), 12);
	--SET @FA_SUMA_TOTAL_CREDITOS = RIGHT(concat(replicate(''0'', 12), (replace((SELECT convert(NUMERIC(15,2),sum(convert(NUMERIC,substring(linea,30,10)))/100) FROM ITF_COELSA_MPD_TEMP WHERE LINEA LIKE ''6%'' AND ID>(SELECT max(id) FROM ITF_COELSA_MPD_TEMP WHERE LINEA LIKE ''1%'') ), ''.'', ''''))), 12);
	SET @FA_SUMA_TOTAL_DEBITOS = RIGHT(concat(replicate(''0'', 20), @TotalesDebitos), 20);
	SET @FA_SUMA_TOTAL_CREDITOS = RIGHT(concat(replicate(''0'', 20), (replace((SELECT convert(NUMERIC(15,2),sum(convert(NUMERIC,substring(linea,26,14)))/100) FROM ITF_COELSA_MPD_TEMP WHERE LINEA LIKE ''6%'' AND ID>(SELECT max(id) FROM ITF_COELSA_MPD_TEMP WHERE LINEA LIKE ''1%'') ), ''.'', ''''))), 20);



	SET @FA_FIN_ARCHIVO = concat(@FA_ID_REG, @FA_CANT_LOTES, @FA_NUMERO_BLOQUES, @FA_CANT_REG_INDIVIDUAL_ADICIONAL, @FA_TOTALES_DE_CONTROL /*@FL_TOTALES_DE_CONTROL --Elisvan*/, @FA_SUMA_TOTAL_DEBITOS, @FA_SUMA_TOTAL_CREDITOS, @FA_RESERVADO);

	--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--- Grabar fin de archivo ---------------------------------------------------------------------------------------------------------------------------------------------------------------

	INSERT INTO dbo.ITF_COELSA_MPD_TEMP (LINEA) VALUES (@FA_FIN_ARCHIVO);
	----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	END TRY

	BEGIN CATCH  
    	SELECT ERROR_NUMBER() AS ErrorNumber  
       		, ERROR_MESSAGE() AS ErrorMessage
       		, ERROR_LINE() AS ErrorLine;  
	END CATCH

END
--select * from  ITF_COELSA_MPD_TEMP--sacar despues
'); 

EXECUTE('CREATE OR ALTER PROCEDURE [dbo].[SP_TRAN_MINORISTA_PRESENTADAS_V2]
(
   @TICKET NUMERIC(16)
)

AS 
BEGIN

	------------ Limpieza de tabla auxiliar --------------------
	TRUNCATE TABLE dbo.ITF_TRAN_MINORISTA_PRESENTADAS_AUX;
	------------------------------------------------------------
	DECLARE @i INT=0;
	--declare @TICKET NUMERIC(16) = 12342142
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
	DECLARE @CL_RESERVADO_CL VARCHAR(3) = ''000''; -- fijo
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
	DECLARE @RI_ENTIDAD_CREDITO_RE VARCHAR(8);
	--DECLARE @RI_RESERVADO VARCHAR(1) = ''0''; -- fijo 
	--DECLARE @RI_CUENTA_CREDITO VARCHAR(17); 
	DECLARE @RI_CUENTA_CREDITO VARCHAR(14); 
	--DECLARE @RI_IMPORTE VARCHAR(11); 
	DECLARE @RI_IMPORTE VARCHAR(14); 
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
	DECLARE @t_estado VARCHAR(2);
	DECLARE @nuevo_estado VARCHAR(2);
	DECLARE @op_tipo NUMERIC(3)=0;
	------ Variables registro ajuste ( RA) ------------

	DECLARE @RA_ID_REG_ADICIONAL VARCHAR(6) = ''705   '';
	DECLARE @RA_FECHA_PRESENTACION VARCHAR(6);
	DECLARE @RA_ENTIDAD VARCHAR(8);
	DECLARE @RA_CONTADOR VARCHAR(15);
	DECLARE @RA_RECHAZO VARCHAR(3);

	--- Variables fin de lote FL
	DECLARE @FL_ID_REG VARCHAR(1) = ''8''; -- fijo 
	DECLARE @FL_CODIGO_CLASE_TRANSAC VARCHAR(3) = ''220''; -- fijo 
	DECLARE @FL_CANT_REG_INDIVIDUAL_ADICIONAL VARCHAR(6) = 0; --registros individuales y adicionales que existen en el lote
	DECLARE @FL_TOTALES_DE_CONTROL VARCHAR(10) = 0;
	--DECLARE @FL_SUMA_TOTAL_DEBITO_LOTE VARCHAR(12); 
	--DECLARE @FL_SUMA_TOTAL_CREDITO_LOTE VARCHAR(12); 
	DECLARE @FL_SUMA_TOTAL_DEBITO_LOTE VARCHAR(20); 
	DECLARE @FL_SUMA_TOTAL_CREDITO_LOTE VARCHAR(20); 
	DECLARE @FL_RESERVADO1 VARCHAR(10) = ''          ''; -- fijo
	--DECLARE @FL_RESERVADO2 VARCHAR(19) = ''                   ''; -- fijo
	DECLARE @FL_RESERVADO2 VARCHAR(3) = ''   ''; -- fijo
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
	--DECLARE @FA_SUMA_TOTAL_DEBITOS VARCHAR(12);
	--DECLARE @FA_SUMA_TOTAL_CREDITOS VARCHAR(12);
	DECLARE @FA_SUMA_TOTAL_DEBITOS VARCHAR(20);
	DECLARE @FA_SUMA_TOTAL_CREDITOS VARCHAR(20);
	--DECLARE @FA_RESERVADO  VARCHAR(100) = concat(replicate('' '', 38),''0''); -- fijo
	DECLARE @FA_RESERVADO  VARCHAR(100) = concat(replicate('' '', 22),''0''); -- fijo

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
	DECLARE @T_FECHA_PRESENTACION DATETIME;
	DECLARE @T_TRACENUMBER NUMERIC(15,0)
	DECLARE @T_MOTIVO_RECHAZO NUMERIC(3,0)


	IF((SELECT COUNT(1) 
		FROM VTA_TRANSFERENCIAS t 
		INNER JOIN VTA_TRANSFERENCIAS_TIPOS TT ON t.OP_TIPO=TT.ID_TIPO
		WHERE ((t.OP_CLASE_TRANS=''R'' AND t.ESTADO=''RC'') OR (t.OP_CLASE_TRANS=''E'' AND t.ESTADO=''PP'')) 
		AND t.OP_MONEDA=1 
		AND t.TZ_LOCK=0
		AND TT.TZ_LOCK=0
		AND tt.TIPO_PROCESO NOT LIKE ''S%'')=0)
	BEGIN
		---------------- Grabar Cabecera Lote ---------------------------
		SET @CL_NUMERO_LOTE = RIGHT(concat(replicate(''0'', 7), (@CL_NUMERO_LOTE + 1)), 7);
		SET @CL_NOM_EMPRESA =  LEFT(concat('''',replicate('' '', 16)),16);
		SET @CL_CRITERIO_EMPRESA = replicate('' '', 20); -- AUN NO EXISTE AUTONUMERICO, FALTA DEFINIR 
		SET @CL_ID_EMPRESA = replicate(''0'', 10);
			
		SET @CL_CABECERA = concat(@CL_ID_REG
								, @CL_CODIGO_CLASE_TRANSAC
								, @CL_NOM_EMPRESA
								, @CL_CRITERIO_EMPRESA
								, @CL_ID_EMPRESA
								, @CL_TIPO_REGISTRO
								, @CL_DESCRIP_TRANSAC
								, @CL_FECHA_PRESENTACION
								, @CL_FECHA_VENCIMIENTO
								, @CL_RESERVADO_CL
								, @CL_CODIGO_ORIGEN
								, @CL_ID_ENTIDAD_ORIGEN
								, @CL_NUMERO_LOTE);
		INSERT INTO dbo.ITF_TRAN_MINORISTA_PRESENTADAS_AUX (LINEA) VALUES (@CL_CABECERA);
	END 
		
    --Condicion de reset del contador de reg individual
	IF ISNULL((SELECT a.FECHA FROM ITF_MASTER_PARAMETROS a WHERE a.CODIGO = 149), CAST(''01-01-1800'' AS DATETIME)) <> (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK))
    	UPDATE dbo.ITF_MASTER_PARAMETROS SET NUMERICO_1 = 1, FECHA = (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)) WHERE CODIGO = 149;

	SET @T_FECHA_COMP = (SELECT CONVERT(DATETIME, dbo.diaHabil ((SELECT (FECHAPROCESO + 1) FROM PARAMETROS WITH(NOLOCK)),''A'')) AS A);
	SET @T_FECHA_VTO =  @T_FECHA_COMP;

	DECLARE CursorTM CURSOR FOR

	SELECT t.OP_NUMERO, 
	   t.OP_MONEDA, 
	   t.OP_IMPORTE, 
	   @T_FECHA_VTO, 
	   @T_FECHA_COMP, 
	   t.ORD_CBU, 
	   t.OP_NUMERO, 
	   t.ORD_NRO_DOC, 
	   t.ORD_NOMBRE, 
	   RIGHT(''00000000000'' + CAST(t.BEN_NRO_DOC AS VARCHAR(11)), 11) AS BEN_NRO_DOC, 
	   t.BEN_NOMBRE, 
	   t.BEN_TIPO_DOC,
	   t.ORD_TIPO_DOC, 
	   t.OP_REFERENCIA,
	   CASE WHEN t.ESTADO=''PP'' THEN TT.ADICIONAL_PRESENT ELSE TT.ADICIONAL_devol end,
	   t.BEN_CBU,
	   t.BEN_MISMO_TITULAR,
	   t.BEN_BANCO,
	   t.OP_TIPO
	   , T.ESTADO
	   	    , T.OP_FECHA_PRES
	    	, T.TRACENUMBER
	    	, T.MOTIVO_RECHAZO
	    	,  RIGHT(''0000'' + CAST(t.ORD_BANCO AS VARCHAR(4)), 4) + 
			   RIGHT(''0000'' + CAST(t.ORD_SUCURSAL AS VARCHAR(4)), 4) AS RI_ENTIDAD_CREDITO_RE
	FROM VTA_TRANSFERENCIAS t 
	INNER JOIN VTA_TRANSFERENCIAS_TIPOS TT ON t.OP_TIPO=TT.ID_TIPO
	WHERE ((t.OP_CLASE_TRANS=''R'' AND t.ESTADO=''RC'') OR (t.OP_CLASE_TRANS=''E'' AND t.ESTADO=''PP'')) 
	AND t.OP_MONEDA=1 
	AND t.TZ_LOCK=0
	AND TT.TZ_LOCK=0
	AND tt.TIPO_PROCESO NOT LIKE ''S%''
	ORDER BY t.ORD_NRO_DOC,t.ben_banco,t.OP_TIPo, t.OP_MONEDA
	OPEN CursorTM
	FETCH NEXT FROM CursorTM INTO @T_ID_CREDITO, 
							  @T_MONEDA, 
							  @T_IMPORTE, 
							  @T_FECHA_VTO,
							  @T_FECHA_COMP,
							  @T_CBU, 
							  @T_REFERENCIA, 
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
							  , @t_estado
								, @T_FECHA_PRESENTACION
							    , @T_TRACENUMBER
							    , @T_MOTIVO_RECHAZO
								, @RI_ENTIDAD_CREDITO_RE 

	WHILE @@FETCH_STATUS = 0
	BEGIN
		Start:
		IF @t_estado=''RC''
			SET @nuevo_estado=''RP''
		ELSE 
			SET @nuevo_estado=''PR''
			
		SET @t_op_referencia=RIGHT(concat(replicate('' '',3),@t_op_referencia),3)
		SET @CL_RESERVADO_CL=RIGHT(concat(''000'',@t_ADICIONAL_PRESENT),3) 
		SET @CL_NOM_EMPRESA =  LEFT(concat(''PARTICULARES'',replicate('' '', 16)),16);

	
		--IF (@SumaImportes > 9999999999.99 OR @SumaEntidad > 999999)  -- 99 millones
		IF (@SumaImportes > 999999999999.99 OR @SumaEntidad > 999999)  -- 99 mil millones
		BEGIN
	
			IF @SumaSucursal > 9999
			BEGIN
				SET @SobranteSucursal = CAST(substring(CAST(@SumaSucursal AS VARCHAR), 1, (len(@SumaSucursal) - 4)) AS NUMERIC);
				SET @SumaEntidad += @SobranteSucursal;
				SET @SumaSucursal = CAST(RIGHT(@SumaSucursal, 4) AS NUMERIC);
			END
		

	   		SET @FL_TOTALES_DE_CONTROL = concat((RIGHT(concat(replicate(''0'', 6), @SumaEntidad), 6)), (RIGHT(concat(replicate(''0'', 4), @SumaSucursal), 4)));
	   		--SET @FL_SUMA_TOTAL_DEBITO_LOTE = RIGHT(replicate(''0'', 12), 12);
			SET @FL_SUMA_TOTAL_DEBITO_LOTE = RIGHT(replicate(''0'', 20), 20);
	   		--SET @FL_SUMA_TOTAL_CREDITO_LOTE = RIGHT(concat(replicate(''0'', 12), (replace((SELECT sum(convert(bigint, substring(linea,30,10))) FROM ITF_TRAN_MINORISTA_PRESENTADAS_AUX WHERE LINEA LIKE ''6%'' AND id>(SELECT max(id) FROM ITF_TRAN_MINORISTA_PRESENTADAS_AUX WHERE LINEA LIKE ''5%'')), ''.'', ''''))), 12); 
	   		SET @FL_SUMA_TOTAL_CREDITO_LOTE = RIGHT(concat(replicate(''0'', 20), (replace((SELECT sum(convert(bigint, substring(linea,26,14))) FROM ITF_TRAN_MINORISTA_PRESENTADAS_AUX WHERE LINEA LIKE ''6%'' AND id>(SELECT max(id) FROM ITF_TRAN_MINORISTA_PRESENTADAS_AUX WHERE LINEA LIKE ''5%'')), ''.'', ''''))), 20); 
	   		SET @TotalesCreditos += @SumaImportes;
	   		SET @FL_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 6), @Cant_Reg_Individual_Adicional), 6); 
	   	 	
	   		SET @FL_FIN_LOTE = concat(@FL_ID_REG, @FL_CODIGO_CLASE_TRANSAC, @FL_CANT_REG_INDIVIDUAL_ADICIONAL, @FL_TOTALES_DE_CONTROL, @FL_SUMA_TOTAL_DEBITO_LOTE, @FL_SUMA_TOTAL_CREDITO_LOTE, @FL_RESERVADO1, @FL_RESERVADO2, @FL_RESERVADO3, @FL_REG_ENTIDAD_ORIGEN, @FL_NUMERO_LOTE);
		
    
	
			INSERT INTO dbo.ITF_TRAN_MINORISTA_PRESENTADAS_AUX (LINEA) VALUES (@FL_FIN_LOTE);
		
			SET @FL_NUMERO_LOTE = CAST(@FL_NUMERO_LOTE AS NUMERIC) + 1;
			SET @FL_NUMERO_LOTE = RIGHT(concat(replicate(''0'', 7), @FL_NUMERO_LOTE), 7);
			SET @CL_NUMERO_LOTE = RIGHT(concat(replicate(''0'', 7), (0)), 7);
			-------------------------------------------------------------------
			-------------Grabamos el Fin de Archivo ----------------------------------------------------------------------------------------------------------------------
			SET @FA_CANT_LOTES = RIGHT(concat(replicate(''0'', 6), @FL_NUMERO_LOTE), 6);
			SET @CantRegistrosPrev = (SELECT (CASE WHEN (@CantRegistros + 4) % 10 = 0 THEN ((@CantRegistros + 4)/10) ELSE (FLOOR((@CantRegistros + 4)/10) + 1) END));
		
		
		 	SET @FA_NUMERO_BLOQUES = RIGHT(concat(replicate(''0'', 6), (SELECT CEILING((count(*)+1) / CONVERT(FLOAT, 10))
																  	FROM ITF_TRAN_MINORISTA_PRESENTADAS_AUX 
																  	WHERE  ID>=(SELECT max(id) 
																  		  		FROM ITF_TRAN_MINORISTA_PRESENTADAS_AUX 
																  		  		WHERE LINEA LIKE ''1%''))), 6)
	
	

			SET @FA_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 8), @CantRegistros), 8);		
			SET @FA_TOTALES_DE_CONTROL = @FL_TOTALES_DE_CONTROL; --igualo al totales de control de fin de lote pq tiene que ser igual	
			--SET @FA_SUMA_TOTAL_DEBITOS = RIGHT(concat(replicate(''0'', 12), (replace(@TotalesDebitos, ''.'', ''''))), 12);
			SET @FA_SUMA_TOTAL_DEBITOS = RIGHT(concat(replicate(''0'', 20), (replace(@TotalesDebitos, ''.'', ''''))), 20);	
			--SET @FA_SUMA_TOTAL_CREDITOS = RIGHT(concat(replicate(''0'', 12), (replace((SELECT sum(convert(bigint, substring(linea,30,10))) FROM ITF_TRAN_MINORISTA_PRESENTADAS_AUX WHERE LINEA LIKE ''6%'' AND id>(SELECT max(id) FROM ITF_TRAN_MINORISTA_PRESENTADAS_AUX WHERE LINEA LIKE ''1%'')), ''.'', ''''))),12);
			SET @FA_SUMA_TOTAL_CREDITOS = RIGHT(concat(replicate(''0'', 20), (replace((SELECT sum(convert(bigint, substring(linea,26,14))) FROM ITF_TRAN_MINORISTA_PRESENTADAS_AUX WHERE LINEA LIKE ''6%'' AND id>(SELECT max(id) FROM ITF_TRAN_MINORISTA_PRESENTADAS_AUX WHERE LINEA LIKE ''1%'')), ''.'', ''''))),20);
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

			SET @CL_CRITERIO_EMPRESA = replicate('' '', 20); -- AUN NO EXISTE AUTONUMERICO, FALTA DEFINIR 		
		


			IF (@t_ord_tipo_doc NOT IN (SELECT tipodocumento FROM CLI_TIPOSDOCUMENTOS WHERE TIPOPERSONA=''F'') AND @CL_RESERVADO_CL not in (''00C'',''00D'',''003'',''008'')) OR @CL_RESERVADO_CL in (''002'',''007'') 
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
   				--SET @FL_SUMA_TOTAL_DEBITO_LOTE = RIGHT(replicate(''0'', 12), 12); 
				SET @FL_SUMA_TOTAL_DEBITO_LOTE = RIGHT(replicate(''0'', 20), 20); 
   				--SET @FL_SUMA_TOTAL_CREDITO_LOTE = RIGHT(concat(replicate(''0'', 12), (replace(@SumaImportes, ''.'', ''''))), 12); 
   				SET @FL_SUMA_TOTAL_CREDITO_LOTE = RIGHT(concat(replicate(''0'', 20), (replace(@SumaImportes, ''.'', ''''))), 20); 
   				SET @TotalesCreditos += @SumaImportes;
   				SET @FL_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 6), @Cant_Reg_Individual_Adicional), 6); 
   	
   				SET @FL_TOTALES_DE_CONTROL =RIGHT(concat(replicate(''0'', 10), (SELECT sum(convert(numeric,substring(t.LINEA,4,8)))
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

				INSERT INTO dbo.ITF_TRAN_MINORISTA_PRESENTADAS_AUX (LINEA) VALUES (@FL_FIN_LOTE);
	
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
	
IF (@t_ord_tipo_doc NOT IN (SELECT tipodocumento FROM CLI_TIPOSDOCUMENTOS WHERE TIPOPERSONA=''F'') AND @CL_RESERVADO_CL not in (''00C'',''00D'',''003'',''008'')) OR @CL_RESERVADO_CL in (''002'',''007'') 
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
		--IF	(@T_IMPORTE>99999999.99)
		IF	(@T_IMPORTE>999999999999.99)
		BEGIN
			--SET @Excedente = (@T_IMPORTE - 99999999.99);
			--SET @T_IMPORTE = 99999999.99;
			SET @Excedente = (@T_IMPORTE - 999999999999.99);
			SET @T_IMPORTE = 999999999999.99;
			SET @CountExcedente += 1;
		END
		ELSE
    	BEGIN
       		SET @Excedente = 0;
    	END
	
		---------------------------- Grabar Registro Individual -----------------------------------------------------------------------------------------------------------------------------------------
		IF @t_estado=''RC''
			SET @RI_ENTIDAD_CREDITO = @RI_ENTIDAD_CREDITO_RE;
		ELSE 
			SET @RI_ENTIDAD_CREDITO = RIGHT(concat(replicate(''0'', 8), LEFT(@T_ben_cbu,7)),8);


    	SET @RI_REFERENCIA_UNIVOCA = RIGHT(concat(replicate(''0'', 15), @T_REFERENCIA), 15);
    
    	IF (@t_ben_mismo_titular=''S'') 
    		SET @num_id=''074''
    	IF (@t_ben_mismo_titular=''N'')
    		SET @num_id=''073''
    	IF(@T_TIPO_DOC =''CUIT'')
    		SET @RI_CLIENTE_PAGADOR = CONCAT(''1'',RIGHT(concat(replicate(''0'',11),@T_CUIT_BEN),11),''       '',@num_id);
    	IF(@T_TIPO_DOC =''CUIL'')
    		SET @RI_CLIENTE_PAGADOR = CONCAT(''2'',RIGHT(concat(replicate(''0'',11),@T_CUIT_BEN),11),''       '',@num_id);
    	IF(@T_TIPO_DOC =''CDI'')
    		SET @RI_CLIENTE_PAGADOR = CONCAT(''3'',RIGHT(concat(replicate(''0'',11),@T_CUIT_BEN),11),''       '',@num_id);
    
		SET @T_CODIGO_TRANSACCION = ''32'';
	
    	IF(@CountExcedente>1)
		BEGIN
        	SET @SumaSucursal += 0888;  --sumo la sucursal que hay que harcodear
        	SET @SumaEntidad +=  @T_COD_BANCO;
        	SET @SumaImportes += @T_IMPORTE;

        	SET @RI_ENTIDAD_CREDITO = concat(replicate(''0'', 4), @T_COD_BANCO, ''0888'');
        	--SET @RI_CUENTA_CREDITO = RIGHT(concat(replicate(''0'', 17), ''88888888888''), 17);
			SET @RI_CUENTA_CREDITO = RIGHT(concat(replicate(''0'', 14), ''88888888888''), 14);
        	SET @RI_REFERENCIA_UNIVOCA = ''000088888888888'';

   
   		END
    	ELSE --la razon de este else, es que SumaSucursal, cuando hay excedente tiene que acumular 0888
    	BEGIN
        	SET @SumaSucursal += @T_SUCURSAL;
			SET @SumaEntidad += @T_COD_BANCO;
			SET @SumaImportes += @T_IMPORTE;

			SET @RI_ENTIDAD_CREDITO = CONCAT(RIGHT(concat(replicate(''0'', 4), @T_COD_BANCO),4) , RIGHT(concat(replicate(''0'', 4), @T_SUCURSAL),4));
    		SET @RI_REFERENCIA_UNIVOCA =  CONCAT(@t_op_referencia,RIGHT(concat(replicate(''0'', 12), @T_REFERENCIA), 12));
    
    		IF (@t_ben_mismo_titular=''S'') 
    			SET @num_id=''074''
    		IF (@t_ben_mismo_titular=''N'')
    			SET @num_id=''073''
    		IF(@T_TIPO_DOC =''CUIT'')
    			SET @RI_CLIENTE_PAGADOR = CONCAT(''1'',RIGHT(concat(replicate(''0'',11),@T_CUIT_BEN),11),''       '',@num_id);
    		IF(@T_TIPO_DOC =''CUIL'')
    			SET @RI_CLIENTE_PAGADOR = CONCAT(''2'',RIGHT(concat(replicate(''0'',11),@T_CUIT_BEN),11),''       '',@num_id);
    		IF(@T_TIPO_DOC =''CDI'')
    			SET @RI_CLIENTE_PAGADOR = CONCAT(''3'',RIGHT(concat(replicate(''0'',11),@T_CUIT_BEN),11),''       '',@num_id);
 
    	END

		--IF @SumaImportes>9999999999.99 GOTO Start
		IF @SumaImportes>999999999999999999.99 GOTO Start
		
    	--SET @RI_IMPORTE = RIGHT(concat(replicate(''0'', 10), replace(CAST(@T_IMPORTE AS VARCHAR),''.'','''')), 10);
		SET @RI_IMPORTE = RIGHT(concat(replicate(''0'', 14), replace(CAST(@T_IMPORTE AS VARCHAR),''.'','''')), 14);

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

     		IF @t_estado=''RC''
			SET @RI_ENTIDAD_CREDITO = @RI_ENTIDAD_CREDITO_RE;
		ELSE 
			SET @RI_ENTIDAD_CREDITO = RIGHT(concat(replicate(''0'', 8), LEFT(@T_ben_cbu,7)),8);

	 	--SET @RI_CUENTA_CREDITO = RIGHT(concat(replicate(''0'', 17), right(@T_ben_cbu,14)),17);	
		SET @RI_CUENTA_CREDITO = RIGHT(concat(replicate(''0'', 14), right(@T_ben_cbu,14)),14);
        	
		--SET @RI_REGISTRO_INDIVIDUAL = concat(@RI_ID_REG, @T_CODIGO_TRANSACCION, @RI_ENTIDAD_CREDITO, @RI_RESERVADO, @RI_CUENTA_CREDITO, @RI_IMPORTE, @RI_REFERENCIA_UNIVOCA, @RI_CLIENTE_PAGADOR, @RI_INFO_ADICIONAL, @RI_REGISTRO_ADICIONAL, @RI_CONTADOR_REGISTRO);
 
 		SET @RI_REGISTRO_INDIVIDUAL = concat(@RI_ID_REG, @T_CODIGO_TRANSACCION, @RI_ENTIDAD_CREDITO, @RI_CUENTA_CREDITO, @RI_IMPORTE, @RI_REFERENCIA_UNIVOCA, @RI_CLIENTE_PAGADOR, @RI_INFO_ADICIONAL, @RI_REGISTRO_ADICIONAL, @RI_CONTADOR_REGISTRO);

    	INSERT INTO dbo.ITF_TRAN_MINORISTA_PRESENTADAS_AUX (LINEA, CORRELATIVO) VALUES (@RI_REGISTRO_INDIVIDUAL,@T_ID_CREDITO);
    	 
    	IF @t_estado=''RC''
    	BEGIN
    		UPDATE dbo.VTA_TRANSFERENCIAS
    		SET ESTADO=@nuevo_estado 
    			, FCH_DEV_REC=@T_FECHA_PRESENTACION
    		WHERE OP_NUMERO=@T_REFERENCIA
			AND OP_CLASE_TRANS=''R'';
    	END 
    	ELSE
    	BEGIN
    		UPDATE dbo.VTA_TRANSFERENCIAS
    		SET ESTADO=@nuevo_estado 
    			, TRACENUMBER=@RI_CONTADOR_REGISTRO
    			, Fecha_estado=@T_FECHA_PRESENTACION
    		WHERE OP_NUMERO=@T_REFERENCIA
			AND OP_CLASE_TRANS=''E'';
    	END 
    
    	SET @RO_NUM_SECUENCIA_ADICIONAL= ''0'';
	-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		/* Logica para agregar el registro adicional*/	
		IF(@CountExcedente<1) 
		BEGIN
	
			SET @RA_FECHA_PRESENTACION=convert(VARCHAR,@T_FECHA_PRESENTACION, 12);
			IF @T_FECHA_PRESENTACION IS NULL 
				SET @RA_FECHA_PRESENTACION=REPLICATE(''0'',6)
			SET @RA_ENTIDAD=@RI_ENTIDAD_CREDITO
			SET @RA_CONTADOR=RIGHT(CONCAT(REPLICATE(''0'',15),CONVERT(VARCHAR, @T_TRACENUMBER)),15)
			SET @RA_RECHAZO=(SELECT codigo_nacha FROM SNP_MOTIVOS_RECHAZO WHERE id_motivo=@T_MOTIVO_RECHAZO AND TZ_LOCK=0);
	
			SET @RO_CONCEPTO = LEFT(CONCAT(@T_CUIT_ORD, @T_NOMBRE_ORDENANTE, REPLICATE('' '',80)),80);
			SET @RO_NUM_SECUENCIA_ADICIONAL= RIGHT(concat(replicate(''0'', 4), (@RO_NUM_SECUENCIA_ADICIONAL + 1)), 4);

			IF @T_MOTIVO_RECHAZO=0
				SET @RI_REGISTRO_INDIVIDUAL = concat(''705'',@RO_CONCEPTO,@RO_NUM_SECUENCIA_ADICIONAL,RIGHT(concat(replicate(''0'', 7), (SELECT NUMERICO_1 FROM ITF_MASTER_PARAMETROS WHERE CODIGO = 149)), 7));
			ELSE 
				SET @RI_REGISTRO_INDIVIDUAL = concat(''705'',@RA_FECHA_PRESENTACION,@RA_ENTIDAD,@RA_CONTADOR,@RA_RECHAZO,REPLICATE('' '',48),@RO_NUM_SECUENCIA_ADICIONAL,RIGHT(concat(replicate(''0'', 7), (SELECT NUMERICO_1 FROM ITF_MASTER_PARAMETROS WHERE CODIGO = 149)), 7));


			INSERT INTO dbo.ITF_TRAN_MINORISTA_PRESENTADAS_AUX (LINEA) VALUES (@RI_REGISTRO_INDIVIDUAL);
		END  


		----------------------------- Actualizar secuencial unico -------------------------------------
		UPDATE dbo.ITF_MASTER_PARAMETROS SET NUMERICO_1 = (NUMERICO_1 + 1) WHERE CODIGO = 149;
		-----------------------------------------------------------------------------------------------

	
		IF (@Excedente = 0)
		BEGIN		     	       				
	
			FETCH NEXT FROM CursorTM INTO @T_ID_CREDITO, 
								  @T_MONEDA, 
								  @T_IMPORTE, 
								  @T_FECHA_VTO,
								  @T_FECHA_COMP,
								  @T_CBU, 
								  @T_REFERENCIA, 
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
								  , @t_estado
								, @T_FECHA_PRESENTACION
							    , @T_TRACENUMBER
							    , @T_MOTIVO_RECHAZO
								, @RI_ENTIDAD_CREDITO_RE 
	
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
	--SET @FL_SUMA_TOTAL_DEBITO_LOTE =  RIGHT(replicate(''0'', 12), 12);
	SET @FL_SUMA_TOTAL_DEBITO_LOTE =  RIGHT(replicate(''0'', 20), 20);
	--SET @FL_SUMA_TOTAL_CREDITO_LOTE = RIGHT(concat(replicate(''0'', 12), (replace((SELECT sum(convert(bigint, substring(linea,30,10))) FROM ITF_TRAN_MINORISTA_PRESENTADAS_AUX WHERE LINEA LIKE ''6%'' AND id>(SELECT max(id) FROM ITF_TRAN_MINORISTA_PRESENTADAS_AUX WHERE LINEA LIKE ''5%'')), ''.'', ''''))), 12);
	SET @FL_SUMA_TOTAL_CREDITO_LOTE = RIGHT(concat(replicate(''0'', 20), (replace((SELECT sum(convert(bigint, substring(linea,26,14))) FROM ITF_TRAN_MINORISTA_PRESENTADAS_AUX WHERE LINEA LIKE ''6%'' AND id>(SELECT max(id) FROM ITF_TRAN_MINORISTA_PRESENTADAS_AUX WHERE LINEA LIKE ''5%'')), ''.'', ''''))), 20);
	SET @TotalesCreditos += @SumaImportes;
	SET @FL_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 6), @Cant_Reg_Individual_Adicional), 6); 
	SET @FL_TOTALES_DE_CONTROL =RIGHT(concat(replicate(''0'', 10), (SELECT sum(convert(INT,substring(t.LINEA,4,8))) FROM ITF_TRAN_MINORISTA_PRESENTADAS_AUX t WHERE t.ID>(SELECT max(tt.id) FROM ITF_TRAN_MINORISTA_PRESENTADAS_AUX tt WHERE tt.LINEA LIKE ''5%'') AND substring(t.LINEA,1,1) IN (''6''))), 10);
	
	SET @FL_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 6), (SELECT count(id) 
																			 FROM ITF_TRAN_MINORISTA_PRESENTADAS_AUX t
																			 WHERE t.ID>(SELECT max(tt.id) 
		  																				 FROM ITF_TRAN_MINORISTA_PRESENTADAS_AUX tt
		  																				 WHERE tt.LINEA LIKE ''5%'')	
																			 AND substring(t.LINEA,1,1) IN (''6'',''7''))), 6);
	SET @FL_RESERVADO1=@CL_ID_EMPRESA;
	SET @FL_NUMERO_LOTE=@CL_NUMERO_LOTE
	
	SET @FL_FIN_LOTE = concat(@FL_ID_REG, @FL_CODIGO_CLASE_TRANSAC, @FL_CANT_REG_INDIVIDUAL_ADICIONAL, @FL_TOTALES_DE_CONTROL, @FL_SUMA_TOTAL_DEBITO_LOTE, @FL_SUMA_TOTAL_CREDITO_LOTE, @FL_RESERVADO1, @FL_RESERVADO2, @FL_RESERVADO3, @FL_REG_ENTIDAD_ORIGEN, @FL_NUMERO_LOTE);
			
	INSERT INTO dbo.ITF_TRAN_MINORISTA_PRESENTADAS_AUX (LINEA) VALUES (@FL_FIN_LOTE);
	
	SET @FL_NUMERO_LOTE = CAST(@FL_NUMERO_LOTE AS NUMERIC) + 1;
	SET @FL_NUMERO_LOTE = RIGHT(concat(replicate(''0'', 7), @FL_NUMERO_LOTE), 7);

	---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-------------Grabamos el Fin de Archivo ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	SET @FA_CANT_LOTES = RIGHT(concat(replicate(''0'', 6), @FL_NUMERO_LOTE), 6);
	SET @CantRegistrosPrev = (SELECT (CASE WHEN (@CantRegistros + 4) % 10 = 0 THEN ((@CantRegistros + 4)/10) ELSE (FLOOR((@CantRegistros + 4)/10) + 1) END));
	
	
	SET @FA_NUMERO_BLOQUES = RIGHT(concat(replicate(''0'', 6), (SELECT CEILING((count(*)+1) / CONVERT(FLOAT, 10))
																  FROM ITF_TRAN_MINORISTA_PRESENTADAS_AUX 
																  WHERE  ID>=(SELECT max(id) 
																  		  		FROM ITF_TRAN_MINORISTA_PRESENTADAS_AUX 
																  		  		WHERE LINEA LIKE ''1%''))), 6);
	
	SET @FA_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 8), @CantRegistros), 8);
	SET @FA_TOTALES_DE_CONTROL = @FL_TOTALES_DE_CONTROL; --igualo al totales de control de fin de lote pq tiene que ser igual
	--SET @FA_SUMA_TOTAL_DEBITOS = RIGHT(concat(replicate(''0'', 12), (replace(@TotalesDebitos, ''.'', ''''))), 12);
	SET @FA_SUMA_TOTAL_DEBITOS = RIGHT(concat(replicate(''0'', 20), (replace(@TotalesDebitos, ''.'', ''''))), 20);
	--SET @FA_SUMA_TOTAL_CREDITOS = RIGHT(concat(replicate(''0'', 12), (replace((SELECT sum(convert(bigint, substring(linea,30,10))) FROM ITF_TRAN_MINORISTA_PRESENTADAS_AUX WHERE LINEA LIKE ''6%'' AND id>(SELECT max(id) FROM ITF_TRAN_MINORISTA_PRESENTADAS_AUX WHERE LINEA LIKE ''1%'')), ''.'', ''''))),12);	
	SET @FA_SUMA_TOTAL_CREDITOS = RIGHT(concat(replicate(''0'', 20), (replace((SELECT sum(convert(bigint, substring(linea,26,14))) FROM ITF_TRAN_MINORISTA_PRESENTADAS_AUX WHERE LINEA LIKE ''6%'' AND id>(SELECT max(id) FROM ITF_TRAN_MINORISTA_PRESENTADAS_AUX WHERE LINEA LIKE ''1%'')), ''.'', ''''))),20);	
	
	SET @FA_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 8), (SELECT count(id) 
																			 FROM ITF_TRAN_MINORISTA_PRESENTADAS_AUX 
																			 WHERE (LINEA LIKE ''6%'' OR LINEA LIKE ''7%'')
																			 AND id>(SELECT max(id) FROM ITF_TRAN_MINORISTA_PRESENTADAS_AUX WHERE LINEA LIKE ''1%''))), 8);
	
	SET @FA_TOTALES_DE_CONTROL =RIGHT(concat(replicate(''0'', 10), (SELECT sum(convert(numeric,substring(LINEA,4,8)))
																 FROM ITF_TRAN_MINORISTA_PRESENTADAS_AUX
														  		 WHERE LINEA LIKE ''6%'' AND ID >(SELECT max(tt.id) 
		  																  FROM ITF_TRAN_MINORISTA_PRESENTADAS_AUX tt
		  																  WHERE tt.LINEA LIKE ''1%''))), 10);
	
	
	SET @FA_CANT_LOTES = RIGHT(concat(replicate(''0'', 6), (SELECT count(ID) FROM ITF_TRAN_MINORISTA_PRESENTADAS_AUX WHERE LINEA LIKE ''5%'' AND id>(SELECT max(id) FROM ITF_TRAN_MINORISTA_PRESENTADAS_AUX WHERE LINEA LIKE ''1%''))), 6);
	SET @FA_FIN_ARCHIVO = concat(@FA_ID_REG, @FA_CANT_LOTES, @FA_NUMERO_BLOQUES, @FA_CANT_REG_INDIVIDUAL_ADICIONAL, @FA_TOTALES_DE_CONTROL, @FA_SUMA_TOTAL_DEBITOS, @FA_SUMA_TOTAL_CREDITOS, @FA_RESERVADO);
			
	INSERT INTO dbo.ITF_TRAN_MINORISTA_PRESENTADAS_AUX (LINEA,correlativo) VALUES (@FA_FIN_ARCHIVO,1);
	------------------------------------------------------------------------------------------------------------------------------------------------------------------

END
'); 

EXECUTE('CREATE OR ALTER PROCEDURE [dbo].[SP_TRAN_SUELDOS_PRESENTADAS_V2]
   @TICKET NUMERIC(16)
AS 
BEGIN


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
	DECLARE @CA_CODIGO_REFERENCIA VARCHAR(8) = ''SUE    0''; --Se conforma con espacios vacíos.

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
	DECLARE @CL_FECHA_VENCIMIENTO VARCHAR(6) = convert(VARCHAR,(SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)), 12); 
	DECLARE @CL_RESERVADO_CL VARCHAR(3) = ''000''; -- fijo
	DECLARE @CL_CODIGO_ORIGEN VARCHAR(1) = ''0''; -- fijo
	DECLARE @CL_ID_ENTIDAD_ORIGEN VARCHAR(8) = (SELECT ''031100''+CAST((SELECT NUMERICO FROM PARAMETROSGENERALES WHERE CODIGO=40) AS VARCHAR)); 
	DECLARE @CL_NUMERO_LOTE VARCHAR(7) = RIGHT(concat(replicate(''0'', 7), 0), 7); -- numero del lote
	
	DECLARE @CL_CABECERA VARCHAR(200);
	DECLARE @t_ord_tipo_doc VARCHAR(4);

	---------------- Grabar Cabecera Archivo ---------------------------
	INSERT INTO dbo.ITF_TRAN_SUELDOS_PRESENTADAS_AUX (LINEA) VALUES (@CA_CABECERA);
	--------------------------------------------------------------------

	------ Variables registro individual ( RI) ------------
	DECLARE @RI_ID_REG VARCHAR(1) = ''6''; -- fijo  
	DECLARE @RI_ENTIDAD_CREDITO VARCHAR(8);
	DECLARE @RI_ENTIDAD_CREDITO_RE VARCHAR(8);
	DECLARE @t_estado VARCHAR(2);
	--DECLARE @RI_RESERVADO VARCHAR(1) = ''0''; -- fijo 
	--DECLARE @RI_CUENTA_CREDITO VARCHAR(17);
	DECLARE @RI_CUENTA_CREDITO VARCHAR(14);
	--DECLARE @RI_IMPORTE VARCHAR(11); 
	DECLARE @RI_IMPORTE VARCHAR(14);
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
	DECLARE @operatoria_bcra VARCHAR(3)=''000'';  
	DECLARE @t_ben_banco NUMERIC(6);
	DECLARE @ben_banco NUMERIC(6)=0;
	DECLARE @t_op_tipo NUMERIC(3);
	DECLARE @op_tipo NUMERIC(3)=0;
	DECLARE @T_FECHA_PRESENTACION DATETIME;
	DECLARE @T_TRACENUMBER NUMERIC(15,0)
	DECLARE @T_MOTIVO_RECHAZO NUMERIC(3,0)


	------ Variables registro ajuste ( RA) ------------

	DECLARE @RA_ID_REG_ADICIONAL VARCHAR(6) = ''705'';
	DECLARE @RA_FECHA_PRESENTACION VARCHAR(6);
	DECLARE @RA_ENTIDAD VARCHAR(8);
	DECLARE @RA_CONTADOR VARCHAR(15);
	DECLARE @RA_RECHAZO VARCHAR(3);
	
	DECLARE @RA_CONTADOR_REGISTRO_ORIGEN VARCHAR(15);
	DECLARE @RA_NUMERO_CERTIFIFADO VARCHAR(6) = ''      '';
	DECLARE @RA_ENTIDAD_ORIGINAL VARCHAR(8) = ''        '';
	DECLARE @RA_OTRO_MOTIVO_RECH VARCHAR(44) = ''                                             '';

	--- Variables fin de lote FL
	DECLARE @FL_ID_REG VARCHAR(1) = ''8''; -- fijo 
	DECLARE @FL_CODIGO_CLASE_TRANSAC VARCHAR(3) = ''220''; -- fijo 
	DECLARE @FL_CANT_REG_INDIVIDUAL_ADICIONAL VARCHAR(6) = 0; --registros individuales y adicionales que existen en el lote
	DECLARE @FL_TOTALES_DE_CONTROL VARCHAR(10) = 0;
	--DECLARE @FL_SUMA_TOTAL_DEBITO_LOTE VARCHAR(12); 
	--DECLARE @FL_SUMA_TOTAL_CREDITO_LOTE VARCHAR(12); 
	DECLARE @FL_SUMA_TOTAL_DEBITO_LOTE VARCHAR(20); 
	DECLARE @FL_SUMA_TOTAL_CREDITO_LOTE VARCHAR(20); 
	DECLARE @FL_RESERVADO1 VARCHAR(10) = ''          ''; -- fijo
	--DECLARE @FL_RESERVADO2 VARCHAR(19) = ''                   ''; -- fijo
	DECLARE @FL_RESERVADO2 VARCHAR(3) = ''   ''; -- fijo
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
	--DECLARE @FA_SUMA_TOTAL_DEBITOS VARCHAR(12);
	--DECLARE @FA_SUMA_TOTAL_CREDITOS VARCHAR(12);
	DECLARE @FA_SUMA_TOTAL_DEBITOS VARCHAR(20);
	DECLARE @FA_SUMA_TOTAL_CREDITOS VARCHAR(20);
	DECLARE @FA_RESERVADO  VARCHAR(100) =  concat(replicate('' '', 22),''0''); -- fijo

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

	IF((SELECT COUNT(1) 
		FROM VTA_TRANSFERENCIAS t 
		LEFT JOIN vta_transferencias_tipos tt ON t.OP_TIPO=tt.ID_TIPO
		WHERE ((t.OP_CLASE_TRANS=''R'' AND t.ESTADO=''RC'') OR (t.OP_CLASE_TRANS=''E'' AND t.ESTADO=''PP'')) 
		AND t.OP_MONEDA=1 
		AND t.TZ_LOCK=0
		AND TT.TZ_LOCK=0
		AND tt.TIPO_PROCESO LIKE ''S%'')=0)

	BEGIN
		---------------- Grabar Cabecera Lote ---------------------------
		SET @CL_NUMERO_LOTE = RIGHT(concat(replicate(''0'', 7), (@CL_NUMERO_LOTE + 1)), 7);
		SET @CL_NOM_EMPRESA =  LEFT(concat('''',replicate('' '', 16)),16);
		SET @CL_CRITERIO_EMPRESA = replicate('' '', 20); -- AUN NO EXISTE AUTONUMERICO, FALTA DEFINIR 
		SET @CL_ID_EMPRESA = LEFT(concat(@T_CUIT_ORD,replicate(''0'', 10)),10);
		SET @CL_CABECERA = concat(@CL_ID_REG
									, @CL_CODIGO_CLASE_TRANSAC
									, @CL_NOM_EMPRESA
									, @CL_CRITERIO_EMPRESA
									, @CL_ID_EMPRESA
									, @CL_TIPO_REGISTRO
									, @CL_DESCRIP_TRANSAC
									, @CL_FECHA_PRESENTACION
									, @CL_FECHA_VENCIMIENTO
									, @CL_RESERVADO_CL
									, @CL_CODIGO_ORIGEN
									, @CL_ID_ENTIDAD_ORIGEN
									, @CL_NUMERO_LOTE);
		INSERT INTO dbo.ITF_TRAN_SUELDOS_PRESENTADAS_AUX (LINEA) VALUES (@CL_CABECERA);
	END 
		
    --Condicion de reset del contador de reg individual
	IF ISNULL((SELECT a.FECHA FROM ITF_MASTER_PARAMETROS a WHERE a.CODIGO = 179), CAST(''01-01-1800'' AS DATETIME)) <> (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK))
    	UPDATE dbo.ITF_MASTER_PARAMETROS SET NUMERICO_1 = 1, FECHA = (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)) WHERE CODIGO = 179;

	SET @T_FECHA_COMP = (SELECT CONVERT(DATETIME, dbo.diaHabil ((SELECT (FECHAPROCESO + 1) FROM PARAMETROS WITH(NOLOCK)),''A'')) AS A);
	SET @T_FECHA_VTO =  @T_FECHA_COMP;

	DECLARE CursorTM CURSOR FOR

	SELECT t.OP_NUMERO
			, t.OP_MONEDA
			, t.OP_IMPORTE
			, @T_FECHA_VTO
			, @T_FECHA_COMP
			, t.ORD_CBU
			, t.OP_NUMERO
			, t.ORD_NRO_DOC
			, t.ORD_NOMBRE
			, t.BEN_NRO_DOC
			, t.BEN_NOMBRE
			, t.BEN_TIPO_DOC
			, t.OP_CLASE_TRANS
			, t.ORD_TIPO_DOC
	    	, t.OP_REFERENCIA
	    	, t.BEN_CBU
	    	, t.BEN_MISMO_TITULAR
	    	, t.BEN_BANCO
	    	, t.OP_TIPO
	    	, T.operatoria_bcra
	    	, CASE WHEN t.ESTADO=''PP'' THEN TT.ADICIONAL_PRESENT ELSE TT.ADICIONAL_devol end
	    	, T.OP_FECHA_PRES
	    	, T.TRACENUMBER
	    	, T.MOTIVO_RECHAZO
			, RIGHT(''0000'' + CAST(t.ORD_BANCO AS VARCHAR(4)), 4) + 
  RIGHT(''0000'' + CAST(t.ORD_SUCURSAL AS VARCHAR(4)), 4) AS RI_ENTIDAD_CREDITO_RE
            , T.ESTADO

	FROM VTA_TRANSFERENCIAS t 
	LEFT JOIN vta_transferencias_tipos tt ON t.OP_TIPO=tt.ID_TIPO
	WHERE ((t.OP_CLASE_TRANS=''R'' AND t.ESTADO=''RC'') OR (t.OP_CLASE_TRANS=''E'' AND t.ESTADO=''PP'')) 
	AND t.OP_MONEDA=1 
	AND t.TZ_LOCK=0
	AND TT.TZ_LOCK=0	
	AND tt.TIPO_PROCESO LIKE ''S%''
	ORDER BY t.ORD_NRO_DOC, t.OP_MONEDA
	
	OPEN CursorTM
	FETCH NEXT FROM CursorTM INTO @T_ID_CREDITO
								, @T_MONEDA
								, @T_IMPORTE
								, @T_FECHA_VTO
								, @T_FECHA_COMP
								, @T_CBU
								, @T_REFERENCIA
								, @T_CUIT_ORD
								, @T_NOMBRE_ORDENANTE
								, @T_CUIT_BEN
								, @T_NOMBRE_BENEFICIARIO
								, @T_TIPO_DOC
								, @T_CLASE
							    , @t_ord_tipo_doc
							    , @t_op_referencia
							    , @t_ben_cbu
							    , @t_ben_mismo_titular
							    , @t_ben_banco
							    , @t_op_tipo 
							    , @operatoria_bcra
							    , @t_ADICIONAL_PRESENT
							    , @T_FECHA_PRESENTACION
							    , @T_TRACENUMBER
							    , @T_MOTIVO_RECHAZO
								, @RI_ENTIDAD_CREDITO_RE
								, @t_estado

	
	WHILE @@FETCH_STATUS = 0
	BEGIN

		Start:

		SET @t_op_referencia=RIGHT(concat(replicate('' '',3),@t_op_referencia),3)
		SET @CL_RESERVADO_CL=RIGHT(concat(''000'',@t_ADICIONAL_PRESENT),3)
		SET @CL_NOM_EMPRESA =  LEFT(concat(''PARTICULARES'',replicate('' '', 16)),16);
		SET @RI_INFO_ADICIONAL= RIGHT(concat(replicate(''0'',4),@t_ADICIONAL_PRESENT),2);
	
		--IF (@SumaImportes > 9999999999.99 OR @SumaEntidad > 999999) -- 99 millones
		IF (@SumaImportes > 999999999999.99 OR @SumaEntidad > 999999) -- 99 mil  millones
		BEGIN
		
			IF @SumaSucursal > 9999
			BEGIN
				SET @SobranteSucursal = CAST(substring(CAST(@SumaSucursal AS VARCHAR), 1, (len(@SumaSucursal) - 4)) AS NUMERIC);
				SET @SumaEntidad += @SobranteSucursal;
				SET @SumaSucursal = CAST(RIGHT(@SumaSucursal, 4) AS NUMERIC);
			END
		

	   		SET @FL_TOTALES_DE_CONTROL = concat((RIGHT(concat(replicate(''0'', 6), @SumaEntidad), 6)), (RIGHT(concat(replicate(''0'', 4), @SumaSucursal), 4)));
	   		--SET @FL_SUMA_TOTAL_DEBITO_LOTE = RIGHT(replicate(''0'', 12), 12);
			SET @FL_SUMA_TOTAL_DEBITO_LOTE = RIGHT(replicate(''0'', 20), 20);
	   		--SET @FL_SUMA_TOTAL_CREDITO_LOTE = RIGHT(concat(replicate(''0'', 12), (replace((SELECT sum(convert(bigint, substring(linea,30,10))) FROM ITF_TRAN_SUELDOS_PRESENTADAS_AUX WHERE LINEA LIKE ''6%'' AND id>(SELECT max(id) FROM ITF_TRAN_SUELDOS_PRESENTADAS_AUX WHERE LINEA LIKE ''5%'')), ''.'', ''''))), 12);
 	   		SET @FL_SUMA_TOTAL_CREDITO_LOTE = RIGHT(concat(replicate(''0'', 20), (replace((SELECT sum(convert(bigint, substring(linea,26,14))) FROM ITF_TRAN_SUELDOS_PRESENTADAS_AUX WHERE LINEA LIKE ''6%'' AND id>(SELECT max(id) FROM ITF_TRAN_SUELDOS_PRESENTADAS_AUX WHERE LINEA LIKE ''5%'')), ''.'', ''''))), 20);

	   		SET @TotalesCreditos += @SumaImportes;
	   		SET @FL_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 6), @Cant_Reg_Individual_Adicional), 6); 
	   	
	   		SET @FL_FIN_LOTE = concat(@FL_ID_REG, @FL_CODIGO_CLASE_TRANSAC, @FL_CANT_REG_INDIVIDUAL_ADICIONAL, @FL_TOTALES_DE_CONTROL, @FL_SUMA_TOTAL_DEBITO_LOTE, @FL_SUMA_TOTAL_CREDITO_LOTE, @FL_RESERVADO1, @FL_RESERVADO2, @FL_RESERVADO3, @FL_REG_ENTIDAD_ORIGEN, @FL_NUMERO_LOTE);
		
    
	
			INSERT INTO dbo.ITF_TRAN_SUELDOS_PRESENTADAS_AUX (LINEA) VALUES (@FL_FIN_LOTE);
		
			SET @FL_NUMERO_LOTE = CAST(@FL_NUMERO_LOTE AS NUMERIC) + 1;
			SET @FL_NUMERO_LOTE = RIGHT(concat(replicate(''0'', 7), @FL_NUMERO_LOTE), 7);
			SET @CL_NUMERO_LOTE = RIGHT(concat(replicate(''0'', 7), (0)), 7);
			-------------------------------------------------------------------
			-------------Grabamos el Fin de Archivo ----------------------------------------------------------------------------------------------------------------------
			SET @FA_CANT_LOTES = RIGHT(concat(replicate(''0'', 6), @FL_NUMERO_LOTE), 6);
			SET @CantRegistrosPrev = (SELECT (CASE WHEN (@CantRegistros + 4) % 10 = 0 THEN ((@CantRegistros + 4)/10) ELSE (FLOOR((@CantRegistros + 4)/10) + 1) END));
		
		
		 	SET @FA_NUMERO_BLOQUES = RIGHT(concat(replicate(''0'', 6), (SELECT CEILING((count(*)+1) / CONVERT(FLOAT, 10))
																  	FROM ITF_TRAN_SUELDOS_PRESENTADAS_AUX 
																  	WHERE  ID>=(SELECT max(id) 
																  		  		FROM ITF_TRAN_SUELDOS_PRESENTADAS_AUX 
																  		  		WHERE LINEA LIKE ''1%''))), 6)
	
	

			SET @FA_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 8), @CantRegistros), 8);		
			SET @FA_TOTALES_DE_CONTROL = @FL_TOTALES_DE_CONTROL; --igualo al totales de control de fin de lote pq tiene que ser igual	
			--SET @FA_SUMA_TOTAL_DEBITOS = RIGHT(concat(replicate(''0'', 12), (replace(@TotalesDebitos, ''.'', ''''))), 12);
			SET @FA_SUMA_TOTAL_DEBITOS = RIGHT(concat(replicate(''0'', 20), (replace(@TotalesDebitos, ''.'', ''''))), 20);	
			--SET @FA_SUMA_TOTAL_CREDITOS = RIGHT(concat(replicate(''0'', 12), (replace((SELECT sum(convert(bigint, substring(linea,30,10))) FROM ITF_TRAN_SUELDOS_PRESENTADAS_AUX WHERE LINEA LIKE ''6%'' AND id>(SELECT max(id) FROM ITF_TRAN_SUELDOS_PRESENTADAS_AUX WHERE LINEA LIKE ''1%'')), ''.'', ''''))),12);
			SET @FA_SUMA_TOTAL_CREDITOS = RIGHT(concat(replicate(''0'', 20), (replace((SELECT sum(convert(bigint, substring(linea,26,14))) FROM ITF_TRAN_SUELDOS_PRESENTADAS_AUX WHERE LINEA LIKE ''6%'' AND id>(SELECT max(id) FROM ITF_TRAN_SUELDOS_PRESENTADAS_AUX WHERE LINEA LIKE ''1%'')), ''.'', ''''))),20);

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
			SET @ben_banco=@t_ben_banco;
			SET @op_tipo=@t_op_tipo;
			SET @CL_ID_EMPRESA = replicate(''0'', 10)
			SET @CL_NUMERO_LOTE = RIGHT(concat(replicate(''0'', 7), (@CL_NUMERO_LOTE + 1)), 7);			

			SET @CL_CRITERIO_EMPRESA = replicate('' '', 20); -- AUN NO EXISTE AUTONUMERICO, FALTA DEFINIR 		
		

			IF @t_ord_tipo_doc NOT IN (SELECT tipodocumento FROM CLI_TIPOSDOCUMENTOS WHERE TIPOPERSONA=''F'') 
			BEGIN
				SET @CL_NOM_EMPRESA =  LEFT(concat(@T_NOMBRE_ORDENANTE,replicate('' '', 16)),16);
				SET @CL_ID_EMPRESA = right(concat(replicate(''0'', 10),LEFT(@T_CUIT_ORD,10)),10)
				SET @CL_CODIGO_ORIGEN=RIGHT(CONCAT(''0'',RIGHT(@T_CUIT_ORD,1)),1)	
			END


				
			SET @CL_CABECERA = concat(@CL_ID_REG, @CL_CODIGO_CLASE_TRANSAC, @CL_NOM_EMPRESA,@CL_CRITERIO_EMPRESA,@CL_ID_EMPRESA, @CL_TIPO_REGISTRO, @CL_DESCRIP_TRANSAC, @CL_FECHA_PRESENTACION, @CL_FECHA_VENCIMIENTO, @CL_RESERVADO_CL, @CL_CODIGO_ORIGEN, @CL_ID_ENTIDAD_ORIGEN, @CL_NUMERO_LOTE);
			INSERT INTO dbo.ITF_TRAN_SUELDOS_PRESENTADAS_AUX (LINEA) VALUES (@CL_CABECERA);
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
   				--SET @FL_SUMA_TOTAL_DEBITO_LOTE = RIGHT(replicate(''0'', 12), 12); 
				SET @FL_SUMA_TOTAL_DEBITO_LOTE = RIGHT(replicate(''0'', 20), 20); 
   				--SET @FL_SUMA_TOTAL_CREDITO_LOTE = RIGHT(concat(replicate(''0'', 12), (replace(@SumaImportes, ''.'', ''''))), 12); 
   				SET @FL_SUMA_TOTAL_CREDITO_LOTE = RIGHT(concat(replicate(''0'', 20), (replace(@SumaImportes, ''.'', ''''))), 20); 
   				SET @TotalesCreditos += @SumaImportes;
   				SET @FL_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 6), @Cant_Reg_Individual_Adicional), 6); 
   	
   				SET @FL_TOTALES_DE_CONTROL =RIGHT(concat(replicate(''0'', 10), (SELECT sum(convert(INT,substring(t.LINEA,4,8)))
															  					FROM ITF_TRAN_SUELDOS_PRESENTADAS_AUX t
															  					WHERE t.ID>(SELECT max(tt.id) 
		  																  					FROM ITF_TRAN_SUELDOS_PRESENTADAS_AUX tt
		  																  					WHERE tt.LINEA LIKE ''5%'')
																		  					AND substring(t.LINEA,1,1) IN (''6''))), 10);
   	
   				SET @FL_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 6), (SELECT count(id) 
																			 			FROM ITF_TRAN_SUELDOS_PRESENTADAS_AUX t
																			 			WHERE t.ID>(SELECT max(tt.id) 
		  																				 			FROM ITF_TRAN_SUELDOS_PRESENTADAS_AUX tt
		  																				 			WHERE tt.LINEA LIKE ''5%'')	
																			 			AND substring(t.LINEA,1,1) IN (''6'',''7''))), 6);
		
				SET @FL_RESERVADO1=@CL_ID_EMPRESA;
				SET @FL_NUMERO_LOTE=@CL_NUMERO_LOTE
   				SET @FL_FIN_LOTE = concat(@FL_ID_REG, @FL_CODIGO_CLASE_TRANSAC, @FL_CANT_REG_INDIVIDUAL_ADICIONAL, @FL_TOTALES_DE_CONTROL, @FL_SUMA_TOTAL_DEBITO_LOTE, @FL_SUMA_TOTAL_CREDITO_LOTE, @FL_RESERVADO1, @FL_RESERVADO2, @FL_RESERVADO3, @FL_REG_ENTIDAD_ORIGEN, @FL_NUMERO_LOTE);

				INSERT INTO dbo.ITF_TRAN_SUELDOS_PRESENTADAS_AUX (LINEA) VALUES (@FL_FIN_LOTE);
	
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
				SET @CL_CODIGO_ORIGEN=RIGHT(CONCAT(''0'',RIGHT(@T_CUIT_ORD,1)),1)	
			END
			
			
						
	
			SET @CL_CRITERIO_EMPRESA = replicate('' '', 20); -- AUN NO EXISTE AUTONUMERICO, FALTA DEFINIR 
			SET @CL_CABECERA = concat(@CL_ID_REG, @CL_CODIGO_CLASE_TRANSAC, @CL_NOM_EMPRESA,@CL_CRITERIO_EMPRESA,@CL_ID_EMPRESA, @CL_TIPO_REGISTRO, @CL_DESCRIP_TRANSAC, @CL_FECHA_PRESENTACION, @CL_FECHA_VENCIMIENTO, @CL_RESERVADO_CL, @CL_CODIGO_ORIGEN, @CL_ID_ENTIDAD_ORIGEN, @CL_NUMERO_LOTE);
			INSERT INTO dbo.ITF_TRAN_SUELDOS_PRESENTADAS_AUX (LINEA) VALUES (@CL_CABECERA);
	
			IF(@T_MONEDA=(SELECT C6399 FROM MONEDAS WHERE C6403=''N''))	
				SET @FL_REG_ENTIDAD_ORIGEN = (SELECT ''0311''+ RIGHT(concat(replicate(''0'', 4), CAST((SELECT NUMERICO FROM PARAMETROSGENERALES WHERE CODIGO=40) AS VARCHAR)), 4)); 
			ELSE
				SET @FL_REG_ENTIDAD_ORIGEN = (SELECT ''0811''+ RIGHT(concat(replicate(''0'', 4), CAST((SELECT NUMERICO FROM PARAMETROSGENERALES WHERE CODIGO=40) AS VARCHAR)), 4)); 
		END
		

		IF(@T_MONEDA= (SELECT C6399 FROM MONEDAS WHERE C6403=''N''))
		BEGIN
			SET @T_COD_BANCO=311;
			SET @RI_INFO_ADICIONAL= RIGHT(concat(replicate(''0'',4),@t_ADICIONAL_PRESENT),2);
		END
		ELSE
		BEGIN
			SET @T_COD_BANCO=811;
			SET @RI_INFO_ADICIONAL= RIGHT(concat(replicate(''0'',4),@t_ADICIONAL_PRESENT),2);
		END
	
		SET @CantRegistros += 1;
		SET @Cant_Reg_Individual_Adicional += 1;
	
		IF	(@Excedente<>0)
		BEGIN
			SET @T_IMPORTE = @Excedente;
			SET @CountExcedente += 1;
		END
		--IF	(@T_IMPORTE>99999999.99)
		IF	(@T_IMPORTE>999999999999.99)
		BEGIN
			--SET @Excedente = (@T_IMPORTE - 99999999.99);
			--SET @T_IMPORTE = 99999999.99;
			SET @Excedente = (@T_IMPORTE - 999999999999.99);
			SET @T_IMPORTE = 999999999999.99;
			SET @CountExcedente += 1;
		END
		ELSE
    	BEGIN
       		SET @Excedente = 0;
    	END
	

		---------------------------- Grabar Registro Individual -----------------------------------------------------------------------------------------------------------------------------------------
     	IF @t_estado=''RC''
			SET @RI_ENTIDAD_CREDITO = @RI_ENTIDAD_CREDITO_RE;
		ELSE 
			SET @RI_ENTIDAD_CREDITO = RIGHT(concat(replicate(''0'', 8), LEFT(@T_ben_cbu,7)),8);

	 	--SET @RI_CUENTA_CREDITO = RIGHT(concat(replicate(''0'', 17), right(@T_ben_cbu,14)),17);
		SET @RI_CUENTA_CREDITO = RIGHT(concat(replicate(''0'', 14), right(@T_ben_cbu,14)),14);

    	SET @RI_REFERENCIA_UNIVOCA = RIGHT(concat(replicate(''0'', 15), @T_REFERENCIA), 15);
		IF(@T_TIPO_DOC IS NULL)
			 SET @RI_CLIENTE_PAGADOR = CONCAT('' '', LEFT(CONCAT(REPLICATE('' '', 11), REPLICATE('' '', 18)), 18), RIGHT(CONCAT(''000'', @operatoria_bcra), 3));
    	IF(@T_TIPO_DOC =''CUIT'')
    		SET @RI_CLIENTE_PAGADOR = CONCAT(''1'',LEFT(concat(@T_CUIT_BEN,replicate('' '',18)),18),RIGHT(concat(''000'',@operatoria_bcra),3));
    	IF(@T_TIPO_DOC =''CUIL'')
    		SET @RI_CLIENTE_PAGADOR = CONCAT(''2'',LEFT(concat(@T_CUIT_BEN,replicate('' '',18)),18),RIGHT(concat(''000'',@operatoria_bcra),3));
    	IF(@T_TIPO_DOC =''CDI'')
    		SET @RI_CLIENTE_PAGADOR = CONCAT(''3'',LEFT(concat(@T_CUIT_BEN,replicate('' '',18)),18),RIGHT(concat(''000'',@operatoria_bcra),3));
    
		SET @T_CODIGO_TRANSACCION = ''32'';
	
    	IF(@CountExcedente>1)
		BEGIN
        	SET @SumaSucursal += 0888;  --sumo la sucursal que hay que harcodear
        	SET @SumaEntidad +=  @T_COD_BANCO;
        	SET @SumaImportes += @T_IMPORTE;

        	SET @RI_ENTIDAD_CREDITO = concat(replicate(''0'', 4), @T_COD_BANCO, ''0888'');
        	--SET @RI_CUENTA_CREDITO = RIGHT(concat(replicate(''0'', 17), ''88888888888''), 17);
			SET @RI_CUENTA_CREDITO = RIGHT(concat(replicate(''0'', 14), ''88888888888''), 14);

        	SET @RI_REFERENCIA_UNIVOCA = ''000088888888888'';
   		END
    	ELSE --la razon de este else, es que SumaSucursal, cuando hay excedente tiene que acumular 0888
    	BEGIN
        	SET @SumaSucursal += @T_SUCURSAL;
			SET @SumaEntidad += @T_COD_BANCO;
			SET @SumaImportes += @T_IMPORTE;
     	--SET @RI_ENTIDAD_CREDITO = RIGHT(concat(replicate(''0'', 8), LEFT(@T_ben_cbu,7)),8);
		IF @t_estado=''RC''
			SET @RI_ENTIDAD_CREDITO = @RI_ENTIDAD_CREDITO_RE;
		ELSE 
			SET @RI_ENTIDAD_CREDITO = RIGHT(concat(replicate(''0'', 8), LEFT(@T_ben_cbu,7)),8);

	 	--SET @RI_CUENTA_CREDITO = RIGHT(concat(replicate(''0'', 17), right(@T_ben_cbu,14)),17);
		SET @RI_CUENTA_CREDITO = RIGHT(concat(replicate(''0'', 14), right(@T_ben_cbu,14)),14);
    		SET @RI_REFERENCIA_UNIVOCA =  CONCAT(''VAR'',RIGHT(concat(replicate(''0'', 12), @T_REFERENCIA), 12));
			IF(@T_TIPO_DOC IS NULL)
			 SET @RI_CLIENTE_PAGADOR = CONCAT('' '', LEFT(CONCAT(REPLICATE('' '', 11), REPLICATE('' '', 18)), 18), RIGHT(CONCAT(''000'', @operatoria_bcra), 3));
    		IF(@T_TIPO_DOC =''CUIT'')
    			SET @RI_CLIENTE_PAGADOR = CONCAT(''1'',LEFT(concat(@T_CUIT_BEN,replicate('' '',18)),18),RIGHT(concat(''000'',@operatoria_bcra),3));
    		IF(@T_TIPO_DOC =''CUIL'')
    			SET @RI_CLIENTE_PAGADOR = CONCAT(''2'',LEFT(concat(@T_CUIT_BEN,replicate('' '',18)),18),RIGHT(concat(''000'',@operatoria_bcra),3));
    		IF(@T_TIPO_DOC =''CDI'')
    			SET @RI_CLIENTE_PAGADOR = CONCAT(''3'',LEFT(concat(@T_CUIT_BEN,replicate('' '',18)),18),RIGHT(concat(''000'',@operatoria_bcra),3));
 
    	END

		--IF @SumaImportes>9999999999.99 GOTO Start
		IF @SumaImportes>999999999999999999.99 GOTO Start
    
    	--SET @RI_IMPORTE = RIGHT(concat(replicate(''0'', 10), replace(CAST(@T_IMPORTE AS VARCHAR),''.'','''')), 10);
		SET @RI_IMPORTE = RIGHT(concat(replicate(''0'', 14), replace(CAST(@T_IMPORTE AS VARCHAR),''.'','''')), 14);

    	SET @RI_REGISTRO_ADICIONAL = ''0'';
    
    	IF(@MONEDA=(SELECT C6399 FROM MONEDAS WHERE C6403=''N''))
    		SET @RI_CONTADOR_REGISTRO = concat(''0311'', RIGHT(concat(replicate(''0'', 4), (''30'')), 4), RIGHT(concat(replicate(''0'', 7), (SELECT NUMERICO_1 FROM ITF_MASTER_PARAMETROS WHERE CODIGO = 179)), 7)); 
    	ELSE
    		SET @RI_CONTADOR_REGISTRO = concat(''0811'', RIGHT(concat(replicate(''0'', 4), (''30'')), 4), RIGHT(concat(replicate(''0'', 7), (SELECT NUMERICO_1 FROM ITF_MASTER_PARAMETROS WHERE CODIGO = 179)), 7)); 
   
   	    IF(@CountExcedente<1)
    	BEGIN 
    		SET @RI_REGISTRO_ADICIONAL = ''1'';
    	END 
     
        	
		SET @RI_REGISTRO_INDIVIDUAL = concat(@RI_ID_REG
											, @T_CODIGO_TRANSACCION
											, @RI_ENTIDAD_CREDITO
											--, @RI_RESERVADO
											, @RI_CUENTA_CREDITO
											, @RI_IMPORTE
											, @RI_REFERENCIA_UNIVOCA
											, @RI_CLIENTE_PAGADOR
											, @RI_INFO_ADICIONAL
											, @RI_REGISTRO_ADICIONAL
											, @RI_CONTADOR_REGISTRO
											);
 
    	INSERT INTO dbo.ITF_TRAN_SUELDOS_PRESENTADAS_AUX (LINEA, CORRELATIVO) VALUES (@RI_REGISTRO_INDIVIDUAL,@T_ID_CREDITO);
    	IF(@T_CLASE=''R'')
		BEGIN
    		UPDATE dbo.VTA_TRANSFERENCIAS SET ESTADO=''RP'' WHERE OP_NUMERO=@T_REFERENCIA AND OP_CLASE_TRANS=''R'';
    	END
    	IF(@T_CLASE=''E'')
		BEGIN
    		UPDATE dbo.VTA_TRANSFERENCIAS SET ESTADO=''PR'', TRACENUMBER=@RI_CONTADOR_REGISTRO WHERE OP_NUMERO=@T_REFERENCIA AND OP_CLASE_TRANS=''E'';
    	END
		-----------
		SET @RO_NUM_SECUENCIA_ADICIONAL= ''0'';--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		/* Logica para agregar el registro adicional*/	
		IF(@CountExcedente<1) 
		BEGIN

			SET @RA_FECHA_PRESENTACION=convert(VARCHAR,@T_FECHA_PRESENTACION, 12);
			IF @T_FECHA_PRESENTACION IS NULL 
				SET @RA_FECHA_PRESENTACION=REPLICATE(''0'',6)
			SET @RA_ENTIDAD=SUBSTRING(@RI_CONTADOR_REGISTRO,1,8);
			SET @RA_CONTADOR=RIGHT(CONCAT(REPLICATE(''0'',15),CONVERT(VARCHAR, @T_TRACENUMBER)),15)
			SET @RA_RECHAZO=(SELECT codigo_nacha FROM SNP_MOTIVOS_RECHAZO WHERE id_motivo=@T_MOTIVO_RECHAZO AND TZ_LOCK=0)

	
		

			SET @RO_CONCEPTO = LEFT(CONCAT(LEFT(concat(@T_CUIT_BEN,replicate('' '',11)),11), @T_NOMBRE_BENEFICIARIO, REPLICATE('' '',80)),80);
			
			SET @RO_NUM_SECUENCIA_ADICIONAL= RIGHT(concat(replicate(''0'', 4), (@RO_NUM_SECUENCIA_ADICIONAL + 1)), 4);
			
			IF @T_MOTIVO_RECHAZO=0
				SET @RI_REGISTRO_INDIVIDUAL = concat(''705'',@RO_CONCEPTO,@RO_NUM_SECUENCIA_ADICIONAL,RIGHT(concat(replicate(''0'', 7), (SELECT NUMERICO_1 FROM ITF_MASTER_PARAMETROS WHERE CODIGO = 179)), 7));
			ELSE 
				SET @RI_REGISTRO_INDIVIDUAL = concat(''705'',@RA_FECHA_PRESENTACION,@RA_ENTIDAD,@RA_CONTADOR,@RA_RECHAZO,REPLICATE('' '',48),@RO_NUM_SECUENCIA_ADICIONAL,RIGHT(concat(replicate(''0'', 7), (SELECT NUMERICO_1 FROM ITF_MASTER_PARAMETROS WHERE CODIGO = 179)), 7));
			
			
			INSERT INTO dbo.ITF_TRAN_SUELDOS_PRESENTADAS_AUX (LINEA) VALUES (@RI_REGISTRO_INDIVIDUAL);

		END  



		----------------------------- Actualizar secuencial unico -------------------------------------
		UPDATE dbo.ITF_MASTER_PARAMETROS SET NUMERICO_1 = (NUMERICO_1 + 1) WHERE CODIGO = 179;
		-----------------------------------------------------------------------------------------------

	
		IF (@Excedente = 0)
		BEGIN		     	       				
	
			FETCH NEXT FROM CursorTM INTO @T_ID_CREDITO
										, @T_MONEDA
										, @T_IMPORTE
										, @T_FECHA_VTO
										, @T_FECHA_COMP
										, @T_CBU
										, @T_REFERENCIA
										, @T_CUIT_ORD, @T_NOMBRE_ORDENANTE, @T_CUIT_BEN, @T_NOMBRE_BENEFICIARIO, @T_TIPO_DOC, @T_CLASE							    , @t_ord_tipo_doc
									    , @t_op_referencia
									    , @t_ben_cbu
									    , @t_ben_mismo_titular
							    		, @t_ben_banco
							    		, @t_op_tipo 
							    		, @operatoria_bcra
							    		, @t_ADICIONAL_PRESENT
							    		, @T_FECHA_PRESENTACION
							    		, @T_TRACENUMBER
							    		, @T_MOTIVO_RECHAZO
										, @RI_ENTIDAD_CREDITO_RE
										, @t_estado
	
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
	--SET @FL_SUMA_TOTAL_DEBITO_LOTE =  RIGHT(replicate(''0'', 12), 12);
	SET @FL_SUMA_TOTAL_DEBITO_LOTE =  RIGHT(replicate(''0'', 20), 20);
	--SET @FL_SUMA_TOTAL_CREDITO_LOTE = RIGHT(concat(replicate(''0'', 12), (replace((SELECT sum(convert(bigint, substring(linea,30,10))) FROM ITF_TRAN_SUELDOS_PRESENTADAS_AUX WHERE LINEA LIKE ''6%'' AND id>(SELECT max(id) FROM ITF_TRAN_SUELDOS_PRESENTADAS_AUX WHERE LINEA LIKE ''5%'')), ''.'', ''''))), 12);
	SET @FL_SUMA_TOTAL_CREDITO_LOTE = RIGHT(concat(replicate(''0'', 20), (replace((SELECT sum(convert(bigint, substring(linea,26,14))) FROM ITF_TRAN_SUELDOS_PRESENTADAS_AUX WHERE LINEA LIKE ''6%'' AND id>(SELECT max(id) FROM ITF_TRAN_SUELDOS_PRESENTADAS_AUX WHERE LINEA LIKE ''5%'')), ''.'', ''''))), 20);

	SET @TotalesCreditos += @SumaImportes;
	SET @FL_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 6), @Cant_Reg_Individual_Adicional), 6); 
	SET @FL_TOTALES_DE_CONTROL =RIGHT(concat(replicate(''0'', 10), (SELECT sum(convert(INT,substring(t.LINEA,4,8)))
															  	  FROM ITF_TRAN_SUELDOS_PRESENTADAS_AUX t
															      WHERE t.ID>(SELECT max(tt.id) 
		  																  	  FROM ITF_TRAN_SUELDOS_PRESENTADAS_AUX tt
		  																      WHERE tt.LINEA LIKE ''5%'')
																		  	  AND substring(t.LINEA,1,1) IN (''6''))), 10);
	
	SET @FL_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 6), (SELECT count(id) 
																			 FROM ITF_TRAN_SUELDOS_PRESENTADAS_AUX t
																			 WHERE t.ID>(SELECT max(tt.id) 
		  																				 FROM ITF_TRAN_SUELDOS_PRESENTADAS_AUX tt
		  																				 WHERE tt.LINEA LIKE ''5%'')	
																			 AND substring(t.LINEA,1,1) IN (''6'',''7''))), 6);
	SET @FL_RESERVADO1=@CL_ID_EMPRESA;
	SET @FL_NUMERO_LOTE=@CL_NUMERO_LOTE	
	
	SET @FL_FIN_LOTE = concat(@FL_ID_REG, @FL_CODIGO_CLASE_TRANSAC, @FL_CANT_REG_INDIVIDUAL_ADICIONAL, @FL_TOTALES_DE_CONTROL, @FL_SUMA_TOTAL_DEBITO_LOTE, @FL_SUMA_TOTAL_CREDITO_LOTE, @FL_RESERVADO1, @FL_RESERVADO2, @FL_RESERVADO3, @FL_REG_ENTIDAD_ORIGEN, @FL_NUMERO_LOTE);
			
	INSERT INTO dbo.ITF_TRAN_SUELDOS_PRESENTADAS_AUX (LINEA) VALUES (@FL_FIN_LOTE);

	SET @FL_NUMERO_LOTE = CAST(@FL_NUMERO_LOTE AS NUMERIC) + 1;
	SET @FL_NUMERO_LOTE = RIGHT(concat(replicate(''0'', 7), @FL_NUMERO_LOTE), 7);
	---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-------------Grabamos el Fin de Archivo ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	SET @FA_CANT_LOTES = RIGHT(concat(replicate(''0'', 6), @FL_NUMERO_LOTE), 6);
	SET @CantRegistrosPrev = (SELECT (CASE WHEN (@CantRegistros + 4) % 10 = 0 THEN ((@CantRegistros + 4)/10) ELSE (FLOOR((@CantRegistros + 4)/10) + 1) END));
	
	SET @FA_NUMERO_BLOQUES = RIGHT(concat(replicate(''0'', 6), (SELECT CEILING((count(*)+1) / CONVERT(FLOAT, 10))
																  FROM ITF_TRAN_SUELDOS_PRESENTADAS_AUX 
																  WHERE  ID>=(SELECT max(id) 
																  		  		FROM ITF_TRAN_SUELDOS_PRESENTADAS_AUX 
																  		  		WHERE LINEA LIKE ''1%''))), 6);
		
	SET @FA_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 8), @CantRegistros), 8);		
	SET @FA_TOTALES_DE_CONTROL = @FL_TOTALES_DE_CONTROL; --igualo al totales de control de fin de lote pq tiene que ser igual
	--SET @FA_SUMA_TOTAL_DEBITOS = RIGHT(concat(replicate(''0'', 12), (replace(@TotalesDebitos, ''.'', ''''))), 12);
	SET @FA_SUMA_TOTAL_DEBITOS = RIGHT(concat(replicate(''0'', 20), (replace(@TotalesDebitos, ''.'', ''''))), 20);
	--SET @FA_SUMA_TOTAL_CREDITOS = RIGHT(concat(replicate(''0'', 12), (replace((SELECT sum(convert(bigint, substring(linea,30,10))) FROM ITF_TRAN_SUELDOS_PRESENTADAS_AUX WHERE LINEA LIKE ''6%'' AND id>(SELECT max(id) FROM ITF_TRAN_SUELDOS_PRESENTADAS_AUX WHERE LINEA LIKE ''1%'')), ''.'', ''''))),12);
	SET @FA_SUMA_TOTAL_CREDITOS = RIGHT(concat(replicate(''0'', 20), (replace((SELECT sum(convert(bigint, substring(linea,26,14))) FROM ITF_TRAN_SUELDOS_PRESENTADAS_AUX WHERE LINEA LIKE ''6%'' AND id>(SELECT max(id) FROM ITF_TRAN_SUELDOS_PRESENTADAS_AUX WHERE LINEA LIKE ''1%'')), ''.'', ''''))),20);
	
	SET @FA_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 8), (SELECT count(id) 
																			 FROM ITF_TRAN_SUELDOS_PRESENTADAS_AUX 
																			 WHERE (LINEA LIKE ''6%'' OR LINEA LIKE ''7%'')
																			 AND id>(SELECT max(id) FROM ITF_TRAN_SUELDOS_PRESENTADAS_AUX WHERE LINEA LIKE ''1%''))), 8);
	
	SET @FA_TOTALES_DE_CONTROL =RIGHT(concat(replicate(''0'', 10), (SELECT sum(convert(INT,substring(LINEA,4,8)))
																 FROM ITF_TRAN_SUELDOS_PRESENTADAS_AUX
														  		 WHERE LINEA LIKE ''6%'' AND ID >(SELECT max(tt.id) 
		  																  FROM ITF_TRAN_SUELDOS_PRESENTADAS_AUX tt
		  																  WHERE tt.LINEA LIKE ''1%''))), 10);
	
	
	SET @FA_CANT_LOTES = RIGHT(concat(replicate(''0'', 6), (SELECT count(ID) FROM ITF_TRAN_SUELDOS_PRESENTADAS_AUX WHERE LINEA LIKE ''5%'' AND id>(SELECT max(id) FROM ITF_TRAN_SUELDOS_PRESENTADAS_AUX WHERE LINEA LIKE ''1%''))), 6);

	SET @FA_FIN_ARCHIVO = concat(@FA_ID_REG, @FA_CANT_LOTES, @FA_NUMERO_BLOQUES, @FA_CANT_REG_INDIVIDUAL_ADICIONAL, @FA_TOTALES_DE_CONTROL, @FA_SUMA_TOTAL_DEBITOS, @FA_SUMA_TOTAL_CREDITOS, @FA_RESERVADO);
			
	INSERT INTO dbo.ITF_TRAN_SUELDOS_PRESENTADAS_AUX (LINEA) VALUES (@FA_FIN_ARCHIVO);
	
	------------------------------------------------------------------------------------------------------------------------------------------------------------------

END
'); 

EXECUTE('CREATE OR ALTER PROCEDURE [dbo].[SP_CLS_TRANS_RECHAZ_PESOS_V2]
	@TICKET NUMERIC(16),
	@MENSAJE_ERROR VARCHAR(max) OUT
AS
BEGIN

	-- Cerrar el cursor si está abierto
	IF CURSOR_STATUS(''global'', ''cls_trans'') >= 0
	BEGIN
	    IF CURSOR_STATUS(''global'', ''cls_trans'') = 1
	    BEGIN
	        CLOSE cls_trans;
	    	DEALLOCATE cls_trans;
	    END
    END 
    
	SET @MENSAJE_ERROR = '''';

	/******** Variables Cabecera de Archivo **********************************/
	DECLARE @IdRegistro VARCHAR(1);
	DECLARE @CodigoPrioridad VARCHAR(2);
	DECLARE @DestinoInmediato VARCHAR(10);
	DECLARE @OrigenInmediato VARCHAR(10);
	DECLARE @FechaPresentacion DATE; --reutilizo la variable mas adelante
	DECLARE @HoraPresentacion NUMERIC(4);
	DECLARE @IdentificadorArchivo VARCHAR(1);
	DECLARE @TamanoRegistro NUMERIC(3);
	DECLARE @FactorBloque NUMERIC(2);
	DECLARE @CodigoFormato VARCHAR(1);
	DECLARE @NombreDestinoInmediato VARCHAR(23);
	DECLARE @NombreOrigenInmediato VARCHAR(23);
	DECLARE @CodigoReferencia VARCHAR(8);

	/******** Variables Cabecera de Lote **********************************/
	DECLARE @FechaVencimiento DATE;
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
--s	DECLARE @ReservadoRI VARCHAR(1);
--s	DECLARE @CuentaDebitar VARCHAR(17);
--s	DECLARE @Importe NUMERIC(10) = 0;     
	DECLARE @CuentaDebitar VARCHAR(14);
	DECLARE @Importe NUMERIC(14) = 0;   
	DECLARE @ReferenciaUn VARCHAR(15);
	DECLARE @CodigoPostal VARCHAR(6);
	DECLARE @PuntoIntercambio VARCHAR(16);
	DECLARE @InfoAdicional VARCHAR(2);
	DECLARE @RegistrosAdicionales VARCHAR(1);
	DECLARE @ContadorRegistros VARCHAR(15);
	DECLARE @CodRechazo VARCHAR (3); 
	
	/******** Variables Registro adicional de rechazos de órdenes de transferencia *************/
	 DECLARE @TraceNumber VARCHAR(15);	

	--SE VAN A USAR ESTOS CAMPOS COMO CLAVE EN LUGAR DEL TRACENUMBER  
	
	DECLARE @Entidad_RI VARCHAR(4);	-- SE CAMBIA TIPO A VARCHAR PORQUE AHORA NO SE VALIDA MAS EL REG INDIVIDUAL
	DECLARE @Sucursal_RI VARCHAR(4); -- SE CAMBIA TIPO A VARCHAR PORQUE AHORA NO SE VALIDA MAS EL REG INDIVIDUAL
	DECLARE @CodigoPostal_RI VARCHAR(4); -- SE CAMBIA TIPO A VARCHAR PORQUE AHORA NO SE VALIDA MAS EL REG INDIVIDUAL
	DECLARE @NumeroCuenta_RI VARCHAR(12); -- SE CAMBIA TIPO A VARCHAR PORQUE AHORA NO SE VALIDA MAS EL REG INDIVIDUAL
	DECLARE @NumeroCheque_RI VARCHAR(12); -- SE CAMBIA TIPO A VARCHAR PORQUE AHORA NO SE VALIDA MAS EL REG INDIVIDUAL

	DECLARE @ExisteRI NUMERIC(1) = 0; --para saber si hay al menos 1 lote
	
	/******** Variables FIN DE LOTE *************/

	--DECLARE @RegIndivAdic NUMERIC(6);
	DECLARE @TotalesControl NUMERIC(10);
--s	DECLARE @SumaDebLote NUMERIC(12);
--s	DECLARE @SumaCredLote NUMERIC(12);
	DECLARE @SumaDebLote NUMERIC(20);
	DECLARE @SumaCredLote NUMERIC(20);
	DECLARE @ReservadoFL VARCHAR(40);

	/******** Variables FIN DE ARCHIVO *************/

	DECLARE @CantLotesFA NUMERIC(6);
	DECLARE @NumBloquesFA NUMERIC(6);
	DECLARE @CantRegAdFA VARCHAR (8);
	DECLARE @TotalesControlFA NUMERIC(10);
--s	DECLARE @ReservadoFA VARCHAR(39);
	DECLARE @ReservadoFA VARCHAR(23);

	/*Validaciones generales */
	
	DECLARE @updRecepcion VARCHAR(1);

	IF(0=(SELECT COUNT(*) FROM ITF_TRANS_PESOS_RECHAZ_AUX
		WHERE LINEA LIKE ''1%''))   		
   			SET @MENSAJE_ERROR = ''Error - Faltan registros.'';   	   
	IF(0=(SELECT COUNT(*) FROM ITF_TRANS_PESOS_RECHAZ_AUX
	WHERE LINEA LIKE ''5%''))
   			SET @MENSAJE_ERROR = ''Error - Faltan registros.'';
	IF(0=(SELECT COUNT(*) FROM ITF_TRANS_PESOS_RECHAZ_AUX
	WHERE LINEA LIKE ''8%''))
   			SET @MENSAJE_ERROR = ''Error - Faltan registros.'';
	IF(0=(SELECT COUNT(*) FROM ITF_TRANS_PESOS_RECHAZ_AUX
	WHERE LINEA LIKE ''9%''))
   			SET @MENSAJE_ERROR = ''Error - Faltan registros.'';


	--#validacion2
	IF ((SELECT COUNT(*)
	FROM ITF_TRANS_PESOS_RECHAZ_AUX
	WHERE LINEA LIKE ''1%'' OR LINEA LIKE ''9%'') > 2 )
	 SET @MENSAJE_ERROR = ''Error - Deben haber solo 1 reg CA y 1 reg FA'';


	--#validacion3
	IF(
	(SELECT COUNT(1) as Orden
	WHERE 1=(
	SELECT count(1)
		WHERE EXISTS
	(SELECT CONVERT(INT,SUBSTRING(LINEA,1,1))
		FROM ITF_TRANS_PESOS_RECHAZ_AUX
		WHERE ID IN
	(SELECT ID-1
			FROM ITF_TRANS_PESOS_RECHAZ_AUX
			WHERE LINEA LIKE ''8%'')
			AND CONVERT(INT,SUBSTRING(LINEA,1,1)) NOT IN (5,6,7)
	))
		OR 1=(
	SELECT count(1)
		WHERE
	EXISTS
	(SELECT CONVERT(INT,SUBSTRING(LINEA,1,1))
		FROM ITF_TRANS_PESOS_RECHAZ_AUX
		WHERE ID IN
	(SELECT ID+1
			FROM ITF_TRANS_PESOS_RECHAZ_AUX
			WHERE LINEA LIKE ''8%'')
			AND CONVERT(INT,SUBSTRING(LINEA,1,1)) NOT IN (5,9)
	))
		OR 1=(
	SELECT count(1)
		WHERE
	EXISTS
	(SELECT CONVERT(INT,SUBSTRING(LINEA,1,1))
		FROM ITF_TRANS_PESOS_RECHAZ_AUX
		WHERE ID IN
	(SELECT ID-1
			FROM ITF_TRANS_PESOS_RECHAZ_AUX
			WHERE LINEA LIKE ''5%'')
			AND CONVERT(INT,SUBSTRING(LINEA,1,1)) NOT IN (1,8)
	))
		OR 1=(
	SELECT count(1)
		WHERE
	EXISTS
	(SELECT CONVERT(INT,SUBSTRING(LINEA,1,1))
		FROM ITF_TRANS_PESOS_RECHAZ_AUX
		WHERE ID IN
	(SELECT ID+1
			FROM ITF_TRANS_PESOS_RECHAZ_AUX
			WHERE LINEA LIKE ''5%'')
			AND CONVERT(INT,SUBSTRING(LINEA,1,1)) NOT IN (6,7,8)
	))) <> 0
	)
	 SET @MENSAJE_ERROR =''Error: el orden de los registros NACHA es incorrecto.'';



	------validaciones #5 #6 #7 y #8

	--#5 y 7
	DECLARE @sumaEntidades_RI NUMERIC = 0;
	DECLARE @sumaSucursales_RI NUMERIC = 0;
	
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
--s		@sumaDebitos_RI = sum(CAST(substring(LINEA, 30, 10) AS NUMERIC)),
		@sumaDebitos_RI = sum(CAST(substring(LINEA, 26, 14) AS NUMERIC)),
		@sumaEntidades_RI = sum(CAST(substring(LINEA, 4, 4) AS NUMERIC)),
		@sumaSucursales_RI = sum(CAST(substring(LINEA, 8, 4) AS NUMERIC))
	FROM ITF_TRANS_PESOS_RECHAZ_AUX
	WHERE LINEA LIKE ''6%'';

   	
	--seteo total control y total de importes FA
	SELECT
		@totControl_FA = CAST(substring(linea, 22, 10) AS NUMERIC),
--s		@totalDebitos_FA = CAST(substring(linea, 32, 12) AS NUMERIC),
--s		@totalCreditos_FA = CAST(substring(linea, 44, 12) AS NUMERIC)
		@totalDebitos_FA = CAST(substring(linea, 32, 20) AS NUMERIC),
		@totalCreditos_FA = CAST(substring(linea, 52, 20) AS NUMERIC)
	FROM ITF_TRANS_PESOS_RECHAZ_AUX
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
--s		@controlDebitos_FL = sum(CAST(substring(LINEA, 21, 12) AS NUMERIC)),
--s		@controlCreditos_FL = sum(CAST(substring(LINEA, 33, 12) AS NUMERIC))
		@controlDebitos_FL = sum(CAST(substring(LINEA, 21, 20) AS NUMERIC)),
		@controlCreditos_FL = sum(CAST(substring(LINEA, 41, 20) AS NUMERIC))
	FROM ITF_TRANS_PESOS_RECHAZ_AUX
	WHERE LINEA LIKE ''8%'';


	--#validacion5
	IF(CONCAT(@sumaEntidades_RI, RIGHT(CONCAT(REPLICATE(''0'',3), @sumaSucursales_RI ),4)) <> @sumaTotalCtrl_FL)	
	SET @MENSAJE_ERROR = ''No concuerda la suma Ent/Suc con control FL'';
   
	
	 	
	--#validacion7
	/*--OPH22112023  Se comenta porque se agregar el kettle principal estandar de validacion
	IF(@sumaTotalCtrl_FL <> @totControl_FA)
	SET @MENSAJE_ERROR = ''No concuerda la suma de TotalesControl de FL con control FA'';
	*/


/* 	ACA HAY QUE PREGUNTAR COMO SE VA A DIFERENCIAR ENTRE LOS CREDITOS Y DEBITOS DEL REGISTRO INDIVIDUAL

	--#validacion6 debitos
	IF(@sumaDebitos_RI  <> @controlDebitos_FL AND @sumaDebitos_RI <> @totalDebitos_FA)
	RAISERROR(''No concuerda la suma de Debitos individuales con el Total Debitos'', 16, 1);

	--#validacion6 creditos
	IF( @sumaCreditos_RI <> @controlCreditos_FL AND @sumaCreditos_RI <> @totalCreditos_FA)
	RAISERROR(''No concuerda la suma de Creditos individuales con el Total Creditos '', 16, 1);
*/


	--#validacion8
	IF((@controlDebitos_FL + @controlCreditos_FL) <>  (@totalDebitos_FA + @totalCreditos_FA))
  		SET @MENSAJE_ERROR = ''No concuerda la suma de Debitos de FL con Total Importe FA'';


	--fin----validaciones #5 #6 #7 y #8



BEGIN TRY
	DECLARE @ID VARCHAR(95);
	DECLARE @LINEA VARCHAR(95);
	DECLARE cls_trans CURSOR FOR 
SELECT ID, LINEA
	FROM dbo.ITF_TRANS_PESOS_RECHAZ_AUX

	OPEN cls_trans

	FETCH NEXT FROM cls_trans INTO @ID, @LINEA

	WHILE @@FETCH_STATUS = 0  
BEGIN


		--#validacion4
		if(DATALENGTH(@LINEA) <> 94)
		SET @MENSAJE_ERROR = ''Se encontraron registros de longitud incorrecta'';

		SET @IdRegistro = substring(@LINEA, 1, 1);

		IF(@IdRegistro NOT IN(''1'',''5'',''6'',''7'',''8'',''9'') ) --validacion de id reg
      	SET @MENSAJE_ERROR = ''Id Registro invalido'';


		/* Cabecera de Archivo */
		IF (@IdRegistro = ''1'') 
      BEGIN
			--variables de cabecera de archivo
			SET @CodigoPrioridad = substring(@LINEA,2,2);
			SET @DestinoInmediato = substring(@LINEA,4 ,10);
			SET @FechaPresentacion = substring(@LINEA, 24, 6);
			SET @HoraPresentacion = substring(@LINEA, 30, 4);
			SET @IdentificadorArchivo = substring(@LINEA, 34, 1);
			SET @TamanoRegistro = substring(@LINEA, 35, 3);
			SET @FactorBloque = substring(@LINEA, 38, 2);
			SET @CodigoFormato = substring(@LINEA, 40, 1);
			SET @NombreDestinoInmediato = substring(@LINEA, 41, 23);
			SET @NombreOrigenInmediato = substring(@LINEA, 64, 23);
			SET @CodigoReferencia = substring(@LINEA, 87, 8);


			IF (@IdentificadorArchivo NOT IN (''A'',''B'',''C'',''D'',''E'',''F'',''G'',''H'',''I'',''J'',''K'',''L'',''M'',''N'',''O'',''P'',''Q'',''R'',''S'',''T'',''U'',''V'',''W'',''X'',''Y'',''Z'',''0'',''1'',''2'',''3'',''4'',''5'',''6'',''7'',''8'',''9'')) 
			SET @MENSAJE_ERROR = ''Identificador Archivo invalido'';


/* por ahora no
			--#validacion11
			IF(substring(@DestinoInmediato, 2, 4) <> ''0811'')
			RAISERROR (''Destino inmediato debe ser 0811'', 16, 1);
*/
		END

		IF (@IdRegistro = ''5'') 
      BEGIN

			--variables cabecera de lote
			SET @ClaseTransaccion = substring(@LINEA, 2, 3);
			SET @ReservadoLote = substring(@LINEA, 5, 46);
			--VALIDACION RESERVADO VACIO
			SET @CodigoRegistro = substring(@LINEA, 51, 3);

			SET @FechaPresentacion = CONVERT(DATETIME,substring(@LINEA, 64, 6),103);
			--VALIDACION FECHAS
			SET @FechaVencimiento = CONVERT(DATETIME,substring(@LINEA, 70, 6),103);
			SET @ReservadoLoteCeros = substring(@LINEA, 76, 3);
			--VALIDACION RESERVADO 000
			SET @CodigoOrigen = substring(@LINEA, 79, 1);

			SET @IdEntidadOrigen = substring(@LINEA, 80, 8);

			SET @NumeroLote = substring(@LINEA, 88, 7);

			
			

			IF (@FechaPresentacion > @FechaVencimiento) 
      			SET @MENSAJE_ERROR = ''Fecha Presentacion debe ser anterior a vencimiento'';
		

		END


		/*FIN DE LOTE*/
		IF (@IdRegistro = ''8'') 
      BEGIN
			SET @ClaseTransaccion = substring(@LINEA, 2, 3);
			--SET @RegIndivAdic = substring(@LINEA, 5, 6);
			--SET @TotalesControl = substring(@LINEA, 11,10);
--s			SET @ReservadoFL = substring(@LINEA, 45, 35);
			SET @ReservadoFL = substring(@LINEA, 61, 19);
			SET @IdEntidadOrigen = substring(@LINEA, 80, 8);
			SET @NumeroLote = substring(@LINEA, 88, 7);

		
		END

		/*FIN DE ARCHIVO*/
		IF (@IdRegistro = ''9'') 
      BEGIN
			SET @CantLotesFA = substring(@LINEA, 2, 6);
			SET @NumBloquesFA = substring(@LINEA, 8, 6);
			SET @CantRegAdFA = substring(@LINEA, 14, 8);
			SET @TotalesControlFA  = substring(@LINEA, 22, 10);
--s			SET @ReservadoFA  = substring(@LINEA, 56, 39);
			SET @ReservadoFA  = substring(@LINEA, 72, 23);
		  
			
			
			--#validacion9
			IF(@ExisteRI = 1 AND (SELECT COUNT(*) FROM ITF_TRANS_PESOS_RECHAZ_AUX WHERE LINEA LIKE ''5%'') <> @CantLotesFA)
			   SET @MENSAJE_ERROR = ''No coincide la cantidad de LOTES con la informada en el reg FA'';
		
			--#validacion10
			IF((SELECT count(*) FROM ITF_TRANS_PESOS_RECHAZ_AUX WHERE LINEA LIKE ''6%'' OR LINEA LIKE ''7%'') <> @CantRegAdFA)
				SET @MENSAJE_ERROR = ''No coincide la cantidad de registros ind y ad con la informada en el reg FA'';
		  
		END

		--Registro ind adicional--
		IF(@IdRegistro = ''7'' AND substring(@LINEA, 2 , 2) = ''99'')
		BEGIN
			--SET @CodRechazo = substring(@LINEA, 5, 2);
			SET @TraceNumber = substring(@LINEA, 7, 15)
		   --IF(@MENSAJE_ERROR = '''') --NO HAY ERRORES NACHA 			
				--UPDATE SNP_TRANSFERENCIAS SET MOTIVO_RECHAZO = @CodRechazo WHERE id_transferencia = CAST(@ReferenciaUn AS NUMERIC) AND TZ_LOCK = 0;	   		
		

		END


		/* Registro Individual */
		IF (@IdRegistro = ''6'') 
      BEGIN
      		SET @ExisteRI = 1;
      		
			SET @CodTransaccion = substring(@LINEA, 2, 2);
			SET @EntidadDebitar = substring(@LINEA, 4, 8);
--s			SET @ReservadoRI = substring(@LINEA, 12, 1);
--s			SET @CuentaDebitar = substring(@LINEA, 13, 17);
			SET @CuentaDebitar = substring(@LINEA, 12, 14);
--s			SET @Importe = substring(@LINEA, 30, 10);
			SET @Importe = substring(@LINEA, 26, 14);
			SET @ReferenciaUn = substring(@LINEA, 40, 15);
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
		   	DECLARE @MONEDA NUMERIC(1,0);
		   	
		   	

			IF(LEFT(@EntidadDebitar,4)=''0311'')
			BEGIN
			  	SET @MONEDA = (SELECT C6399 FROM MONEDAS WHERE C6403=''N'' AND tz_lock=0);
			END
			 ELSE
			BEGIN
			 	SET @MONEDA = (SELECT C6399 FROM MONEDAS WHERE C6403=''D'' AND tz_lock=0);
			END

			IF (@RegistrosAdicionales NOT IN(''1'',''0''))       		
			   SET @MENSAJE_ERROR = ''Campo Registro adicional invalido'';
		   
		   IF(@RegistrosAdicionales=''1'')
			BEGIN
--				SET @CodRechazo = (SELECT TOP 1 SUBSTRING(LINEA,4,3) FROM ITF_TRANS_PESOS_RECHAZ_AUX WHERE ID>@ID AND LINEA LIKE ''799%'');
				SET @CodRechazo = (SELECT TOP 1 ID_MOTIVO from SNP_MOTIVOS_RECHAZO WHERE CODIGO_NACHA=(SELECT TOP 1 SUBSTRING(LINEA,4,3) FROM ITF_TRANS_PESOS_RECHAZ_AUX WHERE ID>@ID AND LINEA LIKE ''799%'') AND funcionalidad=''TR'')
				SET @TraceNumber = (SELECT TOP 1 substring(linea, 7, 15) FROM ITF_TRANS_PESOS_RECHAZ_AUX WHERE ID>@ID AND LINEA LIKE ''799%'') 
			END

			--- Variables Generales ---
			DECLARE @NRO_DPF_CHEQUE NUMERIC(12);
			DECLARE @BANCO_GIRADO NUMERIC(4);
			DECLARE @SUCURSAL_BANCO NUMERIC(5);
			DECLARE @TIPO_DOCUMENTO VARCHAR(4);
			DECLARE @IMPORTE_TOTAL NUMERIC(12);
			DECLARE @SERIE_DEL_CHEQUE VARCHAR(6);
			DECLARE @NRO_CUENTA NUMERIC(12);
			DECLARE @CODIGO_POSTAL NUMERIC(4);		
			DECLARE @EXISTE NUMERIC(4) = 0;
			DECLARE @ORDINAL NUMERIC(12);
			
			
			IF(@MENSAJE_ERROR = '''') --NO HAY ERRORES NACHA 	 
			BEGIN 
				DECLARE @FECHADATE DATETIME;
		  		SET @FECHADATE = (SELECT FECHAPROCESO FROM PARAMETROS);

				UPDATE dbo.VTA_TRANSFERENCIAS
				SET ESTADO = ''RC'' , REJECTADO=''S'',FECHA_ESTADO=@FECHADATE , NUMERO_ASIENTO=@TICKET, MOTIVO_RECHAZO=@CodRechazo,FCH_DEV_REC=@FechaPresentacion
				WHERE OP_CLASE_TRANS = ''E'' 
				   AND OP_MONEDA=@MONEDA 
				   AND OP_FECHA_PRES = @FechaPresentacion
				   AND TRACENUMBER = @TraceNumber 
			END
		END

		FETCH NEXT FROM cls_trans INTO @ID, @LINEA
	END
	END TRY

BEGIN CATCH  
    -- Cerrar y desalojar el cursor en caso de error
    IF CURSOR_STATUS(''global'', ''cls_trans'') >= -1
    BEGIN
        CLOSE cls_trans;
        DEALLOCATE cls_trans;
    END

    -- Construir el mensaje de error
    SET @MENSAJE_ERROR = ''Linea Error: '' + CONVERT(VARCHAR, ERROR_LINE()) + 
                         '' Mensaje Error: '' + ERROR_MESSAGE();    
    RETURN;
END CATCH;

	CLOSE cls_trans
	DEALLOCATE cls_trans

END;
'); 

EXECUTE('CREATE OR ALTER PROCEDURE [dbo].[SP_ITF_COELSA_TRANS_RECH_ENV_V2]
	@TICKET NUMERIC(16)
AS

BEGIN

	BEGIN TRY  
	
	------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--- Created : 
	--- Autor: 
	--- Se crea el sp con el fin de generar la información de las transferencias rechazadas a informar a COELSA.
	------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
	--- Limpiar Tabla auxiliar ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	TRUNCATE TABLE VTA_TRANSFERENCIAS_TEMP;
	------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--- Variables Cabecera Archivo ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	DECLARE @CA_ID_REG VARCHAR(1) = ''1'';
	DECLARE @CA_CODIGO_PRIORIDAD VARCHAR(2) = ''01'';
	DECLARE @CA_DESTINO_INMEDIATO VARCHAR(10) = '' 050000010''; --Por revisar
	DECLARE @CA_ORIGEN_INMEDIATO VARCHAR(10) = '' 081100300'';
	DECLARE @CA_FECHA_PRESENTACION VARCHAR(6) = convert(VARCHAR,(SELECT FECHAPROCESO FROM PARAMETROS WITH (NOLOCK)), 12); 
	DECLARE @CA_HORA_PRESENTACION VARCHAR(4) = concat(SUBSTRING((SELECT CONVERT (VARCHAR(8), SYSDATETIME(),24)),1,2), SUBSTRING((SELECT CONVERT (VARCHAR(8), SYSDATETIME(),24)),4,2));
	
	DECLARE @CONT NUMERIC(5);
	DECLARE @AZ VARCHAR(1);
	
	SELECT @CONT =
	(CASE
		WHEN  ((SELECT a.NUMERICO_1 FROM ITF_MASTER_PARAMETROS a WHERE a.CODIGO=423) > 26) or (SELECT a.NUMERICO_1 FROM ITF_MASTER_PARAMETROS a WHERE a.CODIGO= 423 AND a.FECHA = (SELECT FECHAPROCESO FROM PARAMETROS)) IS NULL THEN 1
		ELSE (SELECT a.NUMERICO_1 FROM ITF_MASTER_PARAMETROS a WHERE a.CODIGO=423 AND a.FECHA = (SELECT FECHAPROCESO FROM PARAMETROS))+1
	END
	);
	
	SELECT @AZ = Char(64 + @CONT);
	
	DECLARE @CA_IDENTIFICADOR_ARCHIVO VARCHAR(1) = @AZ; --Por Revisar
	DECLARE @CA_TAMANNO_REGISTRO VARCHAR(3) = ''094'';
	DECLARE @CA_FACTOR_BLOQUE VARCHAR(2) = ''10'';
	DECLARE @CA_CODIGO_FORMATO VARCHAR(1) = ''1'';
	DECLARE @CA_NOMBRE_DEST_INMEDIATO VARCHAR(23) = concat(''COELSA'',replicate('' '', 17));  -- completo con espacios a la derecha
	DECLARE @CA_NOMBRE_ORIG_INMEDIATO VARCHAR(23) = concat(''NUEVO BCO CHACO S.A.'',replicate('' '', 3));									     
	DECLARE @CA_CODIGO_REFERENCIA VARCHAR(8) = concat(''MIN'', replicate('' '', 4),''0'');
	DECLARE @CA_CABECERA VARCHAR(200);
	
	SET @CA_CABECERA = concat(@CA_ID_REG, @CA_CODIGO_PRIORIDAD, @CA_DESTINO_INMEDIATO, @CA_ORIGEN_INMEDIATO, @CA_FECHA_PRESENTACION, @CA_HORA_PRESENTACION, @CA_IDENTIFICADOR_ARCHIVO, @CA_TAMANNO_REGISTRO, @CA_FACTOR_BLOQUE, @CA_CODIGO_FORMATO, @CA_NOMBRE_DEST_INMEDIATO, @CA_NOMBRE_ORIG_INMEDIATO, @CA_CODIGO_REFERENCIA);
	------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
	--- Variables Cabecera Lote ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	DECLARE @CL_ID_REG VARCHAR(1) = ''5''; 
	DECLARE @CL_CODIGO_CLASE_TRANSAC VARCHAR(3) = ''220'';
	DECLARE @CL_NOMBRE_EMPRESA_INDIVIDUO VARCHAR(16);
	DECLARE @CL_INFORMACION_DISCRECIONAL VARCHAR(20) = REPLICATE('' '',20);
	DECLARE @CL_IDENTIFICACION_EMP_IND VARCHAR(10);-- = ''3067015779'';--Por revisar
	DECLARE @CL_TIPO_REGISTRO VARCHAR(3) = RIGHT(''CTX'', 3);
	DECLARE @CL_RESERVADO VARCHAR(10) = REPLICATE('' '', 10);  
	DECLARE @CL_FECHA_PRESENTACION VARCHAR(6) = convert(VARCHAR,(SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)), 12);
	DECLARE @CL_FECHA_COMPENSACION VARCHAR(6) = convert(VARCHAR,(SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)), 12);--Por revisar
	DECLARE @CL_MONEDA_TRANSACCION VARCHAR(3) = RIGHT(''013'', 3);--Para revisar
	DECLARE @CL_DIGITO_VERIFICADOR VARCHAR(1);-- = RIGHT(''9'', 1);--Para revisar
	DECLARE @CL_ID_ENTIDAD_ORIGEN VARCHAR(8) = ''08110030''; 
	-----
	DECLARE @CL_ORD_NRO_DOC VARCHAR(11);
	DECLARE @CL_BEN_BANCO VARCHAR(6);
	DECLARE @CL_OP_CLASE_TRANS VARCHAR(1);
	DECLARE @CL_NUM_LOTE_CAB VARCHAR(7);
	DECLARE @CL_NUM_LOTE_CAB_NEW NUMERIC(7)=0;
	
	DECLARE @CL_NUMERO_LOTE VARCHAR(7)=''0'';
	DECLARE @CL_CABECERA VARCHAR(200);

	--- Variables Fin de Lote ---------------------------------------------------------------------------------------------------------------------------------------------------------------
	DECLARE @FL_ID_REG VARCHAR(1) = ''8'';  
	DECLARE @FL_CODIGO_CLASE_TRANSAC VARCHAR(3) = ''220''; 
	DECLARE @FL_CANT_REG_INDIVIDUAL_ADICIONAL VARCHAR(6) = replicate(''0'',6); 
	DECLARE @FL_TOTALES_DE_CONTROL VARCHAR(10) = replicate(''0'',10); 
--s	DECLARE @FL_SUMA_TOTAL_DEBITO_LOTE VARCHAR(12)=replicate(''0'',12); --cambio el largo a 12
--s	DECLARE @FL_SUMA_TOTAL_CREDITO_LOTE VARCHAR(12)=replicate(''0'',12); --cambio el largo a 12
	DECLARE @FL_SUMA_TOTAL_DEBITO_LOTE VARCHAR(12)=replicate(''0'',20); --cambio el largo a 20
	DECLARE @FL_SUMA_TOTAL_CREDITO_LOTE VARCHAR(12)=replicate(''0'',20); --cambio el largo a 20
	DECLARE @FL_IDENTIFICACION_EMP_IND VARCHAR(10);-- = ''3067015779'';--Por revisar
--s	DECLARE @FL_RESERVADO2 VARCHAR(19) = replicate('' '', 19); --cambio largo a 19
	DECLARE @FL_RESERVADO2 VARCHAR(19) = replicate('' '', 3); --cambio largo a 19
	DECLARE @FL_RESERVADO3 VARCHAR(6) = replicate('' '', 6); --cambio largo a 6
	DECLARE @FL_REG_ENTIDAD_ORIGEN VARCHAR(8) = ''08110030''; 
	
	DECLARE @FL_FIN_LOTE VARCHAR(200);
	
	
		--- Variables Fin de Archivo ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	DECLARE @FA_ID_REG VARCHAR(1) = ''9'';  
	DECLARE @FA_CANT_LOTES VARCHAR(6) = ''000001'';
	DECLARE @FA_NUMERO_BLOQUES VARCHAR(6);
	DECLARE @FA_CANT_REG_INDIVIDUAL_ADICIONAL VARCHAR(8);
	DECLARE @FA_TOTALES_DE_CONTROL VARCHAR(10);  --NO LO VOY A NECESITAR MAS, EN SU LUGAR USO @FL_TOTALES_DE_CONTROL
--s	DECLARE @FA_SUMA_TOTAL_DEBITOS VARCHAR(12);--cambio largo a 12
--s	DECLARE @FA_SUMA_TOTAL_CREDITOS VARCHAR(12);
	DECLARE @FA_SUMA_TOTAL_DEBITOS VARCHAR(20);--cambio largo a 20
	DECLARE @FA_SUMA_TOTAL_CREDITOS VARCHAR(20);
--s	DECLARE @FA_RESERVADO  VARCHAR(39) = concat(REPLICATE('' '', 38),0);
	DECLARE @FA_RESERVADO  VARCHAR(23) = concat(REPLICATE('' '', 22),0);

	
	DECLARE @FA_FIN_ARCHIVO VARCHAR(200);
	---------------------------------------
	
	DECLARE @FA_SUMA_ACUMULADA NUMERIC(15)=0;
	DECLARE @FA_SumaEntidad NUMERIC(12) = 0; 
	DECLARE @FA_SumaSucursal NUMERIC(12) = 0;
	DECLARE @FA_TotalesCreditos NUMERIC(15,2) = 0;
	
	DECLARE @FA_CANT_LOTES_ARCHIVO NUMERIC(6) = 0;
	DECLARE @CantRegistrosTotal NUMERIC(15) = 2; --seteo 4, cuento la cabecera de archivo, cabecera lote, fin de lote y el fin de archivo 
	DECLARE @CantRegistros NUMERIC(15) = 0; 
	
	--- Grabamos la cabecera del archivo ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	INSERT INTO VTA_TRANSFERENCIAS_TEMP (LINEA) VALUES (@CA_CABECERA);
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		IF((SELECT COUNT(1) 
			FROM VTA_TRANSFERENCIAS VT1
			WHERE VT1.OP_CLASE_TRANS = ''R'' 
			and VT1.ESTADO=''RC'' 
			and VT1.OP_MONEDA = 2 
			AND VT1.CONTABILIZADA<> ''R'' 
			AND VT1.TZ_LOCK=0)=0)
	BEGIN
		
		---------------- Grabar Cabecera Lote ---------------------------
		SET @FA_CANT_LOTES_ARCHIVO = @FA_CANT_LOTES_ARCHIVO + 1;
		SET @CantRegistrosTotal +=1;
		SET @CL_NUM_LOTE_CAB_NEW +=1;
		SET @CL_NUMERO_LOTE = RIGHT(concat(replicate(''0'', 7), (@CL_NUMERO_LOTE + 1)), 7);
		SET @CL_IDENTIFICACION_EMP_IND = replicate(''0'', 10);
		SET @CL_DIGITO_VERIFICADOR = ''0'';
		SET @CL_NOMBRE_EMPRESA_INDIVIDUO =  LEFT(concat('''',replicate('' '', 16)),16);
			
		SET @CL_CABECERA = concat(@CL_ID_REG
									, @CL_CODIGO_CLASE_TRANSAC
									, @CL_NOMBRE_EMPRESA_INDIVIDUO
									, @CL_INFORMACION_DISCRECIONAL
									, @CL_IDENTIFICACION_EMP_IND
									, @CL_TIPO_REGISTRO
									, @CL_RESERVADO
									, @CL_FECHA_PRESENTACION
									, @CL_FECHA_COMPENSACION
									, @CL_MONEDA_TRANSACCION
									, @CL_DIGITO_VERIFICADOR
									, @CL_ID_ENTIDAD_ORIGEN
									, @CL_NUMERO_LOTE);
		INSERT INTO dbo.VTA_TRANSFERENCIAS_TEMP (LINEA) VALUES (@CL_CABECERA);
	END 
	
	DECLARE CursorLote CURSOR FOR
	
	
	SELECT 

			A.ORD_NRO_DOC, 
			A.BEN_BANCO, 
			A.OP_CLASE_TRANS,
			RIGHT(REPLICATE(''0'',7) + CAST(ROW_NUMBER() OVER(ORDER BY A.ORD_NRO_DOC,A.BEN_BANCO,A.OP_CLASE_TRANS ASC) AS VARCHAR(10)), 7) AS NUM_LOTE_CAB,
(CASE WHEN (A.ORD_TIPO_DOC NOT IN (SELECT TIPODOCUMENTO FROM CLI_TIPOSDOCUMENTOS WHERE TIPOPERSONA=''F'') AND OP_TIPO NOT IN (11,9) ) or OP_TIPO=8  THEN SUBSTRING(CAST(A.ORD_NRO_DOC AS VARCHAR(11)),1,10) ELSE REPLICATE(''0'',10) END) AS CL_IDENTIFICACION_EMP_IND,
(CASE WHEN (A.ORD_TIPO_DOC NOT IN (SELECT TIPODOCUMENTO FROM CLI_TIPOSDOCUMENTOS WHERE TIPOPERSONA=''F'')AND OP_TIPO NOT IN (11,9) ) or OP_TIPO=8  THEN SUBSTRING(CAST(A.ORD_NRO_DOC AS VARCHAR(11)),11,1) ELSE ''0'' END) AS CL_DIGITO_VERIFICADOR,
LEFT((CASE WHEN (A.ORD_TIPO_DOC NOT IN (SELECT TIPODOCUMENTO FROM CLI_TIPOSDOCUMENTOS WHERE TIPOPERSONA=''F'')AND OP_TIPO NOT IN (11,9)) or OP_TIPO=8 THEN ORD_NOMBRE ELSE ''PARTICULARES'' END) + REPLICATE('' '',16),16) AS CL_NOMBRE_EMPRESA_INDIVIDUO,
           RIGHT(CONCAT(''000'',(SELECT TOP 1 ADICIONAL_PRESENT FROM VTA_TRANSFERENCIAS_TIPOS WHERE ID_TIPO=OP_TIPO AND TZ_LOCK=0) ),3) AS CL_MONEDA_TRANSACCION
		FROM 
		(
			SELECT DISTINCT VT1.OP_TIPO, VT1.ORD_TIPO_DOC, VT1.ORD_NRO_DOC, VT1.BEN_BANCO,VT1.OP_CLASE_TRANS,VT1.ORD_NOMBRE
			FROM VTA_TRANSFERENCIAS VT1
			WHERE VT1.OP_CLASE_TRANS = ''R'' and VT1.ESTADO=''RC'' and VT1.OP_MONEDA = 2 
				AND VT1.CONTABILIZADA<> ''R'' AND VT1.TZ_LOCK=0
		) A
	OPEN CursorLote
	FETCH NEXT FROM CursorLote INTO @CL_ORD_NRO_DOC, @CL_BEN_BANCO, @CL_OP_CLASE_TRANS, @CL_NUM_LOTE_CAB, @CL_IDENTIFICACION_EMP_IND, @CL_DIGITO_VERIFICADOR, @CL_NOMBRE_EMPRESA_INDIVIDUO,@CL_MONEDA_TRANSACCION 
	

	WHILE @@FETCH_STATUS = 0
	BEGIN
	   

	SET @FA_CANT_LOTES_ARCHIVO = @FA_CANT_LOTES_ARCHIVO + 1;
	SET @CantRegistrosTotal +=1;
	SET @CL_NUM_LOTE_CAB_NEW +=1;
	
	SET @CL_NUMERO_LOTE = @CL_NUM_LOTE_CAB;

	
		SET @CL_CABECERA = concat(@CL_ID_REG
									, @CL_CODIGO_CLASE_TRANSAC
									, @CL_NOMBRE_EMPRESA_INDIVIDUO
									, @CL_INFORMACION_DISCRECIONAL
									, @CL_IDENTIFICACION_EMP_IND
									, @CL_TIPO_REGISTRO
									, @CL_RESERVADO
									, @CL_FECHA_PRESENTACION
									, @CL_FECHA_COMPENSACION
									, @CL_MONEDA_TRANSACCION
									, @CL_DIGITO_VERIFICADOR
									, @CL_ID_ENTIDAD_ORIGEN
									, @CL_NUMERO_LOTE);
		----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
		--- Grabar la cabecera de lote ---------------------------------------------------------------------------------------------------------------------------------------------------------------
		INSERT INTO VTA_TRANSFERENCIAS_TEMP (LINEA) VALUES (@CL_CABECERA);
		----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
	--- Variables Registro Individual -------------------------------------------------------------------------------------------------------------------------------------------------------------
	DECLARE @RI_ID_REG VARCHAR(1) = ''6'';  
	DECLARE @RI_CODIGO_TRANSAC VARCHAR(2) = ''31'';
	DECLARE @RI_ENTIDAD_AACREDITAR VARCHAR(8);
--s	DECLARE @RI_RESERVADO VARCHAR(1) = ''0'';
--s	DECLARE @RI_CUENTA_AACREDITAR VARCHAR(17); 
  	DECLARE @RI_CUENTA_AACREDITAR VARCHAR(14); 
--s	DECLARE @RI_IMPORTE VARCHAR(10); 
    DECLARE @RI_IMPORTE VARCHAR(14); 
	DECLARE @RI_REFERENCIA_UNIVOCA VARCHAR(15); 
	DECLARE @RI_IDENTIFICACION_CLIENTE_BEN VARCHAR(22);
	DECLARE @RI_MONEDA VARCHAR(2);
	DECLARE @RI_REGISTRO_ADICIONAL VARCHAR(1) = ''1''; 
	DECLARE @RI_CONTADOR_REGISTRO VARCHAR(15);
	
	
	DECLARE @RI_REGISTRO_INDIVIDUAL VARCHAR (200);
	
	-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--- Variables Registro Adicional------------------------------------------------------------------------------------------------------------------------------------------------------
	DECLARE @RA_ID_REG VARCHAR(1) = ''7''; 
	DECLARE @RA_CODIGO_TIPO_ADICIONAL VARCHAR(2) = ''99'';
	DECLARE @RA_CODIGO_MOTIVO_RECHAZO VARCHAR(3);
	DECLARE @RA_CONTADOR_REG_TRAN_ORIGINAL VARCHAR(15);	--Contador de registro de transacción original
	DECLARE @RA_RESERVADO VARCHAR(6) = replicate('' '', 6);
	DECLARE @RA_ENTIDAD_TRAN_ORIGINAL VARCHAR(8);									
	DECLARE @RA_INFORMACION_ADICIONAL VARCHAR(44);
	DECLARE @RA_CONTADOR_REGISTRO VARCHAR(15);
	
	DECLARE @RA_REGISTRO_ADICIONAL VARCHAR (200);
	
	-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	

	--------------------------------------------------------------------------------------------------------------------------------------------- 		
--------------------------------------------------------------------------------------------------------------
	--- Grabar registro individual ---------------------------------------------------------------------------------------------------------------------------------------------------------------

	DECLARE @DP_BANCO NUMERIC(5);
	DECLARE @DP_SUCURSAL NUMERIC(5);
	DECLARE @DP_NUMERO_CUENTA varchar(20);

	DECLARE @DP_IMPORTE NUMERIC(15,2);
	
	------- Variables generales ------------
	DECLARE @SumaImportes NUMERIC(15) = 0;
	DECLARE @TotalesControl NUMERIC(10) = 0;
	DECLARE @TotalesDebitos NUMERIC(15,2) = 0;
	DECLARE @TotalesCreditos NUMERIC(15,2) = 0;
	
	
	DECLARE @SumaEntidad NUMERIC = 0;
	DECLARE @SumaSucursal NUMERIC = 0;
	DECLARE @SobranteSucursal NUMERIC = 0;
	DECLARE @Excedente NUMERIC(15,2) = 0;
	DECLARE @CountExcedente INT = 0;
	------------------------------------------  
	DECLARE CursorTransferencias CURSOR FOR
	
	SELECT
	    --3 Entidad a acreditar
	    	    RIGHT(''0000'' + CAST(TR.ORD_BANCO AS VARCHAR(4)), 4) + 
			   RIGHT(''0000'' + CAST(TR.ORD_SUCURSAL AS VARCHAR(4)), 4) AS RI_ENTIDAD_AACREDITAR,--Numero de sucursal destino,
	     (CASE WHEN BEN_CBU='''' THEN replicate(''0'',17) ELSE right(concat(replicate(''0'',17),RIGHT(BEN_CBU,14)),17) END) AS DP_NUMERO_CUENTA, --Cuenta a acreditar
	    TR.OP_IMPORTE AS IMPORTE,--6 importe
	    --7 Referencia univoca de la transferencia
	     CONCAT(LEFT(TR.OP_REFERENCIA + REPLICATE('' '',3),3),--Código de referencia de la transferencia.
	     RIGHT(REPLICATE(''0'',12) + CAST(TR.OP_NUMERO AS VARCHAR(10)), 12)) AS RI_REFERENCIA_UNIVOCA,--Referencia univoca de la transferencia
	    --8 Identificación del cliente beneficiario
	     LEFT(CAST(concat(
		 (CASE WHEN TR.BEN_TIPO_DOC = ''CUIT'' THEN ''1'' WHEN TR.BEN_TIPO_DOC = ''CUIL'' THEN ''2'' ELSE ''3'' END),
	     RIGHT(REPLICATE(''0'',11) + CAST(TR.BEN_NRO_DOC AS VARCHAR(11)), 11),--En las 11 posiciones siguientes el número de clave fiscal
	     REPLICATE('' '',7),--7 espacios en blanco
	     RIGHT(REPLICATE(''0'',3) +
	     (CASE WHEN TR.OPERATORIA_BCRA=NULL THEN ''000'' ELSE TR.OPERATORIA_BCRA END --código de operatoria del BCRA:73,74,75, se incluye el CERO (Total 3 dígitos)
	     ),3))
	     --código de operatoria del BCRA:73,74,75
	       AS VARCHAR(22)) + REPLICATE('' '',22),22) AS RI_IDENTIFICACION_CLIENTE_BEN,  
	     RIGHT(CONCAT(''00'',(SELECT TOP 1 ADICIONAL_PRESENT FROM VTA_TRANSFERENCIAS_TIPOS WHERE ID_TIPO=TR.OP_TIPO AND TZ_LOCK=0) ),2) AS RI_MONEDA--Tipo de transferencia
		 ,RIGHT(''0000'' + CAST(TR.ORD_BANCO AS VARCHAR(4)), 4) AS DP_BANCO
	     ,RIGHT(''0000'' + CAST(TR.ORD_SUCURSAL AS VARCHAR(4)), 4) AS DP_SUCURSAL
		 ,RIGHT(CONCAT(''000'',(SELECT codigo_nacha FROM SNP_MOTIVOS_RECHAZO WHERE id_motivo=TR.MOTIVO_RECHAZO AND FUNCIONALIDAD=''TR'' AND TZ_LOCK=0)),3) AS RA_CODIGO_MOTIVO_RECHAZO
		 ,CONCAT(RIGHT(REPLICATE(''0'',4) + 
	    	(CASE WHEN TR.OP_MONEDA=2 THEN 
	    		CAST((TR.BEN_BANCO + 500) AS VARCHAR(10))
	    		ELSE
	    		CAST(TR.BEN_BANCO AS VARCHAR(10)) END)
	    		, 4), --Número de entidad destino
	    RIGHT(REPLICATE(''0'',4) + SUBSTRING(TR.BEN_CBU,4,4),4)) AS RA_ENTIDAD_TRAN_ORIGINAL
		 ,LEFT(UPPER((SELECT TOP 1 dbo.RemoveAccents(descripcion) FROM SNP_MOTIVOS_RECHAZO WHERE id_motivo=TR.MOTIVO_RECHAZO AND FUNCIONALIDAD=''TR'' AND TZ_LOCK=0)) + REPLICATE('' '',44),44) AS RA_INFORMACION_ADICIONAL
		 ,RIGHT(''000000000000000'' + CAST(TR.TRACENUMBER AS VARCHAR(15)), 15) AS RA_CONTADOR_REG_TRAN_ORIGINAL
	    FROM VTA_TRANSFERENCIAS TR (NOLOCK)
	    WHERE 
	    	TR.OP_CLASE_TRANS = ''R'' and TR.ESTADO=''RC'' 
	    	AND TR.OP_MONEDA = 2 AND TR.TZ_LOCK=0
	    	AND TR.CONTABILIZADA<> ''R'' AND TR.ORD_NRO_DOC=@CL_ORD_NRO_DOC AND TR.BEN_BANCO=@CL_BEN_BANCO AND TR.OP_CLASE_TRANS=@CL_OP_CLASE_TRANS
	    ORDER BY TR.ORD_NRO_DOC,TR.BEN_BANCO,TR.OP_TIPO ASC
	
	OPEN CursorTransferencias
	FETCH NEXT FROM CursorTransferencias INTO @RI_ENTIDAD_AACREDITAR
											, @DP_NUMERO_CUENTA
											, @DP_IMPORTE
											, @RI_REFERENCIA_UNIVOCA
											, @RI_IDENTIFICACION_CLIENTE_BEN
											, @RI_MONEDA
											, @DP_BANCO
											, @DP_SUCURSAL
											, @RA_CODIGO_MOTIVO_RECHAZO
											, @RA_ENTIDAD_TRAN_ORIGINAL
											, @RA_INFORMACION_ADICIONAL
											, @RA_CONTADOR_REG_TRAN_ORIGINAL
	        
	WHILE @@FETCH_STATUS = 0
	BEGIN
		Start:
--s		IF (@SumaImportes > 9999999999.99 OR @SumaEntidad > 999999 OR @FA_SUMA_ACUMULADA > 999999999999.99)
		IF (@SumaImportes > 999999999999.99 OR @SumaEntidad > 999999 OR @FA_SUMA_ACUMULADA > 999999999999999999.99)

		BEGIN
		
			IF @SumaSucursal > 9999
			BEGIN
				SET @SobranteSucursal = CAST(substring(CAST(@SumaSucursal AS VARCHAR), 1, (len(@SumaSucursal) - 4)) AS NUMERIC);
				SET @SumaEntidad += @SobranteSucursal;
				SET @SumaSucursal = CAST(RIGHT(@SumaSucursal, 4) AS NUMERIC);
			END
			
			SET @TotalesControl += @SumaEntidad + @SumaSucursal;
		   	SET @FL_TOTALES_DE_CONTROL = concat(right(concat(replicate(''0'', 6), @SumaEntidad), 6), right(concat(replicate(''0'', 4),@SumaSucursal), 4)); --relleno y separo con ceros

			SET @FL_SUMA_TOTAL_DEBITO_LOTE  = RIGHT(replicate(''0'', 12), 12);
		   	SET @FL_SUMA_TOTAL_CREDITO_LOTE = RIGHT(concat(replicate(''0'', 12), (replace((SELECT sum(convert(bigint, substring(linea,30,10))) FROM VTA_TRANSFERENCIAS_TEMP WHERE LINEA LIKE ''6%'' AND id>(SELECT max(id) FROM VTA_TRANSFERENCIAS_TEMP WHERE LINEA LIKE ''5%'')), ''.'', ''''))), 12);  
			SET @TotalesCreditos += @SumaImportes
			SET @FA_SumaEntidad = @FA_SumaEntidad + @SumaEntidad
			SET @FA_SumaSucursal = @FA_SumaSucursal + @SumaSucursal
		  
			SET @FL_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 6), (SELECT count(id) 
																			 FROM VTA_TRANSFERENCIAS_TEMP t
																			 WHERE t.ID>(SELECT max(tt.id) 
		  																				 FROM VTA_TRANSFERENCIAS_TEMP tt
		  																				 WHERE tt.LINEA LIKE ''5%'')	
																			 AND substring(t.LINEA,1,1) IN (''6'',''7''))), 6);


		   	
		 
		   	SET @FL_FIN_LOTE = concat(@FL_ID_REG, @FL_CODIGO_CLASE_TRANSAC,@FL_CANT_REG_INDIVIDUAL_ADICIONAL, @FL_TOTALES_DE_CONTROL, @FL_SUMA_TOTAL_DEBITO_LOTE, @FL_SUMA_TOTAL_CREDITO_LOTE, @CL_IDENTIFICACION_EMP_IND, @FL_RESERVADO2, @FL_RESERVADO3, @FL_REG_ENTIDAD_ORIGEN, @CL_NUMERO_LOTE);	
			
			INSERT INTO dbo.VTA_TRANSFERENCIAS_TEMP (LINEA) VALUES (replace(@FL_FIN_LOTE, '''', ''''));
			

			-------------------------------------------------------------------
			-------------Grabamos el Fin de Archivo ----------------------------------------------------------------------------------------------------------------------
			SET @FA_TOTALES_DE_CONTROL = concat(right(concat(replicate(''0'', 6), @FA_SumaEntidad), 6), right(concat(replicate(''0'', 4),@FA_SumaSucursal), 4));
			SET @FA_CANT_LOTES = RIGHT(concat(replicate(''0'', 6), @FA_CANT_LOTES_ARCHIVO), 6);
			SET @FA_NUMERO_BLOQUES = RIGHT(CONCAT(REPLICATE(''0'',6) , CAST((CASE WHEN @CantRegistrosTotal % 10 = 0 THEN (@CantRegistrosTotal/10) ELSE (FLOOR(@CantRegistrosTotal /10) + 1) END) AS INTEGER)),6);
	
			SET @FA_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 8), @CantRegistros*2), 8);
			SET @FA_TotalesCreditos = @FA_TotalesCreditos + @SumaImportes
			SET @FA_SUMA_TOTAL_DEBITOS = RIGHT(concat(replicate(''0'', 12), (replace(@TotalesDebitos, ''.'', ''''))), 12);
			SET @FA_SUMA_TOTAL_CREDITOS = RIGHT(concat(replicate(''0'', 12), (replace((SELECT sum(convert(bigint, substring(linea,30,10))) FROM VTA_TRANSFERENCIAS_TEMP WHERE LINEA LIKE ''6%'' AND id>(SELECT max(id) FROM VTA_TRANSFERENCIAS_TEMP WHERE LINEA LIKE ''1%'')), ''.'', ''''))), 12);  

	
			SET @FA_FIN_ARCHIVO = concat(@FA_ID_REG, RIGHT(REPLICATE(''0'',6) + CAST(@CL_NUM_LOTE_CAB_NEW AS VARCHAR(6)),6), @FA_NUMERO_BLOQUES, @FA_CANT_REG_INDIVIDUAL_ADICIONAL, @FL_TOTALES_DE_CONTROL, @FA_SUMA_TOTAL_DEBITOS, @FA_SUMA_TOTAL_CREDITOS, @FA_RESERVADO);
			
	
			INSERT INTO dbo.VTA_TRANSFERENCIAS_TEMP (LINEA) VALUES (@FA_FIN_ARCHIVO);
			------------------------------------------------------------------------------------------------------------------------------------------------------------------
			---------- Limpiamos variables -----------------------------------------------------------------------------------------------------------------------------------
			SET @SumaImportes = 0;
			SET @CantRegistros = 0; 
			SET @CantRegistrosTotal = 0; --le sumo 2, que corresponden a los registros CL y FL ya que en teoria se creo un nuevo lote
	
			SET @TotalesControl = 0;
			SET @TotalesDebitos = 0;
			SET @TotalesCreditos = 0;
	
			SET @SumaEntidad = 0;
			SET @SumaSucursal = 0;
			SET @FA_SumaEntidad = 0;
			SET @FA_SumaSucursal = 0;
			
			SET @FL_CANT_REG_INDIVIDUAL_ADICIONAL = 0;
			SET @FL_TOTALES_DE_CONTROL = 0;
			SET @FA_SUMA_TOTAL_DEBITOS = 0;
			SET @FA_SUMA_TOTAL_CREDITOS = 0;
			SET @FA_TotalesCreditos = 0;
			SET @CL_NUM_LOTE_CAB_NEW = 0
			SET @CL_NUM_LOTE_CAB_NEW +=1;
			SET @FA_SUMA_ACUMULADA = 0;
			-------------------------------------------------------------------------------------------------------------------------------------------------------------------
			--------- Grabamos nueva Cabecera de Archivo ----------------------------------------------------------------------------------------------------------------------
		    SET @CA_CABECERA = concat(@CA_ID_REG, @CA_CODIGO_PRIORIDAD, @CA_DESTINO_INMEDIATO, @CA_ORIGEN_INMEDIATO, @CA_FECHA_PRESENTACION, @CA_HORA_PRESENTACION, @CA_IDENTIFICADOR_ARCHIVO, @CA_TAMANNO_REGISTRO, @CA_FACTOR_BLOQUE, @CA_CODIGO_FORMATO, @CA_NOMBRE_DEST_INMEDIATO, @CA_NOMBRE_ORIG_INMEDIATO, @CA_CODIGO_REFERENCIA);
			
			INSERT INTO dbo.VTA_TRANSFERENCIAS_TEMP (LINEA) VALUES (@CA_CABECERA);
			----------------------------------------------------------------------------------------------------------------------------------------------------------------------
			--------- Grabamos nueva Cabecera Lote ------------------------------------------------------------------------------------------------------------------------------------------------------
			SET @CL_CABECERA = concat(@CL_ID_REG, @CL_CODIGO_CLASE_TRANSAC, @CL_NOMBRE_EMPRESA_INDIVIDUO, @CL_INFORMACION_DISCRECIONAL, @CL_IDENTIFICACION_EMP_IND, @CL_TIPO_REGISTRO, @CL_RESERVADO, @CL_FECHA_PRESENTACION, @CL_FECHA_COMPENSACION, @CL_MONEDA_TRANSACCION, @CL_DIGITO_VERIFICADOR, @CL_ID_ENTIDAD_ORIGEN, right(concat(replicate(''0'',7),@CL_NUMERO_LOTE),7));
			
			INSERT INTO dbo.VTA_TRANSFERENCIAS_TEMP (LINEA) VALUES (@CL_CABECERA);
	
	
			---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		SET @FA_CANT_LOTES_ARCHIVO = 0;
		
		END
		
		SET @CantRegistros += 1;
	    SET @CantRegistrosTotal = @CantRegistrosTotal + 2;
	    SET @FA_SUMA_ACUMULADA = @FA_SUMA_ACUMULADA + @RI_IMPORTE;
		SET @FL_CANT_REG_INDIVIDUAL_ADICIONAL += 1;
			
		IF	(@Excedente<>0)
			BEGIN
			SET @DP_IMPORTE = @Excedente;
			SET @CountExcedente += 1;
			END
--s		IF	(@DP_IMPORTE > 99999999.99)
		IF	(@DP_IMPORTE > 999999999999.99)
			BEGIN
			SET @Excedente = (@DP_IMPORTE - 999999999999.99);
			SET @DP_IMPORTE = 999999999999.99;
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
	
			SET @RI_ENTIDAD_AACREDITAR= concat(RIGHT(concat(replicate(''0'', 4), @DP_BANCO), 4), ''0888'');
--s	        SET @RI_CUENTA_AACREDITAR = RIGHT(concat(replicate(''0'', 17), ''88888888888''), 17);
	        SET @RI_CUENTA_AACREDITAR = RIGHT(concat(replicate(''0'', 14), ''88888888888''), 14);

	
		END
	    ELSE --la razon de este else, es que SumaSucursal, cuando hay excedente tiene que acumular 0888
	    BEGIN
			
			SET @SumaSucursal += @DP_SUCURSAL;
			SET @SumaEntidad += @DP_BANCO;
			SET @SumaImportes += @DP_IMPORTE;
			
			------ Registro Individual -------
			SET @RI_ENTIDAD_AACREDITAR =concat(RIGHT(concat(replicate(''0'', 4), @DP_BANCO), 4), RIGHT(concat(replicate(''0'', 4), @DP_SUCURSAL), 4)); 
--s			SET @RI_CUENTA_AACREDITAR = RIGHT(concat(replicate(''0'', 17), @DP_NUMERO_CUENTA), 17); 
    		SET @RI_CUENTA_AACREDITAR = RIGHT(concat(replicate(''0'', 14), @DP_NUMERO_CUENTA), 14); 
		
		END
--s		IF @SumaImportes>9999999999.99 GOTO Start
		IF @SumaImportes>999999999999999999.99 GOTO Start
--s		SET @RI_IMPORTE = RIGHT(concat(replicate(''0'', 10), replace(CAST(@DP_IMPORTE AS VARCHAR),''.'','''')), 10);
		SET @RI_IMPORTE = RIGHT(concat(replicate(''0'', 14), replace(CAST(@DP_IMPORTE AS VARCHAR),''.'','''')), 14);
		
	    --Condicion de reset del contador de reg individual
	 	IF ISNULL((SELECT a.FECHA FROM ITF_MASTER_PARAMETROS a WHERE a.CODIGO = 422), CAST(''01-01-1800'' AS DATETIME)) <> (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK))
	  
		    UPDATE dbo.ITF_MASTER_PARAMETROS SET NUMERICO_1 = 1, FECHA = (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)) WHERE CODIGO = 422;
	   
		SET @RI_CONTADOR_REGISTRO = concat(@RA_ENTIDAD_TRAN_ORIGINAL, RIGHT(concat(replicate(''0'', 7), (SELECT a.NUMERICO_1 FROM ITF_MASTER_PARAMETROS a WHERE CODIGO = 422)), 7)); 
			
	    --Incremento el contador
	    UPDATE dbo.ITF_MASTER_PARAMETROS SET NUMERICO_1 += 1 WHERE CODIGO = 422;
	
		SET @RI_REGISTRO_INDIVIDUAL = concat(@RI_ID_REG, @RI_CODIGO_TRANSAC, @RI_ENTIDAD_AACREDITAR, @RI_CUENTA_AACREDITAR, @RI_IMPORTE, @RI_REFERENCIA_UNIVOCA, @RI_IDENTIFICACION_CLIENTE_BEN, @RI_MONEDA, @RI_REGISTRO_ADICIONAL, @RI_CONTADOR_REGISTRO);
	
		INSERT INTO VTA_TRANSFERENCIAS_TEMP (LINEA) VALUES (replace(@RI_REGISTRO_INDIVIDUAL, '''', ''''));
		
		--- Grabar Registro Adicional -----------------------------------------------------------------------------
	
	SET @RA_REGISTRO_ADICIONAL = concat(@RA_ID_REG
											, @RA_CODIGO_TIPO_ADICIONAL
											, @RA_CODIGO_MOTIVO_RECHAZO
											, @RA_CONTADOR_REG_TRAN_ORIGINAL
											, @RA_RESERVADO
											, @RA_ENTIDAD_TRAN_ORIGINAL
											, @RA_INFORMACION_ADICIONAL
											, @RI_CONTADOR_REGISTRO);	

		INSERT INTO VTA_TRANSFERENCIAS_TEMP (LINEA) VALUES (replace(@RA_REGISTRO_ADICIONAL, '''', ''''));
		

	IF (@Excedente = 0)
	BEGIN		     	
	
	FETCH NEXT FROM CursorTransferencias INTO @RI_ENTIDAD_AACREDITAR, @DP_NUMERO_CUENTA, @DP_IMPORTE, @RI_REFERENCIA_UNIVOCA, @RI_IDENTIFICACION_CLIENTE_BEN, @RI_MONEDA, @DP_BANCO, @DP_SUCURSAL, @RA_CODIGO_MOTIVO_RECHAZO, @RA_ENTIDAD_TRAN_ORIGINAL, @RA_INFORMACION_ADICIONAL ,@RA_CONTADOR_REG_TRAN_ORIGINAL
	SET @CountExcedente = 0;
	END
		
	END	--Fin del cursor CursorTransferencias
	        
	CLOSE CursorTransferencias
	DEALLOCATE CursorTransferencias
	
	IF @SumaSucursal > 9999
	BEGIN
		SET @SobranteSucursal = 0;
		SET @SobranteSucursal = CAST(substring(CAST(@SumaSucursal AS VARCHAR), 1, (len(@SumaSucursal) - 4)) AS NUMERIC);
		SET @SumaEntidad += @SobranteSucursal;
		SET @SumaSucursal = CAST(RIGHT(@SumaSucursal, 4) AS NUMERIC);
	END
			
	
	SET @FL_TOTALES_DE_CONTROL = concat(right(concat(replicate(''0'', 6), @SumaEntidad), 6), right(concat(replicate(''0'', 4),@SumaSucursal), 4)); --relleno y separo con ceros
	
	SET @TotalesControl += CAST(@FL_TOTALES_DE_CONTROL AS INTEGER); --lo uso para armar el totalControl del reg FA
	

	SET @FL_SUMA_TOTAL_DEBITO_LOTE  = replicate(''0'', 12);
		   	SET @FL_SUMA_TOTAL_CREDITO_LOTE = RIGHT(concat(replicate(''0'', 12), (replace((SELECT sum(convert(bigint, substring(linea,30,10))) FROM VTA_TRANSFERENCIAS_TEMP WHERE LINEA LIKE ''6%'' AND id>(SELECT max(id) FROM VTA_TRANSFERENCIAS_TEMP WHERE LINEA LIKE ''5%'')), ''.'', ''''))), 12);  

	SET @TotalesCreditos += @SumaImportes;
		  

	SET @CantRegistrosTotal +=1;
	
		
	
	SET @FL_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 6), (SELECT count(id) 
																			 FROM VTA_TRANSFERENCIAS_TEMP t
																			 WHERE t.ID>(SELECT max(tt.id) 
		  																				 FROM VTA_TRANSFERENCIAS_TEMP tt
		  																				 WHERE tt.LINEA LIKE ''5%'')	
																			 AND substring(t.LINEA,1,1) IN (''6'',''7''))), 6);


	
	SET @FL_FIN_LOTE = concat(@FL_ID_REG, @FL_CODIGO_CLASE_TRANSAC, @FL_CANT_REG_INDIVIDUAL_ADICIONAL, @FL_TOTALES_DE_CONTROL, @FL_SUMA_TOTAL_DEBITO_LOTE, @FL_SUMA_TOTAL_CREDITO_LOTE, @CL_IDENTIFICACION_EMP_IND, @FL_RESERVADO2, @FL_RESERVADO3, @FL_REG_ENTIDAD_ORIGEN, @CL_NUMERO_LOTE);			
		-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
	--- Grabamos la fin de lote del archivo ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	INSERT INTO dbo.VTA_TRANSFERENCIAS_TEMP (LINEA) VALUES (replace(@FL_FIN_LOTE, '''', ''''));
	
	SET @FA_SumaEntidad = @FA_SumaEntidad + @SumaEntidad
	SET @FA_SumaSucursal = @FA_SumaSucursal + @SumaSucursal
	SET @FA_TotalesCreditos = @FA_TotalesCreditos + @SumaImportes
	
	--------------------------------------------------------------------------------------------------------------------
	FETCH NEXT FROM CursorLote INTO @CL_ORD_NRO_DOC, @CL_BEN_BANCO, @CL_OP_CLASE_TRANS, @CL_NUM_LOTE_CAB, @CL_IDENTIFICACION_EMP_IND, @CL_DIGITO_VERIFICADOR, @CL_NOMBRE_EMPRESA_INDIVIDUO,@CL_MONEDA_TRANSACCION
	
	END --Fin del cursor CursoLote
	
	CLOSE CursorLote
	DEALLOCATE CursorLote
	--------------------------------------------------------------------------------------------------------------------
	IF (SELECT count(1) FROM VTA_TRANSFERENCIAS_TEMP WHERE LINEA LIKE ''6%'')=0
	BEGIN
		SET @FL_FIN_LOTE = concat(@FL_ID_REG, @FL_CODIGO_CLASE_TRANSAC,@FL_CANT_REG_INDIVIDUAL_ADICIONAL, @FL_TOTALES_DE_CONTROL, @FL_SUMA_TOTAL_DEBITO_LOTE, @FL_SUMA_TOTAL_CREDITO_LOTE, @CL_IDENTIFICACION_EMP_IND, @FL_RESERVADO2, @FL_RESERVADO3, @FL_REG_ENTIDAD_ORIGEN, @CL_NUMERO_LOTE);	
			
		INSERT INTO dbo.VTA_TRANSFERENCIAS_TEMP (LINEA) VALUES (replace(@FL_FIN_LOTE, '''', ''''));
	END 
	-------------Grabamos el Fin de Archivo -------------------------------------------------------------------------------------------------------------------------------------
	SET @FA_TOTALES_DE_CONTROL = concat(right(concat(replicate(''0'', 6), @FA_SumaEntidad), 6), right(concat(replicate(''0'', 4),@FA_SumaSucursal), 4));
	SET @FA_CANT_LOTES = RIGHT(concat(replicate(''0'', 6), CAST(@FA_CANT_LOTES_ARCHIVO AS NUMERIC)), 6);
	SET @FA_NUMERO_BLOQUES = RIGHT(CONCAT(REPLICATE(''0'',6) , CAST((CASE WHEN @CantRegistrosTotal % 10 = 0 THEN (@CantRegistrosTotal/10) ELSE (FLOOR(@CantRegistrosTotal /10) + 1) END) AS INTEGER)),6);
	
	SET @FA_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 8), @CantRegistros*2), 8);
			
	SET @FA_SUMA_TOTAL_DEBITOS = RIGHT(concat(replicate(''0'', 12), (replace(@TotalesDebitos, ''.'', ''''))), 12);
	SET @FA_SUMA_TOTAL_CREDITOS = RIGHT(concat(replicate(''0'', 12), (replace((SELECT sum(convert(bigint, substring(linea,30,10))) FROM VTA_TRANSFERENCIAS_TEMP WHERE LINEA LIKE ''6%'' AND id>(SELECT max(id) FROM VTA_TRANSFERENCIAS_TEMP WHERE LINEA LIKE ''1%'')), ''.'', ''''))), 12);  
	PRINT @FA_ID_REG 	
	SET @FA_TOTALES_DE_CONTROL =RIGHT(concat(replicate(''0'', 10), (SELECT sum(convert(numeric,substring(LINEA,4,8)))
																 FROM VTA_TRANSFERENCIAS_TEMP
														  		 WHERE LINEA LIKE ''6%'' AND ID >(SELECT max(tt.id) 
		  																  FROM VTA_TRANSFERENCIAS_TEMP tt
		  																  WHERE tt.LINEA LIKE ''1%''))), 10);
	
	SET @FA_FIN_ARCHIVO = concat(@FA_ID_REG, RIGHT(REPLICATE(''0'',6) + CAST(@CL_NUM_LOTE_CAB_NEW AS VARCHAR(6)),6), @FA_NUMERO_BLOQUES, @FA_CANT_REG_INDIVIDUAL_ADICIONAL, @FA_TOTALES_DE_CONTROL, @FA_SUMA_TOTAL_DEBITOS, @FA_SUMA_TOTAL_CREDITOS, @FA_RESERVADO);
	
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	--- Grabar fin de archivo ---------------------------------------------------------------------------------------------------------------------------------------------------------------
	INSERT INTO dbo.VTA_TRANSFERENCIAS_TEMP (LINEA) VALUES (@FA_FIN_ARCHIVO);
	----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
	----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
	END TRY
	
	BEGIN CATCH  
	    SELECT   
	        ERROR_NUMBER() AS ErrorNumber  
	       ,ERROR_MESSAGE() AS ErrorMessage
	       ,ERROR_LINE() AS ErrorLine;  
	END CATCH

END;
'); 

EXECUTE('
CREATE OR ALTER PROCEDURE [dbo].[SP_TRAN_MINORISTA_RECIBIDAS_V2]
	@TICKET NUMERIC(16),
	@MONEDA_IN NUMERIC(1),
	@CODREGISTRO_IN VARCHAR(3),
	@ARCHIVO VARCHAR(30)
	, @MSJ 	VARCHAR(500) OUTPUT
AS
BEGIN 
BEGIN TRANSACTION;

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
	DECLARE @OrigenInmediato VARCHAR(10);
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
					--variables para validacion mandatorios fin de archivo
		DECLARE @cantLotesAux VARCHAR(6);		
		DECLARE @numBloquesAux VARCHAR(6);
		DECLARE @cantRegAuxFA VARCHAR(8);
		DECLARE @valMandFA NUMERIC(1);	
		
			DECLARE @BenBanco NUMERIC(6,0);
				DECLARE @nombreEO VARCHAR(50)
				DECLARE @nombreBEN VARCHAR(50)

	/******** Variables Cabecera de Lote **********************************/
	DECLARE @FechaVencimiento DATE;
	DECLARE @FechaCompensacion DATE;
	DECLARE @VFechaVencimiento VARCHAR(6);
	DECLARE @VFechaCompensacion VARCHAR(6);
	DECLARE @ClaseTransaccion VARCHAR(3);
	DECLARE @ReservadoLote VARCHAR(46);
	DECLARE @Tipo_Transferencia_CL VARCHAR(3);
	DECLARE @CodigoOrigen  NUMERIC(1);
	DECLARE @CodigoRegistro VARCHAR(3);
	DECLARE @IdEntidadOrigen NUMERIC(8);
	DECLARE @OrdBanco NUMERIC(4,0);
	DECLARE @OrdSucursal NUMERIC(4,0);
	declare @NumeroLote NUMERIC(7);
	DECLARE @IdEmpresa VARCHAR(10);
		DECLARE @CUIT_EO NUMERIC(11,0);
					--variables para validacion mandatorios fin de lote
		DECLARE @lineaAux VARCHAR(95);
		DECLARE @idRegistroAux VARCHAR(1);
		DECLARE @codigoClaseAux VARCHAR(3);		
		DECLARE @cantRegAux VARCHAR(6);
		DECLARE @totControlAux VARCHAR(10);
		DECLARE @totDebAux VARCHAR(12);
		DECLARE @totCredAux VARCHAR(12);
		DECLARE @idEmpresaAux VARCHAR(10);
		DECLARE @idOriginanteAux VARCHAR(8);
		DECLARE @numLoteAux VARCHAR(7);
		DECLARE @valMandFL NUMERIC(1);			
	/******** Variables Registro Individual de Cheques y Ajustes *************/
	DECLARE @CodTransaccion VARCHAR(2);
	DECLARE @EntidadDebitar VARCHAR(8);
--s	DECLARE @ReservadoRI VARCHAR(1);
--s	DECLARE @CuentaDebitar VARCHAR(17);
	DECLARE @CuentaDebitar VARCHAR(14);
--s	DECLARE @VImporte VARCHAR(10); 
	DECLARE @VImporte VARCHAR(16);   
	DECLARE @Importe NUMERIC(15,2) = 0;     
	DECLARE @ReferenciaUnivoca VARCHAR(15);
	DECLARE @IdClientePegador VARCHAR(22);
	DECLARE @InfoAdicional VARCHAR(2);
	DECLARE @RegistrosAdicionales VARCHAR(1);
	DECLARE @ContadorRegistros VARCHAR(15);
	DECLARE @CBU VARCHAR(22);
	DECLARE @CUIT_BEN VARCHAR(11);
	DECLARE @Tipo_transferencia NUMERIC(3,0);
	
	DECLARE @CodRechazo VARCHAR (3);
	DECLARE @Operatoria_BCRA VARCHAR(3);

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
--s	DECLARE @SumaDebLote NUMERIC(12);
--s	DECLARE @SumaCredLote NUMERIC(12);
	DECLARE @SumaDebLote NUMERIC(20);
	DECLARE @SumaCredLote NUMERIC(20);
	DECLARE @ReservadoFL VARCHAR(40);

	/******** Variables FIN DE ARCHIVO *************/

	DECLARE @CantLotesFA NUMERIC(6);
	DECLARE @NumBloquesFA NUMERIC(6);
	DECLARE @CantRegAdFA NUMERIC (8);
	DECLARE @TotalesControlFA NUMERIC(10);
--s	DECLARE @ReservadoFA VARCHAR(39);
	DECLARE @ReservadoFA VARCHAR(23);
	
	
	DECLARE @ESTADOSUC VARCHAR(1);
	DECLARE @SFecVenc VARCHAR(6)
	DECLARE @SFecComp VARCHAR(6)
	DECLARE @SFecVencCA VARCHAR(6)
	      
	      
	/*Validaciones generales */
	
	DECLARE @updRecepcion VARCHAR(1);
	DECLARE @correlativo NUMERIC(10,0)=0;
	DECLARE @Reverso_Directo NUMERIC(1);
	DECLARE @ben_mismo_titular VARCHAR(1)=''N'';
	SET @MSJ = '''';
	DECLARE @FECHADATE DATETIME = (SELECT top 1 FECHAPROCESO FROM PARAMETROS);
	DECLARE @PRODUCTO INT;
	
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
--s		@sumaCreditos_RI = sum(CAST(substring(LINEA, 30, 10) AS NUMERIC)),
		@sumaCreditos_RI = sum(CAST(substring(LINEA, 26, 14) AS NUMERIC)),
		@sumaEntidades_RI = sum(CAST(substring(LINEA, 4, 4) AS NUMERIC)),
		@sumaSucursales_RI = sum(CAST(substring(LINEA, 8, 4) AS NUMERIC))
	FROM ITF_TRAN_MINORISTA_RECIBIDAS_AUX
	WHERE LINEA LIKE ''6%''

	SET @sumaEntidades_RI += isNull(@sumaEntidades_RIaux,0);
	SET @sumaSucursales_RI += isNull(@sumaSucursales_RIaux,0);
	
	--seteo total control y total de importes FA
	SELECT
		@totControl_FA = CAST(substring(linea, 22, 10) AS NUMERIC),
--s		@totalDebitos_FA = CAST(substring(linea, 32, 12) AS NUMERIC),
--s		@totalCreditos_FA = CAST(substring(linea, 44, 12) AS NUMERIC)
		@totalDebitos_FA = CAST(substring(linea, 32, 20) AS NUMERIC),
		@totalCreditos_FA = CAST(substring(linea, 44, 20) AS NUMERIC)
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
--s		@controlDebitos_FL = sum(CAST(substring(LINEA, 21, 12) AS NUMERIC)),
--s		@controlCreditos_FL = sum(CAST(substring(LINEA, 33, 12) AS NUMERIC))
		@controlDebitos_FL = sum(CAST(substring(LINEA, 21, 20) AS NUMERIC)),
		@controlCreditos_FL = sum(CAST(substring(LINEA, 33, 20) AS NUMERIC))
	FROM ITF_TRAN_MINORISTA_RECIBIDAS_AUX
	WHERE LINEA LIKE ''8%'';


	--#validacion5
/**	IF(CONCAT(@sumaEntidades_RI, RIGHT(CONCAT(REPLICATE(''0'',3), @sumaSucursales_RI),4)) <> @sumaTotalCtrl_FL)
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
**/	
	IF(/*@sumaDebitos_RI  <> @controlDebitos_FL AND*/ @sumaDebitos_RI <> @totalDebitos_FA)
	BEGIN
		SET @MSJ = ''No concuerda la suma de Debitos individuales con el Total Debitos Fin Archivo'';
		RETURN
	END
/**	
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
**/	
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
		
		SET @IdRegistro = substring(@LINEA, 1, 1);
		
		/* Cabecera de Archivo */
		IF (@IdRegistro = ''1'') 
      BEGIN
			--variables de cabecera de archivo
			SET @CodigoPrioridad = substring(@LINEA,2,2);
			SET @DestinoInmediato = substring(@LINEA,4 ,10);
			SET @OrigenInmediato  = substring(@LINEA,14 ,10);
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
			
			--validacion mandatorio pie de lote
			SET @lineaAux = (SELECT TOP 1 LINEA FROM ITF_TRAN_MINORISTA_RECIBIDAS_AUX WHERE LINEA LIKE ''9%'' AND ID>@ID)

			SET @idRegistroAux=substring(@lineaAux,1,1);	
			SET @cantLotesAux=substring(@lineaAux,2,6);		
			SET @numBloquesAux=substring(@lineaAux,8,6);
			SET @cantRegAuxFA=substring(@lineaAux,14,8);		
			SET @totControlAux=substring(@lineaAux,22,10)
		 	SET @totDebAux=substring(@lineaAux,32,12);
		 	SET @totCredAux=substring(@lineaAux,44,12);
			SET @valMandFA=1;
			
			IF(
			isnumeric(ltrim(rtrim(@idRegistroAux)))=0 or 
			isnumeric(ltrim(rtrim(@cantLotesAux)))=0 or 
			isnumeric(ltrim(rtrim(@numBloquesAux)))=0 or 
			isnumeric(ltrim(rtrim(@cantRegAuxFA)))=0 or 
			isnumeric(ltrim(rtrim(@totControlAux)))=0 or 
			isnumeric(ltrim(rtrim(@totCredAux)))=0 or 
			isnumeric(ltrim(rtrim(@totDebAux)))=0 
			)
			BEGIN 
				SET @valMandFA=0
			END 


			
		END

		IF (@IdRegistro = ''5'') 
      BEGIN

			--variables cabecera de lote
			SET @ClaseTransaccion = substring(@LINEA, 2, 3);
			SET @ReservadoLote = substring(@LINEA, 5, 46);
			--VALIDACION RESERVADO VACIO
			SET @CodigoRegistro = substring(@LINEA, 51, 3);
			SET @IdEmpresa=substring(@linea,41,10);
			SET @VFechaVencimiento = substring(@LINEA, 64, 6);
			--VALIDACION FECHAS
			SET @VFechaCompensacion = substring(@LINEA, 70, 6);
			SET @Tipo_Transferencia_CL = substring(@LINEA, 76, 3); 
			--VALIDACION RESERVADO 000
			SET @CodigoOrigen = try_convert(INT,substring(@LINEA, 79, 1));
			SET @cuit_EO=try_convert(NUMERIC,concat(@IdEmpresa,@CodigoOrigen))
			SET @IdEntidadOrigen = substring(@LINEA, 80, 8);
			SET @OrdBanco = substring(@LINEA, 80, 4);
			SET @OrdSucursal = substring(@LINEA, 84, 4);
			SET @nombreEO=''''
			SET @nombreBEN=''''
			SELECT TOP 1 @nombreeo=substring(isnull(nombre_completo,''''),1,50) FROM ITF_BCRA_PADFYJ WHERE CUIT=@cuit_EO AND TZ_LOCK=0


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
			
			--validacion mandatorio fin de lote
			SET @lineaAux = (SELECT TOP 1 LINEA FROM ITF_TRAN_MINORISTA_RECIBIDAS_AUX WHERE LINEA LIKE ''8%'' AND ID>@ID)

			SET @idRegistroAux=substring(@lineaAux,1,1);
			SET @codigoClaseAux=substring(@lineaAux,2,3);
			SET @cantRegAux=substring(@lineaAux,5,6);
		 	SET @totControlAux=substring(@lineaAux,11,10);
		 	SET @totDebAux=substring(@lineaAux,21,12);
		 	SET @totCredAux=substring(@lineaAux,33,12);
		 	SET @idEmpresaAux=substring(@lineaAux,45,10);
		 	SET @idOriginanteAux=substring(@lineaAux,80,8);
			SET @numLoteAux=substring(@lineaAux,88,7);
			SET @valMandFL=1;
			IF(
			len(ltrim(rtrim(@idEmpresaAux)))=0 or 
			isnumeric(ltrim(rtrim(@idRegistroAux)))=0 or 
			isnumeric(ltrim(rtrim(@codigoClaseAux)))=0 or 
			isnumeric(ltrim(rtrim(@cantRegAux)))=0 or 
			isnumeric(ltrim(rtrim(@totControlAux)))=0 or 
			isnumeric(ltrim(rtrim(@totDebAux)))=0 or 
			isnumeric(ltrim(rtrim(@totCredAux)))=0 or 
			isnumeric(ltrim(rtrim(@FactorBloque)))=0 or 
			isnumeric(ltrim(rtrim(@CodigoFormato)))=0 
			)
			BEGIN 
				SET @valMandFL=0
			END 			
			
		END

		
		/*FIN DE LOTE*/
		IF (@IdRegistro = ''8'') 
      BEGIN
			SET @ClaseTransaccion = substring(@LINEA, 2, 3);
--s			SET @ReservadoFL = substring(@LINEA, 45, 35);
			SET @ReservadoFL = substring(@LINEA, 61, 19);
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
--s			SET @ReservadoFA  = substring(@LINEA, 56, 39);
			SET @ReservadoFA  = substring(@LINEA, 72, 23);


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
--s			SET @ReservadoRI = substring(@LINEA, 12, 1);
--s			SET @CuentaDebitar = substring(@LINEA, 13, 17);
			SET @CuentaDebitar = substring(@LINEA, 12, 14);
--s			SET @VImporte = substring(@LINEA, 30, 10);
			SET @VImporte = substring(@LINEA, 26, 14); 
			SET @Importe = try_CONVERT(NUMERIC(15,2),@VImporte)/100;
			SET @ReferenciaUnivoca = substring(@LINEA, 40, 15);
			SET @IdClientePegador = substring(@LINEA, 55, 22);
			IF( UPPER(SUBSTRING(@ARCHIVO,1,2))=''SP'') 
				SET @CUIT_BEN = try_convert(NUMERIC(11),substring(@IdClientePegador,1,11))
			ELSE
				SET @CUIT_BEN = try_convert(NUMERIC(11),substring(@IdClientePegador,2,11))

			SET @Operatoria_BCRA = substring(@LINEA, 74, 3);
			SET @InfoAdicional = substring(@LINEA, 77, 2);
			SELECT TOP 1 @nombreBEN=substring(isnull(nombre_completo,''''),1,50) FROM ITF_BCRA_PADFYJ WHERE CUIT=@cuit_ben AND TZ_LOCK=0
			
			
			SET @RegistrosAdicionales = substring(@LINEA, 79, 1);
			SET @ContadorRegistros = substring(@LINEA, 80, 15);
			SET @Tipo_transferencia = (SELECT  top 1 ID_TIPO FROM VTA_TRANSFERENCIAS_TIPOS WHERE ADICIONAL_PRESENT=@InfoAdicional AND tz_lock=0);
			/* Trace Number */
			
			
			IF(@RegistrosAdicionales=''1'')
			BEGIN
			SET @CBU = CONCAT(substring(@LINEA, 5, 7), substring(@LINEA, 16, 12));
			END

			DECLARE @E01 INT = 10-((CONVERT(INT, ''3'')*7+
			CONVERT(INT, ''1'')*1+
			CONVERT(INT, ''1'')*3+
			CONVERT(INT, SUBSTRING(@EntidadDebitar, 5, 1))*9+
			CONVERT(INT, SUBSTRING(@EntidadDebitar, 6, 1))*7+
			CONVERT(INT, SUBSTRING(@EntidadDebitar, 7, 1))*1+
			CONVERT(INT, SUBSTRING(@EntidadDebitar, 8, 1))*3)%10)
	
			SET @CBU=concat(''3'',RIGHT(@EntidadDebitar,6),RIGHT(convert(VARCHAR(2),@E01),1),substring(@LINEA,16,14))	
			SET @Entidad_RI = substring(@ContadorRegistros, 1, 4);
			SET @Sucursal_RI = substring(@ContadorRegistros, 5, 4);
			SET @IdClientePegador_RI = RIGHT(@IdClientePegador, 4);
			SET @NumeroCuenta_RI = LEFT(RIGHT(@CuentaDebitar, 12),11);
			SET @ReferenciaUnivoca_RI = RIGHT(@ReferenciaUnivoca, 12);
		

			IF (@RegistrosAdicionales NOT IN(''1'',''0'')) 
      		BEGIN
      			SET @MSJ =  ''Campo Registro adicional invalido'';
      			
				RETURN
			END
	 		
	 		DECLARE @Moneda INT;
		      IF(LEFT(@InfoAdicional,1)=''0'')
				SET @Moneda = (SELECT top 1 C6399 FROM MONEDAS WHERE C6403=''N'');
		      IF(LEFT(@InfoAdicional,1)=''1'')
				SET @Moneda = (SELECT top 1 C6399 FROM MONEDAS WHERE C6403=''D'');
	
	------------Fin Primera Validacion ----------------
	 	
			IF(@TICKET>0)
			BEGIN	
				BEGIN TRY
 
				
				IF( UPPER(SUBSTRING(@ARCHIVO,1,2))=''MR'') --logica para la 2.8.19
				BEGIN

					UPDATE VTA_TRANSFERENCIAS
					SET ESTADO=''RC''
			 			, MOTIVO_RECHAZO=(SELECT TOP 1 id_motivo FROM snp_motivos_rechazo WHERE CODIGO_NACHA= (SELECT SUBSTRING(LINEA,4,3) FROM ITF_TRAN_MINORISTA_RECIBIDAS_AUX WHERE ID=@ID+1) AND FUNCIONALIDAD=''TR'' AND TZ_LOCK=0)
			 			, FECHA_ESTADO=@FECHADATE 
			 			, NUMERO_ASIENTO=@TICKET
			 			, OPERATORIA_BCRA=@Operatoria_BCRA
			 			, FCH_DEV_REC=@FECHACOMPENSACION
					WHERE tracenumber=(SELECT try_convert(NUMERIC,SUBSTRING(LINEA,7,15)) FROM ITF_TRAN_MINORISTA_RECIBIDAS_AUX WHERE ID=@ID+1)
					AND OP_NUMERO=isnull(TRY_CONVERT(NUMERIC(12,0),LTRIM(RIGHT(@ReferenciaUnivoca,12))),0)
					AND OP_CLASE_TRANS=''E''
				
					
					GOTO Final
	   			END
				
				
				
		IF ( UPPER(SUBSTRING(@ARCHIVO,1,2))!=''SP'' AND (@cuit_EO IS NULL OR @cuit_EO <= 9999999999) AND @RegistrosAdicionales=''1'')
		BEGIN 
					SELECT @cuit_EO=try_convert(NUMERIC(11,0),substring(linea,4,11)) FROM ITF_TRAN_MINORISTA_RECIBIDAS_AUX	WHERE ID=@id+1	
					IF @cuit_EO<20000000000
						SELECT TOP 1 @cuit_EO=cuit FROM itf_bcra_padfyj	WHERE TRY_convert(VARCHAR(11),cuit) LIKE ''%''+convert(VARCHAR,@cuit_EO)+''%''
						
						
					SELECT TOP 1 @nombreeo=substring(isnull(nombre_completo,''''),1,50)  FROM ITF_BCRA_PADFYJ WHERE CUIT=@cuit_EO AND TZ_LOCK=0
		
		
		END 


	
		  DECLARE @JTS_OID NUMERIC(10,0) = (SELECT top 1 JTS_OID_SALDO FROM VTA_SALDOS WHERE CTA_CBU=@CBU AND tz_lock=0);
	      
	      ----------------------- VALIDACIONES INCLUYENTES------------------------
	      ------------------------------------------------------------------------

	      IF @moneda_in=0 AND @CODREGISTRO_IN=''CTX'' AND LEFT(@infoadicional,1)=''0'' AND RIGHT(@infoadicional,1) IN (''7'',''8'',''D'')
	      BEGIN
				

			UPDATE dbo.VTA_TRANSFERENCIAS
			SET ESTADO = ''RC'' 
				, FECHA_ESTADO=@FECHADATE 
				, NUMERO_ASIENTO=@TICKET
				, MOTIVO_RECHAZO=(SELECT TOP 1 id_motivo FROM snp_motivos_rechazo WHERE CODIGO_NACHA= (SELECT substring(linea,33,3) FROM ITF_TRAN_MINORISTA_RECIBIDAS_AUX WHERE ID=@id+1) AND FUNCIONALIDAD=''TR'' AND TZ_LOCK=0)
				, OPERATORIA_BCRA=@Operatoria_BCRA
				, FCH_DEV_REC=@FECHACOMPENSACION
			WHERE TRACENUMBER=(SELECT try_convert(NUMERIC(15),substring(linea,18,15)) 
								FROM ITF_TRAN_MINORISTA_RECIBIDAS_AUX 
								WHERE ID=@id+1 
								AND LINEA LIKE ''7%'')
			AND OP_NUMERO=isnull(TRY_CONVERT(NUMERIC(12,0),LTRIM(RIGHT(@ReferenciaUnivoca,12))),0) 
			AND OP_CLASE_TRANS = ''E''


			GOTO Final
	      END
	      
	      
				IF try_convert(NUMERIC,@cuit_ben)=@cuit_eo
					SET @ben_mismo_titular=''S''
				ELSE SET @ben_mismo_titular=''N''
	      
	      
	      
		  --------------
		  ----NACHA R17
		  --------------
			SET @BenBanco=try_convert(NUMERIC,substring(@EntidadDebitar,1,4))
		  	IF @BenBanco=811
		  		SET @BenBanco=311

		  IF ISNUMERIC(@CodTransaccion) = 0 
		  	 or ISNUMERIC(@EntidadDebitar) = 0  
--s		  	 OR ISNUMERIC(@ReservadoRI) = 0 
		  	 OR ISNUMERIC(@CuentaDebitar) = 0
			 OR ISNUMERIC(@VImporte) = 0 
			 OR LEFT(@Tipo_Transferencia_CL,1)!=''0''
			 OR ISNUMERIC(@RegistrosAdicionales) = 0 
			 OR ISNUMERIC(@ContadorRegistros) = 0
	      BEGIN
	      PRINT @Tipo_Transferencia_CL
	      PRINT @RegistrosAdicionales
	      PRINT @ContadorRegistros
	      
	      		INSERT INTO dbo.VTA_TRANSFERENCIAS (OP_NUMERO, 
	      											NUMERO_ASIENTO,
	      											OP_FECHA_PRES, 
	      											OP_CLASE_TRANS,
	      											ESTADO, 
	      											OP_MONEDA, 
	      											OP_TIPO, 
	      											BEN_CBU, 
	      											OP_IMPORTE, 
	      											BEN_JTS_OID_CUENTA, 
	      											BEN_NRO_DOC, 
	      											MOTIVO_RECHAZO, 
	      											OP_FORMA_ING, 
	      											FECHA_ESTADO, 
	      											CONTABILIZADA, 
	      											OP_INFO_REF,
	      											OPERATORIA_BCRA
	      											, FCH_DEV_REC
	      											, TRACENUMBER
	      																						, ORD_NRO_DOC
											, ORD_NOMBRE
											, BEN_BANCO
											, BEN_TIPO_DOC
											, ord_tipo_doc 
											, ben_mismo_titular , ben_nombre , op_referencia  
											, ORD_BANCO , ORD_SUCURSAL
											)
				VALUES ((SELECT ISNULL(MAX(OP_NUMERO),0)+1 FROM VTA_TRANSFERENCIAS WHERE OP_CLASE_TRANS=''R''),
						 @TICKET, 
						 @FECHADATE, 
						 ''R'', 
						 ''RC'', 
						 @Moneda, 
						 @Tipo_transferencia, 
						 @CBU, 
						 @Importe, 
						 @JTS_OID, 
						 @CUIT_BEN,
						 4, 
						 ''C'' , 
						 @FECHADATE, 
						 ''N'', 
						 RTRIM(LTRIM(@ReferenciaUnivoca)),
						 @OPERATORIA_BCRA
						 , @FECHACOMPENSACION
						 , TRY_CONVERT(NUMERIC(15),@ContadorRegistros)
						 						 , @cuit_eo
						 , @nombreEO
						 , @BenBanco
						 , CASE WHEN substring (@CUIT_BEN,1,1)=''2'' THEN ''CUIL'' WHEN substring (CONVERT(VARCHAR,@CUIT_BEN),1,1)=''3'' THEN ''CUIT'' END
						 , CASE WHEN substring (CONVERT(VARCHAR,@CUIT_EO),1,1)=''2'' THEN ''CUIL'' WHEN substring (CONVERT(VARCHAR,@CUIT_EO),1,1)=''3'' THEN ''CUIT'' END
						 , @ben_mismo_titular  , @nombreBEN , LEFT(@ReferenciaUnivoca,3) 
						 , @OrdBanco, @OrdSucursal
						 )
	      	GOTO Final
	      END

		  --------------
		  ----NACHAR R26
		  --------------		  
		  
		  
		  IF (
		  
		  	len(ltrim(rtrim(@IdentificadorArchivo)))=0 or 
			len(ltrim(rtrim(@CodigoReferencia)))=0 or 
			isnumeric(ltrim(rtrim(@CodigoPrioridad)))=0 or 
			isnumeric(ltrim(rtrim(@DestinoInmediato)))=0 or 
			isnumeric(ltrim(rtrim(@OrigenInmediato)))=0 or 
			isnumeric(ltrim(rtrim(@VFechaVencimientoCA)))=0 or 
			isnumeric(ltrim(rtrim(@HoraPresentacion)))=0 or 
			isnumeric(ltrim(rtrim(@TamanoRegistro)))=0 or 
			isnumeric(ltrim(rtrim(@FactorBloque)))=0 or 
			isnumeric(ltrim(rtrim(@CodigoFormato)))=0 or 
			len(ltrim(rtrim(@CodigoRegistro)))=0 or 
			len(ltrim(rtrim(left(@ReservadoLote,16))))=0 or 
			len(ltrim(rtrim(@Tipo_Transferencia_CL)))=0 or 
			isnumeric(ltrim(rtrim(@ClaseTransaccion)))=0 or 
			isnumeric(ltrim(rtrim(right(@ReservadoLote,10))))=0 or 
			isnumeric(ltrim(rtrim(@IdEmpresa)))=0 or 
			isnumeric(ltrim(rtrim(@VFechaVencimiento)))=0 or 
			isnumeric(ltrim(rtrim(@VFechaCompensacion)))=0 or 
			isnumeric(ltrim(rtrim(@IdEntidadOrigen)))=0 or 
			isnumeric(ltrim(rtrim(@CodigoOrigen)))=0 or 
			isnumeric(ltrim(rtrim(@NumeroLote)))=0 or 
			isnumeric(ltrim(rtrim(@CodTransaccion)))=0 or 
			isnumeric(ltrim(rtrim(@EntidadDebitar)))=0 or 
--s			isnumeric(ltrim(rtrim(@ReservadoRI)))=0 or 
			isnumeric(ltrim(rtrim(@CuentaDebitar)))=0 or 
			isnumeric(ltrim(rtrim(@VImporte)))=0 or 
			len(ltrim(rtrim(@ReferenciaUnivoca)))=0 or 
			len(ltrim(rtrim(@IdClientePegador)))=0 or 
			len(ltrim(rtrim(@InfoAdicional)))=0 or 
			isnumeric(ltrim(rtrim(@RegistrosAdicionales)))=0 or 
			isnumeric(ltrim(rtrim(@ContadorRegistros)))=0 
			)
		  	BEGIN
		  	INSERT INTO dbo.VTA_TRANSFERENCIAS (OP_NUMERO, NUMERO_ASIENTO,  OP_FECHA_PRES, OP_CLASE_TRANS, ESTADO, OP_MONEDA, OP_TIPO, BEN_CBU, OP_IMPORTE, BEN_JTS_OID_CUENTA, BEN_NRO_DOC, MOTIVO_RECHAZO, OP_FORMA_ING, FECHA_ESTADO, CONTABILIZADA, OP_INFO_REF,OPERATORIA_BCRA, FCH_DEV_REC, TRACENUMBER 
		  												, ORD_NRO_DOC
											, ORD_NOMBRE
											, BEN_BANCO
											, BEN_TIPO_DOC 
											, ord_tipo_doc 
											, ben_mismo_titular , ben_nombre , op_referencia 
											, ORD_BANCO , ORD_SUCURSAL
											)
				VALUES ((SELECT ISNULL(MAX(OP_NUMERO),0)+1 FROM VTA_TRANSFERENCIAS WHERE OP_CLASE_TRANS=''R'')
											, @TICKET
											, @FECHADATE
											, ''R''
											, ''RC''
											, @Moneda, @Tipo_transferencia, @CBU
											, @Importe
											, @JTS_OID, @CUIT_BEN
											,11
											, ''C'' 
											, @FECHADATE
											, ''N''
											, RTRIM(LTRIM(@ReferenciaUnivoca))
											,@OPERATORIA_BCRA, @FECHACOMPENSACION, TRY_CONVERT(NUMERIC(15),@ContadorRegistros)
										 	, @cuit_eo
						 					, @nombreEO
						 					, @BenBanco
						 					, CASE WHEN substring (@CUIT_BEN,1,1)=''2'' THEN ''CUIL'' WHEN substring (CONVERT(VARCHAR,@CUIT_BEN),1,1)=''3'' THEN ''CUIT'' END
						 					, CASE WHEN substring (CONVERT(VARCHAR,@CUIT_EO),1,1)=''2'' THEN ''CUIL'' WHEN substring (CONVERT(VARCHAR,@CUIT_EO),1,1)=''3'' THEN ''CUIT'' END
						 					, @ben_mismo_titular  , @nombreBEN , LEFT(@ReferenciaUnivoca,3)
											, @OrdBanco, @OrdSucursal
						 					)
	      	GOTO Final
		  	END 

		  --------------
		  ----NACHA R87
		  --------------

		  IF try_convert(NUMERIC,LEFT(@InfoAdicional,1))!=@MONEDA_IN 
			 OR try_convert(NUMERIC,substring(@Tipo_Transferencia_CL,2,1))!=@MONEDA_IN
	      BEGIN

	      		INSERT INTO dbo.VTA_TRANSFERENCIAS (OP_NUMERO, 
	      											NUMERO_ASIENTO,
	      											OP_FECHA_PRES, 
	      											OP_CLASE_TRANS,
	      											ESTADO, 
	      											OP_MONEDA, 
	      											OP_TIPO, 
	      											BEN_CBU, 
	      											OP_IMPORTE, 
	      											BEN_JTS_OID_CUENTA, 
	      											BEN_NRO_DOC, 
	      											MOTIVO_RECHAZO, 
	      											OP_FORMA_ING, 
	      											FECHA_ESTADO, 
	      											CONTABILIZADA, 
	      											OP_INFO_REF,
	      											OPERATORIA_BCRA
	      											, FCH_DEV_REC
	      											, TRACENUMBER
	      																						, ORD_NRO_DOC
											, ORD_NOMBRE
											, BEN_BANCO
											, BEN_TIPO_DOC 
											, ord_tipo_doc 
											, ben_mismo_titular , ben_nombre , op_referencia
											, ORD_BANCO , ORD_SUCURSAL
											)
				VALUES ((SELECT ISNULL(MAX(OP_NUMERO),0)+1 FROM VTA_TRANSFERENCIAS WHERE OP_CLASE_TRANS=''R''),
						 @TICKET, 
						 @FECHADATE, 
						 ''R'', 
						 ''RC'', 
						 @Moneda, 
						 @Tipo_transferencia, 
						 @CBU, 
						 @Importe, 
						 @JTS_OID, 
						 @CUIT_BEN,
						 21, 
						 ''C'' , 
						 @FECHADATE, 
						 ''N'', 
						 RTRIM(LTRIM(@ReferenciaUnivoca)),
						 @OPERATORIA_BCRA
						 , @FECHACOMPENSACION
						 , TRY_CONVERT(NUMERIC(15),@ContadorRegistros)
						 						 , @cuit_eo
						 , @nombreEO
						 , @BenBanco
						 , CASE WHEN substring (@CUIT_BEN,1,1)=''2'' THEN ''CUIL'' WHEN substring (CONVERT(VARCHAR,@CUIT_BEN),1,1)=''3'' THEN ''CUIT'' END
						 , CASE WHEN substring (CONVERT(VARCHAR,@CUIT_EO),1,1)=''2'' THEN ''CUIL'' WHEN substring (CONVERT(VARCHAR,@CUIT_EO),1,1)=''3'' THEN ''CUIT'' END
						 , @ben_mismo_titular  , @nombreBEN , LEFT(@ReferenciaUnivoca,3)
						 , @OrdBanco, @OrdSucursal
						 )
	      	GOTO Final
	      END

		  

		  


		  
	      DECLARE @NumCuenta NUMERIC(20);
	      
		  SET @NumCuenta = CAST(LEFT(RIGHT(@CuentaDebitar, 12),11) AS NUMERIC);
		  SET @Importe = CONVERT(NUMERIC(15),@VImporte)/100;


		  --------------
		  ----NACHA R13
		  --------------


		  IF (SELECT count(sucursal) FROM SUCURSALES WHERE sucursal=CONVERT(INT,RIGHT(@EntidadDebitar,4)) AND TZ_LOCK=0)=0
	      BEGIN
	      		INSERT INTO dbo.VTA_TRANSFERENCIAS (OP_NUMERO, NUMERO_ASIENTO,  OP_FECHA_PRES, OP_CLASE_TRANS, ESTADO, OP_MONEDA, OP_TIPO, BEN_CBU, OP_IMPORTE, BEN_JTS_OID_CUENTA, BEN_NRO_DOC, MOTIVO_RECHAZO, OP_FORMA_ING, FECHA_ESTADO, CONTABILIZADA, OP_INFO_REF,OPERATORIA_BCRA, FCH_DEV_REC, TRACENUMBER 
	      													, ORD_NRO_DOC
											, ORD_NOMBRE
											, BEN_BANCO
											, BEN_TIPO_DOC
											, ord_tipo_doc 
											, ben_mismo_titular , ben_nombre , op_referencia  
											, ORD_BANCO , ORD_SUCURSAL
											)
				VALUES ((SELECT ISNULL(MAX(OP_NUMERO),0)+1 FROM VTA_TRANSFERENCIAS WHERE OP_CLASE_TRANS=''R''),@TICKET, @FECHADATE, ''R'', ''RC'', @Moneda, @Tipo_transferencia, @CBU, @Importe, @JTS_OID, @CUIT_BEN
							,2
							, ''C'' , @FECHADATE, ''N'', RTRIM(LTRIM(@ReferenciaUnivoca)),@OPERATORIA_BCRA, @FECHACOMPENSACION, TRY_CONVERT(NUMERIC(15),@ContadorRegistros)
							, @cuit_eo
							, @nombreEO
						 	, @BenBanco
						 	, CASE WHEN substring (@CUIT_BEN,1,1)=''2'' THEN ''CUIL'' WHEN substring (CONVERT(VARCHAR,@CUIT_BEN),1,1)=''3'' THEN ''CUIT'' END
						 	, CASE WHEN substring (CONVERT(VARCHAR,@CUIT_EO),1,1)=''2'' THEN ''CUIL'' WHEN substring (CONVERT(VARCHAR,@CUIT_EO),1,1)=''3'' THEN ''CUIT'' END
						 	, @ben_mismo_titular  , @nombreBEN , LEFT(@ReferenciaUnivoca,3)
							, @OrdBanco, @OrdSucursal
						 	)
	      	GOTO Final
	      END


	      --------------
	      ----NACHA R19
	      --------------
	      
	      IF (@Importe <= 0 OR IsNumeric(@Importe) = 0)
	      BEGIN
	      		INSERT INTO dbo.VTA_TRANSFERENCIAS (OP_NUMERO, NUMERO_ASIENTO,  OP_FECHA_PRES, OP_CLASE_TRANS, ESTADO, OP_MONEDA, OP_TIPO, BEN_CBU, OP_IMPORTE, BEN_JTS_OID_CUENTA, BEN_NRO_DOC, MOTIVO_RECHAZO, OP_FORMA_ING, FECHA_ESTADO, CONTABILIZADA, OP_INFO_REF,OPERATORIA_BCRA, FCH_DEV_REC, TRACENUMBER  
	      													, ORD_NRO_DOC
											, ORD_NOMBRE
											, BEN_BANCO
											, BEN_TIPO_DOC 
											, ord_tipo_doc 
											, ben_mismo_titular , ben_nombre , op_referencia 
											, ORD_BANCO , ORD_SUCURSAL
											)
				VALUES ((SELECT ISNULL(MAX(OP_NUMERO),0)+1 FROM VTA_TRANSFERENCIAS WHERE OP_CLASE_TRANS=''R''),@TICKET, @FECHADATE, ''R'', ''RC'', @Moneda, @Tipo_transferencia, @CBU, @Importe, @JTS_OID, @CUIT_BEN
							,5, ''C'' , @FECHADATE, ''N'', RTRIM(LTRIM(@ReferenciaUnivoca)),@OPERATORIA_BCRA, @FECHACOMPENSACION, TRY_CONVERT(NUMERIC(15),@ContadorRegistros)
						 	, @cuit_eo
						 	, @nombreEO
						 	, @BenBanco
						 	, CASE WHEN substring (@CUIT_BEN,1,1)=''2'' THEN ''CUIL'' WHEN substring (CONVERT(VARCHAR,@CUIT_BEN),1,1)=''3'' THEN ''CUIT'' END
						 	, CASE WHEN substring (CONVERT(VARCHAR,@CUIT_EO),1,1)=''2'' THEN ''CUIL'' WHEN substring (CONVERT(VARCHAR,@CUIT_EO),1,1)=''3'' THEN ''CUIT'' END
						 	, @ben_mismo_titular  , @nombreBEN , LEFT(@ReferenciaUnivoca,3)
							, @OrdBanco, @OrdSucursal
						 )

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
	      		INSERT INTO dbo.VTA_TRANSFERENCIAS (OP_NUMERO, NUMERO_ASIENTO,  OP_FECHA_PRES, OP_CLASE_TRANS, ESTADO, OP_MONEDA, OP_TIPO, BEN_CBU, OP_IMPORTE, BEN_JTS_OID_CUENTA, BEN_NRO_DOC, MOTIVO_RECHAZO, OP_FORMA_ING, FECHA_ESTADO, CONTABILIZADA, OP_INFO_REF,OPERATORIA_BCRA, FCH_DEV_REC, TRACENUMBER 
	      													, ORD_NRO_DOC
											, ORD_NOMBRE
											, BEN_BANCO
											, BEN_TIPO_DOC 
											, ord_tipo_doc 
											, ben_mismo_titular , ben_nombre , op_referencia 
											, ORD_BANCO , ORD_SUCURSAL
											)
				VALUES ((SELECT ISNULL(MAX(OP_NUMERO),0)+1 FROM VTA_TRANSFERENCIAS WHERE OP_CLASE_TRANS=''R''), @TICKET, @FECHADATE, ''R'', ''RC'', @Moneda, @Tipo_transferencia, @CBU, @Importe, @JTS_OID, @CUIT_BEN
							,8, ''C'' , @FECHADATE, ''N'', RTRIM(LTRIM(@ReferenciaUnivoca)),@OPERATORIA_BCRA, @FECHACOMPENSACION, TRY_CONVERT(NUMERIC(15),@ContadorRegistros)
							 , @cuit_eo
						 	, @nombreEO
						 	, @BenBanco
						 	, CASE WHEN substring (@CUIT_BEN,1,1)=''2'' THEN ''CUIL'' WHEN substring (CONVERT(VARCHAR,@CUIT_BEN),1,1)=''3'' THEN ''CUIT'' END
						 	, CASE WHEN substring (CONVERT(VARCHAR,@CUIT_EO),1,1)=''2'' THEN ''CUIL'' WHEN substring (CONVERT(VARCHAR,@CUIT_EO),1,1)=''3'' THEN ''CUIT'' END
						 	, @ben_mismo_titular  , @nombreBEN , LEFT(@ReferenciaUnivoca,3)
							, @OrdBanco, @OrdSucursal
						 	)
	      	GOTO Final
	      END
	      
	      --------------
	      ----NACHA R75
	      --------------
	      
	      
		  IF ISDATE(@VFechaVencimiento) = 0 OR ISDATE(@VFechaCompensacion) = 0 OR ISDATE(@VFechaVencimientoCA) = 0
	      BEGIN
	             
	      		INSERT INTO dbo.VTA_TRANSFERENCIAS (OP_NUMERO
	      											, NUMERO_ASIENTO
	      											,  OP_FECHA_PRES
	      											, OP_CLASE_TRANS
	      											, ESTADO
	      											, OP_MONEDA
	      											, OP_TIPO
	      											, BEN_CBU
	      											, OP_IMPORTE
	      											, BEN_JTS_OID_CUENTA
	      											, BEN_NRO_DOC
	      											, MOTIVO_RECHAZO, OP_FORMA_ING, FECHA_ESTADO, CONTABILIZADA, OP_INFO_REF,OPERATORIA_BCRA, FCH_DEV_REC, TRACENUMBER 
	      													, ORD_NRO_DOC
											, ORD_NOMBRE
											, BEN_BANCO
											, BEN_TIPO_DOC
											, ord_tipo_doc 
											, ben_mismo_titular , ben_nombre , op_referencia 
											, ORD_BANCO , ORD_SUCURSAL
											)
				VALUES ((SELECT ISNULL(MAX(OP_NUMERO),0)+1 FROM VTA_TRANSFERENCIAS WHERE OP_CLASE_TRANS=''R'')
							, @TICKET
							, @FECHADATE
							, ''R''
							, ''RC''
							, @Moneda
							, @Tipo_transferencia
							, @CBU
							, @Importe
							, @JTS_OID
							, @CUIT_BEN
							, 16, ''C'' , @FECHADATE, ''N'', RTRIM(LTRIM(@ReferenciaUnivoca)),@OPERATORIA_BCRA, @FECHACOMPENSACION, TRY_CONVERT(NUMERIC(15),@ContadorRegistros)
										 , @cuit_eo
						 	, @nombreEO
						 	, @BenBanco
						 	, CASE WHEN substring (@CUIT_BEN,1,1)=''2'' THEN ''CUIL'' WHEN substring (CONVERT(VARCHAR,@CUIT_BEN),1,1)=''3'' THEN ''CUIT'' END
						 	, CASE WHEN substring (CONVERT(VARCHAR,@CUIT_EO),1,1)=''2'' THEN ''CUIL'' WHEN substring (CONVERT(VARCHAR,@CUIT_EO),1,1)=''3'' THEN ''CUIT'' END
						 	, @ben_mismo_titular  , @nombreBEN , LEFT(@ReferenciaUnivoca,3)
							, @OrdBanco, @OrdSucursal
						 )
	      	GOTO Final
	      END
	      

		  --------------
		  ----NACHA R03
		  --------------
			
		  IF (SELECT count(jts_oid_saldo) FROM vta_saldos WHERE cta_cbu=@cbu AND TZ_LOCK=0)=0
	      BEGIN
	      		INSERT INTO dbo.VTA_TRANSFERENCIAS (OP_NUMERO
	      											, NUMERO_ASIENTO
	      											, OP_FECHA_PRES
	      											, OP_CLASE_TRANS
	      											, ESTADO
	      											, OP_MONEDA
	      											, OP_TIPO
	      											, BEN_CBU
	      											, OP_IMPORTE
	      											, BEN_JTS_OID_CUENTA
	      											, BEN_NRO_DOC
	      											, MOTIVO_RECHAZO
	      											, OP_FORMA_ING
	      											, FECHA_ESTADO
	      											, CONTABILIZADA
	      											, OP_INFO_REF
	      											, OPERATORIA_BCRA
	      											, FCH_DEV_REC
	      											, TRACENUMBER 
	      											, ORD_NRO_DOC
													, ORD_NOMBRE
													, BEN_BANCO
										   			, BEN_TIPO_DOC 
													, ord_tipo_doc 
													, ben_mismo_titular 
													, ben_nombre 
													, op_referencia 
													, ORD_BANCO , ORD_SUCURSAL
											)
				VALUES ((SELECT ISNULL(MAX(OP_NUMERO),0)+1 FROM VTA_TRANSFERENCIAS WHERE OP_CLASE_TRANS=''R'')
						, @TICKET
						, @FECHADATE
						, ''R''
						, ''RC''
						, @Moneda
						, @Tipo_transferencia
						, @CBU
						, @Importe
						, @JTS_OID
						, @CUIT_BEN
						, 1
						, ''C'' 
						, @FECHADATE
						, ''N''
						, RTRIM(LTRIM(@ReferenciaUnivoca))
						, @OPERATORIA_BCRA
						, @FECHACOMPENSACION
						, TRY_CONVERT(NUMERIC(15),@ContadorRegistros)
						, @cuit_eo
						 , @nombreEO
						 , @BenBanco
						 , CASE WHEN substring (@CUIT_BEN,1,1)=''2'' THEN ''CUIL'' WHEN substring (CONVERT(VARCHAR,@CUIT_BEN),1,1)=''3'' THEN ''CUIT'' END
						 , CASE WHEN substring (CONVERT(VARCHAR,@CUIT_EO),1,1)=''2'' THEN ''CUIL'' WHEN substring (CONVERT(VARCHAR,@CUIT_EO),1,1)=''3'' THEN ''CUIT'' END
						 , @ben_mismo_titular  
						 , @nombreBEN 
						 , LEFT(@ReferenciaUnivoca,3)
						 , @OrdBanco, @OrdSucursal
						 )
	      	GOTO Final
	      END
    
		
		  --------------
		  ----NACHA R40
		  --------------
		  DECLARE @V40 NUMERIC;
		  DECLARE @cuit VARCHAR(20);	 
			
		IF (LEFT(@IDCLIENTEPEGADOR,1) IN (''1'',''2'',''3'') AND LEN(REPLACE(substring(@IDCLIENTEPEGADOR,2,11),'' '',''''))=11)
			SET @cuit=substring(@IDCLIENTEPEGADOR,2,11)


		SET @V40 = (
	    SELECT COUNT(1) 
	    FROM SALDOS s
	    JOIN cli_clientepersona cp ON s.C1803 = cp.CODIGOCLIENTE
	    JOIN CLI_DocumentosPFPJ fj ON fj.NUMEROPERSONAFJ = cp.NUMEROPERSONA
	    WHERE cp.TITULARIDAD = ''T''
	      AND s.CUENTA = @NumCuenta
	      AND EXISTS (
	          SELECT 1
	          FROM VW_CLIENTES_PERSONAS vcp
	          JOIN VTA_SALDOS vs ON vs.CTA_CBU = @CBU AND s.JTS_OID = vs.JTS_OID_SALDO
	          WHERE vcp.NUMERODOC = fj.NUMERODOCUMENTO
	            AND vcp.CODIGOCLIENTE = s.C1803
	            AND vcp.TITULARIDAD = ''T''
	      )
	      AND s.TZ_LOCK = 0
	      AND cp.TZ_LOCK = 0
	      AND fj.TZ_LOCK = 0
		);


		  IF @V40=0 AND @Tipo_transferencia!=10
		  BEGIN
	      		INSERT INTO dbo.VTA_TRANSFERENCIAS (OP_NUMERO, NUMERO_ASIENTO,  OP_FECHA_PRES, OP_CLASE_TRANS, ESTADO, OP_MONEDA, OP_TIPO, BEN_CBU, OP_IMPORTE, BEN_JTS_OID_CUENTA, BEN_NRO_DOC, MOTIVO_RECHAZO, OP_FORMA_ING, FECHA_ESTADO, CONTABILIZADA, OP_INFO_REF,OPERATORIA_BCRA, FCH_DEV_REC, TRACENUMBER 
	      													, ORD_NRO_DOC
											, ORD_NOMBRE
											, BEN_BANCO
											, BEN_TIPO_DOC
											, ord_tipo_doc 
											, ben_mismo_titular , ben_nombre , op_referencia 
											, ORD_BANCO , ORD_SUCURSAL
											)
				VALUES ((SELECT ISNULL(MAX(OP_NUMERO),0)+1 FROM VTA_TRANSFERENCIAS WHERE OP_CLASE_TRANS=''R''),@TICKET, @FECHADATE, ''R'', ''RC'', @Moneda, @Tipo_transferencia, @CBU, @Importe, @JTS_OID, @CUIT_BEN
							,14, ''C'' , @FECHADATE, ''N'', RTRIM(LTRIM(@ReferenciaUnivoca)),@OPERATORIA_BCRA, @FECHACOMPENSACION, TRY_CONVERT(NUMERIC(15),@ContadorRegistros)
										 , @cuit_eo
						 , @nombreEO
						 , @BenBanco
						 , CASE WHEN substring (@CUIT_BEN,1,1)=''2'' THEN ''CUIL'' WHEN substring (CONVERT(VARCHAR,@CUIT_BEN),1,1)=''3'' THEN ''CUIT'' END
						 , CASE WHEN substring (CONVERT(VARCHAR,@CUIT_EO),1,1)=''2'' THEN ''CUIL'' WHEN substring (CONVERT(VARCHAR,@CUIT_EO),1,1)=''3'' THEN ''CUIT'' END
						 , @ben_mismo_titular  , @nombreBEN , LEFT(@ReferenciaUnivoca,3)
						 , @OrdBanco, @OrdSucursal
						 )
	      	GOTO Final
	      END
	      
	      
	      --------------
	      ----NACHA R20
	      --------------
	      
	      DECLARE @MonedaCta NUMERIC(2);
	      DECLARE @TipoCuenta VARCHAR(2);
		  DECLARE @Cod_Cliente NUMERIC(20);
		  DECLARE @saldo_jts_oid NUMERIC(15);
	      
	      SET @NumCuenta = CAST(LEFT(RIGHT(@CuentaDebitar, 12),11) AS NUMERIC);
--s	      SET @TipoCuenta = SUBSTRING(@CuentaDebitar,4,2);
          SET @TipoCuenta = SUBSTRING(@CuentaDebitar,1,2);

	      SELECT @MonedaCta = MONEDA,
	      	@Cod_Cliente = C1803,
			@saldo_jts_oid = JTS_OID
	      FROM SALDOS 
	      WHERE CUENTA = @NumCuenta 
	        AND SUCURSAL = CONVERT(INT,RIGHT(@EntidadDebitar,4))
	        AND C1785 = (CASE WHEN TRY_CAST(@TipoCuenta AS NUMERIC) = 11 OR TRY_CAST(@TipoCuenta AS NUMERIC) = 15 THEN 3 
	        				  WHEN TRY_CAST(@TipoCuenta AS NUMERIC) = 1 OR TRY_CAST(@TipoCuenta AS NUMERIC) = 7 THEN 2
	        			 END)
            AND MONEDA = (CASE WHEN TRY_CAST(@TipoCuenta AS NUMERIC) = 11 OR TRY_CAST(@TipoCuenta AS NUMERIC) = 1 THEN 1 
            				   WHEN TRY_CAST(@TipoCuenta AS NUMERIC) = 15 OR TRY_CAST(@TipoCuenta AS NUMERIC) = 7 THEN 2 END)
	        AND TZ_LOCK = 0;

	      IF( @Moneda <> ISNULL(@MonedaCta,99) )
	      BEGIN

    
	      		INSERT INTO dbo.VTA_TRANSFERENCIAS (OP_NUMERO, NUMERO_ASIENTO,  OP_FECHA_PRES, OP_CLASE_TRANS, ESTADO, OP_MONEDA, OP_TIPO, BEN_CBU, OP_IMPORTE, BEN_JTS_OID_CUENTA, BEN_NRO_DOC, MOTIVO_RECHAZO, OP_FORMA_ING, FECHA_ESTADO, CONTABILIZADA, OP_INFO_REF,OPERATORIA_BCRA, FCH_DEV_REC, TRACENUMBER 
	      													, ORD_NRO_DOC
											, ORD_NOMBRE
											, BEN_BANCO
											, BEN_TIPO_DOC 
											, ord_tipo_doc 
											, ben_mismo_titular , ben_nombre , op_referencia 
											, ORD_BANCO , ORD_SUCURSAL
											)
				VALUES ((SELECT ISNULL(MAX(OP_NUMERO),0)+1 FROM VTA_TRANSFERENCIAS WHERE OP_CLASE_TRANS=''R''), @TICKET, @FECHADATE, ''R'', ''RC'', @Moneda, @Tipo_transferencia, @CBU, @Importe, @JTS_OID, @CUIT_BEN,6, ''C'' , @FECHADATE, ''N'', RTRIM(LTRIM(@ReferenciaUnivoca)),@OPERATORIA_BCRA, @FECHACOMPENSACION, TRY_CONVERT(NUMERIC(15),@ContadorRegistros)
										 , @cuit_eo
						 , @nombreEO
						 , @BenBanco
						 , CASE WHEN substring (@CUIT_BEN,1,1)=''2'' THEN ''CUIL'' WHEN substring (CONVERT(VARCHAR,@CUIT_BEN),1,1)=''3'' THEN ''CUIT'' END
						 , CASE WHEN substring (CONVERT(VARCHAR,@CUIT_EO),1,1)=''2'' THEN ''CUIL'' WHEN substring (CONVERT(VARCHAR,@CUIT_EO),1,1)=''3'' THEN ''CUIT'' END
						 , @ben_mismo_titular  , @nombreBEN , LEFT(@ReferenciaUnivoca,3)
						 , @OrdBanco, @OrdSucursal
						 )

	      	GOTO Final
	      END
	      
		  --------------
          ----NACHA R45
          --------------
          SELECT TOP 1 @PRODUCTO = PRODUCTO
          FROM SALDOS WITH (NOLOCK)
          WHERE CUENTA = @NUMCUENTA AND JTS_OID = @JTS_OID AND TZ_LOCK = 0;
 
          IF @CODREGISTRO_IN = ''CCD''AND (@PRODUCTO NOT IN (1,2,3,4,6,7,9,10,16,23,24,53) AND NOT (@PRODUCTO = 51 AND EXISTS (SELECT 1 FROM CLI_DocumentosPFPJ WHERE NUMERODOCUMENTO = @CUIT_BEN AND TIPOPERSONA = ''F'')))
			BEGIN 
	      		INSERT INTO dbo.VTA_TRANSFERENCIAS (OP_NUMERO, NUMERO_ASIENTO,  OP_FECHA_PRES, OP_CLASE_TRANS, ESTADO, OP_MONEDA, OP_TIPO, BEN_CBU, OP_IMPORTE, BEN_JTS_OID_CUENTA, BEN_NRO_DOC, MOTIVO_RECHAZO, OP_FORMA_ING, FECHA_ESTADO, CONTABILIZADA, OP_INFO_REF,OPERATORIA_BCRA, FCH_DEV_REC, TRACENUMBER 
	      													, ORD_NRO_DOC
											, ORD_NOMBRE
											, BEN_BANCO
											, BEN_TIPO_DOC
											, ord_tipo_doc 
											, ben_mismo_titular , ben_nombre , op_referencia  
											, ORD_BANCO , ORD_SUCURSAL
										   )
				VALUES ((SELECT ISNULL(MAX(OP_NUMERO),0)+1 FROM VTA_TRANSFERENCIAS WHERE OP_CLASE_TRANS=''R''), @TICKET, @FECHADATE, ''R'', ''RC'', @Moneda, @Tipo_transferencia, @CBU, @Importe, @JTS_OID, @CUIT_BEN
							,15
							, ''C'' , @FECHADATE, ''N'', RTRIM(LTRIM(@ReferenciaUnivoca)),@OPERATORIA_BCRA, @FECHACOMPENSACION, TRY_CONVERT(NUMERIC(15),@ContadorRegistros)
										 , @cuit_eo
						 , @nombreEO
						 , @BenBanco
						 , CASE WHEN substring (@CUIT_BEN,1,1)=''2'' THEN ''CUIL'' WHEN substring (CONVERT(VARCHAR,@CUIT_BEN),1,1)=''3'' THEN ''CUIT'' END
						 , CASE WHEN substring (CONVERT(VARCHAR,@CUIT_EO),1,1)=''2'' THEN ''CUIL'' WHEN substring (CONVERT(VARCHAR,@CUIT_EO),1,1)=''3'' THEN ''CUIT'' END
						 , @ben_mismo_titular  , @nombreBEN , LEFT(@ReferenciaUnivoca,3)
						 , @OrdBanco, @OrdSucursal
						 )

	      	GOTO Final
			END 
			
		  --------------
		  ----NACHA R93
		  --------------
	      SET @FechaVencimientoCA = convert(DATE, @VFechaVencimientoCA);
		  
		  DECLARE @V93 NUMERIC(2);
	      DECLARE @FechaPro VARCHAR(10);
	      

	      SET @FechaPro = CONVERT(VARCHAR(10),(SELECT FECHAPROCESO FROM PARAMETROS),103);
	      
	      SET @V93 = (SELECT COUNT(1) FROM FERIADOS WHERE (SUCURSAL=CONVERT(INT,RIGHT(@EntidadDebitar,4)) OR SUCURSAL=-1) AND DIA=FORMAT(@FechaVencimientoCA,''dd'') AND MES=FORMAT(@FechaVencimientoCA,''MM'') AND (ANIO=FORMAT(@FechaVencimientoCA,''yyyy'') OR ANIO=0)); 

	      IF (@V93 > 0)
	      BEGIN
	      		INSERT INTO dbo.VTA_TRANSFERENCIAS (OP_NUMERO, NUMERO_ASIENTO,  OP_FECHA_PRES, OP_CLASE_TRANS, ESTADO, OP_MONEDA, OP_TIPO, BEN_CBU, OP_IMPORTE, BEN_JTS_OID_CUENTA, BEN_NRO_DOC, MOTIVO_RECHAZO, OP_FORMA_ING, FECHA_ESTADO, CONTABILIZADA, OP_INFO_REF,OPERATORIA_BCRA, FCH_DEV_REC, TRACENUMBER 
	      													, ORD_NRO_DOC
											, ORD_NOMBRE
											, BEN_BANCO
											, BEN_TIPO_DOC
											, ord_tipo_doc 
											, ben_mismo_titular , ben_nombre , op_referencia  
											, ORD_BANCO , ORD_SUCURSAL
											)
				VALUES ((SELECT ISNULL(MAX(OP_NUMERO),0)+1 FROM VTA_TRANSFERENCIAS WHERE OP_CLASE_TRANS=''R''),@TICKET, @FECHADATE, ''R'', ''RC'', @Moneda, @Tipo_transferencia, @CBU, @Importe, @JTS_OID, @CUIT_BEN
							, 25
							, ''C'' , @FECHADATE, ''N'', RTRIM(LTRIM(@ReferenciaUnivoca)),@OPERATORIA_BCRA, @FECHACOMPENSACION, TRY_CONVERT(NUMERIC(15),@ContadorRegistros)
										 , @IdEmpresa
						 , @nombreEO
						 , @BenBanco
						 , CASE WHEN substring (@CUIT_BEN,1,1)=''2'' THEN ''CUIL'' WHEN substring (CONVERT(VARCHAR,@CUIT_BEN),1,1)=''3'' THEN ''CUIT'' END
						 , CASE WHEN substring (CONVERT(VARCHAR,@CUIT_EO),1,1)=''2'' THEN ''CUIL'' WHEN substring (CONVERT(VARCHAR,@CUIT_EO),1,1)=''3'' THEN ''CUIT'' END
						 , @ben_mismo_titular  , @nombreBEN , LEFT(@ReferenciaUnivoca,3) 
						 , @OrdBanco, @OrdSucursal
						 )
	      	GOTO Final
	      END
		  
		  
		  --------------
		  ----NACHA R76
		  --------------


		DECLARE @PRESTACION VARCHAR(10);
		DECLARE @CTA_CBU VARCHAR(22);

		SELECT TOP 1
			@PRESTACION = PRESTACION
		FROM SNP_PRESTACIONES_EMPRESAS
		WHERE ENTIDAD = @IdEntidadOrigen AND CUIT_EO=@CUIT_EO

	      IF (@CodigoOrigen!=0 AND (dbo.validarCuit(@cuit_eo)=0)) --or @cuit_eo not in (select cuit from itf_bcra_padfyj)
	      BEGIN
	      		INSERT INTO dbo.VTA_TRANSFERENCIAS (OP_NUMERO, NUMERO_ASIENTO,  OP_FECHA_PRES, OP_CLASE_TRANS, ESTADO, OP_MONEDA, OP_TIPO, BEN_CBU, OP_IMPORTE, BEN_JTS_OID_CUENTA, BEN_NRO_DOC, MOTIVO_RECHAZO, OP_FORMA_ING, FECHA_ESTADO, CONTABILIZADA, OP_INFO_REF,OPERATORIA_BCRA, FCH_DEV_REC, TRACENUMBER 
	      													, ORD_NRO_DOC
											, ORD_NOMBRE
											, BEN_BANCO
											, BEN_TIPO_DOC 
											, ord_tipo_doc 
											, ben_mismo_titular , ben_nombre , op_referencia 
											, ORD_BANCO , ORD_SUCURSAL
											)
				VALUES ((SELECT ISNULL(MAX(OP_NUMERO),0)+1 FROM VTA_TRANSFERENCIAS WHERE OP_CLASE_TRANS=''R''),@TICKET, @FECHADATE, ''R'', ''RC'', @Moneda, @Tipo_transferencia, @CBU, @Importe, @JTS_OID, @CUIT_BEN
						, 17
						, ''C'' , @FECHADATE, ''N'', RTRIM(LTRIM(@ReferenciaUnivoca)),@OPERATORIA_BCRA, @FECHACOMPENSACION, TRY_CONVERT(NUMERIC(15),@ContadorRegistros)
										 , @cuit_eo
						 , @nombreEO
						 , @BenBanco
						 , CASE WHEN substring (@CUIT_BEN,1,1)=''2'' THEN ''CUIL'' WHEN substring (CONVERT(VARCHAR,@CUIT_BEN),1,1)=''3'' THEN ''CUIT'' END
						 , CASE WHEN substring (CONVERT(VARCHAR,@CUIT_EO),1,1)=''2'' THEN ''CUIL'' WHEN substring (CONVERT(VARCHAR,@CUIT_EO),1,1)=''3'' THEN ''CUIT'' END
						 , @ben_mismo_titular  , @nombreBEN , LEFT(@ReferenciaUnivoca,3)
						 , @OrdBanco, @OrdSucursal
						 )
	      	GOTO Final
	      END 
		  
		  
		  	      
	      --------------
	      ----NACHA R24
	      --------------
	      
		  DECLARE @V24 NUMERIC(3);
	      
	      DECLARE @NIdClientePegador NUMERIC(12);
	      
	      SET @NIdClientePegador = try_convert(NUMERIC(12),substring(@IdClientePegador, 2, 11));
	      
	    
	      SET @V24 = (SELECT COUNT(1) 
	      			  FROM dbo.VTA_TRANSFERENCIAS 
	      			  WHERE OP_INFO_REF=RTRIM(LTRIM(@ReferenciaUnivoca))
	      			  AND FECHA_ESTADO=@FECHADATE
	      			  AND OP_FECHA_PRES=@FECHADATE 
	      			  AND (OP_TIPO=@Tipo_transferencia OR OP_TIPO IS NULL)
	      			  AND BEN_CBU= @CBU
	      			  AND TRACENUMBER=TRY_CONVERT(NUMERIC(15),@ContadorRegistros));

		  
		  IF (@V24 > 0)
	      BEGIN
	      		INSERT INTO dbo.VTA_TRANSFERENCIAS (OP_NUMERO
	      									, NUMERO_ASIENTO
	      									,  OP_FECHA_PRES
	      									, OP_CLASE_TRANS
	      									, ESTADO
	      									, OP_MONEDA
	      									, OP_TIPO
	      									, BEN_CBU
	      									, OP_IMPORTE
	      									, BEN_JTS_OID_CUENTA
	      									, BEN_NRO_DOC
	      									, MOTIVO_RECHAZO
	      									, OP_FORMA_ING
	      									, FECHA_ESTADO
	      									, CONTABILIZADA
	      									, OP_INFO_REF,OPERATORIA_BCRA
	      									, FCH_DEV_REC
	      									, TRACENUMBER
	      									, ORD_NRO_DOC
											, ORD_NOMBRE
											, BEN_BANCO
											, BEN_TIPO_DOC 
											, ord_tipo_doc 
											, ben_mismo_titular 
											, ben_nombre 
											, op_referencia 
											, ORD_BANCO , ORD_SUCURSAL
											) 
				VALUES ((SELECT ISNULL(MAX(OP_NUMERO),0)+1 FROM VTA_TRANSFERENCIAS WHERE OP_CLASE_TRANS=''R''),@TICKET, @FECHADATE, ''R'', ''RC'', @Moneda, @Tipo_transferencia, @CBU, @Importe, @JTS_OID, @CUIT_BEN
						, 9
						, ''C'' , @FECHADATE, ''N'', RTRIM(LTRIM(@ReferenciaUnivoca)),@OPERATORIA_BCRA, @FECHACOMPENSACION
						, TRY_CONVERT(NUMERIC(15),@ContadorRegistros)
												 , @cuit_eo
						 , @nombreEO
						 , @BenBanco
						 , CASE WHEN substring (@CUIT_BEN,1,1)=''2'' THEN ''CUIL'' WHEN substring (CONVERT(VARCHAR,@CUIT_BEN),1,1)=''3'' THEN ''CUIT'' END
						 , CASE WHEN substring (CONVERT(VARCHAR,@CUIT_EO),1,1)=''2'' THEN ''CUIL'' WHEN substring (CONVERT(VARCHAR,@CUIT_EO),1,1)=''3'' THEN ''CUIT'' END
						 , @ben_mismo_titular  , @nombreBEN , LEFT(@ReferenciaUnivoca,3)
						 , @OrdBanco, @OrdSucursal
						 );
	      	GOTO Final
	      END
	     
	      --------------
	      ----NACHA R91
	      --------------
	      
		  IF((LEFT(@EntidadDebitar,4)=''0311'' AND LEFT(@InfoAdicional,1)<>''0'') OR (LEFT(@EntidadDebitar,4)=''0811'' AND LEFT(@InfoAdicional,1)<>''1''))
	      BEGIN
	      	    INSERT INTO dbo.VTA_TRANSFERENCIAS (OP_NUMERO, 
	      	    									NUMERO_ASIENTO,  
	      	    									OP_FECHA_PRES, 
	      	    									OP_CLASE_TRANS, 
	      	    									ESTADO, 
	      	    									OP_MONEDA, 
	      	    									OP_TIPO, 
	      	    									BEN_CBU, 
	      	    									OP_IMPORTE, 
	      	    									BEN_JTS_OID_CUENTA, 
	      	    									BEN_NRO_DOC, 
	      	    									MOTIVO_RECHAZO, 
	      	    									OP_FORMA_ING, 
	      	    									FECHA_ESTADO, 
	      	    									CONTABILIZADA, 
	      	    									OP_INFO_REF,
	      	    									OPERATORIA_BCRA, 
	      	    									FCH_DEV_REC
	      	    									, TRACENUMBER
											, ORD_NRO_DOC
											, ORD_NOMBRE
											, BEN_BANCO
											, BEN_TIPO_DOC
											, ord_tipo_doc 
											, ben_mismo_titular , ben_nombre , op_referencia  
											, ORD_BANCO , ORD_SUCURSAL
											)
				VALUES ((SELECT ISNULL(MAX(OP_NUMERO),0)+1 FROM VTA_TRANSFERENCIAS WHERE OP_CLASE_TRANS=''R'')
						, @TICKET
						, @FECHADATE
						, ''R''
						, ''RC''
						, @Moneda
						, @Tipo_transferencia
						, @CBU
						, @Importe
						, @JTS_OID
						, @CUIT_BEN
						, 24
						, ''C'' 
						, @FECHADATE
						, ''N''
						, RTRIM(LTRIM(@ReferenciaUnivoca))
						,@OPERATORIA_BCRA
						, @FECHACOMPENSACION
						, TRY_CONVERT(NUMERIC(15),@ContadorRegistros)
						 , @cuit_eo
						 , @nombreEO
						 , @BenBanco
						 , CASE WHEN substring (@CUIT_BEN,1,1)=''2'' THEN ''CUIL'' WHEN substring (CONVERT(VARCHAR,@CUIT_BEN),1,1)=''3'' THEN ''CUIT'' END
						 , CASE WHEN substring (CONVERT(VARCHAR,@CUIT_EO),1,1)=''2'' THEN ''CUIL'' WHEN substring (CONVERT(VARCHAR,@CUIT_EO),1,1)=''3'' THEN ''CUIT'' END
						 , @ben_mismo_titular  , @nombreBEN , LEFT(@ReferenciaUnivoca,3)
						 , @OrdBanco, @OrdSucursal
						 )
	      	GOTO Final
	      END
	      
		SET @correlativo = @correlativo +1;
		DECLARE @Tipo_Documento VARCHAR(4);
		DECLARE @Nro_Documento NUMERIC(15,0);
		  
		
		SELECT @CTA_CBU = CTA_CBU
		FROM VTA_SALDOS
		WHERE JTS_OID_SALDO = @saldo_jts_oid
	
		INSERT INTO dbo.VTA_TRANSFERENCIAS (OP_NUMERO, 
											NUMERO_ASIENTO,  
											OP_FECHA_PRES, 
											OP_CLASE_TRANS, 
											ESTADO, 
											OP_MONEDA, 
											OP_TIPO, 
											BEN_CBU, 
											OP_IMPORTE, 
											BEN_JTS_OID_CUENTA, 
											BEN_NRO_DOC, 
											OP_FORMA_ING, 
											FECHA_ESTADO, 
											CONTABILIZADA, 
											OP_INFO_REF,
											OPERATORIA_BCRA
											, TRACENUMBER
											, ORD_NRO_DOC
											, ORD_NOMBRE
											, BEN_BANCO
											, BEN_TIPO_DOC
											, ord_tipo_doc 
											, ben_mismo_titular , ben_nombre , op_referencia 
											, ORD_BANCO , ORD_SUCURSAL
											)
				VALUES ((SELECT ISNULL(MAX(OP_NUMERO),0)+1 FROM VTA_TRANSFERENCIAS WHERE OP_CLASE_TRANS=''R''), 
						 @TICKET, 
						 @FECHADATE, 
						 ''R'', 
						 ''PP'', 
						 @Moneda, 
						 @Tipo_transferencia, 
						 @CBU, 
						 @Importe, 
						 @JTS_OID, 
						 @CUIT_BEN, 
						 ''C'' , 
						 @FECHADATE, 
						 ''N'', 
						 RTRIM(LTRIM(@ReferenciaUnivoca)),
						 @OPERATORIA_BCRA
						 , TRY_CONVERT(NUMERIC(15),@ContadorRegistros)
						 , @CUIT_EO
						 , @nombreEO
						 , @BenBanco
						 , CASE WHEN substring (@CUIT_BEN,1,1)=''2'' THEN ''CUIL'' WHEN substring (CONVERT(VARCHAR,@CUIT_BEN),1,1)=''3'' THEN ''CUIT'' END
						 , CASE WHEN substring (CONVERT(VARCHAR,@CUIT_EO),1,1)=''2'' THEN ''CUIL'' WHEN substring (CONVERT(VARCHAR,@CUIT_EO),1,1)=''3'' THEN ''CUIT'' END
						 , @ben_mismo_titular  , @nombreBEN , LEFT(@ReferenciaUnivoca,3)
						 , @OrdBanco, @OrdSucursal
						 )
			
		
		END TRY
		BEGIN CATCH  
		  CLOSE tran_cursor
		  DEALLOCATE tran_cursor
		  ROLLBACK transaction;
		  SET @MSJ = ''Linea Error: '' + CONVERT(VARCHAR,ERROR_LINE()) + '' Mensaje Error: '' +  ERROR_MESSAGE();
		  RETURN
		  
		END CATCH; 


	END

		END	
		Final:
		FETCH NEXT FROM tran_cursor INTO @ID, @LINEA
	END

	CLOSE tran_cursor
	DEALLOCATE tran_cursor
	COMMIT TRANSACTION;

END
'); 