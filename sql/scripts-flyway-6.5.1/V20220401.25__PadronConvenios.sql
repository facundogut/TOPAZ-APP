Execute('DROP TABLE IF EXISTS ITF_CONVENIOS_PADRON;

CREATE TABLE dbo.ITF_CONVENIOS_PADRON
	(
	TIPO_REGISTRO               INT NOT NULL,
	ID_TICKET                   INT NOT NULL,
	NRO_LINEA                   INT IDENTITY NOT NULL,
	FECHA_PADRON                DATE NULL,
	PERIODO                     INT NULL,
	NRO_DOCUMENTO               VARCHAR (15) NULL,
	NRO_COMPROBANTE             INT NULL,
	TIPO_DOCUMENTO              INT NULL,
	NOMBRE_APELLIDO             VARCHAR (60) NULL,
	NOMBRE_ADICIONAL            VARCHAR (60) NULL,
	TIPO_PAGO                   VARCHAR (1) NULL,
	TOTAL_DEUDA                 NUMERIC (10, 2) NULL,
	FECHA_PRIMER_VENCIMIENTO    DATETIME NULL,
	IMPORTE_PRIMER_VENCIMIENTO  NUMERIC (10, 2) NULL,
	FECHA_SEGUNDO_VENCIMIENTO   DATETIME NULL,
	IMPORTE_SEGUNDO_VENCIMIENTO NUMERIC (10, 2) NULL,
	MARCA_BAJA_PADRON           VARCHAR (1) NULL,
	FECHA_VIGENCIA              DATETIME NULL,
	CANTIDAD_REGISTROS          INT NULL,
	SUMATORIA_TOTAL_DEUDA       NUMERIC (13, 2) NULL,
	SUMATORIA_PRIMER_VTO        NUMERIC (13, 2) NULL,
	SUMATORIA_SEGUNDO_VTO       NUMERIC (13, 2) NULL,
	NRO_CONVENIO                INT NULL,
	CODIGO_BARRAS               VARCHAR (256) NULL,
	ESTADO                      CHAR (1) NULL,
	Descripcion                 VARCHAR (100) NULL,
	NombreArchivo               CHAR (25) NULL,
	NroRegistro                 INT NULL,
	FechaProceso                DATETIME NULL,
	HoraProceso                 CHAR (8) NULL,
	CONSTRAINT PK__ITF_CONVENIOS_PADRON PRIMARY KEY (ID_TICKET, TIPO_REGISTRO, NRO_LINEA)
	)

ALTER TABLE ITF_CONVENIOS_PADRON ALTER COLUMN sumatoria_total_deuda VARCHAR(15)
ALTER TABLE ITF_CONVENIOS_PADRON ALTER COLUMN total_deuda VARCHAR(15)
ALTER TABLE ITF_CONVENIOS_PADRON ALTER COLUMN tipo_documento VARCHAR(2)
ALTER TABLE ITF_CONVENIOS_PADRON ALTER COLUMN nro_Comprobante VARCHAR(15)')

Execute('CREATE OR ALTER PROCEDURE [dbo].[SP_ITF_CONVENIOS_PADRON] (@ticket NUMERIC(15,0),
												@VALIDACION NUMERIC(1,0) OUTPUT)
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

SET @sumatotaldeuda = (	SELECT SUM(CAST(TOTAL_DEUDA AS numeric)/100) 
						FROM ITF_CONVENIOS_PADRON WITH (NOLOCK)
						WHERE ID_TICKET = @ticket 
								AND TIPO_REGISTRO =2 AND Estado = ''P'');
SET @sumaprimervencimiento = (	SELECT SUM(CAST(IMPORTE_PRIMER_VENCIMIENTO AS NUMERIC)/100)  
								FROM ITF_CONVENIOS_PADRON WITH (NOLOCK) 
								WHERE ID_TICKET = @ticket 
										AND TIPO_REGISTRO =2 AND Estado = ''P'');
SET @sumasegundovencimiento = (SELECT SUM(CAST(IMPORTE_SEGUNDO_VENCIMIENTO AS NUMERIC)/100)  
								FROM ITF_CONVENIOS_PADRON WITH (NOLOCK) 
								WHERE ID_TICKET = @ticket 
									AND TIPO_REGISTRO =2 AND Estado = ''P''); 
SET @totalregistros = (	SELECT count(*) 
						FROM ITF_CONVENIOS_PADRON WITH (NOLOCK) 
						WHERE ID_TICKET = @ticket AND Estado = ''P'');
SET @VALIDACION = 1;
/*se cargan los valores que estan en el txt (los que se ecnuentran en el registro tipo 3)*/
SET @totalregistrosarchivo = (	SELECT CANTIDAD_REGISTROS 
								FROM ITF_CONVENIOS_PADRON  WITH (NOLOCK)
								WHERE ID_TICKET = @ticket 
									AND TIPO_REGISTRO = 3 AND Estado = ''P'');
SET @sumatotaldeudaarchivo = (	SELECT CAST(SUMATORIA_TOTAL_DEUDA AS NUMERIC)/100 
								FROM ITF_CONVENIOS_PADRON  WITH (NOLOCK)
								WHERE ID_TICKET = @ticket 
									AND TIPO_REGISTRO = 3 AND Estado = ''P'');
SET @sumaprimervencimientoarchivo= (SELECT CAST(SUMATORIA_PRIMER_VTO AS NUMERIC)/100 
									FROM ITF_CONVENIOS_PADRON  WITH (NOLOCK)
									WHERE ID_TICKET = @ticket 
										AND TIPO_REGISTRO = 3 AND Estado = ''P'');
SET @sumasegundovencimientoarchivo = (SELECT CAST(SUMATORIA_SEGUNDO_VTO AS NUMERIC)/100 
										FROM ITF_CONVENIOS_PADRON WITH (NOLOCK) 
										WHERE ID_TICKET = @ticket 
												AND TIPO_REGISTRO = 3 AND Estado = ''P'')

SET @idconvenio = (SELECT Id_ConvRec 
					FROM conv_convenios_rec  WITH (NOLOCK)
					WHERE Id_ConvRec IN (SELECT (NRO_CONVENIO) 
											FROM ITF_CONVENIOS_PADRON  WITH (NOLOCK) 
											WHERE ID_TICKET =@ticket 
												AND TIPO_REGISTRO =1 AND Estado = ''P''));
IF @idconvenio IS NULL 
	SET @idconvenio = 0;		

IF @totalregistros <> @totalregistrosarchivo OR @sumatotaldeuda <> @sumatotaldeudaarchivo OR @idconvenio = 0 OR  @sumaprimervencimientoarchivo <> @sumaprimervencimiento OR @sumasegundovencimientoarchivo <> @sumasegundovencimiento
	SET @VALIDACION = 0;
	PRINT @VALIDACION;



END')

