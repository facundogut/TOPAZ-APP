ALTER   PROCEDURE [dbo].[SP_COELSA_CHEQUES_TERCEROS_RECHAZADOS]

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
--s	DECLARE @Importe VARCHAR(10);
	DECLARE @Importe VARCHAR(16);
	DECLARE @NumeroCheque VARCHAR(15);
	DECLARE @CodigoPostal VARCHAR(6);
--s	DECLARE @PuntoIntercambio VARCHAR(16);
	DECLARE @PuntoIntercambio VARCHAR(10);
	DECLARE @InfoAdicional VARCHAR(2);
	DECLARE @RegistrosAdicionales VARCHAR(2);
	DECLARE @ContadorRegistros VARCHAR(15);
	
	DECLARE @CodRechazo VARCHAR (2);
	DECLARE @CodRechazoOri VARCHAR (2);
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
	IF(0=(SELECT COUNT(1) FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX WHERE LINEA LIKE '1%'))
		RAISERROR ('Error - Faltan registros.', 16, 1);
	IF(0=(SELECT COUNT(1) FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX WHERE LINEA LIKE '5%'))
		RAISERROR ('Error - Faltan registros.', 16, 1);
	IF(0=(SELECT COUNT(1) FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX WHERE LINEA LIKE '8%'))
		RAISERROR ('Error - Faltan registros.', 16, 1);
	IF(0=(SELECT COUNT(1) FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX WHERE LINEA LIKE '9%'))
		RAISERROR ('Error - Faltan registros.', 16, 1);

	--#validacion2
	IF ((SELECT COUNT(1) FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX WHERE LINEA LIKE '1%' OR LINEA LIKE '9%') > 2 )
		RAISERROR('Error - Deben haber solo 1 reg CA y 1 reg FA', 16, 1);

	--#validacion3
	IF(
	(SELECT COUNT(1) as Orden
	WHERE 1=(SELECT count(1)
			WHERE EXISTS (SELECT CONVERT(INT,SUBSTRING(LINEA,1,1))
							FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX
							WHERE ID IN	(SELECT ID-1
										FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX
										WHERE LINEA LIKE '8%')
							AND CONVERT(INT,SUBSTRING(LINEA,1,1)) NOT IN (5,6,7)
						)
			)
		OR 1=(SELECT count(1)
			WHERE EXISTS (SELECT CONVERT(INT,SUBSTRING(LINEA,1,1))
							FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX
							WHERE ID IN	(SELECT ID+1
										FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX
										WHERE LINEA LIKE '8%')
										AND CONVERT(INT,SUBSTRING(LINEA,1,1)) NOT IN (5,9)
							)
			)
		OR 1=(SELECT count(1)
			WHERE EXISTS (SELECT CONVERT(INT,SUBSTRING(LINEA,1,1))
						FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX
						WHERE ID IN	(SELECT ID-1
									FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX
									WHERE LINEA LIKE '5%')
						AND CONVERT(INT,SUBSTRING(LINEA,1,1)) NOT IN (1,8)
							)
					)
		OR 1=(SELECT count(1)
			WHERE EXISTS (SELECT CONVERT(INT,SUBSTRING(LINEA,1,1))
							FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX
							WHERE ID IN	(SELECT ID+1
										FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX
										WHERE LINEA LIKE '5%')
							AND CONVERT(INT,SUBSTRING(LINEA,1,1)) NOT IN (6,7,8)
							)
						)) <> 0
	)
		RAISERROR('El orden de los registros NACHA es incorrecto', 16, 1);


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
--s		@sumaDebitos_RI = sum(CAST(substring(LINEA, 30, 10) AS NUMERIC)),
		@sumaDebitos_RI = sum(CAST(substring(LINEA, 61, 16) AS NUMERIC)),
		@sumaEntidades_RI = sum(CAST(substring(LINEA, 4, 4) AS NUMERIC)),
		@sumaSucursales_RI = sum(CAST(substring(LINEA, 8, 4) AS NUMERIC))
	FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX
	WHERE LINEA LIKE '626%';

	SELECT --creditos
