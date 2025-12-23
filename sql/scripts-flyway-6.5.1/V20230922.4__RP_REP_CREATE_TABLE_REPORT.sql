
Execute('
DROP TABLE IF EXISTS ITF_RP_REPORTE;

CREATE TABLE ITF_RP_REPORTE (
	ID INT IDENTITY,
	empresa VARCHAR(40),
	fechaProceso VARCHAR(10),
	nombreConvenio VARCHAR(40),
	nombreArchivo VARCHAR(12), 
	fechaRendicion VARCHAR(10),
	cuentaRecaudacion NUMERIC(10),
	fechaRecaudacion VARCHAR(10),
	totalRecaudado NUMERIC(15,2),
	cantComprobantes NUMERIC(7),
	impComision NUMERIC(15,2),	
	IVAsobreComisiones NUMERIC(15,2),
   	totalRetenciones NUMERIC(15,2), 	
	cargoEspecifico NUMERIC(15,2),	
	importeRendido  NUMERIC(15,2)	

	CONSTRAINT PK_REP_brr PRIMARY KEY (ID)
)

')