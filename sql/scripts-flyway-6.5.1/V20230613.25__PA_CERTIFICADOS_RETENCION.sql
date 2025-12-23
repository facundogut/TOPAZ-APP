
EXECUTE('
CREATE OR ALTER PROCEDURE PA_CERTIFICADOS_RETENCION
   @P_ID_PROCESO 			FLOAT(53),
   @P_DT_PROCESO			DATETIME2(0),
   @P_CLAVE                 varchar(max),
   @P_SUCURSAL              float(53),
   @P_NROMAQUINA            float(53),
   @P_RET_PROCESO			FLOAT(53)  OUTPUT,
   @P_MSG_PROCESO			VARCHAR(max)  OUTPUT
   
AS 

   BEGIN

      SET @P_RET_PROCESO = NULL
      SET @P_MSG_PROCESO = NULL
      
      DECLARE
      
      	@v_constante VARCHAR(1), --ESTA VARIABLE SE DEVUELVE COMO TIPO DE ERROR EN EL CATCH. 
      						 --SE SUPONE QUE NOSOTROS LA MODIFIQUEMOS? VER USO EN OTROS SP
      
        @CANT NUMERIC(15)
      --DECLARE Y SET DE VARIABLES
      
      ------------------------------------------------------------
      
      --BÚSQUEDA DE DATOS Y USO DE TABLAS TEMPORALES     
      		
      		--si no se ingresa cliente (parámetro = -1), hacer búsqueda un barrido de todos los movimientos que puedan generar certificados
      		--estos son los registros de CI_FACTURA_LINEA para cargos o impuestos con tipo 3 IVA Retención 4 IGA y 12 IIBB CABA Retención
      		--para el cargo o impuesto, buscar el tipo de impuesto, relacionar con la tabla CON_EQUIVALENCIA_CARGO_IMPOSITIVO para saber qué valor guardar
      		--relacionar con la tabla CON_REGIMEN_CERTIF_RET para saber regimen a guardar
      		--según el tipo de cargo impositivo, sucursal y anteriores certificados, calcular el siguiente número de certificado a utilizar.
      		--copiar los datos necesarios de ci_factura_linea, o los parámetros de entrada.
      		--devolver el número de certificado en caso de que sea a operación para que se pueda buscar, imprimir y modificar registro para agregar una copia.
      		--si no se puede, ya dar de alta con estado impreso y 1 copia, si el llamado viene de la operación.
      		
      ---------------------------------
      

      BEGIN
        
        SET @CANT =NULL
     
        SELECT @CANT= count(*)
						FROM MOVIMIENTOS_CONTABLES AS M WITH (nolock)
						JOIN ASIENTOS A ON 
						    A.ASIENTO = M.ASIENTO 
						    AND A.FECHAPROCESO = M.FECHAPROCESO 
						    AND A.SUCURSAL = M.SUCURSAL 
						    AND A.ESTADO = 77
						    
						JOIN CI_FACTURA_LINEA R ON R.ASIENTO = M.ASIENTO
						                        AND R.SUCURSAL_ASIENTO = M.SUCURSAL
						                        AND R.FECHA_PROCESO_ASIENTO = M.FECHAPROCESO
						                        AND R.ORDINAL_MOVIMIENTO =M.ORDINAL
						                        AND R.TR_REAL = M.TRREAL
						                        AND R.TZ_LOCK = 0
						JOIN CON_EQUIVALENCIA_CARGO_IMPOSITIVO E ON 
						    E.TZ_LOCK=0
						    AND (    (E.CARGO_O_IMPUESTO = ''I''
						            AND E.TIPO_IMPUESTO = (    SELECT TIPO_IMPUESTO 
						                                FROM CI_IMPUESTOS AS CI WITH (nolock)
						                                WHERE 
						                                    CI.TZ_LOCK = 0
						                                    AND CI.ID_IMPUESTO = R.ID_IMPUESTO
						                                    AND FECHADESDE = (    SELECT MAX(FECHADESDE) 
						                                                        FROM CI_IMPUESTOS 
						                                                        WHERE ID_IMPUESTO = CI.ID_IMPUESTO
						                                                            AND TZ_LOCK = 0
						                                                            AND FECHADESDE <= (SELECT FECHAPROCESO FROM PARAMETROS)
						                                                    )
						                            )
						        ) 
						        OR     (E.CARGO_O_IMPUESTO = ''C''
						            AND E.TIPO_IMPUESTO = (    SELECT TIPO_CARGO_IMPOSITIVO 
						                                FROM CI_CARGOS AS CC WITH (nolock)
						                                WHERE 
						                                    CC.TZ_LOCK = 0
						                                    AND CC.ID_CARGO = R.ID_CARGO
						                            )
						
						       )
						    )
						
						JOIN CON_REGIMEN_CERTIF_RET RCR ON RCR.TIPO_CARGO_IMPOSITIVO=E.TIPO_CARGO_IMPOSITIVO
						                                AND RCR.VIGENCIA_DESDE = (    SELECT MAX(VIGENCIA_DESDE) 
						                                                        FROM CON_REGIMEN_CERTIF_RET 
						                                                        WHERE TIPO_CARGO_IMPOSITIVO = RCR.TIPO_CARGO_IMPOSITIVO
						                                                            AND TZ_LOCK = 0
						                                                            AND VIGENCIA_DESDE <= (SELECT FECHAPROCESO FROM PARAMETROS) ) 
						 
						WHERE
						    M.MONEDA IN (SELECT C6399 FROM MONEDAS WHERE C6403 = ''N'' AND TZ_LOCK = 0)
						    AND M.OPERACION<>9999
						    
						    AND NOT EXISTS (SELECT * 
						                    FROM CON_CERTIFICADOS_RETENCION AS M2
						                    WHERE
						                        M2.ASIENTO = M.ASIENTO
						                        AND M2.FECHA_ASIENTO= M.FECHAPROCESO
						                        AND M2.SUCURSAL_ASIENTO = M.SUCURSAL
						                        AND (M2.ID_CARGO = R.ID_CARGO
						                          OR M2.ID_CARGO = R.ID_IMPUESTO)
						                        AND M2.TZ_LOCK = 0
						 
						                  )

      END 
      
      BEGIN TRANSACTION

      BEGIN TRY

      BEGIN
      
        
      
       INSERT INTO CON_CERTIFICADOS_RETENCION  
        SELECT
						    0 AS TZ_LOCK,
						    cast(CONCAT(M.SUCURSAL,year(M.FECHAPROCESO),
						                                (SELECT  MAX(RIGHT(cr.NRO_CERTIFICADO,6))
														   FROM CON_CERTIFICADOS_RETENCION CR
														  WHERE CR.TIPO_CARGO_IMPOSITIVO = e.TIPO_CARGO_IMPOSITIVO
						        							AND cr.TZ_LOCK = 0))AS NUMERIC(15)) +
						                             
						                          
						    ROW_NUMBER () OVER (PARTITION BY E.tipo_cargo_impositivo ORDER BY E.tipo_cargo_impositivo) AS NRO_CERTIFICADO , 
						                           
						    E.TIPO_CARGO_IMPOSITIVO,
						    M.CLIENTE,
						    M.FECHACONTABLE,
						    RCR.CODIGO_REGIMEN, 
						    
						    CASE WHEN (SELECT TOP 1 C1785 FROM SALDOS WHERE JTS_OID = m.JTS_OID AND TZ_LOCK = 0)=3 THEN (SELECT TOP 1 CUENTA FROM SALDOS WHERE JTS_OID = m.JTS_OID AND TZ_LOCK = 0)
						         ELSE (SELECT TOP 1 certificado_dpf FROM PZO_SALDOS WHERE JTS_OID = m.JTS_OID AND TZ_LOCK = 0)
						         END AS NRO_COMPROBANTE,
						
						    
						    (SELECT sum(capitalrealizado) FROM MOVIMIENTOS_CONTABLES
								WHERE ASIENTO =M.ASIENTO
								 AND SUCURSAL = M.SUCURSAL
								 AND FECHAPROCESO = M.FECHAPROCESO
								 AND DEBITOCREDITO = ''D'') AS MONTO_COMPROBANTE,
						    R.MONTO_IMPONIBLE,
						    R.IMPORTEMN,
						    CASE WHEN R.IMPORTEMN/R.MONTO_IMPONIBLE>0.05 THEN 10 ELSE 3 END AS ALICUOTA,
						    (SELECT sum(capitalrealizado) FROM MOVIMIENTOS_CONTABLES
								WHERE ASIENTO =M.ASIENTO
								 AND SUCURSAL = M.SUCURSAL
								 AND FECHAPROCESO = M.FECHAPROCESO
								 AND DEBITOCREDITO = ''D'') - ( R.MONTO_IMPONIBLE + R.IMPORTEMN)as OTROS_CONCEPTOS,
						    ''AA'' AS ESTADO,
						    0 AS IMPRESIONES,
						    M.ASIENTO,
						    M.SUCURSAL,
						    M.FECHAPROCESO, 
						    M.OPERACION,
						    R.ID_CARGO
						FROM MOVIMIENTOS_CONTABLES AS M WITH (nolock)
						JOIN ASIENTOS A ON 
						    A.ASIENTO = M.ASIENTO 
						    AND A.FECHAPROCESO = M.FECHAPROCESO 
						    AND A.SUCURSAL = M.SUCURSAL 
						    AND A.ESTADO = 77
						    
						JOIN CI_FACTURA_LINEA R ON R.ASIENTO = M.ASIENTO
						                        AND R.SUCURSAL_ASIENTO = M.SUCURSAL
						                        AND R.FECHA_PROCESO_ASIENTO = M.FECHAPROCESO
						                        AND R.ORDINAL_MOVIMIENTO =M.ORDINAL
						                        AND R.TR_REAL = M.TRREAL
						                        AND R.TZ_LOCK = 0
						JOIN CON_EQUIVALENCIA_CARGO_IMPOSITIVO E ON 
						    E.TZ_LOCK=0
						    AND (    (E.CARGO_O_IMPUESTO = ''I''
						            AND E.TIPO_IMPUESTO = (    SELECT TIPO_IMPUESTO 
						                                FROM CI_IMPUESTOS AS CI WITH (nolock)
						                                WHERE 
						                                    CI.TZ_LOCK = 0
						                                    AND CI.ID_IMPUESTO = R.ID_IMPUESTO
						                                    AND FECHADESDE = (    SELECT MAX(FECHADESDE) 
						                                                        FROM CI_IMPUESTOS 
						                                                        WHERE ID_IMPUESTO = CI.ID_IMPUESTO
						                                                            AND TZ_LOCK = 0
						                                                            AND FECHADESDE <= (SELECT FECHAPROCESO FROM PARAMETROS)
						                                                    )
						                            )
						        ) 
						        OR     (E.CARGO_O_IMPUESTO = ''C''
						            AND E.TIPO_IMPUESTO = (    SELECT TIPO_CARGO_IMPOSITIVO 
						                                FROM CI_CARGOS AS CC WITH (nolock)
						                                WHERE 
						                                    CC.TZ_LOCK = 0
						                                    AND CC.ID_CARGO = R.ID_CARGO
						                            )
						
						       )
						    )
						
						JOIN CON_REGIMEN_CERTIF_RET RCR ON RCR.TIPO_CARGO_IMPOSITIVO=E.TIPO_CARGO_IMPOSITIVO
						                                AND RCR.VIGENCIA_DESDE = (    SELECT MAX(VIGENCIA_DESDE) 
						                                                        FROM CON_REGIMEN_CERTIF_RET 
						                                                        WHERE TIPO_CARGO_IMPOSITIVO = RCR.TIPO_CARGO_IMPOSITIVO
						                                                            AND TZ_LOCK = 0
						                                                            AND VIGENCIA_DESDE <= (SELECT FECHAPROCESO FROM PARAMETROS) ) 
						 
						WHERE
						    M.MONEDA IN (SELECT C6399 FROM MONEDAS WHERE C6403 = ''N'' AND TZ_LOCK = 0)
						    AND M.OPERACION<>9999
						    
						    AND NOT EXISTS (SELECT * 
						                    FROM CON_CERTIFICADOS_RETENCION AS M2
						                    WHERE
						                        M2.ASIENTO = M.ASIENTO
						                        AND M2.FECHA_ASIENTO= M.FECHAPROCESO
						                        AND M2.SUCURSAL_ASIENTO = M.SUCURSAL
						                        AND (M2.ID_CARGO = R.ID_CARGO
						                          OR M2.ID_CARGO = R.ID_IMPUESTO)
						                        AND M2.TZ_LOCK = 0
						 
						                  )
        
      END
      
      SET @P_RET_PROCESO = 1
	  SET @P_MSG_PROCESO = ''Certificados de Retención funcionó correctamente. Se pasaron ''+ ISNULL(CAST(@CANT AS nvarchar(max)), '''') + '' registros.''
	  
	  EXECUTE dbo.pkg_constantes$VarcharConstantes ''C_LOG_TIPO_INFORMACION'', @v_constante OUTPUT;
	  
	  EXECUTE dbo.PKG_LOG_PROCESO$PROC_INS_LOG_PROCESO 
	       @P_ID_PROCESO = @P_ID_PROCESO, 
	       @P_FCH_PROCESO = @P_DT_PROCESO, 
	       @P_NOM_PACKAGE = ''PA_CERTIFICADOS_RETENCION'', 
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
               @p_nom_package = ''PA_CERTIFICADOS_RETENCION'', 
               @p_cod_error = @p_ret_proceso, 
               @p_msg_error = @p_msg_proceso, 
               @p_tipo_error = @v_constante

         END

      END CATCH

   END

')