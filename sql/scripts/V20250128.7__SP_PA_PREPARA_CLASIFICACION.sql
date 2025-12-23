EXECUTE('
ALTER PROCEDURE SP_PA_PREPARA_CLASIFICACION
   @P_ID_PROCESO float(53),
   @P_DT_PROCESO datetime2(0),
   @P_RET_PROCESO float(53)  OUTPUT,
   @P_MSG_PROCESO varchar(max)  OUTPUT
AS
BEGIN
      SET @P_RET_PROCESO = NULL
      SET @P_MSG_PROCESO = NULL 
      
      -- Si cliente presenta certificado el dia de proceso, obtenemos ultima categoria del cliente previo al inicio de la emergencia
      -- Actualizar CLI_CLIENTES.CATEGORIARESULTANTE
      -- Insertar regitro en HISTORICO_CALIF_X_CLIENTE
                
      
      BEGIN
      -- Refinanciaciones realizadas en el dia, deben cargar la OBJETIVA_REFINANCIADA del cliente si la misma esta vacia (SIN CLASIFICACION)      
      UPDATE CLI_CLIENTES
      SET OBJETIVA_REFINANCIADO = CATEGORIARESULTANTE
      WHERE CODIGOCLIENTE IN (
      				SELECT DISTINCT C1803 
      				FROM SALDOS WITH (NOLOCK)
      				WHERE C1785=5 AND C8748=''S'' AND C1604<>0 AND TZ_LOCK=0 
      				AND C1621 = (SELECT FECHAPROCESO FROM PARAMETROS WITH (NOLOCK))
      				)
      AND  OBJETIVA_REFINANCIADO = '' '';				
      END 
      
      
      BEGIN 
      -- Clientes que ya no van a ingresar al proceso de Calificacion Objetiva por deuda NO Refinanciada
	   UPDATE CLI 
       SET CATEGORIAOBJETIVA = '' ''
       FROM CLI_CLIENTES CLI
       WHERE NOT EXISTS (SELECT 1
									FROM SALDOS S WITH (NOLOCK)
									INNER JOIN PLANCTAS P WITH (NOLOCK) ON S.C1730 = P.C6326
									INNER JOIN PRODUCTOS R WITH (NOLOCK) ON S.PRODUCTO=R.C6250
									WHERE S.C1803=CLI.CODIGOCLIENTE AND S.TZ_LOCK=0 AND P.TZ_LOCK=0 AND R.TZ_LOCK=0 
									AND ((S.C1785 IN (2, 5, 6) AND S.C1604 < 0) OR (S.C1785=1 AND R.C6800=''T'' AND S.C1726 > 0)) 
									AND P.CALIFICA = ''S'')
		AND CATEGORIAOBJETIVA <> '' '' ;
	   END
	   				
	   
	  BEGIN 
	   -- Clientes que ya no van a ingresar al proceso de Calificacion Objetiva por deuda Refinanciada
       UPDATE CLI_CLIENTES
	   SET    OBJETIVA_REFINANCIADO = '' ''		       
	   WHERE  CODIGOCLIENTE IN (SELECT DISTINCT S.C1803
		                        FROM   HISTORICO_CALIF_X_SALDO  H WITH (NOLOCK)
		                        INNER JOIN SALDOS S WITH (NOLOCK)
		                                        ON H.JTS_PRESTAMO = S.JTS_OID 
		                         WHERE S.C1785 =5 AND S.C8748 = ''S'' AND NOT EXISTS (SELECT 1 FROM SALDOS WITH (NOLOCK) WHERE  C1803=s.C1803 
		                         	    AND C1785=5 AND C8748=''S'' AND C1604<>0 AND TZ_LOCK=0)
		                         		AND H.TZ_LOCK = 0
		                                AND S.TZ_LOCK = 0) 
	  AND  OBJETIVA_REFINANCIADO <> '' ''	;							
	  END						
	  
	  BEGIN 
	  -- Clientes que ya no tienen asistencias por ende no califican 								
	  UPDATE CLI_CLIENTES
      SET CATEGORIASUBJETIVA = '' '', DISCREPANCIA = '' '', SITUACION_JUDICIAL = '' '',Sit_MorExEnt = '' ''
      WHERE CATEGORIAOBJETIVA = '' '' AND OBJETIVA_REFINANCIADO = '' '' AND TZ_LOCK=0;							
	  END 							
								
      BEGIN
      SET @P_MSG_PROCESO = ''Se actualizó correctamente''     
           
      SET @P_RET_PROCESO = 1
      
      DECLARE @p_tipo_error varchar(80)
      SET @p_tipo_error=''se actualizó correctamente''
 
 	  EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso 
				@P_ID_PROCESO,
		    	@P_DT_PROCESO,
		    	''SP_PA_PREPARA_CLASIFICACION '',
		    	@P_RET_PROCESO,
		    	@P_MSG_PROCESO,
		    	@p_tipo_error
		    	
		    	
		END
            
END
')