--------------------------------------------------------------------------------------------------------------------------------
-- Arquitectura                                                                                                               --
--------------------------------------------------------------------------------------------------------------------------------

-- Tablas ----------------------------------------------------------------------------------------------------------------------

-- CLI_Vinculos_Primarios
create table CLI_VINCULOS_PRIMARIOS (
  TZ_LOCK     numeric(16) default (0) not null,
  ID          numeric(3)  not null,
  DESCRIPCION varchar(80) not null,
  TIPO        varchar(1)  not null,
  constraint PK_CLI_VINCULOS_PRIMARIOS primary key (ID)
);
go

-- CLI_Vinculos_Secundarios
create table CLI_VINCULOS_SECUNDARIOS (
  TZ_LOCK     numeric(16) default (0) not null,
  ID          numeric(3)  not null,
  DESCRIPCION varchar(80) not null,
  TIPO        varchar(1)  not null,
  MODALIDAD   varchar(1)  not null,
  VIGENCIA    numeric(2)  default (0) not null,
  constraint PK_CLI_VINCULOS_SECUNDARIOS primary key (ID)
);
go

-- CLI_Roles
create table CLI_ROLES (
  TZ_LOCK        numeric(16) default (0) not null,
  ID             numeric(3)  not null,
  DESCRIPCION    varchar(80) not null,
  TIPO_ROL       numeric(2)  not null,
  TIPO_PERSONA   varchar(1)  not null,
  GRADO          numeric(1)  not null,
  GRUPO_PRIMARIO varchar(1)  not null,
  CANTIDAD       numeric(2)  default (0) not null,
  constraint PK_CLI_ROLES primary key (ID)
);
go

-- CLI_Vinculos
create table CLI_VINCULOS (
  TZ_LOCK               numeric(16) default (0) not null,
  ID                    varchar(2)  not null,
  DESCRIPCION           varchar(80) not null,
  VINCULO_PRIMARIO      numeric(3)  not null,
  VINCULO_SECUNDARIO    numeric(3)  not null,
  TIPO_ROL              numeric(2)  not null,
  NIVEL_MINIMO_APERTURA numeric(1)  not null
  constraint PK_CLI_VINCULOS primary key (ID)
);
go

-- CLI_Vinculaciones
create table CLI_VINCULACIONES (
  TZ_LOCK                 numeric(16)   default (0) not null,
  ID                      numeric(16)   not null,  
  TIPO_PERSONA_VINCULANTE varchar(1)    not null,
  PERSONA_VINCULANTE      numeric(12)   not null,
  TIPO_PERSONA_VINCULADA  varchar(1)    not null,
  PERSONA_VINCULADA       numeric(12)   not null,
  ROL                     numeric(3)    not null,
  VINCULO                 varchar(2)    not null,
  GRUPO_PRIMARIO          varchar(1)    not null,
  FECHA_INICIO            datetime      not null,
  FECHA_FIN               datetime,
  REGISTRO                varchar(1)    not null,
  constraint PK_CLI_VINCULACIONES primary key (ID)
);
go

-- CLI_Riesgos_Crediticios
create table CLI_RIESGOS_CREDITICIOS (
  TZ_LOCK                 numeric(16)   default (0) not null,
  ID                      numeric(16)   not null,
  DEUDA                   numeric(15,2) default (0) not null,
  FECHA_INICIO            datetime      not null,
  FECHA_FIN               datetime,
  FECHA_DESVINCULACION    datetime,
  ACTUALIZACION           varchar(1)    not null,
  constraint PK_CLI_RIESGOS_CREDITICIOS primary key (ID)
);
go

-- CLI_VinculadosJuridicos
create table CLI_VINCULADOSJURIDICOS (
  TZ_LOCK                 numeric(16)   default (0) not null,
  NUMEROPERSONAJURIDICA   numeric(12,0) not null,
  TIPODOCUMENTO           varchar (4)   not null,
  NUMERODOCUMENTO         varchar (20)  not null,
  RAZONSOCIAL             varchar (70)  not null,
  TIPO_PERSONA            varchar(1)    not null,
  constraint PK_CLI_VINCULADOSJURIDICOS primary key (NUMEROPERSONAJURIDICA)
);
go

