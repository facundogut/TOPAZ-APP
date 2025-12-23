EXECUTE('
IF OBJECT_ID (''[dbo].[SP_COELSA_CHEQUES_TERCEROS_RECHAZADOS]'') IS NOT NULL
	DROP PROCEDURE [dbo].[SP_COELSA_CHEQUES_TERCEROS_RECHAZADOS]

')
EXECUTE('

DELETE FROM dbo.ITF_MASTER
WHERE ID = 95

DELETE FROM dbo.ITF_MASTER
WHERE ID = 96

INSERT INTO dbo.ITF_MASTER (TZ_LOCK, ID, DESCRIPCION, OBJ_KETTLE, P0_MODO, P0_TIPO, P0_CAPTION, P0_CONSTANTE, P1_MODO, P1_TIPO, P1_CAPTION, P1_CONSTANTE, P2_MODO, P2_TIPO, P2_CAPTION, P2_CONSTANTE, P3_MODO, P3_TIPO, P3_CAPTION, P3_CONSTANTE, P4_MODO, P4_TIPO, P4_CAPTION, P4_CONSTANTE, P5_MODO, P5_TIPO, P5_CAPTION, P5_CONSTANTE, P6_MODO, P6_TIPO, P6_CAPTION, P6_CONSTANTE, P7_MODO, P7_TIPO, P7_CAPTION, P7_CONSTANTE, P8_MODO, P8_TIPO, P8_CONSTANTE, P8_CAPTION, P9_MODO, P9_TIPO, P9_CAPTION, P9_CONSTANTE, TIPO_OBJ, COMENTARIO, ID_REPORTE, MODO_EJECUCION)
VALUES (0, 95, ''ITF_COELSA_DPFD_RECHAZADOS_RECIBIDOS'', ''ITF_COELSA_DPFD_RECHAZADOS_RECIBIDOS.kjb'', '''', '''', '''', '' '', '''', '''', '''', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', ''J'', '' '', 0, ''M'')

INSERT INTO dbo.ITF_MASTER (TZ_LOCK, ID, DESCRIPCION, OBJ_KETTLE, P0_MODO, P0_TIPO, P0_CAPTION, P0_CONSTANTE, P1_MODO, P1_TIPO, P1_CAPTION, P1_CONSTANTE, P2_MODO, P2_TIPO, P2_CAPTION, P2_CONSTANTE, P3_MODO, P3_TIPO, P3_CAPTION, P3_CONSTANTE, P4_MODO, P4_TIPO, P4_CAPTION, P4_CONSTANTE, P5_MODO, P5_TIPO, P5_CAPTION, P5_CONSTANTE, P6_MODO, P6_TIPO, P6_CAPTION, P6_CONSTANTE, P7_MODO, P7_TIPO, P7_CAPTION, P7_CONSTANTE, P8_MODO, P8_TIPO, P8_CONSTANTE, P8_CAPTION, P9_MODO, P9_TIPO, P9_CAPTION, P9_CONSTANTE, TIPO_OBJ, COMENTARIO, ID_REPORTE, MODO_EJECUCION)
VALUES (0, 96, ''ITF_COELSA_CHEQUES_DPF_TERCEROS_RECHAZADOS'', ''ITF_COELSA_CHEQUES_DPF_TERCEROS_RECHAZADOS.kjb'', '''', '''', '''', '' '', '''', '''', '''', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', ''J'', '' '', 0, ''M'')

')
EXECUTE('
CREATE PROCEDURE [dbo].[SP_COELSA_CHEQUES_TERCEROS_RECHAZADOS]

@TICKET NUMERIC(16)

AS
BEGIN

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- Modified : 26/10/2021 10:00 a.m.
--- Autor: Luis Etchebarne 
--- Se graban los ajustes en el histórico.
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- Modified : 20/10/2021 10:00 a.m.
--- Autor: Luis Etchebarne 
--- Se graba la tabla ITF_COELSA_SESION_RECHAZADOS para llevar un historial de los registros.
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- Modified : 14/10/2021 10:00 a.m.
--- Autor: Luis Etchebarne 
--- Se agregaron validaciones para tomar solo fecha_acreditacion = fecha_proceso.
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- Modified : 06/10/2021 10:00 a.m.
--- Autor: Luis Etchebarne 
--- Se agregaron las lecturas a las tablas bases para sacar las claves de cheques y dpf.
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- Modified : 23/08/2021 10:00 a.m.
--- Autor: Luis Etchebarne 
--- Debido al cambio de clave en las tablas de cheques, se ajusta el insert para contemplar dicho cambio.
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- Created : 29/07/2021 12:00 a.m.
--- Autor: Luis Etchebarne 
--- Se crea el sp con el fin de procesar los registros de cheques de terceros rechazados a través del plano (ITF_OTROS_CHEQUES_RESPUESTA_AUX).
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/******** Variables Cabecera de Archivo **********************************/
DECLARE @IdRegistro NUMERIC(1);
DECLARE @CodPrioridad NUMERIC(2);
DECLARE @DestinoInmediato NUMERIC(10);
DECLARE @OrigenInmediato NUMERIC(10);
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

/******** Variables FIN DE LOTE *************/ 
DECLARE @RegIndivAdic NUMERIC(6);
DECLARE @TotalesControl NUMERIC(10);
DECLARE @SumaDebLote NUMERIC(12); 
DECLARE @SumaCredLote NUMERIC(12);
DECLARE @ReservadoFL VARCHAR(40);

/******** Variables FIN DE ARCHIVO *************/ 

DECLARE @CantLotesFA NUMERIC(6);
DECLARE @NumBloquesFA NUMERIC(6);
DECLARE @CantRegAdFA NUMERIC (8);
DECLARE @TotalesControlFA NUMERIC(10);
DECLARE @SumaTotDebitosFA NUMERIC(12);
DECLARE @SumaTotCreditosFA NUMERIC(12);
DECLARE @ReservadoFA VARCHAR(39);
/*************************************************************************/
DECLARE @SumatoriaDebitosRI NUMERIC(12) = 0;

/*Validaciones generales */
IF(0=(SELECT COUNT(*) FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX WHERE LINEA LIKE ''1%''))
RAISERROR (''Error raised in TRY block.'', 16, 1);
IF(0=(SELECT COUNT(*) FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX WHERE LINEA LIKE ''5%''))
RAISERROR (''Error raised in TRY block.'', 16, 1);
IF(0=(SELECT COUNT(*) FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX WHERE LINEA LIKE ''8%''))
RAISERROR (''Error raised in TRY block.'', 16, 1);
IF(0=(SELECT COUNT(*) FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX WHERE LINEA LIKE ''9%''))
RAISERROR (''Error raised in TRY block.'', 16, 1);

IF((SELECT SUM(CONVERT(NUMERIC(12),substring(LINEA, 21, 12))) FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX WHERE LINEA LIKE ''8%'')<>(SELECT SUM(CONVERT(NUMERIC(12),substring(LINEA, 32, 12))) FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX WHERE LINEA LIKE ''9%''))
RAISERROR (''Sum cabezal no concuerda con arch.'', 16, 1);


DECLARE @LINEA VARCHAR(94);
DECLARE che_cursor CURSOR FOR 
SELECT LINEA 
FROM dbo.ITF_OTROS_CHEQUES_RESPUESTA_AUX

OPEN che_cursor  

FETCH NEXT FROM che_cursor INTO @LINEA  

WHILE @@FETCH_STATUS = 0  
BEGIN  
      SET @IdRegistro = substring(@LINEA, 1, 1);
      
      IF(@IdRegistro NOT IN(''1'',''5'',''6'',''7'',''8'',''9'') ) --validacion de id reg
      BEGIN
      	RAISERROR (''Id Registro invalido'', 16, 1);
      END
      	
     
      /* Cabecera de Archivo */
      IF (@IdRegistro = ''1'') 
      BEGIN
      	SET @CodPrioridad = substring(@LINEA, 2, 2);
      	IF(@CodPrioridad<>1)
      	BEGIN
      	 RAISERROR (''Error raised in TRY block.'', 16, 1);
      	END
      	
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
		BEGIN
			RAISERROR (''Identificador Archivo invalido'', 16, 1);
		END
		  IF(@FactorBloque <> 10) 
      	BEGIN
    		RAISERROR (''Factor Bloque debe ser igual a 10'', 16, 1); 
      	END

      	
      END
      
      
      IF (@IdRegistro = ''5'') 
      BEGIN

	  	--variables cabecera de lote
		SET @ClaseTransaccion = substring(@LINEA, 2, 3);
		SET @ReservadoLote = substring(@LINEA, 5, 46); --VALIDACION RESERVADO VACIO
		SET @CodigoRegistro = substring(@LINEA, 51, 3);
		
        SET @FechaPresentacion = CAST(substring(@LINEA, 64, 6) AS DATE); --VALIDACION FECHAS
      	SET @FechaVencimiento = CAST(substring(@LINEA, 70, 6) AS DATE);
        SET @ReservadoLoteCeros = substring(@LINEA, 76, 3); --VALIDACION RESERVADO 000
        SET @CodigoOrigen = substring(@LINEA, 79, 1); 

        SET @IdEntidadOrigen = substring(@LINEA, 80, 4);

	 	SET @NumeroLote = substring(@LINEA, 88, 7);

		IF (@ClaseTransaccion <> 200) 
      	BEGIN
    		RAISERROR (''Codigo de clase de transaccion debe ser 200'', 16, 1); 
      	END		

		IF (LEN(@ReservadoLote) <> 0) 
      	BEGIN
    		RAISERROR (''Campos reservados deben estar vacios'', 16, 1); 
      	END	

        IF (@ReservadoLoteCeros <> 000) 
      	BEGIN
    		RAISERROR (''Campo reservado debe ser 000'', 16, 1); 
      	END	

        IF (@CodigoOrigen <> 1) 
      	BEGIN
    		RAISERROR (''Codigo origen debe ser 1'', 16, 1); 
      	END	

		IF (@CodigoRegistro <> ''TRC'') 
      	BEGIN
    		RAISERROR (''Codigo de registro debe ser TRC'', 16, 1); 
      	END	
      	
      	IF (@FechaPresentacion > @FechaVencimiento) 
      	BEGIN
    		RAISERROR (''Fecha Presentacion debe ser anterior a vencimiento'', 16, 1); 
      	END	
      	   			
		IF (@IdEntidadOrigen <> 311) 
      	BEGIN
    		RAISERROR (''Id de entidad de origen debe ser 0811'', 16, 1); 
      	END	
      END
      
      /* Registro Individual */
      IF (@IdRegistro = ''6'') 
      BEGIN
      	SET @CodTransaccion = substring(@LINEA, 2, 2);
      	SET @EntidadDebitar = substring(@LINEA, 4, 8);
      	SET @ReservadoRI = substring(@LINEA, 12, 1);
      	SET @CuentaDebitar = substring(@LINEA, 13, 17);
      	SET @Importe = substring(@LINEA, 30, 10);
      	SET @NumeroCheque = substring(@LINEA, 40, 15);
      	SET @CodigoPostal = substring(@LINEA, 55, 6);
      	SET @PuntoIntercambio = substring(@LINEA, 61, 16);
      	SET @InfoAdicional = substring(@LINEA, 77, 2);
      	SET @RegistrosAdicionales = substring(@LINEA, 79, 2);
      	SET @ContadorRegistros = substring(@LINEA, 80, 15); /* Trace Number */
      	
      	DECLARE @Entidad NUMERIC(4) = CAST(substring(@EntidadDebitar, 1, 4) AS NUMERIC);
      	DECLARE @Sucursal NUMERIC(4) = CAST(substring(@EntidadDebitar, 4, 4) AS NUMERIC);
      	DECLARE @CodRechazo NUMERIC(2) =  RIGHT(CAST(@PuntoIntercambio AS NUMERIC), 3);
      	
      	SET @SumatoriaDebitosRI += @Importe;
      	
      	IF (@ReservadoRI <> ''0'') 
      	BEGIN
    		RAISERROR (''Reservado de RI debe ser 0'', 16, 1); 
      	END

        IF (@InfoAdicional NOT IN(''10'',''11'')) 
      	BEGIN
    		RAISERROR (''Informacion Adicional invalido'', 16, 1); 
      	END

        IF (@RegistrosAdicionales NOT IN(''1'',''0'')) 
      	BEGIN
    		RAISERROR (''Campo Registro adicional invalido'', 16, 1); 
      	END
      	
      	/*FIN DE LOTE*/
      IF (@IdRegistro = ''8'') 
      BEGIN
		SET @ClaseTransaccion = substring(@LINEA, 2, 3);
	  	SET @RegIndivAdic = substring(@LINEA, 5, 6);
	  	SET @TotalesControl = substring(@LINEA, 11,10);
	  	SET @SumaDebLote = substring(@LINEA, 21, 12);
	   	SET @SumaCredLote = substring(@LINEA, 33, 12);
	   	SET @ReservadoFL = substring(@LINEA, 45, 35);
	  	SET @IdEntidadOrigen = substring(@LINEA, 80, 4);
	  	SET @NumeroLote = substring(@LINEA, 88, 7);  

		
        IF (@SumaDebLote <> @SumatoriaDebitosRI) 
      	BEGIN
    		RAISERROR (''No coincide la sumatoria de importes del FL'', 16, 1); 
      	END

		IF (@ClaseTransaccion <> 200) 
		BEGIN
			RAISERROR (''Codigo de clase de transaccion debe ser 200'', 16, 1); 
		END		
		
		
		IF (LEN(@ReservadoFL) <> 0) 
		BEGIN
			RAISERROR (''Espacio reservado debe estar vacio'', 16, 1); 
		END	

		IF (@IdEntidadOrigen <> 311) 
      	BEGIN
    		RAISERROR (''Id de entidad de origen debe ser 0811'', 16, 1); 
      	END

      END
    	
        /*FIN DE ARCHIVO*/
      IF (@IdRegistro = ''9'') 
      BEGIN
        SET @CantLotesFA = substring(@LINEA, 2, 6);
        SET @NumBloquesFA = substring(@LINEA, 8, 6);
        SET @CantRegAdFA = substring(@LINEA, 14, 8);
        SET @TotalesControlFA  = substring(@LINEA, 22, 10);
        SET @SumaTotDebitosFA  = substring(@LINEA, 32, 12);
        SET @SumaTotCreditosFA  = substring(@LINEA, 44, 12);
        SET @ReservadoFA  = substring(@LINEA, 56, 39);
        

        IF (@SumaTotDebitosFA <> @SumatoriaDebitosRI) 
      	BEGIN
    		RAISERROR (''No coincide la sumatoria de importes del FA'', 16, 1); 
      	END

      END	
    	
      	--- Variables Generales ---
      	DECLARE @NRO_DPF_CHEQUE NUMERIC(12);
      	DECLARE @BANCO_GIRADO NUMERIC(4);
      	DECLARE @SUCURSAL_BANCO NUMERIC(5);
      	DECLARE @FECHA_ALTA DATETIME;
      	DECLARE @TIPO_DOCUMENTO VARCHAR(4);
      	DECLARE @IMPORTE_TOTAL NUMERIC(10,2);
      	DECLARE @SERIE_DEL_CHEQUE VARCHAR(6);
      	DECLARE @NRO_CUENTA NUMERIC(12);
      	DECLARE @CODIGO_POSTAL NUMERIC(4);
      	DECLARE @MONEDA NUMERIC(4);
      	DECLARE @EXISTE NUMERIC(4) = 0;
      	DECLARE @ORDINAL NUMERIC(12);
      	
      	IF(@TICKET<>0)
      	BEGIN
      	
      	IF (CAST(@CuentaDebitar AS NUMERIC) = 88888888888)
      	BEGIN
      		-- La idea es actualizar los rechazados del plano con ESTADO_AJUSTE = ''R'' y el resto de cheques del historial con ESTADO_AJUSTE  = ''A''	
      		UPDATE dbo.CLE_CHEQUES_AJUSTE SET ESTADO_AJUSTE = ''R'' WHERE TRACKNUMBER = CAST(@ContadorRegistros AS NUMERIC) AND FECHA_ACREDITACION = (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)) AND TZ_LOCK = 0;
      		
      		-- Consulta Ajuste
      		SELECT @EXISTE = 1, @ORDINAL = ORDINAL, @BANCO_GIRADO = BANCO, @FECHA_ALTA = FECHA_ALTA, @NRO_DPF_CHEQUE = NUMERO_CHEQUE, @SUCURSAL_BANCO = SUCURSAL_BANCO_GIRADO, @NRO_CUENTA = NUMERO_CUENTA, @CODIGO_POSTAL = CODIGO_POSTAL, @IMPORTE_TOTAL = IMPORTE, @MONEDA = MONEDA
      		FROM CLE_CHEQUES_AJUSTE WITH(NOLOCK) WHERE TRACKNUMBER = CAST(@ContadorRegistros AS NUMERIC) AND TZ_LOCK = 0;
      		
      		IF @EXISTE > 0
      		BEGIN
      			-- Insertamos en el historial
   				INSERT INTO ITF_COELSA_SESION_RECHAZADOS (ID_TICKET, FECHA_ALTA, BANCO, SUCURSAL, CUENTA, IMPORTE, CODIGO_POSTAL, NRO_CHEQUE, PUNTO_INTERCAMBIO, TRACK_NUMBER, TIPO, MONEDA, TIPO_DOCUMENTO, CODIGO_RECHAZO, ORDINAL)
   				VALUES(@TICKET, @FECHA_ALTA, @BANCO_GIRADO, @SUCURSAL_BANCO, @NRO_CUENTA, @IMPORTE_TOTAL, @CODIGO_POSTAL, @NRO_DPF_CHEQUE, @PuntoIntercambio, @ContadorRegistros, ''A'', @MONEDA, @TIPO_DOCUMENTO, @CodRechazo, @ORDINAL);
   			END
      	END
      	
      	ELSE IF (CAST(@CuentaDebitar AS NUMERIC) = 77777777777)
      	BEGIN
 			-- Consulta DPF  			
      		SELECT @EXISTE = 1, @TIPO_DOCUMENTO = TIPO_DOCUMENTO, @NRO_DPF_CHEQUE = NUMERO_DPF, @BANCO_GIRADO = BANCO_GIRADO, @SUCURSAL_BANCO = SUCURSAL_BANCO_GIRADO, @FECHA_ALTA = FECHA_ALTA, @IMPORTE_TOTAL = IMPORTE, @CODIGO_POSTAL = COD_POSTAL, @MONEDA = MONEDA, @NRO_CUENTA = NUMERICO_CUENTA_GIRADORA 
      		FROM CLE_DPF_SALIENTE WITH(NOLOCK) WHERE TRACKNUMBER = CAST(@ContadorRegistros AS NUMERIC) AND TZ_LOCK = 0; 
   			
   			IF @EXISTE > 0
   			BEGIN
      			INSERT INTO CLE_RECEPCION_DPF_DEV (NUMERO_DPF, BANCO_GIRADO, FECHA_ALTA, SUCURSAL_BANCO_GIRADO, TIPO_DOCUMENTO, IMPORTE_DPF, [CODIGO_CAMARA], ESTADO_DEVOLUCION, CODIGO_RECHAZO)
      			VALUES (@NRO_DPF_CHEQUE, @BANCO_GIRADO, @FECHA_ALTA, @SUCURSAL_BANCO, @TIPO_DOCUMENTO, @IMPORTE_TOTAL, (SELECT [CODIGO_DE_CAMARA] FROM CLE_CAMARAS_COMPENSADORAS WITH (NOLOCK)), 1, @CodRechazo);
      		END
      		
      		-- Insertamos en el historial
   			INSERT INTO ITF_COELSA_SESION_RECHAZADOS (ID_TICKET, FECHA_ALTA, BANCO, SUCURSAL, CUENTA, IMPORTE, CODIGO_POSTAL, NRO_CHEQUE, PUNTO_INTERCAMBIO, TRACK_NUMBER, TIPO, MONEDA, TIPO_DOCUMENTO, CODIGO_RECHAZO)
   			VALUES(@TICKET, @FECHA_ALTA, @BANCO_GIRADO, @SUCURSAL_BANCO, @NRO_CUENTA, @IMPORTE_TOTAL, @CODIGO_POSTAL, @NRO_DPF_CHEQUE, @PuntoIntercambio, @ContadorRegistros, ''D'', @MONEDA, @TIPO_DOCUMENTO, @CodRechazo);
      	END
      	
      	ELSE
      	BEGIN
      		-- Consulta Cheque
      		SELECT @EXISTE = 1, @NRO_DPF_CHEQUE = NRO_CHEQUE, @SERIE_DEL_CHEQUE = SERIE_DEL_CHEQUE, @BANCO_GIRADO = BANCO, @FECHA_ALTA = FECHA_PRESENTADO, @SUCURSAL_BANCO = SUCURSAL, @NRO_CUENTA = CUENTA, @TIPO_DOCUMENTO = TIPO_DOCUMENTO, @IMPORTE_TOTAL = IMPORTE, @CODIGO_POSTAL = CODIGO_POSTAL, @MONEDA = MONEDA
      		FROM ITF_COELSA_CHEQUES_OTROS WITH(NOLOCK) WHERE TRACE_NUMBER = CAST(@ContadorRegistros AS NUMERIC);
      		
      		IF @EXISTE > 0
   			BEGIN
      			INSERT INTO CLE_RECEPCION_CHEQUES_DEV (NUMERO_CHEQUE, SERIE_DEL_CHEQUE, BANCO_GIRADO, FECHA_ALTA, SUCURSAL_BANCO_GIRADO, NUMERO_CUENTA_GIRADORA, TIPO_DOCUMENTO, IMPORTE_CHEQUE, CODIGO_RECHAZO, ESTADO_DEVOLUCION, CODIGO_CAMARA)
      			VALUES (@NRO_DPF_CHEQUE, @SERIE_DEL_CHEQUE, @BANCO_GIRADO, @FECHA_ALTA, @SUCURSAL_BANCO, @NRO_CUENTA, @TIPO_DOCUMENTO, @IMPORTE_TOTAL, @CodRechazo, 1, (SELECT [CODIGO_DE_CAMARA] FROM CLE_CAMARAS_COMPENSADORAS WITH(NOLOCK)));
      		END
      		
      		-- Insertamos en el historial
   			INSERT INTO ITF_COELSA_SESION_RECHAZADOS (ID_TICKET, FECHA_ALTA, BANCO, SUCURSAL, CUENTA, IMPORTE, CODIGO_POSTAL, NRO_CHEQUE, PUNTO_INTERCAMBIO, TRACK_NUMBER, TIPO, MONEDA, TIPO_DOCUMENTO, CODIGO_RECHAZO, SERIE_DEL_CHEQUE)
   			VALUES(@TICKET, @FECHA_ALTA, @BANCO_GIRADO, @SUCURSAL_BANCO, @NRO_CUENTA, @IMPORTE_TOTAL, @CODIGO_POSTAL, @NRO_DPF_CHEQUE, @PuntoIntercambio, @ContadorRegistros, ''C'', @MONEDA, @TIPO_DOCUMENTO, @CodRechazo, @SERIE_DEL_CHEQUE);	   	
      	
      	END
      	
      	END
          
      END
      
      FETCH NEXT FROM che_cursor INTO @LINEA 
END 

CLOSE che_cursor  
DEALLOCATE che_cursor

--- Actualizar el estado de los ajustes no incluidos en el plano -------------------------------------------------------------
UPDATE dbo.CLE_CHEQUES_AJUSTE SET ESTADO_AJUSTE = ''A'' WHERE ESTADO_AJUSTE IS NULL AND ESTADO = ''P'' AND FECHA_ACREDITACION = (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)); 
------------------------------------------------------------------------------------------------------------------------------

END;
')

