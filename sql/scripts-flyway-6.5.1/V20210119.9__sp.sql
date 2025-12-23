EXECUTE('
	ALTER PROCEDURE SP_SEG_VALIDA_MAQUINA
	(@pNumeroMaquina NUMERIC(5), @pSucursal NUMERIC(10), @pSalida NUMERIC(10) OUTPUT)
	AS
	BEGIN 
		IF EXISTS (Select NUMERODEMAQUINA
					from VW_NETMAP WHERE 
					NUMERODEMAQUINA = @pNumeroMaquina AND
					NROSUCURSAL = @pSucursal
					)
		SET @pSalida = 1
		ELSE 
		SET @pSalida = 0
		
		Return @pSalida;
	END 
');