-- Vistas ----------------------------------------------------------------------------------------------------------------------

-- VW_Vinculaciones
create view VW_VINCULACIONES as
  select
    vi.ID,
    vi.TIPO_PERSONA_VINCULANTE as TP_VINCULANTE,
    d1.TIPODOCUMENTO as TD_VINCULANTE,
    d1.NUMERODOCUMENTO as DOC_VINCULANTE,
    case vi.TIPO_PERSONA_VINCULANTE
      when 'F' then
        (select
          concat(f.APELLIDOPATERNO, ' ', f.PRIMERNOMBRE)
        from
          CLI_PERSONASFISICAS f
        where
          (vi.TZ_LOCK < 300000000000000 or vi.TZ_LOCK >= 400000000000000) and (vi.TZ_LOCK < 100000000000000 or vi.TZ_LOCK >= 200000000000000)
          and (f.TZ_LOCK < 300000000000000 or f.TZ_LOCK >= 400000000000000) and (f.TZ_LOCK < 100000000000000 or f.TZ_LOCK >= 200000000000000)
          and f.NUMEROPERSONAFISICA = vi.PERSONA_VINCULANTE)
      else
       (select
         j.RAZONSOCIAL
       from
         CLI_PERSONASJURIDICAS j
       where
         (vi.TZ_LOCK < 300000000000000 or vi.TZ_LOCK >= 400000000000000) and (vi.TZ_LOCK < 100000000000000 or vi.TZ_LOCK >= 200000000000000)
         and (j.TZ_LOCK < 300000000000000 or j.TZ_LOCK >= 400000000000000) and (j.TZ_LOCK < 100000000000000 or j.TZ_LOCK >= 200000000000000)
         and j.NUMEROPERSONAJURIDICA = vi.PERSONA_VINCULANTE)
    end VINCULANTE,
    vi.TIPO_PERSONA_VINCULADA as TP_VINCULADO,
    d2.TIPODOCUMENTO as TD_VINCULADO,
    d2.NUMERODOCUMENTO as DOC_VINCULADO,
    case vi.TIPO_PERSONA_VINCULADA
      when 'F' then
        (select
          concat(f.APELLIDOPATERNO, ' ', f.PRIMERNOMBRE)
        from
          CLI_PERSONASFISICAS f
        where
          (vi.TZ_LOCK < 300000000000000 or vi.TZ_LOCK >= 400000000000000) and (vi.TZ_LOCK < 100000000000000 or vi.TZ_LOCK >= 200000000000000)
          and (f.TZ_LOCK < 300000000000000 or f.TZ_LOCK >= 400000000000000) and (f.TZ_LOCK < 100000000000000 or f.TZ_LOCK >= 200000000000000)
          and f.NUMEROPERSONAFISICA = vi.PERSONA_VINCULADA)
     else
       (select
         j.RAZONSOCIAL
       from
         CLI_PERSONASJURIDICAS j
       where
         (vi.TZ_LOCK < 300000000000000 or vi.TZ_LOCK >= 400000000000000) and (vi.TZ_LOCK < 100000000000000 or vi.TZ_LOCK >= 200000000000000)
         and (j.TZ_LOCK < 300000000000000 or j.TZ_LOCK >= 400000000000000) and (j.TZ_LOCK < 100000000000000 or j.TZ_LOCK >= 200000000000000)
         and j.NUMEROPERSONAJURIDICA = vi.PERSONA_VINCULADA)
    end VINCULADO,
    vi.ROL,
    vi.VINCULO,
    vs.MODALIDAD,
    vi.GRUPO_PRIMARIO
  from
    CLI_VINCULACIONES vi
    inner join CLI_DOCUMENTOSPFPJ d1 on d1.NUMEROPERSONAFJ = vi.PERSONA_VINCULANTE
    inner join CLI_DOCUMENTOSPFPJ d2 on d2.NUMEROPERSONAFJ = vi.PERSONA_VINCULADA
    inner join CLI_VINCULOS vc on vc.ID = vi.VINCULO
    inner join CLI_VINCULOS_SECUNDARIOS vs on vs.ID = vc.VINCULO_SECUNDARIO
  where
    (vi.TZ_LOCK < 300000000000000 or vi.TZ_LOCK >= 400000000000000) and (vi.TZ_LOCK < 100000000000000 or vi.TZ_LOCK >= 200000000000000)
    and (d1.TZ_LOCK < 300000000000000 or d1.TZ_LOCK >= 400000000000000) and (d1.TZ_LOCK < 100000000000000 or d1.TZ_LOCK >= 200000000000000)
    and (d2.TZ_LOCK < 300000000000000 or d2.TZ_LOCK >= 400000000000000) and (d2.TZ_LOCK < 100000000000000 or d2.TZ_LOCK >= 200000000000000)
    and (vc.TZ_LOCK < 300000000000000 or vc.TZ_LOCK >= 400000000000000) and (vc.TZ_LOCK < 100000000000000 or vc.TZ_LOCK >= 200000000000000)
    and (vs.TZ_LOCK < 300000000000000 or vs.TZ_LOCK >= 400000000000000) and (vs.TZ_LOCK < 100000000000000 or vs.TZ_LOCK >= 200000000000000)
	and vi.REGISTRO = 'C'
  union all
  select
    vi.ID,
    vi.TIPO_PERSONA_VINCULANTE as TP_VINCULANTE,
    d1.TIPODOCUMENTO as TD_VINCULANTE,
    d1.NUMERODOCUMENTO as DOC_VINCULANTE,
    case vi.TIPO_PERSONA_VINCULANTE
      when 'F' then
        (select
          concat(f.APELLIDOPATERNO, ' ', f.PRIMERNOMBRE)
        from
          CLI_PERSONASFISICAS f
        where
          (vi.TZ_LOCK < 300000000000000 or vi.TZ_LOCK >= 400000000000000) and (vi.TZ_LOCK < 100000000000000 or vi.TZ_LOCK >= 200000000000000)
          and (f.TZ_LOCK < 300000000000000 or f.TZ_LOCK >= 400000000000000) and (f.TZ_LOCK < 100000000000000 or f.TZ_LOCK >= 200000000000000)
          and f.NUMEROPERSONAFISICA = vi.PERSONA_VINCULANTE)
      else
       (select
         j.RAZONSOCIAL
       from
         CLI_PERSONASJURIDICAS j
       where
         (vi.TZ_LOCK < 300000000000000 or vi.TZ_LOCK >= 400000000000000) and (vi.TZ_LOCK < 100000000000000 or vi.TZ_LOCK >= 200000000000000)
         and (j.TZ_LOCK < 300000000000000 or j.TZ_LOCK >= 400000000000000) and (j.TZ_LOCK < 100000000000000 or j.TZ_LOCK >= 200000000000000)
         and j.NUMEROPERSONAJURIDICA = vi.PERSONA_VINCULANTE)
    end VINCULANTE,
    vi.TIPO_PERSONA_VINCULADA as TP_VINCULADO,
    d2.TIPODOCUMENTO as TD_VINCULADO,
    d2.NUMERODOCUMENTO as DOC_VINCULADO,
    d2.RAZONSOCIAL as VINCULADO,
    vi.ROL,
    vi.VINCULO,
    vs.MODALIDAD,
    vi.GRUPO_PRIMARIO
  from
    CLI_VINCULACIONES vi
    inner join CLI_DOCUMENTOSPFPJ d1 on d1.NUMEROPERSONAFJ = vi.PERSONA_VINCULANTE
    inner join CLI_VINCULADOSJURIDICOS d2 on d2.NUMEROPERSONAJURIDICA = vi.PERSONA_VINCULADA
    inner join CLI_VINCULOS vc on vc.ID = vi.VINCULO
    inner join CLI_VINCULOS_SECUNDARIOS vs on vs.ID = vc.VINCULO_SECUNDARIO
  where
    (vi.TZ_LOCK < 300000000000000 or vi.TZ_LOCK >= 400000000000000) and (vi.TZ_LOCK < 100000000000000 or vi.TZ_LOCK >= 200000000000000)
    and (d1.TZ_LOCK < 300000000000000 or d1.TZ_LOCK >= 400000000000000) and (d1.TZ_LOCK < 100000000000000 or d1.TZ_LOCK >= 200000000000000)
    and (d2.TZ_LOCK < 300000000000000 or d2.TZ_LOCK >= 400000000000000) and (d2.TZ_LOCK < 100000000000000 or d2.TZ_LOCK >= 200000000000000)
    and (vc.TZ_LOCK < 300000000000000 or vc.TZ_LOCK >= 400000000000000) and (vc.TZ_LOCK < 100000000000000 or vc.TZ_LOCK >= 200000000000000)
    and (vs.TZ_LOCK < 300000000000000 or vs.TZ_LOCK >= 400000000000000) and (vs.TZ_LOCK < 100000000000000 or vs.TZ_LOCK >= 200000000000000)
	and vi.REGISTRO = 'V';
