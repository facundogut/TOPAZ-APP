EXECUTE('
CREATE OR ALTER PROCEDURE SP_ESTADO_CONV_PADRONES
   @P_ID                    NUMERIC(15),
   @P_CONVENIO	            NUMERIC(15),
   @P_ESTADO                VARCHAR(1),
   @P_OPCION				VARCHAR(1),	
   @P_ASIENTO				NUMERIC(7),
   @P_IMPORTE				NUMERIC(15,2),
   @P_RESULTADO             VARCHAR(5) OUTPUT
   
AS 

   BEGIN
   
     SET @P_RESULTADO = ''ERROR''
     
     
          
     DECLARE @TablaAux TABLE(
			ID                       NUMERIC(15),
    		ID_LINEA				 NUMERIC(15),
    		CODIGO_BARRAS			 VARCHAR(120),
    		NRO_COMPROBANTE_CLIENTE  NUMERIC(12),
    		LETRA					 VARCHAR(1),
    		PUNTO_VENTA				 VARCHAR(4),
    		TOTAL_CARGO_ESPECIFICO   NUMERIC(15,2)
		)
	 BEGIN 	
	  INSERT INTO @TablaAux
	  SELECT DISTINCT
		    c.ID,
		    d.ID_LINEA,
		    d.CODIGO_BARRAS,
		    cc2.NRO_COMPROBANTE_CLIENTE,
		    cc2.LETRA,
		    cc2.PUNTO_VENTA,
		    cc2.TOTAL_CARGO_ESPECIFICO 
		FROM REC_CAB_RECAUDOS_CANAL AS c WITH (NOLOCK)
		INNER JOIN REC_DET_RECAUDOS_CANAL AS d WITH (NOLOCK)
		    ON c.ID = d.ID_CABEZAL
		    AND d.TZ_LOCK = 0
		INNER JOIN CONV_PADRONES AS cc2 WITH (NOLOCK)
		    ON cc2.CONVENIO = c.CONVENIO
		    AND cc2.TZ_LOCK = 0
		    AND cc2.TOTAL_CARGO_ESPECIFICO != 0
		    AND cc2.TOTAL_CARGO_ESPECIFICO IS NOT NULL
		    AND (cc2.NRO_COMPROBANTE_CLIENTE = SUBSTRING(d.CODIGO_BARRAS, 11, 8)
		        AND cc2.TIPO_COMPROBANTE = SUBSTRING(d.CODIGO_BARRAS, 4, 2)
		        AND cc2.LETRA = CASE WHEN SUBSTRING(d.CODIGO_BARRAS, 6, 1) = 0 THEN ''B'' ELSE ''A'' END
		        AND cc2.PUNTO_VENTA = SUBSTRING(d.CODIGO_BARRAS, 7, 4))
		    
		WHERE c.TZ_LOCK = 0
		  AND c.CONVENIO =  (SELECT r.Id_ConvRec FROM CONV_CONVENIOS_REC r
								WHERE R.Id_TpoConv = 18
								AND R.TZ_LOCK = 0
								AND R.Estado = ''A'');	
      END 
    
      IF @P_ESTADO = ''I'' AND @P_OPCION = ''R''
        BEGIN 
	      UPDATE REC_CAB_RECAUDOS_CANAL
	         SET ESTADO = ''R'',
	             TOTAL_CARGO_ESPECIFICO = @P_IMPORTE
	       WHERE ID = @P_ID; 
	       
	      UPDATE REC_DET_RECAUDOS_CANAL
	         SET ESTADO = ''R'',
	             DETALLE_ESTADO = ''Rendido''
	       WHERE ID_CABEZAL = @P_ID
	         
	      
	      UPDATE REC_DET_RECAUDOS_CANAL 
	         SET ESTADO = ''R'',
	             DETALLE_ESTADO = ''Rendido'',
	             TOTAL_CARGO_ESPECIFICO = c.TOTAL_CARGO_ESPECIFICO 
	        FROM REC_DET_RECAUDOS_CANAL A JOIN @TablaAux C
		 	  ON A.ID_CABEZAL=c.ID AND a.ID_LINEA = c.ID_LINEA
		   WHERE TZ_LOCK = 0
		  
		  UPDATE CONV_PADRONES
		     SET ESTADO = ''C'',
		         REF_TOPAZ = @P_ASIENTO
		    FROM CONV_PADRONES A JOIN @TablaAux C
		 	  ON A.NRO_COMPROBANTE_CLIENTE = c.NRO_COMPROBANTE_CLIENTE
		 	 AND A.LETRA = c.LETRA
		 	 AND A.PUNTO_VENTA = c.PUNTO_VENTA
		   WHERE TZ_LOCK = 0   
	           
	      	       
	      SET @P_RESULTADO = ''OK''
      
    END
    
   
      IF @P_ESTADO = ''I'' AND @P_OPCION = ''A''
        BEGIN 
	       UPDATE REC_CAB_RECAUDOS_CANAL
	         SET ESTADO = ''A'',
	             TOTAL_CARGO_ESPECIFICO = @P_IMPORTE
	       WHERE ID = @P_ID 
	      
	      UPDATE REC_DET_RECAUDOS_CANAL
	         SET ESTADO = ''A'',
	             DETALLE_ESTADO = ''Anulado''
	       WHERE ID_CABEZAL = @P_ID 
	      
	      SET @P_RESULTADO = ''OK''
      
        END
    
     
      IF @P_ESTADO = ''A'' AND @P_OPCION = ''P''
       BEGIN  
         UPDATE REC_CAB_RECAUDOS_CANAL
	         SET ESTADO = ''I'',
	             TOTAL_CARGO_ESPECIFICO = @P_IMPORTE
	       WHERE ID = @P_ID 
	       
	     	      
	     UPDATE REC_DET_RECAUDOS_CANAL
	         SET ESTADO = ''I'',
	             DETALLE_ESTADO = ''Ingresado'',
	             TOTAL_CARGO_ESPECIFICO = NULL
	       WHERE ID_CABEZAL = @P_ID
	       
	      SET @P_RESULTADO = ''OK''
	      
	      
        END
        
     
        IF @P_ESTADO = ''R'' AND @P_OPCION = ''P'' 
         BEGIN 
	       UPDATE REC_CAB_RECAUDOS_CANAL
	         SET ESTADO = ''I'',
	             TOTAL_CARGO_ESPECIFICO = @P_IMPORTE
	       WHERE ID = @P_ID
	       
	       UPDATE REC_DET_RECAUDOS_CANAL
	         SET ESTADO = ''I'',
	             DETALLE_ESTADO = ''Ingresado'',
	             TOTAL_CARGO_ESPECIFICO = NULL
	       WHERE ID_CABEZAL = @P_ID
	           
	      		  
		  UPDATE CONV_PADRONES
		     SET ESTADO = ''P'',
		         REF_TOPAZ = 0
		    FROM CONV_PADRONES A JOIN @TablaAux C
		 	  ON A.NRO_COMPROBANTE_CLIENTE = c.NRO_COMPROBANTE_CLIENTE
		 	 AND A.LETRA = c.LETRA
		 	 AND A.PUNTO_VENTA = c.PUNTO_VENTA
		   WHERE TZ_LOCK = 0;	   
	       
	      SET @P_RESULTADO = ''OK''
        END
    END
')
