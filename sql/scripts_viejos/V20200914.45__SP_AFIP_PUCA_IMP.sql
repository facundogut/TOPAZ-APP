CREATE   PROCEDURE SP_AFIP_PUCA_IMP @TICKET AS NUMERIC(16), @iva VARCHAR(2) OUTPUT, @iga VARCHAR(2) OUTPUT, @mono VARCHAR(2) OUTPUT

AS
BEGIN
	
	SET @iva = 'NI';
	SET @iga = 'NI';
	SET @mono = 'NI';
	
	DECLARE cursor_impuestos CURSOR FOR
	
	SELECT I.IMPUESTO FROM ITF_AFIP_IMP (nolock) I WHERE ID_TICKET = @TICKET
	
	DECLARE @cod_impuesto NUMERIC(16,0);
	
	OPEN cursor_impuestos

	FETCH NEXT FROM cursor_impuestos INTO @cod_impuesto
	
	
	WHILE @@fetch_status = 0
	BEGIN
	IF @cod_impuesto <> 0 
		
		IF @cod_impuesto = 11 OR @cod_impuesto = 10
		BEGIN
			SET @iga = 'AC';
		END
		
		IF @cod_impuesto = 30
		BEGIN
			SET @iva = 'AC';
		END
		
		IF @cod_impuesto = 32
		BEGIN
			SET @iva = 'EX';
		END
		
		IF @cod_impuesto = 20
		BEGIN
			SET @mono = 'AC';
		END
		
		FETCH NEXT FROM cursor_impuestos INTO @cod_impuesto
	
	END 
	PRINT CAST(@iva as varchar(2)) + CAST(@iga as varchar(2)) + CAST(@mono as varchar(2))
	CLOSE cursor_impuestos 
	DEALLOCATE cursor_impuestos 
END
