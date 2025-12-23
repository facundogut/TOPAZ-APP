ALTER           PROCEDURE [dbo].[SP_TRAN_MINORISTA_RECIBIDAS]
	@TICKET NUMERIC(16),
	@MONEDA_IN NUMERIC(1),
	@CODREGISTRO_IN VARCHAR(3),
	@ARCHIVO VARCHAR(30)
	, @MSJ 	VARCHAR(500) OUTPUT
AS
BEGIN 
    -- Cerrar el cursor si está abierto
	IF CURSOR_STATUS('global', 'tran_cursor') >= 0
	BEGIN
	    IF CURSOR_STATUS('global', 'tran_cursor') = 1
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
	

	/******** Variables Cabecera de Lote **********************************/
	DECLARE @FechaVencimiento DATE;
	DECLARE @FechaCompensacion DATE;
	DECLARE @VFechaVencimiento VARCHAR(6);
	DECLARE @VFechaCompensacion VARCHAR(6);
	DECLARE @ClaseTransaccion VARCHAR(3);
	DECLARE @ReservadoLote VARCHAR(46);
	DECLARE @nombreEO VARCHAR(16)
	DECLARE @Tipo_Transferencia_CL VARCHAR(3);
	DECLARE @CodigoOrigen  NUMERIC(1);
	DECLARE @CodigoRegistro VARCHAR(3);
	DECLARE @IdEntidadOrigen NUMERIC(8);
	declare @NumeroLote NUMERIC(7);
	DECLARE @IdEmpresa VARCHAR(10);
		DECLARE @CUIT_EO NUMERIC(11,0);
			
	/******** Variables Registro Individual de Cheques y Ajustes *************/
	DECLARE @CodTransaccion VARCHAR(2);
	DECLARE @EntidadDebitar VARCHAR(8);
	DECLARE @BenBanco NUMERIC(6,0);
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
	DECLARE @CUIL VARCHAR(11);
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
	
	DECLARE @correlativo NUMERIC(10,0)=0;

	SET @MSJ = '';
	
	
	
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
		IF (@IdRegistro = '1') 
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
		END

		IF (@IdRegistro = '5') 
      	BEGIN

			--variables cabecera de lote
			SET @ClaseTransaccion = substring(@LINEA, 2, 3);
			SET @ReservadoLote = substring(@LINEA, 5, 46);
			SET @nombreEO = substring(@LINEA, 5, 16);
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


			SET @NumeroLote = substring(@LINEA, 88, 7);			
			
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

		END

		/* Registro Individual */
		IF (@IdRegistro = '6') 
      	BEGIN
      		SET @ExisteRI = 1;
      		--PRINT @LINEA
			SET @CodTransaccion = substring(@LINEA, 2, 2);
			SET @EntidadDebitar = substring(@LINEA, 4, 8);
			--PRINT @EntidadDebitar
			SET @ReservadoRI = substring(@LINEA, 12, 1);
			SET @CuentaDebitar = substring(@LINEA, 13, 17);
			SET @VImporte = substring(@LINEA, 30, 10);
			--SET @Importe = CONVERT(NUMERIC(15,2),@VImporte)/100;
			SET @ReferenciaUnivoca = substring(@LINEA, 40, 15);
			SET @IdClientePegador = substring(@LINEA, 55, 22);
			SET @cuil = try_convert(NUMERIC(11),substring(@IdClientePegador,2,11))
			SET @Operatoria_BCRA = substring(@LINEA, 74, 3);
			SET @InfoAdicional = substring(@LINEA, 77, 2);
			
			
			SET @RegistrosAdicionales = substring(@LINEA, 79, 1);
			SET @ContadorRegistros = substring(@LINEA, 80, 15);
			SET @Tipo_transferencia = (SELECT  top 1 ID_TIPO FROM VTA_TRANSFERENCIAS_TIPOS WHERE ADICIONAL_PRESENT=@InfoAdicional AND tz_lock=0);
			/* Trace Number */
			
			
			IF(@RegistrosAdicionales='1')
			BEGIN
				SET @CBU = CONCAT(substring(@LINEA, 5, 7), substring(@LINEA, 16, 12));
				SELECT @IdEmpresa=try_convert(NUMERIC,SUBSTRING(LINEA,4,11))
						, @nombreEO=SUBSTRING(LINEA,15,22)  
				FROM ITF_TRAN_MINORISTA_RECIBIDAS_AUX 
				WHERE ID=@ID+1
			END
			
			--bloque nuevo ji
			
			
			DECLARE @E01 INT = 10-((CONVERT(INT, '3')*7+
			CONVERT(INT, '1')*1+
			CONVERT(INT, '1')*3+
			CONVERT(INT, SUBSTRING(@EntidadDebitar, 5, 1))*9+
			CONVERT(INT, SUBSTRING(@EntidadDebitar, 6, 1))*7+
			CONVERT(INT, SUBSTRING(@EntidadDebitar, 7, 1))*1+
			CONVERT(INT, SUBSTRING(@EntidadDebitar, 8, 1))*3)%10)
	
			SET @CBU=concat('3',RIGHT(@EntidadDebitar,6),RIGHT(convert(VARCHAR(2),@E01),1),substring(@LINEA,16,14))	
			

			--hasta aca ji
		
			
			
			
			SET @Entidad_RI = substring(@ContadorRegistros, 1, 4);
			SET @Sucursal_RI = substring(@ContadorRegistros, 5, 4);
			SET @IdClientePegador_RI = RIGHT(@IdClientePegador, 4);
			SET @NumeroCuenta_RI = LEFT(RIGHT(@CuentaDebitar, 12),11);
			SET @ReferenciaUnivoca_RI = RIGHT(@ReferenciaUnivoca, 12);
	 		
	 		DECLARE @Moneda INT;
		    IF(LEFT(@InfoAdicional,1)='0')
				SET @Moneda = (SELECT top 1 C6399 FROM MONEDAS WHERE C6403='N');
		    IF(LEFT(@InfoAdicional,1)='1')
				SET @Moneda = (SELECT top 1 C6399 FROM MONEDAS WHERE C6403='D');
	
	------------Fin Primera Validacion ----------------
	 	
			IF(@TICKET>0)
			BEGIN
	
				IF( UPPER(SUBSTRING(@ARCHIVO,1,2))='MR') --logica para la 2.8.19
				BEGIN

					SELECT try_convert(NUMERIC,SUBSTRING(LINEA,7,15)) FROM ITF_TRAN_MINORISTA_RECIBIDAS_AUX WHERE ID=@ID+1
					UPDATE VTA_TRANSFERENCIAS
					SET ESTADO='RC'
			 			, MOTIVO_RECHAZO=(SELECT SUBSTRING(LINEA,5,2) FROM ITF_TRAN_MINORISTA_RECIBIDAS_AUX WHERE ID=@ID+1)
					WHERE tracenumber=(SELECT try_convert(NUMERIC,SUBSTRING(LINEA,7,15)) FROM ITF_TRAN_MINORISTA_RECIBIDAS_AUX WHERE ID=@ID+1)
					AND OP_CLASE_TRANS='E'
				
					GOTO Final
	   			END
	
				BEGIN TRY

