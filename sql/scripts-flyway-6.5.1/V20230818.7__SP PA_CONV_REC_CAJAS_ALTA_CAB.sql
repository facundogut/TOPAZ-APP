EXECUTE('
CREATE OR ALTER PROCEDURE PA_CONV_REC_CAJAS_ALTA_CAB
/*EL PA CORRE EN CADENA DE INCIO Y CREA LOS CABEZALES PARA LOS CONVENIOS
  ACTIVOS DE TIPO 4 Y DE CANAL 1*/ 
@P_ID_PROCESO float(53),
@P_DT_PROCESO  datetime2(0),
@P_RET_PROCESO float(53)  OUTPUT,
@P_MSG_PROCESO varchar(max)  OUTPUT

AS

BEGIN
    SET @P_RET_PROCESO = NULL;
    SET @P_MSG_PROCESO = NULL;

    DECLARE @fecha_proceso DATETIME;
    DECLARE @str_archivo VARCHAR(24);
    DECLARE @estado VARCHAR(1);
    DECLARE @last_id NUMERIC(15);
    DECLARE @moneda NUMERIC(5);
    DECLARE @count NUMERIC(10);
	DECLARE @v_constante VARCHAR(1); --Constante para loguear información o error
    
    -- Instanciamos variables
    SELECT @fecha_proceso = FECHAPROCESO FROM PARAMETROS WITH (nolock);
    SET @str_archivo = ''REC_CAJA_'';
    SET @estado = ''I'';
    SELECT @last_id = MAX(ID) FROM REC_CAB_RECAUDOS_CAJA WITH (nolock);
    SELECT @moneda = MONNAC FROM PARAMETROS WITH (nolock);
    SET @count = 0;
    
    -- Creamos tabla temporal para almacenar los convenios que ya existen
    CREATE TABLE #cab_existentes (convenio NUMERIC(15));
    
    BEGIN TRY
    
	    -- Insertamos los convenios existentes en la tabla temporal
	    INSERT INTO #cab_existentes (convenio)
	    SELECT CONVENIO
	    FROM REC_CAB_RECAUDOS_CAJA with (nolock)
	    WHERE 
	    	FECHACARGA = @fecha_proceso
			AND ((TZ_LOCK < 100000000000000 OR TZ_LOCK >= 200000000000000)
				AND (TZ_LOCK < 300000000000000 OR TZ_LOCK >= 400000000000000)  
			);
	    
	    -- Insertamos nuevas filas en REC_CAB_RECAUDOS_CAJA 
	    INSERT INTO REC_CAB_RECAUDOS_CAJA (ID, ESTADO, ARCHIVO, CONVENIO, FECHACARGA, ID_LIQUIDACION, MONEDA, TOTALREGISTROS, TOTALIMPORTE, TZ_LOCK)
	    SELECT (@last_id + ROW_NUMBER() OVER (ORDER BY Id_ConvRec ASC)) AS ID,
	           @estado AS ESTADO,
	           CONCAT(@str_archivo, Id_ConvRec) AS ARCHIVO,
	           Id_ConvRec AS CONVENIO,
	           @fecha_proceso AS FECHACARGA,
	           0 AS ID_LIQUIDACION,
	           @moneda AS MONEDA,
	           0 AS TOTALREGISTROS,
	           0 AS TOTALIMPORTE,
	           0 AS TZ_LOCK
	    FROM CONV_CONVENIOS_REC WITH (nolock)
	    WHERE Canal = 1
	        AND Id_TpoConv = 4
	        AND Estado = ''A''
			AND ((TZ_LOCK < 100000000000000 OR TZ_LOCK >= 200000000000000)
				AND (TZ_LOCK < 300000000000000 OR TZ_LOCK >= 400000000000000)  
			)
	        AND NOT EXISTS (
	            SELECT 1
	            FROM #cab_existentes
	            WHERE CONVENIO = Id_ConvRec
	        );
	    
	    SET @count = @@ROWCOUNT; -- número de filas insertadas
	    
	    -- Limpiamos la tabla temporal
	    DROP TABLE #cab_existentes;
	    
	    SET @P_RET_PROCESO = 1;
	    SET @P_MSG_PROCESO = CONCAT(''Creación de cabeceras funcionó correctamente, se crearon '', @count, '' cabeceras'');
	    
	    EXECUTE dbo.pkg_constantes$VarcharConstantes ''C_LOG_TIPO_INFORMACION'', @v_constante OUTPUT;	
	    EXECUTE dbo.PKG_LOG_PROCESO$PROC_INS_LOG_PROCESO 
	       @P_ID_PROCESO = @P_ID_PROCESO, 
	       @P_FCH_PROCESO = @P_DT_PROCESO, 
	       @P_NOM_PACKAGE = ''PA_CONV_REC_CAJAS_ALTA_CAB'', 
	       @P_COD_ERROR = @P_RET_PROCESO, 
	       @P_MSG_ERROR = @P_MSG_PROCESO, 
	       @P_TIPO_ERROR = @v_constante
	END TRY
	
	BEGIN CATCH
        DECLARE
           @errornumber int
        SET @errornumber = ERROR_NUMBER()
        DECLARE
           @errormessage nvarchar(4000)
        SET @errormessage = ERROR_MESSAGE()
        BEGIN
           SET @P_RET_PROCESO = ERROR_NUMBER()
           SET @P_MSG_PROCESO = ''Error en la creación de cabeceras de convenios de recaudos por caja. '' + @errormessage
           EXECUTE dbo.pkg_constantes$VarcharConstantes ''C_LOG_TIPO_ERROR'', @v_constante OUTPUT;
           EXECUTE dbo.PKG_LOG_PROCESO$PROC_INS_LOG_PROCESO 
              @P_ID_PROCESO = @P_ID_PROCESO, 
              @P_FCH_PROCESO = @P_DT_PROCESO, 
              @P_NOM_PACKAGE = ''PA_CONV_REC_CAJAS_ALTA_CAB'', 
              @P_COD_ERROR = @P_RET_PROCESO, 
              @P_MSG_ERROR = @P_MSG_PROCESO, 
              @P_TIPO_ERROR = @v_constante
        END
     END CATCH
	
END
')

