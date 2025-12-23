EXECUTE('

--VISTAS
DROP VIEW VW_AYUDA_CONVENIOS

')

EXECUTE ('

CREATE   VIEW VW_AYUDA_CONVENIOS
AS
SELECT con.Id_ConvRec AS [Numero convenio],con.NomConvRec AS [Nombre del convenio],con.RecConBD AS Padron,est.ID_REFERENCIA AS [Id Formulario],est.ID_CODIGO_BARRAS AS [Id Codigo de barras],est.LARGO AS [Largo]
FROM CONV_CONVENIOS_REC con JOIN CONV_CB_ESTRUCTURA est ON con.Id_ConvRec=est.ID_CONVENIO
WHERE (est.LARGO=0 OR (est.LARGO>0 AND con.RecConBD =''S'')) AND con.Canal = 1

')

execute ('
ALTER TABLE CONV_CB_ESTRUCTURA ADD [LARGO_ID] [numeric] (1,0) NULL

')