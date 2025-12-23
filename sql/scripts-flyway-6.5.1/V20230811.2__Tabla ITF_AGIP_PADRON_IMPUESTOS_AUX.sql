EXECUTE('
IF OBJECT_ID (''dbo.ITF_AGIP_PADRON_IMPUESTOS_AUX'') IS NOT NULL
	DROP TABLE dbo.ITF_AGIP_PADRON_IMPUESTOS_AUX
')

EXECUTE('
CREATE TABLE dbo.ITF_AGIP_PADRON_IMPUESTOS_AUX
	(
	ID                   INT IDENTITY NOT NULL,
	fecha_public         VARCHAR (90),
	fecha_vig_desde      VARCHAR (90),
	fecha_vig_hasta      VARCHAR (90),
	cuit                 VARCHAR (90),
	Tipo_Contr_Insc      VARCHAR (90),
	Marca_alta_sujeto    VARCHAR (90),
	Marca_alicuota       VARCHAR (90),
	Alicuota_Percepcion  VARCHAR (10),
	Alicuota_Retencion   VARCHAR (10),
	Nro_Grupo_Percepcion VARCHAR (90),
	Nro_Grupo_Retencion  VARCHAR (90),
	Razon_Social         VARCHAR (90),
	AFECTA_CLIENTE       VARCHAR (1),
	msj_error            VARCHAR (1000),
	CONSTRAINT PK_AGIP_PADRON_AUX PRIMARY KEY (ID)
	)
')