EXECUTE(' DROP FUNCTION IF EXISTS ITF_INSSSEP_IMPORTE;')
EXECUTE(' 
CREATE FUNCTION ITF_INSSSEP_IMPORTE (@jts_oid NUMERIC(10,0), @nro_cuota NUMERIC(4,0)) 
RETURNS NUMERIC(15,2)
/*
@jts_oid = id de la operación a procesar
@nro_cuota = nro de cuota de la oper a procesar
*/
AS
BEGIN		
	
	DECLARE @resultado NUMERIC(15,2) = 0;	
	DECLARE @resultadoG NUMERIC(15,2) = 0;	
	
	SET @resultado = (SELECT SUM(C2309 + C2310 + C2311) FROM PLANPAGOS WHERE SALDO_JTS_OID=@jts_oid AND C2300=@nro_cuota AND TZ_LOCK=0);		
	
	IF @resultado IS NULL	
		SET @resultado = 0;
	
	SET @resultadoG = (SELECT SALDO_GASTO FROM GASTOS_POR_CUOTA WHERE SALDOS_JTS_OID=@jts_oid AND NUMERO_CUOTA=@nro_cuota AND TZ_LOCK=0);
	
	IF @resultadoG IS NULL	
		SET @resultadoG = 0;
		
	SET @resultado = @resultado	+ @resultadoG;
	
	RETURN @resultado
END



')