EXECUTE('
CREATE OR ALTER                        PROCEDURE [dbo].[MIG_AJUSTO_INVENTARIO] 

@P_ID_PROCESO INT,
@P_DT_PROCESO DATE,

@P_RET_PROCESO INT OUTPUT,
@P_MSG_PROCESO VARCHAR(500) OUTPUT

AS

BEGIN


DECLARE TABLA CURSOR FOR 
SELECT SUCURSAL, C1730, MONEDA, SUM(C1604) AS C1604, SUM(C3958) AS SALDOMN 
FROM SALDOS (NOLOCK) WHERE C1827 IN (''PRE'', ''VIS'', ''DPF'', ''CHE'', ''RCT'',''SOB'',''LIS'',''CDD'',''UVA'') 
					 AND TZ_LOCK=0
GROUP BY SUCURSAL, C1730, MONEDA

DECLARE @W_EXISTE NUMERIC 
DECLARE @W_FECHA DATETIME 
DECLARE @W_RUBOPE NUMERIC 
DECLARE @W_FECHASYS VARCHAR(20); SET @W_FECHASYS =  (SELECT FECHAPROCESO FROM PARAMETROS (NOLOCK))
DECLARE @W_MENSAJE VARCHAR(500); SET @W_MENSAJE = ''''
DECLARE @W_SUCURSAL NUMERIC(3); SET @W_SUCURSAL = 0
DECLARE @W_C1730 NUMERIC(15); SET @W_C1730 = 0
DECLARE @W_MONEDA NUMERIC(4); SET @W_MONEDA = 0
DECLARE @W_C1604 NUMERIC(15,2); SET @W_C1604 = 0
DECLARE @W_SALDOMN NUMERIC(15,2); SET @W_SALDOMN = 0
DECLARE @W_JTS_OID NUMERIC (10)

DECLARE @p_modulo VARCHAR(30)
DECLARE @p_NomScr VARCHAR(30)
DECLARE @v_CICLO  SMALLINT 
DECLARE @v_PROCESO SMALLINT 
DECLARE @v_FECHASYS DATETIME

/*********************************************************************************
SETEO DE VARIABLES PRINCIPALES
***********************************************************************************/
SET @v_ciclo = 1
SET @v_proceso = 1
SET @v_FECHASYS = SYSDATETIME()

set @p_modulo	= ''AJUSTO_INV''
set @p_NomScr	= ''MIG_AJUSTO_INV''



	BEGIN TRY 

    OPEN TABLA 
    -- COMIENZO CURSOR -- 
    FETCH NEXT FROM TABLA INTO @W_SUCURSAL, @W_C1730, @W_MONEDA, @W_C1604, @W_SALDOMN
    WHILE @@FETCH_STATUS = 0 
    BEGIN
     
        SELECT @W_RUBOPE = C6340
        FROM PLANCTAS (NOLOCK)
        WHERE C6326 = @W_C1730

        IF @W_RUBOPE IS NULL 
        BEGIN 
            SET @W_RUBOPE = @W_C1730
        END
        
        SET @W_EXISTE = 0
        SELECT @W_EXISTE = COUNT(*)
        FROM SALDOS S (NOLOCK)
        WHERE S.SUCURSAL = @W_SUCURSAL 
          AND S.CUENTA = @W_C1730 
          AND S.MONEDA = @W_MONEDA 
          AND C1785 = 1
          AND S.PRODUCTO = 0 
          AND S.ORDINAL = 0 
          AND S.OPERACION = 0 
          AND C1827 NOT IN (''PRE'', ''VIS'', ''DPF'', ''CHE'', ''RCT'', ''SOB'', ''LIS'', ''CDD'', ''UVA'')
        -- Identifica los Saldos que no estan llegando en contabilidad --

        IF @W_EXISTE = 1
        BEGIN 
            UPDATE SALDOS 
            SET C1604 = (C1604 - @W_C1604),
                C3958 = (C3958 - @W_SALDOMN),
                C3959 = (C3959 - @W_SALDOMN) -- MIGNBCAR-2523
            WHERE SUCURSAL = @W_SUCURSAL 
              AND CUENTA = @W_C1730 
              AND C1785 = 1
              AND MONEDA = @W_MONEDA 
              AND PRODUCTO = 0 
              AND ORDINAL = 0 
              AND OPERACION = 0 
              AND C1827 NOT IN (''PRE'', ''VIS'', ''DPF'', ''CHE'', ''RCT'', ''SOB'', ''LIS'', ''CDD'', ''UVA'')
        END
        ELSE 
        BEGIN 
            IF @W_EXISTE = 0 
            BEGIN 
                INSERT INTO SALDOS (
                    SUCURSAL,  -- 1
                    PRODUCTO,  -- 2
                    MONEDA,    -- 3
                    CUENTA,    -- 4
                    ORDINAL,   -- 5
                    OPERACION, -- 6
                    C1620,     -- 7
                    C1730,     -- 8
                    C1604,     -- 9
                    C3958,     -- 10
                    C1804,     -- 11
                    C1785,     -- 12
                    C1692,     -- 13
                    C1827,     -- 14
                    TZ_LOCK,   -- 15
                    OBJETIVA_REFINANCIADO,
                    C50007,
                    C1621
                )
                VALUES (
                    @W_SUCURSAL,  -- 1
                    0,            -- 2
                    @W_MONEDA,    -- 3
                    @W_C1730,     -- 4
                    0,            -- 5
                    0,            -- 6
                    @W_FECHASYS,     -- 7
                    @W_C1730,     -- 8
                    (-@W_C1604),  -- 9
                    (-@W_SALDOMN),-- 10
                    @W_RUBOPE,    -- 11
                    1,            -- 12
                    @W_C1730,     -- 13
                    ''AJU'',        -- 14
                    0,            -- 15
                    '' '',          -- OBJETIVA_REFINANCIADO
                    '' '',          -- C50007
                    @W_FECHASYS      -- C1621
                )
            END
            ELSE
            BEGIN
                SET @W_MENSAJE = ''CUENTA:'' + CONVERT(VARCHAR, @W_C1730) 
                                 + '', MONEDA:'' + CONVERT(VARCHAR, @W_MONEDA) 
                                 + '', SUCURSAL:'' + CONVERT(VARCHAR, @W_SUCURSAL) 
                                 + '', ENCONTRADOS:'' + CONVERT(VARCHAR, @W_EXISTE);
                INSERT INTO MIG_ERRORES (
                    MODULO,
                    TABLA,
                    MENSAJE,
                    FECHA_TRATAMIENTO
                )
                VALUES (
                    ''CONTA'',
                    ''SALDOS'',
                    @W_MENSAJE,
                    @W_FECHASYS
                )
            END 
        END 

        -- OBTENGO EL SIGUIENTE REGISTRO -- 
        FETCH NEXT FROM TABLA INTO @W_SUCURSAL, @W_C1730, @W_MONEDA, @W_C1604, @W_SALDOMN
    END
    -- CIERRO CURSOR -- 
    CLOSE TABLA
    DEALLOCATE TABLA
		--
	 SET @P_RET_PROCESO = 1
	 SET @P_MSG_PROCESO = ''Proceso ejecutado con exito. ''
	--

	INSERT INTO MIG_RESULTADOS
					(CICLO, PROCESO, MODULO, FECHAINICIO, FECHAFIN, ESTADO, ERRORES, MENSAJE, ARCHIVO)
				VALUES
				   (@v_CICLO,
					@v_PROCESO,
					@p_MODULO,
					@v_FECHASYS,
					SYSDATETIME(),
					''A'',
					''N'',
				    ''OK'',
					''MIG_AJU_INVENT'')
   	   END TRY

	   BEGIN CATCH 
	   CLOSE TABLA
	   DEALLOCATE TABLA 
	   

	

	   INSERT INTO MIG_RESULTADOS
					(CICLO, PROCESO, MODULO, FECHAINICIO, FECHAFIN, ESTADO, ERRORES, MENSAJE, ARCHIVO)
				VALUES
				   (@v_CICLO,
					@v_PROCESO,
					@p_MODULO,
					@v_FECHASYS,
					SYSDATETIME(),
					''A'',
					''N'',
				    ERROR_MESSAGE(),
					''MIG_AJU_INVENT'')

	 END CATCH

END
')