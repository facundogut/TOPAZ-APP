EXECUTE('
CREATE OR ALTER VIEW dbo.VW_NBCH24_CTA_TJD(tipo, tarjeta, estado, doc, jts_oid, descripcion, producto, clase, titularidad, primaria, ambito, comprasExterior)
AS
	select ''TJD'', t.ID_TARJETA, t.ESTADO,  docc.numerodocumento, c.saldo_jts_oid, ttt.descripcion, ttt.codigo_producto, ttt.clase, t.titularidad,
	case when c.ESTADO in( ''3'',''R'',''E'') then ''S'' else ''N'' end, --primaria
	case when c.ESTADO = ''3'' then ''NACIONAL'' when c.ESTADO = ''R'' then ''GLOBAL'' when c.ESTADO = ''E'' then ''EXTERIOR''  when c.ESTADO = ''1'' then ''VINCULADA'' else '''' end, --ambito
	case when c.ESTADO IN (''E'',''R'', ''1'', ''3'') then ''S'' else ''N'' end 
	from TJD_TARJETAS t WITH (NOLOCK)
	inner join TJD_TIPO_TARJETA ttt WITH (NOLOCK) on ttt.tipo_tarjeta = t.tipo_Tarjeta
	inner join TJD_REL_TARJETA_CUENTA c WITH (NOLOCK) on t.ID_TARJETA=c.ID_TARJETA
	inner join cli_documentospfpj docc WITH (NOLOCK) on t.nro_persona = docc.NUMEROPERSONAFJ
	where t.ESTADO in (''0'', ''1'', ''8'') and c.ESTADO NOT IN (''9'', ''X'')
	and c.TZ_LOCK = 0
	and docc.TZ_LOCK = 0

	UNION 

	select ''TJV'', caf.NRO_tARJETA, ''1'', doc.numerodocumento, caf.saldo_jts_oid, null, null, null, Null,
	''N'', '' '', ''N''  
	from itf_lk_Caf_cuentas caf WITH (NOLOCK)
	inner join ITF_LK_CAF_TARJETAS Tcaf ON Tcaf.NRO_TARJETA = caf.NRO_TARJETA
	inner join saldos s WITH (NOLOCK) on caf.saldo_jts_oid = s.jts_oid 
	inner join CLI_ClientePersona ccp WITH (NOLOCK) on ccp.CODIGOCLIENTE = s.c1803
	inner join cli_documentospfpj doc WITH (NOLOCK) on doc.numeropersonafj = ccp.numeropersona 
	where caf.estado_Cuenta = ''1''
	and Tcaf.ESTADO_TARJETA in (''1'')
	and ccp.TZ_LOCK = 0 and ccp.TITULARIDAD = ''T'' 
	and doc.TZ_LOCK = 0
	and caf.NRO_TARJETA not in (select x.ID_TARJETA  from TJD_TARJETAS x WITH (NOLOCK));
');

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
