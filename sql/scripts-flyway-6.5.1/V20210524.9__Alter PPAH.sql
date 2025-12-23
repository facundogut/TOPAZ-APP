EXECUTE('
IF OBJECT_ID (''dbo.VW_PRODUCTOS_CONVENIOS_AH'') IS NOT NULL
	DROP VIEW dbo.VW_PRODUCTOS_CONVENIOS_AH
')

EXECUTE('
CREATE VIEW dbo.VW_PRODUCTOS_CONVENIOS_AH (
	"Producto", 
	"NombreProducto", 
	"Convenio",
	"NombreConvenio",
	"SucursalCuenta",
	"NombreSucursal",
	"Cuenta",
	"EstadoCuenta",
	"ContratoMarco",
	"Beneficio",
	"TipoContrato",
	"pf",
	JTS_OID,
	"MontoCalculado",
	"CantidadSueldo",
	"Jurisdiccion",
	"TipoScoring",
	"Afectacion",
	"Canal",
	"CapacidadPago",
	"AfectacionCanal",
	"Cliente"
)
AS
	SELECT 
	pc.PRODUCTO AS "Producto", 
	p.C6251 AS "NombreProducto", 
	vc.ID_CONVENIO AS "Convenio",
	c.NomConvPago AS "NombreConvenio",
	s.SUCURSAL AS "SucursalCuenta",
	suc.NOMBRESUCURSAL AS "NombreSucursal", 
	s.CUENTA AS "Cuenta",
	CASE WHEN s.C1651 = ''1'' THEN ''Cuenta Cerrada'' ELSE ''Cuenta Activa'' END AS "EstadoCuenta",
	''Sin Firmar'' AS "ContratoMarco",
	vc.ID_BENEFICIO AS "Beneficio",
	t.TpoContrato AS "TipoContrato",
	id_persona AS "pf",
	s.JTS_OID,
	isnull(ca.MONTO_CALCULADO,0) AS "MontoCalculado",
	pc.CANT_SUELDO AS "CantidadSueldo",
	vc.ID_JURISDICCION AS "Jurisdiccion",
	tp.TIPO_SCORING AS "TipoScoring",
	pc.PORC_AFECTACION AS "Afectacion",
	can.CANAL,
	isnull(ca.CAPACIDAD_PAGO,0) AS "CapacidadPago",
	can.PORCENTAJE_AFECTACION AS "AfectacionCanal",
	s.C1803 AS "Cliente"
	FROM CRE_VINCULACIONES_CONVENIOS vc
	INNER JOIN SALDOS s ON vc.JTS_CV = s.JTS_OID AND s.TZ_LOCK = 0 AND s.C1785 IN (2,3)
	INNER JOIN SUCURSALES suc ON s.SUCURSAL = suc.SUCURSAL AND suc.TZ_LOCK = 0
	INNER JOIN CRE_PROD_CONVENIOS pc ON vc.ID_CONVENIO = pc.DATO_TIPO AND pc.TIPO = ''C'' AND pc.HABILITADO = ''S'' AND pc.TZ_LOCK = 0
	INNER JOIN CONV_CONVENIOS_PAG c ON pc.DATO_TIPO = c.ID_ConvPago
	INNER JOIN CONV_TIPOS t ON c.Id_TpoConv = t.Id_TpoConv AND t.TZ_LOCK = 0
	INNER JOIN PRODUCTOS p ON pc.PRODUCTO = p.C6250 AND p.TZ_LOCK = 0 AND p.C6800 = ''AH''
	INNER JOIN TOPESPRODUCTO tp ON p.C6250 = tp.CODPRODUCTO AND tp.MONEDA = 1 AND tp.TZ_LOCK = 0
	INNER JOIN CRE_PRODUCTOSCANALDIGITAL can ON p.C6250 = can.PRODUCTO AND can.CANAL_PRESENCIAL = ''S'' AND can.HABILITADO = ''S'' AND can.TZ_LOCK = 0
	LEFT JOIN CRE_AUX_SOL_CALCULO_ADELANTO ca ON p.C6250 = ca.PRODUCTO AND c.ID_ConvPago = ca.CONVENIO AND vc.ID_PERSONA = ca.CLIENTE AND vc.ID_JURISDICCION = ca.ID_JURIDICCION AND can.CANAL = ca.CANAL
	WHERE vc.TZ_LOCK = 0
	UNION
	SELECT
	pc.PRODUCTO AS "Producto", 
	p.C6251 AS "NombreProducto", 
	vc.ID_CONVENIO AS "Convenio",
	c.NomConvPago AS "NombreConvenio",
	s.SUCURSAL AS "SucursalCuenta",
	suc.NOMBRESUCURSAL AS "NombreSucursal", 
	s.CUENTA AS "Cuenta",
	CASE WHEN s.C1651 = ''1'' THEN ''Cuenta Cerrada'' ELSE ''Cuenta Activa'' END AS "EstadoCuenta",
	''Sin Firmar'' AS "ContratoMarco",
	vc.ID_BENEFICIO AS "Beneficio",
	t.TpoContrato AS "TipoContrato",
	id_persona AS "pf",
	s.JTS_OID,
	isnull(ca.MONTO_CALCULADO,0) AS "MontoCalculado",
	pc.CANT_SUELDO AS "CantidadSueldo",
	vc.ID_JURISDICCION AS "Jurisdiccion",
	tp.TIPO_SCORING AS "TipoScoring",
	pc.PORC_AFECTACION AS "Afectacion",
	can.CANAL,
	isnull(ca.CAPACIDAD_PAGO,0) AS "CapacidadPago",
	can.PORCENTAJE_AFECTACION AS "AfectacionCanal",
	s.C1803 AS "Cliente"
	FROM CRE_VINCULACIONES_CONVENIOS vc
	INNER JOIN SALDOS s ON vc.JTS_CV = s.JTS_OID AND s.TZ_LOCK = 0 AND s.C1785 IN (2,3)
	INNER JOIN SUCURSALES suc ON s.SUCURSAL = suc.SUCURSAL AND suc.TZ_LOCK = 0
	INNER JOIN CONV_CONVENIOS_PAG c ON vc.ID_CONVENIO = c.ID_ConvPago
	INNER JOIN CONV_TIPOS t ON c.Id_TpoConv = t.Id_TpoConv AND t.TZ_LOCK = 0
	INNER JOIN CRE_PROD_CONVENIOS pc ON t.TpoContrato = pc.DATO_TIPO AND pc.TIPO = ''G'' AND pc.HABILITADO = ''S'' AND pc.TZ_LOCK = 0
	INNER JOIN PRODUCTOS p ON pc.PRODUCTO = p.C6250 AND p.TZ_LOCK = 0 AND p.C6800 = ''AH''
	INNER JOIN TOPESPRODUCTO tp ON p.C6250 = tp.CODPRODUCTO AND tp.MONEDA = 1 AND tp.TZ_LOCK = 0
	INNER JOIN CRE_PRODUCTOSCANALDIGITAL can ON p.C6250 = can.PRODUCTO AND can.CANAL_PRESENCIAL = ''S'' AND can.HABILITADO = ''S'' AND can.TZ_LOCK = 0
	LEFT JOIN CRE_AUX_SOL_CALCULO_ADELANTO ca ON p.C6250 = ca.PRODUCTO AND c.ID_ConvPago = ca.CONVENIO AND vc.ID_PERSONA = ca.CLIENTE AND vc.ID_JURISDICCION = ca.ID_JURIDICCION AND can.CANAL = ca.CANAL
')

EXECUTE('
IF OBJECT_ID (''dbo.VW_PRODUCTOS_CONVENIOS_PP'') IS NOT NULL
	DROP VIEW dbo.VW_PRODUCTOS_CONVENIOS_PP
')


EXECUTE('
CREATE VIEW dbo.VW_PRODUCTOS_CONVENIOS_PP (
	"Producto", 
	"NombreProducto", 
	"Convenio",
	"NombreConvenio",
	"SucursalCuenta",
	"NombreSucursal",
	"Cuenta",
	"EstadoCuenta",
	"Beneficio",
	"TipoContrato",
	"pf",
	JTS_OID,
	"Cliente"
)
AS
	SELECT 
	pc.PRODUCTO AS "Producto", 
	p.C6251 AS "NombreProducto", 
	vc.ID_CONVENIO AS "Convenio",
	c.NomConvPago AS "NombreConvenio",
	s.SUCURSAL AS "SucursalCuenta",
	suc.NOMBRESUCURSAL AS "NombreSucursal", 
	s.CUENTA AS "Cuenta",
	CASE WHEN s.C1651 = ''1'' THEN ''Cuenta Cerrada'' ELSE ''Cuenta Activa'' END AS "EstadoCuenta",
	vc.ID_BENEFICIO AS "Beneficio",
	t.TpoContrato AS "TipoContrato",
	id_persona AS "pf",
	s.JTS_OID,
	s.C1803 AS "Cliente"
	FROM CRE_VINCULACIONES_CONVENIOS vc
	INNER JOIN SALDOS s ON vc.JTS_CV = s.JTS_OID AND s.TZ_LOCK = 0 AND s.C1785 IN (2,3)
	INNER JOIN SUCURSALES suc ON s.SUCURSAL = suc.SUCURSAL AND suc.TZ_LOCK = 0
	INNER JOIN CRE_PROD_CONVENIOS pc ON vc.ID_CONVENIO = pc.DATO_TIPO AND pc.TIPO = ''C'' AND pc.HABILITADO = ''S'' AND pc.TZ_LOCK = 0
	INNER JOIN CONV_CONVENIOS_PAG c ON pc.DATO_TIPO = c.ID_ConvPago
	INNER JOIN CONV_TIPOS t ON c.Id_TpoConv = t.Id_TpoConv AND t.TZ_LOCK = 0
	INNER JOIN PRODUCTOS p ON pc.PRODUCTO = p.C6250 AND p.TZ_LOCK = 0 AND p.C6800 = ''PP''
	WHERE vc.TZ_LOCK = 0
	UNION
	SELECT
	pc.PRODUCTO AS "Producto", 
	p.C6251 AS "NombreProducto", 
	vc.ID_CONVENIO AS "Convenio",
	c.NomConvPago AS "NombreConvenio",
	s.SUCURSAL AS "SucursalCuenta",
	suc.NOMBRESUCURSAL AS "NombreSucursal", 
	s.CUENTA AS "Cuenta",
	CASE WHEN s.C1651 = ''1'' THEN ''Cuenta Cerrada'' ELSE ''Cuenta Activa'' END AS "EstadoCuenta",
	vc.ID_BENEFICIO AS "Beneficio",
	t.TpoContrato AS "TipoContrato",
	id_persona AS "pf",
	s.JTS_OID,
	s.C1803 AS "Cliente"
	FROM CRE_VINCULACIONES_CONVENIOS vc
	INNER JOIN SALDOS s ON vc.JTS_CV = s.JTS_OID AND s.TZ_LOCK = 0 AND s.C1785 IN (2,3)
	INNER JOIN SUCURSALES suc ON s.SUCURSAL = suc.SUCURSAL AND suc.TZ_LOCK = 0
	INNER JOIN CONV_CONVENIOS_PAG c ON vc.ID_CONVENIO = c.ID_ConvPago
	INNER JOIN CONV_TIPOS t ON c.Id_TpoConv = t.Id_TpoConv AND t.TZ_LOCK = 0
	INNER JOIN CRE_PROD_CONVENIOS pc ON t.TpoContrato = pc.DATO_TIPO AND pc.TIPO = ''G'' AND pc.HABILITADO = ''S'' AND pc.TZ_LOCK = 0
	INNER JOIN PRODUCTOS p ON pc.PRODUCTO = p.C6250 AND p.TZ_LOCK = 0 AND p.C6800 = ''PP''
')

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
         @V_MONTO_CONEQUIV NUMERIC(15,2) = 0,
         @V_MONTO_MISMOPROD NUMERIC(15,2) = 0,
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
               	SET @V_MONTO_CONEQUIV = 0
               	SET @V_SUBTOTAL = 0
               	SET @V_MONTO_CALCULADO = 0
               	SET @V_MONTO_MISMOPROD = 0
                  
                IF @LINEA_REG$TIPO_SCORING = 4
                	BEGIN
                		SELECT @V_MONTO_CALCULADO = isnull(MONTO_MAXIMO,0) FROM CRE_SCORINGPORLISTA WHERE PRODUCTO = @LINEA_REG$PRODUCTO AND CONVENIO = @LINEA_REG$CONVENIO 
                		AND JURISDICCION = @LINEA_REG$JURISDICCION AND CUIT = @P_DOCUMENTO AND TZ_LOCK = 0
                		
                		SET @V_CAPACIDAD = @V_MONTO_CALCULADO
                	END
                IF @LINEA_REG$TIPO_SCORING IN (0,1)
                	BEGIN
                		SELECT @V_MONTO_SUELDO = isnull(round(avg(t.MONTO),2),0)
						FROM (SELECT TOP (@LINEA_REG$CANT_SUELDO) *
								FROM CRE_SOL_ACREDITACIONES_SUELDOS WHERE TIPO = ''S'' AND SALDO_JTS_OID = @LINEA_REG$JTS_SALDO AND CONVENIO = @LINEA_REG$CONVENIO
								AND ID_JURISDICCION = @LINEA_REG$JURISDICCION AND TZ_LOCK = 0
								ORDER BY FECHA DESC) t
                		
						SELECT @V_MONTO_SINEQUIV = isnull(sum(s.C1612),0)
						FROM SALDOS s
						WHERE s.C1785 IN (5,6) AND s.TZ_LOCK = 0 AND s.C1604 < 0 AND s.PRODUCTO <> @LINEA_REG$PRODUCTO
						AND s.C1803 IN (SELECT C1803 FROM SALDOS WHERE JTS_OID = @LINEA_REG$JTS_SALDO AND TZ_LOCK = 0) 
						AND s.PRODUCTO NOT IN (SELECT PRODUCTO_EQUIVALENTE FROM CRE_PRODUCTOSEQUIVALENTES WHERE PRODUCTO = @LINEA_REG$PRODUCTO AND EQUIV_SCORING = ''S'' AND TZ_LOCK = 0)
						
						SET @V_SUBTOTAL = (@V_MONTO_SUELDO - @V_MONTO_SINEQUIV) * @LINEA_REG$AFECTACION / 100
						SET @V_SUBTOTAL = @V_SUBTOTAL * @LINEA_REG$AFECTACIONCANAL / 100
						
						SELECT @V_MONTO_CONEQUIV = isnull(sum(s.C1612),0)
						FROM SALDOS s
						WHERE s.C1785 IN (5,6) AND s.TZ_LOCK = 0 AND s.C1604 < 0 AND s.PRODUCTO <> @LINEA_REG$PRODUCTO
						AND s.C1803 IN (SELECT C1803 FROM SALDOS WHERE JTS_OID = @LINEA_REG$JTS_SALDO AND TZ_LOCK = 0) 
						AND s.PRODUCTO IN (SELECT PRODUCTO_EQUIVALENTE FROM CRE_PRODUCTOSEQUIVALENTES WHERE PRODUCTO = @LINEA_REG$PRODUCTO AND EQUIV_SCORING = ''S'' AND TZ_LOCK = 0)
						
						SELECT @V_MONTO_MISMOPROD = isnull(sum(s.C1612),0)
						FROM SALDOS s
						WHERE s.C1785 IN (5,6) AND s.TZ_LOCK = 0 AND s.C1604 < 0 AND s.PRODUCTO = @LINEA_REG$PRODUCTO
						AND s.C1803 IN (SELECT C1803 FROM SALDOS WHERE JTS_OID = @LINEA_REG$JTS_SALDO) 						
												
						IF @LINEA_REG$TIPO_SCORING = 0	 
							BEGIN			
								SET @V_MONTO_CALCULADO = @V_SUBTOTAL - @V_MONTO_CONEQUIV - @V_MONTO_MISMOPROD
								SET @V_CAPACIDAD = @V_MONTO_CALCULADO
							END		 
						ELSE
							BEGIN		   
								SELECT TOP (1) @V_COEFICIENTE = isnull(COEFICIENTE,0) FROM CRE_SCORINGPORCUOTAS WHERE PRODUCTO = @LINEA_REG$PRODUCTO AND TZ_LOCK = 0 ORDER BY CANTIDAD_CUOTAS DESC	
								
								SET @V_MONTO_CALCULADO = (@V_SUBTOTAL - @V_MONTO_CONEQUIV - @V_MONTO_MISMOPROD) * @V_COEFICIENTE 
								SET @V_CAPACIDAD = @V_SUBTOTAL - @V_MONTO_CONEQUIV - @V_MONTO_MISMOPROD
							END								                		
                	END                
                IF @LINEA_REG$TIPO_SCORING = 2
                	BEGIN
                		SELECT @V_MONTO_SUELDO = isnull(round(avg(t.MONTO),2),0)
						FROM (SELECT TOP (@LINEA_REG$CANT_SUELDO) *
								FROM CRE_SOL_ACREDITACIONES_SUELDOS WHERE TIPO = ''A'' AND SALDO_JTS_OID = @LINEA_REG$JTS_SALDO AND CONVENIO = @LINEA_REG$CONVENIO
								AND ID_JURISDICCION = @LINEA_REG$JURISDICCION AND TZ_LOCK = 0
								ORDER BY FECHA DESC) t
                		
                		SET @V_SUBTOTAL = @V_MONTO_SUELDO * @LINEA_REG$AFECTACION / 100
                		SET @V_SUBTOTAL = @V_SUBTOTAL * @LINEA_REG$AFECTACIONCANAL / 100
                		
						SELECT @V_MONTO_CONEQUIV = isnull(sum(s.C1612),0)
						FROM SALDOS s
						WHERE s.C1785 IN (5,6) AND s.TZ_LOCK = 0 AND s.C1604 < 0 AND s.PRODUCTO <> @LINEA_REG$PRODUCTO
						AND s.C1803 IN (SELECT C1803 FROM SALDOS WHERE JTS_OID = @LINEA_REG$JTS_SALDO AND TZ_LOCK = 0) 						
						AND s.PRODUCTO IN (SELECT PRODUCTO_EQUIVALENTE FROM CRE_PRODUCTOSEQUIVALENTES WHERE PRODUCTO = @LINEA_REG$PRODUCTO AND EQUIV_SCORING = ''S'' AND TZ_LOCK = 0)                		
                		
						SELECT @V_MONTO_MISMOPROD = isnull(sum(s.C1612),0)
						FROM SALDOS s
						WHERE s.C1785 IN (5,6) AND s.TZ_LOCK = 0 AND s.C1604 < 0 AND s.PRODUCTO = @LINEA_REG$PRODUCTO
						AND s.C1803 IN (SELECT C1803 FROM SALDOS WHERE JTS_OID = @LINEA_REG$JTS_SALDO AND TZ_LOCK = 0) 	
						                		
                		SET @V_MONTO_CALCULADO = @V_SUBTOTAL - @V_MONTO_CONEQUIV - @V_MONTO_MISMOPROD
                		
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