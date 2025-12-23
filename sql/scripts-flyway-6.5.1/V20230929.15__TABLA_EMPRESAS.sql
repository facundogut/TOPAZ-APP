EXECUTE('
IF OBJECT_ID (''dbo.EMPRESAS'') IS NOT NULL
	DROP TABLE dbo.EMPRESAS
')

EXECUTE('
CREATE TABLE EMPRESAS
      (
      TZ_LOCK             NUMERIC (15) DEFAULT (0),
      EMPRESA             NUMERIC (4) DEFAULT (0) NOT NULL,
      RAZAOSOCIAL         VARCHAR (120) DEFAULT ('' ''),
      NOMEFANTASIA        VARCHAR (60) DEFAULT ('' ''),
      TIPO_EMPRESA        NUMERIC (5) DEFAULT (0),
      CNPJ_EMPRESA        VARCHAR (20) DEFAULT ('' ''),
      SIT_EMPRESA         VARCHAR (1) DEFAULT ('' ''),
      DATA_INI_ATIV       DATE,
      DATA_CADASTRO       DATE,
      TIPO_LOG            VARCHAR (36),
      LOGRADOURO          VARCHAR (100) DEFAULT ('' ''),
      NUMERO              VARCHAR (10) DEFAULT ('' ''),
      COMPLEMENTO         VARCHAR (100) DEFAULT (''''),
      BAIRRO              VARCHAR (72) DEFAULT ('' ''),
      CIDADE              VARCHAR (72) DEFAULT ('' ''),
      UF                  VARCHAR (2) DEFAULT ('' ''),
      CEP                 VARCHAR (8) DEFAULT ('' ''),
      DDD_FIXO            NUMERIC (3),
      TEL_FIXO            NUMERIC (9),
      HORA_INCLUSAO       VARCHAR (8),
      DATA_INCLUSAO       DATE,
      USER_INCLUSAO       VARCHAR (8),
      HORA_ULT_MOD        VARCHAR (8),
      DATA_ULT_MOD        DATE,
      USER_ULT_MOD        VARCHAR (8),
      AG_BANCO            VARCHAR (4),
      NRO_CONTA           VARCHAR (12),
      EMPRESA_SUPERIOR    NUMERIC (4),
      DATA_CONSTITUICAO   DATE,
      SUC_TPZ_CTA_TRANSIT NUMERIC (10),
      DESCRICAO           VARCHAR (60),
      CONSTRAINT PK_EMPRESAS120417 PRIMARY KEY (EMPRESA)
      )
')

EXECUTE('
alter table MOVIMIENTOS_CONTABLES add default 0 for EMPRESA

')