--		PRINT LEFT(@IdClientePegador,11)
	   	  DECLARE @FECHADATE DATETIME;
		  SET @FECHADATE = (SELECT top 1 FECHAPROCESO FROM PARAMETROS);
		  DECLARE @JTS_OID NUMERIC(10,0) = (SELECT top 1 JTS_OID_SALDO FROM VTA_SALDOS WHERE CTA_CBU=@CBU AND tz_lock=0);
	      
	      ----------------------- VALIDACIONES INCLUYENTES------------------------
	      ------------------------------------------------------------------------
	      --PRINT @CodTransaccion
	      --Rechazos
	      --IF @CodTransaccion='31' OR @CodTransaccion='37' 
	      IF @moneda_in=0 AND @CODREGISTRO_IN='CTX' AND LEFT(@infoadicional,1)='0' AND RIGHT(@infoadicional,1) IN ('7','8','D')
	      BEGIN
	      	PRINT 'codigo rechazo:';
	      	PRINT @CodRechazo;
	      	
	      	--(SELECT try_convert(NUMERIC(15),substring(linea,4,15)) FROM ITF_TRAN_MINORISTA_RECIBIDAS_AUX WHERE ID=@id+1 AND LINEA LIKE '7%')
	      	
	      	--UPDATE dbo.VTA_TRANSFERENCIAS
			--SET ESTADO = 'RC' , FECHA_ESTADO=@FECHADATE , NUMERO_ASIENTO=@TICKET, MOTIVO_RECHAZO=@CodRechazo, OPERATORIA_BCRA=@Operatoria_BCRA, FCH_DEV_REC=@FECHACOMPENSACION
			--WHERE OP_CLASE_TRANS = 'E' 
			--AND BEN_CBU = @CBU  
			--AND OP_MONEDA=@Moneda 
			--AND OP_NUMERO=LTRIM(RIGHT(@ReferenciaUnivoca,12))	
				
			--*** agregado el 16/06/2024***--
			UPDATE dbo.VTA_TRANSFERENCIAS
			SET ESTADO = 'RC' 
				, FECHA_ESTADO=@FECHADATE 
				, NUMERO_ASIENTO=@TICKET
				, MOTIVO_RECHAZO=@CodRechazo
				, OPERATORIA_BCRA=@Operatoria_BCRA
				, FCH_DEV_REC=@FECHACOMPENSACION
			WHERE TRACENUMBER=(SELECT try_convert(NUMERIC(15),substring(linea,18,15)) 
								FROM ITF_TRAN_MINORISTA_RECIBIDAS_AUX 
								WHERE ID=@id+1 
								AND LINEA LIKE '7%')
			AND OP_NUMERO=LTRIM(RIGHT(@ReferenciaUnivoca,12))
			AND OP_CLASE_TRANS = 'E'
			--*****************************--
			GOTO Final
	      END
	      
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
			 OR LEFT(@Tipo_Transferencia_CL,1)!='0'
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
											, BEN_TIPO_DOC )
				VALUES ((SELECT ISNULL(MAX(OP_NUMERO),0)+1 FROM VTA_TRANSFERENCIAS WHERE OP_CLASE_TRANS='R'),
						 @TICKET, 
						 @FECHADATE, 
						 'R', 
						 'RC', 
						 @Moneda, 
						 @Tipo_transferencia, 
						 @CBU, 
						 @VImporte, 
						 @JTS_OID, 
						 @CUIL,
						 (SELECT top 1 CODIGO_NACHA FROM CLE_TIPO_CAUSAL WHERE CODIGO_DE_CAUSAL = 32), 
						 'C' , 
						 @FECHADATE, 
						 'N', 
						 RTRIM(LTRIM(@ReferenciaUnivoca)),
						 @OPERATORIA_BCRA
						 , @FECHACOMPENSACION
						 , TRY_CONVERT(NUMERIC(15),@ContadorRegistros)
						 						 , try_convert(NUMERIC(11,0),@IdEmpresa)
						 , @nombreEO
						 , @BenBanco
						 , CASE WHEN substring (@CUIL,1,1)='2' THEN 'CUIL' ELSE 'CUIT' END
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
											, BEN_TIPO_DOC )
				VALUES ((SELECT ISNULL(MAX(OP_NUMERO),0)+1 FROM VTA_TRANSFERENCIAS WHERE OP_CLASE_TRANS='R'),
						 @TICKET, 
						 @FECHADATE, 
						 'R', 
						 'RC', 
						 @Moneda, 
						 @Tipo_transferencia, 
						 @CBU, 
						 @VImporte, 
						 @JTS_OID, 
						 @CUIL,
						 (SELECT top 1 CODIGO_NACHA FROM CLE_TIPO_CAUSAL WHERE CODIGO_DE_CAUSAL = 71), 
						 'C' , 
						 @FECHADATE, 
						 'N', 
						 RTRIM(LTRIM(@ReferenciaUnivoca)),
						 @OPERATORIA_BCRA
						 , @FECHACOMPENSACION
						 , TRY_CONVERT(NUMERIC(15),@ContadorRegistros)
						 						 , try_convert(NUMERIC(11,0),@IdEmpresa)
						 , @nombreEO
						 , @BenBanco
						 , CASE WHEN substring (@CUIL,1,1)='2' THEN 'CUIL' ELSE 'CUIT' END
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
											, BEN_TIPO_DOC )
				VALUES ((SELECT ISNULL(MAX(OP_NUMERO),0)+1 FROM VTA_TRANSFERENCIAS WHERE OP_CLASE_TRANS='R'),@TICKET, @FECHADATE, 'R', 'RC', @Moneda, @Tipo_transferencia, @CBU, @VImporte, @JTS_OID, @CUIL,(SELECT top 1 CODIGO_NACHA FROM CLE_TIPO_CAUSAL WHERE CODIGO_DE_CAUSAL = 39), 'C' , @FECHADATE, 'N', RTRIM(LTRIM(@ReferenciaUnivoca)),@OPERATORIA_BCRA, @FECHACOMPENSACION, TRY_CONVERT(NUMERIC(15),@ContadorRegistros)
										 , try_convert(NUMERIC(11,0),@IdEmpresa)
						 , @nombreEO
						 , @BenBanco
						 , CASE WHEN substring (@CUIL,1,1)='2' THEN 'CUIL' ELSE 'CUIT' END
						 )
	      	GOTO Final
		  	END 
