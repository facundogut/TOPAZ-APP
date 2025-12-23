EXECUTE('DROP PROCEDURE dbo.SP_LINK_MOV_CONFORMADOS;')
EXECUTE('
CREATE  PROCEDURE dbo.SP_LINK_MOV_CONFORMADOS 
	@fch_chr AS VARCHAR(10)

AS
BEGIN

	DECLARE @fch_proceso DATETIME;
	SET @fch_proceso  = CONVERT(datetime, @fch_chr,101);	 
		
	DECLARE @prueba VARCHAR (20);
	
   	DELETE FROM ITF_LINK_MOVCONFORMADOS;

	
	EXEC SP_LINK @fch_chr, ''1'', 1;				
   
   	INSERT INTO ITF_LINK_MOVCONFORMADOS (tipo_registro, banco, tipo_cuenta, moneda, cuenta, cbu, fecha_mov, fecha_valor,
		deb_cred, monto, secuencia, referencia, fecha_proceso, depositante, jts_oid, secuencia_gral) 


	SELECT
		''CONFOR'' AS ''Tipo_registro'' ,
		(SELECT NUMERICO FROM PARAMETROSGENERALES WHERE [CODIGO] = 2) AS ''Banco'',
		(CASE
			WHEN s.MONEDA = (SELECT MONNAC FROM PARAMETROS) and p.c6252=2 and p.TIPO_CUENTA_VISTA =14 THEN ''0''
			WHEN s.MONEDA = (SELECT MONNAC FROM PARAMETROS) and p.c6252=3 and p.TIPO_CUENTA_VISTA =13 THEN ''6''
			WHEN s.MONEDA = 2 and p.c6252=3 and p.TIPO_CUENTA_VISTA =13 THEN ''7''
			WHEN s.MONEDA = (SELECT MONNAC FROM PARAMETROS) and p.c6252 in (2,3) and p.TIPO_CUENTA_VISTA not in (13,14) then ''1''
			WHEN s.MONEDA = 2 and p.c6252 in (2,3) and p.TIPO_CUENTA_VISTA not in (13,14) then ''2''
		END) AS ''Tipo_cuenta'',
	    (CASE WHEN s.MONEDA = 1 THEN ''00'' 
	    	  WHEN s.MONEDA = 988 THEN ''00'' 
	    	  WHEN s.MONEDA = 999 THEN ''00'' 
	    	  WHEN s.MONEDA = 2 THEN ''01'' END) AS ''MONEDA'',

		RIGHT(REPLICATE(''0'', 19)+ CAST(vt.CTA_REDLINK AS VARCHAR(19)), 19) AS ''cuenta'',	
		LEFT(REPLICATE('' '', 23)+ CAST(vt.CTA_CBU AS VARCHAR(23)), 23) AS ''cbu'',	 
	    hv.FECHA_PROCESADO AS ''Fecha-mov'',
		hv.FECHA_VALOR AS ''Fecha-valor'',
		hv.DEBITO_CREDITO AS ''Tipo de operación'',
		RIGHT(REPLICATE(''0'', 17)+ CAST(floor((hv.MONTO*100)) AS VARCHAR(17)), 17) AS ''Monto'',
		RIGHT(REPLICATE(''0'', 4)+ CAST(itf.secuencia  AS VARCHAR(4)), 4)  AS ''secuencia'',
		RIGHT(REPLICATE(''0'', 13)+ CAST(itf.asiento AS VARCHAR(13)), 13) AS  ''referencia'',
		@fch_proceso AS ''fecha_proceso'',
		
	    RIGHT(REPLICATE('' '', 150)+ CAST((CASE 
	  		WHEN hv.DEBITO_CREDITO = ''C'' THEN ''CRED.TRANSF.ID '' + (vpj.NUMERODOCUMENTO) + '' '' + ISNULL(vc.NOMBRE_I, '''') + '' '' + ISNULL(vc.APELLIDO_I, '''')
	  		WHEN hv.DEBITO_CREDITO = ''D'' THEN hv.CONCEPTO
	  	 END) AS VARCHAR(150)), 150)  AS ''depositante'',
	  	
		itf.jts_oid, 
		ROW_NUMBER() OVER (ORDER BY hv.FECHA_PROCESADO desc) AS ''secuencia_gral''

	FROM
		ITF_MOVCONFORMADOS itf
	INNER JOIN HISTORIA_VISTA hv ON
		itf.asiento = hv.ASIENTO
		AND itf.fch_procesado = hv.FECHA_PROCESADO
		AND itf.sucursal = hv.SUCURSAL
		AND itf.nro_mov = hv.NUMERO_MOVIMIENTO
		and itf.ordinal = hv.ORDINAL
		AND itf.ordinal = hv.ORDINAL
		AND itf.TRTIPO = hv.TRTIPO
		AND itf.TRVIRTUAL = hv.TRVIRTUAL
		AND itf.jts_oid = hv.SALDO_JTS_OID
	INNER JOIN saldos s ON
		s.JTS_OID = itf.jts_oid AND s.C1679=0
	INNER JOIN vta_saldos vt ON
		vt.JTS_OID_SALDO = itf.jts_oid
	INNER JOIN productos p on p.c6250=itf.tpo_prod
	INNER JOIN CLI_CLIENTES AS c  ON c.[CODIGOCLIENTE]=s.C1803
	INNER JOIN VTA_CUMPLIMIENTO vc ON vc.ASIENTO=hv.ASIENTO AND vc.SALDO_JTS_OID=hv.SALDO_JTS_OID
	INNER JOIN PROD_RELCANALES pr ON pr.CANAL = 3 AND pr.HABILITADO = ''S''
	JOIN CLI_ClientePersona cp ON cp.[CODIGOCLIENTE] = c.[CODIGOCLIENTE]
	JOIN VW_CLI_DOCUMENTOSPFPJ_MEJORADA  vpj ON vpj.NUMEROPERSONAFJ = cp.NUMEROPERSONA
   	WHERE
		itf.fch_procesado <= @fch_proceso 
	  	AND c.SUBDIVISION1 <> ''02''
	  	AND s.TZ_LOCK=0
		AND c.TZ_LOCK=0
		AND vt.TZ_LOCK=0
	    AND	p.TZ_LOCK=0
	
  UPDATE ITF_LINK_MOVCONFORMADOS SET cant_registros= (SELECT max(secuencia_gral) FROM ITF_LINK_MOVCONFORMADOS)
END')

