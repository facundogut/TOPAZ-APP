CREATE PROCEDURE SP_AFIP_COD_ACTIVIDAD @codigo AS VARCHAR(12), @cod_validado VARCHAR(12) OUTPUT
AS
BEGIN
	IF LEN(@codigo) = 5
	BEGIN
		SET @cod_validado = REPLICATE('0', 1) + @codigo;
	END
	
    ELSE
    BEGIN
    	SET @cod_validado = @codigo;
    END

    PRINT @cod_validado;   
END
GO