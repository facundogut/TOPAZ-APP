execute('
IF EXISTS (SELECT name 
           FROM sys.indexes 
           WHERE name = ''IX_PYF_APODERADOS_NBCH2401'' 
             AND object_id = OBJECT_ID(''dbo.PYF_APODERADOS''))
BEGIN
    DROP INDEX IX_PYF_APODERADOS_NBCH2401 ON dbo.PYF_APODERADOS;
END;
');

execute('
drop view if exists dbo.VW_NBCH24_CLI_CLIENTE;
drop view if exists dbo.VW_NBCH24_CLI_PERSONA;
drop view if exists dbo.VW_NBCH24_CRE_CUOTAS;
drop view if exists dbo.VW_NBCH24_CRE_PLAZO_GRACIA;
drop view if exists dbo.VW_NBCH24_CRE_SCORING;
drop view if exists dbo.VW_NBCH24_CRE_TENENCIA;
drop view if exists dbo.VW_NBCH24_CTA_ACUERDOS;
drop view if exists dbo.VW_NBCH24_CTA_BLOQUEOS;
drop view if exists dbo.VW_NBCH24_CTA_TENENCIA;
drop view if exists dbo.VW_NBCH24_CTA_TJD;
drop view if exists dbo.VW_NBCH24_DPF_PIZARRA;
drop view if exists dbo.VW_NBCH24_DPF_TENENCIA;
drop view if exists dbo.VW_NBCH24_GRL_COTIZACIONES;
drop procedure if exists dbo.SP_NBCH24_MOVIMIENTOS;
');

execute('
CREATE NONCLUSTERED INDEX IX_PYF_APODERADOS_NBCH2401 ON dbo.PYF_APODERADOS (TZ_LOCK ASC, TIPO_ENTIDAD ASC, ID_PERSONA ASC, TIPO_PODER ASC) INCLUDE (FECHA_INI_VIGENCIA, FECHA_VENCIMIENTO);
');

execute('
CREATE VIEW dbo.VW_NBCH24_CLI_CLIENTE
AS
	select c.codigocliente idcliente, 
	c.nombrecliente nombre, 
	c.tipo tipo, 
	c.FECHAAPERTURA fechaalta, 
	cp.numeropersona idPersona,
	dir.calle calle, 
	dir.numero numero, 
	dir.piso piso, 
	dir.apartamento depto, 
	dir.cpa_viejo cp,
	loc.descripcion_dim3 localidad, 
	prov.ID_BCRA codigoprov, 
	prov.descripcion prov, 
	pais.CODIGOPAIS codigopais,
	pais.nombrepais pais, 
	dir.tipodireccion
	from cli_clientes c WITH (NOLOCK)
	inner join cli_clientepersona cp WITH (NOLOCK) on c.codigocliente = cp.CODIGOCLIENTE
	inner join cli_direcciones dir WITH (NOLOCK) on dir.id = cp.numeropersona 
	inner join cli_paises pais WITH (NOLOCK) on dir.pais = pais.codigopais
	inner join cli_provincias prov WITH (NOLOCK) on prov.codigopais = pais.codigopais and prov.dim1 = dir.provincia
	inner join cli_localidades loc WITH (NOLOCK) on loc.dim2  = dir.departamento and loc.dim3 = dir.localidad and loc.dim1 = dir.provincia
	where c.tz_lock = 0
	and cp.titularidad = ''T'' and cp.tz_lock = 0
	and dir.TZ_LOCK = 0 and dir.tipodireccion in (''PR'', ''L'')
	and pais.TZ_LOCK = 0
	and prov.TZ_LOCK = 0
	and loc.TZ_LOCK = 0;
');

execute('
CREATE VIEW dbo.VW_NBCH24_CLI_PERSONA (idpersona, tipo, doc, apellido, nombre, razonSocial, fecha, nacionalidad, estadocivil, sexo, fechaAlta, estado, estadoDesc, motivoCancelacion, motivoCancelacionDesc)
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
	(select md.descripcion from opciones md WITH (NOLOCK) where md.numerodecampo = 33368 and md.opcioninterna = pf.MOTIVO_INHABILITADO) -- descripcion motivo inhabilitacion 
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
	(select md.descripcion from opciones md WITH (NOLOCK) where md.numerodecampo = 33368 and md.opcioninterna = pj.MOTIVO_INHABILITADO) -- descripcion motivo inhabilitacion 	
	from cli_personasjuridicas pj 
	inner join cli_documentospfpj docu on pj.numeropersonajuridica = docu.NUMEROPERSONAFJ
	where pj.TZ_LOCK = 0 
	and docu.TZ_LOCK = 0;
');

execute('
CREATE VIEW dbo.VW_NBCH24_CRE_CUOTAS
AS
	SELECT 
	s.jts_oid jtsCRE, 
	ecc.NCUOTA AS nroCuota,
	ecc.VENCIMIENTOCUOTA AS fecVencimiento,
	ecc.fechavalor AS fecPago,
	ecc.CAPITAL AS capital,
	ecc.INTERES AS interes,
	ecc.SALDO_CAPITAL+ecc.SALDO_INTERES+ecc.PP_IVAINTERES+ecc.PP_IVAPERCEPCIONINTERES+ecc.PP_MORA+ecc.PP_IVAMORA+ecc.PP_IVAPERCEPCIONMORA+
	ecc.PP_INTCOMPMORA+ecc.PP_IVAINTCOMPMORA+ecc.PP_IVAPERCEPCIONINTCOMPMORA AS saldo,
	isnull(pagos.impuestos, 0) impuestos,
	isnull(pagos.otros_rubros, 0) otrosRubros, 
	isnull(pagos.TOTAL_PAGO, 0) totalPago
	FROM SALDOS S WITH (NOLOCK)
	INNER JOIN VBS_ESTADO_CUENTA_CLIENTE ecc ON ecc.SALDO_JTS_OID = S.JTS_OID
	LEFT JOIN 
	(select
	vp.SALDO_JTS_OID,
	vp.ncuota,
	(sum(VP.PP_IVAINTERES)+sum(VP.PP_IVAPERCEPCIONINTERES)+sum(VP.PP_IVAMORA)+sum(VP.PP_IVAPERCEPCIONMORA)+sum(VP.PP_IVAINTCOMPMORA)+sum(VP.PP_IVAPERCEPCIONINTCOMPMORA)) AS IMPUESTOS, 
	(sum(VP.PP_MORA)+sum(VP.PP_INTCOMPMORA)+sum(VP.PP_GASTOS)) OTROS_RUBROS,
	(sum(VP.CAPITAL)+sum(VP.INTERES)+sum(VP.PP_IVAINTERES)+sum(VP.PP_IVAPERCEPCIONINTERES)+sum(VP.PP_IVAMORA)+sum(VP.PP_IVAPERCEPCIONMORA)+sum(VP.PP_IVAINTCOMPMORA)+sum(VP.PP_IVAPERCEPCIONINTCOMPMORA)+
	sum(VP.PP_MORA)+sum(VP.PP_INTCOMPMORA)+sum(VP.PP_GASTOS)) AS TOTAL_PAGO
	from VBS_DETALLE_CUOTAS_PAGADAS VP 
	group by vp.SALDO_JTS_OID, vp.ncuota ) pagos ON pagos.SALDO_JTS_OID=S.JTS_OID AND pagos.NCUOTA=ecc.NCUOTA;
');

execute('
CREATE VIEW dbo.VW_NBCH24_CRE_PLAZO_GRACIA
AS
	SELECT
	CASE WHEN tp.PERMITE_GRACIA=''S'' AND pc.SALDOS_JTS_OID IS NULL THEN ''S'' 
		 WHEN tp.PERMITE_GRACIA=''S'' AND pc.SALDOS_JTS_OID IS NOT NULL 
		 	  AND NOT EXISTS (SELECT 1 FROM PLANPAGOS pp WITH (NOLOCK) WHERE pp.SALDO_JTS_OID=s.JTS_OID 
		      AND (SELECT FECHAPROCESO FROM PARAMETROS WITH (NOLOCK)) BETWEEN pp.C2301 AND pp.C2302
		      AND (pp.C2309+pp.C2310)>0 AND pp.PRORROGADA=''S'' AND pp.TZ_LOCK=0) THEN ''S'' 
		 ELSE ''N'' END AS ADMITE_GRACIA,-- Esto controla que si existe un periodo de gracia no se encuentre en periodo
	--tp.PERMITE_GRACIA AS ADMITE_GRACIA2,-- Esto solo controla si permite gracia el producto o no
	CASE WHEN pc.SALDOS_JTS_OID IS NOT NULL THEN ''S'' ELSE ''N'' END AS GRACIA_ACEPTADA,
	tp.CUOTA_GRACIA AS PLAZO_GRACIA,
	s.jts_oid jtsCRE 
	FROM SALDOS s WITH (NOLOCK)
	INNER JOIN PRODUCTOS p WITH (NOLOCK) ON p.C6250=s.PRODUCTO AND p.TZ_LOCK=0
	INNER JOIN TOPESPRODUCTO tp WITH (NOLOCK) ON tp.CODPRODUCTO=p.C6250 AND tp.TZ_LOCK=0
	LEFT JOIN BS_PRORROGA_CUOTAS pc WITH (NOLOCK) ON pc.SALDOS_JTS_OID=s.JTS_OID AND pc.TZ_LOCK=0;
');

execute('
CREATE VIEW dbo.VW_NBCH24_CRE_SCORING
AS
	SELECT 
	vc.JTS_CV jtsCV,
	p.C6250 AS linea, 
	p.C6251 AS descripcion, 
	pc.MONTO_MINIMO AS montoMinimo,
	pc.MONTO_MAXIMO AS montoMaximo,
	doc.numerodoc documentoUsuario,
	p.C6800 modulo, 
	dg.CANAL canal 
	FROM CRE_VINCULACIONES_CONVENIOS vc WITH (NOLOCK)
	INNER JOIN SALDOS s WITH (NOLOCK) ON vc.JTS_CV = s.JTS_OID AND s.TZ_LOCK = 0 AND s.C1785 IN (2,3)
	INNER JOIN SUCURSALES suc WITH (NOLOCK) ON s.SUCURSAL = suc.SUCURSAL AND suc.TZ_LOCK = 0
	INNER JOIN CRE_PROD_CONVENIOS pc WITH (NOLOCK) ON vc.ID_CONVENIO = pc.DATO_TIPO AND pc.TIPO = ''C'' AND pc.HABILITADO = ''S'' 	AND pc.TZ_LOCK = 0
	INNER JOIN CONV_CONVENIOS_PAG c WITH (NOLOCK) ON pc.DATO_TIPO = c.ID_ConvPago AND c.TZ_LOCK=0
	INNER JOIN CONV_TIPOS t WITH (NOLOCK) ON c.Id_TpoConv = t.Id_TpoConv AND t.TZ_LOCK = 0
	INNER JOIN PRODUCTOS p WITH (NOLOCK) ON pc.PRODUCTO = p.C6250 AND p.TZ_LOCK = 0 --AND p.C6800 = ''AH''
	INNER JOIN CRE_PRODUCTOSCANALDIGITAL dg WITH (NOLOCK) ON dg.PRODUCTO=P.C6250
	INNER JOIN VW_CLI_X_DOC doc WITH (NOLOCK) ON doc.CODIGOCLIENTE=s.C1803
	where vc.TZ_LOCK=0 --AND dg.CANAL=''HO'';
');

execute('
CREATE VIEW dbo.VW_NBCH24_CRE_TENENCIA
AS
	SELECT 
	cast(s.sucursal as varchar) + ''-'' + cast(s.operacion as varchar) + ''-'' + cast(s.ordinal as varchar) id,
	s.OPERACION operacion, 
	S.PRODUCTO producto, 
	P.C6251 AS NOMBRE_PRODUCTO, 
	S.MONEDA moneda, 
	S.C1621 AS fecInicio, 
	S.C1627 AS fecVencimiento,
	S.C1642*S.C1644 AS plazo, 
	S.C1601 AS montoSolicitado, 
	S.C1645 AS cuotasPagadas, 
	S.C1644-S.C1645 AS cuotasPendientes ,
	(SELECT COUNT(C2300) FROM PLANPAGOS WITH (NOLOCK) WHERE SALDO_JTS_OID=S.JTS_OID AND C2302< (SELECT FECHAPROCESO FROM PARAMETROS WITH (NOLOCK)) AND (C2309+C2310>0)) AS cuotasMorosas, 
	CASE WHEN s.C1628 < (SELECT FECHAPROCESO FROM PARAMETROS WITH (NOLOCK)) THEN datediff(dd,s.C1628,(SELECT FECHAPROCESO FROM PARAMETROS WITH (NOLOCK)))  ELSE 0 END AS atraso, 
	S.C1612 AS montoCuota, 
	ABS(S.C1604) AS SALDO,
	CASE WHEN  s.C1628 < (SELECT FECHAPROCESO FROM PARAMETROS WITH (NOLOCK)) THEN VAD.SALDO_A_FECHA ELSE 0 END AS mora, 
	(C.TASA_CONVERTIDA+C.PUNTOS_CONVERTIDOS) AS TNA, S.C1632 AS tea,
	C.CFT cft, 
	C.CFT_CON_IMPUESTOS cftImpuestos,
	s.jts_oid jtsCRE, 
	ctav.c1785 moduloCuentaCobro, 
	ctav.SUCURSAL sucursalCuentaCobro, 
	ctav.CUENTA cuentaCobro,
	s.C1665 jtsCuentaCobro,
	docT.NUMEROPERSONAFJ idPersonaTitular,
	docT.NUMERODOCUMENTO documentoTitular,
	case when(ctav.PRODUCTO = 9 or ctav.PRODUCTO = 10) then docc.numerodocumento else docT.NUMERODOCUMENTO end documentoContexto
	FROM SALDOS S WITH (NOLOCK)
	INNER JOIN PRODUCTOS P WITH (NOLOCK) ON P.C6250=S.PRODUCTO AND P.TZ_LOCK=0
	INNER JOIN CRE_SALDOS C WITH (NOLOCK) ON C.SALDOS_JTS_OID=S.JTS_OID AND C.TZ_LOCK=0
	inner  join PYF_APODERADOS pa WITH (NOLOCK) on pa.id_entidad = s.C1665 
	inner join cli_documentospfpj docc WITH (NOLOCK) on pa.ID_PERSONA = docc.NUMEROPERSONAFJ
	inner join CLI_ClientePersona cp WITH (NOLOCK) on cp.CODIGOCLIENTE = s.C1803 and cp.TITULARIDAD = ''T''
	inner join cli_documentospfpj docT WITH (NOLOCK) on docT.NUMEROPERSONAFJ = cp.NUMEROPERSONA
	INNER JOIN VW_ASISTENCIAS_DEUDA VAD ON VAD.JTS_OID=S.JTS_OID
	inner join saldos ctav on s.C1665 = ctav.JTS_OID  --saldos para cuenta de cobro
	WHERE S.C1604<0 AND S.TZ_LOCK=0
	AND S.C1785 = 5  --prestamos 
	and pa.tipo_poder = 666;
');

execute('
CREATE VIEW dbo.VW_NBCH24_CTA_ACUERDOS (jts_oid, nroAcuerdo, importe, tasa, fechaInicio, fechaVencimiento)
AS
	SELECT S.JTS_OID_SALDO, S.Nro_Autorizacion, s.Importe, t.tasa, S.Valor_vigencia, S.Fecha_vencimiento
    FROM VTA_SOBREGIROS S WITH(NOLOCK) 
    INNER JOIN VTA_TASAS_SOBREGIROS T WITH(NOLOCK)  on T.NRO_ACUERDO = s.Nro_Autorizacion
    WHERE S.tz_lock=0 AND estado =1;
');

execute('
CREATE VIEW dbo.VW_NBCH24_CTA_BLOQUEOS 
AS
	select saldo_jts_oid jts_oid, gb.COD_BLOQUEO codBloqueo, gcb.DESCRIPCION descripcion, gb.DESCRIPCION causa, 
	case when ACCIONES_DEBITO in (2, 3) then ''S'' else ''N'' end bloqueoDebito, 
	case when ACCIONES_CREDITO in (2, 3) then ''S'' else ''N'' end bloqueoCredito
	from GRL_BLOQUEOS gb WITH (NOLOCK) INNER join GRL_COD_BLOQUEOS gcb WITH (NOLOCK) on  gb.COD_BLOQUEO = gcb.COD_BLOQUEO 
	where   estado = 1 
	and gb.TZ_LOCK  = 0
	and gcb.TZ_LOCK  = 0;
');

execute('
CREATE VIEW dbo.VW_NBCH24_CTA_TENENCIA
AS
    select pa.id_entidad jts_oid, 
	pa.ID_PERSONA idPersonaUsuario,  
	s.PRODUCTO producto, 
	p.C6251 productoDescripcion,
	s.C1785 modulo, 
	s.SUCURSAL sucursal, 
	s.CUENTA cuenta, 
	s.moneda moneda,
	m.C6400 descripcionMoneda, 
	m.c6401 signoMoneda, 
	m.c6440 cotBcra, 
	s.c1803 cliente, 
	c.SUBDIVISION1 sector, 
 	ccp.numeropersona idPersonaTitular, 
	doct.NUMERODOCUMENTO documentoTitular,
	s.C1679 estado, 
	S.C1604 saldo, 
	(S.C1604 + S.C1605 + S.C1683 + S.C2627) saldoDisponible,
	(s.C1605 + s.C2627) saldoBloqueado,
	s.C1606 saldo24hs,
	s.C1607 saldo48hs,
	v.CTA_CBU cbu,
	case when pa.tipo_poder = 50 then ''F'' else ''A'' end rol, 
	pa.FECHA_INI_VIGENCIA fechaInicioPoder, 
	pa.FECHA_VENCIMIENTO fechaFinPoder, 
	case when s.C1679 = ''1'' then ''S'' else ''N'' end bloqueoCuenta, 	
	docc.numerodocumento documentoUsuario,
	CASE WHEN EXISTS (select 1 from PYF_APODERADOS pTrf WITH (NOLOCK) where pa.ID_ENTIDAD = pTrf.ID_ENTIDAD and pa.ID_PERSONA = pTrf.ID_PERSONA and pTrf.TIPO_ENTIDAD = 2 and pTrf.TIPO_PODER = 5) THEN ''S'' ELSE ''N'' END poderTRF, --poder de transferencia de fondos
	CASE WHEN EXISTS (select 1 from PYF_APODERADOS pTj WITH (NOLOCK) where pa.ID_ENTIDAD = pTj.ID_ENTIDAD and pa.ID_PERSONA = pTj.ID_PERSONA and pTj.TIPO_ENTIDAD = 2 and pTj.TIPO_PODER = 43) THEN ''S'' ELSE ''N'' END poderTJD, --poder TJD
	case when(s.PRODUCTO = 9 or s.PRODUCTO = 10) then docc.numerodocumento else doct.NUMERODOCUMENTO end documentoContexto,
	em.EMAIL email 
	from PYF_APODERADOS pa WITH (NOLOCK)
	inner join saldos s WITH (NOLOCK) on pa.id_entidad = s.jts_oid 
	inner join VTA_SALDOS v WITH (NOLOCK) on s.JTS_OID = v.JTS_OID_SALDO
	inner join productos p WITH (NOLOCK) on s.producto = p.C6250
	inner join cli_documentospfpj docc WITH (NOLOCK) on pa.ID_PERSONA = docc.NUMEROPERSONAFJ
	inner join CLI_ClientePersona ccp WITH (NOLOCK) on ccp.codigocliente = s.c1803 
	inner join cli_documentospfpj doct WITH (NOLOCK) on ccp.numeropersona = doct.NUMEROPERSONAFJ
	inner join CLI_CLIENTES c WITH (NOLOCK) on c.CODIGOCLIENTE = s.c1803 
	inner join monedas m WITH (NOLOCK) on s.MONEDA = m.c6399
	left join GRL_ESTADOS_DE_CUENTA ec on ec.JTSOID = s.JTS_OID and ec.correo_tradicional = ''S'' and ec.TZ_LOCK=0
	left join CLI_EMAILS em on em.FORMATO = ec.FORMATO_MAIL  and em.TIPO = ec.TIPO_MAIL and em.ORDINAL = ec.ORDINAL_MAIL  and em.ID = ccp.numeropersona and  ec.jtsoid = s.jts_oid
	where pa.tipo_poder in(50, 51)
	and pa.tipo_Entidad = 2 
	and pa.TZ_LOCK = 0 
	and v.TZ_LOCK = 0
	and s.TZ_LOCK = 0 and s.c1651 in ('''', '' '', ''0'', null) --codigo cancelacion
	and p.tz_lock = 0
	and docc.TZ_LOCK = 0
	and c.TZ_LOCK = 0
	and ccp.TZ_LOCK = 0 AND TITULARIDAD = ''T''
	and (c.SUBDIVISION1 not in (''02'') or (s.PRODUCTO in (9, 10))) -- excluye clientes sector publico, excepto cuentas DJ;
');

execute('
CREATE VIEW dbo.VW_NBCH24_CTA_TJD(tipo, tarjeta, doc, jts_oid, descripcion, producto, clase, titularidad, primaria, ambito, comprasExterior)
AS
	select ''TJD'', t.ID_TARJETA, docc.numerodocumento, c.saldo_jts_oid, ttt.descripcion, ttt.codigo_producto, ttt.clase, t.titularidad,
	case when c.ESTADO in (''3'',''R'',''E'') then ''S'' else ''N'' end, --primaria
	case when c.ESTADO = ''3'' then ''NACIONAL'' when c.ESTADO = ''R'' then ''GLOBAL'' when c.ESTADO = ''E'' then ''EXTERIOR''  when c.ESTADO = ''1'' then ''VINCULADA'' else '''' end, --ambito
	case when c.ESTADO IN (''E'',''R'', ''1'', ''3'') then ''S'' else ''N'' end 
	from TJD_TARJETAS t WITH (NOLOCK)
	inner join TJD_TIPO_TARJETA ttt WITH (NOLOCK) on ttt.tipo_tarjeta = t.tipo_Tarjeta
	inner join TJD_REL_TARJETA_CUENTA c WITH (NOLOCK) on t.ID_TARJETA=c.ID_TARJETA
	inner join cli_documentospfpj docc WITH (NOLOCK) on t.nro_persona = docc.NUMEROPERSONAFJ
	where t.ESTADO in (''0'', ''1'') and c.ESTADO NOT IN (''9'', ''X'')
	and c.TZ_LOCK = 0
	and docc.TZ_LOCK = 0

	UNION 

	select ''TJV'', caf.NRO_tARJETA, doc.numerodocumento, caf.saldo_jts_oid, null, null, null, Null,
	''N'', '' '', ''N''  
	from itf_lk_Caf_cuentas caf WITH (NOLOCK)
	inner join saldos s WITH (NOLOCK) on caf.saldo_jts_oid = s.jts_oid 
	inner join CLI_ClientePersona ccp WITH (NOLOCK) on ccp.CODIGOCLIENTE = s.c1803
	inner join cli_documentospfpj doc WITH (NOLOCK) on doc.numeropersonafj = ccp.numeropersona 
	where estado_Cuenta = ''1''
	and ccp.TZ_LOCK = 0 and ccp.TITULARIDAD = ''T'' 
	and doc.TZ_LOCK = 0
	and caf.NRO_TARJETA not in (select x.ID_TARJETA  from TJD_TARJETAS x WITH (NOLOCK) where x.ESTADO in (''0'', ''1''));
');

execute('
CREATE VIEW dbo.VW_NBCH24_DPF_PIZARRA
	AS
	select p.C6250 codProducto, 
	p.C6251 descProducto, 
	t.PLAZOMINCANC plazoMinCanc,
	p.TIPO tipo,  --A: ambos, --E: PJ, --P: PF
	pr.MONEDA moneda,
	t.PLAZOMINIMO plazoMin,
	t.PLAZOMAXIMO plazoMax,
	t.MONTOMINIMOAPER montoMin, 
	t.MONTOMAXIMOAPER montoMax, 
	pr.HABILITADO habilitado
	from TOPESPRODUCTO t WITH (NOLOCK)
	inner join PRODUCTOS p WITH (NOLOCK) on p.C6250 = t.CODPRODUCTO 
	inner join prod_relcanales pr WITH (NOLOCK) on pr.producto = p.c6250 and t.MONEDA = pr.MONEDA
	where p.C6252 = 4 --producto DPF
	and pr.CANAL = 4 --canal
	and p.TZ_LOCK = 0
	and pr.TZ_LOCK = 0
	and t.TZ_LOCK  = 0;
');

execute('
CREATE VIEW dbo.VW_NBCH24_GRL_COTIZACIONES(codigo, cotBCRA, cotCompra, cotVenta, fecha)
AS
	SELECT C6399, c6440, TCCOMPRACOMUN, TCVENTACOMUN, FECHAPROCESO FROM MONEDAS WITH (NOLOCK), PARAMETROS WITH (NOLOCK)

	union 

	SELECT moneda, tipo_cambio_oficial, TIPO_CAMBIO_COMPRA, TIPO_CAMBIO_VENTA, FECHA_COTIZACION FROM  HISTORICOTIPOSCAMBIO WITH (NOLOCK);
');

execute('
CREATE VIEW dbo.VW_NBCH24_DPF_TENENCIA
AS
	SELECT 
	cast(s.sucursal as varchar) + ''-'' + cast(s.operacion as varchar) + ''-'' + cast(s.C1800 as varchar) id,
	s.PRODUCTO producto, 
	s.sucursal, 
	s.cuenta, 
	s.moneda mon, 
	s.operacion, 
	p.C6251 descripcion,
	s.c1800 canal, 
	s.MONEDA moneda, 
	s.C1621 fechaAlta, 
	s.C1627 fechaVenc, 
	CASE WHEN (t.PLAZOMINCANC > 0) THEN DATEADD(day, t.PLAZOMINCANC, s.C1621) ELSE null END AS fechaMinPrecanc,
	abs(DATEDIFF( DAY, s.C1627, s.C1621)) plazo, 
	s.c1601 capital, 
	s.C1604 saldo, 
	s.C1608 interes, 
	s.c1600 montoOriginal, 
	s.c1601 + s.C1608  montoCobrar,
	COALESCE(ctz.cotBcra, 0) cotizacionOriginal, 
	mon.c6440 cotizacionActual,
	s.C1659 accionVenc, 
	opc.DESCRIPCION accionDesc, 
	s.C1632 tea,
	((POWER(1 + s.C1632 / 100.0, 1.0 / 12) - 1) * 12) * 100 AS tna,
	(((POWER(1 + s.C1632 / 100.0, 1.0 / 12) - 1) * 12) * 100)  / 12 AS tem,
	ps.RETENCION retencion, 
	s.C1665  jtsCuentaCobro,
	ctav.c1785 moduloCuentaCobro, 
	ctav.SUCURSAL sucursalCuentaCobro, 
	ctav.CUENTA cuentaCobro,
	s.JTS_OID jtsDPF,
	s.c1803 cliente, 
	pa.ID_PERSONA idPersonaUsuario, 
	docc.numerodocumento documentoUsuario,
	docT.NUMEROPERSONAFJ idPersonaTitular,
	docT.NUMERODOCUMENTO documentoTitular,
	case when(ctav.PRODUCTO = 9 or ctav.PRODUCTO = 10) then docc.numerodocumento else docT.NUMERODOCUMENTO end documentoContexto
	FROM SALDOS s WITH (NOLOCK)
	inner join PRODUCTOS p WITH (NOLOCK) on p.C6250 = s.PRODUCTO 
	inner join OPCIONES opc WITH (NOLOCK) on opc.OPCIONDEPANTALLA = s.C1659 and opc.NUMERODECAMPO = 1659 and IDIOMA = ''E''
	inner  join PYF_APODERADOS pa WITH (NOLOCK) on pa.id_entidad = s.C1665 
	inner join cli_documentospfpj docc WITH (NOLOCK) on pa.ID_PERSONA = docc.NUMEROPERSONAFJ
	INNER join MONEDAS mon WITH (NOLOCK) on mon.C6399 = s.MONEDA 
	inner join PZO_SALDOS ps WITH (NOLOCK) on  ps.JTS_OID_SALDO = s.JTS_OID 
	inner join CLI_ClientePersona cp WITH (NOLOCK) on cp.CODIGOCLIENTE = s.C1803 and cp.TITULARIDAD = ''T''
	inner join cli_documentospfpj docT WITH (NOLOCK) on docT.NUMEROPERSONAFJ = cp.NUMEROPERSONA
	inner join saldos ctav on s.C1665 = ctav.JTS_OID  --saldos para cuenta de cobro 
	left join TOPESPRODUCTO t on t.CODPRODUCTO = s.PRODUCTO and t.MONEDA = s.moneda
	left join VW_NBCH24_GRL_COTIZACIONES ctz WITH (NOLOCK) on s.C1621  = ctz.fecha and ctz.codigo = s.MONEDA --fecha de cotizacion para UVA
	WHERE s.C1785=4  --dpf
	and pa.tipo_poder = 50
	and (s.C1604 != 0 or s.C1608 != 0) -- activos 
	and s.TZ_LOCK  = 0
	and p.TZ_LOCK = 0
	and pa.tipo_Entidad = 2 
	and pa.TZ_LOCK = 0 
	--AND s.C1803 = 17969463;
');

execute('
CREATE PROCEDURE dbo.SP_NBCH24_MOVIMIENTOS
    @P_jtsoid numeric(15, 0),
    @P_fechaDesde datetime,
    @P_fechaHasta datetime,
    @P_pagina integer, 
    @P_cantidad integer,
    @P_ttr nvarchar(MAX) = NULL,
    @P_fv char(1)
AS
BEGIN

    SET NOCOUNT ON;

    Select 
    h.MOV_JTS_OID id,
    h.SALDO_JTS_OID jts_oid, 
    h.FECHA_VALOR fechaValor,
    h.FECHA_PROCESADO fechaProceso, 
    a.HORAFIN fechaHoraReloj ,
    h.DEBITO_CREDITO operacion, 
    h.MONTO monto, 
    case when DEBITO_CREDITO = ''D'' then -h.monto else h.monto end importe,
    COALESCE(SALDO_AJUSTADO, 0)  + 
    SUM(case when DEBITO_CREDITO = ''D'' then -h.monto else h.monto end ) OVER (PARTITION BY h.FECHA_VALOR ORDER BY h.FECHA_VALOR, h.MOV_JTS_OID) AS saldoParcial,
    h.CONCEPTO concepto,
    a.OPERACION nroOperacion, 
    h.CODIGO_TRANSACCION codTransaccion, 
    h.ASIENTO comprobante,
    dbo.diaHabil(h.fecha_Valor - 1, ''D'') fechaSaldo, 
    COALESCE(SALDO_AJUSTADO, 0) saldoDiario,
    COALESCE(ctz.cotBcra, 0) cotizacion,
    hm.infoExtendida detalle
    from HISTORIA_VISTA h WITH (NOLOCK)
    inner join ASIENTOS A WITH (NOLOCK) on H.ASIENTO = A.ASIENTO and H.SUCURSAL = A.SUCURSAL and H.FECHA_PROCESADO = A.FECHAPROCESO 
    inner join HISTORICO_MOVIMIENTOS hm WITH (NOLOCK) on h.MOV_JTS_OID = hm.movJtsOid  
    inner join saldos s WITH (NOLOCK) on s.JTS_OID = h.SALDO_JTS_OID 
    left JOIN STRING_SPLIT(@P_ttr, '','') AS ttr ON ttr.value = h.CODIGO_TRANSACCION
    left join GRL_SALDOS_DIARIOS sal WITH (NOLOCK) on sal.fecha = dbo.diaHabil(h.fecha_Valor - 1, ''D'') and h.SALDO_JTS_OID = sal.SALDOS_JTS_OID
    left join VW_NBCH24_GRL_COTIZACIONES ctz WITH (NOLOCK) on h.FECHA_VALOR = ctz.fecha and ctz.codigo = s.moneda --fecha de cotizacion para UVA
    where a.ESTADO = 77 and h.MONTO > 0 
    and h.SALDO_JTS_OID = @P_jtsoid and h.FECHA_VALOR BETWEEN @P_fechaDesde and @P_fechaHasta   
    and  (@P_ttr IS NULL OR ttr.value IS NOT NULL) --si @p_ttr es null incluye todos los codigos de transaccion 
    and (@P_fv <> ''S'' OR h.FECHA_VALOR < h.FECHA_PROCESADO)
    order by h.FECHA_VALOR, a.HORAFIN 
    OFFSET (@P_pagina - 1) * @P_cantidad ROWS
    FETCH NEXT @P_cantidad ROWS ONLY

END;
');

