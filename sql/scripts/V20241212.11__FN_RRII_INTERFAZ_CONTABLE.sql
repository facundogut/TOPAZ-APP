EXECUTE('
CREATE OR ALTER FUNCTION FN_ObtenerTipoCambioOficial
(
    @moneda INT,
    @fecha DATETIME
)
RETURNS DECIMAL(18, 6)
AS
BEGIN
    DECLARE @tipoCambio DECIMAL(18, 6);

    SELECT TOP 1 @tipoCambio = H.TIPO_CAMBIO_COMPRA
    FROM HISTORICOTIPOSCAMBIO H
    WHERE H.MONEDA = @moneda 
    AND H.FECHA_COTIZACION <= @fecha
    AND H.TZ_LOCK = 0
    ORDER BY H.FECHA_COTIZACION DESC;

    RETURN ISNULL(@tipoCambio, 1); 
END;
')

EXECUTE('
CREATE OR ALTER FUNCTION FN_ObtenerTipoCambioMesAnterior
(
    @moneda INT,
    @fecha DATETIME
)
RETURNS DECIMAL(18, 6)
AS
BEGIN
    DECLARE @fechaMesAnterior DATETIME;
    DECLARE @tipoCambioMesAnterior DECIMAL(18, 6);

    
    SET @fechaMesAnterior = dbo.ULTIMODIAHABIL(DATEADD(MONTH, -1, @fecha));

    SELECT TOP 1 @tipoCambioMesAnterior = H.TIPO_CAMBIO_COMPRA
    FROM HISTORICOTIPOSCAMBIO H
    WHERE H.MONEDA = @moneda 
    AND H.FECHA_COTIZACION <= @fechaMesAnterior
    AND H.TZ_LOCK = 0
    ORDER BY H.FECHA_COTIZACION DESC;

    RETURN ISNULL(@tipoCambioMesAnterior, 1);
END;
')
