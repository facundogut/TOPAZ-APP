EXECUTE('CREATE OR ALTER PROCEDURE [dbo].[SP_ITF_ELIMINA_PARAM]

-- =====================================================================================
-- NUEVO OBJETO SP_ITF_ELIMINA_PARAM
-- =====================================================================================
/*-- ===================================================================================
	| Autor								:	TOPAZ
	| Fecha de creación					:	26/04/2023
	| Descripción						:	Elimina el parámetro ITF_MASTER_PARAMETROS
	| Fecha Ultima Modificación			:   No aplica
	| Descripción Ultima Modificación	:	No aplica

-- =====================================================================================*/

@V_CODIGO			NUMERIC(6), 		-- V_NROSOLICITUD como valor de entrada
@V_RESULTADO 		NUMERIC(5) OUTPUT	-- V_RESULTADO como salida

AS

BEGIN

	SET @V_RESULTADO=0;
	DELETE FROM ITF_MASTER_PARAMETROS WHERE CODIGO=@V_CODIGO
	SET @V_RESULTADO=1;

END')


