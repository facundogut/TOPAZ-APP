EXECUTE('
CREATE PROCEDURE SP_PA_RESETEA_CLASIFICACION
   @P_ID_PROCESO float(53),
   @P_DT_PROCESO datetime2(0),
   @P_RET_PROCESO float(53)  OUTPUT,
   @P_MSG_PROCESO varchar(max)  OUTPUT
AS
BEGIN
      SET @P_RET_PROCESO = NULL
      SET @P_MSG_PROCESO = NULL
      
      -- CLIENTES QUE SE EVALUAN NUEVAMENTE EN LOS PROCESOS DE CATEGORIZACION Y QUE TUVIERON ASISTENCIAS
       UPDATE CLI_CLIENTES
	   SET    CATEGORIAOBJETIVA = '' '',
		       OBJETIVA_REFINANCIADO = '' ''
	   WHERE  CODIGOCLIENTE IN (SELECT DISTINCT S.C1803
		                         FROM   HISTORICO_CALIF_X_SALDO  H
		                                INNER JOIN SALDOS S
		                                        ON H.JTS_PRESTAMO = S.JTS_OID 
		                         WHERE H.TZ_LOCK = 0
		                                AND S.TZ_LOCK = 0) 
      
      -- CLIENTES QUE TUVIERON ASISTENCIAS, HOY NO TIENEN Y TIENEN CATEGORIASUBJETIVA CARGADA
	   UPDATE CLI_CLIENTES  
       SET CATEGORIASUBJETIVA ='' '' 
       WHERE CODIGOCLIENTE IN  (
						 SELECT DISTINCT S.C1803
						 FROM            HISTORICO_CALIF_X_SALDO  H
						 INNER JOIN      SALDOS S
						 ON              H.JTS_PRESTAMO=S.JTS_OID -- AND 
						 INNER JOIN      PRODUCTOS R 
						 ON S.PRODUCTO=R.C6250
						 WHERE           H.TZ_LOCK=0
						 AND             S.TZ_LOCK=0
						 AND ((S.C1785 IN (5, 6) AND S.C1604 = 0) OR  (S.C1785 IN (2) AND S.C1604+S.C1683 >= 0)
											 OR (S.C1785=1 AND R.C6800=''T'' AND C1726 = 0 )) 
						)
			AND CATEGORIASUBJETIVA <> '' '' 	
      BEGIN
      SET @P_MSG_PROCESO = ''Se actualizó correctamente''     
           
      SET @P_RET_PROCESO = 1
      
      DECLARE @p_tipo_error varchar(80)
      SET @p_tipo_error=''se actualizó correctamente''
 
 EXECUTE PKG_LOG_PROCESO$proc_ins_log_proceso 
				@P_ID_PROCESO,
		    	@P_DT_PROCESO,
		    	''SP_PA_RESETEA_CLASIFICACION'',
		    	@P_RET_PROCESO,
		    	@P_MSG_PROCESO,
		    	@p_tipo_error
		    	
		    	
		END
            
      END
')

