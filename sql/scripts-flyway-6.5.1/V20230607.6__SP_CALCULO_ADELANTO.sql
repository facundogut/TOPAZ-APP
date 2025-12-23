EXECUTE('
ALTER PROCEDURE dbo.SP_CALCULA_ADELANTO
   @P_SOLICITUD numeric(15),
   @P_CLIENTE numeric(15),
   @P_DOCUMENTO varchar(20)
AS 
   BEGIN

      DECLARE
         @V_MONTO_CALCULADO NUMERIC(15,2) = 0,
         @V_MONTO_SUELDO NUMERIC(15,2) = 0,
         @V_MONTO_SINEQUIV NUMERIC(15,2) = 0, 
         @V_ADELANTOS_SINEQUIV NUMERIC(15,2) = 0,
         @V_MONTO_TARJETA NUMERIC(15,2) = 0, 
         @V_MONTO_CONEQUIV NUMERIC(15,2) = 0,
         @V_ADELANTOS_CONEQUIV NUMERIC(15,2) = 0,
         @V_MONTO_MISMOPROD NUMERIC(15,2) = 0, 
         @V_ADELANTOS_MISMOPROD NUMERIC(15,2) = 0,
         @V_SUBTOTAL NUMERIC(15,2) = 0,
         @V_CAPACIDAD NUMERIC(15,2) = 0,
         @V_COEFICIENTE NUMERIC(11,7) = 0

      BEGIN
      
      	 DELETE FROM CRE_AUX_SOL_CALCULO_ADELANTO WHERE NUMERO_SOLICITUD = 0 AND CLIENTE = @P_CLIENTE
      
         DECLARE
         @LINEA_REG$PRODUCTO numeric(5), 
         @LINEA_REG$CONVENIO numeric(15),         
         @LINEA_REG$JTS_SALDO numeric(15),
         @LINEA_REG$CANT_SUELDO INT,
         @LINEA_REG$JURISDICCION varchar(20),
         @LINEA_REG$TIPO_SCORING numeric(1),
         @LINEA_REG$AFECTACION numeric(5,2),
         @LINEA_REG$AFECTACIONCANAL numeric(5,2),
         @LINEA_REG$CANAL varchar(20)
         
         /*
         *   -----------------------------
         *    CURSOR REGISTROS obtengo productos
         *   -----------------------------
         */
         
         DECLARE
             CUR_REGISTROS CURSOR LOCAL FOR 
               -- Se obtienen lineas disponibles para el cliente
               SELECT DISTINCT Producto, Convenio, JTS_OID, CantidadSueldo, Jurisdiccion, Canal, TipoScoring, Afectacion, AfectacionCanal FROM VW_PRODUCTOS_CONVENIOS_AH WHERE Cliente = @P_CLIENTE

         OPEN CUR_REGISTROS

         WHILE 1 = 1
         
            BEGIN

               /*Lotes*/
               FETCH CUR_REGISTROS
                   INTO 
			         @LINEA_REG$PRODUCTO, 
			         @LINEA_REG$CONVENIO,
			         @LINEA_REG$JTS_SALDO,
			         @LINEA_REG$CANT_SUELDO,
			         @LINEA_REG$JURISDICCION,
			         @LINEA_REG$CANAL,
			         @LINEA_REG$TIPO_SCORING,
			         @LINEA_REG$AFECTACION,
			         @LINEA_REG$AFECTACIONCANAL
			         
               IF @@FETCH_STATUS <> 0
               	BREAK
               	
               	SET @V_MONTO_SUELDO = 0
               	SET @V_MONTO_SINEQUIV = 0
               	SET @V_ADELANTOS_SINEQUIV = 0
               	SET @V_ADELANTOS_CONEQUIV = 0
               	SET @V_MONTO_CONEQUIV = 0
               	SET @V_SUBTOTAL = 0
               	SET @V_MONTO_CALCULADO = 0
               	SET @V_MONTO_MISMOPROD = 0
               	SET @V_ADELANTOS_MISMOPROD = 0
                
                -- Scoring Lista  
                IF @LINEA_REG$TIPO_SCORING = 4
                	BEGIN
                		SELECT @V_MONTO_CALCULADO = isnull(MONTO_MAXIMO,0) FROM CRE_SCORINGPORLISTA WITH(NOLOCK) WHERE PRODUCTO = @LINEA_REG$PRODUCTO AND CONVENIO = @LINEA_REG$CONVENIO 
                		AND JURISDICCION = @LINEA_REG$JURISDICCION AND CUIT = @P_DOCUMENTO AND TZ_LOCK = 0
                		
                		SET @V_CAPACIDAD = @V_MONTO_CALCULADO
                	END
                -- Scoring 1 Cuota / N Cuotas	
                IF @LINEA_REG$TIPO_SCORING IN (0,1)
                	BEGIN
                		-- Importe de las ultimas N acreditaciones para ese convenio-jurisdiccion
                		SELECT @V_MONTO_SUELDO = isnull(round(avg(t.MONTO),2),0)
						FROM (SELECT TOP (@LINEA_REG$CANT_SUELDO) *
								FROM CRE_SOL_ACREDITACIONES_SUELDOS WITH(NOLOCK) WHERE TIPO = ''S'' AND SALDO_JTS_OID = @LINEA_REG$JTS_SALDO AND CONVENIO = @LINEA_REG$CONVENIO
								AND ID_JURISDICCION = @LINEA_REG$JURISDICCION AND TZ_LOCK = 0
								ORDER BY FECHA DESC) t
								
						-----------------------------------SIN EQUIVALENTES------------------------------------------------------------------------		
                		-- Importe de cuotas para productos que no son de la linea sin productos equivalentes
                		-- Asistencias ya desembolsadas
						SELECT @V_MONTO_SINEQUIV = isnull(sum(s.C1612),0)
						FROM SALDOS s WITH(NOLOCK)
						WHERE s.C1785 IN (5,6) AND s.TZ_LOCK = 0 AND s.C1604 < 0 AND s.PRODUCTO <> @LINEA_REG$PRODUCTO
						AND s.C1803 IN (SELECT C1803 FROM SALDOS WITH(NOLOCK) WHERE JTS_OID = @LINEA_REG$JTS_SALDO AND TZ_LOCK = 0) 
						AND s.PRODUCTO IN (SELECT C6250 FROM PRODUCTOS WITH(NOLOCK) WHERE TZ_LOCK = 0 AND C6800 <> ''AH'')
						
						-- Adelantos pendientes de impacto en canales digitales
						SELECT @V_ADELANTOS_SINEQUIV = isnull(sum(c.CUOTA_CALCULADA),0)
						FROM CRE_ADELANTOS_HABERES c WITH(NOLOCK)
						WHERE c.TZ_LOCK = 0 AND c.ESTADO=''I'' AND c.PRODUCTO <> @LINEA_REG$PRODUCTO
						AND c.CLIENTE IN (SELECT C1803 FROM SALDOS WITH(NOLOCK) WHERE JTS_OID = @LINEA_REG$JTS_SALDO AND TZ_LOCK = 0) 
						AND c.PRODUCTO IN (SELECT C6250 FROM PRODUCTOS WITH(NOLOCK) WHERE TZ_LOCK = 0 AND C6800 <> ''AH'')
						
						-- Importe minimo de TC pendiente
						SELECT @V_MONTO_TARJETA = isnull(sum(MONTO),0)
						FROM SALDOS t WITH(NOLOCK)
						INNER JOIN (SELECT s.JTS_OID, CASE WHEN s.C6676 = ''1'' THEN isnull(s.C1685 - (s.C1832 - s.AJUSTEINFLACION),0) ELSE isnull(s.AJUSTEINFLACION,0) END AS MONTO 
						FROM SALDOS s WITH(NOLOCK)
						WHERE s.C1785 = 1 AND s.TZ_LOCK = 0
						AND s.C1803 IN (SELECT C1803 FROM SALDOS WITH(NOLOCK) WHERE JTS_OID = @LINEA_REG$JTS_SALDO AND TZ_LOCK = 0) 
						AND s.PRODUCTO IN (SELECT C6250 FROM PRODUCTOS WITH(NOLOCK) WHERE TZ_LOCK = 0 AND C6800 = ''T'')  
						AND ((s.C6676 = ''1'' AND s.C1832 - s.AJUSTEINFLACION < s.C1685) OR s.C6676 = ''2'')) a ON t.JTS_OID = a.JTS_OID
						
						-- Se calcula subTotal, restando cuotas de productos sin equivalentes - minimos de TC y aplicando el 
						-- % de afectacion definido para el convenio y canal
						SET @V_SUBTOTAL = (@V_MONTO_SUELDO - @V_MONTO_SINEQUIV - @V_ADELANTOS_SINEQUIV - @V_MONTO_TARJETA) * @LINEA_REG$AFECTACION / 100
						SET @V_SUBTOTAL = @V_SUBTOTAL * @LINEA_REG$AFECTACIONCANAL / 100
						
						
						-----------------------------------CON EQUIVALENTES------------------------------------------------------------------------
						-- Se obtienen cuotas de productos equivalentes que no sean del producto de la linea
						-- Asistencias ya desembolsadas
						SELECT @V_MONTO_CONEQUIV = isnull(sum(s.C1612),0)
						FROM SALDOS s WITH(NOLOCK)
						WHERE s.C1785 IN (5,6) AND s.TZ_LOCK = 0 AND s.C1604 < 0 AND s.PRODUCTO <> @LINEA_REG$PRODUCTO
						AND s.C1803 IN (SELECT C1803 FROM SALDOS WITH(NOLOCK) WHERE JTS_OID = @LINEA_REG$JTS_SALDO AND TZ_LOCK = 0) 
						AND s.PRODUCTO IN (SELECT PRODUCTO_EQUIVALENTE FROM CRE_PRODUCTOSEQUIVALENTES WITH(NOLOCK) WHERE PRODUCTO = @LINEA_REG$PRODUCTO AND EQUIV_SCORING = ''S'' AND TZ_LOCK = 0)
						
						-- Adelantos pendientes de impacto en canales digitales
						SELECT @V_ADELANTOS_CONEQUIV = isnull(sum(c.CUOTA_CALCULADA),0)
						FROM CRE_ADELANTOS_HABERES c WITH(NOLOCK)
						WHERE c.TZ_LOCK = 0 AND c.ESTADO=''I'' AND c.PRODUCTO <> @LINEA_REG$PRODUCTO
						AND c.CLIENTE IN (SELECT C1803 FROM SALDOS WHERE JTS_OID = @LINEA_REG$JTS_SALDO AND TZ_LOCK = 0) 
						AND c.PRODUCTO IN (SELECT PRODUCTO_EQUIVALENTE FROM CRE_PRODUCTOSEQUIVALENTES WITH(NOLOCK) WHERE PRODUCTO = @LINEA_REG$PRODUCTO AND EQUIV_SCORING = ''S'' AND TZ_LOCK = 0)
						
						-- Cuotas de la misma linea
						-- Asistencias ya desembolsadas
						SELECT @V_MONTO_MISMOPROD = isnull(sum(s.C1612),0)
						FROM SALDOS s WITH(NOLOCK)
						WHERE s.C1785 IN (5,6) AND s.TZ_LOCK = 0 AND s.C1604 < 0 AND s.PRODUCTO = @LINEA_REG$PRODUCTO
						AND s.C1803 IN (SELECT C1803 FROM SALDOS WITH(NOLOCK) WHERE JTS_OID = @LINEA_REG$JTS_SALDO AND TZ_LOCK = 0) 	
						
						-- Adelantos pendientes de impacto en canales digitales
						SELECT @V_ADELANTOS_MISMOPROD = isnull(sum(c.CUOTA_CALCULADA),0)
						FROM CRE_ADELANTOS_HABERES c WITH(NOLOCK)
						WHERE c.TZ_LOCK = 0 AND c.ESTADO=''I'' AND  c.PRODUCTO = @LINEA_REG$PRODUCTO
						AND c.CLIENTE IN (SELECT C1803 FROM SALDOS WITH(NOLOCK) WHERE JTS_OID = @LINEA_REG$JTS_SALDO AND TZ_LOCK = 0) 	
										
						
						-- Si es Scoring 1 cuota no aplico coeficiente						
						IF @LINEA_REG$TIPO_SCORING = 0	 
							BEGIN			
								SET @V_MONTO_CALCULADO = @V_SUBTOTAL - @V_MONTO_CONEQUIV - @V_ADELANTOS_CONEQUIV - @V_MONTO_MISMOPROD - @V_ADELANTOS_MISMOPROD
								SET @V_CAPACIDAD = @V_MONTO_CALCULADO
							END	
						-- Si es Scoring n Cuotas, aplico coeficiente sobre el resultado		 
						ELSE
							BEGIN		   
								SELECT TOP (1) @V_COEFICIENTE = isnull(COEFICIENTE,0) FROM CRE_SCORINGPORCUOTAS WITH(NOLOCK) WHERE PRODUCTO = @LINEA_REG$PRODUCTO AND TZ_LOCK = 0 ORDER BY CANTIDAD_CUOTAS DESC	
								
								SET @V_MONTO_CALCULADO = (@V_SUBTOTAL - @V_MONTO_CONEQUIV - @V_ADELANTOS_CONEQUIV - @V_MONTO_MISMOPROD - @V_ADELANTOS_MISMOPROD) * @V_COEFICIENTE 
								SET @V_CAPACIDAD = @V_SUBTOTAL - @V_MONTO_CONEQUIV - @V_MONTO_MISMOPROD - @V_ADELANTOS_MISMOPROD - @V_ADELANTOS_CONEQUIV 
							END								                		
                	END    
                	
                	
                -- Scoring SAC (Aguinaldo)	            
                IF @LINEA_REG$TIPO_SCORING = 2
                	BEGIN
                		SELECT @V_MONTO_SUELDO = isnull(round(avg(t.MONTO),2),0)
						FROM (SELECT TOP (@LINEA_REG$CANT_SUELDO) *
								FROM CRE_SOL_ACREDITACIONES_SUELDOS WITH(NOLOCK) WHERE TIPO = ''A'' AND SALDO_JTS_OID = @LINEA_REG$JTS_SALDO AND CONVENIO = @LINEA_REG$CONVENIO
								AND ID_JURISDICCION = @LINEA_REG$JURISDICCION AND TZ_LOCK = 0
								ORDER BY FECHA DESC) t
                		
                		SET @V_SUBTOTAL = @V_MONTO_SUELDO * @LINEA_REG$AFECTACION / 100
                		SET @V_SUBTOTAL = @V_SUBTOTAL * @LINEA_REG$AFECTACIONCANAL / 100
                		
                		-- Se obtienen cuotas de productos equivalentes que no sean del producto de la linea
						-- Asistencias ya desembolsadas
						SELECT @V_MONTO_CONEQUIV = isnull(sum(s.C1612),0)
						FROM SALDOS s WITH(NOLOCK)
						WHERE s.C1785 IN (5,6) AND s.TZ_LOCK = 0 AND s.C1604 < 0 AND s.PRODUCTO <> @LINEA_REG$PRODUCTO
						AND s.C1803 IN (SELECT C1803 FROM SALDOS WITH(NOLOCK) WHERE JTS_OID = @LINEA_REG$JTS_SALDO AND TZ_LOCK = 0) 						
						AND s.PRODUCTO IN (SELECT PRODUCTO_EQUIVALENTE FROM CRE_PRODUCTOSEQUIVALENTES WITH(NOLOCK) WHERE PRODUCTO = @LINEA_REG$PRODUCTO AND EQUIV_SCORING = ''S'' AND TZ_LOCK = 0)                		
                		
                		-- Adelantos pendientes de impacto en canales digitales
						SELECT @V_ADELANTOS_CONEQUIV = isnull(sum(c.CUOTA_CALCULADA),0)
						FROM CRE_ADELANTOS_HABERES c WITH(NOLOCK)
						WHERE c.TZ_LOCK = 0 AND c.ESTADO=''I'' AND c.PRODUCTO <> @LINEA_REG$PRODUCTO
						AND c.CLIENTE IN (SELECT C1803 FROM SALDOS WHERE JTS_OID = @LINEA_REG$JTS_SALDO AND TZ_LOCK = 0) 
						AND c.PRODUCTO IN (SELECT PRODUCTO_EQUIVALENTE FROM CRE_PRODUCTOSEQUIVALENTES WITH(NOLOCK) WHERE PRODUCTO = @LINEA_REG$PRODUCTO AND EQUIV_SCORING = ''S'' AND TZ_LOCK = 0)
						
                		-- Asistencias ya desembolsadas
						SELECT @V_MONTO_MISMOPROD = isnull(sum(s.C1612),0)
						FROM SALDOS s WITH(NOLOCK)
						WHERE s.C1785 IN (5,6) AND s.TZ_LOCK = 0 AND s.C1604 < 0 AND s.PRODUCTO = @LINEA_REG$PRODUCTO
						AND s.C1803 IN (SELECT C1803 FROM SALDOS WITH(NOLOCK) WHERE JTS_OID = @LINEA_REG$JTS_SALDO AND TZ_LOCK = 0) 	
						
						-- Adelantos pendientes de impacto en canales digitales
						SELECT @V_ADELANTOS_MISMOPROD = isnull(sum(c.CUOTA_CALCULADA),0)
						FROM CRE_ADELANTOS_HABERES c WITH(NOLOCK)
						WHERE c.TZ_LOCK = 0 AND c.ESTADO=''I'' AND  c.PRODUCTO = @LINEA_REG$PRODUCTO
						AND c.CLIENTE IN (SELECT C1803 FROM SALDOS WITH(NOLOCK) WHERE JTS_OID = @LINEA_REG$JTS_SALDO AND TZ_LOCK = 0) 	
														                		
                		SET @V_MONTO_CALCULADO = @V_SUBTOTAL - @V_MONTO_CONEQUIV - @V_ADELANTOS_CONEQUIV - @V_MONTO_MISMOPROD - @V_ADELANTOS_MISMOPROD
                		
                		SET @V_CAPACIDAD = @V_MONTO_CALCULADO
                	END 
                IF @LINEA_REG$TIPO_SCORING = 3  
                	BEGIN  
                		SET @V_MONTO_CALCULADO = 0 
                		SET @V_CAPACIDAD = @V_MONTO_CALCULADO    
                	END                	                      
				
				IF @V_MONTO_CALCULADO < 0
					SET @V_MONTO_CALCULADO = 0
					
				IF @V_CAPACIDAD < 0
					SET @V_CAPACIDAD = 0
										
                INSERT INTO dbo.CRE_AUX_SOL_CALCULO_ADELANTO (NUMERO_SOLICITUD, CLIENTE, PRODUCTO, CONVENIO, ID_JURIDICCION, CANAL, MONTO_CALCULADO, CAPACIDAD_PAGO, TZ_LOCK)
				VALUES (0, @P_CLIENTE, @LINEA_REG$PRODUCTO, @LINEA_REG$CONVENIO, @LINEA_REG$JURISDICCION, @LINEA_REG$CANAL, @V_MONTO_CALCULADO, @V_CAPACIDAD, 0)     

            END

         CLOSE CUR_REGISTROS

         DEALLOCATE CUR_REGISTROS

      END

   END
')