--s		@sumaCreditos_RI = sum(CAST(substring(LINEA, 30, 10) AS NUMERIC)),
		@sumaCreditos_RI = sum(CAST(substring(LINEA, 61, 16) AS NUMERIC)),
		@sumaEntidades_RIaux = sum(CAST(substring(LINEA, 4, 4) AS NUMERIC)),
		@sumaSucursales_RIaux = sum(CAST(substring(LINEA, 8, 4) AS NUMERIC))
	FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX
	WHERE LINEA LIKE '622%';

	SET @sumaEntidades_RI += isNull(@sumaEntidades_RIaux,0);
	SET @sumaSucursales_RI += isNull(@sumaSucursales_RIaux,0);
	

	--seteo total control y total de importes FA
	SELECT
		@totControl_FA = CAST(substring(linea, 22, 10) AS NUMERIC), --revisar acaaaa
--s		@totalDebitos_FA = CAST(substring(linea, 32, 12) AS NUMERIC),
--s		@totalCreditos_FA = CAST(substring(linea, 44, 12) AS NUMERIC)
		@totalDebitos_FA = CAST(substring(linea, 32, 20) AS NUMERIC),
		@totalCreditos_FA = CAST(substring(linea, 52, 20) AS NUMERIC)
	FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX
	WHERE LINEA LIKE '9%';


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
	FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX
	WHERE LINEA LIKE '8%';

--PRINT CONCAT(@sumaEntidades_RI, RIGHT(CONCAT(REPLICATE('0',3), @sumaSucursales_RI ),4))
--PRINT @sumaTotalCtrl_FL
	--#validacion5
	IF(CONCAT(@sumaEntidades_RI, RIGHT(CONCAT(REPLICATE('0',3), @sumaSucursales_RI ),4)) <> @sumaTotalCtrl_FL)
		RAISERROR('No concuerda la suma Ent/Suc con control FL', 16, 1);

	--#validacion7
	IF(@sumaTotalCtrl_FL <> @totControl_FA)
		RAISERROR('No concuerda la suma de TotalesControl de FL con control FA', 16, 1);

	--#validacion6 debitos
	IF(@sumaDebitos_RI  <> @controlDebitos_FL AND @sumaDebitos_RI <> @totalDebitos_FA)
		RAISERROR('No concuerda la suma de Debitos individuales con el Total Debitos', 16, 1);

	--#validacion6 creditos
	IF( @sumaCreditos_RI <> @controlCreditos_FL AND @sumaCreditos_RI <> @totalCreditos_FA)
		RAISERROR('No concuerda la suma de Creditos individuales con el Total Creditos ', 16, 1);

	--#validacion8
	IF((@controlDebitos_FL + @controlCreditos_FL) <>  (@totalDebitos_FA + @totalCreditos_FA))
		RAISERROR('No concuerda la suma de Debitos de FL con Total Importe FA', 16, 1);


	--fin----validaciones #5 #6 #7 y #8

	DECLARE @id int,@LINEA VARCHAR(95);
	DECLARE che_cursor CURSOR FOR 
	SELECT id,LINEA
	FROM dbo.ITF_OTROS_CHEQUES_RESPUESTA_AUX

	OPEN che_cursor

	FETCH NEXT FROM che_cursor INTO @id,@LINEA

	WHILE @@FETCH_STATUS = 0  
	BEGIN

		--#validacion4
		if(DATALENGTH(@LINEA) <> 94)
			RAISERROR('Se encontraron registros de longitud incorrecta', 16,1);

		SET @IdRegistro = substring(@LINEA, 1, 1);

		IF(@IdRegistro NOT IN('1','5','6','7','8','9') ) --validacion de id reg      
      		RAISERROR ('Id Registro invalido', 16, 1);



		/* Cabecera de Archivo */
		IF (@IdRegistro = '1') 
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


			IF (@IdArchivo NOT IN ('A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','0','1','2','3','4','5','6','7','8','9')) 	
				RAISERROR ('Identificador Archivo invalido', 16, 1);

			--#validacion11
			IF(substring(@DestinoInmediato, 2, 4) <> '0311')
				RAISERROR ('Destino inmediato debe ser 0311', 16, 1);

		END


		IF (@IdRegistro = '5') 
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
    			RAISERROR ('Codigo de clase de transaccion debe ser 200', 16, 1);

			IF (@CodigoOrigen <> 1)     	
    			RAISERROR ('Codigo origen debe ser 1', 16, 1);


			IF (@CodigoRegistro <> 'TRC')       
    			RAISERROR ('Codigo de registro debe ser TRC', 16, 1);

			IF (@FechaPresentacion > @FechaVencimiento)      	
    			RAISERROR ('Fecha Presentacion debe ser anterior a vencimiento', 16, 1);
		END

		/*FIN DE LOTE*/
		IF (@IdRegistro = '8') 
      	BEGIN
			SET @ClaseTransaccion = substring(@LINEA, 2, 3);
			--SET @RegIndivAdic = substring(@LINEA, 5, 6);
		--	SET @TotalesControl = substring(@LINEA, 11,10);
