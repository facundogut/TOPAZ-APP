Execute('CREATE OR ALTER    PROCEDURE [dbo].[SP_COELSA_CHEQUES_TERCEROS_RECHAZADOS]

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
	IF(0=(SELECT COUNT(1) FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX WHERE LINEA LIKE ''1%''))
		RAISERROR (''Error - Faltan registros.'', 16, 1);
	IF(0=(SELECT COUNT(1) FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX WHERE LINEA LIKE ''5%''))
		RAISERROR (''Error - Faltan registros.'', 16, 1);
	IF(0=(SELECT COUNT(1) FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX WHERE LINEA LIKE ''8%''))
		RAISERROR (''Error - Faltan registros.'', 16, 1);
	IF(0=(SELECT COUNT(1) FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX WHERE LINEA LIKE ''9%''))
		RAISERROR (''Error - Faltan registros.'', 16, 1);

	--#validacion2
	IF ((SELECT COUNT(1) FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX WHERE LINEA LIKE ''1%'' OR LINEA LIKE ''9%'') > 2 )
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
--s		@sumaDebitos_RI = sum(CAST(substring(LINEA, 30, 10) AS NUMERIC)),
		@sumaDebitos_RI = sum(CAST(substring(LINEA, 61, 16) AS NUMERIC)),
		@sumaEntidades_RI = sum(CAST(substring(LINEA, 4, 4) AS NUMERIC)),
		@sumaSucursales_RI = sum(CAST(substring(LINEA, 8, 4) AS NUMERIC))
	FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX
	WHERE LINEA LIKE ''626%'';

	SELECT --creditos
--s		@sumaCreditos_RI = sum(CAST(substring(LINEA, 30, 10) AS NUMERIC)),
		@sumaCreditos_RI = sum(CAST(substring(LINEA, 61, 16) AS NUMERIC)),
		@sumaEntidades_RIaux = sum(CAST(substring(LINEA, 4, 4) AS NUMERIC)),
		@sumaSucursales_RIaux = sum(CAST(substring(LINEA, 8, 4) AS NUMERIC))
	FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX
	WHERE LINEA LIKE ''622%'';

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
--s			SET @ReservadoFL = substring(@LINEA, 45, 35);
			SET @ReservadoFL = substring(@LINEA, 61, 29);
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
--s			SET @ReservadoFA  = substring(@LINEA, 56, 39);
			SET @ReservadoFA  = substring(@LINEA, 72, 23);


			--#validacion9
			IF((SELECT COUNT(1)
			FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX
			WHERE LINEA LIKE ''5%'') <> @CantLotesFA)
			RAISERROR(''No coincide la cantidad de LOTES con la informada en el reg FA'', 16, 1);
			--#validacion10
			IF((SELECT count(1)
			FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX
			WHERE LINEA LIKE ''6%'' OR LINEA LIKE ''7%'') <> @CantRegAdFA)
			RAISERROR(''No coincide la cantidad de registros ind y ad con la informada en el reg FA'', 16, 1);

		END




		/* Registro Individual*/
		IF (@IdRegistro = ''6'' ) 
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


			IF (@RegistrosAdicionales NOT IN(''1'',''0'')) 
    			RAISERROR (''Campo Registro adicional invalido'', 16, 1);



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
				IF(@RegistrosAdicionales = ''1'')
				BEGIN
			 
					SET @CodRechazo = (SELECT substring(LINEA, 5, 2) FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX WHERE id=@id+1)

	
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
--REVISAMOS ACA
--						IF(@updRecepcion = ''D'')
--						BEGIN
--							UPDATE CLE_RECEPCION_DPF_DEV 
--							SET CODIGO_RECHAZO = @CodRechazo 
--							WHERE NUMERO_DPF = @NumeroCheque_RI 
--							AND BANCO_GIRADO = @Entidad_RI 
--							AND SUCURSAL_BANCO_GIRADO = @Sucursal_RI;
--						END
						
--COMENTADO EL 17/12/2024 POR FUNCIONAMIENTO INCORRECTO DE CLE_RECEPCION_CHEQUES_DEV J.I.
						
--						ELSE IF(@updRecepcion = ''C'' AND ISNUMERIC(@CodRechazo) = 1)
--						BEGIN
--							UPDATE CLE_RECEPCION_CHEQUES_DEV 
--							SET CODIGO_RECHAZO = @CodRechazo 
--							WHERE NUMERO_CHEQUE = @NumeroCheque_RI 
--							AND BANCO_GIRADO = @Entidad_RI 
--							AND SUCURSAL_BANCO_GIRADO = @Sucursal_RI;
--						END
					
--HASTA ACA--

					END
					UPDATE RRII_CHE_RECHAZADOS
					SET CAUSAL=(SELECT TOP 1 CODIGO_DE_CAUSAL FROM CLE_TIPO_CAUSAL WHERE CODIGO_NACHA=@CodRechazo),
						CODIGO_MOTIVO=@CodRechazo
					WHERE cod_entidad = 311
    				AND Nro_sucursal = TRIM(''0'' FROM RIGHT(@EntidadDebitar, 3))
    				AND cuenta = @NumeroCuenta_RI
    				AND nro_cheque = @NumeroCheque_RI
    				AND fecha_registro_novedad = (SELECT fechaproceso FROM PARAMETROS);
				END
      		
--si es un rechazo de entidad depositaria (622%) el codigo de rechazo lo tenemos que setear de la siguiente forma       		
				IF @codTransaccion=''22''
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
																	''C'',  
																	@MONEDA, 
																	@TIPO_DOCUMENTO, 
																	@CodRechazo, 
																	@ORDINAL
																	, (CASE WHEN substring(@infoadicional,2,1) IN (''2'',''3'') THEN ''E'' ELSE '' '' END))
					
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
							''C'',
							@moneda, 
							@TIPO_DOCUMENTO
							, @codRechazo
							, (CASE WHEN substring(@infoadicional,2,1) IN (''2'',''3'') THEN ''E'' ELSE '' '' END));

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
						IF (SELECT COUNT(1) 
							FROM CLE_RECEPCION_DPF_DEV
							WHERE NUMERO_DPF = @NumeroCheque_RI 
							AND BANCO_GIRADO = @Entidad_RI 
							AND SUCURSAL_BANCO_GIRADO = @Sucursal_RI
							)>0
						BEGIN
							UPDATE CLE_RECEPCION_DPF_DEV 
							SET CODIGO_RECHAZO = @CodRechazo 
							WHERE NUMERO_DPF = @NumeroCheque_RI 
							AND BANCO_GIRADO = @Entidad_RI 
							AND SUCURSAL_BANCO_GIRADO = @Sucursal_RI
						END
						ELSE
						BEGIN
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
						END
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
								, ''C'',  @MONEDA
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
								, ''C''
								, @moneda
								, @TIPO_DOCUMENTO
								, @codRechazo
								, (CASE WHEN substring(@infoadicional,2,1) IN (''2'',''3'') THEN ''E'' ELSE '' '' END));			
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
						
						SET @updRecepcion = ''C''; --para saber si updatear el cod Rechazo de la tabla CLE RECEPCION_CHEQUES_DEV


