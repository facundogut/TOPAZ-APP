execute('
CREATE OR ALTER PROCEDURE [SP_DD_PRESENTADOS_RECIBIDOS]
	@TICKET NUMERIC(16),
	@MSJ 	VARCHAR(500) OUTPUT
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
	DECLARE @VFechaVencimientoCA VARCHAR(6);
	DECLARE @FechaVencimientoCA DATE;
	DECLARE @FechaPresentacion VARCHAR(6);
	
	
	/******** Variables Registro Adicional **********************************/
	DECLARE @FechaVencimientoRA DATE;
	DECLARE @VFechaVencimientoRA VARCHAR(6);
	DECLARE @TraceNumberRA VARCHAR(15);
	DECLARE @MotivoReversaRA VARCHAR(3);
	
	/******** Variables Cabecera de Lote **********************************/
	DECLARE @FechaVencimiento DATE;
	DECLARE @FechaCompensacion DATE;
	DECLARE @VFechaVencimiento VARCHAR(6);
	DECLARE @VFechaCompensacion VARCHAR(6);
	DECLARE @ClaseTransaccion VARCHAR(3);
	DECLARE @ReservadoLote VARCHAR(46);
	DECLARE @ReservadoLoteCeros NUMERIC(3);
	DECLARE @CodigoRegistro VARCHAR(3);
	DECLARE @IdEntidadOrigen NUMERIC(8);
	declare @NumeroLote NUMERIC(7);
	DECLARE @IdentificacionEI NUMERIC(10); --OPH 05012024
	DECLARE @DigitoV NUMERIC(1);--OPH 05012024
	DECLARE @VPrestacion VARCHAR(10); --OPH 07012024
	DECLARE @VCod_Ent_Originante VARCHAR(4); --OPH 08012024
	DECLARE @VCod_Suc_Originante VARCHAR(4); --OPH 08012024
	DECLARE @NOM_EMPRESA VARCHAR(16);
	DECLARE @INFO_DISCRECIONAL VARCHAR(20);

	/******** Variables Registro Individual de Cheques y Ajustes *************/
	DECLARE @CodTransaccion VARCHAR(2);
	DECLARE @EntidadDebitar VARCHAR(8);
	DECLARE @ReservadoRI VARCHAR(1);
	DECLARE @CuentaDebitar VARCHAR(17);
	DECLARE @VImporte VARCHAR(16);   
	DECLARE @Importe NUMERIC(15,2) = 0;     
	DECLARE @ReferenciaUnivoca VARCHAR(15);
	DECLARE @IdClientePegador VARCHAR(22);
	DECLARE @InfoAdicional VARCHAR(2);
	DECLARE @RegistrosAdicionales VARCHAR(1);
	DECLARE @ContadorRegistros VARCHAR(15);
	DECLARE @CodigoOrigen  NUMERIC(2); --OPH 07012024
	DECLARE @Cod_Ent_Destino VARCHAR(4); --OPH 08012024
	DECLARE @Cod_Suc_Destino VARCHAR(4); --OPH 08012024

	DECLARE @CodRechazo VARCHAR (2);

	--SE VAN A USAR ESTOS CAMPOS COMO CLAVE EN LUGAR DEL TRACENUMBER  
	
	DECLARE @Entidad_RI VARCHAR(4);	-- SE CAMBIA TIPO A VARCHAR PORQUE AHORA NO SE VALIDA MAS EL REG INDIVIDUAL
	DECLARE @Sucursal_RI VARCHAR(4); -- SE CAMBIA TIPO A VARCHAR PORQUE AHORA NO SE VALIDA MAS EL REG INDIVIDUAL
	DECLARE @IdClientePegador_RI VARCHAR(4); -- SE CAMBIA TIPO A VARCHAR PORQUE AHORA NO SE VALIDA MAS EL REG INDIVIDUAL
	DECLARE @NumeroCuenta_RI VARCHAR(12); -- SE CAMBIA TIPO A VARCHAR PORQUE AHORA NO SE VALIDA MAS EL REG INDIVIDUAL
	DECLARE @ReferenciaUnivoca_RI VARCHAR(12); -- SE CAMBIA TIPO A VARCHAR PORQUE AHORA NO SE VALIDA MAS EL REG INDIVIDUAL

	DECLARE @ExisteRI NUMERIC(1) = 0; --para saber si hay al menos 1 lote
	
	/******** Variables FIN DE LOTE *************/


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
	
	BEGIN TRY
	
	------------Inicio Primera Validacion ----------------
	
	IF(0=(SELECT COUNT(1) FROM ITF_DD_PRESENTADOS_RECIBIDOS_AUX WITH (NOLOCK)
	WHERE LINEA LIKE ''1%''))
	BEGIN
	  SET @MSJ = ''Error - Falta registro Cabecera de Archivo'';
	  RETURN
	END
	
	IF(0=(SELECT COUNT(1) FROM ITF_DD_PRESENTADOS_RECIBIDOS_AUX WITH (NOLOCK)
	WHERE LINEA LIKE ''5%''))
	BEGIN
	  SET @MSJ = ''Error - Falta registro Cabecera de Lote.'';
	  RETURN
	END
	
	IF(0=(SELECT COUNT(1) FROM ITF_DD_PRESENTADOS_RECIBIDOS_AUX WITH (NOLOCK)
	WHERE LINEA LIKE ''8%''))
	BEGIN
	  SET @MSJ = ''Error - Falta registro Control Fin de Lote.'';
	  RETURN
	END
	
	IF(0=(SELECT COUNT(1) FROM ITF_DD_PRESENTADOS_RECIBIDOS_AUX WITH (NOLOCK)
	WHERE LINEA LIKE ''9%''))
	BEGIN
	  SET @MSJ = ''Error - Falta registro Control Fin de Archivo.'';
	  RETURN
	END
	
	IF ((SELECT COUNT(1) FROM ITF_DD_PRESENTADOS_RECIBIDOS_AUX WITH (NOLOCK)
		WHERE SUBSTRING(LINEA,1,1) NOT IN(''1'',''5'',''6'',''7'',''8'',''9'')) > 0) --validacion de id reg
  	BEGIN
  	  SET @MSJ = ''Id Registro invalido'';
	  RETURN
    END

	--#validacion2
	IF ((SELECT COUNT(1)
	FROM ITF_DD_PRESENTADOS_RECIBIDOS_AUX WITH (NOLOCK)
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
		FROM ITF_DD_PRESENTADOS_RECIBIDOS_AUX WITH (NOLOCK)
		WHERE ID IN
	(SELECT ID-1
			FROM ITF_DD_PRESENTADOS_RECIBIDOS_AUX WITH (NOLOCK)
			WHERE LINEA LIKE ''8%'')
			AND CONVERT(INT,SUBSTRING(LINEA,1,1)) NOT IN (5,6,7)
	))
		OR 1=(
	SELECT count(1)
		WHERE
	EXISTS
	(SELECT CONVERT(INT,SUBSTRING(LINEA,1,1))
		FROM ITF_DD_PRESENTADOS_RECIBIDOS_AUX WITH (NOLOCK)
		WHERE ID IN
	(SELECT ID+1
			FROM ITF_DD_PRESENTADOS_RECIBIDOS_AUX WITH (NOLOCK)
			WHERE LINEA LIKE ''8%'')
			AND CONVERT(INT,SUBSTRING(LINEA,1,1)) NOT IN (5,9)
	))
		OR 1=(
	SELECT count(1)
		WHERE
	EXISTS
	(SELECT CONVERT(INT,SUBSTRING(LINEA,1,1))
		FROM ITF_DD_PRESENTADOS_RECIBIDOS_AUX WITH (NOLOCK)
		WHERE ID IN
	(SELECT ID-1
			FROM ITF_DD_PRESENTADOS_RECIBIDOS_AUX WITH (NOLOCK)
			WHERE LINEA LIKE ''5%'')
			AND CONVERT(INT,SUBSTRING(LINEA,1,1)) NOT IN (1,8)
	))
		OR 1=(
	SELECT count(1)
		WHERE
	EXISTS
	(SELECT CONVERT(INT,SUBSTRING(LINEA,1,1))
		FROM ITF_DD_PRESENTADOS_RECIBIDOS_AUX WITH (NOLOCK)
		WHERE ID IN
	(SELECT ID+1
			FROM ITF_DD_PRESENTADOS_RECIBIDOS_AUX WITH (NOLOCK)
			WHERE LINEA LIKE ''5%'')
			AND CONVERT(INT,SUBSTRING(LINEA,1,1)) NOT IN (6,7,8)
	))) <> 0
	)
	BEGIN
	  SET @MSJ = ''El orden de los registros NACHA es incorrecto'';
	  RETURN
	END

	
	IF (SELECT COUNT(1)
			FROM ITF_DD_PRESENTADOS_RECIBIDOS_AUX WITH (NOLOCK)
			WHERE LINEA LIKE ''5%'') <> (SELECT COUNT(1)
			FROM ITF_DD_PRESENTADOS_RECIBIDOS_AUX WITH (NOLOCK)
			WHERE LINEA LIKE ''8%'')
	BEGIN
	  SET @MSJ = ''Nro de Registros de Cabecera de Lote es distinto al Final de Lote'';
	  RETURN
	END 
	
	IF( (SELECT COUNT(1) FROM ITF_DD_PRESENTADOS_RECIBIDOS_AUX WITH (NOLOCK)
		 WHERE LEN(LINEA) <> 94) > 0)
	BEGIN
	  SET @MSJ = ''Existe(n) fila(s) con longitud incorrecta'';
	  RETURN
	END 
	------validaciones #5 #6 #7 y #8
	
	IF ((select count(1)
		FROM ITF_DD_PRESENTADOS_RECIBIDOS_AUX WITH (NOLOCK)
		WHERE LINEA LIKE ''6%''
		  AND IsNumeric(substring(LINEA, 30, 10)) = 0) > 0)