--s			SET @ReservadoFL = substring(@LINEA, 45, 35);
			SET @ReservadoFL = substring(@LINEA, 61, 29);
			SET @IdEntidadOrigen = substring(@LINEA, 80, 4);
			SET @NumeroLote = substring(@LINEA, 88, 7);

			IF (@ClaseTransaccion <> 200) 
				RAISERROR ('Codigo de clase de transaccion debe ser 200', 16, 1);

		END

		/*FIN DE ARCHIVO*/
		IF (@IdRegistro = '9') 
      	BEGIN
			SET @CantLotesFA = substring(@LINEA, 2, 6);
			SET @NumBloquesFA = substring(@LINEA, 8, 6);
			SET @CantRegAdFA = substring(@LINEA, 14, 8);
			SET @TotalesControlFA  = substring(@LINEA, 22, 10);
--s			SET @ReservadoFA  = substring(@LINEA, 56, 39);
			SET @ReservadoFA  = substring(@LINEA, 72, 23);


			--#validacion9
			IF((SELECT COUNT(1)
			FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX
			WHERE LINEA LIKE '5%') <> @CantLotesFA)
			RAISERROR('No coincide la cantidad de LOTES con la informada en el reg FA', 16, 1);
			--#validacion10
			IF((SELECT count(1)
			FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX
			WHERE LINEA LIKE '6%' OR LINEA LIKE '7%') <> @CantRegAdFA)
			RAISERROR('No coincide la cantidad de registros ind y ad con la informada en el reg FA', 16, 1);

		END




		/* Registro Individual*/
		IF (@IdRegistro = '6' ) 
      	BEGIN
			SET @ExisteRI = 1;

			SET @CodTransaccion = substring(@LINEA, 2, 2);
			SET @EntidadDebitar = substring(@LINEA, 4, 8);
			SET @ReservadoRI = substring(@LINEA, 12, 1);
			SET @CuentaDebitar = substring(@LINEA, 13, 17);
--s			SET @Importe = substring(@LINEA, 30, 10);
			SET @Importe = convert(VARCHAR(16),convert(NUMERIC(15,2),(convert(NUMERIC(16),substring(@LINEA, 61, 16))/100))); 
			SET @NumeroCheque = substring(@LINEA, 40, 15);
			SET @CodigoPostal = substring(@LINEA, 55, 6);
--s			SET @PuntoIntercambio = substring(@LINEA, 61, 16);
			SET @PuntoIntercambio = substring(@LINEA, 30, 10);
			SET @InfoAdicional = substring(@LINEA, 77, 2);
			SET @RegistrosAdicionales = substring(@LINEA, 79, 1);
			SET @ContadorRegistros = substring(@LINEA, 80, 15);
			/* Trace Number */

			SET @Entidad_RI = substring(@ContadorRegistros, 1, 4);
			SET @Sucursal_RI = substring(@ContadorRegistros, 5, 4);
			SET @CodigoPostal_RI = RIGHT(@CodigoPostal, 4);
			SET @NumeroCuenta_RI = RIGHT(@CuentaDebitar, 12);
			SET @NumeroCheque_RI = RIGHT(@NumeroCheque, 12);


			IF (@RegistrosAdicionales NOT IN('1','0')) 
    			RAISERROR ('Campo Registro adicional invalido', 16, 1);



			--- Variables Generales ---
			DECLARE @NRO_DPF_CHEQUE NUMERIC(12);
			DECLARE @BANCO_GIRADO NUMERIC(4);
			DECLARE @SUCURSAL_BANCO NUMERIC(5);
			DECLARE @TIPO_DOCUMENTO VARCHAR(4);