--COMENTADO EL DIA 17/12/2024 PORQUE SE ESTAN INSERTANDO DUPLICADOS LOS REGISTROS EN CLE_RECEPCION_CHEQUES_DEV J.I.

--						INSERT INTO CLE_RECEPCION_CHEQUES_DEV(NUMERO_CHEQUE
--															--, SERIE_DEL_CHEQUE
--															, BANCO_GIRADO
--															, FECHA_ALTA
--															, SUCURSAL_BANCO_GIRADO
--															, NUMERO_CUENTA_GIRADORA
--															, TIPO_DOCUMENTO
--															, IMPORTE_CHEQUE
--															, ESTADO_DEVOLUCION
--															, CODIGO_CAMARA
--															, serie_del_cheque)
--						VALUES (@NRO_DPF_CHEQUE
--								--, @SERIE_DEL_CHEQUE
--								, @BANCO_GIRADO
--								--, @FechaPresentacion
--								, (select fechaproceso from parametros)
--								, @SUCURSAL_BANCO
--								, @NRO_CUENTA
--								, @TIPO_DOCUMENTO
--								, @IMPORTE_TOTAL
--								, 1
--								, (SELECT [CODIGO_DE_CAMARA] FROM CLE_CAMARAS_COMPENSADORAS WITH(NOLOCK))
--								, (CASE WHEN substring(@infoadicional,2,1) IN (''2'',''3'') THEN ''E'' ELSE '' '' END));
								
--HASTA ACA--

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
							, ''C''
							, @MONEDA
							, @TIPO_DOCUMENTO
							--, @SERIE_DEL_CHEQUE
							, @codRechazo
							, (CASE WHEN substring(@infoadicional,2,1) IN (''2'',''3'') THEN ''E'' ELSE '' '' END));
					
					
					
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
							''C'',
							@moneda, 
							@TIPO_DOCUMENTO
							, @codRechazo
							, (CASE WHEN substring(@infoadicional,2,1) IN (''2'',''3'') THEN ''E'' ELSE '' '' END));
							

					END

				END

		--***Bloque nuevo 13/05/2024 JI***--
				IF (try_convert(numeric,@codRechazo) IS null)
				BEGIN
					PRINT @linea
					PRINT @codRechazo
					SELECT convert(NUMERIC(15,2),substring(@linea,30,10))/100,CAST(substring(@linea,13,17) AS NUMERIC),substring(@linea,40,2)
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
--s							, convert(NUMERIC(15,2),substring(@linea,30,10))/100
							,@Importe
							, (CASE WHEN substring(@infoadicional,2,1) IN (''2'',''3'') THEN ''E'' ELSE '' '' END)
