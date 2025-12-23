execute('
CREATE or alter PROCEDURE [dbo].[PKG_DEPURACION$proc_dep_periodica_2]

@p_id_proceso	float(38),
@p_dt_proceso	datetime,
@p_tabla		varchar(30),
@p_package		varchar(60),
@p_from			varchar(max), --INNER JOINS
@p_where		varchar(max),
@p_indexes		varchar(300),
@p_fecha		datetime,
@p_fecha2		datetime,
@DB_NAME 		SYSNAME,
@p_ret_proceso	float(38)  OUTPUT,
@p_msg_proceso	varchar(max)  OUTPUT

AS 
 BEGIN
    DECLARE
	@v_procesadosOk 	float(38),
	@v_cantidad 		float(38),
	@v_cantidad_dep		float(38),
	@v_cantidad_total 	float(38),
	@rowcount			float(38),
	@v_old_name			varchar(30),
	@v_columns			nvarchar(max),
	@v_key				nvarchar(max),	
	@v_stmt				nvarchar(max),
	@v_commit			float(38),
	@v_fecha			DATETIME,
	@v_fecha2			DATETIME,
	@RECOVERYMODEL VARCHAR(20);

BEGIN TRY

	SET @p_ret_proceso = NULL
	SET @p_msg_proceso = NULL
	SET @v_procesadosOk = 0
	SET @v_cantidad_dep = 0
	SET @v_cantidad = 0
	SET @v_cantidad_total = 0
	SET @v_commit = 1000000
	SET @rowcount = 0
	SET @v_old_name = SUBSTRING(@p_tabla, 0, 18) + ''_OLD_'' + replace(convert(VARCHAR,getdate(), 104), ''.'' , '''');
	SET @v_fecha = @p_fecha; --Los copio a una variable local, en algun lado leí que utilizar las variables pasadas por parámetro es menos performante a la hora de usarlas.
	SET @v_fecha2 = @p_fecha2;

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

	DECLARE
		@hora_proceso varchar(max)

	-- Registra versión
    EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso @p_id_proceso,
                                         @p_dt_proceso,
                                         @p_package,
                                         @c_log_cod_sin_error,
                                         @c_version,
                                         @c_log_tipo_version;


    -- Logueo de información
	set @hora_proceso = ''Hora de Inicio del Proceso '' + CAST (getdate() AS nvarchar(max))
	print @hora_proceso
    EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso @p_id_proceso,
                                         @p_dt_proceso,
                                         @p_package,
                                         @c_log_cod_sin_error,
                                         @hora_proceso,
                                         @c_log_tipo_version;
	

	SELECT @v_commit = PERIODO FROM PARAMETROS_DEPURACION WHERE MODULO = ''COMMIT'' AND ID = ''COMMIT'' AND TZ_LOCK = 0;
	
	SET @v_stmt = N''SELECT @v_cantidad_total = COUNT(*) FROM dbo.'' + @p_tabla
	EXECUTE sp_executesql @v_stmt, N''@v_cantidad_total float(38) output'', @v_cantidad_total OUTPUT;
	
	SET @v_stmt = N''SELECT @v_cantidad = count(*) FROM dbo.'' + @p_tabla + @p_from + '' WHERE '' + @p_where
	EXECUTE sp_executesql @v_stmt, N''@v_cantidad float(38) output, @fecha datetime, @fecha2 datetime'', @v_cantidad OUTPUT, @v_fecha, @v_fecha2;
		
	PRINT ''Cantidad de registros a eliminar: '' + STR(@v_cantidad) + '' de un total de: '' + STR(@v_cantidad_total)

	IF (@v_cantidad_total > 0 AND @v_cantidad > 0)
		begin
			SELECT @RECOVERYMODEL = RECOVERY_MODEL_DESC FROM SYS.DATABASES WHERE NAME=@DB_NAME
			EXEC USP_DisableEnableNonClusteredIndexes  @DB_NAME,1, @p_tabla, @p_indexes -- DISABLE NON-CLUSTERED INDEXES para hacer el Insert.
			SET @v_stmt = ''ALTER DATABASE '' +@DB_NAME+ '' SET RECOVERY SIMPLE'';
			EXECUTE (@v_stmt);
			--------------------------------------------------------------------------------------------------------------
			-- Se borran los registros de la tabla original (y se respaldan en la tabla OLD)
			--------------------------------------------------------------------------------------------------------------
			begin	
				----- Obtengo los nombres de las columnas de la tabla
				SELECT @v_columns = ( SELECT + Column_name + '','' 
				from INFORMATION_SCHEMA.columns
				WHERE Table_name = @p_tabla
				FOR XML PATH ( '''' ) )
				SET @v_columns = ISNULL(LEFT(@v_columns, LEN(@v_columns) - 1),''ErrMsg'') ;
			
				SET @v_stmt = ''INSERT INTO '' + @v_old_name + '' WITH (TABLOCK) ('' + @v_columns + '') SELECT * FROM ( DELETE TOP ('' + str(@v_commit)  + '') '' + @p_tabla + '' WITH (TABLOCK) OUTPUT deleted.*
				FROM dbo.'' + @p_tabla + @p_from + '' WHERE '' + @p_where + '' ) subquery ''
						
				PRINT @v_stmt;
				
				WHILE @v_procesadosOk < @v_cantidad 
				 
					BEGIN
						BEGIN TRY
							EXECUTE sp_executesql @v_stmt, N''@fecha datetime, @fecha2 datetime'', @v_fecha, @v_fecha2;
							SELECT @rowcount = @@ROWCOUNT
							SET @v_procesadosOk = @v_procesadosOk + @rowcount;
						END TRY

						BEGIN CATCH
							BEGIN		
								SET @p_msg_proceso = ''Error borrando datos e insertandolos en la tabla de respaldo. Error original: '' + ERROR_MESSAGE() + '' Linea: '' + CAST(ERROR_LINE() AS VARCHAR(50));				 
								PRINT @p_msg_proceso;	
								RAISERROR ( @p_msg_proceso, 16, 1 ); -- Message, Severity, State
							END
						END CATCH
					END
				SET @v_cantidad_dep = @v_procesadosOk
			end
			EXEC USP_DisableEnableNonClusteredIndexes  @DB_NAME,2, @p_tabla, '' ''-- REBUILD NON-CLUSTERED INDEXES
			SET @v_stmt = ''ALTER DATABASE '' +@DB_NAME+ '' SET RECOVERY ''+@RECOVERYMODEL ;
			EXEC (@v_stmt);	
		end
			

	--EXECUTE (@v_stmt);	
	
	SET @p_msg_proceso = 
	''El proceso de '' + @p_package + '' se realizo correctamente. '' + 
	''Se depuraron '' + ISNULL(STR(@v_cantidad_dep), '''') + 
	'' registros de '' + @p_tabla + '', de un total de: '' + 
	ISNULL(STR(@v_cantidad_total), ''0'')

	PRINT @p_msg_proceso

	
	SET @p_ret_proceso = @c_log_cod_sin_error

	-- Logueo de información
	set @hora_proceso = ''Hora de Fin del Proceso del Proceso '' + CAST (getdate() AS nvarchar(max))
	PRINT @hora_proceso
	EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso @p_id_proceso,
									 @p_dt_proceso,
									 @p_package,
									 @c_log_cod_sin_error,
									 @hora_proceso,
									 @c_log_tipo_version;
		
END TRY

BEGIN CATCH

    SET @p_msg_proceso = ''El proceso de '' + @p_package + '' produjo un error. Error original: '' + ERROR_MESSAGE() + '' Linea: '' + CAST(ERROR_LINE() AS VARCHAR(50));	

	print @p_msg_proceso
	
	SET @p_ret_proceso = @c_log_error

	-- Logueo de información
    EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso @p_id_proceso,
                                         @p_dt_proceso,
                                         @p_package,
                                         @c_log_error,
                                         @p_msg_proceso,
                                         @c_log_tipo_version;
	RAISERROR ( @p_msg_proceso, 16, 1 ); -- Message, Severity, State

END CATCH

END
; ')

