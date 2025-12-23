--------------------------------------------------------------------------------------------------------------------------------
-- Parametría                                                                                                                 --
--------------------------------------------------------------------------------------------------------------------------------

-- CLI_VINCULOS_PRIMARIOS
insert into CLI_VINCULOS_PRIMARIOS values (0, 1, 'Relación de control','D');
insert into CLI_VINCULOS_PRIMARIOS values (0, 10, 'Personas directores/síndicos','D');
insert into CLI_VINCULOS_PRIMARIOS values (0, 15, 'Personas gerentes/funcionarios','D');
insert into CLI_VINCULOS_PRIMARIOS values (0, 20, 'Personas indirectas vinculados a directos','I');
insert into CLI_VINCULOS_PRIMARIOS values (0, 25, 'Relaciones familiares','C');
go

-- CLI_VINCULOS_SECUNDARIOS
insert into CLI_VINCULOS_SECUNDARIOS values (0, 1, 'Empresas controladas NBCH', 'D', 'I', 1);
insert into CLI_VINCULOS_SECUNDARIOS values (0, 2, 'Desempeño funcional en entidades NBCH', 'D', 'I', 1);
insert into CLI_VINCULOS_SECUNDARIOS values (0, 3, 'Empresas controladas - Vinculados a un directo NBCH', 'I', 'I', 1);
insert into CLI_VINCULOS_SECUNDARIOS values (0, 4, 'Desempeño funcional - Vinculados a un directo NBCH', 'I', 'I', 1);
insert into CLI_VINCULOS_SECUNDARIOS values (0, 11, 'Empresas controladas', 'D', 'E', 0);
insert into CLI_VINCULOS_SECUNDARIOS values (0, 12, 'Desempeño funcional en entidades', 'D', 'E', 0);
insert into CLI_VINCULOS_SECUNDARIOS values (0, 13, 'Empresas controladas - Vinculados a un directo', 'I', 'E', 0);
insert into CLI_VINCULOS_SECUNDARIOS values (0, 14, 'Desempeño funcional - Vinculados a un directo', 'I', 'E', 0);
insert into CLI_VINCULOS_SECUNDARIOS values (0, 21, 'Parentesco y afinidad', 'C', 'M', 0);
go

-- CLI_ROLES
insert into CLI_ROLES values (0, 11, 'Entidades financieras del país', 1, 'J', 0, 'N', 0);
insert into CLI_ROLES values (0, 12, 'Empresas de servicios complementarios del país', 1, 'J', 0, 'N', 0);
insert into CLI_ROLES values (0, 13, 'Empresas de servicios complementarios del exterior', 1, 'J', 0, 'N', 0);
insert into CLI_ROLES values (0, 14, 'Entidades financieras del exterior', 1, 'J', 0, 'N', 0);
insert into CLI_ROLES values (0, 15, 'Otras contrapartes vinculadas x relación de control', 1, 'J', 0, 'N', 0);
insert into CLI_ROLES values (0, 16, 'Entidades financieras del país', 1, 'I', 0, 'N', 0);
insert into CLI_ROLES values (0, 17, 'Entidades financieras del exterior', 1, 'I', 0, 'N', 0);
insert into CLI_ROLES values (0, 31, 'Director', 2, 'F', 0, 'N', 0);
insert into CLI_ROLES values (0, 32, 'Sindico', 2, 'F', 0, 'N', 0);
insert into CLI_ROLES values (0, 41, 'Gerente general', 3, 'F', 0, 'N', 0);
insert into CLI_ROLES values (0, 42, 'Funcionarios autorizados en materia de crédito', 3, 'F', 0, 'N', 0);
insert into CLI_ROLES values (0, 61, 'Padres', 4, 'F', 1, 'N', 0);
insert into CLI_ROLES values (0, 62, 'Hijos', 4, 'F', 1, 'S', 0);
insert into CLI_ROLES values (0, 63, 'Abuelos', 4, 'F', 2, 'N', 0);
insert into CLI_ROLES values (0, 64, 'Hermanos', 4, 'F', 2, 'N', 0);
insert into CLI_ROLES values (0, 65, 'Nietos', 4, 'F', 2, 'N', 0);
insert into CLI_ROLES values (0, 66, 'Medios hermanos', 4, 'F', 2, 'N', 0);
insert into CLI_ROLES values (0, 71, 'Cónyuge', 5, 'F', 1, 'S', 0);
insert into CLI_ROLES values (0, 72, 'Concubino', 5, 'F', 1, 'N', 0);
insert into CLI_ROLES values (0, 73, 'Suegros', 5, 'F', 1, 'N', 0);
insert into CLI_ROLES values (0, 74, 'Yernos', 5, 'F', 1, 'N', 0);
insert into CLI_ROLES values (0, 75, 'Nueras', 5, 'F', 1, 'N', 0);
insert into CLI_ROLES values (0, 76, 'Padrastros', 5, 'F', 1, 'N', 0);
insert into CLI_ROLES values (0, 77, 'Hijastros', 5, 'F', 1, 'N', 0);
go

-- CLI_VINCULOS
insert into CLI_VINCULOS values (0, 'DA', 'Directos - Relación control - Empresas controladas NBCH', 1, 1, 1, 1);
insert into CLI_VINCULOS values (0, 'DB', 'Directos - Desempeño funcionales directivos - NBCH', 10, 2, 2, 1);
insert into CLI_VINCULOS values (0, 'DC', 'Directos - Desempeño funcionales gerenciales - NBCH', 15, 2, 3, 1);
insert into CLI_VINCULOS values (0, 'IA', 'Indirectos - Empresas controladas - Vinculados a un directo NBCH', 20, 3, 1, 0);
insert into CLI_VINCULOS values (0, 'IB', 'Indirectos - Desempeño funcionales directivos - Vinculados a un directo NBCH', 20, 4, 2, 0);
insert into CLI_VINCULOS values (0, 'IC', 'Indirectos - Desempeño funcionales gerenciales - Vinculados a un directo NBCH', 20, 4, 3, 0);
insert into CLI_VINCULOS values (0, 'DD', 'Directos - Relación control - Empresas controladas', 1, 11, 1, 0);
insert into CLI_VINCULOS values (0, 'DE', 'Directos - Desempeño funcionales directivos', 10, 12, 2, 0);
insert into CLI_VINCULOS values (0, 'DF', 'Directos - Desempeño funcionales gerenciales', 15, 12, 3, 0);
insert into CLI_VINCULOS values (0, 'IF', 'Indirectos - Empresas controladas - Vinculados a un directo', 20, 13, 1, 0);
insert into CLI_VINCULOS values (0, 'IG', 'Indirectos - Desempeño funcionales directivos -  Vinculados a un directo', 20, 14, 2, 0);
insert into CLI_VINCULOS values (0, 'IH', 'Indirectos - Desempeño funcionales gerenciales - Vinculados a un directo', 20, 14, 3, 0);
insert into CLI_VINCULOS values (0, 'CA', 'Comunes - Parentesco por consaguinidad', 25, 21, 4, 0);
insert into CLI_VINCULOS values (0, 'CB', 'Comunes - Parentesco por afinidad', 25, 21, 5, 0);
go
