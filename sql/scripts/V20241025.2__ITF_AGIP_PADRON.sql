EXECUTE('
IF OBJECT_ID (''dbo.ITF_AGIP_PADRON'') IS NOT NULL
   DROP TABLE dbo.ITF_AGIP_PADRON
')

EXECUTE('
CREATE TABLE dbo.ITF_AGIP_PADRON
	(
	Fecha_Vigencia_Desde DATETIME,
	Fecha_Publicacion    DATETIME,
	Fecha_Vigencia_Hasta DATETIME,
	CUIT                 NUMERIC,
	Razon_Social         VARCHAR (60),
	Tipo_Contr_Insc      VARCHAR (1),
	Marca_alta_sujeto    VARCHAR (1),
	Alicuota_Percepcion  NUMERIC,
	Alicuota_Retencion   NUMERIC,
	Nro_Grupo_Percepcion VARCHAR (2),
	Marca_alicuota       VARCHAR (1),
	Nro_Grupo_Retencion  VARCHAR (2),
	CONSTRAINT PK_ITF_AGIP_PADRON_01 PRIMARY KEY (CUIT, Fecha_Vigencia_Desde)
	);
')