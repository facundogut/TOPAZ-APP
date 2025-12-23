EXECUTE('

CREATE FUNCTION dbo.ITFcantPaginas
(	
	@totalRegistros INT,@regirstrosPorPagina INT
)
RETURNS INT 
AS	
BEGIN 
DECLARE @result int 
SET @result= (SELECT @totalRegistros % @regirstrosPorPagina);

 IF (@result=0)
 	BEGIN
 	   SET @result = (SELECT @totalRegistros / @regirstrosPorPagina)
 	   RETURN @result	
 	END  
 ELSE
 	BEGIN
 		SET @result = (SELECT @totalRegistros / @regirstrosPorPagina)
 		--SET @result= FLOOR(@result)
 		SET @result= (@result + 1)
 		
 	END
RETURN @result 
END

')