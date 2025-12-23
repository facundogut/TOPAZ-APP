EXECUTE('
CREATE PROCEDURE  SP_GeneraDigVerifCUITL(
  @nroDocumento       VARCHAR(10),
  @digitoVerificador  VARCHAR(2) OUTPUT
)
AS
/*
a. Autor: ALVAROC - Álvaro Correa (Topaz)
b. Descripción: Procedimiento que devuelve el dígito verificador dado un número
                de documento con su respectivo prefijo (para más información
                ver sub-rutina 310 o el siguiente link provisto por el cliente
                para la implementación de la validación de documentos:
                https://es.wikipedia.org/wiki/Clave_%C3%9Anica_de_Identificaci%C3%B3n_Tributaria)
c. Fecha Creación:  08/10/2020
d. Comentario:  Se creó para los casos en los que no vienen el tipo de documento
                ni el digito verificador en la trama leída por el lector de
                códigos de barras
e. Codigo Jira: NBCHSEG-79
*/
BEGIN
  DECLARE @factmult       VARCHAR(6) =''234567'',
          @nroDocAlReves  VARCHAR(20),
          @i              INT = 0,
          @j              INT = 0,
          @suma           NUMERIC(15) = 0,
          @retorno        INT = 0
  ;

  SET @nroDocAlReves = REVERSE(LEFT(REPLACE(@nroDocumento, ''-'', ''''), 10));

  WHILE (@i <= LEN(@nroDocAlReves))
    BEGIN
      SET @suma = @suma + CAST((SUBSTRING(@nroDocAlReves, @i, 1)) AS INT) * CAST((SUBSTRING(@factmult, @j, 1)) AS INT);

      SET @i += 1;
      SET @j += 1;

      IF @j > 6
        SET @j = 1;
    END

  SET @retorno = @suma % 11;

  IF @retorno > 0
    SET @retorno = 11 - @retorno;
  SET @digitoVerificador = @retorno;
END
');
