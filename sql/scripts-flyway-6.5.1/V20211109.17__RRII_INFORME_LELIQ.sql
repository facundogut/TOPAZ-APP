EXECUTE('
IF OBJECT_ID (''RRII_INFORME_LELIQ'') IS NOT NULL
	DROP PROC RRII_INFORME_LELIQ
')

EXECUTE('
CREATE PROC RRII_INFORME_LELIQ @fchini AS VARCHAR(10)
AS

BEGIN	
	
	DECLARE @fch DATE;
	DECLARE @fch_inicio DATETIME; -- 1er día del mes de ejecución							
	DECLARE @fch_aux DATETIME;
	
	DECLARE @mes INT;
	DECLARE @anio INT;
	DECLARE @dia INT;
	DECLARE @dia_chr VARCHAR(2);
	
	SET @fch  = CONVERT(date, @fchini);		
	SET @mes  = month(@fch);                                        
	SET @anio = year(@fch);
	SET @fch_inicio = datefromparts(@anio, @mes, 01);
	SET @fch_aux = @fch_inicio;
	
	---------------- Borro Tabla RRII_ESTADO a la fecha de ejecución --------------------
	DELETE FROM RRII_ESTADO WHERE INFORME = ''INFORME_LELIQ'' AND FECHA_REPORTE BETWEEN @fch_inicio and @fch ; 
	--incluir borrado desde el primer dia del mes de la fecha de ejecucion hasta la misma	
	-------------------------------------------------------------------------------------
	
	-------------------- Grabo Tabla RRII_ESTADO a la fecha de ejecución ----------------
	WHILE @fch_aux <= @fch
	
	BEGIN
		
		--print @fch_aux;
		
		SET @dia  = day(@fch_aux);
		
		SET @dia_chr = CAST(@dia AS VARCHAR(2));
		
		IF @dia < 10  
			BEGIN
				SET @dia_chr = CONCAT(''0'',CAST(@dia AS VARCHAR(1)));
			END
		
		--print @dia_chr;
			
		INSERT INTO RRII_ESTADO
		SELECT 
		''INFORME_LELIQ'' AS INFORME, 
		@fch_aux AS FECHA,
		(CONCAT(CBE.CODIGO_INTERNO /*CA.CODIGO*/,@dia_chr)) AS CODIGO, 
		CAST((CONCAT(CBE.CODIGO_INTERNO /*CA.CODIGO*/,@dia_chr)) AS NUMERIC(15,0)) AS CODIGO_INT,
		--CAST(CA.CODIGO AS NUMERIC(15,0)) AS CODIGO_INT,
		'''' AS COLUMNA1,
		
		(CASE
			WHEN dbo.saldoAFechaINFORME_LELIQ(''INFORME_LELIQ'', @fch_aux, CBE.CODIGO_INTERNO/*CA.CODIGO*/) IS NULL THEN 0
			ELSE dbo.saldoAFechaINFORME_LELIQ(''INFORME_LELIQ'', @fch_aux, CBE.CODIGO_INTERNO/*CA.CODIGO*/)
		END) AS COLUMNA2,
		
		0 AS COLUMNA3,
		0 AS COLUMNA4,
		0 AS COLUMNA5,
		0 AS COLUMNA6,
		0 AS COLUMNA7,
		0 AS COLUMNA8,
		0 AS COLUMNA9,
		0 AS COLUMNA10
		
		FROM  CO_BALANCE_ESTRUCTURA CBE --CODIGOAGRUPADOR CA
		WHERE CBE.ID_BCE = 33--CA.INFORME = ''INFORME_LELIQ'' 
		GROUP BY CBE.CODIGO_INTERNO;--CA.CODIGO
		
		SET @fch_aux = DATEADD(DAY, 1, @fch_aux)--DAY(@fch_aux) + 1;
	END  		
END');