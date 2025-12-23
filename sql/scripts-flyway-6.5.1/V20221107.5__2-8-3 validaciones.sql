Execute('

CREATE OR ALTER  PROCEDURE [dbo].[SP_COELSA_CHEQUES_TERCEROS_RECHAZADOS]

	@TICKET NUMERIC(16)

AS
BEGIN

	------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--- Modified : 07/11/2022 10:00 a.m.
	--- Autor: Juan Pedrozo
	--- Se agregan validaciones excluyentes de registros NACHA.
	------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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


	--SE VAN A USAR ESTOS CAMPOS COMO CLAVE EN LUGAR DEL TRACENUMBER
	DECLARE @Entidad_RI NUMERIC(4);
	--se sacan de cada tracenumber de los RI
	DECLARE @Sucursal_RI NUMERIC(4);
	DECLARE @CodigoPostal_RI NUMERIC(4);
	DECLARE @NumeroCuenta_RI NUMERIC(12);
	DECLARE @NumeroCheque_RI NUMERIC(12);

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
	IF(0=(SELECT COUNT(*) FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX
	WHERE LINEA LIKE ''1%''))
	RAISERROR (''Error - Faltan registros.'', 16, 1);
	IF(0=(SELECT COUNT(*) FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX
	WHERE LINEA LIKE ''5%''))
	RAISERROR (''Error - Faltan registros.'', 16, 1);
	IF(0=(SELECT COUNT(*) FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX
	WHERE LINEA LIKE ''8%''))
	RAISERROR (''Error - Faltan registros.'', 16, 1);
	IF(0=(SELECT COUNT(*) FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX
	WHERE LINEA LIKE ''9%''))
	RAISERROR (''Error - Faltan registros.'', 16, 1);

	--#validacion2
	IF ((SELECT COUNT(*)
	FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX
	WHERE LINEA LIKE ''1%'' OR LINEA LIKE ''9%'') > 2 )
	RAISERROR(''Error - Deben haber solo 1 reg CA y 1 reg FA'', 16, 1);

	--#validacion3
	IF(
	(SELECT COUNT(1) as Orden
	WHERE 1=(
	SELECT count(1)
		WHERE EXISTS
	(SELECT CONVERT(INT,SUBSTRING(LINEA,1,1))
		FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX
		WHERE ID IN
	(SELECT ID-1
			FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX
			WHERE LINEA LIKE ''8%'')
			AND CONVERT(INT,SUBSTRING(LINEA,1,1)) NOT IN (5,6,7)
	))
		OR 1=(
	SELECT count(1)
		WHERE
	EXISTS
	(SELECT CONVERT(INT,SUBSTRING(LINEA,1,1))
		FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX
		WHERE ID IN
	(SELECT ID+1
			FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX
			WHERE LINEA LIKE ''8%'')
			AND CONVERT(INT,SUBSTRING(LINEA,1,1)) NOT IN (5,9)
	))
		OR 1=(
	SELECT count(1)
		WHERE
	EXISTS
	(SELECT CONVERT(INT,SUBSTRING(LINEA,1,1))
		FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX
		WHERE ID IN
	(SELECT ID-1
			FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX
			WHERE LINEA LIKE ''5%'')
			AND CONVERT(INT,SUBSTRING(LINEA,1,1)) NOT IN (1,8)
	))
		OR 1=(
	SELECT count(1)
		WHERE
	EXISTS
	(SELECT CONVERT(INT,SUBSTRING(LINEA,1,1))
		FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX
		WHERE ID IN
	(SELECT ID+1
			FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX
			WHERE LINEA LIKE ''5%'')
			AND CONVERT(INT,SUBSTRING(LINEA,1,1)) NOT IN (6,7,8)
	))) <> 0
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


	--seteo suma entidades/suc y debitos RI
	SELECT
		@sumaEntidades_RI = sum(CAST(substring(LINEA, 4, 4) AS NUMERIC)),
		@sumaSucursales_RI = sum(CAST(substring(LINEA, 8, 4) AS NUMERIC))
	FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX
	WHERE LINEA LIKE ''6%'';


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

	SET @sumaEntidades_RI += @sumaEntidades_RIaux;
	SET @sumaSucursales_RI += @sumaSucursales_RIaux;

	--seteo total control y total de importes FA
	SELECT
		@totControl_FA = CAST(substring(linea, 22, 10) AS NUMERIC),
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
			SET @RegIndivAdic = substring(@LINEA, 5, 6);
			SET @TotalesControl = substring(@LINEA, 11,10);
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

			--actualizo el codigo de rechazo
			UPDATE ITF_COELSA_SESION_RECHAZADOS SET CODIGO_RECHAZO = @CodRechazo WHERE BANCO = @Entidad_RI AND  SUCURSAL = @Sucursal_RI AND CUENTA = @NumeroCuenta_RI AND CODIGO_POSTAL = @CodigoPostal_RI AND NRO_CHEQUE = @NumeroCheque_RI;

			IF(@updRecepcion = ''D'')
				UPDATE CLE_RECEPCION_DPF_DEV SET CODIGO_RECHAZO = @CodRechazo WHERE NUMERO_DPF = @NumeroCheque_RI AND BANCO_GIRADO = @Entidad_RI AND SUCURSAL_BANCO_GIRADO = @Sucursal_RI;
			
			ELSE IF(@updRecepcion = ''C'')
				UPDATE CLE_RECEPCION_CHEQUES_DEV SET CODIGO_RECHAZO = @CodRechazo WHERE NUMERO_CHEQUE = @NumeroCheque_RI AND BANCO_GIRADO = @Entidad_RI AND SUCURSAL_BANCO_GIRADO = @Sucursal_RI;

		END

		/* Registro Individual*/
		IF (@IdRegistro = ''6'' ) 
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
			SET @ContadorRegistros = substring(@LINEA, 80, 15);
			/* Trace Number */

			SET @Entidad_RI = CAST(substring(@ContadorRegistros, 1, 4) AS NUMERIC(4));
			SET @Sucursal_RI = CAST(substring(@ContadorRegistros, 5, 4) AS NUMERIC(4));;
			SET @CodigoPostal_RI = CAST(RIGHT(@CodigoPostal, 4) AS NUMERIC(4));
			SET @NumeroCuenta_RI = CAST(RIGHT(@CuentaDebitar, 12) AS NUMERIC(12));
			SET @NumeroCheque_RI = CAST(RIGHT(@NumeroCheque, 12) AS NUMERIC(12));


			IF (@RegistrosAdicionales NOT IN(''1'',''0'')) 
    		RAISERROR (''Campo Registro adicional invalido'', 16, 1);



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
					--lo seteo en ''-'' y desp veo su hay que updatear CLE_RECEPCION_CHEQUES_DEV (''C'') o CLE_RECEPCION_DPF_DEV (''D'')
					SET @updRecepcion = ''-'';

					-- La idea es actualizar los rechazados del plano con ESTADO_AJUSTE = ''R'' y el resto de cheques del historial con ESTADO_AJUSTE  = ''A''	
					UPDATE dbo.CLE_CHEQUES_AJUSTE SET ESTADO_AJUSTE = ''R'' WHERE TZ_LOCK = 0 AND
						@Entidad_RI = BANCO AND @Sucursal_RI  = SUCURSAL_BANCO_GIRADO AND @CodigoPostal_RI = CODIGO_POSTAL AND @NumeroCheque_RI = NUMERO_CHEQUE AND @NumeroCuenta_RI = NUMERO_CUENTA;

					-- Consulta Ajuste
					SELECT @EXISTE = 1, @ORDINAL = ORDINAL, @BANCO_GIRADO = BANCO, @FECHA_ALTA = FECHA_ALTA, @NRO_DPF_CHEQUE = NUMERO_CHEQUE, @SUCURSAL_BANCO = SUCURSAL_BANCO_GIRADO, @NRO_CUENTA = NUMERO_CUENTA, @CODIGO_POSTAL = CODIGO_POSTAL, @IMPORTE_TOTAL = IMPORTE, @MONEDA = MONEDA
					FROM CLE_CHEQUES_AJUSTE WITH(NOLOCK)
					WHERE TZ_LOCK = 0 AND
						@Entidad_RI = BANCO AND @Sucursal_RI  = SUCURSAL_BANCO_GIRADO AND @CodigoPostal_RI = CODIGO_POSTAL AND @NumeroCheque_RI = NUMERO_CHEQUE AND @NumeroCuenta_RI = NUMERO_CUENTA;

					IF @EXISTE > 0
					BEGIN
						
						-- Guardamos clave para update si hay reg adicional
						SET @Entidad_RI = @BANCO_GIRADO;
						SET @Sucursal_RI = @SUCURSAL_BANCO;
						SET @NumeroCuenta_RI = @NRO_CUENTA;
						SET @CodigoPostal_RI = @CODIGO_POSTAL;
						SET @NumeroCheque_RI = @NRO_DPF_CHEQUE;

						-- Insertamos en el historial
						INSERT INTO ITF_COELSA_SESION_RECHAZADOS
							(ID_TICKET, FECHA_ALTA, BANCO, SUCURSAL, CUENTA, IMPORTE, CODIGO_POSTAL, NRO_CHEQUE, PUNTO_INTERCAMBIO, TRACK_NUMBER, TIPO, MONEDA, TIPO_DOCUMENTO, CODIGO_RECHAZO, ORDINAL)
						VALUES(@TICKET, @FECHA_ALTA, @BANCO_GIRADO, @SUCURSAL_BANCO, @NRO_CUENTA, @IMPORTE_TOTAL, @CODIGO_POSTAL, @NRO_DPF_CHEQUE, @PuntoIntercambio, @ContadorRegistros, ''C'', @MONEDA, @TIPO_DOCUMENTO, @CodRechazo, @ORDINAL);
					END
					ELSE
					BEGIN
						-- Insertamos en el historial en caso de que no exista
						INSERT INTO ITF_COELSA_SESION_RECHAZADOS
							(ID_TICKET, FECHA_ALTA, BANCO, SUCURSAL, CUENTA, IMPORTE, CODIGO_POSTAL, NRO_CHEQUE, PUNTO_INTERCAMBIO, TRACK_NUMBER, TIPO, MONEDA, TIPO_DOCUMENTO, CODIGO_RECHAZO)
						VALUES(@TICKET, @FechaPresentacion, @Entidad_RI, @Sucursal_RI, @NumeroCuenta_RI, @Importe, @CodigoPostal_RI, @NumeroCheque_RI, @PuntoIntercambio, @ContadorRegistros, ''C'', 1 , @TIPO_DOCUMENTO, @CodRechazo);

					END
				END			
				ELSE IF (CAST(@CuentaDebitar AS NUMERIC) = 77777777777)
				BEGIN
						-- Consulta DPF  			
						SELECT @EXISTE = 1, @TIPO_DOCUMENTO = TIPO_DOCUMENTO, @NRO_DPF_CHEQUE = NUMERO_DPF, @BANCO_GIRADO = BANCO_GIRADO, @SUCURSAL_BANCO = SUCURSAL_BANCO_GIRADO, @FECHA_ALTA = FECHA_ALTA, @IMPORTE_TOTAL = IMPORTE, @CODIGO_POSTAL = COD_POSTAL, @MONEDA = MONEDA, @NRO_CUENTA = NUMERICO_CUENTA_GIRADORA
						FROM CLE_DPF_SALIENTE WITH(NOLOCK)
						WHERE TZ_LOCK = 0 AND
							@Entidad_RI = BANCO_GIRADO AND @Sucursal_RI  = SUCURSAL_BANCO_GIRADO AND @CodigoPostal_RI = COD_POSTAL AND @NumeroCheque_RI = NUMERO_DPF AND @NumeroCuenta_RI = NUMERICO_CUENTA_GIRADORA;


						IF @EXISTE > 0
						BEGIN
							-- Guardamos clave para update si hay reg adicional
							SET @Entidad_RI = @BANCO_GIRADO;
							SET @Sucursal_RI = @SUCURSAL_BANCO;
							SET @NumeroCuenta_RI = @NRO_CUENTA;
							SET @CodigoPostal_RI = @CODIGO_POSTAL;
							SET @NumeroCheque_RI = @NRO_DPF_CHEQUE;
							
							SET @updRecepcion = ''D''; --para saber si hay que updatear  CLE_RECEPCION_DPF_DEV

							INSERT INTO CLE_RECEPCION_DPF_DEV
								(NUMERO_DPF, BANCO_GIRADO, FECHA_ALTA, SUCURSAL_BANCO_GIRADO, TIPO_DOCUMENTO, IMPORTE_DPF, [CODIGO_CAMARA], ESTADO_DEVOLUCION)
							VALUES
								(@NRO_DPF_CHEQUE, @BANCO_GIRADO, @FECHA_ALTA, @SUCURSAL_BANCO, @TIPO_DOCUMENTO, @IMPORTE_TOTAL, (SELECT [CODIGO_DE_CAMARA]
									FROM CLE_CAMARAS_COMPENSADORAS WITH (NOLOCK)), 1);

							-- Insertamos en el historial
							INSERT INTO ITF_COELSA_SESION_RECHAZADOS
								(ID_TICKET, FECHA_ALTA, BANCO, SUCURSAL, CUENTA, IMPORTE, CODIGO_POSTAL, NRO_CHEQUE, PUNTO_INTERCAMBIO, TRACK_NUMBER, TIPO, MONEDA, TIPO_DOCUMENTO, ORDINAL)
							VALUES(@TICKET, @FECHA_ALTA, @BANCO_GIRADO, @SUCURSAL_BANCO, @NRO_CUENTA, @IMPORTE_TOTAL, @CODIGO_POSTAL, @NRO_DPF_CHEQUE, @PuntoIntercambio, @ContadorRegistros, ''C'', @MONEDA, @TIPO_DOCUMENTO, @ORDINAL);

						END
						ELSE
						BEGIN
							-- Insertamos en el historial en caso de que no exista
							INSERT INTO ITF_COELSA_SESION_RECHAZADOS
								(ID_TICKET, FECHA_ALTA, BANCO, SUCURSAL, CUENTA, IMPORTE, CODIGO_POSTAL, NRO_CHEQUE, PUNTO_INTERCAMBIO, TRACK_NUMBER, TIPO, MONEDA, TIPO_DOCUMENTO)
							VALUES(@TICKET, @FechaPresentacion, @Entidad_RI, @Sucursal_RI, @NumeroCuenta_RI, @Importe, @CodigoPostal_RI, @NumeroCheque_RI, @PuntoIntercambio, @ContadorRegistros, ''C'', 1 , @TIPO_DOCUMENTO);

						END
				END      	
				ELSE
				BEGIN
					-- Consulta Cheque
					SELECT @EXISTE = 1, @NRO_DPF_CHEQUE = NRO_CHEQUE, @SERIE_DEL_CHEQUE = SERIE_DEL_CHEQUE, @BANCO_GIRADO = BANCO, @FECHA_ALTA = FECHA_PRESENTADO, @SUCURSAL_BANCO = SUCURSAL, @NRO_CUENTA = CUENTA, @TIPO_DOCUMENTO = TIPO_DOCUMENTO, @IMPORTE_TOTAL = IMPORTE, @CODIGO_POSTAL = CODIGO_POSTAL, @MONEDA = MONEDA
					FROM ITF_COELSA_CHEQUES_OTROS WITH(NOLOCK)
					WHERE 
					@Entidad_RI = BANCO AND @Sucursal_RI  = SUCURSAL AND @CodigoPostal_RI = CODIGO_POSTAL AND @NumeroCheque_RI = NRO_CHEQUE AND @NumeroCuenta_RI = CUENTA;

					IF @EXISTE > 0
					BEGIN
						-- Guardamos clave para update si hay reg adicional
						SET @Entidad_RI = @BANCO_GIRADO;
						SET @Sucursal_RI = @SUCURSAL_BANCO;
						SET @NumeroCuenta_RI = @NRO_CUENTA;
						SET @CodigoPostal_RI = @CODIGO_POSTAL;
						SET @NumeroCheque_RI = @NRO_DPF_CHEQUE;
						
						SET @updRecepcion = ''C''; --para saber si updatear el cod Rechazo de la tabla CLE_RECEPCION_CHEQUES_DEV

						INSERT INTO CLE_RECEPCION_CHEQUES_DEV
							(NUMERO_CHEQUE, SERIE_DEL_CHEQUE, BANCO_GIRADO, FECHA_ALTA, SUCURSAL_BANCO_GIRADO, NUMERO_CUENTA_GIRADORA, TIPO_DOCUMENTO, IMPORTE_CHEQUE,  ESTADO_DEVOLUCION, CODIGO_CAMARA)
						VALUES
							(@NRO_DPF_CHEQUE, @SERIE_DEL_CHEQUE, @BANCO_GIRADO, @FECHA_ALTA, @SUCURSAL_BANCO, @NRO_CUENTA, @TIPO_DOCUMENTO, @IMPORTE_TOTAL,  1, (SELECT [CODIGO_DE_CAMARA]
								FROM CLE_CAMARAS_COMPENSADORAS WITH(NOLOCK)));

						-- Insertamos en el historial
						INSERT INTO ITF_COELSA_SESION_RECHAZADOS
							(ID_TICKET, FECHA_ALTA, BANCO, SUCURSAL, CUENTA, IMPORTE, CODIGO_POSTAL, NRO_CHEQUE, PUNTO_INTERCAMBIO, TRACK_NUMBER, TIPO, MONEDA, TIPO_DOCUMENTO,  SERIE_DEL_CHEQUE)
						VALUES(@TICKET, @FECHA_ALTA, @BANCO_GIRADO, @SUCURSAL_BANCO, @NRO_CUENTA, @IMPORTE_TOTAL, @CODIGO_POSTAL, @NRO_DPF_CHEQUE, @PuntoIntercambio, @ContadorRegistros, ''C'', @MONEDA, @TIPO_DOCUMENTO, @SERIE_DEL_CHEQUE);
					END
					ELSE
					BEGIN
							-- Insertamos en el historial en caso de que no exista
							INSERT INTO ITF_COELSA_SESION_RECHAZADOS
								(ID_TICKET, FECHA_ALTA, BANCO, SUCURSAL, CUENTA, IMPORTE, CODIGO_POSTAL, NRO_CHEQUE, PUNTO_INTERCAMBIO, TRACK_NUMBER, TIPO, MONEDA, TIPO_DOCUMENTO)
							VALUES(@TICKET, @FechaPresentacion, @Entidad_RI, @Sucursal_RI, @NumeroCuenta_RI, @Importe, @CodigoPostal_RI, @NumeroCheque_RI, @PuntoIntercambio, @ContadorRegistros, ''C'', 1 , @TIPO_DOCUMENTO);

					END

				END
			END


		END --end RI id = 6

		FETCH NEXT FROM che_cursor INTO @LINEA
	END

	CLOSE che_cursor
	DEALLOCATE che_cursor

	--- Actualizar el estado de los ajustes no incluidos en el plano -------------------------------------------------------------
	UPDATE dbo.CLE_CHEQUES_AJUSTE SET ESTADO_AJUSTE = ''A'' WHERE ESTADO_AJUSTE IS NULL AND ESTADO = ''P'' AND FECHA_ACREDITACION = (SELECT FECHAPROCESO
		FROM PARAMETROS WITH(NOLOCK));
------------------------------------------------------------------------------------------------------------------------------

END;

')