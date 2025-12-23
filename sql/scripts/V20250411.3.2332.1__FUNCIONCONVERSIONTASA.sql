EXECUTE('
CREATE OR ALTER FUNCTION dbo.CONVERSION_TASA (@PERIODO_ASIST NUMERIC(10), @C1632 NUMERIC(11,7),
@C6253 VARCHAR(1),@C6255 NUMERIC(5,0),@TIPO_CONVERSION VARCHAR(5) )
RETURNS NUMERIC(11,7)
AS
-- Recibe de la tabla Saldos: JTS_OID, TEA y PRODUCTO.
-- Luego obtiene los datos necesarios para realizar el cálculo del TNA.
BEGIN
	
    -- Inicializar TNA = 0 en caso de error
    DECLARE @TASA NUMERIC(11,7);
    SET @TASA = 0;
	
    -- Declaración de variables
	DECLARE @PERIODO NUMERIC(10,5);
    
    -- Obtener el periodo promedio
    IF @TIPO_CONVERSION = 0
    BEGIN 
    	SET @PERIODO = round(@C6255/@PERIODO_ASIST,5,1) -- Truncar, NO redondear a 5 decimales
    END 
    ELSE 
    BEGIN
    	SET @PERIODO = @PERIODO_ASIST
    END

    -- Calcular TNA: Sólo si es tipo efectiva se realiza la conversión a nominal
    IF @PERIODO IS NOT NULL AND @C6253 IS NOT NULL AND @C6255 IS NOT NULL
    BEGIN
        IF @C6253 = ''E''
        BEGIN
            SET @TASA = (CAST(@C6255 AS NUMERIC(11,7)) / @PERIODO) * 
                       (POWER((1 + (@C1632 / 100)), (1 / (CAST(@C6255 AS NUMERIC(11,7)) / @PERIODO))) - 1) * 100;
        END
        ELSE IF @C6253 = ''N''
        BEGIN
            SET @TASA = ROUND(CAST((POWER((1 + CAST((@C1632)AS NUMERIC(11,7)) / (@C6255 *100)*@PERIODO), ((CAST(@C6255 AS NUMERIC(11,7)) / @PERIODO))) - 1) * 100 AS NUMERIC(11,7)),4,1)
            			
        END
    END

    RETURN @TASA;
END;
')