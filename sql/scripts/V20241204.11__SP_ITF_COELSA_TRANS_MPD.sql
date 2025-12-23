ALTER   PROCEDURE [dbo].[SP_ITF_COELSA_TRANS_MPD]
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
	TRUNCATE TABLE ITF_COELSA_MPD_TEMP;
	------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	DECLARE @T_REFERENCIA VARCHAR(15);
	--- Variables Cabecera Archivo ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	DECLARE @CA_ID_REG VARCHAR(1) = '1';
	DECLARE @CA_CODIGO_PRIORIDAD VARCHAR(2) = '01';
	DECLARE @CA_DESTINO_INMEDIATO VARCHAR(10) = ' 050000010';
	DECLARE @CA_ORIGEN_INMEDIATO VARCHAR(10) = ' 081100300';
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
	DECLARE @CA_TAMANNO_REGISTRO VARCHAR(3) = '094';
	DECLARE @CA_FACTOR_BLOQUE VARCHAR(2) = '10';
	DECLARE @CA_CODIGO_FORMATO VARCHAR(1) = '1';
	DECLARE @CA_NOMBRE_DEST_INMEDIATO VARCHAR(23) = concat('COELSA',replicate(' ', 17));
	DECLARE @CA_NOMBRE_ORIG_INMEDIATO VARCHAR(23) =  concat('NUEVO BCO CHACO S.A.',replicate(' ', 3));
	DECLARE @CA_CODIGO_REFERENCIA VARCHAR(8) = concat('MIN', replicate(' ', 4),'0');
	DECLARE @CA_CABECERA VARCHAR(200);

	SET @CA_CABECERA = concat(@CA_ID_REG, @CA_CODIGO_PRIORIDAD, @CA_DESTINO_INMEDIATO, @CA_ORIGEN_INMEDIATO, @CA_FECHA_PRESENTACION, @CA_HORA_PRESENTACION, @CA_IDENTIFICADOR_ARCHIVO, @CA_TAMANNO_REGISTRO, @CA_FACTOR_BLOQUE, @CA_CODIGO_FORMATO, @CA_NOMBRE_DEST_INMEDIATO, @CA_NOMBRE_ORIG_INMEDIATO, @CA_CODIGO_REFERENCIA);
	------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	--- Variables Cabecera Lote ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	DECLARE @CL_ID_REG VARCHAR(1) = '5'; 
	DECLARE @CL_CODIGO_CLASE_TRANSAC VARCHAR(3) = '220';
	DECLARE @CL_NOMBRE_EMPRESA_INDIVIDUO VARCHAR(16) = LEFT('PARTICULARES' + REPLICATE(' ',16),16);
	DECLARE @RA_NOMBRE_EMPRESA_INDIVIDUO VARCHAR(16);
	DECLARE @CL_INFORMACION_DISCRECIONAL VARCHAR(20) = CONCAT('TRANSFERENCIAS',REPLICATE(' ',6));
	DECLARE @CL_IDENTIFICACION_EMP_IND VARCHAR(10);-- = '3067015779';--Por revisar
	DECLARE @CL_TIPO_REGISTRO VARCHAR(3) = RIGHT('CTX', 3);
	DECLARE @CL_RESERVADO VARCHAR(10) = REPLICATE(' ', 10);  
	DECLARE @CL_FECHA_PRESENTACION VARCHAR(6) = convert(VARCHAR,(SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)), 12);
	DECLARE @CL_FECHA_COMPENSACION VARCHAR(6) = convert(VARCHAR,(SELECT FECHAPROximoproceso FROM PARAMETROS WITH(NOLOCK)), 12);
	DECLARE @CL_MONEDA_TRANSACCION VARCHAR(3) = RIGHT('010', 3);
	DECLARE @CL_DIGITO_VERIFICADOR VARCHAR(1);-- = RIGHT('9', 1);--Para revisar
	DECLARE @CL_ID_ENTIDAD_ORIGEN VARCHAR(8) = '08110030'; 
	
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
	DECLARE @FA_RESERVADO  VARCHAR(39) = concat(REPLICATE(' ', 38),'0');
	DECLARE @FA_ID_REG VARCHAR(1) = '9';  
	DECLARE @FA_CANT_LOTES VARCHAR(6) = '000001';
	
		--- Variables Fin de Lote ---------------------------------------------------------------------------------------------------------------------------------------------------------------
		DECLARE @FL_ID_REG VARCHAR(1) = '8';
		DECLARE @FL_CODIGO_CLASE_TRANSAC VARCHAR(3) = '220'; 
		DECLARE @FL_CANT_REG_INDIVIDUAL_ADICIONAL VARCHAR(6) = replicate('0',6); 
		DECLARE @FL_TOTALES_DE_CONTROL VARCHAR(10) = replicate('0',10); 
		DECLARE @FL_SUMA_TOTAL_DEBITO_LOTE VARCHAR(12); --cambio el largo a 12
		DECLARE @FL_SUMA_TOTAL_CREDITO_LOTE VARCHAR(12); --cambio el largo a 12
		DECLARE @FL_IDENTIFICACION_EMP_IND VARCHAR(10);-- = '3067015779';--Por revisar
		DECLARE @FL_RESERVADO2 VARCHAR(19) = replicate(' ', 19); --cambio largo a 19
		DECLARE @FL_RESERVADO3 VARCHAR(6) = replicate(' ', 6); --cambio largo a 6
		DECLARE @FL_REG_ENTIDAD_ORIGEN VARCHAR(8) = '08110030'; 

		DECLARE @FL_FIN_LOTE VARCHAR(200);

	
	
	DECLARE @CantRegistrosTotal NUMERIC(15) = 2; --seteo 4, cuento la cabecera de archivo, cabecera lote, fin de lote y el fin de archivo 
	DECLARE @CantRegistros NUMERIC(15) = 0; 

	--- Grabamos la cabecera del archivo ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	INSERT INTO ITF_COELSA_MPD_TEMP (LINEA) VALUES (@CA_CABECERA);
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	IF((SELECT count(1)	FROM VTA_TRANSFERENCIAS VT1 WHERE VT1.OP_CLASE_TRANS = 'E' AND VT1.ESTADO='PP' AND VT1.OP_MONEDA = 2 AND VT1.TZ_LOCK=0)=0)
	BEGIN
		---------------- Grabar Cabecera Lote ---------------------------
		SET @CL_IDENTIFICACION_EMP_IND = replicate('0', 10);
		SET @CL_DIGITO_VERIFICADOR='0'
		SET @CL_NOMBRE_EMPRESA_INDIVIDUO = REPLICATE(' ',16);	
		SET @CL_CABECERA = concat(@CL_ID_REG, @CL_CODIGO_CLASE_TRANSAC, @CL_NOMBRE_EMPRESA_INDIVIDUO, @CL_INFORMACION_DISCRECIONAL, @CL_IDENTIFICACION_EMP_IND, @CL_TIPO_REGISTRO, @CL_RESERVADO, @CL_FECHA_PRESENTACION, @CL_FECHA_COMPENSACION, @CL_MONEDA_TRANSACCION, @CL_DIGITO_VERIFICADOR, @CL_ID_ENTIDAD_ORIGEN, RIGHT(REPLICATE('0',7) + CAST('1' AS VARCHAR(7)),7));
		INSERT INTO dbo.ITF_COELSA_MPD_TEMP (LINEA) VALUES (@CL_CABECERA);
		SET @FL_FIN_LOTE = concat(@FL_ID_REG, @FL_CODIGO_CLASE_TRANSAC, RIGHT(CONCAT(REPLICATE('0',6),CAST(@FL_CANT_REG_INDIVIDUAL_ADICIONAL AS NUMERIC)),6), @FL_TOTALES_DE_CONTROL, replicate('0',12), replicate('0',12), @CL_IDENTIFICACION_EMP_IND, @FL_RESERVADO2, @FL_RESERVADO3, @FL_REG_ENTIDAD_ORIGEN, /*@CL_NUMERO_LOTE*/  RIGHT(REPLICATE('0',7) + CAST('1' AS VARCHAR(7)),7) );
		INSERT INTO dbo.ITF_COELSA_MPD_TEMP (LINEA) VALUES (@FL_FIN_LOTE);
	END 
	
	
	DECLARE CursorLote CURSOR FOR
	SELECT A.ORD_NRO_DOC, 
		   A.BEN_BANCO,
	   		A.OP_TIPO, 
	   		A.OP_CLASE_TRANS,
	   		RIGHT(REPLICATE('0',7) + CAST(ROW_NUMBER() OVER(ORDER BY A.ORD_NRO_DOC,A.BEN_BANCO,A.OP_TIPO,A.OP_CLASE_TRANS ASC) AS VARCHAR(10)), 7) AS NUM_LOTE_CAB,
	   		(CASE WHEN (A.ORD_TIPO_DOC NOT IN (SELECT TIPODOCUMENTO FROM CLI_TIPOSDOCUMENTOS WHERE TIPOPERSONA='F') AND OP_TIPO NOT IN (11,9) ) or OP_TIPO=8  THEN SUBSTRING(CAST(A.ORD_NRO_DOC AS VARCHAR(11)),1,10) ELSE REPLICATE('0',10) END) AS CL_IDENTIFICACION_EMP_IND,
			(CASE WHEN (A.ORD_TIPO_DOC NOT IN (SELECT TIPODOCUMENTO FROM CLI_TIPOSDOCUMENTOS WHERE TIPOPERSONA='F')AND OP_TIPO NOT IN (11,9) ) or OP_TIPO=8  THEN SUBSTRING(CAST(A.ORD_NRO_DOC AS VARCHAR(11)),11,1) ELSE '0' END) AS CL_DIGITO_VERIFICADOR,
			LEFT((CASE WHEN (A.ORD_TIPO_DOC NOT IN (SELECT TIPODOCUMENTO FROM CLI_TIPOSDOCUMENTOS WHERE TIPOPERSONA='F')AND OP_TIPO NOT IN (11,9)) or OP_TIPO=8 THEN ORD_NOMBRE ELSE 'PARTICULARES' END) + REPLICATE(' ',16),16) AS CL_NOMBRE_EMPRESA_INDIVIDUO,	   		
	   		LEFT(ORD_NOMBRE + REPLICATE(' ',16),16) AS RA_NOMBRE_EMPRESA_INDIVIDUO    	  
	   			
	FROM 
		(
		SELECT DISTINCT VT1.ORD_NRO_DOC
						, VT1.BEN_BANCO
						, VT1.OP_CLASE_TRANS
						, VT1.OP_TIPO
						, VT1.ORD_NOMBRE
						, vt1.ORD_TIPO_DOC
		FROM VTA_TRANSFERENCIAS VT1
		WHERE VT1.OP_CLASE_TRANS = 'E' 
		AND VT1.ESTADO='PP' 
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
	
		SET @CL_MONEDA_TRANSACCION =(SELECT TOP 1 concat('01',RIGHT(adicional_present,1)) FROM VTA_TRANSFERENCIAS_TIPOS WHERE id_tipo=@cl_op_tipo)
  		SET @FA_CANT_LOTES_ARCHIVO = @FA_CANT_LOTES_ARCHIVO + 1;
  		SET @CantRegistrosTotal +=1;
  		SET @CL_NUM_LOTE_CAB_NEW +=1;
  
		DECLARE @CL_NUMERO_LOTE VARCHAR(7) = @CL_NUM_LOTE_CAB;
		

		SET @CL_CABECERA = concat(@CL_ID_REG, @CL_CODIGO_CLASE_TRANSAC, @CL_NOMBRE_EMPRESA_INDIVIDUO, @CL_INFORMACION_DISCRECIONAL, @CL_IDENTIFICACION_EMP_IND, @CL_TIPO_REGISTRO, @CL_RESERVADO, @CL_FECHA_PRESENTACION, @CL_FECHA_COMPENSACION, @CL_MONEDA_TRANSACCION, @CL_DIGITO_VERIFICADOR, @CL_ID_ENTIDAD_ORIGEN, RIGHT(REPLICATE('0',7) + CAST(@CL_NUM_LOTE_CAB_NEW AS VARCHAR(7)),7));
		----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

		--- Grabar la cabecera de lote ---------------------------------------------------------------------------------------------------------------------------------------------------------------
		INSERT INTO ITF_COELSA_MPD_TEMP (LINEA) VALUES (@CL_CABECERA);
		----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

		--- Variables Registro Individual -------------------------------------------------------------------------------------------------------------------------------------------------------------
		DECLARE @RI_ID_REG VARCHAR(1) = '6';
		DECLARE @RI_CODIGO_TRANSAC VARCHAR(2) = '32';
		DECLARE @RI_ENTIDAD_AACREDITAR VARCHAR(8);
		DECLARE @RI_RESERVADO VARCHAR(1) = '0';
		DECLARE @RI_CUENTA_AACREDITAR VARCHAR(17); 
		DECLARE @RI_IMPORTE VARCHAR(10); 
		DECLARE @RI_REFERENCIA_UNIVOCA VARCHAR(15); 
		DECLARE @RI_IDENTIFICACION_CLIENTE_BEN VARCHAR(22);
		DECLARE @RI_MONEDA VARCHAR(2);
		DECLARE @RI_REGISTRO_ADICIONAL VARCHAR(1) = '1'; 
		DECLARE @RI_CONTADOR_REGISTRO VARCHAR(15);


		DECLARE @RI_REGISTRO_INDIVIDUAL VARCHAR (200);
	
		-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		--- Variables Registro Adicional------------------------------------------------------------------------------------------------------------------------------------------------------
		DECLARE @RA_ID_REG VARCHAR(1) = '7'; 
		DECLARE @RA_CODIGO_TIPO_ADICIONAL VARCHAR(2) = '05';
		DECLARE @RA_CODIGO_CONCEPTO VARCHAR(80);
		DECLARE @RA_CODIGO_MOTIVO_RECHAZO VARCHAR(3);
		DECLARE @RA_NUM_SECUENCIA VARCHAR(4)='0001';	--Contador de registro de transacción original
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
		DECLARE @FA_SUMA_TOTAL_DEBITOS VARCHAR(12);--cambio largo a 12
		DECLARE @FA_SUMA_TOTAL_CREDITOS VARCHAR(12);
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
    		RIGHT(CONCAT(replicate('0',8),convert(BIGINT,substring(TR.BEN_CBU,1,7))+5000000),8) AS RI_ENTIDAD_AACREDITAR --Numero de sucursal destino,
    		, (CASE WHEN BEN_CBU='' THEN replicate('0',17) ELSE right(concat(replicate('0',17),RIGHT(BEN_CBU,14)),17) END) AS DP_NUMERO_CUENTA --Cuenta a acreditar
    		, TR.OP_IMPORTE AS IMPORTE --6 importe
     		, CONCAT(isnull(tr.OP_REFERENCIA,'   '), RIGHT(REPLICATE('0',12) + CAST(TR.OP_NUMERO AS VARCHAR(12)) ,12)) AS RI_REFERENCIA_UNIVOCA--Referencia univoca de la transferencia
     		, LEFT(CAST(concat((CASE WHEN TR.BEN_TIPO_DOC = 'CUIT' THEN '1' WHEN TR.BEN_TIPO_DOC = 'CUIL' THEN '2' ELSE '3' END),RIGHT(REPLICATE('0',11) + CAST(TR.BEN_NRO_DOC AS VARCHAR(11)), 11),REPLICATE(' ',7), (CASE WHEN TR.BEN_MISMO_TITULAR='N' THEN '073' else '074' end)) AS VARCHAR(22)) + REPLICATE(' ',22),22) AS RI_IDENTIFICACION_CLIENTE_BEN --código de operatoria del BCRA:73,74,75 ...POR REVISAR Y COMPLETAR
     		, CONCAT((CASE WHEN TR.OP_MONEDA=1 THEN '0' WHEN TR.OP_MONEDA=2 THEN '1' ELSE '2' END), RIGHT(CAST(TR.OP_TIPO AS VARCHAR(3)), 1)) AS RI_MONEDA--Tipo de transferencia
	 		, TR.BEN_BANCO AS DP_BANCO
     		, RIGHT(BEN_SUCURSAL,3) AS DP_SUCURSAL
	 		, RIGHT(REPLICATE('0',3) + CAST(TR.MOTIVO_RECHAZO AS VARCHAR(10)), 3) AS RA_CODIGO_MOTIVO_RECHAZO
	 		, CONCAT(RIGHT(REPLICATE('0',4) + (CASE WHEN TR.OP_MONEDA=2 THEN CAST((TR.BEN_BANCO + 500) AS VARCHAR(10)) ELSE CAST(TR.BEN_BANCO AS VARCHAR(10)) END), 4), RIGHT(REPLICATE('0',4) + SUBSTRING(TR.BEN_CBU,4,4),4)) AS RA_ENTIDAD_TRAN_ORIGINAL
	 		, LEFT(UPPER(TR.OP_MOTIVO) + REPLICATE(' ',44),44) AS RA_INFORMACION_ADICIONAL
	 		, tR.OP_NUMERO	 
    	FROM VTA_TRANSFERENCIAS TR (NOLOCK)
    	WHERE TR.OP_CLASE_TRANS = 'E' 
    	and TR.ESTADO='PP' 
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
			IF (@SumaImportes > 9999999999.99 OR @SumaEntidad > 999999 OR @FA_SUMA_ACUMULADA > 999999999999.99)
			BEGIN
				PRINT @SumaImportes
				IF @SumaSucursal > 9999
				BEGIN
					SET @SobranteSucursal = CAST(substring(CAST(@SumaSucursal AS VARCHAR), 1, (len(@SumaSucursal) - 4)) AS NUMERIC);
					SET @SumaEntidad += @SobranteSucursal;
					SET @SumaSucursal = CAST(RIGHT(@SumaSucursal, 4) AS NUMERIC);
				END
		
				SET @TotalesControl += @SumaEntidad + @SumaSucursal;
	   			SET @FL_TOTALES_DE_CONTROL = right(concat(replicate('0', 10), (SELECT sum(convert(INT,substring(linea,4,8))) FROM ITF_COELSA_MPD_TEMP WHERE LINEA LIKE '6%' AND ID>(SELECT max(id) FROM ITF_COELSA_MPD_TEMP WHERE LINEA LIKE '5%'))),10);
				SET @FL_SUMA_TOTAL_DEBITO_LOTE  = RIGHT(replicate('0', 12), 12);
	   			SET @FL_SUMA_TOTAL_CREDITO_LOTE = RIGHT(concat(replicate('0', 12), (replace(@SumaImportes, '.', ''))), 12); 
				SET @TotalesCreditos += @SumaImportes
				SET @FA_SumaEntidad = @FA_SumaEntidad + @SumaEntidad
				SET @FA_SumaSucursal = @FA_SumaSucursal + @SumaSucursal
				SET @FL_CANT_REG_INDIVIDUAL_ADICIONAL = (SELECT count(1) FROM ITF_COELSA_MPD_TEMP WHERE substring(linea,1,1) IN ('6','7') AND ID>(SELECT max(id) FROM ITF_COELSA_MPD_TEMP WHERE LINEA LIKE '5%')) 
	   			SET @FL_FIN_LOTE = concat(@FL_ID_REG, @FL_CODIGO_CLASE_TRANSAC,RIGHT(CONCAT(REPLICATE('0',6),CAST(@FL_CANT_REG_INDIVIDUAL_ADICIONAL AS NUMERIC)),6), @FL_TOTALES_DE_CONTROL, @FL_SUMA_TOTAL_DEBITO_LOTE, @FL_SUMA_TOTAL_CREDITO_LOTE, @CL_IDENTIFICACION_EMP_IND, @FL_RESERVADO2, @FL_RESERVADO3, @FL_REG_ENTIDAD_ORIGEN, /*@CL_NUMERO_LOTE*/ RIGHT(REPLICATE('0',7) + CAST(@CL_NUM_LOTE_CAB_NEW AS VARCHAR(7)),7));	
		
				INSERT INTO dbo.ITF_COELSA_MPD_TEMP (LINEA) VALUES (replace(@FL_FIN_LOTE, '.', ''));
		
				-------------------------------------------------------------------
				-------------Grabamos el Fin de Archivo ----------------------------------------------------------------------------------------------------------------------
		
				SET @FA_TOTALES_DE_CONTROL = right(concat(replicate('0', 10), (SELECT sum(convert(INT,substring(linea,4,8))) FROM ITF_COELSA_MPD_TEMP WHERE LINEA LIKE '6%' AND ID>(SELECT max(id) FROM ITF_COELSA_MPD_TEMP WHERE LINEA LIKE '1%'))),10);
		
				SET @FA_CANT_LOTES = RIGHT(concat(replicate('0', 6), @FA_CANT_LOTES_ARCHIVO), 6);
        		
				SET @FA_NUMERO_BLOQUES = RIGHT(CONCAT(REPLICATE('0',6) , CAST((CASE WHEN @CantRegistrosTotal % 10 = 0 THEN (@CantRegistrosTotal/10) ELSE (FLOOR(@CantRegistrosTotal /10) + 1) END) AS INTEGER)),6);

				SET @FA_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate('0', 8), (SELECT count(id) FROM ITF_COELSA_MPD_TEMP WHERE (LINEA LIKE '6%' OR LINEA LIKE '7%') AND id>(SELECT max(id) FROM ITF_COELSA_MPD_TEMP WHERE LINEA LIKE '1%'))), 8);
					
				SET @FA_SUMA_TOTAL_DEBITOS = RIGHT(concat(replicate('0', 12), @TotalesDebitos), 12);
		
				SET @FA_TotalesCreditos = @FA_TotalesCreditos + @SumaImportes		
				SET @FA_SUMA_TOTAL_CREDITOS = RIGHT(concat(replicate('0', 12), (replace((SELECT convert(NUMERIC(15,2),sum(convert(NUMERIC,substring(linea,30,10)))/100) FROM ITF_COELSA_MPD_TEMP WHERE LINEA LIKE '6%' AND ID>(SELECT max(id) FROM ITF_COELSA_MPD_TEMP WHERE LINEA LIKE '1%') ), '.', ''))), 12);

		
				SET @FA_FIN_ARCHIVO = concat(@FA_ID_REG, RIGHT(REPLICATE('0',6) + CAST(@CL_NUM_LOTE_CAB_NEW AS VARCHAR(6)),6), @FA_NUMERO_BLOQUES, @FA_CANT_REG_INDIVIDUAL_ADICIONAL, @FA_TOTALES_DE_CONTROL, @FA_SUMA_TOTAL_DEBITOS, @FA_SUMA_TOTAL_CREDITOS, @FA_RESERVADO);
		

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
		
				SET @CL_CABECERA = concat(@CL_ID_REG, @CL_CODIGO_CLASE_TRANSAC, @CL_NOMBRE_EMPRESA_INDIVIDUO, @CL_INFORMACION_DISCRECIONAL, @CL_IDENTIFICACION_EMP_IND, @CL_TIPO_REGISTRO, @CL_RESERVADO, @CL_FECHA_PRESENTACION, @CL_FECHA_COMPENSACION, @CL_MONEDA_TRANSACCION, @CL_DIGITO_VERIFICADOR, @CL_ID_ENTIDAD_ORIGEN, right(concat(replicate('0',7), @CL_NUM_LOTE_CAB_NEW),7));
		
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
			IF	(@DP_IMPORTE > 99999999.99)
			BEGIN
				SET @Excedente = (@DP_IMPORTE - 99999999.99);
				SET @DP_IMPORTE = 99999999.99;
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

				SET @RI_ENTIDAD_AACREDITAR= concat(RIGHT(concat(replicate('0', 4), @DP_BANCO+500), 4), '0888'); --agregue el +500 aca
        		SET @RI_CUENTA_AACREDITAR = RIGHT(concat(replicate('0', 17), '88888888888'), 17);
    
			END
    		ELSE --la razon de este else, es que SumaSucursal, cuando hay excedente tiene que acumular 0888
    		BEGIN
			
				SET @SumaSucursal += @DP_SUCURSAL;
				SET @SumaEntidad += @DP_BANCO;
				SET @SumaImportes += @DP_IMPORTE;
		
		
	
			END
			IF @SumaImportes>9999999999.99
				GOTO Start
			SET @RI_IMPORTE = RIGHT(concat(replicate('0', 10), replace(CAST(@DP_IMPORTE AS VARCHAR),'.','')), 10);
	
	
		    --Condicion de reset del contador de reg individual
 			IF ISNULL((SELECT a.FECHA FROM ITF_MASTER_PARAMETROS a WHERE a.CODIGO = 442), CAST('01-01-1800' AS DATETIME)) <> (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK))
  
	    	UPDATE dbo.ITF_MASTER_PARAMETROS SET NUMERICO_1 = 1, FECHA = (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)) WHERE CODIGO = 442;
   
			SET @RI_MONEDA=(SELECT TOP 1 concat('1',RIGHT(adicional_present,1)) FROM VTA_TRANSFERENCIAS_TIPOS WHERE id_tipo=@cl_op_tipo)
			SET @RI_CONTADOR_REGISTRO = concat(@cl_id_entidad_origen, RIGHT(concat(replicate('0', 7), (SELECT a.NUMERICO_1 FROM ITF_MASTER_PARAMETROS a WHERE CODIGO = 442)), 7)); 

			--Incremento el contador
    		UPDATE dbo.ITF_MASTER_PARAMETROS SET NUMERICO_1 += 1 WHERE CODIGO = 442;
	
			SET @RI_REGISTRO_INDIVIDUAL = concat(@RI_ID_REG, @RI_CODIGO_TRANSAC, @RI_ENTIDAD_AACREDITAR, @RI_RESERVADO, @RI_CUENTA_AACREDITAR, @RI_IMPORTE, @RI_REFERENCIA_UNIVOCA, @RI_IDENTIFICACION_CLIENTE_BEN, @RI_MONEDA, @RI_REGISTRO_ADICIONAL, @RI_CONTADOR_REGISTRO);

			INSERT INTO ITF_COELSA_MPD_TEMP (LINEA) VALUES (replace(@RI_REGISTRO_INDIVIDUAL, '.', ''));
			
			UPDATE dbo.VTA_TRANSFERENCIAS 
    		SET ESTADO='PR' 
    			, TRACENUMBER=@RI_CONTADOR_REGISTRO
    		WHERE OP_NUMERO=@T_REFERENCIA
    		AND OP_CLASE_TRANS='E';
	
			--- Grabar Registro Adicional -----------------------------------------------------------------------------

			SET @RA_CONTADOR_REG_ADICIONAL = RIGHT(@RI_CONTADOR_REGISTRO,7);
			SET @RA_CODIGO_CONCEPTO = CONCAT(@CL_ORD_NRO_DOC, LEFT(@RA_NOMBRE_EMPRESA_INDIVIDUO + REPLICATE(' ' ,69), 69));
	
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
		

		SET @FL_TOTALES_DE_CONTROL = right(concat(replicate('0', 10), (SELECT sum(convert(INT,substring(linea,4,8))) FROM ITF_COELSA_MPD_TEMP WHERE LINEA LIKE '6%' AND ID>(SELECT max(id) FROM ITF_COELSA_MPD_TEMP WHERE LINEA LIKE '5%'))),10); --relleno y separo con ceros

		SET @TotalesControl += CAST(@FL_TOTALES_DE_CONTROL AS INTEGER); --lo uso para armar el totalControl del reg FA

		SET @FL_SUMA_TOTAL_DEBITO_LOTE  = replicate('0', 12);
		SET @FL_SUMA_TOTAL_CREDITO_LOTE = RIGHT(concat(replicate('0', 12), (replace(@SumaImportes, '.', ''))), 12); 
		SET @TotalesCreditos += @SumaImportes;
	  
		--SELECT @FL_SUMA_TOTAL_CREDITO_LOTE
		SET @CantRegistrosTotal +=1;
		SET @FL_CANT_REG_INDIVIDUAL_ADICIONAL = (SELECT count(1) FROM ITF_COELSA_MPD_TEMP WHERE substring(linea,1,1) IN ('6','7') AND ID>(SELECT max(id) FROM ITF_COELSA_MPD_TEMP WHERE LINEA LIKE '5%')) 

		SET @FL_FIN_LOTE = concat(@FL_ID_REG, @FL_CODIGO_CLASE_TRANSAC, RIGHT(CONCAT(REPLICATE('0',6),CAST(@FL_CANT_REG_INDIVIDUAL_ADICIONAL AS NUMERIC)),6), @FL_TOTALES_DE_CONTROL, @FL_SUMA_TOTAL_DEBITO_LOTE, @FL_SUMA_TOTAL_CREDITO_LOTE, @CL_IDENTIFICACION_EMP_IND, @FL_RESERVADO2, @FL_RESERVADO3, @FL_REG_ENTIDAD_ORIGEN, /*@CL_NUMERO_LOTE*/  RIGHT(REPLICATE('0',7) + CAST(@CL_NUM_LOTE_CAB_NEW AS VARCHAR(7)),7) );
		-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

		--- Grabamos la fin de lote del archivo ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		INSERT INTO dbo.ITF_COELSA_MPD_TEMP (LINEA) VALUES (replace(@FL_FIN_LOTE, '.', ''));


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


	SET @FA_TOTALES_DE_CONTROL = right(concat(replicate('0', 10), (SELECT sum(convert(INT,substring(linea,4,8))) FROM ITF_COELSA_MPD_TEMP WHERE LINEA LIKE '6%' AND ID>(SELECT max(id) FROM ITF_COELSA_MPD_TEMP WHERE LINEA LIKE '1%'))),10);
	SET @FA_CANT_LOTES = RIGHT(concat(replicate('0', 6), (SELECT count(id) FROM ITF_COELSA_MPD_TEMP WHERE LINEA LIKE '5%' AND id>(SELECT max(id) FROM ITF_COELSA_MPD_TEMP WHERE LINEA LIKE '1%'))), 6);
	SET @FA_NUMERO_BLOQUES = RIGHT(concat(replicate('0', 6), (SELECT CEILING((count(*)+1) / CONVERT(FLOAT, 10)) FROM ITF_COELSA_MPD_TEMP WHERE  ID>=(SELECT max(id) FROM ITF_COELSA_MPD_TEMP WHERE LINEA LIKE '1%'))), 6);
	SET @FA_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate('0', 8), (SELECT count(id) FROM ITF_COELSA_MPD_TEMP WHERE (LINEA LIKE '6%' OR LINEA LIKE '7%') AND id>(SELECT max(id) FROM ITF_COELSA_MPD_TEMP WHERE LINEA LIKE '1%'))), 8);
	SET @FA_SUMA_TOTAL_DEBITOS = RIGHT(concat(replicate('0', 12), @TotalesDebitos), 12);
	SET @FA_SUMA_TOTAL_CREDITOS = RIGHT(concat(replicate('0', 12), (replace((SELECT convert(NUMERIC(15,2),sum(convert(NUMERIC,substring(linea,30,10)))/100) FROM ITF_COELSA_MPD_TEMP WHERE LINEA LIKE '6%' AND ID>(SELECT max(id) FROM ITF_COELSA_MPD_TEMP WHERE LINEA LIKE '1%') ), '.', ''))), 12);

	SET @FA_FIN_ARCHIVO = concat(@FA_ID_REG, @FA_CANT_LOTES, @FA_NUMERO_BLOQUES, @FA_CANT_REG_INDIVIDUAL_ADICIONAL, @FA_TOTALES_DE_CONTROL /*@FL_TOTALES_DE_CONTROL --Elisvan*/, @FA_SUMA_TOTAL_DEBITOS, @FA_SUMA_TOTAL_CREDITOS, @FA_RESERVADO);
PRINT @FA_FIN_ARCHIVO
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
GO