--s			DECLARE @IMPORTE_TOTAL NUMERIC(10,2);
			DECLARE @IMPORTE_TOTAL NUMERIC(15,2);
			DECLARE @MONEDA NUMERIC(1);
			DECLARE @SERIE_DEL_CHEQUE VARCHAR(6);
			DECLARE @NRO_CUENTA NUMERIC(12);
			DECLARE @CODIGO_POSTAL NUMERIC(4);
			DECLARE @EXISTE NUMERIC(4) = 0;

			IF(@TICKET<>0)
      		BEGIN
      		
      			--Rechazos como girada (trae registro adicional)
      					/*Registro ind adicional*/
				IF(@RegistrosAdicionales = '1')
				BEGIN
			 
					SET @CodRechazo = (SELECT substring(LINEA, 5, 2) FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX WHERE id=@id+1)
--PRINT @CodRechazo
	
					IF(ISNUMERIC(@Entidad_RI) = 1 AND ISNUMERIC(@Sucursal_RI) = 1 AND ISNUMERIC(@CodigoPostal_RI) = 1 AND ISNUMERIC(@NumeroCheque_RI) = 1 AND ISNUMERIC(@NumeroCuenta_RI ) = 1 )
					BEGIN			
			--actualizo el codigo de rechazo
						UPDATE ITF_COELSA_SESION_RECHAZADOS 
						SET CODIGO_RECHAZO = @CodRechazo 
						WHERE ID_TICKET = @TICKET 
						AND BANCO = @Entidad_RI 
						AND  SUCURSAL = @Sucursal_RI 
						AND CUENTA = @NumeroCuenta_RI 
						AND CODIGO_POSTAL = @CodigoPostal_RI 
						AND NRO_CHEQUE = @NumeroCheque_RI;

						IF(@updRecepcion = 'D')
							UPDATE CLE_RECEPCION_DPF_DEV 
							SET CODIGO_RECHAZO = @CodRechazo 
							WHERE NUMERO_DPF = @NumeroCheque_RI 
							AND BANCO_GIRADO = @Entidad_RI 
							AND SUCURSAL_BANCO_GIRADO = @Sucursal_RI;
			
						ELSE IF(@updRecepcion = 'C' AND ISNUMERIC(@CodRechazo) = 1)
							UPDATE CLE_RECEPCION_CHEQUES_DEV 
							SET CODIGO_RECHAZO = @CodRechazo 
							WHERE NUMERO_CHEQUE = @NumeroCheque_RI 
							AND BANCO_GIRADO = @Entidad_RI 
							AND SUCURSAL_BANCO_GIRADO = @Sucursal_RI;
					END
					UPDATE RRII_CHE_RECHAZADOS
					SET CAUSAL=(SELECT TOP 1 CODIGO_DE_CAUSAL FROM CLE_TIPO_CAUSAL WHERE CODIGO_NACHA=@CodRechazo),
						CODIGO_MOTIVO=@CodRechazo
					WHERE cod_entidad = 311
    				AND Nro_sucursal = TRIM('0' FROM RIGHT(@EntidadDebitar, 3))
    				AND cuenta = @NumeroCuenta_RI
    				AND nro_cheque = @NumeroCheque_RI
    				AND fecha_registro_novedad = (SELECT fechaproceso FROM PARAMETROS);
				END
      		
