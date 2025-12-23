EXECUTE
('
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
	    a.HORAFIN fechaHoraReloj,
	    h.DEBITO_CREDITO operacion, 
	    h.MONTO monto, 
	    case when h.DEBITO_CREDITO = ''D'' then -h.monto else h.monto end importe,
	    COALESCE(SALDO_AJUSTADO, 0)  + 
	    SUM(case when h.DEBITO_CREDITO = ''D'' then -h.monto else h.monto end ) OVER (PARTITION BY h.FECHA_VALOR ORDER BY h.FECHA_VALOR, h.MOV_JTS_OID) AS saldoParcial,
	    CASE WHEN h.CODIGO_TRANSACCION = 0 then h.CONCEPTO ELSE codTtr.DESCRIPCION END concepto,
	    a.OPERACION nroOperacion, 
	    h.CODIGO_TRANSACCION codTransaccion, 
	    h.ASIENTO comprobante,
	    dbo.diaHabil(h.fecha_Valor - 1, ''D'') fechaSaldo, 
	    COALESCE(SALDO_AJUSTADO, 0) saldoDiario,    
	    case when mon.C6403 = ''I'' then ctz.cotBcra else null end cotizacion,
	    hm.infoExtendida detalle
	
	    from HISTORIA_VISTA h WITH (NOLOCK)
	    inner join ASIENTOS A WITH (NOLOCK) on H.ASIENTO = A.ASIENTO and H.SUCURSAL = A.SUCURSAL and H.FECHA_PROCESADO = A.FECHAPROCESO 
	    left join HISTORICO_MOVIMIENTOS hm WITH (NOLOCK) on h.MOV_JTS_OID = hm.movJtsOid  
	    inner join saldos s WITH (NOLOCK) on s.JTS_OID = h.SALDO_JTS_OID 
	    left join TTR_CODIGO_TRANSACCION_DEF codTtr WITH (NOLOCK) ON h.CODIGO_TRANSACCION = codTtr.CODIGO_TRANSACCION
	    left JOIN STRING_SPLIT(@P_ttr, '','') AS ttr ON ttr.value = h.CODIGO_TRANSACCION
	    left join GRL_SALDOS_DIARIOS sal WITH (NOLOCK) on sal.fecha = dbo.diaHabil(h.fecha_Valor - 1, ''D'') and h.SALDO_JTS_OID = sal.SALDOS_JTS_OID
	    left join VW_NBCH24_GRL_COTIZACIONES ctz WITH (NOLOCK) on h.FECHA_VALOR = ctz.fecha and ctz.codigo = s.moneda --fecha de cotizacion para UVA
	    left join monedas mon on ctz.codigo = mon.C6399
	    where a.ESTADO = 77 and h.MONTO > 0 
	
	    and 
	    ((h.SALDO_JTS_OID = @P_jtsoid and cast(h.FECHA_PROCESADO as Date) BETWEEN @P_fechaDesde and @P_fechaHasta and @P_filter = ''*PROC'') 
	    or 
	    (h.SALDO_JTS_OID = @P_jtsoid and cast(a.HORAFIN as Date)  BETWEEN @P_fechaDesde and @P_fechaHasta and @P_filter = ''*TIME'') )
	
	    and  (@P_ttr IS NULL OR ttr.value IS NOT NULL) --si @p_ttr es null incluye todos los codigos de transaccion 
	    and (@P_fv <> ''S'' OR h.FECHA_VALOR < h.FECHA_PROCESADO)
	    order by h.FECHA_VALOR desc, a.HORAFIN desc
	    OFFSET (@P_pagina - 1) * @P_cantidad ROWS
	    FETCH NEXT @P_cantidad ROWS ONLY
	END
');

EXECUTE
('
	CREATE OR ALTER VIEW dbo.VW_NBCH24_GRL_COTIZACIONES(codigo, cotBCRA, cotCompra, cotVenta, fecha)
	AS
		SELECT 
		m.C6399, 
		m.c6440, 
		CASE WHEN m.C6399 = 2 THEN (m.TCCOMPRACOMUN + coalesce(ms.SPVENTACAJA, 0)) ELSE m.TCCOMPRACOMUN END,
		CASE WHEN m.C6399 = 2 THEN (m.TCVENTACOMUN + coalesce(ms.SPVENTACAJA, 0)) ELSE m.TCVENTACOMUN END,
		p.FECHAPROCESO
		FROM MONEDAS m WITH (NOLOCK), PARAMETROS p WITH (NOLOCK)
		LEFT JOIN MONEDAS_SUCURSAL ms WITH (NOLOCK) ON ms.MONEDA = 2 AND ms.SUCURSAL = 50
		
		union 
		
		SELECT moneda, tipo_cambio_oficial, TIPO_CAMBIO_COMPRA, TIPO_CAMBIO_VENTA, FECHA_COTIZACION FROM HISTORICOTIPOSCAMBIO htc WITH (NOLOCK)
');

EXECUTE
('
	CREATE OR ALTER VIEW dbo.VW_NBCH24_ECHEQ_CTA(jts_oid, sucursal, cuenta, producto, chequesDisponibles, limiteEmision, emiteEcheq, depositaEcheq)
	AS
	
	with libretas as (
	select ch.NROSOLICCHEQ nroSolic, 
		   ch.CHEQUEDESDE, 
		   ch.CHEQUEHASTA,
	       ch.PRODUCTO,
		   ch.sucursal, 
		   ch.cuenta, 
	       max(ch.CANTIDADCHEQUES) cantCheques, 
	       COALESCE (max(ch.LIMITE_EMISION), 0) limiteEmision, 
	       count(*) usados 
	from CHE_CHEQUERAS ch 
	inner join CHE_CHEQUES cc on ch.sucursal = cc.sucursal and ch.cuenta = cc.cuenta and   ((cc.NUMEROCHEQUE >= ch.CHEQUEDESDE) and (cc.NUMEROCHEQUE <= ch.CHEQUEHASTA))
	and ch.producto = cc.PRODUCTO and ch.moneda = cc.MONEDA
	where ch.estado = ''A'' and ch.SERIE = ''E'' and ch.tz_lock = 0 
	group by ch.NROSOLICCHEQ,  ch.CHEQUEDESDE,    ch.CHEQUEHASTA,    ch.PRODUCTO, ch.sucursal,   ch.cuenta),
	
	disponibles as (select producto, sucursal, cuenta, sum(cantCheques - usados) chequesDisponibles, max(limiteEmision)  limiteEmision from libretas 
	GROUP by producto, SUCURSAL, CUENTA)
	
	select s.jts_oid, s.sucursal, s.cuenta, s.producto, coalesce(d.chequesDisponibles, 0) chequesDisponibles, coalesce(d.limiteEmision, 999999999999999) limiteEmision,
	case when s.permite_echeq = ''S'' then ''S'' else ''N'' end emiteEcheq, 
	case when tp.ACEPTA_ECHEQ = ''S'' then ''S'' else ''N'' end depositaEcheq from saldos s 
	left join disponibles d  on d.producto = s.producto and d.sucursal = s.sucursal and d.cuenta = s.cuenta 
	left join topesproducto tp on tp.codproducto = s.producto and tp.moneda = s.moneda
');

Execute('CREATE OR ALTER PROCEDURE [dbo].[SP_COELSA_ENVIO_DPF_PROPIOS_RECHAZADOS]
   @TICKET NUMERIC(16),
   @MONEDA NUMERIC(4)
AS 
BEGIN
	
	------------ Limpieza de tabla auxiliar --------------------
	TRUNCATE TABLE dbo.ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX;
	------------------------------------------------------------
	
	--- Variables Cabecera Archivo (CA)
	DECLARE @CA_ID_REG VARCHAR(1) = ''1''; -- fijo
	DECLARE @CA_CODIGO_PRIORIDAD VARCHAR (2)= ''01''; -- fijo
	DECLARE @CA_DESTINO_INMEDIATO VARCHAR (10)= '' 000000010''; --fijo
	DECLARE @CA_ORIGEN_INMEDIATO VARCHAR(10) = (SELECT '' 031100''+CAST((SELECT NUMERICO FROM PARAMETROSGENERALES WHERE CODIGO=40) AS VARCHAR)+''0''); 
	DECLARE @CA_FECHA_PRESENTACION VARCHAR(6)= convert(VARCHAR,(SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)), 12); -- fijo
	DECLARE @CA_HORA_PRESENTACION VARCHAR(4)= concat (SUBSTRING((SELECT CONVERT (VARCHAR(8), SYSDATETIME(),24)),1,2), SUBSTRING((SELECT CONVERT (VARCHAR(8), SYSDATETIME(),24)),4,5)); -- fijo
	DECLARE @CA_IDENTIFICADOR_ARCHIVO VARCHAR(1) = ''1''; --
	DECLARE @CA_TAMANNO_REGISTRO VARCHAR(3)= ''094''; -- fijo
	DECLARE @CA_FACTOR_BLOQUE VARCHAR(2)= ''10''; -- fijo
	DECLARE @CA_CODIGO_FORMATO VARCHAR(1)= ''1''; -- fijo
	DECLARE @CA_NOMBRE_DEST_INMEDIATO VARCHAR(23)= ''COELSA                 ''; -- fijo
	DECLARE @CA_NOMBRE_ORIG_INMEDIATO VARCHAR(23)=''NUEVO BCO CHACO S.A.   ''; -- fijo
	DECLARE @CA_CODIGO_REFERENCIA VARCHAR(8) = ''CHQ.RECH''; --Se conforma con espacios vacíos.
	
	DECLARE @CA_CABECERA VARCHAR(200);
	
	SET @CA_CABECERA = concat(@CA_ID_REG
							, @CA_CODIGO_PRIORIDAD
							, @CA_DESTINO_INMEDIATO
							, @CA_ORIGEN_INMEDIATO
							, @CA_FECHA_PRESENTACION
							, @CA_HORA_PRESENTACION
							, @CA_IDENTIFICADOR_ARCHIVO
							, @CA_TAMANNO_REGISTRO
							, @CA_FACTOR_BLOQUE
							, @CA_CODIGO_FORMATO
							, @CA_NOMBRE_DEST_INMEDIATO
							, @CA_NOMBRE_ORIG_INMEDIATO
							, @CA_CODIGO_REFERENCIA);
	
	
	--- Variables cabecera lote (CL)
	DECLARE @CL_ID_REG VARCHAR(1) = ''5''; -- fijo
	DECLARE @CL_CODIGO_CLASE_TRANSAC VARCHAR(3) = ''200''; -- fijo 
	DECLARE @CL_RESERVADO VARCHAR(46) = replicate('' '', 46); -- 3 campos reservados
	DECLARE @CL_TIPO_REGISTRO VARCHAR(3) = ''TRC''; -- fijo 
	DECLARE @CL_DESCRIP_TRANSAC VARCHAR(10) = ''          ''; -- fijo
	DECLARE @CL_FECHA_PRESENTACION VARCHAR(6) = convert(VARCHAR,(SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)), 12);
	DECLARE @CL_FECHA_VENCIMIENTO VARCHAR(6) = convert(VARCHAR,(SELECT FECHAPROXIMOPROCESO FROM PARAMETROS WITH(NOLOCK)), 12); 
	DECLARE @CL_RESERVADO_CL VARCHAR(3) = ''000''; -- fijo
	DECLARE @CL_CODIGO_ORIGEN VARCHAR(1) = ''1''; -- fijo
	DECLARE @CL_ID_ENTIDAD_ORIGEN VARCHAR(8) = (SELECT ''031100''+CAST((SELECT NUMERICO FROM PARAMETROSGENERALES WHERE CODIGO=40) AS VARCHAR)); 
	DECLARE @CL_NUMERO_LOTE VARCHAR(7) = RIGHT(concat(replicate(''0'', 7), 1), 7); -- numero del lote
	
	DECLARE @CL_CABECERA VARCHAR(200);
	
	SET @CL_CABECERA = concat(@CL_ID_REG
							, @CL_CODIGO_CLASE_TRANSAC
							, @CL_RESERVADO
							, @CL_TIPO_REGISTRO
							, @CL_DESCRIP_TRANSAC
							, @CL_FECHA_PRESENTACION
							, @CL_FECHA_VENCIMIENTO
							, @CL_RESERVADO_CL
							, @CL_CODIGO_ORIGEN
							, @CL_ID_ENTIDAD_ORIGEN
							, @CL_NUMERO_LOTE);
	
	/*---- Grabamos cabecera de lote y archivo solo si hay registros individuales ingresados
	IF(0<(SELECT COUNT(*) FROM ITF_COELSA_CHEQUES_RECHAZO WHERE ESTADO = ''P'' AND TIPO = ''D'' AND SUBSTRING(INFO_ADICIONAL, 1, 1) = @MONEDA  AND FECHAPROCESO = (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK))))
		BEGIN*/
			---------------- Grabar Cabecera Archivo ---------------------------
			INSERT INTO dbo.ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX (LINEA) VALUES (@CA_CABECERA);
			--------------------------------------------------------------------
			---------------- Grabar Cabecera Lote ---------------------------
			INSERT INTO dbo.ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX (LINEA) VALUES (@CL_CABECERA);
			-----------------------------------------------------------------
		--END
	
	------ Variables registro individual ( RI) ------------
	DECLARE @RI_ID_REG VARCHAR(1) = ''6''; -- fijo  
	DECLARE @RI_ENTIDAD_DEBITAR VARCHAR(8);
	DECLARE @RI_RESERVADO VARCHAR(1) = ''0''; -- fijo 
	DECLARE @RI_CUENTA_DEBITAR VARCHAR(17); 
	DECLARE @RI_IMPORTE VARCHAR(16); 
	DECLARE @RI_NUMERO_CHEQUE VARCHAR(15);
	DECLARE @RI_CODIGO_POSTAL VARCHAR(6); 
	DECLARE @RI_PUNTO_INTERCAMBIO VARCHAR(10) = ''0000      '';
	DECLARE @RI_INFO_ADICIONAL VARCHAR(2);
	DECLARE @RI_REGISTRO_ADICIONAL VARCHAR(1); 
	DECLARE @RI_CONTADOR_REGISTRO VARCHAR(15);
								
	DECLARE @RI_REGISTRO_INDIVIDUAL VARCHAR (200);
	
	------ Variables registro ajuste ( RA) ------------
	
	DECLARE @RA_ID_REG_ADICIONAL VARCHAR(6) = ''799'';
	DECLARE @RA_CONTADOR_REGISTRO_ORIGEN VARCHAR(15);
	DECLARE @RA_NUMERO_CERTIFIFADO VARCHAR(6) = ''      '';
	DECLARE @RA_ENTIDAD_ORIGINAL VARCHAR(8) = ''        '';
	DECLARE @RA_OTRO_MOTIVO_RECH VARCHAR(44) = ''                                             '';
	DECLARE @CODIGO_RECHAZO VARCHAR(3);
	DECLARE @TRACE_NUMBER VARCHAR(15); 
	DECLARE @OTRO_RECHAZO VARCHAR(44);
	DECLARE @CheEntidadDebitarV VARCHAR(8);
	
	DECLARE @RA_REGISTRO_INDIVIDUAL VARCHAR (200);
	
	--- Variables fin de lote FL
	DECLARE @FL_ID_REG VARCHAR(1) = ''8''; -- fijo 
	DECLARE @FL_CODIGO_CLASE_TRANSAC VARCHAR(3) = ''200''; -- fijo 
	DECLARE @FL_CANT_REG_INDIVIDUAL_ADICIONAL VARCHAR(6) = 0; --registros individuales y adicionales que existen en el lote
	DECLARE @FL_TOTALES_DE_CONTROL VARCHAR(10) = 0;
	DECLARE @FL_SUMA_TOTAL_DEBITO_LOTE VARCHAR(20); 
	DECLARE @FL_SUMA_TOTAL_CREDITO_LOTE VARCHAR(20); 
	DECLARE @FL_RESERVADO1 VARCHAR(10) = ''          ''; -- fijo
	DECLARE @FL_RESERVADO2 VARCHAR(5) = ''     ''; -- fijo
	DECLARE @FL_RESERVADO3 VARCHAR(4) = ''    ''; -- fijo
	DECLARE @FL_REG_ENTIDAD_ORIGEN VARCHAR(8) = (SELECT ''0311''+ RIGHT(concat(replicate(''0'', 4), CAST((SELECT NUMERICO FROM PARAMETROSGENERALES WHERE CODIGO=40) AS VARCHAR)), 4)); 
	DECLARE @FL_NUMERO_LOTE VARCHAR(7) = ''0000001''; 
	DECLARE @FL_FIN_LOTE VARCHAR(200);
	
	--- Variables fin de Archivo FA
	DECLARE @FA_ID_REG VARCHAR(1) = ''9''; -- fijo  
	DECLARE @FA_CANT_LOTES VARCHAR(6);-- total de lotes que contiene el archivo
	DECLARE @FA_NUMERO_BLOQUES VARCHAR(6);-- ver detalles en doc pdf
	DECLARE @FA_CANT_REG_INDIVIDUAL_ADICIONAL VARCHAR(8); --total de registros individuales y adicionales que existen en el archivo
	DECLARE @FA_TOTALES_DE_CONTROL VARCHAR(10);
	DECLARE @FA_SUMA_TOTAL_DEBITOS VARCHAR(20);
	DECLARE @FA_SUMA_TOTAL_CREDITOS VARCHAR(20);
	DECLARE @FA_RESERVADO  VARCHAR(100) = replicate('' '', 23); -- fijo
	
	DECLARE @FA_FIN_ARCHIVO VARCHAR (200);
	
	
	
	------- Variables generales ------------
	DECLARE @SumaImportes NUMERIC(15,2) = 0;
	DECLARE @TotalesControl NUMERIC(10) = 0;
	DECLARE @TotalesDebitos NUMERIC(15,2) = 0;
	DECLARE @TotalesCreditos NUMERIC(15,2) = 0;
	DECLARE @CantRegistros NUMERIC(15) = 0;
	DECLARE @CantRegistrosPrev NUMERIC(6)= 0;
	DECLARE @Cant_Reg_Individual_Adicional VARCHAR(6)= 0;
	
	DECLARE @SumaEntidad NUMERIC = 0;
	DECLARE @SumaSucursal NUMERIC = 0;
	DECLARE @SobranteSucursal NUMERIC = 0;
	DECLARE @Excedente NUMERIC(15,2) = 0;
	DECLARE @CountExcedente INT = 0;
	
	------------------------------------------
	------------Variables Cursor
	DECLARE @T_ENTIDAD_DEBITAR VARCHAR(8);
	DECLARE @T_CODIGO_TRANSACCION VARCHAR(2);
	DECLARE @T_CUENTA_DEBITAR VARCHAR(17);
	DECLARE @T_IMPORTE NUMERIC(15,2);
	DECLARE @T_NRO_CHEQUE VARCHAR(15);
	DECLARE @T_CODIGO_POSTAL VARCHAR(6);
	DECLARE @T_PUNTO_INTERCAMBIO VARCHAR(16);
	DECLARE @T_TRACE_NUMBER VARCHAR(15);
	DECLARE @CheCodRechazo NUMERIC(2);
	--------------------------------
	
	    --Condicion de reset del contador de reg individual
	IF ISNULL((SELECT a.FECHA FROM ITF_MASTER_PARAMETROS a WHERE a.CODIGO = 137), CAST(''01-01-1800'' AS DATETIME)) <> (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK))
	    UPDATE dbo.ITF_MASTER_PARAMETROS SET NUMERICO_1 = 1, FECHA = (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)) WHERE CODIGO = 137;
	 
	
	
	DECLARE CursorDPF CURSOR FOR
				
	SELECT ENTIDAD_DEBITAR
			, ''26'' -- CODIGO_TRANSACCION
			, CUENTA_DEBITAR
			, IMPORTE
			, NRO_CHEQUE
			, CODIGO_POSTAL
			, isnull(RIGHT(''00''+INFO_ADICIONAL,2),''00'')
			, PUNTO_INTERCAMBIO
			, TRACE_NUMBER
			, COD_RECHAZO
	FROM ITF_COELSA_CHEQUES_RECHAZO 
	WHERE ESTADO = ''P'' 
	AND TIPO = ''D'' 
	AND SUBSTRING(INFO_ADICIONAL, 1, 1) = @MONEDA  
	AND FECHAPROCESO = (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK))
	
					        		
	OPEN CursorDPF
	FETCH NEXT FROM CursorDPF INTO @T_ENTIDAD_DEBITAR
									, @T_CODIGO_TRANSACCION
									, @T_CUENTA_DEBITAR
									, @T_IMPORTE
									, @T_NRO_CHEQUE
									, @T_CODIGO_POSTAL
									, @RI_INFO_ADICIONAL
									, @T_PUNTO_INTERCAMBIO
									, @T_TRACE_NUMBER
									, @CheCodRechazo
	
	WHILE @@FETCH_STATUS = 0
	BEGIN
		Start_1:
		IF (@SumaImportes > 999999999999999999.99 OR @SumaEntidad > 999999) -- 99 millones
		BEGIN
			
			IF @SumaSucursal > 9999
			BEGIN
				SET @SobranteSucursal = CAST(substring(CAST(@SumaSucursal AS VARCHAR), 1, (len(@SumaSucursal) - 4)) AS NUMERIC);
				SET @SumaEntidad += @SobranteSucursal;
				SET @SumaSucursal = CAST(RIGHT(@SumaSucursal, 4) AS NUMERIC);
			END
			
		   --	SET @TotalesControl += @SumaEntidad + @SumaSucursal;
	   		SET @FL_TOTALES_DE_CONTROL =RIGHT(concat(replicate(''0'', 10), (SELECT sum(convert(bigINT,substring(t.LINEA,4,8))) FROM ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX t WHERE t.ID>(SELECT max(tt.id) FROM ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX tt WHERE tt.LINEA LIKE ''5%'') AND substring(t.LINEA,1,1) IN (''6''))), 10);
	   		SET @FL_SUMA_TOTAL_DEBITO_LOTE =  RIGHT(concat(replicate(''0'', 20), (replace((SELECT sum(convert(bigint, substring(linea,61,16))) FROM ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE ''6%'' AND LINEA NOT LIKE ''622%'' AND id>(SELECT max(id) FROM ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE ''5%'')), ''.'', ''''))), 20); 
	   		SET @FL_SUMA_TOTAL_CREDITO_LOTE = RIGHT(concat(replicate(''0'', 20), (replace((SELECT sum(convert(bigint, substring(linea,61,16))) FROM ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE ''622%'' AND id>(SELECT max(id) FROM ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE ''5%'')), ''.'', ''''))), 20); 
	   		SET @TotalesDebitos += @SumaImportes;
	   		SET @FL_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 6), (SELECT count(id) FROM ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX t WHERE t.ID>(SELECT max(tt.id) FROM ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX tt WHERE tt.LINEA LIKE ''5%'') AND substring(t.LINEA,1,1) IN (''6'',''7''))), 6);	
		   	
		   	SET @FL_FIN_LOTE = concat(@FL_ID_REG
										, @FL_CODIGO_CLASE_TRANSAC
										, @FL_CANT_REG_INDIVIDUAL_ADICIONAL
										, @FL_TOTALES_DE_CONTROL
										, @FL_SUMA_TOTAL_DEBITO_LOTE
										, @FL_SUMA_TOTAL_CREDITO_LOTE
										, @FL_RESERVADO1
										, @FL_RESERVADO2
										, @FL_RESERVADO3
										, @FL_REG_ENTIDAD_ORIGEN
										, @FL_NUMERO_LOTE);
			
	    
		
			INSERT INTO dbo.ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX (LINEA) VALUES (replace(@FL_FIN_LOTE, ''.'', ''''));
			
			SET @FL_NUMERO_LOTE = CAST(@FL_NUMERO_LOTE AS NUMERIC) + 1;
			SET @FL_NUMERO_LOTE = RIGHT(concat(replicate(''0'', 7), @FL_NUMERO_LOTE), 7);
			-------------------------------------------------------------------
			-------------Grabamos el Fin de Archivo ----------------------------------------------------------------------------------------------------------------------
			SET @FA_CANT_LOTES = RIGHT(concat(replicate(''0'', 6), (SELECT count(ID) FROM ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE ''5%''AND id>(SELECT max(ID) FROM ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE ''1%''))), 6);
			SET @CantRegistrosPrev = (SELECT (CASE WHEN (@CantRegistros + 4) % 10 = 0 THEN ((@CantRegistros + 4)/10) ELSE (FLOOR((@CantRegistros + 4)/10) + 1) END));
			SET @FA_NUMERO_BLOQUES = RIGHT(concat(replicate(''0'', 6), (SELECT CEILING((count(*)+1) / CONVERT(FLOAT, 10)) FROM ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX WHERE  ID>=(SELECT max(id) FROM ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE ''1%''))), 6);
	
			SET @FA_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 8), (SELECT count(id) FROM ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX t WHERE t.ID>(SELECT max(tt.id) FROM ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX tt WHERE tt.LINEA LIKE ''1%'') AND substring(t.LINEA,1,1) IN (''6'',''7''))), 8);
			
			SET @FA_TOTALES_DE_CONTROL =  RIGHT(concat(replicate(''0'', 10), (SELECT sum(convert(bigINT,substring(t.LINEA,4,8))) FROM ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX t WHERE t.ID>(SELECT max(tt.id) FROM ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX tt WHERE tt.LINEA LIKE ''1%'') AND substring(t.LINEA,1,1) IN (''6''))), 10);
			
			SET @FA_SUMA_TOTAL_DEBITOS = RIGHT(concat(replicate(''0'', 20), (replace((SELECT sum(convert(bigint, substring(linea,61,16))) FROM ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE ''6%'' AND LINEA NOT LIKE ''622%'' AND id>(SELECT max(id) FROM ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE ''1%'')), ''.'', ''''))), 20);
		
			SET @FA_SUMA_TOTAL_CREDITOS = RIGHT(concat(replicate(''0'', 20), (replace((SELECT sum(convert(bigint, substring(linea,61,16))) FROM ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE ''622%'' AND id>(SELECT max(id) FROM ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE ''1%'')), ''.'', ''''))), 20);
	
			SET @FA_FIN_ARCHIVO = concat(@FA_ID_REG, @FA_CANT_LOTES, @FA_NUMERO_BLOQUES, @FA_CANT_REG_INDIVIDUAL_ADICIONAL, @FA_TOTALES_DE_CONTROL, @FA_SUMA_TOTAL_DEBITOS, @FA_SUMA_TOTAL_CREDITOS, @FA_RESERVADO);
			
			INSERT INTO dbo.ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX (LINEA) VALUES (@FA_FIN_ARCHIVO);
			------------------------------------------------------------------------------------------------------------------------------------------------------------------
			---------- Limpiamos variables -----------------------------------------------------------------------------------------------------------------------------------
			SET @SumaImportes = 0;
			SET @CantRegistros = 0;
			SET @CantRegistrosPrev = 0;
			
			SET @TotalesControl = 0;
			SET @TotalesDebitos = 0;
			SET @TotalesCreditos = 0;
	
			SET @SumaEntidad = 0;
			SET @SumaSucursal = 0;
			SET @Cant_Reg_Individual_Adicional = 0;
			SET @FL_TOTALES_DE_CONTROL = 0;
			SET @FA_SUMA_TOTAL_DEBITOS = 0;
			SET @FA_SUMA_TOTAL_CREDITOS = 0;
			SET @SumaSucursal =0;
			-------------------------------------------------------------------------------------------------------------------------------------------------------------------
			--------- Grabamos nueva Cabecera de Archivo ----------------------------------------------------------------------------------------------------------------------
			SET @CA_CABECERA = concat(@CA_ID_REG, @CA_CODIGO_PRIORIDAD, @CA_DESTINO_INMEDIATO, @CA_ORIGEN_INMEDIATO, @CA_FECHA_PRESENTACION, @CA_HORA_PRESENTACION, @CA_IDENTIFICADOR_ARCHIVO, @CA_TAMANNO_REGISTRO, @CA_FACTOR_BLOQUE, @CA_CODIGO_FORMATO, @CA_NOMBRE_DEST_INMEDIATO, @CA_NOMBRE_ORIG_INMEDIATO, @CA_CODIGO_REFERENCIA);
			
			INSERT INTO dbo.ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX (LINEA) VALUES (@CA_CABECERA);
			----------------------------------------------------------------------------------------------------------------------------------------------------------------------
			--------- Grabamos nueva Cabecera Lote ------------------------------------------------------------------------------------------------------------------------------------------------------
			SET @CL_NUMERO_LOTE = RIGHT(concat(replicate(''0'', 7), (@CL_NUMERO_LOTE + 1)), 7);
			SET @CL_CABECERA = concat(@CL_ID_REG, @CL_CODIGO_CLASE_TRANSAC, @CL_RESERVADO, @CL_TIPO_REGISTRO, @CL_DESCRIP_TRANSAC, @CL_FECHA_PRESENTACION, @CL_FECHA_VENCIMIENTO, @CL_RESERVADO_CL, @CL_CODIGO_ORIGEN, @CL_ID_ENTIDAD_ORIGEN, @CL_NUMERO_LOTE);
			INSERT INTO dbo.ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX (LINEA) VALUES (@CL_CABECERA);
			---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
		END
		
		SET @CantRegistros += 1;
		SET @Cant_Reg_Individual_Adicional += 1;
		
		IF	(@Excedente<>0)
		BEGIN
			SET @T_IMPORTE = @Excedente;
			SET @CountExcedente += 1;
		END
		IF	(@T_IMPORTE>99999999999999.99)
		BEGIN
			SET @Excedente = (@T_IMPORTE - 99999999999999.99);
			SET @T_IMPORTE = 99999999999999.99;
			SET @CountExcedente += 1;
			--SET @RA_CONTADOR_REGISTRO_ORIGEN = @RI_CONTADOR_REGISTRO;
		END
		ELSE
	    BEGIN
	       SET @Excedente = 0;
	    END
		
		/*
		SET @SumaSucursal += CONVERT(NUMERIC(4),RIGHT(@T_ENTIDAD_DEBITAR,4));
		SET @SumaEntidad += CONVERT(NUMERIC(4),LEFT(RIGHT(concat(replicate(''0'', 8), @T_ENTIDAD_DEBITAR), 8),4));
		SET @SumaImportes += @T_IMPORTE;
		*/
		---------------------------- Grabar Registro Individual -----------------------------------------------------------------------------------------------------------------------------------------
		SET @RI_ENTIDAD_DEBITAR = RIGHT(concat(replicate(''0'', 8), @T_ENTIDAD_DEBITAR), 8);
	    SET @RI_CUENTA_DEBITAR = RIGHT(concat(replicate(''0'', 17), @T_CUENTA_DEBITAR), 17);
	    SET @RI_NUMERO_CHEQUE = concat(''00'', RIGHT(concat(replicate(''0'', 13), @T_NRO_CHEQUE), 13));
	    
	    IF(@CountExcedente>1)
		BEGIN
	        SET @SumaSucursal += 0888;  --sumo la sucursal que hay que harcodear
	        SET @SumaEntidad +=  CONVERT(NUMERIC(4),LEFT(RIGHT(concat(replicate(''0'', 8), @T_ENTIDAD_DEBITAR), 8),4));
	        SET @SumaImportes += @T_IMPORTE;
	
	        SET @RI_ENTIDAD_DEBITAR = concat(LEFT(RIGHT(concat(replicate(''0'', 8), @T_ENTIDAD_DEBITAR), 8),4), ''0888'');
	        SET @RI_CUENTA_DEBITAR = RIGHT(concat(replicate(''0'', 17), ''88888888888''), 17);
	        SET @RI_NUMERO_CHEQUE = ''000088888888888'';
	
	   
	   	END
	    ELSE --la razon de este else, es que SumaSucursal, cuando hay excedente tiene que acumular 0888
	    BEGIN
	        SET @SumaSucursal += CONVERT(NUMERIC(4),RIGHT(@T_ENTIDAD_DEBITAR,4));
			SET @SumaEntidad += CONVERT(NUMERIC(4),LEFT(RIGHT(concat(replicate(''0'', 8), @T_ENTIDAD_DEBITAR), 8),4));
			SET @SumaImportes += @T_IMPORTE;
	
	        SET @RI_ENTIDAD_DEBITAR = RIGHT(concat(replicate(''0'', 8), @T_ENTIDAD_DEBITAR), 8);
	        
	        SET @RI_CUENTA_DEBITAR = RIGHT(concat(replicate(''0'', 17), @T_CUENTA_DEBITAR), 17);
	        
	        SET @RI_NUMERO_CHEQUE = concat(''00'', RIGHT(concat(replicate(''0'', 13), @T_NRO_CHEQUE), 13));
	 
	    END
	
		IF @SumaImportes>999999999999999999.99 GOTO Start_1

	    SET @RI_IMPORTE = RIGHT(concat(replicate(''0'', 16), replace(CAST(@T_IMPORTE AS VARCHAR),''.'','''')), 16);
	    SET @RI_CODIGO_POSTAL = RIGHT(concat(''00'', replicate(''0'', 6), @T_CODIGO_POSTAL), 6);
	    --SET @RI_INFO_ADICIONAL = @MONEDA;
	    SET @RI_REGISTRO_ADICIONAL = ''0'';
	    
	    IF(@MONEDA=1)
	    SET @RI_CONTADOR_REGISTRO = concat(''0811'', RIGHT(concat(replicate(''0'', 4), (''97'')), 4), RIGHT(concat(replicate(''0'', 7), (SELECT NUMERICO_1 FROM ITF_MASTER_PARAMETROS WHERE CODIGO = 137)), 7)); 
	    ELSE
	    SET @RI_CONTADOR_REGISTRO = concat(''0311'', RIGHT(concat(replicate(''0'', 4), (''97'')), 4), RIGHT(concat(replicate(''0'', 7), (SELECT NUMERICO_1 FROM ITF_MASTER_PARAMETROS WHERE CODIGO = 137)), 7)); 
	     
	        	
		SET @RI_REGISTRO_INDIVIDUAL = concat(@RI_ID_REG
											, @T_CODIGO_TRANSACCION
											, @RI_ENTIDAD_DEBITAR
											, @RI_RESERVADO
											, @RI_CUENTA_DEBITAR
											, @RI_PUNTO_INTERCAMBIO											
											, @RI_NUMERO_CHEQUE
											, @RI_CODIGO_POSTAL
											, @RI_IMPORTE
											, @RI_INFO_ADICIONAL
											, @RI_REGISTRO_ADICIONAL
											, @RI_CONTADOR_REGISTRO);
	 
	    
	    INSERT INTO dbo.ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX (LINEA) VALUES (@RI_REGISTRO_INDIVIDUAL);
		
		----Grabo Registro Adicional (RA)
		SET @CODIGO_RECHAZO = ''R'' + RIGHT(CONCAT(''00'',@CheCodRechazo),2);
		SET @TRACE_NUMBER=  RIGHT(CONCAT(''000000000000000'',@T_TRACE_NUMBER),15); 
		SET @OTRO_RECHAZO = REPLICATE('' '',44);
		SET @CheEntidadDebitarV = RIGHT(concat(replicate(''0'', 8), @T_ENTIDAD_DEBITAR), 8);
		
		SET @RA_REGISTRO_INDIVIDUAL = Concat(@RA_ID_REG_ADICIONAL,
											 @CODIGO_RECHAZO,
											 @TRACE_NUMBER,
											 ''      '',
											 @CheEntidadDebitarV,
											 @OTRO_RECHAZO,
											 @RI_CONTADOR_REGISTRO);
		
		INSERT INTO dbo.ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX (LINEA) VALUES (@RA_REGISTRO_INDIVIDUAL);
		-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		----------------------------- Actualizar secuencial unico -------------------------------------
		UPDATE dbo.ITF_MASTER_PARAMETROS SET NUMERICO_1 = (NUMERICO_1 + 1) WHERE CODIGO = 137;
		-----------------------------------------------------------------------------------------------
		/*
		----------------------------- Grabar historial ---------------------------------------------------------------------------------------------------------------------------------------------------------------
	    INSERT INTO ITF_COELSA_CHEQUES_OTROS (ID_TICKET, ID_PROCESO, FECHAPROCESO, CODIGO_TRANSACCION, BANCO, SUCURSAL, CUENTA, IMPORTE, CODIGO_POSTAL, FECHA_PRESENTADO, FECHA_VENCIMIENTO, NRO_CHEQUE, PUNTO_INTERCAMBIO, TRACE_NUMBER, ESTADO, TIPO, MONEDA, TIPO_DOCUMENTO)
	    VALUES (@TICKET, @TICKET, (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK)), @RI_CODIGO_TRANSAC, @D_BANCO, @D_SUCURSAL, @D_CUENTA, @D_IMPORTE, @D_CODIGO_POSTAL, @D_FECHA, @D_FECHA, @D_NUMERO_DPF, @RI_PUNTO_INTERCAMBIO, @RI_CONTADOR_REGISTRO, ''P'', ''D'', @D_MONEDA, @D_TIPO_DOCUMENTO);
	    --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		
		---------------- Actualizar informacion del dpf --------------------------------------------------------------------------------------------------------------------------------------
		UPDATE dbo.CLE_DPF_SALIENTE SET TRACKNUMBER = @RI_CONTADOR_REGISTRO, ESTADO = 2, FECHA_ENVIO_COMPENSACION = (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK))
	    WHERE TIPO_DOCUMENTO = @D_TIPO_DOCUMENTO AND NUMERO_DPF = @D_NUMERO_DPF AND BANCO_GIRADO = @D_BANCO AND SUCURSAL_BANCO_GIRADO = @D_SUCURSAL AND FECHA_ALTA = @D_FECHA AND TZ_LOCK = 0;
		--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------    	
		*/
		
		IF (@Excedente = 0)
		BEGIN		     	       				
		
		FETCH NEXT FROM CursorDPF INTO @T_ENTIDAD_DEBITAR, @T_CODIGO_TRANSACCION, @T_CUENTA_DEBITAR, @T_IMPORTE, @T_NRO_CHEQUE,@T_CODIGO_POSTAL,@RI_INFO_ADICIONAL,@T_PUNTO_INTERCAMBIO,@T_TRACE_NUMBER,@CheCodRechazo
		
		SET @CountExcedente = 0;
		--SET @RA_CONTADOR_REGISTRO_ORIGEN = '''';
		END
		
	END
	
	CLOSE CursorDPF
	DEALLOCATE CursorDPF
	
	
	IF @SumaSucursal > 9999
	BEGIN
		SET @SobranteSucursal = CAST(substring(CAST(@SumaSucursal AS VARCHAR), 1, (len(@SumaSucursal) - 4)) AS NUMERIC);
	  	SET @SumaEntidad += @SobranteSucursal;
		SET @SumaSucursal = CAST(RIGHT(@SumaSucursal, 4) AS NUMERIC);
	END
	
	/*-- Grabamos fin de lote y archivo solo si hay registros individuales ingresados
	IF(0<(SELECT COUNT(*) FROM ITF_COELSA_CHEQUES_RECHAZO WHERE ESTADO = ''P'' AND TIPO = ''D'' AND SUBSTRING(INFO_ADICIONAL, 1, 1) = @MONEDA  AND FECHAPROCESO = (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK))))
	BEGIN
		  */	
	--SET @TotalesControl += @SumaEntidad + @SumaSucursal;
	SET @FL_TOTALES_DE_CONTROL =RIGHT(concat(replicate(''0'', 10), (SELECT sum(convert(bigINT,substring(t.LINEA,4,8))) FROM ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX t WHERE t.ID>(SELECT max(tt.id) FROM ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX tt WHERE tt.LINEA LIKE ''5%'') AND substring(t.LINEA,1,1) IN (''6''))), 10);
	--SET @TotalesControl += CAST(@FL_TOTALES_DE_CONTROL AS INTEGER);
	SET @FL_SUMA_TOTAL_DEBITO_LOTE =  RIGHT(concat(replicate(''0'', 20), (replace((SELECT sum(convert(bigint, substring(linea,61,16))) FROM ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE ''6%'' AND LINEA NOT LIKE ''622%'' AND id>(SELECT max(id) FROM ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE ''5%'')), ''.'', ''''))), 20); 
	SET @FL_SUMA_TOTAL_CREDITO_LOTE = RIGHT(concat(replicate(''0'', 20), (replace((SELECT sum(convert(bigint, substring(linea,61,16))) FROM ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE ''622%'' AND id>(SELECT max(id) FROM ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE ''5%'')), ''.'', ''''))), 20);	
	SET @FL_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 6), (SELECT count(id) FROM ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX t WHERE t.ID>(SELECT max(tt.id) FROM ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX tt WHERE tt.LINEA LIKE ''5%'') AND substring(t.LINEA,1,1) IN (''6'',''7''))), 6);	
	
	
	
	SET @FL_FIN_LOTE = concat(@FL_ID_REG
							, @FL_CODIGO_CLASE_TRANSAC
							, @FL_CANT_REG_INDIVIDUAL_ADICIONAL
							, @FL_TOTALES_DE_CONTROL
							, @FL_SUMA_TOTAL_DEBITO_LOTE
							, @FL_SUMA_TOTAL_CREDITO_LOTE
							, @FL_RESERVADO1
							, @FL_RESERVADO2
							, @FL_RESERVADO3
							, @FL_REG_ENTIDAD_ORIGEN
							, @FL_NUMERO_LOTE);
			
	INSERT INTO dbo.ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX (LINEA) VALUES (@FL_FIN_LOTE);

	---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-------------Grabamos el Fin de Archivo ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	SET @FA_CANT_REG_INDIVIDUAL_ADICIONAL = RIGHT(concat(replicate(''0'', 8), (SELECT count(id) FROM ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX t WHERE t.ID>(SELECT max(tt.id) FROM ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX tt WHERE tt.LINEA LIKE ''1%'') AND substring(t.LINEA,1,1) IN (''6'',''7''))), 8);
			
	SET @FA_TOTALES_DE_CONTROL =RIGHT(concat(replicate(''0'', 10), (SELECT sum(convert(bigINT,substring(t.LINEA,4,8))) FROM ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX t WHERE t.ID>(SELECT max(tt.id) FROM ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX tt WHERE tt.LINEA LIKE ''1%'') AND substring(t.LINEA,1,1) IN (''6''))), 10); --igualo al totales de control de fin de lote pq tiene que ser igual
			
	SET @FA_SUMA_TOTAL_DEBITOS = RIGHT(concat(replicate(''0'', 20), (replace((SELECT sum(convert(bigint, substring(linea,61,16))) FROM ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE ''6%'' AND LINEA NOT LIKE ''622%'' AND id>(SELECT max(id) FROM ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE ''1%'')), ''.'', ''''))), 20);
			
	SET @FA_SUMA_TOTAL_CREDITOS = RIGHT(concat(replicate(''0'', 20), (replace((SELECT sum(convert(bigint, substring(linea,61,16))) FROM ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE ''622%'' AND id>(SELECT max(id) FROM ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE ''1%'')), ''.'', ''''))), 20);
	

	SET @FA_CANT_LOTES = RIGHT(concat(replicate(''0'', 6), (SELECT count(ID) FROM ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE ''5%''AND id>(SELECT max(ID) FROM ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX WHERE LINEA LIKE ''1%''))), 6);

	--SET @FA_NUMERO_BLOQUES = RIGHT(concat(replicate(''0'', 6), @CantRegistrosPrev ), 6);
			
	SET @FA_NUMERO_BLOQUES = RIGHT(concat(replicate(''0'', 6), (SELECT CEILING((count(*)+1) / CONVERT(FLOAT, 10))
																  FROM ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX 
																  WHERE  ID>=(SELECT max(id) 
																  		  		FROM ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX 
																  		  		WHERE LINEA LIKE ''1%''))), 6);

	SET @FA_FIN_ARCHIVO = concat(@FA_ID_REG, @FA_CANT_LOTES, @FA_NUMERO_BLOQUES, @FA_CANT_REG_INDIVIDUAL_ADICIONAL, @FA_TOTALES_DE_CONTROL, @FA_SUMA_TOTAL_DEBITOS, @FA_SUMA_TOTAL_CREDITOS, @FA_RESERVADO);

	INSERT INTO dbo.ITF_ENVIO_DPF_PROPIOS_RECHAZADOS_AUX (LINEA) VALUES (@FA_FIN_ARCHIVO);
	
				
	SET @FL_NUMERO_LOTE = CAST(@FL_NUMERO_LOTE AS NUMERIC) + 1;
	SET @FL_NUMERO_LOTE = RIGHT(concat(replicate(''0'', 7), @FL_NUMERO_LOTE), 7);
	------------------------------------------------------------------------------------------------------------------------------------------------------------------
--END
END')

Execute('CREATE OR ALTER PROCEDURE [dbo].[SP_COELSA_CHEQUES_TERCEROS_RECHAZADOS]

	@TICKET NUMERIC(16)

AS
BEGIN

	/******** Variables Cabecera de Archivo **********************************/
	DECLARE @IdRegistro NUMERIC(1);
	DECLARE @CodPrioridad NUMERIC(2);
	DECLARE @DestinoInmediato VARCHAR(10);
	DECLARE @OrigenInmediato VARCHAR(10);
	DECLARE @FechaPresentacion DATE;
	DECLARE @HoraPresentacion NUMERIC(4);
	DECLARE @IdArchivo VARCHAR(1);
	DECLARE @TamanioRegistro VARCHAR(3);
	DECLARE @FactorBloque VARCHAR(2);
	DECLARE @CodFormato NUMERIC(1);
	DECLARE @NomDestinoInmediato VARCHAR(23);
	DECLARE @NomOrigenInmediato VARCHAR(23);
	DECLARE @CodReferencia VARCHAR(8);
	/*************************************************************************/

	/******** Variables Cabecera de Lote **********************************/
	DECLARE @FechaVencimiento DATE;
	DECLARE @ClaseTransaccion NUMERIC(3);
	DECLARE @ReservadoLote VARCHAR(46);
	DECLARE @ReservadoLoteCeros NUMERIC(3);
	DECLARE @CodigoOrigen  NUMERIC(1);
	DECLARE @CodigoRegistro VARCHAR(3);
	DECLARE @IdEntidadOrigen NUMERIC(8);
	declare @NumeroLote NUMERIC(7);

	/******** Variables Registro Individual de Cheques y Ajustes *************/
	DECLARE @CodTransaccion VARCHAR(2);
	DECLARE @EntidadDebitar VARCHAR(8);
	DECLARE @ReservadoRI VARCHAR(1);
	DECLARE @CuentaDebitar VARCHAR(17);
--s	DECLARE @Importe VARCHAR(10);
	DECLARE @Importe VARCHAR(16);
	DECLARE @NumeroCheque VARCHAR(15);
	DECLARE @CodigoPostal VARCHAR(6);
--s	DECLARE @PuntoIntercambio VARCHAR(16);
	DECLARE @PuntoIntercambio VARCHAR(10);
	DECLARE @InfoAdicional VARCHAR(2);
	DECLARE @RegistrosAdicionales VARCHAR(2);
	DECLARE @ContadorRegistros VARCHAR(15);
	
	DECLARE @CodRechazo VARCHAR (2);
	DECLARE @CodRechazoOri VARCHAR (2);
	DECLARE @CODCLI NUMERIC(12);
	DECLARE @PRODUCTO NUMERIC(5);
	DECLARE @ORDINAL NUMERIC(6);
	DECLARE @Entidad NUMERIC(4);

    
	--SE VAN A USAR ESTOS CAMPOS COMO CLAVE EN LUGAR DEL TRACENUMBER
	
	DECLARE @Entidad_RI VARCHAR(4);	-- SE CAMBIA TIPO A VARCHAR PORQUE AHORA NO SE VALIDA MAS EL REG INDIVIDUAL
	DECLARE @Sucursal_RI VARCHAR(4); -- SE CAMBIA TIPO A VARCHAR PORQUE AHORA NO SE VALIDA MAS EL REG INDIVIDUAL
	DECLARE @CodigoPostal_RI VARCHAR(4); -- SE CAMBIA TIPO A VARCHAR PORQUE AHORA NO SE VALIDA MAS EL REG INDIVIDUAL
	DECLARE @NumeroCuenta_RI VARCHAR(12); -- SE CAMBIA TIPO A VARCHAR PORQUE AHORA NO SE VALIDA MAS EL REG INDIVIDUAL
	DECLARE @NumeroCheque_RI VARCHAR(12); -- SE CAMBIA TIPO A VARCHAR PORQUE AHORA NO SE VALIDA MAS EL REG INDIVIDUAL

	DECLARE @ExisteRI NUMERIC(1) = 0; --para saber si hay al menos 1 lote
	
	/******** Variables FIN DE LOTE *************/
	DECLARE @RegIndivAdic NUMERIC(6);
	DECLARE @TotalesControl NUMERIC(10);
	DECLARE @ReservadoFL VARCHAR(40);

	/******** Variables FIN DE ARCHIVO *************/

	DECLARE @CantLotesFA NUMERIC(6);
	DECLARE @NumBloquesFA NUMERIC(6);
	DECLARE @CantRegAdFA NUMERIC (8);
	DECLARE @TotalesControlFA NUMERIC(10);

	DECLARE @ReservadoFA VARCHAR(39);
	/*************************************************************************/


	/*Validaciones generales */

	DECLARE @updRecepcion VARCHAR(1);

	--#validacion1
	IF(0=(SELECT COUNT(1) FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX WHERE LINEA LIKE ''1%''))
		RAISERROR (''Error - Faltan registros.'', 16, 1);
	IF(0=(SELECT COUNT(1) FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX WHERE LINEA LIKE ''5%''))
		RAISERROR (''Error - Faltan registros.'', 16, 1);
	IF(0=(SELECT COUNT(1) FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX WHERE LINEA LIKE ''8%''))
		RAISERROR (''Error - Faltan registros.'', 16, 1);
	IF(0=(SELECT COUNT(1) FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX WHERE LINEA LIKE ''9%''))
		RAISERROR (''Error - Faltan registros.'', 16, 1);

	--#validacion2
	IF ((SELECT COUNT(1) FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX WHERE LINEA LIKE ''1%'' OR LINEA LIKE ''9%'') > 2 )
		RAISERROR(''Error - Deben haber solo 1 reg CA y 1 reg FA'', 16, 1);

	--#validacion3
	IF(
	(SELECT COUNT(1) as Orden
	WHERE 1=(SELECT count(1)
			WHERE EXISTS (SELECT CONVERT(INT,SUBSTRING(LINEA,1,1))
							FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX
							WHERE ID IN	(SELECT ID-1
										FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX
										WHERE LINEA LIKE ''8%'')
							AND CONVERT(INT,SUBSTRING(LINEA,1,1)) NOT IN (5,6,7)
						)
			)
		OR 1=(SELECT count(1)
			WHERE EXISTS (SELECT CONVERT(INT,SUBSTRING(LINEA,1,1))
							FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX
							WHERE ID IN	(SELECT ID+1
										FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX
										WHERE LINEA LIKE ''8%'')
										AND CONVERT(INT,SUBSTRING(LINEA,1,1)) NOT IN (5,9)
							)
			)
		OR 1=(SELECT count(1)
			WHERE EXISTS (SELECT CONVERT(INT,SUBSTRING(LINEA,1,1))
						FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX
						WHERE ID IN	(SELECT ID-1
									FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX
									WHERE LINEA LIKE ''5%'')
						AND CONVERT(INT,SUBSTRING(LINEA,1,1)) NOT IN (1,8)
							)
					)
		OR 1=(SELECT count(1)
			WHERE EXISTS (SELECT CONVERT(INT,SUBSTRING(LINEA,1,1))
							FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX
							WHERE ID IN	(SELECT ID+1
										FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX
										WHERE LINEA LIKE ''5%'')
							AND CONVERT(INT,SUBSTRING(LINEA,1,1)) NOT IN (6,7,8)
							)
						)) <> 0
	)
		RAISERROR(''El orden de los registros NACHA es incorrecto'', 16, 1);


	------validaciones #5 #6 #7 y #8

	--#5 y 7
	DECLARE @sumaEntidades_RI NUMERIC = 0;
	DECLARE @sumaSucursales_RI NUMERIC = 0;
	DECLARE @sumaEntidades_RIaux NUMERIC = 0;
	DECLARE @sumaSucursales_RIaux NUMERIC = 0;




	DECLARE @sumaTotalCtrl_FL NUMERIC;
	DECLARE @totControl_FA NUMERIC;

	DECLARE @excedenteSuc NUMERIC = 0;

	--#6 y 8
	DECLARE @sumaDebitos_RI NUMERIC;
	DECLARE @sumaCreditos_RI NUMERIC;

	DECLARE @controlDebitos_FL NUMERIC;
	DECLARE @controlCreditos_FL NUMERIC;

	DECLARE @totalDebitos_FA NUMERIC;
	DECLARE @totalCreditos_FA NUMERIC;

	--seteo suma deb y cred 

	SELECT -- debitos
--s		@sumaDebitos_RI = sum(CAST(substring(LINEA, 30, 10) AS NUMERIC)),
		@sumaDebitos_RI = sum(CAST(substring(LINEA, 61, 16) AS NUMERIC)),
		@sumaEntidades_RI = sum(CAST(substring(LINEA, 4, 4) AS NUMERIC)),
		@sumaSucursales_RI = sum(CAST(substring(LINEA, 8, 4) AS NUMERIC))
	FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX
	WHERE LINEA LIKE ''626%'';

	SELECT --creditos
--s		@sumaCreditos_RI = sum(CAST(substring(LINEA, 30, 10) AS NUMERIC)),
		@sumaCreditos_RI = sum(CAST(substring(LINEA, 61, 16) AS NUMERIC)),
		@sumaEntidades_RIaux = sum(CAST(substring(LINEA, 4, 4) AS NUMERIC)),
		@sumaSucursales_RIaux = sum(CAST(substring(LINEA, 8, 4) AS NUMERIC))
	FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX
	WHERE LINEA LIKE ''622%'';

	SET @sumaEntidades_RI += isNull(@sumaEntidades_RIaux,0);
	SET @sumaSucursales_RI += isNull(@sumaSucursales_RIaux,0);
	

	--seteo total control y total de importes FA
	SELECT
		@totControl_FA = CAST(substring(linea, 22, 10) AS NUMERIC), --revisar acaaaa
--s		@totalDebitos_FA = CAST(substring(linea, 32, 12) AS NUMERIC),
--s		@totalCreditos_FA = CAST(substring(linea, 44, 12) AS NUMERIC)
		@totalDebitos_FA = CAST(substring(linea, 32, 20) AS NUMERIC),
		@totalCreditos_FA = CAST(substring(linea, 52, 20) AS NUMERIC)
	FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX
	WHERE LINEA LIKE ''9%'';


	--CHEQUEO SI HAY EXCEDENTE #5 Y 7
	IF(LEN(@sumaSucursales_RI) > 4)
	BEGIN
		SET @excedenteSuc = CAST(LEFT(@sumaSucursales_RI,len(@sumaSucursales_RI)-4) AS NUMERIC);
		SET @sumaSucursales_RI = RIGHT(@sumaSucursales_RI, 4);
	--ME QUEDO CON LAS 4 CIFRAS SIGNIFICATIVAS
	END
	SET @sumaEntidades_RI = @sumaEntidades_RI + @excedenteSuc;
	--LE SUMO EL EXCEDENTE, SI NO HAY SUMO 0

	--seteo suma totales control y debitos de FL
	SELECT
		@sumaTotalCtrl_FL = SUM(CAST(substring(linea, 11, 10) AS NUMERIC)),
--s		@controlDebitos_FL = sum(CAST(substring(LINEA, 21, 12) AS NUMERIC)),
--s		@controlCreditos_FL = sum(CAST(substring(LINEA, 33, 12) AS NUMERIC))
		@controlDebitos_FL = sum(CAST(substring(LINEA, 21, 20) AS NUMERIC)),
		@controlCreditos_FL = sum(CAST(substring(LINEA, 41, 20) AS NUMERIC))
	FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX
	WHERE LINEA LIKE ''8%'';

--PRINT CONCAT(@sumaEntidades_RI, RIGHT(CONCAT(REPLICATE(''0'',3), @sumaSucursales_RI ),4))
--PRINT @sumaTotalCtrl_FL
	--#validacion5
	IF(CONCAT(@sumaEntidades_RI, RIGHT(CONCAT(REPLICATE(''0'',3), @sumaSucursales_RI ),4)) <> @sumaTotalCtrl_FL)
		RAISERROR(''No concuerda la suma Ent/Suc con control FL'', 16, 1);

	--#validacion7
	IF(@sumaTotalCtrl_FL <> @totControl_FA)
		RAISERROR(''No concuerda la suma de TotalesControl de FL con control FA'', 16, 1);

	--#validacion6 debitos
	IF(@sumaDebitos_RI  <> @controlDebitos_FL AND @sumaDebitos_RI <> @totalDebitos_FA)
		RAISERROR(''No concuerda la suma de Debitos individuales con el Total Debitos'', 16, 1);

	--#validacion6 creditos
	IF( @sumaCreditos_RI <> @controlCreditos_FL AND @sumaCreditos_RI <> @totalCreditos_FA)
		RAISERROR(''No concuerda la suma de Creditos individuales con el Total Creditos '', 16, 1);

	--#validacion8
	IF((@controlDebitos_FL + @controlCreditos_FL) <>  (@totalDebitos_FA + @totalCreditos_FA))
		RAISERROR(''No concuerda la suma de Debitos de FL con Total Importe FA'', 16, 1);


	--fin----validaciones #5 #6 #7 y #8

	DECLARE @id int,@LINEA VARCHAR(95);
	DECLARE che_cursor CURSOR FOR 
	SELECT id,LINEA
	FROM dbo.ITF_OTROS_CHEQUES_RESPUESTA_AUX

	OPEN che_cursor

	FETCH NEXT FROM che_cursor INTO @id,@LINEA

	WHILE @@FETCH_STATUS = 0  
	BEGIN

		--#validacion4
		if(DATALENGTH(@LINEA) <> 94)
			RAISERROR(''Se encontraron registros de longitud incorrecta'', 16,1);

		SET @IdRegistro = substring(@LINEA, 1, 1);

		IF(@IdRegistro NOT IN(''1'',''5'',''6'',''7'',''8'',''9'') ) --validacion de id reg      
      		RAISERROR (''Id Registro invalido'', 16, 1);



		/* Cabecera de Archivo */
		IF (@IdRegistro = ''1'') 
      	BEGIN
			SET @CodPrioridad = substring(@LINEA, 2, 2);
			SET @DestinoInmediato = substring(@LINEA, 4, 10);
			SET @OrigenInmediato = substring(@LINEA, 14, 10);
			SET @FechaPresentacion = substring(@LINEA, 24, 6);
			SET @HoraPresentacion = substring(@LINEA, 30, 4);
			SET @IdArchivo = substring(@LINEA, 34, 1);
			SET @TamanioRegistro = substring(@LINEA, 35, 3);
			SET @FactorBloque = substring(@LINEA, 38, 2);
			SET @CodFormato = substring(@LINEA, 40, 1);
			SET @NomDestinoInmediato = substring(@LINEA, 41, 23);
			SET @NomOrigenInmediato = substring(@LINEA, 64, 23);
			SET @CodReferencia = substring(@LINEA, 87, 8);


			IF (@IdArchivo NOT IN (''A'',''B'',''C'',''D'',''E'',''F'',''G'',''H'',''I'',''J'',''K'',''L'',''M'',''N'',''O'',''P'',''Q'',''R'',''S'',''T'',''U'',''V'',''W'',''X'',''Y'',''Z'',''0'',''1'',''2'',''3'',''4'',''5'',''6'',''7'',''8'',''9'')) 	
				RAISERROR (''Identificador Archivo invalido'', 16, 1);

			--#validacion11
			IF(substring(@DestinoInmediato, 2, 4) <> ''0311'')
				RAISERROR (''Destino inmediato debe ser 0311'', 16, 1);

		END


		IF (@IdRegistro = ''5'') 
      	BEGIN

			--variables cabecera de lote
			SET @ClaseTransaccion = substring(@LINEA, 2, 3);
			SET @ReservadoLote = substring(@LINEA, 5, 46);
			--VALIDACION RESERVADO VACIO
			SET @CodigoRegistro = substring(@LINEA, 51, 3);

			SET @FechaPresentacion = CAST(substring(@LINEA, 64, 6) AS DATE);
			--VALIDACION FECHAS
			SET @FechaVencimiento = CAST(substring(@LINEA, 70, 6) AS DATE);
			SET @ReservadoLoteCeros = substring(@LINEA, 76, 3);
			--VALIDACION RESERVADO 000
			SET @CodigoOrigen = substring(@LINEA, 79, 1);

			SET @IdEntidadOrigen = substring(@LINEA, 80, 4);

			SET @NumeroLote = substring(@LINEA, 88, 7);

			IF (@ClaseTransaccion <> 200)     
    			RAISERROR (''Codigo de clase de transaccion debe ser 200'', 16, 1);

			IF (@CodigoOrigen <> 1)     	
    			RAISERROR (''Codigo origen debe ser 1'', 16, 1);


			IF (@CodigoRegistro <> ''TRC'')       
    			RAISERROR (''Codigo de registro debe ser TRC'', 16, 1);

			IF (@FechaPresentacion > @FechaVencimiento)      	
    			RAISERROR (''Fecha Presentacion debe ser anterior a vencimiento'', 16, 1);
		END

		/*FIN DE LOTE*/
		IF (@IdRegistro = ''8'') 
      	BEGIN
			SET @ClaseTransaccion = substring(@LINEA, 2, 3);
			--SET @RegIndivAdic = substring(@LINEA, 5, 6);
		--	SET @TotalesControl = substring(@LINEA, 11,10);
--s			SET @ReservadoFL = substring(@LINEA, 45, 35);
			SET @ReservadoFL = substring(@LINEA, 61, 29);
			SET @IdEntidadOrigen = substring(@LINEA, 80, 4);
			SET @NumeroLote = substring(@LINEA, 88, 7);

			IF (@ClaseTransaccion <> 200) 
				RAISERROR (''Codigo de clase de transaccion debe ser 200'', 16, 1);

		END

		/*FIN DE ARCHIVO*/
		IF (@IdRegistro = ''9'') 
      	BEGIN
			SET @CantLotesFA = substring(@LINEA, 2, 6);
			SET @NumBloquesFA = substring(@LINEA, 8, 6);
			SET @CantRegAdFA = substring(@LINEA, 14, 8);
			SET @TotalesControlFA  = substring(@LINEA, 22, 10);
--s			SET @ReservadoFA  = substring(@LINEA, 56, 39);
			SET @ReservadoFA  = substring(@LINEA, 72, 23);


			--#validacion9
			IF((SELECT COUNT(1)
			FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX
			WHERE LINEA LIKE ''5%'') <> @CantLotesFA)
			RAISERROR(''No coincide la cantidad de LOTES con la informada en el reg FA'', 16, 1);
			--#validacion10
			IF((SELECT count(1)
			FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX
			WHERE LINEA LIKE ''6%'' OR LINEA LIKE ''7%'') <> @CantRegAdFA)
			RAISERROR(''No coincide la cantidad de registros ind y ad con la informada en el reg FA'', 16, 1);

		END




		/* Registro Individual*/
		IF (@IdRegistro = ''6'' ) 
      	BEGIN
			SET @ExisteRI = 1;

			SET @CodTransaccion = substring(@LINEA, 2, 2);
			SET @EntidadDebitar = substring(@LINEA, 4, 8);
			SET @ReservadoRI = substring(@LINEA, 12, 1);
			SET @CuentaDebitar = substring(@LINEA, 13, 17);
--s			SET @Importe = substring(@LINEA, 30, 10);
			SET @Importe = convert(VARCHAR(16),convert(NUMERIC(15,2),(convert(NUMERIC(16),substring(@LINEA, 61, 16))/100))); 
			SET @NumeroCheque = substring(@LINEA, 40, 15);
			SET @CodigoPostal = substring(@LINEA, 55, 6);
--s			SET @PuntoIntercambio = substring(@LINEA, 61, 16);
			SET @PuntoIntercambio = substring(@LINEA, 30, 10);
			SET @InfoAdicional = substring(@LINEA, 77, 2);
			SET @RegistrosAdicionales = substring(@LINEA, 79, 1);
			SET @ContadorRegistros = substring(@LINEA, 80, 15);
			/* Trace Number */

			SET @Entidad_RI = substring(@ContadorRegistros, 1, 4);
			SET @Sucursal_RI = substring(@ContadorRegistros, 5, 4);
			SET @CodigoPostal_RI = RIGHT(@CodigoPostal, 4);
			SET @NumeroCuenta_RI = RIGHT(@CuentaDebitar, 12);
			SET @NumeroCheque_RI = RIGHT(@NumeroCheque, 12);


			IF (@RegistrosAdicionales NOT IN(''1'',''0'')) 
    			RAISERROR (''Campo Registro adicional invalido'', 16, 1);



			--- Variables Generales ---
			DECLARE @NRO_DPF_CHEQUE NUMERIC(12);
			DECLARE @BANCO_GIRADO NUMERIC(4);
			DECLARE @SUCURSAL_BANCO NUMERIC(5);
			DECLARE @TIPO_DOCUMENTO VARCHAR(4);
--s			DECLARE @IMPORTE_TOTAL NUMERIC(10,2);
			DECLARE @IMPORTE_TOTAL NUMERIC(15,2);
			DECLARE @MONEDA NUMERIC(1);
			DECLARE @SERIE_DEL_CHEQUE VARCHAR(6);
			DECLARE @NRO_CUENTA NUMERIC(12);
			DECLARE @CODIGO_POSTAL NUMERIC(4);
			DECLARE @EXISTE NUMERIC(4) = 0;

			IF(@TICKET<>0)
      		BEGIN
      		
      			--Rechazos como girada (trae registro adicional)
      					/*Registro ind adicional*/
				IF(@RegistrosAdicionales = ''1'')
				BEGIN
			 
					SET @CodRechazo = (SELECT substring(LINEA, 5, 2) FROM ITF_OTROS_CHEQUES_RESPUESTA_AUX WHERE id=@id+1)

	
					IF(ISNUMERIC(@Entidad_RI) = 1 AND ISNUMERIC(@Sucursal_RI) = 1 AND ISNUMERIC(@CodigoPostal_RI) = 1 AND ISNUMERIC(@NumeroCheque_RI) = 1 AND ISNUMERIC(@NumeroCuenta_RI ) = 1 )
					BEGIN			
			--actualizo el codigo de rechazo
						UPDATE ITF_COELSA_SESION_RECHAZADOS 
						SET CODIGO_RECHAZO = @CodRechazo 
						WHERE ID_TICKET = @TICKET 
						AND BANCO = @Entidad_RI 
						AND  SUCURSAL = @Sucursal_RI 
						AND CUENTA = @NumeroCuenta_RI 
						AND CODIGO_POSTAL = @CodigoPostal_RI 
						AND NRO_CHEQUE = @NumeroCheque_RI;
--REVISAMOS ACA
--						IF(@updRecepcion = ''D'')
--						BEGIN
--							UPDATE CLE_RECEPCION_DPF_DEV 
--							SET CODIGO_RECHAZO = @CodRechazo 
--							WHERE NUMERO_DPF = @NumeroCheque_RI 
--							AND BANCO_GIRADO = @Entidad_RI 
--							AND SUCURSAL_BANCO_GIRADO = @Sucursal_RI;
--						END
						
--COMENTADO EL 17/12/2024 POR FUNCIONAMIENTO INCORRECTO DE CLE_RECEPCION_CHEQUES_DEV J.I.
						
--						ELSE IF(@updRecepcion = ''C'' AND ISNUMERIC(@CodRechazo) = 1)
--						BEGIN
--							UPDATE CLE_RECEPCION_CHEQUES_DEV 
--							SET CODIGO_RECHAZO = @CodRechazo 
--							WHERE NUMERO_CHEQUE = @NumeroCheque_RI 
--							AND BANCO_GIRADO = @Entidad_RI 
--							AND SUCURSAL_BANCO_GIRADO = @Sucursal_RI;
--						END
					
--HASTA ACA--

					END
					UPDATE RRII_CHE_RECHAZADOS
					SET CAUSAL=(SELECT TOP 1 CODIGO_DE_CAUSAL FROM CLE_TIPO_CAUSAL WHERE CODIGO_NACHA=@CodRechazo),
						CODIGO_MOTIVO=@CodRechazo
					WHERE cod_entidad = 311
    				AND Nro_sucursal = TRIM(''0'' FROM RIGHT(@EntidadDebitar, 3))
    				AND cuenta = @NumeroCuenta_RI
    				AND nro_cheque = @NumeroCheque_RI
    				AND fecha_registro_novedad = (SELECT fechaproceso FROM PARAMETROS);
				END
      		
--si es un rechazo de entidad depositaria (622%) el codigo de rechazo lo tenemos que setear de la siguiente forma       		
				IF @codTransaccion=''22''
				BEGIN
					IF TRY_CONVERT(INT,SUBSTRING(@LINEA,65,2))=0
					BEGIN
						SET @codRechazo=substring(@linea,67,2)
					END
					ELSE IF TRY_CONVERT(INT,SUBSTRING(@LINEA,67,2))=0
		   			BEGIN
						SET @codRechazo=substring(@linea,65,2)
					END
					ELSE 
					BEGIN 
						SET @CodRechazo=substring(@linea,65,2)
					END 
				END 
				SET @updRecepcion = ''-'';

				IF (ISNUMERIC(@CuentaDebitar) = 1 AND CAST(@CuentaDebitar AS NUMERIC) = 88888888888)
				BEGIN
					IF(ISNUMERIC(@Entidad_RI) = 1 AND ISNUMERIC(@Sucursal_RI) = 1 AND ISNUMERIC(@CodigoPostal_RI) = 1 AND ISNUMERIC(@NumeroCheque_RI) = 1 AND ISNUMERIC(@NumeroCuenta_RI ) = 1 )
					BEGIN
						-- La idea es actualizar los rechazados del plano con ESTADO_AJUSTE = ''R'' y el resto de cheques del historial con ESTADO_AJUSTE  = ''A''	
						UPDATE dbo.CLE_CHEQUES_AJUSTE 
						SET ESTADO_AJUSTE = ''R'' 
						WHERE TZ_LOCK = 0 
						AND @Entidad_RI = BANCO 
						AND @Sucursal_RI  = SUCURSAL_BANCO_GIRADO 
						AND @CodigoPostal_RI = CODIGO_POSTAL 
						AND @NumeroCheque_RI = NUMERO_CHEQUE 
						AND @NumeroCuenta_RI = NUMERO_CUENTA;

						-- Consulta Ajuste
						SELECT @EXISTE = 1, @ORDINAL = ORDINAL, @BANCO_GIRADO = BANCO, @NRO_DPF_CHEQUE = NUMERO_CHEQUE, @SUCURSAL_BANCO = SUCURSAL_BANCO_GIRADO, @NRO_CUENTA = NUMERO_CUENTA, @CODIGO_POSTAL = CODIGO_POSTAL, @IMPORTE_TOTAL = IMPORTE, @MONEDA = MONEDA
						FROM CLE_CHEQUES_AJUSTE WITH(NOLOCK)
						WHERE TZ_LOCK = 0 
						AND @Entidad_RI = BANCO 
						AND @Sucursal_RI  = SUCURSAL_BANCO_GIRADO 
						AND @CodigoPostal_RI = CODIGO_POSTAL 
						AND @NumeroCheque_RI = NUMERO_CHEQUE 
						AND @NumeroCuenta_RI = NUMERO_CUENTA;
					END

					IF @EXISTE > 0
					BEGIN
						
						-- Guardamos clave para update si hay reg adicional
						SET @Entidad_RI = @BANCO_GIRADO;
						SET @Sucursal_RI = @SUCURSAL_BANCO;
						SET @NumeroCuenta_RI = @NRO_CUENTA;
						SET @CodigoPostal_RI = @CODIGO_POSTAL;
						SET @NumeroCheque_RI = @NRO_DPF_CHEQUE;

						-- Insertamos en el historial
						INSERT INTO ITF_COELSA_SESION_RECHAZADOS (ID_TICKET, 
																	FECHA_ALTA, 
																	BANCO, 
																	SUCURSAL, 
																	CUENTA, 
																	IMPORTE, 
																	CODIGO_POSTAL, 
																	NRO_CHEQUE, 
																	PUNTO_INTERCAMBIO, 
																	TRACK_NUMBER, 
																	TIPO, 
																	MONEDA, 
																	TIPO_DOCUMENTO, 
																	CODIGO_RECHAZO, 
																	ORDINAL
																	, serie_del_cheque)
															VALUES(@TICKET, 
																	@FechaPresentacion, 
																	@BANCO_GIRADO, 
																	@SUCURSAL_BANCO, 
																	@NRO_CUENTA, 
																	@IMPORTE_TOTAL, 
																	@CODIGO_POSTAL, 
																	@NRO_DPF_CHEQUE, 
																	@PuntoIntercambio, 
																	@ContadorRegistros, 
																	''C'',  
																	@MONEDA, 
																	@TIPO_DOCUMENTO, 
																	@CodRechazo, 
																	@ORDINAL
																	, (CASE WHEN substring(@infoadicional,2,1) IN (''2'',''3'') THEN ''E'' ELSE '' '' END))
					
PRINT concat(''Moneda-existe-ticket<>0: '',@moneda)
					END
					ELSE
					BEGIN
						-- Insertamos en el historial en caso de que no exista
						SET @moneda=1

						INSERT INTO ITF_COELSA_SESION_RECHAZADOS (ID_TICKET, 
																	FECHA_ALTA, 
																	BANCO, 
																	SUCURSAL, 
																	CUENTA, 
																	IMPORTE, 
																	CODIGO_POSTAL, 
																	NRO_CHEQUE, 
																	PUNTO_INTERCAMBIO, 
																	TRACK_NUMBER, 
																	TIPO, 
																	MONEDA, 
																	TIPO_DOCUMENTO
																	, codigo_rechazo
																	, serie_del_cheque)
						VALUES(@TICKET, 
							@FechaPresentacion, 
							CASE WHEN ISNUMERIC(@Entidad_RI) = 0 THEN -1 ELSE CAST(@Entidad_RI AS NUMERIC(4)) END ,
							CASE WHEN ISNUMERIC(@Sucursal_RI) = 0 THEN -1 ELSE CAST(@Sucursal_RI AS NUMERIC(5)) END, 
							CASE WHEN ISNUMERIC(@NumeroCuenta_RI) = 0 THEN -1 ELSE CAST(@NumeroCuenta_RI AS NUMERIC(12)) END, 
							@Importe, 
							CASE WHEN ISNUMERIC(@CodigoPostal_RI) = 0 THEN -1 ELSE CAST(@CodigoPostal_RI AS NUMERIC(4)) END, 
							CASE WHEN ISNUMERIC(@NumeroCheque_RI) = 0 THEN -1 ELSE CAST(@NumeroCheque_RI AS NUMERIC(12)) END ,
							@PuntoIntercambio, 
							@ContadorRegistros, 
							''C'',
							@moneda, 
							@TIPO_DOCUMENTO
							, @codRechazo
							, (CASE WHEN substring(@infoadicional,2,1) IN (''2'',''3'') THEN ''E'' ELSE '' '' END));

					END
				END			
				ELSE IF (ISNUMERIC(@CuentaDebitar) = 1 AND CAST(@CuentaDebitar AS NUMERIC) = 77777777777)
				BEGIN
					IF(ISNUMERIC(@Entidad_RI) = 1 AND ISNUMERIC(@Sucursal_RI) = 1 AND ISNUMERIC(@CodigoPostal_RI) = 1 AND ISNUMERIC(@NumeroCheque_RI) = 1 AND ISNUMERIC(@NumeroCuenta_RI ) = 1 )
					BEGIN
					 	-- Consulta DPF  			
					 	SELECT @EXISTE = 1, @TIPO_DOCUMENTO = TIPO_DOCUMENTO, @NRO_DPF_CHEQUE = NUMERO_DPF, @BANCO_GIRADO = BANCO_GIRADO, @SUCURSAL_BANCO = SUCURSAL_BANCO_GIRADO, @IMPORTE_TOTAL = IMPORTE, @CODIGO_POSTAL = COD_POSTAL, @MONEDA = MONEDA, @NRO_CUENTA = NUMERICO_CUENTA_GIRADORA
					 	FROM CLE_DPF_SALIENTE WITH(NOLOCK)
					 	WHERE TZ_LOCK = 0 
					 	AND @Entidad_RI = BANCO_GIRADO 
					 	AND @Sucursal_RI  = SUCURSAL_BANCO_GIRADO 
					 	AND @CodigoPostal_RI = COD_POSTAL 
					 	AND @NumeroCheque_RI = NUMERO_DPF 
					 	AND @NumeroCuenta_RI = NUMERICO_CUENTA_GIRADORA;
					END

					IF @EXISTE > 0
				    BEGIN
					 	-- Guardamos clave para update si hay reg adicional
					 	SET @Entidad_RI = @BANCO_GIRADO;
					 	SET @Sucursal_RI = @SUCURSAL_BANCO;
					 	SET @NumeroCuenta_RI = @NRO_CUENTA;
					 	SET @CodigoPostal_RI = @CODIGO_POSTAL;
					 	SET @NumeroCheque_RI = @NRO_DPF_CHEQUE;
							
					 	SET @updRecepcion = ''D''; --para saber si hay que updatear  CLE_RECEPCION_DPF_DEV
						IF (SELECT COUNT(1) 
							FROM CLE_RECEPCION_DPF_DEV
							WHERE NUMERO_DPF = @NumeroCheque_RI 
							AND BANCO_GIRADO = @Entidad_RI 
							AND SUCURSAL_BANCO_GIRADO = @Sucursal_RI
							)>0
						BEGIN
							UPDATE CLE_RECEPCION_DPF_DEV 
							SET CODIGO_RECHAZO = @CodRechazo 
							WHERE NUMERO_DPF = @NumeroCheque_RI 
							AND BANCO_GIRADO = @Entidad_RI 
							AND SUCURSAL_BANCO_GIRADO = @Sucursal_RI
						END
						ELSE
						BEGIN
						 	INSERT INTO CLE_RECEPCION_DPF_DEV(NUMERO_DPF
						 										, BANCO_GIRADO
						 										, FECHA_ALTA
						 										, SUCURSAL_BANCO_GIRADO
						 										, TIPO_DOCUMENTO
						 										, IMPORTE_DPF
						 										, [CODIGO_CAMARA]
						 										, ESTADO_DEVOLUCION)
						 	VALUES (@NRO_DPF_CHEQUE
						 			, @BANCO_GIRADO
						 			, @FechaPresentacion
						 			, @SUCURSAL_BANCO
						 			, @TIPO_DOCUMENTO
						 			, @IMPORTE_TOTAL, 
						 			(SELECT [CODIGO_DE_CAMARA] FROM CLE_CAMARAS_COMPENSADORAS WITH (NOLOCK))
						 			, 1);
						END
				   		-- Insertamos en el historial
				   		INSERT INTO ITF_COELSA_SESION_RECHAZADOS(ID_TICKET
				   												, FECHA_ALTA
				   												, BANCO
				   												, SUCURSAL
				   												, CUENTA
				   												, IMPORTE
				   												, CODIGO_POSTAL
				   												, NRO_CHEQUE
				   												, PUNTO_INTERCAMBIO
				   												, TRACK_NUMBER
				   												, TIPO
				   												, MONEDA
				   												, TIPO_DOCUMENTO
				   												, ORDINAL
				   												, codigo_rechazo)
						VALUES(@TICKET
								, @FechaPresentacion
								, @BANCO_GIRADO
								, @SUCURSAL_BANCO
								, @NRO_CUENTA
								, @IMPORTE_TOTAL
								, @CODIGO_POSTAL
								, @NRO_DPF_CHEQUE
								, @PuntoIntercambio
								, @ContadorRegistros
								, ''C'',  @MONEDA
								, @TIPO_DOCUMENTO
								, @ORDINAL
								, @CodRechazo);

					END
					ELSE
					BEGIN
						SET @moneda=1
						-- Insertamos en el historial en caso de que no exista
						INSERT INTO ITF_COELSA_SESION_RECHAZADOS(ID_TICKET
																, FECHA_ALTA
																, BANCO
																, SUCURSAL
																, CUENTA
																, IMPORTE
																, CODIGO_POSTAL
																, NRO_CHEQUE
																, PUNTO_INTERCAMBIO
																, TRACK_NUMBER
																, TIPO
																, MONEDA
																, TIPO_DOCUMENTO
																, codigo_rechazo
																, serie_del_cheque)
						VALUES(@TICKET
								, @FechaPresentacion
								, CASE WHEN ISNUMERIC(@Entidad_RI) = 0 THEN -1 ELSE CAST(@Entidad_RI AS NUMERIC(4)) END 
								, CASE WHEN ISNUMERIC(@Sucursal_RI) = 0 THEN -1 ELSE CAST(@Sucursal_RI AS NUMERIC(5)) END
								, CASE WHEN ISNUMERIC(@NumeroCuenta_RI) = 0 THEN -1 ELSE CAST(@NumeroCuenta_RI AS NUMERIC(12)) END
								, @Importe
								, CASE WHEN ISNUMERIC(@CodigoPostal_RI) = 0 THEN -1 ELSE CAST(@CodigoPostal_RI AS NUMERIC(4)) END
								, CASE WHEN ISNUMERIC(@NumeroCheque_RI) = 0 THEN -1 ELSE CAST(@NumeroCheque_RI AS NUMERIC(12)) END 
								, @PuntoIntercambio
								, @ContadorRegistros
								, ''C''
								, @moneda
								, @TIPO_DOCUMENTO
								, @codRechazo
								, (CASE WHEN substring(@infoadicional,2,1) IN (''2'',''3'') THEN ''E'' ELSE '' '' END));			
					END
				END      	
				ELSE
				BEGIN

					IF(ISNUMERIC(@Entidad_RI) = 1 AND ISNUMERIC(@Sucursal_RI) = 1 AND ISNUMERIC(@CodigoPostal_RI) = 1 AND ISNUMERIC(@NumeroCheque_RI) = 1 AND ISNUMERIC(@NumeroCuenta_RI ) = 1 )
					BEGIN
						-- Consulta Cheque
						SELECT @EXISTE = 1
								, @NRO_DPF_CHEQUE = NRO_CHEQUE
								, @SERIE_DEL_CHEQUE = SERIE_DEL_CHEQUE
								, @BANCO_GIRADO = BANCO
								, @SUCURSAL_BANCO = SUCURSAL
								, @NRO_CUENTA = CUENTA
								, @TIPO_DOCUMENTO = TIPO_DOCUMENTO
								, @IMPORTE_TOTAL = IMPORTE
								, @CODIGO_POSTAL = CODIGO_POSTAL
								, @MONEDA = MONEDA
						FROM ITF_COELSA_CHEQUES_OTROS WITH(NOLOCK)
						WHERE @Entidad_RI = BANCO 
						AND @Sucursal_RI  = SUCURSAL 
						AND @CodigoPostal_RI = CODIGO_POSTAL 
						AND @NumeroCheque_RI = NRO_CHEQUE 
						AND @NumeroCuenta_RI = CUENTA;
					END

					IF @EXISTE > 0
					BEGIN
						-- Guardamos clave para update si hay reg adicional
						SET @Entidad_RI = @BANCO_GIRADO;
						SET @Sucursal_RI = @SUCURSAL_BANCO;
						SET @NumeroCuenta_RI = @NRO_CUENTA;
						SET @CodigoPostal_RI = @CODIGO_POSTAL;
						SET @NumeroCheque_RI = @NRO_DPF_CHEQUE;
						
						SET @updRecepcion = ''C''; --para saber si updatear el cod Rechazo de la tabla CLE RECEPCION_CHEQUES_DEV


--COMENTADO EL DIA 17/12/2024 PORQUE SE ESTAN INSERTANDO DUPLICADOS LOS REGISTROS EN CLE_RECEPCION_CHEQUES_DEV J.I.

--						INSERT INTO CLE_RECEPCION_CHEQUES_DEV(NUMERO_CHEQUE
--															--, SERIE_DEL_CHEQUE
--															, BANCO_GIRADO
--															, FECHA_ALTA
--															, SUCURSAL_BANCO_GIRADO
--															, NUMERO_CUENTA_GIRADORA
--															, TIPO_DOCUMENTO
--															, IMPORTE_CHEQUE
--															, ESTADO_DEVOLUCION
--															, CODIGO_CAMARA
--															, serie_del_cheque)
--						VALUES (@NRO_DPF_CHEQUE
--								--, @SERIE_DEL_CHEQUE
--								, @BANCO_GIRADO
--								--, @FechaPresentacion
--								, (select fechaproceso from parametros)
--								, @SUCURSAL_BANCO
--								, @NRO_CUENTA
--								, @TIPO_DOCUMENTO
--								, @IMPORTE_TOTAL
--								, 1
--								, (SELECT [CODIGO_DE_CAMARA] FROM CLE_CAMARAS_COMPENSADORAS WITH(NOLOCK))
--								, (CASE WHEN substring(@infoadicional,2,1) IN (''2'',''3'') THEN ''E'' ELSE '' '' END));
								
--HASTA ACA--

						-- Insertamos en el historial
						INSERT INTO ITF_COELSA_SESION_RECHAZADOS(ID_TICKET
																, FECHA_ALTA
																, BANCO
																, SUCURSAL
																, CUENTA
																, IMPORTE
																, CODIGO_POSTAL
																, NRO_CHEQUE
																, PUNTO_INTERCAMBIO
																, TRACK_NUMBER
																, TIPO
																, MONEDA
																, TIPO_DOCUMENTO
																--, SERIE_DEL_CHEQUE
																, Codigo_rechazo
																, serie_del_cheque)
						VALUES(@TICKET
							, @FechaPresentacion
							, @BANCO_GIRADO
							, @SUCURSAL_BANCO
							, @NRO_CUENTA
							, @IMPORTE_TOTAL
							, @CODIGO_POSTAL
							, @NRO_DPF_CHEQUE
							, @PuntoIntercambio
							, @ContadorRegistros
							, ''C''
							, @MONEDA
							, @TIPO_DOCUMENTO
							--, @SERIE_DEL_CHEQUE
							, @codRechazo
							, (CASE WHEN substring(@infoadicional,2,1) IN (''2'',''3'') THEN ''E'' ELSE '' '' END));
					
					
					
					END
					ELSE
					BEGIN
					  
						SET @moneda=1
							-- Insertamos en el historial en caso de que no exista
						INSERT INTO ITF_COELSA_SESION_RECHAZADOS(ID_TICKET
																, FECHA_ALTA
																, BANCO
																, SUCURSAL
																, CUENTA
																, IMPORTE
																, CODIGO_POSTAL
																, NRO_CHEQUE
																, PUNTO_INTERCAMBIO
																, TRACK_NUMBER
																, TIPO
																, MONEDA
																, TIPO_DOCUMENTO
																, codigo_rechazo
																, serie_del_cheque)
						VALUES(@TICKET
--							, @FechaPresentacion
							, (select fechaproceso from parametros)
							, CASE WHEN ISNUMERIC(@Entidad_RI) = 0 THEN -1 ELSE CAST(@Entidad_RI AS NUMERIC(4)) END ,
							CASE WHEN ISNUMERIC(@Sucursal_RI) = 0 THEN -1 ELSE CAST(@Sucursal_RI AS NUMERIC(5)) END, 
							CASE WHEN ISNUMERIC(@NumeroCuenta_RI) = 0 THEN -1 ELSE CAST(@NumeroCuenta_RI AS NUMERIC(12)) END, 
							@Importe, 
							CASE WHEN ISNUMERIC(@CodigoPostal_RI) = 0 THEN -1 ELSE CAST(@CodigoPostal_RI AS NUMERIC(4)) END, 
							CASE WHEN ISNUMERIC(@NumeroCheque_RI) = 0 THEN -1 ELSE CAST(@NumeroCheque_RI AS NUMERIC(12)) END ,
							@PuntoIntercambio, 
							@ContadorRegistros, 
							''C'',
							@moneda, 
							@TIPO_DOCUMENTO
							, @codRechazo
							, (CASE WHEN substring(@infoadicional,2,1) IN (''2'',''3'') THEN ''E'' ELSE '' '' END));
							

					END

				END

		--***Bloque nuevo 13/05/2024 JI***--
				IF (try_convert(numeric,@codRechazo) IS null)
				BEGIN
					PRINT @linea
					PRINT @codRechazo
					SELECT convert(NUMERIC(15,2),substring(@linea,30,10))/100,CAST(substring(@linea,13,17) AS NUMERIC),substring(@linea,40,2)
				END 
		--IF (@linea LIKE ''622%'')
		--BEGIN
		
				SELECT @CODCLI=c1803
						, @PRODUCTO=PRODUCTO
						, @ordinal=ordinal 
				FROM SALDOS 
				WHERE CUENTA = @NumeroCuenta_RI 
				AND SUCURSAL = TRIM(''0'' FROM RIGHT(@EntidadDebitar, 3)) 
				AND MONEDA = @MONEDA 
				AND C1785 = 2
		
		
		
--PRINT @linea

			
				SET @Entidad = CAST(LEFT( CAST(RIGHT(''0000'' + Ltrim(Rtrim(@EntidadDebitar)),8) AS VARCHAR ), 4) AS NUMERIC);
						---inserto en CLE_CHEQUES_CLEARING_RECH_DEV---
		   		BEGIN TRY
				INSERT INTO dbo.CLE_CHEQUES_CLEARING_RECH_DEPOSITARIA
							(
							CLIENTE
							, MONEDA
							, ORDINAL_LISTA
							, PRODUCTO
							, NUMERO_BANCO
							, NUMERO_DEPENDENCIA
							, NUMERO_CHEQUE
							, IMPORTE
							, SERIE_CHEQUE
							, FECHA_VALOR
							, ESTADO
							, CUENTA
							, CAMARA_COMPENSADORA
							, CMC7
							, TRACKNUMBER
							, TZ_LOCK
							, CODIGO_CAUSAL_DEVOLUCION
							)
				VALUES
							(
							@CODCLI
							, @MONEDA
							, @ORDINAL
							, @PRODUCTO
							, @Entidad_RI 
							, @Sucursal_RI
							, @NumeroCheque
--s							, convert(NUMERIC(15,2),substring(@linea,30,10))/100
							,@Importe
							, (CASE WHEN substring(@infoadicional,2,1) IN (''2'',''3'') THEN ''E'' ELSE '' '' END)
--							, @FechaPresentacion
							,(select fechaproceso from parametros)
							, ''0'' 
							, CAST(substring(@linea,13,17) AS NUMERIC)
							, 1
							, (SELECT CONCAT( @Entidad, RIGHT(@EntidadDebitar, 3),RIGHT(@CodigoPostal,4),RIGHT(CONCAT(REPLICATE(''0'',8),RIGHT(@NumeroCheque, 8)),8), RIGHT(CONCAT(''00000000000'',RIGHT(@CuentaDebitar,11)),11) ))         										
							, @ContadorRegistros
							, 0
							, @codRechazo
							)
				END TRY 
			
				BEGIN CATCH
				END CATCH
							---***---
			
-- PRINT @NumeroCheque
				IF (SELECT COUNT(1) 
					FROM CLE_RECEPCION_CHEQUES_DEV 
					WHERE NUMERO_CHEQUE = @NumeroCheque
					  -- AND SERIE_DEL_CHEQUE = @SERIE_DEL_CHEQUE
					  AND BANCO_GIRADO = @Entidad_RI 
					  AND FECHA_ALTA = (SELECT fechaproceso FROM PARAMETROS)--@FechaPresentacion
					  AND SUCURSAL_BANCO_GIRADO = @Sucursal_RI
					  AND NUMERO_CUENTA_GIRADORA = CAST(SUBSTRING(@linea, 13, 17) AS NUMERIC)
				   ) > 0
				BEGIN
					-- PRINT ''existe'' -- REVISAR CLE PREVALENCIA CAUSAL

					-- Obtener el código de rechazo original
					SELECT @codRechazoOri = CODIGO_RECHAZO
					FROM CLE_RECEPCION_CHEQUES_DEV
					WHERE NUMERO_CHEQUE = @NumeroCheque
					  AND SERIE_DEL_CHEQUE = @SERIE_DEL_CHEQUE
					  AND BANCO_GIRADO = @Entidad_RI 
					  AND FECHA_ALTA = (SELECT fechaproceso FROM PARAMETROS)--@FechaPresentacion
					  AND SUCURSAL_BANCO_GIRADO = @Sucursal_RI
					  AND NUMERO_CUENTA_GIRADORA = CAST(SUBSTRING(@linea, 13, 17) AS NUMERIC)
					  AND TIPO_DOCUMENTO = SUBSTRING(@linea, 40, 2);
					
					PRINT @codRechazoOri
					
					-- Determinar el código de rechazo basado en la prevalencia causal
					SELECT @codrechazo = ISNULL(RIGHT(causal_prevaleciente, 2), @codRechazo)
					FROM CLE_PREVALENCIA_CAUSAL 
					WHERE CAUSAL_DEPOSITARIA = @codRechazo 
					  AND CAUSAL_GIRADA = @codRechazoOri 
					  AND TZ_LOCK = 0;

					-- Actualizar el código de rechazo en la tabla de recepción de cheques devueltos
					UPDATE CLE_RECEPCION_CHEQUES_DEV
					SET CODIGO_RECHAZO = TRY_CONVERT(NUMERIC(3), @codRechazo)
					WHERE NUMERO_CHEQUE = @NumeroCheque
					  AND SERIE_DEL_CHEQUE = @SERIE_DEL_CHEQUE
					  AND BANCO_GIRADO = @Entidad_RI
					  AND FECHA_ALTA = @FechaPresentacion
					  AND SUCURSAL_BANCO_GIRADO = @Sucursal_RI
					  AND NUMERO_CUENTA_GIRADORA = CAST(SUBSTRING(@linea, 13, 17) AS NUMERIC)
					  AND TIPO_DOCUMENTO = SUBSTRING(@linea, 40, 2);
				END

				ELSE
				BEGIN
			
--			PRINT @NRO_CUENTA
--PRINT @Entidad_RI
					INSERT INTO dbo.CLE_RECEPCION_CHEQUES_DEV
						(
						BANCO_GIRADO --num 4
						, SUCURSAL_BANCO_GIRADO --num 5
						, SERIE_DEL_CHEQUE --var 6
						, IMPORTE_CHEQUE  --num 15,2
						, CODIGO_RECHAZO --num 3
						, NUMERO_CHEQUE --num 12
						, ESTADO_DEVOLUCION --num 1
						, CODIGO_CAMARA  --num  4
						, TIPO_DOCUMENTO --var
 						, FECHA_ALTA  --date
						, NUMERO_CUENTA_GIRADORA  --num
						, TZ_LOCK
						)
					VALUES
						(
						@Entidad_RI
						, @Sucursal_RI
						, (CASE WHEN substring(@infoadicional,2,1) IN (''2'',''3'') THEN ''E'' ELSE '' '' END)
--s						, convert(NUMERIC(15,2),substring(@linea,30,10))/100
						,@Importe
 						, try_convert(numeric,@codRechazo)
 						, @NumeroCheque
				  		, 1
						, (SELECT TOP 1 CODIGO_DE_CAMARA FROM CLE_CAMARAS_COMPENSADORAS WITH(NOLOCK))
						, substring(@linea,40,2)
-- 						, @FechaPresentacion
						, (select fechaproceso from parametros)
						, CAST(substring(@linea,13,17) AS NUMERIC)
						, 0
						)
				END 
		--END 


			--***FIN***--
		
		
		
		
		
		
		
    -- Insertar en la tabla RRII_CHE_RECHAZADOS
    


				BEGIN TRY
					INSERT INTO dbo.RRII_CHE_RECHAZADOS (COD_ENTIDAD, 
									 NRO_SUCURSAL, 
									 CUENTA, 
									 NRO_CHEQUE, 
									 AVISO, 
									 COD_MOVIMIENTO, 
									 CLASE_REGISTRO, 
									 FECHA_NOTIF_O_DENUNCIA, 
									 MONEDA, 
									 IMPORTE, 
									 FECHA_RECHAZO_O_PRES_COBRO, 
									 FECHA_REGISTRACION, 
									 PLAZO_DIFERIMIENTO, 
									 FECHA_PAGO_CHEQUE, 
									 FECHA_PAGO_MULTA, 
									 FECHA_CIERRE_CTA, 
									 FECHA_REGISTRO_NOVEDAD, 
									 TZ_LOCK)
					SELECT 311, 
						TRIM(''0'' FROM RIGHT(@EntidadDebitar, 3)), 
	   					@NumeroCuenta_RI, 
	   					@NumeroCheque_RI,
	   					CONCAT(@Entidad_RI, @Sucursal_RI), 
						''A'', 
						1
--						, @FechaPresentacion
						, (select fechaproceso from parametros)
						, @MONEDA,  
						@IMPORTE, 
						@FechaPresentacion, 
						(SELECT fechaproceso	FROM PARAMETROS), 
						NULL, 
						NULL, 
						NULL, 
						NULL,  
						(SELECT fechaproceso FROM PARAMETROS), 
						0;
		


		--agregamos los numeros de documento de los titulares y cotitulares		



				-- Crear una tabla temporal para almacenar los valores a actualizar
					CREATE TABLE #TempUpdate (
    							PRIMER_NRO_IDENTIFICATORIO NUMERIC(11, 0),
    							SEGUNDO_NRO_IDENTIFICATORIO NUMERIC(11, 0),
    							TERCER_NRO_IDENTIFICATORIO NUMERIC(11, 0),
    							CUARTO_NRO_IDENTIFICATORIO NUMERIC(11, 0),
    							QUINTO_NRO_IDENTIFICATORIO NUMERIC(11, 0),
    							SEXTO_NRO_IDENTIFICATORIO NUMERIC(11, 0),
    							SEPTIMO_NRO_IDENTIFICATORIO NUMERIC(11, 0),
    							OCTAVO_NRO_IDENTIFICATORIO NUMERIC(11, 0),
    							NOVENO_NRO_IDENTIFICATORIO NUMERIC(11, 0),
    							DECIMO_NRO_IDENTIFICATORIO NUMERIC(11, 0)
								);

					-- Insertar los valores condicionalmente en la tabla temporal
					INSERT INTO #TempUpdate (PRIMER_NRO_IDENTIFICATORIO, SEGUNDO_NRO_IDENTIFICATORIO, TERCER_NRO_IDENTIFICATORIO, CUARTO_NRO_IDENTIFICATORIO, QUINTO_NRO_IDENTIFICATORIO, SEXTO_NRO_IDENTIFICATORIO, SEPTIMO_NRO_IDENTIFICATORIO, OCTAVO_NRO_IDENTIFICATORIO, NOVENO_NRO_IDENTIFICATORIO, DECIMO_NRO_IDENTIFICATORIO)
					SELECT
    					MAX(CASE WHEN RN = 1 THEN CAST(RTRIM([NUMERO DE DOCUMENTO]) AS NUMERIC(11, 0)) END),
    					MAX(CASE WHEN RN = 2 THEN CAST(RTRIM([NUMERO DE DOCUMENTO]) AS NUMERIC(11, 0)) END),
    					MAX(CASE WHEN RN = 3 THEN CAST(RTRIM([NUMERO DE DOCUMENTO]) AS NUMERIC(11, 0)) END),
    					MAX(CASE WHEN RN = 4 THEN CAST(RTRIM([NUMERO DE DOCUMENTO]) AS NUMERIC(11, 0)) END),
    					MAX(CASE WHEN RN = 5 THEN CAST(RTRIM([NUMERO DE DOCUMENTO]) AS NUMERIC(11, 0)) END),
    					MAX(CASE WHEN RN = 6 THEN CAST(RTRIM([NUMERO DE DOCUMENTO]) AS NUMERIC(11, 0)) END),
    					MAX(CASE WHEN RN = 7 THEN CAST(RTRIM([NUMERO DE DOCUMENTO]) AS NUMERIC(11, 0)) END),
    					MAX(CASE WHEN RN = 8 THEN CAST(RTRIM([NUMERO DE DOCUMENTO]) AS NUMERIC(11, 0)) END),
    					MAX(CASE WHEN RN = 9 THEN CAST(RTRIM([NUMERO DE DOCUMENTO]) AS NUMERIC(11, 0)) END),
    					MAX(CASE WHEN RN = 10 THEN CAST(RTRIM([NUMERO DE DOCUMENTO]) AS NUMERIC(11, 0)) END)
					FROM (
    					SELECT
        						[Codigo de Cliente],
        						[Numero de Documento],
        						[Titularidad],
        						ROW_NUMBER() OVER (PARTITION BY [Codigo de Cliente] ORDER BY CASE WHEN [Titularidad] = ''T'' THEN 0 ELSE 1 END, [Numero de Documento]) AS RN
    					FROM VW_CLI_PERSONAS
    					WHERE [Codigo de Cliente] = (
													SELECT c1803 
													FROM SALDOS 
													WHERE CUENTA = @NumeroCuenta_RI 
													AND SUCURSAL = TRIM(''0'' FROM RIGHT(@EntidadDebitar, 3)) 
													AND MONEDA = @MONEDA 
													AND C1785 = 2
    												) 
							) Subquery;

					-- Realizar la actualización utilizando la tabla temporal
					UPDATE RRII_CHE_RECHAZADOS
					SET
    					PRIMER_NRO_IDENTIFICATORIO = #TempUpdate.PRIMER_NRO_IDENTIFICATORIO,
    					SEGUNDO_NRO_IDENTIFICATORIO = #TempUpdate.SEGUNDO_NRO_IDENTIFICATORIO,
    					TERCER_NRO_IDENTIFICATORIO = #TempUpdate.TERCER_NRO_IDENTIFICATORIO,
    					CUARTO_NRO_IDENTIFICATORIO = #TempUpdate.CUARTO_NRO_IDENTIFICATORIO,
    					QUINTO_NRO_IDENTIFICATORIO = #TempUpdate.QUINTO_NRO_IDENTIFICATORIO,
    					SEXTO_NRO_IDENTIFICATORIO = #TempUpdate.SEXTO_NRO_IDENTIFICATORIO,
    					SEPTIMO_NRO_IDENTIFICATORIO = #TempUpdate.SEPTIMO_NRO_IDENTIFICATORIO,
    					OCTAVO_NRO_IDENTIFICATORIO = #TempUpdate.OCTAVO_NRO_IDENTIFICATORIO,
    					NOVENO_NRO_IDENTIFICATORIO = #TempUpdate.NOVENO_NRO_IDENTIFICATORIO,
    					DECIMO_NRO_IDENTIFICATORIO = #TempUpdate.DECIMO_NRO_IDENTIFICATORIO
					FROM #TempUpdate
					WHERE cod_entidad = 311
    				AND Nro_sucursal = TRIM(''0'' FROM RIGHT(@EntidadDebitar, 3))
    				AND cuenta = @NumeroCuenta_RI
    				AND nro_cheque = @NumeroCheque_RI
    				AND fecha_registro_novedad = (SELECT fechaproceso FROM PARAMETROS);

					-- Eliminar la tabla temporal
					DROP TABLE #TempUpdate;


				END	TRY
				BEGIN CATCH
	PRINT ''No se pudo insertar en tabla RRII_CHE_RECHAZADOS''
				END CATCH	
			END
		END --end RI id = 6
		FETCH NEXT FROM che_cursor INTO @id,@LINEA
	END

	CLOSE che_cursor
	DEALLOCATE che_cursor

	--- Actualizar el estado de los ajustes no incluidos en el plano -------------------------------------------------------------
	UPDATE dbo.CLE_CHEQUES_AJUSTE 
	SET ESTADO_AJUSTE = ''A'' 
	WHERE ESTADO_AJUSTE IS NULL 
	AND ESTADO = ''P'' 
	AND FECHA_ACREDITACION = (SELECT FECHAPROCESO FROM PARAMETROS WITH(NOLOCK));
------------------------------------------------------------------------------------------------------------------------------

END')

