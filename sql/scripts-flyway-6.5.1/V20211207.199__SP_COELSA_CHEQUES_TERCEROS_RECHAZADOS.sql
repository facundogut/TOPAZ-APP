EXECUTE('DROP PROCEDURE IF EXISTS [dbo].[SP_COELSA_CHEQUES_TERCEROS_RECHAZADOS];')

EXECUTE('
CREATE PROCEDURE [dbo].[SP_COELSA_CHEQUES_TERCEROS_RECHAZADOS]

@TICKET NUMERIC(16)

AS
BEGIN

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
DECLARE @IdRegistro VARCHAR(1);
/*DECLARE @CodPrioridad VARCHAR(2);
DECLARE @DestinoInmediato NUMERIC(10);
DECLARE @OrigenInmediato NUMERIC(10);
DECLARE @FechaPresentacion DATE;
DECLARE @HoraPresentacion NUMERIC(4);
DECLARE @IdArchivo VARCHAR(1);
DECLARE @TamanioRegistro VARCHAR(3);
DECLARE @FactorBloque VARCHAR(2);
DECLARE @CodFormato NUMERIC(1);
DECLARE @NomDestinoInmediato VARCHAR(23);
DECLARE @NomOrigenInmediato VARCHAR(23);
DECLARE @CodReferencia VARCHAR(8);*/
/*************************************************************************/
/******** Variables Cabecera de Lote *************************************/
/*DECLARE @CodClaseTran VARCHAR(3);
DECLARE @CodTipoRegistro VARCHAR(3);
DECLARE @DescTran VARCHAR(10);
DECLARE @FechaVencimiento DATE;
DECLARE @CodOrigen VARCHAR(1);
DECLARE @IdEntidadOrigen NUMERIC(8);
DECLARE @NumeroLote NUMERIC(7);*/
/*************************************************************************/	
/******** Variables Registro Individual de Cheques y Ajustes *************/ 
DECLARE @CodTransaccion VARCHAR(2);
DECLARE @EntidadDebitar VARCHAR(8);
DECLARE @CuentaDebitar VARCHAR(17);
DECLARE @Importe VARCHAR(10);
DECLARE @NumeroCheque VARCHAR(15);
DECLARE @CodigoPostal VARCHAR(6);
DECLARE @PuntoIntercambio VARCHAR(16);
DECLARE @InfoAdicional VARCHAR(2);
DECLARE @RegistrosAdicionales VARCHAR(2);
DECLARE @ContadorRegistros VARCHAR(15); 
/*************************************************************************/
DECLARE @LINEA VARCHAR(94);
DECLARE che_cursor CURSOR FOR 
SELECT LINEA 
FROM dbo.ITF_OTROS_CHEQUES_RESPUESTA_AUX

OPEN che_cursor  

FETCH NEXT FROM che_cursor INTO @LINEA  

WHILE @@FETCH_STATUS = 0  
BEGIN  
      SET @IdRegistro = substring(@LINEA, 1, 1);
      
      /* Cabecera de Archivo */
      /*IF (@IdRegistro = ''1'') 
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
      	SET @CodReferncia = substring(@LINEA, 87, 8);
      	
      END*/
      /* Cabecera de Lote */ 
      /*ELSE IF (@IdRegistro = ''5'') 
      BEGIN
      	SET @CodClaseTran = substring(@LINEA, 2, 3);
      	SET @CodTipoRegistro = substring(@LINEA, 51, 3);
      	SET @DescTran = substring(@LINEA, 54, 10);
      	SET @FechaPresentacion = CAST(substring(@LINEA, 64, 6) AS DATE);
      	SET @FechaVencimiento = CAST(substring(@LINEA, 70, 6) AS DATE);
      	SET @CodOrigen = substring(@LINEA, 79, 1);
      	SET @IdEntidadOrigen = substring(@LINEA, 80, 8);
      	SET @NumeroLote = substring(@LINEA, 88, 7);
      END*/
      
      /* Registro Individual */
      IF (@IdRegistro = ''6'') 
      BEGIN
      	SET @CodTransaccion = substring(@LINEA, 2, 2);
      	SET @EntidadDebitar = substring(@LINEA, 4, 8);
      	SET @CuentaDebitar = substring(@LINEA, 13, 17);
      	SET @Importe = substring(@LINEA, 30, 10);
      	SET @NumeroCheque = substring(@LINEA, 40, 15);
      	SET @CodigoPostal = substring(@LINEA, 55, 6);
      	SET @PuntoIntercambio = substring(@LINEA, 61, 16);
      	SET @InfoAdicional = substring(@LINEA, 77, 2);
      	SET @RegistrosAdicionales = substring(@LINEA, 79, 2);
      	SET @ContadorRegistros = substring(@LINEA, 80, 15); /* Trace Number */
      	
      	DECLARE @Entidad NUMERIC(4) = CAST(substring(@EntidadDebitar, 1, 4) AS NUMERIC);
      	DECLARE @Sucursal NUMERIC(4) = CAST(substring(@EntidadDebitar, 4, 4) AS NUMERIC);
      	DECLARE @CodRechazo NUMERIC(2) =  RIGHT(CAST(@PuntoIntercambio AS NUMERIC), 3);
    
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
      	
      	IF (CAST(@CuentaDebitar AS NUMERIC) = 88888888888)
      	BEGIN
      		-- La idea es actualizar los rechazados del plano con ESTADO_AJUSTE = ''R'' y el resto de cheques del historial con ESTADO_AJUSTE  = ''A''	
      		UPDATE dbo.CLE_CHEQUES_AJUSTE SET ESTADO_AJUSTE = ''R'' WHERE ESTADO_AJUSTE IS NULL AND TRACKNUMBER = CAST(@ContadorRegistros AS NUMERIC) AND FECHA_ACREDITACION = (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)) AND TZ_LOCK = 0;
      		
      		-- Consulta Ajuste
      		SELECT @EXISTE = 1, @ORDINAL = ORDINAL, @BANCO_GIRADO = BANCO, @FECHA_ALTA = FECHA_ALTA, @NRO_DPF_CHEQUE = NUMERO_CHEQUE, @SUCURSAL_BANCO = SUCURSAL_BANCO_GIRADO, @NRO_CUENTA = NUMERO_CUENTA, @CODIGO_POSTAL = CODIGO_POSTAL, @IMPORTE_TOTAL = IMPORTE, @MONEDA = MONEDA
      		FROM CLE_CHEQUES_AJUSTE WITH(NOLOCK) WHERE TRACKNUMBER = CAST(@ContadorRegistros AS NUMERIC) AND TZ_LOCK = 0;
      		
      		IF @EXISTE > 0
      		BEGIN
      			-- Insertamos en el historial
   				INSERT INTO ITF_COELSA_SESION_RECHAZADOS (ID_TICKET, FECHA_ALTA, BANCO, SUCURSAL, CUENTA, IMPORTE, CODIGO_POSTAL, NRO_CHEQUE, PUNTO_INTERCAMBIO, TRACK_NUMBER, TIPO, MONEDA, TIPO_DOCUMENTO, CODIGO_RECHAZO, ORDINAL)
   				VALUES(@TICKET, @FECHA_ALTA, @BANCO_GIRADO, @SUCURSAL_BANCO, @NRO_CUENTA, @IMPORTE_TOTAL, @CODIGO_POSTAL, @NRO_DPF_CHEQUE, @PuntoIntercambio, @ContadorRegistros, ''A'', @MONEDA, @TIPO_DOCUMENTO, @CodRechazo, @ORDINAL);
   			END
      	END
      	
      	ELSE IF (CAST(@CuentaDebitar AS NUMERIC) = 77777777777)
      	BEGIN
 			-- Consulta DPF  			
      		SELECT @EXISTE = 1, @TIPO_DOCUMENTO = TIPO_DOCUMENTO, @NRO_DPF_CHEQUE = NUMERO_DPF, @BANCO_GIRADO = BANCO_GIRADO, @SUCURSAL_BANCO = SUCURSAL_BANCO_GIRADO, @FECHA_ALTA = FECHA_ALTA, @IMPORTE_TOTAL = IMPORTE, @CODIGO_POSTAL = COD_POSTAL, @MONEDA = MONEDA, @NRO_CUENTA = NUMERICO_CUENTA_GIRADORA 
      		FROM CLE_DPF_SALIENTE WITH(NOLOCK) WHERE TRACKNUMBER = CAST(@ContadorRegistros AS NUMERIC) AND TZ_LOCK = 0; 
   			
   			IF @EXISTE > 0
   			BEGIN
      			INSERT INTO CLE_RECEPCION_DPF_DEV (NUMERO_DPF, BANCO_GIRADO, FECHA_ALTA, SUCURSAL_BANCO_GIRADO, TIPO_DOCUMENTO, IMPORTE_DPF, [CODIGO_CAMARA], ESTADO_DEVOLUCION, CODIGO_RECHAZO)
      			VALUES (@NRO_DPF_CHEQUE, @BANCO_GIRADO, @FECHA_ALTA, @SUCURSAL_BANCO, @TIPO_DOCUMENTO, @IMPORTE_TOTAL, (SELECT [CODIGO_DE_CAMARA] FROM CLE_CAMARAS_COMPENSADORAS WITH (NOLOCK)), 1, @CodRechazo);
      		END
      		
      		-- Insertamos en el historial
   			INSERT INTO ITF_COELSA_SESION_RECHAZADOS (ID_TICKET, FECHA_ALTA, BANCO, SUCURSAL, CUENTA, IMPORTE, CODIGO_POSTAL, NRO_CHEQUE, PUNTO_INTERCAMBIO, TRACK_NUMBER, TIPO, MONEDA, TIPO_DOCUMENTO, CODIGO_RECHAZO)
   			VALUES(@TICKET, @FECHA_ALTA, @BANCO_GIRADO, @SUCURSAL_BANCO, @NRO_CUENTA, @IMPORTE_TOTAL, @CODIGO_POSTAL, @NRO_DPF_CHEQUE, @PuntoIntercambio, @ContadorRegistros, ''D'', @MONEDA, @TIPO_DOCUMENTO, @CodRechazo);
      	END
      	
      	ELSE
      	BEGIN
      		-- Consulta Cheque
      		SELECT @EXISTE = 1, @NRO_DPF_CHEQUE = NRO_CHEQUE, @SERIE_DEL_CHEQUE = SERIE_DEL_CHEQUE, @BANCO_GIRADO = BANCO, @FECHA_ALTA = FECHA_PRESENTADO, @SUCURSAL_BANCO = SUCURSAL, @NRO_CUENTA = CUENTA, @TIPO_DOCUMENTO = TIPO_DOCUMENTO, @IMPORTE_TOTAL = IMPORTE, @CODIGO_POSTAL = CODIGO_POSTAL, @MONEDA = MONEDA
      		FROM ITF_COELSA_CHEQUES_OTROS WITH(NOLOCK) WHERE TRACE_NUMBER = CAST(@ContadorRegistros AS NUMERIC);
      		
      		IF @EXISTE > 0
   			BEGIN
      			INSERT INTO CLE_RECEPCION_CHEQUES_DEV (NUMERO_CHEQUE, SERIE_DEL_CHEQUE, BANCO_GIRADO, FECHA_ALTA, SUCURSAL_BANCO_GIRADO, NUMERO_CUENTA_GIRADORA, TIPO_DOCUMENTO, IMPORTE_CHEQUE, CODIGO_RECHAZO, ESTADO_DEVOLUCION, CODIGO_CAMARA)
      			VALUES (@NRO_DPF_CHEQUE, @SERIE_DEL_CHEQUE, @BANCO_GIRADO, @FECHA_ALTA, @SUCURSAL_BANCO, @NRO_CUENTA, @TIPO_DOCUMENTO, @IMPORTE_TOTAL, @CodRechazo, 1, (SELECT [CODIGO_DE_CAMARA] FROM CLE_CAMARAS_COMPENSADORAS WITH(NOLOCK)));
      		END
      		
      		-- Insertamos en el historial
   			INSERT INTO ITF_COELSA_SESION_RECHAZADOS (ID_TICKET, FECHA_ALTA, BANCO, SUCURSAL, CUENTA, IMPORTE, CODIGO_POSTAL, NRO_CHEQUE, PUNTO_INTERCAMBIO, TRACK_NUMBER, TIPO, MONEDA, TIPO_DOCUMENTO, CODIGO_RECHAZO, SERIE_DEL_CHEQUE)
   			VALUES(@TICKET, @FECHA_ALTA, @BANCO_GIRADO, @SUCURSAL_BANCO, @NRO_CUENTA, @IMPORTE_TOTAL, @CODIGO_POSTAL, @NRO_DPF_CHEQUE, @PuntoIntercambio, @ContadorRegistros, ''C'', @MONEDA, @TIPO_DOCUMENTO, @CodRechazo, @SERIE_DEL_CHEQUE);	   	
      	
      	END
          
      END
      
      FETCH NEXT FROM che_cursor INTO @LINEA 
END 

CLOSE che_cursor  
DEALLOCATE che_cursor

--- Actualizar el estado de los ajustes no incluidos en el plano -------------------------------------------------------------
UPDATE dbo.CLE_CHEQUES_AJUSTE SET ESTADO_AJUSTE = ''A'' WHERE (ESTADO_AJUSTE IS NULL) AND ESTADO = ''P'' AND FECHA_ACREDITACION = (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)); 
------------------------------------------------------------------------------------------------------------------------------

END;')