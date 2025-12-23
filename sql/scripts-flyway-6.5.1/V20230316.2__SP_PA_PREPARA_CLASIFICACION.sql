EXECUTE('
DROP PROCEDURE SP_PA_RESETEA_CLASIFICACION;
')

EXECUTE('
CREATE PROCEDURE SP_PA_PREPARA_CLASIFICACION
   @P_ID_PROCESO float(53),
   @P_DT_PROCESO datetime2(0),
   @P_RET_PROCESO float(53)  OUTPUT,
   @P_MSG_PROCESO varchar(max)  OUTPUT
AS
BEGIN
      SET @P_RET_PROCESO = NULL
      SET @P_MSG_PROCESO = NULL            
      
      BEGIN
      -- Refinanciaciones realizadas en el dia, deben cargar la OBJETIVA_REFINANCIADA del cliente si la misma esta vacia (SIN CLASIFICACION)      
      UPDATE CLI_CLIENTES
      SET OBJETIVA_REFINANCIADO = CATEGORIARESULTANTE
      WHERE CODIGOCLIENTE IN (
      				SELECT DISTINCT C1803 
      				FROM SALDOS 
      				WHERE C1785=5 AND C8748=''S'' AND C1604<>0 AND TZ_LOCK=0 
      				AND C1621 = (SELECT FECHAPROCESO FROM PARAMETROS)
      				)
      AND  OBJETIVA_REFINANCIADO = '' '';				
      END 
      
      BEGIN 
      -- Clientes que ya no van a ingresar al proceso de Calificacion Objetiva por deuda NO Refinanciada
	   UPDATE CLI_CLIENTES  
       SET CATEGORIAOBJETIVA = '' ''
       WHERE CODIGOCLIENTE IN  (SELECT DISTINCT S.C1803
								 FROM            HISTORICO_CALIF_X_SALDO  H
								 INNER JOIN      SALDOS S
								 ON              H.JTS_PRESTAMO=S.JTS_OID 
								 WHERE NOT EXISTS (SELECT 1
									FROM SALDOS S1 
									INNER JOIN PLANCTAS P ON S1.C1730 = P.C6326
									INNER JOIN CLI_CLIENTES C ON C.CODIGOCLIENTE=S.C1803
									INNER JOIN PRODUCTOS R ON S.PRODUCTO=R.C6250
									WHERE S1.C1803=S.C1803 AND S1.TZ_LOCK=0 AND P.TZ_LOCK=0 AND R.TZ_LOCK=0 AND C.TZ_LOCK=0
									AND ((S1.C1785 IN (2, 5, 6) AND S1.C1604 < 0) OR (S1.C1785=1 AND R.C6800=''T'' AND S1.C1726 > 0)) 
									AND P.CALIFICA = ''S'' AND S1.C8748 <> ''S'')
								)
		AND CATEGORIAOBJETIVA <> '' '' ;  
	   END 						
	   
	   BEGIN 
	   -- Clientes que ya no van a ingresar al proceso de Calificacion Objetiva por deuda Refinanciada
       UPDATE CLI_CLIENTES
	   SET    OBJETIVA_REFINANCIADO = '' ''		       
	   WHERE  CODIGOCLIENTE IN (SELECT DISTINCT S.C1803
		                        FROM   HISTORICO_CALIF_X_SALDO  H
		                        INNER JOIN SALDOS S
		                                        ON H.JTS_PRESTAMO = S.JTS_OID 
		                         WHERE S.C1785 =5 AND S.C8748 = ''S'' AND NOT EXISTS (SELECT 1 FROM SALDOS WHERE  C1803=s.C1803 
		                         	    AND C1785=5 AND C8748=''S'' AND C1604<>0 AND TZ_LOCK=0)
		                         		AND H.TZ_LOCK = 0
		                                AND S.TZ_LOCK = 0) 
	  AND  OBJETIVA_REFINANCIADO <> '' ''	;							
	  END 						
	  
	  BEGIN 
	  -- Clientes que ya no tienen asistencias por ende no califican 								
	  UPDATE CLI_CLIENTES  
      SET CATEGORIASUBJETIVA = '' ''
      WHERE CATEGORIAOBJETIVA = '' '' AND OBJETIVA_REFINANCIADO = '' ''	AND TZ_LOCK=0;							
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

