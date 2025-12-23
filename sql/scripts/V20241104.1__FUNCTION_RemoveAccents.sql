CREATE FUNCTION RemoveAccents(@input VARCHAR(MAX))
RETURNS VARCHAR(MAX)
AS
BEGIN
    DECLARE @output VARCHAR(MAX) = @input;

    SET @output = REPLACE(@output, 'á', 'a');
    SET @output = REPLACE(@output, 'é', 'e');
    SET @output = REPLACE(@output, 'í', 'i');
    SET @output = REPLACE(@output, 'ó', 'o');
    SET @output = REPLACE(@output, 'ú', 'u');
    SET @output = REPLACE(@output, 'ñ', 'n');
    
    SET @output = REPLACE(@output, 'Á', 'A');
    SET @output = REPLACE(@output, 'É', 'E');
    SET @output = REPLACE(@output, 'Í', 'I');
    SET @output = REPLACE(@output, 'Ó', 'O');
    SET @output = REPLACE(@output, 'Ú', 'U');
    SET @output = REPLACE(@output, 'Ñ', 'N');

    RETURN @output;
END;