--							, @FechaPresentacion
							, @FechaPresentacion--(select fechaproceso from parametros)
							, ''0'' 
							, CAST(substring(@linea,13,17) AS NUMERIC)
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
			
-- PRINT @NumeroCheque
				--PRINT ''Num CHEQUE: '' + @NumeroCheque + '' Banco Girado: '' + @Entidad_RI + '' Suc Banco Girado: '' + @Sucursal_RI + '' Num Cta Gir: '' + SUBSTRING(@linea, 13, 17)
				IF (SELECT COUNT(1) 
					FROM CLE_RECEPCION_CHEQUES_DEV 
					WHERE NUMERO_CHEQUE = @NumeroCheque
					  -- AND SERIE_DEL_CHEQUE = @SERIE_DEL_CHEQUE
					  AND BANCO_GIRADO = @Entidad_RI 
					  AND FECHA_ALTA = (SELECT fechaproceso FROM PARAMETROS)--@FechaPresentacion
					  AND SUCURSAL_BANCO_GIRADO = @Sucursal_RI
					  AND NUMERO_CUENTA_GIRADORA = CAST(SUBSTRING(@linea, 13, 17) AS NUMERIC)
				   ) > 0
				   
				BEGIN
					-- PRINT ''existe'' -- REVISAR CLE PREVALENCIA CAUSAL

					-- Obtener el código de rechazo original
					SELECT @codRechazoOri = CODIGO_RECHAZO
					FROM CLE_RECEPCION_CHEQUES_DEV
					WHERE NUMERO_CHEQUE = @NumeroCheque
					  --AND SERIE_DEL_CHEQUE = @SERIE_DEL_CHEQUE
					  AND BANCO_GIRADO = @Entidad_RI 
					  AND FECHA_ALTA = (SELECT fechaproceso FROM PARAMETROS)--@FechaPresentacion
					  AND SUCURSAL_BANCO_GIRADO = @Sucursal_RI
					  AND NUMERO_CUENTA_GIRADORA = CAST(SUBSTRING(@linea, 13, 17) AS NUMERIC);
					  --AND TIPO_DOCUMENTO = SUBSTRING(@linea, 40, 2);
					
					--PRINT Concat(''Cod rechazo original: '', IsNull(Cast(@codRechazoOri as varchar),0))
					
					-- Determinar el código de rechazo basado en la prevalencia causal
					SELECT @codrechazo = ISNULL(RIGHT(causal_prevaleciente, 2), @codRechazo)
					FROM CLE_PREVALENCIA_CAUSAL 
					WHERE CAUSAL_DEPOSITARIA = ''R'' + @codRechazoOri
					  AND CAUSAL_GIRADA = ''R'' + @codRechazo 
					  AND TZ_LOCK = 0;
					
					--PRINT ''Codigo Rechazo: '' + @codrechazo
					
					-- Actualizar el código de rechazo en la tabla de recepción de cheques devueltos
					UPDATE CLE_RECEPCION_CHEQUES_DEV
					SET CODIGO_RECHAZO = TRY_CONVERT(NUMERIC(3), @codRechazo)
					WHERE NUMERO_CHEQUE = @NumeroCheque
					  --AND SERIE_DEL_CHEQUE = @SERIE_DEL_CHEQUE
					  AND BANCO_GIRADO = @Entidad_RI
					  AND FECHA_ALTA = (SELECT fechaproceso FROM PARAMETROS)--@FechaPresentacion
					  AND SUCURSAL_BANCO_GIRADO = @Sucursal_RI
					  AND NUMERO_CUENTA_GIRADORA = CAST(SUBSTRING(@linea, 13, 17) AS NUMERIC);
					  --AND TIPO_DOCUMENTO = SUBSTRING(@linea, 40, 2);
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
						, (CASE WHEN substring(@infoadicional,2,1) IN (''2'',''3'') THEN ''E'' ELSE '' '' END)
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
						TRIM(''0'' FROM RIGHT(@EntidadDebitar, 3)), 
	   					@NumeroCuenta_RI, 
	   					@NumeroCheque_RI,
	   					CONCAT(@Entidad_RI, @Sucursal_RI), 
						''A'', 
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
	PRINT ''No se pudo insertar en tabla RRII_CHE_RECHAZADOS''
				END CATCH	
			END
		END --end RI id = 6
		FETCH NEXT FROM che_cursor INTO @id,@LINEA
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

END')

Execute('CREATE OR ALTER  PROCEDURE [dbo].[SP_TRAN_MINORISTA_RECIBIDAS]
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
	DECLARE @ReservadoRI VARCHAR(1);
	DECLARE @CuentaDebitar VARCHAR(17);
	DECLARE @VImporte VARCHAR(10);     
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
		  	 OR ISNUMERIC(@ReservadoRI) = 0 
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
			isnumeric(ltrim(rtrim(@ReservadoRI)))=0 or 
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
	      SET @TipoCuenta = SUBSTRING(@CuentaDebitar,4,2);
	      
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

END')
