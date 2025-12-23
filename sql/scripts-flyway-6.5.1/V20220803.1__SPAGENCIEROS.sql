Execute('CREATE OR ALTER   PROCEDURE [dbo].[SP_ITF_AGENCIEROS]  
											   @NRO_CUENTA NUMERIC(10,0),
											   @SUCURSAL NUMERIC(5,0),
											   @TIPO_CUENTA NUMERIC(1,0),
											   @FECHA INT,
											   @NRO_SORTEO NUMERIC(5,0),
											   @AGENCIA NUMERIC(4,0),
											   @IMPORTE INT,
											   @OPERACION_1 NUMERIC(1,0),
											   @OPERACION_2 NUMERIC(1,0),
											   @OPERACION_3 NUMERIC(1,0),
											   @OPERACION_4 NUMERIC(1,0),
											   @ERROR_OPERACION INT,
											   @FECHA_SORTEO VARCHAR(20),
											   @CAJA_DEBITO VARCHAR(1),
											   @CUENTA_CERO INT,
											   @JTS_OID NUMERIC(10,0) OUTPUT,
											   @ERRORS VARCHAR(50) OUTPUT,
											   @ESTADO VARCHAR(1) OUTPUT,
											   @DETALLE_ESTADO VARCHAR(10) OUTPUT,
											   @ERRORFECHA INT OUTPUT
											   



AS 
   DECLARE @cant NUMERIC(5,0) = 0;
   DECLARE @cant_sucursal NUMERIC(5,0) = 0;
   DECLARE @cant_cuenta NUMERIC(5,0) = 0;
   DECLARE @cant_tipo_cuenta NUMERIC(5,0) = 0;
   DECLARE @cant_registros NUMERIC(5,0)=0;
	
   SET @ERRORFECHA = 0;
   SET @ERRORS ='''';
   SET @ESTADO = ''E'';
   SET @DETALLE_ESTADO= ''Error''
   BEGIN
   	IF @CAJA_DEBITO = ''D''
   	BEGIN
   	SET @cant_tipo_cuenta = (	SELECT count(*) 
							FROM SALDOS WITH (NOLOCK) 
							WHERE C1785 = @TIPO_CUENTA AND CUENTA = @NRO_CUENTA
								AND TZ_LOCK=0);
   	
   	IF @cant_tipo_cuenta = 0  -- Tipo de cuenta incorrecto, o cuenta no definida.
   		BEGIN
   			SET @ERRORS = ''001 '';
  		END   	
   	
	SET @cant_sucursal = (	SELECT count(*) 
							FROM SALDOS  WITH (NOLOCK)
							WHERE SUCURSAL=@SUCURSAL AND CUENTA = @NRO_CUENTA
							AND TZ_LOCK=0 );
	
   	IF @cant_sucursal = 0  -- Sucursal inexistente.
   		BEGIN
   			SET @ERRORS = CONCAT(@ERRORS,''002 '');
  		END   
 	
 	IF @CUENTA_CERO = 1
 		BEGIN
 			SET @JTS_OID=0;
 		END
 	ELSE
 		BEGIN
	   	SET @cant_cuenta = (	SELECT count(*) 
								FROM SALDOS  WITH (NOLOCK)
								WHERE CUENTA=@NRO_CUENTA AND MONEDA=1 AND  C1785 = @TIPO_CUENTA 
								AND TZ_LOCK=0);
								
	   	IF @cant_cuenta = 0  -- Numero de cuenta inexistente.
	   		BEGIN
	   			SET @ERRORS = CONCAT(@ERRORS,''003 '');
	  		END
	  	ELSE 
	  		BEGIN
	  			SET @JTS_OID = (SELECT JTS_OID 
								FROM SALDOS  WITH (NOLOCK)
								WHERE CUENTA=@NRO_CUENTA AND MONEDA=1 AND  C1785 = @TIPO_CUENTA 
								AND TZ_LOCK=0)
	  		END
	 	END 
	  		
  	SET @cant_cuenta =0;
  	SET @cant_cuenta = (	SELECT count(*) 
							FROM SALDOS  WITH (NOLOCK)
							WHERE CUENTA=@NRO_CUENTA AND C1651=''1'' AND TZ_LOCK = 0
							AND  C1785 = @TIPO_CUENTA );
							
   	IF @cant_cuenta > 0  -- Cuenta dada de baja..
   		BEGIN
   			SET @ERRORS = CONCAT(@ERRORS,''004 '');
  		END 
  		
  	
   	SET @cant_cuenta =0;
  	SET @cant_cuenta = (  SELECT count(*) 
  						  FROM SALDOS AS s, GRL_BLOQUEOS AS g WITH (NOLOCK)
  						  WHERE C1679=''1'' AND s.JTS_OID=g.SALDO_JTS_OID AND s.CUENTA=@NRO_CUENTA AND s.TZ_LOCK=0
						   AND g.TZ_LOCK = 0 AND  C1785 = @TIPO_CUENTA);
							
   	IF @cant_cuenta > 0  -- Cuenta Bloqueada.
   		BEGIN
   			SET @ERRORS = CONCAT(@ERRORS,''005 '');
  		END 
	END
	IF @FECHA = 1 Or IsDate(@FECHA_SORTEO) = 0 -- Fecha invalida
		BEGIN
			SET @ERRORS = CONCAT(@ERRORS,''006 '');
			SET @ERRORFECHA = 1; -- Flag para modificar la fecha en la itf sino da error al grabar la tabla
		END 		

	IF @NRO_SORTEO=0	-- Numero de sorteo igual a cero.
		BEGIN
			SET @ERRORS = CONCAT(@ERRORS,''007 '');
		END
   	
	IF @AGENCIA=0	-- Numero de agencia igual a cero.
		BEGIN
			SET @ERRORS = CONCAT(@ERRORS,''008 '');
		END	
		
	IF @IMPORTE=1	-- Importe invalido.
		BEGIN
			SET @ERRORS = CONCAT(@ERRORS,''009 '');
		END	
	IF @ERROR_OPERACION=1
		BEGIN
			SET @ERRORS = CONCAT(@ERRORS,''010 '');
		END
	SET @cant_registros=(	SELECT count(*) 
							FROM REC_Agencieros  WITH (NOLOCK)
							WHERE FECHA_SORTEO= Case When isdate(@FECHA_SORTEO) = 1 Then CAST(@FECHA_SORTEO AS DATETIME) Else null End AND NRO_SORTEO_NOCTURNO=@NRO_SORTEO AND AGENCIA=@AGENCIA AND TZ_LOCK=0)
	IF @cant_registros>0 -- Registro ya procesado.
		BEGIN
			SET @ERRORS = CONCAT(@ERRORS,''011'');
		END

	IF @ERRORS =''''
		BEGIN
			SET @ERRORS=''0'';
			SET @ESTADO=''V'';
			SET @DETALLE_ESTADO = ''Validado''
		END
	
   END;')

