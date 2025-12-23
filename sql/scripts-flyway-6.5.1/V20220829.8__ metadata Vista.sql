EXECUTE('
CREATE   VIEW [VW_CV_MOTIVOS_CANCELACION] (
                                           CODIGO_MOTIVO,
                                           DESCRIPCION,
                                           DESC_TIPO,
                                           TIPO)
AS
   SELECT
          M.CODIGO_MOTIVO,
          M.DESCRIPCION,
          O.DESCRIPCION AS DESC_TIPO,
          M.TIPO
   FROM
      CV_MOTIVOS_CANCELACION  AS M WITH (NOLOCK)
      INNER JOIN OPCIONES  AS O WITH (NOLOCK) ON O.NUMERODECAMPO = 35340
      AND O.IDIOMA = ''E'' AND O.OPCIONINTERNA = M.Tipo

   WHERE
      M.TZ_LOCK = 0
')