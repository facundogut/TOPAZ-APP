ALTER    PROCEDURE [dbo].[SP_CLS_TRANS_RECHAZ_PESOS]
	@TICKET NUMERIC(16),
	@MENSAJE_ERROR VARCHAR(max) OUT
AS
BEGIN

	------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--- Created: /03/2023 10:00 a.m.
	--- Autor: Juan Pedrozo
	------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--- Modificado: Fabio Menendez 18/10/2023
	
	-- Cerrar el cursor si está abierto
	IF CURSOR_STATUS('global', 'cls_trans') >= 0
	BEGIN
	    IF CURSOR_STATUS('global', 'cls_trans') = 1
	    BEGIN
	        CLOSE cls_trans;
	    	DEALLOCATE cls_trans;
	    END
    END 
    
	SET @MENSAJE_ERROR = '';

	/******** Variables Cabecera de Archivo **********************************/
	DECLARE @IdRegistro VARCHAR(1);
	DECLARE @CodigoPrioridad VARCHAR(2);
	DECLARE @DestinoInmediato VARCHAR(10);
	DECLARE @OrigenInmediato VARCHAR(10);
	DECLARE @FechaPresentacion DATE; --reutilizo la variable mas adelante
	DECLARE @HoraPresentacion NUMERIC(4);
	DECLARE @IdentificadorArchivo VARCHAR(1);
	DECLARE @TamanoRegistro NUMERIC(3);
	DECLARE @FactorBloque NUMERIC(2);
	DECLARE @CodigoFormato VARCHAR(1);
	DECLARE @NombreDestinoInmediato VARCHAR(23);
	DECLARE @NombreOrigenInmediato VARCHAR(23);
	DECLARE @CodigoReferencia VARCHAR(8);

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
	DECLARE @Importe NUMERIC(10) = 0;     
	DECLARE @ReferenciaUn VARCHAR(15);
	DECLARE @CodigoPostal VARCHAR(6);
	DECLARE @PuntoIntercambio VARCHAR(16);
	DECLARE @InfoAdicional VARCHAR(2);
	DECLARE @RegistrosAdicionales VARCHAR(1);
	DECLARE @ContadorRegistros VARCHAR(15);
	DECLARE @CodRechazo VARCHAR (3); 
	
	/******** Variables Registro adicional de rechazos de órdenes de transferencia *************/
	 DECLARE @TraceNumber VARCHAR(15);	

	--SE VAN A USAR ESTOS CAMPOS COMO CLAVE EN LUGAR DEL TRACENUMBER  
	
	DECLARE @Entidad_RI VARCHAR(4);	-- SE CAMBIA TIPO A VARCHAR PORQUE AHORA NO SE VALIDA MAS EL REG INDIVIDUAL
	DECLARE @Sucursal_RI VARCHAR(4); -- SE CAMBIA TIPO A VARCHAR PORQUE AHORA NO SE VALIDA MAS EL REG INDIVIDUAL
	DECLARE @CodigoPostal_RI VARCHAR(4); -- SE CAMBIA TIPO A VARCHAR PORQUE AHORA NO SE VALIDA MAS EL REG INDIVIDUAL
	DECLARE @NumeroCuenta_RI VARCHAR(12); -- SE CAMBIA TIPO A VARCHAR PORQUE AHORA NO SE VALIDA MAS EL REG INDIVIDUAL
	DECLARE @NumeroCheque_RI VARCHAR(12); -- SE CAMBIA TIPO A VARCHAR PORQUE AHORA NO SE VALIDA MAS EL REG INDIVIDUAL

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
	DECLARE @CantRegAdFA VARCHAR (8);
	DECLARE @TotalesControlFA NUMERIC(10);
	DECLARE @ReservadoFA VARCHAR(39);

	/*Validaciones generales */
	
	DECLARE @updRecepcion VARCHAR(1);

	IF(0=(SELECT COUNT(*) FROM ITF_TRANS_PESOS_RECHAZ_AUX
		WHERE LINEA LIKE '1%'))   		
   			SET @MENSAJE_ERROR = 'Error - Faltan registros.';   	   
	IF(0=(SELECT COUNT(*) FROM ITF_TRANS_PESOS_RECHAZ_AUX
	WHERE LINEA LIKE '5%'))
   			SET @MENSAJE_ERROR = 'Error - Faltan registros.';
	IF(0=(SELECT COUNT(*) FROM ITF_TRANS_PESOS_RECHAZ_AUX
	WHERE LINEA LIKE '8%'))
   			SET @MENSAJE_ERROR = 'Error - Faltan registros.';
	IF(0=(SELECT COUNT(*) FROM ITF_TRANS_PESOS_RECHAZ_AUX
	WHERE LINEA LIKE '9%'))
   			SET @MENSAJE_ERROR = 'Error - Faltan registros.';


	--#validacion2
	IF ((SELECT COUNT(*)
	FROM ITF_TRANS_PESOS_RECHAZ_AUX
	WHERE LINEA LIKE '1%' OR LINEA LIKE '9%') > 2 )
	 SET @MENSAJE_ERROR = 'Error - Deben haber solo 1 reg CA y 1 reg FA';


	--#validacion3
	IF(
	(SELECT COUNT(1) as Orden
	WHERE 1=(
	SELECT count(1)
		WHERE EXISTS
	(SELECT CONVERT(INT,SUBSTRING(LINEA,1,1))
		FROM ITF_TRANS_PESOS_RECHAZ_AUX
		WHERE ID IN
	(SELECT ID-1
			FROM ITF_TRANS_PESOS_RECHAZ_AUX
			WHERE LINEA LIKE '8%')
			AND CONVERT(INT,SUBSTRING(LINEA,1,1)) NOT IN (5,6,7)
	))
		OR 1=(
	SELECT count(1)
		WHERE
	EXISTS
	(SELECT CONVERT(INT,SUBSTRING(LINEA,1,1))
		FROM ITF_TRANS_PESOS_RECHAZ_AUX
		WHERE ID IN
	(SELECT ID+1
			FROM ITF_TRANS_PESOS_RECHAZ_AUX
			WHERE LINEA LIKE '8%')
			AND CONVERT(INT,SUBSTRING(LINEA,1,1)) NOT IN (5,9)
	))
		OR 1=(
	SELECT count(1)
		WHERE
	EXISTS
	(SELECT CONVERT(INT,SUBSTRING(LINEA,1,1))
		FROM ITF_TRANS_PESOS_RECHAZ_AUX
		WHERE ID IN
	(SELECT ID-1
			FROM ITF_TRANS_PESOS_RECHAZ_AUX
			WHERE LINEA LIKE '5%')
			AND CONVERT(INT,SUBSTRING(LINEA,1,1)) NOT IN (1,8)
	))
		OR 1=(
	SELECT count(1)
		WHERE
	EXISTS
	(SELECT CONVERT(INT,SUBSTRING(LINEA,1,1))
		FROM ITF_TRANS_PESOS_RECHAZ_AUX
		WHERE ID IN
	(SELECT ID+1
			FROM ITF_TRANS_PESOS_RECHAZ_AUX
			WHERE LINEA LIKE '5%')
			AND CONVERT(INT,SUBSTRING(LINEA,1,1)) NOT IN (6,7,8)
	))) <> 0
	)
	 SET @MENSAJE_ERROR ='Error: el orden de los registros NACHA es incorrecto.';



	------validaciones #5 #6 #7 y #8

	--#5 y 7
	DECLARE @sumaEntidades_RI NUMERIC = 0;
	DECLARE @sumaSucursales_RI NUMERIC = 0;
	
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
	FROM ITF_TRANS_PESOS_RECHAZ_AUX
	WHERE LINEA LIKE '6%';

   	
	--seteo total control y total de importes FA
	SELECT
		@totControl_FA = CAST(substring(linea, 22, 10) AS NUMERIC),
		@totalDebitos_FA = CAST(substring(linea, 32, 12) AS NUMERIC),
		@totalCreditos_FA = CAST(substring(linea, 44, 12) AS NUMERIC)
	FROM ITF_TRANS_PESOS_RECHAZ_AUX
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
	FROM ITF_TRANS_PESOS_RECHAZ_AUX
	WHERE LINEA LIKE '8%';


	--#validacion5
	IF(CONCAT(@sumaEntidades_RI, RIGHT(CONCAT(REPLICATE('0',3), @sumaSucursales_RI ),4)) <> @sumaTotalCtrl_FL)	
	SET @MENSAJE_ERROR = 'No concuerda la suma Ent/Suc con control FL';
   
	
	 	
	--#validacion7
	/*--OPH22112023  Se comenta porque se agregar el kettle principal estandar de validacion
	IF(@sumaTotalCtrl_FL <> @totControl_FA)
	SET @MENSAJE_ERROR = 'No concuerda la suma de TotalesControl de FL con control FA';
	*/


