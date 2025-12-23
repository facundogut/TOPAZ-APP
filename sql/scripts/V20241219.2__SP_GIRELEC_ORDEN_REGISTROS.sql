ALTER   PROCEDURE dbo.[SP_GIRELEC_ORDEN_REGISTROS] 
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
	BEGIN 
		INSERT INTO ITF_GIRELEC_AUX (ID_CABEZAL, CAMPO, TIPO, SUCURSAL) 		
		SELECT
			CAB.ID AS idCabezal, 
			Concat('C',
			RIGHT(CONCAT(REPLICATE('0',4),SUCFIC.SUCURSAL),4),
			convert(VARCHAR,CAB.FECHACARGA,12),
			RIGHT(CONCAT(REPLICATE('0',10),CAB.TOTALREGISTROS),10), 
			RIGHT(CONCAT(REPLICATE('0',12),CAST(Round(CAB.TOTALIMPORTE*100,0) AS NUMERIC(12))),12),
			REPLICATE(' ',107)) as Registro
			, 1
			, SUCFIC.SUCURSAL
		FROM CONV_CONVENIOS_REC (nolock) CONV 
            JOIN REC_RENDICION (nolock) REN ON CONV.Id_ConvRec = ren.CONVENIO 
	   		JOIN REC_LIQUIDACION (nolock) LIQ ON liq.ID_RENDICION = ren.ID_RENDICION 
            JOIN REC_CAB_RECAUDOS_CANAL (nolock) CAB ON cab.ID_LIQUIDACION = liq.ID_LIQUIDACION 
            JOIN SUC_FICTICIA_CONV_CANALES (nolock) SUCFIC ON SUCFIC.CANAL = CONV.Canal		

		WHERE 
			LIQ.ESTADO = 'R' 
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
                IDIOMA = 'E' AND 
                upper(DESCRIPCION) LIKE '%GIRELEC%'
                )
		GROUP BY SUCFIC.SUCURSAL,CAB.FECHACARGA, CAB.ID, CAB.TOTALREGISTROS, CAB.TOTALIMPORTE	
	END 
			  
	--CAJA 
	BEGIN 	
		INSERT INTO ITF_GIRELEC_AUX (ID_CABEZAL, CAMPO, TIPO, SUCURSAL) 	
		SELECT 
			CAB.ID AS idCabezal, 
			Concat('C',
				RIGHT(CONCAT(REPLICATE('0',4),DET.SUCURSAL_COBRANZA),4),
				convert(VARCHAR,CAB.FECHACARGA,12),
				RIGHT(CONCAT(REPLICATE('0',10),CAB.TOTALREGISTROS),10),
				RIGHT(CONCAT(REPLICATE('0',10),CAST(Round(CAB.TOTALIMPORTE*100,0) AS NUMERIC(12))),12),
				REPLICATE(' ',107)) as Registro
				, 2
				, DET.SUCURSAL_COBRANZA
		FROM CONV_CONVENIOS_REC (nolock) CONV 
            JOIN REC_RENDICION (nolock) REN ON CONV.Id_ConvRec = ren.CONVENIO
		 	JOIN REC_LIQUIDACION (nolock) LIQ ON liq.ID_RENDICION = ren.ID_RENDICION 
            JOIN REC_CAB_RECAUDOS_CAJA (nolock) CAB ON CAB.ID_LIQUIDACION = LIQ.ID_LIQUIDACION 
            JOIN REC_DET_RECAUDOS_CAJA (nolock) DET ON CAB.ID = DET.ID_CABEZAL
		WHERE 
			LIQ.ESTADO = 'R' 
            AND (CONV.Id_ConvRec = @convenio OR CONV.Id_ConvPadre = @convenio) 
            AND REN.FECHA = CAST(@fecha_rendicion AS DATE) 
			
			AND	REN.TZ_LOCK = 0 
            AND LIQ.TZ_LOCK = 0 
            AND	CONV.TZ_LOCK = 0 
            AND	CAB.TZ_LOCK = 0 
            AND CONV.FORMATO_RENDICION = 			
                (
                SELECT opcioninterna 
                FROM OPCIONES (nolock)
                WHERE 
                NUMERODECAMPO = 45146 AND 
                IDIOMA = 'E' AND 
                upper(DESCRIPCION) LIKE '%GIRELEC%'
                )
		GROUP BY DET.SUCURSAL_COBRANZA,CAB.FECHACARGA, CAB.ID, CAB.TOTALREGISTROS, CAB.TOTALIMPORTE
	END 

