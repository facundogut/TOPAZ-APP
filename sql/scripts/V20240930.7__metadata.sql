CREATE OR ALTER PROCEDURE SP_REL_CUENTA_COMIT_ID_CLIENTE
    @idCliente VARCHAR(15), 
    @cuentaComitente VARCHAR(15),
    @descripcion VARCHAR (80) OUTPUT,
    @textoResultado VARCHAR(10) OUTPUT,
    @codigoResultado NUMERIC(5) OUTPUT
AS
BEGIN
    DECLARE
        @fechaAlta DATE = (SELECT CAST(fechaproceso AS DATE) FROM PARAMETROS (nolock)),    
        @clienteOk INT,
        @existeCliente INT,
        @existeCuenta INT,
        @clienteHabilitado INT;

    IF TRY_CONVERT(NUMERIC(12,0), @idCliente) IS NULL OR LEN(@idCliente) > 12
        SET @idCliente = '-';

    IF TRY_CONVERT(NUMERIC(12,0), @cuentaComitente) IS NULL OR LEN(@cuentaComitente) > 12
        SET @cuentaComitente = '-';

    IF (@idCliente = '-' OR @cuentaComitente = '-')
    BEGIN
        SET @descripcion = 'Cuenta o Cliente inválidos.';
        SET @textoResultado = 'ERROR';
        SET @codigoResultado = 500;
        RETURN;
    END

    BEGIN TRY
        SELECT @clienteOk = COUNT(*) FROM CLI_CLIENTES clie (nolock) WHERE clie.CODIGOCLIENTE = CONVERT(NUMERIC(12,0), @idCliente);
		SELECT @clienteHabilitado = MAX(ESTADO) FROM CLI_CLIENTES clie (nolock) WHERE clie.CODIGOCLIENTE = CONVERT(NUMERIC(12,0), @idCliente);

	IF(@clienteOk = 0)
	    BEGIN
            SET @descripcion = 'Cliente no existe.';
            SET @textoResultado = 'ERROR';
            SET @codigoResultado = 500;
            RETURN;
        END
	ELSE IF(@clienteHabilitado = 1)
    	BEGIN
            SET @descripcion = 'Cliente inhabilitado.';
            SET @textoResultado = 'ERROR';
            SET @codigoResultado = 500;
            RETURN;
	    END
	ELSE
		BEGIN
		    
	        SELECT @existeCuenta = COUNT(*) FROM REL_CLIENTE_CTA_COMITENTE (nolock) WHERE Cuenta = CONVERT(NUMERIC(12,0), @cuentaComitente);
		
	        SELECT @existeCliente = COUNT(*) FROM REL_CLIENTE_CTA_COMITENTE (nolock) WHERE Cliente = CONVERT(NUMERIC(12,0), @idCliente);
		
	        IF (@existeCuenta = 0 AND @existeCliente = 0)
	        BEGIN
	            INSERT INTO REL_CLIENTE_CTA_COMITENTE (Cuenta, Cliente, FechaAlta) VALUES (@cuentaComitente, @idCliente, @fechaAlta);
	
	            SET @descripcion = 'Relacion realizada correctamente.';
	            SET @textoResultado = 'OK';
	            SET @codigoResultado = 200;
	        END
	        ELSE IF(@existeCuenta = 1 AND @existeCliente = 1)
	        BEGIN
	            SET @descripcion = 'La cuenta ya está registrada.';
	            SET @textoResultado = 'OK';
	            SET @codigoResultado = 200;
	        END
	        ELSE IF(@existeCuenta = 0 AND @existeCliente = 1)
	        BEGIN
	            UPDATE REL_CLIENTE_CTA_COMITENTE 
	            SET Cuenta = @cuentaComitente, FechaAlta = @fechaAlta 
	            WHERE Cliente = @idCliente;
	
	            SET @descripcion = 'Relacion actualizada correctamente.';
	            SET @textoResultado = 'OK';
	            SET @codigoResultado = 200;
	        END
	        ELSE IF(@existeCuenta = 1 AND @existeCliente = 0)
	        BEGIN
	            UPDATE REL_CLIENTE_CTA_COMITENTE 
	            SET Cliente = @idCliente, FechaAlta = @fechaAlta 
	            WHERE Cuenta = @cuentaComitente;
	
	            SET @descripcion = 'Relacion actualizada correctamente.';
	            SET @textoResultado = 'OK';
	            SET @codigoResultado = 200;
	        END
		END
    END TRY
    BEGIN CATCH
        SET @descripcion = ERROR_MESSAGE();
        SET @textoResultado = 'ERROR';
        SET @codigoResultado = 500;
    END CATCH
END