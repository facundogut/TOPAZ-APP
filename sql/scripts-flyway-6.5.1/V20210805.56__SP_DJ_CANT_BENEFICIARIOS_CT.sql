/****** Object:  StoredProcedure [dbo].[SP_DJ_CANT_BENEFICIARIOS_CTA]    Script Date: 02/06/2021 17:35:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_DJ_CANT_BENEFICIARIOS_CTA]
				@pNroCausa NUMERIC(12),
				@pNroJtsOid NUMERIC(10),
				@pContBeneficiarios NUMERIC(1) OUT
AS 
BEGIN
	DECLARE 
	@vContBeneficiarios NUMERIC(6);
	
	SELECT @vContBeneficiarios = COUNT(*) 
	FROM DJ_BENEFICIARIOS B WITH (NOLOCK)
	WHERE B.NRO_CAUSA = @pNroCausa AND B.TZ_LOCK = 0
		AND B.JTS_OID_CUENTA = @pNroJtsOid;
	
	SET @pContBeneficiarios = @vContBeneficiarios;
END