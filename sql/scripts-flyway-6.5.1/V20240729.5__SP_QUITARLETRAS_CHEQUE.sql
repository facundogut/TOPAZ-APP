EXECUTE('
CREATE OR ALTER PROCEDURE SP_QUITARLETRAS_CHEQUE 
	@buffer	varchar(max),
	@P_RETORNO	varchar(max)	OUTPUT   
AS 
	BEGIN

	DECLARE @pos INT
  SET @Pos = PATINDEX(''%[a-z]%'',@buffer)
  WHILE @Pos > 0
   BEGIN
    SET @buffer = STUFF(@buffer,@pos,1,'''')
    SET @Pos = PATINDEX(''%[a-z]%'',@buffer)
   END
  SET @P_RETORNO = @buffer
END
')
