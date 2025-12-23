EXECUTE('
CREATE OR ALTER PROCEDURE PA_CANALES_ESTADO_CONV_PADRONES
   @P_ID_PROCESO  float(53) = NULL,
   @P_DT_PROCESO  datetime2(0) = NULL,
   @P_RET_PROCESO float(53)  OUTPUT,
   @P_MSG_PROCESO varchar(max)  OUTPUT
   
AS 

BEGIN

 SET @P_RET_PROCESO = NULL
 SET @P_MSG_PROCESO = NULL
 
 DECLARE  @v_constante VARCHAR(1)
 
 DECLARE @TablaAux TABLE(
		ID                       NUMERIC(15),
		ID_LINEA				 NUMERIC(15),
		NRO_COMPROBANTE_CLIENTE  NUMERIC(12),
		LETRA					 VARCHAR(1),
		PUNTO_VENTA				 VARCHAR(4),
		TOTAL_CARGO_ESPECIFICO   NUMERIC(15,2)
	)

 
   
	 BEGIN TRANSACTION
      
      BEGIN TRY
	   BEGIN 
		
		INSERT INTO @TablaAux
	   SELECT DISTINCT L.ID_CABEZAL, RD.ID_LINEA, VW.NRO_COMPROBANTE_CLIENTE, VW.LETRA,
	                   VW.PUNTO_VENTA,VW.TOTAL_CARGO_ESPECIFICO
		  FROM REC_RENDICION R 
		  INNER JOIN REC_LIQUIDACION L ON L.ID_LIQUIDACION = r.ID_LIQUIDACION
		                               AND L.TZ_LOCK =0
		  INNER JOIN REC_DET_RECAUDOS_CANAL RD ON RD.ID_CABEZAL = l.ID_CABEZAL
		                                       AND RD.TZ_LOCK =0 
		  INNER JOIN ASIENTOS A ON A.ASIENTO = R.ASIENTO_RENDICION
		                       AND A.FECHAPROCESO = R.FECHA
		                       AND A.SUCURSAL = R.SUCURSAL_RENDICION
		                       AND A.ESTADO = 42
		                       AND A.OPERACION =2651
		  INNER JOIN VW_CANAL_REND_CARGO_ESPECIFICO VW ON VW.ID_CABEZAL = l.ID_CABEZAL
		                                         AND VW.ID_CABEZAL = RD.ID_CABEZAL
		                                         AND VW.ID_LINEA = Rd.ID_LINEA
		                                         AND VW.ESTADO = ''C''
		WHERE (R.TZ_LOCK >300000000000000
		  AND  R.TZ_LOCK <400000000000000);
		
	END
	
    
		UPDATE REC_DET_RECAUDOS_CANAL
		SET
			TOTAL_CARGO_ESPECIFICO = 0
		FROM REC_DET_RECAUDOS_CANAL A
		JOIN @TablaAux C ON
			A.ID_CABEZAL=c.ID
			AND a.ID_LINEA = c.ID_LINEA
		WHERE TZ_LOCK = 0
		
		UPDATE CONV_PADRONES
		SET
			ESTADO = ''P'',
			REF_TOPAZ = 0
		FROM CONV_PADRONES A
		JOIN @TablaAux C ON
			A.NRO_COMPROBANTE_CLIENTE = c.NRO_COMPROBANTE_CLIENTE
			AND A.LETRA = c.LETRA
			AND A.PUNTO_VENTA = c.PUNTO_VENTA
		WHERE TZ_LOCK = 0
		
		
		SET @P_RET_PROCESO = 1
	    SET @P_MSG_PROCESO = ''Reversa Cargos especificos de canales''
	  
	  EXECUTE dbo.pkg_constantes$VarcharConstantes ''C_LOG_TIPO_INFORMACION'', @v_constante OUTPUT;
	  
	  EXECUTE dbo.PKG_LOG_PROCESO$PROC_INS_LOG_PROCESO 
	       @P_ID_PROCESO = @P_ID_PROCESO, 
	       @P_FCH_PROCESO = @P_DT_PROCESO, 
	       @P_NOM_PACKAGE = ''PA_CANALES_ESTADO_CONV_PADRONES'', 
	       @P_COD_ERROR = @P_RET_PROCESO, 
	       @P_MSG_ERROR = @P_MSG_PROCESO, 
	       @P_TIPO_ERROR = @v_constante
		
	  COMMIT TRANSACTION;     
         
      END TRY	
	 	
	   BEGIN CATCH

         
         BEGIN
         
         	ROLLBACK TRANSACTION

            /* Valores de Retorno.*/
            SET @p_ret_proceso = ERROR_NUMBER()

            SET @p_msg_proceso = ERROR_MESSAGE()
            
            EXECUTE dbo.pkg_constantes$VarcharConstantes ''C_LOG_TIPO_ERROR'', @v_constante OUTPUT;

            EXECUTE dbo.PKG_LOG_PROCESO$proc_ins_log_proceso 
               @p_id_proceso = @p_id_proceso, 
               @p_fch_proceso = @p_dt_proceso, 
               @p_nom_package = ''PA_CANALES_ESTADO_CONV_PADRONES'', 
               @p_cod_error = @p_ret_proceso, 
               @p_msg_error = @p_msg_proceso, 
               @p_tipo_error = @v_constante

         END

      END CATCH
      
 END
')