--si es un rechazo de entidad depositaria (622%) el codigo de rechazo lo tenemos que setear de la siguiente forma       		
				IF @codTransaccion='22'
				BEGIN
					IF TRY_CONVERT(INT,SUBSTRING(@LINEA,65,2))=0
					BEGIN
						SET @codRechazo=substring(@linea,67,2)
					END
					ELSE IF TRY_CONVERT(INT,SUBSTRING(@LINEA,67,2))=0
		   			BEGIN
						SET @codRechazo=substring(@linea,65,2)
					END
					ELSE 
					BEGIN 
						SET @CodRechazo=substring(@linea,65,2)
					END 
				END 
				--lo seteo en '-' y desp veo su hay que updatear CLE_RECEPCION_CHEQUES_DEV ('C') o CLE_RECEPCION_DPF_DEV ('D')
				SET @updRecepcion = '-';

				IF (ISNUMERIC(@CuentaDebitar) = 1 AND CAST(@CuentaDebitar AS NUMERIC) = 88888888888)
				BEGIN
					IF(ISNUMERIC(@Entidad_RI) = 1 AND ISNUMERIC(@Sucursal_RI) = 1 AND ISNUMERIC(@CodigoPostal_RI) = 1 AND ISNUMERIC(@NumeroCheque_RI) = 1 AND ISNUMERIC(@NumeroCuenta_RI ) = 1 )
					BEGIN
						-- La idea es actualizar los rechazados del plano con ESTADO_AJUSTE = 'R' y el resto de cheques del historial con ESTADO_AJUSTE  = 'A'	
						UPDATE dbo.CLE_CHEQUES_AJUSTE 
						SET ESTADO_AJUSTE = 'R' 
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
																	ORDINAL
																	, serie_del_cheque)
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
																	'C',  
																	@MONEDA, 
																	@TIPO_DOCUMENTO, 
																	@CodRechazo, 
																	@ORDINAL
																	, (CASE WHEN substring(@infoadicional,2,1) IN ('2','3') THEN 'E' ELSE ' ' END))
					
PRINT concat('Moneda-existe-ticket<>0: ',@moneda)
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
																	TIPO_DOCUMENTO
																	, codigo_rechazo
																	, serie_del_cheque)
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
							'C',
							@moneda, 
							@TIPO_DOCUMENTO
							, @codRechazo
							, (CASE WHEN substring(@infoadicional,2,1) IN ('2','3') THEN 'E' ELSE ' ' END));

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
							
					 	SET @updRecepcion = 'D'; --para saber si hay que updatear  CLE_RECEPCION_DPF_DEV

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
				   												, ORDINAL
				   												, codigo_rechazo)
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
								, 'C',  @MONEDA
								, @TIPO_DOCUMENTO
								, @ORDINAL
								, @CodRechazo);

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
																, TIPO_DOCUMENTO
																, codigo_rechazo
																, serie_del_cheque)
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
								, 'C'
								, @moneda
								, @TIPO_DOCUMENTO
								, @codRechazo
								, (CASE WHEN substring(@infoadicional,2,1) IN ('2','3') THEN 'E' ELSE ' ' END));			
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
						
						SET @updRecepcion = 'C'; --para saber si updatear el cod Rechazo de la tabla CLE_RECEPCION_CHEQUES_DEV

						INSERT INTO CLE_RECEPCION_CHEQUES_DEV(NUMERO_CHEQUE
															--, SERIE_DEL_CHEQUE
															, BANCO_GIRADO
															, FECHA_ALTA
															, SUCURSAL_BANCO_GIRADO
															, NUMERO_CUENTA_GIRADORA
															, TIPO_DOCUMENTO
															, IMPORTE_CHEQUE
															, ESTADO_DEVOLUCION
															, CODIGO_CAMARA
															, serie_del_cheque)
						VALUES (@NRO_DPF_CHEQUE
								--, @SERIE_DEL_CHEQUE
								, @BANCO_GIRADO
								--, @FechaPresentacion
								, (select fechaproceso from parametros)
								, @SUCURSAL_BANCO
								, @NRO_CUENTA
								, @TIPO_DOCUMENTO
								, @IMPORTE_TOTAL
								, 1
								, (SELECT [CODIGO_DE_CAMARA] FROM CLE_CAMARAS_COMPENSADORAS WITH(NOLOCK))
								, (CASE WHEN substring(@infoadicional,2,1) IN ('2','3') THEN 'E' ELSE ' ' END));

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
																--, SERIE_DEL_CHEQUE
																, Codigo_rechazo
																, serie_del_cheque)
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
							, 'C'
							, @MONEDA
							, @TIPO_DOCUMENTO
							--, @SERIE_DEL_CHEQUE
							, @codRechazo
							, (CASE WHEN substring(@infoadicional,2,1) IN ('2','3') THEN 'E' ELSE ' ' END));
					
					
					
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
																, TIPO_DOCUMENTO
																, codigo_rechazo
																, serie_del_cheque)
						VALUES(@TICKET
--							, @FechaPresentacion
							, (select fechaproceso from parametros)
							, CASE WHEN ISNUMERIC(@Entidad_RI) = 0 THEN -1 ELSE CAST(@Entidad_RI AS NUMERIC(4)) END ,
							CASE WHEN ISNUMERIC(@Sucursal_RI) = 0 THEN -1 ELSE CAST(@Sucursal_RI AS NUMERIC(5)) END, 
							CASE WHEN ISNUMERIC(@NumeroCuenta_RI) = 0 THEN -1 ELSE CAST(@NumeroCuenta_RI AS NUMERIC(12)) END, 
							@Importe, 
							CASE WHEN ISNUMERIC(@CodigoPostal_RI) = 0 THEN -1 ELSE CAST(@CodigoPostal_RI AS NUMERIC(4)) END, 
							CASE WHEN ISNUMERIC(@NumeroCheque_RI) = 0 THEN -1 ELSE CAST(@NumeroCheque_RI AS NUMERIC(12)) END ,
							@PuntoIntercambio, 
							@ContadorRegistros, 
							'C',
							@moneda, 
							@TIPO_DOCUMENTO
							, @codRechazo
							, (CASE WHEN substring(@infoadicional,2,1) IN ('2','3') THEN 'E' ELSE ' ' END));
							

					END

				END

		--***Bloque nuevo 13/05/2024 JI***--
				IF (try_convert(numeric,@codRechazo) IS null)
				BEGIN
					PRINT @linea
					PRINT @codRechazo
					SELECT convert(NUMERIC(15,2),substring(@linea,30,10))/100,CAST(substring(@linea,13,17) AS NUMERIC),substring(@linea,40,2)
				END 
		--IF (@linea LIKE '622%')
		--BEGIN
		
				SELECT @CODCLI=c1803
						, @PRODUCTO=PRODUCTO
						, @ordinal=ordinal 
				FROM SALDOS 
				WHERE CUENTA = @NumeroCuenta_RI 
				AND SUCURSAL = TRIM('0' FROM RIGHT(@EntidadDebitar, 3)) 
				AND MONEDA = @MONEDA 
				AND C1785 = 2
		
		
		
