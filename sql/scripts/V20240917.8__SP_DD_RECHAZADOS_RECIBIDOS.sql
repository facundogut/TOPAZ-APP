ALTER     PROCEDURE [dbo].[SP_DD_RECHAZADOS_RECIBIDOS]
	@TICKET NUMERIC(16)
AS
BEGIN 

 --	DECLARE 	@TICKET NUMERIC(16)=2
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
	DECLARE @FechaPresentacion DATE;
	DECLARE @FechaCompensacion DATE;
	DECLARE @ClaseTransaccion NUMERIC(3);
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
	DECLARE @Importe NUMERIC(10) = 0;     
	DECLARE @ReferenciaUnivoca VARCHAR(15);
	DECLARE @IdClientePagador VARCHAR(22);
	DECLARE @InfoAdicional VARCHAR(2);
	DECLARE @RegistrosAdicionales VARCHAR(1);
	DECLARE @ContadorRegistros VARCHAR(15);

	DECLARE @CodRechazo VARCHAR (2);

	--SE VAN A USAR ESTOS CAMPOS COMO CLAVE EN LUGAR DEL TRACENUMBER  
	
	DECLARE @Entidad_RI VARCHAR(4);	-- SE CAMBIA TIPO A VARCHAR PORQUE AHORA NO SE VALIDA MAS EL REG INDIVIDUAL
	DECLARE @Sucursal_RI VARCHAR(4); -- SE CAMBIA TIPO A VARCHAR PORQUE AHORA NO SE VALIDA MAS EL REG INDIVIDUAL
	DECLARE @IdClientePagador_RI VARCHAR(4); -- SE CAMBIA TIPO A VARCHAR PORQUE AHORA NO SE VALIDA MAS EL REG INDIVIDUAL
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

	IF(0=(SELECT COUNT(*) FROM ITF_DD_RECHAZADOS_RECIBIDOS_AUX
	WHERE LINEA LIKE '1%'))
	RAISERROR ('Error - Faltan registros.', 16, 1);
	IF(0=(SELECT COUNT(*) FROM ITF_DD_RECHAZADOS_RECIBIDOS_AUX
	WHERE LINEA LIKE '5%'))
	RAISERROR ('Error - Faltan registros.', 16, 1);
	IF(0=(SELECT COUNT(*) FROM ITF_DD_RECHAZADOS_RECIBIDOS_AUX
	WHERE LINEA LIKE '8%'))
	RAISERROR ('Error - Faltan registros.', 16, 1);
	IF(0=(SELECT COUNT(*) FROM ITF_DD_RECHAZADOS_RECIBIDOS_AUX
	WHERE LINEA LIKE '9%'))
	RAISERROR ('Error - Faltan registros.', 16, 1);


	--#validacion2
	IF ((SELECT COUNT(*)
	FROM ITF_DD_RECHAZADOS_RECIBIDOS_AUX
	WHERE LINEA LIKE '1%' OR LINEA LIKE '9%') > 2 )
	RAISERROR('Error - Deben haber solo 1 reg CA y 1 reg FA', 16, 1);


	--#validacion3
	IF(
	(SELECT COUNT(1) as Orden
	WHERE 1=(
	SELECT count(1)
		WHERE EXISTS
	(SELECT CONVERT(INT,SUBSTRING(LINEA,1,1))
		FROM ITF_DD_RECHAZADOS_RECIBIDOS_AUX
		WHERE ID IN
	(SELECT ID-1
			FROM ITF_DD_RECHAZADOS_RECIBIDOS_AUX
			WHERE LINEA LIKE '8%')
			AND CONVERT(INT,SUBSTRING(LINEA,1,1)) NOT IN (5,6,7)
	))
		OR 1=(
	SELECT count(1)
		WHERE
	EXISTS
	(SELECT CONVERT(INT,SUBSTRING(LINEA,1,1))
		FROM ITF_DD_RECHAZADOS_RECIBIDOS_AUX
		WHERE ID IN
	(SELECT ID+1
			FROM ITF_DD_RECHAZADOS_RECIBIDOS_AUX
			WHERE LINEA LIKE '8%')
			AND CONVERT(INT,SUBSTRING(LINEA,1,1)) NOT IN (5,9)
	))
		OR 1=(
	SELECT count(1)
		WHERE
	EXISTS
	(SELECT CONVERT(INT,SUBSTRING(LINEA,1,1))
		FROM ITF_DD_RECHAZADOS_RECIBIDOS_AUX
		WHERE ID IN
	(SELECT ID-1
			FROM ITF_DD_RECHAZADOS_RECIBIDOS_AUX
			WHERE LINEA LIKE '5%')
			AND CONVERT(INT,SUBSTRING(LINEA,1,1)) NOT IN (1,8)
	))
		OR 1=(
	SELECT count(1)
		WHERE
	EXISTS
	(SELECT CONVERT(INT,SUBSTRING(LINEA,1,1))
		FROM ITF_DD_RECHAZADOS_RECIBIDOS_AUX
		WHERE ID IN
	(SELECT ID+1
			FROM ITF_DD_RECHAZADOS_RECIBIDOS_AUX
			WHERE LINEA LIKE '5%')
			AND CONVERT(INT,SUBSTRING(LINEA,1,1)) NOT IN (6,7,8)
	))) <> 0
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
		@sumaDebitos_RI = sum(CAST(substring(LINEA, 30, 10) AS NUMERIC)),
		@sumaEntidades_RI = sum(CAST(substring(LINEA, 4, 4) AS NUMERIC)),
		@sumaSucursales_RI = sum(CAST(substring(LINEA, 8, 4) AS NUMERIC))
	FROM ITF_DD_RECHAZADOS_RECIBIDOS_AUX
	WHERE LINEA LIKE '6%' --OR LINEA LIKE '7%';

	/*SELECT --creditos
		@sumaCreditos_RI = sum(CAST(substring(LINEA, 30, 10) AS NUMERIC)),
		@sumaEntidades_RIaux = sum(CAST(substring(LINEA, 4, 4) AS NUMERIC)),
		@sumaSucursales_RIaux = sum(CAST(substring(LINEA, 8, 4) AS NUMERIC))
	FROM ITF_DD_RECHAZADOS_RECIBIDOS_AUX
	WHERE LINEA LIKE '622%';*/

	SET @sumaEntidades_RI += isNull(@sumaEntidades_RIaux,0);
	SET @sumaSucursales_RI += isNull(@sumaSucursales_RIaux,0);
	
	--seteo total control y total de importes FA
	SELECT
		@totControl_FA = CAST(substring(linea, 22, 10) AS NUMERIC),
		@totalDebitos_FA = CAST(substring(linea, 32, 12) AS NUMERIC),
		@totalCreditos_FA = CAST(substring(linea, 44, 12) AS NUMERIC)
	FROM ITF_DD_RECHAZADOS_RECIBIDOS_AUX
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
		@controlDebitos_FL = sum(CAST(substring(LINEA, 21, 12) AS NUMERIC)),
		@controlCreditos_FL = sum(CAST(substring(LINEA, 33, 12) AS NUMERIC))
	FROM ITF_DD_RECHAZADOS_RECIBIDOS_AUX
	WHERE LINEA LIKE '8%';

	--#validacion5
	IF(CONCAT(@sumaEntidades_RI, RIGHT(CONCAT(REPLICATE('0',3), @sumaSucursales_RI ),4)) <> @sumaTotalCtrl_FL)
	RAISERROR('No concuerda la suma Ent/Suc con control FL', 16, 1);
	--#validacion7
	IF(RIGHT(@sumaTotalCtrl_FL,10) <> @totControl_FA)
	RAISERROR('No concuerda la suma de TotalesControl de FL con control FA', 16, 1);


	--#validacion6 debitos
	IF(@sumaDebitos_RI <> @totalDebitos_FA OR @controlDebitos_FL <> @totalDebitos_FA)
	RAISERROR('No concuerda la suma de Debitos individuales con el Total Debitos', 16, 1);

	--#validacion6 creditos
	IF( 0 <> @controlCreditos_FL OR 0 <> @totalCreditos_FA)
	RAISERROR(' Total Creditos incorrectos ', 16, 1);


	--#validacion8
   /*	IF((@controlDebitos_FL + @controlCreditos_FL) <>  (@totalDebitos_FA + @totalCreditos_FA))
	RAISERROR('No concuerda la suma de Debitos de FL con Total Importe FA', 16, 1);
*/

	--fin----validaciones #5 #6 #7 y #8





	DECLARE @LINEA VARCHAR(95);
	DECLARE deb_cursor CURSOR FOR 
SELECT LINEA
	FROM dbo.ITF_DD_RECHAZADOS_RECIBIDOS_AUX

	OPEN deb_cursor

	FETCH NEXT FROM deb_cursor INTO @LINEA

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
      
			--variables de cabecera de archivo
			SET @CodigoPrioridad = substring(@LINEA,2,2);
			SET @DestinoInmediato = substring(@LINEA,4 ,10);
			SET @FechaVencimiento = CONVERT(DATE, substring(@LINEA, 24, 6), 12);
			SET @HoraPresentacion = substring(@LINEA, 30, 4);
			SET @IdentificadorArchivo = substring(@LINEA, 34, 1);
			SET @TamanoRegistro = substring(@LINEA, 35, 3);
			SET @FactorBloque = substring(@LINEA, 38, 2);
			SET @CodigoFormato = substring(@LINEA, 40, 1);
			SET @NombreDestinoInmediato = substring(@LINEA, 41, 23);
			SET @NombreOrigenInmediato = substring(@LINEA, 64, 23);
			SET @CodigoReferencia = substring(@LINEA, 87, 8);


			IF(@CodigoPrioridad<>'01')
			RAISERROR ('Codigo Prioridad debe ser 01', 16, 1);
			

			IF(@TamanoRegistro<>'094')
			RAISERROR ('Tamaño registro debe ser 094', 16, 1);
			
			IF(@FactorBloque<>'10')
			RAISERROR ('Factor Bloque debe ser 10', 16, 1);
			
						
			IF(@CodigoFormato<>'1')
			RAISERROR ('Codigo Formato debe ser 1', 16, 1);
			
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

			SET @FechaVencimiento = CONVERT(DATE, substring(@LINEA, 64, 6), 12);
			--VALIDACION FECHAS
			SET @FechaCompensacion = CAST(substring(@LINEA, 70, 6) AS DATE);
			SET @ReservadoLoteCeros = substring(@LINEA, 76, 3);
			--VALIDACION RESERVADO 000
			SET @CodigoOrigen = substring(@LINEA, 79, 1);

			SET @IdEntidadOrigen = substring(@LINEA, 80, 8);

			SET @NumeroLote = substring(@LINEA, 88, 7);

			IF (@ClaseTransaccion <> 200) 
      		RAISERROR ('Codigo de clase de transaccion debe ser 200', 16, 1);
			

			IF (@CodigoRegistro <> 'PPD') 
    		RAISERROR ('Codigo de registro debe ser TRC', 16, 1);
			

			IF (@FechaVencimiento > @FechaCompensacion) 
      		RAISERROR ('Fecha Presentacion debe ser anterior a vencimiento', 16, 1);
		
			
		END


		/*FIN DE LOTE*/
		IF (@IdRegistro = '8') 
      BEGIN
			SET @ClaseTransaccion = substring(@LINEA, 2, 3);
			--SET @RegIndivAdic = substring(@LINEA, 5, 6);
			--SET @TotalesControl = substring(@LINEA, 11,10);
			SET @ReservadoFL = substring(@LINEA, 45, 35);
			SET @IdEntidadOrigen = substring(@LINEA, 80, 8);
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
			SET @ReservadoFA  = substring(@LINEA, 56, 39);

			--#validacion9
			IF(@ExisteRI = 1 AND (SELECT COUNT(*) FROM ITF_DD_RECHAZADOS_RECIBIDOS_AUX WHERE LINEA LIKE '5%') <> @CantLotesFA)
				RAISERROR('No coincide la cantidad de LOTES con la informada en el reg FA', 16, 1);
			
			--#validacion10
			IF((SELECT count(*) FROM ITF_DD_RECHAZADOS_RECIBIDOS_AUX WHERE LINEA LIKE '6%' OR LINEA LIKE '7%') <> @CantRegAdFA)
				RAISERROR('No coincide la cantidad de registros ind y ad con la informada en el reg FA', 16, 1);

		END


		/* Registro Individual */
		IF (@IdRegistro = '6') 
        BEGIN
      		SET @ExisteRI = 1;
      		
			SET @CodTransaccion = substring(@LINEA, 2, 2);
			SET @EntidadDebitar = substring(@LINEA, 4, 8);
			SET @ReservadoRI = substring(@LINEA, 12, 1);
			SET @CuentaDebitar = substring(@LINEA, 13, 16);
			SET @Importe = CONVERT(NUMERIC(15,2),substring(@LINEA, 30, 10))/100;
			SET @ReferenciaUnivoca = substring(@LINEA, 40, 15);
			SET @IdClientePagador = substring(@LINEA, 55, 22);
			SET @InfoAdicional = substring(@LINEA, 77, 2);
			SET @RegistrosAdicionales = substring(@LINEA, 79, 1);
			SET @ContadorRegistros = substring(@LINEA, 80, 15);
			/* Trace Number */


			SET @Entidad_RI = substring(@ContadorRegistros, 1, 4);
			SET @Sucursal_RI = substring(@ContadorRegistros, 5, 4);
			SET @IdClientePagador_RI = RIGHT(@IdClientePagador, 4);
			SET @NumeroCuenta_RI = RIGHT(@CuentaDebitar, 12);
			SET @ReferenciaUnivoca_RI = RIGHT(@ReferenciaUnivoca, 12);


			IF (@RegistrosAdicionales NOT IN('1','0')) 
      		BEGIN
				RAISERROR ('Campo Registro adicional invalido', 16, 1);
			END
		END
		
				/* Registro Rechazo */
		IF (@IdRegistro = '7' AND substring(@LINEA, 2, 2)='99') 
      	BEGIN
      	
		IF(@TICKET>0)
		BEGIN
		
			
			  DECLARE @NumCuenta NUMERIC(20);
			  DECLARE @JTS_OID NUMERIC(20);
		      DECLARE @Moneda INT;
		      IF(LEFT(@InfoAdicional,1)=0)
				SET @Moneda = (SELECT C6399 FROM MONEDAS WHERE C6403='N');
		      IF(LEFT(@InfoAdicional,1)=1)
				SET @Moneda = (SELECT C6399 FROM MONEDAS WHERE C6403='D');
		   
		      SET @NumCuenta = CAST(@CuentaDebitar AS NUMERIC);
		      
		      SET @JTS_OID = (SELECT JTS_OID FROM SALDOS WHERE CUENTA = @NumCuenta AND SUCURSAL = CONVERT(INT,RIGHT(@EntidadDebitar,4)) AND MONEDA=@Moneda);
			  
			  --SELECT substring(@LINEA, 4, 3) AS LINEA,@NumCuenta AS NumCuenta, @JTS_OID AS JTS_OID, CONVERT(INT,RIGHT(@EntidadDebitar,4)) AS SUCURSAL,
			  --@Moneda AS Moneda

			 				
		      UPDATE dbo.SNP_DEBITOS
			  SET ESTADO = 'RC', MOTIVO_RECHAZO = (SELECT TOP 1 id_motivo FROM snp_motivos_rechazo WHERE CODIGO_NACHA=substring(@LINEA, 4, 3) AND FUNCIONALIDAD='DD' AND TZ_LOCK=0)
			  WHERE ID_DEBITO = (SELECT TOP 1 ID_DEBITO 
			  					 FROM SNP_DEBITOS 
			  					 WHERE SALDO_JTS_OID = @JTS_OID 
--			  					 AND IMPORTE = @Importe 
--			  					 AND MONEDA = @Moneda 
								 AND REFERENCIA=@ReferenciaUnivoca
			  					 AND FECHA_VTO = @FechaVencimiento 
			  					 AND FECHA_COMP =@FechaCompensacion 
			  					 AND ESTADO<>'RC');
			
			  UPDATE SNP_MSG_ORDENES
			  SET ESTADO='RC', MOTIVO_RECHAZO = (SELECT TOP 1 id_motivo FROM snp_motivos_rechazo WHERE CODIGO_NACHA=substring(@LINEA, 4, 3) AND FUNCIONALIDAD='DD' AND TZ_LOCK=0)
			  WHERE (TRACE_N_1PRE=substring(@LINEA,7,15) 
			  		 OR TRACE_N_2PRE=substring(@LINEA,7,15))
--			  		 AND CLIENTE_PAGADOR=@IdClientePagador
					 AND REFERENCIA=@ReferenciaUnivoca
					 AND (FECHA_VENCIMIENTO=@FechaVencimiento OR SEGUNDO_VTO=@FechaVencimiento)			 
--			  		 AND (PRESENTACION_PRIMER_VTO=@FechaVencimiento OR PRESENTACION_SEGUNDO_VTO=@FechaVencimiento)
			  		 AND ESTADO<>'RC'
			  		 
			  UPDATE SNP_ADHESIONES
			  SET ESTADO='RC', MOTIVO_RECHAZO = (SELECT TOP 1 id_motivo FROM snp_motivos_rechazo WHERE CODIGO_NACHA=substring(@LINEA, 4, 3) AND FUNCIONALIDAD='DD' AND TZ_LOCK=0), FECHA_RECHAZO=@FechaCompensacion
			  WHERE TRACKNUMBER=substring(@LINEA,7,15)  

			  INSERT INTO dbo.ITF_DD_RECHAZOS_RECIBIDOS (ID_TICKET,  FECHAPROCESO, CODIGO_TRANSACCION, SUCURSAL, MONEDA, CUENTA, IMPORTE,  REFERENCIA_UNIVOCA, ID_CLIENTE_PAGADOR,  MOTIVO_RECHAZO, INFO_ADICIONAL)
       		  VALUES (@TICKET, (SELECT FECHAPROCESO FROM PARAMETROS), @CodTransaccion, CONVERT(INT,RIGHT(@EntidadDebitar,4)), @Moneda, @CuentaDebitar, @Importe,  @ReferenciaUnivoca, @IdClientePagador,  (SELECT TOP 1 id_motivo FROM snp_motivos_rechazo WHERE CODIGO_NACHA=substring(@LINEA, 4, 3) AND FUNCIONALIDAD='DD' AND TZ_LOCK=0) ,@InfoAdicional);

		END
		
		END
		

		Final:
		FETCH NEXT FROM deb_cursor INTO @LINEA
	END

	CLOSE deb_cursor
	DEALLOCATE deb_cursor
-- a ordenes entramos con cliente pagador, fecha presentacion 1 o 2 y tracenumber, estado rc y motivo rechazo
END;
GO

