EXECUTE('
CREATE PROC [dbo].[SP_PORCENTAJE_COINCIDENCIA]
(
    @string1 NVARCHAR(100)
    ,@string2 NVARCHAR(100)
	,@percentageOfGoodCharacters INT OUTPUT
  
)

AS
BEGIN

    DECLARE @levenShteinNumber INT

    DECLARE @string1Length INT = LEN(@string1)
    , @string2Length INT = LEN(@string2)
    DECLARE @maxLengthNumber INT = CASE WHEN @string1Length > @string2Length THEN @string1Length ELSE @string2Length END

    SELECT @levenShteinNumber = [dbo].[LEVENSHTEIN] (   @string1  ,@string2)

    DECLARE @percentageOfBadCharacters INT = @levenShteinNumber * 100 / @maxLengthNumber

    SET @percentageOfGoodCharacters = 100 - @percentageOfBadCharacters

END

    -- Return the result of the function
    RETURN @percentageOfGoodCharacters
')



EXECUTE('
CREATE FUNCTION [dbo].[LEVENSHTEIN](@left  VARCHAR(100),
                                    @right VARCHAR(100))
returns INT
AS
  BEGIN
      DECLARE @difference    INT,
              @lenRight      INT,
              @lenLeft       INT,
              @leftIndex     INT,
              @rightIndex    INT,
              @left_char     CHAR(1),
              @right_char    CHAR(1),
              @compareLength INT

      SET @lenLeft = LEN(@left)
      SET @lenRight = LEN(@right)
      SET @difference = 0

      IF @lenLeft = 0
        BEGIN
            SET @difference = @lenRight

            GOTO done
        END

      IF @lenRight = 0
        BEGIN
            SET @difference = @lenLeft

            GOTO done
        END

      GOTO comparison

      COMPARISON:

      IF ( @lenLeft >= @lenRight )
        SET @compareLength = @lenLeft
      ELSE
        SET @compareLength = @lenRight

      SET @rightIndex = 1
      SET @leftIndex = 1

      WHILE @leftIndex <= @compareLength
        BEGIN
            SET @left_char = substring(@left, @leftIndex, 1)
            SET @right_char = substring(@right, @rightIndex, 1)

            IF @left_char <> @right_char
              BEGIN -- Would an insertion make them re-align?
                  IF( @left_char = substring(@right, @rightIndex + 1, 1) )
                    SET @rightIndex = @rightIndex + 1
                  -- Would an deletion make them re-align?
                  ELSE IF( substring(@left, @leftIndex + 1, 1) = @right_char )
                    SET @leftIndex = @leftIndex + 1

                  SET @difference = @difference + 1
              END

            SET @leftIndex = @leftIndex + 1
            SET @rightIndex = @rightIndex + 1
        END

      GOTO done

      DONE:

      RETURN @difference
  END 
')