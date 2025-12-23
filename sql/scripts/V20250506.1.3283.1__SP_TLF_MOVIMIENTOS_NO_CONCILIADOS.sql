EXECUTE('
CREATE OR ALTER PROCEDURE dbo.SP_TLF_MOVIMIENTOS_NO_CONCILIADOS
	@p_id_proceso FLOAT(53),     /* Identificador de proceso */
	@p_dt_proceso DATETIME,   /* Fecha de proceso */
	@p_ret_proceso FLOAT OUT, /* Estado de ejecucion SQL(0:Correcto, 2: Error) */
	@p_msg_proceso VARCHAR(MAX) OUT
AS 
BEGIN
   DECLARE 
    @contador NUMERIC (12),
	------- Campos para el LOG --------
	@c_log_tipo_error varchar(30),
	@c_log_tipo_informacion VARCHAR(30)
	------- Campos para el LOG --------
	SET @c_log_tipo_error = ''E'';
	SET @c_log_tipo_informacion = ''I'';
	-----------------------------------	
   DECLARE @SUMMARY_420 TABLE (TIPOMENSAJE VARCHAR(4), HORATRANSACCION VARCHAR(6), CODIGOPROCESAMIENTO VARCHAR(6), 
							FECHATRANSACCION VARCHAR(4),NUMEROTRANSACCION VARCHAR(12),IDENTIFICACIONCAJERO VARCHAR(16)
						   )
						   
   BEGIN TRY
   -- Obtenemos mensajes de reversa que contiene la SUMMARY
   INSERT INTO @SUMMARY_420
   SELECT s.TIPOMENSAJE, s.CODIGOPROCESAMIENTO,S.HORATRANSACCION, S.FECHATRANSACCION,S.NUMEROTRANSACCION, 
   		  s.IDENTIFICACIONCAJERO
   FROM TJD_TLF_SUMMARY s WITH (NOLOCK)
   WHERE s.TIPOMENSAJE=''420'' AND s.CODIGORESPUESTA=''00''
    	   			    
    	   			    
   -- Cantidad de registros a procesar
   SELECT @contador=COUNT(*) 
   FROM TJD_TLF_SUMMARY s
   WHERE NOT EXISTS (
				        SELECT 1
				        FROM TP_TOPAZPOSCONTROL tp WITH (NOLOCK) 
				        WHERE tp.ELEMENT0 IN (''0200'',''0220'')
				          AND tp.ELEMENT12 = s.HORATRANSACCION
				          AND tp.ELEMENT13 = s.FECHATRANSACCION
				          AND tp.ELEMENT37 = s.NUMEROTRANSACCION
				          AND tp.ELEMENT41 = s.IDENTIFICACIONCAJERO
    	   			);
	-- Actualizar campo "CONCILIACION" a ''N'' en la tabla TJD_TLF_SUMMARY
	-- para los registros que no existen en la tabla TP_TOPAZPOSCONTROL
	
	-- Movimientos que no se deben comparar contra TOPAZ porque en el TLF vienen no aprobados
	-- Es decir que tenemos un 200 y un 420 asociados que se netean entre si.
	
	-- Movimientos que existen en el TLF aprobados pero no estan en TOPAZ
	UPDATE s 
	SET s.CONCILIACION = ''N''
	FROM TJD_TLF_SUMMARY s
	WHERE s.CODIGORESPUESTA=''00'' AND s.TIPOMENSAJE IN (''200'',''220'')
					AND NOT EXISTS (
		 		        SELECT 1
		  		        FROM TP_TOPAZPOSCONTROL tp WITH (NOLOCK) 
		  		        WHERE tp.ELEMENT0 IN (''0200'',''0220'')
			  		        AND tp.ELEMENT3  = s.CODIGOPROCESAMIENTO
			        	    AND tp.ELEMENT12 = s.HORATRANSACCION
						    AND tp.ELEMENT13 = s.FECHATRANSACCION
						    AND tp.ELEMENT37 = s.NUMEROTRANSACCION
						    AND tp.ELEMENT41 = s.IDENTIFICACIONCAJERO
		    	    )
		    	    AND NOT EXISTS (
		 		        SELECT 1
		  		        FROM @SUMMARY_420 tp
		  		        WHERE tp.HORATRANSACCION = s.HORATRANSACCION
			  		        AND tp.CODIGOPROCESAMIENTO  = s.CODIGOPROCESAMIENTO
						    AND tp.FECHATRANSACCION = s.FECHATRANSACCION
						    AND tp.NUMEROTRANSACCION = s.NUMEROTRANSACCION
						    AND tp.IDENTIFICACIONCAJERO = s.IDENTIFICACIONCAJERO
		    	    );
	 -- Movimientos que existen en el TLF aprobados, estan en TOPAZ pero no aprobados
	UPDATE s 
	SET s.CONCILIACION = ''N''
	FROM TJD_TLF_SUMMARY s
	WHERE s.CODIGORESPUESTA=''00'' AND s.TIPOMENSAJE IN (''200'',''220'') 
					AND EXISTS (
		 		        SELECT 1
		  		        FROM TP_TOPAZPOSCONTROL tp WITH (NOLOCK) 
		  		        WHERE tp.ELEMENT0 IN (''0210'',''0230'')
			  		        AND tp.ELEMENT3  = s.CODIGOPROCESAMIENTO
			        	    AND tp.ELEMENT12 = s.HORATRANSACCION
						    AND tp.ELEMENT13 = s.FECHATRANSACCION
						    AND tp.ELEMENT37 = s.NUMEROTRANSACCION
						    AND tp.ELEMENT41 = s.IDENTIFICACIONCAJERO
						    AND tp.ELEMENT39 <> ''00''
		    	    )
		    	    AND NOT EXISTS (
		 		        SELECT 1
		  		        FROM @SUMMARY_420 tp 
		  		        WHERE tp.HORATRANSACCION = s.HORATRANSACCION
			  		        AND tp.CODIGOPROCESAMIENTO  = s.CODIGOPROCESAMIENTO
						    AND tp.FECHATRANSACCION = s.FECHATRANSACCION
						    AND tp.NUMEROTRANSACCION = s.NUMEROTRANSACCION
						    AND tp.IDENTIFICACIONCAJERO = s.IDENTIFICACIONCAJERO
		    	    );
		    	    
		    	    
		     	SET @P_RET_PROCESO = 1 --OK
		     	SET @P_MSG_PROCESO = ''El proceso que identifica movimientos no conciliados, ha finalizado correctamente. Transacciones NO Conciliadas: ''+ CONVERT(VARCHAR(10), @contador)
			-- Logueo de información
			EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso 
				@p_id_proceso,
		    	@p_dt_proceso,
		    	''SP_TLF_MOVIMIENTOS_NO_CONCILIADOS'',
		    	@p_cod_error = @p_ret_proceso, 
				@p_msg_error = @p_msg_proceso, 
				@p_tipo_error = @c_log_tipo_informacion

      ------------------------------------------------------------------------------------------------------------------------------------------
      -- CDS-3283: Solucion provisoria, la cual consiste en arreglar los datos inconsistentes provenientes de Banelco para su impacto manual.
      ------------------------------------------------------------------------------------------------------------------------------------------

      UPDATE s
      SET TOACCOUNT=
        CONCAT(
          substring(element126, CHARINDEX(''! Q7'', element126)+18, 2),
          ''0'',
          substring(element126, CHARINDEX(''! Q7'', element126)+13, 4),
          substring(element126, CHARINDEX(''! Q7'', element126)+20, 11)
        )
      from TJD_TLF_SUMMARY s
      inner join TP_TOPAZPOSCONTROL t 
      on FECHATRANSACCION = element13 
        and HORATRANSACCION=element12 
        and NUMEROTRANSACCION = element37
        and IDENTIFICACIONCAJERO=element41
        and SUBSTRING(TOACCOUNT, 3, 19) = element103
      where
        substring(element3, 1, 2) in (''09'', ''29'')
        and element39=''00''
        and len(trim(element103))<>16
        and (element103 <>'''' and element103<>''00000000000000000'');

      ------------------------------------------------------------------------------------------------------------------------------------------
      -- Fin CDS-3283
      ------------------------------------------------------------------------------------------------------------------------------------------  

	END TRY
	BEGIN CATCH
	
	        SET @p_ret_proceso = ERROR_NUMBER()
	        SET @p_msg_proceso = ''Ocurrió un error en el Proceso de identificacion de movimientos no conciliados: '' + ERROR_MESSAGE()
	
			EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso 
	        	@p_id_proceso = @p_id_proceso, 
	        	@p_fch_proceso = @p_dt_proceso, 
	        	@p_nom_package = ''SP_TLF_MOVIMIENTOS_NO_CONCILIADOS'', 
	        	@p_cod_error = @p_ret_proceso, 
	        	@p_msg_error = @p_msg_proceso, 
	       		@p_tipo_error = @c_log_tipo_informacion
	END CATCH   
END

')