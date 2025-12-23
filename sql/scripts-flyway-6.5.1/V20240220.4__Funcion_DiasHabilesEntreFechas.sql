execute('
CREATE OR ALTER FUNCTION dbo.DiasHabilesEntreFechas(@fechaInicio DATETIME, @fechaFin DATETIME)
RETURNS INT
AS
BEGIN
    DECLARE @diasHabiles INT = 0;
    DECLARE @fechaActual DATETIME = @fechaInicio;

    WHILE @fechaActual < @fechaFin
    BEGIN
        -- Si el día actual no es sábado ni domingo, aumentar el contador de días hábiles
        IF dbo.diaHabil(@fechaActual, ''A'')=@fechaActual
            SET @diasHabiles = @diasHabiles + 1;

        -- Avanzar al siguiente día
        SET @fechaActual = DATEADD(DAY, 1, @fechaActual);
    END

    RETURN @diasHabiles;
END
');
