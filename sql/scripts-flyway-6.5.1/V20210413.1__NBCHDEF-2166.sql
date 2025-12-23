EXECUTE('
IF OBJECT_ID (''USUARIOSBPM'') IS NOT NULL
	DROP VIEW USUARIOSBPM
')

EXECUTE('
CREATE VIEW USUARIOSBPM
AS (
select clave, nombre, grupo from usuarios 
UNION
select ''Administrator'' as clave , ''Administrator'' as nombre, ''Administrators'' as grupo)
')


EXECUTE('
IF OBJECT_ID (''GRUPOSBPM'') IS NOT NULL
	DROP VIEW GRUPOSBPM
')


EXECUTE('
CREATE VIEW GRUPOSBPM
AS (
select grupo, descripcion from grupos 
UNION
select ''Administrators'' as grupo , ''Administrators'' as descripcion 
)
')
