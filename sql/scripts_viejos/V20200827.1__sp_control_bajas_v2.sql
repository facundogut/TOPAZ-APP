
CREATE PROC SP_CONTROL_BAJAS_V2 @campoIN AS VARCHAR(20), @valor AS VARCHAR(20), 
	@resultado NUMERIC(5,0) OUTPUT, @tablaOUT VARCHAR(30) OUTPUT
AS
BEGIN
	
	DECLARE @sql NVARCHAR(500);	
	
	declare @count int = 0;	
	
	SET @valor = concat(CHAR(39),@valor,CHAR(39));			
	
	DECLARE cursor_diccionario cursor FOR
		SELECT TABLA, CAMPO, DE.NOMBREFISICO FROM DICCIONARIO DI INNER JOIN DESCRIPTORES DE ON DI.TABLA = DE.IDENTIFICACION
		WHERE (DI.NUMERODECAMPO IN (
		SELECT NUMERODECAMPO FROM DICCIONARIO WHERE TABLADEVALIDACION 
		IN (
		SELECT IDENTIFICACION FROM DESCRIPTORES WHERE IDENTIFICACION IN (
		SELECT tabla FROM DICCIONARIO WHERE NUMERODECAMPO=@campoIN)
		UNION
		SELECT NUMERODEAYUDA FROM AYUDAS WHERE NUMERODEARCHIVO IN (
		SELECT tabla FROM DICCIONARIO WHERE NUMERODECAMPO=@campoIN)
		))
		OR TABLADEAYUDA IN (
		SELECT IDENTIFICACION FROM DESCRIPTORES WHERE IDENTIFICACION IN (
		SELECT tabla FROM DICCIONARIO WHERE NUMERODECAMPO=@campoIN)
		UNION
		SELECT NUMERODEAYUDA FROM AYUDAS WHERE NUMERODEARCHIVO IN (
		SELECT tabla FROM DICCIONARIO WHERE NUMERODECAMPO=@campoIN)
		)) 
		AND TABLA<>0 AND TABLA NOT IN (SELECT tabla FROM DICCIONARIO WHERE NUMERODECAMPO=@campoIN)
		AND TABLADEVALIDACION IN (SELECT tabla FROM DICCIONARIO WHERE NUMERODECAMPO=@campoIN);  
	
	DECLARE @tabla NUMERIC(5,0);
	DECLARE @campo VARCHAR(30);
	DECLARE @nombrefisico VARCHAR(60);
	
	OPEN cursor_diccionario  -- abrimos el cursor
	
	FETCH NEXT FROM cursor_diccionario INTO @tabla, @campo, @nombrefisico		
	
	SET @resultado = 0;
	SET @tablaOUT = '';
	
	while @@fetch_status = 0 AND @count = 0 
	BEGIN				
		
		IF @tabla <> 0 	
			
			SET @sql = 'SELECT @count=count(*) from ' + @nombrefisico + ' WHERE TZ_LOCK=0 AND ' + @campo + ' = '+  @valor 	
			PRINT @sql
			
			EXEC sp_executesql @sql,
				N'@count int OUTPUT',
				@count = @count OUTPUT			
			
			SET @resultado = @count;	
			SET @tablaOUT = @nombrefisico;						
			
			FETCH NEXT FROM cursor_diccionario INTO @tabla, @campo, @nombrefisico
	END

	CLOSE cursor_diccionario -- cerramos el cursor
	DEALLOCATE cursor_diccionario -- liberamos recursos
END
GO

