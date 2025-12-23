EXECUTE('
CREATE OR ALTER PROCEDURE dbo.[SP_GIRELEC_ORDEN_REGISTROS] 
--Created: Juan Pedrozo: 28/03/23

--cod_error = 1 es porque no hay suficientes registros para armar el documento

--en ITF_GIRELEC_ORDEN_REG_AUX, el campo TIPO es 1:CANAL - 2:CAJA - 3:PIE


@convenio NUMERIC(5), 
@fecha_rendicion VARCHAR(8),
@cod_error VARCHAR(1) OUT

AS

DECLARE @codigoEmpresa VARCHAR(10) = (SELECT CodigoEmpresa FROM RelConvPadreNomArchivo WHERE tz_lock = 0 AND convenioPadre = @convenio);

	TRUNCATE TABLE ITF_GIRELEC_AUX;	
	
--cab	
	--CANAL
	INSERT INTO ITF_GIRELEC_AUX (ID_CABEZAL, CAMPO, TIPO) 		
		SELECT
			CAB.ID AS idCabezal, 
			Concat(''C'',
			RIGHT(CONCAT(REPLICATE(''0'',4),SUCFIC.SUCURSAL),4),
			convert(VARCHAR,CAB.FECHACARGA,12),
			RIGHT(CONCAT(REPLICATE(''0'',10),CAB.TOTALREGISTROS),10), --preguntar si es la cantidad de detalles que corresponden a este cab
			RIGHT(CONCAT(REPLICATE(''0'',12),CAST(Round(CAB.TOTALIMPORTE*100,0) AS NUMERIC(12))),12),
			REPLICATE('' '',107)) as Registro, 1
		FROM CONV_CONVENIOS_REC CONV 
            JOIN REC_RENDICION REN ON CONV.Id_ConvRec = ren.CONVENIO 
	   		JOIN REC_LIQUIDACION LIQ ON liq.ID_RENDICION = ren.ID_RENDICION 
            JOIN REC_CAB_RECAUDOS_CANAL CAB ON cab.ID_LIQUIDACION = liq.ID_LIQUIDACION 
            JOIN SUC_FICTICIA_CONV_CANALES SUCFIC ON SUCFIC.CANAL = CONV.Canal		

		WHERE 
			LIQ.ESTADO = ''R'' 
            AND (CONV.Id_ConvRec = @convenio OR CONV.Id_ConvPadre = @convenio) 
            AND REN.FECHA = CAST(@fecha_rendicion AS DATE) 
            
            AND	REN.TZ_LOCK = 0 
            AND LIQ.TZ_LOCK = 0 
            AND	CONV.TZ_LOCK = 0 
            AND	CAB.TZ_LOCK = 0 
            AND CONV.FORMATO_RENDICION = 			
                (
                SELECT opcioninterna 
                FROM OPCIONES 
                WHERE 
                NUMERODECAMPO = 45146 AND 
                IDIOMA = ''E'' AND 
                upper(DESCRIPCION) LIKE ''%GIRELEC%''
                )
		GROUP BY SUCFIC.SUCURSAL,CAB.FECHACARGA, CAB.ID, CAB.TOTALREGISTROS, CAB.TOTALIMPORTE	
		
	  
	--CAJA	
	INSERT INTO ITF_GIRELEC_AUX (ID_CABEZAL, CAMPO, TIPO) 	
		SELECT 
			CAB.ID AS idCabezal, 
			Concat(''C'',
				RIGHT(CONCAT(REPLICATE(''0'',4),DET.SUCURSAL_COBRANZA),4),
				convert(VARCHAR,CAB.FECHACARGA,12),
				RIGHT(CONCAT(REPLICATE(''0'',10),CAB.TOTALREGISTROS),10),
				RIGHT(CONCAT(REPLICATE(''0'',10),CAST(Round(CAB.TOTALIMPORTE*100,0) AS NUMERIC(12))),12),
				REPLICATE('' '',107)) as Registro, 2
		FROM CONV_CONVENIOS_REC CONV 
            JOIN REC_RENDICION REN ON CONV.Id_ConvRec = ren.CONVENIO
		 	JOIN REC_LIQUIDACION LIQ ON liq.ID_RENDICION = ren.ID_RENDICION 
            JOIN REC_CAB_RECAUDOS_CAJA CAB ON CAB.ID_LIQUIDACION = LIQ.ID_LIQUIDACION 
            JOIN REC_DET_RECAUDOS_CAJA DET ON CAB.ID = DET.ID_CABEZAL
		WHERE 
			LIQ.ESTADO = ''R'' 
            AND (CONV.Id_ConvRec = @convenio OR CONV.Id_ConvPadre = @convenio) 
            AND REN.FECHA = CAST(@fecha_rendicion AS DATE) 
			
			AND	REN.TZ_LOCK = 0 
            AND LIQ.TZ_LOCK = 0 
            AND	CONV.TZ_LOCK = 0 
            AND	CAB.TZ_LOCK = 0 
            AND CONV.FORMATO_RENDICION = 			
                (
                SELECT opcioninterna 
                FROM OPCIONES 
                WHERE 
                NUMERODECAMPO = 45146 AND 
                IDIOMA = ''E'' AND 
                upper(DESCRIPCION) LIKE ''%GIRELEC%''
                )
		GROUP BY DET.SUCURSAL_COBRANZA,CAB.FECHACARGA, CAB.ID, CAB.TOTALREGISTROS, CAB.TOTALIMPORTE
	
	
--det	
	--CANAL
	INSERT INTO ITF_GIRELEC_AUX (ID_CABEZAL, CAMPO, TIPO) 
		SELECT 
			CAB.ID AS idCabezal, 
			Concat(''T'',
				LEFT(CONCAT(isnull(DET.CODIGO_BARRAS,'' ''),REPLICATE(''0'',100)),100),
				CASE WHEN DET.CODIGO_BARRAS IS NOT NULL THEN ''0'' ELSE ''5'' END,
				RIGHT(CONCAT(REPLICATE(''0'',12),CAST(Round(DET.IMPORTE*100,0) AS NUMERIC(12))),12),
				REPLICATE('' '',26)) as Registro, 1
		FROM CONV_CONVENIOS_REC CONV 
            JOIN REC_RENDICION REN ON CONV.Id_ConvRec = REN.CONVENIO 
		 	JOIN REC_LIQUIDACION LIQ ON liq.ID_RENDICION = ren.ID_RENDICION 
            JOIN REC_CAB_RECAUDOS_CANAL CAB ON  CAB.ID_LIQUIDACION = LIQ.ID_LIQUIDACION 
            JOIN REC_DET_RECAUDOS_CANAL DET ON CAB.ID = DET.ID_CABEZAL
		WHERE 
			LIQ.ESTADO = ''R'' 
            AND (CONV.Id_ConvRec = @convenio OR CONV.Id_ConvPadre = @convenio) 
            AND REN.FECHA = CAST(@fecha_rendicion AS DATE) 
            
            AND	REN.TZ_LOCK = 0 
            AND LIQ.TZ_LOCK = 0
            AND	CONV.TZ_LOCK = 0 
            AND	CAB.TZ_LOCK = 0 
            AND	DET.TZ_LOCK = 0
            AND CONV.FORMATO_RENDICION = 			
                (
                SELECT opcioninterna 
                FROM OPCIONES 
                WHERE 
                NUMERODECAMPO = 45146 AND 
                IDIOMA = ''E'' AND 
                upper(DESCRIPCION) LIKE ''%GIRELEC%''
                )
		GROUP BY DET.CODIGO_BARRAS,REN.SUCURSAL_RENDICION, cab.ID,DET.IMPORTE
		
	--CAJA
	INSERT INTO ITF_GIRELEC_AUX (ID_CABEZAL, CAMPO, TIPO)
		SELECT 
			CAB.ID AS idCabezal, 
			Concat(''T'',
				LEFT(CONCAT(isnull(DET.CODIGO_BARRAS,'' ''),REPLICATE(''0'',100)),100),
				CASE WHEN DET.CODIGO_BARRAS IS NOT NULL THEN ''0'' ELSE ''5'' END,
				RIGHT(CONCAT(REPLICATE(''0'',12),CAST(Round(DET.IMPORTE*100,0) AS NUMERIC(12))),12),
				REPLICATE('' '',26)) as Registro, 2
		FROM CONV_CONVENIOS_REC CONV 
            JOIN REC_RENDICION REN ON CONV.Id_ConvRec = REN.CONVENIO 
            JOIN REC_LIQUIDACION LIQ ON liq.ID_RENDICION = ren.ID_RENDICION 
            JOIN REC_CAB_RECAUDOS_CAJA CAB ON CAB.ID_LIQUIDACION = LIQ.ID_LIQUIDACION 
            JOIN REC_DET_RECAUDOS_CAJA DET ON CAB.ID = DET.ID_CABEZAL
		WHERE 
			LIQ.ESTADO = ''R'' 
            AND (CONV.Id_ConvRec = @convenio OR CONV.Id_ConvPadre = @convenio) 
            AND REN.FECHA = CAST(@fecha_rendicion AS DATE) 
            
            AND	REN.TZ_LOCK = 0 
            AND LIQ.TZ_LOCK = 0
            AND	CONV.TZ_LOCK = 0 
            AND	CAB.TZ_LOCK = 0 
            AND	DET.TZ_LOCK = 0
            AND CONV.FORMATO_RENDICION = 			
                (
                SELECT opcioninterna 
                FROM OPCIONES 
                WHERE 
                NUMERODECAMPO = 45146 AND 
                IDIOMA = ''E'' AND 
                upper(DESCRIPCION) LIKE ''%GIRELEC%''
                )		
		GROUP BY DET.CODIGO_BARRAS,REN.SUCURSAL_RENDICION, CAB.ID,DET.IMPORTE
	
	
--pie
	INSERT INTO ITF_GIRELEC_AUX (ID_CABEZAL, CAMPO, TIPO) 
		SELECT 
			(SELECT max(ID_CABEZAL)+1 FROM ITF_GIRELEC_AUX) AS idCabezal,
			Concat(''P'',
				RIGHT(CONCAT(''00000'',@codigoEmpresa),5),
				RIGHT(CONCAT(''00000'',(SELECT numerico FROM PARAMETROSGENERALES WHERE CODIGO = 2)),5),
				RIGHT(CONCAT(REPLICATE(''0'',20),totalTalones),20),		
				RIGHT(CONCAT(REPLICATE(''0'',22),totalImporteTalones),22),
				REPLICATE('' '',87)) AS REGISTRO, 3 
			FROM 
			(
				SELECT 
					count(*) as totalTalones, 
					sum(CAST(substring(CAMPO, 105,12) AS NUMERIC)) as totalImporteTalones
				FROM ITF_GIRELEC_AUX WHERE CAMPO LIKE ''T%''
			) AS datos;
	
	

	--set cod error
	 SET @cod_error = (SELECT CASE WHEN COUNT(*) >= 3 THEN 0 ELSE 1 END FROM ITF_GIRELEC_AUX);	 
	 IF (@cod_error = 0)
	 BEGIN
	 	DECLARE @cantCabezales NUMERIC(20) = (SELECT COUNT(*) FROM ITF_GIRELEC_AUX WHERE CAMPO LIKE ''C%'');
	   	DECLARE @cantTalones NUMERIC(20) = (SELECT COUNT(*) FROM ITF_GIRELEC_AUX WHERE CAMPO LIKE ''T%'');
	    DECLARE @cantPie NUMERIC(20) = (SELECT COUNT(*) FROM ITF_GIRELEC_AUX WHERE CAMPO LIKE ''P%'');
	    
		IF(
			@cantCabezales  = 0 OR 
			@cantCabezales > @cantTalones OR
			@cantTalones = 0 OR 
			@cantPie <> 1
		) SET @cod_error = 1;
		
	 END
')