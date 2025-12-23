EXECUTE('
DELETE FROM OPERACIONES WHERE IDENTIFICACION = 185;

INSERT INTO OPERACIONES
(TITULO, IDENTIFICACION, NOMBRE, DESCRIPCION, MNEMOTECNICO, AUTORIZACION, FORMULARIOPRINCIPAL, PROXOPERACION, ESTADO, TZ_LOCK, COPIAS, SUBOPERACION, PERMITEBAJA, COMPORTAMIENTOENCIERRE, REQUIERECONTRASENA, PERMITECONCURRENTE, PERMITEESTADODIFERIDO, ICONO_TITULO, ESTILO)
VALUES(6800, 185, ''Resumen por Convenio y Fecha'', ''Resumen por Convenio y Fecha'', ''185'', ''N'', NULL, NULL, ''P'', 0, NULL, 0, ''S'', ''N'', ''N'', ''N'', ''N'', NULL, 0);
')
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
    SET @codigoError = 3;

    -- Validar que @cuenta sea un numérico de hasta 15 dígitos
    IF TRY_CAST(@cuenta AS NUMERIC(15,0)) IS NULL
    BEGIN
        SET @codigoError = 2;
        RETURN;
    END

    -- Obtener resultados en variables locales
    DECLARE @tmpSucursalAlta VARCHAR(100);
    DECLARE @tmpFechaAsiento VARCHAR(10);
    DECLARE @tmpMoneda VARCHAR(100);
    DECLARE @tmpCuentaRubro NUMERIC(15,0);
    DECLARE @tmpImporteHaber NUMERIC(18,2);
    DECLARE @tmpImporteDebe NUMERIC(18,2);
    DECLARE @tmpImporteContabilidad NUMERIC(18,2);

    SELECT
        @tmpSucursalAlta = CONCAT(mc.SUCURSAL_CUENTA, '' - '', s.NOMBRESUCURSAL),
        @tmpFechaAsiento = CONVERT(VARCHAR(10), mc.FECHAPROCESO, 120),
        @tmpMoneda = CONCAT(mc.moneda, '' - '', m.C6400),
        @tmpCuentaRubro = mc.RUBROCONTABLE,
        @tmpImporteHaber = SUM(CASE WHEN mc.DEBITOCREDITO = ''D'' THEN CAPITALREALIZADO ELSE 0 END),
        @tmpImporteDebe = SUM(CASE WHEN mc.DEBITOCREDITO = ''C'' THEN CAPITALREALIZADO ELSE 0 END)
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
    WHERE mc.FECHAPROCESO = @fecha
        AND mc.RUBROCONTABLE = @cuenta
        AND mc.SUCURSAL_CUENTA = 97
    GROUP BY mc.SUCURSAL_CUENTA, s.NOMBRESUCURSAL, mc.FECHAPROCESO, mc.RUBROCONTABLE, mc.moneda, m.C6400;

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
    SET @codigoError = 0;
END')
