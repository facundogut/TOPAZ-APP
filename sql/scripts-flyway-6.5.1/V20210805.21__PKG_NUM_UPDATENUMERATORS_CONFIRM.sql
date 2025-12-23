/****** Object:  StoredProcedure [dbo].[PKG_NUM_UPDATENUMERATORS_CONFIRM]    Script Date: 18/06/2021 16:21:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[PKG_NUM_UPDATENUMERATORS_CONFIRM]
(
@POSTINGNUMBER 	NUMERIC ,
@SUCURSAL      	NUMERIC ,
@FECHA         	DATETIME,
@MSGLOG 		VARCHAR(400) OUTPUT
)
AS
------------------------------------------------------
-- PKG_NUM_UPDATENUMERATORS_CONFIRM
-- CREADO POR : JIC		
-- CREADO : 02-12-2014
-- Modifica el estado (NUMERATOR_USED) de los numeradores solicitados durante la ejecución de un proceso.
-- @param postingNumber Número de Asiento que quiere Cancelar los numeradores reservasdos. 
-- @param sucursal Sucursal desde donde se pide el numerador.
-- @param fecha Fecha en que se pidio el numerador.   
-----------------------------------------------------------
--DECLARE @ErrorCode int
--SELECT @ErrorCode = @@Error
--IF @ErrorCode = 0
BEGIN
   
	SET @MSGLOG =''
	DECLARE @NUMERATOR_RESERVED VARCHAR = 'R'
	DECLARE @NUMERATOR_USED VARCHAR = 'U'
		
	BEGIN TRY
		UPDATE 		NUMERATORASIGNED 
		SET 		NUMERATORASIGNED.ESTADO = @NUMERATOR_USED  
		WHERE 		NUMERATORASIGNED.ASIENTO = @POSTINGNUMBER 
		AND 		NUMERATORASIGNED.FECHAPROCESO = @FECHA 
		AND 		NUMERATORASIGNED.SUCURSAL = @SUCURSAL 
		AND 		NUMERATORASIGNED.ESTADO = @NUMERATOR_RESERVED
		SET @MSGLOG = 'Se actualizo Numerador'
		RETURN 1
	END TRY 
	BEGIN CATCH
		SET @MSGLOG = 'No fue posible actualizar el estado a USADO de los numeradores reservados para el asiento: '+STR(@POSTINGNUMBER)+' Sucursal: '+STR(@SUCURSAL)+'MSSQLServer error: '+str(@@ERROR)
		RETURN 0
	END CATCH
END
GO


