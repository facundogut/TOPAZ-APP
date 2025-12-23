EXECUTE('
IF OBJECT_ID (''dbo.SP_COELSA_IMAGENES_CHEQUES_PRESENTADOS_RECIBIDOS'') IS NOT NULL
	DROP PROCEDURE dbo.SP_COELSA_IMAGENES_CHEQUES_PRESENTADOS_RECIBIDOS
')

EXECUTE('

CREATE PROCEDURE dbo.SP_COELSA_IMAGENES_CHEQUES_PRESENTADOS_RECIBIDOS @TICKET NUMERIC(16)
AS
BEGIN
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- Modified : 30/04/2021 15:00 p.m.
--- Autor: Luis Etchebarne 
--- Cuando el tipo de registro es un Registro Totalizador grabamos el campo ID_REGISTRO en 0 dela tabla ITF_COELSA_IMAGENES_CHEQUES_PROPIOS.
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- Created : 30/04/2021 10:00 a.m.
--- Autor: Luis Etchebarne 
--- Se crea el sp con el fin de procesar los registros de las imágenes de chgeques propios recibidos a través del plano (ITF_CONTROL_IMAGENES_CHEQUES_RECIBIDOS_AUX).
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/*********************************** Variables ****************************/
DECLARE @IdRegistro VARCHAR(1);
DECLARE @CantidadRegistros NUMERIC(6);
DECLARE @FechaProceso DATE;
DECLARE @BancoDepositario NUMERIC(3);
DECLARE @BancoGirado NUMERIC(3);
DECLARE @SucursalGirada NUMERIC(3);
DECLARE @CodigoPostal VARCHAR(4);
DECLARE @NroCheque NUMERIC(8);
DECLARE @NroCuenta NUMERIC(11);
DECLARE @FechaPresentacion DATE;
DECLARE @FechaCompensacion DATE;
DECLARE @TipoTransaccion VARCHAR(1);
DECLARE @NombreImagen VARCHAR(33);
/*************************************************************************/

/* Se hacen controles previos al recorrer la tabla*/
DECLARE @CantidadIndividuales NUMERIC(10);
SET @CantidadIndividuales = (SELECT COUNT(1) FROM dbo.ITF_CONTROL_IMAGENES_CHEQUES_RECIBIDOS_AUX WITH(NOLOCK) WHERE LINEA LIKE ''1%'' OR LINEA LIKE ''5%'' OR LINEA LIKE ''3%'');
IF( 0 = @CantidadIndividuales)
BEGIN
	RAISERROR (''Error raised in TRY block.'', 16, 1);
END
IF( 1<> (SELECT COUNT(1) FROM dbo.ITF_CONTROL_IMAGENES_CHEQUES_RECIBIDOS_AUX WITH(NOLOCK) WHERE LINEA LIKE ''T%''))
BEGIN
	RAISERROR (''Error raised in TRY block.'', 16, 1);
END

IF( 0<> (SELECT COUNT(1) FROM dbo.ITF_CONTROL_IMAGENES_CHEQUES_RECIBIDOS_AUX WITH(NOLOCK) WHERE LINEA NOT LIKE ''1%'' AND LINEA NOT LIKE ''5%'' AND LINEA NOT LIKE ''3%'' AND LINEA NOT LIKE ''T%''))
BEGIN
	RAISERROR (''Error raised in TRY block.'', 16, 1);
END

IF( ''T''<> (SELECT substring(LINEA, 1, 1) FROM dbo.ITF_CONTROL_IMAGENES_CHEQUES_RECIBIDOS_AUX WITH(NOLOCK) WHERE ID = (SELECT COUNT(1) FROM ITF_CONTROL_IMAGENES_CHEQUES_RECIBIDOS_AUX) ))
BEGIN
	RAISERROR (''Error raised in TRY block.'', 16, 1);
END

/* Fin de controles*/

DECLARE @LINEA VARCHAR(94);
DECLARE che_img_cursor CURSOR FOR 
SELECT LINEA 
FROM dbo.ITF_CONTROL_IMAGENES_CHEQUES_RECIBIDOS_AUX

OPEN che_img_cursor  

FETCH NEXT FROM che_img_cursor INTO @LINEA  

WHILE @@FETCH_STATUS = 0  
BEGIN  
      SET @IdRegistro = substring(@LINEA, 1, 1);
      	IF(@IdRegistro<>''T''AND @IdRegistro<>''1'' AND @IdRegistro<>''5'' AND @IdRegistro<>''3'')
      	BEGIN
      	 RAISERROR (''Error raised in TRY block.'', 16, 1);
      	END
      
      /* Registro Totalizador */
      IF (@IdRegistro = ''T'') 
      BEGIN
      	SET @CantidadRegistros = substring(@LINEA, 2, 6);
      	SET @FechaProceso = CAST(substring(@LINEA, 8, 8) AS date);
      	
      	/* Verifico que la cantidad de registros sea la misma que la indicada en el totalizador*/
      	IF(@CantidadRegistros<>@CantidadIndividuales)
      	BEGIN
      	 RAISERROR (''Error raised in TRY block.'', 16, 1);
      	END
      	
      	/*
      	IF(@TICKET<>0)
      	BEGIN
      	INSERT INTO dbo.ITF_COELSA_IMAGENES_CHEQUES_PROPIOS(ID_TICKET, ID_PROCESO, FECHA_PROCESO, ID_REGISTRO) 
      	VALUES (@TICKET, @TICKET, (SELECT FECHAPROCESO FROM PARAMETROS), 0);
      	END */
      END
      
      /* Registro Individual */ 
      ELSE 
      BEGIN
	  	SET @BancoDepositario = CAST(substring(@LINEA, 2, 3) AS NUMERIC);
		SET @BancoGirado = CAST(substring(@LINEA, 5, 3) AS NUMERIC);
		SET @SucursalGirada = CAST(substring(@LINEA, 8, 3) AS NUMERIC);
 		SET @CodigoPostal = CAST(substring(@LINEA, 11, 4) AS NUMERIC);
		SET @NroCheque = CAST(substring(@LINEA, 15, 8) AS NUMERIC);
		SET @NroCuenta = CAST(substring(@LINEA, 23, 11) AS NUMERIC);
		SET @FechaPresentacion = CAST(RIGHT(substring(@LINEA, 44, 12), 8) AS date);
		SET @FechaCompensacion = CAST(RIGHT(substring(@LINEA, 56, 15), 8) AS date);
		SET @TipoTransaccion = substring(@LINEA, 71, 1);
		SET @NombreImagen = substring(@LINEA, 72, 33);
		
		IF((@IdRegistro=1 AND @TipoTransaccion<>''0'' AND @TipoTransaccion<>''L'' AND @TipoTransaccion<>''N'') OR(@IdRegistro=3 AND @TipoTransaccion<>''B'' AND @TipoTransaccion<>''E'' AND @TipoTransaccion<>''F'' AND @TipoTransaccion<>''I'' AND @TipoTransaccion<>''R'' AND @TipoTransaccion<>''S'' AND @TipoTransaccion<>''T'') OR (@IdRegistro=5 AND @TipoTransaccion<>''P'' AND @TipoTransaccion<>''A''))
		BEGIN
			RAISERROR (''Error raised in TRY block.'', 16, 1);
		END
		
		IF(@TICKET<>0)
      	BEGIN
		INSERT INTO dbo.ITF_COELSA_IMAGENES_CHEQUES_PROPIOS(ID_TICKET, ID_PROCESO, FECHA_PROCESO, ESTADO, ID_REGISTRO, BANCO_DEPOSITARIO, BANCO_GIRADO, SUCURSAL_GIRADA, CODIGO_POSTAL, NRO_CHEQUE, NRO_CUENTA, FECHA_PRESENTACION, FECHA_COMPENSACION, ESTADO_TRAN, NOMBRE_IMAGEN) 
      	VALUES (@TICKET, @TICKET, (SELECT FECHAPROCESO FROM PARAMETROS), ''P'', @IdRegistro, @BancoDepositario, @BancoGirado, @SucursalGirada, @CodigoPostal, @NroCheque, @NroCuenta, @FechaPresentacion, @FechaCompensacion, @TipoTransaccion, @NombreImagen);
		END
      END
      
      FETCH NEXT FROM che_img_cursor INTO @LINEA 
END 

CLOSE che_img_cursor  
DEALLOCATE che_img_cursor
    
END;

')

EXECUTE('
ALTER TABLE ITF_COELSA_IMAGENES_CHEQUES_PROPIOS ALTER COLUMN ESTADO_TRAN VARCHAR(1);
')