--PRINT @linea

			
				SET @Entidad = CAST(LEFT( CAST(RIGHT('0000' + Ltrim(Rtrim(@EntidadDebitar)),8) AS VARCHAR ), 4) AS NUMERIC);
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
--s							, convert(NUMERIC(15,2),substring(@linea,30,10))/100
							,@Importe
							, (CASE WHEN substring(@infoadicional,2,1) IN ('2','3') THEN 'E' ELSE ' ' END)
--							, @FechaPresentacion
							,(select fechaproceso from parametros)
							, '0' 
							, CAST(substring(@linea,13,17) AS NUMERIC)
							, 1
							, (SELECT CONCAT( @Entidad, RIGHT(@EntidadDebitar, 3),RIGHT(@CodigoPostal,4),RIGHT(CONCAT(REPLICATE('0',8),RIGHT(@NumeroCheque, 8)),8), RIGHT(CONCAT('00000000000',RIGHT(@CuentaDebitar,11)),11) ))         										
							, @ContadorRegistros
							, 0
							, @codRechazo
							)
				END TRY 
			
				BEGIN CATCH
				END CATCH
							---***---
			
--PRINT @NumeroCheque 
   				IF ( SELECT count(1) 
					FROM CLE_RECEPCION_CHEQUES_DEV 
					WHERE NUMERO_CHEQUE= @NumeroCheque
			   		--AND SERIE_DEL_CHEQUE= @SERIE_DEL_CHEQUE
					AND BANCO_GIRADO= @Entidad_RI 
					AND FECHA_ALTA= @FechaPresentacion
					AND SUCURSAL_BANCO_GIRADO=@Sucursal_RI
					AND NUMERO_CUENTA_GIRADORA= CAST(substring(@linea,13,17) AS NUMERIC)) > 0
				BEGIN
