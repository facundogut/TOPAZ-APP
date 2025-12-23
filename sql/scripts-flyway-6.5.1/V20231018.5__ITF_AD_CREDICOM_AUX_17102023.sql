EXECUTE('
IF OBJECT_ID (''dbo.ITF_AD_CREDICOM_AUX'') IS NOT NULL
	DROP TABLE dbo.ITF_AD_CREDICOM_AUX

CREATE TABLE dbo.ITF_AD_CREDICOM_AUX
	(
	ID                      NUMERIC (15) NOT NULL,
	Cod_Acreditacion        VARCHAR (2) DEFAULT ('' ''),
	Nro_Cuenta_Acreditacion VARCHAR (11) DEFAULT ('' ''),
	Cod_Tipo_Mov            VARCHAR (3) DEFAULT ('' ''),
	Fecha_Acreditacion      VARCHAR (10) DEFAULT ('' ''),
	Nro_Comprobante         VARCHAR (9) DEFAULT ('' ''),
	Importe_Acreditacion    VARCHAR (13) DEFAULT ('' ''),
	Cod_Admin               VARCHAR (1) DEFAULT ('' ''),
	Cod_Moneda              VARCHAR (1) DEFAULT ('' ''),
	Suc_Cuenta              VARCHAR (5) DEFAULT ('' ''),
	Nombre_Cliente          VARCHAR (30) DEFAULT ('' ''),
	Num_CUIT                VARCHAR (11) DEFAULT ('' ''),
	Num_Comercion           VARCHAR (20) DEFAULT ('' ''),
	CBU                     VARCHAR (22) DEFAULT ('' ''),
	Id_Univoco              VARCHAR (15) DEFAULT ('' ''),
	Cod_Respuesta           VARCHAR (3) DEFAULT ('' ''),
	Descripcion             VARCHAR (148) DEFAULT ('' ''),
	DATO_OBSOLETO           VARCHAR (1),
	CONSTRAINT PK_ITF_AD_CREDICOM_AUX_01 PRIMARY KEY (ID)
	)
')
