
EXECUTE('DROP PROCEDURE IF EXISTS [dbo].[SP_CONTROL_BAJAS]')

EXECUTE('CREATE   PROCEDURE [dbo].[SP_CONTROL_BAJAS] @campoIN AS VARCHAR(20), @valor AS VARCHAR(20), 
	@resultado NUMERIC(5,0) OUTPUT, @tablaOUT VARCHAR(30) OUTPUT
AS
BEGIN
	--------------- DECLARO VRIABLES ---------------
	DECLARE @sql NVARCHAR(500);	 
	DECLARE @sql_print NVARCHAR(500);		
	DECLARE @count INT = 0;						
	DECLARE @tabla NUMERIC(5,0) = 0;
	DECLARE @nro_ayuda NUMERIC(5,0) = 0;
	
	DECLARE @tabla_f NUMERIC(5,0); 
	DECLARE @campo VARCHAR(30);
	DECLARE @nombrefisico VARCHAR(60);
	------------------------------------------------
	
	SET @valor = concat(CHAR(39),@valor,CHAR(39));	
	SET @tabla = (SELECT TABLA FROM DICCIONARIO WHERE NUMERODECAMPO=@campoIN AND TABLA<>0);		
	SET @resultado = 0;
	SET @tablaOUT = ''PUEDE BORRAR'';
	
	
	DECLARE cursor_ayuda cursor FOR
		SELECT NUMERODEAYUDA FROM AYUDAS WHERE NUMERODEARCHIVO=@tabla;
	
	OPEN cursor_ayuda;
	FETCH NEXT FROM cursor_ayuda INTO @nro_ayuda	
	
	WHILE @@fetch_status = 0 AND @count = 0
	BEGIN
	
		DECLARE cursor_diccionario cursor FOR
			SELECT DI.TABLA, DI.CAMPO, DE.NOMBREFISICO
			FROM DICCIONARIO DI INNER JOIN DESCRIPTORES DE ON DI.TABLA=DE.IDENTIFICACION
			WHERE NUMERODECAMPO IN (SELECT NUMERODECAMPO FROM DICCIONARIO WHERE (TABLADEAYUDA=@nro_ayuda OR TABLADEVALIDACION=@tabla) 
			AND TABLA<>0 AND TABLA NOT IN (SELECT TABLA FROM DICCIONARIO WHERE NUMERODECAMPO=@campoIN));
		
		OPEN cursor_diccionario
		FETCH NEXT FROM cursor_diccionario INTO @tabla_f, @campo, @nombrefisico	
		
		WHILE @@fetch_status = 0 AND @count = 0
		BEGIN
		
			SET @sql = ''SELECT @count=count(*) from '' + @nombrefisico + '' WHERE TZ_LOCK=0 AND '' + @campo + '' = ''+  @valor 	
			SET @sql_print = ''SELECT count(*) from '' + @nombrefisico + '' WHERE TZ_LOCK=0 AND '' + @campo + '' = ''+  @valor + '';'' 
			PRINT @sql_print
			
			EXEC sp_executesql @sql,
			N''@count int OUTPUT'',
			@count = @count OUTPUT		
		
			SET @resultado = @count;	
			SET @tablaOUT = @nombrefisico;
			
			FETCH NEXT FROM cursor_diccionario INTO @tabla_f, @campo, @nombrefisico
			
		END
		
		CLOSE cursor_diccionario -- cerramos el cursor
		DEALLOCATE cursor_diccionario -- liberamos recursos

		FETCH NEXT FROM cursor_ayuda INTO @nro_ayuda			
	END 
	
	CLOSE cursor_ayuda;
	DEALLOCATE cursor_ayuda;
			 				
END')


