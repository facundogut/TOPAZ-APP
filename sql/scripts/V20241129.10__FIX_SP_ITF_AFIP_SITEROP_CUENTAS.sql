create or ALTER      PROCEDURE [dbo].[SP_ITF_AFIP_SITEROP_CUENTAS]
   @P_FECHA  DATE
AS

BEGIN

	BEGIN TRY  
	
	
	------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--- Created : 
	--- Autor: Miguel Angel Martinez Acosta 
	--- Se crea el sp con el fin de generar el informe de operaciones y cuentas mensual para su envio a AFIP.
	------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
	------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
   	----Variables Cabecera Archivo ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	DECLARE @CA_TIPO_REG VARCHAR(2) = '01';
	DECLARE @CA_CUIT_INFORMANTE VARCHAR(11) = FORMAT(CONVERT(NUMERIC,(SELECT NOMBRE2 FROM PARAMETROS)), '00000000000');;
	DECLARE @CA_PERIODO_INFORMADO VARCHAR(6) = CAST(YEAR(@P_FECHA) AS CHAR(4)) + RIGHT('0' + CAST(MONTH(@P_FECHA) AS VARCHAR(2)), 2);
	DECLARE @CA_SECUENCIA VARCHAR(2) = (SELECT RIGHT(concat('0',isnull(MAX(SECUENCIA),-1)+1),2) FROM ITF_AFIP_SITEROP_HIST (nolock) hist
																		WHERE TIPO_REGISTRO = '01' 
																	   		AND LEFT(convert(VARCHAR(10), @P_FECHA, 112), 6) = hist.PERIODO_INFORMADO);
	DECLARE @CA_CODIGO_ENTIDAD_FINANCIERA VARCHAR(5) = FORMAT((SELECT NUMERICO FROM PARAMETROSGENERALES WHERE CODIGO = 2), '00000');
	DECLARE @CA_CODIGO_IMPUESTO VARCHAR(4) = '0103'; 
	DECLARE @CA_CODIGO_CONCEPTO VARCHAR(3) = '911';
	DECLARE @CA_NUMERO_FORMULARIO VARCHAR(4) = '0943';
	DECLARE @CA_FILLER VARCHAR(212) = REPLICATE(' ', 212);
	DECLARE @CA_VERSION VARCHAR(5) = '00200';
    DECLARE @CA_PRES_SIN_MOVIMIENTO VARCHAR(1) = '0';
    DECLARE @CA_CABECERA VARCHAR(255);
    DECLARE @CA_NOMBRE_FICHERO VARCHAR(32);
    
    --- Variables registro Detalle de la Cuenta (Reg. Tipo 02) ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	DECLARE @R02_TIPO_REGISTRO VARCHAR(2) = '02'; 
   	DECLARE @R02_TIPO_CUENTA VARCHAR(2);
   	DECLARE @R02_NUMERO_CUENTA VARCHAR(22);
    DECLARE @R02_CBU VARCHAR(22); 	
	DECLARE @R02_TIPO_MONEDA VARCHAR(3);
	DECLARE @R02_SUCURSAL VARCHAR(5);
	DECLARE @R02_TIPO_DOCUMENTO VARCHAR(2);
	DECLARE @R02_NUMERO_DOCUMENTO VARCHAR(11);
	DECLARE @R02_CODIGOCAJA_VALORES_SA VARCHAR(5);
	DECLARE @R02_CARACTER VARCHAR(2);
	DECLARE @R02_CANT_INTEGRANTES VARCHAR(2);
	DECLARE @R02_CANT_INTEGRANTES_NUM NUMERIC(2,0);
	DECLARE @R02_CANT_TARJDEBITO_ADICIONALES VARCHAR(2);
	DECLARE @R02_TOTAL_ACREDITACIONES VARCHAR(18);
	DECLARE @R02_ACRED_TRANSF_CUENTAS_TITULAR VARCHAR(18);
	DECLARE @R02_ACRED_PREST_ENTIDAD_FINANCIERA VARCHAR(18);
	DECLARE @R02_ACRED_PREST_ENTIDAD_FINANCIERA_NUM NUMERIC;
	DECLARE @R02_ACRED_VENC_PLAZO_FIJO VARCHAR(18);
	DECLARE @R02_TOTAL_EXTRAC_PAIS_EXTERIOR VARCHAR(18);
	DECLARE @R02_SIGNO_SALDO VARCHAR(1);
	DECLARE @R02_SALDO VARCHAR(18);
	DECLARE @R02_SIGCONSUMO_TARJDEBITO_PAIS VARCHAR(1);
	DECLARE @R02_CONSUMO_TARJDEBITO_PAIS VARCHAR(18);
	DECLARE @R02_SIGCONSUMO_TARJDEBITO_EXTERIOR VARCHAR(1);
	DECLARE @R02_CONSUMO_TARJDEBITO_EXTERIOR VARCHAR(18);
	DECLARE @R02_TIPO_MOVIMIENTO VARCHAR(1) = 'A';
	DECLARE @R02_FECHA_MOVIMIENTO VARCHAR(8);
	DECLARE @R02_CODCLIENTE VARCHAR(12);
	DECLARE @R02_JTS_OID NUMERIC(10,0);
	DECLARE @R02_LINEA VARCHAR(255);
	DECLARE @R02_TIPO_DOCUMENTO_ORIG VARCHAR(4);
	DECLARE @R02_NUM_DOCUMENTO_ORIG VARCHAR(20);
	DECLARE @R02_TIPO_PERSONA_ORIG VARCHAR(1);
	DECLARE @R02_NUM_PERSONA_ORIG NUMERIC(12,0);
	DECLARE @R02_C1651 VARCHAR(1);
	
	
		
	--- Variables registro Detalle de los integrantes (Reg. Tipo 03) ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	DECLARE @R03_TIPO_REGISTRO VARCHAR(2) = '03'; 
   	DECLARE @R03_TIPO_DOCUMENTO VARCHAR(2);
   	DECLARE @R03_NUMERO_DOCUMENTO VARCHAR(11);
    DECLARE @R03_CARACTER VARCHAR(2);
    DECLARE @R03_LINEA VARCHAR(255);   
    	
	
    
    -- Variables generales y auxiliares--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
    DECLARE @CANT_MOVIMIENTOS_CUENTAS NUMERIC; 
    DECLARE @R02_SUMA_ACRED_PESOS NUMERIC(15,2);
    DECLARE @R02_SUMA_ACRED_EXTR NUMERIC(15,2);
    DECLARE @FECHA_PROCESO DATETIME = (SELECT FECHAPROCESO FROM PARAMETROS (NOLOCK));
    DECLARE @P_TOTAL_ACREDITACIONES NUMERIC(15,2) = (SELECT importe FROM PARAMETROSGENERALES WHERE CODIGO=772);
     
    --- Seteo Secuencia ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--    IF(@P_RECTIFICATIVA = 'S')      
	--	       SET @CA_SECUENCIA = (SELECT CASE WHEN max(secuencia) IS NULL OR max(secuencia) = '99' THEN '00' ELSE LEFT(concat('0',max(secuencia)+1),2) END FROM ITF_AFIP_SITEROP_HIST (nolock) WHERE TIPO_REGISTRO = '01');  	

    ---Seteo nombre fichero------------------------------------------------------------------------------------------------
    SET @CA_NOMBRE_FICHERO = 'F0943.'+ @CA_CUIT_INFORMANTE + '.' + @CA_PERIODO_INFORMADO + '00.' + '00'+ @CA_SECUENCIA;
        
    --- Limpiar Tabla auxiliar ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	TRUNCATE TABLE ITF_AFIP_SITEROP_AUX; 	
	
	--- Verifico si hay movimientos cuentas para el periodo -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	SELECT @CANT_MOVIMIENTOS_CUENTAS  = count(*) FROM SALDOS s WITH (NOLOCK) 
    INNER JOIN MOVIMIENTOS_CONTABLES mc WITH (NOLOCK)
      ON s.JTS_OID = mc.SALDO_JTS_OID
    WHERE (CAST(YEAR(mc.FECHAPROCESO) AS CHAR(4)) + 
       RIGHT('0' + CAST(MONTH(mc.FECHAPROCESO) AS VARCHAR(2)), 2)) = @CA_PERIODO_INFORMADO  
       AND s.C1785 NOT IN(0,4) 
       AND s.TZ_LOCK = 0
	
	IF(@CANT_MOVIMIENTOS_CUENTAS = 0)
	    SET @CA_PRES_SIN_MOVIMIENTO = '1';	    

	SET @CA_CABECERA = concat(@CA_TIPO_REG,@CA_CUIT_INFORMANTE,@CA_PERIODO_INFORMADO,@CA_SECUENCIA,@CA_CODIGO_ENTIDAD_FINANCIERA,@CA_CODIGO_IMPUESTO,@CA_CODIGO_CONCEPTO,@CA_NUMERO_FORMULARIO,@CA_FILLER,@CA_VERSION,@CA_PRES_SIN_MOVIMIENTO);

	--- Grabamos la cabecera del archivo Reg(01) ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	INSERT INTO ITF_AFIP_SITEROP_AUX(TIPO_REGISTRO,LINEA,SECUENCIA,NOMBRE_FICHERO)
	VALUES (@CA_TIPO_REG,@CA_CABECERA,@CA_SECUENCIA,@CA_NOMBRE_FICHERO);
	
	--Grabo en historial:
	INSERT INTO ITF_AFIP_SITEROP_HIST(	TIPO_REGISTRO, CUIT_INFORMANTE 	, PERIODO_INFORMADO	, SECUENCIA 	, CODIGO_ENTIDAD_FINANCIERA   	, CODIGO_IMPUESTO 	, CODIGO_CONCEPTO , NUMERO_FORMULARIO 	, VERSION 	, PRESENTACION_SIN_MOVIMIENTO, FECHA_PROCESO )
      VALUES (@CA_TIPO_REG,@CA_CUIT_INFORMANTE,@CA_PERIODO_INFORMADO,@CA_SECUENCIA,@CA_CODIGO_ENTIDAD_FINANCIERA,@CA_CODIGO_IMPUESTO,@CA_CODIGO_CONCEPTO,@CA_NUMERO_FORMULARIO,@CA_VERSION,@CA_PRES_SIN_MOVIMIENTO,@FECHA_PROCESO)	

	
	DECLARE cursor_cuentas CURSOR FOR
	SELECT       
           REPLACE((CONVERT(VARCHAR(2),(CAST((SELECT NUM2 FROM  rri_parametros_inf WHERE CODIGO = 512 AND ID1 = s.PRODUCTO AND ID2 = s.C1785) AS VARCHAR(10))))),'.','') AS Tipo_Cuenta,
           FORMAT(s.cuenta,'0000000000000000000000') AS Nro_Cuenta,
           FORMAT(CONVERT(NUMERIC(22),vta.CTA_CBU),'0000000000000000000000') AS CBU,
           (CASE WHEN m.C6399 IN(988,999) THEN 'ARS'
             ELSE m.C6402
           END) AS Tipo_Moneda,
           FORMAT(s.SUCURSAL,'00000') AS Codigo_Sucursal,
           (CASE WHEN doc.TIPODOCUMENTO = 'CUIT' THEN '80'
              WHEN doc.TIPODOCUMENTO = 'CUIL' THEN '86'
              WHEN doc.TIPODOCUMENTO = 'CDI'  THEN '87'
              WHEN doc.TIPOPERSONA = 'J' AND pj.TIPOSOCIEDAD = 66 THEN '66'
              WHEN doc.TIPOPERSONA = 'J' AND pj.TIPOSOCIEDAD = 29 THEN '55'           
           END) AS Tipo_Documento,
           FORMAT(CONVERT(NUMERIC,doc.NUMERODOCUMENTO),'00000000000')  AS Numero_Documento,
           '00000' AS Codigo_Caja_Valores_SA,
           '01'  AS Caracter,           
           '01' AS Cantidad_Tarjetas_Debito_Adicionales,--duda,no dice nada en el dise�o              
           '000000000000000000' AS Total_extracciones_pais_exterior,--duda,pendiente dise�o
           '1' AS Signo_Saldo,--duda,pendiente dise�o
           '000000000000000000' AS Saldo,--duda,pendiente dise�o
           '1'   AS Signo_Consumo_Tarjetas_debito_pais,--duda,pendiente dise�o
           '000000000000000000'   AS Consumos_Tarjetas_debito_pais,--duda,pendiente dise�o
           '1'   AS Signo_Consumo_Tarjetas_debito_exterior,--duda,pendiente dise�o
           '000000000000000000' AS Consumos_Tarjetas_debito_exterior,--duda,pendiente dise�o           
            cli.CODIGOCLIENTE,
            s.JTS_OID,
            doc.TIPODOCUMENTO AS TIPODOCUMENTO_ORIG,
            doc.NUMERODOCUMENTO AS NUMERODOCUMENTO_ORIG,
            doc.TIPOPERSONA AS TIPOPERSONA_ORIG,
            doc.NUMEROPERSONAFJ AS NUMPERSONA_ORIG,
            s.C1651 
     FROM SALDOS s WITH (NOLOCK)            
     INNER JOIN VTA_SALDOS vta WITH (NOLOCK)
       ON s.JTS_OID = vta.JTS_OID_SALDO
       AND vta.TZ_LOCK = 0
     INNER JOIN MONEDAS m WITH (NOLOCK)
       ON s.MONEDA = m.C6399
       AND m.TZ_LOCK = 0
     INNER JOIN CLI_CLIENTES cli WITH (NOLOCK) 
     ON s.C1803 = cli.CODIGOCLIENTE
       AND cli.TZ_LOCK = 0 
     INNER JOIN CLI_ClientePersona cp WITH (NOLOCK)
       ON cli.CODIGOCLIENTE = cp.CODIGOCLIENTE
       AND cp.TZ_LOCK = 0 
     INNER JOIN CLI_DocumentosPFPJ doc WITH (NOLOCK)
       ON cp.NUMEROPERSONA = doc.NUMEROPERSONAFJ
       AND doc.TZ_LOCK = 0
     LEFT JOIN CLI_PERSONASJURIDICAS pj WITH (NOLOCK)
       ON doc.NUMEROPERSONAFJ = pj.NUMEROPERSONAJURIDICA
       AND pj.TZ_LOCK = 0     
     WHERE EXISTS (SELECT * FROM MOVIMIENTOS_CONTABLES mc 
                   WHERE (CAST(YEAR(mc.FECHAPROCESO) AS CHAR(4)) + RIGHT('0' + CAST(MONTH(mc.FECHAPROCESO) AS VARCHAR(2)), 2)) = @CA_PERIODO_INFORMADO 
                   AND mc.SALDO_JTS_OID = s.JTS_OID
                   )       
           AND s.C1785 IN(2,3)
           AND cp.TITULARIDAD = 'T'
           AND s.TZ_LOCK = 0
           
     

	OPEN cursor_cuentas

	FETCH NEXT FROM cursor_cuentas INTO @R02_TIPO_CUENTA, 
   	                                    @R02_NUMERO_CUENTA, 
                                        @R02_CBU,  	
	                                    @R02_TIPO_MONEDA, 
	                                    @R02_SUCURSAL, 
	                                    @R02_TIPO_DOCUMENTO, 
	                                    @R02_NUMERO_DOCUMENTO, 
	                                    @R02_CODIGOCAJA_VALORES_SA, 
	                                    @R02_CARACTER,	                                     
	                                    @R02_CANT_TARJDEBITO_ADICIONALES,	                                                                        
                                        @R02_TOTAL_EXTRAC_PAIS_EXTERIOR, 
                                        @R02_SIGNO_SALDO, 
	                                    @R02_SALDO, 
	                                    @R02_SIGCONSUMO_TARJDEBITO_PAIS, 
                                        @R02_CONSUMO_TARJDEBITO_PAIS, 
	                                    @R02_SIGCONSUMO_TARJDEBITO_EXTERIOR, 
	                                    @R02_CONSUMO_TARJDEBITO_EXTERIOR,                               
	                                    @R02_CODCLIENTE,
	                                    @R02_JTS_OID,
	                                    @R02_TIPO_DOCUMENTO_ORIG,
	                                    @R02_NUM_DOCUMENTO_ORIG,
	                                    @R02_TIPO_PERSONA_ORIG,
	                                    @R02_NUM_PERSONA_ORIG,
	                                    @R02_C1651 
	                                                             

	WHILE @@FETCH_STATUS = 0
	BEGIN
	   
	   
	    --- Calculo campo Total Acreditaciones ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------   
	    SELECT @R02_SUMA_ACRED_PESOS = COALESCE(SUM(mc.CAPITALREALIZADO),0) 
        FROM MOVIMIENTOS_CONTABLES mc WITH (NOLOCK)        
        WHERE (CAST(YEAR(mc.FECHAPROCESO) AS CHAR(4)) + RIGHT('0' + CAST(MONTH(mc.FECHAPROCESO) AS VARCHAR(2)), 2)) = @CA_PERIODO_INFORMADO
         AND mc.DEBITOCREDITO = 'C' 
         AND mc.CUENTA = CONVERT(NUMERIC(12),@R02_NUMERO_CUENTA)
         AND mc.SUCURSAL = CONVERT(NUMERIC(5),@R02_SUCURSAL)
         AND mc.MONEDA = 1 
         
         
        SELECT @R02_SUMA_ACRED_EXTR = COALESCE(SUM(mc.EQUIVALENTEMN),0) 
        FROM MOVIMIENTOS_CONTABLES mc WITH (NOLOCK)        
        WHERE (CAST(YEAR(mc.FECHAPROCESO) AS CHAR(4)) + RIGHT('0' + CAST(MONTH(mc.FECHAPROCESO) AS VARCHAR(2)), 2)) = @CA_PERIODO_INFORMADO
         AND mc.DEBITOCREDITO = 'C' 
         AND mc.CUENTA = CONVERT(NUMERIC(12),@R02_NUMERO_CUENTA)
         AND mc.SUCURSAL = CONVERT(NUMERIC(5),@R02_SUCURSAL)
         AND mc.MONEDA <> 1   
	    
	 
	    SET @R02_TOTAL_ACREDITACIONES = RIGHT(concat(replicate('0',18), CAST(CAST((@R02_SUMA_ACRED_PESOS + @R02_SUMA_ACRED_EXTR)*100 AS BIGINT) AS VARCHAR(18))),18);
	   
	    
	
	    --- Calculo campo Tipo Movimiento ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        IF EXISTS(SELECT * FROM BITACORA_CLIENTES WHERE CODIGOBLOQUEO = 'B' AND CODIGOCLIENTE = @R02_CODCLIENTE AND TZ_LOCK = 0 AND MONTH(FECHA) = MONTH(@FECHA_PROCESO) AND YEAR(FECHA) = YEAR(@FECHA_PROCESO) )
             SET @R02_TIPO_MOVIMIENTO = 'B'
        ELSE IF (EXISTS(SELECT * FROM BITACORA_CLIENTPERSONA WHERE CODIGOCLIENTE = @R02_CODCLIENTE AND TZ_LOCK = 0 AND MONTH(FECHA) = MONTH(@FECHA_PROCESO) AND YEAR(FECHA) = YEAR(@FECHA_PROCESO) ) OR 
                 EXISTS(SELECT * FROM  BITACORA_APODERADOS WHERE ID_CLIENTE_SALDO = @R02_CODCLIENTE AND TZ_LOCK = 0  AND MONTH(FECHA) = MONTH(@FECHA_PROCESO) AND YEAR(FECHA) = YEAR(@FECHA_PROCESO) )
                 ) 
             SET @R02_TIPO_MOVIMIENTO = 'N'
        ELSE IF (@R02_C1651 = 1)
            SET @R02_TIPO_MOVIMIENTO = 'C'

        --- Calculo campo Cantidad Integrantes--------------------------------------------------
        SET @R02_CANT_INTEGRANTES_NUM = isnull((SELECT count(CODIGOCLIENTE) FROM CLI_ClientePersona WITH (NOLOCK) 
                                         WHERE TITULARIDAD <> 'T'
                                         AND CODIGOCLIENTE = @R02_CODCLIENTE      
                                         GROUP BY CODIGOCLIENTE
                                         ),0)
        
        --Calculo campo Acreditaciones_Prestamos_Entidad_Financiera------------------------------------------------
        SET @R02_ACRED_PREST_ENTIDAD_FINANCIERA_NUM = (SELECT count(*) FROM MOVIMIENTOS_CONTABLES WITH (NOLOCK)  
                                                       WHERE COD_TRANSACCION IN(3002,3008) 
                                                       AND DEBITOCREDITO = 'C'
                                                       AND SALDO_JTS_OID = @R02_JTS_OID
                                                       )
                                                   
        
       --Calculo campo Acreditaciones por vencimiento Plazo Fijo---------------------------------------------------
       SET @R02_ACRED_VENC_PLAZO_FIJO = FORMAT((SELECT COALESCE(SUM(CAPITALREALIZADO),0) FROM MOVIMIENTOS_CONTABLES
                                          WHERE OPERACION IN(8620, 2513, 2517, 5399)
                                          AND DEBITOCREDITO = 'C'
                                          AND SALDO_JTS_OID = @R02_JTS_OID
                                          ),'000000000000000000')    
        
        
        ---Calculo campo Fecha Movimiento----------------------------------------------------------------------------
        SET @R02_FECHA_MOVIMIENTO = (SELECT CONVERT(VARCHAR(8),MAX(FECHAPROCESO),112) FROM MOVIMIENTOS_CONTABLES WITH (NOLOCK)
									                                     WHERE SALDO_JTS_OID = @R02_JTS_OID
									                                      AND (CAST(YEAR(FECHAPROCESO) AS CHAR(4)) + RIGHT('0' + CAST(MONTH(FECHAPROCESO) AS VARCHAR(2)), 2)) = @CA_PERIODO_INFORMADO
									                                    )
          
        
        
        --Acreditaciones por Transferencias entre cuentas del mismo titular-------------------------------------------
       SET @R02_ACRED_TRANSF_CUENTAS_TITULAR = 
																					right(concat(replicate('0',18),isnull((
																					SELECT CAST(CASE 
																									WHEN MC.MONEDA = 1 THEN SUM(MC.CAPITALREALIZADO) 
																							 		ELSE SUM(MC.CAPITALREALIZADO)*isnull((SELECT TOP 1 TC_VENTA FROM CON_COTIZACIONES_BNA (nolock) cot 
																							 																				WHERE cot.Moneda = MC.MONEDA 
																							 																					AND cot.TZ_LOCK = 0
																							 																					AND YEAR(cot.Fecha_Cotizacion) = YEAR(@P_FECHA) 
																							 																					AND MONTH(cot.Fecha_Cotizacion) = MONTH(@P_FECHA)  
																							 																						ORDER BY cot.Fecha_Cotizacion DESC ),1) END  *100 AS BIGINT) capRealizado
																								  		FROM MOVIMIENTOS_CONTABLES (nolock) MC 	
																							WHERE MC.OPERACION IN (SELECT I.ID1 FROM RRI_PARAMETROS_DEF D (NOLOCK) 
																																					JOIN RRI_PARAMETROS_INF I (NOLOCK) ON D.CODIGO = I.CODIGO 
																																								WHERE D.CODIGO = 517) 
																								AND MC.DEBITOCREDITO = 'D'
																								AND YEAR(MC.FECHAPROCESO) = YEAR(@P_FECHA) 
																								AND MONTH(MC.FECHAPROCESO) = MONTH(@P_FECHA) 																							
																						AND EXISTS (
																						SELECT 1 FROM VW_CUENTAS_CLIENTES (nolock) CC 
																							JOIN CLI_ClientePersona (nolock) CP ON CC.NRO_CLIENTE = CP.CODIGOCLIENTE
																								WHERE CC.NRO_CLIENTE = @R02_CODCLIENTE
																									AND CP.TITULARIDAD = 'T'
																							  		AND MC.CLIENTE = CC.NRO_CLIENTE 
																									AND CC.CUENTA = MC.CUENTA
																									AND CP.TZ_LOCK = 0
																						)
																					GROUP BY MC.MONEDA
																					),0)),18);


        
   /*     SET @R02_ACRED_TRANSF_CUENTAS_TITULAR = FORMAT((SELECT SUM(CAPITALREALIZADO) FROM MOVIMIENTOS_CONTABLES mc
                                                        INNER JOIN ASIENTOS a 
                                                          ON a.ASIENTO = mc.ASIENTO
                                                          AND a.FECHAPROCESO = mc.FECHAPROCESO
                                                          AND a.OPERACION = mc.OPERACION
                                                          AND a.ESTADO = 77
                                                        WHERE mc.OPERACION IN(3502)
                                                        AND mc.DEBITOCREDITO = 'C'
                                                        AND mc.CLIENTE = @R02_CODCLIENTE
                                                        AND (CAST(YEAR(mc.FECHAPROCESO) AS CHAR(4)) + RIGHT('0' + CAST(MONTH(mc.FECHAPROCESO) AS VARCHAR(2)), 2)) = @CA_PERIODO_INFORMADO 
                                                        AND EXISTS (SELECT 1 FROM MOVIMIENTOS_CONTABLES m 
                                                                    WHERE mc.FECHAPROCESO = m.FECHAPROCESO
                                                                    AND mc.ASIENTO = m.ASIENTO
                                                                    AND mc.OPERACION = m.OPERACION
                                                                    AND mc.CLIENTE = m.CLIENTE
                                                                    AND mc.CUENTA <> m.CLIENTE
                                                                    AND mc.DEBITOCREDITO = 'D'
                                                                    )
                                                        ),'000000000000000000') 
        */
        
        
        
        ---Grabamos registro Detalle de la Cuenta (Reg. Tipo 02) ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        --formateo datos-----------
        SET @R02_CANT_INTEGRANTES = FORMAT(@R02_CANT_INTEGRANTES_NUM,'00');
        SET @R02_ACRED_PREST_ENTIDAD_FINANCIERA = FORMAT(@R02_ACRED_PREST_ENTIDAD_FINANCIERA_NUM,'000000000000000000'); 
        SET @R02_TIPO_CUENTA = RIGHT(REPLICATE('0', 2) + @R02_TIPO_CUENTA, 2);     
        
        IF(@CA_PRES_SIN_MOVIMIENTO = '0' AND ((@R02_SUMA_ACRED_PESOS + @R02_SUMA_ACRED_EXTR) >= @P_TOTAL_ACREDITACIONES))          
          BEGIN
          
              ------------- --------------- --------------- --------------- --------------- ----------------------           
              SET @R02_LINEA = concat(@R02_TIPO_REGISTRO,@R02_TIPO_CUENTA,@R02_NUMERO_CUENTA,@R02_CBU,@R02_TIPO_MONEDA,@R02_SUCURSAL,@R02_TIPO_DOCUMENTO,@R02_NUMERO_DOCUMENTO,@R02_CODIGOCAJA_VALORES_SA, 
	                                  @R02_CARACTER,@R02_CANT_INTEGRANTES,@R02_CANT_TARJDEBITO_ADICIONALES,@R02_TOTAL_ACREDITACIONES, @R02_ACRED_TRANSF_CUENTAS_TITULAR,@R02_ACRED_PREST_ENTIDAD_FINANCIERA, 
                                      @R02_ACRED_VENC_PLAZO_FIJO,@R02_TOTAL_EXTRAC_PAIS_EXTERIOR,@R02_SIGNO_SALDO,@R02_SALDO,@R02_SIGCONSUMO_TARJDEBITO_PAIS,@R02_CONSUMO_TARJDEBITO_PAIS, 
	                                  @R02_SIGCONSUMO_TARJDEBITO_EXTERIOR,@R02_CONSUMO_TARJDEBITO_EXTERIOR,@R02_TIPO_MOVIMIENTO,@R02_FECHA_MOVIMIENTO);
	                                   
	          INSERT INTO ITF_AFIP_SITEROP_AUX(TIPO_REGISTRO,LINEA,SECUENCIA,NOMBRE_FICHERO,TIPO_DOCUMENTO,NUMERO_DOCUMENTO,TIPO_PERSONA,NUMERO_PERSONA)
	          VALUES (@R02_TIPO_REGISTRO,@R02_LINEA,'','',@R02_TIPO_DOCUMENTO_ORIG,@R02_NUM_DOCUMENTO_ORIG,@R02_TIPO_PERSONA_ORIG,@R02_NUM_PERSONA_ORIG);
	          
	          
	          --Grabamos tabla historica reg tipo 02---
	          INSERT INTO ITF_AFIP_SITEROP_HIST(TIPO_REGISTRO,PERIODO_INFORMADO,SECUENCIA,TIPO_CUENTA ,NUMERO_CUENTA 	,CBU ,TIPO_MONEDA ,SUCURSAL ,TIPO_DOCUMENTO ,NUMERO_DOCUMENTO ,CODIGO_CAJA_VALORES_SA ,CARACTER 	,CANTIDAD_INTEGRANTES ,CANT_TDD_ADICIONALES	,TOTAL_ACREDITACIONES 	
	          ,ACRED_TRANSF_MISMO_TIT 	,ACRED_PRESTAMO_ENT_FINANCIERA 	,ACRED_VTO_PLAZO_FIJO 	,TOT_EXTRACCIONES ,SIGNO_SALDO 	,SALDO 	,SIGNO_CONSUMO_TDD_PAIS ,CONSUMO_TDD_PAIS ,SIGNO_CONSUMO_TDD_EXT 	,CONSUMO_TDD_EXT ,TIPO_MOVIMIENTO ,FECHA_MOVIMIENTO,FECHA_PROCESO)
	          VALUES(@R02_TIPO_REGISTRO,@CA_PERIODO_INFORMADO,@CA_SECUENCIA,@R02_TIPO_CUENTA,@R02_NUMERO_CUENTA,@R02_CBU,@R02_TIPO_MONEDA,@R02_SUCURSAL,@R02_TIPO_DOCUMENTO,@R02_NUMERO_DOCUMENTO,@R02_CODIGOCAJA_VALORES_SA, 
	                                  @R02_CARACTER,@R02_CANT_INTEGRANTES,
	                                  @R02_CANT_TARJDEBITO_ADICIONALES,
	                                  @R02_TOTAL_ACREDITACIONES, 
	                                  @R02_ACRED_TRANSF_CUENTAS_TITULAR,
	                                  @R02_ACRED_PREST_ENTIDAD_FINANCIERA, 
                                      @R02_ACRED_VENC_PLAZO_FIJO,
                                      @R02_TOTAL_EXTRAC_PAIS_EXTERIOR,
                                      @R02_SIGNO_SALDO,@R02_SALDO,@R02_SIGCONSUMO_TARJDEBITO_PAIS,@R02_CONSUMO_TARJDEBITO_PAIS, 
	                                  @R02_SIGCONSUMO_TARJDEBITO_EXTERIOR,@R02_CONSUMO_TARJDEBITO_EXTERIOR,@R02_TIPO_MOVIMIENTO,@R02_FECHA_MOVIMIENTO,@FECHA_PROCESO)
	          
	          -- Cargo integrantes de la cuenta que no son titulares Reg(03) 
             INSERT INTO ITF_AFIP_SITEROP_AUX(TIPO_REGISTRO,LINEA,SECUENCIA,NOMBRE_FICHERO,TIPO_DOCUMENTO,NUMERO_DOCUMENTO,TIPO_PERSONA,NUMERO_PERSONA) 
             SELECT DISTINCT @R03_TIPO_REGISTRO,
                    CONCAT(@R03_TIPO_REGISTRO,(CASE WHEN doc.TIPODOCUMENTO = 'CUIT' THEN '80'
                                 WHEN doc.TIPODOCUMENTO = 'CUIL' THEN '86'
                                 WHEN doc.TIPODOCUMENTO = 'CDI'  THEN '87'
                                 WHEN doc.TIPOPERSONA = 'J' AND pj.TIPOSOCIEDAD = 66 THEN '66'
                                 WHEN doc.TIPOPERSONA = 'J' AND pj.TIPOSOCIEDAD = 29 THEN '55'           
                            END
                           ),
                           FORMAT(CONVERT(NUMERIC,doc.NUMERODOCUMENTO),'00000000000'), ---Ver de donde se toma el dato(CLI_DOCUMENTOS_PERSONAS o CLI_DocumentosPFPJ)
                           (CASE WHEN doc.TIPOPERSONA = 'F' THEN '02' 
                                 WHEN doc.TIPOPERSONA = 'J' THEN FORMAT((SELECT NUM1 FROM  rri_parametros_inf WHERE CODIGO = 513 AND ID4 = ipj.CODIGOCARGO AND TZ_LOCK = 0),'00')                       
                            END
                           )
                          ),
                      '',
                      '',
                      doc.TIPODOCUMENTO,
                      doc.NUMERODOCUMENTO,
                      doc.TIPOPERSONA,
                      doc.NUMEROPERSONAFJ                           
             FROM SALDOS s WITH (NOLOCK)
             INNER JOIN CLI_CLIENTES cli WITH (NOLOCK) 
               ON s.C1803 = cli.CODIGOCLIENTE
               AND cli.TZ_LOCK = 0
             INNER JOIN CLI_ClientePersona cp WITH (NOLOCK)
               ON cli.CODIGOCLIENTE = cp.CODIGOCLIENTE
               AND cp.TZ_LOCK = 0 
             INNER JOIN CLI_DocumentosPFPJ doc WITH (NOLOCK)
               ON cp.NUMEROPERSONA = doc.NUMEROPERSONAFJ
               AND doc.TZ_LOCK = 0
             LEFT JOIN CLI_PERSONASJURIDICAS pj WITH (NOLOCK)
               ON doc.NUMEROPERSONAFJ = pj.NUMEROPERSONAJURIDICA
               AND pj.TZ_LOCK = 0             
             LEFT JOIN CLI_INTEGRANTESPJ ipj WITH (NOLOCK)
               ON cp.NUMEROPERSONA = ipj.NUMEROPERSONAJURIDICA
               AND ipj.TZ_LOCK = 0    
             WHERE s.CUENTA = CONVERT(NUMERIC(12),@R02_NUMERO_CUENTA)
              AND cp.TITULARIDAD <> 'T' 
              AND s.TZ_LOCK = 0                   
              
              
              --SETEO VARIABLES TIPO 03 PARA GRABAR
              
               --Grabamos tabla historica reg tipo 03---
	          INSERT INTO ITF_AFIP_SITEROP_HIST(TIPO_REGISTRO,PERIODO_INFORMADO,SECUENCIA,TIPO_DOCUMENTO,NUMERO_DOCUMENTO,CARACTER,FECHA_PROCESO)
					          
				SELECT DISTINCT 
				@R03_TIPO_REGISTRO,
				@CA_PERIODO_INFORMADO,
				@CA_SECUENCIA,
				CASE WHEN doc.TIPODOCUMENTO = 'CUIT' THEN '80'
				     WHEN doc.TIPODOCUMENTO = 'CUIL' THEN '86'
				     WHEN doc.TIPODOCUMENTO = 'CDI'  THEN '87'
				     WHEN doc.TIPOPERSONA = 'J' AND pj.TIPOSOCIEDAD = 66 THEN '66'
				     WHEN doc.TIPOPERSONA = 'J' AND pj.TIPOSOCIEDAD = 29 THEN '55'           
				END ,
				FORMAT(CONVERT(NUMERIC,doc.NUMERODOCUMENTO),'00000000000') ,
				
				CASE WHEN doc.TIPOPERSONA = 'F' THEN '02' 
				     WHEN doc.TIPOPERSONA = 'J' THEN FORMAT((SELECT NUM1 FROM  rri_parametros_inf WHERE CODIGO = 513 AND ID4 = ipj.CODIGOCARGO AND TZ_LOCK = 0),'00')                       
				END,
				@FECHA_PROCESO                     
				 FROM SALDOS s WITH (NOLOCK)
					 INNER JOIN CLI_CLIENTES cli WITH (NOLOCK) 
					   ON s.C1803 = cli.CODIGOCLIENTE
					   AND cli.TZ_LOCK = 0
					 INNER JOIN CLI_ClientePersona cp WITH (NOLOCK)
					   ON cli.CODIGOCLIENTE = cp.CODIGOCLIENTE
					   AND cp.TZ_LOCK = 0 
					 INNER JOIN CLI_DocumentosPFPJ doc WITH (NOLOCK)
					   ON cp.NUMEROPERSONA = doc.NUMEROPERSONAFJ
					   AND doc.TZ_LOCK = 0
					 LEFT JOIN CLI_PERSONASJURIDICAS pj WITH (NOLOCK)
					   ON doc.NUMEROPERSONAFJ = pj.NUMEROPERSONAJURIDICA
					   AND pj.TZ_LOCK = 0             
					 LEFT JOIN CLI_INTEGRANTESPJ ipj WITH (NOLOCK)
					   ON cp.NUMEROPERSONA = ipj.NUMEROPERSONAJURIDICA
					   AND ipj.TZ_LOCK = 0    
					WHERE s.CUENTA = CONVERT(NUMERIC(12),@R02_NUMERO_CUENTA)
					  AND cp.TITULARIDAD <> 'T' 
					  AND s.TZ_LOCK = 0         
				  
	                                 
          END
          
          
        
        	
		
	    FETCH NEXT FROM cursor_cuentas INTO @R02_TIPO_CUENTA, 
   	                                        @R02_NUMERO_CUENTA, 
                                            @R02_CBU,  	
	                                        @R02_TIPO_MONEDA, 
	                                        @R02_SUCURSAL, 
	                                        @R02_TIPO_DOCUMENTO, 
	                                        @R02_NUMERO_DOCUMENTO, 
	                                        @R02_CODIGOCAJA_VALORES_SA, 
	                                        @R02_CARACTER,	                                         
	                                        @R02_CANT_TARJDEBITO_ADICIONALES,	                                                        
                                            @R02_TOTAL_EXTRAC_PAIS_EXTERIOR, 
                                            @R02_SIGNO_SALDO, 
	                                        @R02_SALDO, 
	                                        @R02_SIGCONSUMO_TARJDEBITO_PAIS, 
                                            @R02_CONSUMO_TARJDEBITO_PAIS, 
	                                        @R02_SIGCONSUMO_TARJDEBITO_EXTERIOR, 
	                                        @R02_CONSUMO_TARJDEBITO_EXTERIOR,                    
	                                        @R02_CODCLIENTE,
	                                        @R02_JTS_OID,
	                                        @R02_TIPO_DOCUMENTO_ORIG,
	                                        @R02_NUM_DOCUMENTO_ORIG,
	                                        @R02_TIPO_PERSONA_ORIG,
	                                        @R02_NUM_PERSONA_ORIG,
	                                        @R02_C1651 
	
	END --Fin del cursor Curso Cuentas

	CLOSE cursor_cuentas
	DEALLOCATE cursor_cuentas    

	END TRY

	BEGIN CATCH  
    	SELECT ERROR_NUMBER() AS ErrorNumber  
       		, ERROR_MESSAGE() AS ErrorMessage
       		, ERROR_LINE() AS ErrorLine;  
	END CATCH

END;
GO

