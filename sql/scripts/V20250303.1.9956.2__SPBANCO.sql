Execute('CREATE OR ALTER PROCEDURE dbo.SP_RESUMEN_CONTABLE_POR_RUBRO_FECHA
    @fecha DATE,
    @cuenta VARCHAR(20),
    @sucursalAlta VARCHAR(100) OUTPUT,
    @fechaAsiento VARCHAR(10) OUTPUT,
    @moneda VARCHAR(100) OUTPUT,
    @cuentaRubro NUMERIC(15,0) OUTPUT,
    @importeHaber NUMERIC(18,2) OUTPUT,
    @importeDebe NUMERIC(18,2) OUTPUT,
    @importeContabilidad NUMERIC(18,2) OUTPUT,
    @saldoAnterior NUMERIC(15,2) OUTPUT,
    @codigoError INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    -- Inicializar variables de salida en NULL
    SET @sucursalAlta = NULL;
    SET @fechaAsiento = NULL;
    SET @moneda = NULL;
    SET @cuentaRubro = NULL;
    SET @importeHaber = NULL;
    SET @importeDebe = NULL;
    SET @importeContabilidad = NULL;
    SET @saldoAnterior = NULL;
    SET @codigoError = 3;

    -- Validar que @cuenta sea un numérico de hasta 15 dígitos
    IF TRY_CAST(@cuenta AS NUMERIC(15,0)) IS NULL
    BEGIN
        SET @codigoError = 2;
        RETURN;
    END

    -- Seteo variables temporales
    DECLARE @tmpSucursalAlta VARCHAR(100);
    DECLARE @tmpFechaAsiento VARCHAR(10);
    DECLARE @tmpMoneda VARCHAR(100);
    DECLARE @tmpCuentaRubro NUMERIC(15,0);
    DECLARE @tmpImporteHaber NUMERIC(18,2);
    DECLARE @tmpImporteDebe NUMERIC(18,2);
    DECLARE @tmpImporteContabilidad NUMERIC(18,2);
    DECLARE @tmpSaldoAnterior NUMERIC(15,2);

    SELECT
        @tmpSucursalAlta = CONCAT(mc.SUCURSAL_CUENTA, '' - '', s.NOMBRESUCURSAL),
        @tmpFechaAsiento = CONVERT(VARCHAR(10), mc.FECHAPROCESO, 120),
        @tmpMoneda = CONCAT(mc.moneda, '' - '', m.C6400),
        @tmpCuentaRubro = mc.RUBROCONTABLE,
        @tmpImporteHaber = SUM(CASE WHEN mc.DEBITOCREDITO = ''D'' THEN CAPITALREALIZADO ELSE 0 END),
        @tmpImporteDebe = SUM(CASE WHEN mc.DEBITOCREDITO = ''C'' THEN CAPITALREALIZADO ELSE 0 END),
        @tmpSaldoAnterior = ISNULL(gsd.SALDO_AL_CORTE, 0)
    FROM MOVIMIENTOS_CONTABLES mc
        INNER JOIN asientos a
        ON a.SUCURSAL = mc.SUCURSAL
            AND a.ASIENTO = mc.ASIENTO
            AND a.FECHAPROCESO = mc.FECHAPROCESO
            AND a.ESTADO = 77
        INNER JOIN MONEDAS m
        ON mc.MONEDA = m.C6399
            AND m.TZ_LOCK = 0
        INNER JOIN SUCURSALES s
        ON mc.SUCURSAL_CUENTA = s.SUCURSAL
            AND s.TZ_LOCK = 0
        LEFT JOIN GRL_SALDOS_DIARIOS gsd
        ON mc.RUBROCONTABLE = gsd.RUBROCONTABLE
            AND mc.SALDO_JTS_OID = gsd.SALDOS_JTS_OID
            AND gsd.TZ_LOCK = 0
            AND gsd.FECHA = dbo.ReducirDiasHabiles(mc.FECHAPROCESO, 1)
    WHERE mc.FECHAPROCESO = @fecha
        AND mc.RUBROCONTABLE = @cuenta
        AND mc.SUCURSAL_CUENTA = 97
    GROUP BY mc.SUCURSAL_CUENTA, s.NOMBRESUCURSAL, mc.FECHAPROCESO, mc.RUBROCONTABLE, mc.moneda, m.C6400, gsd.SALDO_AL_CORTE;

    -- Verificar si se encontró un resultado
    IF @@ROWCOUNT = 0
    BEGIN
        SET @codigoError = 1;
        RETURN;
    END

    -- Asignar valores a variables de salida
    SET @sucursalAlta = @tmpSucursalAlta;
    SET @fechaAsiento = @tmpFechaAsiento;
    SET @moneda = @tmpMoneda;
    SET @cuentaRubro = @tmpCuentaRubro;
    SET @importeHaber = @tmpImporteHaber;
    SET @importeDebe = @tmpImporteDebe;
    SET @importeContabilidad = @tmpImporteHaber - @tmpImporteDebe;
    SET @saldoAnterior = @tmpSaldoAnterior;
    SET @codigoError = 0;
END')
