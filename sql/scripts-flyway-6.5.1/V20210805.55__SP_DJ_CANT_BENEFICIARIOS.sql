
/****** Object:  StoredProcedure [dbo].[SP_DJ_CANT_BENEFICIARIOS]    Script Date: 31/05/2021 16:59:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_DJ_CANT_BENEFICIARIOS]
@pNroCausa NUMERIC(12),
@pContBeneficiarios NUMERIC(1) OUT
AS 
BEGIN
	DECLARE 
	@vContBeneficiarios NUMERIC(6);
	
	SELECT @vContBeneficiarios = COUNT(*) 
	FROM DJ_BENEFICIARIOS B with (nolock)
	WHERE B.NRO_CAUSA = @pNroCausa AND B.TZ_LOCK = 0;
	SET @pContBeneficiarios = @vContBeneficiarios;
END