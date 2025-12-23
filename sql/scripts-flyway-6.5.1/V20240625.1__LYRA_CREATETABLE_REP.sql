
Execute('
DROP TABLE IF EXISTS ITF_LYRA_REC_REPORTE
CREATE TABLE ITF_LYRA_REC_REPORTE (
	shopkey VARCHAR(20), 
	shopname VARCHAR(20),
	convenio INT, 
	rechazos INT, 
	importeRechazado NUMERIC(15,2),
	aceptado INT,
	importeAceptado NUMERIC(15,2)
CONSTRAINT PK_LYRA_REP PRIMARY KEY (shopkey)
)

')