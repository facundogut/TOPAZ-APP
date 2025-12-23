EXECUTE('
CREATE OR ALTER   PROCEDURE SP_REL_CUENTA_COMIT_ID_CLIENTE
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
	@clienteHabilitado INT

--no son num
SET @idCliente = (SELECT CASE WHEN ISNUMERIC(@idCliente) = 1 AND LEN(@idCliente) <= 12 THEN @idCliente ELSE ''-'' END);

SET @cuentaComitente = (SELECT CASE WHEN isnumeric(@cuentaComitente) = 1 AND LEN(@cuentaComitente) <= 12 THEN @cuentaComitente ELSE ''-'' END);

IF (@idCliente <> ''-'' AND @cuentaComitente <> ''-'')

BEGIN

	SELECT @clienteOk = COUNT(*), @clienteHabilitado = ESTADO FROM CLI_CLIENTES clie (nolock)
	WHERE clie.CODIGOCLIENTE = CONVERT(NUMERIC(12,0),@idCliente)
	group by CODIGOCLIENTE, ESTADO;
	
	IF(ISNULL(@clienteOk,0) = 0)
		BEGIN
			SET @descripcion = ''Cliente no existe.'';
			SET @textoResultado = ''ERROR'';
	   		SET @codigoResultado = 500;
	   	END 
	ELSE IF(ISNULL(@clienteHabilitado,0) = 1)
		BEGIN
			SET @descripcion = ''Cliente inhabilitado'';
			SET @textoResultado = ''ERROR'';
	   		SET @codigoResultado = 500;
		END
	ELSE
		BEGIN			
			SELECT @existeCuenta = count(*) FROM REL_CLIENTE_CTA_COMITENTE (nolock) 
			                                WHERE Cuenta = CONVERT(NUMERIC(12,0),@cuentaComitente)
			                                  AND Cliente = CONVERT(NUMERIC(12,0),@idCliente);
			
			/*
			SELECT @existeCliente = count(*) FROM REL_CLIENTE_CTA_COMITENTE (nolock) 
			                                WHERE Cliente = CONVERT(NUMERIC(12,0),@idCliente);		
			*/
			IF (ISNULL(@existeCuenta,0) = 0 /*AND @existeCliente = 0*/)  
			   BEGIN
			      INSERT INTO REL_CLIENTE_CTA_COMITENTE VALUES (@cuentaComitente, @idCliente, @fechaAlta);			
			      SET @descripcion = ''Relacion realizada correctamente.'';
			      SET @textoResultado = ''OK'';
	   		      SET @codigoResultado = 200;
	   		      RETURN;
	   		   END   
	   		ELSE IF(@existeCuenta = 1 /*AND @existeCliente = 1*/)
	   		   BEGIN
	   		      SET @descripcion = ''La cuenta ya esta registrada.'';
			      SET @textoResultado = ''OK'';
	   		      SET @codigoResultado = 200; 
	   		      RETURN; 		      
	   		   END 
	   	    /*ELSE IF(@existeCuenta = 0 AND @existeCliente = 1)
	   		   BEGIN
	   		      UPDATE REL_CLIENTE_CTA_COMITENTE 
			        SET Cuenta = @cuentaComitente,
			             FechaAlta = @fechaAlta 
			      WHERE Cliente = @idCliente;
			       			
			      SET @descripcion = ''Relacion actualizada correctamente.'';
			      SET @textoResultado = ''OK'';
	   		      SET @codigoResultado = 200;  		      
	   		   END
	   		 ELSE IF(@existeCuenta = 1 AND @existeCliente = 0)
	   		   BEGIN
	   		      UPDATE REL_CLIENTE_CTA_COMITENTE 
			        SET Cliente = @idCliente,
			             FechaAlta = @fechaAlta 
			      WHERE Cuenta = @cuentaComitente;
			       			
			      SET @descripcion = ''Relacion actualizada correctamente.'';
			      SET @textoResultado = ''OK'';
	   		      SET @codigoResultado = 200;  		      
	   		   END*/	  	   		             
	   		END        
		END
	

ELSE --no son num
BEGIN
	SET @descripcion = ''Cuenta o Cliente inválidos.'';
	SET @textoResultado = ''ERROR'';
	SET @codigoResultado = 500;
END

END
')