insert into cli_perfildocumental (id_persona, promedio_sueldos, FECHA_ACTUALIZACION, INGRESOS_ANUALES, ORIGEN)
select numeropersonafisica, 0, SYSDATETIME(), 0, 'S' from cli_personasfisicas where NUMEROPERSONAFISICA > 1000000

insert into cli_perfildocumental (id_persona, promedio_sueldos, FECHA_ACTUALIZACION, INGRESOS_ANUALES, ORIGEN)
select numeropersonajuridica, 0, SYSDATETIME(), 0, 'S' from cli_personasjuridicas where NUMEROPERSONAJURIDICA > 1000000