go

-- VW_Vinculados
create view VW_VINCULADOS as
  select
    vi.PERSONA_VINCULADA,
    vp.TIPO,
	vc.TIPO_ROL,
    vi.FECHA_INICIO,
    vi.FECHA_FIN
  from
    CLI_VINCULACIONES vi
    inner join CLI_VINCULOS vc on vc.ID = vi.VINCULO
    inner join CLI_VINCULOS_PRIMARIOS vp on vp.ID = vc.VINCULO_PRIMARIO
  where
    (vi.TZ_LOCK < 300000000000000 or vi.TZ_LOCK >= 400000000000000) and (vi.TZ_LOCK < 100000000000000 or vi.TZ_LOCK >= 200000000000000)
    and (vc.TZ_LOCK < 300000000000000 or vc.TZ_LOCK >= 400000000000000) and (vc.TZ_LOCK < 100000000000000 or vc.TZ_LOCK >= 200000000000000)
    and (vp.TZ_LOCK < 300000000000000 or vp.TZ_LOCK >= 400000000000000) and (vp.TZ_LOCK < 100000000000000 or vp.TZ_LOCK >= 200000000000000)
    and vi.REGISTRO = 'C'
	and vp.TIPO <> 'C';
go

-- VW_Vinculos
create view VW_VINCULOS as
  select
    vc.ID,
    vc.DESCRIPCION,
    vs.TIPO,
    vc.TIPO_ROL,
    vc.NIVEL_MINIMO_APERTURA,
    vs.MODALIDAD,
    vs.VIGENCIA
  from
    CLI_VINCULOS vc
    inner join CLI_VINCULOS_SECUNDARIOS vs on vs.ID = vc.VINCULO_SECUNDARIO
  where
    (vc.TZ_LOCK < 300000000000000 or vc.TZ_LOCK >= 400000000000000) and (vc.TZ_LOCK < 100000000000000 or vc.TZ_LOCK >= 200000000000000)
    and (vs.TZ_LOCK < 300000000000000 or vs.TZ_LOCK >= 400000000000000) and (vs.TZ_LOCK < 100000000000000 or vs.TZ_LOCK >= 200000000000000);
