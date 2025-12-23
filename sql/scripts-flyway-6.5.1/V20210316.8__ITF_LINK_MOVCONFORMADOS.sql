EXECUTE('DROP TABLE IF EXISTS dbo.ITF_LINK_MOVCONFORMADOS;')
EXECUTE('
CREATE TABLE dbo.ITF_LINK_MOVCONFORMADOS
	(
	tipo_registro  VARCHAR (20),
	banco          INT,
	tipo_cuenta    VARCHAR (50),
	moneda         VARCHAR (2),
	cuenta         VARCHAR (50),
	cbu            VARCHAR (50),
	fecha_mov      DATE,
	fecha_valor    DATE,
	deb_cred       VARCHAR (1),
	monto          VARCHAR (20),
	secuencia      VARCHAR (10),
	referencia     VARCHAR (20),
	fecha_proceso  DATE,
	depositante    VARCHAR (200),
	jts_oid        NUMERIC (15),
	secuencia_gral NUMERIC (15),
	cant_registros VARCHAR (20)
	);')


