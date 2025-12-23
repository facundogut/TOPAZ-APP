execute('create or ALTER   PROCEDURE [dbo].[SP_COELSA_CHEQUES_VALIDACION]
@TICKET NUMERIC(16)
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
DECLARE @InfoAdicional VARCHAR (2);

DECLARE che_cursor CURSOR FOR 
SELECT ID, ID_TICKET, ID_PROCESO, FECHAPROCESO, CODIGO_TRANSACCION, ENTIDAD_DEBITAR, CUENTA_DEBITAR, IMPORTE, CODIGO_POSTAL, FECHA_PRESENTADO, FECHA_VENCIMIENTO, NRO_CHEQUE, PUNTO_INTERCAMBIO, TRACE_NUMBER, ESTADO, TIPO, INFO_ADICIONAL
FROM dbo.ITF_COELSA_CHEQUES_PROPIOS
WHERE ESTADO = ''P''

OPEN che_cursor  

FETCH NEXT FROM che_cursor INTO @Id, @IdTicket, @IdProceso, @FechaProceso, @CodTransaccion, @EntidadDebitar, @CuentaDebitar, @Importe, @CodigoPostal, @FechaPresentado, @FechaVencimiento, @NroCheque, @PuntoIntercambio, @TraceNumber, @Estado, @Tipo, @InfoAdicional

WHILE @@FETCH_STATUS = 0  
BEGIN
		---R13---
	  /* Validación 94: Suc / Entid destino inexistente */ 
      DECLARE @Sucursal NUMERIC(4);
      DECLARE @Entidad NUMERIC(4);
      DECLARE @Parametro NUMERIC(2);
      DECLARE @Moneda NUMERIC(2);
      DECLARE @V94 NUMERIC(2);
      
      SET  @Parametro = (SELECT (CASE WHEN (SELECT LEFT(@InfoAdicional,1))=1 THEN 41 WHEN (SELECT LEFT(@InfoAdicional,1))=0 THEN 2 END));
      
      SET @EntidadDebitar = CAST(RIGHT(''0000'' + Ltrim(Rtrim(@EntidadDebitar)),8) AS NUMERIC ); 
      SET @Entidad = CAST(LEFT( CAST(RIGHT(''0000'' + Ltrim(Rtrim(@EntidadDebitar)),8) AS VARCHAR ), 4) AS NUMERIC);
      SET @Sucursal = CAST(RIGHT( CAST(RIGHT(''0000'' + Ltrim(Rtrim(@EntidadDebitar)),8) AS VARCHAR ), 4) AS NUMERIC);
      SET @Moneda = (SELECT (CASE WHEN (SELECT LEFT(@InfoAdicional,1))=1 THEN (SELECT C6399 FROM MONEDAS WHERE C6403=''D'' AND tz_lock=0) WHEN (SELECT LEFT(@InfoAdicional,1))=0 THEN (SELECT C6399 FROM MONEDAS WHERE C6403=''N'' AND tz_lock=0) END))
      
      SET @V94 = (SELECT COUNT(*) FROM PARAMETROSGENERALES, SUCURSALES WHERE CODIGO = @Parametro AND NUMERICO = @Entidad);
      IF( @Tipo=''C'' OR @Tipo=''D'')
      	BEGIN
      		SET @V94 = (SELECT COUNT(*) FROM PARAMETROSGENERALES, SUCURSALES WHERE CODIGO = @Parametro AND NUMERICO = @Entidad AND SUCURSAL = @Sucursal);
      	END 
      	
      
      IF (@V94 = 0 AND @TIPO!=''A'')
      BEGIN
      	INSERT INTO dbo.ITF_COELSA_CHEQUES_RECHAZO (ID_TICKET, ID_PROCESO, FECHAPROCESO, CODIGO_TRANSACCION, ENTIDAD_DEBITAR, CUENTA_DEBITAR, IMPORTE, CODIGO_POSTAL, FECHA_PRESENTADO, FECHA_VENCIMIENTO, NRO_CHEQUE, PUNTO_INTERCAMBIO, TRACE_NUMBER, ESTADO, TIPO, COD_RECHAZO, INFO_ADICIONAL)
      	VALUES (@TICKET, @TICKET, @FechaProceso, @CodTransaccion, @EntidadDebitar, @CuentaDebitar, @Importe, @CodigoPostal, @FechaPresentado, @FechaVencimiento, @NroCheque, @PuntoIntercambio, @TraceNumber, @Estado, @Tipo, (SELECT CODIGO_NACHA FROM CLE_TIPO_CAUSAL T, CLE_CONTROLES_RECIBIDO C WHERE T.CODIGO_DE_CAUSAL = C.CODIGO_CAUSAL AND C.CODIGO_DE_CONTROL = 94),@InfoAdicional);
      	UPDATE dbo.ITF_COELSA_CHEQUES_PROPIOS SET ESTADO = ''R'' WHERE ID = @Id;
      	GOTO Final
      END
      ---R82---
      /* Validación 91: ITF-Imagen Cheque Faltante */
      IF (@Tipo=''C'' OR @Tipo=''D'')
	  BEGIN
	      DECLARE @V91 NUMERIC(2);
      	  	  
      	  SET @V91 =  (SELECT COUNT(*) FROM ITF_COELSA_IMAGENES_CHEQUES_PROPIOS WHERE ESTADO=''R'' AND NRO_CHEQUE=@NroCheque AND NRO_CUENTA=@CuentaDebitar AND SUCURSAL_GIRADA=@Sucursal AND FECHA_PROCESO=@FechaProceso)
      	  
      	  IF(@Tipo=''C'' AND @Importe>(SELECT NUMERICO FROM PARAMETROSGENERALES WHERE CODIGO=736) AND @InfoAdicional=''00'' AND 0=(SELECT COUNT(*) FROM ITF_COELSA_CHEQUES_PROPIOS p INNER JOIN ITF_COELSA_IMAGENES_CHEQUES_PROPIOS i ON p.ID=@ID AND p.CUENTA_DEBITAR=i.NRO_CUENTA AND RIGHT(p.ENTIDAD_DEBITAR, 4)=i.SUCURSAL_GIRADA AND p.FECHAPROCESO=i.FECHA_PROCESO AND i.NRO_CUENTA=@CuentaDebitar AND i.SUCURSAL_GIRADA=@Sucursal AND i.FECHA_PROCESO=@FechaProceso))
      	  SET @V91=1;
      	  
      	  IF (@Tipo=''D'' AND 0=(SELECT COUNT(*) FROM ITF_COELSA_IMAGENES_CHEQUES_PROPIOS WHERE ESTADO=''P'' AND NRO_CHEQUE=@NroCheque AND SUCURSAL_GIRADA=@Sucursal AND FECHA_PROCESO=@FechaProceso))
	  	  SET @V91=1;
	      
	      IF (@V91 > 0)
	      BEGIN
	      	INSERT INTO dbo.ITF_COELSA_CHEQUES_RECHAZO (ID_TICKET, ID_PROCESO, FECHAPROCESO, CODIGO_TRANSACCION, ENTIDAD_DEBITAR, CUENTA_DEBITAR, IMPORTE, CODIGO_POSTAL, FECHA_PRESENTADO, FECHA_VENCIMIENTO, NRO_CHEQUE, PUNTO_INTERCAMBIO, TRACE_NUMBER, ESTADO, TIPO, COD_RECHAZO, INFO_ADICIONAL)
	      	VALUES (@TICKET, @TICKET, @FechaProceso, @CodTransaccion, @EntidadDebitar, @CuentaDebitar, @Importe, @CodigoPostal, @FechaPresentado, @FechaVencimiento, @NroCheque, @PuntoIntercambio, @TraceNumber, @Estado, @Tipo, (SELECT CODIGO_NACHA FROM CLE_TIPO_CAUSAL T, CLE_CONTROLES_RECIBIDO C WHERE T.CODIGO_DE_CAUSAL = C.CODIGO_CAUSAL AND C.CODIGO_DE_CONTROL = 91),@InfoAdicional);
	      	UPDATE dbo.ITF_COELSA_CHEQUES_PROPIOS SET ESTADO = ''R'' WHERE ID = @Id;
	      	GOTO Final
	      END			
	  END
	  
	  ---R09---
	  /* Validación 92: Feriado Local */
	  IF (@Tipo<>''  '')
	  BEGIN
	      DECLARE @V92 NUMERIC(2);
	      DECLARE @FechaPro DATETIME;
	      SET @FechaPro = (SELECT FECHAPROCESO FROM PARAMETROS);
	      IF(@Tipo = ''D'')
	      SET @Sucursal = (SELECT TOP 1 SUCURSAL FROM SALDOS WHERE OPERACION=@NroCheque AND MONEDA=@Moneda)
	      	      
	      SET @V92 = (SELECT COUNT(*) FROM FERIADOS WHERE (SUCURSAL=@Sucursal OR SUCURSAL=-1) AND DIA=FORMAT(@FechaPro,''dd'') AND MES=FORMAT(@FechaPro,''MM'') AND (ANIO=FORMAT(@FechaPro,''yyyy'') OR ANIO=0)); 
	      
	      IF(@Tipo = ''D'')
	      SET @Sucursal = CAST(RIGHT( CAST(RIGHT(''0000'' + Ltrim(Rtrim(@EntidadDebitar)),8) AS VARCHAR ), 4) AS NUMERIC);
	      
	      IF (@V92 > 0)
	      BEGIN
	      	INSERT INTO dbo.ITF_COELSA_CHEQUES_RECHAZO (ID_TICKET, ID_PROCESO, FECHAPROCESO, CODIGO_TRANSACCION, ENTIDAD_DEBITAR, CUENTA_DEBITAR, IMPORTE, CODIGO_POSTAL, FECHA_PRESENTADO, FECHA_VENCIMIENTO, NRO_CHEQUE, PUNTO_INTERCAMBIO, TRACE_NUMBER, ESTADO, TIPO, COD_RECHAZO,INFO_ADICIONAL)
	      	VALUES (@TICKET, @TICKET, @FechaProceso, @CodTransaccion, @EntidadDebitar, @CuentaDebitar, @Importe, @CodigoPostal, @FechaPresentado, @FechaVencimiento, @NroCheque, @PuntoIntercambio, @TraceNumber, @Estado, @Tipo, (SELECT CODIGO_NACHA FROM CLE_TIPO_CAUSAL T, CLE_CONTROLES_RECIBIDO C WHERE T.CODIGO_DE_CAUSAL = C.CODIGO_CAUSAL AND C.CODIGO_DE_CONTROL = 92),@InfoAdicional);
	      	UPDATE dbo.ITF_COELSA_CHEQUES_PROPIOS SET ESTADO = ''R'' WHERE ID = @Id;
	      	GOTO Final
	      END
      END
      
      
      ---R94--
      /* Validación 93: Código Postal Erroneo */
	  /*
	  Se levanta control a pedido de Marcelo Vives, nos comenta que este control lo realizara el core. Ver Ticket 6729 - Alvaro E 3/4/2024
	  
      IF (@Tipo<>''A'')
	  BEGIN
	      DECLARE @V93 NUMERIC(4);
	      DECLARE @CodPostal NUMERIC(4);
	      SET @CodPostal = CAST(RIGHT(@CodigoPostal, 4) AS NUMERIC(4));
	      
	      IF (@Tipo=''D'')
	      BEGIN
	      SET @V93 = (SELECT CPA_VIEJO FROM CLI_DIRECCIONES WHERE FORMATO=''S'' AND ID=(SELECT TOP 1 SUCURSAL FROM SALDOS WHERE OPERACION=@NroCheque));
		  END
		  IF (@Tipo=''C'')
	      BEGIN
	      SET @V93 = (SELECT CPA_VIEJO FROM CLI_DIRECCIONES WHERE FORMATO=''S'' AND ID=@Sucursal);
	      END
	      
	      IF (@V93 <> @CodPostal)
	      BEGIN
	      	INSERT INTO dbo.ITF_COELSA_CHEQUES_RECHAZO (ID_TICKET, ID_PROCESO, FECHAPROCESO, CODIGO_TRANSACCION, ENTIDAD_DEBITAR, CUENTA_DEBITAR, IMPORTE, CODIGO_POSTAL, FECHA_PRESENTADO, FECHA_VENCIMIENTO, NRO_CHEQUE, PUNTO_INTERCAMBIO, TRACE_NUMBER, ESTADO, TIPO, COD_RECHAZO, INFO_ADICIONAL)
	      	VALUES (@TICKET, @TICKET, @FechaProceso, @CodTransaccion, @EntidadDebitar, @CuentaDebitar, @Importe, @CodigoPostal, @FechaPresentado, @FechaVencimiento, @NroCheque, @PuntoIntercambio, @TraceNumber, @Estado, @Tipo, (SELECT CODIGO_NACHA FROM CLE_TIPO_CAUSAL T, CLE_CONTROLES_RECIBIDO C WHERE T.CODIGO_DE_CAUSAL = C.CODIGO_CAUSAL AND C.CODIGO_DE_CONTROL = 93),@InfoAdicional);
	      	UPDATE dbo.ITF_COELSA_CHEQUES_PROPIOS SET ESTADO = ''R'' WHERE ID = @Id;
	      	GOTO Final
	      END
      END
	  */
     
     
      /* Validación 95: Número de cuenta inválido */
      IF (@Tipo=''C'')
	  BEGIN
	      DECLARE @V95 NUMERIC(2);
	      DECLARE @NumCuenta NUMERIC(12);
	      
	      
	      SET @NumCuenta = CAST(@CuentaDebitar AS NUMERIC);
	        
	      IF (@Tipo=''C'')
	  	  BEGIN
	      SET @V95 = (SELECT COUNT(*) FROM SALDOS WHERE CUENTA = @NumCuenta AND SUCURSAL = @Sucursal);
	      END
	      
	      IF (@Tipo=''D'')
	  	  BEGIN
	      SET @V95 = (SELECT COUNT(*) FROM SALDOS WHERE OPERACION=@NroCheque AND C1785=4 AND MONEDA=@Moneda);
	      END
	      
	      IF (@V95 = 0)
	      BEGIN
	      	INSERT INTO dbo.ITF_COELSA_CHEQUES_RECHAZO (ID_TICKET, ID_PROCESO, FECHAPROCESO, CODIGO_TRANSACCION, ENTIDAD_DEBITAR, CUENTA_DEBITAR, IMPORTE, CODIGO_POSTAL, FECHA_PRESENTADO, FECHA_VENCIMIENTO, NRO_CHEQUE, PUNTO_INTERCAMBIO, TRACE_NUMBER, ESTADO, TIPO, COD_RECHAZO, INFO_ADICIONAL)
	      	VALUES (@TICKET, @TICKET, @FechaProceso, @CodTransaccion, @EntidadDebitar, @CuentaDebitar, @Importe, @CodigoPostal, @FechaPresentado, @FechaVencimiento, @NroCheque, @PuntoIntercambio, @TraceNumber, @Estado, @Tipo, (SELECT CODIGO_NACHA FROM CLE_TIPO_CAUSAL T, CLE_CONTROLES_RECIBIDO C WHERE T.CODIGO_DE_CAUSAL = C.CODIGO_CAUSAL AND C.CODIGO_DE_CONTROL = 1),@InfoAdicional);
	      	UPDATE dbo.ITF_COELSA_CHEQUES_PROPIOS SET ESTADO = ''R'' WHERE ID = @Id;
	      	GOTO Final		
	      END
      END
      
      ---R24---
      
      /* Validación 90: Transaccion duplicada*/
      DECLARE @V90 NUMERIC(2);
      SET @V90 = (SELECT COUNT(*) 
      				FROM ITF_COELSA_CHEQUES_PROPIOS 
      				WHERE ESTADO=''P'' 
      				AND ID_PROCESO=@IdProceso 
      				AND  FECHAPROCESO=CONVERT(VARCHAR, @FechaProceso, 23) 
      				AND CODIGO_TRANSACCION=@CodTransaccion 
      				AND ENTIDAD_DEBITAR=@EntidadDebitar 
      				AND CUENTA_DEBITAR=@CuentaDebitar 
      				AND IMPORTE= @Importe 
      				AND CODIGO_POSTAL=@CodigoPostal 
      				AND FECHA_PRESENTADO=CONVERT(VARCHAR, @FechaPresentado, 23) 
      				AND FECHA_VENCIMIENTO=CONVERT(VARCHAR, @FechaVencimiento, 23) 
      				AND NRO_CHEQUE=@NroCheque 
      				AND PUNTO_INTERCAMBIO=@PuntoIntercambio 
      				AND TIPO=@Tipo )
      
      IF(0<(SELECT COUNT(*) 
      		FROM CLE_CHEQUES_CLEARING 
      		WHERE MONEDA=1 
      		AND NUMERO_CHEQUE=@NroCheque 
      		AND FECHA_VALOR=@FechaProceso 
      		AND NUMERO_BANCO=@Entidad 
      		AND NUMERO_DEPENDENCIA=@Sucursal 
      		AND CUENTA=@CuentaDebitar 
      		AND ORDINAL_LISTA=(SELECT TOP 1 S.ORDINAL 
      							FROM SALDOS  S 
      							WHERE S.CUENTA=@CuentaDebitar 
      							AND S.SUCURSAL=@Sucursal 
      							AND S.MONEDA=1) 
      		AND SERIE_CHEQUE=''''))
      SET @V90=2;
      
      IF(0<(SELECT COUNT(*) 
      		FROM CLE_DPF_RECIBIDO 
      		WHERE MONEDA=@Moneda 
      		AND NUMERO_DPF=@NroCheque 
      		AND OPERACION=@NroCheque 
      		AND BANCO_DEPOSITANTE=@Entidad 
      		AND NUMERO_DEPENDENCIA=@Sucursal))
      SET @V90=2;


      IF (@V90 > 1 AND @Tipo!=''A'') --(@NroCheque!=88888888 or @CuentaDebitar!=88888888888 or @Sucursal!=888)
      BEGIN
      	INSERT INTO dbo.ITF_COELSA_CHEQUES_RECHAZO (ID_TICKET, ID_PROCESO, FECHAPROCESO, CODIGO_TRANSACCION, ENTIDAD_DEBITAR, CUENTA_DEBITAR, IMPORTE, CODIGO_POSTAL, FECHA_PRESENTADO, FECHA_VENCIMIENTO, NRO_CHEQUE, PUNTO_INTERCAMBIO, TRACE_NUMBER, ESTADO, TIPO, COD_RECHAZO, INFO_ADICIONAL)
      	VALUES (@TICKET, @TICKET, @FechaProceso, @CodTransaccion, @EntidadDebitar, @CuentaDebitar, @Importe, @CodigoPostal, @FechaPresentado, @FechaVencimiento, @NroCheque, @PuntoIntercambio, @TraceNumber, @Estado, @Tipo, (SELECT CODIGO_NACHA FROM CLE_TIPO_CAUSAL T, CLE_CONTROLES_RECIBIDO C WHERE T.CODIGO_DE_CAUSAL = C.CODIGO_CAUSAL AND C.CODIGO_DE_CONTROL = 90),@InfoAdicional);
      	UPDATE dbo.ITF_COELSA_CHEQUES_PROPIOS SET ESTADO = ''R'' WHERE ID = @Id;
      	GOTO Final		
      END
      

      /* Validación 96: Erroneo N° cheque informado
      IF (@Tipo <> ''A'')
      BEGIN
	      DECLARE @V96 NUMERIC(2);
	      SET @V96 = (SELECT COUNT(*) FROM ITF_COELSA_CHEQUES_PROPIOS WHERE ESTADO=''P'' AND ID_TICKET=@TICKET AND ID_PROCESO=@IdProceso AND  FECHAPROCESO=@FechaProceso AND CODIGO_TRANSACCION=@CodTransaccion AND ENTIDAD_DEBITAR=@EntidadDebitar AND CUENTA_DEBITAR=@CuentaDebitar AND IMPORTE= @Importe AND CODIGO_POSTAL=@CodigoPostal AND FECHA_PRESENTADO=@FechaPresentado AND FECHA_VENCIMIENTO=@FechaVencimiento AND NRO_CHEQUE=@NroCheque AND PUNTO_INTERCAMBIO=@PuntoIntercambio AND TIPO=@Tipo )
	      IF (@V96 = 0)
	      BEGIN
	      	INSERT INTO dbo.ITF_COELSA_CHEQUES_RECHAZO (ID_TICKET, ID_PROCESO, FECHAPROCESO, CODIGO_TRANSACCION, ENTIDAD_DEBITAR, CUENTA_DEBITAR, IMPORTE, CODIGO_POSTAL, FECHA_PRESENTADO, FECHA_VENCIMIENTO, NRO_CHEQUE, PUNTO_INTERCAMBIO, TRACE_NUMBER, ESTADO, TIPO, COD_RECHAZO)
	      	VALUES (@TICKET, @TICKET, @FechaProceso, @CodTransaccion, @EntidadDebitar, @CuentaDebitar, @Importe, @CodigoPostal, @FechaPresentado, @FechaVencimiento, @NroCheque, @PuntoIntercambio, @TraceNumber, @Estado, @Tipo, (SELECT CODIGO_NACHA FROM CLE_TIPO_CAUSAL T, CLE_CONTROLES_RECIBIDO C WHERE T.CODIGO_DE_CAUSAL = C.CODIGO_CAUSAL AND C.CODIGO_DE_CONTROL = 96));
	      	UPDATE dbo.ITF_COELSA_CHEQUES_PROPIOS SET ESTADO = ''R'' WHERE ID = @Id;
	      	GOTO Final		
	      END
	  END
      */
      /* Validación 91: Imagen Faltante */
    /* Se comenta hasta que la solucion de digitalizacion de cheque este pronta
      IF (@Tipo=''C'')
	  BEGIN
	      DECLARE @V91 NUMERIC(2);
	      DECLARE @Tope NUMERIC(15,2);
	      SET @Tope = (SELECT IMPORTE FROM PARAMETROSGENERALES WHERE CODIGO = 725);
	      
	      IF (@Tipo = ''D'')
	      BEGIN
	      	SET @Tope = 0;
	      END
	      
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
	  END*/
     
     
      ---R03---
       /* Validación 1: Saldo inexistente */
	  IF (@Tipo=''C'')
	  BEGIN
	      DECLARE @V1 NUMERIC(3);
	      IF (@Tipo = ''D'')
      		BEGIN
	      	SET @V1 = (SELECT COUNT(*) FROM SALDOS  S WHERE S.OPERACION=@NroCheque AND S.MONEDA=@Moneda);
	      	END
	      IF (@Tipo = ''C'')
      		BEGIN
	      	SET @V1 = (SELECT COUNT(*) FROM SALDOS  S WHERE S.CUENTA=@CuentaDebitar AND S.SUCURSAL=@Sucursal AND S.MONEDA=1);
	      	END
	      
	      IF (@V1 = 0)
	      BEGIN
	      	INSERT INTO dbo.ITF_COELSA_CHEQUES_RECHAZO (ID_TICKET, ID_PROCESO, FECHAPROCESO, CODIGO_TRANSACCION, ENTIDAD_DEBITAR, CUENTA_DEBITAR, IMPORTE, CODIGO_POSTAL, FECHA_PRESENTADO, FECHA_VENCIMIENTO, NRO_CHEQUE, PUNTO_INTERCAMBIO, TRACE_NUMBER, ESTADO, TIPO, COD_RECHAZO, INFO_ADICIONAL)
	      	VALUES (@TICKET, @TICKET, @FechaProceso, @CodTransaccion, @EntidadDebitar, @CuentaDebitar, @Importe, @CodigoPostal, @FechaPresentado, @FechaVencimiento, @NroCheque, @PuntoIntercambio, @TraceNumber, @Estado, @Tipo, (SELECT CODIGO_NACHA FROM CLE_TIPO_CAUSAL T, CLE_CONTROLES_RECIBIDO C WHERE T.CODIGO_DE_CAUSAL = C.CODIGO_CAUSAL AND C.CODIGO_DE_CONTROL = 1),@InfoAdicional);
	      	UPDATE dbo.ITF_COELSA_CHEQUES_PROPIOS SET ESTADO = ''R'' WHERE ID = @Id;
	      	GOTO Final
	      END
      END
      
      /* Grabamos las tablas correspondiente en caso de que los registros pasen las validaciones*/
      IF (@Tipo = ''C'')
      BEGIN
      	DECLARE @NroCLiente NUMERIC(12);
      	DECLARE @Ordinal NUMERIC(7);
      	DECLARE @Producto NUMERIC(5);
      	SELECT TOP 1 @NroCLiente=S.C1803, @Ordinal=S.ORDINAL, @Producto=S.PRODUCTO FROM SALDOS  S WHERE S.CUENTA=@CuentaDebitar AND S.SUCURSAL=@Sucursal AND S.MONEDA=1 AND S.C1785=2 AND S.TZ_LOCK=0
      	INSERT INTO dbo.CLE_CHEQUES_CLEARING (CLIENTE, MONEDA, ORDINAL_LISTA, PRODUCTO, NUMERO_BANCO, NUMERO_DEPENDENCIA, NUMERO_CHEQUE, IMPORTE, SERIE_CHEQUE, FECHA_VALOR, ESTADO, CUENTA, CAMARA_COMPENSADORA, CMC7, TRACKNUMBER, TZ_LOCK)
        VALUES (@NroCLiente, 1, @Ordinal, @Producto, @Entidad, @Sucursal, @NroCheque, @Importe, '''', @FechaProceso, ''0'', @CuentaDebitar, 1, (SELECT CONCAT( @Entidad, RIGHT(@EntidadDebitar, 3),RIGHT(@CodigoPostal,4),RIGHT(CONCAT(REPLICATE(''0'',8),RIGHT(@NroCheque, 8)),8), RIGHT(CONCAT(''00000000000'',RIGHT(@CuentaDebitar,11)),11) )), @TraceNumber, 0)
      	UPDATE dbo.ITF_COELSA_CHEQUES_PROPIOS SET ESTADO = ''V'' WHERE ID = @Id;
      END
      IF (@Tipo = ''D'')
      BEGIN
      	DECLARE @DNroCLiente NUMERIC(12);
      	DECLARE @DOrdinal NUMERIC(7);
      	DECLARE @DProducto NUMERIC(5);
      	SELECT TOP 1 @DNroCLiente=S.C1803, @DOrdinal=S.ORDINAL, @DProducto=S.PRODUCTO FROM SALDOS  S WHERE S.OPERACION=@NroCheque
      	INSERT INTO dbo.CLE_DPF_RECIBIDO (TZ_LOCK, MONEDA, NUMERO_DPF, CLIENTE, NUMERICO_CUENTA, PRODUCTO, OPERACION, ORDINAL, BANCO_DEPOSITANTE, CODIGO_USUARIO, FECHA_VALOR, IMPORTE, ESTADO, NUMERO_DEPENDENCIA, TRACKNUMBER, ESTADO_DPF, BANDA, CODIGO_CAUSAL_RECHAZO)
		VALUES (0, @Moneda, @NroCheque, @DNroCLiente, @CuentaDebitar, @DProducto, @NroCheque, @DOrdinal, @Entidad, ''TOP'', @FechaProceso, @Importe, 1, @Sucursal, @TraceNumber, ''I'', NULL, 0)      
	  	UPDATE dbo.ITF_COELSA_CHEQUES_PROPIOS SET ESTADO = ''V'' WHERE ID = @Id;
	  END
      IF (@Tipo = ''A'')
      BEGIN
      	--- Simulo Numerador Topaz
      	DECLARE @Aordinal NUMERIC(10);
        SET @Aordinal = (SELECT VALOR FROM  NUMERATORVALUES WHERE NUMERO=35171);
        WHILE 0<>(SELECT COUNT(*) FROM CLE_CHEQUES_AJUSTE WHERE ORDINAL=@Aordinal)
	        BEGIN
	        	SET @Aordinal = @Aordinal+1;
	        END;
      	INSERT INTO dbo.NUMERATORASIGNED (OID, VALOR, FECHAPROCESO, SUCURSAL, ESTADO, ASIENTO)
		VALUES ((SELECT OID FROM  NUMERATORVALUES WHERE NUMERO=35171), @Aordinal, (SELECT FECHAPROCESO FROM PARAMETROS), 97, ''R'', 1111111);
		UPDATE dbo.NUMERATORVALUES SET VALOR = (@Aordinal+1) WHERE NUMERO = 35171;
		
        --Insert tabla CLE_CHEQUES_AJUSTE
        INSERT INTO dbo.CLE_CHEQUES_AJUSTE (TZ_LOCK, ORDINAL, NUMERO_CHEQUE, BANCO, SUCURSAL_BANCO_GIRADO, NUMERO_CUENTA, ESTADO, CODIGO_POSTAL, FECHA_ALTA, SUCURSAL_CLIENTE, IMPORTE, P_INTERCAMBIO, ENVIADO_RECIBIDO, TRACKNUMBER, ESTADO_AJUSTE, FECHA_ENVIO_CAMARA, MONEDA, FECHA_ACREDITACION, NRO_ASIENTO, SUCURSAL_DE_INGRESO)
	    VALUES (0, @Aordinal, @NroCheque, @Entidad, @Sucursal, @CuentaDebitar, ''I'', @CodigoPostal, @FechaProceso, NULL, @Importe, ''0000'', ''R'', @TraceNumber, NULL, NULL, 1, NULL, NULL, NULL)
      	UPDATE dbo.ITF_COELSA_CHEQUES_PROPIOS SET ESTADO = ''V'' WHERE ID = @Id;
      	--- Fin insert
      	
      	DELETE FROM dbo.NUMERATORASIGNED WHERE OID = (SELECT OID FROM  NUMERATORVALUES WHERE NUMERO=35171) AND VALOR = @Aordinal;
		--- FIn simulacion Numerador Topaz
      	
      END
      
      Final:
      FETCH NEXT FROM che_cursor INTO @Id, @IdTicket, @IdProceso, @FechaProceso, @CodTransaccion, @EntidadDebitar, @CuentaDebitar, @Importe, @CodigoPostal, @FechaPresentado, @FechaVencimiento, @NroCheque, @PuntoIntercambio, @TraceNumber, @Estado, @Tipo, @InfoAdicional
END 

CLOSE che_cursor  
DEALLOCATE che_cursor

END');