go

-- VW_PersonasFisicas
create view VW_PERSONASFISICAS as
  select
    d.TIPODOCUMENTO,
    d.NUMERODOCUMENTO,
    d.NUMEROPERSONAFJ,
    f.APELLIDOPATERNO,
    f.APELLIDOMATERNO,
    f.PRIMERNOMBRE,
    f.SEGUNDONOMBRE,
	f.NIVEL_APERTURA as APERTURA
  from
    CLI_DOCUMENTOSPFPJ d
    inner join CLI_PERSONASFISICAS f on d.TIPOPERSONA = 'F' and d.NUMEROPERSONAFJ = f.NUMEROPERSONAFISICA
  where
    (d.TZ_LOCK < 300000000000000 or d.TZ_LOCK >= 400000000000000) and (d.TZ_LOCK < 100000000000000 or d.TZ_LOCK >= 200000000000000)
    and (f.TZ_LOCK < 300000000000000 or f.TZ_LOCK >= 400000000000000) and (f.TZ_LOCK < 100000000000000 or f.TZ_LOCK >= 200000000000000);
go

-- VW_PersonasJuridicas
create view VW_PERSONASJURIDICAS as
  select
    d.TIPODOCUMENTO,
    d.NUMERODOCUMENTO,
    d.NUMEROPERSONAFJ,
    j.RAZONSOCIAL,
	j.NIVEL_APERTURA as APERTURA
  from
    CLI_DOCUMENTOSPFPJ d
    inner join CLI_PERSONASJURIDICAS j on d.TIPOPERSONA = 'J' and d.NUMEROPERSONAFJ = j.NUMEROPERSONAJURIDICA
  where
    (d.TZ_LOCK < 300000000000000 or d.TZ_LOCK >= 400000000000000) and (d.TZ_LOCK < 100000000000000 or d.TZ_LOCK >= 200000000000000)
    and (j.TZ_LOCK < 300000000000000 or j.TZ_LOCK >= 400000000000000) and (j.TZ_LOCK < 100000000000000 or j.TZ_LOCK >= 200000000000000)
    and j.NIVEL_APERTURA < 4
  union all
  select
    v.TIPODOCUMENTO,
    v.NUMERODOCUMENTO,
    v.NUMEROPERSONAJURIDICA as NUMEROPERSONAFJ,
    v.RAZONSOCIAL,
	0 as APERTURA
  from
    CLI_VINCULADOSJURIDICOS v
  where
    (v.TZ_LOCK < 300000000000000 or v.TZ_LOCK >= 400000000000000) and (v.TZ_LOCK < 100000000000000 or v.TZ_LOCK >= 200000000000000)
    and v.TIPO_PERSONA = 'J';
