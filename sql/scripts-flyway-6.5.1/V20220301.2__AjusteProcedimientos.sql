
EXECUTE('
IF OBJECT_ID (''SP_ACTUALIZA_BCRA'') IS NOT NULL
	DROP PROCEDURE SP_ACTUALIZA_BCRA
')

EXECUTE('
CREATE PROCEDURE [dbo].[SP_ACTUALIZA_BCRA]
	@p_id_proceso FLOAT(53),     /* Identificador de proceso */
	@p_dt_proceso DATETIME,   /* Fecha de proceso */
	@p_ret_proceso FLOAT OUT, /* Estado de ejecucion SQL(0:Correcto, 2: Error) */
	@p_msg_proceso VARCHAR(MAX) OUT
AS
BEGIN
	DECLARE 
	------- Campos para el LOG --------
	@c_log_tipo_error varchar(30),
	@c_log_tipo_informacion VARCHAR(30),
	-----------------------------------	
	@contador NUMERIC(10)
	SET @contador = 0;
	------- Campos para el LOG --------
	SET @c_log_tipo_error = ''E'';
	SET @c_log_tipo_informacion = ''I'';
	-----------------------------------	

	BEGIN TRY
        	  
		SET @contador =	(SELECT count(1)
		FROM ITF_BCRA_CENDEU b WITH (NOLOCK)
		INNER JOIN (SELECT DISTINCT doc.TIPODOCUMENTO, doc.NUMERODOCUMENTO, c.CODIGOCLIENTE
		FROM CLI_CLIENTES c WITH (NOLOCK)
		INNER JOIN CLI_CLIENTEPERSONA cp WITH (NOLOCK) ON c.CODIGOCLIENTE = cp.CODIGOCLIENTE AND cp.TITULARIDAD = ''T'' AND cp.TZ_LOCK = 0
		INNER JOIN CLI_DocumentosPFPJ doc WITH (NOLOCK) ON cp.NUMEROPERSONA = doc.NUMEROPERSONAFJ AND doc.TZ_LOCK = 0
		WHERE c.FECHAAPERTURA = (SELECT FECHAPROCESO FROM PARAMETROS WITH (NOLOCK)) AND c.TZ_LOCK = 0) a ON b.NRO_IDENTIFICACION = a.NUMERODOCUMENTO AND a.CODIGOCLIENTE NOT IN (SELECT CODIGOCLIENTE FROM CRE_BCRA_CENDEU WITH (NOLOCK) WHERE COD_ENTIDAD = b.COD_ENTIDAD AND FECHA_PROCESO = (SELECT FECHAPROCESO FROM PARAMETROS WITH (NOLOCK)))
		WHERE b.TPO_IDENTIFICACION = 11)				
		
		IF @contador > 0
		BEGIN
			INSERT INTO CRE_BCRA_CENDEU (FECHA_PROCESO, COD_ENTIDAD, FECHA, CODIGOCLIENTE, TPO_IDENTIFICACION, NRO_IDENTIFICACION, ACTIVIDAD, SITUACION_BCRA, PRESTAMOS, PARTICIPACIONES, GARANTIAS, OTROS_CONCEPTOS, DEUDA_TOTAL, GARANTIA_A, GARANTIA_B, SIN_GARANTIAS, CONTRA_GARANTIA_A, CONTRA_GARANTIA_B, SIN_CONTRA_GARANTIA, PREVISIONES, DEUDA_CUBIERTA, PROCESO_JUDICIAL, REFINANCIACIONES, RECATEGORIZACION, SIT_JURIDICA, IRR_DISP_TECNICA, DIAS_ATRASO, SITUACION_ENTIDAD, TZ_LOCK)
			SELECT (SELECT FECHAPROCESO FROM PARAMETROS WITH (NOLOCK)), b.COD_ENTIDAD, b.FECHA, a.CODIGOCLIENTE, b.TPO_IDENTIFICACION, b.NRO_IDENTIFICACION, b.ACTIVIDAD, b.SITUACION_BCRA, b.PRESTAMOS, b.PARTICIPACIONES, b.GARANTIAS, b.OTROS_CONCEPTOS, (b.PRESTAMOS +  b.PARTICIPACIONES + b.GARANTIAS + b.OTROS_CONCEPTOS) AS DEUDA_TOTAL, b.GARANTIA_A, b.GARANTIA_B, b.SIN_GARANTIAS, b.CONTRA_GARANTIA_A, b.CONTRA_GARANTIA_B, b.SIN_CONTRA_GARANTIA, b.PREVISIONES, b.DEUDA_CUBIERTA, b.PROCESO_JUDICIAL, b.REFINANCIACIONES, b.RECATEGORIZACION, b.SIT_JURIDICA, b.IRR_DISP_TECNICA, b.DIAS_ATRASO, b.SITUACION_NBCH AS SITUACION_ENTIDAD, 0 AS TZ_LOCK 
			FROM ITF_BCRA_CENDEU b WITH (NOLOCK)
			INNER JOIN (SELECT DISTINCT doc.TIPODOCUMENTO, doc.NUMERODOCUMENTO, c.CODIGOCLIENTE
			FROM CLI_CLIENTES c WITH (NOLOCK) 
			INNER JOIN CLI_CLIENTEPERSONA cp WITH (NOLOCK) ON c.CODIGOCLIENTE = cp.CODIGOCLIENTE AND cp.TITULARIDAD = ''T'' AND cp.TZ_LOCK = 0
			INNER JOIN CLI_DocumentosPFPJ doc WITH (NOLOCK) ON cp.NUMEROPERSONA = doc.NUMEROPERSONAFJ AND doc.TZ_LOCK = 0
			WHERE c.FECHAAPERTURA = (SELECT FECHAPROCESO FROM PARAMETROS WITH (NOLOCK)) AND c.TZ_LOCK = 0) a ON b.NRO_IDENTIFICACION = a.NUMERODOCUMENTO AND a.CODIGOCLIENTE NOT IN (SELECT CODIGOCLIENTE FROM CRE_BCRA_CENDEU WITH (NOLOCK) WHERE COD_ENTIDAD = b.COD_ENTIDAD AND FECHA_PROCESO = (SELECT FECHAPROCESO FROM PARAMETROS WITH (NOLOCK)))
			WHERE b.TPO_IDENTIFICACION = 11 AND b.TZ_LOCK = 0
		END
		  
		    SET @p_msg_proceso = ''El Proceso de Actualización de BCRA ha finalizado correctamente. Registros procesados: ''+ CONVERT(VARCHAR(10), @contador)
			SET @p_ret_proceso = 1 		
			
			-- Logueo de información
			EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso 
				@p_id_proceso,
		    	@p_dt_proceso,
		    	''SP_ACTUALIZA_BCRA'',
		    	@p_cod_error = @p_ret_proceso, 
				@p_msg_error = @p_msg_proceso, 
				@p_tipo_error = @c_log_tipo_informacion
		END TRY
							             
		BEGIN CATCH
	
	        SET @p_ret_proceso = ERROR_NUMBER()
	     SET @p_msg_proceso = ''Ocurrió un error en el Proceso de Actualización de BCRA: '' + ERROR_MESSAGE()
	
			EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso 
	        	@p_id_proceso = @p_id_proceso, 
	        	@p_fch_proceso = @p_dt_proceso, 
	        	@p_nom_package = ''SP_ACTUALIZA_BCRA'', 
	        	@p_cod_error = @p_ret_proceso, 
	        	@p_msg_error = @p_msg_proceso, 
	       		@p_tipo_error = @c_log_tipo_informacion
		END CATCH
END
')

EXECUTE('

IF OBJECT_ID (''SP_ACTUALIZA_SITUACION_BCRA'') IS NOT NULL
	DROP PROCEDURE SP_ACTUALIZA_SITUACION_BCRA

')

EXECUTE('
CREATE PROCEDURE [dbo].[SP_ACTUALIZA_SITUACION_BCRA]
	@p_id_proceso FLOAT(53),     /* Identificador de proceso */
	@p_dt_proceso DATETIME,   /* Fecha de proceso */
	@p_ret_proceso FLOAT OUT, /* Estado de ejecucion SQL(0:Correcto, 2: Error) */
	@p_msg_proceso VARCHAR(MAX) OUT
AS
BEGIN
	DECLARE 
	------- Campos para el LOG --------
	@c_log_tipo_error varchar(30),
	@c_log_tipo_informacion VARCHAR(30),
	-----------------------------------	
	@contador NUMERIC(10)
	SET @contador = 0;
	------- Campos para el LOG --------
	SET @c_log_tipo_error = ''E'';
	SET @c_log_tipo_informacion = ''I'';
	-----------------------------------	

	BEGIN TRY
        	  
		SET @contador =	(SELECT count(1)			
		FROM CLI_CLIENTES c WITH (NOLOCK)
		INNER JOIN (SELECT CODIGOCLIENTE, max(SITUACION_ENTIDAD) AS CALIFICACION FROM CRE_BCRA_CENDEU WHERE FECHA_PROCESO = (SELECT FECHAPROCESO FROM PARAMETROS WITH (NOLOCK)) AND TZ_LOCK = 0 AND COD_ENTIDAD <> right(''000000'' + CAST((SELECT NUMERICO FROM PARAMETROSGENERALES WITH (NOLOCK) WHERE CODIGO = 2) AS VARCHAR(5)),5) GROUP BY CODIGOCLIENTE) a
		ON a.CODIGOCLIENTE = c.CODIGOCLIENTE
		WHERE c.TZ_LOCK = 0)				
		
		IF @contador > 0
		BEGIN
			UPDATE c
			SET c.CATEGORIA_OFICIAL = a.CALIFICACION
			FROM CLI_CLIENTES c WITH (NOLOCK)
			INNER JOIN (SELECT CODIGOCLIENTE, max(SITUACION_ENTIDAD) AS CALIFICACION FROM CRE_BCRA_CENDEU WHERE FECHA_PROCESO = (SELECT FECHAPROCESO FROM PARAMETROS WITH (NOLOCK)) AND TZ_LOCK = 0 AND COD_ENTIDAD <> right(''000000'' + CAST((SELECT NUMERICO FROM PARAMETROSGENERALES WITH (NOLOCK) WHERE CODIGO = 2) AS VARCHAR(5)),5) GROUP BY CODIGOCLIENTE) a
			ON a.CODIGOCLIENTE = c.CODIGOCLIENTE
			WHERE c.TZ_LOCK = 0
		END
		  
		    SET @p_msg_proceso = ''El Proceso de Actualización de Situacion de BCRA ha finalizado correctamente. Registros procesados: ''+ CONVERT(VARCHAR(10), @contador)
			SET @p_ret_proceso = 1 		
			
			-- Logueo de información
			EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso 
				@p_id_proceso,
		    	@p_dt_proceso,
		    	''SP_ACTUALIZA_SITUACION_BCRA'',
		    	@p_cod_error = @p_ret_proceso, 
				@p_msg_error = @p_msg_proceso, 
				@p_tipo_error = @c_log_tipo_informacion
		END TRY
							             
		BEGIN CATCH
	
	        SET @p_ret_proceso = ERROR_NUMBER()
	        SET @p_msg_proceso = ''Ocurrió un error en el Proceso de Actualización de Situacion de BCRA: '' + ERROR_MESSAGE()
	
			EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso 
	        	@p_id_proceso = @p_id_proceso, 
	        	@p_fch_proceso = @p_dt_proceso, 
	        	@p_nom_package = ''SP_ACTUALIZA_SITUACION_BCRA'', 
	        	@p_cod_error = @p_ret_proceso, 
	        	@p_msg_error = @p_msg_proceso, 
	       		@p_tipo_error = @c_log_tipo_informacion
		END CATCH
END
')

EXECUTE('
IF OBJECT_ID (''SP_MARCA_CREDITO_ADICIONAL'') IS NOT NULL
	DROP PROCEDURE SP_MARCA_CREDITO_ADICIONAL
')

EXECUTE('
CREATE PROCEDURE [dbo].[SP_MARCA_CREDITO_ADICIONAL]
	@p_id_proceso FLOAT(53),     /* Identificador de proceso */
	@p_dt_proceso DATETIME,   /* Fecha de proceso */
	@p_ret_proceso FLOAT OUT, /* Estado de ejecucion SQL(0:Correcto, 2: Error) */
	@p_msg_proceso VARCHAR(MAX) OUT
AS
BEGIN
	DECLARE 
	------- Campos para el LOG --------
	@c_log_tipo_error varchar(30),
	@c_log_tipo_informacion VARCHAR(30),
	-----------------------------------	
	@contador NUMERIC(10)
	SET @contador = 0;
	------- Campos para el LOG --------
	SET @c_log_tipo_error = ''E'';
	SET @c_log_tipo_informacion = ''I'';
	-----------------------------------	

	BEGIN TRY
        	  
		SET @contador =	(SELECT count(1)
		FROM SALDOS s WITH (NOLOCK)
		INNER JOIN (SELECT count(*) AS CANTIDAD, C1803 AS CLIENTE 
					FROM SALDOS WITH (NOLOCK)
					WHERE C1604 < 0 AND C1785 = 5 AND C1695 = '' '' AND TZ_LOCK = 0 
					GROUP BY C1803) sc ON s.C1803 = sc.CLIENTE AND sc.CANTIDAD > 1
		INNER JOIN (SELECT sum(SALDO) AS DEUDA, CLIENTE AS CLIENTE 
					FROM VW_ASISTENCIAS WITH (NOLOCK)
					WHERE SALDO > 0
					GROUP BY CLIENTE) sd ON s.C1803 = sd.CLIENTE 			
		INNER JOIN CLI_CLIENTES c WITH (NOLOCK) ON s.C1803 = c.CODIGOCLIENTE AND c.TZ_LOCK = 0
		INNER JOIN CLI_CLASUBJETIVA co WITH (NOLOCK) ON c.CATEGORIAOBJETIVA = co.CATEGORIASUB AND co.TZ_LOCK = 0 AND 
		round(((s.C1604*-1)*100/NULLIF((sd.DEUDA - (s.C1604*-1)),0)),2) <= co.PORCENTAJE_SF  
		WHERE s.C1604 < 0 AND s.C1785 = 5 AND s.C1695 = '' '' AND s.TZ_LOCK = 0 AND s.C1621 = (SELECT FECHAPROCESO FROM PARAMETROS WITH (NOLOCK)))				
		
		IF @contador > 0
		BEGIN
			UPDATE s
			SET s.C1695 = ''S''
			FROM SALDOS s WITH (NOLOCK)
			INNER JOIN (
			SELECT s.JTS_OID
			FROM SALDOS s WITH (NOLOCK)
			INNER JOIN (SELECT count(*) AS CANTIDAD, C1803 AS CLIENTE 
						FROM SALDOS WITH (NOLOCK)
						WHERE C1604 < 0 AND C1785 = 5 AND C1695 = '' '' AND TZ_LOCK = 0 
						GROUP BY C1803) sc ON s.C1803 = sc.CLIENTE AND sc.CANTIDAD > 1
			INNER JOIN (SELECT sum(SALDO) AS DEUDA, CLIENTE AS CLIENTE 
						FROM VW_ASISTENCIAS WITH (NOLOCK)
						WHERE SALDO > 0
						GROUP BY CLIENTE) sd ON s.C1803 = sd.CLIENTE 			INNER JOIN CLI_CLIENTES c WITH (NOLOCK) ON s.C1803 = c.CODIGOCLIENTE AND c.TZ_LOCK = 0
			INNER JOIN CLI_CLASUBJETIVA co WITH (NOLOCK) ON c.CATEGORIAOBJETIVA = co.CATEGORIASUB AND co.TZ_LOCK = 0 AND 
			round(((s.C1604*-1)*100/NULLIF((sd.DEUDA - (s.C1604*-1)),0)),2) <= co.PORCENTAJE_SF  
			WHERE s.C1604 < 0 AND s.C1785 = 5 AND s.C1695 = '' '' AND s.TZ_LOCK = 0 AND s.C1621 = (SELECT FECHAPROCESO FROM PARAMETROS WITH (NOLOCK))) a
			ON a.JTS_OID = s.JTS_OID					
		END
		  
		    SET @p_msg_proceso = ''El Proceso de Marca de Credito Adicional ha finalizado correctamente. Registros procesados: ''+ CONVERT(VARCHAR(10), @contador)
			SET @p_ret_proceso = 1 		
			
			-- Logueo de información
			EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso 
				@p_id_proceso,
		    	@p_dt_proceso,
		    	''SP_MARCA_CREDITO_ADICIONAL'',
		    	@p_cod_error = @p_ret_proceso, 
				@p_msg_error = @p_msg_proceso, 
				@p_tipo_error = @c_log_tipo_informacion
		END TRY
							             
		BEGIN CATCH
	
	        SET @p_ret_proceso = ERROR_NUMBER()
	        SET @p_msg_proceso = ''Ocurrió un error en el Proceso de Marca de Credito Adicional: '' + ERROR_MESSAGE()
	
			EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso 
	        	@p_id_proceso = @p_id_proceso, 
	        	@p_fch_proceso = @p_dt_proceso, 
	        	@p_nom_package = ''SP_MARCA_CREDITO_ADICIONAL'', 
	        	@p_cod_error = @p_ret_proceso, 
	        	@p_msg_error = @p_msg_proceso, 
	       		@p_tipo_error = @c_log_tipo_informacion
		END CATCH
END
')

EXECUTE('
IF OBJECT_ID (''SP_DESESTIMA_CREDITO_ADICIONAL'') IS NOT NULL
	DROP PROCEDURE SP_DESESTIMA_CREDITO_ADICIONAL
')

EXECUTE('
CREATE PROCEDURE [dbo].[SP_DESESTIMA_CREDITO_ADICIONAL]
	@p_id_proceso FLOAT(53),     /* Identificador de proceso */
	@p_dt_proceso DATETIME,   /* Fecha de proceso */
	@p_ret_proceso FLOAT OUT, /* Estado de ejecucion SQL(0:Correcto, 2: Error) */
	@p_msg_proceso VARCHAR(MAX) OUT
AS
BEGIN
	DECLARE 
	------- Campos para el LOG --------
	@c_log_tipo_error varchar(30),
	@c_log_tipo_informacion VARCHAR(30),
	-----------------------------------	
	@contador NUMERIC(10)
	SET @contador = 0;
	------- Campos para el LOG --------
	SET @c_log_tipo_error = ''E'';
	SET @c_log_tipo_informacion = ''I'';
	-----------------------------------	

	BEGIN TRY
        	  
		SET @contador =	(SELECT count(1)
		FROM SALDOS s WITH (NOLOCK)
		WHERE C1695 = ''S'' AND C1785 = 5 AND C1604 < 0 AND TZ_LOCK = 0 AND 
		DATEADD(DAY,(SELECT DIASINMOVILIZADA FROM CRE_PARAMETROS WITH (NOLOCK) WHERE CODIGO = 167), C1628) < (SELECT FECHAPROCESO FROM PARAMETROS WITH (NOLOCK)))				
		
		IF @contador > 0
		BEGIN
			UPDATE s
			SET s.C1695 = ''D''
			FROM SALDOS s WITH (NOLOCK)
			INNER JOIN (
			SELECT s.JTS_OID 
			FROM SALDOS s
			WHERE C1695 = ''S'' AND C1785 = 5 AND C1604 < 0 AND TZ_LOCK = 0 AND 
			DATEADD(DAY,(SELECT DIASINMOVILIZADA FROM CRE_PARAMETROS WITH (NOLOCK) WHERE CODIGO = 167), C1628) < (SELECT FECHAPROCESO FROM PARAMETROS WITH (NOLOCK))) a
			ON a.JTS_OID = s.JTS_OID					
		END
		  
		    SET @p_msg_proceso = ''El Proceso de Desestimar Credito Adicional ha finalizado correctamente. Registros procesados: ''+ CONVERT(VARCHAR(10), @contador)
			SET @p_ret_proceso = 1 		
			
			-- Logueo de información
			EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso 
				@p_id_proceso,
		    	@p_dt_proceso,
		    	''SP_DESESTIMA_CREDITO_ADICIONAL'',
		    	@p_cod_error = @p_ret_proceso, 
				@p_msg_error = @p_msg_proceso, 
				@p_tipo_error = @c_log_tipo_informacion
		END TRY
							             
		BEGIN CATCH
	
	        SET @p_ret_proceso = ERROR_NUMBER()
	        SET @p_msg_proceso = ''Ocurrió un error en el Proceso de Desestimar Credito Adicional: '' + ERROR_MESSAGE()
	
			EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso 
	        	@p_id_proceso = @p_id_proceso, 
	        	@p_fch_proceso = @p_dt_proceso, 
	        	@p_nom_package = ''SP_DESESTIMA_CREDITO_ADICIONAL'', 
	        	@p_cod_error = @p_ret_proceso, 
	        	@p_msg_error = @p_msg_proceso, 
	       		@p_tipo_error = @c_log_tipo_informacion
		END CATCH
END
')

EXECUTE('
IF OBJECT_ID (''SP_LIMPIA_DISCREPANCIA'') IS NOT NULL
	DROP PROCEDURE SP_LIMPIA_DISCREPANCIA
')

EXECUTE('
CREATE PROCEDURE [dbo].[SP_LIMPIA_DISCREPANCIA]
	@p_id_proceso FLOAT(53),     /* Identificador de proceso */
	@p_dt_proceso DATETIME,   /* Fecha de proceso */
	@p_ret_proceso FLOAT OUT, /* Estado de ejecucion SQL(0:Correcto, 2: Error) */
	@p_msg_proceso VARCHAR(MAX) OUT
AS
BEGIN
	DECLARE 
	------- Campos para el LOG --------
	@c_log_tipo_error varchar(30),
	@c_log_tipo_informacion VARCHAR(30),
	-----------------------------------	
	@contador NUMERIC(10)
	SET @contador = 0;
	------- Campos para el LOG --------
	SET @c_log_tipo_error = ''E'';
	SET @c_log_tipo_informacion = ''I'';
	-----------------------------------	

	BEGIN TRY
        	  
		SET @contador =	(SELECT count(1) FROM CLI_CLIENTES WITH (NOLOCK) WHERE DISCREPANCIA IS NOT NULL OR DISCREPANCIA != '' '')				
		
		IF @contador > 0
		BEGIN
			UPDATE CLI_CLIENTES SET DISCREPANCIA = '' '' WHERE DISCREPANCIA IS NOT NULL OR DISCREPANCIA != '' '';
		END
		  
		    SET @p_msg_proceso = ''El Proceso de Limpieza de la Discrepancia ha finalizado correctamente. Registros procesados: ''+ CONVERT(VARCHAR(10), @contador)
			SET @p_ret_proceso = 1 		
			
			-- Logueo de información
			EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso 
				@p_id_proceso,
		    	@p_dt_proceso,
		    	''SP_LIMPIA_DISCREPANCIA'',
		    	@p_cod_error = @p_ret_proceso, 
				@p_msg_error = @p_msg_proceso, 
				@p_tipo_error = @c_log_tipo_informacion
		END TRY
							             
		BEGIN CATCH
	
	        SET @p_ret_proceso = ERROR_NUMBER()
	        SET @p_msg_proceso = ''Ocurrió un error en el Proceso de Limpieza de la Discrepancia: '' + ERROR_MESSAGE()
	
			EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso 
	        	@p_id_proceso = @p_id_proceso, 
	        	@p_fch_proceso = @p_dt_proceso, 
	        	@p_nom_package = ''SP_LIMPIA_DISCREPANCIA'', 
	        	@p_cod_error = @p_ret_proceso, 
	        	@p_msg_error = @p_msg_proceso, 
	       		@p_tipo_error = @c_log_tipo_informacion
		END CATCH
END
')

EXECUTE('
IF OBJECT_ID (''SP_ACTUALIZA_DISCREPANCIA'') IS NOT NULL
	DROP PROCEDURE SP_ACTUALIZA_DISCREPANCIA
')

EXECUTE('
CREATE PROCEDURE [dbo].[SP_ACTUALIZA_DISCREPANCIA]
	@p_id_proceso FLOAT(53),     /* Identificador de proceso */
	@p_dt_proceso DATETIME,   /* Fecha de proceso */
	@p_ret_proceso FLOAT OUT, /* Estado de ejecucion SQL(0:Correcto, 2: Error) */
	@p_msg_proceso VARCHAR(MAX) OUT
AS
BEGIN
	DECLARE 
	------- Campos para el LOG --------
	@c_log_tipo_error varchar(30),
	@c_log_tipo_informacion VARCHAR(30),
	-----------------------------------	
	@contador NUMERIC(10)
	SET @contador = 0;
	------- Campos para el LOG --------
	SET @c_log_tipo_error = ''E'';
	SET @c_log_tipo_informacion = ''I'';
	-----------------------------------	

	BEGIN TRY
        	  
		SET @contador =	(SELECT count(1)
		FROM CLI_CLIENTES c WITH (NOLOCK)
		-- Deuda fuera de la institucion que supere total de niveles peores
		INNER JOIN (SELECT cen.CODIGOCLIENTE, sum(cen.DEUDA_TOTAL) AS DEUDA 
				FROM CRE_BCRA_CENDEU cen WITH (NOLOCK)
				INNER JOIN CLI_CLIENTES cli WITH (NOLOCK) ON cen.CODIGOCLIENTE = cli.CODIGOCLIENTE AND cli.TZ_LOCK = 0
				INNER JOIN CLI_CLASUBJETIVA pon1 WITH (NOLOCK) ON pon1.CATEGORIASUB = CAST(cen.SITUACION_ENTIDAD AS VARCHAR(2)) AND pon1.TZ_LOCK = 0
				INNER JOIN CLI_CLASUBJETIVA pon2 WITH (NOLOCK) ON pon2.CATEGORIASUB = cli.CATEGORIAOBJETIVA AND pon2.TZ_LOCK = 0 AND pon2.PONDERACION + (SELECT DIASINMOVILIZADA FROM CRE_PARAMETROS WITH (NOLOCK) WHERE CODIGO = 170) < pon1.PONDERACION 
				WHERE cen.COD_ENTIDAD <> right(''00000'' + CAST((SELECT NUMERICO FROM PARAMETROSGENERALES WITH (NOLOCK) WHERE CODIGO = 2) AS VARCHAR(5)),5) AND cen.TZ_LOCK = 0 AND
				cen.COD_ENTIDAD NOT IN (SELECT right(''00000'' + CAST(ENTIDAD AS VARCHAR(5)),5) FROM CRE_Excep_Ent_Discrepancia WITH (NOLOCK) WHERE TZ_LOCK = 0 AND (CARTERA = ''T'' OR CARTERA = cli.CATEGORIA_COMERCIAL OR (CARTERA = ''C'' AND cli.CATEGORIA_COMERCIAL = ''S'')))		
				GROUP BY cen.CODIGOCLIENTE) d ON c.CODIGOCLIENTE = d.CODIGOCLIENTE 
		-- Deuda TOTAL fuera de la institucion
		INNER JOIN (SELECT cen.CODIGOCLIENTE, sum(cen.DEUDA_TOTAL) AS DEUDA 
				FROM CRE_BCRA_CENDEU cen WITH (NOLOCK)
				INNER JOIN CLI_CLIENTES cli WITH (NOLOCK) ON cen.CODIGOCLIENTE = cli.CODIGOCLIENTE AND cli.TZ_LOCK = 0
				WHERE cen.COD_ENTIDAD <> right(''00000'' + CAST((SELECT NUMERICO FROM PARAMETROSGENERALES WITH (NOLOCK) WHERE CODIGO = 2) AS VARCHAR(5)),5) AND cen.TZ_LOCK = 0 AND
				cen.COD_ENTIDAD NOT IN (SELECT right(''00000'' + CAST(ENTIDAD AS VARCHAR(5)),5) FROM CRE_Excep_Ent_Discrepancia WITH (NOLOCK) WHERE TZ_LOCK = 0 AND (CARTERA = ''T'' OR CARTERA = cli.CATEGORIA_COMERCIAL OR (CARTERA = ''C'' AND cli.CATEGORIA_COMERCIAL = ''S'')))				
				GROUP BY cen.CODIGOCLIENTE) dt ON c.CODIGOCLIENTE = dt.CODIGOCLIENTE 
		-- Busco deuda con la institucion		
		INNER JOIN (SELECT CODIGOCLIENTE, sum(DEUDA_TOTAL) AS DEUDA 
				FROM CRE_BCRA_CENDEU WITH (NOLOCK)
				WHERE COD_ENTIDAD = right(''00000'' + CAST((SELECT NUMERICO FROM PARAMETROSGENERALES WITH (NOLOCK) WHERE CODIGO = 2) AS VARCHAR(5)),5) AND TZ_LOCK = 0 				
				GROUP BY CODIGOCLIENTE) dm ON c.CODIGOCLIENTE = dm.CODIGOCLIENTE				
		/*INNER JOIN (SELECT sum(SALDO) AS DEUDA, CLIENTE 
				FROM VW_ASISTENCIAS WITH (NOLOCK)
				WHERE SALDO > 0
				GROUP BY CLIENTE ) dm ON c.CODIGOCLIENTE = dm.CLIENTE */
		-- Cantidad de entidades con niveles peores que el actual
		INNER JOIN (SELECT cen.CODIGOCLIENTE, count(cen.CODIGOCLIENTE) AS CANTIDAD
				FROM CRE_BCRA_CENDEU cen WITH (NOLOCK)
				INNER JOIN CLI_CLIENTES cli WITH (NOLOCK) ON cen.CODIGOCLIENTE = cli.CODIGOCLIENTE AND cli.TZ_LOCK = 0
				INNER JOIN CLI_CLASUBJETIVA pon1 WITH (NOLOCK) ON pon1.CATEGORIASUB = CAST(cen.SITUACION_ENTIDAD AS VARCHAR(2)) AND pon1.TZ_LOCK = 0
				INNER JOIN CLI_CLASUBJETIVA pon2 WITH (NOLOCK) ON pon2.CATEGORIASUB = cli.CATEGORIAOBJETIVA AND pon2.TZ_LOCK = 0 AND pon2.PONDERACION + (SELECT DIASINMOVILIZADA FROM CRE_PARAMETROS WITH (NOLOCK) WHERE CODIGO = 170) < pon1.PONDERACION 
				WHERE cen.COD_ENTIDAD <> right(''00000'' + CAST((SELECT NUMERICO FROM PARAMETROSGENERALES WITH (NOLOCK) WHERE CODIGO = 2) AS VARCHAR(5)),5) AND cen.TZ_LOCK = 0  AND
				cen.COD_ENTIDAD NOT IN (SELECT right(''00000'' + CAST(ENTIDAD AS VARCHAR(5)),5) FROM CRE_Excep_Ent_Discrepancia WITH (NOLOCK) WHERE TZ_LOCK = 0 AND (CARTERA = ''T'' OR CARTERA = cli.CATEGORIA_COMERCIAL OR (CARTERA = ''C'' AND cli.CATEGORIA_COMERCIAL = ''S'')))
				GROUP BY cen.CODIGOCLIENTE) cant ON c.CODIGOCLIENTE = cant.CODIGOCLIENTE AND cant.CANTIDAD >= (SELECT DIASINMOVILIZADA FROM CRE_PARAMETROS WITH (NOLOCK) WHERE CODIGO = 169)			
		-- Busco peor nivel con mayor deuda			   
		INNER JOIN (SELECT b.CODIGOCLIENTE, b.PONDERACION 
					FROM (
						SELECT a.CODIGOCLIENTE, a.PONDERACION,
						ROW_NUMBER() OVER(PARTITION BY a.CODIGOCLIENTE ORDER BY a.DEUDA_TOTAL DESC) AS CANTIDAD
						FROM(
							SELECT cen.CODIGOCLIENTE, pon1.PONDERACION, sum(cen.DEUDA_TOTAL) AS DEUDA_TOTAL
							FROM CRE_BCRA_CENDEU cen WITH (NOLOCK)
							INNER JOIN CLI_CLIENTES cli WITH (NOLOCK) ON cen.CODIGOCLIENTE = cli.CODIGOCLIENTE AND cli.TZ_LOCK = 0
							INNER JOIN CLI_CLASUBJETIVA pon1 WITH (NOLOCK) ON pon1.CATEGORIASUB = CAST(cen.SITUACION_ENTIDAD AS VARCHAR(2)) AND pon1.TZ_LOCK = 0
							INNER JOIN CLI_CLASUBJETIVA pon2 WITH (NOLOCK) ON pon2.CATEGORIASUB = cli.CATEGORIAOBJETIVA AND pon2.TZ_LOCK = 0 AND pon2.PONDERACION + (SELECT DIASINMOVILIZADA FROM CRE_PARAMETROS WITH (NOLOCK) WHERE CODIGO = 170) < pon1.PONDERACION 
							WHERE cen.COD_ENTIDAD <> right(''00000'' + CAST((SELECT NUMERICO FROM PARAMETROSGENERALES WITH (NOLOCK) WHERE CODIGO = 2) AS VARCHAR(5)),5) AND cen.TZ_LOCK = 0  AND
							cen.COD_ENTIDAD NOT IN (SELECT right(''00000'' + CAST(ENTIDAD AS VARCHAR(5)),5) FROM CRE_Excep_Ent_Discrepancia WITH (NOLOCK) WHERE TZ_LOCK = 0 AND (CARTERA = ''T'' OR CARTERA = cli.CATEGORIA_COMERCIAL OR (CARTERA = ''C'' AND cli.CATEGORIA_COMERCIAL = ''S'')))
							GROUP BY cen.CODIGOCLIENTE, pon1.PONDERACION) a 
						) b
					WHERE b.CANTIDAD = 1) pn ON c.CODIGOCLIENTE = pn.CODIGOCLIENTE	
		WHERE c.TZ_LOCK = 0 AND
		round(( d.DEUDA / (dt.DEUDA + dm.DEUDA) ),2) * 100  >= (SELECT IMPORTE FROM CRE_PARAMETROS WITH (NOLOCK) WHERE CODIGO = 168))				
		
		IF @contador > 0
		BEGIN
			UPDATE c
			SET c.DISCREPANCIA = a.CATEGORIASUB
			FROM CLI_CLIENTES c WITH (NOLOCK)
			INNER JOIN (SELECT c.CODIGOCLIENTE, p.CATEGORIASUB
				FROM CLI_CLIENTES c WITH (NOLOCK)
				-- Deuda fuera de la institucion que supere total de niveles peores
				INNER JOIN (SELECT cen.CODIGOCLIENTE, sum(cen.DEUDA_TOTAL) AS DEUDA 
						FROM CRE_BCRA_CENDEU cen WITH (NOLOCK)
						INNER JOIN CLI_CLIENTES cli WITH (NOLOCK) ON cen.CODIGOCLIENTE = cli.CODIGOCLIENTE AND cli.TZ_LOCK = 0
						INNER JOIN CLI_CLASUBJETIVA pon1 WITH (NOLOCK) ON pon1.CATEGORIASUB = CAST(cen.SITUACION_ENTIDAD AS VARCHAR(2)) AND pon1.TZ_LOCK = 0
						INNER JOIN CLI_CLASUBJETIVA pon2 WITH (NOLOCK) ON pon2.CATEGORIASUB = cli.CATEGORIAOBJETIVA AND pon2.TZ_LOCK = 0 AND pon2.PONDERACION + (SELECT DIASINMOVILIZADA FROM CRE_PARAMETROS WITH (NOLOCK) WHERE CODIGO = 170) < pon1.PONDERACION 
						WHERE cen.COD_ENTIDAD <> right(''00000'' + CAST((SELECT NUMERICO FROM PARAMETROSGENERALES WITH (NOLOCK) WHERE CODIGO = 2) AS VARCHAR(5)),5) AND cen.TZ_LOCK = 0 AND
						cen.COD_ENTIDAD NOT IN (SELECT right(''00000'' + CAST(ENTIDAD AS VARCHAR(5)),5) FROM CRE_Excep_Ent_Discrepancia WITH (NOLOCK) WHERE TZ_LOCK = 0 AND (CARTERA = ''T'' OR CARTERA = cli.CATEGORIA_COMERCIAL OR (CARTERA = ''C'' AND cli.CATEGORIA_COMERCIAL = ''S'')))		
						GROUP BY cen.CODIGOCLIENTE) d ON c.CODIGOCLIENTE = d.CODIGOCLIENTE 
				-- Deuda TOTAL fuera de la institucion
				INNER JOIN (SELECT cen.CODIGOCLIENTE, sum(cen.DEUDA_TOTAL) AS DEUDA 
						FROM CRE_BCRA_CENDEU cen WITH (NOLOCK)
						INNER JOIN CLI_CLIENTES cli WITH (NOLOCK) ON cen.CODIGOCLIENTE = cli.CODIGOCLIENTE AND cli.TZ_LOCK = 0
						WHERE cen.COD_ENTIDAD <> right(''00000'' + CAST((SELECT NUMERICO FROM PARAMETROSGENERALES WITH (NOLOCK) WHERE CODIGO = 2) AS VARCHAR(5)),5) AND cen.TZ_LOCK = 0 AND
						cen.COD_ENTIDAD NOT IN (SELECT right(''00000'' + CAST(ENTIDAD AS VARCHAR(5)),5) FROM CRE_Excep_Ent_Discrepancia WITH (NOLOCK) WHERE TZ_LOCK = 0 AND (CARTERA = ''T'' OR CARTERA = cli.CATEGORIA_COMERCIAL OR (CARTERA = ''C'' AND cli.CATEGORIA_COMERCIAL = ''S'')))				
						GROUP BY cen.CODIGOCLIENTE) dt ON c.CODIGOCLIENTE = dt.CODIGOCLIENTE 
				-- Busco deuda con la institucion		
				INNER JOIN (SELECT CODIGOCLIENTE, sum(DEUDA_TOTAL) AS DEUDA 
						FROM CRE_BCRA_CENDEU WITH (NOLOCK)
						WHERE COD_ENTIDAD = right(''00000'' + CAST((SELECT NUMERICO FROM PARAMETROSGENERALES WITH (NOLOCK) WHERE CODIGO = 2) AS VARCHAR(5)),5) AND TZ_LOCK = 0 				
						GROUP BY CODIGOCLIENTE) dm ON c.CODIGOCLIENTE = dm.CODIGOCLIENTE				
				/*INNER JOIN (SELECT sum(SALDO) AS DEUDA, CLIENTE 
						FROM VW_ASISTENCIAS WITH (NOLOCK)
						WHERE SALDO > 0
						GROUP BY CLIENTE ) dm ON c.CODIGOCLIENTE = dm.CLIENTE */
				-- Cantidad de entidades con niveles peores que el actual
				INNER JOIN (SELECT cen.CODIGOCLIENTE, count(cen.CODIGOCLIENTE) AS CANTIDAD
						FROM CRE_BCRA_CENDEU cen WITH (NOLOCK)
						INNER JOIN CLI_CLIENTES cli WITH (NOLOCK) ON cen.CODIGOCLIENTE = cli.CODIGOCLIENTE AND cli.TZ_LOCK = 0
						INNER JOIN CLI_CLASUBJETIVA pon1 WITH (NOLOCK) ON pon1.CATEGORIASUB = CAST(cen.SITUACION_ENTIDAD AS VARCHAR(2)) AND pon1.TZ_LOCK = 0
						INNER JOIN CLI_CLASUBJETIVA pon2 WITH (NOLOCK) ON pon2.CATEGORIASUB = cli.CATEGORIAOBJETIVA AND pon2.TZ_LOCK = 0 AND pon2.PONDERACION + (SELECT DIASINMOVILIZADA FROM CRE_PARAMETROS WITH (NOLOCK) WHERE CODIGO = 170) < pon1.PONDERACION 
						WHERE cen.COD_ENTIDAD <> right(''00000'' + CAST((SELECT NUMERICO FROM PARAMETROSGENERALES WITH (NOLOCK) WHERE CODIGO = 2) AS VARCHAR(5)),5) AND cen.TZ_LOCK = 0  AND
						cen.COD_ENTIDAD NOT IN (SELECT right(''00000'' + CAST(ENTIDAD AS VARCHAR(5)),5) FROM CRE_Excep_Ent_Discrepancia WITH (NOLOCK) WHERE TZ_LOCK = 0 AND (CARTERA = ''T'' OR CARTERA = cli.CATEGORIA_COMERCIAL OR (CARTERA = ''C'' AND cli.CATEGORIA_COMERCIAL = ''S'')))
						GROUP BY cen.CODIGOCLIENTE) cant ON c.CODIGOCLIENTE = cant.CODIGOCLIENTE AND cant.CANTIDAD >= (SELECT DIASINMOVILIZADA FROM CRE_PARAMETROS WITH (NOLOCK) WHERE CODIGO = 169)			
				-- Busco peor nivel con mayor deuda			   
				INNER JOIN (SELECT b.CODIGOCLIENTE, b.PONDERACION FROM (
								SELECT a.CODIGOCLIENTE, a.PONDERACION,
								ROW_NUMBER() OVER(PARTITION BY a.CODIGOCLIENTE ORDER BY a.DEUDA_TOTAL DESC) AS CANTIDAD
								FROM(
									SELECT cen.CODIGOCLIENTE, pon1.PONDERACION, sum(cen.DEUDA_TOTAL) AS DEUDA_TOTAL
									FROM CRE_BCRA_CENDEU cen WITH (NOLOCK)
									INNER JOIN CLI_CLIENTES cli WITH (NOLOCK) ON cen.CODIGOCLIENTE = cli.CODIGOCLIENTE AND cli.TZ_LOCK = 0
									INNER JOIN CLI_CLASUBJETIVA pon1 WITH (NOLOCK) ON pon1.CATEGORIASUB = CAST(cen.SITUACION_ENTIDAD AS VARCHAR(2)) AND pon1.TZ_LOCK = 0
									INNER JOIN CLI_CLASUBJETIVA pon2 WITH (NOLOCK) ON pon2.CATEGORIASUB = cli.CATEGORIAOBJETIVA AND pon2.TZ_LOCK = 0 AND pon2.PONDERACION + (SELECT DIASINMOVILIZADA FROM CRE_PARAMETROS WITH (NOLOCK) WHERE CODIGO = 170) < pon1.PONDERACION 
									WHERE cen.COD_ENTIDAD <> right(''00000'' + CAST((SELECT NUMERICO FROM PARAMETROSGENERALES WITH (NOLOCK) WHERE CODIGO = 2) AS VARCHAR(5)),5) AND cen.TZ_LOCK = 0  AND
									cen.COD_ENTIDAD NOT IN (SELECT right(''00000'' + CAST(ENTIDAD AS VARCHAR(5)),5) FROM CRE_Excep_Ent_Discrepancia WITH (NOLOCK) WHERE TZ_LOCK = 0 AND (CARTERA = ''T'' OR CARTERA = cli.CATEGORIA_COMERCIAL OR (CARTERA = ''C'' AND cli.CATEGORIA_COMERCIAL = ''S'')))
									GROUP BY cen.CODIGOCLIENTE, pon1.PONDERACION) a ) b
								WHERE b.CANTIDAD = 1) pn ON c.CODIGOCLIENTE = pn.CODIGOCLIENTE	
				INNER JOIN CLI_CLASUBJETIVA p ON pn.PONDERACION - (SELECT DIASINMOVILIZADA FROM CRE_PARAMETROS WITH (NOLOCK) WHERE CODIGO = 171) = p.PONDERACION AND p.TZ_LOCK = 0
				WHERE c.TZ_LOCK = 0 AND
				round((d.DEUDA / (dt.DEUDA + dm.DEUDA) ),2) * 100 >= (SELECT IMPORTE FROM CRE_PARAMETROS WITH (NOLOCK) WHERE CODIGO = 168)) a
			ON a.CODIGOCLIENTE = c.CODIGOCLIENTE
			WHERE c.TZ_LOCK = 0		
		END
		  
		SET @p_msg_proceso = ''El Proceso de Actualización de Discrepancia ha finalizado correctamente. Registros procesados: ''+ CONVERT(VARCHAR(10), @contador)
		SET @p_ret_proceso = 1 		
			
		-- Logueo de información
		EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso 
			@p_id_proceso,
		   	@p_dt_proceso,
		   	''SP_ACTUALIZA_DISCREPANCIA'',
		   	@p_cod_error = @p_ret_proceso, 
			@p_msg_error = @p_msg_proceso, 
			@p_tipo_error = @c_log_tipo_informacion
	END TRY
							             
	BEGIN CATCH
	
	    SET @p_ret_proceso = ERROR_NUMBER()
	    SET @p_msg_proceso = ''Ocurrió un error en el Proceso de Actualización de Discrepancia: '' + ERROR_MESSAGE()
	
		EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso 
	       	@p_id_proceso = @p_id_proceso, 
	       	@p_fch_proceso = @p_dt_proceso, 
	       	@p_nom_package = ''SP_ACTUALIZA_DISCREPANCIA'', 
	       	@p_cod_error = @p_ret_proceso, 
	       	@p_msg_error = @p_msg_proceso, 
	  		@p_tipo_error = @c_log_tipo_informacion
	END CATCH
END
')

EXECUTE('
IF OBJECT_ID (''SP_ACTUALIZA_MOROSOS'') IS NOT NULL
	DROP PROCEDURE SP_ACTUALIZA_MOROSOS
')

EXECUTE('
CREATE PROCEDURE [dbo].[SP_ACTUALIZA_MOROSOS]
	@p_id_proceso FLOAT(53),     /* Identificador de proceso */
	@p_dt_proceso DATETIME,   /* Fecha de proceso */
	@p_ret_proceso FLOAT OUT, /* Estado de ejecucion SQL(0:Correcto, 2: Error) */
	@p_msg_proceso VARCHAR(MAX) OUT
AS
BEGIN
	DECLARE 
	------- Campos para el LOG --------
	@c_log_tipo_error varchar(30),
	@c_log_tipo_informacion VARCHAR(30),
	-----------------------------------	
	@contador NUMERIC(10)
	SET @contador = 0;
	------- Campos para el LOG --------
	SET @c_log_tipo_error = ''E'';
	SET @c_log_tipo_informacion = ''I'';
	-----------------------------------	

	BEGIN TRY
        	  
		SET @contador =	(SELECT count(1)
			FROM ITF_BCRA_MOREXENT b WITH (NOLOCK)
			INNER JOIN (SELECT DISTINCT doc.TIPODOCUMENTO, doc.NUMERODOCUMENTO, c.CODIGOCLIENTE
			FROM CLI_CLIENTES c WITH (NOLOCK) 
			INNER JOIN CLI_CLIENTEPERSONA cp WITH (NOLOCK) ON c.CODIGOCLIENTE = cp.CODIGOCLIENTE AND cp.TITULARIDAD = ''T'' AND cp.TZ_LOCK = 0
			INNER JOIN CLI_DocumentosPFPJ doc WITH (NOLOCK) ON cp.NUMEROPERSONA = doc.NUMEROPERSONAFJ AND doc.TZ_LOCK = 0
			WHERE c.TZ_LOCK = 0) a ON b.NRO_IDENTIFICACION = a.NUMERODOCUMENTO 
			WHERE b.TPO_IDENTIFICACION = 11 AND b.TZ_LOCK = 0)				
		
		IF @contador > 0
		BEGIN
			TRUNCATE TABLE CRE_BCRA_MOREXENT	
		
			INSERT INTO CRE_BCRA_MOREXENT (FECHA_PROCESO, CODIGOCLIENTE, FECHA, DENOMINACION, TPO_IDENTIFICACION, NRO_IDENTIFICACION, PROC_JUDICIAL, TZ_LOCK)
			SELECT (SELECT FECHAPROCESO FROM PARAMETROS WITH (NOLOCK)), a.CODIGOCLIENTE, b.FECHA, b.DENOMINACION, b.TPO_IDENTIFICACION, b.NRO_IDENTIFICACION, b.PROC_JUDICIAL, b.TZ_LOCK
			FROM ITF_BCRA_MOREXENT b WITH (NOLOCK)
			INNER JOIN (SELECT DISTINCT doc.TIPODOCUMENTO, doc.NUMERODOCUMENTO, c.CODIGOCLIENTE
			FROM CLI_CLIENTES c WITH (NOLOCK) 
			INNER JOIN CLI_CLIENTEPERSONA cp WITH (NOLOCK) ON c.CODIGOCLIENTE = cp.CODIGOCLIENTE AND cp.TITULARIDAD = ''T'' AND cp.TZ_LOCK = 0
			INNER JOIN CLI_DocumentosPFPJ doc WITH (NOLOCK) ON cp.NUMEROPERSONA = doc.NUMEROPERSONAFJ AND doc.TZ_LOCK = 0
			WHERE c.TZ_LOCK = 0) a ON b.NRO_IDENTIFICACION = a.NUMERODOCUMENTO 
			WHERE b.TPO_IDENTIFICACION = 11 AND b.TZ_LOCK = 0
		END
		  
		    SET @p_msg_proceso = ''El Proceso de Actualización de Morosos ex Entidades ha finalizado correctamente. Registros procesados: ''+ CONVERT(VARCHAR(10), @contador)
			SET @p_ret_proceso = 1 		
			
			-- Logueo de información
			EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso 
				@p_id_proceso,
		    	@p_dt_proceso,
		    	''SP_ACTUALIZA_MOROSOS'',
		    	@p_cod_error = @p_ret_proceso, 
				@p_msg_error = @p_msg_proceso, 
				@p_tipo_error = @c_log_tipo_informacion
		END TRY
							             
		BEGIN CATCH
	
	        SET @p_ret_proceso = ERROR_NUMBER()
	        SET @p_msg_proceso = ''Ocurrió un error en el Proceso de Actualización de Morosos ex Entidades: '' + ERROR_MESSAGE()
	
			EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso 
	        	@p_id_proceso = @p_id_proceso, 
	        	@p_fch_proceso = @p_dt_proceso, 
	        	@p_nom_package = ''SP_ACTUALIZA_MOROSOS'', 
	        	@p_cod_error = @p_ret_proceso, 
	        	@p_msg_error = @p_msg_proceso, 
	       		@p_tipo_error = @c_log_tipo_informacion
		END CATCH
END
')

EXECUTE('
IF OBJECT_ID (''SP_ACTUALIZA_MOROSOS_NUEVOS'') IS NOT NULL
	DROP PROCEDURE SP_ACTUALIZA_MOROSOS_NUEVOS
')

EXECUTE('
CREATE PROCEDURE [dbo].[SP_ACTUALIZA_MOROSOS_NUEVOS]
	@p_id_proceso FLOAT(53),     /* Identificador de proceso */
	@p_dt_proceso DATETIME,   /* Fecha de proceso */
	@p_ret_proceso FLOAT OUT, /* Estado de ejecucion SQL(0:Correcto, 2: Error) */
	@p_msg_proceso VARCHAR(MAX) OUT
AS
BEGIN
	DECLARE 
	------- Campos para el LOG --------
	@c_log_tipo_error varchar(30),
	@c_log_tipo_informacion VARCHAR(30),
	-----------------------------------	
	@contador NUMERIC(10)
	SET @contador = 0;
	------- Campos para el LOG --------
	SET @c_log_tipo_error = ''E'';
	SET @c_log_tipo_informacion = ''I'';
	-----------------------------------	

	BEGIN TRY
        	  
		SET @contador =	(SELECT count(1)
			FROM ITF_BCRA_MOREXENT b WITH (NOLOCK)
			INNER JOIN (SELECT DISTINCT doc.TIPODOCUMENTO, doc.NUMERODOCUMENTO, c.CODIGOCLIENTE
			FROM CLI_CLIENTES c WITH (NOLOCK) 
			INNER JOIN CLI_CLIENTEPERSONA cp WITH (NOLOCK) ON c.CODIGOCLIENTE = cp.CODIGOCLIENTE AND cp.TITULARIDAD = ''T'' AND cp.TZ_LOCK = 0
			INNER JOIN CLI_DocumentosPFPJ doc WITH (NOLOCK) ON cp.NUMEROPERSONA = doc.NUMEROPERSONAFJ AND doc.TZ_LOCK = 0
			WHERE c.FECHAAPERTURA = (SELECT FECHAPROCESO FROM PARAMETROS WITH (NOLOCK)) AND c.TZ_LOCK = 0) a ON b.NRO_IDENTIFICACION = a.NUMERODOCUMENTO AND a.CODIGOCLIENTE NOT IN (SELECT CODIGOCLIENTE FROM CRE_BCRA_MOREXENT WITH (NOLOCK) WHERE TZ_LOCK = 0 AND FECHA_PROCESO = (SELECT FECHAPROCESO FROM PARAMETROS WITH (NOLOCK)))
			WHERE b.TPO_IDENTIFICACION = 11 AND b.TZ_LOCK = 0)				
		
		IF @contador > 0
		BEGIN		
			INSERT INTO CRE_BCRA_MOREXENT (FECHA_PROCESO, CODIGOCLIENTE, FECHA, DENOMINACION, TPO_IDENTIFICACION, NRO_IDENTIFICACION, PROC_JUDICIAL, TZ_LOCK)
			SELECT (SELECT FECHAPROCESO FROM PARAMETROS WITH (NOLOCK)), a.CODIGOCLIENTE, b.FECHA, b.DENOMINACION, b.TPO_IDENTIFICACION, b.NRO_IDENTIFICACION, b.PROC_JUDICIAL, b.TZ_LOCK
			FROM ITF_BCRA_MOREXENT b WITH (NOLOCK)
			INNER JOIN (SELECT DISTINCT doc.TIPODOCUMENTO, doc.NUMERODOCUMENTO, c.CODIGOCLIENTE
			FROM CLI_CLIENTES c WITH (NOLOCK) 
			INNER JOIN CLI_CLIENTEPERSONA cp WITH (NOLOCK) ON c.CODIGOCLIENTE = cp.CODIGOCLIENTE AND cp.TITULARIDAD = ''T'' AND cp.TZ_LOCK = 0
			INNER JOIN CLI_DocumentosPFPJ doc WITH (NOLOCK) ON cp.NUMEROPERSONA = doc.NUMEROPERSONAFJ AND doc.TZ_LOCK = 0
			WHERE c.FECHAAPERTURA = (SELECT FECHAPROCESO FROM PARAMETROS WITH (NOLOCK)) AND c.TZ_LOCK = 0) a ON b.NRO_IDENTIFICACION = a.NUMERODOCUMENTO AND a.CODIGOCLIENTE NOT IN (SELECT CODIGOCLIENTE FROM CRE_BCRA_MOREXENT WITH (NOLOCK) WHERE TZ_LOCK = 0 AND FECHA_PROCESO = (SELECT FECHAPROCESO FROM PARAMETROS WITH (NOLOCK)))
			WHERE b.TPO_IDENTIFICACION = 11 AND b.TZ_LOCK = 0
		END
		  
		    SET @p_msg_proceso = ''El Proceso de Actualización de Morosos ex Entidades Nuevos ha finalizado correctamente. Registros procesados: ''+ CONVERT(VARCHAR(10), @contador)
			SET @p_ret_proceso = 1 		
			
			-- Logueo de información
			EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso 
				@p_id_proceso,
		    	@p_dt_proceso,
		    	''SP_ACTUALIZA_MOROSOS_NUEVOS'',
		    	@p_cod_error = @p_ret_proceso, 
				@p_msg_error = @p_msg_proceso, 
				@p_tipo_error = @c_log_tipo_informacion
		END TRY
							             
		BEGIN CATCH
	
	        SET @p_ret_proceso = ERROR_NUMBER()
	        SET @p_msg_proceso = ''Ocurrió un error en el Proceso de Actualización de Morosos ex Entidades Nuevos: '' + ERROR_MESSAGE()
	
			EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso 
	        	@p_id_proceso = @p_id_proceso, 
	        	@p_fch_proceso = @p_dt_proceso, 
	        	@p_nom_package = ''SP_ACTUALIZA_MOROSOS_NUEVOS'', 
	        	@p_cod_error = @p_ret_proceso, 
	        	@p_msg_error = @p_msg_proceso, 
	       		@p_tipo_error = @c_log_tipo_informacion
		END CATCH
END

')

EXECUTE('
IF OBJECT_ID (''SP_ACTUALIZA_MOROSOS_SITUACION'') IS NOT NULL
	DROP PROCEDURE SP_ACTUALIZA_MOROSOS_SITUACION
')

EXECUTE('	
CREATE PROCEDURE [dbo].[SP_ACTUALIZA_MOROSOS_SITUACION]
	@p_id_proceso FLOAT(53),     /* Identificador de proceso */
	@p_dt_proceso DATETIME,   /* Fecha de proceso */
	@p_ret_proceso FLOAT OUT, /* Estado de ejecucion SQL(0:Correcto, 2: Error) */
	@p_msg_proceso VARCHAR(MAX) OUT
AS
BEGIN
	DECLARE 
	------- Campos para el LOG --------
	@c_log_tipo_error varchar(30),
	@c_log_tipo_informacion VARCHAR(30),
	-----------------------------------	
	@contador NUMERIC(10),
	@contadorLimpiar NUMERIC(10)
	SET @contador = 0;
	SET @contadorLimpiar = 0;
	------- Campos para el LOG --------
	SET @c_log_tipo_error = ''E'';
	SET @c_log_tipo_informacion = ''I'';
	-----------------------------------	

	BEGIN TRY

		SET @contadorLimpiar =(SELECT count(1) FROM CRE_BCRA_MOREXENT WITH (NOLOCK) WHERE FECHA_PROCESO <> (SELECT FECHAPROCESO FROM PARAMETROS WITH (NOLOCK)) AND TZ_LOCK = 0)   

		SET @contador =	(SELECT count(1)			
		FROM CLI_CLIENTES c WITH (NOLOCK)
		INNER JOIN (SELECT CODIGOCLIENTE FROM CRE_BCRA_MOREXENT WITH (NOLOCK) WHERE FECHA_PROCESO = (SELECT FECHAPROCESO FROM PARAMETROS WITH (NOLOCK)) AND TZ_LOCK = 0) a
		ON a.CODIGOCLIENTE = c.CODIGOCLIENTE
		WHERE c.TZ_LOCK = 0)				
		
		IF @contadorLimpiar = 0 AND @contador > 0
		BEGIN		   	
			UPDATE CLI_CLIENTES SET Sit_MorExEnt = '' ''
		END					
        	  				
		IF @contador > 0
		BEGIN		   	
			UPDATE c
			SET c.Sit_MorExEnt  = ''6''
			FROM CLI_CLIENTES c WITH (NOLOCK)
			INNER JOIN (SELECT CODIGOCLIENTE FROM CRE_BCRA_MOREXENT WITH (NOLOCK) WHERE FECHA_PROCESO = (SELECT FECHAPROCESO FROM PARAMETROS WITH (NOLOCK)) AND TZ_LOCK = 0) a
			ON a.CODIGOCLIENTE = c.CODIGOCLIENTE
			WHERE c.TZ_LOCK = 0	
		END
				  
		    SET @p_msg_proceso = ''El Proceso de Actualización de Situacion de Morosos ex Entidades ha finalizado correctamente. Registros procesados: ''+ CONVERT(VARCHAR(10), @contador)
			SET @p_ret_proceso = 1 		
			
			-- Logueo de información
			EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso 
				@p_id_proceso,
		    	@p_dt_proceso,
		    	''SP_ACTUALIZA_MOROSOS_SITUACION'',
		    	@p_cod_error = @p_ret_proceso, 
				@p_msg_error = @p_msg_proceso, 
				@p_tipo_error = @c_log_tipo_informacion
		END TRY
							             
		BEGIN CATCH
	
	        SET @p_ret_proceso = ERROR_NUMBER()
	        SET @p_msg_proceso = ''Ocurrió un error en el Proceso de Actualización de Situacion de Morosos ex Entidades: '' + ERROR_MESSAGE()
	
			EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso 
	        	@p_id_proceso = @p_id_proceso, 
	        	@p_fch_proceso = @p_dt_proceso, 
	        	@p_nom_package = ''SP_ACTUALIZA_MOROSOS_SITUACION'', 
	        	@p_cod_error = @p_ret_proceso, 
	        	@p_msg_error = @p_msg_proceso, 
	       		@p_tipo_error = @c_log_tipo_informacion
		END CATCH
END
')

EXECUTE('
IF OBJECT_ID (''SP_ACTUALIZA_SITUACION_RESULTANTE'') IS NOT NULL
	DROP PROCEDURE SP_ACTUALIZA_SITUACION_RESULTANTE
')

EXECUTE('
CREATE PROCEDURE [dbo].[SP_ACTUALIZA_SITUACION_RESULTANTE]
	@p_id_proceso FLOAT(53),     /* Identificador de proceso */
	@p_dt_proceso DATETIME,   /* Fecha de proceso */
	@p_ret_proceso FLOAT OUT, /* Estado de ejecucion SQL(0:Correcto, 2: Error) */
	@p_msg_proceso VARCHAR(MAX) OUT
AS
BEGIN
	DECLARE 
	------- Campos para el LOG --------
	@c_log_tipo_error varchar(30),
	@c_log_tipo_informacion VARCHAR(30),
	-----------------------------------	
	@contador NUMERIC(10)
	SET @contador = 0;
	------- Campos para el LOG --------
	SET @c_log_tipo_error = ''E'';
	SET @c_log_tipo_informacion = ''I'';
	-----------------------------------	

	BEGIN TRY
        	  
		SET @contador =	(SELECT count(1) FROM CLI_CLIENTES WHERE NIVEL_APERTURA = 3 AND TZ_LOCK = 0)				
		
		IF @contador > 0
		BEGIN
			UPDATE c
			SET c.CATEGORIARESULTANTE = a.CALIFICACION
			FROM CLI_CLIENTES c WITH (NOLOCK)
			INNER JOIN (
			SELECT CASE WHEN CATEGORIASUBJETIVA <> '' '' AND CATEGORIASUBJETIVA IS NOT NULL THEN CATEGORIASUBJETIVA 
			WHEN Sit_MorExEnt <> '' '' AND Sit_MorExEnt IS NOT NULL THEN Sit_MorExEnt 
			WHEN SITUACION_JUDICIAL <> '' '' AND SITUACION_JUDICIAL IS NOT NULL THEN SITUACION_JUDICIAL
			WHEN DISCREPANCIA <> '' '' AND DISCREPANCIA IS NOT NULL THEN DISCREPANCIA
			WHEN OBJETIVA_REFINANCIADO <> '' '' AND OBJETIVA_REFINANCIADO IS NOT NULL THEN OBJETIVA_REFINANCIADO
			ELSE CATEGORIAOBJETIVA END AS CALIFICACION,
			CODIGOCLIENTE 
			FROM CLI_CLIENTES WITH (NOLOCK) WHERE NIVEL_APERTURA = 3 AND TZ_LOCK = 0) a
			ON a.CODIGOCLIENTE = c.CODIGOCLIENTE
			
			DELETE HISTORICO_CALIF_X_CLIENTE WHERE CLIENTE IN (SELECT CODIGOCLIENTE FROM CLI_CLIENTES WITH (NOLOCK) WHERE NIVEL_APERTURA = 3 AND TZ_LOCK = 0) AND FECHA = (SELECT FECHAPROCESO FROM PARAMETROS)
			
			INSERT INTO dbo.HISTORICO_CALIF_X_CLIENTE (CLIENTE, FECHA, CALIFICACION_OBJETIVA, CALIFICACION_REESTRUCTURADA, CALIFICACION_SUBJETIVA, CALIFICACION_SF, CALIFICACION_RESULTANTE, TIPO_RIESGO, DIAS_ATRASO, TZ_LOCK, SITUACION_JUDICIAL, Sit_MorExEnt, DISCREPANCIA, TIPO_CALIFICACION)
			SELECT CODIGOCLIENTE, (SELECT FECHAPROCESO FROM PARAMETROS WITH (NOLOCK)), CATEGORIAOBJETIVA, REESTRUCTURA, CATEGORIASUBJETIVA, CATEGORIA_OFICIAL, 
			CASE WHEN CATEGORIASUBJETIVA <> '' '' AND CATEGORIASUBJETIVA IS NOT NULL THEN CATEGORIASUBJETIVA 
			WHEN Sit_MorExEnt <> '' '' AND Sit_MorExEnt IS NOT NULL THEN Sit_MorExEnt 
			WHEN SITUACION_JUDICIAL <> '' '' AND SITUACION_JUDICIAL IS NOT NULL THEN SITUACION_JUDICIAL
			WHEN DISCREPANCIA <> '' '' AND DISCREPANCIA IS NOT NULL THEN DISCREPANCIA
			WHEN OBJETIVA_REFINANCIADO <> '' '' AND OBJETIVA_REFINANCIADO IS NOT NULL THEN OBJETIVA_REFINANCIADO
			ELSE CATEGORIAOBJETIVA END AS CALIFICACION_RESULTANTE,
			CATEGORIA_COMERCIAL, 0, 0, SITUACION_JUDICIAL, Sit_MorExEnt, DISCREPANCIA,
			CASE WHEN CATEGORIASUBJETIVA <> '' '' AND CATEGORIASUBJETIVA IS NOT NULL THEN 1 
			WHEN Sit_MorExEnt <> '' '' AND Sit_MorExEnt IS NOT NULL THEN 2 
			WHEN SITUACION_JUDICIAL <> '' '' AND SITUACION_JUDICIAL IS NOT NULL THEN 3
			WHEN DISCREPANCIA <> '' '' AND DISCREPANCIA IS NOT NULL THEN 4
			WHEN OBJETIVA_REFINANCIADO <> '' '' AND OBJETIVA_REFINANCIADO IS NOT NULL THEN 5
			ELSE 6 END AS TIPO_CALIFICACION
			FROM CLI_CLIENTES WITH (NOLOCK) WHERE NIVEL_APERTURA = 3 AND TZ_LOCK = 0	
			
			UPDATE hist
			SET hist.FECHA_SITUACION = b.FECHA_SITUACION
			FROM HISTORICO_CALIF_X_CLIENTE hist WITH (NOLOCK)
			INNER JOIN (
				SELECT CASE WHEN a.CALIFICACION_RESULTANTE IS NULL THEN (SELECT FECHAPROCESO FROM PARAMETROS WITH (NOLOCK))
				WHEN a.CALIFICACION_RESULTANTE <> h.CALIFICACION_RESULTANTE THEN (SELECT FECHAPROCESO FROM PARAMETROS WITH (NOLOCK))
				ELSE a.FECHA_SITUACION END AS FECHA_SITUACION, h.CLIENTE, h.FECHA
				FROM HISTORICO_CALIF_X_CLIENTE h WITH (NOLOCK)
				LEFT JOIN (SELECT CLIENTE, CALIFICACION_RESULTANTE, FECHA_SITUACION,
							ROW_NUMBER() OVER(PARTITION BY CLIENTE ORDER BY FECHA DESC) AS CANTIDAD
							FROM HISTORICO_CALIF_X_CLIENTE WITH (NOLOCK)
							WHERE FECHA <> (SELECT FECHAPROCESO FROM PARAMETROS WITH (NOLOCK))) a ON a.CLIENTE = h.CLIENTE AND a.CANTIDAD = 1
				WHERE h.FECHA = (SELECT FECHAPROCESO FROM PARAMETROS WITH (NOLOCK)) AND h.TZ_LOCK = 0) b 
			ON hist.CLIENTE = b.CLIENTE AND hist.FECHA = b.FECHA			
				
		END
		  
		    SET @p_msg_proceso = ''El Proceso de Actualización de Situacion Resultante ha finalizado correctamente. Registros procesados: ''+ CONVERT(VARCHAR(10), @contador)
			SET @p_ret_proceso = 1 		
			
			-- Logueo de información
			EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso 
				@p_id_proceso,
		    	@p_dt_proceso,
		    	''SP_ACTUALIZA_SITUACION_RESULTANTE'',
		    	@p_cod_error = @p_ret_proceso, 
				@p_msg_error = @p_msg_proceso, 
				@p_tipo_error = @c_log_tipo_informacion
		END TRY
							             
		BEGIN CATCH
	
	        SET @p_ret_proceso = ERROR_NUMBER()
	        SET @p_msg_proceso = ''Ocurrió un error en el Proceso de Actualización de Situacion Resultante: '' + ERROR_MESSAGE()
	
			EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso 
	        	@p_id_proceso = @p_id_proceso, 
	        	@p_fch_proceso = @p_dt_proceso, 
	        	@p_nom_package = ''SP_ACTUALIZA_SITUACION_RESULTANTE'', 
	        	@p_cod_error = @p_ret_proceso, 
	        	@p_msg_error = @p_msg_proceso, 
	       		@p_tipo_error = @c_log_tipo_informacion
		END CATCH
END

')

EXECUTE('
IF OBJECT_ID (''SP_LIMPIA_SITUACION_JUDICIAL'') IS NOT NULL
	DROP PROCEDURE SP_LIMPIA_SITUACION_JUDICIAL
')

EXECUTE('
CREATE PROCEDURE [dbo].[SP_LIMPIA_SITUACION_JUDICIAL]
	@p_id_proceso FLOAT(53),     /* Identificador de proceso */
	@p_dt_proceso DATETIME,   /* Fecha de proceso */
	@p_ret_proceso FLOAT OUT, /* Estado de ejecucion SQL(0:Correcto, 2: Error) */
	@p_msg_proceso VARCHAR(MAX) OUT
AS
BEGIN
	DECLARE 
	------- Campos para el LOG --------
	@c_log_tipo_error varchar(30),
	@c_log_tipo_informacion VARCHAR(30),
	-----------------------------------	
	@contador NUMERIC(10)
	SET @contador = 0;
	------- Campos para el LOG --------
	SET @c_log_tipo_error = ''E'';
	SET @c_log_tipo_informacion = ''I'';
	-----------------------------------	

	BEGIN TRY
        	  
		SET @contador =	(SELECT count(1) FROM CLI_CLIENTES WITH (NOLOCK) WHERE SITUACION_JUDICIAL IN (''4'',''5''))				
		
		IF @contador > 0
		BEGIN
			UPDATE CLI_CLIENTES SET SITUACION_JUDICIAL = '' '' WHERE SITUACION_JUDICIAL IN (''4'',''5'');
		END
		  
		    SET @p_msg_proceso = ''El Proceso de Limpieza de Situacion Judicial ha finalizado correctamente. Registros procesados: ''+ CONVERT(VARCHAR(10), @contador)
			SET @p_ret_proceso = 1 		
			
			-- Logueo de información
			EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso 
				@p_id_proceso,
		    	@p_dt_proceso,
		    	''SP_LIMPIA_SITUACION_JUDICIAL'',
		    	@p_cod_error = @p_ret_proceso, 
				@p_msg_error = @p_msg_proceso, 
				@p_tipo_error = @c_log_tipo_informacion
		END TRY
							             
		BEGIN CATCH
	
	        SET @p_ret_proceso = ERROR_NUMBER()
	        SET @p_msg_proceso = ''Ocurrió un error en el Proceso de Limpieza de Situacion Judicial: '' + ERROR_MESSAGE()
	
			EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso 
	        	@p_id_proceso = @p_id_proceso, 
	        	@p_fch_proceso = @p_dt_proceso, 
	        	@p_nom_package = ''SP_LIMPIA_SITUACION_JUDICIAL'', 
	        	@p_cod_error = @p_ret_proceso, 
	        	@p_msg_error = @p_msg_proceso, 
	       		@p_tipo_error = @c_log_tipo_informacion
		END CATCH
END
')

EXECUTE('
IF OBJECT_ID (''SP_ACTUALIZA_SITUACION_JUDICIAL'') IS NOT NULL
	DROP PROCEDURE SP_ACTUALIZA_SITUACION_JUDICIAL
')

EXECUTE('
CREATE PROCEDURE [dbo].[SP_ACTUALIZA_SITUACION_JUDICIAL]
	@p_id_proceso FLOAT(53),     /* Identificador de proceso */
	@p_dt_proceso DATETIME,   /* Fecha de proceso */
	@p_ret_proceso FLOAT OUT, /* Estado de ejecucion SQL(0:Correcto, 2: Error) */
	@p_msg_proceso VARCHAR(MAX) OUT
AS
BEGIN
	DECLARE 
	------- Campos para el LOG --------
	@c_log_tipo_error varchar(30),
	@c_log_tipo_informacion VARCHAR(30),
	-----------------------------------	
	@contador NUMERIC(10)
	SET @contador = 0;
	------- Campos para el LOG --------
	SET @c_log_tipo_error = ''E'';
	SET @c_log_tipo_informacion = ''I'';
	-----------------------------------	

	BEGIN TRY
        	  
		SET @contador =	(SELECT count(1)
			FROM VW_CLI_X_DOC c WITH (NOLOCK)
			INNER JOIN CLI_ClientePersona cp WITH (NOLOCK) ON c.CODIGOCLIENTE = cp.CODIGOCLIENTE AND cp.TITULARIDAD = ''T'' AND cp.TZ_LOCK = 0
			INNER JOIN (SELECT pf.NUMEROPERSONAFISICA AS PERSONA FROM CLI_PERSONASFISICAS pf WITH (NOLOCK) WHERE pf.CONC_ACREEDORES = ''S'' AND pf.TZ_LOCK = 0
			UNION
			SELECT pj.NUMEROPERSONAJURIDICA AS PERSONA FROM CLI_PERSONASJURIDICAS pj WITH (NOLOCK) WHERE pj.CONC_ACREEDORES = ''S'' AND pj.TZ_LOCK = 0) p 
			ON cp.NUMEROPERSONA = p.PERSONA 
			INNER JOIN CLI_CONCURSO_ACREEDORES ca WITH (NOLOCK) ON c.TIPODOC = ca.TIPODOCUMENTO AND c.NUMERODOC = ca.CUIT_CUIL AND ca.CONC_ACREEDORES = ''S'' AND ca.TZ_LOCK = 0 AND
			ca.FECHA_INGRESO <= (SELECT FECHAPROCESO FROM PARAMETROS WITH (NOLOCK)) AND ((CA.FECHA_FIN IS NOT NULL AND ca.FECHA_FIN >= (SELECT FECHAPROCESO FROM PARAMETROS WITH (NOLOCK))) OR ca.FECHA_FIN IS NULL))				
		
		IF @contador > 0
		BEGIN
			UPDATE c
			SET c.SITUACION_JUDICIAL = a.CALIF
			FROM CLI_CLIENTES c WITH (NOLOCK)
			INNER JOIN (SELECT CASE WHEN datediff(DAY,ca.FECHA_INGRESO,(SELECT FECHAPROCESO FROM PARAMETROS WITH (NOLOCK))) > (SELECT DIASINMOVILIZADA FROM CRE_PARAMETROS WITH (NOLOCK) WHERE CODIGO = 166) THEN ''5'' ELSE ''4'' END AS CALIF, c.CODIGOCLIENTE
			FROM VW_CLI_X_DOC c WITH (NOLOCK)
			INNER JOIN CLI_ClientePersona cp WITH (NOLOCK) ON c.CODIGOCLIENTE = cp.CODIGOCLIENTE AND cp.TITULARIDAD = ''T'' AND cp.TZ_LOCK = 0
			INNER JOIN (SELECT pf.NUMEROPERSONAFISICA AS PERSONA FROM CLI_PERSONASFISICAS pf WITH (NOLOCK) WHERE pf.CONC_ACREEDORES = ''S'' AND pf.TZ_LOCK = 0
			UNION
			SELECT pj.NUMEROPERSONAJURIDICA AS PERSONA FROM CLI_PERSONASJURIDICAS pj WITH (NOLOCK) WHERE pj.CONC_ACREEDORES = ''S'' AND pj.TZ_LOCK = 0) p 
			ON cp.NUMEROPERSONA = p.PERSONA 
			INNER JOIN CLI_CONCURSO_ACREEDORES ca WITH (NOLOCK) ON c.TIPODOC = ca.TIPODOCUMENTO AND c.NUMERODOC = ca.CUIT_CUIL AND ca.CONC_ACREEDORES = ''S'' AND ca.TZ_LOCK = 0 AND
			ca.FECHA_INGRESO <= (SELECT FECHAPROCESO FROM PARAMETROS WITH (NOLOCK)) AND ((CA.FECHA_FIN IS NOT NULL AND ca.FECHA_FIN >= (SELECT FECHAPROCESO FROM PARAMETROS WITH (NOLOCK))) OR ca.FECHA_FIN IS NULL)) a
			ON a.CODIGOCLIENTE = c.CODIGOCLIENTE
			WHERE c.TZ_LOCK = 0		END
		  
		    SET @p_msg_proceso = ''El Proceso de Actualización de Situacion Judicial ha finalizado correctamente. Registros procesados: ''+ CONVERT(VARCHAR(10), @contador)
			SET @p_ret_proceso = 1 		
			
			-- Logueo de información
			EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso 
				@p_id_proceso,
		    	@p_dt_proceso,
		    	''SP_ACTUALIZA_SITUACION_JUDICIAL'',
		    	@p_cod_error = @p_ret_proceso, 
				@p_msg_error = @p_msg_proceso, 
				@p_tipo_error = @c_log_tipo_informacion
		END TRY
							             
		BEGIN CATCH
	
	        SET @p_ret_proceso = ERROR_NUMBER()
	        SET @p_msg_proceso = ''Ocurrió un error en el Proceso de Actualización de Situacion Judicial: '' + ERROR_MESSAGE()
	
			EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso 
	        	@p_id_proceso = @p_id_proceso, 
	        	@p_fch_proceso = @p_dt_proceso, 
	        	@p_nom_package = ''SP_ACTUALIZA_SITUACION_JUDICIAL'', 
	        	@p_cod_error = @p_ret_proceso, 
	        	@p_msg_error = @p_msg_proceso, 
	       		@p_tipo_error = @c_log_tipo_informacion
		END CATCH
END
')

