Execute('CREATE TABLE dbo.ITF_LINK_TRK
(
	Linea varchar (1649)
)')

Execute('
CREATE TABLE TJD_ITF_TARJETA_RAIZ (
    NumRaiz VARCHAR(19) PRIMARY KEY,
    Prefijo VARCHAR(11),
    NumCliente Numeric(18,0),
    Sucursal INT,
    Producto VARCHAR(4),
    EstadoRaiz VARCHAR(1),
    TipoCuentaPrincipal VARCHAR(2),
    NumCuentaPrincipal VARCHAR(19),
    TipoDocApoderado VARCHAR(3),
    NumDocApoderado Numeric(18,0),
    Apellido VARCHAR(15),
    Nombre VARCHAR(15),
    CodEnte INT,
    CantMiembros INT,
    DomicilioPin CHAR(1),
    DomicilioPlastico CHAR(1),
    CalleParticular VARCHAR(45),
    NumParticular VARCHAR(5),
    PisoParticular VARCHAR(2),
    DeptoParticular VARCHAR(3),
    LocalidadParticular VARCHAR(20),
    CodPostalParticular VARCHAR(15),
    CodProvinciaParticular VARCHAR(2),
    TelParticular VARCHAR(15),
    CalleLaboral VARCHAR(45),
    NumLaboral VARCHAR(5),
    PisoLaboral VARCHAR(2),
    DeptoLaboral VARCHAR(3),
    LocalidadLaboral VARCHAR(20),
    CodPostalLaboral VARCHAR(15),
    CodProvinciaLaboral VARCHAR(2),
    TelLaboral VARCHAR(15),
    GrupoOperadorModif INT,
    TimestampModif NUMERIC(16),
    GrupoOperadorAlta INT,
    TimestampAlta NUMERIC(16),
    GrupoOperadorConfir INT,
    TimestampConfir NUMERIC(16)
);')

Execute('CREATE TABLE TJD_ITF_PERSONAS (
	NroDocumento  NUMERIC(9),
	TipoDocumento VARCHAR(3),
    GrupoOperadorModif NUMERIC(6),
    TimestampModif NUMERIC(16),
    Auditoria_Alta NUMERIC(6),
    Timestamp_Alta NUMERIC(16),
    GrupoOperadorConfir NUMERIC(6),
    TimestampConfir NUMERIC(16),    
    Apellido VARCHAR(15),
    Nombre VARCHAR(15),
    Sexo VARCHAR(1),
    Código_CUIL NUMERIC(2),
    NroDocumentoCuil NUMERIC(9),
    DigVerificadorCuil NUMERIC(1),
    Ocupación VARCHAR(20),
    FechaNacimiento NUMERIC(8),
    EstadoCivil VARCHAR(1),
    Nacionalidad VARCHAR(15),
    Observaciones VARCHAR(30)
	CONSTRAINT PK_TJD_ITF_PERSONAS PRIMARY KEY (NroDocumento,TipoDocumento)
);')											 
Execute('
CREATE TABLE dbo.TJD_ITF_TARJETAS_COMPLETAS
(
    Nro_Tarjeta            VARCHAR (19) NOT NULL,
    Tipo_Doc               VARCHAR (3) NULL,
    Nro_Doc                NUMERIC (9) NULL,
    Nro_Raiz               VARCHAR (19) NULL,
    Grp_Op_Modif           NUMERIC (6) NULL,
    Timestamp_Modif        NUMERIC (16) NULL,
    Aud_Alta               NUMERIC (6) NULL,
    Timestamp_Alta         NUMERIC (16) NULL,
    Grp_Op_Conf            NUMERIC (6) NULL,
    Timestamp_Conf         NUMERIC (16) NULL,
    Miembro                NUMERIC (1) NULL,
    Nro_Version            NUMERIC (1) NULL,
    Dig_Verif              NUMERIC (1) NULL,
    Cat_Comision           NUMERIC (2) NULL,
    Cod_Lim_Debito         NUMERIC (2) NULL,
    Cod_Lim_Credito        NUMERIC (2) NULL,
    Tipo_Tarj              VARCHAR (2) NULL,
    Meses_Vigencia         NUMERIC (3) NULL,
    Fec_Vencimiento        NUMERIC (4) NULL,
    Estado                 VARCHAR (1) NULL,
    Cant_Cuentas_Asociadas NUMERIC (2) NULL,
    Ref_Cliente            VARCHAR (12) NULL,
    Cant_Pin_Impresos      NUMERIC (2) NULL,
    Marca_Pin              VARCHAR (1) NULL,
    Fec_Emi_Pin            VARCHAR (8) NULL,
    Fec_Ent_Pin            VARCHAR (8) NULL,
    Cant_Plasticos_Imp     NUMERIC (2) NULL,
    Marca_Plastico         VARCHAR (1) NULL,
    Fec_Emi_Plast          VARCHAR (8) NULL,
    Fec_Ent_Plast          VARCHAR (8) NULL,
    Cod_Denuncia           VARCHAR (16) NULL,
    Grp_Afinidad           VARCHAR (4) NULL,
    PRIMARY KEY (Nro_Tarjeta),
    CONSTRAINT FK_TJD_ITF_TARJETA_RAIZ FOREIGN KEY (Nro_Raiz)  REFERENCES dbo.TJD_ITF_TARJETA_RAIZ (NumRaiz)   ON DELETE CASCADE,
    CONSTRAINT FK_TJD_ITF_TARJETAS_COMPLETAS_TJD_ITF_PERSONAS FOREIGN KEY (Nro_Doc, Tipo_Doc) REFERENCES dbo.TJD_ITF_PERSONAS (NroDocumento, TipoDocumento) ON DELETE CASCADE
);')

Execute('CREATE TABLE TJD_ITF_PERSONAS_CONTACTO (
    Tipo_Doc char(3),
    Num_Doc numeric(9),
    Grupo_Oper_Alta numeric(6),
    Timestamp_Alta numeric(16),
    Grupo_Oper_Modif numeric(6),
    Timestamp_Modif numeric(16),
    Calle_Contacto varchar(60),
    Num_Contacto varchar(10),
    Piso_Contacto varchar(2),
    Depto_Contacto varchar(3),
    Provincia_Contacto varchar(30),
    Localidad_Contacto varchar(40),
    Tel_Personal_Area varchar(4),
    Tel_Personal_Num varchar(10),
    Tel_Laboral_Area varchar(4),
    Tel_Laboral_Num varchar(10),
    Tel_Laboral_Interno varchar(5),
    Tel_Celular_Area varchar(4),
    Tel_Celular_Num varchar(10),
    Email varchar(100)
	CONSTRAINT PK_TJD_ITF_PERSONAS_CONTACTO PRIMARY KEY (Tipo_Doc,Num_Doc)
);')

Execute('CREATE TABLE TJD_ITF_TARJETAS_CUENTAS (
  NroTarjeta varchar(19),
  Cuenta NUMERIC(2),
  Tipo_Cuenta NUMERIC(2),
  Numero_Cuenta varchar(19),
  Estado_Cuenta varchar(1)

  CONSTRAINT PK_TJD_ITF_TARJETAS_CUENTAS PRIMARY KEY (NroTarjeta,Cuenta),
  CONSTRAINT FK_TJD_ITF_TARJETAS FOREIGN KEY (NroTarjeta) REFERENCES TJD_ITF_TARJETAS_COMPLETAS(Nro_Tarjeta) ON DELETE CASCADE
 );
')
Execute('CREATE OR ALTER PROCEDURE SP_ITF_LINK_TRX_TARJETA_CUENTA  @Error VARCHAR(150) OUTPUT

AS 

BEGIN
      delete from TJD_ITF_TARJETAS_CUENTAS;
      SET @Error = '' '';
      BEGIN TRY
            --Sección 5
            INSERT INTO TJD_ITF_TARJETAS_CUENTAS 
            (NroTarjeta,Cuenta,Tipo_Cuenta, Numero_Cuenta, Estado_Cuenta)
            Select substring(Linea,731,19),1,substring(Linea,853,2) ,substring(Linea,855,19),substring(Linea,874,1) 
            FROM ITF_LINK_TRK where SUBSTRING(Linea, 1, 6) 
            IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)  
            AND (substring(Linea,731,19) <> ''                   '' and  substring(Linea,731,19) <> ''0000000000000000000'')
            AND (substring(Linea,855,19) <> ''                   '' and  substring(Linea,855,19) <> ''0000000000000000000'');
            
            INSERT INTO TJD_LINK_MAESTRO_CUENTA (ID_TARJETA, TIPO,NUMERO,ESTADO)
            Select substring(Linea,731,19),substring(Linea,853,2) ,substring(Linea,855,19),substring(Linea,874,1) 
            FROM ITF_LINK_TRK where SUBSTRING(Linea, 1, 6) 
            IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)  
            AND (substring(Linea,731,19) <> ''                   '' and  substring(Linea,731,19) <> ''0000000000000000000'')
            AND (substring(Linea,855,19) <> ''                   '' and  substring(Linea,855,19) <> ''0000000000000000000'');

            INSERT INTO TJD_ITF_TARJETAS_CUENTAS 
            (NroTarjeta,Cuenta,Tipo_Cuenta, Numero_Cuenta, Estado_Cuenta)
            Select substring(Linea,731,19),2,substring(Linea,875,2) ,substring(Linea,877,19),substring(Linea,896,1) 
            FROM ITF_LINK_TRK where SUBSTRING(Linea, 1, 6) 
            IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)  
            AND (substring(Linea,731,19) <> ''                   '' and  substring(Linea,731,19) <> ''0000000000000000000'')
            AND (substring(Linea,877,19) <> ''                   '' and  substring(Linea,877,19) <> ''0000000000000000000'');
            
            INSERT INTO TJD_LINK_MAESTRO_CUENTA (ID_TARJETA, TIPO,NUMERO,ESTADO)
            Select substring(Linea,731,19),substring(Linea,875,2) ,substring(Linea,877,19),substring(Linea,896,1) 
            FROM ITF_LINK_TRK where SUBSTRING(Linea, 1, 6) 
            IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)  
            AND (substring(Linea,731,19) <> ''                   '' and  substring(Linea,731,19) <> ''0000000000000000000'')
            AND (substring(Linea,877,19) <> ''                   '' and  substring(Linea,877,19) <> ''0000000000000000000'');

            INSERT INTO TJD_ITF_TARJETAS_CUENTAS 
            (NroTarjeta,Cuenta,Tipo_Cuenta, Numero_Cuenta, Estado_Cuenta)
            Select substring(Linea,731,19),3,substring(Linea,897,2) ,substring(Linea,899,19),substring(Linea,918,1) 
            FROM ITF_LINK_TRK where SUBSTRING(Linea, 1, 6) 
            IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)  
            AND (substring(Linea,731,19) <> ''                   '' and  substring(Linea,731,19) <> ''0000000000000000000'')
            AND (substring(Linea,899,19) <> ''                   '' and  substring(Linea,899,19) <> ''0000000000000000000'');
            
            INSERT INTO TJD_LINK_MAESTRO_CUENTA (ID_TARJETA, TIPO,NUMERO,ESTADO)
            Select substring(Linea,731,19),substring(Linea,897,2) ,substring(Linea,899,19),substring(Linea,918,1) 
            FROM ITF_LINK_TRK where SUBSTRING(Linea, 1, 6) 
            IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)  
            AND (substring(Linea,731,19) <> ''                   '' and  substring(Linea,731,19) <> ''0000000000000000000'')
            AND (substring(Linea,899,19) <> ''                   '' and  substring(Linea,899,19) <> ''0000000000000000000'');
            

            INSERT INTO TJD_ITF_TARJETAS_CUENTAS 
            (NroTarjeta,Cuenta,Tipo_Cuenta, Numero_Cuenta, Estado_Cuenta)
            Select substring(Linea,731,19),4,substring(Linea,919,2) ,substring(Linea,921,19),substring(Linea,940,1) 
            FROM ITF_LINK_TRK where SUBSTRING(Linea, 1, 6) 
            IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)  
            AND (substring(Linea,731,19) <> ''                   '' and  substring(Linea,731,19) <> ''0000000000000000000'')
            AND (substring(Linea,921,19) <> ''                   '' and  substring(Linea,921,19) <> ''0000000000000000000'');
            
            INSERT INTO TJD_LINK_MAESTRO_CUENTA (ID_TARJETA, TIPO,NUMERO,ESTADO)
            Select substring(Linea,731,19),substring(Linea,919,2) ,substring(Linea,921,19),substring(Linea,940,1) 
            FROM ITF_LINK_TRK where SUBSTRING(Linea, 1, 6) 
            IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)  
            AND (substring(Linea,731,19) <> ''                   '' and  substring(Linea,731,19) <> ''0000000000000000000'')
            AND (substring(Linea,921,19) <> ''                   '' and  substring(Linea,921,19) <> ''0000000000000000000'');

            INSERT INTO TJD_ITF_TARJETAS_CUENTAS 
            (NroTarjeta,Cuenta,Tipo_Cuenta, Numero_Cuenta, Estado_Cuenta)
            Select substring(Linea,731,19),5,substring(Linea,941,2) ,substring(Linea,943,19),substring(Linea,962,1) 
            FROM ITF_LINK_TRK where SUBSTRING(Linea, 1, 6) 
            IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)  
            AND (substring(Linea,731,19) <> ''                   '' and  substring(Linea,731,19) <> ''0000000000000000000'')
            AND (substring(Linea,943,19) <> ''                   '' and  substring(Linea,943,19) <> ''0000000000000000000'');
            
            INSERT INTO TJD_LINK_MAESTRO_CUENTA (ID_TARJETA, TIPO,NUMERO,ESTADO)
            Select substring(Linea,731,19),substring(Linea,941,2) ,substring(Linea,943,19),substring(Linea,962,1) 
            FROM ITF_LINK_TRK where SUBSTRING(Linea, 1, 6) 
            IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)  
            AND (substring(Linea,731,19) <> ''                   '' and  substring(Linea,731,19) <> ''0000000000000000000'')
            AND (substring(Linea,943,19) <> ''                   '' and  substring(Linea,943,19) <> ''0000000000000000000'');

            INSERT INTO TJD_ITF_TARJETAS_CUENTAS 
            (NroTarjeta,Cuenta,Tipo_Cuenta, Numero_Cuenta, Estado_Cuenta)
            Select substring(Linea,731,19),6,substring(Linea,963,2) ,substring(Linea,965,19),substring(Linea,984,1) 
            FROM ITF_LINK_TRK where SUBSTRING(Linea, 1, 6) 
            IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)  
            AND (substring(Linea,731,19) <> ''                   '' and  substring(Linea,731,19) <> ''0000000000000000000'')
            AND (substring(Linea,965,19) <> ''                   '' and  substring(Linea,965,19) <> ''0000000000000000000'');
            
            INSERT INTO TJD_LINK_MAESTRO_CUENTA (ID_TARJETA, TIPO,NUMERO,ESTADO)
            Select substring(Linea,731,19),substring(Linea,963,2) ,substring(Linea,965,19),substring(Linea,984,1) 
            FROM ITF_LINK_TRK where SUBSTRING(Linea, 1, 6) 
            IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)  
            AND (substring(Linea,731,19) <> ''                   '' and  substring(Linea,731,19) <> ''0000000000000000000'')
            AND (substring(Linea,965,19) <> ''                   '' and  substring(Linea,965,19) <> ''0000000000000000000'');

            INSERT INTO TJD_ITF_TARJETAS_CUENTAS 
            (NroTarjeta,Cuenta,Tipo_Cuenta, Numero_Cuenta, Estado_Cuenta)
            Select substring(Linea,731,19),7,substring(Linea,985,2) ,substring(Linea,987,19),substring(Linea,1006,1)
            FROM ITF_LINK_TRK where SUBSTRING(Linea, 1, 6) 
            IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)  
            AND (substring(Linea,731,19) <> ''                   '' and  substring(Linea,731,19) <> ''0000000000000000000'')
            AND (substring(Linea,987,19) <> ''                   '' and  substring(Linea,987,19) <> ''0000000000000000000'');
            
            INSERT INTO TJD_LINK_MAESTRO_CUENTA (ID_TARJETA, TIPO,NUMERO,ESTADO)
            Select substring(Linea,731,19),substring(Linea,985,2) ,substring(Linea,987,19),substring(Linea,1006,1)
            FROM ITF_LINK_TRK where SUBSTRING(Linea, 1, 6) 
            IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)  
            AND (substring(Linea,731,19) <> ''                   '' and  substring(Linea,731,19) <> ''0000000000000000000'')
            AND (substring(Linea,987,19) <> ''                   '' and  substring(Linea,987,19) <> ''0000000000000000000'');

            INSERT INTO TJD_ITF_TARJETAS_CUENTAS 
            (NroTarjeta,Cuenta,Tipo_Cuenta, Numero_Cuenta, Estado_Cuenta)
            Select substring(Linea,731,19),8,substring(Linea,1007,2) ,substring(Linea,1009,19),substring(Linea,1028,1) 
            FROM ITF_LINK_TRK where SUBSTRING(Linea, 1, 6) 
            IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)  
            AND (substring(Linea,731,19) <> ''                   '' and  substring(Linea,731,19) <> ''0000000000000000000'')
            AND (substring(Linea,1009,19) <> ''                   '' and  substring(Linea,1009,19) <> ''0000000000000000000'');
            
            INSERT INTO TJD_LINK_MAESTRO_CUENTA (ID_TARJETA, TIPO,NUMERO,ESTADO)
            Select substring(Linea,731,19),substring(Linea,1007,2) ,substring(Linea,1009,19),substring(Linea,1028,1) 
            FROM ITF_LINK_TRK where SUBSTRING(Linea, 1, 6) 
            IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)  
            AND (substring(Linea,731,19) <> ''                   '' and  substring(Linea,731,19) <> ''0000000000000000000'')
            AND (substring(Linea,1009,19) <> ''                   '' and  substring(Linea,1009,19) <> ''0000000000000000000'');
           

            INSERT INTO TJD_ITF_TARJETAS_CUENTAS 
            (NroTarjeta,Cuenta,Tipo_Cuenta, Numero_Cuenta, Estado_Cuenta)
            Select substring(Linea,731,19),9,substring(Linea,1029,2) ,substring(Linea,1031,19),substring(Linea,1050,1) 
            FROM ITF_LINK_TRK where SUBSTRING(Linea, 1, 6) 
            IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)  
            AND (substring(Linea,731,19) <> ''                   '' and  substring(Linea,731,19) <> ''0000000000000000000'')
            AND (substring(Linea,1031,19) <> ''                   '' and  substring(Linea,1031,19) <> ''0000000000000000000'');
            
            INSERT INTO TJD_LINK_MAESTRO_CUENTA (ID_TARJETA, TIPO,NUMERO,ESTADO)
            Select substring(Linea,731,19),substring(Linea,1029,2) ,substring(Linea,1031,19),substring(Linea,1050,1) 
            FROM ITF_LINK_TRK where SUBSTRING(Linea, 1, 6) 
            IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)  
            AND (substring(Linea,731,19) <> ''                   '' and  substring(Linea,731,19) <> ''0000000000000000000'')
            AND (substring(Linea,1031,19) <> ''                   '' and  substring(Linea,1031,19) <> ''0000000000000000000'');

            INSERT INTO TJD_ITF_TARJETAS_CUENTAS 
            (NroTarjeta,Cuenta,Tipo_Cuenta, Numero_Cuenta, Estado_Cuenta)
            Select substring(Linea,731,19),10,substring(Linea,1051,2) ,substring(Linea,1053,19),substring(Linea,1072,1) 
            FROM ITF_LINK_TRK where SUBSTRING(Linea, 1, 6) 
            IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)  
            AND (substring(Linea,731,19) <> ''                   '' and  substring(Linea,731,19) <> ''0000000000000000000'')
            AND (substring(Linea,1053,19) <> ''                   '' and  substring(Linea,1053,19) <> ''0000000000000000000'');
            
            INSERT INTO TJD_LINK_MAESTRO_CUENTA (ID_TARJETA, TIPO,NUMERO,ESTADO)
            Select substring(Linea,731,19),substring(Linea,1051,2) ,substring(Linea,1053,19),substring(Linea,1072,1) 
            FROM ITF_LINK_TRK where SUBSTRING(Linea, 1, 6) 
            IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)  
            AND (substring(Linea,731,19) <> ''                   '' and  substring(Linea,731,19) <> ''0000000000000000000'')
            AND (substring(Linea,1053,19) <> ''                   '' and  substring(Linea,1053,19) <> ''0000000000000000000'');

            INSERT INTO TJD_ITF_TARJETAS_CUENTAS 
            (NroTarjeta,Cuenta,Tipo_Cuenta, Numero_Cuenta, Estado_Cuenta)
            Select substring(Linea,731,19),11,substring(Linea,1073,2) ,substring(Linea,1075,19),substring(Linea,1094,1) 
            FROM ITF_LINK_TRK where SUBSTRING(Linea, 1, 6) 
            IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)  
            AND (substring(Linea,731,19) <> ''                   '' and  substring(Linea,731,19) <> ''0000000000000000000'')
            AND (substring(Linea,1075,19) <> ''                   '' and  substring(Linea,1075,19) <> ''0000000000000000000'');
            
            INSERT INTO TJD_LINK_MAESTRO_CUENTA (ID_TARJETA, TIPO,NUMERO,ESTADO)
            Select substring(Linea,731,19),substring(Linea,1073,2) ,substring(Linea,1075,19),substring(Linea,1094,1) 
            FROM ITF_LINK_TRK where SUBSTRING(Linea, 1, 6) 
            IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)  
            AND (substring(Linea,731,19) <> ''                   '' and  substring(Linea,731,19) <> ''0000000000000000000'')
            AND (substring(Linea,1075,19) <> ''                   '' and  substring(Linea,1075,19) <> ''0000000000000000000'');
            

            INSERT INTO TJD_ITF_TARJETAS_CUENTAS 
            (NroTarjeta,Cuenta,Tipo_Cuenta, Numero_Cuenta, Estado_Cuenta)
            Select substring(Linea,731,19),12, substring(Linea,1095,2) , substring(Linea,1097,19), substring(Linea,1116,1) 
            FROM ITF_LINK_TRK where SUBSTRING(Linea, 1, 6) 
            IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)  
            AND (substring(Linea,731,19) <> ''                   '' and  substring(Linea,731,19) <> ''0000000000000000000'')
            AND (substring(Linea,1097,19) <> ''                   '' and  substring(Linea,1097,19) <> ''0000000000000000000'');
            
            INSERT INTO TJD_LINK_MAESTRO_CUENTA (ID_TARJETA, TIPO,NUMERO,ESTADO)
            Select substring(Linea,731,19),substring(Linea,1095,2) , substring(Linea,1097,19), substring(Linea,1116,1) 
            FROM ITF_LINK_TRK where SUBSTRING(Linea, 1, 6) 
            IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)  
            AND (substring(Linea,731,19) <> ''                   '' and  substring(Linea,731,19) <> ''0000000000000000000'')
            AND (substring(Linea,1097,19) <> ''                   '' and  substring(Linea,1097,19) <> ''0000000000000000000'');

            INSERT INTO TJD_ITF_TARJETAS_CUENTAS 
            (NroTarjeta,Cuenta,Tipo_Cuenta, Numero_Cuenta, Estado_Cuenta)
            Select substring(Linea,731,19),13,substring(Linea,1117,2) ,substring(Linea,1119,19),substring(Linea,1138,1) 
            FROM ITF_LINK_TRK where SUBSTRING(Linea, 1, 6) 
            IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)  
            AND (substring(Linea,731,19) <> ''                   '' and  substring(Linea,731,19) <> ''0000000000000000000'')
            AND (substring(Linea,1119,19) <> ''                   '' and  substring(Linea,1119,19) <> ''0000000000000000000'');
            
            INSERT INTO TJD_LINK_MAESTRO_CUENTA (ID_TARJETA, TIPO,NUMERO,ESTADO)
            Select substring(Linea,731,19),substring(Linea,1117,2) ,substring(Linea,1119,19),substring(Linea,1138,1) 
            FROM ITF_LINK_TRK where SUBSTRING(Linea, 1, 6) 
            IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)  
            AND (substring(Linea,731,19) <> ''                   '' and  substring(Linea,731,19) <> ''0000000000000000000'')
            AND (substring(Linea,1119,19) <> ''                   '' and  substring(Linea,1119,19) <> ''0000000000000000000'');

            INSERT INTO TJD_ITF_TARJETAS_CUENTAS 
            (NroTarjeta,Cuenta,Tipo_Cuenta, Numero_Cuenta, Estado_Cuenta)
            Select substring(Linea,731,19),14,substring(Linea,1139,2) ,substring(Linea,1141,19),substring(Linea,1160,1) 
            FROM ITF_LINK_TRK where SUBSTRING(Linea, 1, 6) 
            IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)  
            AND (substring(Linea,731,19) <> ''                   '' and  substring(Linea,731,19) <> ''0000000000000000000'')
            AND (substring(Linea,1141,19) <> ''                   '' and  substring(Linea,1141,19) <> ''0000000000000000000'');
            
            INSERT INTO TJD_LINK_MAESTRO_CUENTA (ID_TARJETA, TIPO,NUMERO,ESTADO)
            Select substring(Linea,731,19),substring(Linea,1139,2) ,substring(Linea,1141,19),substring(Linea,1160,1) 
            FROM ITF_LINK_TRK where SUBSTRING(Linea, 1, 6) 
            IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)  
            AND (substring(Linea,731,19) <> ''                   '' and  substring(Linea,731,19) <> ''0000000000000000000'')
            AND (substring(Linea,1141,19) <> ''                   '' and  substring(Linea,1141,19) <> ''0000000000000000000'');

            INSERT INTO TJD_ITF_TARJETAS_CUENTAS 
            (NroTarjeta,Cuenta,Tipo_Cuenta, Numero_Cuenta, Estado_Cuenta)
            Select substring(Linea,731,19),15,substring(Linea,1161,2) ,substring(Linea,1163,19),substring(Linea,1182,1) 
            FROM ITF_LINK_TRK where SUBSTRING(Linea, 1, 6) 
            IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)  
            AND (substring(Linea,731,19) <> ''                   '' and  substring(Linea,731,19) <> ''0000000000000000000'')
            AND (substring(Linea,1163,19) <> ''                   '' and  substring(Linea,1163,19) <> ''0000000000000000000'');
            
            INSERT INTO TJD_LINK_MAESTRO_CUENTA (ID_TARJETA, TIPO,NUMERO,ESTADO)
            Select substring(Linea,731,19),substring(Linea,1161,2) ,substring(Linea,1163,19),substring(Linea,1182,1) 
            FROM ITF_LINK_TRK where SUBSTRING(Linea, 1, 6) 
            IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)  
            AND (substring(Linea,731,19) <> ''                   '' and  substring(Linea,731,19) <> ''0000000000000000000'')
            AND (substring(Linea,1163,19) <> ''                   '' and  substring(Linea,1163,19) <> ''0000000000000000000'');

            INSERT INTO TJD_ITF_TARJETAS_CUENTAS 
            (NroTarjeta,Cuenta,Tipo_Cuenta, Numero_Cuenta, Estado_Cuenta)
            Select substring(Linea,731,19),16,substring(Linea,1183,2) ,substring(Linea,1185,19),substring(Linea,1204,1) 
            FROM ITF_LINK_TRK where SUBSTRING(Linea, 1, 6) 
            IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)  
            AND (substring(Linea,731,19) <> ''                   '' and  substring(Linea,731,19) <> ''0000000000000000000'')
            AND (substring(Linea,1185,19) <> ''                   '' and  substring(Linea,1185,19) <> ''0000000000000000000'');
            
            INSERT INTO TJD_LINK_MAESTRO_CUENTA (ID_TARJETA, TIPO,NUMERO,ESTADO)
            Select substring(Linea,731,19),substring(Linea,1183,2) ,substring(Linea,1185,19),substring(Linea,1204,1) 
            FROM ITF_LINK_TRK where SUBSTRING(Linea, 1, 6) 
            IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)  
            AND (substring(Linea,731,19) <> ''                   '' and  substring(Linea,731,19) <> ''0000000000000000000'')
            AND (substring(Linea,1185,19) <> ''                   '' and  substring(Linea,1185,19) <> ''0000000000000000000'');
            
            
      END TRY

      BEGIN CATCH
         -- Captura la excepción y almacena el mensaje de error en la variable @Error
         SET @Error = ERROR_MESSAGE();
         print @Error;
      END CATCH;
