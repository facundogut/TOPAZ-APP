execute('
ALTER FUNCTION sumarDiasHabiles (@fch1 DATE, @dias NUMERIC(3)) RETURNS DATE
AS

BEGIN
	/*DECLARE @fchAux DATE = @fch1
	DECLARE @fchHabil DATE
	DECLARE @contador INT
	DECLARE @sumarizador NUMERIC(3) = 0
	
		
	WHILE @sumarizador < @dias+1
		BEGIN
			SET @contador = 0
			SET @contador = (SELECT count(*) FROM FERIADOS WHERE TZ_LOCK = 0 AND TIPO != ''S'' AND (anio = year(@fchAux) OR anio = 0) AND mes = month(@fchAux) AND dia = day(@fchAux))
			
			IF @contador = 0
				BEGIN
					SET @contador = (SELECT count(*) FROM FERIADOS WHERE TZ_LOCK = 0 AND TIPO = ''S'' AND DESCRIPCION LIKE UPPER(DATENAME(dw, @fchAux)))
					
					IF @contador = 0
						BEGIN
							SET @fchAux = dateadd(DAY,1,@fchAux) 
							SET @sumarizador = @sumarizador + 1
						END
					ELSE
						SET @fchAux = dateadd(DAY,1,@fchAux)   
				END		
			ELSE		  
				SET @fchAux = dateadd(DAY,1,@fchAux)		
		END	
	
	SET @fchHabil = @fchAux
	RETURN @fchHabil*/
	RETURN dbo.AgregarDiasHabiles(@fch1,@dias+1)
END
');
