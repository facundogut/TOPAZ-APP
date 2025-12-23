
Execute('
CREATE OR ALTER PROCEDURE SP_SIBE_FLUJO_FONDO 

	@cuit NUMERIC (12),
	@anio NUMERIC (5),
	@proyMes1 NUMERIC (15,2),
	@proyMes2 NUMERIC (15,2),
	@proyMes3 NUMERIC (15,2),
	@proyMes4 NUMERIC (15,2),
	@proyMes5 NUMERIC (15,2),
	@proyMes6 NUMERIC (15,2),
	@proyMes7 NUMERIC (15,2),
	@proyMes8 NUMERIC (15,2),
	@proyMes9 NUMERIC (15,2),
	@proyMes10 NUMERIC (15,2),
	@proyMes11 NUMERIC (15,2),
	@proyMes12 NUMERIC (15,2),
	
	@P_RET_PROCESO float(53)  OUTPUT,
   	@P_MSG_PROCESO varchar(max)  OUTPUT
   	
AS 
BEGIN

DECLARE @existeFondo INT;


 
IF (len(@cuit) <> 11 OR len(@anio) <> 4 OR @anio < 1900 OR @anio > (SELECT DATEPART(year, (SELECT fechaproceso FROM PARAMETROS (nolock)))))
 	RAISERROR(''CUIT o anio ingresado invalido.'', 16, 1)
	
	
ELSE
BEGIN

BEGIN TRY
      
    
	SET @existeFondo = (SELECT COUNT(*) FROM SIBE_FLUJO_FONDO (NOLOCK) WHERE CUIT = @cuit AND ANIO = @anio);
	IF @existeFondo = 0
		INSERT INTO SIBE_FLUJO_FONDO VALUES (@cuit,	@anio,	@proyMes1,	@proyMes2,	@proyMes3,	@proyMes4,	@proyMes5,	@proyMes6,	@proyMes7,	@proyMes8,	@proyMes9,	@proyMes10,	@proyMes11,	@proyMes12) 
	ELSE 
		UPDATE SIBE_FLUJO_FONDO SET ProyMes01 = @proyMes1,	
									ProyMes02 = @proyMes2,	
									ProyMes03 = @proyMes3,	
									ProyMes04 = @proyMes4,	
									ProyMes05 = @proyMes5,	
									ProyMes06 = @proyMes6,	
									ProyMes07 = @proyMes7,	
									ProyMes08 = @proyMes8,	
									ProyMes09 = @proyMes9,	
									ProyMes10 = @proyMes10,	
									ProyMes11 = @proyMes11,	
									ProyMes12 = @proyMes12 WHERE CUIT = @cuit AND ANIO = @anio;   
    
    SET @P_RET_PROCESO = 0; 
    SET @P_MSG_PROCESO = ''Flujo de Fondos Registrado'';
    
END TRY
BEGIN CATCH

	SET @P_RET_PROCESO = ERROR_NUMBER();
	SET @P_MSG_PROCESO = ''Error en los parametros de entrada. '';
	
   	PRINT ERROR_MESSAGE();
 
END CATCH;

END

END
')