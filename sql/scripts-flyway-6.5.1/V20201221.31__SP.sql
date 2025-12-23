EXECUTE('
ALTER PROCEDURE SP_SEG_VALIDA_MAQUINA
(@pUsuario VARCHAR(8), @pSucursal NUMERIC(10), @pNuevaSucursal NUMERIC(10), @pSalida NUMERIC(10) OUTPUT)
AS
BEGIN 

	DECLARE @numeroMaquina NUMERIC(5);
	SET @numeroMaquina = 0;
	SET @pSalida = 0;

	SET @numeroMaquina = (SELECT NUMERODEMAQUINA FROM USUARIOS
						 WHERE CLAVE = @pUsuario)

	SET @pSalida = (SELECT NUMERODEMAQUINA FROM NETMAP n 
			   WHERE NROSUCURSAL = @pNuevaSucursal
			   AND   NUMERODEMAQUINA = @numeroMaquina)
			   
	IF (@pSalida IS NULL)
	BEGIN
	   Select @pSalida = 0
	END

	Return @pSalida;
END
');

