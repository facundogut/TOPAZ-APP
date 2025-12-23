execute('
CREATE or alter PROCEDURE [dbo].[PKG_DP_CONTABILIDAD_BR$proc_dep_periodica]

@p_id_proceso float(53),
@p_dt_proceso datetime,
@DB_NAME 		SYSNAME,
@p_ret_proceso float(53)  OUTPUT,
@p_msg_proceso varchar(max)  OUTPUT

AS 
 BEGIN
    DECLARE
	@v_fecha	datetime,
	@v_fecha2	datetime,
	@v_where	nvarchar(max),
	@v_anios numeric,
	@v_anios2 numeric,
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
	
	SELECT @v_anios = PERIODO FROM PARAMETROS_DEPURACION WHERE MODULO = ''CONTABILIDAD'' AND ID = ''BALANCES_DIARIOS'' AND TZ_LOCK = 0;
	SELECT @v_anios2 = PERIODO FROM PARAMETROS_DEPURACION WHERE MODULO = ''CONTABILIDAD'' AND ID = ''BALANCES_MENSUALES'' AND TZ_LOCK = 0;
	
	SET @v_fecha = DATEADD(dd, - DATEPART(dd, dateadd(mm, -12 * @v_anios, @p_dt_proceso)) + 1, dateadd(mm, -12 * @v_anios, @p_dt_proceso)); --Resto el parametro en años y tomo el principio del mes.
	SET @v_fecha2 = DATEADD(dd, - DATEPART(dd, dateadd(mm, -12 * @v_anios2, @p_dt_proceso)) + 1, dateadd(mm, -12 * @v_anios2, @p_dt_proceso)); --Resto el parametro en años y tomo el principio del mes.
	
	----------------------------------------------------------------------------------
	SET @v_tabla = ''CO_BALANCE_RESULTADOS''
	SET @v_old_name = SUBSTRING(@v_tabla, 0, 18) + ''_OLD_'' + replace(convert(VARCHAR,getdate(), 104), ''.'' , '''');
	SET @v_stmt = ''SELECT * INTO '' + @v_old_name + '' FROM '' + @v_tabla + '' with (nolock) '' + '' WHERE 1 = 0'';
	print ''Creando tabla de BACKUP '' + @v_old_name;
	EXECUTE(@v_stmt);	
	
	SET @v_where = ''(CO_BALANCE_RESULTADOS.FECHA < @fecha and CO_BALANCE_RESULTADOS.TIPO_BALANCE = ''''D'''') 
				OR (CO_BALANCE_RESULTADOS.FECHA < @fecha2 and (CO_BALANCE_RESULTADOS.TIPO_BALANCE = ''''M'''' OR CO_BALANCE_RESULTADOS.TIPO_BALANCE = ''''S''''))''				
	EXECUTE PKG_DEPURACION$proc_dep_periodica_2 @p_id_proceso,
													@p_dt_proceso,
													@v_tabla,
													''PKG_DP_CONTABILIDAD_BR$proc_dep_periodica'',
													'''',
													@v_where,
													'' FECHA, TIPO_BALANCE '',
													@v_fecha,
													@v_fecha2,
													@DB_NAME,
													@p_ret_proceso OUT,
													@p_msg_proceso OUT;	
	----------------------------------------------------------------------------------													
END TRY

BEGIN CATCH

    SET @p_msg_proceso = ''El proceso PKG_DP_CONTABILIDAD_BR$proc_dep_periodica produjo un error. Error original: '' + ERROR_MESSAGE() + '' Linea: '' + CAST(ERROR_LINE() AS VARCHAR(50));	

	print @p_msg_proceso
	
	SET @p_ret_proceso = @c_log_error

	-- Logueo de información
    EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso @p_id_proceso,
                                         @p_dt_proceso,
                                         ''PKG_DP_CONTABILIDAD_BR'',
                                         @c_log_error,
                                         @p_msg_proceso,
                                         @c_log_tipo_version;

END CATCH

END
; ')

