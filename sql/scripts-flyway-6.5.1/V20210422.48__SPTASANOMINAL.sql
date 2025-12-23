
EXECUTE('
	
CREATE PROC [dbo].[tasaNominalDPF] @campo1632 numeric(11, 7),  @campo1642 numeric(3,0), @campo6255 numeric(4,0), @resultado NUMERIC(15,2) OUTPUT
	AS
	BEGIN 
		IF @campo1642 = 0
			SELECT @resultado = CAST ((((POWER( ((((@campo1632 / 100) * @campo1642) / @campo6255) + 1), @campo6255 / 1)) - 1) * 100) AS DECIMAL(11,2));
		ELSE 
			SELECT @resultado = CAST ((((POWER( ((((@campo1632 / 100) * @campo1642) / @campo6255) + 1), @campo6255 / @campo1642)) - 1) * 100) AS DECIMAL(11,2));
	
		PRINT @resultado;
	END

')