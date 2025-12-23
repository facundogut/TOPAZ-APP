execute('
CREATE OR ALTER   PROCEDURE [dbo].[SP_TRAN_MINORISTA_RECIBIDAS]
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
			SET @CUIL = (SELECT TOP 1 SUBSTRING(LINEA,4,11) FROM ITF_TRAN_MINORISTA_RECIBIDAS_AUX WHERE ID>@ID AND LINEA LIKE ''7%'');
			SET @CodRechazo = (SELECT TOP 1 SUBSTRING(LINEA,5,2) FROM ITF_TRAN_MINORISTA_RECIBIDAS_AUX WHERE ID>@ID AND LINEA LIKE ''7%'');
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
	      	PRINT @CodRechazo;
	      	UPDATE dbo.VTA_TRANSFERENCIAS
			SET ESTADO = ''RC'' , FECHA_ESTADO=@FECHADATE , NUMERO_ASIENTO=@TICKET, MOTIVO_RECHAZO=@CodRechazo
			WHERE OP_CLASE_TRANS = ''E'' AND BEN_CBU = @CBU  AND OP_MONEDA=@Moneda AND  OP_NUMERO=LTRIM(RIGHT(@ReferenciaUnivoca,12))		

			GOTO Final
	      END
	      
	      
		  --------------
		  ----NACHA R17
		  --------------
		  

		  IF ISNUMERIC(@CodTransaccion) = 0 or ISNUMERIC(@EntidadDebitar) = 0  OR ISNUMERIC(@ReservadoRI) = 0 OR ISNUMERIC(@CuentaDebitar) = 0
			 OR ISNUMERIC(@Importe) = 0 OR ISNUMERIC(@InfoAdicional) = 0 OR ISNUMERIC(@RegistrosAdicionales) = 0 OR ISNUMERIC(@ContadorRegistros) = 0
	      BEGIN
	      		INSERT INTO dbo.VTA_TRANSFERENCIAS (OP_NUMERO, NUMERO_ASIENTO,  OP_FECHA_PRES, OP_CLASE_TRANS, ESTADO, OP_MONEDA, OP_TIPO, BEN_CBU, OP_IMPORTE, BEN_JTS_OID_CUENTA, BEN_NRO_DOC, MOTIVO_RECHAZO, OP_FORMA_ING, FECHA_ESTADO, CONTABILIZADA, OP_INFO_REF )
				VALUES ((SELECT ISNULL(MAX(OP_NUMERO),0)+1 FROM VTA_TRANSFERENCIAS WHERE OP_CLASE_TRANS=''R''),@TICKET, @FECHADATE, ''R'', ''RC'', @Moneda, @Tipo_transferencia, @CBU, @VImporte, @JTS_OID, @CUIL,(SELECT CODIGO_NACHA FROM CLE_TIPO_CAUSAL WHERE CODIGO_DE_CAUSAL = 32), ''C'' , @FECHADATE, ''N'', RTRIM(LTRIM(@ReferenciaUnivoca)));
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
				VALUES ((SELECT ISNULL(MAX(OP_NUMERO),0)+1 FROM VTA_TRANSFERENCIAS WHERE OP_CLASE_TRANS=''R''),@TICKET, @FECHADATE, ''R'', ''RC'', @Moneda, @Tipo_transferencia, @CBU, @VImporte, @JTS_OID, @CUIL,(SELECT CODIGO_NACHA FROM CLE_TIPO_CAUSAL WHERE CODIGO_DE_CAUSAL = 76), ''C'' , @FECHADATE, ''N'', RTRIM(LTRIM(@ReferenciaUnivoca)));
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
				VALUES ((SELECT ISNULL(MAX(OP_NUMERO),0)+1 FROM VTA_TRANSFERENCIAS WHERE OP_CLASE_TRANS=''R''), @TICKET, @FECHADATE, ''R'', ''RC'', @Moneda, @Tipo_transferencia, @CBU, @VImporte, @JTS_OID, @CUIL,(SELECT CODIGO_NACHA FROM CLE_TIPO_CAUSAL WHERE CODIGO_DE_CAUSAL = 4), ''C'' , @FECHADATE, ''N'', RTRIM(LTRIM(@ReferenciaUnivoca)));

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
				VALUES ((SELECT ISNULL(MAX(OP_NUMERO),0)+1 FROM VTA_TRANSFERENCIAS WHERE OP_CLASE_TRANS=''R''),@TICKET, @FECHADATE, ''R'', ''RC'', @Moneda, @Tipo_transferencia, @CBU, @VImporte, @JTS_OID, @CUIL,(SELECT CODIGO_NACHA FROM CLE_TIPO_CAUSAL WHERE CODIGO_DE_CAUSAL = 93), ''C'' , @FECHADATE, ''N'', RTRIM(LTRIM(@ReferenciaUnivoca)));

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
				VALUES ((SELECT ISNULL(MAX(OP_NUMERO),0)+1 FROM VTA_TRANSFERENCIAS WHERE OP_CLASE_TRANS=''R''), @TICKET, @FECHADATE, ''R'', ''RC'', @Moneda, @Tipo_transferencia, @CBU, @VImporte, @JTS_OID, @CUIL,(SELECT CODIGO_NACHA FROM CLE_TIPO_CAUSAL WHERE CODIGO_DE_CAUSAL = 94), ''C'' , @FECHADATE, ''N'', RTRIM(LTRIM(@ReferenciaUnivoca)));

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
				VALUES ((SELECT ISNULL(MAX(OP_NUMERO),0)+1 FROM VTA_TRANSFERENCIAS WHERE OP_CLASE_TRANS=''R''), @TICKET, @FECHADATE, ''R'', ''RC'', @Moneda, @Tipo_transferencia, @CBU, @VImporte, @JTS_OID, @CUIL,(SELECT CODIGO_NACHA FROM CLE_TIPO_CAUSAL WHERE CODIGO_DE_CAUSAL = 95), ''C'' , @FECHADATE, ''N'', RTRIM(LTRIM(@ReferenciaUnivoca)));
	      	GOTO Final
	      END
	      
	      --------------
	      ----NACHA R75
	      --------------
	      
	      SET @FechaVencimientoCA = convert(DATE, @VFechaVencimientoCA);
	      
		  IF ISDATE(@VFechaVencimiento) = 0 OR ISDATE(@VFechaCompensacion) = 0 OR ISDATE(@VFechaVencimientoCA) = 0
	      BEGIN
	             
	      		INSERT INTO dbo.VTA_TRANSFERENCIAS (OP_NUMERO, NUMERO_ASIENTO,  OP_FECHA_PRES, OP_CLASE_TRANS, ESTADO, OP_MONEDA, OP_TIPO, BEN_CBU, OP_IMPORTE, BEN_JTS_OID_CUENTA, BEN_NRO_DOC, MOTIVO_RECHAZO, OP_FORMA_ING, FECHA_ESTADO, CONTABILIZADA, OP_INFO_REF )
				VALUES ((SELECT ISNULL(MAX(OP_NUMERO),0)+1 FROM VTA_TRANSFERENCIAS WHERE OP_CLASE_TRANS=''R''),@TICKET, @FECHADATE, ''R'', ''RC'', @Moneda, @Tipo_transferencia, @CBU, @VImporte, @JTS_OID, @CUIL,(SELECT CODIGO_NACHA FROM CLE_TIPO_CAUSAL WHERE CODIGO_DE_CAUSAL = 58), ''C'' , @FECHADATE, ''N'', RTRIM(LTRIM(@ReferenciaUnivoca)));
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
				VALUES ((SELECT ISNULL(MAX(OP_NUMERO),0)+1 FROM VTA_TRANSFERENCIAS WHERE OP_CLASE_TRANS=''R''),@TICKET, @FECHADATE, ''R'', ''RC'', @Moneda, @Tipo_transferencia, @CBU, @VImporte, @JTS_OID, @CUIL,(SELECT CODIGO_NACHA FROM CLE_TIPO_CAUSAL WHERE CODIGO_DE_CAUSAL = 36), ''C'' , @FECHADATE, ''N'', RTRIM(LTRIM(@ReferenciaUnivoca)));
	      	GOTO Final
	      END
	     
	      
	      --------------
	      ----NACHA R91
	      --------------
	      
		  IF((LEFT(@EntidadDebitar,4)=''0311'' AND LEFT(@InfoAdicional,1)<>0) OR (LEFT(@EntidadDebitar,4)=''0811'' AND LEFT(@InfoAdicional,1)<>''1''))
	      BEGIN
	      	    INSERT INTO dbo.VTA_TRANSFERENCIAS (OP_NUMERO, NUMERO_ASIENTO,  OP_FECHA_PRES, OP_CLASE_TRANS, ESTADO, OP_MONEDA, OP_TIPO, BEN_CBU, OP_IMPORTE, BEN_JTS_OID_CUENTA, BEN_NRO_DOC, MOTIVO_RECHAZO, OP_FORMA_ING, FECHA_ESTADO, CONTABILIZADA, OP_INFO_REF )
				VALUES ((SELECT ISNULL(MAX(OP_NUMERO),0)+1 FROM VTA_TRANSFERENCIAS WHERE OP_CLASE_TRANS=''R''), @TICKET, @FECHADATE, ''R'', ''RC'', @Moneda, @Tipo_transferencia, @CBU, @VImporte, @JTS_OID, @CUIL,(SELECT CODIGO_NACHA FROM CLE_TIPO_CAUSAL WHERE CODIGO_DE_CAUSAL = 74), ''C'' , @FECHADATE, ''N'', RTRIM(LTRIM(@ReferenciaUnivoca)));
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
				VALUES ((SELECT ISNULL(MAX(OP_NUMERO),0)+1 FROM VTA_TRANSFERENCIAS WHERE OP_CLASE_TRANS=''R''), @TICKET, @FECHADATE, ''R'', ''PR'', @Moneda, @Tipo_transferencia, @CBU, @VImporte, @JTS_OID, @CUIL, ''C'' , @FECHADATE, ''N'', RTRIM(LTRIM(@ReferenciaUnivoca)));
	
		
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

');

