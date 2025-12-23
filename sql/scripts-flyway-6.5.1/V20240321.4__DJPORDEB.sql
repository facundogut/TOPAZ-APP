Execute('DROP TABLE dbo.OrdenDebitoLote_bitacora;

CREATE TABLE dbo.OrdenDebitoLote_bitacora
(
	id_bitacora BIGINT PRIMARY KEY IDENTITY(1,1) NOT NULL,
    fecha_proceso DATETIME NOT NULL,
    fecha_reloj DATETIME NOT NULL,
    id BIGINT NOT NULL,
    idRegistro BIGINT NULL,
    codigoServicio BIGINT NULL,
    nombreServicio VARCHAR(10) NULL,
    tipoDocumento VARCHAR(4) NULL,
    numeroDocumento BIGINT NULL,
    cuit BIGINT NULL,
    apellidoNombre VARCHAR(30) NULL,
    cbu VARCHAR(22) NULL,
    codigoCliente NUMERIC(15,0) NULL,
    clientePagador VARCHAR(22) NULL,
    prestacion VARCHAR(22) NULL,
    convenio NUMERIC(15,0) NULL,
    referenciaDebito BIGINT NULL,
    fechaPrimerVencimiento DATETIME2 NULL,
    importePrimerVencimiento DECIMAL(15,2) NULL,
    fechaSegundoVencimiento DATETIME2 NULL,
    importeSegundoVencimiento DECIMAL(15,2) NULL, 
	ESTADO VARCHAR(2) NULL,
	TIPO_ORDEN VARCHAR(6) NULL,
	MONEDA NUMERIC(4,0) NULL,
    idLote VARCHAR(50) NOT NULL,
    codigoError BIGINT NULL,
    descripcionError VARCHAR(255) NULL,
    fechaDeCarga DATETIME2 NULL
);')