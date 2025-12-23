EXECUTE('
CREATE OR ALTER     FUNCTION dbo.itf_cuentas_LINK (@id_solicitud NUMERIC(15,0), @cantidad NUMERIC(3,0)) 
RETURNS VARCHAR(352)
/* parametros in: id_solicitud y cantidad de cuentas que se quieran mostrar como maximo*/
AS
BEGIN		
	
	DECLARE @iterador NUMERIC(3,0) = 0;
	DECLARE @resultado VARCHAR(352) = '''';
	
	DECLARE cursor_cuentaLINK CURSOR FOR
	SELECT tipo_cuenta,nro_cuenta,estado_cuenta FROM TJD_SOLICITUD_CUENTAS_LINK WHERE ID_SOLICITUD=@id_solicitud AND TZ_LOCK=0; 
	
	DECLARE @tipo_cuenta NUMERIC(2,0);
	DECLARE @nro_cuenta NUMERIC(19,0);
	DECLARE @estado_cuenta VARCHAR(10);
	
	OPEN cursor_cuentaLINK
	FETCH NEXT FROM cursor_cuentaLINK INTO @tipo_cuenta, @nro_cuenta, @estado_cuenta
	
	WHILE @@fetch_status = 0
	BEGIN							
		SET @iterador = @iterador + 1;
		
		SET @resultado = concat(@resultado,RIGHT(''00''+CAST(@tipo_cuenta AS VARCHAR(2)),2));
		SET @resultado = concat(@resultado,RIGHT(''0000000000000000000''+CAST(@nro_cuenta AS VARCHAR(19)),19));
		SET @resultado = concat(@resultado,RTRIM(@estado_cuenta));
		/*Se mueve al siguiente registro dentro del cursor*/
		FETCH NEXT FROM cursor_cuentaLINK INTO @tipo_cuenta, @nro_cuenta, @estado_cuenta
	
	END 
	
	WHILE @iterador < @cantidad
	BEGIN
		SET @resultado = CONCAT(@resultado,''                      '');
		SET @iterador = @iterador + 1;
	END;		
		   
	CLOSE cursor_cuentaLINK    -- Cierra el cursor.
	DEALLOCATE cursor_cuentaLINK
	
	RETURN @resultado
END;
')