/* 	ACA HAY QUE PREGUNTAR COMO SE VA A DIFERENCIAR ENTRE LOS CREDITOS Y DEBITOS DEL REGISTRO INDIVIDUAL

	--#validacion6 debitos
	IF(@sumaDebitos_RI  <> @controlDebitos_FL AND @sumaDebitos_RI <> @totalDebitos_FA)
	RAISERROR('No concuerda la suma de Debitos individuales con el Total Debitos', 16, 1);

	--#validacion6 creditos
	IF( @sumaCreditos_RI <> @controlCreditos_FL AND @sumaCreditos_RI <> @totalCreditos_FA)
	RAISERROR('No concuerda la suma de Creditos individuales con el Total Creditos ', 16, 1);
*/


	--#validacion8
	IF((@controlDebitos_FL + @controlCreditos_FL) <>  (@totalDebitos_FA + @totalCreditos_FA))
  		SET @MENSAJE_ERROR = 'No concuerda la suma de Debitos de FL con Total Importe FA';


	--fin----validaciones #5 #6 #7 y #8




	DECLARE @ID VARCHAR(95);
	DECLARE @LINEA VARCHAR(95);
	DECLARE cls_trans CURSOR FOR 
SELECT ID, LINEA
	FROM dbo.ITF_TRANS_PESOS_RECHAZ_AUX

	OPEN cls_trans

	FETCH NEXT FROM cls_trans INTO @ID, @LINEA

	WHILE @@FETCH_STATUS = 0  
