EXECUTE('

CREATE OR ALTER PROCEDURE dbo.SP_OPET001
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
    @MT_ENTIDAD INT,
    @MT_ASIENTO BIGINT,
    @MT_ASIENTO_SUCURSAL INT,
    @MT_FECHAPROCESO DATE,
    @MT_SUCURSAL INT,
    @MT_MONEDA INT,
    @MT_CAPITALREALIZADO NUMERIC(15, 2),
    @MT_CUENTA BIGINT,
    @MT_CLIENTE BIGINT,
    @MT_PRODUCTO VARCHAR(2),
    @MT_NOMBRECLIENTE VARCHAR(50),
    @MT_NUMERODOCUMENTO NUMERIC(11, 0),
    @MT_CTA_CBU NUMERIC(22, 0),
    @MT_ASIENTO_CONTRAPARTE BIGINT = NULL,
    @MT_FECHAPROCESO_CONTRAPARTE DATE = NULL,
    @MT_ASIENTO_SUCURSAL_CONTRAPARTE INT = NULL,
    @EX_idAsiento VARCHAR(10),
    @EX_sucursalAsiento VARCHAR(5),
    @EX_fechaAsiento VARCHAR(8),
    @PAR_SOLICITUD_FECHA DATE,
    @MT_bancoContraparte VARCHAR(5),
    @MT_sucursalContraparte VARCHAR(5),
    @MT_moduloContraparte VARCHAR(2),
    @MT_cuentaContraparte VARCHAR(13),
    @MT_nombreContraparte VARCHAR(70),
    @MT_cuitContraparte VARCHAR(11),
    @MT_cbuContraparte VARCHAR(22)

    IF TRY_CONVERT(DATE, @fechaAsiento, 112) IS NULL
    BEGIN
        SET @RETORNO = ''05''
        SET @MENSAJE = ''fechaAsiento invalida''
    END
    ELSE
    BEGIN

        SELECT @PAR_SOLICITUD_FECHA = p.FECHAPROCESO
        FROM parametros p;

        IF @extornoAsiento = ''X''
        BEGIN
            SET @EX_idAsiento = @idAsiento
            SET @EX_sucursalAsiento = @sucursalAsiento
            SET @EX_fechaAsiento = @fechaAsiento

            select TOP 1
                @idAsiento = CAST(ex.ASIENTO_ORIGINAL AS VARCHAR(10)),
                @sucursalAsiento = CAST(ex.SUCURSAL_ORIGINAL AS VARCHAR(5)),
                @fechaAsiento = CONVERT(VARCHAR(8), ex.FECHAPROCESO_ORIGINAL, 112)
            from VW_CON_ASIENTOS_EXTORNADOS ex
            where ex.ASIENTO = @EX_idAsiento
                and ex.SUCURSAL = @EX_sucursalAsiento
                and ex.FECHAPROCESO = @EX_fechaAsiento
        END

        SELECT @registros_MTO = COUNT(*)
        FROM (
            SELECT TOP 1
                *
            FROM MAESTRO_TRANSFERENCIAS
            WHERE ORIGEN_ASIENTO_NUMERO = @idAsiento
                AND ORIGEN_ASIENTO_FECHA = @fechaAsiento
                AND ORIGEN_ASIENTO_SUCURSAL = @sucursalAsiento
                AND MAESTRO_TRANSFERENCIAS.TZ_LOCK = 0
            ) AS Subquery1

        SELECT @registros_MTD = COUNT(*)
        FROM (
            SELECT TOP 1
                *
            FROM MAESTRO_TRANSFERENCIAS
            WHERE DESTINO_ASIENTO_NUMERO = @idAsiento
                AND DESTINO_ASIENTO_FECHA = @fechaAsiento
                AND DESTINO_ASIENTO_SUCURSAL = @sucursalAsiento
                AND MAESTRO_TRANSFERENCIAS.TZ_LOCK = 0
        ) AS Subquery2

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
            FROM (
                SELECT TOP 1
                    MOVIMIENTOS_CONTABLES.*
                FROM MOVIMIENTOS_CONTABLES
                    left join CLI_CLIENTES on MOVIMIENTOS_CONTABLES.CLIENTE = CLI_CLIENTES.CODIGOCLIENTE and CLI_CLIENTES.TZ_LOCK = 0
                    left join CLI_ClientePersona on CLI_CLIENTES.CODIGOCLIENTE = CLI_ClientePersona.CODIGOCLIENTE and CLI_ClientePersona.TZ_LOCK = 0 and CLI_ClientePersona.TITULARIDAD = ''T''
                    left join CLI_DocumentosPFPJ on CLI_ClientePersona.NUMEROPERSONA = CLI_DocumentosPFPJ.NUMEROPERSONAFJ and CLI_DocumentosPFPJ.TZ_LOCK = 0
                    left join VTA_SALDOS on MOVIMIENTOS_CONTABLES.SALDO_JTS_OID = VTA_SALDOS.JTS_OID_SALDO and VTA_SALDOS.TZ_LOCK = 0
                WHERE MOVIMIENTOS_CONTABLES.ASIENTO = @idAsiento
                    AND MOVIMIENTOS_CONTABLES.FECHAPROCESO = @fechaAsiento
                    AND MOVIMIENTOS_CONTABLES.SUCURSAL = @sucursalAsiento
                    AND MOVIMIENTOS_CONTABLES.TIPO = ''M''
                    AND MOVIMIENTOS_CONTABLES.DEBITOCREDITO = @origenDebitoCredito
            ) AS Subquery3
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
                @MT_CTA_CBU = VTA_SALDOS.CTA_CBU,
                @MT_ENTIDAD = LEFT(VTA_SALDOS.CTA_CBU, 3)
            FROM MOVIMIENTOS_CONTABLES
                left join CLI_CLIENTES on MOVIMIENTOS_CONTABLES.CLIENTE = CLI_CLIENTES.CODIGOCLIENTE and CLI_CLIENTES.TZ_LOCK = 0
                left join CLI_ClientePersona on CLI_CLIENTES.CODIGOCLIENTE = CLI_ClientePersona.CODIGOCLIENTE and CLI_ClientePersona.TZ_LOCK = 0 and CLI_ClientePersona.TITULARIDAD = ''T''
                left join CLI_DocumentosPFPJ on CLI_ClientePersona.NUMEROPERSONA = CLI_DocumentosPFPJ.NUMEROPERSONAFJ and CLI_DocumentosPFPJ.TZ_LOCK = 0
                left join VTA_SALDOS on MOVIMIENTOS_CONTABLES.SALDO_JTS_OID = VTA_SALDOS.JTS_OID_SALDO and VTA_SALDOS.TZ_LOCK = 0
                left join SALDOS on MOVIMIENTOS_CONTABLES.SALDO_JTS_OID = SALDOS.JTS_OID AND SALDOS.TZ_LOCK = 0
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
            SET @MT_ASIENTO_SUCURSAL_CONTRAPARTE = @MT_ASIENTO_SUCURSAL

            SELECT
                @MT_sucursalContraparte = SALDOS.SUCURSAL,
                @MT_cuentaContraparte = MOVIMIENTOS_CONTABLES.CUENTA,
                @MT_moduloContraparte = 
                    CASE 
                        WHEN SALDOS.C1785 = 2 THEN ''CC''
                        WHEN SALDOS.C1785 = 3 THEN ''AC''
                        ELSE NULL
                    END,
                @MT_nombreContraparte = CLI_Clientes.NOMBRECLIENTE,
                @MT_cuitContraparte = CLI_DocumentosPFPJ.NUMERODOCUMENTO,
                @MT_cbuContraparte = VTA_SALDOS.CTA_CBU,
                @MT_bancoContraparte = LEFT(VTA_SALDOS.CTA_CBU, 3)
            FROM MOVIMIENTOS_CONTABLES
                left join CLI_CLIENTES on MOVIMIENTOS_CONTABLES.CLIENTE = CLI_CLIENTES.CODIGOCLIENTE and CLI_CLIENTES.TZ_LOCK = 0
                left join CLI_ClientePersona on CLI_CLIENTES.CODIGOCLIENTE = CLI_ClientePersona.CODIGOCLIENTE and CLI_ClientePersona.TZ_LOCK = 0 and CLI_ClientePersona.TITULARIDAD = ''T''
                left join CLI_DocumentosPFPJ on CLI_ClientePersona.NUMEROPERSONA = CLI_DocumentosPFPJ.NUMEROPERSONAFJ and CLI_DocumentosPFPJ.TZ_LOCK = 0
                left join VTA_SALDOS on MOVIMIENTOS_CONTABLES.SALDO_JTS_OID = VTA_SALDOS.JTS_OID_SALDO and VTA_SALDOS.TZ_LOCK = 0
                left join SALDOS on MOVIMIENTOS_CONTABLES.SALDO_JTS_OID = SALDOS.JTS_OID AND SALDOS.TZ_LOCK = 0
            WHERE MOVIMIENTOS_CONTABLES.ASIENTO = @idAsiento
                AND MOVIMIENTOS_CONTABLES.FECHAPROCESO = @fechaAsiento
                AND MOVIMIENTOS_CONTABLES.SUCURSAL = @sucursalAsiento
                AND MOVIMIENTOS_CONTABLES.TIPO = ''M''
                AND MOVIMIENTOS_CONTABLES.DEBITOCREDITO <> @origenDebitoCredito
        END

        IF @registros_MC <> 0 AND @monobanco = 0
            BEGIN
            SET @MT_bancoContraparte = @bancoContraparte
            SET @MT_sucursalContraparte = @sucursalContraparte
            SET @MT_moduloContraparte = @moduloContraparte
            SET @MT_cuentaContraparte = @cuentaContraparte
            SET @MT_nombreContraparte = @nombreContraparte
            SET @MT_cuitContraparte = @cuitContraparte
            SET @MT_cbuContraparte = @cbuContraparte
        END

        IF @extornoAsiento = ''X''
        BEGIN

            SELECT @extornos_IAB = COUNT(*)
            FROM (
                SELECT TOP 1
                    *
                from VW_CON_ASIENTOS_EXTORNADOS ex
                where ex.ASIENTO = @EX_idAsiento
                    and ex.SUCURSAL = @EX_sucursalAsiento
                    and ex.FECHAPROCESO = @EX_fechaAsiento
            ) AS Subquery4

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
        ELSE IF @monobanco = 0 AND (@cuentaContraparte = @MT_CUENTA AND @mismoTitular = ''N'') AND @cuentaContraparte <> ''''
            BEGIN
            SET @RETORNO = ''06''
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
                    (@MT_ASIENTO_CONTRAPARTE, @MT_FECHAPROCESO_CONTRAPARTE, @MT_ASIENTO_SUCURSAL_CONTRAPARTE, @MT_ASIENTO, @MT_FECHAPROCESO, @MT_ASIENTO_SUCURSAL, NULLIF(@MT_bancoContraparte, ''''), NULLIF(@MT_moduloContraparte, ''''), NULLIF(@MT_sucursalContraparte, ''''), NULLIF(@MT_cuentaContraparte, ''''), NULLIF(@MT_cuitContraparte, ''''), NULLIF(@MT_nombreContraparte, ''''), NULLIF(@MT_cbuContraparte, ''''), NULLIF(@mismoTitular, ''''), @extornoAsiento, @MT_CANAL, @MT_INTERFAZ, @MT_MOTIVO, @MT_REFERENCIA, @MT_MONEDA, @MT_CAPITALREALIZADO, @PAR_SOLICITUD_FECHA, @MT_ENTIDAD, @MT_PRODUCTO, @MT_SUCURSAL, @MT_CUENTA, @MT_NUMERODOCUMENTO, @MT_NOMBRECLIENTE, @MT_CTA_CBU);
            END
                ELSE IF @origenDebitoCredito = ''C'' 
                BEGIN
                INSERT INTO dbo.MAESTRO_TRANSFERENCIAS
                    (ORIGEN_ASIENTO_NUMERO, ORIGEN_ASIENTO_FECHA, ORIGEN_ASIENTO_SUCURSAL, DESTINO_ASIENTO_NUMERO, DESTINO_ASIENTO_FECHA, DESTINO_ASIENTO_SUCURSAL, ORIGEN_ENTIDAD, ORIGEN_SUBSISTEMA, ORIGEN_SUCURSAL, ORIGEN_CUENTA, ORIGEN_CUIT, ORIGEN_RAZON_SOCIAL, ORIGEN_CBU, TITULAR, ESTADO, CANAL, INTERFAZ, MOTIVO, REFERENCIA, MONEDA, IMPORTE, SOLICITUD_FECHA, DESTINO_ENTIDAD, DESTINO_SUBSISTEMA, DESTINO_SUCURSAL, DESTINO_CUENTA, DESTINO_CUIT, DESTINO_RAZON_SOCIAL, DESTINO_CBU)
                VALUES
                    (@MT_ASIENTO_CONTRAPARTE, @MT_FECHAPROCESO_CONTRAPARTE, @MT_ASIENTO_SUCURSAL_CONTRAPARTE, @MT_ASIENTO, @MT_FECHAPROCESO, @MT_ASIENTO_SUCURSAL, NULLIF(@MT_bancoContraparte, ''''), NULLIF(@MT_moduloContraparte, ''''), NULLIF(@MT_sucursalContraparte, ''''), NULLIF(@MT_cuentaContraparte, ''''), NULLIF(@MT_cuitContraparte, ''''), NULLIF(@MT_nombreContraparte, ''''), NULLIF(@MT_cbuContraparte, ''''), NULLIF(@mismoTitular, ''''), @extornoAsiento, @MT_CANAL, @MT_INTERFAZ, @MT_MOTIVO, @MT_REFERENCIA, @MT_MONEDA, @MT_CAPITALREALIZADO, @PAR_SOLICITUD_FECHA, @MT_ENTIDAD, @MT_PRODUCTO, @MT_SUCURSAL, @MT_CUENTA, @MT_NUMERODOCUMENTO, @MT_NOMBRECLIENTE, @MT_CTA_CBU);
            END
            SET @RETORNO = ''00''
            SET @MENSAJE = ''REGISTRO GRABADO''
        END
    END
END;


')