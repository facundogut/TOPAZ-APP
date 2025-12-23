EXECUTE('
CREATE OR ALTER PROCEDURE SP_CLI_MAXIMO_SIRCREB
    @P_PERSONAS VARCHAR(100),
    @P_RET_PROCESO FLOAT OUT,
    @P_MSG_PROCESO VARCHAR(MAX) OUT,
    @P_SIRCREB VARCHAR(2) OUT
AS
BEGIN
    SET @P_RET_PROCESO = NULL;
    SET @P_MSG_PROCESO = NULL;
 
    BEGIN TRY
        DECLARE @V_SIRCREB VARCHAR(12);
 
       
        DECLARE @Tabla_SIRCREB TABLE (
            SIRCREB VARCHAR(2)
        );
 
        
        INSERT INTO @Tabla_sircreb (SIRCREB)
        SELECT PF.SIRCREB
        FROM CLI_PERSONASFISICAS PF WITH (NOLOCK)
        WHERE PF.NUMEROPERSONAFISICA IN (SELECT value FROM STRING_SPLIT(@P_PERSONAS, '',''))
          AND PF.TZ_LOCK = 0
        ORDER BY PF.SIRCREB DESC;
 
       
        IF EXISTS (SELECT 1 FROM @Tabla_SIRCREB)
        BEGIN
            SET @P_SIRCREB = (
                SELECT TOP 1 ts.SIRCREB
                FROM @Tabla_SIRCREB ts
                ORDER BY ts.SIRCREB DESC
            );
 
            SET @P_MSG_PROCESO = ''Se encontro maximo sircreb'';
            SET @P_RET_PROCESO = 1;
           END
 
    END TRY
    BEGIN CATCH
        SET @P_SIRCREB = NULL;
        SET @P_RET_PROCESO = ERROR_NUMBER();
        SET @P_MSG_PROCESO = ''No se encontro Sircreb'';
    END CATCH;
END;
')