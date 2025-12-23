EXECUTE('
CREATE OR ALTER FUNCTION dbo.ITF_DEVUELVE_TITULAR(@CodigoCliente NUMERIC(12,0), @cantidad NUMERIC(3,0)) 
RETURNS VARCHAR(500)
/* parametros in: id_solicitud y cantidad de cuentas que se quieran mostrar como maximo*/
AS
BEGIN		
	
	DECLARE @iterador NUMERIC(3,0) = 0;
	DECLARE @resultado VARCHAR(500) = '''';
	DECLARE @APE_NOMBRE VARCHAR(100);
	
	DECLARE CURSOR_CUENTA CURSOR FOR
	SELECT  APE_NOMBRE FROM VW_CLIENTES_PERSONAS 
	WHERE CODIGOCLIENTE = @CodigoCliente AND TITULARIDAD = ''T'' ORDER BY NUMEROPERSONA; 
	OPEN CURSOR_CUENTA
	FETCH NEXT FROM CURSOR_CUENTA INTO @APE_NOMBRE
	
	WHILE @@fetch_status = 0
	BEGIN							
		SET @iterador = @iterador + 1;
		
		
		IF @iterador = @cantidad
		BEGIN
			SET @resultado = @APE_NOMBRE;
		END;
		
		/*Se mueve al siguiente registro dentro del cursor*/
		FETCH NEXT FROM CURSOR_CUENTA INTO @APE_NOMBRE
	
	END 
		   
	CLOSE CURSOR_CUENTA    -- Cierra el cursor.
	DEALLOCATE CURSOR_CUENTA
	
	RETURN @resultado
END;
')


