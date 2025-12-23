CREATE OR ALTER FUNCTION dbo.ReducirDiasHabiles(
    @fechaInicio DATETIME, 
    @diasHabiles INT
)
RETURNS DATETIME
AS
BEGIN
    DECLARE @fechaActual DATETIME = @fechaInicio;
    DECLARE @diasContados INT = 0;

    WHILE @diasContados < @diasHabiles
    BEGIN
        -- Avanzar al siguiente día
        SET @fechaActual = DATEADD(DAY, -1, @fechaActual);

        -- Si el día actual es hábil, aumentar el contador de días hábiles
        IF dbo.diaHabil(@fechaActual, 'D')=@fechaActual
        BEGIN
            SET @diasContados = @diasContados + 1;
        END
    END

    RETURN @fechaActual;
END