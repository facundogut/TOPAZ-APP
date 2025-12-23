EXECUTE('
IF OBJECT_ID (''dbo.VW_RENDICION_RECAUD_ENTE'') IS NOT NULL
	DROP VIEW dbo.VW_RENDICION_RECAUD_ENTE
')

EXECUTE('
CREATE VIEW dbo.[VW_RENDICION_RECAUD_ENTE]
AS


SELECT distinct  r.NomConvRec, 
       R.Id_ConvRec,
       c.ID AS "ID", 
       c.FECHACARGA AS "FECHA_PADRON",
       c.ESTADO AS "ESTADO",
	   c.ARCHIVO as "ARCHIVO",
       c.TOTALIMPORTE TOTAL_VTO1, 
       isnull(c.TOTAL_CARGO_ESPECIFICO,0)  TOTAL_CARGO_ESPECIFICO, 
       c.TOTALREGISTROS CANTIDAD_TOTAL_PADRON,
       isnull((SELECT count(p.ID_CABEZAL) FROM REC_DET_RECAUDOS_CANAL P
        WHERE p.ID_CABEZAL = c.ID 
          --AND p.ID_LINEA = d.ID_LINEA
          AND P.TOTAL_CARGO_ESPECIFICO !=0
          ),0) Cantidad_Cargo_especifico
         
         
  FROM REC_CAB_RECAUDOS_CANAL AS c WITH (NOLOCK)
  --INNER JOIN REC_DET_RECAUDOS_CANAL AS d WITH (NOLOCK)
     --           ON c.ID = d.ID_CABEZAL
       --			AND d.TZ_LOCK = 0       
  				
  INNER JOIN CONV_CONVENIOS_REC R  WITH (nolock)
                                  ON r.Id_ConvRec = c.CONVENIO
                                  AND R.Id_TpoConv = 18
   								  AND R.TZ_LOCK = 0
   								  AND R.Estado = ''A''
 WHERE c.TZ_LOCK = 0
   AND C.CONVENIO = r.Id_ConvRec



GROUP BY r.NomConvRec, R.Id_ConvRec,c.ID, 
         c.FECHACARGA,r.Id_ConvPadre,c.ESTADO,
          --d.ID_CABEZAL,d.ID_LINEA,
          c.archivo,c.TOTALIMPORTE,
		  c.TOTAL_CARGO_ESPECIFICO,c.TOTALREGISTROS

')
