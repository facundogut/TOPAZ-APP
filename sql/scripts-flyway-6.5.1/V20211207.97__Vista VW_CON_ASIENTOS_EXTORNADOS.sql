EXECUTE('
------------------------------
--VW_CON_ASIENTOS_EXTORNADOS--
------------------------------
CREATE VIEW VW_CON_ASIENTOS_EXTORNADOS
									AS
								SELECT A.ASIENTO, 
									A.SUCURSAL, 
									A.FECHAPROCESO, 
									A.ASIENTO_ORIGINAL, 
									A.SUCURSAL_ORIGINAL, 
									A.FECHAPROCESO_ORIGINAL
								FROM CON_ASIENTOS_EXTORNADOS AS A WITH (nolock)
----
')