--tenemos que ver esto ticket NBCHSEG-8397

		  
	      DECLARE @NumCuenta NUMERIC(20);
	      
		  SET @NumCuenta = CAST(LEFT(RIGHT(@CuentaDebitar, 12),11) AS NUMERIC);
		  SET @Importe = CONVERT(NUMERIC(15),@VImporte)/100;
		  --------------
		  ----NACHA R04
		  --------------
		  
--		  DECLARE @V04 NUMERIC(2);
	      
	   	  
--		  IF (ISNUMERIC(@CuentaDebitar) = 0)
--	      BEGIN
--	      		INSERT INTO dbo.VTA_TRANSFERENCIAS (OP_NUMERO, NUMERO_ASIENTO,  OP_FECHA_PRES, OP_CLASE_TRANS, ESTADO, OP_MONEDA, OP_TIPO, BEN_CBU, OP_IMPORTE, BEN_JTS_OID_CUENTA, BEN_NRO_DOC, MOTIVO_RECHAZO, OP_FORMA_ING, FECHA_ESTADO, CONTABILIZADA , OP_INFO_REF,OPERATORIA_BCRA, FCH_DEV_REC, TRACENUMBER )
--				VALUES ((SELECT ISNULL(MAX(OP_NUMERO),0)+1 FROM VTA_TRANSFERENCIAS WHERE OP_CLASE_TRANS='R'), @TICKET, @FECHADATE, 'R', 'RC', @Moneda, @Tipo_transferencia, @CBU, @Importe, @JTS_OID, @CUIL,(SELECT CODIGO_NACHA FROM CLE_TIPO_CAUSAL WHERE CODIGO_DE_CAUSAL = 4), 'C' , @FECHADATE, 'N', RTRIM(LTRIM(@ReferenciaUnivoca)),@OPERATORIA_BCRA, @FECHACOMPENSACION, TRY_CONVERT(NUMERIC(15),@ContadorRegistros));
--
--	      	GOTO Final
--	      END


		  --------------
		  ----NACHA R13
		  --------------


		  IF (SELECT count(sucursal) FROM SUCURSALES WHERE sucursal=CONVERT(INT,RIGHT(@EntidadDebitar,4)) AND TZ_LOCK=0)=0
	      BEGIN
	      		INSERT INTO dbo.VTA_TRANSFERENCIAS (OP_NUMERO, NUMERO_ASIENTO,  OP_FECHA_PRES, OP_CLASE_TRANS, ESTADO, OP_MONEDA, OP_TIPO, BEN_CBU, OP_IMPORTE, BEN_JTS_OID_CUENTA, BEN_NRO_DOC, MOTIVO_RECHAZO, OP_FORMA_ING, FECHA_ESTADO, CONTABILIZADA, OP_INFO_REF,OPERATORIA_BCRA, FCH_DEV_REC, TRACENUMBER 
	      													, ORD_NRO_DOC
											, ORD_NOMBRE
											, BEN_BANCO
											, BEN_TIPO_DOC )
				VALUES ((SELECT ISNULL(MAX(OP_NUMERO),0)+1 FROM VTA_TRANSFERENCIAS WHERE OP_CLASE_TRANS='R'),@TICKET, @FECHADATE, 'R', 'RC', @Moneda, @Tipo_transferencia, @CBU, @Importe, @JTS_OID, @CUIL,(SELECT top 1 CODIGO_NACHA FROM CLE_TIPO_CAUSAL WHERE CODIGO_DE_CAUSAL = 18), 'C' , @FECHADATE, 'N', RTRIM(LTRIM(@ReferenciaUnivoca)),@OPERATORIA_BCRA, @FECHACOMPENSACION, TRY_CONVERT(NUMERIC(15),@ContadorRegistros)
										 , try_convert(NUMERIC(11,0),@IdEmpresa)
						 , @nombreEO
						 , @BenBanco
						 , CASE WHEN substring (@CUIL,1,1)='2' THEN 'CUIL' ELSE 'CUIT' END
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
											, BEN_TIPO_DOC )
				VALUES ((SELECT ISNULL(MAX(OP_NUMERO),0)+1 FROM VTA_TRANSFERENCIAS WHERE OP_CLASE_TRANS='R'),@TICKET, @FECHADATE, 'R', 'RC', @Moneda, @Tipo_transferencia, @CBU, @Importe, @JTS_OID, @CUIL,(SELECT top 1 CODIGO_NACHA FROM CLE_TIPO_CAUSAL WHERE CODIGO_DE_CAUSAL = 93), 'C' , @FECHADATE, 'N', RTRIM(LTRIM(@ReferenciaUnivoca)),@OPERATORIA_BCRA, @FECHACOMPENSACION, TRY_CONVERT(NUMERIC(15),@ContadorRegistros)
										 , try_convert(NUMERIC(11,0),@IdEmpresa)
						 , @nombreEO
						 , @BenBanco
						 , CASE WHEN substring (@CUIL,1,1)='2' THEN 'CUIL' ELSE 'CUIT' END
						 )

	      	GOTO Final
	      END


	      --------------
	      ----NACHA R23
	      --------------
	      
	      SELECT @ESTADOSUC = ESTADO 
	      FROM SUCURSALESSC
	      WHERE SUCURSAL = CONVERT(INT,RIGHT(@EntidadDebitar,4));
	      
	      IF @ESTADOSUC <> 'A'
	      BEGIN
	      		INSERT INTO dbo.VTA_TRANSFERENCIAS (OP_NUMERO, NUMERO_ASIENTO,  OP_FECHA_PRES, OP_CLASE_TRANS, ESTADO, OP_MONEDA, OP_TIPO, BEN_CBU, OP_IMPORTE, BEN_JTS_OID_CUENTA, BEN_NRO_DOC, MOTIVO_RECHAZO, OP_FORMA_ING, FECHA_ESTADO, CONTABILIZADA, OP_INFO_REF,OPERATORIA_BCRA, FCH_DEV_REC, TRACENUMBER 
	      													, ORD_NRO_DOC
											, ORD_NOMBRE
											, BEN_BANCO
											, BEN_TIPO_DOC )
				VALUES ((SELECT ISNULL(MAX(OP_NUMERO),0)+1 FROM VTA_TRANSFERENCIAS WHERE OP_CLASE_TRANS='R'), @TICKET, @FECHADATE, 'R', 'RC', @Moneda, @Tipo_transferencia, @CBU, @Importe, @JTS_OID, @CUIL,(SELECT CODIGO_NACHA FROM CLE_TIPO_CAUSAL WHERE CODIGO_DE_CAUSAL = 95), 'C' , @FECHADATE, 'N', RTRIM(LTRIM(@ReferenciaUnivoca)),@OPERATORIA_BCRA, @FECHACOMPENSACION, TRY_CONVERT(NUMERIC(15),@ContadorRegistros)
										 , try_convert(NUMERIC(11,0),@IdEmpresa)
						 , @nombreEO
						 , @BenBanco
						 , CASE WHEN substring (@CUIL,1,1)='2' THEN 'CUIL' ELSE 'CUIT' END
						 )
	      	GOTO Final
	      END
	      
	      --------------
	      ----NACHA R75
	      --------------
	      
	      
		  IF ISDATE(@VFechaVencimiento) = 0 OR ISDATE(@VFechaCompensacion) = 0 OR ISDATE(@VFechaVencimientoCA) = 0
	      BEGIN
	             
	      		INSERT INTO dbo.VTA_TRANSFERENCIAS (OP_NUMERO, NUMERO_ASIENTO,  OP_FECHA_PRES, OP_CLASE_TRANS, ESTADO, OP_MONEDA, OP_TIPO, BEN_CBU, OP_IMPORTE, BEN_JTS_OID_CUENTA, BEN_NRO_DOC, MOTIVO_RECHAZO, OP_FORMA_ING, FECHA_ESTADO, CONTABILIZADA, OP_INFO_REF,OPERATORIA_BCRA, FCH_DEV_REC, TRACENUMBER 
	      													, ORD_NRO_DOC
											, ORD_NOMBRE
											, BEN_BANCO
											, BEN_TIPO_DOC )
				VALUES ((SELECT ISNULL(MAX(OP_NUMERO),0)+1 FROM VTA_TRANSFERENCIAS WHERE OP_CLASE_TRANS='R'),@TICKET, @FECHADATE, 'R', 'RC', @Moneda, @Tipo_transferencia, @CBU, @Importe, @JTS_OID, @CUIL,(SELECT top 1 CODIGO_NACHA FROM CLE_TIPO_CAUSAL WHERE CODIGO_DE_CAUSAL = 58), 'C' , @FECHADATE, 'N', RTRIM(LTRIM(@ReferenciaUnivoca)),@OPERATORIA_BCRA, @FECHACOMPENSACION, TRY_CONVERT(NUMERIC(15),@ContadorRegistros)
										 , try_convert(NUMERIC(11,0),@IdEmpresa)
						 , @nombreEO
						 , @BenBanco
						 , CASE WHEN substring (@CUIL,1,1)='2' THEN 'CUIL' ELSE 'CUIT' END
						 )
	      	GOTO Final
	      END
	      

		  --------------
		  ----NACHA R03
		  --------------
			
		  IF (SELECT count(jts_oid_saldo) FROM vta_saldos WHERE cta_cbu=@cbu AND TZ_LOCK=0)=0
	      BEGIN
	      		INSERT INTO dbo.VTA_TRANSFERENCIAS (OP_NUMERO, NUMERO_ASIENTO,  OP_FECHA_PRES, OP_CLASE_TRANS, ESTADO, OP_MONEDA, OP_TIPO, BEN_CBU, OP_IMPORTE, BEN_JTS_OID_CUENTA, BEN_NRO_DOC, MOTIVO_RECHAZO, OP_FORMA_ING, FECHA_ESTADO, CONTABILIZADA, OP_INFO_REF,OPERATORIA_BCRA, FCH_DEV_REC, TRACENUMBER 
	      													, ORD_NRO_DOC
											, ORD_NOMBRE
											, BEN_BANCO
											, BEN_TIPO_DOC )
				VALUES ((SELECT ISNULL(MAX(OP_NUMERO),0)+1 FROM VTA_TRANSFERENCIAS WHERE OP_CLASE_TRANS='R'),@TICKET, @FECHADATE, 'R', 'RC', @Moneda, @Tipo_transferencia, @CBU, @Importe, @JTS_OID, @CUIL,(SELECT top 1 CODIGO_NACHA FROM CLE_TIPO_CAUSAL WHERE CODIGO_DE_CAUSAL = 3), 'C' , @FECHADATE, 'N', RTRIM(LTRIM(@ReferenciaUnivoca)),@OPERATORIA_BCRA, @FECHACOMPENSACION, TRY_CONVERT(NUMERIC(15),@ContadorRegistros)
										 , try_convert(NUMERIC(11,0),@IdEmpresa)
						 , @nombreEO
						 , @BenBanco
						 , CASE WHEN substring (@CUIL,1,1)='2' THEN 'CUIL' ELSE 'CUIT' END
						 )
	      	GOTO Final
	      END
    
		
		  --------------
		  ----NACHA R40
		  --------------
		  DECLARE @V40 NUMERIC;
		  DECLARE @cuit VARCHAR(20);	 