BEGIN


		--#validacion4
		if(DATALENGTH(@LINEA) <> 94)
		SET @MENSAJE_ERROR = 'Se encontraron registros de longitud incorrecta';

		SET @IdRegistro = substring(@LINEA, 1, 1);

		IF(@IdRegistro NOT IN('1','5','6','7','8','9') ) --validacion de id reg
      	SET @MENSAJE_ERROR = 'Id Registro invalido';


		/* Cabecera de Archivo */
		IF (@IdRegistro = '1') 
      BEGIN
			--variables de cabecera de archivo
			SET @CodigoPrioridad = substring(@LINEA,2,2);
			SET @DestinoInmediato = substring(@LINEA,4 ,10);
			SET @FechaPresentacion = substring(@LINEA, 24, 6);
			SET @HoraPresentacion = substring(@LINEA, 30, 4);
			SET @IdentificadorArchivo = substring(@LINEA, 34, 1);
			SET @TamanoRegistro = substring(@LINEA, 35, 3);
			SET @FactorBloque = substring(@LINEA, 38, 2);
			SET @CodigoFormato = substring(@LINEA, 40, 1);
			SET @NombreDestinoInmediato = substring(@LINEA, 41, 23);
			SET @NombreOrigenInmediato = substring(@LINEA, 64, 23);
			SET @CodigoReferencia = substring(@LINEA, 87, 8);


			IF (@IdentificadorArchivo NOT IN ('A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','0','1','2','3','4','5','6','7','8','9')) 
			SET @MENSAJE_ERROR = 'Identificador Archivo invalido';


