/****** Object:  StoredProcedure [dbo].[SP_CONTROL_BAJAS]    Script Date: 24/02/2021 9:05:17 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROC [dbo].[SP_CONTROL_BAJAS] @campoIN AS VARCHAR(20), @valor AS VARCHAR(20), 
	@resultado NUMERIC(5,0) OUTPUT, @tablaOUT VARCHAR(30) OUTPUT
AS
BEGIN
	
	DECLARE @sql NVARCHAR(500);	
	
	declare @count int = 0;	
	
	SET @valor = concat(CHAR(39),@valor,CHAR(39));			
	
	DECLARE cursor_diccionario cursor FOR
		SELECT TABLA, CAMPO, DE.NOMBREFISICO 
		FROM DICCIONARIO DI with (nolock)
		INNER JOIN DESCRIPTORES DE with (nolock) ON DI.TABLA = DE.IDENTIFICACION
		WHERE DI.NUMERODECAMPO IN (
									SELECT NUMERODECAMPO 
									FROM DICCIONARIO with (nolock)
									WHERE TABLADEVALIDACION 
															IN (
																SELECT IDENTIFICACION 
																FROM DESCRIPTORES with (nolock)
																WHERE IDENTIFICACION IN (
																							SELECT tabla 
																							FROM DICCIONARIO with (nolock)
																							WHERE NUMERODECAMPO=@campoIN
																						)
									UNION
									SELECT NUMERODEAYUDA 
									FROM AYUDAS with (nolock)
									WHERE NUMERODEARCHIVO IN (
																SELECT tabla 
																FROM DICCIONARIO with (nolock)
																WHERE NUMERODECAMPO=@campoIN)
															) 
										OR TABLADEAYUDA IN (
															SELECT IDENTIFICACION 
															FROM DESCRIPTORES with (nolock)
															WHERE IDENTIFICACION IN (
																						SELECT tabla 
																						FROM DICCIONARIO with (nolock)
																						WHERE NUMERODECAMPO=@campoIN
																					)
															UNION
															SELECT NUMERODEAYUDA 
															FROM AYUDAS with (nolock)
															WHERE NUMERODEARCHIVO IN (
																						SELECT tabla 
																						FROM DICCIONARIO with (nolock)
																						WHERE NUMERODECAMPO=@campoIN
																					)
															)
										)
		AND TABLA<>0 AND TABLA <> (SELECT tabla 
									FROM DICCIONARIO with (nolock)
									WHERE NUMERODECAMPO=@campoIN
									); 
	
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


