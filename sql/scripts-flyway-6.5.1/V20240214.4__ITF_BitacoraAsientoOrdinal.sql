EXECUTE('
CREATE OR ALTER     PROCEDURE ITF_BitacoraAsientoOrdinal
@Sucursal INT,
@Fecha   DATE,
@Tipo    VARCHAR(1),
@Asiento  NUMERIC(10) OUTPUT,
@Ordinal  NUMERIC(6) OUTPUT
AS
BEGIN

    DECLARE @AsientoAux NUMERIC(10);
    DECLARE @OrdinalAux NUMERIC(6);
    DECLARE @Codigo 	NUMERIC(6);
    
	IF @Tipo = ''C''
	BEGIN
		SET @Codigo = 478;
		
		SELECT @OrdinalAux = NEXT VALUE FOR dbo.BITACORA_CLIENTE_ORDINAL;
		SELECT @AsientoAux = NUMERICO_1 FROM ITF_MASTER_PARAMETROS WHERE CODIGO= @Codigo;
	
		--Tener en cuenta que el maximo valor del ordinal tiene que ser el que este en la secuencia BITACORA_CLIENTE_ORDINAL
		IF @OrdinalAux = 999999 
		BEGIN
		  UPDATE ITF_MASTER_PARAMETROS 
		  SET NUMERICO_1 = NUMERICO_1 + 1
		  WHERE CODIGO= @Codigo
		  
		  ALTER SEQUENCE dbo.BITACORA_CLIENTE_ORDINAL RESTART WITH 1;
		  
		END
		
	END;
	
	IF @Tipo = ''F''
	BEGIN
		SET @Codigo = 479;
		
		SELECT @OrdinalAux = NEXT VALUE FOR dbo.BITACORA_FISICA_ORDINAL;
		SELECT @AsientoAux = NUMERICO_1 FROM ITF_MASTER_PARAMETROS WHERE CODIGO= @Codigo;
	
		--Tener en cuenta que el maximo valor del ordinal tiene que ser el que este en la secuencia BITACORA_CLIENTE_ORDINAL
		IF @OrdinalAux = 999999 
		BEGIN
		  UPDATE ITF_MASTER_PARAMETROS 
		  SET NUMERICO_1 = NUMERICO_1 + 1
		  WHERE CODIGO= @Codigo
		  
		  ALTER SEQUENCE dbo.BITACORA_FISICA_ORDINAL RESTART WITH 1;
		  
		END
		
	END;
	
	IF @Tipo = ''J''
	BEGIN
		SET @Codigo = 480;
		
		SELECT @OrdinalAux = NEXT VALUE FOR dbo.BITACORA_JURIDICA_ORDINAL;
	    SELECT @AsientoAux = NUMERICO_1 FROM ITF_MASTER_PARAMETROS WHERE CODIGO= @Codigo;
	
		--Tener en cuenta que el maximo valor del ordinal tiene que ser el que este en la secuencia BITACORA_JURIDICA_ORDINAL
		IF @OrdinalAux = 999999 
		BEGIN
		  UPDATE ITF_MASTER_PARAMETROS 
		  SET NUMERICO_1 = NUMERICO_1 + 1
		  WHERE CODIGO= @Codigo
		  
		  ALTER SEQUENCE dbo.BITACORA_JURIDICA_ORDINAL RESTART WITH 1;
		  
		END
		  
	END;
    
    SET @Asiento = @AsientoAux;
    SET @Ordinal = @OrdinalAux;
    
END
')