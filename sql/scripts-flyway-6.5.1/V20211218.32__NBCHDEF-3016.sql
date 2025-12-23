EXECUTE('
UPDATE dbo.AYUDAS
SET CAMPOSVISTA = ''Id_Cargo;Id_Impuesto;Descripcion;Pivot_;Condicion;''
WHERE NUMERODEAYUDA = 9343
')