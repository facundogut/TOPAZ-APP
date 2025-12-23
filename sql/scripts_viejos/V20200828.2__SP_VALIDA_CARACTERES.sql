create PROCEDURE SP_VALIDA_CARACTERES
@pCadena VARCHAR(500),
@pCaracteresExcluir VARCHAR(500),
@pResultado NUMERIC(1) OUT
AS
DECLARE
	@idx NUMERIC(3),
	@char VARCHAR(1),
	@resultado NUMERIC(1)
BEGIN
	SET @idx = 1
	SET @resultado = 1
	
	WHILE @idx <= LEN(@pCaracteresExcluir) AND @resultado = 1
	BEGIN
		SET @char = SUBSTRING(@pCaracteresExcluir, @idx, 1)
		
		IF CHARINDEX(@char, @pCadena) > 0
		BEGIN
			SET @resultado = 0 
		END
		
		SET @idx = @idx + 1
	END
	SET @pResultado = @resultado
END
go