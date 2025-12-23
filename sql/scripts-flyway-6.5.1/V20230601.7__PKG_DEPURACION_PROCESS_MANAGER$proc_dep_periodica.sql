execute('
CREATE or alter PROCEDURE [dbo].[PKG_DEPURACION_PROCESS_MANAGER$proc_dep_periodica] 
  @p_id_proceso FLOAT(53), 
  @p_dt_proceso DATETIME, 
  @DB_NAME SYSNAME, 
  @p_ret_proceso FLOAT(53) output, 
  @p_msg_proceso VARCHAR(max) output 
AS 
  BEGIN 
    DECLARE @v_fecha DATETIME, 
      @v_where       NVARCHAR(max), 
      @v_meses       NUMERIC, 
      @v_stmt        NVARCHAR(max), 
      @v_old_name    NVARCHAR(30), 
      @v_tabla       NVARCHAR(30) 
      -- Manejo de Error 
    DECLARE @c_log_cod_warning NUMERIC, 
      @c_log_cod_sin_error     NUMERIC, 
      @c_log_user_exception    NUMERIC, 
      @c_log_error             NUMERIC, 
      @c_version               VARCHAR(max), 
      @c_log_tipo_error        VARCHAR(1), 
      @c_log_tipo_version      VARCHAR(1), 
      @c_log_tipo_informacion  VARCHAR(1), 
      @c_log_tipo_warning      VARCHAR(1) 
    SET @c_version = ''Versión 1.0'' 
    SET @c_log_cod_warning = 3 
    SET @c_log_cod_sin_error = 1 
    SET @c_log_user_exception = 2 
    SET @c_log_error = 2 
    SET @c_log_tipo_error = ''E'' 
    SET @c_log_tipo_version = ''V'' 
    SET @c_log_tipo_informacion = ''I'' 
    SET @c_log_tipo_warning = ''W'' 
    BEGIN try 
	  SET ANSI_NULLS ON
	  SET NOCOUNT ON
      SET @p_ret_proceso = NULL 
      SET @p_msg_proceso = NULL 
      SELECT @v_meses = periodo 
      FROM   parametros_depuracion 
      WHERE  modulo = ''PROCESS_MANAGER'' 
      AND    id = ''PROCESS_MANAGER'' 
      AND    tz_lock = 0; 
       
      SET @v_fecha = Dateadd(dd, - Datepart(dd, Dateadd(mm, -1 * @v_meses, @p_dt_proceso)) + 1, Dateadd(mm, -1 * @v_meses, @p_dt_proceso));
      ---------------------------------------------------------------------------------- 
      SET @v_tabla = ''PM_BTPROCESS'' 
      SET @v_old_name = Substring(@v_tabla, 0, 18) + ''_OLD_'' + Replace(CONVERT(VARCHAR,Getdate(), 104), ''.'' , '''');
      SET @v_stmt = ''SELECT * INTO ''               + @v_old_name + '' FROM '' + @v_tabla + '' with (nolock) '' + '' WHERE 1 = 0'';
      PRINT ''Creando tabla de BACKUP ''             + @v_old_name; 
      EXECUTE(@v_stmt); 
      SET @v_where = ''PM_BTPROCESS.INIT_TIME < @fecha'' 
	  
	  SET @v_stmt = ''ALTER TABLE '' + @v_old_name + '' DROP COLUMN Execution_ID; ALTER TABLE '' + @v_old_name + '' ADD Execution_ID INT;''
	  EXECUTE (@v_stmt);
	  
      EXECUTE pkg_depuracion$proc_dep_periodica @p_id_proceso, 
												@p_dt_proceso, 
												@v_tabla, 
												''PKG_DEPURACION_PROCESS_MANAGER$proc_dep_periodica'', 
												'''', 
												@v_where, 
												''INIT_TIME'',
												@v_fecha, 
												@DB_NAME, 									
												@p_ret_proceso out, 
												@p_msg_proceso out; 
      ---------------------------------------------------------------------------------- 
      ---------------------------------------------------------------------------------- 
      SET @v_tabla = ''LOG_PROCESO'' 
      SET @v_old_name = Substring(@v_tabla, 0, 18) + ''_OLD_'' + Replace(CONVERT(VARCHAR,Getdate(), 104), ''.'' , '''');
      SET @v_stmt = ''SELECT * INTO ''               + @v_old_name + '' FROM '' + @v_tabla + '' with (nolock) '' + '' WHERE 1 = 0'';
      PRINT ''Creando tabla de BACKUP ''             + @v_old_name; 
      EXECUTE(@v_stmt); 

	  SET @v_stmt = ''ALTER TABLE '' + @v_old_name + '' DROP COLUMN ID_ORDINAL; ALTER TABLE '' + @v_old_name + '' ADD ID_ORDINAL INT;''
	  EXECUTE (@v_stmt);
	  
      SET @v_where = ''LOG_PROCESO.FECHA_ERROR < @fecha'' 
	  EXECUTE pkg_depuracion$proc_dep_periodica @p_id_proceso, 
												@p_dt_proceso, 
												@v_tabla, 
												''PKG_DEPURACION_PROCESS_MANAGER$proc_dep_periodica'', 
												'''', 
												@v_where,
												''FECHA_ERROR'', 
												@v_fecha, 
												@DB_NAME,										
												@p_ret_proceso out, 
												@p_msg_proceso out; 
    END try 
    BEGIN catch 
      SET @p_msg_proceso = ''El proceso PKG_DEPURACION_PROCESS_MANAGER$proc_dep_periodica produjo un error. Error original: '' + Error_message() + '' Linea: '' + Cast(Error_line() AS VARCHAR(50));
      PRINT @p_msg_proceso 
      SET @p_ret_proceso = @c_log_error 
      -- Logueo de información 
      EXECUTE pkg_log_proceso$proc_ins_log_proceso 
        @p_id_proceso, 
        @p_dt_proceso, 
        ''PKG_DEPURACION_PROCESS_MANAGER'', 
        @c_log_error, 
        @p_msg_proceso, 
        @c_log_tipo_version; 
    END catch 
  END
; ')