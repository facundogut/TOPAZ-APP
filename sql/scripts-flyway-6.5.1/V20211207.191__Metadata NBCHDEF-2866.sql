EXECUTE('
-----------------------------
--QUITO OPCION CUIT PARA PF--
-----------------------------
DELETE FROM OPCIONES
WHERE NUMERODECAMPO = 34111 AND IDIOMA = ''E'' AND OPCIONINTERNA = ''CUIT''
----
')
