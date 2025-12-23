EXECUTE('ALTER PROCEDURE sp_dj_validar_causa
@pJuzgado NUMERIC(12),
@pAnio	NUMERIC(4),
@pExpediente VARCHAR(12),
@pCantidad NUMERIC(6) OUT
AS
BEGIN
	DECLARE
	@vCantCausas NUMERIC(6)
	
	SELECT @vCantCausas = COUNT(*) FROM DJ_CAUSAS C WHERE C.JUZGADO=@pJuzgado AND C.ANO=@pAnio AND C.EXPEDIENTE=@pExpediente AND C.TZ_LOCK=0;
	
	SET @pCantidad = @vCantCausas
END
');