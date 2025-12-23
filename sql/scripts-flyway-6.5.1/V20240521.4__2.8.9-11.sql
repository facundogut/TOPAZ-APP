execute('create or ALTER   PROCEDURE [SP_DD_PRESENTADOS_RECIBIDOS]
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
	DECLARE @VImporte VARCHAR(10);     
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
	
	BEGIN TRY
	
	------------Inicio Primera Validacion ----------------
	
	IF(0=(SELECT COUNT(*) FROM ITF_DD_PRESENTADOS_RECIBIDOS_AUX
	WHERE LINEA LIKE ''1%''))
	BEGIN
	  SET @MSJ = ''Error - Falta registro Cabecera de Archivo'';
	  RETURN
	END
	
	IF(0=(SELECT COUNT(*) FROM ITF_DD_PRESENTADOS_RECIBIDOS_AUX
	WHERE LINEA LIKE ''5%''))
	BEGIN
	  SET @MSJ = ''Error - Falta registro Cabecera de Lote.'';
	  RETURN
	END
	
	IF(0=(SELECT COUNT(*) FROM ITF_DD_PRESENTADOS_RECIBIDOS_AUX
	WHERE LINEA LIKE ''8%''))
	BEGIN
	  SET @MSJ = ''Error - Falta registro Control Fin de Lote.'';
	  RETURN
	END
	
	IF(0=(SELECT COUNT(*) FROM ITF_DD_PRESENTADOS_RECIBIDOS_AUX
	WHERE LINEA LIKE ''9%''))
	BEGIN
	  SET @MSJ = ''Error - Falta registro Control Fin de Archivo.'';
	  RETURN
	END
	
	IF ((SELECT COUNT(1) FROM ITF_DD_PRESENTADOS_RECIBIDOS_AUX
		WHERE SUBSTRING(LINEA,1,1) NOT IN(''1'',''5'',''6'',''7'',''8'',''9'')) > 0) --validacion de id reg
  	BEGIN
  	  SET @MSJ = ''Id Registro invalido'';
	  RETURN
    END

	--#validacion2
	IF ((SELECT COUNT(*)
	FROM ITF_DD_PRESENTADOS_RECIBIDOS_AUX
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
	BEGIN
	  SET @MSJ = ''El orden de los registros NACHA es incorrecto'';
	  RETURN
	END

	
	IF (SELECT COUNT(1)
			FROM ITF_DD_PRESENTADOS_RECIBIDOS_AUX
			WHERE LINEA LIKE ''5%'') <> (SELECT COUNT(1)
			FROM ITF_DD_PRESENTADOS_RECIBIDOS_AUX
			WHERE LINEA LIKE ''8%'')
	BEGIN
	  SET @MSJ = ''Nro de Registros de Cabecera de Lote es distinto al Final de Lote'';
	  RETURN
	END 
	
	IF( (SELECT COUNT(1) FROM ITF_DD_PRESENTADOS_RECIBIDOS_AUX
		 WHERE LEN(LINEA) <> 94) > 0)
	BEGIN
	  SET @MSJ = ''Existe(n) fila(s) con longitud incorrecta'';
	  RETURN
	END 
	------validaciones #5 #6 #7 y #8
	
	IF ((select count(1)
		FROM ITF_DD_PRESENTADOS_RECIBIDOS_AUX
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
		@sumaEntidades_RI = sum(CAST(substring(LINEA, 4, 4) AS NUMERIC)),
		@sumaSucursales_RI = sum(CAST(substring(LINEA, 8, 4) AS NUMERIC))
	FROM ITF_DD_PRESENTADOS_RECIBIDOS_AUX
	WHERE LINEA LIKE ''6%''

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
	
	DECLARE deb_cursor CURSOR FOR 
	SELECT ID, LINEA
	FROM dbo.ITF_DD_PRESENTADOS_RECIBIDOS_AUX

	OPEN deb_cursor

	FETCH NEXT FROM deb_cursor INTO @ID, @LINEA

	WHILE @@FETCH_STATUS = 0  
	BEGIN

		SET @NroArchivo = (SELECT ISNULL(MAX(ID_DEBITO),0) FROM dbo.SNP_DEBITOS)+1;
		
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
			--Se incluye desde el IDRegistro 5, debio estar en IDRegistro 1 OPH25102023
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
			--SET @ReservadoLoteCeros = substring(@LINEA, 76, 3); OPH26102023
			--VALIDACION RESERVADO 000

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
			SET @ReservadoFL = substring(@LINEA, 45, 35);
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
			SET @ReservadoFA  = substring(@LINEA, 56, 39);

			--#validacion9
			IF(@ExisteRI = 1 AND (SELECT COUNT(*) FROM ITF_DD_PRESENTADOS_RECIBIDOS_AUX WHERE LINEA LIKE ''5%'') <> @CantLotesFA)
			BEGIN
				SET @MSJ = ''No coincide la cantidad de LOTES con la informada en el reg FA'';
				RETURN
			END
			
			--#validacion10
			IF((SELECT count(*) FROM ITF_DD_PRESENTADOS_RECIBIDOS_AUX WHERE LINEA LIKE ''6%'' OR LINEA LIKE ''7%'') <> @CantRegAdFA)
			BEGIN
				SET @MSJ = ''No coincide la cantidad de registros ind y ad con la informada en el reg FA'';
				RETURN
			END

		END
		
		/*Registro Adicional*/
		IF (@IdRegistro = ''7'') 
		BEGIN
			IF(substring(@linea,2,2)=''05'')
			BEGIN
				SET @FechaVencimientoRA = try_convert(DATE, substring(@linea,4,6),12);
				SET @TraceNumberRA = substring(@linea,10,15);
				SET @MotivoReversaRA = substring(@linea,30,3);
			end
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
	      SET @NumCuenta = CAST(SUBSTRING(@CuentaDebitar,6,11) AS NUMERIC);
	      SET @TipoCuenta = SUBSTRING(@CuentaDebitar,4,2);
	      
	      --SELECT @TipoCuenta AS ''TipoCuenta'' OMAR
	      
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
	
	
	
	
			SELECT @CTA_CBU = CTA_CBU
		FROM VTA_SALDOS
		WHERE JTS_OID_SALDO = @saldo_jts_oid	
	
	
	
	 SET @CUIT_EO = CONCAT(isnull(@IdentificacionEI,0),isnull(@DigitoV,0))
	
	
	
	IF @CTA_CBU IS NULL
	BEGIN		
		DECLARE @E01 INT = 10-((CONVERT(INT, SUBSTRING(@EntidadDebitar, 2, 1))*7+
		CONVERT(INT, SUBSTRING(@EntidadDebitar, 3, 1))*1+
		CONVERT(INT, SUBSTRING(@EntidadDebitar, 4, 1))*3+
		CONVERT(INT, SUBSTRING(@EntidadDebitar, 5, 1))*9+
		CONVERT(INT, SUBSTRING(@EntidadDebitar, 6, 1))*7+
		CONVERT(INT, SUBSTRING(@EntidadDebitar, 7, 1))*1+
		CONVERT(INT, SUBSTRING(@EntidadDebitar, 8, 1))*3)%10)
	
		SET @CTA_CBU=concat(RIGHT(@EntidadDebitar,7),convert(VARCHAR(1),@E01),RIGHT(@CuentaDebitar,14))
	END
	

	
	IF @MonedaCta IS NULL
  	BEGIN
  		SET @MonedaCta=1;
  	END
  	
	      ----------------------- VALIDACIONES INCLUYENTES------------------------
	      ------------------------------------------------------------------------
		  --------------
		  ----NACHA R17
		  --------------
		  DECLARE @FECHADATE DATETIME;
		  SET @FECHADATE = (SELECT FECHAPROCESO FROM PARAMETROS);

		  IF ISNUMERIC(@CodTransaccion) = 0 or ISNUMERIC(@EntidadDebitar) = 0  OR ISNUMERIC(@ReservadoRI) = 0 OR ISNUMERIC(@CuentaDebitar) = 0
			 OR ISNUMERIC(@InfoAdicional) = 0 OR ISNUMERIC(@RegistrosAdicionales) = 0 OR ISNUMERIC(@ContadorRegistros) = 0
	      BEGIN
	      		INSERT INTO dbo.ITF_DD_PRESENT_RECIB_RECHAZOS (ID_TICKET,  
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
	      													   motivo_rechazo,
	      													   prestacion
	      													   )
													   VALUES (@TICKET, 
													   		   @FECHADATE, 
													   		   @CodTransaccion, 
													   		   @EntidadDebitar, 
													   		   @CuentaDebitar, 
													   		   @VImporte,  
													   		   @ReferenciaUnivoca, 
													   		   @IdClientePegador,  
													   		   ''I'',  
													   		   (SELECT CODIGO_NACHA FROM CLE_TIPO_CAUSAL WHERE CODIGO_DE_CAUSAL = 32),
													   		   @InfoAdicional,
													   		   
													   		   @MonedaCta,
													   		   @IdClientePegador,
													   		   @saldo_jts_oid,
													   		   @FechaVencimiento,
													   		   @FechaCompensacion,
													   		   @CTA_CBU,
													   		   @ReferenciaUnivoca,
													   		   @CUIT_EO,
													   		   ''17'',
													   		   @VPRESTACION
													   		   );
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
	     			      		INSERT INTO dbo.ITF_DD_PRESENT_RECIB_RECHAZOS (ID_TICKET,  
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
	      													   motivo_rechazo,
	      													   prestacion
	      													   )
													   VALUES (@TICKET, 
													   		   @FECHADATE, 
													   		   @CodTransaccion, 
													   		   @EntidadDebitar, 
													   		   @CuentaDebitar, 
													   		   @VImporte,  
													   		   @ReferenciaUnivoca, 
													   		   @IdClientePegador,  
													   		   ''I'',  
													   		   (SELECT CODIGO_NACHA FROM CLE_TIPO_CAUSAL WHERE CODIGO_DE_CAUSAL = 76),
													   		   @InfoAdicional,
													   		   
													   		   @MonedaCta,
													   		   @IdClientePegador,
													   		   @saldo_jts_oid,
													   		   @FechaVencimiento,
													   		   @FechaCompensacion,
													   		   @CTA_CBU,
													   		   @ReferenciaUnivoca,
													   		   @CUIT_EO,
													   		   ''93'',
													   		   @VPRESTACION
													   		   );
	      	GOTO Final
	      END
		  
		  --------------
		  ----NACHA R04
		  --------------
		  
	      IF(LEFT(@InfoAdicional,1)=''0'')
			SET @Moneda = (SELECT C6399 FROM MONEDAS WHERE C6403=''N'' AND TZ_LOCK=0);--OPH24102023
	      IF(LEFT(@InfoAdicional,1)=''1'')
			SET @Moneda = (SELECT C6399 FROM MONEDAS WHERE C6403=''D'' AND TZ_LOCK=0);--OPH24102023
	   	  
		  IF (ISNUMERIC(@CuentaDebitar) = 0)
	      BEGIN
	      			      		INSERT INTO dbo.ITF_DD_PRESENT_RECIB_RECHAZOS (ID_TICKET,  
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
	      													   motivo_rechazo,
	      													   prestacion
	      													   )
													   VALUES (@TICKET, 
													   		   @FECHADATE, 
													   		   @CodTransaccion, 
													   		   @EntidadDebitar, 
													   		   @CuentaDebitar, 
													   		   @VImporte,  
													   		   @ReferenciaUnivoca, 
													   		   @IdClientePegador,  
													   		   ''I'',  
													   		   (SELECT CODIGO_NACHA FROM CLE_TIPO_CAUSAL WHERE CODIGO_DE_CAUSAL = 4),
													   		   @InfoAdicional,
													   		   
													   		   @MonedaCta,
													   		   @IdClientePegador,
													   		   @saldo_jts_oid,
													   		   @FechaVencimiento,
													   		   @FechaCompensacion,
													   		   @CTA_CBU,
													   		   @ReferenciaUnivoca,
													   		   @CUIT_EO,
													   		   ''4'',
													   		   @VPRESTACION
													   		   );
	      	GOTO Final
	      END
	      
	      --------------
	      ----NACHA R15
	      --------------
	      
	      DECLARE @V15 NUMERIC;--OPH24102023
	        
	      SELECT @V15 = convert(NUMERIC,COUNT(1))
		  FROM SNP_PRESTACIONES_EMPRESAS
		  WHERE CUIT_EO = @CUIT_EO
		  
		  
	      IF (@V15 = 0 AND @CodTransaccion!=''38'')
	      BEGIN
 	      			      		INSERT INTO dbo.ITF_DD_PRESENT_RECIB_RECHAZOS (ID_TICKET,  
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
	      													   motivo_rechazo,
	      													   prestacion
	      													   )
													   VALUES (@TICKET, 
													   		   @FECHADATE, 
													   		   @CodTransaccion, 
													   		   @EntidadDebitar, 
													   		   @CuentaDebitar, 
													   		   @VImporte,  
													   		   @ReferenciaUnivoca, 
													   		   @IdClientePegador,  
													   		   ''I'',  
													   		   (SELECT CODIGO_NACHA FROM CLE_TIPO_CAUSAL WHERE CODIGO_DE_CAUSAL = 92),
													   		   @InfoAdicional,
													   		   
													   		   @MonedaCta,
													   		   @IdClientePegador,
													   		   @saldo_jts_oid,
													   		   @FechaVencimiento,
													   		   @FechaCompensacion,
													   		   @CTA_CBU,
													   		   @ReferenciaUnivoca,
													   		   @CUIT_EO,
													   		   ''15'',
													   		   @VPRESTACION
													   		   );
	      	GOTO Final
	      END
	      
	      --------------
	      ----NACHA R19
	      --------------
	      
	      IF (@CodTransaccion!=''38'' AND (@Importe <= 0 OR IsNumeric(@Importe) = 0))
	      BEGIN
 	      			      		INSERT INTO dbo.ITF_DD_PRESENT_RECIB_RECHAZOS (ID_TICKET,  
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
	      													   motivo_rechazo,
	      													   prestacion
	      													   )
													   VALUES (@TICKET, 
													   		   @FECHADATE, 
													   		   @CodTransaccion, 
													   		   @EntidadDebitar, 
													   		   @CuentaDebitar, 
													   		   @VImporte,  
													   		   @ReferenciaUnivoca, 
													   		   @IdClientePegador,  
													   		   ''I'',  
													   		   (SELECT CODIGO_NACHA FROM CLE_TIPO_CAUSAL WHERE CODIGO_DE_CAUSAL = 93),
													   		   @InfoAdicional,
													   		   
													   		   @MonedaCta,
													   		   @IdClientePegador,
													   		   @saldo_jts_oid,
													   		   @FechaVencimiento,
													   		   @FechaCompensacion,
													   		   @CTA_CBU,
													   		   @ReferenciaUnivoca,
													   		   @CUIT_EO,
													   		   ''19'',
													   		   @VPRESTACION
													   		   );
	      	GOTO Final
	      END
	      
	      --------------
	      ----NACHA R20
	      --------------
	      
	      SET @NumCuenta = CAST(SUBSTRING(@CuentaDebitar,6,11) AS NUMERIC);
	      SET @TipoCuenta = SUBSTRING(@CuentaDebitar,4,2);
	      
	      --------------
	      ----NACHA R23
	      --------------
	      
	      SELECT @ESTADOSUC = ESTADO 
	      FROM SUCURSALESSC
	      WHERE SUCURSAL = CONVERT(INT,RIGHT(@EntidadDebitar,4));
	      
	      IF @ESTADOSUC <> ''A''
	      BEGIN
	      			      		INSERT INTO dbo.ITF_DD_PRESENT_RECIB_RECHAZOS (ID_TICKET,  
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
	      													   motivo_rechazo,
	      													   prestacion
	      													   )
													   VALUES (@TICKET, 
													   		   @FECHADATE, 
													   		   @CodTransaccion, 
													   		   @EntidadDebitar, 
													   		   @CuentaDebitar, 
													   		   @VImporte,  
													   		   @ReferenciaUnivoca, 
													   		   @IdClientePegador,  
													   		   ''I'',  
													   		   (SELECT CODIGO_NACHA FROM CLE_TIPO_CAUSAL WHERE CODIGO_DE_CAUSAL = 95),
													   		   @InfoAdicional,
													   		   
													   		   @MonedaCta,
													   		   @IdClientePegador,
													   		   @saldo_jts_oid,
													   		   @FechaVencimiento,
													   		   @FechaCompensacion,
													   		   @CTA_CBU,
													   		   @ReferenciaUnivoca,
													   		   @CUIT_EO,
													   		   ''23'',
													   		   @VPRESTACION
													   		   );
	      	GOTO Final
	      END
	      
	      --------------
	      ----NACHA R75
	      --------------      
	      
		  IF ((ISDATE(@VFechaVencimiento) = 0 OR ISDATE(@VFechaCompensacion) = 0 OR ISDATE(@VFechaVencimientoCA) = 0) AND @CodTransaccion!=''38'')
	      BEGIN
	             
	      			      		INSERT INTO dbo.ITF_DD_PRESENT_RECIB_RECHAZOS (ID_TICKET,  
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
	      													   motivo_rechazo,
	      													   prestacion
	      													   )
													   VALUES (@TICKET, 
													   		   @FECHADATE, 
													   		   @CodTransaccion, 
													   		   @EntidadDebitar, 
													   		   @CuentaDebitar, 
													   		   @VImporte,  
													   		   @ReferenciaUnivoca, 
													   		   @IdClientePegador,  
													   		   ''I'',  
													   		   (SELECT CODIGO_NACHA FROM CLE_TIPO_CAUSAL WHERE CODIGO_DE_CAUSAL = 58),
													   		   @InfoAdicional,
													   		   
													   		   @MonedaCta,
													   		   @IdClientePegador,
													   		   @saldo_jts_oid,
													   		   @FechaVencimiento,
													   		   @FechaCompensacion,
													   		   @CTA_CBU,
													   		   @ReferenciaUnivoca,
													   		   @CUIT_EO,
													   		   ''75'',
													   		   @VPRESTACION
													   		   );
	      	GOTO Final
	      END
	      
	      SET @FechaVencimientoCA = convert(DATE, @VFechaVencimientoCA);
	      
	      --------------
	      ----NACHA R08
	      --------------
	      
		  DECLARE @V08 NUMERIC(2);
	      SET @V08 = (SELECT COUNT(*) FROM SNP_STOP_DEBIT WHERE FECHA_DESDE<=@FECHADATE AND FECHA_VENCIMIENTO>@FECHADATE AND SALDO_JTS_OID = @saldo_jts_oid );
			
		  IF (@V08 > 0 AND @CodTransaccion!=''38'')
	      BEGIN
	      			      		INSERT INTO dbo.ITF_DD_PRESENT_RECIB_RECHAZOS (ID_TICKET,  
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
	      													   motivo_rechazo,
	      													   prestacion
	      													   )
													   VALUES (@TICKET, 
													   		   @FECHADATE, 
													   		   @CodTransaccion, 
													   		   @EntidadDebitar, 
													   		   @CuentaDebitar, 
													   		   @VImporte,  
													   		   @ReferenciaUnivoca, 
													   		   @IdClientePegador,  
													   		   ''I'',  
													   		   (SELECT CODIGO_NACHA FROM CLE_TIPO_CAUSAL WHERE CODIGO_DE_CAUSAL = 14),
													   		   @InfoAdicional,
													   		   
													   		   @MonedaCta,
													   		   @IdClientePegador,
													   		   @saldo_jts_oid,
													   		   @FechaVencimiento,
													   		   @FechaCompensacion,
													   		   @CTA_CBU,
													   		   @ReferenciaUnivoca,
													   		   @CUIT_EO,
													   		   ''8'',
													   		   @VPRESTACION
													   		   );
	      	GOTO Final
	      END
	      
	      --------------
	      ----NACHA R91
	      --------------
	      
		  IF(@CodTransaccion!=''38'' AND ((LEFT(@EntidadDebitar,4)=''0311'' AND LEFT(@InfoAdicional,1)<>0) OR (LEFT(@EntidadDebitar,4)=''0811'' AND LEFT(@InfoAdicional,1)<>''1'')))
	      BEGIN
	      			      		INSERT INTO dbo.ITF_DD_PRESENT_RECIB_RECHAZOS (ID_TICKET,  
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
	      													   motivo_rechazo,
	      													   prestacion
	      													   )
													   VALUES (@TICKET, 
													   		   @FECHADATE, 
													   		   @CodTransaccion, 
													   		   @EntidadDebitar, 
													   		   @CuentaDebitar, 
													   		   @VImporte,  
													   		   @ReferenciaUnivoca, 
													   		   @IdClientePegador,  
													   		   ''I'',  
													   		   (SELECT CODIGO_NACHA FROM CLE_TIPO_CAUSAL WHERE CODIGO_DE_CAUSAL = 74),
													   		   @InfoAdicional,
													   		   
													   		   @MonedaCta,
													   		   @IdClientePegador,
													   		   @saldo_jts_oid,
													   		   @FechaVencimiento,
													   		   @FechaCompensacion,
													   		   @CTA_CBU,
													   		   @ReferenciaUnivoca,
													   		   @CUIT_EO,
													   		   ''91'',
													   		   @VPRESTACION
													   		   );
	      	GOTO Final
	      END
	    
	      
		SET @correlativo = @correlativo +1;
		DECLARE @Tipo_Documento VARCHAR(4);
		DECLARE @Nro_Documento NUMERIC(15,0);
		  
		SELECT @Tipo_Documento=TIPODOCUMENTO, 
		  		@Nro_Documento=NUMERODOCUMENTO 
		FROM CLI_DocumentosPFPJ 
		WHERE NUMEROPERSONAFJ = (SELECT TOP 1 NUMEROPERSONA FROM CLI_ClientePersona 
								 WHERE CODIGOCLIENTE= @Cod_Cliente 
								   AND ((TZ_LOCK < 300000000000000 OR TZ_LOCK >= 400000000000000) 
								   		AND (TZ_LOCK < 100000000000000 OR TZ_LOCK >= 200000000000000)))
		
		

	
		SET @CUIT_EO = CONCAT(isnull(@IdentificacionEI,0),isnull(@DigitoV,0))
		SET @PRESTACION = @VPrestacion
		
		
		SELECT --@CUIT_EO = CUIT_EO,
			@PRESTACION = PRESTACION
		FROM SNP_PRESTACIONES_EMPRESAS
		WHERE ENTIDAD = @IdEntidadOrigen
		
		SELECT @CTA_CBU = CTA_CBU
		FROM VTA_SALDOS
		WHERE JTS_OID_SALDO = @saldo_jts_oid
	
		IF @CodTransaccion = ''32''
		BEGIN
		  SET @Reverso_Directo = 1;
		END;
		ELSE
		BEGIN
		  SET @Reverso_Directo = 0;
		END
		-- tipo 38 e info adicional in 4 5 6: insertamos en snp_adhesiones,de no ser posible update
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
		  					   (SELECT fechaproceso FROM PARAMETROS),
		  					   @ContadorRegistros  
		  					)
		END
		ELSE
		BEGIN	
			IF (SELECT count(*) FROM snp_adhesiones WHERE cliente_adherido=@Cod_Cliente AND cuit_eo=@CUIT_EO AND prestacion=@VPRESTACION AND tz_lock=0)>0	 
		  	BEGIN
		  		UPDATE snp_adhesiones
		  		SET 
									DNI_CLIENTE_ADHERIDO=(SELECT TOP 1 numerodoc FROM vw_clientes_personas WHERE CODIGOCLIENTE=@Cod_Cliente)
									, APELLIDO_NOMBRE=@NOM_EMPRESA
									--, PRODUCTO
   									--, SUCURSAL
									, CUENTA=@NumCuenta
									, MONEDA=@Moneda
									
									
									, ENTIDAD_ORIGEN=@VCod_Ent_Originante
									, SUCURSAL_ORIGEN=@VCod_Suc_Originante
									, ORIGEN_ADHESION=''C''
									, FECHA_PRESENTACION=convert(DATE,@FechaPresentacion)
									, FECHA_VENCIMIENTO=@FechaVencimiento
									, ID_CLIENTE_PAGADOR=try_convert(NUMERIC,@IdClientePegador)
									, CBU=@CTA_CBU
									, TRACKNUMBER=@ContadorRegistros
									, ESTADO=''PP'',
									estado_proceso=null
		  		WHERE cliente_adherido=@Cod_Cliente 
		  		AND cuit_eo=@CUIT_EO 
		  		AND prestacion=@VPRESTACION
		  		AND TZ_LOCK=0
		  	END
		  	ELSE
		  	BEGIN
	


		  		INSERT INTO dbo.SNP_ADHESIONES
								(
									TZ_LOCK
									, CLIENTE_ADHERIDO
									, DNI_CLIENTE_ADHERIDO
									, APELLIDO_NOMBRE
									--, PRODUCTO
   									--, SUCURSAL
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
									)
							VALUES
									(
									0
									,  @Cod_Cliente
									, (SELECT TOP 1 numerodoc FROM vw_clientes_personas WHERE CODIGOCLIENTE=@Cod_Cliente)
									, @NOM_EMPRESA
									--, 52
									--, @VCod_Suc_Originante
									, @NumCuenta
									, @Moneda
									, @CUIT_EO
									, @VPRESTACION
									, @VCod_Ent_Originante
									, @VCod_Suc_Originante
									,''C''
									, convert(DATE,@FechaPresentacion)
									, NULL
									, @FechaVencimiento
									, NULL
									, NULL
									, try_convert(NUMERIC,@IdClientePegador)
									, null 
									, @CTA_CBU
									, @ContadorRegistros
									, ''PP''
									, null
									)
		  	END
		END 				

 		IF convert(INT,@RegistrosAdicionales)=1
 		BEGIN 

 			UPDATE SNP_MSG_ORDENES
 			SET ESTADO=''RC''
 			WHERE REFERENCIA= @ReferenciaUnivoca 
 			AND FECHA_VENCIMIENTO=@FechaVencimientoRA
 			AND (TRACE_N_1PRE=@TraceNumberRA OR TRACE_N_2PRE=@TraceNumberRA)
 		END
 
 		--***Bloque agregado el 14/05/2024, corresponde al ticket NBCHSEG-7499***--
 		
 		IF @CodTransaccion=''37'' AND @InfoAdicional=''01'' AND LEFT(@EntidadDebitar,4)<>''0311''
		BEGIN 
			PRINT ''entra''
 			IF(
 				SELECT TOP 1 RENDIDA 
 				from SNP_MSG_ORDENES
 				WHERE REFERENCIA= @ReferenciaUnivoca 
 				AND FECHA_VENCIMIENTO=@FechaVencimientoRA
 				AND (TRACE_N_1PRE=@TraceNumberRA OR TRACE_N_2PRE=@TraceNumberRA))=''S''
   			BEGIN
 	
 				INSERT INTO SNP_MSG_ORDENES(correlativo,
 											contabilizada,
 											rendida,
 											CONCEPTO, 
 											ID_archivo_reversado,
 											ESTADO)
 				SELECT CORRELATIVO+1 AS correlativo, 
 						''N'' AS contabilizada, 
 						''N'' AS rendida, 
 						concat(''Reversa de orden cámara '', ID_ARCHIVO) AS concepto,
 						id_archivo AS Id_archivo_reversado,
 						''PR'' AS estado
 				from SNP_MSG_ORDENES
 				wHERE REFERENCIA= @ReferenciaUnivoca 
 				AND FECHA_VENCIMIENTO=@FechaVencimientoRA
 				AND (TRACE_N_1PRE=@TraceNumberRA OR TRACE_N_2PRE=@TraceNumberRA)
 		
 		
 			END
 			ELSE 
 			BEGIN
 		
 		
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
 											ESTADO)
 				SELECT CORRELATIVO+1 AS correlativo, 
 						''N'' AS contabilizada, 
 						''N'' AS rendida, 
 						concat(''Reversa de orden cámara '', ID_ARCHIVO) AS concepto,
 						id_archivo AS Id_archivo_reversado,
 						''AN'' AS estado
 				from SNP_MSG_ORDENES
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

END');

execute('create or ALTER   PROCEDURE [dbo].[SP_DD_ENVIO_PRESENTADOS_RECIVIDOS]
   @TICKET NUMERIC(16)
AS 
BEGIN

--- Autor: Fabio Alexis Menendez --------------------

------------ Limpieza de tabla auxiliar --------------------
--TRUNCATE TABLE dbo.ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX;
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
DECLARE @CA_CODIGO_REFERENCIA VARCHAR(8) = ''        ''; --Se conforma con espacios vacíos.

DECLARE @CA_CABECERA VARCHAR(200);

SET @CA_CABECERA = concat(@CA_ID_REG, @CA_CODIGO_PRIORIDAD, @CA_DESTINO_INMEDIATO, @CA_ORIGEN_INMEDIATO, @CA_FECHA_PRESENTACION, @CA_HORA_PRESENTACION, @CA_IDENTIFICADOR_ARCHIVO, @CA_TAMANNO_REGISTRO, @CA_FACTOR_BLOQUE, @CA_CODIGO_FORMATO, @CA_NOMBRE_DEST_INMEDIATO, @CA_NOMBRE_ORIG_INMEDIATO, @CA_CODIGO_REFERENCIA);


--- Variables cabecera lote (CL)
DECLARE @CL_ID_REG VARCHAR(1) = ''5''; -- fijo
DECLARE @CL_CODIGO_CLASE_TRANSAC VARCHAR(3) = ''200''; -- fijo 
--DECLARE @CL_RESERVADO VARCHAR(46) = replicate('' '', 46); -- 3 campos reservados
DECLARE @CL_NOM_EMPRESA VARCHAR(16);
DECLARE @CL_CRITERIO_EMPRESA VARCHAR(20);
DECLARE @CL_ID_EMPRESA VARCHAR(10);
DECLARE @CL_TIPO_REGISTRO VARCHAR(3) = ''PPD''; -- fijo 
DECLARE @CL_DESCRIP_TRANSAC VARCHAR(10) = ''SERVICIOS ''; -- fijo
DECLARE @CL_FECHA_PRESENTACION VARCHAR(6) = convert(VARCHAR,(SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)), 12);
DECLARE @CL_FECHA_VENCIMIENTO VARCHAR(6) = convert(VARCHAR,(SELECT FECHAPROXIMOPROCESO FROM PARAMETROS WITH(NOLOCK)), 12); 
DECLARE @CL_RESERVADO_CL VARCHAR(3) = ''R  ''; -- fijo
DECLARE @CL_CODIGO_ORIGEN VARCHAR(1) = ''0''; -- fijo
DECLARE @CL_ID_ENTIDAD_ORIGEN VARCHAR(8) = (SELECT ''031100''+CAST((SELECT NUMERICO FROM PARAMETROSGENERALES WHERE CODIGO=40) AS VARCHAR)); 
DECLARE @CL_NUMERO_LOTE VARCHAR(7) = RIGHT(concat(replicate(''0'', 7), 0), 7); -- numero del lote

DECLARE @CL_CABECERA VARCHAR(200);



--SET @CL_CABECERA = concat(@CL_ID_REG, @CL_CODIGO_CLASE_TRANSAC, @CL_RESERVADO, @CL_TIPO_REGISTRO, @CL_DESCRIP_TRANSAC, @CL_FECHA_PRESENTACION, @CL_FECHA_VENCIMIENTO, @CL_RESERVADO_CL, @CL_CODIGO_ORIGEN, @CL_ID_ENTIDAD_ORIGEN, @CL_NUMERO_LOTE);

		---------------- Grabar Cabecera Archivo ---------------------------
		INSERT INTO dbo.ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX (LINEA) VALUES (@CA_CABECERA);
		--------------------------------------------------------------------
		
------ Variables registro individual ( RI) ------------
DECLARE @RI_ID_REG VARCHAR(1) = ''6''; -- fijo  
DECLARE @RI_ENTIDAD_DEBITAR VARCHAR(8);
DECLARE @RI_RESERVADO VARCHAR(1) = ''0''; -- fijo 
DECLARE @RI_CUENTA_DEBITAR VARCHAR(17); 
DECLARE @RI_IMPORTE VARCHAR(11); 
DECLARE @RI_REFERENCIA_UNIVOCA VARCHAR(15);
DECLARE @RI_CLIENTE_PAGADOR VARCHAR(22); 
DECLARE @RI_INFO_ADICIONAL VARCHAR(2);
DECLARE @RI_REGISTRO_ADICIONAL VARCHAR(1); 
DECLARE @RI_CONTADOR_REGISTRO VARCHAR(15);
							
DECLARE @RI_REGISTRO_INDIVIDUAL VARCHAR (200);


------ Variables registro ajuste ( RA) ------------

DECLARE @RA_ID_REG_ADICIONAL VARCHAR(6) = ''799   '';
DECLARE @RA_CONTADOR_REGISTRO_ORIGEN VARCHAR(15);
DECLARE @RA_NUMERO_CERTIFIFADO VARCHAR(6) = ''      '';
DECLARE @RA_ENTIDAD_ORIGINAL VARCHAR(8) = ''        '';
DECLARE @RA_OTRO_MOTIVO_RECH VARCHAR(44) = ''                                             '';

--- Variables fin de lote FL
DECLARE @FL_ID_REG VARCHAR(1) = ''8''; -- fijo 
DECLARE @FL_CODIGO_CLASE_TRANSAC VARCHAR(3) = ''200''; -- fijo 
DECLARE @FL_CANT_REG_INDIVIDUAL_ADICIONAL VARCHAR(6) = 0; --registros individuales y adicionales que existen en el lote
DECLARE @FL_TOTALES_DE_CONTROL VARCHAR(10) = 0;
DECLARE @FL_SUMA_TOTAL_DEBITO_LOTE VARCHAR(12); 
DECLARE @FL_SUMA_TOTAL_CREDITO_LOTE VARCHAR(12); 
DECLARE @FL_RESERVADO1 VARCHAR(10) = ''          ''; -- fijo
DECLARE @FL_RESERVADO2 VARCHAR(19) = ''                   ''; -- fijo
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
DECLARE @FA_SUMA_TOTAL_DEBITOS VARCHAR(12);
DECLARE @FA_SUMA_TOTAL_CREDITOS VARCHAR(12);
DECLARE @FA_RESERVADO  VARCHAR(100) = replicate('' '', 39); -- fijo

DECLARE @FA_FIN_ARCHIVO VARCHAR (200);

------- Variables para registro adicional rechazo -------

DECLARE @CODIGO_RECHAZO VARCHAR(3);
DECLARE @TRACE_NUMBER VARCHAR(15); 
DECLARE @OTRO_RECHAZO VARCHAR(44);
DECLARE @RI_REGISTRO_INDIVIDUAL_ADICIONAL VARCHAR(100);

------- Variables generales ------------
DECLARE @SumaImportes NUMERIC(15,2) = 0;
DECLARE @TotalesControl NUMERIC(10) = 0;
DECLARE @TotalesDebitos NUMERIC(15,2) = 0;
DECLARE @TotalesCreditos NUMERIC(15,2) = 0;
DECLARE @CantRegistros NUMERIC(15) = 0;
DECLARE @CantRegistrosPrev NUMERIC(6)= 0;
DECLARE @Cant_Reg_Individual_Adicional VARCHAR(6)= 0;

DECLARE @SumaEntidad NUMERIC = 0;
DECLARE @SumaSucursal NUMERIC = 0;

DECLARE @SumaEntidad_TOT NUMERIC = 0;
DECLARE @SumaSucursal_TOT NUMERIC = 0;

DECLARE @SobranteSucursal NUMERIC = 0;
DECLARE @Excedente NUMERIC(15,2) = 0;
DECLARE @CountExcedente INT = 0;
DECLARE @MONEDA INT=0;
------------------------------------------


DECLARE @T_JTS_OID NUMERIC(10,0);
DECLARE @T_MONEDA NUMERIC(4,0);
DECLARE @T_ENTIDAD_DEBITAR VARCHAR(8);
DECLARE @T_CODIGO_CLIENTE varchar(22);
DECLARE @T_IMPORTE NUMERIC(15,2);
DECLARE @T_FECHA_VTO DATETIME;
DECLARE @T_FECHA_COMP DATETIME;
DECLARE @T_CBU VARCHAR(22);
DECLARE @T_REFERENCIA VARCHAR(15);
DECLARE @T_CUENTA NUMERIC(12,0);
DECLARE @T_SUCURSAL NUMERIC(5,0);
DECLARE @T_COD_BANCO NUMERIC(4,0);
DECLARE @T_CODIGO_TRANSACCION NUMERIC(3,0);
DECLARE @T_ID_DEBITO NUMERIC(15,0);
DECLARE @T_CUIT NUMERIC(11,0)=0;
DECLARE @CUIT NUMERIC(11,0)=0;
DECLARE @T_MOTIVO_RECHAZO VARCHAR(3);
DECLARE @T_PRESTACION VARCHAR(10);


		IF((SELECT COUNT(1)FROM SNP_DEBITOS WHERE ESTADO = ''RC'' AND fecha_vto=(SELECT fechaproceso FROM PARAMETROS))=0 AND (SELECT COUNT(1) FROM ITF_DD_PRESENT_RECIB_RECHAZOS WHERE ESTADO=''I'' AND fecha_vto=(SELECT fechaproceso FROM PARAMETROS))=0)
		BEGIN
		---------------- Grabar Cabecera Lote ---------------------------
		SET @CL_NUMERO_LOTE = RIGHT(concat(replicate(''0'', 7), (@CL_NUMERO_LOTE + 1)), 7);
		SET @CL_NOM_EMPRESA =  LEFT(concat('''',replicate('' '', 16)),16);
		SET @CL_CRITERIO_EMPRESA = replicate('' '', 20); -- AUN NO EXISTE AUTONUMERICO, FALTA DEFINIR 
		SET @CL_ID_EMPRESA = LEFT(concat(@T_CUIT,replicate(''0'', 10)),10);
		SET @CL_CODIGO_ORIGEN = RIGHT(concat(replicate(''0'', 1),@T_CUIT),1);
		SET @CL_CABECERA = concat(@CL_ID_REG, @CL_CODIGO_CLASE_TRANSAC, @CL_NOM_EMPRESA,@CL_CRITERIO_EMPRESA,@CL_ID_EMPRESA, @CL_TIPO_REGISTRO, @CL_DESCRIP_TRANSAC, @CL_FECHA_PRESENTACION, @CL_FECHA_VENCIMIENTO, @CL_RESERVADO_CL, @CL_CODIGO_ORIGEN, @CL_ID_ENTIDAD_ORIGEN, @CL_NUMERO_LOTE);
		INSERT INTO dbo.ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX (LINEA) VALUES (@CL_CABECERA);
		END 


    --Condicion de reset del contador de reg individual
IF ISNULL((SELECT a.FECHA FROM ITF_MASTER_PARAMETROS a WHERE a.CODIGO = 147), CAST(''01-01-1800'' AS DATETIME)) <> (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK))
    UPDATE dbo.ITF_MASTER_PARAMETROS SET NUMERICO_1 = 1, FECHA = (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)) WHERE CODIGO = 147;
 


DECLARE CursorDD CURSOR FOR
			
SELECT ID_DEBITO, SALDO_JTS_OID, MONEDA, IMPORTE, FECHA_VTO, FECHA_COMP, CBU, replace(REFERENCIA,''.'',''''), convert(VARCHAR(22),CODIGO_CLIENTE), CUIT_EO, MOTIVO_RECHAZO, PRESTACION, isnull(INFO_ADICIONAL,''00'')
FROM SNP_DEBITOS  
WHERE ESTADO = ''RC''
AND fecha_vto=(SELECT fechaproceso FROM PARAMETROS)

UNION 

SELECT ID, SALDO_JTS_OID, MONEDA, IMPORTE, FECHA_VTO, FECHA_COMP, CBU, replace(REFERENCIA,''.'',''''), id_cliente_pagador, CUIT_EO, MOTIVO_RECHAZO, PRESTACION, isnull(INFO_ADICIONAL,''00'')
FROM ITF_DD_PRESENT_RECIB_RECHAZOS 
WHERE ESTADO=''I''
AND fecha_vto=(SELECT fechaproceso FROM PARAMETROS)
ORDER BY CUIT_EO, MONEDA

				        		
OPEN CursorDD
FETCH NEXT FROM CursorDD INTO @T_ID_DEBITO, @T_JTS_OID, @T_MONEDA, @T_IMPORTE, @T_FECHA_VTO,@T_FECHA_COMP,@T_CBU, @T_REFERENCIA, @T_CODIGO_CLIENTE, @T_CUIT, @T_MOTIVO_RECHAZO,@T_PRESTACION, @RI_INFO_ADICIONAL

WHILE @@FETCH_STATUS = 0
BEGIN
	
	IF (@SumaImportes > 9999999999 OR @SumaEntidad > 999999) -- 99 millones
	BEGIN
	PRINT ''SUPERA IMPORTES''	
		IF @SumaSucursal > 9999
		BEGIN
			SET @SobranteSucursal = CAST(substring(CAST(@SumaSucursal AS VARCHAR), 1, (len(@SumaSucursal) - 4)) AS NUMERIC);
			SET @SumaEntidad += @SobranteSucursal;
			SET @SumaSucursal = CAST(RIGHT(@SumaSucursal, 4) AS NUMERIC);
		END
		

	   	--SET @FL_TOTALES_DE_CONTROL = concat((RIGHT(concat(replicate(''0'', 6), @SumaEntidad), 6)), (RIGHT(concat(replicate(''0'', 4), @SumaSucursal), 4)));
	   	SET @FL_SUMA_TOTAL_DEBITO_LOTE = RIGHT(concat(replicate(''0'', 12), (replace(@SumaImportes, ''.'', ''''))), 12); 
	   	SET @FL_SUMA_TOTAL_CREDITO_LOTE = RIGHT(replicate(''0'', 12), 12);
	   	SET @TotalesDebitos += @SumaImportes;
	   	SET @FL_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 6), @Cant_Reg_Individual_Adicional+@CantRegistros), 6); 
	   	
	   	   	--nuevo
   	SET @FL_TOTALES_DE_CONTROL = (RIGHT(concat(replicate(''0'', 10), (SELECT sum(convert(numeric,substring(linea,4,8)))
																	FROM ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX
																	WHERE LINEA LIKE ''6%'' 
																	AND ID>(SELECT max(id) 
																			FROM ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX 
																			WHERE LINEA LIKE ''5%''))), 10))

	   	
	   	SET @FL_FIN_LOTE = concat(@FL_ID_REG, @FL_CODIGO_CLASE_TRANSAC, @FL_CANT_REG_INDIVIDUAL_ADICIONAL, @FL_TOTALES_DE_CONTROL, @FL_SUMA_TOTAL_DEBITO_LOTE, @FL_SUMA_TOTAL_CREDITO_LOTE, @FL_RESERVADO1, @FL_RESERVADO2, @FL_RESERVADO3, @FL_REG_ENTIDAD_ORIGEN, @FL_NUMERO_LOTE);
		
    --OJO CON ESTO--
    SET @CantRegistros = 0;
	SET @Cant_Reg_Individual_Adicional = 0;
	
	SET @SumaEntidad_TOT += @SumaEntidad;
	SET @SumaSucursal_TOT += @SumaSucursal;

		--OJO CON ESTO X2--
	SET @SumaEntidad = 0;
	SET @SumaSucursal = 0;
	SET @SumaImportes=0;
	

	
		INSERT INTO dbo.ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX (LINEA) VALUES (replace(@FL_FIN_LOTE, ''.'', ''''));
		
		SET @FL_NUMERO_LOTE = CAST(@FL_NUMERO_LOTE AS NUMERIC) + 1;

		SET @FL_NUMERO_LOTE = RIGHT(concat(replicate(''0'', 7), @FL_NUMERO_LOTE), 7);
		-------------------------------------------------------------------
		-------------Grabamos el Fin de Archivo ----------------------------------------------------------------------------------------------------------------------
		--SET @FA_CANT_LOTES = RIGHT(concat(replicate(''0'', 6), @FL_NUMERO_LOTE), 6);
		
		
				 SET @FA_CANT_LOTES = RIGHT(concat(replicate(''0'', 6), (SELECT count(*) --le su,o uno al count por la linea que estamos por insertar (9%)
																  FROM ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX 
																  WHERE  LINEA LIKE ''5%'' AND ID>=(SELECT max(id) 
																  		  		FROM ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX 
																  		  		WHERE LINEA LIKE ''1%''))), 6);
		
		
		
		SET @CantRegistrosPrev = (SELECT (CASE WHEN (@CantRegistros + 4) % 10 = 0 THEN ((@CantRegistros + 4)/10) ELSE (FLOOR((@CantRegistros + 4)/10) + 1) END));
		--SET @FA_NUMERO_BLOQUES = RIGHT(concat(replicate(''0'', 6), @CantRegistrosPrev), 6);
		
		 SET @FA_NUMERO_BLOQUES = RIGHT(concat(replicate(''0'', 6), (SELECT floor((count(*)+1)/10)+1 --le su,o uno al count por la linea que estamos por insertar (9%)
																  FROM ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX 
																  WHERE  ID>=(SELECT max(id) 
																  		  		FROM ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX 
																  		  		WHERE LINEA LIKE ''1%''))), 6);

		
		

		--SET @FA_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 8), @CantRegistros), 8);

	SET @FA_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 8), (SELECT sum(convert(numeric,substring(linea,5,6)))
	  																		 FROM ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX 
																			 WHERE LINEA LIKE ''8%''
																			 AND ID>(SELECT max(ID) FROM ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX WHERE LINEA LIKE ''1%''))), 8);



PRINT @FA_CANT_REG_INDIVIDUAL_ADICIONAL
		
		--SET @FA_TOTALES_DE_CONTROL = @FL_TOTALES_DE_CONTROL; --igualo al totales de control de fin de lote pq tiene que ser igual



   	SET @FA_TOTALES_DE_CONTROL = (RIGHT(concat(replicate(''0'', 10), (SELECT sum(convert(numeric,substring(linea,4,8)))
																	FROM ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX
																	WHERE LINEA LIKE ''6%'' 
																	AND ID>(SELECT max(id) 
																			FROM ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX 
																			WHERE LINEA LIKE ''1%''))), 10))

		
		
			SET @FA_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 8), (SELECT sum(convert(numeric,substring(linea,5,6)))
	  																		 FROM ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX 
																			 WHERE LINEA LIKE ''8%''
																			 AND ID>(SELECT max(ID) FROM ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX WHERE LINEA LIKE ''1%''))), 8);

		
		
		
		SET @FA_SUMA_TOTAL_DEBITOS = RIGHT(concat(replicate(''0'', 12), (replace(@TotalesDebitos, ''.'', ''''))), 12);
		
		SET @FA_SUMA_TOTAL_CREDITOS = RIGHT(concat(replicate(''0'', 12), (replace(@TotalesCreditos, ''.'', ''''))),12);

			PRINT ''1:''
	PRINT @FA_ID_REG
	PRINT ''2:''
	PRINT @FA_CANT_LOTES
	PRINT ''3:''
	PRINT @FA_NUMERO_BLOQUES
	PRINT ''4:''
	PRINT @FA_CANT_REG_INDIVIDUAL_ADICIONAL
	PRINT ''5:''
	PRINT @FA_TOTALES_DE_CONTROL
	PRINT ''6:''
	PRINT @FA_SUMA_TOTAL_DEBITOS
	PRINT ''7:''
	PRINT @FA_SUMA_TOTAL_CREDITOS
	PRINT ''8:''
	PRINT @FA_RESERVADO
		
		
		
		SET @FA_FIN_ARCHIVO = concat(@FA_ID_REG, @FA_CANT_LOTES, @FA_NUMERO_BLOQUES, @FA_CANT_REG_INDIVIDUAL_ADICIONAL, @FA_TOTALES_DE_CONTROL, @FA_SUMA_TOTAL_DEBITOS, @FA_SUMA_TOTAL_CREDITOS, @FA_RESERVADO);
		
		PRINT @FA_NUMERO_BLOQUES

		
		INSERT INTO dbo.ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX (LINEA) VALUES (@FA_FIN_ARCHIVO);
		
		PRINT @FA_NUMERO_BLOQUES
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
		
		INSERT INTO dbo.ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX (LINEA) VALUES (@CA_CABECERA);
		----------------------------------------------------------------------------------------------------------------------------------------------------------------------
		--------- Grabamos nueva Cabecera Lote ------------------------------------------------------------------------------------------------------------------------------------------------------

		SET @CUIT = @T_CUIT;
		SET @CL_NUMERO_LOTE = RIGHT(concat(replicate(''0'', 7), (@CL_NUMERO_LOTE + 1)), 7);
		SET @CL_NOM_EMPRESA =  LEFT(concat(replicate('' '', 16), (SELECT NOMBRE_EMPRESA FROM SNP_PRESTACIONES_EMPRESAS WHERE CUIT_EO=@T_CUIT AND PRESTACION=@T_PRESTACION)),16);
		SET @CL_CRITERIO_EMPRESA = replicate('' '', 20); -- AUN NO EXISTE AUTONUMERICO, FALTA DEFINIR 
		SET @CL_ID_EMPRESA = LEFT(@T_CUIT,10);
		
		PRINT ''CASO 1''
		PRINT @T_CUIT
		SET @CL_CODIGO_ORIGEN = RIGHT(concat(replicate(''0'', 1),@T_CUIT),1);
		PRINT @CL_CODIGO_ORIGEN
		
		SET @CL_NUMERO_LOTE=''0000001''
		SET @FL_NUMERO_LOTE=''0000001''
		
		SET @CL_CABECERA = concat(@CL_ID_REG, @CL_CODIGO_CLASE_TRANSAC, @CL_NOM_EMPRESA,@CL_CRITERIO_EMPRESA,@CL_ID_EMPRESA, @CL_TIPO_REGISTRO, @CL_DESCRIP_TRANSAC, @CL_FECHA_PRESENTACION, @CL_FECHA_VENCIMIENTO, @CL_RESERVADO_CL, @CL_CODIGO_ORIGEN, @CL_ID_ENTIDAD_ORIGEN, @CL_NUMERO_LOTE);
		
		INSERT INTO dbo.ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX (LINEA) VALUES (@CL_CABECERA);
		---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	END
	
	IF(@T_MONEDA=(SELECT C6399 FROM MONEDAS WHERE C6403=''N''))
	SET @CL_ID_ENTIDAD_ORIGEN  = (SELECT ''031100''+CAST((SELECT NUMERICO FROM PARAMETROSGENERALES WHERE CODIGO=40) AS VARCHAR));
	ELSE
	SET @CL_ID_ENTIDAD_ORIGEN  = (SELECT ''081100''+CAST((SELECT NUMERICO FROM PARAMETROSGENERALES WHERE CODIGO=40) AS VARCHAR));
	
	/* LOGICA PARA GRABAR LA CABECERA DE LOTE*/
	IF(@CUIT!=@T_CUIT OR @T_MONEDA!=@MONEDA)
	BEGIN
	
	IF(@CUIT!=0)
	BEGIN
	--SET @FL_TOTALES_DE_CONTROL = concat((RIGHT(concat(replicate(''0'', 6), @SumaEntidad), 6)), (RIGHT(concat(replicate(''0'', 4), @SumaSucursal), 4)));
   	SET @FL_SUMA_TOTAL_DEBITO_LOTE = RIGHT(concat(replicate(''0'', 12), (replace(@SumaImportes, ''.'', ''''))), 12); 
   	SET @FL_SUMA_TOTAL_CREDITO_LOTE = RIGHT(replicate(''0'', 12), 12);
   	SET @TotalesDebitos += @SumaImportes;
   	SET @FL_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 6), @Cant_Reg_Individual_Adicional+@CantRegistros), 6); 
   	
   	--nuevo
   	SET @FL_TOTALES_DE_CONTROL = (RIGHT(concat(replicate(''0'', 10), (SELECT sum(convert(numeric,substring(linea,4,8)))
																	FROM ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX
																	WHERE LINEA LIKE ''6%'' 
																	AND ID>(SELECT max(id) 
																			FROM ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX 
																			WHERE LINEA LIKE ''5%''))), 10))
   	
   	
   	SET @FL_FIN_LOTE = concat(@FL_ID_REG, @FL_CODIGO_CLASE_TRANSAC, @FL_CANT_REG_INDIVIDUAL_ADICIONAL, @FL_TOTALES_DE_CONTROL, @FL_SUMA_TOTAL_DEBITO_LOTE, @FL_SUMA_TOTAL_CREDITO_LOTE, @FL_RESERVADO1, @FL_RESERVADO2, @FL_RESERVADO3, @FL_REG_ENTIDAD_ORIGEN, @FL_NUMERO_LOTE);

    --OJO CON ESTO--
    SET @CantRegistros = 0;
	SET @Cant_Reg_Individual_Adicional = 0;
	
	SET @SumaEntidad_TOT += @SumaEntidad;
	SET @SumaSucursal_TOT += @SumaSucursal;

		--OJO CON ESTO X2--
	SET @SumaEntidad = 0;
	SET @SumaSucursal = 0;
	SET @SumaImportes=0;

	SET @FL_NUMERO_LOTE = CAST(@FL_NUMERO_LOTE AS NUMERIC) + 1;

	SET @FL_NUMERO_LOTE = RIGHT(concat(replicate(''0'', 7), @FL_NUMERO_LOTE), 7);
	
	INSERT INTO dbo.ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX (LINEA) VALUES (replace(@FL_FIN_LOTE, ''.'', ''''));
		
	
	
	END
	
	SET @CUIT = @T_CUIT;
	SET @MONEDA = @T_MONEDA;
	
	SET @CL_NUMERO_LOTE = RIGHT(concat(replicate(''0'', 7), (@CL_NUMERO_LOTE + 1)), 7);
	SET @CL_NOM_EMPRESA =  LEFT(concat((SELECT NOMBRE_EMPRESA FROM SNP_PRESTACIONES_EMPRESAS WHERE CUIT_EO=@T_CUIT AND PRESTACION=@T_PRESTACION),replicate('' '', 16)),16);
	SET @CL_CRITERIO_EMPRESA = replicate('' '', 20); -- AUN NO EXISTE AUTONUMERICO, FALTA DEFINIR 
	SET @CL_ID_EMPRESA = LEFT(concat(@T_CUIT,replicate(''0'', 10)),10);
	
	PRINT ''CASO 1''
	PRINT @T_CUIT
	SET @CL_CODIGO_ORIGEN = RIGHT(concat(replicate(''0'', 1),@T_CUIT),1);
	PRINT @CL_CODIGO_ORIGEN
	
		SET @CL_CABECERA = concat(@CL_ID_REG, @CL_CODIGO_CLASE_TRANSAC, @CL_NOM_EMPRESA,@CL_CRITERIO_EMPRESA,@CL_ID_EMPRESA, @CL_TIPO_REGISTRO, @CL_DESCRIP_TRANSAC, @CL_FECHA_PRESENTACION, @CL_FECHA_VENCIMIENTO, @CL_RESERVADO_CL, @CL_CODIGO_ORIGEN, @CL_ID_ENTIDAD_ORIGEN, @CL_NUMERO_LOTE);
		

		
		INSERT INTO dbo.ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX (LINEA) VALUES (@CL_CABECERA);
	
	IF(@T_MONEDA=(SELECT C6399 FROM MONEDAS WHERE C6403=''N''))	
	SET @FL_REG_ENTIDAD_ORIGEN = (SELECT ''0311''+ RIGHT(concat(replicate(''0'', 4), CAST((SELECT NUMERICO FROM PARAMETROSGENERALES WHERE CODIGO=40) AS VARCHAR)), 4)); 
	ELSE
	SET @FL_REG_ENTIDAD_ORIGEN = (SELECT ''0811''+ RIGHT(concat(replicate(''0'', 4), CAST((SELECT NUMERICO FROM PARAMETROSGENERALES WHERE CODIGO=40) AS VARCHAR)), 4)); 
	END
	
	IF (@T_JTS_OID IS NULL)
		BEGIN
			SELECT @T_SUCURSAL=SUCURSAL, @T_CUENTA=CUENTA FROM SALDOS WHERE JTS_OID=@T_JTS_OID;
		END
	ELSE
		BEGIN
			SET @T_SUCURSAL=convert(NUMERIC(5,0),substring(@T_CBU,4,4));
		END
		
	
	
	IF(@T_MONEDA= (SELECT C6399 FROM MONEDAS WHERE C6403=''N''))
	BEGIN
		SET @T_COD_BANCO=311;
		--SET @RI_INFO_ADICIONAL=''00'';
	END
	ELSE
	BEGIN
		SET @T_COD_BANCO=811;
		--SET @RI_INFO_ADICIONAL=''10'';
	END
	
	SET @CantRegistros += 1;
	SET @Cant_Reg_Individual_Adicional += 1;

	
	IF	(@Excedente<>0)
	BEGIN
		SET @T_IMPORTE = @Excedente;
		SET @CountExcedente += 1;
	END
	IF	(@T_IMPORTE>99999999)
	BEGIN
		SET @Excedente = (@T_IMPORTE - 99999999);
		SET @T_IMPORTE = 99999999;
		SET @CountExcedente += 1;
	END
	ELSE
    BEGIN
       SET @Excedente = 0;
    END
	

	---------------------------- Grabar Registro Individual -----------------------------------------------------------------------------------------------------------------------------------------
	SET @RI_ENTIDAD_DEBITAR = CONCAT(RIGHT(concat(replicate(''0'', 4), @T_COD_BANCO),4) , RIGHT(concat(replicate(''0'', 4), @T_SUCURSAL),4));
    SET @RI_CUENTA_DEBITAR = RIGHT(concat(replicate(''0'', 17), @T_CUENTA), 17);
    SET @RI_REFERENCIA_UNIVOCA = RIGHT(concat(replicate(''0'', 15), @T_REFERENCIA), 15);
    SET @RI_CLIENTE_PAGADOR = RIGHT(concat(replicate(''0'', 22), @T_CODIGO_CLIENTE), 22);
	SET @T_CODIGO_TRANSACCION = ''36'';
	
    IF(@CountExcedente>1)
	BEGIN
	

	
        SET @SumaSucursal += 0888;  --sumo la sucursal que hay que harcodear
        SET @SumaEntidad +=  @T_COD_BANCO;
        SET @SumaImportes += @T_IMPORTE;

        
        SET @RI_ENTIDAD_DEBITAR = CONCAT(RIGHT(concat(replicate(''0'', 4), @T_COD_BANCO),4) , RIGHT(concat(replicate(''0'', 4), ''0888''),4));

        
        SET @RI_CUENTA_DEBITAR = RIGHT(concat(replicate(''0'', 17), ''88888888888''), 17);
        SET @RI_REFERENCIA_UNIVOCA = ''000088888888888'';


   
   	END
    ELSE --la razon de este else, es que SumaSucursal, cuando hay excedente tiene que acumular 0888
    BEGIN
        SET @SumaSucursal += @T_SUCURSAL;
		SET @SumaEntidad += @T_COD_BANCO;
		SET @SumaImportes += @T_IMPORTE;



		SET @RI_ENTIDAD_DEBITAR = CONCAT(RIGHT(concat(replicate(''0'', 4), @T_COD_BANCO),4) , RIGHT(concat(replicate(''0'', 4), @T_SUCURSAL),4));
    	SET @RI_CUENTA_DEBITAR = RIGHT(concat(replicate(''0'', 17), @T_CUENTA), 17);
    	SET @RI_REFERENCIA_UNIVOCA =  RIGHT(concat(replicate(''0'', 15), @T_REFERENCIA), 15);
    	SET @RI_CLIENTE_PAGADOR = RIGHT(concat(replicate(''0'', 22), @T_CODIGO_CLIENTE), 22);
 

 			

 
    END

    
    SET @RI_IMPORTE = RIGHT(concat(replicate(''0'', 10), replace(CAST(@T_IMPORTE AS VARCHAR),''.'','''')), 10);
    --SET @RI_CODIGO_POSTAL = RIGHT(concat(''00'', replicate(''0'', 6), @T_CODIGO_POSTAL), 6);

    SET @RI_REGISTRO_ADICIONAL = ''1'';

    IF(@T_MONEDA=(SELECT C6399 FROM MONEDAS WHERE C6403=''N''))
    SET @RI_CONTADOR_REGISTRO = concat(''0311'', RIGHT(concat(replicate(''0'', 4), (''97'')), 4), RIGHT(concat(replicate(''0'', 7), (SELECT NUMERICO_1 FROM ITF_MASTER_PARAMETROS WHERE CODIGO = 147)), 7)); 
    ELSE
    SET @RI_CONTADOR_REGISTRO = concat(''0811'', RIGHT(concat(replicate(''0'', 4), (''97'')), 4), RIGHT(concat(replicate(''0'', 7), (SELECT NUMERICO_1 FROM ITF_MASTER_PARAMETROS WHERE CODIGO = 147)), 7)); 
     
        	
	SET @RI_REGISTRO_INDIVIDUAL = concat(@RI_ID_REG, @T_CODIGO_TRANSACCION, @RI_ENTIDAD_DEBITAR, @RI_RESERVADO, @RI_CUENTA_DEBITAR, @RI_IMPORTE, @RI_REFERENCIA_UNIVOCA, @RI_CLIENTE_PAGADOR, @RI_INFO_ADICIONAL, @RI_REGISTRO_ADICIONAL, @RI_CONTADOR_REGISTRO);





 
    INSERT INTO dbo.ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX (LINEA) VALUES (replace(@RI_REGISTRO_INDIVIDUAL, ''.'', ''''));
	-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	/* Logica para agregar el registro adicional con el motivo del rechazo*/	
	IF(@Excedente=0 OR @Excedente<99999999)
	BEGIN
		SET @CODIGO_RECHAZO = ''R'' + RIGHT(CONCAT(''00'',@T_MOTIVO_RECHAZO),2);
		SET @TRACE_NUMBER=  RIGHT(CONCAT(''000000000000000'',@T_ID_DEBITO),15); 
		SET @OTRO_RECHAZO = REPLICATE('' '',44);
	
		SET @RI_REGISTRO_INDIVIDUAL_ADICIONAL = concat(''799'',@CODIGO_RECHAZO,@TRACE_NUMBER,''      '',(''0''+LEFT(@T_CBU,7)),@OTRO_RECHAZO,@RI_CONTADOR_REGISTRO);
		INSERT INTO dbo.ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX (LINEA,idSNP_DEBITOS) VALUES (replace(@RI_REGISTRO_INDIVIDUAL_ADICIONAL, ''.'', ''''), @T_ID_DEBITO);
	END

	----------------------------- Actualizar secuencial unico -------------------------------------
	UPDATE dbo.ITF_MASTER_PARAMETROS SET NUMERICO_1 = (NUMERICO_1 + 1) WHERE CODIGO = 147;
	-----------------------------------------------------------------------------------------------

	
	IF (@Excedente = 0)
	BEGIN		     	       				
	
	FETCH NEXT FROM CursorDD INTO @T_ID_DEBITO, @T_JTS_OID, @T_MONEDA, @T_IMPORTE, @T_FECHA_VTO,@T_FECHA_COMP,@T_CBU, @T_REFERENCIA, @T_CODIGO_CLIENTE, @T_CUIT, @T_MOTIVO_RECHAZO,@T_PRESTACION,@RI_INFO_ADICIONAL
	
	SET @CountExcedente = 0;

	END	
END




CLOSE CursorDD
DEALLOCATE CursorDD


IF @SumaSucursal > 9999
BEGIN
	SET @SobranteSucursal = CAST(substring(CAST(@SumaSucursal AS VARCHAR), 1, (len(@SumaSucursal) - 4)) AS NUMERIC);
  	SET @SumaEntidad += @SobranteSucursal;
	SET @SumaSucursal = CAST(RIGHT(@SumaSucursal, 4) AS NUMERIC);
END

	--SET @FL_TOTALES_DE_CONTROL = concat((RIGHT(concat(replicate(''0'', 6), @SumaEntidad), 6)), (RIGHT(concat(replicate(''0'', 4), @SumaSucursal), 4)));
	SET @FL_SUMA_TOTAL_DEBITO_LOTE = RIGHT(concat(replicate(''0'', 12), (replace(@SumaImportes, ''.'', ''''))), 12); 
	SET @FL_SUMA_TOTAL_CREDITO_LOTE = RIGHT(replicate(''0'', 12), 12);
	SET @TotalesDebitos += @SumaImportes;
	SET @FL_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 6), @Cant_Reg_Individual_Adicional+@CantRegistros), 6); 
	
	   	--nuevo
   	SET @FL_TOTALES_DE_CONTROL = (RIGHT(concat(replicate(''0'', 10), (SELECT sum(convert(numeric,substring(linea,4,8)))
																	FROM ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX
																	WHERE LINEA LIKE ''6%'' 
																	AND ID>(SELECT max(id) 
																			FROM ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX 
																			WHERE LINEA LIKE ''5%''))), 10))
	
	
	
     --OJO CON ESTO--
--    SET @CantRegistros = 0;
	SET @Cant_Reg_Individual_Adicional = 0;	

	SET @SumaEntidad_TOT += @SumaEntidad;
	SET @SumaSucursal_TOT += @SumaSucursal;
	
	--OJO CON ESTO X2--
	SET @SumaEntidad = 0;
	SET @SumaSucursal = 0;	
	SET @SumaImportes=0;
	
	SET @FL_FIN_LOTE = concat(@FL_ID_REG, @FL_CODIGO_CLASE_TRANSAC, @FL_CANT_REG_INDIVIDUAL_ADICIONAL, @FL_TOTALES_DE_CONTROL, @FL_SUMA_TOTAL_DEBITO_LOTE, @FL_SUMA_TOTAL_CREDITO_LOTE, @FL_RESERVADO1, @FL_RESERVADO2, @FL_RESERVADO3, @FL_REG_ENTIDAD_ORIGEN, @FL_NUMERO_LOTE);
			
	INSERT INTO dbo.ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX (LINEA) VALUES (replace(@FL_FIN_LOTE, ''.'', ''''));

	---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-------------Grabamos el Fin de Archivo ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--SET @FA_CANT_LOTES = RIGHT(concat(replicate(''0'', 6), @FL_NUMERO_LOTE), 6);
	--SET @CantRegistrosPrev = (SELECT (CASE WHEN (@CantRegistros + 4) % 10 = 0 THEN ((@CantRegistros + 4)/10) ELSE (FLOOR((@CantRegistros + 4)/10) + 1) END));
	--SET @FA_NUMERO_BLOQUES = RIGHT(concat(replicate(''0'', 6), @CantRegistrosPrev+1), 6);

		 SET @FA_CANT_LOTES = RIGHT(concat(replicate(''0'', 6), (SELECT count(*) --le su,o uno al count por la linea que estamos por insertar (9%)
																  FROM ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX 
																  WHERE  LINEA LIKE ''5%'' AND ID>=(SELECT max(id) 
																  		  		FROM ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX 
																  		  		WHERE LINEA LIKE ''1%''))), 6);

	
		 SET @FA_NUMERO_BLOQUES = RIGHT(concat(replicate(''0'', 6), (SELECT floor((count(*)+1)/10)+1 --le su,o uno al count por la linea que estamos por insertar (9%)
																  FROM ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX 
																  WHERE  ID>=(SELECT max(id) 
																  		  		FROM ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX 
																  		  		WHERE LINEA LIKE ''1%''))), 6);
	
	
	
  --			SET @FA_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 8), @CantRegistros), 8);

	
	
	SET @FA_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 8), (SELECT sum(convert(numeric,substring(linea,5,6)))
	  																		 FROM ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX 
																			 WHERE LINEA LIKE ''8%''
																			 AND ID>(SELECT max(ID) FROM ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX WHERE LINEA LIKE ''1%''))), 8);

PRINT  @FA_CANT_REG_INDIVIDUAL_ADICIONAL			
--	SET @FA_TOTALES_DE_CONTROL = concat((RIGHT(concat(replicate(''0'', 6), @SumaEntidad_TOT), 6)), (RIGHT(concat(replicate(''0'', 4), @SumaSucursal_TOT), 4)));; --igualo al totales de control de fin de lote pq tiene que ser igual

   	SET @FA_TOTALES_DE_CONTROL = (RIGHT(concat(replicate(''0'', 10), (SELECT sum(convert(numeric,substring(linea,4,8)))
																	FROM ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX
																	WHERE LINEA LIKE ''6%'' 
																	AND ID>(SELECT max(id) 
																			FROM ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX 
																			WHERE LINEA LIKE ''1%''))), 10))
			
	SET @FA_SUMA_TOTAL_DEBITOS = RIGHT(concat(replicate(''0'', 12), (replace(@TotalesDebitos, ''.'', ''''))), 12);
			
	SET @FA_SUMA_TOTAL_CREDITOS = RIGHT(concat(replicate(''0'', 12), (replace(@TotalesCreditos, ''.'', ''''))),12);
	
	PRINT ''1:''
	PRINT @FA_ID_REG
	PRINT ''2:''
	PRINT @FA_CANT_LOTES
	PRINT ''3:''
	PRINT @FA_NUMERO_BLOQUES
	PRINT ''4:''
	PRINT @FA_CANT_REG_INDIVIDUAL_ADICIONAL
	PRINT ''5:''
	PRINT @FA_TOTALES_DE_CONTROL
	PRINT ''6:''
	PRINT @FA_SUMA_TOTAL_DEBITOS
	PRINT ''7:''
	PRINT @FA_SUMA_TOTAL_CREDITOS
	PRINT ''8:''
	PRINT @FA_RESERVADO

	
	SET @FA_FIN_ARCHIVO = concat(@FA_ID_REG, 
								 @FA_CANT_LOTES, 
								 @FA_NUMERO_BLOQUES, 
								 @FA_CANT_REG_INDIVIDUAL_ADICIONAL, 
								 @FA_TOTALES_DE_CONTROL, 
								 @FA_SUMA_TOTAL_DEBITOS, 
								 @FA_SUMA_TOTAL_CREDITOS, 
								 @FA_RESERVADO);
			
	
	
	INSERT INTO dbo.ITF_DD_PRESENTADOS_RECIBIDOS_ENVIAR_AUX (LINEA) VALUES (@FA_FIN_ARCHIVO);
	
				

	------------------------------------------------------------------------------------------------------------------------------------------------------------------

END');

