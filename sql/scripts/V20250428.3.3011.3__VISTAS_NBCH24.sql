EXECUTE('
	CREATE or alter VIEW dbo.VW_NBCH24_CTA_EMAIL 
	AS 
	select 
	s.EMAIL, 
	s.JTS_OID_SALDO, 
	s.ID 
	from SUSCRIPCIONES_RESUMEN s WITH (NOLOCK) 
	where s.ESTADO = ''S'' 
	and s.TZ_LOCK = 0 
');

