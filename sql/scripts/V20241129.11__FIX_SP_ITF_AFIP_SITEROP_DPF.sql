create or ALTER      PROCEDURE [dbo].[SP_ITF_AFIP_SITEROP_DPF]
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
    --- Variables registro Detalle productos DPF (Reg. Tipo 04) ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	DECLARE @CA_SECUENCIA VARCHAR(2) = (SELECT RIGHT(concat('0',MAX(SECUENCIA)),2) FROM ITF_AFIP_SITEROP_HIST (nolock) hist
																		WHERE TIPO_REGISTRO = '01' 
																	   		AND LEFT(convert(VARCHAR(10), @P_FECHA, 112), 6) = hist.PERIODO_INFORMADO);
	DECLARE @R04_TIPO_REGISTRO VARCHAR(2) = '04'; 
   	DECLARE @R04_TIPO_OPERACION VARCHAR(2);
   	DECLARE @R04_NUMERO_OPERACION VARCHAR(22);
    DECLARE @R04_SUCURSAL VARCHAR(5);
    DECLARE @R04_FECHA_CONSTITUCION VARCHAR(8); 
   	DECLARE @R04_BENEFICIARIO_EXTERIOR VARCHAR(1);
   	DECLARE @R04_FECHA_VENCIMIENTO VARCHAR(8);
    DECLARE @R04_TIPO_DOCUMENTO VARCHAR(2);
    DECLARE @R04_NUMERO_DOCUMENTO VARCHAR(20); 
   	DECLARE @R04_CARACTER VARCHAR(2) = '01'; 
   	DECLARE @R04_CANT_INTEGRANTES VARCHAR(2);
   	DECLARE @R04_CANT_INTEGRANTES_NUM NUMERIC(2,0);
    DECLARE @R04_CODCAJA_VALORES_SA VARCHAR(5);
    DECLARE @R04_MONTO_CONSTITUCION_PESOS VARCHAR(18);
    DECLARE @R04_MONTO_CONSTITUCION_PESOS_NUM NUMERIC(15,2); 
   	DECLARE @R04_MONTO_INTERES_PESOS VARCHAR(18);
   	DECLARE @R04_MONTO_INTERES_PESOS_NUM NUMERIC(15,2);
   	DECLARE @R04_MONTO_CONSTITUCION_MON_ORIGINAL VARCHAR(18);
    DECLARE @R04_MONTO_INTERES_MON_ORIGINAL VARCHAR(18);    
   	DECLARE @R04_TIPO_MONEDA VARCHAR(3); 
	DECLARE @R04_TIPO_MOVIMIENTO VARCHAR(1);
	DECLARE @R04_FECHA_MOVIMIENTO VARCHAR(8);	
	DECLARE @R04_COD_CLIENTE NUMERIC(12);
	DECLARE @R04_TIPO_PERSONA VARCHAR(1);
	DECLARE @R04_LINEA VARCHAR(255);
	DECLARE @R04_C1600 NUMERIC(15,2);
	DECLARE @R04_C1608 NUMERIC(15,2);
	DECLARE @R04_MONEDA NUMERIC(4,0);
   	DECLARE @R04_TIPO_DOCUMENTO_ORIG VARCHAR(4);
	DECLARE @R04_NUM_DOCUMENTO_ORIG VARCHAR(20);
	DECLARE @R04_NUMPERSONA_ORIG NUMERIC(12,0);
	DECLARE @R04_C1728 VARCHAR(1);
	DECLARE @R04_C1734 VARCHAR(1); 
    DECLARE @R04_JTS_OID NUMERIC(10,0); 
	
	-- Variables registro Detalle integrantes DPF (Reg. Tipo 05) ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	DECLARE @R05_TIPO_REGISTRO VARCHAR(2) = '05'; 
   	DECLARE @R05_TIPO_DOCUMENTO VARCHAR(2);
   	DECLARE @R05_NUMERO_DOCUMENTO VARCHAR(11);
    DECLARE @R05_BENEFICIARIO_EXTERIOR VARCHAR(1);
    DECLARE @R05_CARACTER VARCHAR(2);
    DECLARE @FECHA_PROCESO DATETIME = (SELECT FECHAPROCESO FROM PARAMETROS);
    
    ---Variables generales----
    DECLARE @CA_PERIODO_INFORMADO VARCHAR(6) = CAST(YEAR(@P_FECHA) AS CHAR(4)) + RIGHT('0' + CAST(MONTH(@P_FECHA) AS VARCHAR(2)), 2); 
    DECLARE @P_TOTAL_ACREDITACIONES NUMERIC(15,2) = (SELECT importe FROM PARAMETROSGENERALES WHERE CODIGO=772);  
    
    --Cursor detalle productos dpf----------------------------------------------------------------------------------------------------------
    DECLARE cursor_productos_dpf CURSOR FOR
    SELECT FORMAT((SELECT NUM1 FROM rri_parametros_inf WHERE CODIGO = 514
            AND ID1 = s.PRODUCTO AND ID2 = s.TIPO_DPF AND TZ_LOCK = 0),'00') as Tipo_Operacion,
           FORMAT(CONVERT(NUMERIC,CONCAT(s.OPERACION,s.ORDINAL)),'0000000000000000000000') AS Numero_Operacion,---duda
           FORMAT(s.SUCURSAL,'00000') as Codigo_Sucursal,--duda,ver si puede ser la del saldo
           CONVERT(VARCHAR(8),s.C1620,112)  as  Fecha_Constitucion,
           '2' AS Beneficiario_Exterior,--duda
           CONVERT(VARCHAR(8),s.C1627,112) AS Fecha_Vencimiento,
           (CASE WHEN doc.TIPODOCUMENTO = 'CUIT' THEN '80'
                 WHEN doc.TIPODOCUMENTO = 'CUIL' THEN '86'
                 WHEN doc.TIPODOCUMENTO = 'CDI'  THEN '87'
                 WHEN doc.TIPOPERSONA = 'J' AND pj.TIPOSOCIEDAD = 66 THEN '66'
                 WHEN doc.TIPOPERSONA = 'J' AND pj.TIPOSOCIEDAD = 29 THEN '55'           
           END) AS Tipo_Documento,
           FORMAT(CONVERT(NUMERIC,doc.NUMERODOCUMENTO),'00000000000') AS Num_documento,
           '01' AS Caracter,           
           '00001' AS Cod_caja_valores_SA,---duda,no definido dise�o
           s.C1600 AS C1600,--(Monto de Constitucion en Pesos),la logica la hago fuera del cursor
           s.C1608 AS C1608,--(Monto de interes en pesos),la logica la hago fuera del cursor
           FORMAT(s.C1600,'000000000000000000') AS Monto_constitucion_moneda_original,
           FORMAT(s.C1608,'000000000000000000') AS Monto_interes_moneda_original,
           (CASE WHEN s.MONEDA IN(998,999) THEN 'ARS'
                 ELSE (SELECT C6402 FROM MONEDAS WHERE C6399 = s.MONEDA AND TZ_LOCK = 0)                             
           END) AS Tipo_moneda,           
           CONVERT(VARCHAR(8),s.C1621,112) AS Fecha_valor,
           s.C1803 AS Cod_Cliente,
           doc.TIPOPERSONA,
           s.MONEDA,
           cp.NUMEROPERSONA,
           doc.TIPODOCUMENTO,
           doc.NUMERODOCUMENTO,
           s.C1728,
           s.C1734,
           s.JTS_OID                  
    FROM SALDOS s  WITH (NOLOCK)           
    INNER JOIN CLI_CLIENTES cli  WITH (NOLOCK)
      ON s.C1803 = cli.CODIGOCLIENTE
      AND cli.TZ_LOCK = 0 
    INNER JOIN CLI_ClientePersona cp  WITH (NOLOCK)
      ON cli.CODIGOCLIENTE = cp.CODIGOCLIENTE 
      AND cp.TZ_LOCK = 0
    INNER JOIN CLI_DocumentosPFPJ doc  WITH (NOLOCK)
      ON cp.NUMEROPERSONA = doc.NUMEROPERSONAFJ
      AND doc.TZ_LOCK = 0
    LEFT JOIN CLI_PERSONASJURIDICAS pj  WITH (NOLOCK)
      ON doc.NUMEROPERSONAFJ = pj.NUMEROPERSONAJURIDICA 
      AND pj.TZ_LOCK = 0  
    WHERE s.C1785 = 4
      AND EXISTS (SELECT * FROM MOVIMIENTOS_CONTABLES mc 
                  WHERE (CAST(YEAR(mc.FECHAPROCESO) AS CHAR(4)) + RIGHT('0' + CAST(MONTH(mc.FECHAPROCESO) AS VARCHAR(2)), 2)) = @CA_PERIODO_INFORMADO 
                  AND mc.SALDO_JTS_OID = s.JTS_OID
                  )                 
      AND s.TZ_LOCK = 0 
      AND cp.TITULARIDAD = 'T'
    
    OPEN cursor_productos_dpf

	FETCH NEXT FROM cursor_productos_dpf INTO  @R04_TIPO_OPERACION,
	                                           @R04_NUMERO_OPERACION, 
                                               @R04_SUCURSAL, 
                                               @R04_FECHA_CONSTITUCION,  
   	                                           @R04_BENEFICIARIO_EXTERIOR, 
   	                                           @R04_FECHA_VENCIMIENTO, 
                                               @R04_TIPO_DOCUMENTO, 
                                               @R04_NUMERO_DOCUMENTO,  
   	                                           @R04_CARACTER,  
   	                                           @R04_CODCAJA_VALORES_SA, 
                                               @R04_C1600,  
   	                                           @R04_C1608, 
   	                                           @R04_MONTO_CONSTITUCION_MON_ORIGINAL, 
                                               @R04_MONTO_INTERES_MON_ORIGINAL, 	                                           
	                                           @R04_TIPO_MONEDA,	                                           
	                                           @R04_FECHA_MOVIMIENTO,
	                                           @R04_COD_CLIENTE,
	                                           @R04_TIPO_PERSONA,
	                                           @R04_MONEDA,
	                                           @R04_NUMPERSONA_ORIG,
	                                           @R04_TIPO_DOCUMENTO_ORIG, 
	                                           @R04_NUM_DOCUMENTO_ORIG,
	                                           @R04_C1728,
	                                           @R04_C1734,
	                                           @R04_JTS_OID 
	                                           
     

	WHILE @@FETCH_STATUS = 0
	BEGIN      
        
        ---Calculo campo Monto de Constitucion en Pesos------------------------------------------------------------------------------------------
        
        IF @R04_MONEDA = 1 
            SET @R04_MONTO_CONSTITUCION_PESOS_NUM  = @R04_C1600     
        ELSE IF @R04_MONEDA = 2 
            SET @R04_MONTO_CONSTITUCION_PESOS_NUM  = @R04_C1600 *(SELECT TC_VENTA FROM CON_COTIZACIONES_BNA WITH (NOLOCK) 
                                                                  WHERE Moneda = 2 
                                                                  AND Fecha_Cotizacion = CONVERT(datetime, dbo.diaHabil(EOMONTH(@P_FECHA), 'D'))
                                                                  AND TZ_LOCK = 0
                                                                  )  
        ELSE IF @R04_MONEDA = 5 
            SET @R04_MONTO_CONSTITUCION_PESOS_NUM  = @R04_C1600 *(SELECT TC_VENTA FROM CON_COTIZACIONES_BNA  WITH (NOLOCK)
                                                                  WHERE Moneda = 5 
                                                                  AND Fecha_Cotizacion = CONVERT(datetime, dbo.diaHabil(EOMONTH(@P_FECHA), 'D'))
                                                                  AND TZ_LOCK = 0)  
        ELSE IF @R04_MONEDA = 6 
            SET @R04_MONTO_CONSTITUCION_PESOS_NUM  = @R04_C1600 *(SELECT TC_VENTA FROM CON_COTIZACIONES_BNA  WITH (NOLOCK) 
                                                                  WHERE Moneda = 6 
                                                                  AND Fecha_Cotizacion = CONVERT(datetime, dbo.diaHabil(EOMONTH(@P_FECHA), 'D'))
                                                                  AND TZ_LOCK = 0
                                                                  )  
        ELSE IF @R04_MONEDA = 988 
            SET @R04_MONTO_CONSTITUCION_PESOS_NUM  = @R04_C1600 *(SELECT TC_VENTA FROM CON_COTIZACIONES_BNA  WITH (NOLOCK) 
                                                                   WHERE Moneda = 988 
                                                                   AND Fecha_Cotizacion = CONVERT(datetime, dbo.diaHabil(EOMONTH(@P_FECHA), 'D'))
                                                                   AND TZ_LOCK = 0
                                                                  )  
        ELSE IF @R04_MONEDA = 999 
            SET @R04_MONTO_CONSTITUCION_PESOS_NUM  = @R04_C1600 *(SELECT TC_VENTA 
                                                                  FROM CON_COTIZACIONES_BNA  WITH (NOLOCK) 
                                                                  WHERE Moneda = 999 
                                                                  AND Fecha_Cotizacion = CONVERT(datetime, dbo.diaHabil(EOMONTH(@P_FECHA), 'D'))
                                                                  AND TZ_LOCK = 0
                                                                  )
        
        ---Calculo campo Monto de interes en pesos-----------------------------------------------------------------------------------------------
        
        IF @R04_MONEDA = 1 
            SET @R04_MONTO_INTERES_PESOS_NUM = @R04_C1608     
        ELSE IF @R04_MONEDA = 2 
            SET @R04_MONTO_INTERES_PESOS_NUM = @R04_C1608 *(SELECT TC_VENTA FROM CON_COTIZACIONES_BNA WITH (NOLOCK) 
                                                             WHERE Moneda = 2 
                                                             AND Fecha_Cotizacion = CONVERT(datetime, dbo.diaHabil(EOMONTH(@P_FECHA), 'D'))
                                                             AND TZ_LOCK = 0)  
        ELSE IF @R04_MONEDA = 5 
            SET @R04_MONTO_INTERES_PESOS_NUM = @R04_C1608 *(SELECT TC_VENTA FROM CON_COTIZACIONES_BNA WITH (NOLOCK)
                                                              WHERE Moneda = 5 
                                                              AND Fecha_Cotizacion = CONVERT(datetime, dbo.diaHabil(EOMONTH(@P_FECHA), 'D'))
                                                              AND TZ_LOCK = 0)  
        ELSE IF @R04_MONEDA = 6 
            SET @R04_MONTO_INTERES_PESOS_NUM = @R04_C1608 *(SELECT TC_VENTA FROM CON_COTIZACIONES_BNA WITH (NOLOCK) 
                                                             WHERE Moneda = 6 
                                                             AND Fecha_Cotizacion = CONVERT(datetime, dbo.diaHabil(EOMONTH(@P_FECHA), 'D'))
                                                             AND TZ_LOCK = 0
                                                             )  
        ELSE IF @R04_MONEDA = 988 
            SET @R04_MONTO_INTERES_PESOS_NUM = @R04_C1608 *(SELECT TC_VENTA FROM CON_COTIZACIONES_BNA WITH (NOLOCK) 
                                                             WHERE Moneda = 988 
                                                             AND Fecha_Cotizacion = CONVERT(datetime, dbo.diaHabil(EOMONTH(@P_FECHA), 'D'))
                                                             AND TZ_LOCK = 0
                                                             )  
        ELSE IF @R04_MONEDA = 999 
            SET @R04_MONTO_INTERES_PESOS_NUM = @R04_C1608 *(SELECT TC_VENTA 
                                                             FROM CON_COTIZACIONES_BNA WITH (NOLOCK) 
                                                             WHERE Moneda = 999 
                                                             AND Fecha_Cotizacion = CONVERT(datetime, dbo.diaHabil(EOMONTH(@P_FECHA), 'D'))
                                                             AND TZ_LOCK = 0)
        
        ---Calculo Cant_integrantes-----------------------------------------------
        
        IF @R04_TIPO_PERSONA = 'F' 
            BEGIN
               SET @R04_CANT_INTEGRANTES_NUM = (SELECT COUNT(CODIGOCLIENTE) FROM CLI_ClientePersona WITH (NOLOCK) 
                                                WHERE TITULARIDAD <> 'T'
                                                AND CODIGOCLIENTE = @R04_COD_CLIENTE 
                                                AND TZ_LOCK = 0 
                                                GROUP BY CODIGOCLIENTE
                                                )
            END
        ELSE IF @R04_TIPO_PERSONA = 'J' 
           BEGIN
               SET @R04_CANT_INTEGRANTES_NUM = (SELECT COUNT(NUMEROPERSONAFISICA) FROM CLI_INTEGRANTESPJ WITH (NOLOCK) 
                                                WHERE NUMEROPERSONAJURIDICA = @R04_NUMPERSONA_ORIG 
                                                AND TZ_LOCK = 0
                                                GROUP BY NUMEROPERSONAJURIDICA
                                                )
           END
        
        
        ---------Tipo_movimiento--------------------------------------------------------------------------------------------------
        IF (@R04_C1728 = 'I' AND @R04_C1734 = 'I')
           SET @R04_TIPO_MOVIMIENTO = 'I';
        ELSE IF (@R04_C1728 = 'V' AND @R04_C1734 = 'I')
           SET @R04_TIPO_MOVIMIENTO = 'X';
        ELSE IF (EXISTS(SELECT * FROM BS_HISTORIA_PLAZO bs
                        WHERE bs.TIPOMOV = 'A'
                        AND (CAST(YEAR(bs.FECHAPROCESOMOV) AS CHAR(4)) + RIGHT('0' + CAST(MONTH(bs.FECHAPROCESOMOV) AS VARCHAR(2)), 2)) = @CA_PERIODO_INFORMADO
                        AND bs.SALDOS_JTS_OID = @R04_JTS_OID
                        ))
                             
             SET @R04_TIPO_MOVIMIENTO = 'A';
        
        
        
        
        ---Grabamos registro Detalle de productos DPF(Reg.Tipo 04) ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        ---formateo campos--
        SET @R04_MONTO_CONSTITUCION_PESOS = FORMAT(@R04_MONTO_CONSTITUCION_PESOS_NUM,'000000000000000000');  
        SET @R04_MONTO_INTERES_PESOS = FORMAT(@R04_MONTO_INTERES_PESOS_NUM,'000000000000000000');
        SET @R04_CANT_INTEGRANTES = FORMAT(@R04_CANT_INTEGRANTES_NUM,'00');
        
        SET @R04_LINEA = CONCAT(@R04_TIPO_REGISTRO, @R04_TIPO_OPERACION, @R04_NUMERO_OPERACION, @R04_SUCURSAL, @R04_FECHA_CONSTITUCION, @R04_BENEFICIARIO_EXTERIOR, 
   	                            @R04_FECHA_VENCIMIENTO, @R04_TIPO_DOCUMENTO, @R04_NUMERO_DOCUMENTO, @R04_CARACTER, @R04_CANT_INTEGRANTES,@R04_CODCAJA_VALORES_SA, 
                                @R04_MONTO_CONSTITUCION_PESOS, @R04_MONTO_INTERES_PESOS, @R04_MONTO_CONSTITUCION_MON_ORIGINAL, @R04_MONTO_INTERES_MON_ORIGINAL,     
   	                            @R04_TIPO_MONEDA,@R04_TIPO_MOVIMIENTO, @R04_FECHA_MOVIMIENTO)
   	                            
   	                          
        IF(@R04_MONTO_CONSTITUCION_PESOS_NUM >=@P_TOTAL_ACREDITACIONES)
         BEGIN
           INSERT INTO ITF_AFIP_SITEROP_AUX(TIPO_REGISTRO,LINEA,SECUENCIA,NOMBRE_FICHERO,TIPO_DOCUMENTO,NUMERO_DOCUMENTO,TIPO_PERSONA,NUMERO_PERSONA)
           VALUES(@R04_TIPO_REGISTRO,@R04_LINEA,'','',@R04_TIPO_DOCUMENTO,@R04_NUMERO_DOCUMENTO,@R04_TIPO_PERSONA,@R04_NUMPERSONA_ORIG);        
       
         
         --Grabamos en historial registros tipo 04
         INSERT INTO ITF_AFIP_SITEROP_HIST (TIPO_REGISTRO, PERIODO_INFORMADO,SECUENCIA,TIPO_OPERACION 	,NUMERO_OPERACION 	,SUCURSAL ,FECHA_CONSTITUCION 	,BENEF_EXTERIOR 	,FECHA_VTO 	,TIPO_DOCUMENTO ,NUMERO_DOCUMENTO ,CARACTER	
         ,CANTIDAD_INTEGRANTES 	,CODIGO_CAJA_VALORES_SA	,MONTO_CONSTITUCION_PESOS 	,MONTO_INTERES_PESOS 	,MONTO_CONST_MONEDA_OG 	,MONTO_INTERES_MONEDA_OG 	,TIPO_MONEDA     ,TIPO_MOVIMIENTO 	,FECHA_MOVIMIENTO ,FECHA_PROCESO )
        VALUES (@R04_TIPO_REGISTRO, @CA_PERIODO_INFORMADO,@CA_SECUENCIA,@R04_TIPO_OPERACION, @R04_NUMERO_OPERACION, @R04_SUCURSAL, @R04_FECHA_CONSTITUCION, @R04_BENEFICIARIO_EXTERIOR, 
   	                            @R04_FECHA_VENCIMIENTO, @R04_TIPO_DOCUMENTO, @R04_NUMERO_DOCUMENTO, @R04_CARACTER, @R04_CANT_INTEGRANTES,@R04_CODCAJA_VALORES_SA, 
                                @R04_MONTO_CONSTITUCION_PESOS, @R04_MONTO_INTERES_PESOS, @R04_MONTO_CONSTITUCION_MON_ORIGINAL, @R04_MONTO_INTERES_MON_ORIGINAL,     
   	                            @R04_TIPO_MONEDA,@R04_TIPO_MOVIMIENTO, @R04_FECHA_MOVIMIENTO,@FECHA_PROCESO)
         

           -- Grabamos integrantes DPF que no son titulares Reg(05) 
           INSERT INTO ITF_AFIP_SITEROP_AUX(TIPO_REGISTRO,LINEA,SECUENCIA,NOMBRE_FICHERO,TIPO_DOCUMENTO,NUMERO_DOCUMENTO,TIPO_PERSONA,NUMERO_PERSONA)         
           SELECT @R05_TIPO_REGISTRO,
                  CONCAT(@R05_TIPO_REGISTRO,
                         (CASE WHEN doc.TIPODOCUMENTO = 'CUIT' THEN '80'
			                 WHEN doc.TIPODOCUMENTO = 'CUIL' THEN '86'
			                 WHEN doc.TIPODOCUMENTO = 'CDI'  THEN '87'
			                 ELSE '99'  END) ,
                         FORMAT(CONVERT(NUMERIC,doc.NUMERODOCUMENTO),'00000000000'),
                         '1', 
                         (CASE WHEN doc.TIPOPERSONA = 'F' THEN '02' 
                               WHEN doc.TIPOPERSONA = 'J' THEN FORMAT((SELECT NUM1 FROM  rri_parametros_inf WHERE CODIGO = 513 AND ID4 = ipj.CODIGOCARGO AND TZ_LOCK = 0),'00')                      
                          END)),
                         '',
                         '',
                          (CASE WHEN doc.TIPODOCUMENTO = 'CUIT' THEN '80'
			                 WHEN doc.TIPODOCUMENTO = 'CUIL' THEN '86'
			                 WHEN doc.TIPODOCUMENTO = 'CDI'  THEN '87'
			                 ELSE '99'  END) ,
	                     doc.NUMERODOCUMENTO,
                         doc.TIPOPERSONA,
                         doc.NUMEROPERSONAFJ                       
           FROM CLI_CLIENTES cli WITH (NOLOCK)
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
           WHERE 
          cli.CODIGOCLIENTE = @R04_COD_CLIENTE  AND 
           cp.TITULARIDAD <>'T'
             AND cli.TZ_LOCK = 0; 
                         
             
         
         --Inserto en historial registros tipo 05
            INSERT INTO ITF_AFIP_SITEROP_HIST (TIPO_REGISTRO,PERIODO_INFORMADO,SECUENCIA,TIPO_DOCUMENTO	,NUMERO_DOCUMENTO	,BENEF_EXTERIOR   	,CARACTER ,FECHA_PROCESO )     
            SELECT DISTINCT 
            	@R05_TIPO_REGISTRO,
            	@CA_PERIODO_INFORMADO,
            	@CA_SECUENCIA,
            	 (CASE WHEN doc.TIPODOCUMENTO = 'CUIT' THEN '80'
                 WHEN doc.TIPODOCUMENTO = 'CUIL' THEN '86'
                 WHEN doc.TIPODOCUMENTO = 'CDI'  THEN '87'
                 ELSE '99' END) AS Tipo_Documento,
                 FORMAT(CONVERT(NUMERIC,doc.NUMERODOCUMENTO),'00000000000'),
                 '1', 
                 CASE WHEN doc.TIPOPERSONA = 'F' THEN '02' 
                       WHEN doc.TIPOPERSONA = 'J' THEN FORMAT((SELECT NUM1 FROM  rri_parametros_inf WHERE CODIGO = 513 AND ID4 = ipj.CODIGOCARGO AND TZ_LOCK = 0),'00')                      
                  END,
                  @FECHA_PROCESO       
           FROM CLI_CLIENTES cli WITH (NOLOCK)
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
           WHERE 
           cli.CODIGOCLIENTE = @R04_COD_CLIENTE  AND            
           cp.TITULARIDAD <>'T'
             AND cli.TZ_LOCK = 0; 
             
         END             
          	
		
	    FETCH NEXT FROM cursor_productos_dpf INTO @R04_TIPO_OPERACION,
	                                              @R04_NUMERO_OPERACION, 
                                                  @R04_SUCURSAL, 
                                                  @R04_FECHA_CONSTITUCION,  
   	                                              @R04_BENEFICIARIO_EXTERIOR, 
   	                                              @R04_FECHA_VENCIMIENTO, 
                                                  @R04_TIPO_DOCUMENTO, 
                                                  @R04_NUMERO_DOCUMENTO,  
   	                                              @R04_CARACTER,  
   	                                              @R04_CODCAJA_VALORES_SA, 
                                                  @R04_C1600,  
   	                                              @R04_C1608, 
   	                                              @R04_MONTO_CONSTITUCION_MON_ORIGINAL, 
                                                  @R04_MONTO_INTERES_MON_ORIGINAL, 	                                           
	                                              @R04_TIPO_MONEDA,	                                              
	                                              @R04_FECHA_MOVIMIENTO,
	                                              @R04_COD_CLIENTE,
	                                              @R04_TIPO_PERSONA,
	                                              @R04_MONEDA,
	                                              @R04_NUMPERSONA_ORIG,
	                                              @R04_TIPO_DOCUMENTO_ORIG, 
	                                              @R04_NUM_DOCUMENTO_ORIG,
	                                              @R04_C1728,
	                                              @R04_C1734,
	                                              @R04_JTS_OID   
                                            
	
	END --Fin del cursor Curso productos DPF

	CLOSE cursor_productos_dpf
	DEALLOCATE cursor_productos_dpf
	
		/*DELETE FROM ITF_AFIP_SITEROP_HIST WHERE PERIODO  = @CA_PERIODO_INFORMADO;  
  
	---Cargo tabla historica personas informadas---
	INSERT INTO ITF_AFIP_SITEROP_HIST(TIPO_DOCUMENTO,NUMERO_DOCUMENTO,TIPO_PERSONA,NUMERO_PERSONA,PERIODO)
	SELECT DISTINCT 
           TIPO_DOCUMENTO,
           NUMERO_DOCUMENTO,
           TIPO_PERSONA,
           NUMERO_PERSONA,
           @CA_PERIODO_INFORMADO
    FROM ITF_AFIP_SITEROP_AUX
    WHERE TIPO_REGISTRO <> '01';      */
	  
	

	END TRY

	BEGIN CATCH  
    	SELECT ERROR_NUMBER() AS ErrorNumber  
       	  		, ERROR_MESSAGE() AS ErrorMessage
      	 		, ERROR_LINE() AS ErrorLine;  
	END CATCH

END;
GO

