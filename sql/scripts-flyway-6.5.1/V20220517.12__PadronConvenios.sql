Execute('

   DROP TABLE dbo.CONV_PADRONES;
   CREATE TABLE dbo.CONV_PADRONES
	(
	ID                      NUMERIC (15) IDENTITY NOT NULL,
	ID_TICKET               INT NOT NULL,
	FECHA_PADRON            DATETIME NULL,
	PERIODO                 NUMERIC (6) DEFAULT ((0)) NULL,
	NRO_DOCUMENTO           NUMERIC (15) DEFAULT ((0)) NULL,
	NRO_COMPROBANTE_CLIENTE NUMERIC (12) DEFAULT ((0)) NULL,
	TIPO_DOCUMENTO          NUMERIC (2) DEFAULT ((0)) NULL,
	APELLIDO_NOMBRE         VARCHAR (60) DEFAULT ('' '') NULL,
	NOMBRE_ADIC             VARCHAR (60) DEFAULT ('' '') NULL,
	FECHA_VTO1              DATETIME NULL,
	IMPORTE_VTO1            NUMERIC (15, 2) DEFAULT ((0)) NULL,
	FECHA_VTO2              DATETIME NULL,
	IMPORTE_VTO2            NUMERIC (15, 2) DEFAULT ((0)) NULL,
	ESTADO                  VARCHAR (1) DEFAULT ('' '') NULL,
	FECHA_VIGENCIA          DATETIME NULL,
	CONVENIO                NUMERIC (15) DEFAULT ((0)) NULL,
	REF_TOPAZ               NUMERIC (15) DEFAULT ((0)) NULL,
	CODIGO_BARRA            VARCHAR (120) DEFAULT ('' '') NULL,
	TZ_LOCK                 NUMERIC (15) DEFAULT ((0)) NOT NULL,
	TOTAL_CARGO_ESPECIFICO  NUMERIC (15, 2) NULL,
	SUCURSAL_TOPAZ          NUMERIC (5) NULL,
	TIPO_DE_PAGO            VARCHAR (1) NULL,
	TIPO_COMPROBANTE        VARCHAR (2) NULL,
	LETRA                   VARCHAR (1) NULL,
	PUNTO_VENTA             VARCHAR (4) NULL,
	CONSTRAINT PK_CONV_PADRONES_01 PRIMARY KEY (ID,ID_TICKET)
	)
	
	DROP TABLE IF EXISTS CONV_REL_ENTECONV;
	CREATE TABLE dbo.CONV_REL_ENTECONV
	(
	COD_ENTE   NUMERIC (10) DEFAULT ((0)) NULL,
	DESC_ENTE  VARCHAR (50) DEFAULT ('' '') NULL,
	ID_CONVREC NUMERIC (15) DEFAULT ((0)) NULL,
	NOMCONVREC VARCHAR (40) DEFAULT ('' '') NULL,
	TIPO_ENTE  NUMERIC (1) DEFAULT ((0)) NULL,
	TZ_LOCK    NUMERIC (15) DEFAULT ((0)) NOT NULL
	)

Delete dbo.DICCIONARIO where NUMERODECAMPO = 45202;
INSERT INTO dbo.DICCIONARIO (NUMERODECAMPO, USODELCAMPO, REFERENCIA, DESCRIPCION, PROMPT, LARGO, TIPODECAMPO, DECIMALES, EDICION, CONTABILIZA, CONCEPTO, CALCULO, VALIDACION, TABLADEVALIDACION, TABLADEAYUDA, OPCIONES, TABLA, CAMPO, BASICO, MASCARA)
VALUES (45202, '' '', 0, ''ID TICKET'', ''ID_TICKET'', 16, ''N'', 0, NULL, 0, 0, 0, 0, 0, 0, 0, 4487, ''ID_TICKET'', 0, NULL)')

Execute('DROP TABLE IF EXISTS ITF_CONVENIOS_PADRON;

CREATE TABLE dbo.ITF_CONVENIOS_PADRON
	(
	TIPO_REGISTRO               INT NOT NULL,
	ID_TICKET                   INT NOT NULL,
	NRO_LINEA                   INT IDENTITY NOT NULL,
	FECHA_PADRON                DATE,
	PERIODO                     INT,
	NRO_DOCUMENTO               VARCHAR (15),
	NRO_COMPROBANTE             VARCHAR (15),
	TIPO_DOCUMENTO              VARCHAR (2),
	NOMBRE_APELLIDO             VARCHAR (60),
	NOMBRE_ADICIONAL            VARCHAR (60),
	TIPO_PAGO                   VARCHAR (1),
	TOTAL_DEUDA                 VARCHAR (15),
	FECHA_PRIMER_VENCIMIENTO    VARCHAR (8),
	IMPORTE_PRIMER_VENCIMIENTO  VARCHAR (15),
	FECHA_SEGUNDO_VENCIMIENTO   VARCHAR (8),
	IMPORTE_SEGUNDO_VENCIMIENTO VARCHAR (15),
	MARCA_BAJA_PADRON           VARCHAR (1),
	FECHA_VIGENCIA              VARCHAR (8),
	CANTIDAD_REGISTROS          INT,
	SUMATORIA_TOTAL_DEUDA       VARCHAR (15),
	SUMATORIA_PRIMER_VTO        NUMERIC (13, 2),
	SUMATORIA_SEGUNDO_VTO       NUMERIC (13, 2),
	NRO_CONVENIO                INT,
	CODIGO_BARRAS               VARCHAR (256),
	ESTADO                      CHAR (1),
	Descripcion                 VARCHAR (100),
	NombreArchivo               CHAR (25),
	NroRegistro                 INT,
	FechaProceso                DATETIME,
	HoraProceso                 CHAR (8),
	CONSTRAINT PK__ITF_CONVENIOS_PADRON PRIMARY KEY (ID_TICKET, TIPO_REGISTRO, NRO_LINEA)
	)')
	
Execute('CREATE Or ALTER PROCEDURE [dbo].[SP_ITF_CONVENIOS_PADRON] (@ticket NUMERIC(15,0),
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



END


')


