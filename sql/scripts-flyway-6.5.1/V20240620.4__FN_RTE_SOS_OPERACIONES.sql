EXECUTE('
CREATE OR ALTER FUNCTION FN_RTE_SOS_OPERACIONES
(
 @CodTransaccion NUMERIC(5), 
 @ImpMovimiento  NUMERIC(15,2)
 ) RETURNS NUMERIC
AS

BEGIN
	DECLARE @ind_sos NUMERIC(1)
	
	SET @ind_sos = 0
	
	SELECT @ind_sos = COUNT(1) 
	FROM SOS_TRANSACCIONES tra 
    WHERE tra.Subsistema IN (''CC'',''AC'')
      AND tra.ind_rte = ''S''
      AND tra.CodTransaccion = @CodTransaccion
      AND ((tra.MtoMinimo < @ImpMovimiento
      	AND tra.MtoMinimo <> 0) OR tra.MtoMinimo = 0)

    RETURN @ind_sos
		
	END;
')