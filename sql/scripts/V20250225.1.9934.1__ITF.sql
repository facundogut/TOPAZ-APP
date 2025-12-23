Execute('

CREATE OR ALTER PROCEDURE dbo.SP_OPET001
    @idAsiento VARCHAR(10),
    @fechaAsiento VARCHAR(8),
    @sucursalAsiento VARCHAR(5),
    @origenDebitoCredito VARCHAR(1),
    @bancoContraparte VARCHAR(5),
    @sucursalContraparte VARCHAR(5),
    @moduloContraparte VARCHAR(2),
    @cuentaContraparte VARCHAR(13),
    @nombreContraparte VARCHAR(50),
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
        ELSE IF @cuentaContraparte = @MT_CUENTA AND @mismoTitular = ''N''
            BEGIN
            SET @RETORNO = ''06''
            SET @MENSAJE = ''ESTA INFORMANDO EL MISMO ASIENTO EN ORIGEN Y DESTINO''
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

Execute('UPDATE dbo.DICCIONARIO SET LARGO = 70 WHERE NUMERODECAMPO = 25564;  
UPDATE dbo.DICCIONARIO SET LARGO = 70 WHERE NUMERODECAMPO = 25574;

ALTER TABLE dbo.MAESTRO_TRANSFERENCIAS ALTER COLUMN ORIGEN_RAZON_SOCIAL VARCHAR(70) COLLATE Modern_Spanish_CI_AS;  
ALTER TABLE dbo.MAESTRO_TRANSFERENCIAS ALTER COLUMN DESTINO_RAZON_SOCIAL VARCHAR(70) COLLATE Modern_Spanish_CI_AS;')

EXEC('
CREATE OR ALTER PROCEDURE [dbo].[SP_VJ_ADMINISTRA_BENEFICIARIO] 
	@jts_oid NUMERIC(10,0),
	@idPersona NUMERIC(12,0),
	@accion varchar(1),
	@asientoFecha date,
	@asientoSucursal numeric(10,0),
	@asientoNumero numeric(10,0),
	@operacion NUMERIC(4,0),
	@usuario VARCHAR(10),
	@hora VARCHAR(8),
    @causaTipo VARCHAR(2),
	@codigo NUMERIC(1) OUTPUT, 
	@descripcion varchar(150) OUTPUT 
AS 
BEGIN 
    SET XACT_ABORT ON;
    BEGIN TRANSACTION;
    BEGIN TRY
    
    -- DECLARACIÓN DE VARIABLES
    DECLARE
        @causaNumero NUMERIC(12,0) = 0,
        @causaJuzgado NUMERIC(12,0) = 0,
        @causaAno NUMERIC(4,0) = 0,
        @causaOficio NUMERIC(12,0) = 0,
        @causaExpediente VARCHAR(100) = '''',
        @idPersonaJuez NUMERIC(12,0) = 0,
        @actorJuez VARCHAR(3) = '''',
        @idPersonaSecretario NUMERIC(12,0) = 0,
        @actorSecretario VARCHAR(3) = '''',
        @cuentaBloqueada NUMERIC(1,0) = NULL;
    
    -- Crear una tabla temporal para almacenar los registros afectados
    DECLARE @Temp_PYF_APODERADOS TABLE (
        TZ_LOCK NUMERIC(16,0),
        ID_ENTIDAD VARCHAR(50),
        TIPO_PODER NUMERIC(5,0),
        TIPO_ENTIDAD NUMERIC(5,0),
        ID_PERSONA NUMERIC(12,0),
        CATEGORIA VARCHAR(1),
        MONEDA_MONTO_INDIV NUMERIC(5,0),
        MONTO_MAX_INDIV NUMERIC(15,2),
        MONEDA_MONTO_GRUPAL NUMERIC(5,0),
        MONTO_MAX_GRUPAL NUMERIC(15,2),
        FECHA_VENCIMIENTO DATETIME,
        FECHA_INI_VIGENCIA DATETIME,
        FECHA_INI_SUSPENSION DATETIME,
        FECHA_FIN_SUSPENSION DATETIME,
        APODERAMIENTO NUMERIC(5,0),
        ID_CLIENTE_SALDO VARCHAR(50),
        ID_ENTIDAD2 NUMERIC(10,0)
    );
   
    -- CODIGO Y DESCRIPCIÓN DEFAULT
    SET @codigo = 1;
    SET @descripcion = ''Error inesperado ejecutando SP Beneficiarios'';
   
      -- OBTENER DATOS DE CAUSA
    SELECT 
        @causaNumero = c.NRO_CAUSA,
        @causaJuzgado = c.JUZGADO,
        @causaAno = c.ANO,
        @causaExpediente = c.EXPEDIENTE
    FROM DJ_CAUSAS c
    WHERE --c.TIPO_CAUSA=@causaTipo AND 
        c.ESTADO=''A'' AND LEFT(c.TZ_LOCK, 1) IN (0, 2, 4)
        AND c.NRO_CAUSA in
            (SELECT cc.NRO_CAUSA
            FROM DJ_CAUSA_CUENTA cc
            WHERE cc.JTS_OID_CUENTA = @jts_oid AND LEFT(cc.TZ_LOCK, 1) IN (0, 2, 4))
    
    IF (@causaNumero = 0 OR @causaNumero is null)
    BEGIN
        SET @codigo = 1;
        SET @descripcion = CONCAT(''Error al encontrar Número de causa. JtsOid: '',@jts_oid);
        ROLLBACK TRANSACTION;
        RETURN;
    END
        
    -- OBTENER NUMERO DE OFICIO
    SELECT TOP 1
        @causaOficio = cc.NRO_OFICIO
    FROM DJ_CAUSA_CUENTA cc
    WHERE cc.JTS_OID_CUENTA = @jts_oid AND cc.NRO_CAUSA = @causaNumero AND LEFT(cc.TZ_LOCK, 1) IN (0, 2, 4);
    
    -- ADECUAR NUMERO DE OFICIO SI NO SE ENCUENTRA
    IF @causaOficio IS NULL
    BEGIN
        SET @causaOficio = 0;
    END
    
    -- OBTENER ID PERSONA JUEZ
    SELECT TOP 1
        @idPersonaJuez = i.ID_PERSONA,
        @actorJuez = i.ACTOR
    FROM DJ_CAUSAS c 
    INNER JOIN DJ_JUZGADOS j ON c.JUZGADO = j.NRO_JUZGADO 
    INNER JOIN DJ_INTEGRANTES_JUZGADOS i ON i.NRO_JUZGADO  = j.NRO_JUZGADO AND i.ACTIVO  = ''S'' AND i.TZ_LOCK = 0
    WHERE
        --c.TIPO_CAUSA = @causaTipo AND
        c.ESTADO = ''A''  
        AND i.ACTOR IN (''JUZ'', ''JU1'')
        AND c.NRO_CAUSA = @causaNumero 
    ORDER BY i.ACTOR DESC;
        
    -- OBTENER ID PERSONA SECRETARIO
    SELECT TOP 1
        @idPersonaSecretario = i.ID_PERSONA,
        @actorSecretario = i.ACTOR
    FROM DJ_CAUSAS c 
    INNER JOIN DJ_JUZGADOS j ON c.JUZGADO = j.NRO_JUZGADO 
    INNER JOIN DJ_INTEGRANTES_JUZGADOS i ON i.NRO_JUZGADO  = j.NRO_JUZGADO AND i.ACTIVO  = ''S'' AND i.TZ_LOCK = 0
    WHERE
        --c.TIPO_CAUSA = @causaTipo AND
        c.ESTADO = ''A''  
        AND i.ACTOR IN (''SEJ'', ''SE1'')
        AND c.NRO_CAUSA = @causaNumero 
    ORDER BY i.ACTOR DESC;

   -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
       
    -- En la baja de beneficiarios se deben eliminar poderes del beneficiario, grabar histórico, baja beneficiario y bitácora
    IF (@accion = ''B'') 
    BEGIN
        -- Insertar en la tabla temporal los registros que se ELIMINARAN
        INSERT INTO @Temp_PYF_APODERADOS
        SELECT * FROM PYF_APODERADOS 
        WHERE TIPO_ENTIDAD = 2 AND ID_ENTIDAD2 = @jts_oid AND ID_PERSONA = @idPersona;
        
        -- Eliminar todos los poderes relacionados al beneficiario para el saldo en cuestión
        DELETE FROM PYF_APODERADOS
        WHERE TIPO_ENTIDAD = 2 AND ID_ENTIDAD2 = @jts_oid AND ID_PERSONA = @idPersona;

        -- Insertar en BITACORA_APODERADOS con tipo_traza = ''B''
        INSERT INTO BITACORA_APODERADOS (
            FECHA, SUCURSAL, ASIENTO, ORDINAL, TIPO_TRAZA, OPERACION, USUARIO, HORA,
            ID_ENTIDAD, TIPO_ENTIDAD, TIPO_PODER, ID_PERSONA, CATEGORIA, MONEDA_MONTO_INDIV,
            MONTO_MAX_INDIV, MONEDA_MONTO_GRUPAL, MONTO_MAX_GRUPAL, FECHA_VENCIMIENTO,
            FECHA_INI_VIGENCIA, FECHA_INI_SUSPENSION, FECHA_FIN_SUSPENSION, TZ_LOCK, ID_CLIENTE_SALDO
        )
        SELECT 
            @asientoFecha, @asientoSucursal, @asientoNumero, 
            ISNULL((SELECT MAX(ORDINAL) FROM BITACORA_APODERADOS WHERE FECHA = @asientoFecha AND SUCURSAL = @asientoSucursal AND ASIENTO = @asientoNumero), 0) + ROW_NUMBER() OVER (ORDER BY ID_ENTIDAD),
            ''B'', @operacion, @usuario, @hora,
            ID_ENTIDAD, TIPO_ENTIDAD, TIPO_PODER, ID_PERSONA, CATEGORIA, MONEDA_MONTO_INDIV,
            MONTO_MAX_INDIV, MONEDA_MONTO_GRUPAL, MONTO_MAX_GRUPAL, FECHA_VENCIMIENTO,
            FECHA_INI_VIGENCIA, FECHA_INI_SUSPENSION, FECHA_FIN_SUSPENSION, 0, ID_CLIENTE_SALDO
        FROM @Temp_PYF_APODERADOS;

        -- DELETE Beneficiario
        DELETE FROM DJ_BENEFICIARIOS
        WHERE NRO_CAUSA = @causaNumero AND JTS_OID_CUENTA = @jts_oid AND ID_BENEFICIARIO = @idPersona;

        -- DJ HISTORICO MOD: BAJA DE BENEFICIARIOS "Y"
        INSERT INTO DJ_HISTORICO_MOD (
            NRO_CAUSA, FECHA, NRO_OFICIO, JUEZ, SECRETARIO, MOTIVO_MOD, VALOR_ANTERIOR, VALOR_NUEVO, USUARIO_ALTA, HORA_ALTA, ORDINAL
        )
        SELECT 
            @causaNumero, @asientoFecha, @asientoNumero, @idPersonaJuez, @idPersonaJuez, ''Y'', @idPersona, NULL, @usuario, @hora,
            ISNULL((SELECT MAX(ORDINAL) FROM DJ_HISTORICO_MOD WHERE NRO_CAUSA = @causaNumero AND FECHA = @asientoFecha), 0)+1

        SET @codigo = 0;
        SET @descripcion = CONCAT(''Poderes eliminados para el beneficiario: '', @idPersona);
    END
    -- En el alta de beneficiarios se debe agregar poderes, grabar histórico, alta beneficiario y bitácora.
    ELSE IF (@accion = ''A'')
    BEGIN

        -- Insertar en la tabla temporal los registros que se AGREGARAN
        INSERT INTO @Temp_PYF_APODERADOS (
                TZ_LOCK, ID_ENTIDAD, TIPO_PODER, TIPO_ENTIDAD,
                ID_PERSONA, CATEGORIA, MONEDA_MONTO_INDIV, MONTO_MAX_INDIV,
                MONEDA_MONTO_GRUPAL, MONTO_MAX_GRUPAL, FECHA_VENCIMIENTO,
                FECHA_INI_VIGENCIA, FECHA_INI_SUSPENSION, FECHA_FIN_SUSPENSION,
                APODERAMIENTO, ID_CLIENTE_SALDO, ID_ENTIDAD2
        )
        SELECT 
            0, @jts_oid, p.CODPODER , 2, @idPersona,
            ''A'', 1, 9999999999999.99, 1, 9999999999999.99,
            ''2123-01-01'', @asientoFecha, NULL, NULL,
            CODAPODERAMIENTO, '''', @jts_oid
        FROM PYF_APODERAMIENTO p WHERE CODAPODERAMIENTO = 22;
        
        -- Eliminar todos los poderes relacionados al beneficiario para el saldo en cuestión
        DELETE FROM PYF_APODERADOS
        WHERE TIPO_ENTIDAD = 2 AND ID_ENTIDAD2 = @jts_oid AND ID_PERSONA = @idPersona;

        -- Insertar en la tabla PYF_APODERADOS
        INSERT INTO PYF_APODERADOS
        SELECT * FROM @Temp_PYF_APODERADOS;

        -- Insertar en BITACORA_APODERADOS
        INSERT INTO BITACORA_APODERADOS (
            FECHA, SUCURSAL, ASIENTO, ORDINAL, TIPO_TRAZA, OPERACION, USUARIO, HORA,
            ID_ENTIDAD, TIPO_ENTIDAD, TIPO_PODER, ID_PERSONA, CATEGORIA, MONEDA_MONTO_INDIV,
            MONTO_MAX_INDIV, MONEDA_MONTO_GRUPAL, MONTO_MAX_GRUPAL, FECHA_VENCIMIENTO,
            FECHA_INI_VIGENCIA, FECHA_INI_SUSPENSION, FECHA_FIN_SUSPENSION, TZ_LOCK, ID_CLIENTE_SALDO
        )
        SELECT 
            @asientoFecha, @asientoSucursal, @asientoNumero, 
            ISNULL((SELECT MAX(ORDINAL) FROM BITACORA_APODERADOS WHERE FECHA = @asientoFecha AND SUCURSAL = @asientoSucursal AND ASIENTO = @asientoNumero), 0) + ROW_NUMBER() OVER (ORDER BY ID_ENTIDAD),
            ''A'', @operacion, @usuario, @hora,
            ID_ENTIDAD, TIPO_ENTIDAD, TIPO_PODER, ID_PERSONA, CATEGORIA, MONEDA_MONTO_INDIV,
            MONTO_MAX_INDIV, MONEDA_MONTO_GRUPAL, MONTO_MAX_GRUPAL, FECHA_VENCIMIENTO,
            FECHA_INI_VIGENCIA, FECHA_INI_SUSPENSION, FECHA_FIN_SUSPENSION, 0, ID_CLIENTE_SALDO
        FROM @Temp_PYF_APODERADOS;
        
        -- DELETE Beneficiario
        DELETE FROM DJ_BENEFICIARIOS WHERE NRO_CAUSA = @causaNumero AND JTS_OID_CUENTA = @jts_oid AND ID_BENEFICIARIO = @idPersona;

        -- ALTA de Beneficiario
        INSERT INTO DJ_BENEFICIARIOS (NRO_CAUSA, JTS_OID_CUENTA, ID_BENEFICIARIO, LECTURA, TZ_LOCK, FECHA_INTEGRACION)
        SELECT 
            @causaNumero, @jts_oid, @idPersona, '' '', 0, @asientoFecha;

        -- DJ HISTORICO MOD: CAMBIO DE BENEFICIARIOS "F"
        INSERT INTO DJ_HISTORICO_MOD (
            NRO_CAUSA, FECHA, NRO_OFICIO, JUEZ, SECRETARIO, MOTIVO_MOD, VALOR_ANTERIOR, VALOR_NUEVO, USUARIO_ALTA, HORA_ALTA, ORDINAL
        )
        SELECT 
            @causaNumero, @asientoFecha, @asientoNumero, @idPersonaJuez, @idPersonaJuez, ''F'', @idPersona, NULL, @usuario, @hora,
            ISNULL((SELECT MAX(ORDINAL) FROM DJ_HISTORICO_MOD WHERE NRO_CAUSA = @causaNumero AND FECHA = @asientoFecha), 0)+1

        SET @codigo = 0;
        SET @descripcion = CONCAT(''Poderes creados para el beneficiario: '', @idPersona);
    END;
      
    COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SET @codigo = 1;
        SET @descripcion = CONCAT(''Error al ejecutar SP_VJ_ADMBENEF_BENEFICIARIO: '',ERROR_MESSAGE());
    END CATCH;
END;
');

EXEC('
CREATE OR ALTER PROCEDURE [dbo].[SP_VJ_ADMINISTRA_JUEZ] 
	@jts_oid NUMERIC(10,0),
	@idPersona NUMERIC(12,0),
	@accion varchar(1),
	@asientoFecha date,
	@asientoSucursal numeric(10,0),
	@asientoNumero numeric(10,0),
	@operacion NUMERIC(4,0),
	@usuario VARCHAR(10),
	@hora VARCHAR(8),
    @causaTipo VARCHAR(2),
    @bloqueoCodigo NUMERIC(3,0),
	@codigo NUMERIC(3) OUTPUT, 
	@descripcion varchar(150) OUTPUT 
AS 
BEGIN 
    SET XACT_ABORT ON;
    BEGIN TRANSACTION;
    BEGIN TRY
    
    -- DECLARACIÓN DE VARIABLES
    DECLARE
        @causaNumero NUMERIC(12,0) = 0,
        @causaJuzgado NUMERIC(12,0) = 0,
        @causaAno NUMERIC(4,0) = 0,
        @causaExpediente VARCHAR(100) = '''',
        @idPersonaJuez NUMERIC(12,0) = 0,
        @actorJuez VARCHAR(3) = '''',
        @idPersonaSecretario NUMERIC(12,0) = 0,
        @actorSecretario VARCHAR(3) = '''',
        @cuentaBloqueada NUMERIC(1,0) = NULL,
        @moneda NUMERIC(5,0);
    
    -- Crear una tabla temporal para almacenar los registros afectados
    DECLARE @Temp_PYF_APODERADOS TABLE (
        TZ_LOCK NUMERIC(16,0),
        ID_ENTIDAD VARCHAR(50),
        TIPO_PODER NUMERIC(5,0),
        TIPO_ENTIDAD NUMERIC(5,0),
        ID_PERSONA NUMERIC(12,0),
        CATEGORIA VARCHAR(1),
        MONEDA_MONTO_INDIV NUMERIC(5,0),
        MONTO_MAX_INDIV NUMERIC(15,2),
        MONEDA_MONTO_GRUPAL NUMERIC(5,0),
        MONTO_MAX_GRUPAL NUMERIC(15,2),
        FECHA_VENCIMIENTO DATETIME,
        FECHA_INI_VIGENCIA DATETIME,
        FECHA_INI_SUSPENSION DATETIME,
        FECHA_FIN_SUSPENSION DATETIME,
        APODERAMIENTO NUMERIC(5,0),
        ID_CLIENTE_SALDO VARCHAR(50),
        ID_ENTIDAD2 NUMERIC(10,0)
    );

  
    -- CODIGO Y DESCRIPCIÓN DEFAULT
    SET @codigo = 99;
    SET @descripcion = ''Error inesperado ejecutando SP'';
   
    -- OBTENER DATOS DE CAUSA
    SELECT 
        @causaNumero = NRO_CAUSA,
        @causaJuzgado = JUZGADO,
        @causaAno = ANO,
        @causaExpediente = EXPEDIENTE
    FROM DJ_CAUSAS
    WHERE ESTADO=''A'' AND TZ_LOCK = 0 --TIPO_CAUSA=@causaTipo AND 
    AND NRO_CAUSA in
        (SELECT NRO_CAUSA
        FROM DJ_CAUSA_CUENTA cc
        WHERE cc.JTS_OID_CUENTA = @jts_oid AND left(cc.TZ_LOCK,1) in (0,2,4))

    IF (@causaNumero = 0 OR @causaNumero is null)
    BEGIN
        SET @codigo = 2;
        SET @descripcion = ''Causa inexistente'';
        ROLLBACK TRANSACTION;
        RETURN;
    END

    SET @moneda = COALESCE((SELECT s.MONEDA FROM SALDOS (NOLOCK) s WHERE s.JTS_OID = @jts_oid), 1)
    
    -- OBTENER ID PERSONA JUEZ
    SELECT TOP 1
        @idPersonaJuez = i.ID_PERSONA,
        @actorJuez = i.ACTOR
    FROM DJ_CAUSAS c 
    INNER JOIN DJ_JUZGADOS j ON c.JUZGADO = j.NRO_JUZGADO 
    INNER JOIN DJ_INTEGRANTES_JUZGADOS i ON i.NRO_JUZGADO  = j.NRO_JUZGADO AND i.ACTIVO  = ''S'' AND i.TZ_LOCK = 0
    WHERE
        --c.TIPO_CAUSA = @causaTipo AND
        c.ESTADO = ''A''  
        AND i.ACTOR IN (''JUZ'', ''JU1'')
        AND c.NRO_CAUSA = @causaNumero 
    ORDER BY i.ACTOR DESC;
    
    -- OBTENER ID PERSONA SECRETARIO
    SELECT TOP 1
        @idPersonaSecretario = i.ID_PERSONA,
        @actorSecretario = i.ACTOR
    FROM DJ_CAUSAS c 
    INNER JOIN DJ_JUZGADOS j ON c.JUZGADO = j.NRO_JUZGADO 
    INNER JOIN DJ_INTEGRANTES_JUZGADOS i ON i.NRO_JUZGADO  = j.NRO_JUZGADO AND i.ACTIVO  = ''S'' AND i.TZ_LOCK = 0
    WHERE
        --c.TIPO_CAUSA = @causaTipo AND
        c.ESTADO = ''A''  
        AND i.ACTOR IN (''SEJ'', ''SE1'')
        AND c.NRO_CAUSA = @causaNumero 
    ORDER BY i.ACTOR DESC;

    -- Eliminar los poderes del JUEZ-SECREATRIO y desbloquear la cuenta
    IF (@accion = ''B'') 
    BEGIN
        -- Insertar en la tabla temporal los registros que se ELIMINARAN
        INSERT INTO @Temp_PYF_APODERADOS
        SELECT * FROM PYF_APODERADOS 
        WHERE TIPO_ENTIDAD = 2 AND ID_ENTIDAD2 = @jts_oid;
        
        -- Eliminar todos los poderes relacionados al saldo
    DELETE FROM PYF_APODERADOS
        WHERE TIPO_ENTIDAD = 2 AND ID_ENTIDAD2 = @jts_oid;

        -- Insertar en BITACORA_APODERADOS con tipo_traza = ''B''
        INSERT INTO BITACORA_APODERADOS (
            FECHA, SUCURSAL, ASIENTO, ORDINAL, TIPO_TRAZA, OPERACION, USUARIO, HORA,
            ID_ENTIDAD, TIPO_ENTIDAD, TIPO_PODER, ID_PERSONA, CATEGORIA, MONEDA_MONTO_INDIV,
            MONTO_MAX_INDIV, MONEDA_MONTO_GRUPAL, MONTO_MAX_GRUPAL, FECHA_VENCIMIENTO,
            FECHA_INI_VIGENCIA, FECHA_INI_SUSPENSION, FECHA_FIN_SUSPENSION, TZ_LOCK, ID_CLIENTE_SALDO
        )
        SELECT 
            @asientoFecha, @asientoSucursal, @asientoNumero, 
            ISNULL((SELECT MAX(ORDINAL) FROM BITACORA_APODERADOS WHERE FECHA = @asientoFecha AND SUCURSAL = @asientoSucursal AND ASIENTO = @asientoNumero), 0) + ROW_NUMBER() OVER (ORDER BY ID_ENTIDAD),
            ''B'', @operacion, @usuario, @hora,
            ID_ENTIDAD, TIPO_ENTIDAD, TIPO_PODER, ID_PERSONA, CATEGORIA, MONEDA_MONTO_INDIV,
            MONTO_MAX_INDIV, MONEDA_MONTO_GRUPAL, MONTO_MAX_GRUPAL, FECHA_VENCIMIENTO,
            FECHA_INI_VIGENCIA, FECHA_INI_SUSPENSION, FECHA_FIN_SUSPENSION, 0, ID_CLIENTE_SALDO
        FROM @Temp_PYF_APODERADOS;

        -- DESASOCIAR DJ_INTEGRANTES_CAUSAS
        IF EXISTS (SELECT 1 FROM DJ_INTEGRANTES_CAUSAS WHERE NRO_CAUSA = @causaNumero)
        BEGIN 
			UPDATE DJ_INTEGRANTES_CAUSAS 
           	SET FECHA_CESE = @asientoFecha, ACTIVO = ''N'' 
           	WHERE NRO_CAUSA = @causaNumero;
        END;

        IF (@bloqueoCodigo > 0)
        BEGIN
            -- DESBLOQUEAR CUENTA SI HAY BLOQUEOS con CODIGO = 9
            IF EXISTS (SELECT 1 FROM GRL_BLOQUEOS WHERE COD_BLOQUEO = @bloqueoCodigo AND ESTADO <> 2 AND SALDO_JTS_OID = @jts_oid)
            BEGIN
                UPDATE GRL_BLOQUEOS
                SET ESTADO = 2
                WHERE COD_BLOQUEO = @bloqueoCodigo AND ESTADO <> 2 AND SALDO_JTS_OID = @jts_oid;
            END;

            -- VERIFICAR: LA CUENTA NO DEBE POSEER BLOQUEOS ACTIVOS ANTES DE MARCAR EL DESBLOQUEO EN SALDOS.
            IF NOT EXISTS (SELECT TOP 1 1 FROM GRL_BLOQUEOS WHERE ESTADO <> 2 AND SALDO_JTS_OID = @jts_oid)
            BEGIN
                UPDATE SALDOS
                SET C1679 = 0
                WHERE JTS_OID = @jts_oid;
            END;
        END;

        SET @codigo = 0;
        SET @descripcion = ''BAJA: Finalizó correctamente'';
    END
    -- Alta: se deben crear los poderes del juez y bloquear la cuenta
    ELSE IF (@accion = ''A'')
    BEGIN
                  
        IF (@idPersonaJuez = 0 AND @idPersonaSecretario = 0)
        BEGIN
            SET @codigo = 51;
            SET @descripcion = CONCAT(''Error: No se encontró Juez y secretario parametrizados para la causa: '', @causaNumero);
        END
        ELSE
        BEGIN
            -- Insertar en la tabla temporal: Juez
            IF (@idPersonaJuez>0)
            BEGIN
                INSERT INTO @Temp_PYF_APODERADOS (
                    TZ_LOCK, ID_ENTIDAD, TIPO_PODER, TIPO_ENTIDAD,
                    ID_PERSONA, CATEGORIA, MONEDA_MONTO_INDIV, MONTO_MAX_INDIV,
                    MONEDA_MONTO_GRUPAL, MONTO_MAX_GRUPAL, FECHA_VENCIMIENTO,
                    FECHA_INI_VIGENCIA, FECHA_INI_SUSPENSION, FECHA_FIN_SUSPENSION,
                    APODERAMIENTO, ID_CLIENTE_SALDO, ID_ENTIDAD2
                )
                SELECT 
                    0, @jts_oid, p.CODPODER, 2, @idPersonaJuez,
                    ''A'', @moneda, 9999999999999.99, @moneda, 9999999999999.99,
                    ''2123-01-01'', @asientoFecha, NULL, NULL,
                    CODAPODERAMIENTO, '''', @jts_oid
                FROM PYF_APODERAMIENTO p WHERE CODAPODERAMIENTO = 21;
            END;  

            -- Insertar en la tabla temporal: Secretario
            IF (@idPersonaSecretario>0)
            BEGIN
                INSERT INTO @Temp_PYF_APODERADOS (
                    TZ_LOCK, ID_ENTIDAD, TIPO_PODER, TIPO_ENTIDAD,
                    ID_PERSONA, CATEGORIA, MONEDA_MONTO_INDIV, MONTO_MAX_INDIV,
                    MONEDA_MONTO_GRUPAL, MONTO_MAX_GRUPAL, FECHA_VENCIMIENTO,
                    FECHA_INI_VIGENCIA, FECHA_INI_SUSPENSION, FECHA_FIN_SUSPENSION,
                    APODERAMIENTO, ID_CLIENTE_SALDO, ID_ENTIDAD2
                )
                SELECT 
                    0, @jts_oid, p.CODPODER, 2, @idPersonaSecretario,
                    ''A'', @moneda, 9999999999999.99, @moneda, 9999999999999.99,
                    ''2123-01-01'', @asientoFecha, NULL, NULL,
                    CODAPODERAMIENTO, '''', @jts_oid
                FROM PYF_APODERAMIENTO p WHERE CODAPODERAMIENTO = 21;
            END;

            -- Eliminar los poderes relacionados al saldo
            DELETE FROM PYF_APODERADOS
            WHERE TIPO_ENTIDAD = 2 AND ID_ENTIDAD2 = @jts_oid;

            -- Asignar poderes reladcionados a juez-secretario sobre el saldo
            INSERT INTO PYF_APODERADOS
            SELECT * FROM @Temp_PYF_APODERADOS;

            -- Insertar en BITACORA_APODERADOS
            INSERT INTO BITACORA_APODERADOS (
                FECHA, SUCURSAL, ASIENTO, ORDINAL, TIPO_TRAZA, OPERACION, USUARIO, HORA,
                ID_ENTIDAD, TIPO_ENTIDAD, TIPO_PODER, ID_PERSONA, CATEGORIA, MONEDA_MONTO_INDIV,
                MONTO_MAX_INDIV, MONEDA_MONTO_GRUPAL, MONTO_MAX_GRUPAL, FECHA_VENCIMIENTO,
                FECHA_INI_VIGENCIA, FECHA_INI_SUSPENSION, FECHA_FIN_SUSPENSION, TZ_LOCK, ID_CLIENTE_SALDO
            )
            SELECT 
                @asientoFecha, @asientoSucursal, @asientoNumero, 
                ISNULL((SELECT MAX(ORDINAL) FROM BITACORA_APODERADOS WHERE FECHA = @asientoFecha AND SUCURSAL = @asientoSucursal AND ASIENTO = @asientoNumero), 0) + ROW_NUMBER() OVER (ORDER BY ID_ENTIDAD),
                ''A'', @operacion, @usuario, @hora,
                ID_ENTIDAD, TIPO_ENTIDAD, TIPO_PODER, ID_PERSONA, CATEGORIA, MONEDA_MONTO_INDIV,
                MONTO_MAX_INDIV, MONEDA_MONTO_GRUPAL, MONTO_MAX_GRUPAL, FECHA_VENCIMIENTO,
                FECHA_INI_VIGENCIA, FECHA_INI_SUSPENSION, FECHA_FIN_SUSPENSION, 0, ID_CLIENTE_SALDO
            FROM @Temp_PYF_APODERADOS;
            
			-- ASOCIAR JUEZ A DJ_INTEGRANTES_CAUSAS
			IF @idPersonaJuez>0 
            BEGIN
                IF EXISTS (SELECT 1 FROM DJ_INTEGRANTES_CAUSAS WHERE NRO_CAUSA = @causaNumero AND ID_PERSONA = @idPersonaJuez)
                BEGIN
                    UPDATE DJ_INTEGRANTES_CAUSAS
                    SET ACTOR = @actorJuez, ACTIVO = ''S'', FECHA_INTEGRACION=@asientoFecha, FECHA_CESE = NULL
                    WHERE NRO_CAUSA = @causaNumero AND ID_PERSONA = @idPersonaJuez;
                END
                ELSE
                BEGIN
                    INSERT INTO DJ_INTEGRANTES_CAUSAS (NRO_CAUSA, ID_PERSONA, ACTOR, ACTIVO, FECHA_INTEGRACION)
                    VALUES (@causaNumero, @idPersonaJuez, @actorJuez, ''S'', @asientoFecha);
                END;
            END;

            -- ASOCIAR SECRETARIO A DJ_INTEGRANTES_CAUSAS
			IF @idPersonaSecretario>0 
            BEGIN
                IF EXISTS (SELECT 1 FROM DJ_INTEGRANTES_CAUSAS WHERE NRO_CAUSA = @causaNumero AND ID_PERSONA = @idPersonaSecretario)
                BEGIN
                    UPDATE DJ_INTEGRANTES_CAUSAS
                    SET ACTOR = @actorSecretario, ACTIVO = ''S'', FECHA_INTEGRACION=@asientoFecha, FECHA_CESE = NULL
                    WHERE NRO_CAUSA = @causaNumero AND ID_PERSONA = @idPersonaSecretario;
                END
                ELSE
                BEGIN
                    INSERT INTO DJ_INTEGRANTES_CAUSAS (NRO_CAUSA, ID_PERSONA, ACTOR, ACTIVO, FECHA_INTEGRACION)
                    VALUES (@causaNumero, @idPersonaSecretario, @actorSecretario, ''S'', @asientoFecha);
                END;
            END;

            IF (@bloqueoCodigo <> 0)
            BEGIN
                -- INSERTAR O ACTUALIZAR BLOQUEO.-
                IF EXISTS (SELECT TOP 1 1 FROM GRL_BLOQUEOS WHERE COD_BLOQUEO = @bloqueoCodigo AND SALDO_JTS_OID = @jts_oid)
                BEGIN
                    UPDATE GRL_BLOQUEOS 
                    SET ESTADO = 1 
                    WHERE COD_BLOQUEO = @bloqueoCodigo AND SALDO_JTS_OID = @jts_oid;
                END
                ELSE
                BEGIN
                    INSERT INTO GRL_BLOQUEOS 
                        (SALDO_JTS_OID,COD_BLOQUEO,ORDINAL_BLOQUEO,FECHA_VIGENCIA,FECHA_VENCIMIENTO,MANEJA_VENCIMIENTO,DESCRIPCION,ESTADO,USUARIO_INGRESO,FECHA_GRABADA,USUARIO_MODIFICACION,FECHA_MODIFICACION,TZ_LOCK,PORORDEN,SOLICITADOPOR) VALUES
                        (@jts_oid,@bloqueoCodigo,1,@asientoFecha,NULL,0,''SIN MOTIVO CARGADO'',1,'' '',NULL,'' '',NULL,0,'' '','' '');
                END
                
                -- MARCAR BLOQUEO EN SALDOS.
                UPDATE SALDOS
                SET C1679 = 1
                WHERE JTS_OID = @jts_oid;
            END;

            SET @codigo = 0;
            SET @descripcion = ''ALTA: Finalizó correctamente'';
        END;
    END;
      
    COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SET @codigo = 99;
        SET @descripcion = CONCAT(''Error al ejecutar SP_VJ_ADMBENEF_JUEZ: '', ERROR_MESSAGE());
    END CATCH;
END;
');

Execute('CREATE OR ALTER PROCEDURE [dbo].[SP_COELSA_CHEQUES_TERCEROS_RECHAZADOS]

	@TICKET NUMERIC(16)

AS
BEGIN

	/******** Variables Cabecera de Archivo **********************************/
	DECLARE @IdRegistro NUMERIC(1);
	DECLARE @CodPrioridad NUMERIC(2);
	DECLARE @DestinoInmediato VARCHAR(10);
	DECLARE @OrigenInmediato VARCHAR(10);
	DECLARE @FechaPresentacion DATE;
	DECLARE @HoraPresentacion NUMERIC(4);
	DECLARE @IdArchivo VARCHAR(1);
	DECLARE @TamanioRegistro VARCHAR(3);
	DECLARE @FactorBloque VARCHAR(2);
	DECLARE @CodFormato NUMERIC(1);
	DECLARE @NomDestinoInmediato VARCHAR(23);
	DECLARE @NomOrigenInmediato VARCHAR(23);
	DECLARE @CodReferencia VARCHAR(8);
	/*************************************************************************/

	/******** Variables Cabecera de Lote **********************************/
	DECLARE @FechaVencimiento DATE;
	DECLARE @ClaseTransaccion NUMERIC(3);
	DECLARE @ReservadoLote VARCHAR(46);
	DECLARE @ReservadoLoteCeros NUMERIC(3);
	DECLARE @CodigoOrigen  NUMERIC(1);
	DECLARE @CodigoRegistro VARCHAR(3);
	DECLARE @IdEntidadOrigen NUMERIC(8);
	declare @NumeroLote NUMERIC(7);

	/******** Variables Registro Individual de Cheques y Ajustes *************/
	DECLARE @CodTransaccion VARCHAR(2);
	DECLARE @EntidadDebitar VARCHAR(8);
	DECLARE @SucursalGirada VARCHAR(4);
	DECLARE @ReservadoRI VARCHAR(1);
	DECLARE @CuentaDebitar VARCHAR(17);
--s	DECLARE @Importe VARCHAR(10);
	DECLARE @Importe VARCHAR(16);
	DECLARE @NumeroCheque VARCHAR(15);
	DECLARE @CodigoPostal VARCHAR(6);
--s	DECLARE @PuntoIntercambio VARCHAR(16);
	DECLARE @PuntoIntercambio VARCHAR(10);
	DECLARE @InfoAdicional VARCHAR(2);
	DECLARE @RegistrosAdicionales VARCHAR(2);
	DECLARE @ContadorRegistros VARCHAR(15);
	
	DECLARE @CodRechazo VARCHAR (2);
	DECLARE @CodRechazoOri VARCHAR (2);
	DECLARE @CODCLI NUMERIC(12);
	DECLARE @PRODUCTO NUMERIC(5);
	DECLARE @ORDINAL NUMERIC(6);
	DECLARE @Entidad NUMERIC(4);

    
	--SE VAN A USAR ESTOS CAMPOS COMO CLAVE EN LUGAR DEL TRACENUMBER
	
	DECLARE @Entidad_RI VARCHAR(4);	-- SE CAMBIA TIPO A VARCHAR PORQUE AHORA NO SE VALIDA MAS EL REG INDIVIDUAL
	DECLARE @Sucursal_RI VARCHAR(4); -- SE CAMBIA TIPO A VARCHAR PORQUE AHORA NO SE VALIDA MAS EL REG INDIVIDUAL
	DECLARE @CodigoPostal_RI VARCHAR(4); -- SE CAMBIA TIPO A VARCHAR PORQUE AHORA NO SE VALIDA MAS EL REG INDIVIDUAL
	DECLARE @NumeroCuenta_RI VARCHAR(12); -- SE CAMBIA TIPO A VARCHAR PORQUE AHORA NO SE VALIDA MAS EL REG INDIVIDUAL
	DECLARE @NumeroCheque_RI VARCHAR(12); -- SE CAMBIA TIPO A VARCHAR PORQUE AHORA NO SE VALIDA MAS EL REG INDIVIDUAL

	DECLARE @ExisteRI NUMERIC(1) = 0; --para saber si hay al menos 1 lote
	
	/******** Variables FIN DE LOTE *************/
	DECLARE @RegIndivAdic NUMERIC(6);
	DECLARE @TotalesControl NUMERIC(10);
	DECLARE @ReservadoFL VARCHAR(40);

	/******** Variables FIN DE ARCHIVO *************/

	DECLARE @CantLotesFA NUMERIC(6);
	DECLARE @NumBloquesFA NUMERIC(6);
	DECLARE @CantRegAdFA NUMERIC (8);
	DECLARE @TotalesControlFA NUMERIC(10);

	DECLARE @ReservadoFA VARCHAR(39);
	/*************************************************************************/


	/*Validaciones generales */

	DECLARE @updRecepcion VARCHAR(1);

	--#validacion1
	IF(0=(SELECT COUNT(1) FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX WHERE LINEA LIKE ''1%''))
		RAISERROR (''Error - Faltan registros.'', 16, 1);
	IF(0=(SELECT COUNT(1) FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX WHERE LINEA LIKE ''5%''))
		RAISERROR (''Error - Faltan registros.'', 16, 1);
	IF(0=(SELECT COUNT(1) FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX WHERE LINEA LIKE ''8%''))
		RAISERROR (''Error - Faltan registros.'', 16, 1);
	IF(0=(SELECT COUNT(1) FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX WHERE LINEA LIKE ''9%''))
		RAISERROR (''Error - Faltan registros.'', 16, 1);

	--#validacion2
	IF ((SELECT COUNT(1) FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX WHERE LINEA LIKE ''1%'' OR LINEA LIKE ''9%'') > 2 )
		RAISERROR(''Error - Deben haber solo 1 reg CA y 1 reg FA'', 16, 1);

	--#validacion3
	IF(
	(SELECT COUNT(1) as Orden
	WHERE 1=(SELECT count(1)
			WHERE EXISTS (SELECT CONVERT(INT,SUBSTRING(LINEA,1,1))
							FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX
							WHERE ID IN	(SELECT ID-1
										FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX
										WHERE LINEA LIKE ''8%'')
							AND CONVERT(INT,SUBSTRING(LINEA,1,1)) NOT IN (5,6,7)
						)
			)
		OR 1=(SELECT count(1)
			WHERE EXISTS (SELECT CONVERT(INT,SUBSTRING(LINEA,1,1))
							FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX
							WHERE ID IN	(SELECT ID+1
										FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX
										WHERE LINEA LIKE ''8%'')
										AND CONVERT(INT,SUBSTRING(LINEA,1,1)) NOT IN (5,9)
							)
			)
		OR 1=(SELECT count(1)
			WHERE EXISTS (SELECT CONVERT(INT,SUBSTRING(LINEA,1,1))
						FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX
						WHERE ID IN	(SELECT ID-1
									FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX
									WHERE LINEA LIKE ''5%'')
						AND CONVERT(INT,SUBSTRING(LINEA,1,1)) NOT IN (1,8)
							)
					)
		OR 1=(SELECT count(1)
			WHERE EXISTS (SELECT CONVERT(INT,SUBSTRING(LINEA,1,1))
							FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX
							WHERE ID IN	(SELECT ID+1
										FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX
										WHERE LINEA LIKE ''5%'')
							AND CONVERT(INT,SUBSTRING(LINEA,1,1)) NOT IN (6,7,8)
							)
						)) <> 0
	)
		RAISERROR(''El orden de los registros NACHA es incorrecto'', 16, 1);


	------validaciones #5 #6 #7 y #8

	--#5 y 7
	DECLARE @sumaEntidades_RI NUMERIC = 0;
	DECLARE @sumaSucursales_RI NUMERIC = 0;
	DECLARE @sumaEntidades_RIaux NUMERIC = 0;
	DECLARE @sumaSucursales_RIaux NUMERIC = 0;




	DECLARE @sumaTotalCtrl_FL NUMERIC;
	DECLARE @totControl_FA NUMERIC;

	DECLARE @excedenteSuc NUMERIC = 0;

	--#6 y 8
	DECLARE @sumaDebitos_RI NUMERIC;
	DECLARE @sumaCreditos_RI NUMERIC;

	DECLARE @controlDebitos_FL NUMERIC;
	DECLARE @controlCreditos_FL NUMERIC;

	DECLARE @totalDebitos_FA NUMERIC;
	DECLARE @totalCreditos_FA NUMERIC;

	--seteo suma deb y cred 

	SELECT -- debitos
--s		@sumaDebitos_RI = sum(CAST(substring(LINEA, 30, 10) AS NUMERIC)),
		@sumaDebitos_RI = sum(CAST(substring(LINEA, 61, 16) AS NUMERIC)),
		@sumaEntidades_RI = sum(CAST(substring(LINEA, 4, 4) AS NUMERIC)),
		@sumaSucursales_RI = sum(CAST(substring(LINEA, 8, 4) AS NUMERIC))
	FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX
	WHERE LINEA LIKE ''626%'';

	SELECT --creditos
--s		@sumaCreditos_RI = sum(CAST(substring(LINEA, 30, 10) AS NUMERIC)),
		@sumaCreditos_RI = sum(CAST(substring(LINEA, 61, 16) AS NUMERIC)),
		@sumaEntidades_RIaux = sum(CAST(substring(LINEA, 4, 4) AS NUMERIC)),
		@sumaSucursales_RIaux = sum(CAST(substring(LINEA, 8, 4) AS NUMERIC))
	FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX
	WHERE LINEA LIKE ''622%'';

	SET @sumaEntidades_RI += isNull(@sumaEntidades_RIaux,0);
	SET @sumaSucursales_RI += isNull(@sumaSucursales_RIaux,0);
	

	--seteo total control y total de importes FA
	SELECT
		@totControl_FA = CAST(substring(linea, 22, 10) AS NUMERIC), --revisar acaaaa
--s		@totalDebitos_FA = CAST(substring(linea, 32, 12) AS NUMERIC),
--s		@totalCreditos_FA = CAST(substring(linea, 44, 12) AS NUMERIC)
		@totalDebitos_FA = CAST(substring(linea, 32, 20) AS NUMERIC),
		@totalCreditos_FA = CAST(substring(linea, 52, 20) AS NUMERIC)
	FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX
	WHERE LINEA LIKE ''9%'';


	--CHEQUEO SI HAY EXCEDENTE #5 Y 7
	IF(LEN(@sumaSucursales_RI) > 4)
	BEGIN
		SET @excedenteSuc = CAST(LEFT(@sumaSucursales_RI,len(@sumaSucursales_RI)-4) AS NUMERIC);
		SET @sumaSucursales_RI = RIGHT(@sumaSucursales_RI, 4);
	--ME QUEDO CON LAS 4 CIFRAS SIGNIFICATIVAS
	END
	SET @sumaEntidades_RI = @sumaEntidades_RI + @excedenteSuc;
	--LE SUMO EL EXCEDENTE, SI NO HAY SUMO 0

	--seteo suma totales control y debitos de FL
	SELECT
		@sumaTotalCtrl_FL = SUM(CAST(substring(linea, 11, 10) AS NUMERIC)),
--s		@controlDebitos_FL = sum(CAST(substring(LINEA, 21, 12) AS NUMERIC)),
--s		@controlCreditos_FL = sum(CAST(substring(LINEA, 33, 12) AS NUMERIC))
		@controlDebitos_FL = sum(CAST(substring(LINEA, 21, 20) AS NUMERIC)),
		@controlCreditos_FL = sum(CAST(substring(LINEA, 41, 20) AS NUMERIC))
	FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX
	WHERE LINEA LIKE ''8%'';

--PRINT CONCAT(@sumaEntidades_RI, RIGHT(CONCAT(REPLICATE(''0'',3), @sumaSucursales_RI ),4))
--PRINT @sumaTotalCtrl_FL
	--#validacion5
	IF(CONCAT(@sumaEntidades_RI, RIGHT(CONCAT(REPLICATE(''0'',3), @sumaSucursales_RI ),4)) <> @sumaTotalCtrl_FL)
		RAISERROR(''No concuerda la suma Ent/Suc con control FL'', 16, 1);

	--#validacion7
	IF(@sumaTotalCtrl_FL <> @totControl_FA)
		RAISERROR(''No concuerda la suma de TotalesControl de FL con control FA'', 16, 1);

	--#validacion6 debitos
	IF(@sumaDebitos_RI  <> @controlDebitos_FL AND @sumaDebitos_RI <> @totalDebitos_FA)
		RAISERROR(''No concuerda la suma de Debitos individuales con el Total Debitos'', 16, 1);

	--#validacion6 creditos
	IF( @sumaCreditos_RI <> @controlCreditos_FL AND @sumaCreditos_RI <> @totalCreditos_FA)
		RAISERROR(''No concuerda la suma de Creditos individuales con el Total Creditos '', 16, 1);

	--#validacion8
	IF((@controlDebitos_FL + @controlCreditos_FL) <>  (@totalDebitos_FA + @totalCreditos_FA))
		RAISERROR(''No concuerda la suma de Debitos de FL con Total Importe FA'', 16, 1);


	--fin----validaciones #5 #6 #7 y #8

	DECLARE @id int,@LINEA VARCHAR(95);
	DECLARE che_cursor CURSOR FOR 
	SELECT id,LINEA
	FROM dbo.ITF_OTROS_CHEQUES_RESPUESTA_AUX

	OPEN che_cursor

	FETCH NEXT FROM che_cursor INTO @id,@LINEA

	WHILE @@FETCH_STATUS = 0  
	BEGIN

		--#validacion4
		if(DATALENGTH(@LINEA) <> 94)
			RAISERROR(''Se encontraron registros de longitud incorrecta'', 16,1);

		SET @IdRegistro = substring(@LINEA, 1, 1);

		IF(@IdRegistro NOT IN(''1'',''5'',''6'',''7'',''8'',''9'') ) --validacion de id reg      
      		RAISERROR (''Id Registro invalido'', 16, 1);



		/* Cabecera de Archivo */
		IF (@IdRegistro = ''1'') 
      	BEGIN
			SET @CodPrioridad = substring(@LINEA, 2, 2);
			SET @DestinoInmediato = substring(@LINEA, 4, 10);
			SET @OrigenInmediato = substring(@LINEA, 14, 10);
			SET @FechaPresentacion = substring(@LINEA, 24, 6);
			SET @HoraPresentacion = substring(@LINEA, 30, 4);
			SET @IdArchivo = substring(@LINEA, 34, 1);
			SET @TamanioRegistro = substring(@LINEA, 35, 3);
			SET @FactorBloque = substring(@LINEA, 38, 2);
			SET @CodFormato = substring(@LINEA, 40, 1);
			SET @NomDestinoInmediato = substring(@LINEA, 41, 23);
			SET @NomOrigenInmediato = substring(@LINEA, 64, 23);
			SET @CodReferencia = substring(@LINEA, 87, 8);


			IF (@IdArchivo NOT IN (''A'',''B'',''C'',''D'',''E'',''F'',''G'',''H'',''I'',''J'',''K'',''L'',''M'',''N'',''O'',''P'',''Q'',''R'',''S'',''T'',''U'',''V'',''W'',''X'',''Y'',''Z'',''0'',''1'',''2'',''3'',''4'',''5'',''6'',''7'',''8'',''9'')) 	
				RAISERROR (''Identificador Archivo invalido'', 16, 1);

			--#validacion11
			IF(substring(@DestinoInmediato, 2, 4) <> ''0311'')
				RAISERROR (''Destino inmediato debe ser 0311'', 16, 1);

		END


		IF (@IdRegistro = ''5'') 
      	BEGIN

			--variables cabecera de lote
			SET @ClaseTransaccion = substring(@LINEA, 2, 3);
			SET @ReservadoLote = substring(@LINEA, 5, 46);
			--VALIDACION RESERVADO VACIO
			SET @CodigoRegistro = substring(@LINEA, 51, 3);

			SET @FechaPresentacion = CAST(substring(@LINEA, 64, 6) AS DATE);
			--VALIDACION FECHAS
			SET @FechaVencimiento = CAST(substring(@LINEA, 70, 6) AS DATE);
			SET @ReservadoLoteCeros = substring(@LINEA, 76, 3);
			--VALIDACION RESERVADO 000
			SET @CodigoOrigen = substring(@LINEA, 79, 1);

			SET @IdEntidadOrigen = substring(@LINEA, 80, 4);

			SET @NumeroLote = substring(@LINEA, 88, 7);

			IF (@ClaseTransaccion <> 200)     
    			RAISERROR (''Codigo de clase de transaccion debe ser 200'', 16, 1);

			IF (@CodigoOrigen <> 1)     	
    			RAISERROR (''Codigo origen debe ser 1'', 16, 1);


			IF (@CodigoRegistro <> ''TRC'')       
    			RAISERROR (''Codigo de registro debe ser TRC'', 16, 1);

			IF (@FechaPresentacion > @FechaVencimiento)      	
    			RAISERROR (''Fecha Presentacion debe ser anterior a vencimiento'', 16, 1);
		END

		/*FIN DE LOTE*/
		IF (@IdRegistro = ''8'') 
      	BEGIN
			SET @ClaseTransaccion = substring(@LINEA, 2, 3);
			--SET @RegIndivAdic = substring(@LINEA, 5, 6);
		--	SET @TotalesControl = substring(@LINEA, 11,10);
--s			SET @ReservadoFL = substring(@LINEA, 45, 35);
			SET @ReservadoFL = substring(@LINEA, 61, 29);
			SET @IdEntidadOrigen = substring(@LINEA, 80, 4);
			SET @NumeroLote = substring(@LINEA, 88, 7);

			IF (@ClaseTransaccion <> 200) 
				RAISERROR (''Codigo de clase de transaccion debe ser 200'', 16, 1);

		END

		/*FIN DE ARCHIVO*/
		IF (@IdRegistro = ''9'') 
      	BEGIN
			SET @CantLotesFA = substring(@LINEA, 2, 6);
			SET @NumBloquesFA = substring(@LINEA, 8, 6);
			SET @CantRegAdFA = substring(@LINEA, 14, 8);
			SET @TotalesControlFA  = substring(@LINEA, 22, 10);
--s			SET @ReservadoFA  = substring(@LINEA, 56, 39);
			SET @ReservadoFA  = substring(@LINEA, 72, 23);


			--#validacion9
			IF((SELECT COUNT(1)
			FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX
			WHERE LINEA LIKE ''5%'') <> @CantLotesFA)
			RAISERROR(''No coincide la cantidad de LOTES con la informada en el reg FA'', 16, 1);
			--#validacion10
			IF((SELECT count(1)
			FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX
			WHERE LINEA LIKE ''6%'' OR LINEA LIKE ''7%'') <> @CantRegAdFA)
			RAISERROR(''No coincide la cantidad de registros ind y ad con la informada en el reg FA'', 16, 1);

		END




		/* Registro Individual*/
		IF (@IdRegistro = ''6'' ) 
      	BEGIN
			SET @ExisteRI = 1;

			SET @CodTransaccion = substring(@LINEA, 2, 2);
			SET @EntidadDebitar = substring(@LINEA, 4, 8);
			SET @SucursalGirada = substring(@LINEA, 8,4);
			SET @ReservadoRI = substring(@LINEA, 12, 1);
			SET @CuentaDebitar = substring(@LINEA, 13, 17);
--s			SET @Importe = substring(@LINEA, 30, 10);
			SET @Importe = convert(VARCHAR(16),convert(NUMERIC(15,2),(convert(NUMERIC(16),substring(@LINEA, 61, 16))/100))); 
			SET @NumeroCheque = substring(@LINEA, 40, 15);
			SET @CodigoPostal = substring(@LINEA, 55, 6);
--s			SET @PuntoIntercambio = substring(@LINEA, 61, 16);
			SET @PuntoIntercambio = substring(@LINEA, 30, 10);
			SET @InfoAdicional = substring(@LINEA, 77, 2);
			SET @RegistrosAdicionales = substring(@LINEA, 79, 1);
			SET @ContadorRegistros = substring(@LINEA, 80, 15);
			/* Trace Number */

			SET @Entidad_RI = substring(@ContadorRegistros, 1, 4);
			SET @Sucursal_RI = substring(@ContadorRegistros, 5, 4);
			SET @CodigoPostal_RI = RIGHT(@CodigoPostal, 4);
			SET @NumeroCuenta_RI = RIGHT(@CuentaDebitar, 12);
			SET @NumeroCheque_RI = RIGHT(@NumeroCheque, 12);


			IF (@RegistrosAdicionales NOT IN(''1'',''0'')) 
    			RAISERROR (''Campo Registro adicional invalido'', 16, 1);



			--- Variables Generales ---
			DECLARE @NRO_DPF_CHEQUE NUMERIC(12);
			DECLARE @BANCO_GIRADO NUMERIC(4);
			DECLARE @SUCURSAL_BANCO NUMERIC(5);
			DECLARE @TIPO_DOCUMENTO VARCHAR(4);
--s			DECLARE @IMPORTE_TOTAL NUMERIC(10,2);
			DECLARE @IMPORTE_TOTAL NUMERIC(15,2);
			DECLARE @MONEDA NUMERIC(1);
			DECLARE @SERIE_DEL_CHEQUE VARCHAR(6);
			DECLARE @NRO_CUENTA NUMERIC(12);
			DECLARE @CODIGO_POSTAL NUMERIC(4);
			DECLARE @EXISTE NUMERIC(4) = 0;
			
			IF (@CodTransaccion = ''22'')
				BEGIN
			   		SET @Sucursal_RI = substring(@LINEA, 8,4);
			   		--PRINT ''TRN: '' + @CodTransaccion + '' Linea: '' + substring(@LINEA, 8,4) + '' Sucursal: '' + @Sucursal_RI
			   	END
			ELSE
				IF (@CodTransaccion = ''26'')
					BEGIN
						SET @Sucursal_RI = (select substring(LINEA, 32,4) from ITF_OTROS_CHEQUES_RESPUESTA_AUX where ID = @id + 1)
						--PRINT ''TRN: '' + @CodTransaccion + '' Linea: '' + substring(@LINEA, 8,4) + '' Sucursal: '' + @Sucursal_RI
					END
			

			IF(@TICKET<>0)
      		BEGIN
      		
      			--Rechazos como girada (trae registro adicional)
      					/*Registro ind adicional*/
				IF(@RegistrosAdicionales = ''1'')
				BEGIN
			 
					SET @CodRechazo = (SELECT substring(LINEA, 5, 2) FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX WHERE id=@id+1)

	
					IF(ISNUMERIC(@Entidad_RI) = 1 AND ISNUMERIC(@Sucursal_RI) = 1 AND ISNUMERIC(@CodigoPostal_RI) = 1 AND ISNUMERIC(@NumeroCheque_RI) = 1 AND ISNUMERIC(@NumeroCuenta_RI ) = 1 )
					BEGIN			
			--actualizo el codigo de rechazo
						UPDATE ITF_COELSA_SESION_RECHAZADOS 
						SET CODIGO_RECHAZO = @CodRechazo 
						WHERE ID_TICKET = @TICKET 
						AND BANCO = @Entidad_RI 
						AND  SUCURSAL = @Sucursal_RI 
						AND CUENTA = @NumeroCuenta_RI 
						AND CODIGO_POSTAL = @CodigoPostal_RI 
						AND NRO_CHEQUE = @NumeroCheque_RI;
--REVISAMOS ACA
--						IF(@updRecepcion = ''D'')
--						BEGIN
--							UPDATE CLE_RECEPCION_DPF_DEV 
--							SET CODIGO_RECHAZO = @CodRechazo 
--							WHERE NUMERO_DPF = @NumeroCheque_RI 
--							AND BANCO_GIRADO = @Entidad_RI 
--							AND SUCURSAL_BANCO_GIRADO = @Sucursal_RI;
--						END
						
--COMENTADO EL 17/12/2024 POR FUNCIONAMIENTO INCORRECTO DE CLE_RECEPCION_CHEQUES_DEV J.I.
						
--						ELSE IF(@updRecepcion = ''C'' AND ISNUMERIC(@CodRechazo) = 1)
--						BEGIN
--							UPDATE CLE_RECEPCION_CHEQUES_DEV 
--							SET CODIGO_RECHAZO = @CodRechazo 
--							WHERE NUMERO_CHEQUE = @NumeroCheque_RI 
--							AND BANCO_GIRADO = @Entidad_RI 
--							AND SUCURSAL_BANCO_GIRADO = @Sucursal_RI;
--						END
					
--HASTA ACA--

					END
					UPDATE RRII_CHE_RECHAZADOS
					SET CAUSAL=(SELECT TOP 1 CODIGO_DE_CAUSAL FROM CLE_TIPO_CAUSAL WHERE CODIGO_NACHA=@CodRechazo),
						CODIGO_MOTIVO=@CodRechazo
					WHERE cod_entidad = 311
    				AND Nro_sucursal = TRIM(''0'' FROM RIGHT(@EntidadDebitar, 3))
    				AND cuenta = @NumeroCuenta_RI
    				AND nro_cheque = @NumeroCheque_RI
    				AND fecha_registro_novedad = (SELECT fechaproceso FROM PARAMETROS);
				END
      		
--si es un rechazo de entidad depositaria (622%) el codigo de rechazo lo tenemos que setear de la siguiente forma       		
				IF @codTransaccion=''22''
				BEGIN
					IF TRY_CONVERT(INT,SUBSTRING(@LINEA,34,2))=0 -- Antes 65,2 - A.E 21/2/2025
					BEGIN
						SET @codRechazo=substring(@linea,36,2) -- Antes 67,2 - A.E 21/2/2025
					END
					ELSE IF TRY_CONVERT(INT,SUBSTRING(@LINEA,36,2))=0 -- Antes 67,2
		   			BEGIN
						SET @codRechazo=substring(@linea,34,2) -- Antes 65,2
					END
					ELSE 
					BEGIN 
						SET @CodRechazo=substring(@linea,34,2) -- Antes 65,2
					END 
				END 
				SET @updRecepcion = ''-'';

				IF (ISNUMERIC(@CuentaDebitar) = 1 AND CAST(@CuentaDebitar AS NUMERIC) = 88888888888)
				BEGIN
					IF(ISNUMERIC(@Entidad_RI) = 1 AND ISNUMERIC(@Sucursal_RI) = 1 AND ISNUMERIC(@CodigoPostal_RI) = 1 AND ISNUMERIC(@NumeroCheque_RI) = 1 AND ISNUMERIC(@NumeroCuenta_RI ) = 1 )
					BEGIN
						-- La idea es actualizar los rechazados del plano con ESTADO_AJUSTE = ''R'' y el resto de cheques del historial con ESTADO_AJUSTE  = ''A''	
						UPDATE dbo.CLE_CHEQUES_AJUSTE 
						SET ESTADO_AJUSTE = ''R'' 
						WHERE TZ_LOCK = 0 
						AND @Entidad_RI = BANCO 
						AND @Sucursal_RI  = SUCURSAL_BANCO_GIRADO 
						AND @CodigoPostal_RI = CODIGO_POSTAL 
						AND @NumeroCheque_RI = NUMERO_CHEQUE 
						AND @NumeroCuenta_RI = NUMERO_CUENTA;

						-- Consulta Ajuste
						SELECT @EXISTE = 1, @ORDINAL = ORDINAL, @BANCO_GIRADO = BANCO, @NRO_DPF_CHEQUE = NUMERO_CHEQUE, @SUCURSAL_BANCO = SUCURSAL_BANCO_GIRADO, @NRO_CUENTA = NUMERO_CUENTA, @CODIGO_POSTAL = CODIGO_POSTAL, @IMPORTE_TOTAL = IMPORTE, @MONEDA = MONEDA
						FROM CLE_CHEQUES_AJUSTE WITH(NOLOCK)
						WHERE TZ_LOCK = 0 
						AND @Entidad_RI = BANCO 
						AND @Sucursal_RI  = SUCURSAL_BANCO_GIRADO 
						AND @CodigoPostal_RI = CODIGO_POSTAL 
						AND @NumeroCheque_RI = NUMERO_CHEQUE 
						AND @NumeroCuenta_RI = NUMERO_CUENTA;
					END

					IF @EXISTE > 0
					BEGIN
						
						-- Guardamos clave para update si hay reg adicional
						SET @Entidad_RI = @BANCO_GIRADO;
						SET @Sucursal_RI = @SUCURSAL_BANCO;
						SET @NumeroCuenta_RI = @NRO_CUENTA;
						SET @CodigoPostal_RI = @CODIGO_POSTAL;
						SET @NumeroCheque_RI = @NRO_DPF_CHEQUE;

						-- Insertamos en el historial
						INSERT INTO ITF_COELSA_SESION_RECHAZADOS (ID_TICKET, 
																	FECHA_ALTA, 
																	BANCO, 
																	SUCURSAL, 
																	CUENTA, 
																	IMPORTE, 
																	CODIGO_POSTAL, 
																	NRO_CHEQUE, 
																	PUNTO_INTERCAMBIO, 
																	TRACK_NUMBER, 
																	TIPO, 
																	MONEDA, 
																	TIPO_DOCUMENTO, 
																	CODIGO_RECHAZO, 
																	ORDINAL
																	, serie_del_cheque)
															VALUES(@TICKET, 
																	@FechaPresentacion, 
																	@BANCO_GIRADO, 
																	@SUCURSAL_BANCO, 
																	@NRO_CUENTA, 
																	@IMPORTE_TOTAL, 
																	@CODIGO_POSTAL, 
																	@NRO_DPF_CHEQUE, 
																	@PuntoIntercambio, 
																	@ContadorRegistros, 
																	''C'',  
																	@MONEDA, 
																	@TIPO_DOCUMENTO, 
																	@CodRechazo, 
																	@ORDINAL
																	, (CASE WHEN substring(@infoadicional,2,1) IN (''2'',''3'') THEN ''E'' ELSE '' '' END))
					
PRINT concat(''Moneda-existe-ticket<>0: '',@moneda)
					END
					ELSE
					BEGIN
						-- Insertamos en el historial en caso de que no exista
						SET @moneda=1

						INSERT INTO ITF_COELSA_SESION_RECHAZADOS (ID_TICKET, 
																	FECHA_ALTA, 
																	BANCO, 
																	SUCURSAL, 
																	CUENTA, 
																	IMPORTE, 
																	CODIGO_POSTAL, 
																	NRO_CHEQUE, 
																	PUNTO_INTERCAMBIO, 
																	TRACK_NUMBER, 
																	TIPO, 
																	MONEDA, 
																	TIPO_DOCUMENTO
																	, codigo_rechazo
																	, serie_del_cheque)
						VALUES(@TICKET, 
							@FechaPresentacion, 
							CASE WHEN ISNUMERIC(@Entidad_RI) = 0 THEN -1 ELSE CAST(@Entidad_RI AS NUMERIC(4)) END ,
							CASE WHEN ISNUMERIC(@Sucursal_RI) = 0 THEN -1 ELSE CAST(@Sucursal_RI AS NUMERIC(5)) END, 
							CASE WHEN ISNUMERIC(@NumeroCuenta_RI) = 0 THEN -1 ELSE CAST(@NumeroCuenta_RI AS NUMERIC(12)) END, 
							@Importe, 
							CASE WHEN ISNUMERIC(@CodigoPostal_RI) = 0 THEN -1 ELSE CAST(@CodigoPostal_RI AS NUMERIC(4)) END, 
							CASE WHEN ISNUMERIC(@NumeroCheque_RI) = 0 THEN -1 ELSE CAST(@NumeroCheque_RI AS NUMERIC(12)) END ,
							@PuntoIntercambio, 
							@ContadorRegistros, 
							''C'',
							@moneda, 
							@TIPO_DOCUMENTO
							, @codRechazo
							, (CASE WHEN substring(@infoadicional,2,1) IN (''2'',''3'') THEN ''E'' ELSE '' '' END));

					END
				END			
				ELSE IF (ISNUMERIC(@CuentaDebitar) = 1 AND CAST(@CuentaDebitar AS NUMERIC) = 77777777777)
				BEGIN
					IF(ISNUMERIC(@Entidad_RI) = 1 AND ISNUMERIC(@Sucursal_RI) = 1 AND ISNUMERIC(@CodigoPostal_RI) = 1 AND ISNUMERIC(@NumeroCheque_RI) = 1 AND ISNUMERIC(@NumeroCuenta_RI ) = 1 )
					BEGIN
					 	-- Consulta DPF  			
					 	SELECT @EXISTE = 1, @TIPO_DOCUMENTO = TIPO_DOCUMENTO, @NRO_DPF_CHEQUE = NUMERO_DPF, @BANCO_GIRADO = BANCO_GIRADO, @SUCURSAL_BANCO = SUCURSAL_BANCO_GIRADO, @IMPORTE_TOTAL = IMPORTE, @CODIGO_POSTAL = COD_POSTAL, @MONEDA = MONEDA, @NRO_CUENTA = NUMERICO_CUENTA_GIRADORA
					 	FROM CLE_DPF_SALIENTE WITH(NOLOCK)
					 	WHERE TZ_LOCK = 0 
					 	AND @Entidad_RI = BANCO_GIRADO 
					 	AND @Sucursal_RI  = SUCURSAL_BANCO_GIRADO 
					 	AND @CodigoPostal_RI = COD_POSTAL 
					 	AND @NumeroCheque_RI = NUMERO_DPF 
					 	AND @NumeroCuenta_RI = NUMERICO_CUENTA_GIRADORA;
					END

					IF @EXISTE > 0
				    BEGIN
					 	-- Guardamos clave para update si hay reg adicional
					 	SET @Entidad_RI = @BANCO_GIRADO;
					 	SET @Sucursal_RI = @SUCURSAL_BANCO;
					 	SET @NumeroCuenta_RI = @NRO_CUENTA;
					 	SET @CodigoPostal_RI = @CODIGO_POSTAL;
					 	SET @NumeroCheque_RI = @NRO_DPF_CHEQUE;
							
					 	SET @updRecepcion = ''D''; --para saber si hay que updatear  CLE_RECEPCION_DPF_DEV
						IF (SELECT COUNT(1) 
							FROM CLE_RECEPCION_DPF_DEV
							WHERE NUMERO_DPF = @NumeroCheque_RI 
							AND BANCO_GIRADO = @Entidad_RI 
							AND SUCURSAL_BANCO_GIRADO = @Sucursal_RI
							)>0
						BEGIN
							UPDATE CLE_RECEPCION_DPF_DEV 
							SET CODIGO_RECHAZO = @CodRechazo 
							WHERE NUMERO_DPF = @NumeroCheque_RI 
							AND BANCO_GIRADO = @Entidad_RI 
							AND SUCURSAL_BANCO_GIRADO = @Sucursal_RI
						END
						ELSE
						BEGIN
						 	INSERT INTO CLE_RECEPCION_DPF_DEV(NUMERO_DPF
						 										, BANCO_GIRADO
						 										, FECHA_ALTA
						 										, SUCURSAL_BANCO_GIRADO
						 										, TIPO_DOCUMENTO
						 										, IMPORTE_DPF
						 										, [CODIGO_CAMARA]
						 										, ESTADO_DEVOLUCION)
						 	VALUES (@NRO_DPF_CHEQUE
						 			, @BANCO_GIRADO
						 			, @FechaPresentacion
						 			, @SUCURSAL_BANCO
						 			, @TIPO_DOCUMENTO
						 			, @IMPORTE_TOTAL, 
						 			(SELECT [CODIGO_DE_CAMARA] FROM CLE_CAMARAS_COMPENSADORAS WITH (NOLOCK))
						 			, 1);
						END
				   		-- Insertamos en el historial
				   		INSERT INTO ITF_COELSA_SESION_RECHAZADOS(ID_TICKET
				   												, FECHA_ALTA
				   												, BANCO
				   												, SUCURSAL
				   												, CUENTA
				   												, IMPORTE
				   												, CODIGO_POSTAL
				   												, NRO_CHEQUE
				   												, PUNTO_INTERCAMBIO
				   												, TRACK_NUMBER
				   												, TIPO
				   												, MONEDA
				   												, TIPO_DOCUMENTO
				   												, ORDINAL
				   												, codigo_rechazo)
						VALUES(@TICKET
								, @FechaPresentacion
								, @BANCO_GIRADO
								, @SUCURSAL_BANCO
								, @NRO_CUENTA
								, @IMPORTE_TOTAL
								, @CODIGO_POSTAL
								, @NRO_DPF_CHEQUE
								, @PuntoIntercambio
								, @ContadorRegistros
								, ''C'',  @MONEDA
								, @TIPO_DOCUMENTO
								, @ORDINAL
								, @CodRechazo);

					END
					ELSE
					BEGIN
						SET @moneda=1
						-- Insertamos en el historial en caso de que no exista
						INSERT INTO ITF_COELSA_SESION_RECHAZADOS(ID_TICKET
																, FECHA_ALTA
																, BANCO
																, SUCURSAL
																, CUENTA
																, IMPORTE
																, CODIGO_POSTAL
																, NRO_CHEQUE
																, PUNTO_INTERCAMBIO
																, TRACK_NUMBER
																, TIPO
																, MONEDA
																, TIPO_DOCUMENTO
																, codigo_rechazo
																, serie_del_cheque)
						VALUES(@TICKET
								, @FechaPresentacion
								, CASE WHEN ISNUMERIC(@Entidad_RI) = 0 THEN -1 ELSE CAST(@Entidad_RI AS NUMERIC(4)) END 
								, CASE WHEN ISNUMERIC(@Sucursal_RI) = 0 THEN -1 ELSE CAST(@Sucursal_RI AS NUMERIC(5)) END
								, CASE WHEN ISNUMERIC(@NumeroCuenta_RI) = 0 THEN -1 ELSE CAST(@NumeroCuenta_RI AS NUMERIC(12)) END
								, @Importe
								, CASE WHEN ISNUMERIC(@CodigoPostal_RI) = 0 THEN -1 ELSE CAST(@CodigoPostal_RI AS NUMERIC(4)) END
								, CASE WHEN ISNUMERIC(@NumeroCheque_RI) = 0 THEN -1 ELSE CAST(@NumeroCheque_RI AS NUMERIC(12)) END 
								, @PuntoIntercambio
								, @ContadorRegistros
								, ''C''
								, @moneda
								, @TIPO_DOCUMENTO
								, @codRechazo
								, (CASE WHEN substring(@infoadicional,2,1) IN (''2'',''3'') THEN ''E'' ELSE '' '' END));			
					END
				END      	
				ELSE
				BEGIN

					IF(ISNUMERIC(@Entidad_RI) = 1 AND ISNUMERIC(@Sucursal_RI) = 1 AND ISNUMERIC(@CodigoPostal_RI) = 1 AND ISNUMERIC(@NumeroCheque_RI) = 1 AND ISNUMERIC(@NumeroCuenta_RI ) = 1 )
					BEGIN
						-- Consulta Cheque
						SELECT @EXISTE = 1
								, @NRO_DPF_CHEQUE = NRO_CHEQUE
								, @SERIE_DEL_CHEQUE = SERIE_DEL_CHEQUE
								, @BANCO_GIRADO = BANCO
								, @SUCURSAL_BANCO = SUCURSAL
								, @NRO_CUENTA = CUENTA
								, @TIPO_DOCUMENTO = TIPO_DOCUMENTO
								, @IMPORTE_TOTAL = IMPORTE
								, @CODIGO_POSTAL = CODIGO_POSTAL
								, @MONEDA = MONEDA
						FROM ITF_COELSA_CHEQUES_OTROS WITH(NOLOCK)
						WHERE @Entidad_RI = BANCO 
						AND @Sucursal_RI  = SUCURSAL 
						AND @CodigoPostal_RI = CODIGO_POSTAL 
						AND @NumeroCheque_RI = NRO_CHEQUE 
						AND @NumeroCuenta_RI = CUENTA;
					END

					IF @EXISTE > 0
					BEGIN
						-- Guardamos clave para update si hay reg adicional
						SET @Entidad_RI = @BANCO_GIRADO;
						SET @Sucursal_RI = @SUCURSAL_BANCO;
						SET @NumeroCuenta_RI = @NRO_CUENTA;
						SET @CodigoPostal_RI = @CODIGO_POSTAL;
						SET @NumeroCheque_RI = @NRO_DPF_CHEQUE;
						
						SET @updRecepcion = ''C''; --para saber si updatear el cod Rechazo de la tabla CLE RECEPCION_CHEQUES_DEV


--COMENTADO EL DIA 17/12/2024 PORQUE SE ESTAN INSERTANDO DUPLICADOS LOS REGISTROS EN CLE_RECEPCION_CHEQUES_DEV J.I.

--						INSERT INTO CLE_RECEPCION_CHEQUES_DEV(NUMERO_CHEQUE
--															--, SERIE_DEL_CHEQUE
--															, BANCO_GIRADO
--															, FECHA_ALTA
--															, SUCURSAL_BANCO_GIRADO
--															, NUMERO_CUENTA_GIRADORA
--															, TIPO_DOCUMENTO
--															, IMPORTE_CHEQUE
--															, ESTADO_DEVOLUCION
--															, CODIGO_CAMARA
--															, serie_del_cheque)
--						VALUES (@NRO_DPF_CHEQUE
--								--, @SERIE_DEL_CHEQUE
--								, @BANCO_GIRADO
--								--, @FechaPresentacion
--								, (select fechaproceso from parametros)
--								, @SUCURSAL_BANCO
--								, @NRO_CUENTA
--								, @TIPO_DOCUMENTO
--								, @IMPORTE_TOTAL
--								, 1
--								, (SELECT [CODIGO_DE_CAMARA] FROM CLE_CAMARAS_COMPENSADORAS WITH(NOLOCK))
--								, (CASE WHEN substring(@infoadicional,2,1) IN (''2'',''3'') THEN ''E'' ELSE '' '' END));
								
--HASTA ACA--

						-- Insertamos en el historial
						INSERT INTO ITF_COELSA_SESION_RECHAZADOS(ID_TICKET
																, FECHA_ALTA
																, BANCO
																, SUCURSAL
																, CUENTA
																, IMPORTE
																, CODIGO_POSTAL
																, NRO_CHEQUE
																, PUNTO_INTERCAMBIO
																, TRACK_NUMBER
																, TIPO
																, MONEDA
																, TIPO_DOCUMENTO
																--, SERIE_DEL_CHEQUE
																, Codigo_rechazo
																, serie_del_cheque)
						VALUES(@TICKET
							, @FechaPresentacion
							, @BANCO_GIRADO
							, @SUCURSAL_BANCO
							, @NRO_CUENTA
							, @IMPORTE_TOTAL
							, @CODIGO_POSTAL
							, @NRO_DPF_CHEQUE
							, @PuntoIntercambio
							, @ContadorRegistros
							, ''C''
							, @MONEDA
							, @TIPO_DOCUMENTO
							--, @SERIE_DEL_CHEQUE
							, @codRechazo
							, (CASE WHEN substring(@infoadicional,2,1) IN (''2'',''3'') THEN ''E'' ELSE '' '' END));
					
					
					
					END
					ELSE
					BEGIN
					  
						SET @moneda=1
							-- Insertamos en el historial en caso de que no exista
						INSERT INTO ITF_COELSA_SESION_RECHAZADOS(ID_TICKET
																, FECHA_ALTA
																, BANCO
																, SUCURSAL
																, CUENTA
																, IMPORTE
																, CODIGO_POSTAL
																, NRO_CHEQUE
																, PUNTO_INTERCAMBIO
																, TRACK_NUMBER
																, TIPO
																, MONEDA
																, TIPO_DOCUMENTO
																, codigo_rechazo
																, serie_del_cheque)
						VALUES(@TICKET
--							, @FechaPresentacion
							, (select fechaproceso from parametros)
							, CASE WHEN ISNUMERIC(@Entidad_RI) = 0 THEN -1 ELSE CAST(@Entidad_RI AS NUMERIC(4)) END ,
							CASE WHEN ISNUMERIC(@Sucursal_RI) = 0 THEN -1 ELSE CAST(@Sucursal_RI AS NUMERIC(5)) END, 
							CASE WHEN ISNUMERIC(@NumeroCuenta_RI) = 0 THEN -1 ELSE CAST(@NumeroCuenta_RI AS NUMERIC(12)) END, 
							@Importe, 
							CASE WHEN ISNUMERIC(@CodigoPostal_RI) = 0 THEN -1 ELSE CAST(@CodigoPostal_RI AS NUMERIC(4)) END, 
							CASE WHEN ISNUMERIC(@NumeroCheque_RI) = 0 THEN -1 ELSE CAST(@NumeroCheque_RI AS NUMERIC(12)) END ,
							@PuntoIntercambio, 
							@ContadorRegistros, 
							''C'',
							@moneda, 
							@TIPO_DOCUMENTO
							, @codRechazo
							, (CASE WHEN substring(@infoadicional,2,1) IN (''2'',''3'') THEN ''E'' ELSE '' '' END));
							

					END

				END

		--***Bloque nuevo 13/05/2024 JI***--
				IF (try_convert(numeric,@codRechazo) IS null)
				BEGIN
					PRINT @linea
					PRINT @codRechazo
					SELECT convert(NUMERIC(15,2),substring(@linea,30,10))/100,CAST(substring(@linea,13,17) AS NUMERIC),substring(@linea,40,2)
				END 
		--IF (@linea LIKE ''622%'')
		--BEGIN
		
				SELECT @CODCLI=c1803
						, @PRODUCTO=PRODUCTO
						, @ordinal=ordinal 
				FROM SALDOS 
				WHERE CUENTA = @NumeroCuenta_RI 
				AND SUCURSAL = TRIM(''0'' FROM RIGHT(@EntidadDebitar, 3)) 
				AND MONEDA = @MONEDA 
				AND C1785 = 2
		
		
		
--PRINT @linea

			
				SET @Entidad = CAST(LEFT( CAST(RIGHT(''0000'' + Ltrim(Rtrim(@EntidadDebitar)),8) AS VARCHAR ), 4) AS NUMERIC);
						---inserto en CLE_CHEQUES_CLEARING_RECH_DEV---
				IF (@codTransaccion=''22'')
					BEGIN TRY
					INSERT INTO dbo.CLE_CHEQUES_CLEARING_RECH_DEPOSITARIA
								(
								CLIENTE
								, MONEDA
								, ORDINAL_LISTA
								, PRODUCTO
								, NUMERO_BANCO
								, NUMERO_DEPENDENCIA
								, NUMERO_CHEQUE
								, IMPORTE
								, SERIE_CHEQUE
								, FECHA_VALOR
								, ESTADO
								, CUENTA
								, CAMARA_COMPENSADORA
								, CMC7
								, TRACKNUMBER
								, TZ_LOCK
								, CODIGO_CAUSAL_DEVOLUCION
								)
					VALUES
								(
								@CODCLI
								, @MONEDA
								, @ORDINAL
								, @PRODUCTO
								, @Entidad_RI 
								, @Sucursal_RI
								, @NumeroCheque
	--s							, convert(NUMERIC(15,2),substring(@linea,30,10))/100
								,@Importe
								, (CASE WHEN substring(@infoadicional,2,1) IN (''2'',''3'') THEN ''E'' ELSE '' '' END)
	--							, @FechaPresentacion
								, @FechaPresentacion--(select fechaproceso from parametros)
								, ''0'' 
								, CAST(substring(@linea,13,17) AS NUMERIC)
								, 1
								, (SELECT CONCAT( @Entidad, RIGHT(@EntidadDebitar, 3),RIGHT(@CodigoPostal,4),RIGHT(CONCAT(REPLICATE(''0'',8),RIGHT(@NumeroCheque, 8)),8), RIGHT(CONCAT(''00000000000'',RIGHT(@CuentaDebitar,11)),11) ))         										
								, @ContadorRegistros
								, 0
								, @codRechazo
								)
					END TRY 
				
					BEGIN CATCH
					END CATCH
								---***---
			
-- PRINT @NumeroCheque
				IF (@codTransaccion=''26'')
					BEGIN
						--PRINT ''Num CHEQUE: '' + @NumeroCheque + '' Banco Girado: '' + @Entidad_RI + '' Suc Banco Girado: '' + @Sucursal_RI + '' Num Cta Gir: '' + SUBSTRING(@linea, 13, 17)
						IF (SELECT COUNT(1) 
							FROM CLE_RECEPCION_CHEQUES_DEV 
							WHERE NUMERO_CHEQUE = @NumeroCheque
							  -- AND SERIE_DEL_CHEQUE = @SERIE_DEL_CHEQUE
							  AND BANCO_GIRADO = @Entidad_RI 
							  AND FECHA_ALTA = (SELECT fechaproceso FROM PARAMETROS)--@FechaPresentacion
							  AND SUCURSAL_BANCO_GIRADO = @Sucursal_RI
							  AND NUMERO_CUENTA_GIRADORA = CAST(SUBSTRING(@linea, 13, 17) AS NUMERIC)
						   ) > 0
						   
						BEGIN
							-- PRINT ''existe'' -- REVISAR CLE PREVALENCIA CAUSAL

							-- Obtener el código de rechazo original
							SELECT @codRechazoOri = CODIGO_RECHAZO
							FROM CLE_RECEPCION_CHEQUES_DEV
							WHERE NUMERO_CHEQUE = @NumeroCheque
							  --AND SERIE_DEL_CHEQUE = @SERIE_DEL_CHEQUE
							  AND BANCO_GIRADO = @Entidad_RI 
							  AND FECHA_ALTA = (SELECT fechaproceso FROM PARAMETROS)--@FechaPresentacion
							  AND SUCURSAL_BANCO_GIRADO = @Sucursal_RI
							  AND NUMERO_CUENTA_GIRADORA = CAST(SUBSTRING(@linea, 13, 17) AS NUMERIC);
							  --AND TIPO_DOCUMENTO = SUBSTRING(@linea, 40, 2);
							
							--PRINT Concat(''Cod rechazo original: '', IsNull(Cast(@codRechazoOri as varchar),0))
							
							-- Determinar el código de rechazo basado en la prevalencia causal
							SELECT @codrechazo = ISNULL(RIGHT(causal_prevaleciente, 2), @codRechazo)
							FROM CLE_PREVALENCIA_CAUSAL 
							WHERE CAUSAL_DEPOSITARIA = ''R'' + @codRechazoOri
							  AND CAUSAL_GIRADA = ''R'' + @codRechazo 
							  AND TZ_LOCK = 0;
							
							--PRINT ''Codigo Rechazo: '' + @codrechazo
							
							-- Actualizar el código de rechazo en la tabla de recepción de cheques devueltos
							UPDATE CLE_RECEPCION_CHEQUES_DEV
							SET CODIGO_RECHAZO = TRY_CONVERT(NUMERIC(3), @codRechazo)
							WHERE NUMERO_CHEQUE = @NumeroCheque
							  --AND SERIE_DEL_CHEQUE = @SERIE_DEL_CHEQUE
							  AND BANCO_GIRADO = @Entidad_RI
							  AND FECHA_ALTA = (SELECT fechaproceso FROM PARAMETROS)--@FechaPresentacion
							  AND SUCURSAL_BANCO_GIRADO = @Sucursal_RI
							  AND NUMERO_CUENTA_GIRADORA = CAST(SUBSTRING(@linea, 13, 17) AS NUMERIC);
							  --AND TIPO_DOCUMENTO = SUBSTRING(@linea, 40, 2);
						END

						ELSE
						BEGIN
			
		--			PRINT @NRO_CUENTA
		--PRINT @Entidad_RI
							INSERT INTO dbo.CLE_RECEPCION_CHEQUES_DEV
								(
								BANCO_GIRADO --num 4
								, SUCURSAL_BANCO_GIRADO --num 5
								, SERIE_DEL_CHEQUE --var 6
								, IMPORTE_CHEQUE  --num 15,2
								, CODIGO_RECHAZO --num 3
								, NUMERO_CHEQUE --num 12
								, ESTADO_DEVOLUCION --num 1
								, CODIGO_CAMARA  --num  4
								, TIPO_DOCUMENTO --var
								, FECHA_ALTA  --date
								, NUMERO_CUENTA_GIRADORA  --num
								, TZ_LOCK
								)
							VALUES
								(
								@Entidad_RI
								, @Sucursal_RI
								, (CASE WHEN substring(@infoadicional,2,1) IN (''2'',''3'') THEN ''E'' ELSE '' '' END)
		--s						, convert(NUMERIC(15,2),substring(@linea,30,10))/100
								,@Importe
								, try_convert(numeric,@codRechazo)
								, @NumeroCheque
								, 1
								, (SELECT TOP 1 CODIGO_DE_CAMARA FROM CLE_CAMARAS_COMPENSADORAS WITH(NOLOCK))
								, substring(@linea,40,2)
		-- 						, @FechaPresentacion
								, (select fechaproceso from parametros)
								, CAST(substring(@linea,13,17) AS NUMERIC)
								, 0
								)
						END 
				END 


			--***FIN***--
		
		
		
		
		
		
		
    -- Insertar en la tabla RRII_CHE_RECHAZADOS
    


				BEGIN TRY
					INSERT INTO dbo.RRII_CHE_RECHAZADOS (COD_ENTIDAD, 
									 NRO_SUCURSAL, 
									 CUENTA, 
									 NRO_CHEQUE, 
									 AVISO, 
									 COD_MOVIMIENTO, 
									 CLASE_REGISTRO, 
									 FECHA_NOTIF_O_DENUNCIA, 
									 MONEDA, 
									 IMPORTE, 
									 FECHA_RECHAZO_O_PRES_COBRO, 
									 FECHA_REGISTRACION, 
									 PLAZO_DIFERIMIENTO, 
									 FECHA_PAGO_CHEQUE, 
									 FECHA_PAGO_MULTA, 
									 FECHA_CIERRE_CTA, 
									 FECHA_REGISTRO_NOVEDAD, 
									 TZ_LOCK)
					SELECT 311, 
						TRIM(''0'' FROM RIGHT(@EntidadDebitar, 3)), 
	   					@NumeroCuenta_RI, 
	   					@NumeroCheque_RI,
	   					CONCAT(@Entidad_RI, @Sucursal_RI), 
						''A'', 
						1
--						, @FechaPresentacion
						, (select fechaproceso from parametros)
						, @MONEDA,  
						@IMPORTE, 
						@FechaPresentacion, 
						(SELECT fechaproceso	FROM PARAMETROS), 
						NULL, 
						NULL, 
						NULL, 
						NULL,  
						(SELECT fechaproceso FROM PARAMETROS), 
						0;
		


		--agregamos los numeros de documento de los titulares y cotitulares		



				-- Crear una tabla temporal para almacenar los valores a actualizar
					CREATE TABLE #TempUpdate (
    							PRIMER_NRO_IDENTIFICATORIO NUMERIC(11, 0),
    							SEGUNDO_NRO_IDENTIFICATORIO NUMERIC(11, 0),
    							TERCER_NRO_IDENTIFICATORIO NUMERIC(11, 0),
    							CUARTO_NRO_IDENTIFICATORIO NUMERIC(11, 0),
    							QUINTO_NRO_IDENTIFICATORIO NUMERIC(11, 0),
    							SEXTO_NRO_IDENTIFICATORIO NUMERIC(11, 0),
    							SEPTIMO_NRO_IDENTIFICATORIO NUMERIC(11, 0),
    							OCTAVO_NRO_IDENTIFICATORIO NUMERIC(11, 0),
    							NOVENO_NRO_IDENTIFICATORIO NUMERIC(11, 0),
    							DECIMO_NRO_IDENTIFICATORIO NUMERIC(11, 0)
								);

					-- Insertar los valores condicionalmente en la tabla temporal
					INSERT INTO #TempUpdate (PRIMER_NRO_IDENTIFICATORIO, SEGUNDO_NRO_IDENTIFICATORIO, TERCER_NRO_IDENTIFICATORIO, CUARTO_NRO_IDENTIFICATORIO, QUINTO_NRO_IDENTIFICATORIO, SEXTO_NRO_IDENTIFICATORIO, SEPTIMO_NRO_IDENTIFICATORIO, OCTAVO_NRO_IDENTIFICATORIO, NOVENO_NRO_IDENTIFICATORIO, DECIMO_NRO_IDENTIFICATORIO)
					SELECT
    					MAX(CASE WHEN RN = 1 THEN CAST(RTRIM([NUMERO DE DOCUMENTO]) AS NUMERIC(11, 0)) END),
    					MAX(CASE WHEN RN = 2 THEN CAST(RTRIM([NUMERO DE DOCUMENTO]) AS NUMERIC(11, 0)) END),
    					MAX(CASE WHEN RN = 3 THEN CAST(RTRIM([NUMERO DE DOCUMENTO]) AS NUMERIC(11, 0)) END),
    					MAX(CASE WHEN RN = 4 THEN CAST(RTRIM([NUMERO DE DOCUMENTO]) AS NUMERIC(11, 0)) END),
    					MAX(CASE WHEN RN = 5 THEN CAST(RTRIM([NUMERO DE DOCUMENTO]) AS NUMERIC(11, 0)) END),
    					MAX(CASE WHEN RN = 6 THEN CAST(RTRIM([NUMERO DE DOCUMENTO]) AS NUMERIC(11, 0)) END),
    					MAX(CASE WHEN RN = 7 THEN CAST(RTRIM([NUMERO DE DOCUMENTO]) AS NUMERIC(11, 0)) END),
    					MAX(CASE WHEN RN = 8 THEN CAST(RTRIM([NUMERO DE DOCUMENTO]) AS NUMERIC(11, 0)) END),
    					MAX(CASE WHEN RN = 9 THEN CAST(RTRIM([NUMERO DE DOCUMENTO]) AS NUMERIC(11, 0)) END),
    					MAX(CASE WHEN RN = 10 THEN CAST(RTRIM([NUMERO DE DOCUMENTO]) AS NUMERIC(11, 0)) END)
					FROM (
    					SELECT
        						[Codigo de Cliente],
        						[Numero de Documento],
        						[Titularidad],
        						ROW_NUMBER() OVER (PARTITION BY [Codigo de Cliente] ORDER BY CASE WHEN [Titularidad] = ''T'' THEN 0 ELSE 1 END, [Numero de Documento]) AS RN
    					FROM VW_CLI_PERSONAS
    					WHERE [Codigo de Cliente] = (
													SELECT c1803 
													FROM SALDOS 
													WHERE CUENTA = @NumeroCuenta_RI 
													AND SUCURSAL = TRIM(''0'' FROM RIGHT(@EntidadDebitar, 3)) 
													AND MONEDA = @MONEDA 
													AND C1785 = 2
    												) 
							) Subquery;

					-- Realizar la actualización utilizando la tabla temporal
					UPDATE RRII_CHE_RECHAZADOS
					SET
    					PRIMER_NRO_IDENTIFICATORIO = #TempUpdate.PRIMER_NRO_IDENTIFICATORIO,
    					SEGUNDO_NRO_IDENTIFICATORIO = #TempUpdate.SEGUNDO_NRO_IDENTIFICATORIO,
    					TERCER_NRO_IDENTIFICATORIO = #TempUpdate.TERCER_NRO_IDENTIFICATORIO,
    					CUARTO_NRO_IDENTIFICATORIO = #TempUpdate.CUARTO_NRO_IDENTIFICATORIO,
    					QUINTO_NRO_IDENTIFICATORIO = #TempUpdate.QUINTO_NRO_IDENTIFICATORIO,
    					SEXTO_NRO_IDENTIFICATORIO = #TempUpdate.SEXTO_NRO_IDENTIFICATORIO,
    					SEPTIMO_NRO_IDENTIFICATORIO = #TempUpdate.SEPTIMO_NRO_IDENTIFICATORIO,
    					OCTAVO_NRO_IDENTIFICATORIO = #TempUpdate.OCTAVO_NRO_IDENTIFICATORIO,
    					NOVENO_NRO_IDENTIFICATORIO = #TempUpdate.NOVENO_NRO_IDENTIFICATORIO,
    					DECIMO_NRO_IDENTIFICATORIO = #TempUpdate.DECIMO_NRO_IDENTIFICATORIO
					FROM #TempUpdate
					WHERE cod_entidad = 311
    				AND Nro_sucursal = TRIM(''0'' FROM RIGHT(@EntidadDebitar, 3))
    				AND cuenta = @NumeroCuenta_RI
    				AND nro_cheque = @NumeroCheque_RI
    				AND fecha_registro_novedad = (SELECT fechaproceso FROM PARAMETROS);

					-- Eliminar la tabla temporal
					DROP TABLE #TempUpdate;


				END	TRY
				BEGIN CATCH
	PRINT ''No se pudo insertar en tabla RRII_CHE_RECHAZADOS''
				END CATCH	
			END
		END --end RI id = 6
		FETCH NEXT FROM che_cursor INTO @id,@LINEA
	END

	CLOSE che_cursor
	DEALLOCATE che_cursor

	--- Actualizar el estado de los ajustes no incluidos en el plano -------------------------------------------------------------
	UPDATE dbo.CLE_CHEQUES_AJUSTE 
	SET ESTADO_AJUSTE = ''A'' 
	WHERE ESTADO_AJUSTE IS NULL 
	AND ESTADO = ''P'' 
	AND FECHA_ACREDITACION = (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK));
------------------------------------------------------------------------------------------------------------------------------

END')

EXECUTE('
DROP TABLE IF EXISTS dbo.ITF_RP_SECHEEP_AUX;

CREATE TABLE dbo.ITF_RP_SECHEEP_AUX
	(
	convpadre     INT NOT NULL,
	nombrearchivo VARCHAR(100) NOT NULL,
	canal         INT NOT NULL,
	codigoempresa INT NOT NULL,
	fechacarga    VARCHAR (10) NOT NULL,
	totcobranzas  INT NULL,
	totimporte    NUMERIC (15, 2) NULL,
	CONSTRAINT SECHPK PRIMARY KEY (convpadre, nombrearchivo, canal, codigoempresa, fechacarga)
	)
')
