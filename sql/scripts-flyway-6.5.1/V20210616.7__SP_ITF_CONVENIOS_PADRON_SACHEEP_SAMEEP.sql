EXECUTE('CREATE PROCEDURE SP_ITF_CONVENIOS_PADRON_SACHEEP_SAMEEP (@ticket NUMERIC(15,0),@VALIDACION NUMERIC(1,0) OUTPUT)
 AS
 /*SP QUE VALIDA LO REQUERIDO Y DEVUELVE CERO si no PASA, si PASA devuelve 1*/
BEGIN

DECLARE @sumatotaldeuda NUMERIC (38,2);
DECLARE @totalregistros NUMERIC(10,0);
DECLARE @idconvenio NUMERIC (15,0) = 0;
-- aca arriba se declaran los reales, a partir de aqui van los del tiporegistro 3, que son los que vienen en el txt
DECLARE @sumatotaldeudaarchivo NUMERIC (14,2);
DECLARE @totalregistrosarchivo NUMERIC(10,0);
/*se cargan los valores reales*/

SET @sumatotaldeuda = (SELECT SUM(IMPORTE_PRIMER_VENCIMIENTO) FROM ITF_CONVENIOS_SACHEEP_SAMEEP WHERE ID_TICKET = @ticket AND TIPO_REGISTRO =2);
SET @totalregistros = (SELECT count(*) FROM ITF_CONVENIOS_SACHEEP_SAMEEP WHERE ID_TICKET = @ticket);
SET @VALIDACION = 1;
/*se cargan los valores que estan en el txt (los que se ecnuentran en el registro tipo 3)*/
SET @totalregistrosarchivo = (SELECT CANTIDAD_REGISTROS FROM ITF_CONVENIOS_SACHEEP_SAMEEP WHERE ID_TICKET = @ticket AND TIPO_REGISTRO = 3);
SET @sumatotaldeudaarchivo = (SELECT IMPORTE_TOTAL_COBRADO FROM ITF_CONVENIOS_SACHEEP_SAMEEP WHERE ID_TICKET = @ticket AND TIPO_REGISTRO = 3);


SET @idconvenio = (SELECT Id_ConvRec FROM conv_convenios_rec WHERE Id_ConvRec IN (SELECT (ENTE) FROM ITF_CONVENIOS_SACHEEP_SAMEEP WHERE ID_TICKET =@ticket AND TIPO_REGISTRO =1));
IF @idconvenio IS NULL 
	SET @idconvenio = 0;		

IF @totalregistros <> @totalregistrosarchivo OR @sumatotaldeuda <> @sumatotaldeudaarchivo OR @idconvenio = 0 
	SET @VALIDACION = 0;
	PRINT @VALIDACION;



END')


