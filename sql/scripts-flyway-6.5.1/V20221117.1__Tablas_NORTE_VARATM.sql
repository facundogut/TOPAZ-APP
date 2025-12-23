Execute('
IF OBJECT_ID (''dbo.ITF_DET_NORTE_VARATM'') IS NOT NULL
	DROP TABLE dbo.ITF_DET_NORTE_VARATM
')


Execute('
IF OBJECT_ID (''dbo.ITF_CAB_NORTE_VARATM'') IS NOT NULL
	DROP TABLE dbo.ITF_CAB_NORTE_VARATM
')


Execute('
CREATE TABLE dbo.ITF_CAB_NORTE_VARATM
	(
	ID                      NUMERIC (15) DEFAULT ((0)) NOT NULL,
	Soporte_Operaciones     DATETIME,
	Moneda                  VARCHAR (2) DEFAULT ('' ''),
	Nro_ATM                 VARCHAR (5) DEFAULT ('' ''),
	Sum_Importe_Disminucion NUMERIC (15, 2) DEFAULT ((0)),
	Denom_billete_1_dism    VARCHAR (7) DEFAULT ('' ''),
	Cant_billete_1_dism     VARCHAR (7) DEFAULT ('' ''),
	Denom_billete_2_dism    VARCHAR (7) DEFAULT ('' ''),
	Cant_billete_2_dism     VARCHAR (7) DEFAULT ('' ''),
	Denom_billete_3_dism    VARCHAR (7) DEFAULT ('' ''),
	Cant_billete_3_dism     VARCHAR (7) DEFAULT ('' ''),
	Denom_billete_4_dism    VARCHAR (7) DEFAULT ('' ''),
	Cant_billete_4_dism     VARCHAR (7) DEFAULT ('' ''),
	Sum_Importe_Deposito    NUMERIC (15, 2) DEFAULT ((0)),
	Sum_Importe_Aumento     NUMERIC (15, 2) DEFAULT ((0)),
	Denom_billete_1_aum     VARCHAR (7) DEFAULT ('' ''),
	Cant_billete_1_aum      VARCHAR (7) DEFAULT ('' ''),
	Denom_billete_2_aum     VARCHAR (7) DEFAULT ('' ''),
	Cant_billete_2_aum      VARCHAR (7) DEFAULT ('' ''),
	Denom_billete_3_aum     VARCHAR (7) DEFAULT ('' ''),
	Cant_billete_3_aum      VARCHAR (7) DEFAULT ('' ''),
	Denom_billete_4_aum     VARCHAR (7) DEFAULT ('' ''),
	Cant_billete_4_aum      VARCHAR (7) DEFAULT ('' ''),
	Sum_Importe_Pago        NUMERIC (15, 2) DEFAULT ((0)),
	TZ_LOCK                 NUMERIC (15) DEFAULT ((0)) NOT NULL,
	CONSTRAINT PK_ITF_NORTE_CAB PRIMARY KEY (ID)
	)
')


Execute('
CREATE TABLE dbo.ITF_DET_NORTE_VARATM
	(
	ID                   NUMERIC (15) DEFAULT ((0)) NOT NULL,
	ID_CABEZAL           NUMERIC (15) DEFAULT ((0)) NOT NULL,
	Soporte_Operaciones  DATETIME,
	Moneda               VARCHAR (2) DEFAULT ('' ''),
	Nro_ATM              VARCHAR (5) DEFAULT ('' ''),
	Importe_Disminucion  NUMERIC (15, 2) DEFAULT ((0)),
	Denom_billete_1_dism VARCHAR (7) DEFAULT ('' ''),
	Cant_billete_1_dism  VARCHAR (7) DEFAULT ('' ''),
	Denom_billete_2_dism VARCHAR (7) DEFAULT ('' ''),
	Cant_billete_2_dism  VARCHAR (7) DEFAULT ('' ''),
	Denom_billete_3_dism VARCHAR (7) DEFAULT ('' ''),
	Cant_billete_3_dism  VARCHAR (7) DEFAULT ('' ''),
	Denom_billete_4_dism VARCHAR (7) DEFAULT ('' ''),
	Cant_billete_4_dism  VARCHAR (7) DEFAULT ('' ''),
	Importe_Deposito     NUMERIC (15, 2) DEFAULT ((0)),
	Importe_Aumento      NUMERIC (15, 2) DEFAULT ((0)),
	Denom_billete_1_aum  VARCHAR (7) DEFAULT ('' ''),
	Cant_billete_1_aum   VARCHAR (7) DEFAULT ('' ''),
	Denom_billete_2_aum  VARCHAR (7) DEFAULT ('' ''),
	Cant_billete_2_aum   VARCHAR (7) DEFAULT ('' ''),
	Denom_billete_3_aum  VARCHAR (7) DEFAULT ('' ''),
	Cant_billete_3_aum   VARCHAR (7) DEFAULT ('' ''),
	Denom_billete_4_aum  VARCHAR (7) DEFAULT ('' ''),
	Cant_billete_4_aum   VARCHAR (7) DEFAULT ('' ''),
	Importe_Pago         NUMERIC (15, 2) DEFAULT ((0)),
	TZ_LOCK              NUMERIC (15) DEFAULT ((0)) NOT NULL,
	CONSTRAINT PK_ITF_NORTE_DET PRIMARY KEY (ID, ID_CABEZAL)
	)
')

