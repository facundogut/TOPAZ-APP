ALTER PROCEDURE [SP_DPF_VALIDA_SOLICITUD]
(@pTipoDoc NUMERIC(5), @pDeposito NUMERIC(10), @pRangoInicio NUMERIC(10), @pRangoFin NUMERIC(10), @pId_Recepcion NUMERIC(10) OUTPUT)
AS
BEGIN 
	DECLARE @Documento NUMERIC(10);
	DECLARE @ExisteDocumento NUMERIC(1);
	SET @Documento = @pRangoInicio;
	SET @ExisteDocumento = 1;
	SET @pId_Recepcion = 1;
	


	WHILE @Documento <= @pRangoFin

	BEGIN
		
		IF(@Documento IN (SELECT ID_DOCUMENTO FROM DPF_DOCS_DOCUMENTOS ddd WITH (nolock)
						  WHERE ID_DOCUMENTO = @Documento   
						  AND CODIGO_TIPO = @pTipoDoc 
						  AND ESTADO_DOCUMENTO = 1 
						  AND CODIGO_DEPOSITO = @pDeposito 
						  AND TZ_LOCK = 0))
		  	BEGIN
			  	SET @Documento = @Documento + 1;
			END
		ELSE
			BEGIN
				SET @ExisteDocumento = 0;
				SET @Documento = @pRangoFin + 1;
			END
		
	END

	IF (@ExisteDocumento = 1)
		BEGIN
			SET @pId_Recepcion = (SELECT ID_RECEPCION FROM DPF_DOCS_DOCUMENTOS ddd WITH (nolock) WHERE ID_DOCUMENTO = @pRangoInicio);
			PRINT @pId_Recepcion;	
		Return @pId_Recepcion;
		
		END
	ELSE
		BEGIN
			SET @pId_Recepcion = 0;
		PRINT @pId_Recepcion;
			Return @pId_Recepcion;
			
		END
		
END


GO