--		    PRINT @linea	  
--			PRINT LEFT(@IDCLIENTEPEGADOR,11)
			
IF (LEFT(@IDCLIENTEPEGADOR,1) IN ('1','2','3') AND LEN(REPLACE(substring(@IDCLIENTEPEGADOR,2,11),' ',''))=11)
	SET @cuit=substring(@IDCLIENTEPEGADOR,2,11)
ELSE
begin 
	SET @cuit=(SELECT TOP 1 NUMERODOC 
				FROM VW_CLIENTES_PERSONAS 
				WHERE CODIGOCLIENTE=(SELECT c1803 
					 					FROM SALDOS 
										WHERE JTS_OID=(SELECT TOP 1 JTS_OID_SALDO 
														FROM VTA_SALDOS 
														WHERE CTA_CBU=@cbu))
				AND titularidad='T')
END

		  SET @V40=(SELECT COUNT(1) 
		  			FROM SALDOS s 
					JOIN cli_clientepersona cp ON s.C1803 = cp.CODIGOCLIENTE
					JOIN CLI_DocumentosPFPJ fj ON fj.NUMEROPERSONAFJ = cp.NUMEROPERSONA
					WHERE cp.TITULARIDAD = 'T'
					AND S.CUENTA=@NumCuenta
					AND FJ.NUMERODOCUMENTO=@cuit
					AND s.TZ_LOCK=0
					AND cp.TZ_LOCK=0
					AND fj.TZ_LOCK=0
					)
					
