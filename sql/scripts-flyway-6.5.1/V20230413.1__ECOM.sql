EXECUTE('
IF OBJECT_ID (''dbo.TEMP_DJ_CUENTAS'') IS NOT NULL
	DROP TABLE dbo.TEMP_DJ_CUENTAS
')

EXECUTE('
CREATE TABLE dbo.TEMP_DJ_CUENTAS
	(
	ID              INT IDENTITY NOT NULL,
	NRO_JUZGADO_CJ  VARCHAR (7),
	ANO_EXP_CJ      VARCHAR (4),
	NUM_EXP_CJ      VARCHAR (10),
	TIPO_CUENTA_J   VARCHAR (2),
	FECHA_CJ        VARCHAR (8),
	CARATULA        VARCHAR (210),
	NRO_OFICIO      VARCHAR (6),
	FECHA_OFICIO    VARCHAR (8),
	APE_NOM_BENEF   VARCHAR (30),
	MONEDA_CUENTA_J VARCHAR (3),
	TIP_CUENT_BANC  VARCHAR (2),
	SUC_CUENT_BANC  VARCHAR (5),
	NUM_CUENT_BANC  VARCHAR (11),
	ESTADO          VARCHAR (1),
	ERROR_DESC      VARCHAR (800) DEFAULT ('' '')
	)
')



EXECUTE('
IF OBJECT_ID (''dbo.SP_ALTACAUSAJ_CAJAAHORRO'') IS NOT NULL
	DROP PROCEDURE dbo.SP_ALTACAUSAJ_CAJAAHORRO
')

EXECUTE('
CREATE      PROCEDURE [dbo].[SP_ALTACAUSAJ_CAJAAHORRO]
	@MENSAJE_ERROR VARCHAR(max) OUT
AS
BEGIN
	
	------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--- Created: 04/04/2023 16:08 a.m.
	--- Autor: Top
	------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	DECLARE @existepie NUMERIC(15);
	DECLARE @existedetalle NUMERIC(15);
	DECLARE @totalregistro NUMERIC(15)
	
	SET @MENSAJE_ERROR = '''';
	
	
	SELECT @existepie = COUNT(1) FROM TEMP_DJ_CUENTAS
	WHERE TIPO_CUENTA_J = ''RT'';
	
	SELECT @existedetalle = COUNT(1) FROM TEMP_DJ_CUENTAS
	WHERE TIPO_CUENTA_J <> ''RT'';
	
	IF(@existepie = 0) 
	begin 		
   	   SET @MENSAJE_ERROR = ''Error - Falta registro de Pie.'';
   	   RETURN
   	END
   	
   	IF(@existepie > 1)   		
   	begin
   	   SET @MENSAJE_ERROR = ''Error - existe mas de un registro en el Pie.'';
   	   RETURN	   
   	END
   	
	IF(@existedetalle = 0)
   	BEGIN
   		SET @MENSAJE_ERROR = ''Error - Faltan registro Detalle.'';
   		RETURN
   	END
   	
   	SELECT @totalregistro = convert(NUMERIC(15), NUM_CUENT_BANC)
   	FROM TEMP_DJ_CUENTAS
	WHERE TIPO_CUENTA_J = ''RT'';
   	
   	IF (@totalregistro <> @existedetalle)
   	BEGIN
   	   SET @MENSAJE_ERROR = ''Error - Total de Registro en el Pie es distinto al Nro de Registro Detalle.'';
   	   RETURN
   	END	
END;
')

