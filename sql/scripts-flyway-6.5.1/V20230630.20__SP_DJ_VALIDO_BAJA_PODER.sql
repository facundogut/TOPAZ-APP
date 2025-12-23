EXECUTE('
CREATE OR ALTER PROCEDURE SP_DJ_VALIDO_BAJA_PODER
@pNroCausa NUMERIC(12), 
@pNroPersona NUMERIC(12),
@pJtsOidCta NUMERIC(10),
@pTipoPoder NUMERIC(5),
@pValido NUMERIC(1) OUT
AS
BEGIN
	DECLARE
	@vEsIntegranteJuz NUMERIC(1),
	@vPoderAcivo NUMERIC(1),
	@vValido NUMERIC(1)
	
	SET @vValido = 0;
	
	SELECT @vEsIntegranteJuz = COUNT(*)
	FROM DJ_INTEGRANTES_CAUSAS IC WITH (NOLOCK)
	WHERE IC.NRO_CAUSA = @pNroCausa 
		AND IC.ID_PERSONA = @pNroPersona 
		AND	IC.ACTIVO = ''S'' 
		AND IC.TZ_LOCK = 0;
	
	IF @vEsIntegranteJuz > 0
	BEGIN
		SELECT @vPoderAcivo = COUNT(*)
		FROM PYF_APODERADOS A WITH (NOLOCK)
		WHERE A.ID_ENTIDAD = @pJtsOidCta 
		AND	A.TIPO_PODER = @pTipoPoder 
		--AND	A.TIPO_ENTIDAD = 2 
		AND	A.ID_PERSONA = @pNroPersona 
		AND	A.FECHA_INI_SUSPENSION IS NULL 
		AND	A.TZ_LOCK = 0
		
		IF @vPoderAcivo > 0 
		BEGIN
			SET @vValido = 1;
		END
	END
	
	SET @pValido = @vValido;
END
')

