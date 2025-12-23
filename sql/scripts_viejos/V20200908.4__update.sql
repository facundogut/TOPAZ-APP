update NUMERATORDEFINITION set PERIODO = 'P', CENTRALIZADO = 1 where NUMERO = 36022;
delete from NUMERATORVALUES where numero = 36022;
insert into NUMERATORVALUES (dia, mes, anio, sucursal, numero, valor) values (0, 0, 0, 0, 36022, (select isnull(max(ID),0) + 1 from CLI_VINCULACIONES));
go

update NUMERATORDEFINITION set PERIODO = 'P', CENTRALIZADO = 1 where NUMERO = 36065;
delete from NUMERATORVALUES where numero = 36065;
insert into NUMERATORVALUES (dia, mes, anio, sucursal, numero, valor) values (0, 0, 0, 0, 36065, (select isnull(max(NUMEROPERSONAJURIDICA),0) + 1 from CLI_VINCULADOSJURIDICOS));
go
