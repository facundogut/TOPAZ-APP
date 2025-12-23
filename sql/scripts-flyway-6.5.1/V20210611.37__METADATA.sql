EXECUTE('

ALTER VIEW [dbo].[VW_TJD_TIPO_TARJETA] (
						Clase,
						Descripción_clase,
						Código_Producto,
						Descripción,
						Bin,
						Producto_Tarjeta
)
AS
					SELECT TT.CLASE, 
							TC.Descripcion, 
							TT.TIPO_TARJETA, 
							TT.DESCRIPCION, 
							TT.BIN, 
							TT.[CODIGO_PRODUCTO]
					FROM TJD_TIPO_TARJETA TT with (nolock)
					INNER JOIN TJD_CLASE TC with (nolock) 
							ON TT.CLASE = TC.Clave
					WHERE TT.TZ_LOCK = 0 
						AND TC.TZ_LOCK = 0;
						
						')
						
						
						
						
						EXECUTE('



UPDATE AYUDAS
SET DESCRIPCION=''Ayuda de productos de tarjeta'', CAMPOS=''556OA1;410;950R;6912;798;759;'', CAMPOSVISTA=''Clase;Descripción_clase;Código_Producto;Descripción;Bin;Producto_Tarjeta;''
WHERE NUMERODEAYUDA=34009;


UPDATE AYUDAS
SET DESCRIPCION=''Ayuda Tipos de Tarjeta''
WHERE NUMERODEAYUDA=90824;


UPDATE DICCIONARIO
SET PROMPT=''Producto Tarjeta''
WHERE NUMERODECAMPO=3863;
UPDATE DICCIONARIO
SET PROMPT=''Tipo de Tarjeta''
WHERE NUMERODECAMPO=3864;


')