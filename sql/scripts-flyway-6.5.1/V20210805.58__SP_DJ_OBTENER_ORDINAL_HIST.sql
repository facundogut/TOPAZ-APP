/****** Object:  StoredProcedure [dbo].[SP_DJ_OBTENER_ORDINAL_HIST]    Script Date: 02/06/2021 17:50:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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
		AND HM.TZ_LOCK = 0;
	
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