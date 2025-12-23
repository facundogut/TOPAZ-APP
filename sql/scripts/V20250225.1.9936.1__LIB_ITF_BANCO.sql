EXECUTE('truncate table TTR_CODIGO_PROGRAMA_TRANSACCION;');

EXECUTE('
INSERT INTO TTR_CODIGO_PROGRAMA_TRANSACCION (codigoPrograma,nombrePrograma,descripcion,TZ_LOCK) VALUES
	 (1,N''MP_INFO_EXTENDIDA_TRANSFERENCIAS_MONOBANCO'',N''Programa Transferencias Monobanco'',0),
	 (2,N''MP_INFO_EXTENDIDA_PLAZO_FIJO'',N''Programa Plazo Fijo'',0),
	 (3,N''MP_INFO_EXTENDIDA_POS_ATM_DEP'',N''POS ATM DEPOSITOS'',0),
	 (4,N''MP_INFO_EXTENDIDA_POS_ATM_EXT'',N''POS ATM EXTRACCION'',0),
	 (5,N''MP_INFO_EXTENDIDA_POS_COMERCIOS'',N''POS COMPRA EN COMERCIOS'',0),
	 (6,N''MP_INFO_EXTENDIDA_POS_DEBIN_CREDIN'',N''POS DEBIN CREDIN'',0),
	 (7,N''MP_INFO_EXTENDIDA_POS_DIFERIDAS'',N''POS TRANSFERENCIAS DIFERIDAS'',0),
	 (8,N''MP_INFO_EXTENDIDA_POS_TRANSFERENCIAS'',N''POS CREDITO DEBITO POR TRANSFERENCIA'',0),
	 (9,N''MP_INFO_EXTENDIDA_TLF_CELULARES'',N''TLF: Recarga celulares'',0),
	 (10,N''MP_INFO_EXTENDIDA_POS_PAGO_SERVICIOS'',N''POS PAGO DE SERVICIOS'',0),
	 (11,N''MP_INFO_EXTENDIDA_PAGOS_ELECTRONICOS'',N''Pagos Electrónicos'',0),
	 (12,N''MP_INFO_EXTENDIDA_COELSA_TRANSFERENCIAS'',N''Transferencias Recibidas / Enviadas por Cámara COELSA'',0),
	 (13,N''MP_INFO_EXTENDIDA_ATE_TRANSFERENCIAS'',N''Transferencias Recibidas / Enviadas por INterbanking ATE'',0),
	 (14,N''MP_INFO_EXTENDIDA_MEP_TRANSFERENCIAS'',N''MEP Transferencias'',0);
');

EXECUTE('truncate table TTR_CODIGO_TRANSACCION_INFO_EXTENDIDA;');

EXECUTE('
INSERT INTO TTR_CODIGO_TRANSACCION_INFO_EXTENDIDA (codigoTransaccion,infoExtendidaTipo,descripcion,TZ_LOCK) VALUES
	 (2,4,N''POS: Extracciones por ATM'',0),
	 (4,3,N''POS: Depósitos en ATM'',0),
	 (21,12,N''Débito por Transferencia Atm Camara'',0),
	 (22,12,N''Débito por Transferencia Caja Camara'',0),
	 (23,1,N''TOPAZ Debito - Transferencias Monobanco'',0),
	 (30,1,N''TOPAZ Credito - Transferencias Monobanco'',0),
	 (34,12,N''Crédito por Transferencia Cámara'',0),
	 (48,2,N''Debito por Constitucion de Plazo Fijo'',0),
	 (49,2,N''Credito por Pre Cancelacion de Plazo Fijo'',0),
	 (50,2,N''Credito por Pago Plazo Fijo'',0),
	 (134,11,N''Pagos Electrónicos'',0),
	 (152,1,N''NBCH24: Credito - Transferencias Monobanco'',0),
	 (153,1,N''NBCH24: Debito - Transferencias Monobanco'',0),
	 (156,13,N''IB - Transferencia Mismo Titular Monobanco'',0),
	 (157,13,N''IB - Transferencia Distinto Titular Monobanco'',0),
	 (158,13,N''IB - Debito  Mismo Titular Interbanco'',0),
	 (159,13,N''IB - Crédito  Mismo Titular Interbanco'',0),
	 (160,13,N''IB - Debito Distinto Titular Interbanco'',0),
	 (161,13,N''IB - Crédito Distinto Titular Interbanco'',0),
	 (162,14,N''MEP Pasivas'',0),
	 (300,5,N''POS: Compra en Comercios'',0),
	 (304,5,N''POS: Devolucion en Comercios'',0),
	 (400,9,N''TLF: Recarga de celulares'',0),
	 (410,10,N''POS: Pago de Servicios'',0),
	 (421,8,N''POS: Debitos / Creditos por Transferencias'',0),
	 (422,6,N''POS: Debin / Credin'',0),
	 (423,7,N''POS: Transferencias Diferidas'',0);
');

EXECUTE('
DELETE FROM dbo.OPERACIONES WHERE IDENTIFICACION = 189;

INSERT INTO dbo.OPERACIONES
(TITULO, IDENTIFICACION, NOMBRE, DESCRIPCION, MNEMOTECNICO, AUTORIZACION, FORMULARIOPRINCIPAL, PROXOPERACION, ESTADO, TZ_LOCK, COPIAS, SUBOPERACION, PERMITEBAJA, COMPORTAMIENTOENCIERRE, REQUIERECONTRASENA, PERMITECONCURRENTE, PERMITEESTADODIFERIDO, ICONO_TITULO, ESTILO)
VALUES
(6800, 189,''Alta de Chequeras No migradas para Topaz'',''Alta de Chequeras No migradas para Topaz'',''189'',''N'', NULL, NULL,''P'', 0, NULL, 0,''S'',''N'',''N'',''N'',''N'', NULL, 0);
')

Execute('DROP PROCEDURE IF EXISTS dbo.SP_OPET001;')

Execute('CREATE PROCEDURE dbo.SP_OPET001
    @idAsiento VARCHAR(10),
    @fechaAsiento VARCHAR(8),
    @sucursalAsiento VARCHAR(5),
    @origenDebitoCredito VARCHAR(1),
    @bancoContraparte VARCHAR(5),
    @sucursalContraparte VARCHAR(5),
    @moduloContraparte VARCHAR(2),
    @cuentaContraparte VARCHAR(13),
    @nombreContraparte VARCHAR(70),
    @cuitContraparte VARCHAR(11),
    @cbuContraparte VARCHAR(22),
    @mismoTitular VARCHAR(1),
    @extornoAsiento VARCHAR(1),
    @monobanco VARCHAR(1),
    @canal VARCHAR(2),
    @motivo VARCHAR(3),
    @referencia VARCHAR(15),
    @RETORNO VARCHAR(2) OUTPUT,
    @MENSAJE VARCHAR(4000) OUTPUT

AS
BEGIN

    DECLARE
    @estado_O VARCHAR(1) = NULL,
    @estado_D VARCHAR(1) = NULL,
    @registros_MT INT = 0,
    @registros_MC INT = 0,
    @registros_MTO INT = 0,
    @registros_MTD INT = 0,
    @extornos_IAB INT = 0,
    @extornos_MT INT = 0,
    @MT_CUENTA_CONTRAPARTE INT,
    @MT_CANAL VARCHAR (2) = @canal,
    @MT_INTERFAZ VARCHAR(10) = ''OPET001'', 
    @MT_MOTIVO VARCHAR(3) = @motivo,
    @MT_REFERENCIA VARCHAR(15) = @referencia,
    @MT_ENTIDAD INT = 311,
    @MT_ASIENTO INT,
    @MT_ASIENTO_SUCURSAL INT,
    @MT_FECHAPROCESO DATE,
    @MT_SUCURSAL INT,
    @MT_MONEDA INT,
    @MT_CAPITALREALIZADO NUMERIC(15, 2),
    @MT_CUENTA INT,
    @MT_CLIENTE INT,
    @MT_PRODUCTO VARCHAR(2),
    @MT_NOMBRECLIENTE VARCHAR(50),
    @MT_NUMERODOCUMENTO NUMERIC(11, 0),
    @MT_CTA_CBU NUMERIC(22, 0),
    @MT_ASIENTO_CONTRAPARTE INT = NULL,
    @MT_FECHAPROCESO_CONTRAPARTE DATE = NULL,
    @MT_ASIENTO_SUCURSAL_CONTRAPARTE INT = NULL

    IF TRY_CONVERT(DATE, @fechaAsiento, 112) IS NULL
    BEGIN
        SET @RETORNO = ''05''
        SET @MENSAJE = ''fechaAsiento invalida''
    END
    ELSE
    BEGIN

        SELECT @registros_MTO = COUNT(*)
        FROM MAESTRO_TRANSFERENCIAS
        WHERE ORIGEN_ASIENTO_NUMERO = @idAsiento
            AND ORIGEN_ASIENTO_FECHA = @fechaAsiento
            AND ORIGEN_ASIENTO_SUCURSAL = @sucursalAsiento
            AND MAESTRO_TRANSFERENCIAS.TZ_LOCK = 0

        SELECT @registros_MTD = COUNT(*)
        FROM MAESTRO_TRANSFERENCIAS
        WHERE DESTINO_ASIENTO_NUMERO = @idAsiento
            AND DESTINO_ASIENTO_FECHA = @fechaAsiento
            AND DESTINO_ASIENTO_SUCURSAL = @sucursalAsiento
            AND MAESTRO_TRANSFERENCIAS.TZ_LOCK = 0

        SET @registros_MT = @registros_MTO + @registros_MTD

        IF @registros_MT <> 0
            BEGIN
            IF @registros_MTO <> 0
                    BEGIN
                SELECT @estado_O = MAESTRO_TRANSFERENCIAS.ESTADO
                FROM MAESTRO_TRANSFERENCIAS
                WHERE ORIGEN_ASIENTO_NUMERO = @idAsiento
                    AND ORIGEN_ASIENTO_FECHA = @fechaAsiento
                    AND ORIGEN_ASIENTO_SUCURSAL = @sucursalAsiento
                    AND MAESTRO_TRANSFERENCIAS.TZ_LOCK = 0
            END

            IF @registros_MTD <> 0
                    BEGIN
                SELECT @estado_D = MAESTRO_TRANSFERENCIAS.ESTADO
                FROM MAESTRO_TRANSFERENCIAS
                WHERE DESTINO_ASIENTO_NUMERO = @idAsiento
                    AND DESTINO_ASIENTO_FECHA = @fechaAsiento
                    AND DESTINO_ASIENTO_SUCURSAL = @sucursalAsiento
                    AND MAESTRO_TRANSFERENCIAS.TZ_LOCK = 0
            END
        END

        IF @registros_MT = 0
            BEGIN
            SELECT @registros_MC = COUNT(*)
            FROM MOVIMIENTOS_CONTABLES
                inner join CLI_CLIENTES on MOVIMIENTOS_CONTABLES.CLIENTE = CLI_CLIENTES.CODIGOCLIENTE and CLI_CLIENTES.TZ_LOCK = 0
                inner join CLI_ClientePersona on CLI_CLIENTES.CODIGOCLIENTE = CLI_ClientePersona.CODIGOCLIENTE and CLI_ClientePersona.TZ_LOCK = 0
                inner join CLI_DocumentosPFPJ on CLI_ClientePersona.NUMEROPERSONA = CLI_DocumentosPFPJ.NUMEROPERSONAFJ and CLI_DocumentosPFPJ.TZ_LOCK = 0
                left join VTA_SALDOS on MOVIMIENTOS_CONTABLES.SALDO_JTS_OID = VTA_SALDOS.JTS_OID_SALDO and VTA_SALDOS.TZ_LOCK = 0
            WHERE MOVIMIENTOS_CONTABLES.ASIENTO = @idAsiento
                AND MOVIMIENTOS_CONTABLES.FECHAPROCESO = @fechaAsiento
                AND MOVIMIENTOS_CONTABLES.SUCURSAL = @sucursalAsiento
                AND MOVIMIENTOS_CONTABLES.TIPO = ''M''
                AND MOVIMIENTOS_CONTABLES.DEBITOCREDITO = @origenDebitoCredito
        END

        IF @registros_MC <> 0
            BEGIN
            SELECT
                @MT_ASIENTO = MOVIMIENTOS_CONTABLES.ASIENTO,
                @MT_FECHAPROCESO = MOVIMIENTOS_CONTABLES.FECHAPROCESO,
                @MT_SUCURSAL = SALDOS.SUCURSAL,
                @MT_ASIENTO_SUCURSAL = MOVIMIENTOS_CONTABLES.SUCURSAL,
                @MT_MONEDA = MOVIMIENTOS_CONTABLES.MONEDA,
                @MT_CAPITALREALIZADO = MOVIMIENTOS_CONTABLES.CAPITALREALIZADO,
                @MT_CUENTA = MOVIMIENTOS_CONTABLES.CUENTA,
                @MT_CLIENTE = MOVIMIENTOS_CONTABLES.CLIENTE,
                @MT_PRODUCTO = 
                    CASE 
                        WHEN SALDOS.C1785 = 2 THEN ''CC''
                        WHEN SALDOS.C1785 = 3 THEN ''AC''
                        ELSE NULL
                    END,
                @MT_NOMBRECLIENTE = CLI_Clientes.NOMBRECLIENTE,
                @MT_NUMERODOCUMENTO = CLI_DocumentosPFPJ.NUMERODOCUMENTO,
                @MT_CTA_CBU = VTA_SALDOS.CTA_CBU
            FROM MOVIMIENTOS_CONTABLES
                inner join CLI_CLIENTES on MOVIMIENTOS_CONTABLES.CLIENTE = CLI_CLIENTES.CODIGOCLIENTE and CLI_CLIENTES.TZ_LOCK = 0
                inner join CLI_ClientePersona on CLI_CLIENTES.CODIGOCLIENTE = CLI_ClientePersona.CODIGOCLIENTE and CLI_ClientePersona.TZ_LOCK = 0
                inner join CLI_DocumentosPFPJ on CLI_ClientePersona.NUMEROPERSONA = CLI_DocumentosPFPJ.NUMEROPERSONAFJ and CLI_DocumentosPFPJ.TZ_LOCK = 0
                left join VTA_SALDOS on MOVIMIENTOS_CONTABLES.SALDO_JTS_OID = VTA_SALDOS.JTS_OID_SALDO and VTA_SALDOS.TZ_LOCK = 0
                join SALDOS on MOVIMIENTOS_CONTABLES.SALDO_JTS_OID = SALDOS.JTS_OID AND SALDOS.TZ_LOCK = 0
            WHERE MOVIMIENTOS_CONTABLES.ASIENTO = @idAsiento
                AND MOVIMIENTOS_CONTABLES.FECHAPROCESO = @fechaAsiento
                AND MOVIMIENTOS_CONTABLES.SUCURSAL = @sucursalAsiento
                AND MOVIMIENTOS_CONTABLES.TIPO = ''M''
                AND MOVIMIENTOS_CONTABLES.DEBITOCREDITO = @origenDebitoCredito
        END

        IF @registros_MC <> 0 AND @monobanco = 1
            BEGIN
            SET @MT_ASIENTO_CONTRAPARTE = @MT_ASIENTO
            SET @MT_FECHAPROCESO_CONTRAPARTE = @MT_FECHAPROCESO
            SET @MT_ASIENTO_SUCURSAL_CONTRAPARTE = @MT_SUCURSAL

            SELECT 
            @MT_CUENTA_CONTRAPARTE = mc.CUENTA 
            FROM MOVIMIENTOS_CONTABLES mc 
            WHERE mc.ASIENTO = @idAsiento
                AND mc.FECHAPROCESO = @fechaAsiento
                AND mc.SUCURSAL = @sucursalAsiento
                AND mc.TIPO = ''M''
                AND mc.DEBITOCREDITO <> @origenDebitoCredito
        END

        IF @extornoAsiento = ''X''
        BEGIN
            SELECT @extornos_IAB = COUNT(*)
            FROM ITF_ACREDITACION_BITACORA
            WHERE NRO_ASIENTO = @idAsiento
                AND FECHA_PROCESO = @fechaAsiento
                AND SUCURSAL = @sucursalAsiento
                AND TZ_LOCK <> 0

            IF (@registros_MT <> 0 OR @registros_MC <> 0) AND @extornos_IAB <> 0
            BEGIN
                SET @extornos_MT = 1
            END
        END

        IF @registros_MT <> 0 AND (@extornoAsiento = @estado_O OR @extornoAsiento = @estado_D)
            BEGIN
            SET @RETORNO = ''01''
            SET @MENSAJE = ''EL REGISTRO YA EXISTE''
            RETURN;
        END
        ELSE IF @registros_MT <> 0 AND @extornoAsiento = ''C'' AND (@estado_O = ''X'' OR @estado_D = ''X'')
            BEGIN
            SET @RETORNO = ''02''
            SET @MENSAJE = ''NO SE PUEDEN REVERSAR LOS EXTORNOS''
            RETURN;
        END
        ELSE IF @registros_MT = 0 AND @registros_MC = 0
            BEGIN
            SET @RETORNO = ''03''
            SET @MENSAJE = ''NO EXISTE EL ASIENTO EN LA FECHA Y LA SUCURSAL INGRESADA''
            RETURN;
        END
        ELSE IF (@extornos_MT = 0 OR @extornos_IAB = 0) AND @extornoAsiento = ''X''
            BEGIN
            SET @RETORNO = ''04''
            SET @MENSAJE = ''NO EXISTE EL EXTORNO DEL ASIENTO EN LA FECHA Y LA SUCURSAL INGRESADA''
        END
        ELSE IF @monobanco = 1 AND (@cuentaContraparte <> @MT_CUENTA_CONTRAPARTE AND @mismoTitular = ''N'')
            BEGIN
            SET @RETORNO = ''06''
            SET @MENSAJE = ''cuentaContraparte NO COINCIDE CON LA CUENTA DE LA CONTRAPARTE DEL ASIENTO INFOMRADO''
        END
            ELSE IF @monobanco = 0 AND (@cuentaContraparte = @MT_CUENTA AND @mismoTitular = ''N'')
            BEGIN
            SET @RETORNO = ''07''
            SET @MENSAJE = ''cuentaContraparte COINCIDE CON LA CUENTA DE LA CONTRAPARTE DEL ASIENTO INFORMADO''
        END
        ELSE IF @extornos_MT <> 0 AND @extornoAsiento = ''X'' AND @registros_MT <> 0
            BEGIN
            IF @estado_O = ''C''
                BEGIN
                UPDATE dbo.MAESTRO_TRANSFERENCIAS
                    SET ESTADO = @extornoAsiento
                    WHERE ORIGEN_ASIENTO_NUMERO = @idAsiento
                    AND ORIGEN_ASIENTO_FECHA = @fechaAsiento
                    AND ORIGEN_ASIENTO_SUCURSAL = @sucursalAsiento;
            END
            IF @estado_D = ''C''
                BEGIN
                UPDATE dbo.MAESTRO_TRANSFERENCIAS
                    SET ESTADO = @extornoAsiento
                    WHERE DESTINO_ASIENTO_NUMERO = @idAsiento
                    AND DESTINO_ASIENTO_FECHA = @fechaAsiento
                    AND DESTINO_ASIENTO_SUCURSAL = @sucursalAsiento;
            END
            SET @RETORNO = ''00''
            SET @MENSAJE = ''EXTORNO REALIZADO''
        END
        ELSE
            BEGIN
            IF @origenDebitoCredito = ''D''
                            BEGIN
                INSERT INTO dbo.MAESTRO_TRANSFERENCIAS
                    (DESTINO_ASIENTO_NUMERO, DESTINO_ASIENTO_FECHA, DESTINO_ASIENTO_SUCURSAL, ORIGEN_ASIENTO_NUMERO, ORIGEN_ASIENTO_FECHA, ORIGEN_ASIENTO_SUCURSAL, DESTINO_ENTIDAD, DESTINO_SUBSISTEMA, DESTINO_SUCURSAL, DESTINO_CUENTA, DESTINO_CUIT, DESTINO_RAZON_SOCIAL, DESTINO_CBU, TITULAR, ESTADO, CANAL, INTERFAZ, MOTIVO, REFERENCIA, MONEDA, IMPORTE, SOLICITUD_FECHA, ORIGEN_ENTIDAD, ORIGEN_SUBSISTEMA, ORIGEN_SUCURSAL, ORIGEN_CUENTA, ORIGEN_CUIT, ORIGEN_RAZON_SOCIAL, ORIGEN_CBU)
                VALUES
                    (@MT_ASIENTO_CONTRAPARTE, @MT_FECHAPROCESO_CONTRAPARTE, @MT_ASIENTO_SUCURSAL_CONTRAPARTE, @MT_ASIENTO, @MT_FECHAPROCESO, @MT_ASIENTO_SUCURSAL, @bancoContraparte, @moduloContraparte, @sucursalContraparte, @cuentaContraparte, @cuitContraparte, @nombreContraparte, @cbuContraparte, @mismoTitular, @extornoAsiento, @MT_CANAL, @MT_INTERFAZ, @MT_MOTIVO, @MT_REFERENCIA, @MT_MONEDA, @MT_CAPITALREALIZADO, @MT_FECHAPROCESO, @MT_ENTIDAD, @MT_PRODUCTO, @MT_SUCURSAL, @MT_CUENTA, @MT_NUMERODOCUMENTO, @MT_NOMBRECLIENTE, @MT_CTA_CBU);
            END
                ELSE IF @origenDebitoCredito = ''C'' 
                            BEGIN
                INSERT INTO dbo.MAESTRO_TRANSFERENCIAS
                    (ORIGEN_ASIENTO_NUMERO, ORIGEN_ASIENTO_FECHA, ORIGEN_ASIENTO_SUCURSAL, DESTINO_ASIENTO_NUMERO, DESTINO_ASIENTO_FECHA, DESTINO_ASIENTO_SUCURSAL, ORIGEN_ENTIDAD, ORIGEN_SUBSISTEMA, ORIGEN_SUCURSAL, ORIGEN_CUENTA, ORIGEN_CUIT, ORIGEN_RAZON_SOCIAL, ORIGEN_CBU, TITULAR, ESTADO, CANAL, INTERFAZ, MOTIVO, REFERENCIA, MONEDA, IMPORTE, SOLICITUD_FECHA, DESTINO_ENTIDAD, DESTINO_SUBSISTEMA, DESTINO_SUCURSAL, DESTINO_CUENTA, DESTINO_CUIT, DESTINO_RAZON_SOCIAL, DESTINO_CBU)
                VALUES
                    (@MT_ASIENTO_CONTRAPARTE, @MT_FECHAPROCESO_CONTRAPARTE, @MT_ASIENTO_SUCURSAL_CONTRAPARTE, @MT_ASIENTO, @MT_FECHAPROCESO,@MT_ASIENTO_SUCURSAL, @bancoContraparte, @moduloContraparte, @sucursalContraparte, @cuentaContraparte, @cuitContraparte, @nombreContraparte, @cbuContraparte, @mismoTitular, @extornoAsiento, @MT_CANAL, @MT_INTERFAZ, @MT_MOTIVO, @MT_REFERENCIA, @MT_MONEDA, @MT_CAPITALREALIZADO, @MT_FECHAPROCESO, @MT_ENTIDAD, @MT_PRODUCTO, @MT_SUCURSAL, @MT_CUENTA, @MT_NUMERODOCUMENTO, @MT_NOMBRECLIENTE, @MT_CTA_CBU);
            END
            SET @RETORNO = ''00''
            SET @MENSAJE = ''REGISTRO GRABADO''
        END
    END

END;')
