
EXECUTE('
IF OBJECT_ID (''dbo.VW_RENDICION_RECAUD_ENTE'') IS NOT NULL
	DROP VIEW dbo.VW_RENDICION_RECAUD_ENTE

')

EXECUTE('
CREATE VIEW dbo.[VW_RENDICION_RECAUD_ENTE]
AS


SELECT r.NomConvRec, 
       R.Id_ConvRec,
       p.ID_TICKET, 
       P.FECHA_PADRON,
       P.ESTADO,
       sum(P.IMPORTE_VTO1) TOTAL_VTO1, 
       sum(P.TOTAL_CARGO_ESPECIFICO) TOTAL_CARGO_ESPECIFICO, 
       count(p.ID_TICKET) CANTIDAD_TOTAL_PADRON,
       (SELECT count(p2.ID) FROM CONV_PADRONES P2 
        WHERE P2.ID_TICKET = p2.ID_TICKET 
          AND P2.CONVENIO = r.Id_ConvPadre
          AND P2.TOTAL_CARGO_ESPECIFICO !=0
          AND P2.TOTAL_CARGO_ESPECIFICO IS NOT NULL
          AND P2.FECHA_PADRON = p.FECHA_PADRON
          AND P2.ESTADO = p.ESTADO
          ) Cantidad_Cargo_especifico
         
  FROM CONV_PADRONES P  WITH (nolock)
  
  INNER JOIN CONV_CONVENIOS_REC R  WITH (nolock)
                                  ON P.CONVENIO = r.Id_ConvPadre
                                  AND R.Id_TpoConv = 18
   								  AND R.TZ_LOCK = 0
   								  AND R.Estado = ''A''
 WHERE P.TZ_LOCK = 0
   
GROUP BY r.NomConvRec, R.Id_ConvRec,p.ID_TICKET, 
         P.FECHA_PADRON,r.Id_ConvPadre,p.FECHA_PADRON,P.ESTADO

')