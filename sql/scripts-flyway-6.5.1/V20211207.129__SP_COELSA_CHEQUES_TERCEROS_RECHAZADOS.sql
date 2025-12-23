EXECUTE('DROP PROCEDURE IF EXISTS dbo.SP_COELSA_CHEQUES_TERCEROS_RECHAZADOS;')
EXECUTE('
CREATE PROCEDURE dbo.SP_COELSA_CHEQUES_TERCEROS_RECHAZADOS @TICKET NUMERIC(16)
AS
BEGIN
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- Created : 29/07/2021 12:00 a.m.
--- Autor: Luis Etchebarne 
--- Se crea el sp con el fin de procesar los registros de cheques de terceros rechazados a través del plano (ITF_OTROS_CHEQUES_RESPUESTA_AUX).
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/******** Variables Cabecera de Archivo **********************************/
DECLARE @IdRegistro VARCHAR(1);
DECLARE @CodPrioridad VARCHAR(2);
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
DECLARE @CodReferncia VARCHAR(8);
/*************************************************************************/
/******** Variables Cabecera de Lote *************************************/
DECLARE @CodClaseTran VARCHAR(3);
DECLARE @CodTipoRegistro VARCHAR(3);
DECLARE @DescTran VARCHAR(10);
DECLARE @FechaVencimiento DATE;
DECLARE @CodOrigen VARCHAR(1);
DECLARE @IdEntidadOrigen NUMERIC(8);
DECLARE @NumeroLote NUMERIC(7);
/*************************************************************************/	
/******** Variables Registro Individual de Cheques y Ajustes *************/ 
DECLARE @CodTransaccion NUMERIC(2);
DECLARE @EntidadDebitar NUMERIC(8);
DECLARE @CuentaDebitar NUMERIC(17);
DECLARE @Importe NUMERIC(10);
DECLARE @NumeroCheque NUMERIC(15);
DECLARE @CodigoPostal VARCHAR(6);
DECLARE @PuntoIntercambio VARCHAR(16);
DECLARE @InfoAdicional VARCHAR(2);
DECLARE @RegistrosAdicionales NUMERIC(1);
DECLARE @ContadorRegistros NUMERIC(15); 
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
      	SET @CodReferncia = substring(@LINEA, 87, 8);
      	
      END
      /* Cabecera de Lote */ 
      ELSE IF (@IdRegistro = ''5'') 
      BEGIN
      	SET @CodClaseTran = substring(@LINEA, 2, 3);
      	SET @CodTipoRegistro = substring(@LINEA, 51, 3);
      	SET @DescTran = substring(@LINEA, 54, 10);
      	SET @FechaPresentacion = CAST(substring(@LINEA, 64, 6) AS DATE);
      	SET @FechaVencimiento = CAST(substring(@LINEA, 70, 6) AS DATE);
      	SET @CodOrigen = substring(@LINEA, 79, 1);
      	SET @IdEntidadOrigen = substring(@LINEA, 80, 8);
      	SET @NumeroLote = substring(@LINEA, 88, 7);
      END
      /* Registro Individual */
      ELSE IF (@IdRegistro = ''6'') 
      BEGIN
      	SET @CodTransaccion = substring(@LINEA, 2, 2);
      	SET @EntidadDebitar = substring(@LINEA, 4, 8);
      	SET @CuentaDebitar = substring(@LINEA, 13, 17);
      	SET @Importe = substring(@LINEA, 30, 10);
      	SET @NumeroCheque = substring(@LINEA, 40, 15);
      	SET @CodigoPostal = substring(@LINEA, 55, 6);
      	SET @PuntoIntercambio = substring(@LINEA, 61, 16);
      	SET @InfoAdicional = substring(@LINEA, 77, 2);
      	SET @RegistrosAdicionales = substring(@LINEA, 79, 1);
      	SET @ContadorRegistros = substring(@LINEA, 80, 15); /* Trace Number */
      	
      	DECLARE @Entidad NUMERIC(5);
      	DECLARE @Sucursal NUMERIC(5);
      	DECLARE @CodRechazo NUMERIC(2);
      	SET @Entidad = CAST(substring(@LINEA, 4, 4) AS NUMERIC);
      	SET @Sucursal = CAST(substring(@LINEA, 8, 4) AS NUMERIC);
      	SET @CodRechazo = CAST(substring(@PuntoIntercambio, 6, 2) AS NUMERIC);
      	
      	IF (CAST(@CuentaDebitar AS NUMERIC) = 88888888888)
      	BEGIN
      	-- La idea es actualizar los rechazados del plano con ESTADO_AJUSTE = ''R'' y el resto de cheques del historial con ESTADO_AJUSTE  = ''A''	
      		UPDATE dbo.CLE_CHEQUES_AJUSTE SET ESTADO_AJUSTE = ''R'' WHERE ESTADO_AJUSTE IS NULL AND NUMERO_CHEQUE = CAST(@NumeroCheque AS NUMERIC);
      		UPDATE dbo.CLE_CHEQUES_AJUSTE SET ESTADO_AJUSTE = ''A'' WHERE ESTADO_AJUSTE IS NULL AND NUMERO_CHEQUE IN (SELECT NRO_CHEQUE FROM ITF_COELSA_CHEQUES_TERCEROS WHERE FECHA_VENCIMIENTO = (SELECT FECHAPROCESO FROM PARAMETROS)); 
      	END
      	
      	ELSE IF (CAST(@CuentaDebitar AS NUMERIC) = 77777777777)
      	BEGIN
      	
      	PRINT(''FALTA'')
      	--FALTARIA GRABAR LOS DPF CONTRA LA TABLA MENCIONADA
      		--SELECT * FROM CLE_RECEPCION_DPF_DEV
      	END
      	
      	ELSE
      	BEGIN
      		INSERT INTO CLE_RECEPCION_CHEQUES_DEV (BANCO_GIRADO, SUCURSAL_BANCO_GIRADO, SERIE_DEL_CHEQUE, IMPORTE_CHEQUE, CODIGO_RECHAZO, NUMERO_CHEQUE, ESTADO_DEVOLUCION, CODIGO_CAMARA, TIPO_DOCUMENTO, FECHA_ALTA)
      		VALUES (@Entidad, @Sucursal, '''', @Importe, @CodRechazo, @NumeroCheque, 0, 1, 0, (SELECT FECHAPROCESO FROM PARAMETROS WITH (NOLOCK)));
      	
      	END
          
      END
      
      FETCH NEXT FROM che_cursor INTO @LINEA 
END 

CLOSE che_cursor  
DEALLOCATE che_cursor
    
END;')