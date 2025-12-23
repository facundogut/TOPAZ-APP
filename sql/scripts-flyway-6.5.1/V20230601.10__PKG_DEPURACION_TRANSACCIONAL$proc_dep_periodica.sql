execute('
create or alter PROCEDURE [dbo].[PKG_DEPURACION_TRANSACCIONAL$proc_dep_periodica]

@p_id_proceso float(53),
@p_dt_proceso datetime,
@DB_NAME 		SYSNAME,
@p_ret_proceso float(53)  OUTPUT,
@p_msg_proceso varchar(max)  OUTPUT

AS 
 BEGIN
    DECLARE
	@v_fecha	datetime,
	@v_where	nvarchar(max),
	@v_meses numeric,
	@v_stmt 	nvarchar(max),
	@v_old_name	nvarchar(30),
	@v_tabla	nvarchar(30)		

	-- Manejo de Error
	DECLARE
	@c_log_cod_warning numeric,
	@c_log_cod_sin_error numeric,
	@c_log_user_exception numeric,
	@c_log_error numeric,
	@c_version varchar(max),
    
	@c_log_tipo_error varchar(1),
	@c_log_tipo_version varchar(1),
	@c_log_tipo_informacion varchar(1),
	@c_log_tipo_warning varchar(1)
	

    SET @c_version = ''Versión 1.0'' 

	SET @c_log_cod_warning = 3
	SET @c_log_cod_sin_error = 1
	SET @c_log_user_exception = 2
	SET @c_log_error = 2

	SET @c_log_tipo_error       = ''E''
	SET @c_log_tipo_version     = ''V''
	SET @c_log_tipo_informacion = ''I''
	SET @c_log_tipo_warning     = ''W''

BEGIN TRY

	SET @p_ret_proceso = NULL
	SET @p_msg_proceso = NULL
	
	SELECT @v_meses = PERIODO FROM PARAMETROS_DEPURACION WHERE MODULO = ''TRANSACCIONAL'' AND ID = ''TRANSACCIONAL'' AND TZ_LOCK = 0;		
	SET @v_fecha = DATEADD(dd, - DATEPART(dd, dateadd(mm, -1 * @v_meses, @p_dt_proceso)) + 1, dateadd(mm, -1 * @v_meses, @p_dt_proceso)); 
	
	----------------------------------------------------------------------------------
	SET @v_tabla = ''ASIENTOS''
	SET @v_old_name = SUBSTRING(@v_tabla, 0, 18) + ''_OLD_'' + replace(convert(VARCHAR,getdate(), 104), ''.'' , '''');
	SET @v_stmt = ''SELECT * INTO '' + @v_old_name + '' FROM '' + @v_tabla + '' with (nolock) '' + '' WHERE 1 = 0'';
	print ''Creando tabla de BACKUP '' + @v_old_name;
	EXECUTE(@v_stmt);	
		
	SET @v_where = ''ASIENTOS.FECHAPROCESO < @fecha''				
	EXECUTE PKG_DEPURACION$proc_dep_periodica @p_id_proceso,
													@p_dt_proceso,
													@v_tabla,
													''PKG_DEPURACION_TRANSACCIONAL$proc_dep_periodica'',
													'''',
													@v_where,
													''FECHAPROCESO'',
													@v_fecha,
													@DB_NAME,
													@p_ret_proceso OUT,
													@p_msg_proceso OUT;	
	----------------------------------------------------------------------------------
	
	----------------------------------------------------------------------------------
	SET @v_tabla = ''MOVIMIENTOS''
	SET @v_old_name = SUBSTRING(@v_tabla, 0, 18) + ''_OLD_'' + replace(convert(VARCHAR,getdate(), 104), ''.'' , '''');
	SET @v_stmt = ''SELECT * INTO '' + @v_old_name + '' FROM '' + @v_tabla + '' with (nolock) '' + '' WHERE 1 = 0'';
	print ''Creando tabla de BACKUP '' + @v_old_name;
	EXECUTE(@v_stmt);	
			
	SET @v_where = ''MOVIMIENTOS.FECHAPROCESO < @fecha''
	EXECUTE PKG_DEPURACION$proc_dep_periodica @p_id_proceso,
													@p_dt_proceso,
													@v_tabla,
													''PKG_DEPURACION_TRANSACCIONAL$proc_dep_periodica'',
													'''',
													@v_where,
													''FECHAPROCESO'',
													@v_fecha,
													@DB_NAME,
													@p_ret_proceso OUT,
													@p_msg_proceso OUT;	
	----------------------------------------------------------------------------------
	
	----------------------------------------------------------------------------------
	SET @v_tabla = ''AUTORIZACIONES''
	SET @v_old_name = SUBSTRING(@v_tabla, 0, 18) + ''_OLD_'' + replace(convert(VARCHAR,getdate(), 104), ''.'' , '''');
	SET @v_stmt = ''SELECT * INTO '' + @v_old_name + '' FROM '' + @v_tabla + '' with (nolock) '' + '' WHERE 1 = 0'';
	print ''Creando tabla de BACKUP '' + @v_old_name;
	EXECUTE(@v_stmt);	
			
	SET @v_where = ''AUTORIZACIONES.FECHAPROCESO < @fecha''
	EXECUTE PKG_DEPURACION$proc_dep_periodica @p_id_proceso,
													@p_dt_proceso,
													@v_tabla,
													''PKG_DEPURACION_TRANSACCIONAL$proc_dep_periodica'',
													'''',
													@v_where,
													''FECHAPROCESO'',
													@v_fecha,
													@DB_NAME,
													@p_ret_proceso OUT,
													@p_msg_proceso OUT;	
	----------------------------------------------------------------------------------
	
	----------------------------------------------------------------------------------
	SET @v_tabla = ''HISTORY''
	SET @v_old_name = SUBSTRING(@v_tabla, 0, 18) + ''_OLD_'' + replace(convert(VARCHAR,getdate(), 104), ''.'' , '''');
	SET @v_stmt = ''SELECT * INTO '' + @v_old_name + '' FROM '' + @v_tabla + '' with (nolock) '' + '' WHERE 1 = 0'';
	print ''Creando tabla de BACKUP '' + @v_old_name;
	EXECUTE(@v_stmt);	
	
	SET @v_stmt = ''ALTER TABLE '' + @v_old_name + '' DROP COLUMN JTS_OID; ALTER TABLE '' + @v_old_name + '' ADD JTS_OID INT;''
	EXECUTE (@v_stmt);
				
	SET @v_where = ''HISTORY.PROCESSDATE < @fecha''
	EXECUTE PKG_DEPURACION$proc_dep_periodica @p_id_proceso,
													@p_dt_proceso,
													@v_tabla,
													''PKG_DEPURACION_TRANSACCIONAL$proc_dep_periodica'',
													'''',
													@v_where,
													''PROCESSDATE'',
													@v_fecha,
													@DB_NAME,
													@p_ret_proceso OUT,
													@p_msg_proceso OUT;	
	----------------------------------------------------------------------------------
	
	----------------------------------------------------------------------------------
	SET @v_tabla = ''REPORTS''
	SET @v_old_name = SUBSTRING(@v_tabla, 0, 18) + ''_OLD_'' + replace(convert(VARCHAR,getdate(), 104), ''.'' , '''');
	SET @v_stmt = ''SELECT * INTO '' + @v_old_name + '' FROM '' + @v_tabla + '' with (nolock) '' + '' WHERE 1 = 0'';
	print ''Creando tabla de BACKUP '' + @v_old_name;
	EXECUTE(@v_stmt);	
				
	SET @v_stmt = ''ALTER TABLE '' + @v_old_name + '' DROP COLUMN JTS_OID; ALTER TABLE '' + @v_old_name + '' ADD JTS_OID INT;''
	EXECUTE (@v_stmt);
	
	SET @v_where = ''REPORTS.PROCESSDATE < @fecha''
	EXECUTE PKG_DEPURACION$proc_dep_periodica @p_id_proceso,
													@p_dt_proceso,
													@v_tabla,
													''PKG_DEPURACION_TRANSACCIONAL$proc_dep_periodica'',
													'''',
													@v_where,
													''PROCESSDATE'',
													@v_fecha,
													@DB_NAME,
													@p_ret_proceso OUT,
													@p_msg_proceso OUT;	
	----------------------------------------------------------------------------------
	
	----------------------------------------------------------------------------------
	SET @v_tabla = ''STOREREPORTS''
	SET @v_old_name = SUBSTRING(@v_tabla, 0, 18) + ''_OLD_'' + replace(convert(VARCHAR,getdate(), 104), ''.'' , '''');
	SET @v_stmt = ''SELECT * INTO '' + @v_old_name + '' FROM '' + @v_tabla + '' with (nolock) '' + '' WHERE 1 = 0'';
	print ''Creando tabla de BACKUP '' + @v_old_name;
	EXECUTE(@v_stmt);	
				
	SET @v_where = ''STOREREPORTS.FECHAPROCESO < @fecha''
	EXECUTE PKG_DEPURACION$proc_dep_periodica @p_id_proceso,
													@p_dt_proceso,
													@v_tabla,
													''PKG_DEPURACION_TRANSACCIONAL$proc_dep_periodica'',
													'''',
													@v_where,
													''FECHAPROCESO'',
													@v_fecha,
													@DB_NAME,
													@p_ret_proceso OUT,
													@p_msg_proceso OUT;	
	----------------------------------------------------------------------------------
	
	----------------------------------------------------------------------------------
	SET @v_tabla = ''MENSAJESCOMM''
	SET @v_old_name = SUBSTRING(@v_tabla, 0, 18) + ''_OLD_'' + replace(convert(VARCHAR,getdate(), 104), ''.'' , '''');
	SET @v_stmt = ''SELECT * INTO '' + @v_old_name + '' FROM '' + @v_tabla + '' with (nolock) '' + '' WHERE 1 = 0'';
	print ''Creando tabla de BACKUP '' + @v_old_name;
	EXECUTE(@v_stmt);

	SET @v_stmt = ''ALTER TABLE '' + @v_old_name + '' DROP COLUMN JTS_OID; ALTER TABLE '' + @v_old_name + '' ADD JTS_OID INT;''
	EXECUTE (@v_stmt);	
				
	SET @v_where = ''MENSAJESCOMM.PROCESSDATE < @fecha''
	EXECUTE PKG_DEPURACION$proc_dep_periodica @p_id_proceso,
													@p_dt_proceso,
													@v_tabla,
													''PKG_DEPURACION_TRANSACCIONAL$proc_dep_periodica'',
													'''',
													@v_where,
													''PROCESSDATE'',
													@v_fecha,
													@DB_NAME,
													@p_ret_proceso OUT,
													@p_msg_proceso OUT;	
	----------------------------------------------------------------------------------
	
	----------------------------------------------------------------------------------
	SET @v_tabla = ''SERVERTASK''
	SET @v_old_name = SUBSTRING(@v_tabla, 0, 18) + ''_OLD_'' + replace(convert(VARCHAR,getdate(), 104), ''.'' , '''');
	SET @v_stmt = ''SELECT * INTO '' + @v_old_name + '' FROM '' + @v_tabla + '' with (nolock) '' + '' WHERE 1 = 0'';
	print ''Creando tabla de BACKUP '' + @v_old_name;
	EXECUTE(@v_stmt);
	
	SET @v_stmt = ''ALTER TABLE '' + @v_old_name + '' DROP COLUMN JTS_OID; ALTER TABLE '' + @v_old_name + '' ADD JTS_OID INT;''
	EXECUTE (@v_stmt);
			
	SET @v_where = ''SERVERTASK.PROCESSDATE < @fecha''
	EXECUTE PKG_DEPURACION$proc_dep_periodica @p_id_proceso,
													@p_dt_proceso,
													@v_tabla,
													''PKG_DEPURACION_TRANSACCIONAL$proc_dep_periodica'',
													'''',
													@v_where,
													''PROCESSDATE'',
													@v_fecha,
													@DB_NAME,
													@p_ret_proceso OUT,
													@p_msg_proceso OUT;															
	---------------------------------------------------------------------------------- 													
END TRY

BEGIN CATCH

    SET @p_msg_proceso = ''El proceso PKG_DEPURACION_TRANSACCIONAL$proc_dep_periodica produjo un error. Error original: '' + ERROR_MESSAGE() + '' Linea: '' + CAST(ERROR_LINE() AS VARCHAR(50));	

	print @p_msg_proceso
	
	SET @p_ret_proceso = @c_log_error

	-- Logueo de información
    EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso @p_id_proceso,
                                         @p_dt_proceso,
                                         ''PKG_DEPURACION_TRANSACCIONAL'',
                                         @c_log_error,
                                         @p_msg_proceso,
                                         @c_log_tipo_version;

END CATCH

END
; ')

