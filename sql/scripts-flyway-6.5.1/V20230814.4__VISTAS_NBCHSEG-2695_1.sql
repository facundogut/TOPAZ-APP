
EXECUTE('
IF OBJECT_ID (''dbo.VW_CALCULO_CESION_CONVENIOS_CAJA_IMP_FIJO'') IS NOT NULL
	DROP VIEW dbo.VW_CALCULO_CESION_CONVENIOS_CAJA_IMP_FIJO
')

EXECUTE('
CREATE VIEW VW_CALCULO_CESION_CONVENIOS_CAJA_IMP_FIJO
				(ID_CABEZAL,
				ID_DETALLE,
				MONEDA,
				IMPORTE_DETALLE,
				SUMA_IMPORTE_CESION,
				RESTO,
				IMPORTE_CESION_1,
				IMPORTE_CESION_2,
				IMPORTE_CESION_3,
				IMPORTE_CESION_4,
				IMPORTE_CESION_5,
				TOTAL_C1,
				TOTAL_C2,
				TOTAL_C3,
				TOTAL_C4,
				TOTAL_C5,
				RESTO_TOTAL)
AS


SELECT DISTINCT c.ID ID_CABEZAL,
       d.ID_LINEA ID_DETALLE,
       d.MONEDA,
       d.IMPORTE IMPORTE_DETALLE,
       (SELECT SUM(importe) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0)  SUMA_IMPORTE_CESION,
	  
      CASE WHEN 
	      (d.IMPORTE - (SELECT SUM(importe) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0))<0 THEN 0 
	     
	  
	  else d.IMPORTE -(SELECT SUM(importe) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0) END AS RESTO,
	  

          isnull( CASE WHEN 
		    (d.IMPORTE - (SELECT SUM(importe) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0))<0 
		      AND (SELECT importe FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0 AND CC.Prioridad = 1) IS NOT NULL
		      AND (SELECT Max(prioridad) FROM CONV_CESIONES cc WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0) in (1)
		    THEN 
		       CASE WHEN 
		         (SELECT importe FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0 AND CC.Prioridad = 1)+
		             (d.IMPORTE-(SELECT SUM(importe) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0))<=0
		         THEN 0
		     ELSE 
		          
		          CASE WHEN
		             (SELECT SUM(importe) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0 
		             AND CC.Prioridad IN (1))>d.IMPORTE 
		             
		            THEN 
		             d.IMPORTE
		           else 
		          
		          (SELECT importe FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0 AND CC.Prioridad = 1)+
		             (d.IMPORTE-(SELECT SUM(importe) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0))
		           END
		         END        
		             
		    ELSE
		    
		          CASE WHEN   
		               d.IMPORTE-(SELECT SUM(importe) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0 
		              AND CC.Prioridad IN (1))<0
		              
		          THEN d.IMPORTE
		        ELSE    
		    
		          CASE WHEN
		             (SELECT SUM(importe) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0 
		             AND CC.Prioridad IN (1))>d.IMPORTE
		            THEN 
		              d.IMPORTE-(SELECT SUM(importe) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0 
		              AND CC.Prioridad IN (1))
		              
		            ELSE
		              (SELECT importe FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0 AND CC.Prioridad = 1)
		            END
		        END    
		         		            
		    END,0) AS IMPORTE_CESION_1,
		  
         
          
         isnull( CASE WHEN 
		    (d.IMPORTE - (SELECT SUM(importe) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0))<0 
		      AND (SELECT importe FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0 AND CC.Prioridad = 2) IS NOT NULL
		      AND (SELECT Max(prioridad) FROM CONV_CESIONES cc WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0) in (2)
		    THEN 
		         CASE WHEN 
		          (SELECT importe FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0 AND CC.Prioridad = 2)+
		             (d.IMPORTE-(SELECT SUM(importe) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0))<=0
		         THEN 0
		     ELSE 
		          
		          CASE WHEN
		             (SELECT SUM(importe) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0 
		             AND CC.Prioridad IN (1,2))>d.IMPORTE
		            THEN 
		              d.IMPORTE-(SELECT SUM(importe) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0 
		              AND CC.Prioridad IN (1))
		           else 
		          
		          (SELECT importe FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0 AND CC.Prioridad = 2)+
		             (d.IMPORTE-(SELECT SUM(importe) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0))
		           END
		         END        
		             
		    ELSE
		     CASE WHEN   
		               d.IMPORTE-(SELECT SUM(importe) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0 
		              AND CC.Prioridad IN (1))<0
		          THEN 0
		        ELSE    
		    
		          CASE WHEN
		             (SELECT SUM(importe) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0 
		             AND CC.Prioridad IN (1,2))>d.IMPORTE
		            THEN 
		              d.IMPORTE-(SELECT SUM(importe) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0 
		              AND CC.Prioridad IN (1))
		              
		            ELSE
		              (SELECT importe FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0 AND CC.Prioridad = 2)
		            END
		        END    
		         		            
		    END,0) AS IMPORTE_CESION_2,
		    
		   
		   isnull(CASE WHEN 
		    (d.IMPORTE - (SELECT SUM(importe) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0))<0 
		      AND (SELECT importe FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0 AND CC.Prioridad = 3) IS NOT NULL
		      AND (SELECT Max(prioridad) FROM CONV_CESIONES cc WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0) in (3)
		    THEN 
		         CASE WHEN 
		          (SELECT importe FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0 AND CC.Prioridad = 3)+
		             (d.IMPORTE-(SELECT SUM(importe) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0))<=0
		         THEN 0
		     ELSE 
		          
		          CASE WHEN
		             (SELECT SUM(importe) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0 
		             AND CC.Prioridad IN (1,2,3))>d.IMPORTE
		            THEN 
		              d.IMPORTE-(SELECT SUM(importe) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0 
		              AND CC.Prioridad IN (1,2))
		           else 
		          
		          (SELECT importe FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0 AND CC.Prioridad = 3)+
		             (d.IMPORTE-(SELECT SUM(importe) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0))
		           END
		         END        
		             
		    ELSE
		       CASE WHEN   
		               d.IMPORTE-(SELECT SUM(importe) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0 
		              AND CC.Prioridad IN (1,2))<0
		          THEN 0
		        ELSE    
		    
		          CASE WHEN
		             (SELECT SUM(importe) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0 
		             AND CC.Prioridad IN (1,2,3))>d.IMPORTE
		            THEN 
		              d.IMPORTE-(SELECT SUM(importe) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0 
		              AND CC.Prioridad IN (1,2))
		              
		            ELSE
		              (SELECT importe FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0 AND CC.Prioridad = 3)
		            END
		        END    
		         		            
		    END,0) AS IMPORTE_CESION_3,
		    
		    
		    
		     isnull(CASE WHEN 
		    (d.IMPORTE - (SELECT SUM(importe) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0))<0 
		      AND (SELECT importe FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0 AND CC.Prioridad = 4) IS NOT NULL
		      AND (SELECT Max(prioridad) FROM CONV_CESIONES cc WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0) in (4)
		    THEN 
		         CASE WHEN 
		          (SELECT importe FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0 AND CC.Prioridad = 4)+
		             (d.IMPORTE-(SELECT SUM(importe) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0))<=0
		         THEN 0
		     ELSE 
		          
		          CASE WHEN
		             (SELECT SUM(importe) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0 
		             AND CC.Prioridad IN (1,2,3,4))>d.IMPORTE
		            THEN 
		              d.IMPORTE-(SELECT SUM(importe) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0 
		              AND CC.Prioridad IN (1,2,3))
		           else 
		          
		          (SELECT importe FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0 AND CC.Prioridad = 4)+
		             (d.IMPORTE-(SELECT SUM(importe) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0))
		           END
		         END        
		             
		    ELSE
		       CASE WHEN   
		               d.IMPORTE-(SELECT SUM(importe) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0 
		              AND CC.Prioridad IN (1,2,3))<0
		          THEN 0
		        ELSE    
		    
		          CASE WHEN
		             (SELECT SUM(importe) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0 
		             AND CC.Prioridad IN (1,2,3,4))>d.IMPORTE
		            THEN 
		              d.IMPORTE-(SELECT SUM(importe) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0 
		              AND CC.Prioridad IN (1,2,3))
		              
		            ELSE
		              (SELECT importe FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0 AND CC.Prioridad = 4)
		            END
		        END    
		         		            
		    END,0) AS IMPORTE_CESION_4,
		    
		    
		    isnull( CASE WHEN 
		    (d.IMPORTE - (SELECT SUM(importe) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0))<0 
		      AND (SELECT importe FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0 AND CC.Prioridad = 5) IS NOT NULL
		      AND (SELECT Max(prioridad) FROM CONV_CESIONES cc WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0) in (5)
		    THEN 
		         CASE WHEN 
		          (SELECT importe FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0 AND CC.Prioridad = 5)+
		             (d.IMPORTE-(SELECT SUM(importe) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0))<=0
		         THEN 0
		     ELSE 
		          
		          CASE WHEN
		             (SELECT SUM(importe) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0 
		             AND CC.Prioridad IN (1,2,3,4,5))>d.IMPORTE
		            THEN 
		              d.IMPORTE-(SELECT SUM(importe) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0 
		              AND CC.Prioridad IN (1,2,3,4))
		           else 
		          
		          (SELECT importe FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0 AND CC.Prioridad = 5)+
		             (d.IMPORTE-(SELECT SUM(importe) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0))
		           END
		         END        
		             
		    ELSE
		       CASE WHEN   
		               d.IMPORTE-(SELECT SUM(importe) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0 
		              AND CC.Prioridad IN (1,2,3,4))<0
		          THEN 0
		        ELSE    
		    
		          CASE WHEN
		             (SELECT SUM(importe) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0 
		             AND CC.Prioridad IN (1,2,3,4,5))>d.IMPORTE
		            THEN 
		              d.IMPORTE-(SELECT SUM(importe) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0 
		              AND CC.Prioridad IN (1,2,3,4))
		              
		            ELSE
		              (SELECT importe FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0 AND CC.Prioridad = 5)
		            END
		        END    
		         		            
		    END,0) AS IMPORTE_CESION_5,
		    ------------------
		    
			(SELECT SUM(O.[TOTAL_CESION_1]) AS TOTAL_C1
			FROM(
			SELECT 
			isnull( CASE WHEN 
		    (d.IMPORTE - (SELECT SUM(importe) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0))<0 
		      AND (SELECT importe FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0 AND CC.Prioridad = 1) IS NOT NULL
		      AND (SELECT Max(prioridad) FROM CONV_CESIONES cc WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0) in (1)
		    THEN 
		       CASE WHEN 
		         (SELECT importe FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0 AND CC.Prioridad = 1)+
		             (d.IMPORTE-(SELECT SUM(importe) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0))<=0
		         THEN 0
		     ELSE 
		          
		          CASE WHEN
		             (SELECT SUM(importe) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0 
		             AND CC.Prioridad IN (1))>d.IMPORTE 
		             
		            THEN 
		             d.IMPORTE
		           else 
		          
		          (SELECT importe FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0 AND CC.Prioridad = 1)+
		             (d.IMPORTE-(SELECT SUM(importe) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0))
		           END
		         END        
		             
		    ELSE
		    
		          CASE WHEN   
		               d.IMPORTE-(SELECT SUM(importe) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0 
		              AND CC.Prioridad IN (1))<0
		              
		          THEN d.IMPORTE
		        ELSE    
		    
		          CASE WHEN
		             (SELECT SUM(importe) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0 
		             AND CC.Prioridad IN (1))>d.IMPORTE
		            THEN 
		              d.IMPORTE-(SELECT SUM(importe) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0 
		              AND CC.Prioridad IN (1))
		              
		            ELSE
		              (SELECT importe FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0 AND CC.Prioridad = 1)
		            END
		        END    
		         		            
		    END,0) TOTAL_CESION_1
			FROM REC_DET_RECAUDOS_CAJA d
			WHERE d.ID_CABEZAL = c.ID) AS O)AS TOTAL_C1,
		    ----------------------
		    
		    (SELECT SUM(O.[TOTAL_CESION_2]) AS TOTAL_C2
FROM(
SELECT
isnull( CASE WHEN 
		    (d.IMPORTE - (SELECT SUM(importe) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0))<0 
		      AND (SELECT importe FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0 AND CC.Prioridad = 2) IS NOT NULL
		      AND (SELECT Max(prioridad) FROM CONV_CESIONES cc WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0) in (2)
		    THEN 
		         CASE WHEN 
		          (SELECT importe FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0 AND CC.Prioridad = 2)+
		             (d.IMPORTE-(SELECT SUM(importe) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0))<=0
		         THEN 0
		     ELSE 
		          
		          CASE WHEN
		             (SELECT SUM(importe) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0 
		             AND CC.Prioridad IN (1,2))>d.IMPORTE
		            THEN 
		              d.IMPORTE-(SELECT SUM(importe) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0 
		              AND CC.Prioridad IN (1))
		           else 
		          
		          (SELECT importe FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0 AND CC.Prioridad = 2)+
		             (d.IMPORTE-(SELECT SUM(importe) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0))
		           END
		         END        
		             
		    ELSE
		     CASE WHEN   
		               d.IMPORTE-(SELECT SUM(importe) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0 
		              AND CC.Prioridad IN (1))<0
		          THEN 0
		        ELSE    
		    
		          CASE WHEN
		             (SELECT SUM(importe) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0 
		             AND CC.Prioridad IN (1,2))>d.IMPORTE
		            THEN 
		              d.IMPORTE-(SELECT SUM(importe) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0 
		              AND CC.Prioridad IN (1))
		              
		            ELSE
		              (SELECT importe FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0 AND CC.Prioridad = 2)
		            END
		        END    
		         		            
		    END,0) TOTAL_CESION_2
	FROM REC_DET_RECAUDOS_CAJA d
	WHERE d.ID_CABEZAL = c.ID) AS O)AS TOTAL_C2,
	
	-------------------------------
	(SELECT SUM(O.[TOTAL_CESION_3]) AS TOTAL_C3
FROM(
SELECT
isnull(CASE WHEN 
		    (d.IMPORTE - (SELECT SUM(importe) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0))<0 
		      AND (SELECT importe FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0 AND CC.Prioridad = 3) IS NOT NULL
		      AND (SELECT Max(prioridad) FROM CONV_CESIONES cc WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0) in (3)
		    THEN 
		         CASE WHEN 
		          (SELECT importe FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0 AND CC.Prioridad = 3)+
		             (d.IMPORTE-(SELECT SUM(importe) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0))<=0
		         THEN 0
		     ELSE 
		          
		          CASE WHEN
		             (SELECT SUM(importe) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0 
		             AND CC.Prioridad IN (1,2,3))>d.IMPORTE
		            THEN 
		              d.IMPORTE-(SELECT SUM(importe) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0 
		              AND CC.Prioridad IN (1,2))
		           else 
		          
		          (SELECT importe FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0 AND CC.Prioridad = 3)+
		             (d.IMPORTE-(SELECT SUM(importe) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0))
		           END
		         END        
		             
		    ELSE
		       CASE WHEN   
		               d.IMPORTE-(SELECT SUM(importe) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0 
		              AND CC.Prioridad IN (1,2))<0
		          THEN 0
		        ELSE    
		    
		          CASE WHEN
		             (SELECT SUM(importe) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0 
		             AND CC.Prioridad IN (1,2,3))>d.IMPORTE
		            THEN 
		              d.IMPORTE-(SELECT SUM(importe) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0 
		              AND CC.Prioridad IN (1,2))
		              
		            ELSE
		              (SELECT importe FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0 AND CC.Prioridad = 3)
		            END
		        END    
		         		            
		    END,0) TOTAL_CESION_3
	FROM REC_DET_RECAUDOS_CAJA d
	WHERE d.ID_CABEZAL = c.ID) AS O)AS TOTAL_C3,
		    
   ---------------------------------------
   (SELECT SUM(O.[TOTAL_CESION_4]) AS TOTAL_C4
FROM(
SELECT
isnull(CASE WHEN 
		    (d.IMPORTE - (SELECT SUM(importe) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0))<0 
		      AND (SELECT importe FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0 AND CC.Prioridad = 4) IS NOT NULL
		      AND (SELECT Max(prioridad) FROM CONV_CESIONES cc WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0) in (4)
		    THEN 
		         CASE WHEN 
		          (SELECT importe FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0 AND CC.Prioridad = 4)+
		             (d.IMPORTE-(SELECT SUM(importe) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0))<=0
		         THEN 0
		     ELSE 
		          
		          CASE WHEN
		             (SELECT SUM(importe) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0 
		             AND CC.Prioridad IN (1,2,3,4))>d.IMPORTE
		            THEN 
		              d.IMPORTE-(SELECT SUM(importe) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0 
		              AND CC.Prioridad IN (1,2,3))
		           else 
		          
		          (SELECT importe FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0 AND CC.Prioridad = 4)+
		             (d.IMPORTE-(SELECT SUM(importe) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0))
		           END
		         END        
		             
		    ELSE
		       CASE WHEN   
		               d.IMPORTE-(SELECT SUM(importe) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0 
		              AND CC.Prioridad IN (1,2,3))<0
		          THEN 0
		        ELSE    
		    
		          CASE WHEN
		             (SELECT SUM(importe) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0 
		             AND CC.Prioridad IN (1,2,3,4))>d.IMPORTE
		            THEN 
		              d.IMPORTE-(SELECT SUM(importe) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0 
		              AND CC.Prioridad IN (1,2,3))
		              
		            ELSE
		              (SELECT importe FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0 AND CC.Prioridad = 4)
		            END
		        END    
		         		            
		    END,0) TOTAL_CESION_4
	FROM REC_DET_RECAUDOS_CAJA d
	WHERE d.ID_CABEZAL = c.ID) AS O)AS TOTAL_C4,
	
	--------------------------------
	(SELECT SUM(O.[TOTAL_CESION_5]) AS TOTAL_C5
FROM(
SELECT
isnull( CASE WHEN 
		    (d.IMPORTE - (SELECT SUM(importe) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0))<0 
		      AND (SELECT importe FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0 AND CC.Prioridad = 5) IS NOT NULL
		      AND (SELECT Max(prioridad) FROM CONV_CESIONES cc WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0) in (5)
		    THEN 
		         CASE WHEN 
		          (SELECT importe FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0 AND CC.Prioridad = 5)+
		             (d.IMPORTE-(SELECT SUM(importe) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0))<=0
		         THEN 0
		     ELSE 
		          
		          CASE WHEN
		             (SELECT SUM(importe) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0 
		             AND CC.Prioridad IN (1,2,3,4,5))>d.IMPORTE
		            THEN 
		              d.IMPORTE-(SELECT SUM(importe) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0 
		              AND CC.Prioridad IN (1,2,3,4))
		           else 
		          
		          (SELECT importe FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0 AND CC.Prioridad = 5)+
		             (d.IMPORTE-(SELECT SUM(importe) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0))
		           END
		         END        
		             
		    ELSE
		       CASE WHEN   
		               d.IMPORTE-(SELECT SUM(importe) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0 
		              AND CC.Prioridad IN (1,2,3,4))<0
		          THEN 0
		        ELSE    
		    
		          CASE WHEN
		             (SELECT SUM(importe) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0 
		             AND CC.Prioridad IN (1,2,3,4,5))>d.IMPORTE
		            THEN 
		              d.IMPORTE-(SELECT SUM(importe) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0 
		              AND CC.Prioridad IN (1,2,3,4))
		              
		            ELSE
		              (SELECT importe FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0 AND CC.Prioridad = 5)
		            END
		        END    
		         		            
		    END,0) TOTAL_CESION_5
	FROM REC_DET_RECAUDOS_CAJA d
	WHERE d.ID_CABEZAL = c.ID) AS O)AS TOTAL_C5,
	
	------------------------------
	(SELECT SUM(O.[TOTAL_RESTO]) AS RESTO_TOTAL
FROM(
SELECT
isnull( 
 CASE WHEN 
	      (d.IMPORTE - (SELECT SUM(importe) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0))<0 THEN 0 
	     
	  
	  else d.IMPORTE -(SELECT SUM(importe) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''I'' AND TZ_LOCK=0) END


,0) TOTAL_RESTO
	FROM REC_DET_RECAUDOS_CAJA d
	WHERE d.ID_CABEZAL = c.ID) AS O)AS RESTO_TOTAL    
		    
		    
		          		          
		                 
      
FROM REC_CAB_RECAUDOS_CAJA AS C WITH (nolock)
 INNER JOIN REC_DET_RECAUDOS_CAJA D WITH (nolock) ON 
    	C.ID=d.ID_CABEZAL
	    AND  D.TZ_LOCK = 0 
	    
 INNER JOIN CONV_CESIONES AS cc2  WITH (nolock) ON 
                             cc2.Id_ConvRec = c.CONVENIO 
                             AND cc2.TZ_LOCK =0
                             AND cc2.TpoCes = ''I''
  WHERE C.TZ_LOCK = 0
GROUP BY c.ID,d.ID_LINEA,d.MONEDA,
       d.IMPORTE,cc2.Importe,c.CONVENIO
')
