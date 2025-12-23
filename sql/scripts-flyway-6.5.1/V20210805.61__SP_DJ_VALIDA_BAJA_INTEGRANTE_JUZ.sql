/****** Object:  StoredProcedure [dbo].[SP_DJ_VALIDA_BAJA_INTEGRANTE_JUZ]    Script Date: 02/06/2021 17:38:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_DJ_VALIDA_BAJA_INTEGRANTE_JUZ]
@pNroJuz NUMERIC(12),
@pNroIntegrante NUMERIC(12),
@pValido NUMERIC(1) OUT
AS
BEGIN
	DECLARE
	@vRolIntegrante VARCHAR(3),
	@vEsObligatorio VARCHAR(1),
	@vValido NUMERIC(1),
	@vCantIntegrantes NUMERIC(6)
	
	SET @vValido = 1;
	
	SELECT @vRolIntegrante = IJ.ACTOR
	FROM DJ_INTEGRANTES_JUZGADOS IJ  WITH (NOLOCK)
	WHERE IJ.ID_PERSONA = @pNroIntegrante and
	IJ.NRO_JUZGADO = @pNroJuz;
	
	SELECT @vEsObligatorio = A.OBLIGATORIO
	FROM DJ_ACTORES A WITH (NOLOCK)
	WHERE A.Id=(SELECT IJ.ACTOR 
				FROM DJ_INTEGRANTES_JUZGADOS IJ WITH (NOLOCK) 
				WHERE IJ.NRO_JUZGADO=@pNroJuz 
						AND IJ.ID_PERSONA=@pNroIntegrante 
						AND IJ.TZ_LOCK=0)
	AND A.TZ_LOCK=0
	
	IF @vEsObligatorio = 'S' 
	BEGIN
		SELECT @vCantIntegrantes = COUNT(*)
		FROM DJ_INTEGRANTES_JUZGADOS IJ WITH (NOLOCK)
		WHERE IJ.NRO_JUZGADO = @pNroJuz AND 
		IJ.ACTOR = @vRolIntegrante AND 
		IJ.TZ_LOCK = 0;
		
		IF @vCantIntegrantes <= 1
		BEGIN
			SET @vValido = 0;
		END
	END
	
	SET @pValido = @vValido;
END