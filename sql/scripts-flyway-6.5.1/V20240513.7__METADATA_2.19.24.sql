Execute('

DROP TABLE IF EXISTS dbo.ITF_RP_SECHEEP_AUX;

CREATE TABLE dbo.ITF_RP_SECHEEP_AUX
	(
	  convpadre INT,
	  canal INT, 
	  codigoempresa INT, 
	  fechacarga varchar(10), 
	  totcobranzas INT, 
	  totimporte NUMERIC(15,2), 
	  CONSTRAINT SECHPK PRIMARY KEY (convpadre,canal,codigoempresa,fechacarga)
	)

')