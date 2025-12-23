Execute('
CREATE OR ALTER PROCEDURE SP_REN_RENAPER
	@convenio NUMERIC(15),
	@fecha VARCHAR(8),
	@msg_ret VARCHAR (50) OUT

-- DESA: conv:33 fecha:''20300122''

AS
BEGIN
		
	DECLARE @existeConv INT, @fechaOk INT;
	
	
	SET	@msg_ret= ''OK'' ;
	
	--limpio tabla aux
	TRUNCATE TABLE ITF_REN_RENAPER_AUX;
	
	SET @existeConv = (SELECT CASE WHEN COUNT(*) > 0 THEN 1 ELSE 0 END FROM CONV_CONVENIOS_REC (nolock) WHERE id_convrec = @convenio);
	SET @fechaOk = (SELECT CASE WHEN isdate(@fecha) = 1 AND CAST(@fecha AS DATE) <= (SELECT fechaproceso FROM PARAMETROS (nolock)) THEN 1 ELSE 0 END);
	
	
	
	IF(@fechaOk*@existeConv = 1)
	BEGIN
		
		--cabezal
		INSERT INTO ITF_REN_RENAPER_AUX 
		SELECT
		concat(
			replace(convert(VARCHAR(10),ren.fecha,105),''-'',''''),
			''CHACO       '',
			RIGHT(concat(replicate(''0'',6),sum(ren.TOTALREGISTROS)), 6),
			RIGHT(concat(replicate(''0'',10),replace(sum(ren.TOTALIMPORTE), ''.'','''')),10),
			replicate(''0'',77)
		) AS cabezal
		
		FROM REC_CAB_RECAUDOS_CAJA cab JOIN
			REC_LIQUIDACION liq ON liq.ID_LIQUIDACION = cab.ID_LIQUIDACION JOIN 
			REC_RENDICION ren ON ren.ID_RENDICION = liq.ID_RENDICION 
				
				WHERE (ren.CONVENIO = @convenio OR ren.convenio_padre = @convenio ) AND ren.FECHA = CAST(@fecha AS DATE)
					GROUP BY ren.fecha;
			 	
				 
		--detalle
		INSERT INTO ITF_REN_RENAPER_AUX 
		SELECT
		concat(
			''CHAC    '',
			RIGHT(concat(replicate(''0'',10),det.SUCURSAL_COBRANZA),10),
			RIGHT(concat(replicate(''0'',8),det.NRO_CAJA),8),  
			RIGHT(concat(replicate(''0'',10),det.ID_LINEA),10),
			RIGHT(concat(replicate(''0'',9),replace(det.IMPORTE,''.'','''')),9),
			LEFT(concat(det.CODIGO_BARRAS, replicate('' '',60)),60),
			CONVERT(VARCHAR(8), det.FECHA_COBRANZA, 112)
		) AS detalle
		FROM 
			REC_DET_RECAUDOS_CAJA det JOIN 
			REC_CAB_RECAUDOS_CAJA cab ON det.ID_CABEZAL = cab.ID JOIN
			REC_LIQUIDACION liq ON liq.ID_LIQUIDACION = cab.ID_LIQUIDACION JOIN 
			REC_RENDICION ren ON ren.ID_RENDICION = liq.ID_RENDICION 
				WHERE (ren.CONVENIO = @convenio OR ren.convenio_padre = @convenio ) AND ren.FECHA = CAST(@fecha AS DATE);
	END
	ELSE 	
		SELECT @msg_ret = CASE WHEN @fechaOk = 0 THEN ''ERROR: fecha ingresada no valida. '' ELSE ''ERROR: no existe convenio. '' END;
		
	
END
')