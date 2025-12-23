
/****** Object:  StoredProcedure [dbo].[SP_DJ_GENERAR_NRO_CTA]    Script Date: 28/05/2021 12:59:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_DJ_GENERAR_NRO_CTA]
@pNroCliente NUMERIC (12) OUT, @pNroCta NUMERIC (12) OUT
 AS
BEGIN
	DECLARE
	@vCliente NUMERIC (12),
	@vNroCta NUMERIC (12)
	
	SELECT @vCliente = NUMERICO 
	FROM PARAMETROSGENERALES with(nolock)
	WHERE CODIGO = 9
	
	SELECT @vNroCta = COALESCE(MAX(CUENTA), @vCliente * 1000000) + 1
	FROM SALDOS S with(nolock)
	WHERE S.C1803=@vCliente --AND S.TZ_LOCK=0  POR NBCHSEG-551
	
	SET @pNroCliente = @vCliente;
	SET @pNroCta = @vNroCta
END