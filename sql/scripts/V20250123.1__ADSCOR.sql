EXEC('
--Funcion de Calculo 
CREATE OR ALTER FUNCTION dbo.F_ADINTAR_SCORING_CALCULO 
( 
	@SALDO_JTS_OID NUMERIC(15,0) 
) 
RETURNS TABLE 
AS 
RETURN 
( 
	select 
	E2.CONVENIO, 
	CONVERT(NUMERIC(15,2), E2.MONTO) as ''TOTAL_MONTO'' 
	from 
	( 
		select 
		E1.SALDO_JTS_OID, 
		E1.CONVENIO, 
		AVG(E1.MONTO) as ''MONTO'', 
		ROW_NUMBER () over (partition by E1.SALDO_JTS_OID order by AVG(E1.MONTO) DESC) as ''NRO_REG_MONTO'' 
		from 
		( 
			select 
			csas.SALDO_JTS_OID, 
			DATETRUNC(MONTH, csas.FECHA) as ''PERIODO'', 
			csas.CONVENIO, 
			SUM(csas.MONTO) as ''MONTO'', 
			ROW_NUMBER () over (partition by csas.SALDO_JTS_OID, csas.CONVENIO order by DATETRUNC(MONTH, csas.FECHA) DESC) as ''NRO_REG_RECIENTE'' 
			from CRE_SOL_ACREDITACIONES_SUELDOS csas (nolock) 
			where csas.SALDO_JTS_OID = @SALDO_JTS_OID and csas.TIPO = ''S'' and csas.TZ_LOCK = 0 and DATETRUNC(MONTH, csas.FECHA) >= (select DATEADD(MONTH, -(select imp.NUMERICO_1 from ITF_MASTER_PARAMETROS imp where imp.CODIGO_INTERFACE = 1319 and imp.ALFA_1 = ''PERIODOS_ATRAS_P'')-2, DATETRUNC(MONTH, p.FECHAPROCESO)) as ''PERIODO_ACTUAL'' from PARAMETROS p) 
			group by csas.SALDO_JTS_OID, DATETRUNC(MONTH, csas.FECHA), csas.CONVENIO 
			--order by csas.SALDO_JTS_OID ASC, csas.CONVENIO ASC, DATETRUNC(MONTH, csas.FECHA) DESC 
		) E1 
		where E1.NRO_REG_RECIENTE <= (select imp.NUMERICO_1 from ITF_MASTER_PARAMETROS imp where imp.CODIGO_INTERFACE = 1319 and imp.ALFA_1 = ''PERIODOS_ATRAS_P'') 
		group by E1.SALDO_JTS_OID, E1.CONVENIO 
		--order by E1.SALDO_JTS_OID ASC, SUM(E1.MONTO) DESC 
	) E2 
	where E2.NRO_REG_MONTO = 1
	--order by E2.SALDO_JTS_OID ASC;
);
');

EXEC('
--Vista 
CREATE OR ALTER VIEW dbo.VW_ADINTAR_SCORING 
AS 
select 
cdp.NUMERODOCUMENTO as ''CUIT'', 
ccp.NUMEROPERSONA as ''NRO_PERSONA'', 
CONVERT(numeric(12,0), s.C1803) as ''NRO_CLIENTE'', 
s.SUCURSAL as ''SUCURSAL'', 
s.CUENTA as ''CUENTA'', 
s.C1785 as ''MODULO'', 
s.JTS_OID as ''SALDO_JTS_OID'', 
vasc.CONVENIO, 
vasc.TOTAL_MONTO 
from SALDOS s (nolock) 
inner join CLI_ClientePersona ccp (nolock) on ccp.CODIGOCLIENTE = s.C1803 and ccp.TITULARIDAD = ''T'' and left(ccp.TZ_LOCK, 1) in (0,4) 
inner join CLI_DocumentosPFPJ cdp (nolock) on cdp.NUMEROPERSONAFJ = ccp.NUMEROPERSONA and left(cdp.TZ_LOCK, 1) in (0,4) 
cross apply F_ADINTAR_SCORING_CALCULO(s.JTS_OID) vasc 
where left(s.TZ_LOCK,1) in (0,4); 
');

EXEC('
--Verifica existencia de acreditacion para un convenio 
CREATE OR ALTER PROCEDURE dbo.SP_ADINTAR_EXISTE_ACRED_CONVENIO 
	@P_NRO_CLIENTE FLOAT, 
	@P_CONVENIO NUMERIC(15,0), 
	@EXISTE NUMERIC(15,0) OUTPUT 
AS 
BEGIN 
	SET @EXISTE = 0;
	
	SELECT top 1 
	@EXISTE = COALESCE(a.CONVENIO,0) 
	FROM SALDOS s (nolock) 
	INNER JOIN CRE_SOL_ACREDITACIONES_SUELDOS a (nolock) ON s.JTS_OID = a.SALDO_JTS_OID AND a.TZ_LOCK = 0 
	INNER JOIN CLI_ClientePersona c (nolock) ON c.CODIGOCLIENTE = s.C1803 AND c.TITULARIDAD = ''T'' and left(c.TZ_LOCK, 1) in (0,4) 
	WHERE c.CODIGOCLIENTE = @P_NRO_CLIENTE AND a.CONVENIO = @P_CONVENIO AND left(s.TZ_LOCK,1) in (0,4) 
END; 
');

EXEC('
--SP para el servicio de Scoring 
CREATE OR ALTER PROCEDURE dbo.SP_ADINTAR_SCORING_SERVICE 
	@NRO_CLIENTE FLOAT, 
	@TotalMonto NUMERIC(15,2) OUTPUT, 
	@Convenio NUMERIC(15,0) OUTPUT 
AS 
BEGIN 
	SET @TotalMonto = 0;
	SET @Convenio = 0;
	
	SELECT TOP 1 
	@TotalMonto = COALESCE(TOTAL_MONTO,0), 
	@Convenio = COALESCE(CONVENIO,0) 
	FROM VW_ADINTAR_SCORING 
	WHERE NRO_CLIENTE = @NRO_CLIENTE 
	ORDER BY TOTAL_MONTO DESC 
END;
');

EXEC('
ALTER TABLE dbo.ITF_AD_SCORING_AUX 
ADD REM_NO_COMP NUMERIC(15,2) NULL;
');

EXEC('
DELETE FROM dbo.DICCIONARIO where NUMERODECAMPO=8164; 
');

EXEC('
INSERT INTO dbo.DICCIONARIO (NUMERODECAMPO,USODELCAMPO,REFERENCIA,DESCRIPCION,PROMPT,LARGO,TIPODECAMPO,DECIMALES,EDICION,CONTABILIZA,CONCEPTO,CALCULO,VALIDACION,TABLADEVALIDACION,TABLADEAYUDA,OPCIONES,TABLA,CAMPO,BASICO,MASCARA) 
	VALUES (8164,'''',0,''REM_NO_COMP'',''REM_NO_COMP'',15,''N'',2,'''',0,0,0,0,0,0,0,988,''REM_NO_COMP'',0,''''); 
');

EXEC('
CREATE OR ALTER VIEW dbo.VW_NBCH24_ACCESOSCV
AS
select 
    pa.id_entidad jts_oid, 
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
where pa.tipo_poder in(50, 51)
	and pa.tipo_Entidad = 2 and 
	s.C1785 in (2, 3);
');

EXEC('
CREATE OR ALTER VIEW dbo.VW_NBCH24_CTA_TENENCIA
AS
    select s.JTS_OID jts_oid, 
	acv.idPersonaUsuario idPersonaUsuario,  
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
 	acv.idPersonaTitular idPersonaTitular, 
	acv.documentoTitular documentoTitular,
	s.C1679 estado, 
	S.C1604 saldo, 
	(S.C1604 + S.C1605 + S.C1683 + S.C2627) saldoDisponible,
	(s.C1605 + s.C2627) saldoBloqueado,
	s.C1606 saldo24hs,
	s.C1607 saldo48hs,
	v.CTA_CBU cbu,
	case when acv.tipoPoder = 50 then ''F'' else ''A'' end rol, 
	acv.fechaFinPoder fechaInicioPoder, 
	acv.fechaFinPoder fechaFinPoder, 
	case when s.C1679 = ''1'' then ''S'' else ''N'' end bloqueoCuenta, 	
	acv.documentoUsuario documentoUsuario,
	CASE WHEN EXISTS (select 1 from PYF_APODERADOS pTrf WITH (NOLOCK) where acv.jts_oid =  pTrf.ID_ENTIDAD2 and acv.idPersonaUsuario = pTrf.ID_PERSONA and pTrf.TIPO_ENTIDAD = 2 and pTrf.TIPO_PODER = 5) THEN ''S'' ELSE ''N'' END poderTRF, --poder de transferencia de fondos
	COALESCE((LEN(f.formula) - LEN(REPLACE(f.formula, ''A'', ''''))), 0) ordenTRF, 
	CASE WHEN EXISTS (select 1 from PYF_APODERADOS pTj WITH (NOLOCK) where acv.jts_oid =  pTj.ID_ENTIDAD2 and acv.idPersonaUsuario = pTj.ID_PERSONA and pTj.TIPO_ENTIDAD = 2 and pTj.TIPO_PODER = 43) THEN ''S'' ELSE ''N'' END poderTJD, --poder TJD
	acv.documentoContexto documentoContexto,
 
    (select em.EMAIL from CLI_EMAILS em inner join GRL_ESTADOS_DE_CUENTA ec on em.FORMATO = ec.FORMATO_MAIL  and em.TIPO = ec.TIPO_MAIL and em.ORDINAL = ec.ORDINAL_MAIL  
	and em.ID = acv.idPersonaTitular where ec.PRODUCTO = s.PRODUCTO and ec.SUCURSAL = s.SUCURSAL and ec.CUENTA = s.CUENTA and ec.MONEDA = s.MONEDA and ec.TIPO_EMISION = ''N'' and 
	ec.OPERACION = 0 and ec.ORDINAL = 0 ) email
	
	from  saldos s WITH (NOLOCK)
	inner join VTA_SALDOS v WITH (NOLOCK) on s.JTS_OID = v.JTS_OID_SALDO
	inner join productos p WITH (NOLOCK) on s.producto = p.C6250	
	inner join VW_NBCH24_ACCESOSCV acv on CONVERT(VARCHAR(10), s.jts_oid) = acv.jts_oid 
	inner join CLI_CLIENTES c WITH (NOLOCK) on c.CODIGOCLIENTE = s.c1803 
	inner join monedas m WITH (NOLOCK) on s.MONEDA = m.c6399
	left join PYF_FORMULAS f on CONVERT(VARCHAR(10), s.jts_oid) = f.id_entidad  and f.TIPO_ENTIDAD = 2 and f.tipo_poder = 5

	where (c.SUBDIVISION1 not in (''02'')  or (s.PRODUCTO in (9, 10))) -- excluye clientes sector publico, excepto cuentas DJ 
	and v.TZ_LOCK = 0
	and s.TZ_LOCK = 0 and s.c1651 in ('''', '' '', ''0'', null) --codigo cancelacion
	and s.C1785 in (2, 3)
	and p.tz_lock = 0	
	and c.TZ_LOCK = 0;
');

EXEC('
DROP INDEX IF EXISTS IDX_NBCH24_PYF_APODERADOS_01 ON PYF_APODERADOS;
DROP INDEX IF EXISTS IDX_NBCH24_HISTORIA_VISTA_01 ON HISTORIA_VISTA;
');

EXEC('
CREATE NONCLUSTERED INDEX [IDX_NBCH24_PYF_APODERADOS_01] ON [dbo].[PYF_APODERADOS]
(
	[TIPO_ENTIDAD] ASC,
	[ID_PERSONA] ASC,
	[TIPO_PODER] ASC
)
INCLUDE([FECHA_VENCIMIENTO],[FECHA_INI_VIGENCIA]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];
');

EXEC('
CREATE NONCLUSTERED INDEX [IDX_NBCH24_HISTORIA_VISTA_01] ON [dbo].[HISTORIA_VISTA] ([SALDO_JTS_OID],[MONTO]);
');

EXEC('
UPDATE dbo.OPERACIONES
	SET COMPORTAMIENTOENCIERRE=''D'',PERMITEESTADODIFERIDO=''S''
	WHERE TITULO=6800 AND IDENTIFICACION=8908;
');

EXEC('
UPDATE dbo.DESCRIPTORES
	SET ACEPTA_MOVS_DIFERIDO=''S''
	WHERE TITULO=930 AND IDENTIFICACION=849;
');

EXEC('
CREATE OR ALTER PROCEDURE [dbo].[SP_NBCH24_MOVIMIENTOS]
    @P_jtsoid numeric(15, 0),
    @P_fechaDesde datetime,
    @P_fechaHasta datetime,
    @P_pagina integer, 
    @P_cantidad integer,
    @P_ttr nvarchar(MAX) = NULL,
    @P_fv char(1),
    @P_filter char(5)
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
    left join HISTORICO_MOVIMIENTOS hm WITH (NOLOCK) on h.MOV_JTS_OID = hm.movJtsOid  
    inner join saldos s WITH (NOLOCK) on s.JTS_OID = h.SALDO_JTS_OID 
    left JOIN STRING_SPLIT(@P_ttr, '','') AS ttr ON ttr.value = h.CODIGO_TRANSACCION
    left join GRL_SALDOS_DIARIOS sal WITH (NOLOCK) on sal.fecha = dbo.diaHabil(h.fecha_Valor - 1, ''D'') and h.SALDO_JTS_OID = sal.SALDOS_JTS_OID
    left join VW_NBCH24_GRL_COTIZACIONES ctz WITH (NOLOCK) on h.FECHA_VALOR = ctz.fecha and ctz.codigo = s.moneda --fecha de cotizacion para UVA
    where a.ESTADO = 77 and h.MONTO > 0 
    and 
    ((h.SALDO_JTS_OID = @P_jtsoid and cast(h.FECHA_PROCESADO as Date) BETWEEN @P_fechaDesde and @P_fechaHasta and @P_filter = ''*PROC'') 
    or 
    (h.SALDO_JTS_OID = @P_jtsoid and cast(a.HORAFIN as Date)  BETWEEN @P_fechaDesde and @P_fechaHasta and @P_filter = ''*TIME'') )
    and  (@P_ttr IS NULL OR ttr.value IS NOT NULL) --si @p_ttr es null incluye todos los codigos de transaccion 
    and (@P_fv <> ''S'' OR h.FECHA_VALOR < h.FECHA_PROCESADO)
    order by h.FECHA_VALOR DESC, a.HORAFIN DESC
    OFFSET (@P_pagina - 1) * @P_cantidad ROWS
    FETCH NEXT @P_cantidad ROWS ONLY
END;
');

Execute('UPDATE dbo.DICCIONARIO
SET CAMPO = ''TIPO_PERSONA''
WHERE NUMERODECAMPO = 21327');
