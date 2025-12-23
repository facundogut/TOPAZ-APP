EXECUTE('
IF OBJECT_ID (''dbo.MEMO_CABECERA'') IS NOT NULL
	DROP TABLE dbo.MEMO_CABECERA
')

EXECUTE('
CREATE TABLE dbo.MEMO_CABECERA
	(
	Fecha_Info          DATETIME NOT NULL,
	CUIT_CUIL_CDI       VARCHAR (20) DEFAULT ('' ''),
	Denominacion        VARCHAR (70) DEFAULT ('' ''),
	Clasificacion       VARCHAR (2) DEFAULT ('' ''),
	Origen_Situacion    VARCHAR (20) DEFAULT ('' ''),
	Cuenta_Orden        VARCHAR (1) DEFAULT ('' ''),
	Deuda_Total         NUMERIC (15, 2) DEFAULT ((0)),
	Deuda_Sin_Gar       NUMERIC (15, 2) DEFAULT ((0)),
	Deuda_GtiasPrefA    NUMERIC (15, 2) DEFAULT ((0)),
	Deuda_GtiasPrefB    NUMERIC (15, 2) DEFAULT ((0)),
	Prevision           NUMERIC (15, 2) DEFAULT ((0)),
	Sector_Activ        NUMERIC (1) DEFAULT ((0)),
	Seccion_Activ       VARCHAR (1) DEFAULT ('' ''),
	Cod_Activ_BCRA      NUMERIC (3) DEFAULT ((0)),
	Cod_Activ_AFIP      NUMERIC (6) DEFAULT ((0)),
	Desc_Cod_Activ_AFIP VARCHAR (400) DEFAULT ('' ''),
	Suc_Cliente         NUMERIC (5) DEFAULT ((0)),
	Categoria_Cliente   NUMERIC (1) DEFAULT ((0)),
	Cat_IVA             VARCHAR (2) DEFAULT ('' ''),
	Desc_Cat_IVA        VARCHAR (40) DEFAULT ('' ''),
	Sit_Prod_Banco      VARCHAR (2) DEFAULT ('' ''),
	Sector_Persona      NUMERIC (1) DEFAULT ((0)),
	Tipo_Persona        VARCHAR (1) DEFAULT ('' ''),
	Segmento            NUMERIC (2) DEFAULT ((0)),
	Subsegmento         NUMERIC (2) DEFAULT ((0)),
	Deudor_Encuadrado_Ley25326   VARCHAR (1) DEFAULT ('' ''),
	Clte_Refinanciado        VARCHAR (1) DEFAULT ('' ''),
	Fallecido           VARCHAR (1) DEFAULT ('' ''),
	Sit_Juridica        VARCHAR (1) DEFAULT ('' ''),
	Sit_Juridica_Ext    VARCHAR (1) DEFAULT ('' ''),
	Max_Atraso          NUMERIC (4) DEFAULT ((0)),
	Tamano_Emp          VARCHAR (20) DEFAULT ('' ''),
	Max_Asistencia      NUMERIC (15, 2) DEFAULT ((0)),
	Fecha_Max_Asist     DATETIME,
	Cliente_Vinc        VARCHAR (1) DEFAULT ('' ''),
	Cliente             NUMERIC (12) DEFAULT ((0)) NOT NULL,
	Emergencia		    VARCHAR(1),
	Desc_Categoria      VARCHAR(30),
	TZ_LOCK             NUMERIC (15) DEFAULT ((0)) NOT NULL,
	CONSTRAINT PK_MEMO_CABECERA_01 PRIMARY KEY (Fecha_Info, Cliente)
	)
')

