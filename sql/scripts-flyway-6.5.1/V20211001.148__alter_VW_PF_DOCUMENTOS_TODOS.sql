EXECUTE ('
CREATE OR ALTER VIEW [dbo].[VW_PF_DOCUMENTOS_TODOS] (
												   "Tipo Documento Identificativo", 
												   "Número Documento Identificativo",
												   "Tipo Documento Físico",
												   "Número de Documento Físico",
												   "Apellidos y Nombres",
												   "Tipo de Persona", 
												   "Nivel de Apertura",
												   "Estado de la Persona",
												   "Motivo Inhabilitado",
												   "Número de Persona")
AS 
   SELECT TOP 9223372036854775807 WITH TIES 
      V.TIPODOCUMENTO , 
      V.NUMERODOCUMENTO ,
      V.TIPO_DOC_FISICO ,
      V.NUM_DOC_FISICO ,
      (U.APELLIDOPATERNO +'' ''+U.PRIMERNOMBRE) AS NOMBRES,
      V.TIPOPERSONA ,  
      CASE U.NIVEL_APERTURA
        WHEN 0 THEN ''REGISTRO''
        WHEN 1 THEN ''BÁSICO''
        WHEN 2 THEN ''PASIVOS''
        WHEN 3 THEN ''ACTIVOS''
      END AS ''NIVEL_APERTURA'',
      CASE U.ESTADO 
    	WHEN 0 THEN ''HABILITADO''
    	WHEN 1 THEN ''INHABILITADO''
    	END AS ''ESTADO'',
       (SELECT DESCRIPCION 
		FROM OPCIONES O  WITH(NOLOCK)
		WHERE O.IDIOMA=''E''
		AND O.OPCIONINTERNA=U.MOTIVO_INHABILITADO 
		AND O.NUMERODECAMPO = 33368) AS  MOTIVO_INHABILITADO,
      V.NUMEROPERSONAFJ 
       
   FROM dbo.CLI_PERSONASFISICAS  AS U WITH(NOLOCK)
   INNER JOIN dbo.CLI_DOCUMENTOSPFPJ  AS V WITH(NOLOCK)ON 
													  U.NUMEROPERSONAFISICA = V.NUMEROPERSONAFJ 
													  AND V.TIPOPERSONA = ''F'' 
													  AND (U.TZ_LOCK < 300000000000000 OR U.TZ_LOCK >= 400000000000000)
													  AND (U.TZ_LOCK < 100000000000000 OR U.TZ_LOCK >= 200000000000000)
													  AND V.TZ_LOCK =0
   ORDER BY NUMEROPERSONAFJ;
   
')

