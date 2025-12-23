/****** Object:  StoredProcedure [dbo].[SP_DJ_VALIDA_BAJA_INTEGRANTE]    Script Date: 01/06/2021 17:33:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_DJ_VALIDA_BAJA_INTEGRANTE]
@pNroCausa NUMERIC(12),
@pNroIntegrante NUMERIC(12),
@pValido NUMERIC(1) OUT
AS
BEGIN
	DECLARE
	@vRolIntegrante NUMERIC(12),
	@vEsObligatorio VARCHAR(1),
	@vValido NUMERIC(1),
	@vCantIntegrantes NUMERIC(6)
	
	SET @vValido = 1;
	
	SELECT @vRolIntegrante = IJ.ACTOR
	FROM DJ_INTEGRANTES_JUZGADOS IJ WITH (NOLOCK)
	WHERE IJ.ID_PERSONA = @pNroIntegrante and
	IJ.NRO_JUZGADO = (SELECT C.JUZGADO FROM DJ_CAUSAS C WITH (NOLOCK) WHERE C.NRO_CAUSA = @pNroCausa);
	
	SELECT @vEsObligatorio = RO.OBLIGATORIO 
	FROM [CLI_ROLES_OBL_CARGO] RO WITH (NOLOCK)
	WHERE RO.TIPO_SOCIEDAD = 26 AND 
	RO.[CARGO] = @vRolIntegrante AND 
	RO.TZ_LOCK = 0; 
	
	IF @vEsObligatorio = 'S' 
	BEGIN
		SELECT @vCantIntegrantes = COUNT(*)
		FROM DJ_INTEGRANTES_CAUSAS IC WITH (NOLOCK)
		WHERE IC.NRO_CAUSA = @pNroCausa AND 
		IC.ACTOR = @vRolIntegrante AND 
		IC.TZ_LOCK = 0;
		
		IF @vCantIntegrantes <= 1
		BEGIN
			SET @vValido = 0;
		END
	END
	
	SET @pValido = @vValido;
END