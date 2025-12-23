EXECUTE('

CREATE OR ALTER PROCEDURE SP_DJ_CANT_BENEFICIARIOS_CTA
@pNroCausa NUMERIC(12),
@pNroJtsOid NUMERIC(10),
@pContBeneficiarios NUMERIC(6) OUT
AS 
BEGIN
	DECLARE 
	@vContBeneficiarios NUMERIC(6);
	
	SELECT @vContBeneficiarios = COUNT(*) 
	FROM DJ_BENEFICIARIOS B WITH (NOLOCK)
	WHERE B.NRO_CAUSA = @pNroCausa 
		AND B.TZ_LOCK = 0
		AND B.JTS_OID_CUENTA = @pNroJtsOid;
	
	SET @pContBeneficiarios = @vContBeneficiarios;
END

')
