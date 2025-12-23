IF OBJECT_ID ('dbo.ITF_AGIP_PADRON_IMPUESTOS_AUX') IS NOT NULL
	DROP TABLE dbo.ITF_AGIP_PADRON_IMPUESTOS_AUX
GO

CREATE TABLE dbo.ITF_AGIP_PADRON_IMPUESTOS_AUX
	(
	  ID                   INT IDENTITY NOT NULL
	, fecha_public         CHAR (8) NULL
	, fecha_vig_desde      CHAR (8) NULL
	, fecha_vig_hasta      CHAR (8) NULL
	, cuit                 CHAR (11) NULL
	, Tipo_Contr_Insc      CHAR (1) NULL
	, Marca_alta_sujeto    CHAR (1) NULL
	, Marca_alicuota       CHAR (1) NULL
	, Alicuota_Percepcion  VARCHAR (20) NULL
	, Alicuota_Retencion   VARCHAR (20) NULL
	, Nro_Grupo_Percepcion CHAR (2) NULL
	, Nro_Grupo_Retencion  CHAR (2) NULL
	, Razon_Social         VARCHAR (60) NULL
	, AFECTA_CLIENTE       CHAR (1) NULL
	, msj_error            VARCHAR (1000) NULL
	, CONSTRAINT PK_AGIP_PADRON_AUX PRIMARY KEY (ID)
	)
GO