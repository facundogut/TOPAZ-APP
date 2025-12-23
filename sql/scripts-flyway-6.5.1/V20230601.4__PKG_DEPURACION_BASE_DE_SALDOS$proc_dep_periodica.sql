execute('
CREATE or alter PROCEDURE [dbo].[PKG_DEPURACION_BASE_DE_SALDOS$proc_dep_periodica]

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
	SET ANSI_NULLS ON
	SET NOCOUNT ON

	SET @p_ret_proceso = NULL
	SET @p_msg_proceso = NULL
	
	SELECT @v_meses = PERIODO FROM PARAMETROS_DEPURACION WHERE MODULO = ''BASE_DE_SALDOS'' AND ID = ''PLAZO'' AND TZ_LOCK = 0;
	SET @v_fecha = DATEADD(dd, - DATEPART(dd, dateadd(mm, -1 * @v_meses, @p_dt_proceso)) + 1, dateadd(mm, -1 * @v_meses, @p_dt_proceso)); 


	----------------------------------------------------------------------------------
	SET @v_tabla = ''BS_CONTEXTO_POR_EVENTO_HP''
	SET @v_old_name = SUBSTRING(@v_tabla, 0, 18) + ''_OLD_'' + replace(convert(VARCHAR,getdate(), 104), ''.'' , '''');
	SET @v_stmt = ''SELECT * INTO '' + @v_old_name + '' FROM '' + @v_tabla + '' with (nolock) '' + '' WHERE 1 = 0'';
	print ''Creando tabla de BACKUP '' + @v_old_name;
	EXECUTE(@v_stmt);	
	
	SET @v_where = ''BS_CONTEXTO_POR_EVENTO_HP.SALDO_JTS_OID IN (SELECT SALDOS.JTS_OID FROM SALDOS WHERE SALDOS.C1785 IN (5,6) AND SALDOS.C1604 = 0 AND SALDOS.C1625 <  @fecha )'';	
	EXECUTE PKG_DEPURACION$proc_dep_periodica @p_id_proceso,
													@p_dt_proceso,
													@v_tabla,
													''PKG_DEPURACION_BASE_DE_SALDOS$proc_dep_periodica'',
													'''',
													@v_where,
													''SALDO_JTS_OID'',
													@v_fecha,
													@DB_NAME,
													@p_ret_proceso OUT,
													@p_msg_proceso OUT;
	----------------------------------------------------------------------------------	
	
	----------------------------------------------------------------------------------
	SET @v_tabla = ''BS_EVENTOS_INTERES_POR_TRAMO''
	SET @v_old_name = SUBSTRING(@v_tabla, 0, 18) + ''_OLD_'' + replace(convert(VARCHAR,getdate(), 104), ''.'' , '''');
	SET @v_stmt = ''SELECT * INTO '' + @v_old_name + '' FROM '' + @v_tabla + '' with (nolock) '' + '' WHERE 1 = 0'';
	print ''Creando tabla de BACKUP '' + @v_old_name;
	EXECUTE(@v_stmt);	
	
	SET @v_where = ''BS_EVENTOS_INTERES_POR_TRAMO.SALDOS_JTS_OID IN (SELECT SALDOS.JTS_OID FROM SALDOS WHERE SALDOS.C1785 IN (5,6) AND SALDOS.C1604 = 0 AND SALDOS.C1625 <  @fecha )'';	
	EXECUTE PKG_DEPURACION$proc_dep_periodica @p_id_proceso,
													@p_dt_proceso,
													@v_tabla,
													''PKG_DEPURACION_BASE_DE_SALDOS$proc_dep_periodica'',
													'''',
													@v_where,
													''SALDOS_JTS_OID'',
													@v_fecha,
													@DB_NAME,
													@p_ret_proceso OUT,
													@p_msg_proceso OUT;
	----------------------------------------------------------------------------------
	
	----------------------------------------------------------------------------------
	SET @v_tabla = ''BS_HP_MONTOS_ORIGINALES''
	SET @v_old_name = SUBSTRING(@v_tabla, 0, 18) + ''_OLD_'' + replace(convert(VARCHAR,getdate(), 104), ''.'' , '''');
	SET @v_stmt = ''SELECT * INTO '' + @v_old_name + '' FROM '' + @v_tabla + '' with (nolock) '' + '' WHERE 1 = 0'';
	print ''Creando tabla de BACKUP '' + @v_old_name;
	EXECUTE(@v_stmt);	
	
	SET @v_where = ''BS_HP_MONTOS_ORIGINALES.HP_JTS_OID IN (SELECT BS_HISTORIA_PLAZO.JTS_OID FROM BS_HISTORIA_PLAZO WHERE SALDOS_JTS_OID IN (SELECT SALDOS.JTS_OID FROM SALDOS WHERE SALDOS.C1785 IN (5,6) AND SALDOS.C1604 = 0 AND SALDOS.C1625 <  @fecha ) )'';	
	EXECUTE PKG_DEPURACION$proc_dep_periodica @p_id_proceso,
													@p_dt_proceso,
													@v_tabla,
													''PKG_DEPURACION_BASE_DE_SALDOS$proc_dep_periodica'',
													'''',
													@v_where,
													''HP_JTS_OID'',
													@v_fecha,
													@DB_NAME,
													@p_ret_proceso OUT,
													@p_msg_proceso OUT;
	----------------------------------------------------------------------------------

	----------------------------------------------------------------------------------
	SET @v_tabla = ''BS_HP_GASTOS_ORIGINALES''
	SET @v_old_name = SUBSTRING(@v_tabla, 0, 18) + ''_OLD_'' + replace(convert(VARCHAR,getdate(), 104), ''.'' , '''');
	SET @v_stmt = ''SELECT * INTO '' + @v_old_name + '' FROM '' + @v_tabla + '' with (nolock) '' + '' WHERE 1 = 0'';
	print ''Creando tabla de BACKUP '' + @v_old_name;
	EXECUTE(@v_stmt);	
	
	SET @v_where = ''BS_HP_GASTOS_ORIGINALES.HP_JTS_OID IN (SELECT BS_HISTORIA_PLAZO.JTS_OID FROM BS_HISTORIA_PLAZO WHERE SALDOS_JTS_OID IN (SELECT SALDOS.JTS_OID FROM SALDOS WHERE SALDOS.C1785 IN (5,6) AND SALDOS.C1604 = 0 AND SALDOS.C1625 <  @fecha ) )'';	
	EXECUTE PKG_DEPURACION$proc_dep_periodica @p_id_proceso,
													@p_dt_proceso,
													@v_tabla,
													''PKG_DEPURACION_BASE_DE_SALDOS$proc_dep_periodica'',
													'''',
													@v_where,
													''HP_JTS_OID'',
													@v_fecha,
													@DB_NAME,											
													@p_ret_proceso OUT,
													@p_msg_proceso OUT;
	----------------------------------------------------------------------------------

	----------------------------------------------------------------------------------
	SET @v_tabla = ''BS_HISTORIA_PLAZO''
	SET @v_old_name = SUBSTRING(@v_tabla, 0, 18) + ''_OLD_'' + replace(convert(VARCHAR,getdate(), 104), ''.'' , '''');
	SET @v_stmt = ''SELECT * INTO '' + @v_old_name + '' FROM '' + @v_tabla + '' with (nolock) '' + '' WHERE 1 = 0'';
	print ''Creando tabla de BACKUP '' + @v_old_name;
	EXECUTE(@v_stmt);	
	
	SET @v_stmt = ''ALTER TABLE '' + @v_old_name + '' DROP COLUMN JTS_OID; ALTER TABLE '' + @v_old_name + '' ADD JTS_OID INT;''
	EXECUTE (@v_stmt);	
		
	SET @v_where = ''BS_HISTORIA_PLAZO.SALDOS_JTS_OID IN (SELECT SALDOS.JTS_OID FROM SALDOS WHERE SALDOS.C1785 IN (5,6) AND SALDOS.C1604 = 0 AND SALDOS.C1625 <  @fecha )'';	
	EXECUTE PKG_DEPURACION$proc_dep_periodica @p_id_proceso,
													@p_dt_proceso,
													@v_tabla,
													''PKG_DEPURACION_BASE_DE_SALDOS$proc_dep_periodica'',
													'''',
													@v_where,
													''SALDOS_JTS_OID'',
													@v_fecha,
													@DB_NAME,
													@p_ret_proceso OUT,
													@p_msg_proceso OUT;
	----------------------------------------------------------------------------------
	
	----------------------------------------------------------------------------------	
	SET @v_tabla = ''BS_PAYS_DETAIL''
	SET @v_old_name = SUBSTRING(@v_tabla, 0, 18) + ''_OLD_'' + replace(convert(VARCHAR,getdate(), 104), ''.'' , '''');
	SET @v_stmt = ''SELECT * INTO '' + @v_old_name + '' FROM '' + @v_tabla + '' with (nolock) '' + '' WHERE 1 = 0'';
	print ''Creando tabla de BACKUP '' + @v_old_name;
	EXECUTE(@v_stmt);	
	
	SET @v_where = ''BS_PAYS_DETAIL.SALDOS_JTS_OID IN (SELECT SALDOS.JTS_OID FROM SALDOS WHERE SALDOS.C1785 IN (5,6) AND SALDOS.C1604 = 0 AND SALDOS.C1625 <  @fecha )'';												
	EXECUTE PKG_DEPURACION$proc_dep_periodica @p_id_proceso,
													@p_dt_proceso,
													@v_tabla,
													''PKG_DEPURACION_BASE_DE_SALDOS$proc_dep_periodica'',
													'''',
													@v_where,
													''SALDOS_JTS_OID'',
													@v_fecha,
													@DB_NAME,
													@p_ret_proceso OUT,
													@p_msg_proceso OUT;	
	----------------------------------------------------------------------------------
	
	----------------------------------------------------------------------------------													
	SET @v_tabla = ''GASTOS_POR_CUOTA''
	SET @v_old_name = SUBSTRING(@v_tabla, 0, 18) + ''_OLD_'' + replace(convert(VARCHAR,getdate(), 104), ''.'' , '''');
	SET @v_stmt = ''SELECT * INTO '' + @v_old_name + '' FROM '' + @v_tabla + '' with (nolock) '' + '' WHERE 1 = 0'';
	print ''Creando tabla de BACKUP '' + @v_old_name;
	EXECUTE(@v_stmt);	
	
	SET @v_where = ''GASTOS_POR_CUOTA.SALDOS_JTS_OID IN (SELECT SALDOS.JTS_OID FROM SALDOS WHERE SALDOS.C1785 IN (5,6) AND SALDOS.C1604 = 0 AND SALDOS.C1625 <  @fecha )'';												
	EXECUTE PKG_DEPURACION$proc_dep_periodica @p_id_proceso,
													@p_dt_proceso,
													@v_tabla,
													''PKG_DEPURACION_BASE_DE_SALDOS$proc_dep_periodica'',
													'''',
													@v_where,
													''SALDOS_JTS_OID'',
													@v_fecha,
													@DB_NAME,
													@p_ret_proceso OUT,
													@p_msg_proceso OUT;	
	----------------------------------------------------------------------------------
	
	----------------------------------------------------------------------------------	
	SET @v_tabla = ''BS_CHARGE_DETAIL''
	SET @v_old_name = SUBSTRING(@v_tabla, 0, 18) + ''_OLD_'' + replace(convert(VARCHAR,getdate(), 104), ''.'' , '''');
	SET @v_stmt = ''SELECT * INTO '' + @v_old_name + '' FROM '' + @v_tabla + '' with (nolock) '' + '' WHERE 1 = 0'';
	print ''Creando tabla de BACKUP '' + @v_old_name;
	EXECUTE(@v_stmt);	
	
	SET @v_where = ''BS_CHARGE_DETAIL.SALDOS_JTS_OID IN (SELECT SALDOS.JTS_OID FROM SALDOS WHERE SALDOS.C1785 IN (5,6) AND SALDOS.C1604 = 0 AND SALDOS.C1625 <  @fecha )'';												
	EXECUTE PKG_DEPURACION$proc_dep_periodica @p_id_proceso,
													@p_dt_proceso,
													@v_tabla,
													''PKG_DEPURACION_BASE_DE_SALDOS$proc_dep_periodica'',
													'''',
													@v_where,
													''SALDOS_JTS_OID'',
													@v_fecha,
													@DB_NAME,
													@p_ret_proceso OUT,
													@p_msg_proceso OUT;	
	----------------------------------------------------------------------------------
	
	----------------------------------------------------------------------------------				
	SET @v_tabla = ''PLANPAGOS''
	SET @v_old_name = SUBSTRING(@v_tabla, 0, 18) + ''_OLD_'' + replace(convert(VARCHAR,getdate(), 104), ''.'' , '''');
	SET @v_stmt = ''SELECT * INTO '' + @v_old_name + '' FROM '' + @v_tabla + '' with (nolock) '' + '' WHERE 1 = 0'';
	print ''Creando tabla de BACKUP '' + @v_old_name;
	EXECUTE(@v_stmt);	
	
	SET @v_where = ''PLANPAGOS.SALDO_JTS_OID IN (SELECT SALDOS.JTS_OID FROM SALDOS WHERE SALDOS.C1785 IN (5,6) AND SALDOS.C1604 = 0 AND SALDOS.C1625 <  @fecha )'';	
	EXECUTE PKG_DEPURACION$proc_dep_periodica @p_id_proceso,
													@p_dt_proceso,
													@v_tabla,
													''PKG_DEPURACION_BASE_DE_SALDOS$proc_dep_periodica'',
													'''',
													@v_where,
													''SALDO_JTS_OID'',
													@v_fecha,
													@DB_NAME,
													@p_ret_proceso OUT,
													@p_msg_proceso OUT;														
	----------------------------------------------------------------------------------
	
	----------------------------------------------------------------------------------	
	SET @v_tabla = ''GRL_SALDOS_DIARIOS''
	SET @v_old_name = SUBSTRING(@v_tabla, 0, 18) + ''_OLD_'' + replace(convert(VARCHAR,getdate(), 104), ''.'' , '''');
	SET @v_stmt = ''SELECT * INTO '' + @v_old_name + '' FROM '' + @v_tabla + '' with (nolock) '' + '' WHERE 1 = 0'';
	print ''Creando tabla de BACKUP '' + @v_old_name;
	EXECUTE(@v_stmt);			
	
	SELECT @v_meses = PERIODO FROM PARAMETROS_DEPURACION WHERE MODULO = ''BASE_DE_SALDOS'' AND ID = ''SALDOS_DIARIOS'' AND TZ_LOCK = 0;
	SET @v_fecha2 = DATEADD(dd, - DATEPART(dd, dateadd(mm, -1 * @v_meses, @p_dt_proceso)) + 1, dateadd(mm, -1 * @v_meses, @p_dt_proceso)); 	
	
	SET @v_where = ''GRL_SALDOS_DIARIOS.FECHA < @fecha '';
	EXECUTE PKG_DEPURACION$proc_dep_periodica @p_id_proceso,
													@p_dt_proceso,
													@v_tabla,
													''PKG_DEPURACION_BASE_DE_SALDOS$proc_dep_periodica'',
													'''',
													@v_where,
													''SALDOS_JTS_OID'',
													@v_fecha2,
													@DB_NAME,
													@p_ret_proceso OUT,
													@p_msg_proceso OUT;	
	----------------------------------------------------------------------------------
	
	----------------------------------------------------------------------------------													
	SET @v_tabla = ''GRL_SALDOS_MENSUALES''
	SET @v_old_name = SUBSTRING(@v_tabla, 0, 18) + ''_OLD_'' + replace(convert(VARCHAR,getdate(), 104), ''.'' , '''');
	SET @v_stmt = ''SELECT * INTO '' + @v_old_name + '' FROM '' + @v_tabla + '' with (nolock) '' + '' WHERE 1 = 0'';
	print ''Creando tabla de BACKUP '' + @v_old_name;
	EXECUTE(@v_stmt);	
		
	SET @v_where = ''GRL_SALDOS_MENSUALES.FECHA < @fecha '';
	EXECUTE PKG_DEPURACION$proc_dep_periodica @p_id_proceso,
													@p_dt_proceso,
													@v_tabla,
													''PKG_DEPURACION_BASE_DE_SALDOS$proc_dep_periodica'',
													'''',
													@v_where,
													''SALDOS_JTS_OID'',
													@v_fecha2,
													@DB_NAME,
													@p_ret_proceso OUT,
													@p_msg_proceso OUT;			
	----------------------------------------------------------------------------------
	
	----------------------------------------------------------------------------------													
	SET @v_tabla = ''SALDOS''
	SET @v_old_name = SUBSTRING(@v_tabla, 0, 18) + ''_OLD_'' + replace(convert(VARCHAR,getdate(), 104), ''.'' , '''');
	SET @v_stmt = ''SELECT * INTO '' + @v_old_name + '' FROM '' + @v_tabla + '' with (nolock) '' + '' WHERE 1 = 0'';
	print ''Creando tabla de BACKUP '' + @v_old_name;
	EXECUTE(@v_stmt);	
		
	SELECT @v_meses = PERIODO FROM PARAMETROS_DEPURACION WHERE MODULO = ''BASE_DE_SALDOS'' AND ID = ''PLAZO'' AND TZ_LOCK = 0;
	SET @v_fecha = DATEADD(dd, - DATEPART(dd, dateadd(mm, -1 * @v_meses, @p_dt_proceso)) + 1, dateadd(mm, -1 * @v_meses, @p_dt_proceso)); 
	
	SET @v_where = ''SALDOS.C1785 IN (5,6) AND SALDOS.C1604 = 0 AND SALDOS.C1625 <  @fecha '';													
	EXECUTE PKG_DEPURACION$proc_dep_periodica @p_id_proceso,
													@p_dt_proceso,
													@v_tabla,
													''PKG_DEPURACION_BASE_DE_SALDOS$proc_dep_periodica'',
													'''',
													@v_where,
													''C1785 , C1604 , C1625'',
													@v_fecha,
													@DB_NAME,
													@p_ret_proceso OUT,
													@p_msg_proceso OUT;		
	----------------------------------------------------------------------------------														
END TRY

BEGIN CATCH

    SET @p_msg_proceso = ''El proceso PKG_DEPURACION_BASE_DE_SALDOS$proc_dep_periodica produjo un error. Error original: '' + ERROR_MESSAGE() + '' Linea: '' + CAST(ERROR_LINE() AS VARCHAR(50));	

	print @p_msg_proceso
	
	SET @p_ret_proceso = @c_log_error

	-- Logueo de información
    EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso @p_id_proceso,
                                         @p_dt_proceso,
                                         ''PKG_DEPURACION_BASE_DE_SALDOS'',
                                         @c_log_error,
                                         @p_msg_proceso,
                                         @c_log_tipo_version;

END CATCH

END
; ')

