EXEC('
DROP TABLE dbo.ITF_TLF_POS_HISTORICO;

CREATE TABLE dbo.ITF_TLF_POS_HISTORICO (
    FECHA_NEGOCIO DATETIME NOT NULL,
	FECHA_RELOJ DATETIME NOT NULL,
	ARCHIVO VARCHAR(50) COLLATE Modern_Spanish_CI_AS NOT NULL,
	LKBYTE varchar(6) COLLATE Modern_Spanish_CI_AS NULL,
	LKPREF varchar(8) COLLATE Modern_Spanish_CI_AS NULL,
	LKDATT varchar(19) COLLATE Modern_Spanish_CI_AS NULL,
	LKRECT varchar(2) COLLATE Modern_Spanish_CI_AS NULL,
	LKAUTP varchar(4) COLLATE Modern_Spanish_CI_AS NULL,
	LKLNAT varchar(4) COLLATE Modern_Spanish_CI_AS NULL,
	LKFIIA varchar(4) COLLATE Modern_Spanish_CI_AS NULL,
	LKTERM varchar(16) COLLATE Modern_Spanish_CI_AS NOT NULL,
	LKLNCA varchar(4) COLLATE Modern_Spanish_CI_AS NULL,
	LKFIIC varchar(4) COLLATE Modern_Spanish_CI_AS NULL,
	LKPANC varchar(28) COLLATE Modern_Spanish_CI_AS NULL,
	LKMBRN numeric(3,0) DEFAULT 0 NULL,
	LKBRCH varchar(4) COLLATE Modern_Spanish_CI_AS NULL,
	LKREGN varchar(4) COLLATE Modern_Spanish_CI_AS NULL,
	LKUSER varchar(2) COLLATE Modern_Spanish_CI_AS NULL,
	LKTYPC varchar(2) COLLATE Modern_Spanish_CI_AS NULL,
	LKTYP numeric(4,0) DEFAULT 0 NULL,
	LKRTES numeric(2,0) DEFAULT 0 NULL,
	LKFI01 varchar(59) COLLATE Modern_Spanish_CI_AS NULL,
	LKTRAD varchar(6) COLLATE Modern_Spanish_CI_AS NOT NULL,
	LKTRAT varchar(8) COLLATE Modern_Spanish_CI_AS NOT NULL,
	LKPOST varchar(6) COLLATE Modern_Spanish_CI_AS NULL,
	LKFI02 varchar(12) COLLATE Modern_Spanish_CI_AS NULL,
	LKSEQN varchar(12) COLLATE Modern_Spanish_CI_AS NOT NULL,
	LKTERT varchar(2) COLLATE Modern_Spanish_CI_AS NULL,
	LKFI03 varchar(27) COLLATE Modern_Spanish_CI_AS NULL,
	LKTCDE varchar(2) COLLATE Modern_Spanish_CI_AS NULL,
	LKTFRO varchar(2) COLLATE Modern_Spanish_CI_AS NULL,
	LKTTO varchar(2) COLLATE Modern_Spanish_CI_AS NULL,
	LKFROM varchar(28) COLLATE Modern_Spanish_CI_AS NULL,
	LKFI04 varchar(1) COLLATE Modern_Spanish_CI_AS NULL,
	LKTOAC varchar(28) COLLATE Modern_Spanish_CI_AS NULL,
	LKFI05 varchar(1) COLLATE Modern_Spanish_CI_AS NULL,
	LKAMT1 numeric(19,2) DEFAULT 0 NULL,
	LKAMT2 numeric(19,2) DEFAULT 0 NULL,
	LKAMT3 numeric(19,2) DEFAULT 0 NULL,
	LKFI08 varchar(11) COLLATE Modern_Spanish_CI_AS NULL,
	LKRES1 varchar(1) COLLATE Modern_Spanish_CI_AS NULL,
	LKRES2 varchar(2) COLLATE Modern_Spanish_CI_AS NULL,
	LKNOMB varchar(25) COLLATE Modern_Spanish_CI_AS NULL,
	LKFI10 varchar(38) COLLATE Modern_Spanish_CI_AS NULL,
	LKTERC varchar(2) COLLATE Modern_Spanish_CI_AS NULL,
	LKFI11 varchar(28) COLLATE Modern_Spanish_CI_AS NULL,
	LKORIG numeric(3,0) DEFAULT 0 NULL,
	LKDATO varchar(22) COLLATE Modern_Spanish_CI_AS NULL,
	LKTIPV numeric(8,3) DEFAULT 0 NULL,
	LKFI14 varchar(11) COLLATE Modern_Spanish_CI_AS NULL,
	LKRVSL numeric(2,0) DEFAULT 0 NULL,
	LKPIN varchar(16) COLLATE Modern_Spanish_CI_AS NULL,
	LKFILL varchar(72) COLLATE Modern_Spanish_CI_AS NULL,
	LKTIPD varchar(1) COLLATE Modern_Spanish_CI_AS NULL,
	LKISSU varchar(4) COLLATE Modern_Spanish_CI_AS NULL,
	LKINTE numeric(6,2) DEFAULT 0 NULL,
	LKCASH numeric(8,2) DEFAULT 0 NULL,
	LKFI15 varchar(250) COLLATE Modern_Spanish_CI_AS NULL,
	LKFI16 varchar(25) COLLATE Modern_Spanish_CI_AS NULL,
	ID_TICKET numeric(15,0) DEFAULT 0 NOT NULL,
	ORDINAL numeric(10,0) NOT NULL,
	FECHAREGISTRO datetime NULL
	PRIMARY KEY (FECHA_NEGOCIO, ARCHIVO, LKTRAD, LKTRAT, LKSEQN, LKTERM, ORDINAL)
);
');

EXEC('
CREATE OR ALTER  PROCEDURE [dbo].[SP_PROCESO_TJD_SOLICITUD_LINK_VINCULACION]
    @jts_oid NUMERIC(10,0),
    @idPersona NUMERIC(12,0),
    @accion VARCHAR(1),
    @asientoFecha DATE,
    @asientoSucursal NUMERIC(10,0),
    @asientoNumero NUMERIC(10,0),
    @operacion NUMERIC(4,0),
    @usuario VARCHAR(10),
    @hora VARCHAR(8),
    @codigo NUMERIC(1) OUTPUT, 
    @descripcion VARCHAR(150) OUTPUT
AS
BEGIN
    SET XACT_ABORT ON;
    BEGIN TRANSACTION;
    BEGIN TRY

        -- DECLARACIÓN DE VARIABLES
        DECLARE 
            --solicitudes
            @idSolicitud NUMERIC(15,0),
            @tipoSolicitud VARCHAR(10),
            @estado VARCHAR(1),
            @fechaSolicitud DATETIME,
            @tipoDocumento VARCHAR(3),
            @nroDocumento VARCHAR(20),
            @nroTarjetaBase NUMERIC(19,0),
            @nroTarjetaCompleta VARCHAR(19),
            @apellido VARCHAR(30),
            @nombre VARCHAR(30),
            @sexo VARCHAR(1),
            @estadoCivil VARCHAR(1),
            @fechaNac DATETIME,
            @cuil NUMERIC(11,0),
            @prefijo NUMERIC(11,0),
            @sucursalCtaPrimaria NUMERIC(5,0),
            @nroCtaPrimaria VARCHAR(19),
            @tipoCtaPrimaria NUMERIC(2,0),
            @limiteDebito VARCHAR(2),
            @limiteCredito VARCHAR(2),
            @producto VARCHAR(4),
            @codProductoTarjeta VARCHAR(4),
            @codCliente NUMERIC(12,0),
            @nroAuditoria VARCHAR(22),
            @tipoDomicilio VARCHAR(1),
            @datosAdicionales VARCHAR(1),
            @tipoTarjeta VARCHAR(3),
            -- direcciones
            @direccionTipo VARCHAR(1),
            @direccionCalle VARCHAR(50),
            @direccionNumero NUMERIC(8,0),
            @direccionPiso NUMERIC(8,0),
            @direccionDepartamento NUMERIC(3,0),
            @direccionLocalidad NUMERIC(3,0),
            @direccionCodigoPostal VARCHAR(15),
            @direccionProvincia VARCHAR(2),
            @direccionTelefono VARCHAR(17),
            @direccionDescripcionLocalidad VARCHAR(60),
            --cuentas
            @cuentaPbf VARCHAR(19),
            @cuentaEstado VARCHAR(10),
            @cuentaNumeroTarjeta VARCHAR(19),
            @cuentaOrden NUMERIC(5,0),
            @cuentaTipo NUMERIC(2,0),
            @cuentaSucursal NUMERIC(5,0),
            @cuentaNumeroCuenta NUMERIC(15,0),
            @cuentaMoneda NUMERIC(4,0),
            --Solicitudes
            @vectorCuentasCantidad NUMERIC(15,0),
            @solicitudActivaId NUMERIC(15,0),
            @existeCuentaEnVector NUMERIC(1,0),
            @existeCuentaEnSolicitud NUMERIC(1,0);

        -- Insertar en la tabla temporal
        DECLARE  @TempCuentas TABLE(
            ORDEN_CUENTA NUMERIC(5,0),
            TIPO_CUENTA NUMERIC(2,0),
            SUCURSAL NUMERIC(5,0),
            NRO_CUENTA NUMERIC(15,0),
            ESTADO_CUENTA VARCHAR(10),
            NRO_TARJETA VARCHAR(19),
            NUMERO_CUENTA_PBF VARCHAR(19)
        );

        ---------------------------------------------------------------------------
        -- OBTENER SET DE DATOS
        ---------------------------------------------------------------------------
        
        -- Busco tarjeta existente para vincularla con la tarjeta
        IF NOT EXISTS (SELECT TOP 1 1 from TJD_TARJETAS t inner join TJD_TIPO_TARJETA tt on t.TIPO_TARJETA=tt.TIPO_TARJETA
                    where tt.CLASE=1 and t.NRO_PERSONA=@idPersona and ESTADO in (''0'', ''1'') )
        BEGIN
            SET @codigo = 1;
            SET @descripcion = ''No se encontró tarjeta para asociar'';
            ROLLBACK TRANSACTION;
            RETURN;
        END
        ELSE
        BEGIN
            SELECT TOP 1 
                @TipoSolicitud = 130002, 
                @Estado = ''I'', 
                @FechaSolicitud = @asientoFecha, 
                @TipoDocumento = d.TIPO_DOC_FISICO, 
  @NroDocumento = d.NUM_DOC_FISICO, 
                @NroTarjetaBase = t.ID_TARJETA_BASE, 
                @NroTarjetaCompleta = t.ID_TARJETA, 
                @Apellido = CONCAT(p.APELLIDOPATERNO, p.APELLIDOMATERNO), 
                @Nombre = CONCAT(p.PRIMERNOMBRE, p.SEGUNDONOMBRE), 
                @Sexo = p.SEXO, 
                @EstadoCivil = p.ESTADOCIVIL, 
                @FechaNac = p.FECHANACIMIENTO, 
                @Cuil = d.NUMERODOCUMENTO, 
                @Prefijo = tj.BIN, 
                @SucursalCtaPrimaria = tr.SUCURSAL, 
                @NroCtaPrimaria = tr.CUENTA, 
                @TipoCtaPrimaria = tr.TIPO_CUENTA, 
                @LimiteDebito = t.LIMITE_DEBITO, 
                @LimiteCredito = t.LIMITE_CREDITO, 
                @Producto = tj.TIPO_TARJETA, 
                @CodProductoTarjeta = tj.CODIGO_PRODUCTO, 
                @CodCliente = t.NRO_CLIENTE,
                @tipoDomicilio = ''P'',
                @datosAdicionales = ''N'',
                @tipoTarjeta = t.PERMISO
            FROM TJD_TARJETAS  (NOLOCK) t 
            INNER JOIN TJD_TIPO_TARJETA  (NOLOCK) tj ON tj.TIPO_TARJETA = t.TIPO_TARJETA AND tj.TZ_LOCK = 0 AND tj.CLASE = 1
            INNER JOIN TJD_REL_TARJETA_CUENTA  (NOLOCK) tr ON tr.ID_TARJETA = t.ID_TARJETA AND tr.PRIORITARIA = 1 AND tr.TZ_LOCK = 0
            INNER JOIN CLI_PERSONASFISICAS  (NOLOCK) p ON p.NUMEROPERSONAFISICA = t.NRO_PERSONA AND p.TZ_LOCK = 0
            INNER JOIN CLI_DocumentosPFPJ  (NOLOCK) d ON d.NUMEROPERSONAFJ = p.NUMEROPERSONAFISICA AND d.TIPOPERSONA = ''F'' AND d.TZ_LOCK = 0
            WHERE t.NRO_PERSONA=@idPersona AND tj.CLASE = 1 AND t.ESTADO IN (''0'', ''1'')
            ORDER BY VENCIMIENTO DESC;

            --domicilio
            SELECT TOP 1                    
                @direccionTipo = ''P'',
                @direccionCalle = dir.CALLE, 
                @direccionNumero = dir.NUMERO,
                @direccionPiso = dir.PISO,
                @direccionDepartamento = dir.DEPARTAMENTO,
                @direccionLocalidad = dir.LOCALIDAD,
                @direccionCodigoPostal = dir.CPA_NUEVO,
                @direccionProvincia = dir.PROVINCIA,
                @direccionTelefono = ct.NUMERO,
                @direccionDescripcionLocalidad = cl.DESCRIPCION_DIM3
            FROM CLI_DIRECCIONES (NOLOCK) dir
            inner join CLI_PAISES  (NOLOCK) cpa on cpa.CODIGOPAIS = dir.PAIS AND cpa.TZ_LOCK = 0
            inner join CLI_PROVINCIAS  (NOLOCK) cp on cp.CODIGOPAIS = dir.PAIS and cp.DIM1 = dir.PROVINCIA AND cp.TZ_LOCK = 0
            inner join CLI_DEPARTAMENTOS  (NOLOCK) cde on cde.CODIGOPAIS = dir.PAIS and cde.DEPARTAMENTO = dir.DEPARTAMENTO and cde.PROVINCIA = dir.PROVINCIA AND cde.TZ_LOCK = 0
            inner join CLI_LOCALIDADES  (NOLOCK) cl on cl.CODIGOPAIS = dir.PAIS and cl.DIM1 = dir.PROVINCIA and cl.DIM2 = dir.DEPARTAMENTO and cl.DIM3 = dir.LOCALIDAD and cl.CODIGO_POSTAL = dir.CPA_VIEJO AND cl.TZ_LOCK=0
            INNER JOIN CLI_TELEFONOS  (NOLOCK) ct ON ct.ID = dir.ID AND ct.FORMATO = ''PF'' 
            WHERE dir.ID = @idPersona AND dir.TZ_LOCK = 0
            
            -- Grabar vector de cuentas existente
            INSERT INTO @TempCuentas (ORDEN_CUENTA, NRO_TARJETA, TIPO_CUENTA, SUCURSAL, NRO_CUENTA, ESTADO_CUENTA, NUMERO_CUENTA_PBF)
                SELECT
                    ROW_NUMBER() OVER (ORDER BY ID_TARJETA),
                    ID_TARJETA, TIPO_CUENTA, SUCURSAL, Cuenta, ESTADO, CUENTA_PBF
                FROM TJD_REL_TARJETA_CUENTA
                WHERE ID_TARJETA = @NroTarjetaCompleta
            
            -- Obtener datos del Saldo
            SELECT
                @cuentaTipo = TRY_CONVERT(NUMERIC(2,0),p.ALFA_2),
                @cuentaSucursal = SUCURSAL,
                @cuentaNumeroCuenta = CUENTA,
                @cuentaPbf = SUBSTRING(vs.CTA_REDLINK, 3, 19),
                @cuentaMoneda = s.MONEDA
            FROM SALDOS (NOLOCK) s
            INNER JOIN VTA_SALDOS vs ON vs.JTS_OID_SALDO = s.JTS_OID and vs.TZ_LOCK = 0
            INNER JOIN ITF_MASTER_PARAMETROS p on CODIGO_INTERFACE = 9 and NUMERICO_1 = s.C1785 and NUMERICO_2 = s.MONEDA
            WHERE s.JTS_OID = @jts_oid

            -- Construir Número de auditoria
            SELECT 
                @nroAuditoria = CONCAT(
                    g.ALFA,
                    FORMAT(p.FECHAPROCESO, ''yyyyMMdd''),
                    FORMAT(GETDATE(), ''HHmmss'')
                )
            FROM parametrosgenerales (NOLOCK) g, parametros (NOLOCK) p
            WHERE g.codigo = 705;

            -- Obtener ID de la solicitud activa
            SET @solicitudActivaId = (
                SELECT MAX(ID_SOLICITUD)  
                FROM TJD_SOLICITUD_LINK  
                WHERE NRO_TARJETA_COMPLETA = @nroTarjetaCompleta  
                AND TIPO_SOLICITUD = @tipoSolicitud  
                AND ESTADO = ''I''
            );

            -- Contar cuentas ACTIVAS del vector de cuentas
            SET @vectorCuentasCantidad = (SELECT COUNT(1) FROM @TempCuentas WHERE ESTADO_CUENTA = ''1'');

            -- Calcular banderas
            SET @existeCuentaEnVector = CASE
                WHEN EXISTS (
                    SELECT 1 FROM @TempCuentas 
                    WHERE SUCURSAL = @cuentaSucursal  
                    AND NRO_CUENTA = @cuentaNumeroCuenta  
                    AND NRO_TARJETA = @nroTarjetaCompleta  
                )
                THEN 1 
                ELSE 0
            END;
            
            SET @existeCuentaEnSolicitud = CASE  
                WHEN @solicitudActivaId IS NOT NULL  
                AND EXISTS (  
                    SELECT 1 FROM TJD_SOLICITUD_CUENTAS_LINK  
                    WHERE SUCURSAL = @cuentaSucursal  
                    AND NRO_CUENTA = @cuentaNumeroCuenta  
                    AND NRO_TARJETA = @nroTarjetaCompleta  
                    AND ID_SOLICITUD = @solicitudActivaId  
                )  
                THEN 1  
                ELSE 0  
            END;
            
            -- Calcular estado según acción
            SET @cuentaEstado = (CASE WHEN @accion=''A'' THEN 1 ELSE ''9'' END);

            ----------------------------------------------------------------------------------------------------
            -- Grabar SOLICITUDES: BAJAS
            ----------------------------------------------------------------------------------------------------
            IF (@accion = ''B'')
            BEGIN
                IF (@existeCuentaEnVector = 0)
                BEGIN
                    -- Marcar baja en solicitud activa
                    IF (@existeCuentaEnSolicitud = 1)
                    BEGIN
                        UPDATE TJD_SOLICITUD_CUENTAS_LINK
                        SET ESTADO_CUENTA = @cuentaEstado
                        WHERE SUCURSAL = @cuentaSucursal AND NRO_CUENTA = @cuentaNumeroCuenta AND NRO_TARJETA = @nroTarjetaCompleta AND ID_SOLICITUD = @solicitudActivaId;
                    END;
                    -- Si la cuenta no existe en el vector retorna con error
                    SET @codigo = 1;
                    SET @descripcion = ''Cuenta a dar de baja no existe en vector de cuentas.'';
                    --ROLLBACK TRANSACTION;
                    COMMIT TRANSACTION;   
                    RETURN;
                END;
               
                -- EXISTE CUENTA EN VECTOR DE CUENTAS
                IF (@existeCuentaEnVector = 1)
                BEGIN
                    IF (@solicitudActivaId IS NOT NULL)
                    BEGIN
                        IF (@vectorCuentasCantidad = 1 AND @existeCuentaEnSolicitud = 1)
                        BEGIN
                            -- NUMERADOR TOPAZ #35147
                            EXEC SP_GET_NUMERADOR_TOPAZ @vNumerador = 35147, @v_result = @idSolicitud OUTPUT;
  IF @idSolicitud IS NULL
                            BEGIN
                                SET @codigo = 2;
                                SET @descripcion = ''Error al generar Numerador ID_SOLICITUD'';
                                ROLLBACK TRANSACTION;
                                RETURN;
                            END;

                            SET @solicitudActivaId = @idSolicitud;

                            -- Insertar en la tabla TJD_SOLICITUD_LINK (BAJA)
                            INSERT INTO dbo.TJD_SOLICITUD_LINK (
                                ID_SOLICITUD, TIPO_SOLICITUD, ESTADO, FECHA_SOLICITUD,
                                USUARIO_SOLICITUD, HORA_SOLICITUD, SUCURSAL_SOLICITUD, 
                                ASIENTO, TIPO_DOCUMENTO, NRO_DOCUMENTO, NRO_TARJETA_BASE, NRO_TARJETA_COMPLETA,
                                APELLIDO, NOMBRE, SEXO, ESTADO_CIVIL, FECHA_NAC,
                                CUIL, PREFIJO, SUCURSAL_CTA_PRIMARIA, NRO_CTA_PRIMARIA, TIPO_CTA_PRIMARIA,
                                LIMITE_DEBITO, PRODUCTO, COD_PRODUCTO_TARJETA, COD_CLIENTE, NRO_PERSONA,
                                NRO_AUDITORIA, TIPO_DOMICILIO, DATOS_ADICIONALES, TIPO_TARJETA, AUTORIZADA, MONEDA_CUENTA
                            ) VALUES (
                                @idSolicitud, ''210002'', @estado, @fechaSolicitud,
                                @usuario, @hora, @asientoSucursal, @asientoNumero,
                                @tipoDocumento, @nroDocumento, @nroTarjetaBase, @nroTarjetaCompleta,
                                @apellido, @nombre, @sexo, @estadoCivil, @fechaNac,
                                @cuil, @prefijo, @sucursalCtaPrimaria, @nroCtaPrimaria, @tipoCtaPrimaria,
                                @limiteDebito, @producto, @codProductoTarjeta, @codCliente, @idPersona,
                                @nroAuditoria, @tipoDomicilio, @datosAdicionales, @tipoTarjeta, 1, @cuentaMoneda
                            );   
                        END
                        -- SIEMPRE DEBE QUEDAR UNA CUENTA ACTIVA PARA CARGAR ESTADO 9 Y SOLICITUD COMO MODIFICACIÓN
                        ELSE IF (@vectorCuentasCantidad>=1)
                        BEGIN
                            IF (@vectorCuentasCantidad>=2 AND @existeCuentaEnSolicitud = 1)
                            BEGIN
                                UPDATE TJD_SOLICITUD_CUENTAS_LINK
                                SET ESTADO_CUENTA = @cuentaEstado
                                WHERE SUCURSAL = @cuentaSucursal AND NRO_CUENTA = @cuentaNumeroCuenta AND NRO_TARJETA = @nroTarjetaCompleta AND ID_SOLICITUD = @solicitudActivaId;
                            END
                            ELSE IF (@existeCuentaEnSolicitud = 0)
                            -- SI NO EXISTE EN LA SOLICITUD INSERTAR LA CUENTA CON ESTADO DE BAJA (9)
                            BEGIN
                                INSERT INTO TJD_SOLICITUD_CUENTAS_LINK (ID_SOLICITUD, ORDEN_CUENTA, TIPO_CUENTA, SUCURSAL, NRO_CUENTA, ESTADO_CUENTA, TZ_LOCK, NRO_TARJETA, NUMERO_CUENTA_PBF)
                                SELECT 
                                    (select TOP 1 ID_SOLICITUD from TJD_SOLICITUD_LINK where NRO_TARJETA_COMPLETA = @nroTarjetaCompleta AND TIPO_SOLICITUD = @tipoSolicitud AND ESTADO = ''I''),
                                    (SELECT COALESCE(MAX(ORDEN_CUENTA),0)+1 FROM TJD_SOLICITUD_CUENTAS_LINK WHERE SUCURSAL = @cuentaSucursal AND NRO_CUENTA = @cuentaNumeroCuenta AND NRO_TARJETA = @nroTarjetaCompleta),
                                    @cuentaTipo,--TIPO_CUENTA,
                                    @cuentaSucursal,--SUCURSAL,
                                    @cuentaNumeroCuenta,--NRO_CUENTA
                                    ''9'',--ESTADO_CUENTA,
                                    0,
                                    @NroTarjetaCompleta,--NRO_TARJETA,
                                    @cuentaPbf
                          END
                        END
                    END
                    ELSE    
                    BEGIN
                        IF (@vectorCuentasCantidad > 1 )
                        BEGIN
                            -- HAY QUE CARGAR UNA MODIFICATORIA
                            -- NUMERADOR TOPAZ #35147
                       EXEC SP_GET_NUMERADOR_TOPAZ @vNumerador = 35147, @v_result = @idSolicitud OUTPUT;
                            IF @idSolicitud IS NULL
                            BEGIN
                                SET @codigo = 2;
                                SET @descripcion = ''Error al generar Numerador ID_SOLICITUD'';
                                ROLLBACK TRANSACTION;
                                RETURN;
                            END;

                            SET @solicitudActivaId = @idSolicitud;

                            -- Insertar en la tabla TJD_SOLICITUD_LINK (Vinculación)
                            INSERT INTO dbo.TJD_SOLICITUD_LINK (
                                ID_SOLICITUD, TIPO_SOLICITUD, ESTADO, FECHA_SOLICITUD,
                                USUARIO_SOLICITUD, HORA_SOLICITUD, SUCURSAL_SOLICITUD, 
                                ASIENTO, TIPO_DOCUMENTO, NRO_DOCUMENTO, NRO_TARJETA_BASE, NRO_TARJETA_COMPLETA,
                                APELLIDO, NOMBRE, SEXO, ESTADO_CIVIL, FECHA_NAC,
                                CUIL, PREFIJO, SUCURSAL_CTA_PRIMARIA, NRO_CTA_PRIMARIA, TIPO_CTA_PRIMARIA,
                                LIMITE_DEBITO, LIMITE_CREDITO, PRODUCTO, COD_PRODUCTO_TARJETA, COD_CLIENTE, NRO_PERSONA,
                                NRO_AUDITORIA, TIPO_DOMICILIO, DATOS_ADICIONALES, TIPO_TARJETA, ORDINAL_DIRECCION
                            ) VALUES (
                                @idSolicitud, @tipoSolicitud, @estado, @fechaSolicitud,
                                @usuario, @hora, @asientoSucursal, @asientoNumero,
                                @tipoDocumento, @nroDocumento, @nroTarjetaBase, @nroTarjetaCompleta,
                                @apellido, @nombre, @sexo, @estadoCivil, @fechaNac,
                                @cuil, @prefijo, @sucursalCtaPrimaria, @nroCtaPrimaria, @tipoCtaPrimaria,
                                @limiteDebito, @limiteCredito, @producto, @codProductoTarjeta, @codCliente, @idPersona,
                                @nroAuditoria, @tipoDomicilio, @datosAdicionales, @tipoTarjeta, 1
                            );

                            -- Grabar nueva cuenta al vector de cuentas
                            IF (@existeCuentaEnVector = 0)
                            BEGIN
                                INSERT INTO @TempCuentas (ORDEN_CUENTA, TIPO_CUENTA, SUCURSAL, NRO_CUENTA, ESTADO_CUENTA, NRO_TARJETA, NUMERO_CUENTA_PBF)
                                    SELECT
                                        (SELECT MAX(ORDEN_CUENTA)+1 FROM @TempCuentas),
                                        @cuentaTipo,--TIPO_CUENTA,
                                        @cuentaSucursal,--SUCURSAL,
                                        @cuentaNumeroCuenta,--NRO_CUENTA
                                        ''9'',--ESTADO_CUENTA,
                                        @NroTarjetaCompleta,--NRO_TARJETA,
                                        @cuentaPbf
                            END
                            ELSE
                            BEGIN
                                UPDATE @TempCuentas
                                SET ESTADO_CUENTA = ''9''
                                WHERE SUCURSAL = @cuentaSucursal  
                                    AND NRO_CUENTA = @cuentaNumeroCuenta  
                                    AND NRO_TARJETA = @nroTarjetaCompleta;
                            END;


                            -- Insertar en TJD_SOLICITUD_CUENTAS_LINK desde la tabla temporal
                            INSERT INTO TJD_SOLICITUD_CUENTAS_LINK (ID_SOLICITUD, ORDEN_CUENTA, TIPO_CUENTA, SUCURSAL, NRO_CUENTA, ESTADO_CUENTA, TZ_LOCK, NRO_TARJETA, NUMERO_CUENTA_PBF)
                            SELECT 
                                @idSolicitud, ORDEN_CUENTA, TIPO_CUENTA, SUCURSAL, NRO_CUENTA, ESTADO_CUENTA, 0, NRO_TARJETA, NUMERO_CUENTA_PBF
                            FROM @TempCuentas;

                            --Insertar en TJD_SOLICITUD_DIRECCIONES_LINK
                            INSERT INTO dbo.TJD_SOLICITUD_DIRECCIONES_LINK (
                                ID, TIPO_DIRECCION, CALLE, NUMERO, 
                                PISO, DEPARTAMENTO, LOCALIDAD, CODIGO_POSTAL,
                                PROVINCIA, TELEFONO, DESC_LOCALIDAD
                            ) VALUES (
                                @idSolicitud, @direccionTipo, @direccionCalle, @direccionNumero,
                                @direccionPiso, @direccionDepartamento, @direccionLocalidad, @direccionCodigoPostal,
                                @direccionProvincia, @direccionTelefono, @direccionDescripcionLocalidad
                            );            
                        END
                        ELSE
                        BEGIN
                            -- NO HAY SOLICITUD ACTIVA PARA LA BAJA: INSERTAR SOLICITUD DE BAJA

                            -- NUMERADOR TOPAZ #35147
                            EXEC SP_GET_NUMERADOR_TOPAZ @vNumerador = 35147, @v_result = @idSolicitud OUTPUT;
                            IF @idSolicitud IS NULL
                            BEGIN
                                SET @codigo = 2;
                                SET @descripcion = ''Error al generar Numerador ID_SOLICITUD'';
                                ROLLBACK TRANSACTION;
                                RETURN;
                            END;

                            SET @solicitudActivaId = @idSolicitud;

                            --SET @tipoSolicitud = ''210002'';
                            -- Insertar en la tabla TJD_SOLICITUD_LINK (BAJA)
                            INSERT INTO dbo.TJD_SOLICITUD_LINK (
                                ID_SOLICITUD, TIPO_SOLICITUD, ESTADO, FECHA_SOLICITUD,
                                USUARIO_SOLICITUD, HORA_SOLICITUD, SUCURSAL_SOLICITUD, 
                                ASIENTO, TIPO_DOCUMENTO, NRO_DOCUMENTO, NRO_TARJETA_BASE, NRO_TARJETA_COMPLETA,
                                APELLIDO, NOMBRE, SEXO, ESTADO_CIVIL, FECHA_NAC,
                                CUIL, PREFIJO, SUCURSAL_CTA_PRIMARIA, NRO_CTA_PRIMARIA, TIPO_CTA_PRIMARIA,
                                LIMITE_DEBITO, PRODUCTO, COD_PRODUCTO_TARJETA, COD_CLIENTE, NRO_PERSONA,
                                NRO_AUDITORIA, TIPO_DOMICILIO, DATOS_ADICIONALES, TIPO_TARJETA, AUTORIZADA, MONEDA_CUENTA
                            ) VALUES (
                                @idSolicitud, ''210002'', @estado, @fechaSolicitud,
                                @usuario, @hora, @asientoSucursal, @asientoNumero,
                                @tipoDocumento, @nroDocumento, @nroTarjetaBase, @nroTarjetaCompleta,
                                @apellido, @nombre, @sexo, @estadoCivil, @fechaNac,
                                @cuil, @prefijo, @sucursalCtaPrimaria, @nroCtaPrimaria, @tipoCtaPrimaria,
                                @limiteDebito, @producto, @codProductoTarjeta, @codCliente, @idPersona,
                                @nroAuditoria, @tipoDomicilio, @datosAdicionales, @tipoTarjeta, 1, @cuentaMoneda
                            );
                        END;
                    END;
                END;
            END
            ----------------------------------------------------------------------------------------------------
            -- Grabar SOLICITUDES: ALTAS
            ----------------------------------------------------------------------------------------------------
            ELSE IF (@accion = ''A'')
            BEGIN
                IF (@existeCuentaEnVector = 1)
                BEGIN
                    -- Si la cuenta no existe en el vector retorna con error
                    SET @codigo = 1;
                    SET @descripcion = ''Cuenta a dar de alta ya existe en vector de cuentas.'';
                    ROLLBACK TRANSACTION;
                    RETURN;
                END;

                --EXISTE UNA SOLICITUD ACTIVA
                IF (@solicitudActivaId IS NOT NULL)
                BEGIN
                    IF (@existeCuentaEnSolicitud = 1)
                    BEGIN
                        UPDATE TJD_SOLICITUD_CUENTAS_LINK
                        SET ESTADO_CUENTA = @cuentaEstado
                        WHERE SUCURSAL = @cuentaSucursal AND NRO_CUENTA = @cuentaNumeroCuenta AND NRO_TARJETA = @nroTarjetaCompleta AND ID_SOLICITUD = @solicitudActivaId;
                    END
                    ELSE IF (@existeCuentaEnSolicitud = 0)
                    BEGIN
                        -- Insertar en la tabla TJD_SOLICITUD_CUENTAS_LINK
                        INSERT INTO TJD_SOLICITUD_CUENTAS_LINK (ID_SOLICITUD, ORDEN_CUENTA, TIPO_CUENTA, SUCURSAL, NRO_CUENTA, ESTADO_CUENTA, TZ_LOCK, NRO_TARJETA, NUMERO_CUENTA_PBF)
                        SELECT 
                            (select TOP 1 ID_SOLICITUD from TJD_SOLICITUD_LINK where NRO_TARJETA_COMPLETA = @nroTarjetaCompleta AND TIPO_SOLICITUD = @tipoSolicitud AND ESTADO = ''I''),
                            (SELECT COALESCE(MAX(ORDEN_CUENTA),0)+1 FROM TJD_SOLICITUD_CUENTAS_LINK WHERE SUCURSAL = @cuentaSucursal AND NRO_CUENTA = @cuentaNumeroCuenta AND NRO_TARJETA = @nroTarjetaCompleta),
                            @cuentaTipo,--TIPO_CUENTA,
                            @cuentaSucursal,--SUCURSAL,
                            @cuentaNumeroCuenta,--NRO_CUENTA,
                            ''1'',--ESTADO_CUENTA,
                            0,
                            @NroTarjetaCompleta,--NRO_TARJETA,
                            @cuentaPbf
                    END;
                END
                ELSE
                BEGIN
                    -- NO EXISTE SOLICITUD ACTIVA: CREAR SOLICITUD

                    -- NUMERADOR TOPAZ #35147
                    EXEC SP_GET_NUMERADOR_TOPAZ @vNumerador = 35147, @v_result = @idSolicitud OUTPUT;
                    IF @idSolicitud IS NULL
                    BEGIN
                        SET @codigo = 2;
                        SET @descripcion = ''Error al generar Numerador ID_SOLICITUD'';
                        ROLLBACK TRANSACTION;
                        RETURN;
                    END;

                    SET @solicitudActivaId = @idSolicitud;

                    -- Insertar en la tabla TJD_SOLICITUD_LINK (Vinculación)
                    INSERT INTO dbo.TJD_SOLICITUD_LINK (
                        ID_SOLICITUD, TIPO_SOLICITUD, ESTADO, FECHA_SOLICITUD,
                        USUARIO_SOLICITUD, HORA_SOLICITUD, SUCURSAL_SOLICITUD, 
                        ASIENTO, TIPO_DOCUMENTO, NRO_DOCUMENTO, NRO_TARJETA_BASE, NRO_TARJETA_COMPLETA,
                        APELLIDO, NOMBRE, SEXO, ESTADO_CIVIL, FECHA_NAC,
                        CUIL, PREFIJO, SUCURSAL_CTA_PRIMARIA, NRO_CTA_PRIMARIA, TIPO_CTA_PRIMARIA,
                        LIMITE_DEBITO, LIMITE_CREDITO, PRODUCTO, COD_PRODUCTO_TARJETA, COD_CLIENTE, NRO_PERSONA,
                        NRO_AUDITORIA, TIPO_DOMICILIO, DATOS_ADICIONALES, TIPO_TARJETA, ORDINAL_DIRECCION
                    ) VALUES (
                        @idSolicitud, @tipoSolicitud, @estado, @fechaSolicitud,
                        @usuario, @hora, @asientoSucursal, @asientoNumero,
                        @tipoDocumento, @nroDocumento, @nroTarjetaBase, @nroTarjetaCompleta,
                        @apellido, @nombre, @sexo, @estadoCivil, @fechaNac,
                        @cuil, @prefijo, @sucursalCtaPrimaria, @nroCtaPrimaria, @tipoCtaPrimaria,
                     @limiteDebito, @limiteCredito, @producto, @codProductoTarjeta, @codCliente, @idPersona,
                        @nroAuditoria, @tipoDomicilio, @datosAdicionales, @tipoTarjeta, 1
                    );

                    -- Grabar nueva cuenta al vector de cuentas
                    IF (@existeCuentaEnVector = 0)
                    BEGIN
                        INSERT INTO @TempCuentas (ORDEN_CUENTA, TIPO_CUENTA, SUCURSAL, NRO_CUENTA, ESTADO_CUENTA, NRO_TARJETA, NUMERO_CUENTA_PBF)
                            SELECT
                                (SELECT MAX(ORDEN_CUENTA)+1 FROM @TempCuentas),
                                @cuentaTipo,--TIPO_CUENTA,
                                @cuentaSucursal,--SUCURSAL,
                                @cuentaNumeroCuenta,--NRO_CUENTA
                                ''1'',--ESTADO_CUENTA,
                                @NroTarjetaCompleta,--NRO_TARJETA,
                                @cuentaPbf
                    END
                    ELSE
                    BEGIN
                        UPDATE @TempCuentas
                        SET ESTADO_CUENTA = ''1''
                        WHERE SUCURSAL = @cuentaSucursal  
                            AND NRO_CUENTA = @cuentaNumeroCuenta  
                            AND NRO_TARJETA = @nroTarjetaCompleta;
                    END;


                    -- Insertar en TJD_SOLICITUD_CUENTAS_LINK desde la tabla temporal
                    INSERT INTO TJD_SOLICITUD_CUENTAS_LINK (ID_SOLICITUD, ORDEN_CUENTA, TIPO_CUENTA, SUCURSAL, NRO_CUENTA, ESTADO_CUENTA, TZ_LOCK, NRO_TARJETA, NUMERO_CUENTA_PBF)
                    SELECT 
                        @idSolicitud, ORDEN_CUENTA, TIPO_CUENTA, SUCURSAL, NRO_CUENTA, ESTADO_CUENTA, 0, NRO_TARJETA, NUMERO_CUENTA_PBF
                    FROM @TempCuentas;

                    --Insertar en TJD_SOLICITUD_DIRECCIONES_LINK
                    INSERT INTO dbo.TJD_SOLICITUD_DIRECCIONES_LINK (
                        ID, TIPO_DIRECCION, CALLE, NUMERO, 
                        PISO, DEPARTAMENTO, LOCALIDAD, CODIGO_POSTAL,
                        PROVINCIA, TELEFONO, DESC_LOCALIDAD
                    ) VALUES (
                        @idSolicitud, @direccionTipo, @direccionCalle, @direccionNumero,
                        @direccionPiso, @direccionDepartamento, @direccionLocalidad, @direccionCodigoPostal,
                        @direccionProvincia, @direccionTelefono, @direccionDescripcionLocalidad
                    );            
                END;                    
            END;
            

            -- Mensaje de salida
            SET @codigo = 0;
            SET @descripcion = concat(''Solicitud '',@solicitudActivaId, '' procesada correctamente'');
            COMMIT TRANSACTION;   
        END;   
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SET @codigo = 1;
        SET @descripcion = CONCAT(''Error al ejecutar SP_PROCESO_TJD_SOLICITUD_LINK_VINCULACION: '',ERROR_MESSAGE());
    END CATCH;
END;
');

EXEC('
CREATE OR ALTER PROCEDURE [dbo].[SP_VJ_MODIFICA_CAUSA]
	@causaId NUMERIC(12,0),
	@causaAno NUMERIC(4,0),
	@causaExpediente VARCHAR(12),
	@causaCaratula VARCHAR(250),
	@causaFecha DATE,
	@usuario VARCHAR(10),
	@outEstado INT OUT,
	@outMensaje VARCHAR(4000) OUT
AS
BEGIN

	
	DECLARE
		@MODIFICACION_MOTIVO_ANO VARCHAR(1) = ''O'',
		@MODIFICACION_MOTIVO_EXPEDIENTE VARCHAR(1) = ''E'',
		@MODIFICACION_MOTIVO_CARATULA VARCHAR(1) = ''C'',
		@MODIFICACION_MOTIVO_FECHA VARCHAR(1) = ''G''
	;
	
	SET @outEstado = 0;
	SET @outMensaje = ''OK'';

	DECLARE
		@causaEstado VARCHAR(1),
		@causaEncontrada NUMERIC(1,0) = 0,
		@causaJuzgado NUMERIC(12,0),
		@causaAnteriorAno NUMERIC(4,0),
		@causaAnteriorExpediente VARCHAR(12),
		@causaAnteriorCaratula VARCHAR(250),
		@causaAnteriorFecha DATETIME,
		@procesoFecha DATETIME = (SELECT FECHAPROCESO FROM PARAMETROS),
		@oficioNumero NUMERIC(12,0) = 0,
		@juez NUMERIC(12,0) = 0,
		@secretario NUMERIC(12,0) = 0,
		@transaccionAbierta BIT = 0
	;
	
	BEGIN TRY
	
		SELECT
			@causaEncontrada = 1,
			@causaAnteriorAno= C.ANO,
			@causaAnteriorExpediente = C.EXPEDIENTE,
			@causaAnteriorCaratula = C.CARATULA,
			@causaAnteriorFecha = C.FECHA_CAUSA,
			@causaJuzgado = C.JUZGADO
		FROM DJ_CAUSAS C WITH (NOLOCK)
		WHERE
			C.NRO_CAUSA = @causaId AND
			C.TZ_LOCK = 0
		;
			
	
	
		IF (@causaEncontrada = 0)
		BEGIN
			THROW 50001, ''Error: Causa no encontrada'', 1;
		END
		
		IF (
			(
				@causaAno<> @causaAnteriorAno OR 
				@causaExpediente <> @causaAnteriorExpediente
			) AND 
			EXISTS (
				SELECT 1 
				FROM DJ_CAUSAS 
				WHERE 
					ANO = @causaAno AND 
					EXPEDIENTE = @causaExpediente AND 
					JUZGADO = @causaJuzgado AND
					TZ_LOCK = 0
			)
		)
		BEGIN
			THROW 50002, ''Error: Ya existe una causa con el mismo año, expediente y juzgado'', 1;
		END
		
		IF (YEAR(@causaFecha) < @causaAno)
		BEGIN
			THROW 50003, ''Error: Fecha de la causa debe ser mayor o igual al año del expediente'', 1;
		END
		
		IF (@causaFecha > @procesoFecha)
		BEGIN
			THROW 50004, ''Error: La Fecha de la causa debe ser menor o igual a la fecha del sistema'', 1;
		END
		
		
		SET @transaccionAbierta = 1;
		BEGIN TRANSACTION;
		
			
			UPDATE DJ_CAUSAS
			SET
				ANO = @causaAno,
				EXPEDIENTE = @causaExpediente,
				CARATULA = @causaCaratula,
				FECHA_CAUSA = @causaFecha
			WHERE
				NRO_CAUSA = @causaId
			;
		
			-- Graba bitácora	
		
			IF (@causaAno <> @causaAnteriorAno)
			BEGIN
				INSERT INTO dbo.DJ_HISTORICO_MOD
				(NRO_CAUSA, FECHA, ORDINAL, NRO_OFICIO, JUEZ, SECRETARIO, MOTIVO_MOD, VALOR_ANTERIOR, VALOR_NUEVO, TZ_LOCK, USUARIO_ALTA, HORA_ALTA)
				VALUES
				(@causaId, @procesoFecha, (SELECT COALESCE(MAX(ORDINAL), 0) + 1 FROM DJ_HISTORICO_MOD WHERE NRO_CAUSA = @causaId), @oficioNumero, @juez, @secretario, @MODIFICACION_MOTIVO_ANO, @causaAnteriorAno, @causaAno, 0, @usuario, (FORMAT(GETDATE(), ''HH:mm:ss'')))
				;
			END
			
			IF (@causaExpediente <> @causaAnteriorExpediente)
			BEGIN
				INSERT INTO dbo.DJ_HISTORICO_MOD
				(NRO_CAUSA, FECHA, ORDINAL, NRO_OFICIO, JUEZ, SECRETARIO, MOTIVO_MOD, VALOR_ANTERIOR, VALOR_NUEVO, TZ_LOCK, USUARIO_ALTA, HORA_ALTA)
				VALUES
				(@causaId, @procesoFecha, (SELECT COALESCE(MAX(ORDINAL), 0)+ 1 FROM DJ_HISTORICO_MOD WHERE NRO_CAUSA = @causaId), @oficioNumero, @juez, @secretario, @MODIFICACION_MOTIVO_EXPEDIENTE, @causaAnteriorExpediente, @causaExpediente, 0, @usuario, (FORMAT(GETDATE(), ''HH:mm:ss'')))
				;
			END
			
			IF (@causaCaratula <> @causaAnteriorCaratula)
			BEGIN				
				INSERT INTO dbo.DJ_HISTORICO_MOD
				(NRO_CAUSA, FECHA, ORDINAL, NRO_OFICIO, JUEZ, SECRETARIO, MOTIVO_MOD, VALOR_ANTERIOR, VALOR_NUEVO, TZ_LOCK, USUARIO_ALTA, HORA_ALTA)
				VALUES
				(@causaId, @procesoFecha, (SELECT COALESCE(MAX(ORDINAL), 0) + 1 FROM DJ_HISTORICO_MOD WHERE NRO_CAUSA = @causaId), @oficioNumero, @juez, @secretario, @MODIFICACION_MOTIVO_CARATULA, SUBSTRING(@causaAnteriorCaratula, 1,49), SUBSTRING(@causaCaratula, 1,49), 0, @usuario, (FORMAT(GETDATE(), ''HH:mm:ss'')))
				;
			
				-- Actualiza el nombre de la cuenta
				UPDATE VTA_SALDOS
				SET NOMBRE_CUENTA = @causaCaratula
				WHERE JTS_OID_SALDO IN (
					SELECT JTS_OID_CUENTA
					FROM DJ_CAUSA_CUENTA
					WHERE NRO_CAUSA = @causaId
				)
			
			END
			
			IF (@causaFecha <> @causaAnteriorFecha)
			BEGIN
				INSERT INTO dbo.DJ_HISTORICO_MOD
				(NRO_CAUSA, FECHA, ORDINAL, NRO_OFICIO, JUEZ, SECRETARIO, MOTIVO_MOD, VALOR_ANTERIOR, VALOR_NUEVO, TZ_LOCK, USUARIO_ALTA, HORA_ALTA)
				VALUES
				(@causaId, @procesoFecha, (SELECT COALESCE(MAX(ORDINAL), 0) + 1 FROM DJ_HISTORICO_MOD WHERE NRO_CAUSA = @causaId), @oficioNumero, @juez, @secretario, @MODIFICACION_MOTIVO_FECHA, FORMAT(@causaAnteriorFecha, ''yyyy-MM-dd''), FORMAT(@causaFecha, ''yyyy-MM-dd''), 0, @usuario, (FORMAT(GETDATE(), ''HH:mm:ss'')))
				;
			END
		
			
		COMMIT TRANSACTION;
	
	END TRY
	
	BEGIN CATCH
		SET @outEstado = ERROR_NUMBER();
		SET @outMensaje = ERROR_MESSAGE();
		
		IF (@transaccionAbierta = 1)
		BEGIN
			ROLLBACK;
		END
		
	
	END CATCH

END
');