--					PRINT 'ACA'
--					PRINT @cbu
--					PRINT @NumCuenta
--					PRINT @cuit
		  IF @V40=0
		  BEGIN
	      		INSERT INTO dbo.VTA_TRANSFERENCIAS (OP_NUMERO, NUMERO_ASIENTO,  OP_FECHA_PRES, OP_CLASE_TRANS, ESTADO, OP_MONEDA, OP_TIPO, BEN_CBU, OP_IMPORTE, BEN_JTS_OID_CUENTA, BEN_NRO_DOC, MOTIVO_RECHAZO, OP_FORMA_ING, FECHA_ESTADO, CONTABILIZADA, OP_INFO_REF,OPERATORIA_BCRA, FCH_DEV_REC, TRACENUMBER 
	      													, ORD_NRO_DOC
											, ORD_NOMBRE
											, BEN_BANCO
											, BEN_TIPO_DOC )
				VALUES ((SELECT ISNULL(MAX(OP_NUMERO),0)+1 FROM VTA_TRANSFERENCIAS WHERE OP_CLASE_TRANS='R'),@TICKET, @FECHADATE, 'R', 'RC', @Moneda, @Tipo_transferencia, @CBU, @Importe, @JTS_OID, @CUIL,40, 'C' , @FECHADATE, 'N', RTRIM(LTRIM(@ReferenciaUnivoca)),@OPERATORIA_BCRA, @FECHACOMPENSACION, TRY_CONVERT(NUMERIC(15),@ContadorRegistros)
										 , try_convert(NUMERIC(11,0),@IdEmpresa)
						 , @nombreEO
						 , @BenBanco
						 , CASE WHEN substring (@CUIL,1,1)='2' THEN 'CUIL' ELSE 'CUIT' END
						 )
	      	GOTO Final
	      END
	      
	      
	      
	      
	      
					

   
    






	      --------------
	      --NACHA R15
	      --------------
	      /*
	      DECLARE @V15 NUMERIC(3);
	      
	      SELECT @V15 = COUNT(1)
		  FROM SNP_PRESTACIONES_EMPRESAS
		  WHERE ENTIDAD = @IdEntidadOrigen;
		  
	      IF (@V15 = 0)
	      BEGIN
	      		INSERT INTO dbo.VTA_TRANSFERENCIAS (OP_NUMERO, NUMERO_ASIENTO,  OP_FECHA_PRES, OP_CLASE_TRANS, ESTADO, OP_MONEDA, OP_TIPO, BEN_CBU, OP_IMPORTE, BEN_JTS_OID_CUENTA, BEN_NRO_DOC, MOTIVO_RECHAZO, OP_FORMA_ING, FECHA_ESTADO, CONTABILIZADA, OP_INFO_REF )
				VALUES ((SELECT MAX(OP_NUMERO)+1 FROM VTA_TRANSFERENCIAS), @TICKET, @FECHADATE, 'R', 'RC', 1, @Tipo_transferencia, @CBU, @VImporte, @JTS_OID, @CUIL,(SELECT CODIGO_NACHA FROM CLE_TIPO_CAUSAL WHERE CODIGO_DE_CAUSAL = 92), 'C' , @FECHADATE, 'N', RTRIM(LTRIM(@ReferenciaUnivoca)));

	      	GOTO Final
	      END
	      */

	      
	      --------------
	      ----NACHA R20
	      --------------
	      
	      DECLARE @MonedaCta NUMERIC(2);
	      DECLARE @TipoCuenta VARCHAR(2);
	      --DECLARE @NroCuenta NUMERIC(11);
		  DECLARE @Cod_Cliente NUMERIC(20);
		  DECLARE @saldo_jts_oid NUMERIC(15);
	      
	      --SET @NumCuenta = CAST(@CuentaDebitar AS NUMERIC);
	      SET @NumCuenta = CAST(LEFT(RIGHT(@CuentaDebitar, 12),11) AS NUMERIC);
	      SET @TipoCuenta = SUBSTRING(@CuentaDebitar,4,2);
	      
	      SELECT @MonedaCta = MONEDA,
	      	@Cod_Cliente = C1803,
			@saldo_jts_oid = JTS_OID
	      FROM SALDOS 
	      WHERE CUENTA = @NumCuenta 
	        AND SUCURSAL = CONVERT(INT,RIGHT(@EntidadDebitar,4))
	        --AND C1785 = @TipoCuenta
	        AND C1785 = (CASE WHEN TRY_CAST(@TipoCuenta AS NUMERIC) = 11 OR TRY_CAST(@TipoCuenta AS NUMERIC) = 15 THEN 3 
	        				  WHEN TRY_CAST(@TipoCuenta AS NUMERIC) = 1 OR TRY_CAST(@TipoCuenta AS NUMERIC) = 7 THEN 2
	        			 END)
            AND MONEDA = (CASE WHEN TRY_CAST(@TipoCuenta AS NUMERIC) = 11 OR TRY_CAST(@TipoCuenta AS NUMERIC) = 1 THEN 1 
            				   WHEN TRY_CAST(@TipoCuenta AS NUMERIC) = 15 OR TRY_CAST(@TipoCuenta AS NUMERIC) = 7 THEN 2 END)
	        AND TZ_LOCK = 0;

	      IF( @Moneda <> ISNULL(@MonedaCta,99) )
	      BEGIN
