EXECUTE('
CREATE OR ALTER PROCEDURE SP_DJ_VALIDO_BAJA_PODER_BENEFICIARIO
@pNroCausa NUMERIC(12), 
@pNroPersona NUMERIC(10),
@pJtsOidCta NUMERIC(10),
@pTipoPoder NUMERIC(5),
@pIdBeneficiario NUMERIC(12),
@pValido NUMERIC(1) OUT
AS
BEGIN
	DECLARE
	@vEsBeneficiario NUMERIC(1),
	@vPoderAcivo NUMERIC(1),
	@vValido NUMERIC(1)
	
	SET @vValido = 0;
	
	SELECT @vEsBeneficiario = COUNT(*)
	FROM DJ_BENEFICIARIOS IC WITH (NOLOCK)
	WHERE IC.NRO_CAUSA = @pNroCausa 
		AND IC.JTS_OID_CUENTA = @pJtsOidCta
		AND IC.ID_BENEFICIARIO = @pIdBeneficiario
		AND IC.TZ_LOCK = 0;
	
	IF @vEsBeneficiario > 0
	BEGIN
		SELECT @vPoderAcivo = COUNT(*)
		FROM PYF_APODERADOS A WITH (NOLOCK)
		WHERE A.ID_ENTIDAD = @pJtsOidCta 
		AND	A.TIPO_PODER = @pTipoPoder 
		AND	A.TIPO_ENTIDAD = 2 
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
