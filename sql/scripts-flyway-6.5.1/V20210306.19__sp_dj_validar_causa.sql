ALTER PROCEDURE sp_dj_validar_causa
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
	@vCausaTransferida NUMERIC(12)
	
	SET @vValido = 0;
	
	SELECT TOP 1 @vValido = 1, @vEstadoCausa = C.ESTADO, @vCausaTransferida = C.CAUSA_DESTINO
	FROM DJ_CAUSAS C 
	WHERE C.JUZGADO=@pJuzgado AND C.ANO=@pAnio AND C.EXPEDIENTE=@pExpediente AND C.TZ_LOCK=0;
	
	IF @vValido = 1 AND @vEstadoCausa = 'A' BEGIN
		SET @pValido = 1;
		SET @pMensaje = 'La causa existe con el mismo Juzgado + Año + Expediente';
	END
	ELSE IF @vValido = 1 AND @vEstadoCausa = 'I' BEGIN
		SET @pValido = 1;
		SET @pMensaje = 'La causa se encuentra Inactiva.'
	END
	ELSE IF @vValido = 1 AND @vEstadoCausa = 'T' BEGIN
		SET @pValido = 1;
		SET @pMensaje = 'La causa fue transferida a la causa número ' + CONVERT(VARCHAR, @vCausaTransferida);
	END
	ELSE IF @vValido = 0 BEGIN
		SET @pValido = 0;
	END
END
GO