--det	
	--CANAL
	BEGIN 
		INSERT INTO ITF_GIRELEC_AUX  (ID_CABEZAL, CAMPO, TIPO, SUCURSAL) 
		SELECT 
			CAB.ID AS idCabezal, 
			Concat('T',
				LEFT(CONCAT(isnull(
				CASE 
					WHEN LEFT(DET.codigo_barras, 3) = '316' AND CAST(DET.IMPORTE*100 AS INT) <> CAST(substring(DET.codigo_barras, 16,12) AS INT)
						THEN 
							dbo.getCodBarraVerificado(
							concat(
								LEFT(DET.codigo_barras, 15),
								RIGHT(concat(replicate('0',12),CAST(cast(DET.IMPORTE*100 AS INT) AS VARCHAR(12))),12),
								REPLACE(CONVERT(VARCHAR(10), DET.FECHA_COBRANZA, 105), '-','')))
					WHEN len(DET.codigo_barras_rendido) = 0 OR RIGHT(trim(DET.CODIGO_BARRAS_RENDIDO), 10) = '0000000000'   --CAST(DET.IMPORTE*100 AS INT) <> CAST(substring(DET.codigo_barras_rendido, 2,12) AS INT)
						THEN DET.codigo_barras						
					ELSE DET.codigo_barras_rendido
				END 			
				,' '),REPLICATE(' ',100)),100),
				CASE WHEN DET.CODIGO_BARRAS IS NOT NULL OR len(DET.CODIGO_BARRAS) = 0 THEN '0' ELSE '5' END,
				RIGHT(CONCAT(REPLICATE('0',12),CAST(Round(DET.IMPORTE*100,0) AS NUMERIC(12))),12),
				REPLICATE(' ',26)) as Registro
				, 1
				, SUCFIC.SUCURSAL
		FROM CONV_CONVENIOS_REC (nolock) CONV 
            JOIN REC_RENDICION (nolock) REN ON CONV.Id_ConvRec = REN.CONVENIO 
		 	JOIN REC_LIQUIDACION (nolock) LIQ ON liq.ID_RENDICION = ren.ID_RENDICION 
            JOIN REC_CAB_RECAUDOS_CANAL (nolock) CAB ON  CAB.ID_LIQUIDACION = LIQ.ID_LIQUIDACION 
            JOIN REC_DET_RECAUDOS_CANAL (nolock) DET ON CAB.ID = DET.ID_CABEZAL
            JOIN SUC_FICTICIA_CONV_CANALES (nolock) SUCFIC ON SUCFIC.CANAL = CONV.Canal
		WHERE 
			LIQ.ESTADO = 'R' 
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
                FROM OPCIONES (nolock) 
                WHERE 
                NUMERODECAMPO = 45146 AND 
                IDIOMA = 'E' AND 
                upper(DESCRIPCION) LIKE '%GIRELEC%'
                )
		GROUP BY DET.CODIGO_BARRAS,REN.SUCURSAL_RENDICION, cab.ID,DET.IMPORTE, DET.FECHA_COBRANZA,DET.codigo_barras_rendido,SUCFIC.SUCURSAL
	END 
	--CAJA
	BEGIN 
		INSERT INTO ITF_GIRELEC_AUX (ID_CABEZAL, CAMPO, TIPO, SUCURSAL)
		SELECT 
			CAB.ID AS idCabezal, 
			Concat('T',
				LEFT(CONCAT(
				CASE WHEN len(DET.CODIGO_BARRAS_RENDIDO) = 0 OR RIGHT(trim(DET.CODIGO_BARRAS_RENDIDO), 10) = '0000000000' THEN DET.CODIGO_BARRAS ELSE DET.CODIGO_BARRAS_RENDIDO END, REPLICATE(' ',100)),100),
				CASE WHEN DET.CODIGO_BARRAS IS NOT NULL OR len(DET.CODIGO_BARRAS) = 0 THEN '0' ELSE '5' END,
				RIGHT(CONCAT(REPLICATE('0',12),CAST(Round(DET.IMPORTE*100,0) AS NUMERIC(12))),12),
				REPLICATE(' ',26)) as Registro
				, 2
				, DET.SUCURSAL_COBRANZA
		FROM CONV_CONVENIOS_REC (nolock) CONV 
            JOIN REC_RENDICION (nolock) REN ON CONV.Id_ConvRec = REN.CONVENIO 
            JOIN REC_LIQUIDACION (nolock) LIQ ON liq.ID_RENDICION = ren.ID_RENDICION 
            JOIN REC_CAB_RECAUDOS_CAJA (nolock) CAB ON CAB.ID_LIQUIDACION = LIQ.ID_LIQUIDACION 
            JOIN REC_DET_RECAUDOS_CAJA (nolock) DET ON CAB.ID = DET.ID_CABEZAL
		WHERE 
			LIQ.ESTADO = 'R' 
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
                FROM OPCIONES (nolock)
                WHERE 
                NUMERODECAMPO = 45146 AND 
                IDIOMA = 'E' AND 
                upper(DESCRIPCION) LIKE '%GIRELEC%'
                )		
		GROUP BY DET.CODIGO_BARRAS,REN.SUCURSAL_RENDICION, CAB.ID,DET.IMPORTE, DET.CODIGO_BARRAS_RENDIDO,DET.SUCURSAL_COBRANZA
	END 
	
