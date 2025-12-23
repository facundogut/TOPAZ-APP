EXECUTE('
CREATE PROCEDURE dbo.SP_CALIFICACION_DISPONIBLE
   @FECHA DATE,
   @PRODUCTO NUMERIC(5),
   @CLIENTE NUMERIC(12),
   @MONTO NUMERIC(15,2),
   @MONEDA NUMERIC(4),
   @IDLIMITE NUMERIC(12,0),
   @COD_ERROR AS NUMERIC(10,0) OUTPUT,
   @DESCRIPCION AS VARCHAR(100) OUTPUT
AS 
   BEGIN
      DECLARE @EXISTE_LIMITE INT = 0,
      @IMPORTE_LIMITE NUMERIC(15,2),
      @MONTO_VIGENTE NUMERIC(18,2),
      @MONTO_SOLICITUDES NUMERIC(18,2),
      @MONTO_EVALUAR NUMERIC(18,2);
      
      SELECT @EXISTE_LIMITE = COUNT(1), @IMPORTE_LIMITE = SUM(PROD.MONTO)
      FROM CRE_PRODUCTOLIC PROD WITH(NOLOCK)
      WHERE PROD.PRODUCTO = @PRODUCTO AND PROD.FECHA_VENCIMIENTO >= @FECHA
      AND PROD.ESTADO = ''A'' AND PROD.TZ_LOCK = 0 AND PROD.IDLIMITE = @IDLIMITE;
      
      IF(@EXISTE_LIMITE=0 OR @EXISTE_LIMITE IS NULL)
      	BEGIN
      		SET @COD_ERROR = 3;
      		SET @DESCRIPCION = ''No existe o no se encuentra vigente el límite definido para el producto ''+CONVERT(VARCHAR(5),@PRODUCTO);
      	END
      	ELSE
      	BEGIN
      		SELECT @MONTO_VIGENTE=ISNULL(SUM(IMPORTE),0)
      		FROM VW_SaldosClienteLimite
      		WHERE cliente = @CLIENTE AND PRODUCTO = @PRODUCTO AND MONEDA = @MONEDA
      		
      		select 
			@MONTO_SOLICITUDES=ISNULL(SUM(CASE WHEN C6800 = ''L'' THEN isnull(s.MONTO_TOTAL_DESGLOSE,0) ELSE s.montosolicitado END),0)
			from cre_solicitudcredito  s WITH(NOLOCK),
			productos             p WITH(NOLOCK)
			where s.codproductosolicitado = p.C6250
			and p.EVALUA_DEUDA = ''S''
			and p.tz_lock = 0
			and s.tz_lock = 0 
			and s.estadosolicitud NOT IN (''04'', ''21'', ''22'', ''23'')
			and cliente = @CLIENTE AND s.CODPRODUCTOSOLICITADO = @PRODUCTO
      			
      		SET @MONTO_EVALUAR = @MONTO_VIGENTE + @MONTO_SOLICITUDES + @MONTO;
      			
      		IF(@MONTO_EVALUAR <= @IMPORTE_LIMITE)
      		BEGIN
      			SET @COD_ERROR = 0;
      			SET @DESCRIPCION = ''Disponible'';
      		END
      		ELSE
      		BEGIN
      			SET @COD_ERROR = 2;
      			SET @DESCRIPCION = ''El importe solicitado supera el límite'';
      		END
      	END
      
   END
')
