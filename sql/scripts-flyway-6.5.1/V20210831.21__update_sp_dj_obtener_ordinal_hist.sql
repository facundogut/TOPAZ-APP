EXECUTE ('
ALTER PROCEDURE [dbo].[SP_DJ_OBTENER_ORDINAL_HIST]
@pNroCausa NUMERIC(12), 
@pFecha DATE, 
@pOrdinal NUMERIC(12) OUT
AS
BEGIN
	DECLARE
	@vOrdinal NUMERIC(12)
	
	SELECT @vOrdinal = MAX(HM.ORDINAL)
	FROM DJ_HISTORICO_MOD HM WITH (NOLOCK)
	WHERE HM.NRO_CAUSA = @pNroCausa 
		AND HM.FECHA = @pFecha 
		-- AND HM.TZ_LOCK = 0
		AND (HM.TZ_LOCK  < 300000000000000 or hm.tz_lock >= 400000000000000);
	
	IF @vOrdinal IS NULL
	BEGIN
		SET @vOrdinal = 1;
	END
	ELSE
	BEGIN
		SET @vOrdinal = @vOrdinal + 1;
	END
	
	SET @pOrdinal = @vOrdinal;
	
END
')