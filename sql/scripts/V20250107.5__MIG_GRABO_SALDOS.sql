EXECUTE('
CREATE OR ALTER                              PROCEDURE [dbo].[MIG_GRABO_SALDOS]

/*********************************************************************************
Modulo  : CUENTASVISTA
Tabla   : SALDOS
Version : 30/09/2024 
Tarea   : MIGNBCAR-2691
***********************************************************************************/

@P_ID_PROCESO INT,
@P_DT_PROCESO DATE,
@V_TABLAAGRABAR VARCHAR(100),

@P_RET_PROCESO INT OUTPUT,
@P_MSG_PROCESO VARCHAR(500) OUTPUT

AS
BEGIN


----------Definicion Variables Intermedias----

DECLARE @p_MODULO VARCHAR(30)
DECLARE @v_FECHASYS datetime
DECLARE @p_NomScr VARCHAR(30)
DECLARE @v_CICLO smallint
DECLARE @v_PROCESO smallint

DECLARE @v_CANT_FINAL numeric(8)

DECLARE @SQL NVARCHAR(MAX);

--------------------------------------------
SET @v_FECHASYS=SYSDATETIME()
SET @v_CICLO = 1
SET @v_PROCESO = 1
SET @p_MODULO = ''CUENTASVISTA''
SET @p_NomScr = ''GRABASALDO''
--

-- Verifico si la tabla existe
IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = @V_TABLAAGRABAR)

	BEGIN
		-- Si la tabla existe, la truncamos
		SET @SQL = ''DROP TABLE '' + QUOTENAME(@V_TABLAAGRABAR);
		EXEC sp_executesql @SQL;
	END

 
--Inserto
	SET @SQL = ''SELECT * INTO '' + QUOTENAME(@V_TABLAAGRABAR) + '' FROM SALDOS(nolock)'';
    EXEC sp_executesql @SQL;
--
	
--Contabilizo
	SET @SQL = ''SELECT @v_CANT_FINAL = COUNT(*) FROM '' + QUOTENAME(@V_TABLAAGRABAR) + ''(nolock)'';
    EXEC sp_executesql @SQL, N''@v_CANT_FINAL INT OUTPUT'', @v_CANT_FINAL OUTPUT;
--


---
	 SET @P_RET_PROCESO = 1
	 SET @P_MSG_PROCESO = ''Se insertaron '' + STR(@v_CANT_FINAL) + '' registros en la tabla: '' + @V_TABLAAGRABAR
---	 


   BEGIN TRANSACTION
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
					@p_NomScr)
		COMMIT;


END
')