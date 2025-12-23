CREATE PROCEDURE [SP_DIFFECHAS]
  @FechaMayor DATETIME,
  @FechaMenor DATETIME,
  @Factor     FLOAT,
  @Dif FLOAT  OUTPUT
AS
BEGIN
  SET NOCOUNT ON;
  -- si el factor es 12 retorna en años
  -- si el factor es 1 retora en meses
  SELECT  @Dif = FLOOR(DATEDIFF(MONTH, @FechaMenor, @FechaMayor) / CONVERT(FLOAT, @Factor));
  SET NOCOUNT OFF;
END
GO
