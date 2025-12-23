EXECUTE('
ALTER PROCEDURE 
[dbo].[sp_dj_validar_causa]
@pJuzgado NUMERIC(12),
@pAnio	NUMERIC(4),
@pExpediente VARCHAR(12),
@pValido NUMERIC(6) OUT,
@pMensaje VARCHAR(200) OUT
AS
BEGIN
	DECLARE
	@vValido NUMERIC(6),
	@vEstadoCausa VARCHAR(1),
	@vCausaTransferida NUMERIC(12),
	@vCausa VARCHAR(12)
	
	SET @vValido = 0;
	
	SELECT TOP 1 @vValido = 1, @vEstadoCausa = C.ESTADO, @vCausaTransferida = C.CAUSA_DESTINO, @vCausa=C.NRO_CAUSA
	FROM DJ_CAUSAS C WITH (NOLOCK)
	WHERE C.JUZGADO=@pJuzgado 
			AND C.ANO=@pAnio 
			AND C.EXPEDIENTE=@pExpediente 
			;
	
	IF @vValido = 1 AND @vEstadoCausa = ''A'' BEGIN
		SET @pValido = 1;
		SET @pMensaje = ''La causa existe con el mismo Juzgado + Año + Expediente. Nro. Causa: '';
		SET @pMensaje = @pMensaje+@vCausa;
	END
	ELSE IF @vValido = 1 AND @vEstadoCausa = ''I'' BEGIN
		SET @pValido = 1;
		SET @pMensaje = ''La causa se encuentra Inactiva. Nro. Causa: '';
		SET @pMensaje = @pMensaje+@vCausa;
	END
	ELSE IF @vValido = 1 AND @vEstadoCausa = ''T'' BEGIN
		SET @pValido = 1;
		SET @pMensaje = ''La causa fue transferida a la causa número '' + CONVERT(VARCHAR, @vCausaTransferida);
	END
	ELSE IF @vValido = 0 BEGIN
		SET @pValido = 0;
	END
END

')