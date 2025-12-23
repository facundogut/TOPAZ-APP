Execute('
CREATE OR ALTER FUNCTION dbo.diaHabil (@fch1 DATE, @secuencia VARCHAR(1)) RETURNS DATE
AS

BEGIN
	DECLARE @fchAux DATE = @fch1
	DECLARE @fchHabil DATE
	DECLARE @fin VARCHAR(1) = ''N''
	DECLARE @contador INT
	DECLARE @sumarizador INT
	
	
	IF @secuencia = ''A'' --  si es ascendente sumo de a 1 día
		SET @sumarizador = 1
	ELSE
		SET @sumarizador = -1  --  si es descendente resto de a 1 día
		
	WHILE @fin = ''N''
		BEGIN
			SET @contador = 0
			SET @contador = (SELECT count(*) FROM FERIADOS WHERE anio = year(@fchAux) AND mes = month(@fchAux) AND dia = day(@fchAux))
			
			IF @contador = 0
				BEGIN
					SET @contador = (SELECT count(*) FROM FERIADOS WHERE mes = month(@fchAux) AND dia = day(@fchAux))
					
					IF @contador = 0
					BEGIN
						SET @contador = (SELECT count(*) FROM FERIADOS WHERE TIPO = ''S'' AND DESCRIPCION LIKE UPPER(DATENAME(dw, @fchAux)))
						IF @contador = 0
							SET @fin = ''S''
						ELSE
							SET @fchAux = dateadd(DAY,@sumarizador,@fchAux)   
					end
					ELSE
						SET @fchAux = dateadd(DAY,@sumarizador,@fchAux)   
				END		
			ELSE		  
				SET @fchAux = dateadd(DAY,@sumarizador,@fchAux)		
		END	
	
	SET @fchHabil = @fchAux
	RETURN @fchHabil
	
END ')