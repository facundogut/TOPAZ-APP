execute ('

CREATE VIEW VW_CLI_INHABILITADOS_UIF  
									   	(
														[Tipo de Documento Identificativo],
														[Nro. de Documento Identificativo],
														[Apellido/s y Nombre/s o Razón Social],
														[Tipo Persona],
														[Estado de la Persona],
														[Descripción del estado],
														[Días Inhabilitación],
														[Fecha Inhabilitación],
														[Fecha Vencimiento]
													
) AS 

SELECT	
	I.TIPODOCUMENTO,
	I.CUIT_CUIL,
	I.NOMBRE,
    (CASE 
    	WHEN I.TIPOPERSONA=''F'' THEN ''PERSONA HUMANA'' 
       	WHEN I.TIPOPERSONA=''I'' THEN ''INSTINTUCION FINANCIERA'' 
      	ELSE ''PERSONA JURIDICA'' END) AS TIPO_PERSONA,  
	I.ESTADO,
	(SELECT DESCRIPCION 
	FROM OPCIONES WITH (NOLOCK) 
	WHERE NUMERODECAMPO = 33230 
	AND OPCIONINTERNA = I.ESTADO 
	AND IDIOMA=''E'') AS DESC_ESTADO,
	I.DIAS_INHABILITADO,
	I.FECHA_INHABILITADO,
	I.FECHA_VENCIMIENTO
	
FROM  
      CLI_INHABILITADOS_UIF AS I WITH (NOLOCK)
WHERE  
	  (	(I.TZ_LOCK < 300000000000000 OR I.TZ_LOCK >= 400000000000000) 
	  AND (I.TZ_LOCK < 100000000000000 OR I.TZ_LOCK >= 200000000000000))


')