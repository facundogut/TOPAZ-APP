--------------------------------------------------------------------------------------------------------------------------------
-- Arquitectura                                                                                                               --
--------------------------------------------------------------------------------------------------------------------------------

-- Tablas ----------------------------------------------------------------------------------------------------------------------

drop table if exists CLI_VINCULOS_PRIMARIOS;
drop table if exists CLI_VINCULOS_SECUNDARIOS;
drop table if exists CLI_ROLES;
drop table if exists CLI_VINCULOS;
drop table if exists CLI_VINCULACIONES;
drop table if exists CLI_RIESGOS_CREDITICIOS;
drop table if exists CLI_VINCULADOSJURIDICOS;
go

-- Vistas ----------------------------------------------------------------------------------------------------------------------

drop view if exists VW_VINCULACIONES;
drop view if exists VW_VINCULADOS;
drop view if exists VW_VINCULOS;
drop view if exists VW_PERSONASFISICAS;
drop view if exists VW_PERSONASJURIDICAS
drop view if exists VW_INSTITUCIONESFINANCIERAS;
go

--------------------------------------------------------------------------------------------------------------------------------
-- Diccionario                                                                                                                --
--------------------------------------------------------------------------------------------------------------------------------

-- Tablas ----------------------------------------------------------------------------------------------------------------------

-- CLI_Vinculos_Primarios
delete from AYUDAS       where NUMERODEARCHIVO = 3601;
delete from INDICES      where NUMERODEARCHIVO = 3601;
delete from OPCIONES     where NUMERODECAMPO between 36001 and 36003;
delete from DICCIONARIO  where NUMERODECAMPO between 36001 and 36003;
delete from DESCRIPTORES where IDENTIFICACION = 3601;
go

-- CLI_Vinculos_Secundarios
delete from AYUDAS       where NUMERODEARCHIVO = 3602;
delete from INDICES      where NUMERODEARCHIVO = 3602;
delete from OPCIONES     where NUMERODECAMPO between 36004 and 36008;
delete from DICCIONARIO  where NUMERODECAMPO between 36004 and 36008;
delete from DESCRIPTORES where IDENTIFICACION = 3602;
go

-- CLI_Roles
delete from AYUDAS       where NUMERODEARCHIVO = 3603;
delete from INDICES      where NUMERODEARCHIVO = 3603;
delete from OPCIONES     where NUMERODECAMPO between 36009 and 36015;
delete from DICCIONARIO  where NUMERODECAMPO between 36009 and 36015;
delete from DESCRIPTORES where IDENTIFICACION = 3603;
go

-- CLI_Vinculos
delete from AYUDAS       where NUMERODEARCHIVO = 3604;
delete from INDICES      where NUMERODEARCHIVO = 3604;
delete from OPCIONES     where NUMERODECAMPO between 36016 and 36021;
delete from DICCIONARIO  where NUMERODECAMPO between 36016 and 36021;
delete from DESCRIPTORES where IDENTIFICACION = 3604;
go

-- CLI_Vinculaciones
delete from AYUDAS       where NUMERODEARCHIVO = 3605;
delete from INDICES      where NUMERODEARCHIVO = 3605;
delete from OPCIONES     where NUMERODECAMPO between 36022 and 36033;
delete from DICCIONARIO  where NUMERODECAMPO between 36022 and 36033;
delete from DESCRIPTORES where IDENTIFICACION = 3605;
go

-- CLI_Riesgos_Crediticios
delete from AYUDAS       where NUMERODEARCHIVO = 3606;
delete from INDICES      where NUMERODEARCHIVO = 3606;
delete from OPCIONES     where NUMERODECAMPO between 36034 and 36039;
delete from DICCIONARIO  where NUMERODECAMPO between 36034 and 36039;
delete from DESCRIPTORES where IDENTIFICACION = 3606;
go

-- CLI_VinculadosJuridicos
delete from AYUDAS       where NUMERODEARCHIVO = 3610;
delete from INDICES      where NUMERODEARCHIVO = 3610;
delete from OPCIONES     where NUMERODECAMPO between 36065 and 36070;
delete from DICCIONARIO  where NUMERODECAMPO between 36065 and 36070;
delete from DESCRIPTORES where IDENTIFICACION = 3610;
go

-- Vistas ----------------------------------------------------------------------------------------------------------------------