END;')
Execute('CREATE OR ALTER PROCEDURE SP_ITF_LINK_TRX_FULL
    @Error VARCHAR(150) OUTPUT, @ErrorMaestroCuenta VARCHAR(150) OUTPUT
AS
BEGIN
    SET @Error = '' '';
      
  BEGIN TRY

      DELETE FROM TJD_ITF_TARJETA_RAIZ;
      DELETE FROM TJD_ITF_PERSONAS;
      DELETE FROM TJD_ITF_TARJETAS_COMPLETAS;
      DELETE FROM TJD_ITF_PERSONAS_CONTACTO;
      DELETE FROM TJD_LINK_MAESTRO;

      INSERT INTO TJD_LINK_MAESTRO (ID_TARJETA, COD_TRAN, TIPO_TARJETA, ESTADO_TARJETA, FECHA_ENTREGA_TARJ, VENCIMIENTO_TARJETA,
      LIMITE_MONTO_TARJETA, NUM_VERSION_TARJ, DIGITO_VERIFICADOR_TARJ, NRO_PERSONA, NRO_CLIENTE, PRODUCTO,NOMBRE_TARJETA, 
      LIMITE_CREDITO, TARJETA_TITULAR)
      SELECT SUBSTRING(Linea, 731, 19), SUBSTRING(Linea, 1, 6), SUBSTRING(Linea, 771, 2), SUBSTRING(Linea, 780, 1),
      SUBSTRING(Linea, 825, 8), SUBSTRING(Linea, 776, 4), SUBSTRING(Linea, 767, 2), SUBSTRING(Linea, 763, 1),
      SUBSTRING(Linea, 764, 1), ISNULL(NUMEROPERSONA,0), ISNULL(CODIGOCLIENTE,0),SUBSTRING(Linea, 178, 4), CONCAT(TRIM(SUBSTRING(Linea, 548, 15)), '' '', TRIM(SUBSTRING(Linea, 563, 15))),
      SUBSTRING(Linea, 769, 2), SUBSTRING(Linea, 132, 19)
      FROM ITF_LINK_TRK
      LEFT JOIN VW_CLI_X_DOC ON NUMERODOC = REPLACE(LTRIM(REPLACE(substring(Linea,539,9),''0'','' '')),'' '',''0'')
      WHERE SUBSTRING(Linea, 1, 6) IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)
      AND SUBSTRING(Linea, 132, 19) <> ''0000000000000000000'' AND SUBSTRING(Linea, 132, 19) <> ''                   '';
      
      --Sección 2
      INSERT INTO TJD_ITF_TARJETA_RAIZ    (NumRaiz, Prefijo, NumCliente, Sucursal, Producto, EstadoRaiz, TipoCuentaPrincipal, 
      NumCuentaPrincipal, TipoDocApoderado, NumDocApoderado, Apellido,Nombre, CodEnte, CantMiembros, DomicilioPin, DomicilioPlastico, 
      CalleParticular, NumParticular, PisoParticular, DeptoParticular,LocalidadParticular, CodPostalParticular, CodProvinciaParticular,
      TelParticular, CalleLaboral, NumLaboral, PisoLaboral, DeptoLaboral,LocalidadLaboral, CodPostalLaboral, CodProvinciaLaboral, 
      TelLaboral, GrupoOperadorModif, TimestampModif, GrupoOperadorAlta, TimestampAlta, GrupoOperadorConfir, TimestampConfir)
      SELECT substring(Linea,132,19),substring(Linea,151,11),CAST(substring(Linea,162,12) AS NUMERIC),substring(Linea,174,4) ,
      substring(Linea,178,4) ,substring(Linea,182,1) , substring(Linea,183,2),CAST(substring(Linea,185,19) AS NUMERIC),
      substring(Linea,204,3) ,substring(Linea,207,9) ,substring(Linea,216,15),substring(Linea,231,15),substring(Linea,246,6) ,
      substring(Linea,252,2),substring(Linea,254,1),substring(Linea,255,1) ,substring(Linea,256,45),substring(Linea,301,5) ,
      substring(Linea,306,2),substring(Linea,308,3),substring(Linea,311,20),substring(Linea,331,15),substring(Linea,346,2) ,
      substring(Linea,348,15),substring(Linea,363,45),substring(Linea,408,5),substring(Linea,413,2),substring(Linea,415,3),
      substring(Linea,418,20),substring(Linea,438,15),substring(Linea,453,2),substring(Linea,455,15),substring(Linea,66,6),
      substring(Linea,72,16),substring(Linea,88,6),substring(Linea,94,16),substring(Linea,110,6),substring(Linea,116,16) 
      FROM ITF_LINK_TRK  WHERE SUBSTRING(Linea, 1, 6) 
      IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)
      AND SUBSTRING(Linea, 132, 19) <> ''0000000000000000000'' AND SUBSTRING(Linea, 132, 19) <> ''                   '';

      --Sección 3
      INSERT INTO TJD_ITF_PERSONAS (NroDocumento,TipoDocumento,GrupoOperadorModif,TimestampModif,Auditoria_Alta,Timestamp_Alta,
      GrupoOperadorConfir, TimestampConfir,Apellido,Nombre,Sexo,Código_CUIL,NroDocumentoCuil,DigVerificadorCuil,Ocupación,
      FechaNacimiento,EstadoCivil, Nacionalidad,Observaciones)
      SELECT CAST(substring(Linea,539,9) AS NUMERIC(9)) ,substring(Linea,536,3),CAST(substring(Linea,470,6) AS NUMERIC(6)) ,
      CAST(substring(Linea,476,16) AS NUMERIC(16)),CAST(substring(Linea,492,6) AS NUMERIC(6)) , CAST(substring(Linea,498,16) AS NUMERIC(16)),
      CAST(substring(Linea,514,6) AS NUMERIC(6)) ,CAST(substring(Linea,520,16) AS NUMERIC(16)),
      substring(Linea,548,15),substring(Linea,563,15), substring(Linea,578,1) ,substring(Linea,579,2) ,substring(Linea,581,9) ,
      substring(Linea,590,1) ,substring(Linea,591,20),
      substring(Linea,611,8) ,substring(Linea,619,1) ,substring(Linea,620,15),substring(Linea,635,30) 
      FROM ITF_LINK_TRK where SUBSTRING(Linea, 1, 6) 
      IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0)
      And (substring(Linea,539,9) <> ''         '' And substring(Linea,539,9) <> ''000000000'') 
      And (substring(Linea,536,3) <> ''   '' And substring(Linea,536,3) <> ''000'');

      --Sección 6
      INSERT INTO TJD_ITF_PERSONAS_CONTACTO 
      (Tipo_Doc, Num_Doc, Grupo_Oper_Alta, Timestamp_Alta,Grupo_Oper_Modif,Timestamp_Modif, Calle_Contacto, Num_Contacto, 
      Piso_Contacto, Depto_Contacto, Provincia_Contacto, Localidad_Contacto, Tel_Personal_Area, Tel_Personal_Num,
       Tel_Laboral_Area, Tel_Laboral_Num, Tel_Laboral_Interno, Tel_Celular_Area, Tel_Celular_Num, Email)
      SELECT substring(Linea,536,3) ,substring(Linea,539,9) ,substring(Linea,1227,6) ,substring(Linea,1233,16),
      substring(Linea,1249,6) ,substring(Linea,1255,16),substring(Linea,1271,60),substring(Linea,1331,10),
      substring(Linea,1341,2) ,substring(Linea,1343,3) ,substring(Linea,1346,2) ,substring(Linea,1376,3) ,substring(Linea,1416,2) ,
      substring(Linea,1420,10),substring(Linea,1430,4) ,substring(Linea,1434,10),substring(Linea,1444,5) ,substring(Linea,1449,4) ,
      substring(Linea,1453,10),substring(Linea,1463,100) 
      FROM ITF_LINK_TRK where SUBSTRING(Linea, 1, 6) 
      IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0) 
      AND (substring(Linea,539,9) <> ''         '' And substring(Linea,539,9) <> ''000000000'') 
      And (substring(Linea,536,3) <> ''   '' And substring(Linea,536,3) <> ''000'');

      --Sección 4
      INSERT INTO TJD_ITF_TARJETAS_COMPLETAS (Nro_Tarjeta,Tipo_Doc,Nro_Doc,Nro_Raiz,Grp_Op_Modif,Timestamp_Modif,Aud_Alta,
        Timestamp_Alta,Grp_Op_Conf,Timestamp_Conf,Miembro,Nro_Version,Dig_Verif,Cat_Comision,Cod_Lim_Debito,Cod_Lim_Credito,
        Tipo_Tarj,Meses_Vigencia,Fec_Vencimiento,Estado,Cant_Cuentas_Asociadas,Ref_Cliente,Cant_Pin_Impresos,Marca_Pin,Fec_Emi_Pin,
        Fec_Ent_Pin,Cant_Plasticos_Imp,Marca_Plastico,Fec_Emi_Plast,Fec_Ent_Plast,Cod_Denuncia,Grp_Afinidad) 
      SELECT substring(Linea,731,19),substring(Linea,751,3) ,substring(Linea,754,9) ,substring(Linea,132,19),substring(Linea,665,6) ,
      substring(Linea,671,16),substring(Linea,687,6) ,substring(Linea,693,16),substring(Linea,709,6) ,substring(Linea,715,16),
      substring(Linea,750,1) ,substring(Linea,763,1) ,substring(Linea,764,1) ,substring(Linea,765,2) ,substring(Linea,767,2) ,
      substring(Linea,769,2) ,substring(Linea,771,2) ,substring(Linea,773,2) ,substring(Linea,776,4) ,substring(Linea,780,1) ,
      substring(Linea,781,2) ,substring(Linea,783,12),substring(Linea,795,2) ,substring(Linea,797,1) ,substring(Linea,798,8) ,
      substring(Linea,806,8) ,substring(Linea,814,2) ,substring(Linea,816,1) ,substring(Linea,817,8) ,substring(Linea,825,8) ,
      substring(Linea,833,16),substring(Linea,849,4) 
      FROM ITF_LINK_TRK where SUBSTRING(Linea, 1, 6) 
      IN (SELECT CODIGO_LINK FROM TJD_TIPOS_NOVEDADES_LINK WHERE ACTUALIZA_BD = ''S'' AND TZ_LOCK = 0) 
      AND (substring(Linea,731,19) <> ''                   '' and  substring(Linea,731,19) <> ''0000000000000000000'');

      --Graba TJD_ITF_TARJETAS_CUENTAS y TJD_LINK_MAESTRO_CUENTA
      EXEC SP_ITF_LINK_TRX_TARJETA_CUENTA @ErrorMaestroCuenta;
      
  END TRY

  BEGIN CATCH
    -- Captura la excepción y almacena el mensaje de error en la variable @Error
    SET @Error = ERROR_MESSAGE();
    print @Error;
  END CATCH;
     
