EXECUTE('
IF OBJECT_ID (''dbo.ITF_DPFD_RECHAZ_AUX'') IS NOT NULL
	DROP TABLE dbo.ITF_DPFD_RECHAZ_AUX


IF OBJECT_ID (''[dbo].[SP_COELSA_DPFD_RECHAZADOS_RECIBIDOS]'') IS NOT NULL
	DROP PROCEDURE [dbo].[SP_COELSA_DPFD_RECHAZADOS_RECIBIDOS]

')

EXECUTE('
CREATE TABLE dbo.ITF_DPFD_RECHAZ_AUX
	(
	ID    INT IDENTITY NOT NULL,
	LINEA VARCHAR (200)
	)
')

EXECUTE('



CREATE PROCEDURE [dbo].[SP_COELSA_DPFD_RECHAZADOS_RECIBIDOS]
@TICKET NUMERIC(16)
AS
BEGIN

/******** Variables Cabecera de Archivo **********************************/
DECLARE @IdRegistro VARCHAR(1);
DECLARE @CodigoPrioridad VARCHAR(2);
DECLARE @OrigenInmediato NUMERIC(4);
DECLARE @HoraPresentacion NUMERIC(4);

DECLARE @IdentificadorArchivo VARCHAR(1);

DECLARE @TamanoRegistro NUMERIC(3);
DECLARE @CodigoFormato NUMERIC(1);
DECLARE @FactorBloque NUMERIC(2);
DECLARE @CodigoReferencia VARCHAR(8);
DECLARE @NombreOrigenInmediato VARCHAR(23);
DECLARE @NombreDestinoInmediato VARCHAR(23);

/******** Variables Cabecera de Lote **********************************/
DECLARE @FechaPresentacion DATE;
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
DECLARE @Importe NUMERIC(10);
DECLARE @NumeroCheque VARCHAR(15);
DECLARE @CodigoPostal VARCHAR(6);
DECLARE @PuntoIntercambio VARCHAR(16);
DECLARE @InfoAdicional VARCHAR(2);
DECLARE @RegistrosAdicionales VARCHAR(1);
DECLARE @ContadorRegistros VARCHAR(15); 

DECLARE @SumatoriaDebitosRI NUMERIC(12) = 0; --sera el acumulador de importes, para luego comparar con el fin de archivo

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


DECLARE @LINEA VARCHAR(94);
DECLARE che_cursor CURSOR FOR 
SELECT LINEA 
FROM dbo.ITF_DPFD_RECHAZ_AUX

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
	  	--variables de cabecera de archivo
        SET @CodigoPrioridad = substring(@LINEA,2,2);
		SET @OrigenInmediato = substring(@LINEA, 15, 4);
		SET @FechaPresentacion = substring(@LINEA, 24, 6);		
      	SET @HoraPresentacion = substring(@LINEA, 30, 4);		
		SET @IdentificadorArchivo = substring(@LINEA, 34, 1);
		SET @TamanoRegistro = substring(@LINEA, 35, 3); 
		SET @FactorBloque = substring(@LINEA, 38, 2); 
        SET @CodigoFormato = substring(@LINEA, 40, 1);
        SET @NombreDestinoInmediato = substring(@LINEA, 41, 23); 
        SET @NombreOrigenInmediato = substring(@LINEA, 64, 23); 
        SET @CodigoReferencia = substring(@LINEA, 87, 8);   
		
	 

        IF(@CodigoPrioridad <> 01) 
      	BEGIN
      	 RAISERROR (''Codigo de prioridad debe ser 01'', 16, 1);
      	END
      	
      	IF(@OrigenInmediato<>811) 
      	BEGIN
    		RAISERROR (''Origen Inmediato debe ser 0811'', 16, 1);
      	END
      	
		IF (@IdentificadorArchivo NOT IN (''A'',''B'',''C'',''D'',''E'',''F'',''G'',''H'',''I'',''J'',''K'',''L'',''M'',''N'',''O'',''P'',''Q'',''R'',''S'',''T'',''U'',''V'',''W'',''X'',''Y'',''Z'',''0'',''1'',''2'',''3'',''4'',''5'',''6'',''7'',''8'',''9'')) 
		BEGIN
			RAISERROR (''Identificador Archivo invalido'', 16, 1);
		END

        IF(@FactorBloque <> 10) 
      	BEGIN
    		RAISERROR (''Factor Bloque debe ser igual a 10'', 16, 1); 
      	END

		IF(@CodigoFormato <> 1) 
      	BEGIN
    		RAISERROR (''Codigo Formato debe ser igual a 1'', 16, 1); 
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
      	   			
		IF (@IdEntidadOrigen <> 811) 
      	BEGIN
    		RAISERROR (''Id de entidad de origen debe ser 0811'', 16, 1); 
      	END	
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

		IF (@IdEntidadOrigen <> 811) 
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
      	SET @RegistrosAdicionales = substring(@LINEA, 79, 1);
      	SET @ContadorRegistros = substring(@LINEA, 80, 15); /* Trace Number */

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
      	
      	DECLARE @Entidad NUMERIC(4) = CAST(substring(@EntidadDebitar, 1, 4) AS NUMERIC);
      	DECLARE @Sucursal NUMERIC(4) = CAST(substring(@EntidadDebitar, 4, 4) AS NUMERIC);
      	DECLARE @CodRechazo NUMERIC(2) =  RIGHT(CAST(@PuntoIntercambio AS NUMERIC), 3);
    
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
      	
      
		-- Consulta DPF  			
  		SELECT @EXISTE = 1, @TIPO_DOCUMENTO = TIPO_DOCUMENTO, @NRO_DPF_CHEQUE = NUMERO_DPF, @BANCO_GIRADO = BANCO_GIRADO, @SUCURSAL_BANCO = SUCURSAL_BANCO_GIRADO, @FECHA_ALTA = FECHA_ALTA, @IMPORTE_TOTAL = IMPORTE, @CODIGO_POSTAL = COD_POSTAL, @MONEDA = MONEDA, @NRO_CUENTA = NUMERICO_CUENTA_GIRADORA 
  		FROM CLE_DPF_SALIENTE WITH(NOLOCK) WHERE TRACKNUMBER = CAST(@ContadorRegistros AS NUMERIC) AND TZ_LOCK = 0; 
	   
		IF(@TICKET<>0)
		BEGIN
		
			IF @EXISTE > 0
			BEGIN
				INSERT INTO CLE_RECEPCION_DPF_DEV (NUMERO_DPF, BANCO_GIRADO, FECHA_ALTA, SUCURSAL_BANCO_GIRADO, TIPO_DOCUMENTO, IMPORTE_DPF, [CODIGO_CAMARA], ESTADO_DEVOLUCION, CODIGO_RECHAZO)
				VALUES (@NRO_DPF_CHEQUE, @BANCO_GIRADO, @FechaPresentacion, @SUCURSAL_BANCO, @TIPO_DOCUMENTO, @IMPORTE_TOTAL, (SELECT [CODIGO_DE_CAMARA] FROM CLE_CAMARAS_COMPENSADORAS WITH (NOLOCK)), 1, @CodRechazo);
				
				-- Insertamos en el historial
				INSERT INTO ITF_COELSA_SESION_RECHAZADOS (ID_TICKET, FECHA_ALTA, BANCO, SUCURSAL, CUENTA, IMPORTE, CODIGO_POSTAL, NRO_CHEQUE, PUNTO_INTERCAMBIO, TRACK_NUMBER, TIPO, MONEDA, TIPO_DOCUMENTO, CODIGO_RECHAZO)
				VALUES(@TICKET,@FechaPresentacion, @BANCO_GIRADO, @SUCURSAL_BANCO, @NRO_CUENTA, @IMPORTE_TOTAL, @CodigoPostal, @NRO_DPF_CHEQUE, @PuntoIntercambio, @ContadorRegistros, ''D'', 1, @TIPO_DOCUMENTO, @CodRechazo);
			
			END
			ELSE
			BEGIN
	
				-- Insertamos en el historial
				INSERT INTO ITF_COELSA_SESION_RECHAZADOS (ID_TICKET, FECHA_ALTA, BANCO, SUCURSAL, CUENTA, IMPORTE, CODIGO_POSTAL, NRO_CHEQUE, PUNTO_INTERCAMBIO, TRACK_NUMBER, TIPO, MONEDA, TIPO_DOCUMENTO, CODIGO_RECHAZO)
				VALUES(@TICKET, @FechaPresentacion, @Entidad, @Sucursal, @CuentaDebitar, @Importe, @CodigoPostal, @NumeroCheque, @PuntoIntercambio, @ContadorRegistros, ''D'',1, @TIPO_DOCUMENTO, @CodRechazo);
			END
  		
  		END
  	

      END
      
      FETCH NEXT FROM che_cursor INTO @LINEA 
END 

CLOSE che_cursor  
DEALLOCATE che_cursor

END;
')