-- VW_Vinculaciones
delete from AYUDAS       where NUMERODEARCHIVO = 3607;
delete from INDICES      where NUMERODEARCHIVO = 3607;
delete from OPCIONES     where NUMERODECAMPO between 36040 and 36052;
delete from DICCIONARIO  where NUMERODECAMPO between 36040 and 36052;
delete from DESCRIPTORES where IDENTIFICACION = 3607;
go

-- VW_Vinculados
delete from AYUDAS       where NUMERODEARCHIVO = 3608;
delete from INDICES      where NUMERODEARCHIVO = 3608;
delete from OPCIONES     where NUMERODECAMPO between 36053 and 36057;
delete from DICCIONARIO  where NUMERODECAMPO between 36053 and 36057;
delete from DESCRIPTORES where IDENTIFICACION = 3608;
go

-- VW_Vinculos
delete from AYUDAS       where NUMERODEARCHIVO = 3609;
delete from INDICES      where NUMERODEARCHIVO = 3609;
delete from OPCIONES     where NUMERODECAMPO between 36058 and 36064;
delete from DICCIONARIO  where NUMERODECAMPO between 36058 and 36064;
delete from DESCRIPTORES where IDENTIFICACION = 3609;
go

-- VW_PersonasFisicas
delete from AYUDAS       where NUMERODEARCHIVO = 287;
delete from INDICES      where NUMERODEARCHIVO = 287;
delete from OPCIONES     where NUMERODECAMPO in (3001,3002,3003,3004,3005,3006,3007,1959);
delete from DICCIONARIO  where NUMERODECAMPO in (3001,3002,3003,3004,3005,3006,3007,1959);
delete from DESCRIPTORES where IDENTIFICACION = 287;
go

-- VW_PersonasJuridicas
delete from AYUDAS       where NUMERODEARCHIVO = 288;
delete from INDICES      where NUMERODEARCHIVO = 288;
delete from OPCIONES     where NUMERODECAMPO in (3008,3009,3010,3011,3021);
delete from DICCIONARIO  where NUMERODECAMPO in (3008,3009,3010,3011,3021);
delete from DESCRIPTORES where IDENTIFICACION = 288;
go

-- VW_InstitucionesFinancieras
delete from AYUDAS       where NUMERODEARCHIVO = 289;
delete from INDICES      where NUMERODEARCHIVO = 289;
delete from OPCIONES     where NUMERODECAMPO in (3012,3013,3014,3015,3022);
delete from DICCIONARIO  where NUMERODECAMPO in (3012,3013,3014,3015,3022);
delete from DESCRIPTORES where IDENTIFICACION = 289;
go

-- Ayudas ----------------------------------------------------------------------------------------------------------------------

-- CLI_PersonasFisicas
delete from AYUDAS       where NUMERODEARCHIVO = 14 and NUMERODEAYUDA = 144;
delete from DICCIONARIO  where NUMERODECAMPO between 1395 and 1396;
go

-- CLI_PersonaJuridicas
delete from AYUDAS       where NUMERODEARCHIVO = 19 and NUMERODEAYUDA = 194;
delete from DICCIONARIO  where NUMERODECAMPO between 1397 and 1398;
go

-- CLI_DocumentosPFPJ
delete from DICCIONARIO  where NUMERODECAMPO = 1132;
go

-- VW_PersonasFisicas
delete from DICCIONARIO  where NUMERODECAMPO = 3018;
go

-- VW_PersonasJuridicas
delete from DICCIONARIO  where NUMERODECAMPO = 3019;
go

-- VW_PersonasJuridicas
delete from DICCIONARIO  where NUMERODECAMPO = 3020;
go

--------------------------------------------------------------------------------------------------------------------------------
-- Macros                                                                                                                     --
--------------------------------------------------------------------------------------------------------------------------------

-- CLI_Vinculaciones
delete from MACROR where PROCESO in (365,366);
go

-- CLI_PersonasFisicas
delete from MACROR where PROCESO = 361;
go

--CLI_PersonasJuridicas
delete from MACROR where PROCESO = 362;
go

-- VW_PersonasFisicas
delete from MACROR where PROCESO in (287,290);
go

-- VW_PersonasJuridicas
delete from MACROR where PROCESO in (288,291);
go

-- VW_InstitucionFinanciera
delete from MACROR where PROCESO in (289,292);
go

--------------------------------------------------------------------------------------------------------------------------------
-- Operaciones                                                                                                                --
--------------------------------------------------------------------------------------------------------------------------------

-- Operaciones
delete from OPERACIONES where IDENTIFICACION between 3671 and 3676;
go

-- Título
delete from OPERACIONES where TITULO = 1003 and IDENTIFICACION = 0;
go
