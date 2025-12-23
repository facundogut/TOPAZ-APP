Execute('CREATE TABLE dbo.ITF_BEE_TENENCIA
(
  	ID_EJECUCION BIGINT IDENTITY(1,1) PRIMARY KEY,
	NOMBRE varchar(30) NOT NULL ,
	NUMERO_VERSION int NOT NULL,
	FECHA_PROCESO DATETIME NOT NULL,
	FECHA_RELOJ DATETIME NOT NULL
);')

Execute('CREATE FUNCTION dbo.calcularTNA (@JTS_OID NUMERIC(15,2), @TEA NUMERIC(11,7), @PRODUCTO NUMERIC(5,0))
RETURNS NUMERIC(11,7)
AS

-- Recibe de la tabla Saldos: JTS_OID, TEA y PRODUCTO.
-- Luego obtiene los datos necesarios para realizar el cálculo del TNA.

BEGIN
	
    -- Inicializar TNA = 0 en caso de error
    DECLARE @TNA NUMERIC(11,7);
    SET @TNA = 0;
	
    -- Declaración de variables
	DECLARE @PERIODO NUMERIC(5,0);
    DECLARE @C6253 CHAR(1); --Tipo de Tasa (Forma calculo Int.)
    DECLARE @C6255 NUMERIC(5,0); --Divisor p/calculo de interes

    -- Obtener el periodo promedio
    SELECT @PERIODO = AVG(DATEDIFF(DD, C2301, C2302))
    FROM PLANPAGOS
    WHERE SALDO_JTS_OID = @JTS_OID AND TZ_LOCK = 0;

    -- Obtener los valores de C6253 y C6255
    SELECT @C6253 = Prd.C6253, @C6255 = Prd.C6255
    FROM PRODUCTOS AS Prd
    WHERE Prd.C6250 = @PRODUCTO AND Prd.TZ_LOCK = 0;

    -- Calcular TNA: Sólo si es tipo efectiva se realiza la conversión a nominal
    IF @PERIODO IS NOT NULL AND @C6253 IS NOT NULL AND @C6255 IS NOT NULL
    BEGIN
        IF @C6253 = ''E''
        BEGIN
            SET @TNA = (CAST(@C6255 AS NUMERIC(11,7)) / @PERIODO) * 
                       (POWER((1 + (@TEA / 100)), (1 / (CAST(@C6255 AS NUMERIC(11,7)) / @PERIODO))) - 1) * 100;
        END
        ELSE IF @C6253 = ''N''
        BEGIN
            SET @TNA = @TEA;
        END
    END

    RETURN CAST(@TNA AS DECIMAL(11,7));
END;')