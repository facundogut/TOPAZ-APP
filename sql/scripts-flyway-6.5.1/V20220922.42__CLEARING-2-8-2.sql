EXECUTE('

IF OBJECT_ID (''dbo.ITF_CHEQUES_RECIBIDOS_AUX'') IS NOT NULL
	DROP TABLE dbo.ITF_CHEQUES_RECIBIDOS_AUX


CREATE TABLE dbo.ITF_CHEQUES_RECIBIDOS_AUX
	(
	ID    INT IDENTITY NOT NULL,
	LINEA VARCHAR (200)
	)
	
')

EXECUTE('
IF OBJECT_ID (''dbo.SP_COELSA_CHEQUES_PRESENTADOS_RECIBIDOS'') IS NOT NULL
	DROP PROCEDURE dbo.SP_COELSA_CHEQUES_PRESENTADOS_RECIBIDOS

')
EXECUTE('
CREATE PROCEDURE [dbo].[SP_COELSA_CHEQUES_PRESENTADOS_RECIBIDOS]
@TICKET NUMERIC(16)
AS
BEGIN
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- Modified : 03/05/2021 10:00 a.m.
--- Autor: Luis Etchebarne 
--- Cuando el registro individual es del tipo ajuste se graba el registro en la tabla CLE_CHEQUES_AJUSTE.
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- Created : 25/04/2021 10:00 a.m.
--- Autor: Luis Etchebarne 
--- Se crea el sp con el fin de procesar los registros de cheques propios recibidos a través del plano (ITF_CHEQUES_RECIBIDOS_AUX).
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
DECLARE @Importe NUMERIC(11,2);
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
FROM dbo.ITF_CHEQUES_RECIBIDOS_AUX

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
      	SET @Importe = CAST(substring(@LINEA, 30, 8)+''.''+substring(@LINEA, 38, 2) AS NUMERIC(10,2));
      	SET @NumeroCheque = substring(@LINEA, 40, 15);
      	SET @CodigoPostal = substring(@LINEA, 55, 6);
      	SET @PuntoIntercambio = substring(@LINEA, 61, 16);
      	SET @InfoAdicional = substring(@LINEA, 77, 2);
      	SET @RegistrosAdicionales = substring(@LINEA, 79, 1);
      	SET @ContadorRegistros = substring(@LINEA, 80, 15); /* Trace Number */
      	IF(@TICKET<>0)
      	BEGIN
      	INSERT INTO dbo.ITF_COELSA_CHEQUES_PROPIOS (ID_TICKET, ID_PROCESO, FECHAPROCESO, CODIGO_TRANSACCION, ENTIDAD_DEBITAR, CUENTA_DEBITAR, IMPORTE, CODIGO_POSTAL, FECHA_PRESENTADO, FECHA_VENCIMIENTO, NRO_CHEQUE, PUNTO_INTERCAMBIO, TRACE_NUMBER, ESTADO, TIPO, INFO_ADICIONAL)
      	VALUES (@TICKET, @TICKET, (SELECT FECHAPROCESO FROM PARAMETROS), @CodTransaccion, @EntidadDebitar, @CuentaDebitar, @Importe, @CodigoPostal, @FechaPresentacion, @FechaVencimiento, @NumeroCheque, @PuntoIntercambio, @ContadorRegistros, ''P'', (CASE WHEN CAST(@CuentaDebitar AS NUMERIC) = 88888888888 THEN ''A'' WHEN CAST(@CuentaDebitar AS NUMERIC) = 77777777777 THEN ''D'' ELSE ''C'' END), @InfoAdicional);
      	END
      END
      
      FETCH NEXT FROM che_cursor INTO @LINEA 
END 

CLOSE che_cursor  
DEALLOCATE che_cursor
    
END;


')


