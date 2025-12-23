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
		
		-- Sufrió cambios la clave de Causa? (Año - Juzgado - Expediente)
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
		
			-- Verificar que existan cambios y actualizar nombre de cuenta en vta_saldos
			-- Graba bitácora	
		
			IF ( @causaCaratula <> @causaAnteriorCaratula OR @causaAno <> @causaAnteriorAno OR @causaExpediente <> @causaAnteriorExpediente )
			BEGIN

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
					(@causaId, @procesoFecha, (SELECT COALESCE(MAX(ORDINAL), 0) + 1 FROM DJ_HISTORICO_MOD WHERE NRO_CAUSA = @causaId), @oficioNumero, @juez, @secretario, @MODIFICACION_MOTIVO_CARATULA, SUBSTRING(@causaAnteriorCaratula, 1,49), SUBSTRING(@causaCaratula, 1,49), 0, @usuario, (FORMAT(GETDATE(), ''HH:mm:ss'')));
				END

				IF EXISTS (SELECT 1 FROM DJ_CAUSA_CUENTA WHERE NRO_CAUSA=@causaId)
				BEGIN
					-- ACTUALIZAR NOMBRE DE CUENTA
					DECLARE @vtaCuentaNombre VARCHAR(250) = 
						SUBSTRING(CONCAT(
							CAST(@causaJuzgado AS VARCHAR(12)), ''/'', 
							CAST(@causaAno AS VARCHAR(4)), ''/'', 
							@causaExpediente, ''/'', 
							@causaCaratula
						), 1, 250);

					UPDATE VTA_SALDOS
					SET NOMBRE_CUENTA = @vtaCuentaNombre
					WHERE EXISTS (
						SELECT 1 
						FROM DJ_CAUSA_CUENTA dj
						WHERE dj.NRO_CAUSA = @causaId AND VTA_SALDOS.JTS_OID_SALDO = dj.JTS_OID_CUENTA
					);
				END;
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

    -- ACTUALIZAR NOMBRE DE CUENTA
    DECLARE @vtaCuentaNombre VARCHAR(250) = 
        SUBSTRING(CONCAT(
            CAST(@causaJuzgado AS VARCHAR(12)), ''/'', 
            CAST(@causaAno AS VARCHAR(4)), ''/'', 
            @causaExpediente, ''/'', 
            @causaCaratula
        ), 1, 250);

    UPDATE VTA_SALDOS
    SET NOMBRE_CUENTA = @vtaCuentaNombre
    WHERE EXISTS (
        SELECT 1 
        FROM @Temp_DJ_CAUSA_CUENTA T
        WHERE VTA_SALDOS.JTS_OID_SALDO = T.JTS_OID_CUENTA
    );

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