go

-- VW_InstitucionesFinancieras
create view VW_INSTITUCIONESFINANCIERAS as
  select
    d.TIPODOCUMENTO,
    d.NUMERODOCUMENTO,
    d.NUMEROPERSONAFJ,
    j.RAZONSOCIAL,
	j.NIVEL_APERTURA as APERTURA
  from
    CLI_DOCUMENTOSPFPJ d
    inner join CLI_PERSONASJURIDICAS j on d.TIPOPERSONA = 'J' and d.NUMEROPERSONAFJ = j.NUMEROPERSONAJURIDICA
  where
    (d.TZ_LOCK < 300000000000000 or d.TZ_LOCK >= 400000000000000) and (d.TZ_LOCK < 100000000000000 or d.TZ_LOCK >= 200000000000000)
    and (j.TZ_LOCK < 300000000000000 or j.TZ_LOCK >= 400000000000000) and (j.TZ_LOCK < 100000000000000 or j.TZ_LOCK >= 200000000000000)
    and j.NIVEL_APERTURA = 4
  union all
  select
    v.TIPODOCUMENTO,
    v.NUMERODOCUMENTO,
    v.NUMEROPERSONAJURIDICA as NUMEROPERSONAFJ,
    v.RAZONSOCIAL,
	0 as APERTURA
  from
    CLI_VINCULADOSJURIDICOS v
  where
    (v.TZ_LOCK < 300000000000000 or v.TZ_LOCK >= 400000000000000) and (v.TZ_LOCK < 100000000000000 or v.TZ_LOCK >= 200000000000000)
    and v.TIPO_PERSONA = 'I';
go
