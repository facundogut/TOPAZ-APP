--------------------------------------------------------------------------------------------------------------------------------
-- Macros                                                                                                                     --
--------------------------------------------------------------------------------------------------------------------------------

-- CLI_Vinculaciones
insert into MACROR    (PROCESO, ORDINAL, ARCHIVO, INDICE, CONDICION, RECEPTOR, FORMULA)
values                (365, 0, 3605, 2, 'CLI_Vinculaciones', NULL, NULL);
insert into MACROR    (PROCESO, ORDINAL, ARCHIVO, INDICE, CONDICION, RECEPTOR, FORMULA)
values                (365, 1, 3605, 2, 'C36025=C617YC36028=C616', 'C631', 'C631+1');
insert into MACROR    (PROCESO, ORDINAL, ARCHIVO, INDICE, CONDICION, RECEPTOR, FORMULA)
values                (366, 0, 3605, 3, 'CLI_Vinculaciones', NULL, NULL);
insert into MACROR    (PROCESO, ORDINAL, ARCHIVO, INDICE, CONDICION, RECEPTOR, FORMULA)
values                (366, 1, 3605, 3, 'C36025=C617YC36027=C618', 'C631', 'C631+1');
go

-- CLI_PersonasFisicas
insert into MACROR    (PROCESO, ORDINAL, ARCHIVO, INDICE, CONDICION, RECEPTOR, FORMULA)
values                (361, 0, 14, 1, 'CLI_PersonasFisicas', NULL, NULL);
insert into MACROR    (PROCESO, ORDINAL, ARCHIVO, INDICE, CONDICION, RECEPTOR, FORMULA)
values                (361, 1, 14, 1, 'C1401=C617', 'C924', 'C1418+" "+C1420+" "+C1421+" "+C1422');
go

--CLI_PersonasJuridicas
insert into MACROR    (PROCESO, ORDINAL, ARCHIVO, INDICE, CONDICION, RECEPTOR, FORMULA)
values                (362, 0, 19, 1, 'CLI_PersonasJuridicas', NULL, NULL);
insert into MACROR    (PROCESO, ORDINAL, ARCHIVO, INDICE, CONDICION, RECEPTOR, FORMULA)
values                (362, 1, 19, 1, 'C1451=C617', 'C924', 'C1452');
go

-- VW_PersonasFisicas
insert into MACROR    (PROCESO, ORDINAL, ARCHIVO, INDICE, CONDICION, RECEPTOR, FORMULA)
values                (287, 0, 287, 1, 'VW_PersonasFisicas', NULL, NULL);
insert into MACROR    (PROCESO, ORDINAL, ARCHIVO, INDICE, CONDICION, RECEPTOR, FORMULA)
values                (287, 1, 287, 1, 'C3001=C537YC3002=C622', 'C665', 'C3003');
insert into MACROR    (PROCESO, ORDINAL, ARCHIVO, INDICE, CONDICION, RECEPTOR, FORMULA)
values                (287, 2, 287, 1, 'C3001=C537YC3002=C622', 'C924', 'C3004+" "+C3005+" "+C3006+" "+C3007');
insert into MACROR    (PROCESO, ORDINAL, ARCHIVO, INDICE, CONDICION, RECEPTOR, FORMULA)
values                (290, 0, 287, 2, 'VW_PersonasFisicas', NULL, NULL);
insert into MACROR    (PROCESO, ORDINAL, ARCHIVO, INDICE, CONDICION, RECEPTOR, FORMULA)
values                (290, 1, 287, 2, 'C3003=C665', 'C537', 'C3001');
insert into MACROR    (PROCESO, ORDINAL, ARCHIVO, INDICE, CONDICION, RECEPTOR, FORMULA)
values                (290, 2, 287, 2, 'C3003=C665', 'C622', 'C3002');
insert into MACROR    (PROCESO, ORDINAL, ARCHIVO, INDICE, CONDICION, RECEPTOR, FORMULA)
values                (290, 3, 287, 2, 'C3003=C665', 'C924', 'C3004+" "+C3005+" "+C3006+" "+C3007');
go

