EXECUTE('
CREATE OR ALTER FUNCTION esFERIADO (@fch1 DATE) RETURNS INT
AS
--- devuelve 1 si el dia ingresado es feriado y 0 sino lo es
BEGIN
	DECLARE @dia INT = day(@fch1)
	DECLARE @mes INT = MONTH(@fch1)
	DECLARE @anio INT = YEAR(@fch1)
	DECLARE @booleano INT
	
	SELECT @booleano = 
	CASE WHEN EXISTS (SELECT *
				FROM FERIADOS F WITH(NOLOCK) 
					WHERE F.DIA=@dia AND
						F.MES=@mes AND
						F.ANIO=@anio AND
						F.PAIS = (SELECT NUMERICO 
								FROM PARAMETROSGENERALES WITH (NOLOCK) 
								WHERE CODIGO=1 
									AND TZ_LOCK=0)) THEN
								1
		ELSE 
			0
		END 
	
	RETURN @booleano
	
END;
')