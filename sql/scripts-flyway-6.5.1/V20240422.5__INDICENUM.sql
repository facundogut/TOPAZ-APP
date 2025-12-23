EXECUTE(' 
if exists (select name from sysindexes where name = ''Indice_14_13'')
   DROP INDEX Indice_14_13 ON NUMERATORASIGNED
')

EXECUTE('
CREATE INDEX Indice_14_13 ON [dbo].[NUMERATORASIGNED] ([FECHAPROCESO], [SUCURSAL], [ASIENTO],[ESTADO])
')