--        AND IsNumeric(substring(LINEA, 61, 16)) = 0) > 0) Se modifica, ¿es por el formato nuevo? En el nuevo va desde la pos 26 y no desde la 61 A.E 10/10/2024
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
	
	DECLARE @ID_Empresa VARCHAR(10);
	DECLARE @ID_Empresa_digitoV VARCHAR(1);

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
--s		@sumaDebitos_RI = sum(CAST(substring(LINEA, 61, 16) AS NUMERIC)), Se modifica, ¿es por el formato nuevo? En el nuevo va desde la pos 26 y no desde la 61 A.E 10/10/2024
		@sumaEntidades_RI = sum(CAST(substring(LINEA, 4, 4) AS NUMERIC)),
		@sumaSucursales_RI = sum(CAST(substring(LINEA, 8, 4) AS NUMERIC))
	FROM ITF_DD_PRESENTADOS_RECIBIDOS_AUX WITH (NOLOCK)
	WHERE LINEA LIKE ''6%''

	SET @sumaEntidades_RI += isNull(@sumaEntidades_RIaux,0);
	SET @sumaSucursales_RI += isNull(@sumaSucursales_RIaux,0);
	
	--seteo total control y total de importes FA
	SELECT
		@totControl_FA = CAST(substring(linea, 22, 10) AS NUMERIC),
		@totalDebitos_FA = CAST(substring(linea, 32, 12) AS NUMERIC), -- Se vuelve a formato anterior A.E 10/10/2024
		@totalCreditos_FA = CAST(substring(linea, 44, 12) AS NUMERIC) -- Se vuelve a formato anterior A.E 10/10/2024
--s		@totalDebitos_FA = CAST(substring(linea, 32, 20) AS NUMERIC),
--s		@totalCreditos_FA = CAST(substring(linea, 52, 20) AS NUMERIC)
	FROM ITF_DD_PRESENTADOS_RECIBIDOS_AUX WITH (NOLOCK)
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
		@controlDebitos_FL = sum(CAST(substring(LINEA, 21, 12) AS NUMERIC)), -- Se vuelve a formato anterior A.E 10/10/2024
		@controlCreditos_FL = sum(CAST(substring(LINEA, 33, 12) AS NUMERIC)) -- Se vuelve a formato anterior A.E 10/10/2024
