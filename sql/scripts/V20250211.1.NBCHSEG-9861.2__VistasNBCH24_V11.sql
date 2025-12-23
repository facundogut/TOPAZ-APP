EXECUTE('
CREATE OR ALTER VIEW dbo.VW_NBCH24_CLI_PERSONA (idpersona, tipo, doc, apellido, nombre, razonSocial, fecha, nacionalidad, estadocivil, sexo, fechaAlta, estado, estadoDesc, motivoCancelacion, motivoCancelacionDesc, mail)
AS
	select 
	pf.numeropersonafisica,
	''PF'', 
	docu.numerodocumento, 
	pf.apellidopaterno, 
	pf.primernombre, 
	pf.apellidopaterno + '' '' +  pf.primernombre, --razon social 
	pf.fechanacimiento, 
	pf.nacionalidad,
    (select ecd.descripcion from opciones ecd  WITH (NOLOCK) where ecd.numerodecampo = 1403  and ecd.opcioninterna = pf.estadocivil and ecd.idioma = ''E''), --descripcion estado civil 
	(select sd.descripcion from opciones sd WITH (NOLOCK) where sd.numerodecampo = 1404 and sd.opcioninterna = pf.sexo and sd.idioma = ''E''), -- descripcion sexo 
	pf.fechaAlta,
	pf.ESTADO, 
	(select ed.descripcion from opciones ed WITH (NOLOCK) where ed.numerodecampo =  33366 and ed.opcioninterna = pf.ESTADO), -- descripcion estado 
	pf.MOTIVO_INHABILITADO,
	(select md.descripcion from opciones md WITH (NOLOCK) where md.numerodecampo = 33368 and md.opcioninterna = pf.MOTIVO_INHABILITADO), -- descripcion motivo inhabilitacion 
	(select cm.EMAIL from CLI_EMAILS cm WITH (NOLOCK) where cm.TIPO = ''PE'' AND cm.ordinal = 1 AND cm.FORMATO = ''PF'' AND pf.numeropersonafisica = cm.ID) -- correo electrónico para persona física
	from cli_personasfisicas pf WITH (NOLOCK)
	inner join cli_documentospfpj docu WITH (NOLOCK) on pf.numeropersonafisica = docu.NUMEROPERSONAFJ	
	where pf.TZ_LOCK = 0
	and docu.TZ_LOCK = 0

	union 

	select  
	pj.numeropersonajuridica,
	''PJ'',
	docu.numerodocumento,
	null, --nombre
	null, --apellido
	pj.razonsocial,
	pj.fechaconstitucion, 
	null, --nacionalidad
	null, --estadocivil
	null, --sexo
	pj.fechaAlta,
	pj.ESTADO, 
	(select ed.descripcion from opciones ed WITH (NOLOCK) where ed.numerodecampo =  33366 and ed.opcioninterna = pj.ESTADO), -- descripcion estado 
	pj.MOTIVO_INHABILITADO,
	(select md.descripcion from opciones md WITH (NOLOCK) where md.numerodecampo = 33368 and md.opcioninterna = pj.MOTIVO_INHABILITADO), -- descripcion motivo inhabilitacion 
	(select cm.EMAIL from CLI_EMAILS cm WITH (NOLOCK) where cm.TIPO = ''LE'' AND cm.ordinal = 1 AND cm.FORMATO = ''PJ'' AND pj.numeropersonajuridica = cm.ID) -- correo electrónico para persona jurídica	
	from cli_personasjuridicas pj 
	inner join cli_documentospfpj docu on pj.numeropersonajuridica = docu.NUMEROPERSONAFJ
	where pj.TZ_LOCK = 0 
	and docu.TZ_LOCK = 0;
');
