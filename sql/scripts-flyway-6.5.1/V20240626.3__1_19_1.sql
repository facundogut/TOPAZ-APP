Execute('IF OBJECT_ID (''dbo.REL_CLIENTE_CTA_COMITENTE'') IS NOT NULL
	DROP TABLE dbo.REL_CLIENTE_CTA_COMITENTE


CREATE TABLE dbo.REL_CLIENTE_CTA_COMITENTE
	(
	Cuenta    NUMERIC (12) NOT NULL,
	Cliente   NUMERIC (12) NOT NULL,
	FechaAlta DATE,
	CONSTRAINT pk_rel_cli PRIMARY KEY (Cliente)
	)')
Execute('CREATE OR ALTER   PROC SP_REL_CUENTA_COMIT_ID_CLIENTE
	@idCliente VARCHAR(12), 
	@cuentaComitente VARCHAR(12),
	@descripcion VARCHAR (80) OUTPUT,
	@textoResultado VARCHAR(10) OUTPUT,
	@codigoResultado NUMERIC(5) OUTPUT

AS
BEGIN

DECLARE
	@fechaAlta DATE = (SELECT CAST(fechaproceso AS DATE) FROM PARAMETROS (nolock)),	
	@clienteOk INT,
	@saldoOk INT,
	@existeCliente INT

--no son num
SET @idCliente = (SELECT CASE WHEN isnumeric(@idCliente) = 1 THEN @idCliente ELSE ''-'' END);
SET @cuentaComitente = (SELECT CASE WHEN isnumeric(@cuentaComitente) = 1 THEN @cuentaComitente ELSE ''-'' END);

IF (@idCliente <> ''-'' AND @cuentaComitente <> ''-'')
BEGIN
	
	
	SELECT @clienteOk = COUNT(*)  FROM CLI_CLIENTES clie (nolock);

   	SELECT @saldoOk = COUNT(*) FROM CLI_CLIENTES clie (nolock) 
		JOIN SALDOS sal (nolock) ON clie.CODIGOCLIENTE = sal.C1803
			WHERE sal.CUENTA = @cuentaComitente
		
	IF(@clienteOk = 0)
		BEGIN
			SET @descripcion = ''Cliente no existe.'';
			SET @textoResultado = ''ERROR'';
	   		SET @codigoResultado = 500;
	   	END 
	ELSE IF (@saldoOk = 0)
		BEGIN
			SET @descripcion = ''Cuenta inexistente o no esta asociada al Cliente.'';	 
			SET @textoResultado = ''ERROR'';
	   		SET @codigoResultado = 500;
		END 	
	ELSE 
		BEGIN			
			SELECT @existeCliente = count(*) FROM REL_CLIENTE_CTA_COMITENTE (nolock) WHERE Cliente = @idCliente;
			IF (@existeCliente = 0)  
			   BEGIN
			      INSERT INTO REL_CLIENTE_CTA_COMITENTE VALUES (@cuentaComitente, @idCliente, @fechaAlta);			
			      SET @descripcion = ''Relacion realizada correctamente.'';
			      SET @textoResultado = ''OK'';
	   		      SET @codigoResultado = 200;
	   		   END   
	   		ELSE
	   		   BEGIN
			      UPDATE REL_CLIENTE_CTA_COMITENTE 
			        SET Cuenta = @cuentaComitente,
			            FechaAlta = @fechaAlta 
			      WHERE Cliente = @idCliente;
			        			
			      SET @descripcion = ''Relacion actualizada correctamente.'';
			      SET @textoResultado = ''OK'';
	   		      SET @codigoResultado = 200;
	   		   END        
		END
	
END
ELSE --no son num
BEGIN
	SET @descripcion = ''Cuenta y Cliente deben ser numericos.'';
	SET @textoResultado = ''ERROR'';
	SET @codigoResultado = 500;

END

--SELECT @descripcion, @textoResultado, @codigoResultado;

END')


