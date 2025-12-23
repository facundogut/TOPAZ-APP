EXECUTE('
DELETE FROM CRE_ESTADOS_LIMITES 
')

EXECUTE('
INSERT INTO dbo.CRE_ESTADOS_LIMITES (TZ_LOCK, COD_ESTADO, ESTADO, DESCRIPCION)
VALUES (0, 1, ''Ingresada'', ''Ingresada'')

INSERT INTO dbo.CRE_ESTADOS_LIMITES (TZ_LOCK, COD_ESTADO, ESTADO, DESCRIPCION)
VALUES (0, 2, ''Rechazada'', ''Rechazada'')

INSERT INTO dbo.CRE_ESTADOS_LIMITES (TZ_LOCK, COD_ESTADO, ESTADO, DESCRIPCION)
VALUES (0, 3, ''Evaluada'', ''Evaluada'')

INSERT INTO dbo.CRE_ESTADOS_LIMITES (TZ_LOCK, COD_ESTADO, ESTADO, DESCRIPCION)
VALUES (0, 4, ''Pendiente de Confirmación ----'', ''Pendiente de Confirmación'')

INSERT INTO dbo.CRE_ESTADOS_LIMITES (TZ_LOCK, COD_ESTADO, ESTADO, DESCRIPCION)
VALUES (0, 5, ''Pend de Conf y Autorización'', ''Pendiente de Confirmación y Autorización'')

INSERT INTO dbo.CRE_ESTADOS_LIMITES (TZ_LOCK, COD_ESTADO, ESTADO, DESCRIPCION)
VALUES (0, 6, ''Pendiente de Autorización'', ''Pendiente de Autorización'')

INSERT INTO dbo.CRE_ESTADOS_LIMITES (TZ_LOCK, COD_ESTADO, ESTADO, DESCRIPCION)
VALUES (0, 7, ''Devuelta'', ''Devuelta'')

INSERT INTO dbo.CRE_ESTADOS_LIMITES (TZ_LOCK, COD_ESTADO, ESTADO, DESCRIPCION)
VALUES (0, 8, ''Autorizada'', ''Autorizada'')

INSERT INTO dbo.CRE_ESTADOS_LIMITES (TZ_LOCK, COD_ESTADO, ESTADO, DESCRIPCION)
VALUES (0, 9, ''Pendiente de Documentación'', ''Pendiente de Documentación'')

INSERT INTO dbo.CRE_ESTADOS_LIMITES (TZ_LOCK, COD_ESTADO, ESTADO, DESCRIPCION)
VALUES (0, 10, ''Pendiente de Información'', ''Pendiente de Información'')

INSERT INTO dbo.CRE_ESTADOS_LIMITES (TZ_LOCK, COD_ESTADO, ESTADO, DESCRIPCION)
VALUES (0, 11, ''Pendiente de Recomendación'', ''Pendiente de Recomendación'')

INSERT INTO dbo.CRE_ESTADOS_LIMITES (TZ_LOCK, COD_ESTADO, ESTADO, DESCRIPCION)
VALUES (0, 12, ''Pendiente'', ''Pendiente'')

INSERT INTO dbo.CRE_ESTADOS_LIMITES (TZ_LOCK, COD_ESTADO, ESTADO, DESCRIPCION)
VALUES (0, 13, ''Pend Confirmar Recomendación'', ''Pendiente de Confirmar Recomendación'')

INSERT INTO dbo.CRE_ESTADOS_LIMITES (TZ_LOCK, COD_ESTADO, ESTADO, DESCRIPCION)
VALUES (0, 14, ''Recomendada'', ''Recomendada'')

INSERT INTO dbo.CRE_ESTADOS_LIMITES (TZ_LOCK, COD_ESTADO, ESTADO, DESCRIPCION)
VALUES (0, 15, ''Pend Autorización Comité'', ''Pendiente de Autorización Comité'')

INSERT INTO dbo.CRE_ESTADOS_LIMITES (TZ_LOCK, COD_ESTADO, ESTADO, DESCRIPCION)
VALUES (0, 16, ''Elevar Directorio'', ''Elevar Directorio'')

INSERT INTO dbo.CRE_ESTADOS_LIMITES (TZ_LOCK, COD_ESTADO, ESTADO, DESCRIPCION)
VALUES (0, 17, ''Elevar Nivel'', ''Elevar Nivel'')
')