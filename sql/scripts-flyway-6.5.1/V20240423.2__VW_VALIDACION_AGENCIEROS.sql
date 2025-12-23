EXECUTE('
IF OBJECT_ID (''dbo.VW_VALIDACION_AGENCIEROS'') IS NOT NULL
	DROP VIEW dbo.VW_VALIDACION_AGENCIEROS
')

EXECUTE('
CREATE   VIEW [dbo].[VW_VALIDACION_AGENCIEROS]
AS


SELECT a.ID_TICKET AS "Id", 
         a.ASIENTO AS "Asiento", 
           a.FECHA AS "Fecha", 
        a.SUCURSAL AS "Sucursal", 
        (SELECT count(b.id) FROM REC_Agencieros b WHERE a.ID_TICKET = b.ID_TICKET AND b.ESTADO = ''H'' ) AS "Cant.Estado H", 
        (SELECT count(b.id) FROM REC_Agencieros b WHERE a.ID_TICKET = b.ID_TICKET AND b.ESTADO = ''F'' ) AS "Cant.Estado F"
  FROM REC_Agencieros a
 WHERE ESTADO IN (''H'',''F'')
   AND TZ_LOCK = 0
   AND ID_TICKET IS NOT NULL
 GROUP BY  ID_TICKET, ASIENTO, FECHA, SUCURSAL

')
