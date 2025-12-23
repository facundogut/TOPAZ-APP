EXECUTE('
	CREATE OR ALTER VIEW dbo.VW_NBCH24_ACCESOSCV
	AS
	select 
		pa.id_entidad2 jts_oid, 
		s.C1785 modulo, 
		s.SUCURSAL sucursal, 
		s.CUENTA cuenta, 
		pa.ID_PERSONA idPersonaUsuario,  
		docp.numerodocumento documentoUsuario,
		pa.tipo_poder tipoPoder, 
		pa.FECHA_INI_VIGENCIA fechaInicioPoder, 
		pa.FECHA_VENCIMIENTO fechaFinPoder,
		ccp.numeropersona idPersonaTitular ,
		doct.numerodocumento documentoTitular, 
		case when(s.PRODUCTO = 9 or s.PRODUCTO = 10) then docp.numerodocumento else doct.numerodocumento end documentoContexto
	from dbo.saldos s WITH (NOLOCK)
	inner join dbo.PYF_APODERADOS pa WITH (NOLOCK) on pa.id_entidad2 = s.jts_oid
	inner join dbo.cli_documentospfpj docp WITH (NOLOCK) on pa.ID_PERSONA = docp.NUMEROPERSONAFJ
	inner join dbo.CLI_ClientePersona ccp WITH (NOLOCK) on ccp.codigocliente = s.c1803 and ccp.TITULARIDAD = ''T''
	inner join dbo.cli_documentospfpj doct WITH (NOLOCK) on ccp.numeropersona = doct.NUMEROPERSONAFJ
	where pa.tipo_poder in(50, 51) and
		  pa.tipo_Entidad = 2 and
		  pa.TZ_LOCK = 0 and
		  s.C1785 in (2, 3);
');
