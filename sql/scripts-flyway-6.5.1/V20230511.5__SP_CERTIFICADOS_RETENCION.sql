
EXECUTE('
CREATE OR ALTER PROCEDURE SP_CERTIFICADO_RETENCION
   @TIPO_CARGO_IMPOSITIVO   NUMERIC(4),
   @P_NRO_COMPROBANTE	    VARCHAR(6) OUTPUT,
   @P_TIPO_CARGO_IMPOSITIVO NUMERIC(4) OUTPUT,
   @P_COD_REGIMEN           NUMERIC(4) OUTPUT
   
AS 

   BEGIN
   
   DECLARE
      
      	@V_TIPO_CARGO_IMPOSITIVO NUMERIC(4)
   
   
   SELECT @V_TIPO_CARGO_IMPOSITIVO=E.TIPO_CARGO_IMPOSITIVO
			FROM CON_EQUIVALENCIA_CARGO_IMPOSITIVO E 
			WHERE E.TZ_LOCK=0
			    AND (    (E.CARGO_O_IMPUESTO = ''I''
			            AND E.TIPO_IMPUESTO = (    SELECT TIPO_IMPUESTO 
			                                FROM CI_IMPUESTOS AS CI WITH (nolock)
			                                WHERE 
			                                    CI.TZ_LOCK = 0
			                                    AND CI.ID_IMPUESTO = @TIPO_CARGO_IMPOSITIVO
			                                    AND FECHADESDE = (    SELECT MAX(FECHADESDE) 
			                                                        FROM CI_IMPUESTOS 
			                                                        WHERE ID_IMPUESTO = @TIPO_CARGO_IMPOSITIVO
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
			                                    AND CC.ID_CARGO = @TIPO_CARGO_IMPOSITIVO
			                            )
			
			       )
			    )
			   
    
   
      SELECT @P_NRO_COMPROBANTE = MAX(RIGHT(cr.NRO_CERTIFICADO,6))+1
		FROM CON_CERTIFICADOS_RETENCION CR
	   WHERE CR.TIPO_CARGO_IMPOSITIVO = @V_TIPO_CARGO_IMPOSITIVO
		 AND cr.TZ_LOCK = 0       
	  
      SET @P_TIPO_CARGO_IMPOSITIVO=@V_TIPO_CARGO_IMPOSITIVO
      
      SELECT @P_COD_REGIMEN=RCR.CODIGO_REGIMEN
		FROM CON_REGIMEN_CERTIF_RET RCR 
		WHERE  RCR.TIPO_CARGO_IMPOSITIVO=@V_TIPO_CARGO_IMPOSITIVO
		                                AND RCR.VIGENCIA_DESDE = (    SELECT MAX(VIGENCIA_DESDE) 
		                                                        FROM CON_REGIMEN_CERTIF_RET 
		                                                        WHERE TIPO_CARGO_IMPOSITIVO = RCR.TIPO_CARGO_IMPOSITIVO
		                                                            AND TZ_LOCK = 0
		                                                            AND VIGENCIA_DESDE <= (SELECT FECHAPROCESO FROM PARAMETROS) ) 
		      
   END
')
