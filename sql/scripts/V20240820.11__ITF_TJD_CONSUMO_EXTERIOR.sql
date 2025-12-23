EXECUTE('
CREATE OR ALTER       PROCEDURE ITF_TJD_CONSUMO_EXTERIOR(
  @DI_FECHA DATETIME)
AS
  DECLARE @FechaIni DATETIME;
  DECLARE @FechaFin DATETIME;
  
BEGIN
    
    SET @FechaIni = CONVERT(VARCHAR,DATEADD(DAY, 1, EOMONTH(@DI_FECHA, -1)),103);
    SET @FechaFin = @DI_FECHA; --CONVERT(VARCHAR, CONVERT(DATETIME, @DI_FECHA), 103);
      
    
    TRUNCATE TABLE ITF_TJD_CONS_EXT
    
	--Dato de Movimientos
	SELECT tp.FECHAMENSAJE AS FechaOperacion,
	  tp.ELEMENT4 AS MontoOperacionPesos,
	  (CASE WHEN convert(NUMERIC(12),tp.ELEMENT4) < 0 THEN ''-'' ELSE ''+'' END) AS SignoMontoOperacionPesos,
	  SubString(element43,1,22) AS NombreComercio,
	  substring(element43,39,2) AS IdentificacionPais,
	  ''08'' AS CodigoRubro,
	  td.ID_TARJETA,
	  td.NRO_CLIENTE
	  INTO #TMP_TOPAZCONTROL
	--select tp.*
	FROM TP_TOPAZPOSCONTROL tp
	  INNER JOIN TJD_TARJETAS td ON td.ID_TARJETA = SUBSTRING(tp.ELEMENT35,1, CHARINDEX(''='',tp.ELEMENT35)-1)
	WHERE tp.TZ_LOCK=0 
	AND tp.element3 IN  (''711000'', ''711500'', ''712000'')
	AND tp.element105!=''0''
	AND tp.element49 = 840
	AND tp.TOPAZPROCESSDATE BETWEEN @FechaIni AND @FechaFin
	
	IF (SELECT count(1) FROM #TMP_TOPAZCONTROL WHERE 1 = 1) > 0
	BEGIN
	
	--Tipo 01
	INSERT INTO ITF_TJD_CONS_EXT
	SELECT ''01'' AS TipoRegistro,
	 RIGHT(CONCAT(REPLICATE(''0'',11),pa.NOMBRE2),11) + --AS CUITInformante,
	 RIGHT(CONCAT(REPLICATE(''0'',11), SUBSTRING(CONVERT(VARCHAR, CONVERT(DATETIME, pa.FECHAPROCESO),112),1,6)),6) + --AS PeriodoInformado,
	 RIGHT(CONCAT(REPLICATE(''0'',2),(SELECT NUMERICO_1 FROM ITF_MASTER_PARAMETROS WHERE CODIGO = 517)),2) + --AS Secuencia,
	 ''0103'' + --AS CodigoImpuesto,
	 ''097'' + --AS CodigoConcepto,
	 ''8103'' + --AS NumeroFormulario,
	 REPLICATE('' '',212) + --AS CampoRelleno,
	 ''00200'' + --AS Version,
	 (CASE WHEN EXISTS(SELECT TOP 1 1 FROM #TMP_TOPAZCONTROL)  THEN ''1'' ELSE ''0'' END) AS DATO, --AS PresentacionSinMovimiento,
	 0 AS IdTarjeta,
	 0 AS CodCliente
	FROM PARAMETROS pa
	
	--Tipo 02
	INSERT INTO ITF_TJD_CONS_EXT
	SELECT ''02'' AS TipoRegistro,
	  LEFT(CONCAT(vsa.CTA_CBU,REPLICATE('' '',22)),22) + -- AS CBU,
	  RIGHT(CONCAT(REPLICATE(''0'',11),cp.NUMERODOCUMENTO),11) + -- AS NumeroDocumento,
	  (CASE WHEN cp.TIPOPERSONA = ''F'' AND cp.TITULARIDAD = ''T'' THEN ''01''
	  		WHEN cp.TIPOPERSONA = ''F'' AND cp.TITULARIDAD = ''C'' THEN ''02''
	  		WHEN cp.TIPOPERSONA = ''J'' AND cp.CODIGOCARGOPJ = ''APO'' THEN ''03''
	  		WHEN cp.TIPOPERSONA = ''J'' AND cp.CODIGOCARGOPJ = ''REP'' THEN ''04''
	  		WHEN cp.TIPOPERSONA = ''J'' AND cp.CODIGOCARGOPJ = ''SDE'' THEN ''06''
	  		WHEN cp.TIPOPERSONA = ''J'' AND cp.CODIGOCARGOPJ = ''FCO'' THEN ''07''
	    END) AS DATO, --AS CaracterIntegrante,
	   pos.ID_TARJETA,
	   pos.NRO_CLIENTE
	FROM #TMP_TOPAZCONTROL pos 
	  INNER JOIN TJD_REL_TARJETA_CUENTA tdr ON tdr.ID_TARJETA = pos.ID_TARJETA AND tdr.TZ_LOCK = 0
	  INNER JOIN SALDOS sa ON sa.JTS_OID = tdr.SALDO_JTS_OID AND sa.TZ_LOCK = 0
	  INNER JOIN VTA_SALDOS vsa ON vsa.JTS_OID_SALDO = sa.JTS_OID AND vsa.TZ_LOCK = 0
	  INNER JOIN VW_CLIENTE_PERSONAS cp ON cp.CODIGOCLIENTE = sa.C1803 AND cp.TITULARIDAD <> ''T''
	  
	
	--Tipo 03
 	INSERT INTO ITF_TJD_CONS_EXT
	SELECT ''03'' AS TipoRegistro,
	  RIGHT(CONCAT(REPLICATE(''0'',11),cp.NUMERODOCUMENTO),11) + -- AS NumeroDocumento,
	  RIGHT(CONCAT(REPLICATE(''0'',8),pos.FechaOperacion),8) + --
	  RIGHT(CONCAT(REPLICATE(''0'',3),pos.IdentificacionPais),3) + --
	  pos.SignoMontoOperacionPesos + --AS SignoOperacion,
	  RIGHT(CONCAT(REPLICATE(''0'',12),pos.MontoOperacionPesos),12) + -- AS MontoOperacion,
	  LEFT(CONCAT(pos.NombreComercio, REPLICATE('' '',25)),25) + --NombreComercio
	  RIGHT(CONCAT(REPLICATE(''0'',2),pos.CodigoRubro),2) AS DATO, -- AS CodigoRubro,
	  pos.ID_TARJETA,
	   pos.NRO_CLIENTE
	FROM #TMP_TOPAZCONTROL pos 
	  INNER JOIN VW_CLIENTE_PERSONAS cp ON cp.CODIGOCLIENTE = pos.NRO_CLIENTE AND cp.TITULARIDAD = ''T''

	END;
END
')