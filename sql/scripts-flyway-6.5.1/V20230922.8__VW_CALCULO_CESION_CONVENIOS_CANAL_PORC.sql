
EXECUTE('
IF OBJECT_ID (''dbo.VW_CALCULO_CESION_CONVENIOS_CANAL_PORC'') IS NOT NULL
	DROP VIEW dbo.VW_CALCULO_CESION_CONVENIOS_CANAL_PORC
')

EXECUTE('
CREATE VIEW VW_CALCULO_CESION_CONVENIOS_CANAL_PORC
				(ID_CABEZAL,
				ID_DETALLE,
				MONEDA,
				IMPORTE_DETALLE,
				SUMA_PORCENTAJE,
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

     (SELECT SUM(cc.Porcentaje) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0)  SUMA_PORCENTAJE,
	  
	  CASE WHEN 
	    (SELECT SUM(cc.Porcentaje) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0)=100 THEN
	    0
	  ELSE
	    
 ROUND(	    	  
(d.importe) -(

(d.IMPORTE*(SELECT (cc.Porcentaje)/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad=1))  

+
(d.IMPORTE-(d.IMPORTE*(SELECT (cc.Porcentaje) /100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = 22 AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad=1)))
*(SELECT (cc.Porcentaje) /100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = 22 AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad=2)

+

( ( (d.IMPORTE-(
	          d.IMPORTE * (
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =1
	                  )
	          )
	    
	    
	    )-     
	    (d.IMPORTE-(
	          d.IMPORTE * (
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =1
	                  )
	          )
	    
	    
	    )*(
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =2
	                  ))*(
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =3
	                  ))
+
	   (((d.IMPORTE-(
	          d.IMPORTE * (
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =1
	                  )
	          )
	    
	    
	    )-     
	    (d.IMPORTE-(
	          d.IMPORTE * (
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =1
	                  )
	          )
	    
	    
	    )*(
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =2
	                  ))
-

  ( ( (d.IMPORTE-(
	          d.IMPORTE * (
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =1
	                  )
	          )
	    
	    
	    )-     
	    (d.IMPORTE-(
	          d.IMPORTE * (
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =1
	                  )
	          )
	    
	    
	    )*(
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =2
	                  ))*(
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =3
	                  )))*(
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =4
	                  )
	 
+
	  
	  ((((d.IMPORTE-(
	          d.IMPORTE * (
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =1
	                  )
	          )
	    
	    
	    )-     
	    (d.IMPORTE-(
	          d.IMPORTE * (
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =1
	                  )
	          )
	    
	    
	    )*(
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =2
	                  ))
-

  ( ( (d.IMPORTE-(
	          d.IMPORTE * (
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =1
	                  )
	          )
	    
	    
	    )-     
	    (d.IMPORTE-(
	          d.IMPORTE * (
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =1
	                  )
	          )
	    
	    
	    )*(
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =2
	                  ))*(
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =3
	                  )))
-
(((d.IMPORTE-(
	          d.IMPORTE * (
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =1
	                  )
	          )
	    
	    
	    )-     
	    (d.IMPORTE-(
	          d.IMPORTE * (
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =1
	                  )
	          )
	    
	    
	    )*(
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =2
	                  ))
-

  ( ( (d.IMPORTE-(
	          d.IMPORTE * (
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =1
	                  )
	          )
	    
	    
	    )-     
	    (d.IMPORTE-(
	          d.IMPORTE * (
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =1
	                  )
	          )
	    
	    
	    )*(
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =2
	                  ))*(
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =3
	                  )))*(
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =4
	                  ))*(
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =5
	                  )),2)
	                  
	    
	  END RESTO,
	  
	 isnull(
	  CASE WHEN 
	    (SELECT SUM(cc.Porcentaje) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0)=100 THEN
	    (d.IMPORTE*(SELECT (cc.Porcentaje)/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad=1))  
	  ELSE
	  ROUND(
	    (d.IMPORTE*(SELECT (cc.Porcentaje)/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad=1))  
	  ,2)
	  
	  END,0) IMPORTE_CESION_1,
	  
   isnull(
	CASE WHEN 
	 (SELECT MAX(cc.Prioridad) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0)=1 THEN
    	 0
	ELSE 
	  CASE WHEN 
	    (SELECT SUM(cc.Porcentaje) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0)=100 THEN
	    (d.IMPORTE-(d.IMPORTE*(SELECT (cc.Porcentaje) /100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad=1)))
	     *(SELECT (cc.Porcentaje) /100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad=2)
	  ELSE
	  ROUND(
	    (d.IMPORTE-(d.IMPORTE*(SELECT (cc.Porcentaje) /100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad=1)))
	     *(SELECT (cc.Porcentaje) /100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad=2)
	  ,2)
	  END 
	  
	END,0) IMPORTE_CESION_2, 
	    
  	
   CASE WHEN 
	 (SELECT MAX(cc.Prioridad) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0)IN (1,2) THEN
    	 0
	ELSE 
	  CASE WHEN 
	    (SELECT SUM(cc.Porcentaje) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0)=100 THEN
	    (d.IMPORTE-(d.IMPORTE * (SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad IN (1,2))))
	     *(SELECT (cc.Porcentaje) /100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad=3)
	  ELSE
	  ROUND(
	    ( ( (d.IMPORTE-(
	          d.IMPORTE * (
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =1
	                  )
	          )
	    
	    
	    )-     
	    (d.IMPORTE-(
	          d.IMPORTE * (
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =1
	                  )
	          )
	    
	    
	    )*(
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =2
	                  ))*(
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =3
	                  )),2)
	  
	  END 
	  
	END IMPORTE_CESION_3,     
	    
	CASE WHEN 
	 (SELECT MAX(cc.Prioridad) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0)IN (1,2,3) THEN
    	 0
	ELSE 
	  CASE WHEN 
	    (SELECT SUM(cc.Porcentaje) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0)=100 THEN
	    (d.IMPORTE-(d.IMPORTE * (SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad IN (1,2,3))))
	     *(SELECT (cc.Porcentaje) /100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad=4)
	  ELSE
	  ROUND(
	     (((d.IMPORTE-(
	          d.IMPORTE * (
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =1
	                  )
	          )
	    
	    
	    )-     
	    (d.IMPORTE-(
	          d.IMPORTE * (
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =1
	                  )
	          )
	    
	    
	    )*(
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =2
	                  ))
-

  ( ( (d.IMPORTE-(
	          d.IMPORTE * (
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =1
	                  )
	          )
	    
	    
	    )-     
	    (d.IMPORTE-(
	          d.IMPORTE * (
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =1
	                  )
	          )
	    
	    
	    )*(
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =2
	                  ))*(
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =3
	                  )))*(
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =4
	                  ),2)
	     
	  END 
	  
	END IMPORTE_CESION_4,
	
	CASE WHEN 
	 (SELECT MAX(cc.Prioridad) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0)IN (1,2,3,4) THEN
    	 0
	ELSE 
	  CASE WHEN 
	    (SELECT SUM(cc.Porcentaje) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0)=100 THEN
	    (d.IMPORTE-(d.IMPORTE * (SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad IN (1,2,3,4))))
	     *(SELECT (cc.Porcentaje) /100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad=5)
	  ELSE
	   ROUND(
	  ((((d.IMPORTE-(
	          d.IMPORTE * (
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =1
	                  )
	          )
	    
	    
	    )-     
	    (d.IMPORTE-(
	          d.IMPORTE * (
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =1
	                  )
	          )
	    
	    
	    )*(
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =2
	                  ))
-

  ( ( (d.IMPORTE-(
	          d.IMPORTE * (
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =1
	                  )
	          )
	    
	    
	    )-     
	    (d.IMPORTE-(
	          d.IMPORTE * (
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =1
	                  )
	          )
	    
	    
	    )*(
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =2
	                  ))*(
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =3
	                  )))
-
(((d.IMPORTE-(
	          d.IMPORTE * (
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =1
	                  )
	          )
	    
	    
	    )-     
	    (d.IMPORTE-(
	          d.IMPORTE * (
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =1
	                  )
	          )
	    
	    
	    )*(
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =2
	                  ))
-

  ( ( (d.IMPORTE-(
	          d.IMPORTE * (
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =1
	                  )
	          )
	    
	    
	    )-     
	    (d.IMPORTE-(
	          d.IMPORTE * (
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =1
	                  )
	          )
	    
	    
	    )*(
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =2
	                  ))*(
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =3
	                  )))*(
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =4
	                  ))*(
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =5
	                  ),2)
	  END 
	  
	END IMPORTE_CESION_5,
	-----------------------------------
		(SELECT SUM(O.[TOTAL_CESION_1]) AS TOTAL_C1
FROM(
SELECT 
isnull(CASE WHEN 
	    (SELECT SUM(cc.Porcentaje) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0)=100 THEN
	    (d.IMPORTE*(SELECT (cc.Porcentaje)/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad=1))  
	  ELSE
	   ROUND(
	    (d.IMPORTE*(SELECT (cc.Porcentaje)/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad=1))  
	  ,2)
	  END,0) TOTAL_CESION_1
	FROM REC_DET_RECAUDOS_CANAL d
	WHERE d.TZ_LOCK=0 AND d.ID_CABEZAL = c.ID) AS O)AS TOTAL_C1,
	
	
(SELECT SUM(O.[TOTAL_CESION_2]) AS TOTAL_C2
FROM(
SELECT 
isnull(CASE WHEN 
	 (SELECT MAX(cc.Prioridad) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0)=1 THEN
    	 0
	ELSE 
	  CASE WHEN 
	    (SELECT SUM(cc.Porcentaje) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0)=100 THEN
	    (d.IMPORTE-(d.IMPORTE*(SELECT (cc.Porcentaje) /100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad=1)))
	     *(SELECT (cc.Porcentaje) /100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad=2)
	  ELSE
	  ROUND(
	    (d.IMPORTE-(d.IMPORTE*(SELECT (cc.Porcentaje) /100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad=1)))
	     *(SELECT (cc.Porcentaje) /100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad=2)
	  ,2)
	  END 
	  
	END,0) TOTAL_CESION_2
	FROM REC_DET_RECAUDOS_CANAL d
	WHERE d.TZ_LOCK=0 AND d.ID_CABEZAL = c.ID) AS O)AS TOTAL_C2,
	
	(SELECT SUM(O.[TOTAL_CESION_3]) AS TOTAL_C3
FROM(
SELECT 
isnull(CASE WHEN 
	 (SELECT MAX(cc.Prioridad) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0)IN (1,2) THEN
    	 0
	ELSE 
	  CASE WHEN 
	    (SELECT SUM(cc.Porcentaje) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0)=100 THEN
	    (d.IMPORTE-(d.IMPORTE * (SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad IN (1,2))))
	     *(SELECT (cc.Porcentaje) /100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad=3)
	  ELSE
	  ROUND(
	   ( ( (d.IMPORTE-(
	          d.IMPORTE * (
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =1
	                  )
	          )
	    
	    
	    )-     
	    (d.IMPORTE-(
	          d.IMPORTE * (
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =1
	                  )
	          )
	    
	    
	    )*(
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =2
	                  ))*(
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =3
	                  )),2)
	  END 
	  
	END,0) TOTAL_CESION_3
	FROM REC_DET_RECAUDOS_CANAL d
	WHERE d.TZ_LOCK=0 AND d.ID_CABEZAL = c.ID) AS O)AS TOTAL_C3,
	
	
	(SELECT SUM(O.[TOTAL_CESION_4]) AS TOTAL_C4
FROM(
SELECT 
isnull(CASE WHEN 
	 (SELECT MAX(cc.Prioridad) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0)IN (1,2,3) THEN
    	 0
	ELSE 
	  CASE WHEN 
	    (SELECT SUM(cc.Porcentaje) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0)=100 THEN
	    (d.IMPORTE-(d.IMPORTE * (SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad IN (1,2,3))))
	     *(SELECT (cc.Porcentaje) /100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad=4)
	  ELSE
	  
	  ROUND(
	   (((d.IMPORTE-(
	          d.IMPORTE * (
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =1
	                  )
	          )
	    
	    
	    )-     
	    (d.IMPORTE-(
	          d.IMPORTE * (
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =1
	                  )
	          )
	    
	    
	    )*(
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =2
	                  ))
-

  ( ( (d.IMPORTE-(
	          d.IMPORTE * (
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =1
	                  )
	          )
	    
	    
	    )-     
	    (d.IMPORTE-(
	          d.IMPORTE * (
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =1
	                  )
	          )
	    
	    
	    )*(
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =2
	                  ))*(
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =3
	                  )))*(
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =4
	                  ),2)
	  END 
	  
	END,0) TOTAL_CESION_4
	FROM REC_DET_RECAUDOS_CANAL d
	WHERE d.TZ_LOCK=0 AND d.ID_CABEZAL = c.ID) AS O)AS TOTAL_C4,
	
	
		(SELECT SUM(O.[TOTAL_CESION_5]) AS TOTAL_C5
FROM(
SELECT 
isnull(CASE WHEN 
	 (SELECT MAX(cc.Prioridad) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0)IN (1,2,3) THEN
    	 0
	ELSE 
	  CASE WHEN 
	    (SELECT SUM(cc.Porcentaje) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0)=100 THEN
	    (d.IMPORTE-(d.IMPORTE * (SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad IN (1,2,3,4))))
	     *(SELECT (cc.Porcentaje) /100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad=5)
	  ELSE
	  ROUND(
	   
	  ((((d.IMPORTE-(
	          d.IMPORTE * (
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =1
	                  )
	          )
	    
	    
	    )-     
	    (d.IMPORTE-(
	          d.IMPORTE * (
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =1
	                  )
	          )
	    
	    
	    )*(
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =2
	                  ))
-

  ( ( (d.IMPORTE-(
	          d.IMPORTE * (
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =1
	                  )
	          )
	    
	    
	    )-     
	    (d.IMPORTE-(
	          d.IMPORTE * (
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =1
	                  )
	          )
	    
	    
	    )*(
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =2
	                  ))*(
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =3
	                  )))
-
(((d.IMPORTE-(
	          d.IMPORTE * (
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =1
	                  )
	          )
	    
	    
	    )-     
	    (d.IMPORTE-(
	          d.IMPORTE * (
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =1
	                  )
	          )
	    
	    
	    )*(
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =2
	                  ))
-

  ( ( (d.IMPORTE-(
	          d.IMPORTE * (
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =1
	                  )
	          )
	    
	    
	    )-     
	    (d.IMPORTE-(
	          d.IMPORTE * (
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =1
	                  )
	          )
	    
	    
	    )*(
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =2
	                  ))*(
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =3
	                  )))*(
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =4
	                  ))*(
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =5
	                  ),2)
	  END 
	  
	END,0) TOTAL_CESION_5
	FROM REC_DET_RECAUDOS_CANAL d
	WHERE d.TZ_LOCK=0 AND d.ID_CABEZAL = c.ID) AS O)AS TOTAL_C5,
	
	(SELECT SUM(O.[TOTAL_RESTO]) AS RESTO_TOTAL
FROM(
SELECT
isnull( 
 	CASE WHEN 
	    (SELECT SUM(cc.Porcentaje) FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0)=100 THEN
	    0
	  ELSE
	    
 ROUND(	  
(d.importe) -(

(d.IMPORTE*(SELECT (cc.Porcentaje)/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad=1))  

+
(d.IMPORTE-(d.IMPORTE*(SELECT (cc.Porcentaje) /100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = 22 AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad=1)))
*(SELECT (cc.Porcentaje) /100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = 22 AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad=2)

+

( ( (d.IMPORTE-(
	          d.IMPORTE * (
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =1
	                  )
	          )
	    
	    
	    )-     
	    (d.IMPORTE-(
	          d.IMPORTE * (
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =1
	                  )
	          )
	    
	    
	    )*(
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =2
	                  ))*(
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =3
	                  ))
+
	   (((d.IMPORTE-(
	          d.IMPORTE * (
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =1
	                  )
	          )
	    
	    
	    )-     
	    (d.IMPORTE-(
	          d.IMPORTE * (
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =1
	                  )
	          )
	    
	    
	    )*(
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =2
	                  ))
-

  ( ( (d.IMPORTE-(
	          d.IMPORTE * (
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =1
	                  )
	          )
	    
	    
	    )-     
	    (d.IMPORTE-(
	          d.IMPORTE * (
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =1
	                  )
	          )
	    
	    
	    )*(
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =2
	                  ))*(
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =3
	                  )))*(
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =4
	                  )
	 
+
	  
	  ((((d.IMPORTE-(
	          d.IMPORTE * (
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =1
	                  )
	          )
	    
	    
	    )-     
	    (d.IMPORTE-(
	          d.IMPORTE * (
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =1
	                  )
	          )
	    
	    
	    )*(
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =2
	                  ))
-

  ( ( (d.IMPORTE-(
	          d.IMPORTE * (
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =1
	                  )
	          )
	    
	    
	    )-     
	    (d.IMPORTE-(
	          d.IMPORTE * (
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =1
	                  )
	          )
	    
	    
	    )*(
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =2
	                  ))*(
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =3
	                  )))
-
(((d.IMPORTE-(
	          d.IMPORTE * (
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =1
	                  )
	          )
	    
	    
	    )-     
	    (d.IMPORTE-(
	          d.IMPORTE * (
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =1
	                  )
	          )
	    
	    
	    )*(
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =2
	                  ))
-

  ( ( (d.IMPORTE-(
	          d.IMPORTE * (
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =1
	                  )
	          )
	    
	    
	    )-     
	    (d.IMPORTE-(
	          d.IMPORTE * (
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =1
	                  )
	          )
	    
	    
	    )*(
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =2
	                  ))*(
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =3
	                  )))*(
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =4
	                  ))*(
	                  SELECT (SUM(cc.Porcentaje))/100 FROM CONV_CESIONES CC WHERE cc.Id_ConvRec = c.CONVENIO AND cc.TpoCes = ''P'' AND TZ_LOCK=0 AND CC.Prioridad =5
	                  )),2)
	                  
	  END
,0) TOTAL_RESTO
	FROM REC_DET_RECAUDOS_CANAL d
	WHERE d.ID_CABEZAL = c.ID) AS O)AS RESTO_TOTAL 
	
	
	
	
                       
      
FROM REC_CAB_RECAUDOS_CANAL AS C WITH (nolock)
 INNER JOIN REC_DET_RECAUDOS_CANAL D WITH (nolock) ON 
    	C.ID=d.ID_CABEZAL
	    AND  D.TZ_LOCK = 0 
	    
 INNER JOIN CONV_CESIONES AS cc2  WITH (nolock) ON 
                             cc2.Id_ConvRec = c.CONVENIO 
                             AND cc2.TZ_LOCK =0
                             AND cc2.TpoCes = ''P''
  WHERE C.TZ_LOCK = 0
    
GROUP BY c.ID,d.ID_LINEA,d.MONEDA,
       d.IMPORTE,cc2.Importe,c.CONVENIO

')
