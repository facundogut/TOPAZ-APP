
execute('DROP TABLE IF EXISTS SIBE_BALANCES');
execute('CREATE TABLE dbo.SIBE_BALANCES
	(
	Cuit     NUMERIC (11) NOT NULL,
	FecVent  NUMERIC (8),
	MonVent  NUMERIC (15, 2),
	RPC      NUMERIC (15, 2),
	FecVig   NUMERIC (8),
	Tipo     VARCHAR (1),
	NroEjerc NUMERIC (15) NOT NULL,
	PRIMARY KEY (Cuit, NroEjerc)
	)');
execute('
CREATE OR ALTER PROCEDURE SP_SIBE_REGISTRO_BALANCES (
     @p_Cuit VARCHAR(15),
     @p_Tipo VARCHAR(15),
     @p_NroEjerc VARCHAR(15),     
     @p_FecVent VARCHAR(15),
     @p_RPC VARCHAR(15),
     @p_FecVig VARCHAR(15), 
     @p_MonVent VARCHAR(15),     
    

     @p_Message VARCHAR(100) output
)

as
BEGIN

DECLARE @ErrorMessage NVARCHAR(200);


    
    -- Validaciones
    IF LEN(@p_Cuit) != 11  OR TRY_CONVERT(NUMERIC(11, 0), @p_Cuit) IS NULL
    begin
		THROW 50000, ''Error: Cuit debe tener una longitud de 11 dígitos y ser numerico.'', 1;
    END
    if TRY_CONVERT(DATE, @p_FecVent,103) IS NULL
    BEGIN
    SET @ErrorMessage = CONCAT(''Fecha venta no válida. Valor de la variable: '', @p_FecVent);
		THROW 50000, @ErrorMessage, 1;
    END 
    if TRY_CONVERT(DATE, @p_FecVig,103) IS NULL OR TRY_CONVERT(DATE, @p_FecVig,103) <= (SELECT fechaproceso
    																			FROM PARAMETROS)
    BEGIN
        SET @ErrorMessage = CONCAT(''Fecha vigencia no válida, debe ser mayor a la fecha proceso. Valor de la variable: '', @p_FecVig);
		THROW 50000, @ErrorMessage, 1;
    END
    if LEN(@p_Tipo) <> 1 OR  PATINDEX(''%[A-Za-z]%'', @p_Tipo) = 0
    BEGIN
    SET @ErrorMessage = CONCAT(''Balance Manif no válido.. Valor de la variable: '', @p_Tipo);
    	THROW 50000, @ErrorMessage, 1;
    END         
    IF TRY_CONVERT(NUMERIC(15, 0), @p_NroEjerc) IS NULL
BEGIN
    SET @ErrorMessage = CONCAT(''Valor no válido como número entero. Variable: @p_NroEjerc, Valor: '', CAST(@p_NroEjerc AS VARCHAR(15)));
    THROW 50000, @ErrorMessage, 1;
END

IF TRY_CONVERT(NUMERIC(15, 2), @p_RPC) IS NULL
BEGIN
    SET @ErrorMessage = CONCAT(''Valor no válido como número con 2 decimales. Variable: @p_RPC, Valor: '', CAST(@p_RPC AS VARCHAR(15)));
    THROW 50000, @ErrorMessage, 1;
END

IF TRY_CONVERT(NUMERIC(15, 2), @p_MonVent) IS NULL
BEGIN
    SET @ErrorMessage = CONCAT(''Valor no válido como número con 2 decimales. Variable: @p_MonVent, Valor: '', CAST(@p_MonVent AS VARCHAR(15)));
    THROW 50000, @ErrorMessage, 1;
END        

DECLARE @v_Cuit NUMERIC(11, 0);
DECLARE @v_FecVent NUMERIC(8, 0);
DECLARE @v_MonVent NUMERIC(15, 2);
DECLARE @v_RPC NUMERIC(15, 2);
DECLARE @v_FecVig NUMERIC(8, 0);
DECLARE @v_Tipo VARCHAR(1);
DECLARE @v_NroEjerc NUMERIC(15, 0);

SET @v_Cuit = CONVERT(NUMERIC(11, 0), @p_Cuit);
SET @v_FecVent = CONVERT(NUMERIC(8, 0), REPLACE(@p_FecVent, ''/'', ''''));
SET @v_MonVent = CONVERT(NUMERIC(15, 2), @p_MonVent);
SET @v_RPC = CONVERT(NUMERIC(15, 2), @p_RPC);
SET @v_FecVig = CONVERT(NUMERIC(8, 0), REPLACE(@p_FecVig, ''/'', ''''));
SET @v_Tipo = CONVERT(VARCHAR(1), @p_Tipo);
SET @v_NroEjerc = CONVERT(NUMERIC(15, 0), @p_NroEjerc);
            
    -- Verificar si ya existe el Cuit/NroEjerc en la tabla
    IF(
    	SELECT COUNT(*) 
    	FROM SIBE_BALANCES
    	WHERE Cuit = @v_Cuit AND NroEjerc = @v_NroEjerc) >0
	BEGIN 
        -- Realizar UPDATE si ya existe el Cuit/NroEjerc en la tabla
        UPDATE SIBE_BALANCES
        SET FecVent = @v_FecVent,
            MonVent = @v_MonVent,
            RPC = @v_RPC,
            FecVig = @v_FecVig,
            Tipo = @v_Tipo
        WHERE Cuit = @v_Cuit AND NroEjerc = @v_NroEjerc;

        SET @p_Message = ''Balance actualizado'';
    END 
    ELSE
    BEGIN
        -- Verificar si existe algún balance (viejo) con el mismo Cuit y Fecha de Vigencia
       

        IF ( SELECT FecVig 
        	FROM SIBE_BALANCES
        	WHERE Cuit = @v_Cuit AND FecVig = @v_FecVig) IS NOT NULL 
            -- Realizar UPDATE de los campos restantes si ya existe algún balance (viejo)
        BEGIN    
            UPDATE SIBE_BALANCES
            SET FecVent = @v_FecVent,
                MonVent = @v_MonVent,
                RPC = @v_RPC,
                Tipo = @v_Tipo,
                NroEjerc = @v_NroEjerc
            WHERE Cuit = @v_Cuit AND FecVig = @v_FecVig;

            SET @p_Message = ''Balance actualizado'';
        END 
        ELSE
        BEGIN
            INSERT INTO SIBE_BALANCES (Cuit, 
            						   FecVent, 
            						   MonVent, 
            						   RPC, 
            						   FecVig, 
            						   Tipo, 
            						   NroEjerc)
            VALUES (@v_Cuit, 
            		@v_FecVent, 
            		@v_MonVent, 
            		@v_RPC, 
            		@v_FecVig, 
            		@v_Tipo, 
            		@v_NroEjerc);

            SET @p_Message = ''Balance registrado'';
        END        
     END          

END;
'
);



