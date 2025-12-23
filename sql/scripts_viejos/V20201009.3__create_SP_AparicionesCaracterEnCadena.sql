EXECUTE('
CREATE PROCEDURE  SP_AparicionesCaracterEnCadena(
  @cadena       VARCHAR(MAX),
  @caracter     VARCHAR(1),
  @apariciones  INT OUTPUT
)
AS
/*
a. Autor: ALVAROC - Álvaro Correa (Topaz)
b. Descripción: Devuelve la cantidad de veces que se encuentra @caracter en 
                @cadena
c. Fecha Creación:  08/10/2020
d. Comentario:  Se creó con la finalidad de obtener la cantidad de veces que se
                presenta un separador en la trama que se obtiene según el
                código de barras leído en las operaciones de alta de persona.
                Se aprovecha a dejar un proceso que se pueda reutilizar en el 
                futuro en caso de ser necesario.
e. Codigo Jira: NBCHSEG-234
*/
BEGIN
  SET @apariciones = LEN(@cadena) - LEN(REPLACE(@cadena, @caracter, ''''));
END
');
