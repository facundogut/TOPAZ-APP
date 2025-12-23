
Execute('DROP TABLE IF EXISTS dbo.ITF_INTERMEDIA_COELSA_CHEQUES')

Execute('
CREATE TABLE dbo.ITF_INTERMEDIA_COELSA_CHEQUES
	(
	TipoRegistro  NUMERIC (2) NOT NULL,
	ConError      CHAR (1),
	Importe       NUMERIC (12),
	Prioridad     CHAR (2),
	Lote          NUMERIC (3),
	CantLote      NUMERIC (3),
	CantRegistro  NUMERIC (4),
	InfoAdicional CHAR (2),
	ControlTotal  NUMERIC (10)
	)

')
