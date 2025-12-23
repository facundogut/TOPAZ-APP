EXECUTE('
IF OBJECT_ID (''dbo.ITF_DD_PRESENT_RECIB_RECHAZOS'') IS NOT NULL
	DROP TABLE dbo.ITF_DD_PRESENT_RECIB_RECHAZOS

IF OBJECT_ID (''dbo.ITF_DD_PRESENTADOS_RECIBIDOS_AUX'') IS NOT NULL
	DROP TABLE dbo.ITF_DD_PRESENTADOS_RECIBIDOS_AUX
	
	
IF OBJECT_ID (''dbo.SNP_MSG_ORDENES'') IS NOT NULL
	DROP TABLE dbo.SNP_MSG_ORDENES
	
	IF OBJECT_ID (''dbo.SNP_STOP_DEBIT'') IS NOT NULL
	DROP TABLE dbo.SNP_STOP_DEBIT
	
	IF OBJECT_ID (''dbo.SP_DD_PRESENTADOS_RECIBIDOS'') IS NOT NULL
	DROP PROCEDURE dbo.SP_DD_PRESENTADOS_RECIBIDOS
	
	')
	
	EXECUTE('
	CREATE TABLE dbo.SNP_STOP_DEBIT
	(
	TZ_LOCK           NUMERIC (15) DEFAULT ((0)) NOT NULL,
	CUIT_EO           NUMERIC (11) DEFAULT ((0)),
	CLIENTE_ADHERIDO  NUMERIC (12) DEFAULT ((0)) NOT NULL,
	CORRELATIVO       NUMERIC (9) DEFAULT ((0)) NOT NULL,
	PRESTACION        VARCHAR (10) DEFAULT ('' ''),
	CODIGO_CLIENTE    NUMERIC (12) DEFAULT ((0)) NOT NULL,
	FECHA_VENCIMIENTO DATETIME,
	REFERENCIA        VARCHAR (15) DEFAULT ('' ''),
	MONEDA            NUMERIC (4) DEFAULT ((0)),
	IMPORTE           NUMERIC (15, 2) DEFAULT ((0)),
	FECHA_DESDE       DATETIME,
	FECHA_HASTA       DATETIME,
	IMPORTE_MAXIMO    NUMERIC (15, 2) DEFAULT ((0)),
	FECHA_ALTA        DATETIME,
	FECHA_BAJA        DATETIME,
	MOTIVO            VARCHAR (250) DEFAULT ('' ''),
	ESTADO            VARCHAR (2) DEFAULT ('' ''),
	ID_CONVENIO       NUMERIC (15) DEFAULT ((0)) NOT NULL,
	DEBITO_DIRECTO    VARCHAR (1),
	SALDO_JTS_OID     NUMERIC (10) DEFAULT ((0)) NOT NULL,
	CONSTRAINT PK_SNP_STOP_DEBIT_01 UNIQUE (ID_CONVENIO, CLIENTE_ADHERIDO, CORRELATIVO)
	)
	')
	EXECUTE('
CREATE TABLE dbo.ITF_DD_PRESENT_RECIB_RECHAZOS
	(
	ID                 INT IDENTITY NOT NULL,
	ID_TICKET          NUMERIC (16),
	FECHAPROCESO       DATETIME,
	CODIGO_TRANSACCION NUMERIC (2),
	ENTIDAD_DEBITAR    NUMERIC (8),
	CUENTA_DEBITAR     NUMERIC (17),
	IMPORTE            NUMERIC (15, 2),
	REFERENCIA_UNIVOCA VARCHAR (30),
	ID_CLIENTE_PAGADOR VARCHAR (22),
	INFO_ADICIONAL     VARCHAR (2),
	ESTADO             VARCHAR (1),
	CODIGO_ERROR       VARCHAR (3),
	CONSTRAINT PK__ITF_DD_PRESENT_RECIB_RECHAZOS PRIMARY KEY (ID)
	)
	
	')
	
	EXECUTE('

	
CREATE TABLE dbo.ITF_DD_PRESENTADOS_RECIBIDOS_AUX
	(
	ID    INT IDENTITY NOT NULL,
	LINEA VARCHAR (200)
	)

')
EXECUTE('



CREATE TABLE dbo.SNP_MSG_ORDENES
	(
	TZ_LOCK              NUMERIC (15) DEFAULT ((0)) NOT NULL,
	CUIT_EO              NUMERIC (11) DEFAULT ((0)) NOT NULL,
	ID_ARCHIVO           VARCHAR (10) DEFAULT ('' '') NOT NULL,
	NRO_ARCHIVO          NUMERIC (15) DEFAULT ((0)) NOT NULL,
	CORRELATIVO          NUMERIC (9) DEFAULT ((0)) NOT NULL,
	DEBITO_TRANSFERENCIA VARCHAR (2) DEFAULT ('' ''),
	CODIGO_ORDEN         NUMERIC (2) DEFAULT ((0)),
	INFO_ADICIONAL       VARCHAR (3) DEFAULT ('' ''),
	PRESTACION           VARCHAR (10) DEFAULT ('' ''),
	CODIGO_CLIENTE       NUMERIC (12) DEFAULT ((0)),
	COD_CLIENTE_PAGADOR  VARCHAR (22) DEFAULT ('' ''),
	CBU                  VARCHAR (22) DEFAULT ('' ''),
	FECHA_VENCIMIENTO    DATETIME,
	FECHA_COMPENSACION   DATETIME,
	REFERENCIA           VARCHAR (15) DEFAULT ('' ''),
	CUENTA               NUMERIC (15),
	MONEDA               NUMERIC (4) DEFAULT ((0)),
	IMPORTE              NUMERIC (15, 2) DEFAULT ((0)),
	TIPO_DOCUMENTO       VARCHAR (4) DEFAULT ('' ''),
	NRO_DOCUMENTO        VARCHAR (20) DEFAULT ('' ''),
	FECHA_ALTA           DATETIME,
	FECHA_BAJA           DATETIME,
	CONCEPTO             VARCHAR (80) DEFAULT ('' ''),
	SEGUNDO_VTO          DATETIME,
	SEGUNDO_IMPORTE      NUMERIC (15, 2) DEFAULT ((0)),
	MOTIVO_RECHAZO       VARCHAR (3) DEFAULT ('' ''),
	CBU_NUEVO            VARCHAR (22) DEFAULT ('' ''),
	CODIGO_CLIENTE_NUEVO NUMERIC (12) DEFAULT ((0)),
	ID_NACHA             VARCHAR (10) DEFAULT ('' ''),
	FECHA_NACHA          DATETIME,
	CORRELATIVO_NACHA    NUMERIC (15) DEFAULT ((0)),
	CORRELATIVO_LOTE     NUMERIC (15) DEFAULT ((0)),
	REGISTRO_INDIVIDUAL  NUMERIC (15) DEFAULT ((0)),
	FECHA_ASIENTO        DATETIME,
	NUMERO_ASIENTO       NUMERIC (10) DEFAULT ((0)),
	SUCURSAL_ASIENTO     NUMERIC (5) DEFAULT ((0)),
	ESTADO               VARCHAR (2) DEFAULT ('' ''),
	TIPO_ORDEN           VARCHAR (6) DEFAULT ('' ''),
	TIPO_TRANSFERENCIA   VARCHAR (1) DEFAULT ('' ''),
	CONSTRAINT PK_SNP_MSG_ORDENES_01 PRIMARY KEY (CUIT_EO, ID_ARCHIVO, NRO_ARCHIVO, CORRELATIVO)
	)

')

EXECUTE('


CREATE PROCEDURE [dbo].[SP_DD_PRESENTADOS_RECIBIDOS]
	@TICKET NUMERIC(16)
AS
BEGIN 

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

	/******** Variables Cabecera de Lote **********************************/
	DECLARE @FechaVencimiento DATE;
	DECLARE @FechaCompensacion DATE;
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
	DECLARE @Importe NUMERIC(10) = 0;     
	DECLARE @ReferenciaUnivoca VARCHAR(15);
	DECLARE @IdClientePegador VARCHAR(22);
	DECLARE @InfoAdicional VARCHAR(2);
	DECLARE @RegistrosAdicionales VARCHAR(1);
	DECLARE @ContadorRegistros VARCHAR(15);

	DECLARE @CodRechazo VARCHAR (2);

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

	/*Validaciones generales */
	
	DECLARE @updRecepcion VARCHAR(1);
	DECLARE @correlativo NUMERIC(10,0)=0;
	DECLARE @NroArchivo NUMERIC(15,0)= (SELECT ISNULL(MAX(NRO_ARCHIVO),0) FROM dbo.SNP_MSG_ORDENES)+1;

	IF(0=(SELECT COUNT(*) FROM ITF_DD_PRESENTADOS_RECIBIDOS_AUX
	WHERE LINEA LIKE ''1%''))
	RAISERROR (''Error - Faltan registros.'', 16, 1);
	IF(0=(SELECT COUNT(*) FROM ITF_DD_PRESENTADOS_RECIBIDOS_AUX
	WHERE LINEA LIKE ''5%''))
	RAISERROR (''Error - Faltan registros.'', 16, 1);
	IF(0=(SELECT COUNT(*) FROM ITF_DD_PRESENTADOS_RECIBIDOS_AUX
	WHERE LINEA LIKE ''8%''))
	RAISERROR (''Error - Faltan registros.'', 16, 1);
	IF(0=(SELECT COUNT(*) FROM ITF_DD_PRESENTADOS_RECIBIDOS_AUX
	WHERE LINEA LIKE ''9%''))
	RAISERROR (''Error - Faltan registros.'', 16, 1);


	--#validacion2
	IF ((SELECT COUNT(*)
	FROM ITF_DD_PRESENTADOS_RECIBIDOS_AUX
	WHERE LINEA LIKE ''1%'' OR LINEA LIKE ''9%'') > 2 )
	RAISERROR(''Error - Deben haber solo 1 reg CA y 1 reg FA'', 16, 1);


	--#validacion3
	IF(
	(SELECT COUNT(1) as Orden
	WHERE 1=(
	SELECT count(1)
		WHERE EXISTS
	(SELECT CONVERT(INT,SUBSTRING(LINEA,1,1))
		FROM ITF_DD_PRESENTADOS_RECIBIDOS_AUX
		WHERE ID IN
	(SELECT ID-1
			FROM ITF_DD_PRESENTADOS_RECIBIDOS_AUX
			WHERE LINEA LIKE ''8%'')
			AND CONVERT(INT,SUBSTRING(LINEA,1,1)) NOT IN (5,6,7)
	))
		OR 1=(
	SELECT count(1)
		WHERE
	EXISTS
	(SELECT CONVERT(INT,SUBSTRING(LINEA,1,1))
		FROM ITF_DD_PRESENTADOS_RECIBIDOS_AUX
		WHERE ID IN
	(SELECT ID+1
			FROM ITF_DD_PRESENTADOS_RECIBIDOS_AUX
			WHERE LINEA LIKE ''8%'')
			AND CONVERT(INT,SUBSTRING(LINEA,1,1)) NOT IN (5,9)
	))
		OR 1=(
	SELECT count(1)
		WHERE
	EXISTS
	(SELECT CONVERT(INT,SUBSTRING(LINEA,1,1))
		FROM ITF_DD_PRESENTADOS_RECIBIDOS_AUX
		WHERE ID IN
	(SELECT ID-1
			FROM ITF_DD_PRESENTADOS_RECIBIDOS_AUX
			WHERE LINEA LIKE ''5%'')
			AND CONVERT(INT,SUBSTRING(LINEA,1,1)) NOT IN (1,8)
	))
		OR 1=(
	SELECT count(1)
		WHERE
	EXISTS
	(SELECT CONVERT(INT,SUBSTRING(LINEA,1,1))
		FROM ITF_DD_PRESENTADOS_RECIBIDOS_AUX
		WHERE ID IN
	(SELECT ID+1
			FROM ITF_DD_PRESENTADOS_RECIBIDOS_AUX
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

--seteo suma deb y cred 

	SELECT -- debitos
		@sumaDebitos_RI = sum(CAST(substring(LINEA, 30, 10) AS NUMERIC)),
		@sumaEntidades_RI = sum(CAST(substring(LINEA, 4, 4) AS NUMERIC)),
		@sumaSucursales_RI = sum(CAST(substring(LINEA, 8, 4) AS NUMERIC))
	FROM ITF_DD_PRESENTADOS_RECIBIDOS_AUX
	WHERE LINEA LIKE ''6%'' --OR LINEA LIKE ''7%'';

	/*SELECT --creditos
		@sumaCreditos_RI = sum(CAST(substring(LINEA, 30, 10) AS NUMERIC)),
		@sumaEntidades_RIaux = sum(CAST(substring(LINEA, 4, 4) AS NUMERIC)),
		@sumaSucursales_RIaux = sum(CAST(substring(LINEA, 8, 4) AS NUMERIC))
	FROM ITF_DD_PRESENTADOS_RECIBIDOS_AUX
	WHERE LINEA LIKE ''622%'';*/

	SET @sumaEntidades_RI += isNull(@sumaEntidades_RIaux,0);
	SET @sumaSucursales_RI += isNull(@sumaSucursales_RIaux,0);
	
	--seteo total control y total de importes FA
	SELECT
		@totControl_FA = CAST(substring(linea, 22, 10) AS NUMERIC),
		@totalDebitos_FA = CAST(substring(linea, 32, 12) AS NUMERIC),
		@totalCreditos_FA = CAST(substring(linea, 44, 12) AS NUMERIC)
	FROM ITF_DD_PRESENTADOS_RECIBIDOS_AUX
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
	FROM ITF_DD_PRESENTADOS_RECIBIDOS_AUX
	WHERE LINEA LIKE ''8%'';


	--#validacion5
	IF(CONCAT(@sumaEntidades_RI, RIGHT(CONCAT(REPLICATE(''0'',3), @sumaSucursales_RI ),4)) <> @sumaTotalCtrl_FL)
	RAISERROR(''No concuerda la suma Ent/Suc con control FL'', 16, 1);
	--#validacion7
	IF(RIGHT(@sumaTotalCtrl_FL,10) <> @totControl_FA)
	RAISERROR(''No concuerda la suma de TotalesControl de FL con control FA'', 16, 1);


	--#validacion6 debitos
	IF(@sumaDebitos_RI  <> @controlDebitos_FL AND @sumaDebitos_RI <> @totalDebitos_FA)
	RAISERROR(''No concuerda la suma de Debitos individuales con el Total Debitos'', 16, 1);

	--#validacion6 creditos
	IF( @sumaCreditos_RI <> @controlCreditos_FL AND @sumaCreditos_RI <> @totalCreditos_FA)
	RAISERROR(''No concuerda la suma de Creditos individuales con el Total Creditos '', 16, 1);


	--#validacion8
   /*	IF((@controlDebitos_FL + @controlCreditos_FL) <>  (@totalDebitos_FA + @totalCreditos_FA))
	RAISERROR(''No concuerda la suma de Debitos de FL con Total Importe FA'', 16, 1);
*/

	--fin----validaciones #5 #6 #7 y #8





	DECLARE @LINEA VARCHAR(95);
	DECLARE deb_cursor CURSOR FOR 
SELECT LINEA
	FROM dbo.ITF_DD_PRESENTADOS_RECIBIDOS_AUX

	OPEN deb_cursor

	FETCH NEXT FROM deb_cursor INTO @LINEA

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
			--variables de cabecera de archivo
			SET @CodigoPrioridad = substring(@LINEA,2,2);
			SET @DestinoInmediato = substring(@LINEA,4 ,10);
			SET @FechaVencimiento = substring(@LINEA, 24, 6);
			SET @HoraPresentacion = substring(@LINEA, 30, 4);
			SET @IdentificadorArchivo = substring(@LINEA, 34, 1);
			SET @TamanoRegistro = substring(@LINEA, 35, 3);
			SET @FactorBloque = substring(@LINEA, 38, 2);
			SET @CodigoFormato = substring(@LINEA, 40, 1);
			SET @NombreDestinoInmediato = substring(@LINEA, 41, 23);
			SET @NombreOrigenInmediato = substring(@LINEA, 64, 23);
			SET @CodigoReferencia = substring(@LINEA, 87, 8);


			IF(@CodigoPrioridad<>''01'')
			RAISERROR (''Codigo Prioridad debe ser 01'', 16, 1);
			

			IF(@TamanoRegistro<>''094'')
			RAISERROR (''Tamaño registro debe ser 094'', 16, 1);
			
			IF(@FactorBloque<>''10'')
			RAISERROR (''Factor Bloque debe ser 10'', 16, 1);
			
						
			IF(@CodigoFormato<>''1'')
			RAISERROR (''Codigo Formato debe ser 1'', 16, 1);
			
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

			SET @FechaVencimiento = CAST(substring(@LINEA, 64, 6) AS DATE);
			--VALIDACION FECHAS
			SET @FechaCompensacion = CAST(substring(@LINEA, 70, 6) AS DATE);
			SET @ReservadoLoteCeros = substring(@LINEA, 76, 3);
			--VALIDACION RESERVADO 000
			SET @CodigoOrigen = substring(@LINEA, 79, 1);

			SET @IdEntidadOrigen = substring(@LINEA, 80, 8);

			SET @NumeroLote = substring(@LINEA, 88, 7);

			IF (@ClaseTransaccion <> 200) 
      		RAISERROR (''Codigo de clase de transaccion debe ser 200'', 16, 1);
			

			IF (@CodigoRegistro <> ''PPD'') 
    		RAISERROR (''Codigo de registro debe ser TRC'', 16, 1);
			

			IF (@FechaVencimiento > @FechaCompensacion) 
      		RAISERROR (''Fecha Presentacion debe ser anterior a vencimiento'', 16, 1);
		
			
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
			IF(@ExisteRI = 1 AND (SELECT COUNT(*) FROM ITF_DD_PRESENTADOS_RECIBIDOS_AUX WHERE LINEA LIKE ''5%'') <> @CantLotesFA)
				RAISERROR(''No coincide la cantidad de LOTES con la informada en el reg FA'', 16, 1);
			
			--#validacion10
			IF((SELECT count(*) FROM ITF_DD_PRESENTADOS_RECIBIDOS_AUX WHERE LINEA LIKE ''6%'' OR LINEA LIKE ''7%'') <> @CantRegAdFA)
				RAISERROR(''No coincide la cantidad de registros ind y ad con la informada en el reg FA'', 16, 1);

		END
/*
		Registro ind adicional
		IF(@IdRegistro = ''7'')
		BEGIN
			SET @CodRechazo = substring(@LINEA, 5, 2);

			--actualizo el codigo de rechazo
			IF(ISNUMERIC(@Entidad_RI) = 1 AND ISNUMERIC(@Sucursal_RI) = 1 AND ISNUMERIC(@IdClientePegador_RI) = 1 AND ISNUMERIC(@ReferenciaUnivoca_RI) = 1 AND ISNUMERIC(@NumeroCuenta_RI ) = 1 )
			BEGIN 
				UPDATE ITF_COELSA_SESION_RECHAZADOS SET CODIGO_RECHAZO = @CodRechazo WHERE ID_TICKET = @TICKET AND BANCO = @Entidad_RI AND  SUCURSAL = @Sucursal_RI AND CUENTA = @NumeroCuenta_RI AND CODIGO_POSTAL = @IdClientePegador_RI AND NRO_CHEQUE = @ReferenciaUnivoca_RI;
			
				IF(@updRecepcion = ''D'')
					UPDATE CLE_RECEPCION_DPF_DEV SET CODIGO_RECHAZO = @CodRechazo WHERE NUMERO_DPF = @ReferenciaUnivoca_RI AND BANCO_GIRADO = @Entidad_RI AND SUCURSAL_BANCO_GIRADO = @Sucursal_RI;
			END	
		END*/


		/* Registro Individual */
		IF (@IdRegistro = ''6'') 
      BEGIN
      		SET @ExisteRI = 1;
      		
			SET @CodTransaccion = substring(@LINEA, 2, 2);
			SET @EntidadDebitar = substring(@LINEA, 4, 8);
			SET @ReservadoRI = substring(@LINEA, 12, 1);
			SET @CuentaDebitar = substring(@LINEA, 13, 16);
			SET @Importe = CONVERT(NUMERIC(15,2),substring(@LINEA, 30, 10))/100;
			SET @ReferenciaUnivoca = substring(@LINEA, 40, 15);
			SET @IdClientePegador = substring(@LINEA, 55, 22);
			SET @InfoAdicional = substring(@LINEA, 77, 2);
			SET @RegistrosAdicionales = substring(@LINEA, 79, 1);
			SET @ContadorRegistros = substring(@LINEA, 80, 15);
			/* Trace Number */


			SET @Entidad_RI = substring(@ContadorRegistros, 1, 4);
			SET @Sucursal_RI = substring(@ContadorRegistros, 5, 4);
			SET @IdClientePegador_RI = RIGHT(@IdClientePegador, 4);
			SET @NumeroCuenta_RI = RIGHT(@CuentaDebitar, 12);
			SET @ReferenciaUnivoca_RI = RIGHT(@ReferenciaUnivoca, 12);


			IF (@RegistrosAdicionales NOT IN(''1'',''0'')) 
      		BEGIN
				RAISERROR (''Campo Registro adicional invalido'', 16, 1);
			END

-- VALIDACIONES INCLUYENTES
			  /* FEREADO EN SUCURSAL R93 */
			  DECLARE @V93 NUMERIC(2);
		      DECLARE @FechaPro VARCHAR(10);
		      DECLARE @FECHADATE DATETIME;
		      SET @FechaPro = CONVERT(VARCHAR(10),(SELECT FECHAPROCESO FROM PARAMETROS),103);
		      SET @FECHADATE = (SELECT FECHAPROCESO FROM PARAMETROS);
		      SET @V93 = (SELECT COUNT(*) FROM FERIADOS WHERE (SUCURSAL=CONVERT(INT,LEFT(@EntidadDebitar,4)) OR SUCURSAL=-1) AND DIA=FORMAT(@FECHADATE,''dd'') AND MES=FORMAT(@FECHADATE,''MM'') AND (ANIO=FORMAT(@FECHADATE,''yyyy'') OR ANIO=0)); 
		      
		      IF (@V93 > 0)
		      BEGIN
		      		INSERT INTO dbo.ITF_DD_PRESENT_RECIB_RECHAZOS (ID_TICKET,  FECHAPROCESO, CODIGO_TRANSACCION, ENTIDAD_DEBITAR, CUENTA_DEBITAR, IMPORTE,  REFERENCIA_UNIVOCA, ID_CLIENTE_PAGADOR,  ESTADO,  CODIGO_ERROR, INFO_ADICIONAL)
       				VALUES (@TICKET, @FECHADATE, @CodTransaccion, @EntidadDebitar, @CuentaDebitar, @Importe,  @ReferenciaUnivoca, @IdClientePegador,  ''I'',  (SELECT CODIGO_NACHA FROM CLE_TIPO_CAUSAL WHERE CODIGO_DE_CAUSAL = 76),@InfoAdicional);
		      	GOTO Final
		      END

			  /* CUENTA INVALIDA R03 */
			  DECLARE @V03 NUMERIC(2);
		      DECLARE @NumCuenta NUMERIC(20);
		      DECLARE @Moneda INT;
		      IF(LEFT(@InfoAdicional,1)=0)
				SET @Moneda = (SELECT C6399 FROM MONEDAS WHERE C6403=''N'');
		      IF(LEFT(@InfoAdicional,1)=1)
				SET @Moneda = (SELECT C6399 FROM MONEDAS WHERE C6403=''D'');
		   
		      SET @NumCuenta = CAST(@CuentaDebitar AS NUMERIC);
		      
		      SET @V03 = (SELECT COUNT(*) FROM SALDOS WHERE CUENTA = @NumCuenta AND SUCURSAL = CONVERT(INT,RIGHT(@EntidadDebitar,4)) AND MONEDA=@Moneda);

			  IF (@V03 > 0)
		      BEGIN
		      		INSERT INTO dbo.ITF_DD_PRESENT_RECIB_RECHAZOS (ID_TICKET,  FECHAPROCESO, CODIGO_TRANSACCION, ENTIDAD_DEBITAR, CUENTA_DEBITAR, IMPORTE,  REFERENCIA_UNIVOCA, ID_CLIENTE_PAGADOR,  ESTADO,  CODIGO_ERROR, INFO_ADICIONAL)
       				VALUES (@TICKET, @FECHADATE, @CodTransaccion, @EntidadDebitar, @CuentaDebitar, @Importe,  @ReferenciaUnivoca, @IdClientePegador,  ''I'',  (SELECT CODIGO_NACHA FROM CLE_TIPO_CAUSAL WHERE CODIGO_DE_CAUSAL = 3),@InfoAdicional);
		      	GOTO Final
		      END
		      
		      /* CUENTA CANCELADA R02 */
		      DECLARE @V02 NUMERIC(2);
		      SET @V02 = (SELECT COUNT(*) FROM SALDOS WHERE CUENTA = @NumCuenta AND SUCURSAL = CONVERT(INT,RIGHT(@EntidadDebitar,4)) AND C1651=''1'' AND MONEDA=@Moneda);
			  IF (@V02 > 0)
		      BEGIN
		      		INSERT INTO dbo.ITF_DD_PRESENT_RECIB_RECHAZOS (ID_TICKET,  FECHAPROCESO, CODIGO_TRANSACCION, ENTIDAD_DEBITAR, CUENTA_DEBITAR, IMPORTE,  REFERENCIA_UNIVOCA, ID_CLIENTE_PAGADOR,  ESTADO,  CODIGO_ERROR, INFO_ADICIONAL)
       				VALUES (@TICKET, @FECHADATE, @CodTransaccion, @EntidadDebitar, @CuentaDebitar, @Importe,  @ReferenciaUnivoca, @IdClientePegador,  ''I'',  (SELECT CODIGO_NACHA FROM CLE_TIPO_CAUSAL WHERE CODIGO_DE_CAUSAL = 2),@InfoAdicional);
		      	GOTO Final
		      END
		      
		      
			  /* IMPORTE CERO R19 */	
			  IF ( @Importe = 0)
		      BEGIN
		      		INSERT INTO dbo.ITF_DD_PRESENT_RECIB_RECHAZOS (ID_TICKET,  FECHAPROCESO, CODIGO_TRANSACCION, ENTIDAD_DEBITAR, CUENTA_DEBITAR, IMPORTE,  REFERENCIA_UNIVOCA, ID_CLIENTE_PAGADOR,  ESTADO,  CODIGO_ERROR, INFO_ADICIONAL)
       				VALUES (@TICKET, @FECHADATE, @CodTransaccion, @EntidadDebitar, @CuentaDebitar, @Importe,  @ReferenciaUnivoca, @IdClientePegador,  ''I'',  (SELECT CODIGO_NACHA FROM CLE_TIPO_CAUSAL WHERE CODIGO_DE_CAUSAL = 34),@InfoAdicional);
		      	GOTO Final
		      END
		      
		       /*  orden de no pago o stop debit R08 */
			  DECLARE @V08 NUMERIC(2);
		      SET @V08 = (SELECT COUNT(*) FROM SNP_STOP_DEBIT WHERE FECHA_DESDE<=@FECHADATE AND FECHA_VENCIMIENTO>@FECHADATE AND SALDO_JTS_OID = (SELECT JTS_OID FROM SALDOS WHERE CUENTA = @NumCuenta AND SUCURSAL = CONVERT(INT,RIGHT(@EntidadDebitar,4)) AND MONEDA=@Moneda) );
				
			  IF (@V08 > 0)
		      BEGIN
		      		INSERT INTO dbo.ITF_DD_PRESENT_RECIB_RECHAZOS (ID_TICKET,  FECHAPROCESO, CODIGO_TRANSACCION, ENTIDAD_DEBITAR, CUENTA_DEBITAR, IMPORTE,  REFERENCIA_UNIVOCA, ID_CLIENTE_PAGADOR,  ESTADO,  CODIGO_ERROR, INFO_ADICIONAL)
       				VALUES (@TICKET, @FECHADATE, @CodTransaccion, @EntidadDebitar, @CuentaDebitar, @Importe,  @ReferenciaUnivoca, @IdClientePegador,  ''I'',  (SELECT CODIGO_NACHA FROM CLE_TIPO_CAUSAL WHERE CODIGO_DE_CAUSAL = 14),@InfoAdicional);
		      	GOTO Final
		      END
		       /*  Transaccion duplicada R24 */
			  DECLARE @V24 NUMERIC(2);
		      SET @V24 = (SELECT COUNT(*) FROM dbo.SNP_MSG_ORDENES WHERE CUENTA=@CuentaDebitar AND IMPORTE= @Importe AND REFERENCIA=@ReferenciaUnivoca AND FECHA_VENCIMIENTO=@FechaVencimiento AND FECHA_COMPENSACION=@FechaCompensacion AND MONEDA=@Moneda AND COD_CLIENTE_PAGADOR=@IdClientePegador);
				
			  IF (@V24 > 0)
		      BEGIN
		      		INSERT INTO dbo.ITF_DD_PRESENT_RECIB_RECHAZOS (ID_TICKET,  FECHAPROCESO, CODIGO_TRANSACCION, ENTIDAD_DEBITAR, CUENTA_DEBITAR, IMPORTE,  REFERENCIA_UNIVOCA, ID_CLIENTE_PAGADOR,  ESTADO,  CODIGO_ERROR, INFO_ADICIONAL)
       				VALUES (@TICKET, @FECHADATE, @CodTransaccion, @EntidadDebitar, @CuentaDebitar, @Importe,  @ReferenciaUnivoca, @IdClientePegador,  ''I'',  (SELECT CODIGO_NACHA FROM CLE_TIPO_CAUSAL WHERE CODIGO_DE_CAUSAL = 36),@InfoAdicional);
		      	GOTO Final
		      END
		      
		      
		       /*  Código de Banco incompatible con moneda R91 */

			  IF((LEFT(@EntidadDebitar,4)=''0311'' AND LEFT(@InfoAdicional,1)<>0) OR (LEFT(@EntidadDebitar,4)=''0811'' AND LEFT(@InfoAdicional,1)<>1))
		      BEGIN
		      		INSERT INTO dbo.ITF_DD_PRESENT_RECIB_RECHAZOS (ID_TICKET,  FECHAPROCESO, CODIGO_TRANSACCION, ENTIDAD_DEBITAR, CUENTA_DEBITAR, IMPORTE,  REFERENCIA_UNIVOCA, ID_CLIENTE_PAGADOR,  ESTADO,  CODIGO_ERROR, INFO_ADICIONAL)
       				VALUES (@TICKET, @FECHADATE, @CodTransaccion, @EntidadDebitar, @CuentaDebitar, @Importe,  @ReferenciaUnivoca, @IdClientePegador,  ''I'',  (SELECT CODIGO_NACHA FROM CLE_TIPO_CAUSAL WHERE CODIGO_DE_CAUSAL = 74),@InfoAdicional);
		      	GOTO Final
		      END
		      
		      /*  cuenta a debitar no cuenta con dinero suficiente R10*/

		      IF (@Importe > (SELECT (C1604+C1605+C1683+C2627+C50107) FROM SALDOS WHERE CUENTA = @NumCuenta AND SUCURSAL = CONVERT(INT,RIGHT(@EntidadDebitar,4)) AND MONEDA=@Moneda))
		      BEGIN
		      		INSERT INTO dbo.ITF_DD_PRESENT_RECIB_RECHAZOS (ID_TICKET,  FECHAPROCESO, CODIGO_TRANSACCION, ENTIDAD_DEBITAR, CUENTA_DEBITAR, IMPORTE,  REFERENCIA_UNIVOCA, ID_CLIENTE_PAGADOR,  ESTADO,  CODIGO_ERROR, INFO_ADICIONAL)
       				VALUES (@TICKET, @FECHADATE, @CodTransaccion, @EntidadDebitar, @CuentaDebitar, @Importe,  @ReferenciaUnivoca, @IdClientePegador,  ''I'',  (SELECT CODIGO_NACHA FROM CLE_TIPO_CAUSAL WHERE CODIGO_DE_CAUSAL = 15),@InfoAdicional);
		      	GOTO Final
		      END
		      
		      
		      
		SET @correlativo = @correlativo +1;
		DECLARE @Cod_Cliente NUMERIC(16,0);
		DECLARE @Tipo_Documento VARCHAR(4);
		DECLARE @Nro_Documento NUMERIC(15,0);
		SET @Cod_Cliente = (SELECT C1803 FROM SALDOS WHERE CUENTA = @NumCuenta AND SUCURSAL = CONVERT(INT,RIGHT(@EntidadDebitar,4)));
		SELECT @Tipo_Documento=TIPODOCUMENTO, @Nro_Documento=NUMERODOCUMENTO FROM CLI_DocumentosPFPJ WHERE NUMEROPERSONAFJ = (SELECT TOP 1 NUMEROPERSONA FROM CLI_ClientePersona WHERE CODIGOCLIENTE=@Cod_Cliente AND ((TZ_LOCK < 300000000000000 OR TZ_LOCK >= 400000000000000) AND (TZ_LOCK < 100000000000000 OR TZ_LOCK >= 200000000000000)))
		INSERT INTO dbo.SNP_MSG_ORDENES (ID_ARCHIVO, NRO_ARCHIVO, CORRELATIVO, DEBITO_TRANSFERENCIA, INFO_ADICIONAL, CODIGO_CLIENTE,COD_CLIENTE_PAGADOR, FECHA_VENCIMIENTO, FECHA_COMPENSACION,REFERENCIA, CUENTA, MONEDA, IMPORTE, TIPO_DOCUMENTO, NRO_DOCUMENTO, FECHA_ASIENTO, NUMERO_ASIENTO, TIPO_ORDEN )
		VALUES (@TICKET,@NroArchivo,@correlativo,''DB'',@InfoAdicional, @Cod_Cliente, @IdClientePegador,@FechaVencimiento,@FechaCompensacion,@ReferenciaUnivoca, @CuentaDebitar,@Moneda, @Importe, @Tipo_Documento, @Nro_Documento, @FECHADATE, @TICKET,''DEBREC'')
		

		END
		

		Final:
		FETCH NEXT FROM deb_cursor INTO @LINEA
	END

	CLOSE deb_cursor
	DEALLOCATE deb_cursor

END;


')

EXECUTE('

DELETE FROM dbo.ITF_MASTER WHERE ID = 104;

INSERT INTO dbo.ITF_MASTER (TZ_LOCK, ID, DESCRIPCION, OBJ_KETTLE, P0_MODO, P0_TIPO, P0_CAPTION, P0_CONSTANTE, P1_MODO, P1_TIPO, P1_CAPTION, P1_CONSTANTE, P2_MODO, P2_TIPO, P2_CAPTION, P2_CONSTANTE, P3_MODO, P3_TIPO, P3_CAPTION, P3_CONSTANTE, P4_MODO, P4_TIPO, P4_CAPTION, P4_CONSTANTE, P5_MODO, P5_TIPO, P5_CAPTION, P5_CONSTANTE, P6_MODO, P6_TIPO, P6_CAPTION, P6_CONSTANTE, P7_MODO, P7_TIPO, P7_CAPTION, P7_CONSTANTE, P8_MODO, P8_TIPO, P8_CONSTANTE, P8_CAPTION, P9_MODO, P9_TIPO, P9_CAPTION, P9_CONSTANTE, TIPO_OBJ, COMENTARIO, ID_REPORTE, MODO_EJECUCION)
VALUES (0, 104, ''Debitos Directos Presentados Recibidos'', ''ITF_COELSA_DEB_DIRECTOS_PRESENTADOS_RECIBIDOS.kjb'', '''', '''', '''', '' '', '''', '''', '''', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', ''J'', '' '', 0, ''M'')

')