--	      PRINT @Moneda
--	      PRINT @EntidadDebitar
--	      PRINT @TipoCuenta
    
	      		INSERT INTO dbo.VTA_TRANSFERENCIAS (OP_NUMERO, NUMERO_ASIENTO,  OP_FECHA_PRES, OP_CLASE_TRANS, ESTADO, OP_MONEDA, OP_TIPO, BEN_CBU, OP_IMPORTE, BEN_JTS_OID_CUENTA, BEN_NRO_DOC, MOTIVO_RECHAZO, OP_FORMA_ING, FECHA_ESTADO, CONTABILIZADA, OP_INFO_REF,OPERATORIA_BCRA, FCH_DEV_REC, TRACENUMBER 
	      													, ORD_NRO_DOC
											, ORD_NOMBRE
											, BEN_BANCO
											, BEN_TIPO_DOC )
				VALUES ((SELECT ISNULL(MAX(OP_NUMERO),0)+1 FROM VTA_TRANSFERENCIAS WHERE OP_CLASE_TRANS='R'), @TICKET, @FECHADATE, 'R', 'RC', @Moneda, @Tipo_transferencia, @CBU, @Importe, @JTS_OID, @CUIL,(SELECT top 1 CODIGO_NACHA FROM CLE_TIPO_CAUSAL WHERE CODIGO_DE_CAUSAL = 94), 'C' , @FECHADATE, 'N', RTRIM(LTRIM(@ReferenciaUnivoca)),@OPERATORIA_BCRA, @FECHACOMPENSACION, TRY_CONVERT(NUMERIC(15),@ContadorRegistros)
										 , try_convert(NUMERIC(11,0),@IdEmpresa)
						 , @nombreEO
						 , @BenBanco
						 , CASE WHEN substring (@CUIL,1,1)='2' THEN 'CUIL' ELSE 'CUIT' END
						 )

	      	GOTO Final
	      END
	      
		  --------------
		  ----NACHA R45
		  --------------
		  
		  IF @CODREGISTRO_IN='CCD' AND (SELECT TOP 1 PRODUCTO FROM SALDOS NOLOCK  WHERE CUENTA=@NUMcUENTA AND TZ_LOCK=0) NOT IN (1,3,4,6,9,10,23)--(SELECT C6250 FROM productos NOLOCK WHERE TIPO_CUENTA_VISTA IN (7,11,5,8) AND TZ_LOCK=0)
			BEGIN 
	      		INSERT INTO dbo.VTA_TRANSFERENCIAS (OP_NUMERO, NUMERO_ASIENTO,  OP_FECHA_PRES, OP_CLASE_TRANS, ESTADO, OP_MONEDA, OP_TIPO, BEN_CBU, OP_IMPORTE, BEN_JTS_OID_CUENTA, BEN_NRO_DOC, MOTIVO_RECHAZO, OP_FORMA_ING, FECHA_ESTADO, CONTABILIZADA, OP_INFO_REF,OPERATORIA_BCRA, FCH_DEV_REC, TRACENUMBER 
	      													, ORD_NRO_DOC
											, ORD_NOMBRE
											, BEN_BANCO
											, BEN_TIPO_DOC )
				VALUES ((SELECT ISNULL(MAX(OP_NUMERO),0)+1 FROM VTA_TRANSFERENCIAS WHERE OP_CLASE_TRANS='R'), @TICKET, @FECHADATE, 'R', 'RC', @Moneda, @Tipo_transferencia, @CBU, @Importe, @JTS_OID, @CUIL,45, 'C' , @FECHADATE, 'N', RTRIM(LTRIM(@ReferenciaUnivoca)),@OPERATORIA_BCRA, @FECHACOMPENSACION, TRY_CONVERT(NUMERIC(15),@ContadorRegistros)
										 , try_convert(NUMERIC(11,0),@IdEmpresa)
						 , @nombreEO
						 , @BenBanco
						 , CASE WHEN substring (@CUIL,1,1)='2' THEN 'CUIL' ELSE 'CUIT' END
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
	      
	      --SET @V93 = (SELECT COUNT(1) FROM FERIADOS WHERE (SUCURSAL=CONVERT(INT,RIGHT(@EntidadDebitar,4)) OR SUCURSAL=-1) AND DIA=FORMAT(@FECHADATE,'dd') AND MES=FORMAT(@FECHADATE,'MM') AND (ANIO=FORMAT(@FECHADATE,'yyyy') OR ANIO=0)); 
	      SET @V93 = (SELECT COUNT(1) FROM FERIADOS WHERE (SUCURSAL=CONVERT(INT,RIGHT(@EntidadDebitar,4)) OR SUCURSAL=-1) AND DIA=FORMAT(@FechaVencimientoCA,'dd') AND MES=FORMAT(@FechaVencimientoCA,'MM') AND (ANIO=FORMAT(@FechaVencimientoCA,'yyyy') OR ANIO=0)); 

	      IF (@V93 > 0)
	      BEGIN
	      		INSERT INTO dbo.VTA_TRANSFERENCIAS (OP_NUMERO, NUMERO_ASIENTO,  OP_FECHA_PRES, OP_CLASE_TRANS, ESTADO, OP_MONEDA, OP_TIPO, BEN_CBU, OP_IMPORTE, BEN_JTS_OID_CUENTA, BEN_NRO_DOC, MOTIVO_RECHAZO, OP_FORMA_ING, FECHA_ESTADO, CONTABILIZADA, OP_INFO_REF,OPERATORIA_BCRA, FCH_DEV_REC, TRACENUMBER 
	      													, ORD_NRO_DOC
											, ORD_NOMBRE
											, BEN_BANCO
											, BEN_TIPO_DOC )
				VALUES ((SELECT ISNULL(MAX(OP_NUMERO),0)+1 FROM VTA_TRANSFERENCIAS WHERE OP_CLASE_TRANS='R'),@TICKET, @FECHADATE, 'R', 'RC', @Moneda, @Tipo_transferencia, @CBU, @Importe, @JTS_OID, @CUIL,(SELECT top 1 CODIGO_NACHA FROM CLE_TIPO_CAUSAL WHERE CODIGO_DE_CAUSAL = 76), 'C' , @FECHADATE, 'N', RTRIM(LTRIM(@ReferenciaUnivoca)),@OPERATORIA_BCRA, @FECHACOMPENSACION, TRY_CONVERT(NUMERIC(15),@ContadorRegistros)
										 , @IdEmpresa
						 , @nombreEO
						 , @BenBanco
						 , CASE WHEN substring (@CUIL,1,1)='2' THEN 'CUIL' ELSE 'CUIT' END
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

--		  IF (convert(NUMERIC(1,0),RIGHT(@CUIT_EO,1))<>@codigoOrigen)
--		  IF (@CodigoOrigen!=0 AND dbo.validarCuit(@cuit_eo)=0) ESTE ES UN POSIBLE CAMBIO PARA QUE CAPTURE CORRECTAMENTE EL R76
--		  IF (@CodigoOrigen!=0 AND (@cuit_eo NOT IN (SELECT CUIT_EO FROM SNP_PRESTACIONES_EMPRESAS WHERE ENTIDAD = @IdEntidadOrigen)))
	      IF (@CodigoOrigen!=0 AND (dbo.validarCuit(@cuit_eo)=0)) --or @cuit_eo not in (select cuit from itf_bcra_padfyj)
	      BEGIN
	      		INSERT INTO dbo.VTA_TRANSFERENCIAS (OP_NUMERO, NUMERO_ASIENTO,  OP_FECHA_PRES, OP_CLASE_TRANS, ESTADO, OP_MONEDA, OP_TIPO, BEN_CBU, OP_IMPORTE, BEN_JTS_OID_CUENTA, BEN_NRO_DOC, MOTIVO_RECHAZO, OP_FORMA_ING, FECHA_ESTADO, CONTABILIZADA, OP_INFO_REF,OPERATORIA_BCRA, FCH_DEV_REC, TRACENUMBER 
	      													, ORD_NRO_DOC
											, ORD_NOMBRE
											, BEN_BANCO
											, BEN_TIPO_DOC )
				VALUES ((SELECT ISNULL(MAX(OP_NUMERO),0)+1 FROM VTA_TRANSFERENCIAS WHERE OP_CLASE_TRANS='R'),@TICKET, @FECHADATE, 'R', 'RC', @Moneda, @Tipo_transferencia, @CBU, @Importe, @JTS_OID, @CUIL,(SELECT top 1 CODIGO_NACHA FROM CLE_TIPO_CAUSAL WHERE CODIGO_DE_CAUSAL = 59), 'C' , @FECHADATE, 'N', RTRIM(LTRIM(@ReferenciaUnivoca)),@OPERATORIA_BCRA, @FECHACOMPENSACION, TRY_CONVERT(NUMERIC(15),@ContadorRegistros)
										 , try_convert(NUMERIC(11,0),@IdEmpresa)
						 , @nombreEO
						 , @BenBanco
						 , CASE WHEN substring (@CUIL,1,1)='2' THEN 'CUIL' ELSE 'CUIT' END
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
	      			  AND OP_TIPO=@Tipo_transferencia OR @Tipo_transferencia IS NULL
	      			  AND BEN_CBU= @CBU);

		  
		  IF (@V24 > 0)
	      BEGIN
	      		INSERT INTO dbo.VTA_TRANSFERENCIAS (OP_NUMERO, NUMERO_ASIENTO,  OP_FECHA_PRES, OP_CLASE_TRANS, ESTADO, OP_MONEDA, OP_TIPO, BEN_CBU, OP_IMPORTE, BEN_JTS_OID_CUENTA, BEN_NRO_DOC, MOTIVO_RECHAZO, OP_FORMA_ING, FECHA_ESTADO, CONTABILIZADA, OP_INFO_REF,OPERATORIA_BCRA, FCH_DEV_REC, TRACENUMBER
	      													, ORD_NRO_DOC
											, ORD_NOMBRE
											, BEN_BANCO
											, BEN_TIPO_DOC ) 
				VALUES ((SELECT ISNULL(MAX(OP_NUMERO),0)+1 FROM VTA_TRANSFERENCIAS WHERE OP_CLASE_TRANS='R'),@TICKET, @FECHADATE, 'R', 'RC', @Moneda, @Tipo_transferencia, @CBU, @Importe, @JTS_OID, @CUIL,(SELECT top 1 CODIGO_NACHA FROM CLE_TIPO_CAUSAL WHERE CODIGO_DE_CAUSAL = 36), 'C' , @FECHADATE, 'N', RTRIM(LTRIM(@ReferenciaUnivoca)),@OPERATORIA_BCRA, @FECHACOMPENSACION
						, TRY_CONVERT(NUMERIC(15),@ContadorRegistros)
												 , try_convert(NUMERIC(11,0),@IdEmpresa)
						 , @nombreEO
						 , @BenBanco
						 , CASE WHEN substring (@CUIL,1,1)='2' THEN 'CUIL' ELSE 'CUIT' END
						 );
	      	GOTO Final
	      END
	     
	      --------------
	      ----NACHA R91
	      --------------
	      
		  IF((LEFT(@EntidadDebitar,4)='0311' AND LEFT(@InfoAdicional,1)<>'0') OR (LEFT(@EntidadDebitar,4)='0811' AND LEFT(@InfoAdicional,1)<>'1'))
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
											, BEN_TIPO_DOC )
				VALUES ((SELECT ISNULL(MAX(OP_NUMERO),0)+1 FROM VTA_TRANSFERENCIAS WHERE OP_CLASE_TRANS='R')
						, @TICKET
						, @FECHADATE
						, 'R'
						, 'RC'
						, @Moneda
						, @Tipo_transferencia
						, @CBU
						, @Importe
						, @JTS_OID
						, @CUIL
						,(SELECT top 1 CODIGO_NACHA FROM CLE_TIPO_CAUSAL WHERE CODIGO_DE_CAUSAL = 74)
						, 'C' 
						, @FECHADATE
						, 'N'
						, RTRIM(LTRIM(@ReferenciaUnivoca))
						,@OPERATORIA_BCRA
						, @FECHACOMPENSACION
						, TRY_CONVERT(NUMERIC(15),@ContadorRegistros)
						 , try_convert(NUMERIC(11,0),@IdEmpresa)
						 , @nombreEO
						 , @BenBanco
						 , CASE WHEN substring (@CUIL,1,1)='2' THEN 'CUIL' ELSE 'CUIT' END
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
											--, FCH_DEV_REC
											, TRACENUMBER
											, ORD_NRO_DOC
											, ORD_NOMBRE
											, BEN_BANCO
											, BEN_TIPO_DOC )
				VALUES ((SELECT ISNULL(MAX(OP_NUMERO),0)+1 FROM VTA_TRANSFERENCIAS WHERE OP_CLASE_TRANS='R'), 
						 @TICKET, 
						 @FECHADATE, 
						 'R', 
						 'PP', 
						 @Moneda, 
						 @Tipo_transferencia, 
						 @CBU, 
						 @Importe, 
						 @JTS_OID, 
						 @CUIL, 
						 'C' , 
						 @FECHADATE, 
						 'N', 
						 RTRIM(LTRIM(@ReferenciaUnivoca)),
						 @OPERATORIA_BCRA
						 --, @FECHACOMPENSACION
						 , TRY_CONVERT(NUMERIC(15),@ContadorRegistros)
						 , @IdEmpresa
						 , @nombreEO
						 , @BenBanco
						 , CASE WHEN substring (@CUIL,1,1)='2' THEN 'CUIL' ELSE 'CUIT' END
						 )
			
		END TRY
		BEGIN CATCH  
		  CLOSE tran_cursor
		  DEALLOCATE tran_cursor
		  
		  SET @MSJ = 'Linea Error: ' + CONVERT(VARCHAR,ERROR_LINE()) + ' Mensaje Error: ' +  ERROR_MESSAGE();
		  RETURN
		  
		END CATCH; 


	END

		END	
		Final:
		FETCH NEXT FROM tran_cursor INTO @ID, @LINEA
	END

	CLOSE tran_cursor
	DEALLOCATE tran_cursor


END
GO

