Execute('create table dbo.AFIP_CBUIN_ARCH 
(
	ANO numeric (4,0) default 0 not null , 
	MES numeric (2,0) default 0 not null , 
	SECUENCIA numeric (8,0) default 0 not null , 
	NOMBREARCH varchar(50) collate Modern_Spanish_CI_AS default '' '' not null , 
	FECHA datetime not null default GETDATE() , 
	TZ_LOCK numeric(15,0) default 0 not null , 
	constraint PK_AFIP_CBUIN_ARCH_01 PRIMARY KEY ( ANO , MES , SECUENCIA ) 
) ; 

create table dbo.AFIP_CBUIN_BITACORA 
(
	ANO numeric (4,0) default 0 not null , 
	MES numeric (2,0) default 0 not null , 
	SECUENCIA numeric (8,0) default 0 not null , 
	TRAMITE varchar(15) collate Modern_Spanish_CI_AS default '' '' not null , 
	CUIT varchar(11) collate Modern_Spanish_CI_AS default '' '' not null , 
	CBU varchar(22) collate Modern_Spanish_CI_AS default '' '' not null , 
	NROREG numeric (8,0) default 0 not null , 
	FECHAAFIP datetime not null , 
	VERIFICADOR varchar (1) collate Modern_Spanish_CI_AS default '' '' not null , 
	FECHACUENTA datetime null , 
	DETALLE varchar (255) collate Modern_Spanish_CI_AS default '' '' null , 
	TZ_LOCK numeric (15,0) default 0 not null , 
	constraint PK_AFIP_CBUIN_BITACORA_01 PRIMARY KEY ( ANO , MES , SECUENCIA , TRAMITE , CUIT , CBU , NROREG ) , 
	constraint FK_AFIP_CBUIN_BITACORA_ARCH FOREIGN KEY (ANO,MES,SECUENCIA) REFERENCES dbo.AFIP_CBUIN_ARCH(ANO,MES,SECUENCIA) ON DELETE CASCADE ON UPDATE NO ACTION 
) ; ')

Execute('create view dbo.VW_CBUIN_ANOS_ARCH 
as
select distinct ANO as "Año" 
from AFIP_CBUIN_ARCH ; ')

Execute('
--Descriptores
delete from dbo.DESCRIPTORES where IDENTIFICACION = 986 or IDENTIFICACION = 992;
insert into dbo.DESCRIPTORES values 
(930,986,null,''Archivos AFIP CBUIN'',0,''AFIP_CBUIN_ARCH'',''D'',null,null,''Top/Clientes'',null,''N''),
(930,992,null,''Bitacora AFIP CBUIN'',0,''AFIP_CBUIN_BITACORA'',''D'',null,null,''Top/Clientes'',null,''N'');


--Diccionario
delete from dbo.DICCIONARIO where (NUMERODECAMPO >= 98601 and NUMERODECAMPO <= 98699) or (NUMERODECAMPO >= 99201 and NUMERODECAMPO <= 99299);
insert into dbo.DICCIONARIO values 
(98601,'''',0,''AÑO'',''AÑO'',4,''N'',0,null,0,0,0,0,0,98660,0,986,''ANO'',0,null),
(98602,'''',0,''MES'',''MES'',2,''N'',0,null,0,0,0,0,0,0,0,986,''MES'',0,null),
(98603,'''',0,''SECUENCIA'',''SECUENCIA'',8,''N'',0,null,0,0,0,0,0,0,0,986,''SECUENCIA'',0,null),
(98604,'''',0,''Nombre Archivo'',''Nombre Archivo'',50,''A'',0,null,0,0,0,0,0,0,0,986,''NOMBREARCH'',0,null),
(98605,'''',0,''Fecha Proceso'',''Fecha Proceso'',8,''F'',0,''F'',0,0,0,0,0,0,0,986,''FECHA'',0,null),
(98650,'''',0,''Grilla Archivos CBUIN'',''Grilla Archivos'',8,''N'',0,null,0,0,0,0,0,98601,0,0,''C98650'',0,null),
(98660,'''',0,''Selector Mes'',''Mes'',2,''N'',0,null,0,0,0,0,0,0,1,0,''C98660'',0,null),
(99201,'''',0,''AÑO'',''AÑO'',4,''N'',0,null,0,0,0,0,0,0,0,992,''ANO'',0,null),
(99202,'''',0,''MES'',''MES'',2,''N'',0,null,0,0,0,0,0,0,0,992,''MES'',0,null),
(99203,'''',0,''SECUENCIA'',''SECUENCIA'',8,''N'',0,null,0,0,0,0,0,0,0,992,''SECUENCIA'',0,null),
(99204,'''',0,''TRAMITE'',''TRAMITE'',15,''A'',0,null,0,0,0,0,0,0,0,992,''TRAMITE'',0,null),
(99205,'''',0,''CUIT'',''CUIT'',11,''A'',0,null,0,0,0,0,0,0,0,992,''CUIT'',0,null),
(99206,'''',0,''CBU'',''CBU'',22,''A'',0,null,0,0,0,0,0,0,0,992,''CBU'',0,null),
(99207,'''',0,''Numero Registro'',''Numero Registro'',8,''N'',0,null,0,0,0,0,0,0,0,992,''NROREG'',0,null),
(99208,'''',0,''Fecha AFIP'',''Fecha AFIP'',8,''F'',0,''F'',0,0,0,0,0,0,0,992,''FECHAAFIP'',0,null),
(99209,'''',0,''Verificador'',''Verif.'',1,''A'',0,null,0,0,0,0,0,0,0,992,''VERIFICADOR'',0,null),
(99210,'''',0,''Fecha Cuenta'',''Fecha Cuenta'',8,''F'',0,''F'',0,0,0,0,0,0,0,992,''FECHACUENTA'',0,null),
(99211,'''',0,''Detalle'',''Detalle Val.'',255,''A'',0,null,0,0,0,0,0,0,0,992,''DETALLE'',0,null),
(99250,'''',0,''Grilla Registros CBUIN'',''Grilla Registros'',8,''N'',0,null,0,0,0,0,0,99201,0,0,''C99250'',0,null);


--Indices
delete from dbo.INDICES where NUMERODEARCHIVO = 986 or NUMERODEARCHIVO = 992;
insert into dbo.INDICES values 
(986,1,''PK_AFIP_CBUIN_ARCH'',0,98601,98602,98603,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
(986,2,''Buscar_ANO_MES'',1,98601,98602,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
(986,3,''Buscar_ANO'',1,98601,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
(992,1,''PK_AFIP_CBUIN_BITACORA'',0,99201,99202,99203,99204,99205,99206,99207,null,null,null,null,null,null,null,null,null,null,null,null,null),
(992,2,''Buscar_ANO_MES_SECUENCIA'',1,99201,99202,99203,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null);


--Opciones
delete from dbo.OPCIONES where NUMERODECAMPO = 98660;
insert into dbo.OPCIONES values 
(98660,''E'',''Todos'',''0'',''00''),
(98660,''E'',''Enero'',''1'',''01''),
(98660,''E'',''Febrero'',''2'',''02''),
(98660,''E'',''Marzo'',''3'',''03''),
(98660,''E'',''Abril'',''4'',''04''),
(98660,''E'',''Mayo'',''5'',''05''),
(98660,''E'',''Junio'',''6'',''06''),
(98660,''E'',''Julio'',''7'',''07''),
(98660,''E'',''Agosto'',''8'',''08''),
(98660,''E'',''Septiembre'',''9'',''09''),
(98660,''E'',''Octubre'',''10'',''10''),
(98660,''E'',''Noviembre'',''11'',''11''),
(98660,''E'',''Diciembre'',''12'',''12'');


--Ayudas
delete from dbo.AYUDAS where NUMERODEAYUDA in (98601, 98660, 99201);
insert into dbo.AYUDAS values 
(986,98601,''Grilla Elegir Archivo'','''',0,''98605;98602ROA1;98603ROA2;98604;98601I;'',null,null,null,0),
(992,99201,''Grilla Elegir Registro'','''',0,''99204R;99205R;99206R;99208;99209;99210;99207ROA1;99211;99201I;99202I;99203I;'',null,null,null,0),
(0,98660,''CBUIN ARCH Años Disponibles'','''',0,''98601ROD1;'',''Año;'',''Top/Clientes'',''VW_CBUIN_ANOS_ARCH'',0);


--Operaciones
delete from dbo.OPERACIONES where IDENTIFICACION = 6801;
insert into dbo.OPERACIONES values 
(6800,6801,''Validador AFIP - CUIT/CBU'',''Validador AFIP - CUIT/CBU'',''6801'',''N'',null,null,''P'',0,null,0,''S'',''N'',''N'',''S'',''N'',null,0);

--Interfaces 
delete from dbo.ITF_MASTER where ID = 131;
insert into dbo.ITF_MASTER values 
(0,131,''AFIP Validador CBU/CUIT'',''ITF_AFIP_VALIDADOR_CBU_CUIT.kjb'',''P'',''S'',''Nombre Archivo'','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '','' '',''J'',''Validador de CBU y CUIT AFIP'',0,''M'');')