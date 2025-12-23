EXECUTE('
CREATE OR ALTER   PROCEDURE ITF_BitacoraAsientoOrdinal
@Sucursal INT,
@Fecha   DATE,
@Tipo    VARCHAR(1),
@Asiento  NUMERIC(10) OUTPUT,
@Ordinal  NUMERIC(6) OUTPUT
AS
BEGIN
    DECLARE @AsientoAux NUMERIC(10);
    DECLARE @OrdinalAux NUMERIC(6);
	
	IF @Tipo = ''C''
	BEGIN
		SELECT @AsientoAux = ISNULL(MIN(Asiento), 9999999999)
	    FROM BITACORA_CLIENTES 
	    WHERE Sucursal = @Sucursal 
	      AND Fecha = @Fecha
	      AND ASIENTO >= 9999999990;
	      
	    SELECT @OrdinalAux = ISNULL(MAX(Ordinal), 1)
	    FROM BITACORA_CLIENTES 
	    WHERE Sucursal = @Sucursal 
	      AND Fecha = @Fecha
	      AND ASIENTO = @AsientoAux;
	END;
	
	IF @Tipo = ''F''
	BEGIN
		SELECT @AsientoAux = ISNULL(MIN(Asiento), 9999999999)
	    FROM BITACORA_PERSONAS_FISICAS 
	    WHERE Sucursal = @Sucursal 
	      AND Fecha = @Fecha
	      AND ASIENTO >= 9999999990;
	      
		SELECT @OrdinalAux = ISNULL(MAX(Ordinal), 1)
	    FROM BITACORA_PERSONAS_FISICAS 
	    WHERE Sucursal = @Sucursal 
	      AND Fecha = @Fecha
	      AND ASIENTO = @AsientoAux;
	END;
	
	IF @Tipo = ''J''
	BEGIN
		SELECT @AsientoAux = ISNULL(MIN(Asiento), 9999999999)
	    FROM BITACORA_PERSONAS_JURIDICAS 
	    WHERE Sucursal = @Sucursal 
	      AND Fecha = @Fecha
	      AND ASIENTO >= 9999999990;
	    
	    SELECT @OrdinalAux = ISNULL(MAX(Ordinal), 1)
	    FROM BITACORA_PERSONAS_JURIDICAS 
	    WHERE Sucursal = @Sucursal 
	      AND Fecha = @Fecha
	      AND ASIENTO = @AsientoAux;
	      
	END;
	
	-- Verifico si el ordinal alcanzo 999999
    IF @OrdinalAux = 999999
    BEGIN
        SET @AsientoAux = @AsientoAux - 1; 
        SET @OrdinalAux = 1; -- Reinicio el ordinal
    END
    ELSE
    BEGIN
        SET @OrdinalAux += 1;
    END
    
    SET @Asiento = @AsientoAux;
    SET @Ordinal = @OrdinalAux;
    
END
')