EXECUTE('
IF OBJECT_ID (''dbo.VW_CONV_CAJA_CABEZAL'') IS NOT NULL
	DROP VIEW dbo.VW_CONV_CAJA_CABEZAL
')
EXECUTE('
CREATE   VIEW [dbo].[VW_CONV_CAJA_CABEZAL]
AS
SELECT cab.ID AS Cabezal, 
       CONV.Id_ConvRec AS Convenio, 
       CONV.NomConvRec AS Nombre, 
       CONV.Cuit AS Cuit, 
       CONV.Cliente AS Cliente, 
       CONV.Id_TpoConv AS Tipo,
       t.DscTpoConv AS "Tipo Descripcion",
       CONV.Canal AS Canal,
       O.DESCRIPCION AS "Canal Descripcion",
       CAB.TOTALREGISTROS AS Registros,
       CAB.TOTALIMPORTE AS Importe,
       CAB.FECHACARGA AS Fecha
  FROM REC_CAB_recaudos_caja CAB
 INNER JOIN CONV_CONVENIOS_REC CONV ON CONV.Id_ConvRec = cab.CONVENIO
                                     AND CONV.TZ_LOCK = 0
                                     AND CONV.Estado =''A''
                                     AND CONV.Canal =1 
 INNER JOIN CONV_TIPOS T ON T.Id_TpoConv= CONV.Id_TpoConv
 INNER JOIN opciones O   ON O.NUMERODECAMPO = 44750
                         AND O.IDIOMA = ''E''
                         AND O.OPCIONINTERNA = CONV.Canal                               
 WHERE CAB.TZ_LOCK = 0
   AND CAB.ESTADO =''L''
')