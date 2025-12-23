execute('
CREATE or alter PROCEDURE [dbo].[PKG_DEPURACION_NUMERATOR$proc_dep_periodica]

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
	@v_from 	nvarchar(max),
	@v_dias numeric,
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
	
	SELECT @v_dias = PERIODO FROM PARAMETROS_DEPURACION WHERE MODULO = ''NUMERADORES'' AND ID = ''DIARIOS'' AND TZ_LOCK = 0;
	SELECT @v_meses = PERIODO FROM PARAMETROS_DEPURACION WHERE MODULO = ''NUMERADORES'' AND ID = ''MENSUALES'' AND TZ_LOCK = 0;

	------------------------------------------------
		SET @v_tabla = ''NUMERATORASIGNED''
		SET @v_old_name = SUBSTRING(@v_tabla, 0, 18) + ''_OLD_'' + replace(convert(VARCHAR,getdate(), 104), ''.'' , '''');
		SET @v_stmt = ''SELECT * INTO '' + @v_old_name + '' FROM '' + @v_tabla + '' with (nolock) '' + '' WHERE 1 = 0'';
		print ''Creando tabla de BACKUP '' + @v_old_name;
		EXECUTE(@v_stmt);	
	
		SET @v_from = '' INNER JOIN NUMERATORVALUES 
			ON NUMERATORASIGNED.OID = NUMERATORVALUES.OID 
			AND NUMERATORVALUES.ANIO <> 0 
			AND NUMERATORVALUES.MES <> 0 
			AND NUMERATORVALUES.DIA <> 0 
				INNER JOIN NUMERATORDEFINITION 
				ON NUMERATORVALUES.NUMERO = NUMERATORDEFINITION.NUMERO 
				AND NUMERATORDEFINITION.PERIODO = ''''D'''' ''
		SET @v_where = '' NUMERATORASIGNED.FECHAPROCESO < @fecha ''
		SET @v_fecha = dateadd(dd, - @v_dias, @p_dt_proceso);
		
		EXECUTE PKG_DEPURACION$proc_dep_periodica @p_id_proceso,
												@p_dt_proceso,
												@v_tabla,
												''PKG_DEPURACION_NUMERATOR$proc_dep_periodica'',
												@v_from,
												@v_where,
												''FECHAPROCESO , OID'',
												@v_fecha,
												@DB_NAME,
												@p_ret_proceso OUT,
												@p_msg_proceso OUT;	

		SET @v_from = '' INNER JOIN NUMERATORVALUES 
			ON NUMERATORASIGNED.OID = NUMERATORVALUES.OID 
			AND NUMERATORVALUES.ANIO <> 0 
			AND NUMERATORVALUES.MES <> 0 
			AND NUMERATORVALUES.DIA = 0 
				INNER JOIN NUMERATORDEFINITION 
				ON NUMERATORVALUES.NUMERO = NUMERATORDEFINITION.NUMERO 
				AND NUMERATORDEFINITION.PERIODO = ''''M'''' ''
		SET @v_where = '' NUMERATORASIGNED.FECHAPROCESO < @fecha ''
		SET @v_fecha = DATEADD(dd, - DATEPART(dd, dateadd(mm, -1 * @v_meses, @p_dt_proceso)) + 1, dateadd(mm, -1 * @v_meses, @p_dt_proceso)); 
		
		EXECUTE PKG_DEPURACION$proc_dep_periodica @p_id_proceso,
												@p_dt_proceso,
												@v_tabla,
												''PKG_DEPURACION_NUMERATOR$proc_dep_periodica'',
												@v_from,
												@v_where,
												''FECHAPROCESO , OID'',
												@v_fecha,
												@DB_NAME,									
												@p_ret_proceso OUT,
												@p_msg_proceso OUT;	
												
		SET @v_from = '' INNER JOIN NUMERATORVALUES 
			ON NUMERATORASIGNED.OID = NUMERATORVALUES.OID 
				INNER JOIN NUMERATORDEFINITION 
				ON NUMERATORVALUES.NUMERO = NUMERATORDEFINITION.NUMERO 
				AND NUMERATORDEFINITION.PERIODO NOT IN (''''A'''', ''''D'''', ''''M'''') ''
		SET @v_where = '' NUMERATORASIGNED.FECHAPROCESO < @fecha AND (NUMERATORASIGNED.ESTADO <> ''''C'''' OR NUMERATORDEFINITION.REUTILIZABLE <> 1) ''
		SET @v_fecha = dateadd(dd, - @v_dias, @p_dt_proceso);
		
		EXECUTE PKG_DEPURACION$proc_dep_periodica @p_id_proceso,
												@p_dt_proceso,
												@v_tabla,
												''PKG_DEPURACION_NUMERATOR$proc_dep_periodica'',
												@v_from,
												@v_where,
												''FECHAPROCESO , OID'',
												@v_fecha,
												@DB_NAME,											
												@p_ret_proceso OUT,
												@p_msg_proceso OUT;	
												
		SET @v_from = '' INNER JOIN NUMERATORVALUES 
			ON NUMERATORASIGNED.OID = NUMERATORVALUES.OID 
			AND NUMERATORVALUES.ANIO <> 0 
			AND NUMERATORVALUES.MES = 0 
			AND NUMERATORVALUES.DIA = 0 
				INNER JOIN NUMERATORDEFINITION 
				ON NUMERATORVALUES.NUMERO = NUMERATORDEFINITION.NUMERO 
				AND NUMERATORDEFINITION.PERIODO = ''''A'''' ''
		SET @v_where = '' NUMERATORASIGNED.FECHAPROCESO < @fecha ''
		SET @v_fecha = CAST(YEAR(@p_dt_proceso) AS VARCHAR(4)) + ''0101''
		
		EXECUTE PKG_DEPURACION$proc_dep_periodica @p_id_proceso,
												@p_dt_proceso,
												@v_tabla,
												''PKG_DEPURACION_NUMERATOR$proc_dep_periodica'',
												@v_from,
												@v_where,
												''FECHAPROCESO , OID'',
												@v_fecha,
												@DB_NAME,
												@p_ret_proceso OUT,
												@p_msg_proceso OUT;			
	------------------------------------------------	

	------------------------------------------------
	 	SET @v_tabla = ''NUMERATORVALUES''
		SET @v_old_name = SUBSTRING(@v_tabla, 0, 18) + ''_OLD_'' + replace(convert(VARCHAR,getdate(), 104), ''.'' , '''');
		SET @v_stmt = ''SELECT * INTO '' + @v_old_name + '' FROM '' + @v_tabla + '' with (nolock) '' + '' WHERE 1 = 0'';
		print ''Creando tabla de BACKUP '' + @v_old_name;
		EXECUTE(@v_stmt);	
		
		SET @v_stmt = ''ALTER TABLE '' + @v_old_name + '' DROP COLUMN OID; ALTER TABLE '' + @v_old_name + '' ADD OID INT;''
		EXECUTE (@v_stmt);	
	
		SET @v_from = '' INNER JOIN NUMERATORDEFINITION ON NUMERATORVALUES.NUMERO = NUMERATORDEFINITION.NUMERO AND NUMERATORDEFINITION.PERIODO = ''''D'''' ''
		SET @v_where = '' NUMERATORVALUES.ANIO <> 0
						AND NUMERATORVALUES.MES <> 0
						AND NUMERATORVALUES.DIA <> 0 
						AND RIGHT( replicate(''''0'''',4) + CAST(NUMERATORVALUES.ANIO AS VARCHAR(4)), 4) + RIGHT( replicate(''''0'''',2) + CAST(NUMERATORVALUES.MES AS VARCHAR(2)), 2) + RIGHT( replicate(''''0'''',2) + CAST(NUMERATORVALUES.DIA AS VARCHAR(2)), 2) < @fecha''
		SET @v_fecha = dateadd(dd, - @v_dias, @p_dt_proceso);
		
		EXECUTE PKG_DEPURACION$proc_dep_periodica @p_id_proceso,
												@p_dt_proceso,
												@v_tabla,
												''PKG_DEPURACION_NUMERATOR$proc_dep_periodica'',
												@v_from,
												@v_where,
												''ANIO , MES , DIA'',
												@v_fecha,
												@DB_NAME,									
												@p_ret_proceso OUT,
												@p_msg_proceso OUT;		
												
		SET @v_from = '' INNER JOIN NUMERATORDEFINITION ON NUMERATORVALUES.NUMERO = NUMERATORDEFINITION.NUMERO AND NUMERATORDEFINITION.PERIODO = ''''M'''' ''
		SET @v_where = '' NUMERATORVALUES.ANIO <> 0
		AND NUMERATORVALUES.MES <> 0
		AND NUMERATORVALUES.DIA = 0
		AND RIGHT( replicate(''''0'''',4) + CAST(NUMERATORVALUES.ANIO AS VARCHAR(4)), 4) + RIGHT( replicate(''''0'''',2) + CAST(NUMERATORVALUES.MES AS VARCHAR(2)), 2) + ''''01'''' < @fecha''	  
		SET @v_fecha = DATEADD(dd, - DATEPART(dd, dateadd(mm, -1 * @v_meses, @p_dt_proceso)) + 1, dateadd(mm, -1 * @v_meses, @p_dt_proceso)); 
		
		EXECUTE PKG_DEPURACION$proc_dep_periodica @p_id_proceso,
												@p_dt_proceso,
												@v_tabla,
												''PKG_DEPURACION_NUMERATOR$proc_dep_periodica'',
												@v_from,
												@v_where,
												''ANIO , MES , DIA'',
												@v_fecha,
												@DB_NAME,									
												@p_ret_proceso OUT,
												@p_msg_proceso OUT;		
												
		SET @v_from = '' INNER JOIN NUMERATORDEFINITION ON NUMERATORVALUES.NUMERO = NUMERATORDEFINITION.NUMERO AND NUMERATORDEFINITION.PERIODO = ''''A'''' ''
		set @v_where = '' NUMERATORVALUES.ANIO <> 0
		AND NUMERATORVALUES.MES <> 0
		AND NUMERATORVALUES.DIA <> 0
		AND RIGHT( replicate(''''0'''',4) + CAST(NUMERATORVALUES.ANIO AS VARCHAR(4)), 4) + ''''0101'''' < @fecha''	    
		SET @v_fecha = CAST(YEAR(@p_dt_proceso) AS VARCHAR(4)) + ''0101''

		EXECUTE PKG_DEPURACION$proc_dep_periodica @p_id_proceso,
												@p_dt_proceso,
												@v_tabla,
												''PKG_DEPURACION_NUMERATOR$proc_dep_periodica'',
												@v_from,
												@v_where,
												''ANIO , MES , DIA'',
												@v_fecha,
												@DB_NAME,									
												@p_ret_proceso OUT,
												@p_msg_proceso OUT;		
												
	-------------------------------------------------	  
      
END TRY

BEGIN CATCH

    SET @p_msg_proceso = ''El proceso PKG_DEPURACION_NUMERATOR$proc_dep_periodica produjo un error. Error original: '' + ERROR_MESSAGE() + '' Linea: '' + CAST(ERROR_LINE() AS VARCHAR(50));	

	print @p_msg_proceso
	
	SET @p_ret_proceso = @c_log_error

	-- Logueo de información
    EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso @p_id_proceso,
                                         @p_dt_proceso,
                                         ''PKG_DEPURACION_NUMERATOR'',
                                         @c_log_error,
                                         @p_msg_proceso,
                                         @c_log_tipo_version;

END CATCH

END
; ')

