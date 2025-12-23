EXECUTE('

ALTER PROCEDURE [dbo].[SP_DPF_ALTA_DOCUMENTOS]
(@pLote VARCHAR(10), @pCodigoDoc NUMERIC(5), @pCodigoDep NUMERIC(5), @pCantidadDesde NUMERIC(10), @pCantidadHasta NUMERIC(10), @pIdRecepcion NUMERIC(10))
AS
BEGIN 
	DECLARE @Documento NUMERIC(10);
	DECLARE @DocumentoAux NUMERIC(10);
	SET @Documento = @pCantidadDesde;
	
	WHILE @Documento <= @pCantidadHasta
	BEGIN
		IF @Documento IN (	SELECT ID_DOCUMENTO 
							FROM DPF_DOCS_DOCUMENTOS ddd with (nolock)
							WHERE ID_DOCUMENTO = @Documento
								--AND CODIGO_TIPO = @pCodigoDoc
						)
			UPDATE DPF_DOCS_DOCUMENTOS SET TZ_LOCK = ''0'', ID_RECEPCION = @pIdRecepcion
				WHERE LOTE = @pLote AND 
			  	CODIGO_TIPO = @pCodigoDoc AND 
			  	OPERATIVA = @pCodigoDoc AND
			  	CODIGO_DEPOSITO = @pCodigoDep AND 
			  	ID_DOCUMENTO = @Documento;
		ELSE
			INSERT INTO DPF_DOCS_DOCUMENTOS(LOTE, ID_DOCUMENTO, OPERATIVA, CODIGO_TIPO, CODIGO_DEPOSITO, ESTADO_DOCUMENTO, ID_RECEPCION)
			VALUES(@pLote, @Documento, @pCodigoDoc, @pCodigoDoc, @pCodigoDep, 1, @pIdRecepcion);
	SET @Documento = @Documento + 1;
	END
END

')