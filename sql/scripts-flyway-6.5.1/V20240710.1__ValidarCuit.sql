execute('create or ALTER FUNCTION dbo.ValidarCUIT (@CUIT NUMERIC(11, 0))
RETURNS INT
AS
BEGIN
    DECLARE @cuitStr CHAR(11);
    DECLARE @coeficientes CHAR(10) = ''5432765432'';
    DECLARE @suma INT = 0;
    DECLARE @i INT;
    DECLARE @verificadorEsperado INT;
    DECLARE @verificadorReal INT;
    DECLARE @a int

    -- Convertir el CUIT a string
    SET @cuitStr = RIGHT(''00000000000'' + CAST(@CUIT AS VARCHAR(11)), 11);

    -- Calcular la suma de los productos de los coeficientes por los primeros 10 dígitos
    SET @i = 1;
    WHILE @i <= 10
    BEGIN
        SET @suma = @suma + (CAST(SUBSTRING(@cuitStr, @i, 1) AS INT) * CAST(SUBSTRING(@coeficientes, @i, 1) AS INT));
        SET @i = @i + 1;
    END

    -- Calcular el resto de la división por 11
    SET @verificadorEsperado = 11 - (@suma % 11);

    -- Si el resto es 10, el verificador es 9. Si el resto es 11, el verificador es 0.
    IF @verificadorEsperado = 11 SET @verificadorEsperado = 0;
    IF @verificadorEsperado = 10 SET @verificadorEsperado = 9;

    -- Obtener el dígito verificador real del CUIT
    SET @verificadorReal = CAST(RIGHT(@cuitStr, 1) AS INT);

    -- Comparar el dígito verificador esperado con el real
    IF @verificadorEsperado = @verificadorReal
        SET @a= 1
    ELSE
        SET @a= 0
        
    RETURN @a
END');