--PRINT 'existe' --REVISAR CLE PREVALENCIA CAUSAL
						SELECT @codRechazoOri=CODIGO_RECHAZO
						FROM CLE_RECEPCION_CHEQUES_DEV
						WHERE NUMERO_CHEQUE= @NumeroCheque
						AND SERIE_DEL_CHEQUE= @SERIE_DEL_CHEQUE
						AND BANCO_GIRADO= @Entidad_RI 
						AND FECHA_ALTA= @FechaPresentacion
						AND SUCURSAL_BANCO_GIRADO=@Sucursal_RI
						AND NUMERO_CUENTA_GIRADORA= CAST(substring(@linea,13,17) AS NUMERIC)
						AND TIPO_DOCUMENTO=substring(@linea,40,2)
						
					SELECT @codrechazo=isnull(RIGHT(causal_prevaleciente,2) ,@codRechazo) FROM CLE_PREVALENCIA_CAUSAL WHERE CAUSAL_DEPOSITARIA=@codRechazo AND CAUSAL_GIRADA=@codRechazoOri AND TZ_LOCK=0

						UPDATE CLE_RECEPCION_CHEQUES_DEV
						SET CODIGO_RECHAZO=try_convert(NUMERIC(3),@codRechazo)
						WHERE NUMERO_CHEQUE= @NumeroCheque
						AND SERIE_DEL_CHEQUE= @SERIE_DEL_CHEQUE
						AND BANCO_GIRADO= @Entidad_RI 
						AND FECHA_ALTA= @FechaPresentacion
						AND SUCURSAL_BANCO_GIRADO=@Sucursal_RI
						AND NUMERO_CUENTA_GIRADORA= CAST(substring(@linea,13,17) AS NUMERIC)
						AND TIPO_DOCUMENTO=substring(@linea,40,2) 		

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
						, (CASE WHEN substring(@infoadicional,2,1) IN ('2','3') THEN 'E' ELSE ' ' END)
--s						, convert(NUMERIC(15,2),substring(@linea,30,10))/100
						,@Importe
 						, try_convert(numeric,@codRechazo)
 						, @NumeroCheque
				  		, 1
						, (SELECT TOP 1 CODIGO_DE_CAMARA FROM CLE_CAMARAS_COMPENSADORAS WITH(NOLOCK))
						, substring(@linea,40,2)
-- 						, @FechaPresentacion
						, (select fechaproceso from parametros)
						, CAST(substring(@linea,13,17) AS NUMERIC)
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
						TRIM('0' FROM RIGHT(@EntidadDebitar, 3)), 
	   					@NumeroCuenta_RI, 
	   					@NumeroCheque_RI,
	   					CONCAT(@Entidad_RI, @Sucursal_RI), 
						'A', 
						1
--						, @FechaPresentacion
						, (select fechaproceso from parametros)
						, @MONEDA,  
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
        						ROW_NUMBER() OVER (PARTITION BY [Codigo de Cliente] ORDER BY CASE WHEN [Titularidad] = 'T' THEN 0 ELSE 1 END, [Numero de Documento]) AS RN
    					FROM VW_CLI_PERSONAS
    					WHERE [Codigo de Cliente] = (
													SELECT c1803 
													FROM SALDOS 
													WHERE CUENTA = @NumeroCuenta_RI 
													AND SUCURSAL = TRIM('0' FROM RIGHT(@EntidadDebitar, 3)) 
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
    				AND Nro_sucursal = TRIM('0' FROM RIGHT(@EntidadDebitar, 3))
    				AND cuenta = @NumeroCuenta_RI
    				AND nro_cheque = @NumeroCheque_RI
    				AND fecha_registro_novedad = (SELECT fechaproceso FROM PARAMETROS);

					-- Eliminar la tabla temporal
					DROP TABLE #TempUpdate;


				END	TRY
				BEGIN CATCH
	--PRINT 'No se pudo insertar en tabla RRII_CHE_RECHAZADOS'
				END CATCH	
			END
		END --end RI id = 6
		FETCH NEXT FROM che_cursor INTO @id,@LINEA
	END

	CLOSE che_cursor
	DEALLOCATE che_cursor

	--- Actualizar el estado de los ajustes no incluidos en el plano -------------------------------------------------------------
	UPDATE dbo.CLE_CHEQUES_AJUSTE 
	SET ESTADO_AJUSTE = 'A' 
	WHERE ESTADO_AJUSTE IS NULL 
	AND ESTADO = 'P' 
	AND FECHA_ACREDITACION = (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK));
------------------------------------------------------------------------------------------------------------------------------

END
GO

