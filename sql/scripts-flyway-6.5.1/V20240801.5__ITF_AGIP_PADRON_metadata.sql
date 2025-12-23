IF OBJECT_ID ('dbo.ITF_AGIP_PADRON') IS NOT NULL
	DROP TABLE dbo.ITF_AGIP_PADRON


CREATE TABLE dbo.ITF_AGIP_PADRON
	(
	  Fecha_Vigencia_Desde DATETIME NULL
	, Fecha_Publicacion    DATETIME NOT NULL
	, Fecha_Vigencia_Hasta DATETIME NULL
	, CUIT                 NUMERIC (11) NOT NULL
	, Razon_Social         VARCHAR (60) NULL
	, Tipo_Contr_Insc      VARCHAR (1) NULL
	, Marca_alta_sujeto    VARCHAR (1) NULL
	, Alicuota_Percepcion  NUMERIC (6, 2) NULL
	, Alicuota_Retencion   NUMERIC (6, 2) NULL
	, Nro_Grupo_Percepcion VARCHAR (2) NULL
	, Marca_alicuota       VARCHAR (1) NULL
	, Nro_Grupo_Retencion  VARCHAR (2) NULL
	, CONSTRAINT PK_ITF_AGIP_PADRON_01 PRIMARY KEY (CUIT, Fecha_Publicacion)
	)