END;')

Execute('CREATE  OR ALTER PROCEDURE SP_ITF_LINK_TRX_REFRESH  @Error VARCHAR(150) OUTPUT
AS
BEGIN
    SET @Error = '' '';
      
  	BEGIN TRY

		UPDATE TJD_LINK_MAESTRO
		SET
		    TIPO_TARJETA = SUBSTRING(Linea, 771, 2),
		    ESTADO_TARJETA = SUBSTRING(Linea, 780, 1),
		    FECHA_ENTREGA_TARJ = SUBSTRING(Linea, 825, 8),
		    VENCIMIENTO_TARJETA = SUBSTRING(Linea, 776, 4),
		    LIMITE_MONTO_TARJETA = SUBSTRING(Linea, 767, 2),
		    NUM_VERSION_TARJ = SUBSTRING(Linea, 763, 1),
		    DIGITO_VERIFICADOR_TARJ = SUBSTRING(Linea, 764, 1),
		    PRODUCTO = SUBSTRING(Linea, 178, 4),
		    NOMBRE_TARJETA = CONCAT(TRIM(SUBSTRING(Linea, 548, 15)), '' '', TRIM(SUBSTRING(Linea, 563, 15))),
		    LIMITE_CREDITO = SUBSTRING(Linea, 769, 2), 
		    TARJETA_TITULAR = SUBSTRING(Linea, 132, 19),
		    PROCESADO = ''N''
		FROM TJD_LINK_MAESTRO 
		    JOIN ITF_LINK_TRK ON ID_TARJETA = SUBSTRING(Linea, 731, 19) AND COD_TRAN = SUBSTRING(Linea, 1, 6)
		WHERE ID_TARJETA = SUBSTRING(Linea, 731, 19) and COD_TRAN = SUBSTRING(Linea, 1, 6) ;


		UPDATE TJD_ITF_TARJETA_RAIZ
		SET 
			Prefijo = substring(Linea,151,11),
		    NumCliente = CAST(substring(Linea,162,12) AS NUMERIC),
		    Sucursal = substring(Linea,174,4) ,
      	    Producto =  substring(Linea,178,4) ,
		    EstadoRaiz = substring(Linea,182,1) ,
		    TipoCuentaPrincipal = substring(Linea,183,2),
		    NumCuentaPrincipal = CAST(substring(Linea,185,19) AS NUMERIC),
		    TipoDocApoderado = substring(Linea,204,3) ,
		    NumDocApoderado = substring(Linea,207,9) ,
		    Apellido = substring(Linea,216,15),
		    Nombre = substring(Linea,231,15),
		    CodEnte =substring(Linea,246,6) ,
		    CantMiembros = substring(Linea,252,2),
		    DomicilioPin = substring(Linea,254,1),
		    DomicilioPlastico = substring(Linea,255,1) ,
		    CalleParticular = substring(Linea,256,45),
		    NumParticular = substring(Linea,301,5) ,
		    PisoParticular = substring(Linea,306,2),
		    DeptoParticular = substring(Linea,308,3),
		    LocalidadParticular = substring(Linea,311,20),
		    CodPostalParticular = substring(Linea,331,15),
		    CodProvinciaParticular = substring(Linea,346,2) ,
		    TelParticular = substring(Linea,348,15),
		    CalleLaboral = substring(Linea,363,45),
		    NumLaboral = substring(Linea,408,5),
		    PisoLaboral = substring(Linea,413,2),
		    DeptoLaboral = substring(Linea,415,3),
		    LocalidadLaboral = substring(Linea,418,20),
		    CodPostalLaboral = substring(Linea,438,15),
		    CodProvinciaLaboral = substring(Linea,453,2),
		    TelLaboral = substring(Linea,455,15),
		    GrupoOperadorModif = substring(Linea,66,6),
		    TimestampModif = substring(Linea,72,16),
		    GrupoOperadorAlta = substring(Linea,88,6),
		    TimestampAlta = substring(Linea,94,16),
		    GrupoOperadorConfir = substring(Linea,110,6),
		    TimestampConfir = substring(Linea,116,16) 
		FROM TJD_ITF_TARJETA_RAIZ JOIN ITF_LINK_TRK ON SUBSTRING(Linea, 132, 19) = NumRaiz
		WHERE SUBSTRING(Linea, 132, 19) = NumRaiz AND TimestampModif < substring(Linea,72,16) AND TimestampConfir < substring(Linea,116,16) ;

		UPDATE TJD_ITF_PERSONAS
		SET 	
			GrupoOperadorModif = substring(Linea,470,6),
	    	TimestampModif = substring(Linea,476,16),
	    	Auditoria_Alta = substring(Linea,492,6),
	    	Timestamp_Alta = substring(Linea,498,16),
	    	GrupoOperadorConfir = substring(Linea,514,6),
	    	TimestampConfir = substring(Linea,520,16),
	    	Apellido = substring(Linea,548,15), 
	    	Nombre = substring(Linea,563,15),
	    	Sexo = substring(Linea,578,1),
	    	Código_CUIL = substring(Linea,579,2),
	    	NroDocumentoCuil = substring(Linea,581,9) ,
	    	DigVerificadorCuil = substring(Linea,590,1) ,      
	    	Ocupación = substring(Linea,591,20),
	    	FechaNacimiento = substring(Linea,611,8) ,
	    	EstadoCivil = substring(Linea,619,1) ,
	    	Nacionalidad = substring(Linea,620,15),
	    	Observaciones = substring(Linea,635,30) 
		FROM TJD_ITF_PERSONAS 
		JOIN ITF_LINK_TRK ON NroDocumento = substring(Linea,539,9) And TipoDocumento = substring(Linea,536,3)
		WHERE NroDocumento = substring(Linea,539,9) And TipoDocumento = substring(Linea,536,3) And TimestampModif < substring(Linea,476,16)
		AND TimestampConfir < substring(Linea,520,16);

		UPDATE TJD_ITF_PERSONAS_CONTACTO
		SET 
			Grupo_Oper_Alta = substring(Linea,1227,6),
		    Timestamp_Alta = substring(Linea,1233,16),
		    Grupo_Oper_Modif = substring(Linea,1249,6),
		    Timestamp_Modif = substring(Linea,1255,16),
		    Calle_Contacto = substring(Linea,1271,60),
		    Num_Contacto = substring(Linea,1331,10),
		    Piso_Contacto = substring(Linea,1341,2) ,
		    Depto_Contacto = substring(Linea,1343,3) ,
		    Provincia_Contacto = substring(Linea,1346,2) ,
		    Localidad_Contacto = substring(Linea,1376,3) ,
		    Tel_Personal_Area = substring(Linea,1416,2) ,
		    Tel_Personal_Num = substring(Linea,1420,10),
		    Tel_Laboral_Area = substring(Linea,1430,4) ,
		    Tel_Laboral_Num = substring(Linea,1434,10),
		    Tel_Laboral_Interno = substring(Linea,1444,5) ,
		    Tel_Celular_Area = substring(Linea,1449,4) ,
		    Tel_Celular_Num = substring(Linea,1453,10),
		    Email = substring(Linea,1463,100) 
		FROM TJD_ITF_PERSONAS_CONTACTO
		JOIN ITF_LINK_TRK ON Tipo_Doc = substring(Linea,536,3) AND Num_Doc = substring(Linea,539,9)
		WHERE Tipo_Doc = substring(Linea,536,3) AND Num_Doc = substring(Linea,539,9) And Timestamp_Modif < substring(Linea,1255,16);

		UPDATE TJD_ITF_TARJETAS_COMPLETAS
		SET 
		    Grp_Op_Modif = substring(Linea,665,6),
		    Timestamp_Modif = substring(Linea,671,16),
		    Aud_Alta = substring(Linea,687,6) ,
		    Timestamp_Alta = substring(Linea,693,16),
		    Grp_Op_Conf = substring(Linea,709,6) ,
		    Timestamp_Conf = substring(Linea,715,16),
		    Miembro = substring(Linea,750,1) ,
		    Nro_Version = substring(Linea,763,1) ,
		    Dig_Verif = substring(Linea,764,1) ,
		    Cat_Comision = substring(Linea,765,2) ,
		    Cod_Lim_Debito = substring(Linea,767,2) ,
		    Cod_Lim_Credito = substring(Linea,769,2) ,
		    Tipo_Tarj = substring(Linea,771,2) ,
		    Meses_Vigencia = substring(Linea,773,2) ,
		    Fec_Vencimiento = substring(Linea,776,4) ,
		    Estado = substring(Linea,780,1) ,
		    Cant_Cuentas_Asociadas = substring(Linea,781,2) ,
		    Ref_Cliente = substring(Linea,783,12),
		    Cant_Pin_Impresos = substring(Linea,795,2) ,
		    Marca_Pin = substring(Linea,797,1) ,
		    Fec_Emi_Pin = substring(Linea,798,8) ,
		    Fec_Ent_Pin = substring(Linea,806,8) ,
		    Cant_Plasticos_Imp = substring(Linea,814,2) ,
		    Marca_Plastico = substring(Linea,816,1) ,
		    Fec_Emi_Plast = substring(Linea,817,8) ,
		    Fec_Ent_Plast = substring(Linea,825,8) ,
		    Cod_Denuncia =  substring(Linea,833,16),
		    Grp_Afinidad = substring(Linea,849,4) 
		FROM TJD_ITF_TARJETAS_COMPLETAS
		JOIN ITF_LINK_TRK ON Nro_Tarjeta = substring(Linea,731,19)
		WHERE Nro_Tarjeta = substring(Linea,731,19) And Timestamp_Modif < substring(Linea,671,16) AND Timestamp_Conf < substring(Linea,715,16);
  

	END TRY

    BEGIN CATCH
         -- Captura la excepción y almacena el mensaje de error en la variable @Error
         SET @Error = ERROR_MESSAGE();
    END CATCH;	

END;')

Execute('
TRUNCATE TABLE dbo.TJD_TIPOS_NOVEDADES_LINK;
INSERT INTO dbo.TJD_TIPOS_NOVEDADES_LINK (CODIGO, CODIGO_LINK, DESCRIPCION, PRIORIDAD, APLICA_PRIORIDAD, ACTUALIZA_BD, TZ_LOCK, ACCION)
VALUES (1, ''120005'', ''ALTA TARJETA TITULAR'', 0, ''N'', ''S'', 0, ''A'')

INSERT INTO dbo.TJD_TIPOS_NOVEDADES_LINK (CODIGO, CODIGO_LINK, DESCRIPCION, PRIORIDAD, APLICA_PRIORIDAD, ACTUALIZA_BD, TZ_LOCK, ACCION)
VALUES (2, ''120006'', ''ALTA TARJETA ADICIONAL'', 100, ''S'', ''S'', 0, ''A'')

INSERT INTO dbo.TJD_TIPOS_NOVEDADES_LINK (CODIGO, CODIGO_LINK, DESCRIPCION, PRIORIDAD, APLICA_PRIORIDAD, ACTUALIZA_BD, TZ_LOCK, ACCION)
VALUES (3, ''130002'', ''RELACION CUENTAS A TARJETA'', 30, ''S'', ''S'', 0, ''M'')

INSERT INTO dbo.TJD_TIPOS_NOVEDADES_LINK (CODIGO, CODIGO_LINK, DESCRIPCION, PRIORIDAD, APLICA_PRIORIDAD, ACTUALIZA_BD, TZ_LOCK, ACCION)
VALUES (4, ''200000'', ''HABILITACION TARJETA'', 10, ''S'', ''S'', 0, ''M'')

INSERT INTO dbo.TJD_TIPOS_NOVEDADES_LINK (CODIGO, CODIGO_LINK, DESCRIPCION, PRIORIDAD, APLICA_PRIORIDAD, ACTUALIZA_BD, TZ_LOCK, ACCION)
VALUES (5, ''190000'', ''REIMPRESION TARJETA CON BLANQUEO'', 110, ''S'', ''S'', 0, ''A'')

INSERT INTO dbo.TJD_TIPOS_NOVEDADES_LINK (CODIGO, CODIGO_LINK, DESCRIPCION, PRIORIDAD, APLICA_PRIORIDAD, ACTUALIZA_BD, TZ_LOCK, ACCION)
VALUES (6, ''170000'', ''BLANQUEO PIN'', 20, ''S'', ''S'', 0, ''M'')

INSERT INTO dbo.TJD_TIPOS_NOVEDADES_LINK (CODIGO, CODIGO_LINK, DESCRIPCION, PRIORIDAD, APLICA_PRIORIDAD, ACTUALIZA_BD, TZ_LOCK, ACCION)
VALUES (7, ''210002'', ''BAJA TARJETA'', 120, ''S'', ''S'', 0, ''M'')

INSERT INTO dbo.TJD_TIPOS_NOVEDADES_LINK (CODIGO, CODIGO_LINK, DESCRIPCION, PRIORIDAD, APLICA_PRIORIDAD, ACTUALIZA_BD, TZ_LOCK, ACCION)
VALUES (8, ''230000'', ''CAMBIO TITULAR TARJETA'', 40, ''S'', ''S'', 0, ''M'')

INSERT INTO dbo.TJD_TIPOS_NOVEDADES_LINK (CODIGO, CODIGO_LINK, DESCRIPCION, PRIORIDAD, APLICA_PRIORIDAD, ACTUALIZA_BD, TZ_LOCK, ACCION)
VALUES (9, ''220000'', ''REQUE MODIF PERSONA CON CONF'', 0, ''N'', ''S'', 0, ''M'')

INSERT INTO dbo.TJD_TIPOS_NOVEDADES_LINK (CODIGO, CODIGO_LINK, DESCRIPCION, PRIORIDAD, APLICA_PRIORIDAD, ACTUALIZA_BD, TZ_LOCK, ACCION)
VALUES (10, ''110301'', ''MODIFICACION PERSONA'', 0, ''N'', ''S'', 0, ''M'')

INSERT INTO dbo.TJD_TIPOS_NOVEDADES_LINK (CODIGO, CODIGO_LINK, DESCRIPCION, PRIORIDAD, APLICA_PRIORIDAD, ACTUALIZA_BD, TZ_LOCK, ACCION)
VALUES (11, ''140005'', ''REIMPRESION SIN BLANQUEO'', 115, ''S'', ''S'', 0, ''M'')

INSERT INTO dbo.TJD_TIPOS_NOVEDADES_LINK (CODIGO, CODIGO_LINK, DESCRIPCION, PRIORIDAD, APLICA_PRIORIDAD, ACTUALIZA_BD, TZ_LOCK, ACCION)
VALUES (12, ''112901'', ''Mod.tarj.sin confirmación  '', 0, ''N'', ''S'', 0, ''M'')

INSERT INTO dbo.TJD_TIPOS_NOVEDADES_LINK (CODIGO, CODIGO_LINK, DESCRIPCION, PRIORIDAD, APLICA_PRIORIDAD, ACTUALIZA_BD, TZ_LOCK, ACCION)
VALUES (13, ''113001'', ''Mod.raíz sin confirmación '', 0, ''N'', ''S'', 0, ''M'')

INSERT INTO dbo.TJD_TIPOS_NOVEDADES_LINK (CODIGO, CODIGO_LINK, DESCRIPCION, PRIORIDAD, APLICA_PRIORIDAD, ACTUALIZA_BD, TZ_LOCK, ACCION)
VALUES (14, ''114001'', ''Reset-Cambio PIL'', 0, ''N'', ''N'', 0, ''M'')

INSERT INTO dbo.TJD_TIPOS_NOVEDADES_LINK (CODIGO, CODIGO_LINK, DESCRIPCION, PRIORIDAD, APLICA_PRIORIDAD, ACTUALIZA_BD, TZ_LOCK, ACCION)
VALUES (15, ''114002'', ''Blanqueo PIL'', 0, ''N'', ''N'', 0, ''M'')

INSERT INTO dbo.TJD_TIPOS_NOVEDADES_LINK (CODIGO, CODIGO_LINK, DESCRIPCION, PRIORIDAD, APLICA_PRIORIDAD, ACTUALIZA_BD, TZ_LOCK, ACCION)
VALUES (16, ''114003'', ''Aviso de Viaje'', 0, ''N'', ''N'', 0, ''A'')

INSERT INTO dbo.TJD_TIPOS_NOVEDADES_LINK (CODIGO, CODIGO_LINK, DESCRIPCION, PRIORIDAD, APLICA_PRIORIDAD, ACTUALIZA_BD, TZ_LOCK, ACCION)
VALUES (17, ''114013'', ''Bloqueo de Tarjeta por Identificación Positiva'', 0, ''N'', ''S'', 0, ''M'')

INSERT INTO dbo.TJD_TIPOS_NOVEDADES_LINK (CODIGO, CODIGO_LINK, DESCRIPCION, PRIORIDAD, APLICA_PRIORIDAD, ACTUALIZA_BD, TZ_LOCK, ACCION)
VALUES (18, ''114014'', ''Reg de llamada Call Center de tarjeta bloq por iden positiva'', 0, ''N'', ''S'', 0, ''M'')

INSERT INTO dbo.TJD_TIPOS_NOVEDADES_LINK (CODIGO, CODIGO_LINK, DESCRIPCION, PRIORIDAD, APLICA_PRIORIDAD, ACTUALIZA_BD, TZ_LOCK, ACCION)
VALUES (19, ''120001'', ''Reque alta titular'', 0, ''N'', ''S'', 0, ''A'')

INSERT INTO dbo.TJD_TIPOS_NOVEDADES_LINK (CODIGO, CODIGO_LINK, DESCRIPCION, PRIORIDAD, APLICA_PRIORIDAD, ACTUALIZA_BD, TZ_LOCK, ACCION)
VALUES (20, ''120002'', ''Reque alta adiciona'', 0, ''N'', ''S'', 0, ''A'')

INSERT INTO dbo.TJD_TIPOS_NOVEDADES_LINK (CODIGO, CODIGO_LINK, DESCRIPCION, PRIORIDAD, APLICA_PRIORIDAD, ACTUALIZA_BD, TZ_LOCK, ACCION)
VALUES (21, ''130001'', ''Reque modificación tarjeta '', 0, ''N'', ''S'', 0, ''M'')

INSERT INTO dbo.TJD_TIPOS_NOVEDADES_LINK (CODIGO, CODIGO_LINK, DESCRIPCION, PRIORIDAD, APLICA_PRIORIDAD, ACTUALIZA_BD, TZ_LOCK, ACCION)
VALUES (22, ''140001'', ''Baja raíz'', 0, ''N'', ''S'', 0, ''M'')

INSERT INTO dbo.TJD_TIPOS_NOVEDADES_LINK (CODIGO, CODIGO_LINK, DESCRIPCION, PRIORIDAD, APLICA_PRIORIDAD, ACTUALIZA_BD, TZ_LOCK, ACCION)
VALUES (23, ''140002'', ''Baja tarjeta'', 0, ''N'', ''S'', 0, ''M'')

INSERT INTO dbo.TJD_TIPOS_NOVEDADES_LINK (CODIGO, CODIGO_LINK, DESCRIPCION, PRIORIDAD, APLICA_PRIORIDAD, ACTUALIZA_BD, TZ_LOCK, ACCION)
VALUES (24, ''140003'', ''Bloqueo raíz'', 0, ''N'', ''S'', 0, ''M'')

INSERT INTO dbo.TJD_TIPOS_NOVEDADES_LINK (CODIGO, CODIGO_LINK, DESCRIPCION, PRIORIDAD, APLICA_PRIORIDAD, ACTUALIZA_BD, TZ_LOCK, ACCION)
VALUES (25, ''140004'', ''Bloqueo tarjeta'', 0, ''N'', ''S'', 0, ''M'')

INSERT INTO dbo.TJD_TIPOS_NOVEDADES_LINK (CODIGO, CODIGO_LINK, DESCRIPCION, PRIORIDAD, APLICA_PRIORIDAD, ACTUALIZA_BD, TZ_LOCK, ACCION)
VALUES (26, ''140010'', ''Bloqueo (USO RED LINK)'', 0, ''N'', ''S'', 0, ''M'')

INSERT INTO dbo.TJD_TIPOS_NOVEDADES_LINK (CODIGO, CODIGO_LINK, DESCRIPCION, PRIORIDAD, APLICA_PRIORIDAD, ACTUALIZA_BD, TZ_LOCK, ACCION)
VALUES (27, ''140011'', ''Cierre por Prevención (USO RED LINK)'', 0, ''N'', ''S'', 0, ''M'')

INSERT INTO dbo.TJD_TIPOS_NOVEDADES_LINK (CODIGO, CODIGO_LINK, DESCRIPCION, PRIORIDAD, APLICA_PRIORIDAD, ACTUALIZA_BD, TZ_LOCK, ACCION)
VALUES (28, ''140012'', ''Cambio de PIN obligatorio (USO RED LINK)'', 0, ''N'', ''S'', 0, ''M'')

INSERT INTO dbo.TJD_TIPOS_NOVEDADES_LINK (CODIGO, CODIGO_LINK, DESCRIPCION, PRIORIDAD, APLICA_PRIORIDAD, ACTUALIZA_BD, TZ_LOCK, ACCION)
VALUES (29, ''140013'', ''Solo Home Banking (USO RED LINK)'', 0, ''N'', ''S'', 0, ''M'')

INSERT INTO dbo.TJD_TIPOS_NOVEDADES_LINK (CODIGO, CODIGO_LINK, DESCRIPCION, PRIORIDAD, APLICA_PRIORIDAD, ACTUALIZA_BD, TZ_LOCK, ACCION)
VALUES (30, ''140021'', ''Cierre de tarjeta desde aplicación VALEpei'', 0, ''N'', ''S'', 0, ''M'')

INSERT INTO dbo.TJD_TIPOS_NOVEDADES_LINK (CODIGO, CODIGO_LINK, DESCRIPCION, PRIORIDAD, APLICA_PRIORIDAD, ACTUALIZA_BD, TZ_LOCK, ACCION)
VALUES (31, ''150001'', ''Consulta detallada tarjeta'', 0, ''N'', ''S'', 0, ''M'')

INSERT INTO dbo.TJD_TIPOS_NOVEDADES_LINK (CODIGO, CODIGO_LINK, DESCRIPCION, PRIORIDAD, APLICA_PRIORIDAD, ACTUALIZA_BD, TZ_LOCK, ACCION)
VALUES (32, ''170005'', ''Blanqueo PIN'', 0, ''N'', ''S'', 0, ''M'')

INSERT INTO dbo.TJD_TIPOS_NOVEDADES_LINK (CODIGO, CODIGO_LINK, DESCRIPCION, PRIORIDAD, APLICA_PRIORIDAD, ACTUALIZA_BD, TZ_LOCK, ACCION)
VALUES (33, ''180001'', ''Reimpresión plast.link soluc '', 0, ''N'', ''S'', 0, ''M'')

INSERT INTO dbo.TJD_TIPOS_NOVEDADES_LINK (CODIGO, CODIGO_LINK, DESCRIPCION, PRIORIDAD, APLICA_PRIORIDAD, ACTUALIZA_BD, TZ_LOCK, ACCION)
VALUES (34, ''180003'', ''Renovación automatica'', 0, ''N'', ''S'', 0, ''A'')

INSERT INTO dbo.TJD_TIPOS_NOVEDADES_LINK (CODIGO, CODIGO_LINK, DESCRIPCION, PRIORIDAD, APLICA_PRIORIDAD, ACTUALIZA_BD, TZ_LOCK, ACCION)
VALUES (35, ''190002'', ''Req nv con cbio de domicilio'', 0, ''N'', ''S'', 0, ''M'')

INSERT INTO dbo.TJD_TIPOS_NOVEDADES_LINK (CODIGO, CODIGO_LINK, DESCRIPCION, PRIORIDAD, APLICA_PRIORIDAD, ACTUALIZA_BD, TZ_LOCK, ACCION)
VALUES (36, ''190007'', ''New versión de tarj con conf(generada prog Autobloqueo)'', 0, ''N'', ''S'', 0, ''M'')

INSERT INTO dbo.TJD_TIPOS_NOVEDADES_LINK (CODIGO, CODIGO_LINK, DESCRIPCION, PRIORIDAD, APLICA_PRIORIDAD, ACTUALIZA_BD, TZ_LOCK, ACCION)
VALUES (37, ''190010'', ''Gen nueva version tarjeta por denuncia de robo/extravío'', 0, ''N'', ''S'', 0, ''A'')

INSERT INTO dbo.TJD_TIPOS_NOVEDADES_LINK (CODIGO, CODIGO_LINK, DESCRIPCION, PRIORIDAD, APLICA_PRIORIDAD, ACTUALIZA_BD, TZ_LOCK, ACCION)
VALUES (38, ''200002'', ''Habilitación de Tarjeta por VALE PEI'', 0, ''N'', ''S'', 0, ''M'')

INSERT INTO dbo.TJD_TIPOS_NOVEDADES_LINK (CODIGO, CODIGO_LINK, DESCRIPCION, PRIORIDAD, APLICA_PRIORIDAD, ACTUALIZA_BD, TZ_LOCK, ACCION)
VALUES (39, ''200004'', ''Desbloqueo de tarjeta'', 0, ''N'', ''S'', 0, ''M'')

INSERT INTO dbo.TJD_TIPOS_NOVEDADES_LINK (CODIGO, CODIGO_LINK, DESCRIPCION, PRIORIDAD, APLICA_PRIORIDAD, ACTUALIZA_BD, TZ_LOCK, ACCION)
VALUES (40, ''200005'', ''Habilitación de tarjeta a través de la aplicación VALEpei'', 0, ''N'', ''S'', 0, ''M'')

INSERT INTO dbo.TJD_TIPOS_NOVEDADES_LINK (CODIGO, CODIGO_LINK, DESCRIPCION, PRIORIDAD, APLICA_PRIORIDAD, ACTUALIZA_BD, TZ_LOCK, ACCION)
VALUES (41, ''210001'', ''Reque baja tarjeta titular'', 0, ''N'', ''S'', 0, ''M'')

INSERT INTO dbo.TJD_TIPOS_NOVEDADES_LINK (CODIGO, CODIGO_LINK, DESCRIPCION, PRIORIDAD, APLICA_PRIORIDAD, ACTUALIZA_BD, TZ_LOCK, ACCION)
VALUES (59, ''120005'', ''ALTA TARJETA TITULAR'', 0, ''N'', ''S'', 0, ''A'')

INSERT INTO dbo.ITF_MASTER (TZ_LOCK, ID, DESCRIPCION, OBJ_KETTLE, P0_MODO, P0_TIPO, P0_CAPTION, P0_CONSTANTE, P1_MODO, P1_TIPO, P1_CAPTION, P1_CONSTANTE, P2_MODO, P2_TIPO, P2_CAPTION, P2_CONSTANTE, P3_MODO, P3_TIPO, P3_CAPTION, P3_CONSTANTE, P4_MODO, P4_TIPO, P4_CAPTION, P4_CONSTANTE, P5_MODO, P5_TIPO, P5_CAPTION, P5_CONSTANTE, P6_MODO, P6_TIPO, P6_CAPTION, P6_CONSTANTE, P7_MODO, P7_TIPO, P7_CAPTION, P7_CONSTANTE, P8_MODO, P8_TIPO, P8_CONSTANTE, P8_CAPTION, P9_MODO, P9_TIPO, P9_CAPTION, P9_CONSTANTE, TIPO_OBJ, COMENTARIO, ID_REPORTE, MODO_EJECUCION)
VALUES (0, 124, ''2.14.1 LK TRX - Actualizacion BD replicada'', ''ITF_LINK_TRX.kjb'', ''P'', ''S'', ''Nombre Archivo'', '' '', ''P'', ''S'', ''Modo(F o R) '', '' '', '''', '''', '''', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', ''J'', '' '', 0, ''M'')

')