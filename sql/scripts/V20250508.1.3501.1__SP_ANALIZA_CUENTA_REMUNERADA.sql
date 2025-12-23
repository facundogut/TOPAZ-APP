EXECUTE ('
CREATE OR ALTER   PROCEDURE SP_ANALIZA_CUENTA_REMUNERADA
   @P_ID_PROCESO  float(53),
   @P_DT_PROCESO  datetime2(0),
   @P_CLAVE       varchar(max),
   @P_SUCURSAL    float(53),
   @P_NROMAQUINA  float(53),
   @P_RET_PROCESO float(53)  OUTPUT,
   @P_MSG_PROCESO varchar(max)  OUTPUT
   
AS 

   BEGIN

      
      
      DECLARE
      @COUNT NUMERIC(15,0),
      @v_constante VARCHAR(1)
      SET @P_RET_PROCESO = NULL
      SET @P_MSG_PROCESO = NULL
      
      
      --DECLARO TABLA AUXILIAR--
	  DECLARE @TablaAuxiliar TABLE(
			SALDOS_JTS_OID NUMERIC	(15,0)
		)
      
      
      INSERT INTO 
			@TablaAuxiliar
            SELECT s.jts_oid
			  FROM SALDOS S WITH (NOLOCK)  
			 INNER JOIN VTA_DEFINICION_VISTA V WITH (NOLOCK) ON S.c1772= V.grupo 
			                                                AND S.producto = V.producto 
			                                                AND S.moneda=V.moneda
			                                                AND V.modalidadpago=''P''
			                                                AND V.TZ_LOCK=0
			 
			 INNER JOIN VTA_RANGOS_TASAS R WITH (NOLOCK) ON  R.codigorango=V.codigorangopago
			  							  		     	AND R.diferencialtasabase>0
			  							  		     	AND R.TZ_LOCK =0
			   AND R.TASA_COBRAR_PAGAR =''P''
			 
			   WHERE  s.TZ_LOCK = 0
			   AND s.C1728 <> ''I'' 
			   AND s.C1651 <> ''1'' 
			   AND S.C1785 IN (2,3) 
			   AND (S.C1604=0 OR  S.C4684=0)
	   
      
      BEGIN TRANSACTION
      
      BEGIN TRY
      
      
 
      BEGIN
      
              	  
      	  UPDATE SALDOS 
      	     SET C3977 = '' ''
      	   WHERE C3977 != '' ''
      	   
      	   
      	  UPDATE R 
     		 SET R.C3977 = ''S''
     	    FROM SALDOS AS R
     	   INNER JOIN @TablaAuxiliar AS T ON R.JTS_OID = T.SALDOS_JTS_OID
     	   
     	  
      	      	
      END
      
      
      	
      SET @P_RET_PROCESO = 1
	  SET @P_MSG_PROCESO = ''Actualización de cuentas remuneradas Funcionó correctamente. Cantidad de registros: ''+ ISNULL(CAST((SELECT COUNT(1) FROM @TablaAuxiliar) AS NVARCHAR(max)), '''') 
	  
	  EXECUTE dbo.pkg_constantes$VarcharConstantes ''C_LOG_TIPO_INFORMACION'', @v_constante OUTPUT;
	  
	  EXECUTE dbo.PKG_LOG_PROCESO$PROC_INS_LOG_PROCESO 
	       @P_ID_PROCESO = @P_ID_PROCESO, 
	       @P_FCH_PROCESO = @P_DT_PROCESO, 
	       @P_NOM_PACKAGE = ''SP_ANALIZA_CUENTA_REMUNERADA'', 
	       @P_COD_ERROR = @P_RET_PROCESO, 
	       @P_MSG_ERROR = @P_MSG_PROCESO, 
	       @P_TIPO_ERROR = @v_constante
	  
	  COMMIT TRANSACTION;     
         
      END TRY
      
      BEGIN CATCH

         
         BEGIN
         
         	ROLLBACK TRANSACTION

           --Valores de Retorno.
            SET @p_ret_proceso = ERROR_NUMBER()

            SET @p_msg_proceso = ERROR_MESSAGE()
            
            EXECUTE dbo.pkg_constantes$VarcharConstantes ''C_LOG_TIPO_ERROR'', @v_constante OUTPUT;

            EXECUTE dbo.PKG_LOG_PROCESO$proc_ins_log_proceso 
               @p_id_proceso = @p_id_proceso, 
               @p_fch_proceso = @p_dt_proceso, 
               @p_nom_package = ''SP_ANALIZA_CUENTA_REMUNERADA'', 
               @p_cod_error = @p_ret_proceso, 
               @p_msg_error = @p_msg_proceso, 
               @p_tipo_error = @v_constante

         END

      END CATCH
      
      
      
   END
')