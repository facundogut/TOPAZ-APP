EXEC('
CREATE OR ALTER PROCEDURE [dbo].[SP_PROCESO_TJD_SOLICITUD_LINK_ALTA]
    @jts_oid NUMERIC(10,0),
    @idPersona NUMERIC(12,0),
    @accion VARCHAR(1),
    @asientoFecha DATE,
    @asientoSucursal NUMERIC(10,0),
    @asientoNumero NUMERIC(10,0),
    @operacion NUMERIC(4,0),
    @usuario VARCHAR(10),
    @hora VARCHAR(8),
    @nroTarjetaBase NUMERIC(19,0),
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
            @monedaCuenta NUMERIC(5,0),
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
            @direccionEmail VARCHAR(250),
            --cuentas
            @cuentaPbf VARCHAR(19),
            @cuentaEstado VARCHAR(10),
            @cuentaNumeroTarjeta VARCHAR(19),
            @cuentaOrden NUMERIC(5,0),
            @cuentaTipo NUMERIC(2,0),
            @cuentaSucursal NUMERIC(5,0),
            @cuentaNumeroCuenta NUMERIC(15,0);

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

        

        -- Busco tarjeta existente para vincularla con la tarjeta
        IF EXISTS (SELECT TOP 1 1 from TJD_TARJETAS t inner join TJD_TIPO_TARJETA tt on t.TIPO_TARJETA=tt.TIPO_TARJETA
            where tt.CLASE=1 and t.NRO_PERSONA=@idPersona and ESTADO in (''0'', ''1'') )
        BEGIN
            SET @codigo = 1;
            SET @descripcion = ''Ya existe tarjeta asociada a la persona'';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- NUMERADOR TOPAZ #35147
        EXEC SP_GET_NUMERADOR_TOPAZ @vNumerador = 35147, @v_result = @idSolicitud OUTPUT;
        -- Verificar si se obtuvo un ID válido
        IF @idSolicitud IS NULL
        BEGIN
            SET @codigo = 1;
            SET @descripcion = ''Error al generar Numerador ID_SOLICITUD'';
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        BEGIN
            SELECT TOP 1 
                @TipoSolicitud = 120005, 
                @Estado = ''I'', 
                @FechaSolicitud = @asientoFecha, 
                --@usuario
                --@hora
                --@asientoSucursal
                --@asientoNumero
                @tipoDocumento = d.TIPO_DOC_FISICO, 
                @nroDocumento = d.NUM_DOC_FISICO, 
                --@NroTarjetaBase, 
                @apellido = CONCAT(p.APELLIDOPATERNO, p.APELLIDOMATERNO), 
                @nombre = CONCAT(p.PRIMERNOMBRE, p.SEGUNDONOMBRE), 
                @sexo = p.SEXO, 
                @estadoCivil = p.ESTADOCIVIL, 
                @fechaNac = p.FECHANACIMIENTO, 
                @cuil = d.NUMERODOCUMENTO, 
                @prefijo = tT.BIN, 
                @sucursalCtaPrimaria = s.SUCURSAL, 
                @nroCtaPrimaria = s.CUENTA, 
                @tipoCtaPrimaria = par.ALFA_2, 
                @limiteDebito = (SELECT ALFA FROM PARAMETROSGENERALES p WHERE CODIGO = 233), 
                @limiteCredito = ''00'', 
                @producto = rel.PRODUCTO, 
                @codProductoTarjeta = tt.CODIGO_PRODUCTO, 
                @codCliente = s.C1803,
                @tipoDomicilio = ''P'',
                @datosAdicionales = ''N'',
                @tipoTarjeta = tt.TIPO_TARJETA,
                @monedaCuenta = s.MONEDA
            FROM SALDOS (NOLOCK) s  
            INNER JOIN PROD_RELTARJETAS rel ON rel.PRODUCTO = s.PRODUCTO AND rel.TZ_LOCK = 0
            INNER JOIN TJD_TIPO_TARJETA tt ON tt.TIPO_TARJETA = rel.TARJETA AND tt.TZ_LOCK = 0
            INNER JOIN CLI_PERSONASFISICAS  (NOLOCK) p ON p.NUMEROPERSONAFISICA = @idPersona AND p.TZ_LOCK = 0
            INNER JOIN CLI_DocumentosPFPJ  (NOLOCK) d ON d.NUMEROPERSONAFJ = p.NUMEROPERSONAFISICA AND d.TIPOPERSONA = ''F'' AND d.TZ_LOCK = 0
            INNER JOIN ITF_MASTER_PARAMETROS par on par.CODIGO_INTERFACE = 9 and par.NUMERICO_1 = s.C1785 and par.NUMERICO_2 = s.MONEDA
            WHERE s.JTS_OID = @jts_oid
            

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
                @direccionDescripcionLocalidad = cl.DESCRIPCION_DIM3,
                @direccionEmail = e.EMAIL
            FROM CLI_DIRECCIONES (NOLOCK) dir
            inner join CLI_PAISES  (NOLOCK) cpa on cpa.CODIGOPAIS = dir.PAIS AND cpa.TZ_LOCK = 0
            inner join CLI_PROVINCIAS  (NOLOCK) cp on cp.CODIGOPAIS = dir.PAIS and cp.DIM1 = dir.PROVINCIA AND cp.TZ_LOCK = 0
            inner join CLI_DEPARTAMENTOS  (NOLOCK) cde on cde.CODIGOPAIS = dir.PAIS and cde.DEPARTAMENTO = dir.DEPARTAMENTO and cde.PROVINCIA = dir.PROVINCIA AND cde.TZ_LOCK = 0
            inner join CLI_LOCALIDADES  (NOLOCK) cl on cl.CODIGOPAIS = dir.PAIS and cl.DIM1 = dir.PROVINCIA and cl.DIM2 = dir.DEPARTAMENTO and cl.DIM3 = dir.LOCALIDAD and cl.CODIGO_POSTAL = dir.CPA_VIEJO AND cl.TZ_LOCK=0
            INNER JOIN CLI_TELEFONOS  (NOLOCK) ct ON ct.ID = dir.ID AND ct.FORMATO = ''PF'' AND ct.TIPO = ''PE''
            INNER JOIN CLI_EMAILS (NOLOCK) e ON e.ID = ct.ID AND e.FORMATO = ''PF'' and e.TIPO = ''PE''
            WHERE dir.ID = @idPersona AND dir.TZ_LOCK = 0

            -- Grabar nueva cuenta al vector de cuentas
            INSERT INTO @TempCuentas (ORDEN_CUENTA, TIPO_CUENTA, SUCURSAL, NRO_CUENTA, ESTADO_CUENTA, NRO_TARJETA, NUMERO_CUENTA_PBF)
                SELECT
                    1,
                    TRY_CONVERT(NUMERIC(2,0),p.ALFA_2),--TIPO_CUENTA,
                    SUCURSAL,--SUCURSAL,
                    CUENTA,--NRO_CUENTA
                    ''1'',--ESTADO_CUENTA,
                    @nroTarjetaBase,--NRO_TARJETA,
                    SUBSTRING (vs.CTA_REDLINK, 3, 19)--NUMERO_CUENTA_PBF
                FROM SALDOS (NOLOCK) s
                INNER JOIN VTA_SALDOS vs ON vs.JTS_OID_SALDO = s.JTS_OID and vs.TZ_LOCK = 0
                INNER JOIN ITF_MASTER_PARAMETROS p on CODIGO_INTERFACE = 9 and NUMERICO_1 = s.C1785 and NUMERICO_2 = s.MONEDA
                WHERE s.JTS_OID = @jts_oid
            
            IF EXISTS (select TOP 1 1 from TJD_SOLICITUD_LINK
                    where 
                        NRO_CTA_PRIMARIA = @nroCtaPrimaria
                        AND TIPO_CTA_PRIMARIA = @tipoCtaPrimaria
                        AND SUCURSAL_CTA_PRIMARIA = @sucursalCtaPrimaria
                        AND NRO_PERSONA = @idPersona
                        AND TIPO_SOLICITUD = @tipoSolicitud 
                        AND ESTADO = ''I'')
            BEGIN 
                SET @codigo = 1;
                SET @descripcion = ''Ya existe solicitud de alta'';
                ROLLBACK TRANSACTION;
                RETURN;
            END
            ELSE
            BEGIN
                -- Insertar en TJD_SOLICITUD_CUENTAS_LINK desde la tabla temporal
                INSERT INTO TJD_SOLICITUD_CUENTAS_LINK (ID_SOLICITUD, ORDEN_CUENTA, TIPO_CUENTA, SUCURSAL, NRO_CUENTA, ESTADO_CUENTA, TZ_LOCK, NRO_TARJETA, NUMERO_CUENTA_PBF)
                SELECT 
                    @idSolicitud, ORDEN_CUENTA, TIPO_CUENTA, SUCURSAL, NRO_CUENTA, ESTADO_CUENTA, 0, NRO_TARJETA, NUMERO_CUENTA_PBF
                FROM @TempCuentas;

                -- Construir Número de auditoria
                SELECT 
                    @nroAuditoria = CONCAT(
                        g.ALFA,
                        FORMAT(p.FECHAPROCESO, ''yyyyMMdd''),
                        FORMAT(GETDATE(), ''HHmmss'')
                    )
                FROM parametrosgenerales (NOLOCK) g, parametros (NOLOCK) p
                WHERE g.codigo = 705;

                -- Insertar en la tabla TJD_SOLICITUD_LINK (Vinculación)
                INSERT INTO dbo.TJD_SOLICITUD_LINK (
                    ID_SOLICITUD, TIPO_SOLICITUD, ESTADO, FECHA_SOLICITUD,
                    USUARIO_SOLICITUD, HORA_SOLICITUD, SUCURSAL_SOLICITUD, 
                    ASIENTO, TIPO_DOCUMENTO, NRO_DOCUMENTO, NRO_TARJETA_BASE, 
                    APELLIDO, NOMBRE, SEXO, ESTADO_CIVIL, FECHA_NAC,
                    CUIL, PREFIJO, SUCURSAL_CTA_PRIMARIA, NRO_CTA_PRIMARIA, TIPO_CTA_PRIMARIA,
                    LIMITE_DEBITO, LIMITE_CREDITO, PRODUCTO, COD_PRODUCTO_TARJETA, COD_CLIENTE, NRO_PERSONA,
                    NRO_AUDITORIA, TIPO_DOMICILIO, DATOS_ADICIONALES, TIPO_TARJETA, ORDINAL_DIRECCION, MONEDA_CUENTA, AUTORIZADA
                ) VALUES (
                    @idSolicitud, @tipoSolicitud, @estado, @fechaSolicitud,
                    @usuario, @hora, @asientoSucursal, @asientoNumero,
                    @tipoDocumento, @nroDocumento, @nroTarjetaBase, 
                    @apellido, @nombre, @sexo, @estadoCivil, @fechaNac,
                    @cuil, @prefijo, @sucursalCtaPrimaria, @nroCtaPrimaria, @tipoCtaPrimaria,
                    @limiteDebito, @limiteCredito, @producto, @codProductoTarjeta, @codCliente, @idPersona,
                    @nroAuditoria, @tipoDomicilio, @datosAdicionales, @tipoTarjeta, 1, @monedaCuenta, 1
                );

                --Insertar en TJD_SOLICITUD_DIRECCIONES_LINK
                INSERT INTO dbo.TJD_SOLICITUD_DIRECCIONES_LINK (
                    ID, TIPO_DIRECCION, CALLE, NUMERO, 
                    PISO, DEPARTAMENTO, LOCALIDAD, CODIGO_POSTAL,
               PROVINCIA, TELEFONO, DESC_LOCALIDAD, EMAIL
                ) VALUES (
                    @idSolicitud, @direccionTipo, @direccionCalle, @direccionNumero,
                    @direccionPiso, @direccionDepartamento, @direccionLocalidad, @direccionCodigoPostal,
                    @direccionProvincia, @direccionTelefono, @direccionDescripcionLocalidad, @direccionEmail
                );
            
                -- Mensaje de salida
                SET @codigo = 0;
                SET @descripcion = ''Alta procesada correctamente'';
                COMMIT TRANSACTION;     
            END         
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SET @codigo = 1;
        SET @descripcion = CONCAT(''Error al ejecutar SP_PROCESO_TJD_SOLICITUD_LINK_ALTA: '',ERROR_MESSAGE());
    END CATCH;
END;
');

EXEC('
CREATE OR ALTER PROCEDURE [dbo].[SP_PROCESO_TJD_SOLICITUD_LINK_VINCULACION]
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
            INNER JOIN TJD_REL_TARJETA_CUENTA  (NOLOCK) tr ON tr.ID_TARJETA = t.ID_TARJETA AND tr.PRIORITARIA = 1 AND tr.MONEDA = 1 AND tr.TZ_LOCK = 0
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
CREATE OR ALTER PROCEDURE dbo.SP_SUCURSAL_POR_NUMERO_CAUSA
    @nroCAUSA INT,
    @SUCURSAL INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @cantidadSUC INT, @CIRCUNSCRIPCION INT;
    
    -- Contar cuántas sucursales distintas hay
    SELECT @cantidadSUC = COUNT(DISTINCT s.SUCURSAL)
    FROM DJ_CAUSA_CUENTA dcc 
    JOIN DJ_CAUSAS dc ON dcc.NRO_CAUSA = dc.NRO_CAUSA 
        AND dc.ESTADO = ''A'' 
        AND dc.TZ_LOCK = 0
        AND dcc.NRO_CAUSA = @nroCAUSA
        AND dcc.TZ_LOCK = 0
    JOIN DJ_JUZGADOS dj ON dc.JUZGADO = dj.NRO_JUZGADO AND dj.TZ_LOCK = 0
    JOIN SALDOS s ON dcc.JTS_OID_CUENTA = s.JTS_OID AND s.TZ_LOCK = 0

    -- Si solo hay una sucursal, asignarla directamente
    IF @cantidadSUC = 1
    BEGIN
        SELECT @SUCURSAL = MAX(s.SUCURSAL)
        FROM DJ_CAUSA_CUENTA dcc 
        JOIN DJ_CAUSAS dc ON dcc.NRO_CAUSA = dc.NRO_CAUSA
            AND dc.TZ_LOCK = 0
            AND dc.ESTADO = ''A'' 
            AND dcc.NRO_CAUSA = @nroCAUSA
            AND dcc.TZ_LOCK = 0
        JOIN DJ_JUZGADOS dj ON dc.JUZGADO = dj.NRO_JUZGADO AND dj.TZ_LOCK = 0
        JOIN SALDOS s ON dcc.JTS_OID_CUENTA = s.JTS_OID AND s.TZ_LOCK = 0
    END
    ELSE
    BEGIN
        -- Obtener la circunscripción
        SELECT @CIRCUNSCRIPCION = dj.CIRCUNSCRIPCION
        FROM DJ_JUZGADOS dj
        JOIN DJ_CAUSAS dc ON dj.NRO_JUZGADO = dc.JUZGADO 
            AND dc.ESTADO = ''A''
            AND dc.NRO_CAUSA = @nroCAUSA
            AND dj.TZ_LOCK = 0;
        
        -- Si la circunscripción es 0 o mayor a 6, asignar 30
        IF @CIRCUNSCRIPCION >= 7 OR @CIRCUNSCRIPCION = 0
        BEGIN
            SET @SUCURSAL = 30;
        END
        ELSE
        BEGIN
            -- Asignar la sucursal basada en la parametrización
            SELECT @SUCURSAL = imp.NUMERICO_2
            FROM DJ_CAUSAS dc
            JOIN DJ_JUZGADOS dj ON dc.JUZGADO = dj.NRO_JUZGADO AND dj.TZ_LOCK = 0
            JOIN ITF_MASTER_PARAMETROS imp ON dj.CIRCUNSCRIPCION = imp.NUMERICO_1 
                AND imp.CODIGO_INTERFACE = 1021003
                AND imp.TZ_LOCK = 0
            WHERE 
                dc.ESTADO = ''A'' 
                AND dc.NRO_CAUSA = @nroCAUSA
                AND dc.TZ_LOCK = 0
        END
    END
END;
');

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
    WHERE c.TIPO_CAUSA=@causaTipo AND c.ESTADO=''A'' AND LEFT(c.TZ_LOCK, 1) IN (0, 2, 4)
    AND c.NRO_CAUSA in
        (SELECT cc.NRO_CAUSA
        FROM DJ_CAUSA_CUENTA cc
        WHERE cc.JTS_OID_CUENTA = @jts_oid AND LEFT(cc.TZ_LOCK, 1) IN (0, 2, 4))
    
    IF (@causaNumero = 0 OR @causaNumero is null)
    BEGIN
        SET @codigo = 1;
        SET @descripcion = CONCAT(''Error al encontrar Número de causa. JtsOid: '',@jts_oid,'' - TipoCuenta: '',@causaTipo);
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
        c.TIPO_CAUSA = @causaTipo
        AND c.ESTADO = ''A''  
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
        c.TIPO_CAUSA = @causaTipo
        AND c.ESTADO = ''A''  
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
    WHERE TIPO_CAUSA=@causaTipo AND ESTADO=''A'' AND TZ_LOCK = 0
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
        c.TIPO_CAUSA = @causaTipo
        AND c.ESTADO = ''A''  
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
        c.TIPO_CAUSA = @causaTipo
        AND c.ESTADO = ''A''  
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
				INSERT INTO gamma.dbo.DJ_HISTORICO_MOD
				(NRO_CAUSA, FECHA, ORDINAL, NRO_OFICIO, JUEZ, SECRETARIO, MOTIVO_MOD, VALOR_ANTERIOR, VALOR_NUEVO, TZ_LOCK, USUARIO_ALTA, HORA_ALTA)
				VALUES
				(@causaId, @procesoFecha, (SELECT COALESCE(MAX(ORDINAL), 0) + 1 FROM DJ_HISTORICO_MOD WHERE NRO_CAUSA = @causaId), @oficioNumero, @juez, @secretario, @MODIFICACION_MOTIVO_ANO, @causaAnteriorAno, @causaAno, 0, @usuario, (FORMAT(GETDATE(), ''HH:mm:ss'')))
				;
			END
			
			IF (@causaExpediente <> @causaAnteriorExpediente)
			BEGIN
				INSERT INTO gamma.dbo.DJ_HISTORICO_MOD
				(NRO_CAUSA, FECHA, ORDINAL, NRO_OFICIO, JUEZ, SECRETARIO, MOTIVO_MOD, VALOR_ANTERIOR, VALOR_NUEVO, TZ_LOCK, USUARIO_ALTA, HORA_ALTA)
				VALUES
				(@causaId, @procesoFecha, (SELECT COALESCE(MAX(ORDINAL), 0)+ 1 FROM DJ_HISTORICO_MOD WHERE NRO_CAUSA = @causaId), @oficioNumero, @juez, @secretario, @MODIFICACION_MOTIVO_EXPEDIENTE, @causaAnteriorExpediente, @causaExpediente, 0, @usuario, (FORMAT(GETDATE(), ''HH:mm:ss'')))
				;
			END
			
			IF (@causaCaratula <> @causaAnteriorCaratula)
			BEGIN				
				INSERT INTO gamma.dbo.DJ_HISTORICO_MOD
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
				INSERT INTO gamma.dbo.DJ_HISTORICO_MOD
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

EXEC('
CREATE OR ALTER PROCEDURE [dbo].[SP_VJ_TRANSFERENCIA_CAUSA] 
    @causaNumero NUMERIC(12,0),
    @causaJuzgado NUMERIC(12,0),
	@asientoFecha date,
	@asientoSucursal numeric(10,0),
	@asientoNumero numeric(10,0),
	@operacion NUMERIC(4,0),
	@usuario VARCHAR(10),
	@hora VARCHAR(8),
	@codigo NUMERIC(3,0) OUTPUT, 
	@descripcion varchar(150) OUTPUT,
    @nuevaCausaNumero NUMERIC(12) OUTPUT

AS 
BEGIN 
    SET XACT_ABORT ON;
    BEGIN TRANSACTION;
    BEGIN TRY
    
    ----------------------------------------------------------------------------------------------------
    -- DECLARACIÓN DE VARIABLES
    ----------------------------------------------------------------------------------------------------

    DECLARE
        -- Causa
    	@causaAno NUMERIC(4,0) = 0,
        @causaExpediente VARCHAR(100) = '''',
        @causaTipo VARCHAR(2) = '''',
        @causaCaratula VARCHAR(250) = '''',
        @causaFecha DATE,
        @causaEstado VARCHAR(1) = '''',
        @causaComentario VARCHAR(150) = '''',
        @causaJtsOidInmovilizado NUMERIC(10,0),
        @causaDestino NUMERIC(12,0),
        @causaJuzgadoAnterior NUMERIC(12,0),
        -- Otros datos
        @idPersonaJuez NUMERIC(12,0) = 0,
        @actorJuez VARCHAR(3) = '''',
        @idPersonaSecretario NUMERIC(12,0) = 0,
        @actorSecretario VARCHAR(3) = '''',
        @cuentaBloqueada NUMERIC(1,0) = NULL,
        @SPcodigo NUMERIC(2,0) = NULL,
        @SPdescripcion VARCHAR(150) = NULL
        ;
    
    -- Temporar Beneficiarios
    DECLARE @Temp_DJ_BENEFICIARIOS TABLE (
        NRO_CAUSA NUMERIC(12,0) DEFAULT 0 NOT NULL,
        JTS_OID_CUENTA NUMERIC(10,0) DEFAULT 0 NOT NULL,
        ID_BENEFICIARIO NUMERIC(12,0) DEFAULT 0 NOT NULL,
        LECTURA VARCHAR(100) COLLATE Modern_Spanish_CI_AS DEFAULT '' '' NULL,
        TZ_LOCK NUMERIC(15,0) DEFAULT 0 NOT NULL,
        FECHA_INTEGRACION DATETIME NULL,
        PRIMARY KEY (NRO_CAUSA, JTS_OID_CUENTA, ID_BENEFICIARIO)
    );

    -- Temporal Causa Cuentas
    DECLARE @Temp_DJ_CAUSA_CUENTA TABLE (
        JTS_OID_CUENTA numeric(10,0) DEFAULT 0 NOT NULL,
        NRO_CAUSA numeric(12,0) DEFAULT 0 NOT NULL,
        NRO_OFICIO numeric(12,0) DEFAULT 0 NULL,
        FECHA_OFICIO datetime NULL,
        TZ_LOCK numeric(15,0) DEFAULT 0 NOT NULL,
        PRIMARY KEY (JTS_OID_CUENTA,NRO_CAUSA)
    )

    -- Temporal Apoderados
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
    SET @descripcion = ''Error inesperado ejecutando SP'';
    SET @nuevaCausaNumero = 0;
   
    SET @causaExpediente = '''';
   
    ----------------------------------------------------------------------------------------------------
    -- VALIDACIONES CANCELATORIAS
    ----------------------------------------------------------------------------------------------------
    SELECT 
        @causaJuzgadoAnterior = c.JUZGADO,
        @causaAno = c.ANO,
        @causaExpediente = c.EXPEDIENTE,
        @causaTipo = c.TIPO_CAUSA,
        @causaCaratula = c.CARATULA,
        @causaFecha = c.FECHA_CAUSA,
        @causaEstado = c.ESTADO,
        @causaJtsOidInmovilizado = c.JTS_OID_INMOVILIZADO,
        @causaDestino = c.CAUSA_DESTINO,
        @causaComentario = c.COMENTARIO
    FROM DJ_CAUSAS c
    WHERE
        c.NRO_CAUSA = @causaNumero 
        AND c.ESTADO = ''A''
        AND c.TZ_LOCK = 0;
    
    -- VALIDAR CAUSA
    IF (@causaExpediente = '''' OR @causaExpediente is null)
    BEGIN
        SET @codigo = 1;
        SET @descripcion = ''ERROR: CAUSA INVÁLIDA'';
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- VALIDAR JUZGADO
    IF NOT EXISTS (SELECT 1 FROM DJ_JUZGADOS j WHERE NRO_JUZGADO = @causaJuzgado AND j.TZ_LOCK = 0)
    BEGIN
        SET @codigo = 1;
        SET @descripcion = ''ERROR: JUZGADO INVÁLIDO''
        ROLLBACK TRANSACTION;
        RETURN;
    END;

    IF (@causaJuzgado = @causaJuzgadoAnterior)
    BEGIN
        SET @codigo = 21;
        SET @descripcion = ''ERROR: LA CAUSA NO PUEDE TRANSITAR A SU MISMO JUZGADO'';
        ROLLBACK TRANSACTION;
        RETURN;
    END;

    -- Generación de nuevo número de causa
    EXEC dbo.SP_GET_NUMERADOR_TOPAZ 33175, @nuevaCausaNumero OUTPUT;
    IF @nuevaCausaNumero IS NULL OR @nuevaCausaNumero = 0
    BEGIN
        SET @codigo = 22;
        SET @descripcion = ''ERROR: Generando Numerador DJ_CAUSAS'';
        ROLLBACK TRANSACTION;
        RETURN;
    END
   
    -- Verificación de duplicados
    IF EXISTS (SELECT 1 FROM DJ_CAUSAS WHERE NRO_CAUSA = @nuevaCausaNumero)
    BEGIN
        SET @codigo = 23;
        SET @descripcion = ''ERROR: El número de causa generado ya existe en DJ_CAUSAS'';
        ROLLBACK TRANSACTION;
        RETURN;
    END

    IF EXISTS ( SELECT 1 FROM DJ_CAUSAS
                WHERE JUZGADO = @causaJuzgado
                AND ANO = @causaAno
                AND EXPEDIENTE = @causaExpediente)
    BEGIN
        SET @codigo = 6;
        SET @descripcion = CONCAT(''ERROR: CAUSA DUPLICADA. Juzgado: '',@causaJuzgado, ''. Año: '',@causaAno,''. Expediente: '',@causaExpediente,''.'');
        ROLLBACK TRANSACTION;
        RETURN;
    END;
        
    -- Insertar en DJ_CAUSAS
    INSERT INTO DJ_CAUSAS (NRO_CAUSA, JUZGADO, ANO, EXPEDIENTE, TIPO_CAUSA, CARATULA, FECHA_CAUSA, TZ_LOCK, JTS_OID_INMOVILIZADO, CAUSA_DESTINO, COMENTARIO, ESTADO)
    VALUES (@nuevaCausaNumero, @causaJuzgado, @causaAno, @causaExpediente, @causaTipo, @causaCaratula, @causaFecha, 0, @causaJtsOidInmovilizado, @causaDestino, @causaComentario, ''A'');

 
    ----------------------------------------------------------------------------------------------------
    -- OBTENER DATOS
    ----------------------------------------------------------------------------------------------------

    -- CARGAR DJ_BENEFICIARIOS TEMP.
    INSERT INTO @Temp_DJ_BENEFICIARIOS (NRO_CAUSA, JTS_OID_CUENTA, ID_BENEFICIARIO, LECTURA, TZ_LOCK, FECHA_INTEGRACION)
    SELECT
        NRO_CAUSA, JTS_OID_CUENTA, ID_BENEFICIARIO, LECTURA, TZ_LOCK, FECHA_INTEGRACION
    FROM DJ_BENEFICIARIOS
    WHERE NRO_CAUSA = @causaNumero AND TZ_LOCK = 0;

    -- CARGAR DJ_CAUSA_CUENTA
    INSERT INTO @Temp_DJ_CAUSA_CUENTA (JTS_OID_CUENTA, NRO_CAUSA, NRO_OFICIO, FECHA_OFICIO, TZ_LOCK) 
    SELECT
        JTS_OID_CUENTA, NRO_CAUSA, NRO_OFICIO, FECHA_OFICIO, TZ_LOCK
    FROM DJ_CAUSA_CUENTA
    WHERE NRO_CAUSA = @causaNumero AND TZ_LOCK = 0;

    -- CARGAR PYF_APODERADOS
    INSERT INTO @Temp_PYF_APODERADOS (TZ_LOCK, ID_ENTIDAD, TIPO_PODER, TIPO_ENTIDAD, ID_PERSONA, CATEGORIA, MONEDA_MONTO_INDIV,
        MONTO_MAX_INDIV, MONEDA_MONTO_GRUPAL, MONTO_MAX_GRUPAL, FECHA_VENCIMIENTO, FECHA_INI_VIGENCIA, FECHA_INI_SUSPENSION,
        FECHA_FIN_SUSPENSION, APODERAMIENTO, ID_CLIENTE_SALDO, ID_ENTIDAD2)
    SELECT
        pa.TZ_LOCK, pa.ID_ENTIDAD, pa.TIPO_PODER, pa.TIPO_ENTIDAD, pa.ID_PERSONA, pa.CATEGORIA, pa.MONEDA_MONTO_INDIV,
        pa.MONTO_MAX_INDIV, pa.MONEDA_MONTO_GRUPAL, pa.MONTO_MAX_GRUPAL, pa.FECHA_VENCIMIENTO, pa.FECHA_INI_VIGENCIA, pa.FECHA_INI_SUSPENSION,
        pa.FECHA_FIN_SUSPENSION, pa.APODERAMIENTO, pa.ID_CLIENTE_SALDO, pa.ID_ENTIDAD2
    FROM PYF_APODERADOS (NOLOCK) pa
    INNER JOIN SALDOS (NOLOCK) s ON s.JTS_OID = pa.ID_ENTIDAD2 AND pa.TIPO_ENTIDAD = 2 AND s.TZ_LOCK = 0
    INNER JOIN DJ_CAUSA_CUENTA cc ON cc.JTS_OID_CUENTA = S.JTS_OID AND cc.TZ_LOCK = 0 AND cc.NRO_CAUSA = @causaNumero
    WHERE pa.TZ_LOCK = 0

    ----------------------------------------------------------------------------------------------------
    -- Causa original -> Transferida
    ----------------------------------------------------------------------------------------------------

    UPDATE DJ_CAUSAS
    SET ESTADO = ''T'', CAUSA_DESTINO = @nuevaCausaNumero
    WHERE NRO_CAUSA = @causaNumero;
    
    UPDATE DJ_INTEGRANTES_CAUSAS
    SET ACTIVO = ''N'', FECHA_CESE = @asientoFecha
    WHERE NRO_CAUSA = @causaNumero AND TZ_LOCK = 0;

    DELETE FROM DJ_CAUSA_CUENTA
    WHERE NRO_CAUSA = @causaNumero AND TZ_LOCK = 0;

    DELETE FROM DJ_BENEFICIARIOS
    WHERE NRO_CAUSA = @causaNumero AND TZ_LOCK = 0;

    INSERT INTO DJ_DEMANDADOS (NRO_CAUSA, NRO_PERSONA, LECTURA, TZ_LOCK)
    SELECT
        @nuevaCausaNumero, NRO_PERSONA, LECTURA, TZ_LOCK
    FROM DJ_DEMANDADOS
    WHERE NRO_CAUSA = @causaNumero AND TZ_LOCK = 0;

    DELETE FROM DJ_DEMANDADOS
    WHERE NRO_CAUSA = @causaNumero AND TZ_LOCK = 0;
  
    ----------------------------------------------------------------------------------------------------
    -- Nueva Causa Judicial -> Creación
    ----------------------------------------------------------------------------------------------------
   
    INSERT INTO DJ_CAUSA_CUENTA (JTS_OID_CUENTA, NRO_CAUSA, NRO_OFICIO, FECHA_OFICIO, TZ_LOCK)
    SELECT
        JTS_OID_CUENTA, @nuevaCausaNumero, NRO_OFICIO, FECHA_OFICIO, 0
    FROM @Temp_DJ_CAUSA_CUENTA;
   
    --SIN BENEFICIARIOS SE DEBEN ASIGNAR PODERES AL JUEZ Y SECRETARIO PARA CADA CUENTA DE LA CAUSA
    
    IF (SELECT COUNT(1) FROM @Temp_DJ_BENEFICIARIOS) = 0
    BEGIN
        -- Iterar sobre los registros de @Temp_DJ_CAUSA_CUENTA y llamar al SP para cada uno
        DECLARE @jts_oid NUMERIC(10,0);
       	DECLARE @tipoBloqueo VARCHAR(2) = (CASE WHEN @causaTipo = ''AL'' THEN 9 ELSE 0 END)

        DECLARE causa_cursor CURSOR FOR 
        SELECT JTS_OID_CUENTA FROM @Temp_DJ_CAUSA_CUENTA;

        OPEN causa_cursor;
        FETCH NEXT FROM causa_cursor INTO @jts_oid;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            -- Llamar al SP para cada registro
            EXEC [dbo].[SP_VJ_ADMINISTRA_JUEZ] 
                @jts_oid = @jts_oid,
                @idPersona = 0,
                @accion = ''A'',
                @asientoFecha = @asientoFecha,
                @asientoSucursal = @asientoSucursal,
                @asientoNumero = @asientoNumero,
                @operacion = @operacion,
                @usuario = @usuario,
                @hora = @hora,
                @causaTipo = @causaTipo,
                @bloqueoCodigo = @tipoBloqueo,
                @codigo = @SPcodigo OUTPUT,
                @descripcion = @SPdescripcion OUTPUT;
            
            IF (@SPcodigo <> 0)
            BEGIN
                SET @codigo = COALESCE(TRY_CONVERT(NUMERIC(3,0),@SPcodigo),0);
                SET @descripcion = CONCAT(''Error: '',@SPdescripcion);
                --ROLLBACK TRANSACTION;
                RETURN;
            END

            FETCH NEXT FROM causa_cursor INTO @jts_oid;
        END;

        CLOSE causa_cursor;
        DEALLOCATE causa_cursor;
    END
    ELSE
    BEGIN 
        INSERT INTO DJ_BENEFICIARIOS (NRO_CAUSA, JTS_OID_CUENTA, ID_BENEFICIARIO, LECTURA, TZ_LOCK, FECHA_INTEGRACION)
        SELECT
            @nuevaCausaNumero, JTS_OID_CUENTA, ID_BENEFICIARIO, LECTURA, TZ_LOCK, FECHA_INTEGRACION
        FROM @Temp_DJ_BENEFICIARIOS;
    END;  

    ---------------------------------------------------------------------------------------------------------------------------
    -- DJ HISTORICO MOD: TRANSFERENCIA y ALTA
    ---------------------------------------------------------------------------------------------------------------------------
    -- OBTENER ID PERSONA JUEZ
    SELECT TOP 1
        @idPersonaJuez = i.ID_PERSONA,
        @actorJuez = i.ACTOR
    FROM DJ_JUZGADOS j
    INNER JOIN DJ_INTEGRANTES_JUZGADOS i ON i.NRO_JUZGADO  = j.NRO_JUZGADO AND i.ACTIVO  = ''S'' AND i.TZ_LOCK = 0
    WHERE j.NRO_JUZGADO = @causaJuzgado AND i.ACTOR IN (''SEJ'', ''SE1'')
    ORDER BY i.ACTOR DESC;
    
    -- OBTENER ID PERSONA SECRETARIO
    SELECT TOP 1
        @idPersonaSecretario = i.ID_PERSONA,
        @actorSecretario = i.ACTOR
    FROM DJ_JUZGADOS j
    INNER JOIN DJ_INTEGRANTES_JUZGADOS i ON i.NRO_JUZGADO  = j.NRO_JUZGADO AND i.ACTIVO  = ''S'' AND i.TZ_LOCK = 0
    WHERE j.NRO_JUZGADO = @causaJuzgado  AND i.ACTOR IN (''SEJ'', ''SE1'')
    ORDER BY i.ACTOR DESC;

    -- TRANSFERENCIA CON VALORES DE JUZGADO
	INSERT INTO DJ_HISTORICO_MOD (
	    NRO_CAUSA, FECHA, NRO_OFICIO, JUEZ, SECRETARIO, MOTIVO_MOD, VALOR_ANTERIOR, VALOR_NUEVO, USUARIO_ALTA, HORA_ALTA, ORDINAL
	)
	SELECT 
	    @causaNumero, @asientoFecha, @asientoNumero, @idPersonaJuez, @idPersonaSecretario, ''T'', 
	    @causaJuzgadoAnterior, @causaJuzgado, @usuario, @hora,
	    ISNULL((SELECT MAX(ORDINAL) FROM DJ_HISTORICO_MOD WHERE NRO_CAUSA = @causaNumero AND FECHA = @asientoFecha), 0) + 1
	
	-- NUEVA CAUSA CON VALOR DE CAUSA    
	INSERT INTO DJ_HISTORICO_MOD (
		NRO_CAUSA, FECHA, NRO_OFICIO, JUEZ, SECRETARIO, MOTIVO_MOD, VALOR_ANTERIOR, VALOR_NUEVO, USUARIO_ALTA, HORA_ALTA, ORDINAL
	)
	SELECT 
	    @nuevaCausaNumero, @asientoFecha, @asientoNumero, @idPersonaJuez, @idPersonaSecretario, ''A'', 
	    NULL, @nuevaCausaNumero, @usuario, @hora,
	    ISNULL((SELECT MAX(ORDINAL) FROM DJ_HISTORICO_MOD WHERE NRO_CAUSA = @nuevaCausaNumero AND FECHA = @asientoFecha), 0) + 1;


    ---------------------------------------------------------------------------------------------------------------------------
    -- SALIDA
    ---------------------------------------------------------------------------------------------------------------------------
	   
    SET @codigo = 0;
    SET @descripcion = CONCAT(''Causa: '',@causaNumero,'' transferida correctamente.'');

      
    COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;
        SET @codigo = 99;
        SET @descripcion = CONCAT(''Error: '', ERROR_MESSAGE());
    END CATCH;

END;
');