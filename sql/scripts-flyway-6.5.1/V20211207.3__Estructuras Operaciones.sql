EXECUTE('
CREATE TABLE ITF_INTERMEDIA_LOTIPAGOS
	(
	TZ_LOCK              NUMERIC (15) NOT NULL,
	TipoRegistro         NUMERIC (2) NOT NULL,
	ID				     NUMERIC(15) NOT NULL,
	IdLotipago           Numeric (5) ,
	FechaProceso         date ,
	CampoAuxCabezal	     VARCHAR (105),
	NroConvenio			 NUMERIC(12) ,
	NroAgencia			 NUMERIC(5) ,
	FechaPago			 VARCHAR(8) ,
	ImporteAbonado		 NUMERIC(15,2),
	CodigoBarras		 VARCHAR(60),
	CampoAuxDetalle      VARCHAR(20),
	CantidadRegistros	 NUMERIC(12),
	SumImporteAbonado 	 NUMERIC(15,2),
	CampoAuxPie			 VARCHAR(90),
	NomArchivo			 VARCHAR(30),
	ID_CABEZAL			 NUMERIC(6),
	ConError			 CHAR(1)
	
	
	CONSTRAINT PK_ITF_INTERMEDIA_LOTIPAGOS PRIMARY KEY (Id,TipoRegistro)
	)
')	