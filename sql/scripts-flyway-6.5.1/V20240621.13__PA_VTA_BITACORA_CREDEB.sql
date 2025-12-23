EXECUTE('


CREATE OR ALTER PROCEDURE PA_VTA_BITACORA_CREDEB 
 
   @P_ID_PROCESO float(53), /* Identificador de proceso*/
   @P_DT_PROCESO DATETIME, /* Fecha de proceso*/

   @P_RET_PROCESO float(53)  OUTPUT, /* Estado de ejecucion del PL/SQL(1:Correcto, 2: Error)*/
   @P_MSG_PROCESO varchar(max)  OUTPUT
   
as 
BEGIN

	/* Proceso que inserta masivamente la RRII_BITACORA_CREDEB para cuentas vistas, en caso que no exista el registro.*/
	
      SET @P_RET_PROCESO = NULL
      SET @P_MSG_PROCESO = NULL 
      DECLARE
	    ------- Campos para el LOG --------
		@c_log_tipo_error varchar(30),
		@c_log_tipo_informacion VARCHAR(30)
		-----------------------------------
		
		------- Campos para el LOG --------
		SET @c_log_tipo_error = ''E''
		SET @c_log_tipo_informacion = ''I''
		-----------------------------------
	
      
     	-- Tabla auxiliar para cargar datos de Saldos.
      									
      DECLARE @TMPSaldosEnBitacora TABLE(
							    					  SALDO_JTS_OID FLOAT (53),
							    					  CREDEB_SEGMENTO NUMERIC (1)
											 	  )  
											 	  
	                           
    	INSERT INTO @TMPSaldosEnBitacora
	   				 
	    SELECT 
	        S.JTS_OID,
	        ISNULL(s.credeb_segmento, 0)
        
      
		    FROM 
		        SALDOS AS S with (nolock)
		    WHERE 
		        S.C1785 IN(2,3)  
		        AND NOT EXISTS (
		            SELECT * 
		            FROM RRII_BITACORA_CREDEB AS R with (nolock)
		            WHERE R.JTS_OID_SALDOS=S.JTS_OID
		            )										 	  
						 
						

BEGIN TRY
 BEGIN 
 
 
    DECLARE @P_CANTIDAD NUMERIC(15)
    SELECT @P_CANTIDAD =COUNT(*)
        FROM @TMPSaldosEnBitacora
     
   -------INSERT TABLA-------------------------
   
   INSERT INTO dbo.RRII_BITACORA_CREDEB(
		   	TZ_LOCK,
		    JTS_OID_SALDOS,
		    Fecha,
		    Segmento, 
		    Tipo_Cargo_Impositivo, 
		    PADRON_BENEF_FISCAL, 
		    Padron_mipyme

			)
			
			(SELECT
				0,
			    t.SALDO_JTS_OID,
			    (SELECT FECHAPROCESO FROM PARAMETROS with(nolock)),
			    t.CREDEB_SEGMENTO,
				6,
				''N'',
			    ''N''
				FROM @TMPSaldosEnBitacora t 
		   
				
			)
		
END 
      
   
   ------------------------------------------------------------------

	SET @P_RET_PROCESO=1
	SET @P_MSG_PROCESO=''OK, Se insertaron: ''+convert(VARCHAR(10), @P_CANTIDAD)+'' registro/s.''
  	
			-- Logueo de información
			 EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso 
			 							 @p_id_proceso,
                                         @p_dt_proceso,
                                         ''PA_VTA_BITACORA_CREDEB'',
                                         @p_cod_error = @p_ret_proceso, 
							             @p_msg_error = @p_msg_proceso, 
							             @p_tipo_error = @c_log_tipo_informacion
END TRY


BEGIN CATCH
	
        SET @p_ret_proceso = ERROR_NUMBER()
        SET @p_msg_proceso = ''Error al actualizar registros '' + ERROR_MESSAGE()
        
		 EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso 
               @p_id_proceso = @p_id_proceso, 
               @p_fch_proceso = @p_dt_proceso, 
               @p_nom_package = ''PA_VTA_BITACORA_CREDEB'', 
               @p_cod_error = @p_ret_proceso, 
               @p_msg_error = @p_msg_proceso, 
               @p_tipo_error = @c_log_tipo_informacion
               
END CATCH

END



')
