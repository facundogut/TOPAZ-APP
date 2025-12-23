Execute('CREATE NONCLUSTERED INDEX TJD_ITF_TARJETAS_CUENTAS_NroTarjeta_IDX ON dbo.TJD_ITF_TARJETAS_CUENTAS (  NroTarjeta )')

Execute('CREATE NONCLUSTERED INDEX TJD_ITF_TARJETAS_COMPLETAS_Nro_Raiz_Miembro_Nro_VersionIDX ON dbo.TJD_ITF_TARJETAS_COMPLETAS (  Nro_Raiz , Miembro , Nro_Version );')

Execute('CREATE NONCLUSTERED INDEX TJD_REL_TARJETA_CUENTA_ID_TARJETA_IDX ON dbo.TJD_REL_TARJETA_CUENTA (ID_TARJETA);')

Execute('DROP TABLE IF EXISTS dbo.RMFULL_ITF_PERSONAS;

CREATE TABLE dbo.RMFULL_ITF_PERSONAS (
	NroDocumento numeric(9,0) NOT NULL,
	TipoDocumento varchar(3) COLLATE Modern_Spanish_CI_AS NOT NULL,
	GrupoOperadorModif numeric(6,0) NULL,
	TimestampModif numeric(16,0) NULL,
	Auditoria_Alta numeric(6,0) NULL,
	Timestamp_Alta numeric(16,0) NULL,
	GrupoOperadorConfir numeric(6,0) NULL,
	TimestampConfir numeric(16,0) NULL,
	Apellido varchar(15) COLLATE Modern_Spanish_CI_AS NULL,
	Nombre varchar(15) COLLATE Modern_Spanish_CI_AS NULL,
	Sexo varchar(1) COLLATE Modern_Spanish_CI_AS NULL,
	"Código_CUIL" numeric(2,0) NULL,
	NroDocumentoCuil numeric(9,0) NULL,
	DigVerificadorCuil numeric(1,0) NULL,
	Ocupación varchar(20) COLLATE Modern_Spanish_CI_AS NULL,
	FechaNacimiento numeric(8,0) NULL,
	EstadoCivil varchar(1) COLLATE Modern_Spanish_CI_AS NULL,
	Nacionalidad varchar(15) COLLATE Modern_Spanish_CI_AS NULL,
	Observaciones varchar(30) COLLATE Modern_Spanish_CI_AS NULL,
	CONSTRAINT PK_RMFULL_ITF_PERSONAS PRIMARY KEY (NroDocumento,TipoDocumento)
);')

Execute('DROP TABLE IF EXISTS dbo.RMFULL_ITF_PERSONAS_CONTACTO;

CREATE TABLE dbo.RMFULL_ITF_PERSONAS_CONTACTO (
	Tipo_Doc char(3) COLLATE Modern_Spanish_CI_AS NOT NULL,
	Num_Doc numeric(9,0) NOT NULL,
	Grupo_Oper_Alta numeric(6,0) NULL,
	Timestamp_Alta numeric(16,0) NULL,
	Grupo_Oper_Modif numeric(6,0) NULL,
	Timestamp_Modif numeric(16,0) NULL,
	Calle_Contacto varchar(60) COLLATE Modern_Spanish_CI_AS NULL,
	Num_Contacto varchar(10) COLLATE Modern_Spanish_CI_AS NULL,
	Piso_Contacto varchar(2) COLLATE Modern_Spanish_CI_AS NULL,
	Depto_Contacto varchar(3) COLLATE Modern_Spanish_CI_AS NULL,
	Provincia_Contacto varchar(30) COLLATE Modern_Spanish_CI_AS NULL,
	Localidad_Contacto varchar(40) COLLATE Modern_Spanish_CI_AS NULL,
	Tel_Personal_Area varchar(4) COLLATE Modern_Spanish_CI_AS NULL,
	Tel_Personal_Num varchar(10) COLLATE Modern_Spanish_CI_AS NULL,
	Tel_Laboral_Area varchar(4) COLLATE Modern_Spanish_CI_AS NULL,
	Tel_Laboral_Num varchar(10) COLLATE Modern_Spanish_CI_AS NULL,
	Tel_Laboral_Interno varchar(5) COLLATE Modern_Spanish_CI_AS NULL,
	Tel_Celular_Area varchar(4) COLLATE Modern_Spanish_CI_AS NULL,
	Tel_Celular_Num varchar(10) COLLATE Modern_Spanish_CI_AS NULL,
	Email varchar(100) COLLATE Modern_Spanish_CI_AS NULL,
	CONSTRAINT PK_RMFULL_ITF_PERSONAS_CONTACTO PRIMARY KEY (Tipo_Doc,Num_Doc)
);')

Execute('DROP TABLE IF EXISTS dbo.RMFULL_ITF_TARJETAS_COMPLETAS;

CREATE TABLE dbo.RMFULL_ITF_TARJETAS_COMPLETAS (
	Nro_Tarjeta varchar(19) COLLATE Modern_Spanish_CI_AS NOT NULL,
	Tipo_Doc varchar(3) COLLATE Modern_Spanish_CI_AS NULL,
	Nro_Doc numeric(9,0) NULL,
	Nro_Raiz varchar(19) COLLATE Modern_Spanish_CI_AS NULL,
	Grp_Op_Modif numeric(6,0) NULL,
	Timestamp_Modif numeric(16,0) NULL,
	Aud_Alta numeric(6,0) NULL,
	Timestamp_Alta numeric(16,0) NULL,
	Grp_Op_Conf numeric(6,0) NULL,
	Timestamp_Conf numeric(16,0) NULL,
	Miembro numeric(1,0) NULL,
	Nro_Version numeric(1,0) NULL,
	Dig_Verif numeric(1,0) NULL,
	Cat_Comision numeric(2,0) NULL,
	Cod_Lim_Debito numeric(2,0) NULL,
	Cod_Lim_Credito numeric(2,0) NULL,
	Tipo_Tarj varchar(2) COLLATE Modern_Spanish_CI_AS NULL,
	Meses_Vigencia numeric(3,0) NULL,
	Fec_Vencimiento numeric(4,0) NULL,
	Estado varchar(1) COLLATE Modern_Spanish_CI_AS NULL,
	Cant_Cuentas_Asociadas numeric(2,0) NULL,
	Ref_Cliente varchar(12) COLLATE Modern_Spanish_CI_AS NULL,
	Cant_Pin_Impresos numeric(2,0) NULL,
	Marca_Pin varchar(1) COLLATE Modern_Spanish_CI_AS NULL,
	Fec_Emi_Pin varchar(8) COLLATE Modern_Spanish_CI_AS NULL,
	Fec_Ent_Pin varchar(8) COLLATE Modern_Spanish_CI_AS NULL,
	Cant_Plasticos_Imp numeric(2,0) NULL,
	Marca_Plastico varchar(1) COLLATE Modern_Spanish_CI_AS NULL,
	Fec_Emi_Plast varchar(8) COLLATE Modern_Spanish_CI_AS NULL,
	Fec_Ent_Plast varchar(8) COLLATE Modern_Spanish_CI_AS NULL,
	Cod_Denuncia varchar(16) COLLATE Modern_Spanish_CI_AS NULL,
	Grp_Afinidad varchar(4) COLLATE Modern_Spanish_CI_AS NULL,
	CONSTRAINT PK_RMFULL_ITF_TARJETAS_COMPLETAS PRIMARY KEY (Nro_Tarjeta)
);')

Execute('DROP TABLE IF EXISTS dbo.RMFULL_ITF_TARJETAS_CUENTAS;

CREATE TABLE dbo.RMFULL_ITF_TARJETAS_CUENTAS (
	NroTarjeta varchar(19) COLLATE Modern_Spanish_CI_AS NOT NULL,
	Cuenta numeric(2,0) NOT NULL,
	Tipo_Cuenta numeric(2,0) NULL,
	Numero_Cuenta varchar(19) COLLATE Modern_Spanish_CI_AS NULL,
	Estado_Cuenta varchar(1) COLLATE Modern_Spanish_CI_AS NULL,
	CONSTRAINT PK_RMFULL_ITF_TARJETAS_CUENTAS PRIMARY KEY (NroTarjeta,Cuenta)
);')

Execute('DROP TABLE IF EXISTS dbo.RMFULL_ITF_TARJETA_RAIZ;

CREATE TABLE dbo.RMFULL_ITF_TARJETA_RAIZ (
	NumRaiz varchar(19) COLLATE Modern_Spanish_CI_AS NOT NULL,
	Prefijo varchar(11) COLLATE Modern_Spanish_CI_AS NULL,
	NumCliente numeric(18,0) NULL,
	Sucursal int NULL,
	Producto varchar(4) COLLATE Modern_Spanish_CI_AS NULL,
	EstadoRaiz varchar(1) COLLATE Modern_Spanish_CI_AS NULL,
	TipoCuentaPrincipal varchar(2) COLLATE Modern_Spanish_CI_AS NULL,
	NumCuentaPrincipal varchar(19) COLLATE Modern_Spanish_CI_AS NULL,
	TipoDocApoderado varchar(3) COLLATE Modern_Spanish_CI_AS NULL,
	NumDocApoderado numeric(18,0) NULL,
	Apellido varchar(15) COLLATE Modern_Spanish_CI_AS NULL,
	Nombre varchar(15) COLLATE Modern_Spanish_CI_AS NULL,
	CodEnte int NULL,
	CantMiembros int NULL,
	DomicilioPin char(1) COLLATE Modern_Spanish_CI_AS NULL,
	DomicilioPlastico char(1) COLLATE Modern_Spanish_CI_AS NULL,
	CalleParticular varchar(45) COLLATE Modern_Spanish_CI_AS NULL,
	NumParticular varchar(5) COLLATE Modern_Spanish_CI_AS NULL,
	PisoParticular varchar(2) COLLATE Modern_Spanish_CI_AS NULL,
	DeptoParticular varchar(3) COLLATE Modern_Spanish_CI_AS NULL,
	LocalidadParticular varchar(20) COLLATE Modern_Spanish_CI_AS NULL,
	CodPostalParticular varchar(15) COLLATE Modern_Spanish_CI_AS NULL,
	CodProvinciaParticular varchar(2) COLLATE Modern_Spanish_CI_AS NULL,
	TelParticular varchar(15) COLLATE Modern_Spanish_CI_AS NULL,
	CalleLaboral varchar(45) COLLATE Modern_Spanish_CI_AS NULL,
	NumLaboral varchar(5) COLLATE Modern_Spanish_CI_AS NULL,
	PisoLaboral varchar(2) COLLATE Modern_Spanish_CI_AS NULL,
	DeptoLaboral varchar(3) COLLATE Modern_Spanish_CI_AS NULL,
	LocalidadLaboral varchar(20) COLLATE Modern_Spanish_CI_AS NULL,
	CodPostalLaboral varchar(15) COLLATE Modern_Spanish_CI_AS NULL,
	CodProvinciaLaboral varchar(2) COLLATE Modern_Spanish_CI_AS NULL,
	TelLaboral varchar(15) COLLATE Modern_Spanish_CI_AS NULL,
	GrupoOperadorModif int NULL,
	TimestampModif numeric(16,0) NULL,
	GrupoOperadorAlta int NULL,
	TimestampAlta numeric(16,0) NULL,
	GrupoOperadorConfir int NULL,
	TimestampConfir numeric(16,0) NULL,
	CONSTRAINT PK__RMFULL_ITF___CDB1AB752FA06E7A PRIMARY KEY (NumRaiz)
);')

Execute('DROP TABLE IF EXISTS dbo.RMFULL_TARJETAS;

CREATE TABLE dbo.RMFULL_TARJETAS (
	JTS_OID_GTOS numeric(10,0) DEFAULT 0 NULL,
	TIPO_TARJETA varchar(2) COLLATE Modern_Spanish_CI_AS DEFAULT '' '' NULL,
	FECHA_PRIMER_USO datetime NULL,
	FECHA_ULTIMO_USO datetime NULL,
	ID_TARJETA varchar(19) COLLATE Modern_Spanish_CI_AS DEFAULT '' '' NOT NULL,
	NRO_CLIENTE numeric(12,0) DEFAULT 0 NULL,
	TITULARIDAD varchar(1) COLLATE Modern_Spanish_CI_AS DEFAULT '' '' NULL,
	ESTADO varchar(1) COLLATE Modern_Spanish_CI_AS DEFAULT '' '' NULL,
	FECHA_ENTREGA datetime NULL,
	VENCIMIENTO datetime NULL,
	NOMBRE_TARJETA varchar(30) COLLATE Modern_Spanish_CI_AS DEFAULT '' '' NULL,
	SUCURSAL numeric(5,0) DEFAULT 0 NULL,
	ID_TARJETA_TITULAR varchar(19) COLLATE Modern_Spanish_CI_AS DEFAULT '' '' NULL,
	NRO_PERSONA numeric(12,0) DEFAULT 0 NULL,
	COD_PLAN numeric(5,0) DEFAULT 0 NULL,
	ID_CONVENIO numeric(6,0) DEFAULT 0 NULL,
	CODIGO_CLIENTE_EMPRESA numeric(12,0) DEFAULT 0 NULL,
	COD_PAQUETE numeric(5,0) DEFAULT 0 NULL,
	STANDARD varchar(1) COLLATE Modern_Spanish_CI_AS DEFAULT '' '' NULL,
	NOMBREEMPRESA varchar(27) COLLATE Modern_Spanish_CI_AS DEFAULT '' '' NULL,
	OBSERVACIONES varchar(100) COLLATE Modern_Spanish_CI_AS DEFAULT '' '' NULL,
	FECHAMODIFICACION datetime NULL,
	CANAL varchar(1) COLLATE Modern_Spanish_CI_AS DEFAULT '' '' NULL,
	ID_TARJETA_BASE numeric(19,0) DEFAULT 0 NULL,
	ORIGEN varchar(1) COLLATE Modern_Spanish_CI_AS DEFAULT '' '' NULL,
	NUM_ENVIO numeric(10,0) DEFAULT 0 NULL,
	TZ_LOCK numeric(15,0) DEFAULT 0 NOT NULL,
	REIMPRESION varchar(1) COLLATE Modern_Spanish_CI_AS NULL,
	MOTIVO_REIMPRESION varchar(1) COLLATE Modern_Spanish_CI_AS NULL,
	NUM_VERSION varchar(1) COLLATE Modern_Spanish_CI_AS NULL,
	DIGITO_VERIFICADOR varchar(1) COLLATE Modern_Spanish_CI_AS NULL,
	LIMITE_CREDITO varchar(2) COLLATE Modern_Spanish_CI_AS NULL,
	LIMITE_DEBITO varchar(2) COLLATE Modern_Spanish_CI_AS NULL,
	PERMISO varchar(3) COLLATE Modern_Spanish_CI_AS NULL,
	CONSTRAINT PK_RMFULL_TARJETAS_01 PRIMARY KEY (ID_TARJETA)
);')

Execute('DROP TABLE IF EXISTS dbo.RMFULL_REL_TARJETA_CUENTA;

CREATE TABLE dbo.RMFULL_REL_TARJETA_CUENTA (
	TZ_LOCK numeric(15,0) DEFAULT 0 NOT NULL,
	ID_TARJETA varchar(19) COLLATE Modern_Spanish_CI_AS DEFAULT '' '' NOT NULL,
	SALDO_JTS_OID numeric(15,0) DEFAULT 0 NOT NULL,
	TIPO_CUENTA numeric(2,0) DEFAULT 0 NULL,
	PRIORITARIA numeric(1,0) DEFAULT 0 NULL,
	PRODUCTO numeric(5,0) DEFAULT 0 NOT NULL,
	CUENTA numeric(12,0) NULL,
	MONEDA numeric(4,0) DEFAULT 0 NOT NULL,
	SUCURSAL numeric(5,0) DEFAULT 0 NOT NULL,
	ORDINAL_PREFERENCIA numeric(2,0) NULL,
	ESTADO varchar(2) COLLATE Modern_Spanish_CI_AS NULL,
	CUENTA_PBF varchar(19) COLLATE Modern_Spanish_CI_AS NULL,
	CONSTRAINT PK_RMFULL_REL_TARJETA_CUENTA PRIMARY KEY (ID_TARJETA,SALDO_JTS_OID)
);')