-- 825
-- VW_PersonasJuridicas
insert into MACROR    (PROCESO, ORDINAL, ARCHIVO, INDICE, CONDICION, RECEPTOR, FORMULA)
values                (288, 0, 288, 1, 'VW_PersonasJuridicas', NULL, NULL);
insert into MACROR    (PROCESO, ORDINAL, ARCHIVO, INDICE, CONDICION, RECEPTOR, FORMULA)
values                (288, 1, 288, 1, 'C3008=C537YC3009=C622', 'C665', 'C3010');
insert into MACROR    (PROCESO, ORDINAL, ARCHIVO, INDICE, CONDICION, RECEPTOR, FORMULA)
values                (288, 2, 288, 1, 'C3008=C537YC3009=C622', 'C924', 'C3011');
insert into MACROR    (PROCESO, ORDINAL, ARCHIVO, INDICE, CONDICION, RECEPTOR, FORMULA)
values                (288, 3, 288, 1, 'C3008=C537YC3009=C622', 'C825', 'C3021');
insert into MACROR    (PROCESO, ORDINAL, ARCHIVO, INDICE, CONDICION, RECEPTOR, FORMULA)
values                (291, 0, 288, 2, 'VW_PersonasJuridicas', NULL, NULL);
insert into MACROR    (PROCESO, ORDINAL, ARCHIVO, INDICE, CONDICION, RECEPTOR, FORMULA)
values                (291, 1, 288, 2, 'C3010=C665', 'C537', 'C3008');
insert into MACROR    (PROCESO, ORDINAL, ARCHIVO, INDICE, CONDICION, RECEPTOR, FORMULA)
values                (291, 2, 288, 2, 'C3010=C665', 'C622', 'C3009');
insert into MACROR    (PROCESO, ORDINAL, ARCHIVO, INDICE, CONDICION, RECEPTOR, FORMULA)
values                (291, 3, 288, 2, 'C3010=C665', 'C924', 'C3011');
go

-- VW_InstitucionFinanciera
insert into MACROR    (PROCESO, ORDINAL, ARCHIVO, INDICE, CONDICION, RECEPTOR, FORMULA)
values                (289, 0, 289, 1, 'VW_InstitucionFinanciera', NULL, NULL);
insert into MACROR    (PROCESO, ORDINAL, ARCHIVO, INDICE, CONDICION, RECEPTOR, FORMULA)
values                (289, 1, 289, 1, 'C3012=C537YC3013=C622', 'C665', 'C3014');
insert into MACROR    (PROCESO, ORDINAL, ARCHIVO, INDICE, CONDICION, RECEPTOR, FORMULA)
values                (289, 2, 289, 1, 'C3012=C537YC3013=C622', 'C924', 'C3015');
insert into MACROR    (PROCESO, ORDINAL, ARCHIVO, INDICE, CONDICION, RECEPTOR, FORMULA)
values                (289, 3, 289, 1, 'C3012=C537YC3013=C622', 'C825', 'C3022');
insert into MACROR    (PROCESO, ORDINAL, ARCHIVO, INDICE, CONDICION, RECEPTOR, FORMULA)
values                (292, 0, 289, 2, 'VW_InstitucionFinanciera', NULL, NULL);
insert into MACROR    (PROCESO, ORDINAL, ARCHIVO, INDICE, CONDICION, RECEPTOR, FORMULA)
values                (292, 1, 289, 2, 'C3014=C665', 'C537', 'C3012');
insert into MACROR    (PROCESO, ORDINAL, ARCHIVO, INDICE, CONDICION, RECEPTOR, FORMULA)
values                (292, 2, 289, 2, 'C3014=C665', 'C622', 'C3013');
insert into MACROR    (PROCESO, ORDINAL, ARCHIVO, INDICE, CONDICION, RECEPTOR, FORMULA)
values                (292, 3, 289, 2, 'C3014=C665', 'C924', 'C3015');
go