/* por ahora no
			--#validacion11
			IF(substring(@DestinoInmediato, 2, 4) <> '0811')
			RAISERROR ('Destino inmediato debe ser 0811', 16, 1);
*/
		END

		IF (@IdRegistro = '5') 
      BEGIN

			--variables cabecera de lote
			SET @ClaseTransaccion = substring(@LINEA, 2, 3);
			SET @ReservadoLote = substring(@LINEA, 5, 46);
			--VALIDACION RESERVADO VACIO
			SET @CodigoRegistro = substring(@LINEA, 51, 3);

			SET @FechaPresentacion = CONVERT(DATETIME,substring(@LINEA, 64, 6),103);
			--VALIDACION FECHAS
			SET @FechaVencimiento = CONVERT(DATETIME,substring(@LINEA, 70, 6),103);
			SET @ReservadoLoteCeros = substring(@LINEA, 76, 3);
			--VALIDACION RESERVADO 000
			SET @CodigoOrigen = substring(@LINEA, 79, 1);

			SET @IdEntidadOrigen = substring(@LINEA, 80, 8);

			SET @NumeroLote = substring(@LINEA, 88, 7);

			
			

			IF (@FechaPresentacion > @FechaVencimiento) 
      			SET @MENSAJE_ERROR = 'Fecha Presentacion debe ser anterior a vencimiento';
		

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
			IF(@ExisteRI = 1 AND (SELECT COUNT(*) FROM ITF_TRANS_PESOS_RECHAZ_AUX WHERE LINEA LIKE '5%') <> @CantLotesFA)
			   SET @MENSAJE_ERROR = 'No coincide la cantidad de LOTES con la informada en el reg FA';
		
			--#validacion10
			IF((SELECT count(*) FROM ITF_TRANS_PESOS_RECHAZ_AUX WHERE LINEA LIKE '6%' OR LINEA LIKE '7%') <> @CantRegAdFA)
				SET @MENSAJE_ERROR = 'No coincide la cantidad de registros ind y ad con la informada en el reg FA';
		  
		END

		--Registro ind adicional--
		IF(@IdRegistro = '7' AND substring(@LINEA, 2 , 2) = '99')
		BEGIN
			--SET @CodRechazo = substring(@LINEA, 5, 2);
			SET @TraceNumber = substring(@LINEA, 7, 15)
		   --IF(@MENSAJE_ERROR = '') --NO HAY ERRORES NACHA 			
				--UPDATE SNP_TRANSFERENCIAS SET MOTIVO_RECHAZO = @CodRechazo WHERE id_transferencia = CAST(@ReferenciaUn AS NUMERIC) AND TZ_LOCK = 0;	   		
		

		END


		/* Registro Individual */
		IF (@IdRegistro = '6') 
      BEGIN
      		SET @ExisteRI = 1;
      		
			SET @CodTransaccion = substring(@LINEA, 2, 2);
			SET @EntidadDebitar = substring(@LINEA, 4, 8);
			SET @ReservadoRI = substring(@LINEA, 12, 1);
			SET @CuentaDebitar = substring(@LINEA, 13, 17);
			SET @Importe = substring(@LINEA, 30, 10);
			SET @ReferenciaUn = substring(@LINEA, 40, 15);
			SET @CodigoPostal = substring(@LINEA, 55, 6);
			SET @PuntoIntercambio = substring(@LINEA, 61, 16);
			SET @InfoAdicional = substring(@LINEA, 77, 2);
			SET @RegistrosAdicionales = substring(@LINEA, 79, 1);
			SET @ContadorRegistros = substring(@LINEA, 80, 15);
			/* Trace Number */


			SET @Entidad_RI = substring(@ContadorRegistros, 1, 4);
			SET @Sucursal_RI = substring(@ContadorRegistros, 5, 4);
			SET @CodigoPostal_RI = RIGHT(@CodigoPostal, 4);
			SET @NumeroCuenta_RI = RIGHT(@CuentaDebitar, 12);
		   	DECLARE @MONEDA NUMERIC(1,0);
		   	
		   	

			IF(LEFT(@EntidadDebitar,4)='0311')
			BEGIN
			  	SET @MONEDA = (SELECT C6399 FROM MONEDAS WHERE C6403='N' AND tz_lock=0);
			END
			 ELSE
			BEGIN
			 	SET @MONEDA = (SELECT C6399 FROM MONEDAS WHERE C6403='D' AND tz_lock=0);
			END

			IF (@RegistrosAdicionales NOT IN('1','0'))       		
			   SET @MENSAJE_ERROR = 'Campo Registro adicional invalido';
		   
		   IF(@RegistrosAdicionales='1')
			BEGIN
--				SET @CodRechazo = (SELECT TOP 1 SUBSTRING(LINEA,4,3) FROM ITF_TRANS_PESOS_RECHAZ_AUX WHERE ID>@ID AND LINEA LIKE '799%');
				SET @CodRechazo = (SELECT TOP 1 ID_MOTIVO from  SNP_MOTIVOS_RECHAZO WHERE CODIGO_NACHA=(SELECT TOP 1 SUBSTRING(LINEA,4,3) FROM ITF_TRANS_PESOS_RECHAZ_AUX WHERE ID>@ID AND LINEA LIKE '799%') AND funcionalidad='TR')
			
			END

			--- Variables Generales ---
			DECLARE @NRO_DPF_CHEQUE NUMERIC(12);
			DECLARE @BANCO_GIRADO NUMERIC(4);
			DECLARE @SUCURSAL_BANCO NUMERIC(5);
			DECLARE @TIPO_DOCUMENTO VARCHAR(4);
			DECLARE @IMPORTE_TOTAL NUMERIC(12);
			DECLARE @SERIE_DEL_CHEQUE VARCHAR(6);
			DECLARE @NRO_CUENTA NUMERIC(12);
			DECLARE @CODIGO_POSTAL NUMERIC(4);		
			DECLARE @EXISTE NUMERIC(4) = 0;
			DECLARE @ORDINAL NUMERIC(12);
			
			
			IF(@MENSAJE_ERROR = '') --NO HAY ERRORES NACHA 	 
			BEGIN 
				DECLARE @FECHADATE DATETIME;
		  		SET @FECHADATE = (SELECT FECHAPROCESO FROM PARAMETROS);

				UPDATE dbo.VTA_TRANSFERENCIAS
				SET ESTADO = 'RC' , FECHA_ESTADO=@FECHADATE , NUMERO_ASIENTO=@TICKET, MOTIVO_RECHAZO=@CodRechazo
				WHERE OP_CLASE_TRANS = 'E' 
				   AND OP_MONEDA=@MONEDA 
				   AND OP_FECHA_PRES = @FechaPresentacion
				   AND TRACENUMBER = @TraceNumber 
			END
		END

		FETCH NEXT FROM cls_trans INTO @ID, @LINEA
	END

	CLOSE cls_trans
	DEALLOCATE cls_trans

END;
GO

