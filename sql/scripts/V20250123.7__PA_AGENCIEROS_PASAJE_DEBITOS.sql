EXECUTE('

CREATE OR ALTER PROCEDURE PA_AGENCIEROS_PASAJE_DEBITOS
   @P_ID_PROCESO  float(53),
   @P_DT_PROCESO  datetime2(0),
   @P_RET_PROCESO float(53)  OUTPUT,
   @P_MSG_PROCESO varchar(max)  OUTPUT
   
AS 

   BEGIN

      SET @P_RET_PROCESO = NULL
      SET @P_MSG_PROCESO = NULL
      
      DECLARE

         @ID NUMERIC(15),
         @JTS_OID NUMERIC(10),
         @TRANS_DEBITO NUMERIC(10),
         @SUCURSAL NUMERIC(5),
         @IMPORTE NUMERIC(15,2),
         @SIGNO NUMERIC(1),
         @CANT	NUMERIC(10),
         @FECHA DATE,
         @v_constante VARCHAR(1),
         @v_numerador NUMERIC,
         @IdConv_DB NUMERIC(15),
         @IdConv_CR NUMERIC(15)
      
      SET @CANT = 0
      SELECT @FECHA= FECHAPROCESO FROM PARAMETROS
      SELECT @IdConv_DB= NUMERICO FROM PARAMETROSGENERALES WHERE CODIGO = 301 AND TZ_LOCK = 0
      SELECT @TRANS_DEBITO= CTA_TRANSITORIA FROM CONV_CONVENIOS_REC WHERE Id_ConvRec=@IdConv_DB AND Estado = ''A'' AND TZ_LOCK = 0;
      
      ------------------------------------------------------------
      
      DECLARE @RegistrosAgencieros TABLE(
		ID INT,
		JTS_OID NUMERIC(10),
		IMPORTE_LIQUIDO NUMERIC(15,2),
		SIG_IMP_LIQUIDO NUMERIC(1),
		SUCURSAL NUMERIC(5) );
		
	INSERT INTO @RegistrosAgencieros 
		SELECT ID,JTS_OID,IMPORTE_LIQUIDO,SIG_IMP_LIQUIDO,SUCURSAL FROM REC_Agencieros  
           WHERE ESTADO = ''V'' AND CAJA_DEBITO = ''D'' AND SIG_IMP_LIQUIDO = 2;
	
      ---------------------------------
      BEGIN TRANSACTION
      
      BEGIN TRY
 
      BEGIN
      
     		 
     			INSERT INTO GRL_ACREDITACIONES_MASIVAS (TIPO_CTA_DEB, CTA_DEB, SUC_DEB, ESTADO, FCHA_PROCESAR, TIPO_CTA_CRED, CTA_CRED, SUC_CRE, IMPORTE, MON_IMPORTE, APL_EVEN_CRE_DEB, TZ_LOCK, REFERENCIA_EXTERNA,TIPO_ACREDITACION
     			                                        ,EVENTO, EVEN_PAG_COB, CANAL,CODIGO_TRANSACCION)--SE agrega NBCHSEG-4189 
				(SELECT
				''V'' AS TIPO_CTA_DEB, 
				JTS_OID AS CTA_DEB, 
				SUCURSAL, 
				''I'' AS ESTADO, 
				@FECHA, 
				''V'' AS TIPO_CTA_CRED, 
				@TRANS_DEBITO AS CTA_CRED,
				SUCURSAL AS SUC_CRE, 
				IMPORTE_LIQUIDO, 
				1 AS MON_IMPORTE, 
				''D'' AS APL_EVEN_CRE_DEB,--SE cambia a S NBCHSEG-4189  
				0 AS TZ_LOCK, 
				ID AS REFERENCIA_EXTERNA, 
				''AGEN'' AS TIPO_ACREDITACION,
				854 AS EVENTO,--SE agrega NBCHSEG-4189 
				''C'' AS EVEN_PAG_COB, --SE agrega NBCHSEG-4189 
				''LOTE'' AS CANAL, -- NBCHSEG-5598
				503
				 FROM @RegistrosAgencieros)
				
			SET @CANT = @@ROWCOUNT
			
			UPDATE REC_Agencieros
			SET ESTADO = ''R'', DETALLE_ESTADO = ''En Proceso''
			FROM REC_Agencieros A JOIN @RegistrosAgencieros R ON A.ID = R.ID
			WHERE A.TZ_LOCK = 0
      	                  
             
      END
      	
      SET @P_RET_PROCESO = 1
	  SET @P_MSG_PROCESO = ''Pasaje Débitos Funcionó correctamente. Se pasaron ''+ ISNULL(CAST(@CANT AS nvarchar(max)), '''') + '' registros.''
	  
	  EXECUTE dbo.pkg_constantes$VarcharConstantes ''C_LOG_TIPO_INFORMACION'', @v_constante OUTPUT;
	  
	  EXECUTE dbo.PKG_LOG_PROCESO$PROC_INS_LOG_PROCESO 
	       @P_ID_PROCESO = @P_ID_PROCESO, 
	       @P_FCH_PROCESO = @P_DT_PROCESO, 
	       @P_NOM_PACKAGE = ''PA_AGENCIEROS_PASAJE'', 
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
               @p_nom_package = ''PA_AGENCIEROS_PASAJE'', 
               @p_cod_error = @p_ret_proceso, 
               @p_msg_error = @p_msg_proceso, 
               @p_tipo_error = @v_constante

         END

      END CATCH

   END

')
