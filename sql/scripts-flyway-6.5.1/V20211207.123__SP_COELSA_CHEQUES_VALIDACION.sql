EXECUTE('DROP PROCEDURE IF EXISTS dbo.SP_COELSA_CHEQUES_VALIDACION;')
EXECUTE('
CREATE PROCEDURE dbo.SP_COELSA_CHEQUES_VALIDACION @TICKET NUMERIC(16)
AS
BEGIN
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- Modified : 26/07/2021 09:00 a.m.
--- Autor: Luis Etchebarne 
--- Se agrega el manejo y validación de DPF propios recibidos.
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- Modified : 16/07/2021 09:00 a.m.
--- Autor: Luis Etchebarne 
--- Se ajustan los códigos de rechazo en base a la parametría actual. Tablas CLE_CONTROLES_RECIBIDO(CODIGO_CONTROL) y CLE_TIPO_CAUSAL(CODIGO_CAUSAL). 
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- Modified : 30/04/2021 09:00 a.m.
--- Autor: Luis Etchebarne 
--- Se elimina el hardcore del campo cod_rechazo de la tabla ITF_COELSA_CHEQUES_RECHAZO, el mismo se obtiene a través de las tablas CLE_CONTROLES_RECIBIDO(CODIGO_CONTROL) y CLE_TIPO_CAUSAL(CODIGO_CAUSAL). 
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- Created : 28/04/2021 10:00 a.m.
--- Autor: Luis Etchebarne 
--- Se crea el sp con el fin de realizar las validaciones pertinentes a los cheques propios recibidos.
--- Se crea el cursor che_cursor sobre la tabla ITF_COELSA_CHEQUES_PROPIOS y se filtran los registros del tipo C - Cheques y con estado P - Procesado 
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DECLARE @Id NUMERIC(15);
DECLARE @IdTicket NUMERIC (16);
DECLARE @IdProceso NUMERIC (15);
DECLARE @FechaProceso DATE;
DECLARE @CodTransaccion NUMERIC (2);
DECLARE @EntidadDebitar NUMERIC (8);
DECLARE @CuentaDebitar NUMERIC (17);
DECLARE @Importe NUMERIC (15, 2);
DECLARE @CodigoPostal VARCHAR (6);
DECLARE @FechaPresentado DATE;
DECLARE @FechaVencimiento DATE;
DECLARE @NroCheque NUMERIC (15);
DECLARE @PuntoIntercambio VARCHAR (16);
DECLARE @TraceNumber NUMERIC (15);
DECLARE @Estado VARCHAR (1);
DECLARE @Tipo VARCHAR (1);

DECLARE che_cursor CURSOR FOR 
SELECT ID, ID_TICKET, ID_PROCESO, FECHAPROCESO, CODIGO_TRANSACCION, ENTIDAD_DEBITAR, CUENTA_DEBITAR, IMPORTE, CODIGO_POSTAL, FECHA_PRESENTADO, FECHA_VENCIMIENTO, NRO_CHEQUE, PUNTO_INTERCAMBIO, TRACE_NUMBER, ESTADO, TIPO 
FROM dbo.ITF_COELSA_CHEQUES_PROPIOS
WHERE ESTADO = ''P''

OPEN che_cursor  

FETCH NEXT FROM che_cursor INTO @Id, @IdTicket, @IdProceso, @FechaProceso, @CodTransaccion, @EntidadDebitar, @CuentaDebitar, @Importe, @CodigoPostal, @FechaPresentado, @FechaVencimiento, @NroCheque, @PuntoIntercambio, @TraceNumber, @Estado, @Tipo 

WHILE @@FETCH_STATUS = 0  
BEGIN
	  /* Validación 92: Feriado Local */
      DECLARE @V92 NUMERIC(2);
      
      SET @V92 = (SELECT COUNT(*) FROM CLE_FERIADOS WHERE COD_POSTAL = @CodigoPostal AND Fecha = @FechaProceso); 
      
      IF (@V92 > 0)
      BEGIN
      	INSERT INTO dbo.ITF_COELSA_CHEQUES_RECHAZO (ID_TICKET, ID_PROCESO, FECHAPROCESO, CODIGO_TRANSACCION, ENTIDAD_DEBITAR, CUENTA_DEBITAR, IMPORTE, CODIGO_POSTAL, FECHA_PRESENTADO, FECHA_VENCIMIENTO, NRO_CHEQUE, PUNTO_INTERCAMBIO, TRACE_NUMBER, ESTADO, TIPO, COD_RECHAZO)
      	VALUES (@TICKET, @TICKET, @FechaProceso, @CodTransaccion, @EntidadDebitar, @CuentaDebitar, @Importe, @CodigoPostal, @FechaPresentado, @FechaVencimiento, @NroCheque, @PuntoIntercambio, @TraceNumber, @Estado, @Tipo, (SELECT CODIGO_NACHA FROM CLE_TIPO_CAUSAL T, CLE_CONTROLES_RECIBIDO C WHERE T.CODIGO_DE_CAUSAL = C.CODIGO_CAUSAL AND C.CODIGO_DE_CONTROL = 92));
      	UPDATE dbo.ITF_COELSA_CHEQUES_PROPIOS SET ESTADO = ''R'' WHERE ID = @Id;
      	GOTO Final
      END
      
      /* Validación 93: Código Postal Erroneo */
      
      DECLARE @V93 NUMERIC(5);
      DECLARE @CodPostal NUMERIC(4);
      
      SET @CodPostal = CAST(RIGHT(@CodigoPostal, 4) AS NUMERIC(4));
      SET @V93 = (SELECT COUNT(*) FROM CLI_LOCALIDADES WHERE CODIGO_POSTAL = @CodPostal);
      
      IF (@V93 = 0)
      BEGIN
      	INSERT INTO dbo.ITF_COELSA_CHEQUES_RECHAZO (ID_TICKET, ID_PROCESO, FECHAPROCESO, CODIGO_TRANSACCION, ENTIDAD_DEBITAR, CUENTA_DEBITAR, IMPORTE, CODIGO_POSTAL, FECHA_PRESENTADO, FECHA_VENCIMIENTO, NRO_CHEQUE, PUNTO_INTERCAMBIO, TRACE_NUMBER, ESTADO, TIPO, COD_RECHAZO)
      	VALUES (@TICKET, @TICKET, @FechaProceso, @CodTransaccion, @EntidadDebitar, @CuentaDebitar, @Importe, @CodigoPostal, @FechaPresentado, @FechaVencimiento, @NroCheque, @PuntoIntercambio, @TraceNumber, @Estado, @Tipo, (SELECT CODIGO_NACHA FROM CLE_TIPO_CAUSAL T, CLE_CONTROLES_RECIBIDO C WHERE T.CODIGO_DE_CAUSAL = C.CODIGO_CAUSAL AND C.CODIGO_DE_CONTROL = 93));
      	UPDATE dbo.ITF_COELSA_CHEQUES_PROPIOS SET ESTADO = ''R'' WHERE ID = @Id;
      	GOTO Final
      END
     
      
      /* Validación 94: Suc / Entid destino inexistente */
      DECLARE @Sucursal NUMERIC(4);
      DECLARE @Entidad NUMERIC(4);
      DECLARE @V94 NUMERIC(2);
      
      SET @Entidad = CAST(LEFT(@EntidadDebitar, 4) AS NUMERIC);
      SET @Sucursal = CAST(RIGHT(@EntidadDebitar, 4) AS NUMERIC);
      
      SET @V94 = (SELECT COUNT(*) FROM PARAMETROSGENERALES, SUCURSALES WHERE CODIGO = 2 AND NUMERICO = @Entidad AND SUCURSAL = @Sucursal);
      
      IF (@V94 = 0)
      BEGIN
      	INSERT INTO dbo.ITF_COELSA_CHEQUES_RECHAZO (ID_TICKET, ID_PROCESO, FECHAPROCESO, CODIGO_TRANSACCION, ENTIDAD_DEBITAR, CUENTA_DEBITAR, IMPORTE, CODIGO_POSTAL, FECHA_PRESENTADO, FECHA_VENCIMIENTO, NRO_CHEQUE, PUNTO_INTERCAMBIO, TRACE_NUMBER, ESTADO, TIPO, COD_RECHAZO)
      	VALUES (@TICKET, @TICKET, @FechaProceso, @CodTransaccion, @EntidadDebitar, @CuentaDebitar, @Importe, @CodigoPostal, @FechaPresentado, @FechaVencimiento, @NroCheque, @PuntoIntercambio, @TraceNumber, @Estado, @Tipo, (SELECT CODIGO_NACHA FROM CLE_TIPO_CAUSAL T, CLE_CONTROLES_RECIBIDO C WHERE T.CODIGO_DE_CAUSAL = C.CODIGO_CAUSAL AND C.CODIGO_DE_CONTROL = 94));
      	UPDATE dbo.ITF_COELSA_CHEQUES_PROPIOS SET ESTADO = ''R'' WHERE ID = @Id;
      	GOTO Final
      END
      
      
      /* Validación 95: Número de cuenta inválido */
      DECLARE @V95 NUMERIC(2);
      DECLARE @NumCuenta NUMERIC(12);
      
      SET @Sucursal = CAST(RIGHT(@EntidadDebitar, 4) AS NUMERIC);
      
      SET @NumCuenta = CAST(@CuentaDebitar AS NUMERIC);
        
      SET @V95 = (SELECT COUNT(*) FROM SALDOS WHERE CUENTA = @NumCuenta AND SUCURSAL = @Sucursal);
      
      IF (@V95 = 0)
      BEGIN
      	INSERT INTO dbo.ITF_COELSA_CHEQUES_RECHAZO (ID_TICKET, ID_PROCESO, FECHAPROCESO, CODIGO_TRANSACCION, ENTIDAD_DEBITAR, CUENTA_DEBITAR, IMPORTE, CODIGO_POSTAL, FECHA_PRESENTADO, FECHA_VENCIMIENTO, NRO_CHEQUE, PUNTO_INTERCAMBIO, TRACE_NUMBER, ESTADO, TIPO, COD_RECHAZO)
      	VALUES (@TICKET, @TICKET, @FechaProceso, @CodTransaccion, @EntidadDebitar, @CuentaDebitar, @Importe, @CodigoPostal, @FechaPresentado, @FechaVencimiento, @NroCheque, @PuntoIntercambio, @TraceNumber, @Estado, @Tipo, (SELECT CODIGO_NACHA FROM CLE_TIPO_CAUSAL T, CLE_CONTROLES_RECIBIDO C WHERE T.CODIGO_DE_CAUSAL = C.CODIGO_CAUSAL AND C.CODIGO_DE_CONTROL = 95));
      	UPDATE dbo.ITF_COELSA_CHEQUES_PROPIOS SET ESTADO = ''R'' WHERE ID = @Id;
      	GOTO Final		
      END
      
      /* Validación 91: Imagen Faltante */
      DECLARE @V91 NUMERIC(2);
      DECLARE @Tope NUMERIC(15,2);
      SET @Tope = (SELECT IMPORTE FROM PARAMETROSGENERALES WHERE CODIGO = 725);
      
      IF (@Importe > @Tope)
      BEGIN
      	SET @V91 = (SELECT COUNT(*) FROM ITF_COELSA_IMAGENES_CHEQUES_PROPIOS WHERE NRO_CHEQUE = @NroCheque);
      	
      	IF (@V91 = 0)
      	BEGIN
      		INSERT INTO dbo.ITF_COELSA_CHEQUES_RECHAZO (ID_TICKET, ID_PROCESO, FECHAPROCESO, CODIGO_TRANSACCION, ENTIDAD_DEBITAR, CUENTA_DEBITAR, IMPORTE, CODIGO_POSTAL, FECHA_PRESENTADO, FECHA_VENCIMIENTO, NRO_CHEQUE, PUNTO_INTERCAMBIO, TRACE_NUMBER, ESTADO, TIPO, COD_RECHAZO)
      		VALUES (@TICKET, @TICKET, @FechaProceso, @CodTransaccion, @EntidadDebitar, @CuentaDebitar, @Importe, @CodigoPostal, @FechaPresentado, @FechaVencimiento, @NroCheque, @PuntoIntercambio, @TraceNumber, @Estado, @Tipo, (SELECT CODIGO_NACHA FROM CLE_TIPO_CAUSAL T, CLE_CONTROLES_RECIBIDO C WHERE T.CODIGO_DE_CAUSAL = C.CODIGO_CAUSAL AND C.CODIGO_DE_CONTROL = 91));
      		UPDATE dbo.ITF_COELSA_CHEQUES_PROPIOS SET ESTADO = ''R'' WHERE ID = @Id;
      		GOTO Final
      	END
      END
      ELSE
      BEGIN
      	GOTO Final
      END
      
      IF (@Tipo = ''D'')
      BEGIN
      	DECLARE @V80 NUMERIC(2) = (SELECT COUNT(*) FROM PZO_SALDOS WHERE TZ_LOCK = 0 AND CERTIFICADO_DPF = @NroCheque);
      	
      	IF (@V80 = 0)
      	BEGIN
      		INSERT INTO dbo.ITF_COELSA_CHEQUES_RECHAZO (ID_TICKET, ID_PROCESO, FECHAPROCESO, CODIGO_TRANSACCION, ENTIDAD_DEBITAR, CUENTA_DEBITAR, IMPORTE, CODIGO_POSTAL, FECHA_PRESENTADO, FECHA_VENCIMIENTO, NRO_CHEQUE, PUNTO_INTERCAMBIO, TRACE_NUMBER, ESTADO, TIPO, COD_RECHAZO)
      		VALUES (@TICKET, @TICKET, @FechaProceso, @CodTransaccion, @EntidadDebitar, @CuentaDebitar, @Importe, @CodigoPostal, @FechaPresentado, @FechaVencimiento, @NroCheque, @PuntoIntercambio, @TraceNumber, @Estado, @Tipo, (SELECT CODIGO_NACHA FROM CLE_TIPO_CAUSAL T, CLE_CONTROLES_RECIBIDO C WHERE T.CODIGO_DE_CAUSAL = C.CODIGO_CAUSAL AND C.CODIGO_DE_CONTROL = 80));
      		UPDATE dbo.ITF_COELSA_CHEQUES_PROPIOS SET ESTADO = ''R'' WHERE ID = @Id;
      		GOTO Final
      	END
    
      	DECLARE @SMoneda NUMERIC(4);
   		DECLARE @SSucursal NUMERIC(4);
   		DECLARE @SEntidad NUMERIC(4);
   		DECLARE @SCliente NUMERIC(12);
   		DECLARE @SNroCuenta NUMERIC(12);
   		DECLARE @SProducto NUMERIC(15);
   		DECLARE @SOperacion NUMERIC(12);
   		DECLARE @SOrdinal NUMERIC(6);
   	
    	SET @SSucursal = CAST(RIGHT(@EntidadDebitar, 4) AS NUMERIC);
    	SET @SEntidad = CAST(LEFT(@EntidadDebitar, 4) AS NUMERIC);
      	
      	SELECT @SMoneda = S.MONEDA, @SCliente = S.C1803, @SNroCuenta = S.CUENTA, @SProducto = S.PRODUCTO, @SOperacion = S.OPERACION, @SOrdinal = S.ORDINAL  FROM SALDOS S, PZO_SALDOS P WHERE S.TZ_LOCK = 0 AND P.TZ_LOCK = 0 AND P.CERTIFICADO_DPF = @NroCheque AND P.JTS_OID_SALDO = S.JTS_OID;
      	
      	INSERT INTO CLE_DPF_RECIBIDO (MONEDA, NUMERO_DPF, CLIENTE, NUMERICO_CUENTA, PRODUCTO, OPERACION, ORDINAL, BANCO_DEPOSITANTE, CODIGO_USUARIO, FECHA_VALOR, IMPORTE, ESTADO, NUMERO_DEPENDENCIA, TRACKNUMBER, CODIGO_CAUSAL_RECHAZO)
      	VALUES (@SMoneda, @NroCheque, @SCliente, @SNroCuenta, @SProducto, @SOperacion, @SOrdinal, @SEntidad, ''TOP'', (SELECT FECHAPROCESO FROM PARAMETROS), @Importe, 1, @SSucursal, @TraceNumber, 0);
      END
      
      Final:
      FETCH NEXT FROM che_cursor INTO @Id, @IdTicket, @IdProceso, @FechaProceso, @CodTransaccion, @EntidadDebitar, @CuentaDebitar, @Importe, @CodigoPostal, @FechaPresentado, @FechaVencimiento, @NroCheque, @PuntoIntercambio, @TraceNumber, @Estado, @Tipo
END 

CLOSE che_cursor  
DEALLOCATE che_cursor
  
END;')

