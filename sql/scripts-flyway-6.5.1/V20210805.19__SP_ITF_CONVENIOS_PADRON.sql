/****** Object:  StoredProcedure [dbo].[SP_ITF_CONVENIOS_PADRON]    Script Date: 01/06/2021 12:18:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_ITF_CONVENIOS_PADRON] (@ticket NUMERIC(15,0),@VALIDACION NUMERIC(1,0) OUTPUT)
 AS
 /*SP QUE VALIDA LO REQUERIDO Y DEVUELVE CERO si no PASA, si PASA devuelve 1*/
BEGIN

DECLARE @sumatotaldeuda NUMERIC (13,2);
DECLARE @sumaprimervencimiento NUMERIC (13,2);
DECLARE @sumasegundovencimiento NUMERIC (13,2);
DECLARE @totalregistros NUMERIC(10,0);
DECLARE @idconvenio NUMERIC (15,0) = 0;
-- aca arriba se declaran los reales, a partir de aqui van los del tiporegistro 3, que son los que vienen en el txt
DECLARE @sumatotaldeudaarchivo NUMERIC (13,2);
DECLARE @sumaprimervencimientoarchivo NUMERIC (13,2);
DECLARE @sumasegundovencimientoarchivo NUMERIC (13,2);
DECLARE @totalregistrosarchivo NUMERIC(10,0);
/*se cargan los valores reales*/

SET @sumatotaldeuda = (SELECT SUM(TOTAL_DEUDA) 
						FROM ITF_CONVENIOS_PADRON WITH (NOLOCK)
						WHERE ID_TICKET = @ticket 
								AND TIPO_REGISTRO =2);
SET @sumaprimervencimiento = (SELECT SUM(IMPORTE_PRIMER_VENCIMIENTO)  
								FROM ITF_CONVENIOS_PADRON  WITH (NOLOCK)
								WHERE ID_TICKET = @ticket AND TIPO_REGISTRO =2);
SET @sumasegundovencimiento = (SELECT SUM(IMPORTE_SEGUNDO_VENCIMIENTO)  
								FROM ITF_CONVENIOS_PADRON  WITH (NOLOCK)
								WHERE ID_TICKET = @ticket AND TIPO_REGISTRO =2); 
SET @totalregistros = (SELECT count(*) 
						FROM ITF_CONVENIOS_PADRON  WITH (NOLOCK) 
						WHERE ID_TICKET = @ticket);
SET @VALIDACION = 1;
/*se cargan los valores que estan en el txt (los que se ecnuentran en el registro tipo 3)*/
SET @totalregistrosarchivo = (SELECT CANTIDAD_REGISTROS FROM ITF_CONVENIOS_PADRON WITH (NOLOCK) WHERE ID_TICKET = @ticket AND TIPO_REGISTRO = 3);
SET @sumatotaldeudaarchivo = (SELECT SUMATORIA_TOTAL_DEUDA FROM ITF_CONVENIOS_PADRON WITH (NOLOCK) WHERE ID_TICKET = @ticket AND TIPO_REGISTRO = 3);
SET @sumaprimervencimientoarchivo= (SELECT SUMATORIA_PRIMER_VTO FROM ITF_CONVENIOS_PADRON WITH (NOLOCK) WHERE ID_TICKET = @ticket AND TIPO_REGISTRO = 3);
SET @sumasegundovencimientoarchivo = (SELECT SUMATORIA_SEGUNDO_VTO FROM ITF_CONVENIOS_PADRON WITH (NOLOCK) WHERE ID_TICKET = @ticket AND TIPO_REGISTRO = 3)

SET @idconvenio = (SELECT Id_ConvRec FROM conv_convenios_rec WITH (NOLOCK) WHERE Id_ConvRec IN (SELECT (NRO_CONVENIO) FROM ITF_CONVENIOS_PADRON WITH (NOLOCK) WHERE ID_TICKET =@ticket AND TIPO_REGISTRO =1));
IF @idconvenio IS NULL 
	SET @idconvenio = 0;		

IF @totalregistros <> @totalregistrosarchivo OR @sumatotaldeuda <> @sumatotaldeudaarchivo OR @idconvenio = 0 OR  @sumaprimervencimientoarchivo <> @sumaprimervencimiento OR @sumasegundovencimientoarchivo <> @sumasegundovencimiento
	SET @VALIDACION = 0;
	PRINT @VALIDACION;



END