--s		@controlDebitos_FL = sum(CAST(substring(LINEA, 21, 20) AS NUMERIC)),
--s		@controlCreditos_FL = sum(CAST(substring(LINEA, 41, 20) AS NUMERIC))
	FROM ITF_DD_PRESENTADOS_RECIBIDOS_AUX WITH (NOLOCK)
	WHERE LINEA LIKE ''8%'';
	
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
	DECLARE @ID int;
	
	DECLARE @NroArchivo NUMERIC(15,0)
	
	DECLARE deb_cursor CURSOR FOR 
	SELECT ID, LINEA
	FROM dbo.ITF_DD_PRESENTADOS_RECIBIDOS_AUX WITH (NOLOCK)
	ORDER BY id

	OPEN deb_cursor

	FETCH NEXT FROM deb_cursor INTO @ID, @LINEA

	WHILE @@FETCH_STATUS = 0  
	BEGIN

		SET @NroArchivo = (SELECT ISNULL(MAX(ID_DEBITO),0) FROM dbo.SNP_DEBITOS WITH (NOLOCK))+1;
		
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
			SET @FechaPresentacion = substring(@LINEA, 24, 6); --OPH 09012024


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
			IF(substring(@DestinoInmediato, 2, 4) <> ''0311'')
			BEGIN
				SET @MSJ = ''Destino inmediato debe ser 0311'';
				RETURN
			END
			
			IF LTRIM(@VFechaVencimientoCA) = '''' OR @VFechaVencimientoCA IS NULL
			BEGIN
				SET @MSJ =  ''Fecha Presentación es obligatorio'';
				RETURN;
			END
			--OPH25102023
		END

		IF (@IdRegistro = ''5'') 
      BEGIN

			--variables cabecera de lote
			SET @ClaseTransaccion = substring(@LINEA, 2, 3);
			SET @ReservadoLote = substring(@LINEA, 5, 46);
			--VALIDACION RESERVADO VACIO
			SET @CodigoRegistro = substring(@LINEA, 51, 3);

			SET @VFechaVencimiento = substring(@LINEA, 64, 6);
			
			
			SET @ID_Empresa=substring(@LINEA, 41, 10);
			SET @ID_Empresa_digitoV=substring(@LINEA, 79, 1);
			--VALIDACION FECHAS
			SET @VFechaCompensacion = substring(@LINEA, 70, 6);

			SET @IdEntidadOrigen = substring(@LINEA, 80, 8);

			SET @NumeroLote = substring(@LINEA, 88, 7);
			
			--OPH 05012024
			SET @IdentificacionEI = substring(@LINEA, 41, 10);
			SET @DigitoV = substring(@LINEA, 79, 1);
			SET @VPrestacion = substring(@LINEA, 54, 10);
			SET @VCod_Ent_Originante = substring(@LINEA, 80, 4);
			SET @VCod_Suc_Originante = substring(@LINEA, 84, 4);
			SET @NOM_EMPRESA= substring(@LINEA, 5, 16);
			SET @INFO_DISCRECIONAL= SUBSTRING(@LINEA, 21, 20);
			--

			IF (@ClaseTransaccion <> ''200'') 
			BEGIN
				SET @MSJ = ''Codigo de clase de transaccion debe ser 200'' ;
				RETURN
			END

			IF (@CodigoRegistro <> ''PPD'') 
			BEGIN
				SET @MSJ =  ''Codigo de registro debe ser PPD'';
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
			SET @ReservadoFL = substring(@LINEA, 45, 35); -- Se vuelve a formato anterior
--s			SET @ReservadoFL = substring(@LINEA, 61, 19);
			SET @IdEntidadOrigen = substring(@LINEA, 80, 8);
			SET @NumeroLote = substring(@LINEA, 88, 7);


			IF (@ClaseTransaccion <> ''200'') 
			BEGIN
				SET @MSJ =  ''Codigo de clase de transaccion debe ser 200'';
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
			SET @ReservadoFA  = substring(@LINEA, 56, 39); -- Se vuelve a formato anterior
--s			SET @ReservadoFA  = substring(@LINEA, 72, 23);

			--#validacion9
			IF(@ExisteRI = 1 AND (SELECT COUNT(1) FROM ITF_DD_PRESENTADOS_RECIBIDOS_AUX WITH (NOLOCK) WHERE LINEA LIKE ''5%'') <> @CantLotesFA)
			BEGIN
				SET @MSJ = ''No coincide la cantidad de LOTES con la informada en el reg FA'';
				RETURN
			END
			
			--#validacion10
			IF((SELECT COUNT(1) FROM ITF_DD_PRESENTADOS_RECIBIDOS_AUX WITH (NOLOCK) WHERE LINEA LIKE ''6%'' OR LINEA LIKE ''7%'') <> @CantRegAdFA)
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
			SET @VImporte = substring(@LINEA, 30, 10); -- Se vuelve a formato anterior
--s			SET @VImporte = substring(@LINEA, 61, 16); 

			--SET @Importe = CONVERT(NUMERIC(15,2),substring(@LINEA, 30, 10))/100;
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
			--OPH 07012024
			SET @CodigoOrigen = substring(@LINEA, 2, 2);
			SET @Cod_Ent_Destino = substring(@LINEA, 4, 4);
			SET @Cod_Suc_Destino = substring(@LINEA, 8, 4);
			--
			--#validacion de codigo de transaccion
			IF (@CodTransaccion NOT IN(''36'',''37'',''31'',''32'',''38'')) 
			BEGIN
--				PRINT @CodTransaccion
--			PRINT @LINEA
				SET @MSJ = ''El tipo de transaccion no esta permitida'';
				RETURN
			END	
			
			IF (@CodTransaccion  =''38'') 
			BEGIN			
				SET @VImporte=0
--				PRINT @linea 
			END
			
			

			IF (@RegistrosAdicionales NOT IN(''1'',''0'')) 
      		BEGIN
      			SET @MSJ =  ''Campo Registro adicional invalido'';
				RETURN
			END
	 
	
	------------Fin Primera Validacion ----------------
	 	
	IF(@TICKET>0)
	
	BEGIN
	
	
			/*Registro Adicional*/
		IF (@IdRegistro = ''6'' AND @RegistrosAdicionales=''1'') 
		BEGIN
			SELECT @FechaVencimientoRA = try_convert(DATE, substring(linea,4,6),12)
				    , @TraceNumberRA = substring(linea,10,15)
				    , @MotivoReversaRA = substring(linea,30,3)
			from ITF_DD_PRESENTADOS_RECIBIDOS_AUX WITH (NOLOCK)
			WHERE id=@id+1
			AND substring(linea,1,3)=''705''		
		END
	
	
	
			  DECLARE @V04 NUMERIC(2);
	      DECLARE @NumCuenta NUMERIC(20);
	      DECLARE @Moneda INT;

		DECLARE @CUIT_EO NUMERIC(11,0);
		DECLARE @PRESTACION VARCHAR(10);
		DECLARE @CTA_CBU VARCHAR(22);


   	      DECLARE @MonedaCta NUMERIC(2);
	      DECLARE @TipoCuenta VARCHAR(2);
	      --DECLARE @NroCuenta NUMERIC(11);
		  DECLARE @Cod_Cliente NUMERIC(20);
		  DECLARE @saldo_jts_oid NUMERIC(15);
	      
	      --SET @NumCuenta = CAST(@CuentaDebitar AS NUMERIC);
--	      SET @NumCuenta = CAST(SUBSTRING(@CuentaDebitar,6,11) AS NUMERIC);
	      SET @NumCuenta = CAST(LEFT(RIGHT(@CuentaDebitar,12),11) AS NUMERIC);
	      SET @TipoCuenta = SUBSTRING(@CuentaDebitar,4,2);
	      
	      --SELECT @TipoCuenta AS ''TipoCuenta'' OMAR
	      
	      SELECT @MonedaCta = MONEDA,
	      	@Cod_Cliente = C1803,
			@saldo_jts_oid = JTS_OID
	      FROM SALDOS WITH (NOLOCK)
	      WHERE CUENTA = @NumCuenta 
	        AND SUCURSAL = CONVERT(INT,RIGHT(@EntidadDebitar,4))
	        --AND C1785 = @TipoCuenta
	        AND C1785 = (CASE WHEN @TipoCuenta = ''11'' OR @TipoCuenta = ''15'' THEN 3 
	        				  WHEN @TipoCuenta = ''01'' OR @TipoCuenta = ''07'' THEN 2
	        			 END)
            AND MONEDA = (CASE WHEN @TipoCuenta = ''11'' OR @TipoCuenta = ''01'' THEN 1 
            				   WHEN @TipoCuenta = ''15'' OR @TipoCuenta = ''07'' THEN 2 END)
	        AND TZ_LOCK = 0;	
	
	
	

	
	
	
	 SET @CUIT_EO = CONCAT(isnull(@IdentificacionEI,0),isnull(@DigitoV,0))
	
	
	
	DECLARE @Temp INT;
	DECLARE @E01 INT;


	SET @Temp = (CONVERT(INT, SUBSTRING(@EntidadDebitar, 2, 1)) * 7 +
	             CONVERT(INT, SUBSTRING(@EntidadDebitar, 3, 1)) * 1 +
	             CONVERT(INT, SUBSTRING(@EntidadDebitar, 4, 1)) * 3 +
	             CONVERT(INT, SUBSTRING(@EntidadDebitar, 5, 1)) * 9 +
	             CONVERT(INT, SUBSTRING(@EntidadDebitar, 6, 1)) * 7 +
	             CONVERT(INT, SUBSTRING(@EntidadDebitar, 7, 1)) * 1 +
	             CONVERT(INT, SUBSTRING(@EntidadDebitar, 8, 1)) * 3) % 10;


	SET @E01 = (10 - @Temp) % 10;
		SET @CTA_CBU=concat(RIGHT(@EntidadDebitar,7),convert(VARCHAR(1),@E01),RIGHT(@CuentaDebitar,14))

	

	
	IF @MonedaCta IS NULL
  	BEGIN
  		SET @MonedaCta=1;
  	END
  		  
		  DECLARE @FECHADATE DATETIME;
		  SET @FECHADATE = (SELECT FECHAPROCESO FROM PARAMETROS WITH (NOLOCK));
		  
	      ----------------------- VALIDACIONES INCLUYENTES------------------------
	      ------------------------------------------------------------------------	
		  --------------
		  ----NACHA R03
		  --------------
		  IF @saldo_jts_oid IS NULL AND NOT ((@CodTransaccion=''37'' AND @InfoAdicional = ''01'') OR @CodTransaccion=''38'')
		  BEGIN
	      		INSERT INTO dbo.ITF_DD_PRESENT_RECIB_RECHAZOS (ID_TICKET,
	      														 TRACENUMBER , 
	      													   FECHAPROCESO, 
	      													   CODIGO_TRANSACCION, 
	      													   ENTIDAD_DEBITAR, 
	      													   CUENTA_DEBITAR, 
	      													   IMPORTE,  
	      													   REFERENCIA_UNIVOCA, 
	      													   ID_CLIENTE_PAGADOR,  
	      													   ESTADO,  
	      													   CODIGO_ERROR, 
	      													   INFO_ADICIONAL,
	      													   
	      													   MONEDA,
	      													   cliente_pagador,
	      													   SALDO_JTS_OID,
	      													   fecha_vto,
	      													   fecha_comp,
	      													   cbu,
	      													   referencia,
	      													   cuit_eo,
	      													   
	      													   prestacion,NOMBRE_EO,COD_ENT_ORIGINANTE,COD_SUC_ORIGINANTE,COD_ENT_DESTINO,COD_SUC_DESTINO,FECHA_PRESENTACION
	      													   )
													   VALUES (@TICKET, @ContadorRegistros,
													   		   @FECHADATE, 
													   		   @CodTransaccion, 
													   		   @EntidadDebitar, 
													   		   @CuentaDebitar, 
													   		   @VImporte,  
													   		   @ReferenciaUnivoca, 
													   		   @IdClientePegador,  
													   		   ''I'',  
													   		   28,
													   		   @InfoAdicional,
													   		   
													   		   @MonedaCta,
													   		   @IdClientePegador,
													   		   @saldo_jts_oid,
													   		   @FechaVencimiento,
													   		   @FechaCompensacion,
													   		   @CTA_CBU,
													   		   @ReferenciaUnivoca,
													   		   @CUIT_EO,
													   		   
													   		   @VPRESTACION,@NOM_EMPRESA,@VCod_Ent_Originante,@VCod_Suc_Originante,@Cod_Ent_Destino,@Cod_Suc_Destino,convert(DATE,@FechaPresentacion)
													   		   );
	      	GOTO Final
		  END 
		  --------------
		  ----NACHA R02
		  --------------
	      DECLARE @v_esta_bloqueada_cuenta_destino NUMERIC(2)= 0;
	      
	      SELECT @v_esta_bloqueada_cuenta_destino = count(1)
	      FROM SALDOS WITH (NOLOCK)
	      WHERE JTS_OID = @saldo_jts_oid AND C1651 = ''1'' AND TZ_LOCK = 0;
	      
	      IF @v_esta_bloqueada_cuenta_destino > 0 
		  BEGIN
	      		INSERT INTO dbo.ITF_DD_PRESENT_RECIB_RECHAZOS (ID_TICKET,
	      														 TRACENUMBER , 
	      													   FECHAPROCESO, 
	      													   CODIGO_TRANSACCION, 
	      													   ENTIDAD_DEBITAR, 
	      													   CUENTA_DEBITAR, 
	      													   IMPORTE,  
	      													   REFERENCIA_UNIVOCA, 
	      													   ID_CLIENTE_PAGADOR,  
	      													   ESTADO,  
	      													   CODIGO_ERROR, 
	      													   INFO_ADICIONAL,
	      													   
	      													   MONEDA,
	      													   cliente_pagador,
	      													   SALDO_JTS_OID,
	      													   fecha_vto,
	      													   fecha_comp,
	      													   cbu,
	      													   referencia,
	      													   cuit_eo,
	      													   
	      													   prestacion,NOMBRE_EO,COD_ENT_ORIGINANTE,COD_SUC_ORIGINANTE,COD_ENT_DESTINO,COD_SUC_DESTINO,FECHA_PRESENTACION
	      													   )
													   VALUES (@TICKET, @ContadorRegistros,
													   		   @FECHADATE, 
													   		   @CodTransaccion, 
													   		   @EntidadDebitar, 
													   		   @CuentaDebitar, 
													   		   @VImporte,  
													   		   @ReferenciaUnivoca, 
													   		   @IdClientePegador,  
													   		   ''I'',  
													   		   27,
													   		   @InfoAdicional,
													   		   
													   		   @MonedaCta,
													   		   @IdClientePegador,
													   		   @saldo_jts_oid,
													   		   @FechaVencimiento,
													   		   @FechaCompensacion,
													   		   @CTA_CBU,
													   		   @ReferenciaUnivoca,
													   		   @CUIT_EO,
													   		   
													   		   @VPRESTACION,@NOM_EMPRESA,@VCod_Ent_Originante,@VCod_Suc_Originante,@Cod_Ent_Destino,@Cod_Suc_Destino,convert(DATE,@FechaPresentacion)
													   		   );
	      	GOTO Final
		  END 	
		  --------------
		  ----NACHA R17
		  --------------

		  IF ISNUMERIC(@CodTransaccion) = 0 or ISNUMERIC(@EntidadDebitar) = 0  OR ISNUMERIC(@ReservadoRI) = 0 OR ISNUMERIC(@CuentaDebitar) = 0
			 OR ISNUMERIC(@InfoAdicional) = 0 OR ISNUMERIC(@RegistrosAdicionales) = 0 OR ISNUMERIC(@ContadorRegistros) = 0
	      BEGIN
	      		INSERT INTO dbo.ITF_DD_PRESENT_RECIB_RECHAZOS (ID_TICKET,
	      														 TRACENUMBER , 
	      													   FECHAPROCESO, 
	      													   CODIGO_TRANSACCION, 
	      													   ENTIDAD_DEBITAR, 
	      													   CUENTA_DEBITAR, 
	      													   IMPORTE,  
	      													   REFERENCIA_UNIVOCA, 
	      													   ID_CLIENTE_PAGADOR,  
	      													   ESTADO,  
	      													   CODIGO_ERROR, 
	      													   INFO_ADICIONAL,
	      													   
	      													   MONEDA,
	      													   cliente_pagador,
	      													   SALDO_JTS_OID,
	      													   fecha_vto,
	      													   fecha_comp,
	      													   cbu,
	      													   referencia,
	      													   cuit_eo,
	      													   
	      													   prestacion,NOMBRE_EO,COD_ENT_ORIGINANTE,COD_SUC_ORIGINANTE,COD_ENT_DESTINO,COD_SUC_DESTINO,FECHA_PRESENTACION
	      													   )
													   VALUES (@TICKET, @ContadorRegistros,
													   		   @FECHADATE, 
													   		   @CodTransaccion, 
													   		   @EntidadDebitar, 
													   		   @CuentaDebitar, 
													   		   @VImporte,  
													   		   @ReferenciaUnivoca, 
													   		   @IdClientePegador,  
													   		   ''I'',  
													   		   33,
													   		   @InfoAdicional,
													   		   
													   		   @MonedaCta,
													   		   @IdClientePegador,
													   		   @saldo_jts_oid,
													   		   @FechaVencimiento,
													   		   @FechaCompensacion,
													   		   @CTA_CBU,
													   		   @ReferenciaUnivoca,
													   		   @CUIT_EO,
													   		   
													   		   @VPRESTACION,@NOM_EMPRESA,@VCod_Ent_Originante,@VCod_Suc_Originante,@Cod_Ent_Destino,@Cod_Suc_Destino,convert(DATE,@FechaPresentacion)
													   		   );
	      	GOTO Final
	      END

--s		  SET @Importe =  CONVERT(NUMERIC(15,2),@VImporte)/100;
          SET @Importe =   convert(NUMERIC(15,2),(convert(NUMERIC(16),@VImporte)/100));
		 			
		  --------------
		  ----NACHA R93
		  --------------
		  
		  DECLARE @V93 NUMERIC(2);
	      DECLARE @FechaPro VARCHAR(10);
	      
	      SET @FechaPro = CONVERT(VARCHAR(10),(SELECT FECHAPROCESO FROM PARAMETROS WITH (NOLOCK)),103);
	      SET @V93 = (SELECT COUNT(1) FROM FERIADOS WITH (NOLOCK) WHERE (SUCURSAL=CONVERT(INT,RIGHT(@EntidadDebitar,4)) OR SUCURSAL=-1) AND DIA=FORMAT(@FECHADATE,''dd'') AND MES=FORMAT(@FECHADATE,''MM'') AND (ANIO=FORMAT(@FECHADATE,''yyyy'') OR ANIO=0)); 
	      
	      IF (@V93 > 0)
	      BEGIN
	     			      		INSERT INTO dbo.ITF_DD_PRESENT_RECIB_RECHAZOS (ID_TICKET, 
	     			      										 TRACENUMBER ,
	      													   FECHAPROCESO, 
	      													   CODIGO_TRANSACCION, 
	      													   ENTIDAD_DEBITAR, 
	      													   CUENTA_DEBITAR, 
	      													   IMPORTE,  
	      													   REFERENCIA_UNIVOCA, 
	      													   ID_CLIENTE_PAGADOR,  
	      													   ESTADO,  
	      													   CODIGO_ERROR, 
	      													   INFO_ADICIONAL,
	      													   
	      													   MONEDA,
	      													   cliente_pagador,
	      													   SALDO_JTS_OID,
	      													   fecha_vto,
	      													   fecha_comp,
	      													   cbu,
	      													   referencia,
	      													   cuit_eo,
	      													   
	      													   prestacion,NOMBRE_EO,COD_ENT_ORIGINANTE,COD_SUC_ORIGINANTE,COD_ENT_DESTINO,COD_SUC_DESTINO,FECHA_PRESENTACION
	      													   )
													   VALUES (@TICKET, @ContadorRegistros,
													   		   @FECHADATE, 
													   		   @CodTransaccion, 
													   		   @EntidadDebitar, 
													   		   @CuentaDebitar, 
													   		   @VImporte,  
													   		   @ReferenciaUnivoca, 
													   		   @IdClientePegador,  
													   		   ''I'',  
													   		   45,
													   		   @InfoAdicional,
													   		   
													   		   @MonedaCta,
													   		   @IdClientePegador,
													   		   @saldo_jts_oid,
													   		   @FechaVencimiento,
													   		   @FechaCompensacion,
													   		   @CTA_CBU,
													   		   @ReferenciaUnivoca,
													   		   @CUIT_EO,
													   		   
													   		   @VPRESTACION,@NOM_EMPRESA,@VCod_Ent_Originante,@VCod_Suc_Originante,@Cod_Ent_Destino,@Cod_Suc_Destino,convert(DATE,@FechaPresentacion)
													   		   );
	      	GOTO Final
	      END
		  
		  --------------
		  ----NACHA R04
		  --------------
		  
	      IF(LEFT(@InfoAdicional,1)=''0'')
			SET @Moneda = (SELECT C6399 FROM MONEDAS WITH (NOLOCK) WHERE C6403=''N'' AND TZ_LOCK=0);--OPH24102023
	      IF(LEFT(@InfoAdicional,1)=''1'')
			SET @Moneda = (SELECT C6399 FROM MONEDAS WITH (NOLOCK) WHERE C6403=''D'' AND TZ_LOCK=0);--OPH24102023
	   	  
		  IF (ISNUMERIC(@CuentaDebitar) = 0)
	      BEGIN
	      			      		INSERT INTO dbo.ITF_DD_PRESENT_RECIB_RECHAZOS (ID_TICKET, TRACENUMBER,
	      													   FECHAPROCESO, 
	      													   CODIGO_TRANSACCION, 
	      													   ENTIDAD_DEBITAR, 
	      													   CUENTA_DEBITAR, 
	      													   IMPORTE,  
	      													   REFERENCIA_UNIVOCA, 
	      													   ID_CLIENTE_PAGADOR,  
	      													   ESTADO,  
	      													   CODIGO_ERROR, 
	      													   INFO_ADICIONAL,
	      													   
	      													   MONEDA,
	      													   cliente_pagador,
	      													   SALDO_JTS_OID,
	      													   fecha_vto,
	      													   fecha_comp,
	      													   cbu,
	      													   referencia,
	      													   cuit_eo,
	      													   
	      													   prestacion,NOMBRE_EO,COD_ENT_ORIGINANTE,COD_SUC_ORIGINANTE,COD_ENT_DESTINO,COD_SUC_DESTINO,FECHA_PRESENTACION
	      													   )
													   VALUES (@TICKET, @ContadorRegistros,
													   		   @FECHADATE, 
													   		   @CodTransaccion, 
													   		   @EntidadDebitar, 
													   		   @CuentaDebitar, 
													   		   @VImporte,  
													   		   @ReferenciaUnivoca, 
													   		   @IdClientePegador,  
													   		   ''I'',  
													   		   29,
													   		   @InfoAdicional,
													   		   
													   		   @MonedaCta,
													   		   @IdClientePegador,
													   		   @saldo_jts_oid,
													   		   @FechaVencimiento,
													   		   @FechaCompensacion,
													   		   @CTA_CBU,
													   		   @ReferenciaUnivoca,
													   		   @CUIT_EO,
													   		   
													   		   @VPRESTACION,@NOM_EMPRESA,@VCod_Ent_Originante,@VCod_Suc_Originante,@Cod_Ent_Destino,@Cod_Suc_Destino,convert(DATE,@FechaPresentacion)
													   		   );
	      	GOTO Final
	      END
	      
	      --------------
	      ----NACHA R15
	      --------------
	      IF @infoadicional=''01''
			PRINT @CUIT_EO	      
	      DECLARE @V15 NUMERIC;--OPH24102023
	        
	      SELECT @V15 = convert(NUMERIC,COUNT(1))
		  FROM SNP_PRESTACIONES_EMPRESAS WITH (NOLOCK)
		  WHERE CUIT_EO = @CUIT_EO
		  
		  
	      IF (@V15 = 0 AND @CodTransaccion!=''38'')
	      BEGIN
 	      			      		INSERT INTO dbo.ITF_DD_PRESENT_RECIB_RECHAZOS (ID_TICKET,  TRACENUMBER, 
	      													   FECHAPROCESO, 
	      													   CODIGO_TRANSACCION, 
	      													   ENTIDAD_DEBITAR, 
	      													   CUENTA_DEBITAR, 
	      													   IMPORTE,  
	      													   REFERENCIA_UNIVOCA, 
	      													   ID_CLIENTE_PAGADOR,  
	      													   ESTADO,  
	      													   CODIGO_ERROR, 
	      													   INFO_ADICIONAL,
	      													   
	      													   MONEDA,
	      													   cliente_pagador,
	      													   SALDO_JTS_OID,
	      													   fecha_vto,
	      													   fecha_comp,
	      													   cbu,
	      													   referencia,
	      													   cuit_eo,
	      													   
	      													   prestacion,NOMBRE_EO,COD_ENT_ORIGINANTE,COD_SUC_ORIGINANTE,COD_ENT_DESTINO,COD_SUC_DESTINO,FECHA_PRESENTACION
	      													   )
													   VALUES (@TICKET, @ContadorRegistros,
													   		   @FECHADATE, 
													   		   @CodTransaccion, 
													   		   @EntidadDebitar, 
													   		   @CuentaDebitar, 
													   		   @VImporte,  
													   		   @ReferenciaUnivoca, 
													   		   @IdClientePegador,  
													   		   ''I'',  
													   		   32,
													   		   @InfoAdicional,
													   		   
													   		   @MonedaCta,
													   		   @IdClientePegador,
													   		   @saldo_jts_oid,
													   		   @FechaVencimiento,
													   		   @FechaCompensacion,
													   		   @CTA_CBU,
													   		   @ReferenciaUnivoca,
													   		   @CUIT_EO,
													   		   
													   		   @VPRESTACION,@NOM_EMPRESA,@VCod_Ent_Originante,@VCod_Suc_Originante,@Cod_Ent_Destino,@Cod_Suc_Destino,convert(DATE,@FechaPresentacion)
													   		   );
	      	GOTO Final
	      END
	      
	      --------------
	      ----NACHA R19
	      --------------
	      
	      IF (@CodTransaccion!=''38'' AND (@Importe <= 0 OR IsNumeric(@Importe) = 0))
	      BEGIN
 	      			      		INSERT INTO dbo.ITF_DD_PRESENT_RECIB_RECHAZOS (ID_TICKET, TRACENUMBER, 
	      													   FECHAPROCESO, 
	      													   CODIGO_TRANSACCION, 
	      													   ENTIDAD_DEBITAR, 
	      													   CUENTA_DEBITAR, 
	      													   IMPORTE,  
	      													   REFERENCIA_UNIVOCA, 
	      													   ID_CLIENTE_PAGADOR,  
	      													   ESTADO,  
	      													   CODIGO_ERROR, 
	      													   INFO_ADICIONAL,
	      													   
	      													   MONEDA,
	      													   cliente_pagador,
	      													   SALDO_JTS_OID,
	      													   fecha_vto,
	      													   fecha_comp,
	      													   cbu,
	      													   referencia,
	      													   cuit_eo,
	      													   
	      													   prestacion,NOMBRE_EO,COD_ENT_ORIGINANTE,COD_SUC_ORIGINANTE,COD_ENT_DESTINO,COD_SUC_DESTINO,FECHA_PRESENTACION
	      													   )
													   VALUES (@TICKET, @ContadorRegistros,
													   		   @FECHADATE, 
													   		   @CodTransaccion, 
													   		   @EntidadDebitar, 
													   		   @CuentaDebitar, 
													   		   @VImporte,  
													   		   @ReferenciaUnivoca, 
													   		   @IdClientePegador,  
													   		   ''I'',  
													   		   34,
													   		   @InfoAdicional,
													   		   
													   		   @MonedaCta,
													   		   @IdClientePegador,
													   		   @saldo_jts_oid,
													   		   @FechaVencimiento,
													   		   @FechaCompensacion,
													   		   @CTA_CBU,
													   		   @ReferenciaUnivoca,
													   		   @CUIT_EO,
													   		   
													   		   @VPRESTACION,@NOM_EMPRESA,@VCod_Ent_Originante,@VCod_Suc_Originante,@Cod_Ent_Destino,@Cod_Suc_Destino,convert(DATE,@FechaPresentacion)
													   		   );
	      	GOTO Final
	      END
	      
	      --------------
	      ----NACHA R20
	      --------------
	      
--	      SET @NumCuenta = CAST(SUBSTRING(@CuentaDebitar,6,11) AS NUMERIC);
	      SET @NumCuenta = CAST(LEFT(RIGHT(@CuentaDebitar,12),11) AS NUMERIC);
	      SET @TipoCuenta = SUBSTRING(@CuentaDebitar,4,2);
	      
	      --------------
	      ----NACHA R23
	      --------------
	      
	      SELECT @ESTADOSUC = ESTADO 
	      FROM SUCURSALESSC WITH (NOLOCK)
	      WHERE SUCURSAL = CONVERT(INT,RIGHT(@EntidadDebitar,4));
	      
	      IF @ESTADOSUC <> ''A''
	      BEGIN
	      			      		INSERT INTO dbo.ITF_DD_PRESENT_RECIB_RECHAZOS (ID_TICKET,  TRACENUMBER,
	      													   FECHAPROCESO, 
	      													   CODIGO_TRANSACCION, 
	      													   ENTIDAD_DEBITAR, 
	      													   CUENTA_DEBITAR, 
	      													   IMPORTE,  
	      													   REFERENCIA_UNIVOCA, 
	      													   ID_CLIENTE_PAGADOR,  
	      													   ESTADO,  
	      													   CODIGO_ERROR, 
	      													   INFO_ADICIONAL,
	      													   
	      													   MONEDA,
	      													   cliente_pagador,
	      													   SALDO_JTS_OID,
	      													   fecha_vto,
	      													   fecha_comp,
	      													   cbu,
	      													   referencia,
	      													   cuit_eo,
	      													   
	      													   prestacion,NOMBRE_EO,COD_ENT_ORIGINANTE,COD_SUC_ORIGINANTE,COD_ENT_DESTINO,COD_SUC_DESTINO,FECHA_PRESENTACION
	      													   )
													   VALUES (@TICKET, @ContadorRegistros,
													   		   @FECHADATE, 
													   		   @CodTransaccion, 
													   		   @EntidadDebitar, 
													   		   @CuentaDebitar, 
													   		   @VImporte,  
													   		   @ReferenciaUnivoca, 
													   		   @IdClientePegador,  
													   		   ''I'',  
													   		   36,
													   		   @InfoAdicional,
													   		   
													   		   @MonedaCta,
													   		   @IdClientePegador,
													   		   @saldo_jts_oid,
													   		   @FechaVencimiento,
													   		   @FechaCompensacion,
													   		   @CTA_CBU,
													   		   @ReferenciaUnivoca,
													   		   @CUIT_EO,
													   		   
													   		   @VPRESTACION,@NOM_EMPRESA,@VCod_Ent_Originante,@VCod_Suc_Originante,@Cod_Ent_Destino,@Cod_Suc_Destino,convert(DATE,@FechaPresentacion)
													   		   );
	      	GOTO Final
	      END
	      
	      --------------
	      ----NACHA R75
	      --------------      
	      
		  IF ((ISDATE(@VFechaVencimiento) = 0 OR ISDATE(@VFechaCompensacion) = 0 OR ISDATE(@VFechaVencimientoCA) = 0) AND @CodTransaccion!=''38'')
	      BEGIN
	             
	      			      		INSERT INTO dbo.ITF_DD_PRESENT_RECIB_RECHAZOS (ID_TICKET,  TRACENUMBER,
	      													   FECHAPROCESO, 
	      													   CODIGO_TRANSACCION, 
	      													   ENTIDAD_DEBITAR, 
	      													   CUENTA_DEBITAR, 
	      													   IMPORTE,  
	      													   REFERENCIA_UNIVOCA, 
	      													   ID_CLIENTE_PAGADOR,  
	      													   ESTADO,  
	      													   CODIGO_ERROR, 
	      													   INFO_ADICIONAL,
	      													   
	      													   MONEDA,
	      													   cliente_pagador,
	      													   SALDO_JTS_OID,
	      													   fecha_vto,
	      													   fecha_comp,
	      													   cbu,
	      													   referencia,
	      													   cuit_eo,
	      													   
	      													   prestacion,NOMBRE_EO,COD_ENT_ORIGINANTE,COD_SUC_ORIGINANTE,COD_ENT_DESTINO,COD_SUC_DESTINO,FECHA_PRESENTACION
	      													   )
													   VALUES (@TICKET, @ContadorRegistros,
													   		   @FECHADATE, 
													   		   @CodTransaccion, 
													   		   @EntidadDebitar, 
													   		   @CuentaDebitar, 
													   		   @VImporte,  
													   		   @ReferenciaUnivoca, 
													   		   @IdClientePegador,  
													   		   ''I'',  
													   		   40,
													   		   @InfoAdicional,
													   		   
													   		   @MonedaCta,
													   		   @IdClientePegador,
													   		   @saldo_jts_oid,
													   		   @FechaVencimiento,
													   		   @FechaCompensacion,
													   		   @CTA_CBU,
													   		   @ReferenciaUnivoca,
													   		   @CUIT_EO,
													   		   
													   		   @VPRESTACION,@NOM_EMPRESA,@VCod_Ent_Originante,@VCod_Suc_Originante,@Cod_Ent_Destino,@Cod_Suc_Destino,convert(DATE,@FechaPresentacion)
													   		   );
	      	GOTO Final
	      END
	      
	      SET @FechaVencimientoCA = convert(DATE, @VFechaVencimientoCA);
	      
	      --------------
	      ----NACHA R08
	      --------------
	      
		  DECLARE @V08 NUMERIC(2);
	      SET @V08 = 0 --se quita validacion por jira NBCHINT-655 (SELECT COUNT(1) FROM SNP_STOP_DEBIT WITH (NOLOCK) WHERE FECHA_DESDE<=@FECHADATE AND FECHA_VENCIMIENTO>@FECHADATE AND SALDO_JTS_OID = @saldo_jts_oid );
			
		  IF (@V08 > 0 AND @CodTransaccion!=''38'')
	      BEGIN
	      			      		INSERT INTO dbo.ITF_DD_PRESENT_RECIB_RECHAZOS (ID_TICKET,  TRACENUMBER,
	      													   FECHAPROCESO, 
	      													   CODIGO_TRANSACCION, 
	      													   ENTIDAD_DEBITAR, 
	      													   CUENTA_DEBITAR, 
	      													   IMPORTE,  
	      													   REFERENCIA_UNIVOCA, 
	      													   ID_CLIENTE_PAGADOR,  
	      													   ESTADO,  
	      													   CODIGO_ERROR, 
	      													   INFO_ADICIONAL,
	      													   
	      													   MONEDA,
	      													   cliente_pagador,
	      													   SALDO_JTS_OID,
	      													   fecha_vto,
	      													   fecha_comp,
	      													   cbu,
	      													   referencia,
	      													   cuit_eo,
	      													  
	      													   prestacion,NOMBRE_EO,COD_ENT_ORIGINANTE,COD_SUC_ORIGINANTE,COD_ENT_DESTINO,COD_SUC_DESTINO,FECHA_PRESENTACION
	      													   )
													   VALUES (@TICKET, @ContadorRegistros,
													   		   @FECHADATE, 
													   		   @CodTransaccion, 
													   		   @EntidadDebitar, 
													   		   @CuentaDebitar, 
													   		   @VImporte,  
													   		   @ReferenciaUnivoca, 
													   		   @IdClientePegador,  
													   		   ''I'',  
													   		   30,
													   		   @InfoAdicional,
													   		   
													   		   @MonedaCta,
													   		   @IdClientePegador,
													   		   @saldo_jts_oid,
													   		   @FechaVencimiento,
													   		   @FechaCompensacion,
													   		   @CTA_CBU,
													   		   @ReferenciaUnivoca,
													   		   @CUIT_EO,
													   		   
													   		   @VPRESTACION,@NOM_EMPRESA,@VCod_Ent_Originante,@VCod_Suc_Originante,@Cod_Ent_Destino,@Cod_Suc_Destino,convert(DATE,@FechaPresentacion)
													   		   );
	      	GOTO Final
	      END
	      
	      --------------
	      ----NACHA R91
	      --------------
	      
		  IF(@CodTransaccion!=''38'' AND ((LEFT(@EntidadDebitar,4)=''0311'' AND LEFT(@InfoAdicional,1)<>0) OR (LEFT(@EntidadDebitar,4)=''0811'' AND LEFT(@InfoAdicional,1)<>''1'')))
	      BEGIN
	      			      		INSERT INTO dbo.ITF_DD_PRESENT_RECIB_RECHAZOS (ID_TICKET,  TRACENUMBER,
	      													   FECHAPROCESO, 
	      													   CODIGO_TRANSACCION, 
	      													   ENTIDAD_DEBITAR, 
	      													   CUENTA_DEBITAR, 
	      													   IMPORTE,  
	      													   REFERENCIA_UNIVOCA, 
	      													   ID_CLIENTE_PAGADOR,  
	      													   ESTADO,  
	      													   CODIGO_ERROR, 
	      													   INFO_ADICIONAL,
	      													   
	      													   MONEDA,
	      													   cliente_pagador,
	      													   SALDO_JTS_OID,
	      													   fecha_vto,
	      													   fecha_comp,
	      													   cbu,
	      													   referencia,
	      													   cuit_eo,
	      													   
	      													   prestacion,NOMBRE_EO,COD_ENT_ORIGINANTE,COD_SUC_ORIGINANTE,COD_ENT_DESTINO,COD_SUC_DESTINO,FECHA_PRESENTACION
	      													   )
													   VALUES (@TICKET, @ContadorRegistros,
													   		   @FECHADATE, 
													   		   @CodTransaccion, 
													   		   @EntidadDebitar, 
													   		   @CuentaDebitar, 
													   		   @VImporte,  
													   		   @ReferenciaUnivoca, 
													   		   @IdClientePegador,  
													   		   ''I'',  
													   		   44,
													   		   @InfoAdicional,
													   		   
													   		   @MonedaCta,
													   		   @IdClientePegador,
													   		   @saldo_jts_oid,
													   		   @FechaVencimiento,
													   		   @FechaCompensacion,
													   		   @CTA_CBU,
													   		   @ReferenciaUnivoca,
													   		   @CUIT_EO,
													   		   
													   		   @VPRESTACION,@NOM_EMPRESA,@VCod_Ent_Originante,@VCod_Suc_Originante,@Cod_Ent_Destino,@Cod_Suc_Destino,convert(DATE,@FechaPresentacion)
													   		   );
	      	GOTO Final
	      END
	    
	      
		SET @correlativo = @correlativo +1;
		DECLARE @Tipo_Documento VARCHAR(4);
		DECLARE @Nro_Documento NUMERIC(15,0);
		  
		SELECT @Tipo_Documento=TIPODOCUMENTO, 
		  		@Nro_Documento=NUMERODOCUMENTO 
		FROM CLI_DocumentosPFPJ WITH (NOLOCK)
		WHERE NUMEROPERSONAFJ = (SELECT TOP 1 NUMEROPERSONA FROM CLI_ClientePersona WITH (NOLOCK)
								 WHERE CODIGOCLIENTE= @Cod_Cliente 
								   AND ((TZ_LOCK < 300000000000000 OR TZ_LOCK >= 400000000000000) 
								   		AND (TZ_LOCK < 100000000000000 OR TZ_LOCK >= 200000000000000)))
		
		

	
		SET @CUIT_EO = CONCAT(isnull(@IdentificacionEI,0),isnull(@DigitoV,0))
		SET @PRESTACION = @VPrestacion
		
		
		SELECT 
			@PRESTACION = PRESTACION
		FROM SNP_PRESTACIONES_EMPRESAS WITH (NOLOCK)
		WHERE ENTIDAD = @IdEntidadOrigen
		

	
		IF @CodTransaccion = ''32''
		BEGIN
		  SET @Reverso_Directo = 1;
		END;
		ELSE
		BEGIN
		  SET @Reverso_Directo = 0;
		END

		IF @codtransaccion!=38
		BEGIN 
			INSERT INTO SNP_DEBITOS(ID_DEBITO, 
								ORIGEN, 
								CUIT_EO, 
								PRESTACION, 
								FECHA_VTO, 
								CODIGO_CLIENTE,
								REFERENCIA, 
								PRIORIDAD, 
								FECHA_COMP, 
								MONEDA, 
								IMPORTE, 
								CBU, 
								SALDO_JTS_OID, 
								CODIGO_ORIGEN,
								INFO_ADICIONAL, 
								MOTIVO_RECHAZO, 
								ESTADO, 
								JTS_OID_FINAL, 
								FECHA_ASIENTO, 
								NUMERO_ASIENTO, 
								SUCURSAL_ASIENTO, 
								REVERSA, 
								COD_ENT_ORIGINANTE, 
								COD_SUC_ORIGINANTE, 
								COD_ENT_DESTINO, 
								COD_SUC_DESTINO, 
								CONTADOR_REGISTRO, 
								FECHA_PRESENTACION,
								IDENTIF_ARCHIVO,
								NOMBRE_EO,
								INFO_DISCRECIONAL,
								IDENTIF_CLIENTE,
								FECHA_VTO_REVERSA,
								TRACKNUMBER_REVERSA,
								MOTIVO_REVERSA,
								fecha_recepcion,
								TRACKNUMBER
		  						)
						VALUES(@NroArchivo, 
							   ''C'', 
							   @CUIT_EO , 
							   @VPRESTACION, 
							   @FechaVencimiento, 
							   @Cod_Cliente, --OPH24102023
		  					   RTRIM(LTRIM(@ReferenciaUnivoca)), 
		  					   @CodigoPrioridad, 
		  					   @FechaCompensacion, 
		  					   @Moneda, 
		  					   @Importe, 
		  					   @CTA_CBU, 
		  					   @saldo_jts_oid, 
		  					   @CodigoOrigen,
		  					   @InfoAdicional, 
		  					   NULL, 
		  					   ''PP'', 
		  					   NULL, 
		  					   NULL, 
		  					   NULL, 
		  					   NULL,
		  					   @Reverso_Directo, 
		  					   @VCod_Ent_Originante, 
		  					   @VCod_Suc_Originante, 
		  					   @Cod_Ent_Destino, 
		  					   @Cod_Suc_Destino, 
		  					   @ContadorRegistros, 
		  					   convert(DATE,@FechaPresentacion),
		  					   @IdentificadorArchivo,
		  					   @NOM_EMPRESA,
		  					   @INFO_DISCRECIONAL,
		  					   @IdClientePegador,
		  					   @FechaVencimientoRA,
		  					   @TraceNumberRA,
		  					   @MotivoReversaRA,
		  					   (SELECT fechaproceso FROM PARAMETROS WITH (NOLOCK)),
		  					   @ContadorRegistros  
		  					)
		END
		ELSE
		BEGIN	
			IF (SELECT COUNT(1) 
				FROM snp_adhesiones WITH (NOLOCK)
				WHERE cliente_adherido=@Cod_Cliente 
				AND cuit_eo=@CUIT_EO 
				AND prestacion=@VPRESTACION 
				AND ID_CLIENTE_PAGADOR=@IdClientePegador 
				AND tz_lock=0)>0	 
		  	BEGIN
PRINT ''ENTRA ADHESIONES''
		  		UPDATE snp_adhesiones
		  		SET 
									DNI_CLIENTE_ADHERIDO=(SELECT TOP 1 p.NumDocFisico FROM CLI_ClientePersona cli WITH (NOLOCK) JOIN vw_personas_f_y_j p WITH (NOLOCK) ON cli.NUMEROPERSONA=p.NUMEROPERSONA WHERE TITULARIDAD=''T'' AND CODIGOCLIENTE=@Cod_Cliente AND cli.TZ_LOCK=0)
									, APELLIDO_NOMBRE=(SELECT TOP 1 replace(p.NOMBRE,'','','' '') FROM CLI_ClientePersona cli WITH (NOLOCK) JOIN vw_personas_f_y_j p WITH (NOLOCK) ON cli.NUMEROPERSONA=p.NUMEROPERSONA WHERE TITULARIDAD=''T'' AND CODIGOCLIENTE=@Cod_Cliente AND cli.TZ_LOCK=0) 
									, CUENTA=@NumCuenta
									, MONEDA=@Moneda
									, FECHA_CICLO_COMP=@FechaCompensacion --nuedvo
									
									, ENTIDAD_ORIGEN=@VCod_Ent_Originante
									, SUCURSAL_ORIGEN=@VCod_Suc_Originante
									, ORIGEN_ADHESION=(CASE WHEN TRY_convert(NUMERIC(4),@VCod_Ent_Originante)=311 THEN ''E'' ELSE ''C'' END) 
									, FECHA_PRESENTACION=convert(DATE,@FechaPresentacion)
									, FECHA_VENCIMIENTO=@FechaVencimiento
									, CBU=@CTA_CBU
									, TRACKNUMBER=@ContadorRegistros
									, ESTADO=(CASE WHEN @InfoAdicional=''04'' THEN ''BA'' ELSE ''AC'' END)
									, estado_proceso=NULL
									, cod_ent_destino=@Cod_Ent_Destino
									, cod_suc_destino=@Cod_Suc_Destino
									, fecha_recepcion=(SELECT fechaproceso FROM PARAMETROS WITH (NOLOCK))
									, identif_archivo=@IdentificadorArchivo
		  		WHERE cliente_adherido=@Cod_Cliente 
		  		AND cuit_eo=@CUIT_EO 
		  		AND prestacion=@VPRESTACION
		  		AND ID_CLIENTE_PAGADOR=@IdClientePegador
		  		AND TZ_LOCK=0
		  	END
		  	ELSE
		  	BEGIN
	

PRINT ''ENTRA INSERT ADHESIONES''
PRINT @IdClientePegador

		  		INSERT INTO dbo.SNP_ADHESIONES
								(
									TZ_LOCK
									, CLIENTE_ADHERIDO
									, DNI_CLIENTE_ADHERIDO
									, APELLIDO_NOMBRE
									, CUENTA
									, MONEDA
									, CUIT_EO
									, PRESTACION
									, ENTIDAD_ORIGEN
									, SUCURSAL_ORIGEN
									, ORIGEN_ADHESION
									, FECHA_PRESENTACION
									, FECHA_BAJA
									, FECHA_VENCIMIENTO
									, FECHA_CICLO_COMP
									, FECHA_RECHAZO
									, ID_CLIENTE_PAGADOR
									, MOTIVO_RECHAZO
									, CBU
									, TRACKNUMBER
									, ESTADO
									, ESTADO_PROCESO   
									, cod_ent_destino
									, cod_suc_destino
									, fecha_recepcion
									, identif_archivo
									)
							VALUES
									(
									0
									,  @Cod_Cliente
									, (SELECT TOP 1 p.NumDocFisico FROM CLI_ClientePersona cli WITH (NOLOCK) JOIN vw_personas_f_y_j p WITH (NOLOCK) ON cli.NUMEROPERSONA=p.NUMEROPERSONA WHERE TITULARIDAD=''T'' AND CODIGOCLIENTE=@Cod_Cliente AND cli.TZ_LOCK=0)									
									, (SELECT TOP 1 replace(p.NOMBRE,'','','' '') FROM CLI_ClientePersona cli WITH (NOLOCK) JOIN vw_personas_f_y_j p WITH (NOLOCK) ON cli.NUMEROPERSONA=p.NUMEROPERSONA WHERE TITULARIDAD=''T'' AND CODIGOCLIENTE=@Cod_Cliente AND cli.TZ_LOCK=0) 
									, @NumCuenta
									, @Moneda
									, @CUIT_EO
									, @VPRESTACION
									, @VCod_Ent_Originante
									, @VCod_Suc_Originante
									, (CASE WHEN TRY_convert(NUMERIC(4),@VCod_Ent_Originante)=311 THEN ''E'' ELSE ''C'' END)
									, convert(DATE,@FechaPresentacion)
									, NULL
									, @FechaVencimiento
									, @FechaCompensacion --NUEVO
									, NULL
									, @IdClientePegador
									, null 
									, @CTA_CBU
									, @ContadorRegistros
									, (CASE WHEN @InfoAdicional=''04'' THEN ''BA'' ELSE ''AC'' END)
									, NULL
									, @Cod_Ent_Destino
									, @Cod_Suc_Destino
									, (SELECT fechaproceso FROM PARAMETROS WITH (NOLOCK) )
									, @IdentificadorArchivo
									)
		  	END
		END 				
PRINT @RegistrosAdicionales
 		IF convert(INT,@RegistrosAdicionales)=1
 		BEGIN 

 			UPDATE SNP_MSG_ORDENES
 			SET ESTADO=''RC''
 			WHERE REFERENCIA= @ReferenciaUnivoca 
 			AND FECHA_VENCIMIENTO=@FechaVencimientoRA
 			AND (TRACE_N_1PRE=@TraceNumberRA OR TRACE_N_2PRE=@TraceNumberRA)
 			AND (RENDIDA!=''S'' or CONTABILIZADA!=''S'')
 		END
 


 		IF @CodTransaccion=''37'' AND @InfoAdicional=''01'' AND LEFT(@EntidadDebitar,4)=''0311''
		BEGIN 
			
 			IF(
 				SELECT TOP 1 RENDIDA 
 				from SNP_MSG_ORDENES WITH (NOLOCK)
 				WHERE REFERENCIA= @ReferenciaUnivoca 
 				AND FECHA_VENCIMIENTO=@FechaVencimientoRA
 				AND (TRACE_N_1PRE=@TraceNumberRA OR TRACE_N_2PRE=@TraceNumberRA))=''S''
   			BEGIN
 	
 				INSERT INTO SNP_MSG_ORDENES(correlativo,
 											contabilizada,
 											rendida,
 											CONCEPTO, 
 											ID_archivo_reversado,
 											ESTADO
 											, CUIT_EO
 											, PRESTACION
 											, ID_ARCHIVO
 											, NRO_ARCHIVO
 											, CODIGO_ORDEN
 											, TIPO_ORDEN
 											, INFO_ADICIONAL
 											, codigo_cliente
 											, CLIENTE_PAGADOR
 											, TIPO_DOCUMENTO
 											, NRO_DOCUMENTO
 											, CBU
 											, CUENTA
 											, MONEDA
 											, importe
 											, segundo_importe
 											, presentacion_primer_vto
 											, presentacion_segundo_vto
 											, fecha_vencimiento
 											, segundo_vto
 											, fecha_compensacion
 											, referencia
 											, id_nacha
 											, fecha_nacha
 											, correlativo_nacha
 											, correlativo_lote
 											, registro_individual
 											, fecha_asiento
 											, numero_asiento
 											, sucursal_asiento
 											, motivo_rechazo
 											, fecha_rendida
 											, convenio
 											, trace_n_1pre
 											, trace_n_2pre
 											)
 				SELECT (SELECT isnull(max(correlativo),0)+1 FROM SNP_MSG_ORDENES WITH (NOLOCK)) AS correlativo, 
 						''N'' AS contabilizada, 
 						''N'' AS rendida, 
 						concat(''Reversa de orden cámara '', ID_ARCHIVO) AS concepto,
 						concat(ID_ARCHIVO, RIGHT(concat(replicate(''0'',15),NRO_ARCHIVO),15), RIGHT(concat(replicate(''0'',9),correlativo),9)) AS Id_archivo_reversado,
 						''PR'' AS estado
 						, CUIT_EO
 						, PRESTACION
 						, ID_ARCHIVO
 						, NRO_ARCHIVO
 						, CODIGO_ORDEN
 						, TIPO_ORDEN
 						, INFO_ADICIONAL
 						, codigo_cliente
 						, CLIENTE_PAGADOR
 						, TIPO_DOCUMENTO
 						, NRO_DOCUMENTO
 						, CBU
 						, CUENTA
 						, MONEDA
 						, importe
 						, segundo_importe
 						, presentacion_primer_vto
 						, presentacion_segundo_vto
 						, fecha_vencimiento
 						, segundo_vto
 						, fecha_compensacion
 						, referencia
 						, id_nacha
 						, fecha_nacha
 						, correlativo_nacha
 						, correlativo_lote
 						, registro_individual
 						, fecha_asiento
 						, numero_asiento
 						, sucursal_asiento
 						, motivo_rechazo
 						, fecha_rendida
 						, convenio
 						, trace_n_1pre
 						, trace_n_2pre
 				from SNP_MSG_ORDENES WITH (NOLOCK)
 				wHERE REFERENCIA= @ReferenciaUnivoca 
 				AND FECHA_VENCIMIENTO=@FechaVencimientoRA
 				AND (TRACE_N_1PRE=@TraceNumberRA OR TRACE_N_2PRE=@TraceNumberRA)
 		
 		
 			END
 			ELSE 
 			BEGIN
 		
 			PRINT ''entra update msg_ordenes''
 				UPDATE SNP_MSG_ORDENES
 				SET ESTADO=''AN''
 				WHERE REFERENCIA= @ReferenciaUnivoca 
 				AND FECHA_VENCIMIENTO=@FechaVencimientoRA
 				AND (TRACE_N_1PRE=@TraceNumberRA OR TRACE_N_2PRE=@TraceNumberRA)	
 		
 	
 				INSERT INTO SNP_MSG_ORDENES(correlativo,
 											contabilizada,
 											rendida,
 											CONCEPTO, 
 											ID_archivo_reversado,
 											ESTADO
 											, CUIT_EO
 											, PRESTACION
 											, ID_ARCHIVO
 											, NRO_ARCHIVO
 											, CODIGO_ORDEN
 											, TIPO_ORDEN
 											, INFO_ADICIONAL
 											, codigo_cliente
 											, CLIENTE_PAGADOR
 											, TIPO_DOCUMENTO
 											, NRO_DOCUMENTO
 											, CBU
 											, CUENTA
 											, MONEDA
 											, importe
 											, segundo_importe
 											, presentacion_primer_vto
 											, presentacion_segundo_vto
 											, fecha_vencimiento
 											, segundo_vto
 											, fecha_compensacion
 											, referencia
 											, id_nacha
 											, fecha_nacha
 											, correlativo_nacha
 											, correlativo_lote
 											, registro_individual
 											, fecha_asiento
 											, numero_asiento
 											, sucursal_asiento
 											, motivo_rechazo
 											, fecha_rendida
 											, convenio
 											, trace_n_1pre
 											, trace_n_2pre
 											)
 				SELECT (SELECT isnull(max(correlativo),0)+1 FROM SNP_MSG_ORDENES WITH (NOLOCK)) AS correlativo, 
 						''N'' AS contabilizada, 
 						''N'' AS rendida, 
 						concat(''Reversa de orden cámara '', ID_ARCHIVO) AS concepto,
 						concat(ID_ARCHIVO, RIGHT(concat(replicate(''0'',15),NRO_ARCHIVO),15), RIGHT(concat(replicate(''0'',9),correlativo),9)) AS Id_archivo_reversado,
 						''AN'' AS estado
 						, CUIT_EO
 						, PRESTACION
 						, ID_ARCHIVO
 						, NRO_ARCHIVO
 						, CODIGO_ORDEN
 						, TIPO_ORDEN
 						, INFO_ADICIONAL
 						, codigo_cliente
 						, CLIENTE_PAGADOR
 						, TIPO_DOCUMENTO
 						, NRO_DOCUMENTO
 						, CBU
 						, CUENTA
 						, MONEDA
 						, importe
 						, segundo_importe
 						, presentacion_primer_vto
 						, presentacion_segundo_vto
 						, fecha_vencimiento
 						, segundo_vto
 						, fecha_compensacion
 						, referencia
 						, id_nacha
 						, fecha_nacha
 						, correlativo_nacha
 						, correlativo_lote
 						, registro_individual
 						, fecha_asiento
 						, numero_asiento
 						, sucursal_asiento
 						, motivo_rechazo
 						, fecha_rendida
 						, convenio
 						, trace_n_1pre
 						, trace_n_2pre
 				from SNP_MSG_ORDENES WITH (NOLOCK) 
 				WHERE REFERENCIA= @ReferenciaUnivoca 
 				AND FECHA_VENCIMIENTO=@FechaVencimientoRA
 				AND (TRACE_N_1PRE=@TraceNumberRA OR TRACE_N_2PRE=@TraceNumberRA)
 	 
 			END
 	
		END	

		--*************************************************************************-- 
 
	END	
	END
		Final:
		FETCH NEXT FROM deb_cursor INTO @ID, @LINEA
	END

	CLOSE deb_cursor
	DEALLOCATE deb_cursor

	END TRY
		BEGIN CATCH  
		  CLOSE deb_cursor
		  DEALLOCATE deb_cursor
		  
		  SET @MSJ = ''Linea Error: '' + CONVERT(VARCHAR,ERROR_LINE()) + '' Mensaje Error: '' +  ERROR_MESSAGE();
		  RETURN
		  
		END CATCH;

END
');