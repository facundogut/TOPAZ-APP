EXECUTE('

DROP TABLE CONV_TIPOS

CREATE TABLE CONV_TIPOS
	(
	Id_TpoConv      NUMERIC (5) DEFAULT ((0)) NOT NULL,
	DscTpoConv      VARCHAR (40) DEFAULT ('' '') NULL,
	TpoProducto     VARCHAR (1) DEFAULT ('' '') NULL,
	TpoCStopD       VARCHAR (1) DEFAULT ('' '') NULL,
	TpoCRev         VARCHAR (1) DEFAULT ('' '') NULL,
	TpoCMulta       VARCHAR (1) DEFAULT ('' '') NULL,
	TpoContrato     NUMERIC (3) DEFAULT ((0)) NULL,
	Rubro_operativo NUMERIC (12) DEFAULT ((0)) NULL,
	TZ_LOCK         NUMERIC (15) DEFAULT ((0)) NOT NULL,
	CONSTRAINT PK_CONV_TIPOS_01 PRIMARY KEY (Id_TpoConv)
	)

DROP TABLE CONV_CONVENIOS_REC

CREATE TABLE CONV_CONVENIOS_REC
	(
	Id_ConvRec        NUMERIC (15) DEFAULT ((0)) NOT NULL,
	NomConvRec        VARCHAR (40) DEFAULT ('' '') NULL,
	Cuit              NUMERIC (11) DEFAULT ((0)) NULL,
	Cliente           NUMERIC (12) DEFAULT ((0)) NULL,
	Dir_Id            NUMERIC (12) DEFAULT ((0)) NULL,
	Dir_Formato       VARCHAR (2) DEFAULT ('' '') NULL,
	Id_TpoConv        NUMERIC (5) DEFAULT ((0)) NULL,
	Plazo             NUMERIC (4) DEFAULT ((0)) NULL,
	Canal             NUMERIC (3) DEFAULT ((0)) NULL,
	RenAuto           VARCHAR (1) DEFAULT ('' '') NULL,
	BajaAuto          NUMERIC (4) DEFAULT ((0)) NULL,
	InactAuto         NUMERIC (4) DEFAULT ((0)) NULL,
	Acreditacion      VARCHAR (3) DEFAULT ('' '') NULL,
	Estado            VARCHAR (1) DEFAULT ('' '') NULL,
	FecAlta           DATETIME NULL,
	FecVto            DATETIME NULL,
	FecUltAct         DATETIME NULL,
	Id_RefExt         VARCHAR (20) DEFAULT ('' '') NULL,
	Id_ConvPadre      NUMERIC (15) DEFAULT ((0)) NULL,
	TieneCesion       VARCHAR (1) DEFAULT ('' '') NULL,
	UsuUltMod         VARCHAR (10) DEFAULT ('' '') NULL,
	TpoConvSeg        VARCHAR (1) DEFAULT ('' '') NULL,
	TpoConvSegM       VARCHAR (1) DEFAULT ('' '') NULL,
	Dir_Tipo          VARCHAR (2) DEFAULT ('' '') NULL,
	TZ_LOCK           NUMERIC (15) DEFAULT ((0)) NOT NULL,
	PerFactVen        VARCHAR (1) NULL,
	CuentaRec         NUMERIC (10) NULL,
	CuentaCom         NUMERIC (10) NULL,
	CuentaCargos      NUMERIC (10) NULL,
	Prioridad         NUMERIC (3) NULL,
	MomentoCom        VARCHAR (2) NULL,
	RecConBD          VARCHAR (1) NULL,
	FecCamEst         DATETIME NULL,
	TpoCalcMora       VARCHAR (1) NULL,
	ID_Formula        NUMERIC (5) NULL,
	DiaCierreDA       NUMERIC (2) NULL,
	CTA_TRANSITORIA   NUMERIC (10) NULL,
	Dir_ordinal       NUMERIC (3) NULL,
	FORMATO_RENDICION NUMERIC (2) NULL,
	CONSTRAINT PK_CONV_CONVENIOS_REC_01 PRIMARY KEY (Id_ConvRec)
	)

ALTER TABLE REC_DET_RECAUDOS_CAJA ADD 
[NRO_CAJA] [numeric] (3,0) NULL

ALTER TABLE CONV_PADRONES ADD 
[TIPO_DE_PAGO] [varchar] (1) ,
[TIPO_COMPROBANTE] [varchar] (2) ,
[LETRA] [varchar] (1) ,
[PUNTO_VENTA] [varchar] (4) 

ALTER TABLE CONV_CB_ESTRUCTURA ADD 
[LLeva_DV] [varchar] (1) ,
[Rutina_DV] [varchar] (20) ,
[Genera_CB] [varchar] (1) 

CREATE TABLE REC_REVERSAS
(
	[Id_Convenio] [numeric] (15,0) NOT NULL ,
	[Id_Cabezal] [numeric] (15,0) NOT NULL ,
	[Id_Linea] [numeric] (15,0) NOT NULL ,
	[Fecha_Reversa] [datetime] NULL,
	[Estado] [varchar] (1) ,
	[Tipo_Debito] [varchar] (2) ,
	[Asiento] [numeric] (10,0) NULL ,
	[Fecha_Asiento] [datetime] NULL,
	[TZ_LOCK] [numeric] (15,0) NOT NULL,
	CONSTRAINT [PK_REC_REVERSAS_01] PRIMARY KEY CLUSTERED
	(
		[Id_Convenio] ASC,
		[Id_Cabezal] ASC,
		[Id_Linea] ASC
	) 
) ON [PRIMARY]

DROP TABLE REC_DET_RECAUDOS_CANAL

CREATE TABLE REC_DET_RECAUDOS_CANAL
	(
	ID_CABEZAL             NUMERIC (15) DEFAULT ((0)) NOT NULL,
	ID_LINEA               NUMERIC (15) DEFAULT ((0)) NOT NULL,
	MONEDA                 NUMERIC (4) DEFAULT ((0)) NULL,
	IMPORTE                NUMERIC (15, 2) DEFAULT ((0)) NULL,
	CODIGO_BARRAS          VARCHAR (120) DEFAULT ('' '') NULL,
	CODIGO_BARRAS_RENDIDO  VARCHAR (120) DEFAULT ('' '') NULL,
	ESTADO                 VARCHAR (1) DEFAULT ('' '') NULL,
	DETALLE_ESTADO         VARCHAR (35) DEFAULT ('' '') NULL,
	TOTAL_CARGO_ESPECIFICO NUMERIC (15, 2) DEFAULT ((0)) NULL,
	TZ_LOCK                NUMERIC (15) DEFAULT ((0)) NOT NULL,
	CONSTRAINT PK_REC_DET_RECAUDOS_CANAL_01 PRIMARY KEY (ID_CABEZAL, ID_LINEA)
	)

')