--pie
	BEGIN 
		INSERT INTO ITF_GIRELEC_AUX (ID_CABEZAL, CAMPO, TIPO, SUCURSAL) 
		SELECT 
			(SELECT max(ID_CABEZAL)+1 FROM ITF_GIRELEC_AUX) AS idCabezal,
			Concat('P',
				RIGHT(CONCAT('00000',@codigoEmpresa),5),
				RIGHT(CONCAT('00000',(SELECT numerico FROM PARAMETROSGENERALES WHERE CODIGO = 2)),5),
				RIGHT(CONCAT(REPLICATE('0',20),totalTalones),20),		
				RIGHT(CONCAT(REPLICATE('0',22),totalImporteTalones),22),
				REPLICATE(' ',87)) AS REGISTRO
				, 3 
				,9999
			FROM 
			(
				SELECT 
					count(*) as totalTalones, 
					sum(CAST(substring(CAMPO, 105,12) AS NUMERIC)) as totalImporteTalones
				FROM ITF_GIRELEC_AUX WHERE CAMPO LIKE 'T%'
			) AS datos;
	END 
	

	--set cod error
	 SET @cod_error = (SELECT CASE WHEN COUNT(*) >= 3 THEN 0 ELSE 1 END FROM ITF_GIRELEC_AUX);	 
	 IF (@cod_error = 0)
	 BEGIN
	 	DECLARE @cantCabezales NUMERIC(20) = (SELECT COUNT(*) FROM ITF_GIRELEC_AUX WHERE CAMPO LIKE 'C%');
	   	DECLARE @cantTalones NUMERIC(20) = (SELECT COUNT(*) FROM ITF_GIRELEC_AUX WHERE CAMPO LIKE 'T%');
	    DECLARE @cantPie NUMERIC(20) = (SELECT COUNT(*) FROM ITF_GIRELEC_AUX WHERE CAMPO LIKE 'P%');
	    
		IF(
			@cantCabezales  = 0 OR 
			@cantCabezales > @cantTalones OR
			@cantTalones = 0 OR 
			@cantPie <> 1
		) SET @cod_error = 1;
		
	 END
GO

