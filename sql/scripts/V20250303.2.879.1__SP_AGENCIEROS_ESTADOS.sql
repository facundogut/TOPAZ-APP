EXECUTE('
CREATE OR ALTER PROCEDURE SP_AGENCIEROS_ESTADOS
   @FECHA_REND       VARCHAR(8),
   @SIGNO            NUMERIC(1),
   @ID_RENDICION     NUMERIC(15),
   @P_RESULTADO      VARCHAR(5) OUTPUT
   
AS 
BEGIN
    SET NOCOUNT ON;
    SET @P_RESULTADO = ''ERROR'';
    DECLARE @Fecha NUMERIC(8);
     SET @Fecha = @FECHA_REND;
    -- Crear una tabla temporal
    DECLARE @TablaAux TABLE(
        ID                       NUMERIC(15),
        FECHA_COBRO_PAGO         DATETIME2,
        SIGNO                    NUMERIC(1),
        ACREDITACION             VARCHAR(3),
        FECHA_REND               VARCHAR(8)
    );

    BEGIN TRY
        -- Iniciar transacción explícita
        BEGIN TRANSACTION;
        
        -- Insertar datos en la tabla temporal con conversión de fecha correcta
        INSERT INTO @TablaAux
        SELECT 
            VW_RENDICION_ID_AGENCIEROS.ID, 
            VW_RENDICION_ID_AGENCIEROS.FECHA_COBRO_PAGO,
            VW_RENDICION_ID_AGENCIEROS.SIGNO, 
            VW_RENDICION_ID_AGENCIEROS.ACREDITACION, 
            VW_RENDICION_ID_AGENCIEROS.FECHA_REND
        FROM VW_RENDICION_ID_AGENCIEROS
        WHERE VW_RENDICION_ID_AGENCIEROS.FECHA_REND =CONVERT(VARCHAR, @Fecha,112) 
        AND VW_RENDICION_ID_AGENCIEROS.SIGNO = @SIGNO;
        
        -- Actualizar la tabla REC_Agencieros
        UPDATE REC_Agencieros
        SET
            ESTADO_REND = ''R'',
            ID_RENDICION = @ID_RENDICION
        FROM REC_Agencieros A
        JOIN @TablaAux C ON A.ID = C.ID
        WHERE A.TZ_LOCK = 0;
        
        -- Confirmar la transacción
        COMMIT TRANSACTION;
        
        SET @P_RESULTADO = ''OK'';
    END TRY
    BEGIN CATCH
        -- Si hay un error, revertir la transacción
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        SET @P_RESULTADO = ''ERROR'';
        
        
    END CATCH;
END

')
