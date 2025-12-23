--------------------------------------------------------------------------------------------------------------------------------
-- Operaciones                                                                                                                --
--------------------------------------------------------------------------------------------------------------------------------

-- Título
insert into OPERACIONES    (TITULO, IDENTIFICACION, NOMBRE, DESCRIPCION, MNEMOTECNICO, AUTORIZACION, ESTADO, SUBOPERACION, PERMITEBAJA)
values                     (1003, 0, '- CLIENTES - Vinculaciones', NULL, 0, NULL, NULL, NULL, NULL);
go

-- Operaciones
insert into OPERACIONES    (TITULO, IDENTIFICACION, NOMBRE, DESCRIPCION, MNEMOTECNICO, AUTORIZACION, ESTADO, SUBOPERACION, PERMITEBAJA)
values                     (1003, 3671, 'ABMC Vínculos Primarios', 'ABMC Vínculos Primarios', 3671, 'A', 'P', 0, 'S');
insert into OPERACIONES    (TITULO, IDENTIFICACION, NOMBRE, DESCRIPCION, MNEMOTECNICO, AUTORIZACION, ESTADO, SUBOPERACION, PERMITEBAJA)
values                     (1003, 3672, 'ABMC Vínculos Secundarios', 'ABMC Vínculos Secundarios', 3672, 'A', 'P', 0, 'S');
insert into OPERACIONES    (TITULO, IDENTIFICACION, NOMBRE, DESCRIPCION, MNEMOTECNICO, AUTORIZACION, ESTADO, SUBOPERACION, PERMITEBAJA)
values                     (1003, 3673, 'ABMC Roles', 'ABMC Roles', 3673, 'A', 'P', 0, 'S');
insert into OPERACIONES    (TITULO, IDENTIFICACION, NOMBRE, DESCRIPCION, MNEMOTECNICO, AUTORIZACION, ESTADO, SUBOPERACION, PERMITEBAJA)
values                     (1003, 3674, 'ABMC Vínculos', 'ABMC Vínculos', 3674, 'A', 'P', 0, 'S');
insert into OPERACIONES    (TITULO, IDENTIFICACION, NOMBRE, DESCRIPCION, MNEMOTECNICO, AUTORIZACION, ESTADO, SUBOPERACION, PERMITEBAJA)
values                     (1003, 3675, 'ABMC Vinculaciones Internas', 'ABMC Vinculaciones Internas', 3675, 'N', 'P', 0, 'S');
insert into OPERACIONES    (TITULO, IDENTIFICACION, NOMBRE, DESCRIPCION, MNEMOTECNICO, AUTORIZACION, ESTADO, SUBOPERACION, PERMITEBAJA)
values                     (1003, 3676, 'ABMC Vinculaciones Externas', 'ABMC Vinculaciones Externas', 3676, 'N', 'P', 0, 'S');
go
