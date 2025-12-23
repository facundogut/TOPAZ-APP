CREATE OR ALTER  FUNCTION dbo.getCodBarraVerificado (@Barra NVARCHAR(MAX))
RETURNS CHAR(120)
AS
BEGIN
    DECLARE @i INT = 1;
    DECLARE @Largo INT = LEN(@Barra);
    DECLARE @Multiplo INT;
    DECLARE @Suma INT = 0;
    DECLARE @Numero INT;
    DECLARE @DV CHAR(1);
    DECLARE @Flg CHAR(1) = 'S';

    WHILE @i <= @Largo
    BEGIN
        IF @Flg = 'S'
        BEGIN
            SET @Multiplo = 3;
            SET @Flg = 'N';
        END
        ELSE
        BEGIN
            SET @Multiplo = 1;
            SET @Flg = 'S';
        END

        SET @Numero = CAST(SUBSTRING(@Barra, @i, 1) AS INT);
        SET @Suma = @Suma + (@Numero * @Multiplo);

        SET @i = @i + 1;
    END

    SET @Suma = @Suma % 10;
    SET @DV = CHAR(((10 - @Suma) % 10) + ASCII('0'));

    RETURN @Barra+@DV;
END