execute('DROP TABLE IF EXISTS SIBE_CALIFICACION_DET');

execute(
'CREATE TABLE SIBE_CALIFICACION_DET (
    Cuit NUMERIC(12, 0),
    NroLinea NUMERIC(8, 0),
    TipoCal CHAR(1),
    ImpCal NUMERIC(15, 2),
    GarantiaSC NUMERIC(1),
    UsuAlta VARCHAR(10),
    FecAlta NUMERIC(8, 0),
    HoraAlta NUMERIC(6, 0),
    PRIMARY KEY (Cuit, NroLinea, FecAlta)
)
'
);

execute('DROP TABLE IF EXISTS SIBE_CALIFICACION_CAB');

execute(
'CREATE TABLE dbo.SIBE_CALIFICACION_CAB
	(
	Cuit     NUMERIC (12) NOT NULL,
	FecVig   NUMERIC (8) NOT NULL,
	FecVenc  NUMERIC (8),
	RiesgCP  NUMERIC (15, 2),
	RiesgLP  NUMERIC (15, 2),
	CalifCP  NUMERIC (15, 2),
	CalifLP  NUMERIC (15, 2),
	MonTE    NUMERIC (15, 2),
	Sucursal NUMERIC (5),
	CtaCli   NUMERIC (9),
	UsuAlta  VARCHAR (10),
	FecAlta  NUMERIC (8),
	PRIMARY KEY (Cuit, FecVig)
	)
'
);

execute('CREATE OR ALTER PROCEDURE SP_ERROR
    @param INT
AS
BEGIN
    IF @param = 1
    BEGIN
        THROW 50000, ''El arreglo de los detalles de riesgos tiene errores'', 1;
    END
END');


execute('CREATE OR ALTER PROCEDURE SP_SIBE_REGISTRO_RIESGO_DET(

	 @p_Cuit VARCHAR(15),
     @p_NroLinea VARCHAR(15), 
     @p_TipoCal VARCHAR(15),
     @p_ImpCal VARCHAR(15), 
     @p_GarantiaSC VARCHAR(15), 

     @p_Message VARCHAR(100) OUTPUT,
     @errorDet NUMERIC(1,0) OUTPUT
     )
     AS 
     BEGIN
	 DECLARE @ErrorMessage NVARCHAR(200);
	 SET @errorDet=0;
	 
	 DECLARE	@v_FechaAlta NUMERIC(8,0)=            		(SELECT CONVERT(NUMERIC(8, 0), 
               			CONCAT(
                 			RIGHT(''00'' + CAST(DAY(fechaproceso) AS NVARCHAR(2)), 2),
                 			RIGHT(''00'' + CAST(MONTH(fechaproceso) AS NVARCHAR(2)), 2),
                 			CAST(YEAR(fechaproceso) AS NVARCHAR(4))
               					)) AS Fechaproceso_Numeric
					 FROM PARAMETROS);

	 DECLARE	@v_HoraAlta NUMERIC(6,0)= (SELECT 
    									CONVERT(NUMERIC(6, 0), 
            							CONCAT(
                								RIGHT(''00'' + CAST(DATEPART(HOUR, fechaproceso) AS NVARCHAR(2)), 2),
                								RIGHT(''00'' + CAST(DATEPART(MINUTE, fechaproceso) AS NVARCHAR(2)), 2),
                								RIGHT(''00'' + CAST(DATEPART(SECOND, fechaproceso) AS NVARCHAR(2)), 2)
            									)) AS HoraNumeric
								   FROM PARAMETROS);

    -- Validaciones
     	  IF LEN(@p_Cuit) != 11  OR TRY_CONVERT(NUMERIC(11, 0), @p_Cuit) IS NULL 
          OR TRY_CONVERT(NUMERIC(8,0),  @p_NroLinea) IS NULL 
          OR LEN(RTRIM(LTRIM(@p_TipoCal))) <> 1 OR  PATINDEX(''%[A-Za-z]%'', RTRIM(LTRIM(@p_TipoCal))) = 0 
          OR TRY_CONVERT(NUMERIC(15, 2),  @p_ImpCal) IS NULL 
          OR TRY_CONVERT(NUMERIC(1,0),  @p_GarantiaSC) IS NULL 
          OR (SELECT count(NUMERODOC) FROM VW_CLI_X_DOC WHERE [NUMERODOC]=@p_Cuit) = 0

          BEGIN

               IF LEN(@p_Cuit) != 11  OR TRY_CONVERT(NUMERIC(11, 0), @p_Cuit) IS NULL 
               begin
		          SET @ErrorMessage = @ErrorMessage + ''-Error: Cuit debe tener una longitud de 11 dígitos y ser numerico.'';
               END

               IF TRY_CONVERT(NUMERIC(8,0),  @p_NroLinea) IS NULL
	          BEGIN
    	               SET @ErrorMessage = @ErrorMessage + CONCAT(''-@p_NroLinea no válido como número entero. , Valor: '',  @p_NroLinea);   	          
	          END

               if LEN(RTRIM(LTRIM(@p_TipoCal))) <> 1 OR  PATINDEX(''%[A-Za-z]%'', RTRIM(LTRIM(@p_TipoCal))) = 0
	          BEGIN
    	               SET @ErrorMessage = @ErrorMessage + CONCAT(''-@p_TipoCal no válido , Valor: '',  @p_TipoCal);
	          END

               IF TRY_CONVERT(NUMERIC(15, 2),  @p_ImpCal) IS NULL
	          BEGIN
    	               SET @ErrorMessage = @ErrorMessage + CONCAT(''-@p_ImpCal no válido como número con 2 decimales. , Valor: '',  @p_ImpCal);
	          END

               IF TRY_CONVERT(NUMERIC(1,0),  @p_GarantiaSC) IS NULL
	          BEGIN
    	               SET @ErrorMessage = @ErrorMessage + CONCAT(''-@p_GarantiaSC no válido como entero. , Valor: '',  @p_GarantiaSC);
	          END

	          IF (SELECT count(NUMERODOC) FROM VW_CLI_X_DOC WHERE [NUMERODOC]=@p_Cuit) = 0
	          BEGIN
                    SET @ErrorMessage = @ErrorMessage + ''-No existen registro de titulares para ese numero de CUIT.'';
	          END

               DECLARE @Cuit NUMERIC(12, 0) = CONVERT(NUMERIC(12, 0), @p_Cuit);


			   SET @errorDet =1

          END
          

DECLARE @v_Cuit NUMERIC(12, 0) = CONVERT(NUMERIC(12, 0), @p_Cuit);
DECLARE @v_NroLinea NUMERIC(8, 0) =CONVERT(NUMERIC(8, 0),@p_NroLinea);
DECLARE @v_TipoCal VARCHAR(1) =CONVERT(VARCHAR(1),@p_TipoCal);
DECLARE @v_ImpCal NUMERIC(15, 2) =CONVERT(NUMERIC(15, 2),@p_ImpCal);
DECLARE @v_GarantiaSC NUMERIC(1, 0) =CONVERT(NUMERIC(1, 0),@p_GarantiaSC);


            


		BEGIN TRY

			INSERT INTO SIBE_CALIFICACION_DET (Cuit, 
                                               NroLinea, 
                                               TipoCal, 
                                               ImpCal, 
                                               GarantiaSC, 
                                               UsuAlta, 
                                               FecAlta, 
                                               HoraAlta 
											   )
            VALUES (@v_Cuit, 
            		@v_NroLinea, 
            		@v_TipoCal, 
            		@v_ImpCal, 
            		@v_GarantiaSC, 
            		''SIBE'',
            		@v_FechaAlta,
            		@v_HoraAlta
            	    );
     
     	END TRY
		BEGIN CATCH
		END CATCH;
		
		
               IF @errorDet=1
          BEGIN
               DELETE FROM SIBE_CALIFICACION_DET
               WHERE Cuit = @Cuit AND FecAlta = @v_FechaAlta;
               
               DELETE FROM SIBE_CALIFICACION_CAB
               WHERE Cuit = @Cuit AND FecVig = @v_FechaAlta;
          END 
          

            SET @p_Message = ''Riesgo y calificación Registrados'';
       
     END


');

execute('CREATE PROCEDURE SP_SIBE_REGISTRO_RIESGO_CAB (
     @p_Cuit VARCHAR(15),
     @p_FecVenc VARCHAR(15),
     @p_RiesgCP VARCHAR(15),     
     @p_RiesgLP VARCHAR(15),
     @p_CalifCP VARCHAR(15),
     @p_CalifLP VARCHAR(15),      
     @p_Sucursal VARCHAR(15),
     @p_MonTE VARCHAR(15),
     @p_CtaCli VARCHAR(15),     
     

     @p_Message VARCHAR(100) output
)

as
BEGIN

DECLARE @ErrorMessage NVARCHAR(200);


    
    -- Validaciones
    IF LEN(@p_Cuit) != 11  OR TRY_CONVERT(NUMERIC(11, 0), @p_Cuit) IS NULL
    begin
		THROW 50000, ''Error: Cuit debe tener una longitud de 11 dígitos y ser numerico.'', 1;
    END
    
    
    if TRY_CONVERT(DATE, @p_FecVenc,103) IS NULL OR TRY_CONVERT(DATE, @p_FecVenc,103) <= (SELECT fechaproceso
    																			FROM PARAMETROS)
    BEGIN
        SET @ErrorMessage = CONCAT(''@p_FecVenc no válida, debe ser mayor a la fecha proceso. Valor de la variable: '', @p_FecVenc);
		THROW 50000, @ErrorMessage, 1;
    END
    
    IF TRY_CONVERT(NUMERIC(15, 2),  @p_RiesgCP) IS NULL
	BEGIN
    	SET @ErrorMessage = CONCAT(''@p_RiesgCP no válido como número con 2 decimales, Valor: '',  @p_RiesgCP);
    	THROW 50000, @ErrorMessage, 1;
	END

    IF TRY_CONVERT(NUMERIC(15, 2),  @p_RiesgLP) IS NULL
	BEGIN
    	SET @ErrorMessage = CONCAT(''@p_RiesgLP no válido como número con 2 decimales. , Valor: '',  @p_RiesgLP);
    	THROW 50000, @ErrorMessage, 1;
	END

    IF TRY_CONVERT(NUMERIC(15, 2),  @p_CalifCP) IS NULL
	BEGIN
    	SET @ErrorMessage = CONCAT(''@p_CalifCP no válido como número con 2 decimales, Valor: '',  @p_CalifCP);
    	THROW 50000, @ErrorMessage, 1;
	END

    IF TRY_CONVERT(NUMERIC(15, 2),  @p_CalifLP) IS NULL
	BEGIN
    	SET @ErrorMessage = CONCAT(''@p_CalifLP cno válido como número con 2 decimales. , Valor: '',  @p_CalifLP);
    	THROW 50000, @ErrorMessage, 1;
	END


    IF TRY_CONVERT(NUMERIC(5,0),  @p_Sucursal) IS NULL
	BEGIN
    	SET @ErrorMessage = CONCAT(''@p_Sucursal no válido como número entero. , Valor: '',  @p_Sucursal);
    	THROW 50000, @ErrorMessage, 1;
	END


    IF TRY_CONVERT(NUMERIC(15, 2),  @p_MonTE) IS NULL
	BEGIN
    	SET @ErrorMessage = CONCAT(''@p_MonTE no válido como número con 2 decimales. , Valor: '',  ''monte '',@p_MonTE);
    	THROW 50000, @ErrorMessage, 1;
	END

    IF TRY_CONVERT(NUMERIC(9,0),  @p_CtaCli) IS NULL
	BEGIN
    	SET @ErrorMessage = CONCAT(''@p_CtaCli no válido como número entero. , Valor: '',  @p_CtaCli);
    	THROW 50000, @ErrorMessage, 1;
	END


	IF (SELECT count(NUMERODOC) FROM VW_CLI_X_DOC WHERE [NUMERODOC]=@p_Cuit) = 0
	BEGIN
SET @ErrorMessage = ''No existen registro de titulares para ese numero de CUIT.'';
    	THROW 50000, @ErrorMessage, 1;
	END

    

DECLARE @v_Cuit NUMERIC(12, 0) = CONVERT(NUMERIC(12, 0), @p_Cuit);
DECLARE @v_FecVenc NUMERIC(8, 0) =CONVERT(NUMERIC(8, 0),REPLACE(@p_FecVenc, ''/'', ''''));
DECLARE @v_RiesgCP NUMERIC(15, 2) =CONVERT(NUMERIC(15, 2),@p_RiesgCP);
DECLARE @v_RiesgLP NUMERIC(15, 2) =CONVERT(NUMERIC(15, 2),@p_RiesgLP);
DECLARE @v_CalifCP NUMERIC(15, 2) =CONVERT(NUMERIC(15, 2),@p_CalifCP);
DECLARE @v_CalifLP NUMERIC(15, 2) =CONVERT(NUMERIC(15, 2),@p_CalifLP);
DECLARE @v_MonTE NUMERIC(15, 2) =CONVERT(NUMERIC(15, 2),@p_MonTE);
DECLARE @v_Sucursal NUMERIC(5, 0) =CONVERT(NUMERIC(5, 0),@p_Sucursal);
DECLARE @v_CtaCli NUMERIC(9, 0) =CONVERT(NUMERIC(9, 0),@p_CtaCli);


DECLARE	@v_FechaAlta NUMERIC(8,0)=            		(SELECT CONVERT(NUMERIC(8, 0), 
               			CONCAT(
                 			RIGHT(''00'' + CAST(DAY(fechaproceso) AS NVARCHAR(2)), 2),
                 			RIGHT(''00'' + CAST(MONTH(fechaproceso) AS NVARCHAR(2)), 2),
                 			CAST(YEAR(fechaproceso) AS NVARCHAR(4))
               					)) AS Fechaproceso_Numeric
					 FROM PARAMETROS);

DECLARE	@v_HoraAlta NUMERIC(6,0)= (SELECT 
    									CONVERT(NUMERIC(6, 0), 
            							CONCAT(
                								RIGHT(''00'' + CAST(DATEPART(HOUR, fechaproceso) AS NVARCHAR(2)), 2),
                								RIGHT(''00'' + CAST(DATEPART(MINUTE, fechaproceso) AS NVARCHAR(2)), 2),
                								RIGHT(''00'' + CAST(DATEPART(SECOND, fechaproceso) AS NVARCHAR(2)), 2)
            									)) AS HoraNumeric
								   FROM PARAMETROS);

            
    -- Verificar si ya existe el Cuit/NroLinea en la tabla CAB
        


		BEGIN TRY
            INSERT INTO SIBE_CALIFICACION_CAB (Cuit, 
                                               FecVig, 
                                               FecVenc, 
                                               RiesgCP, 
                                               RiesgLP, 
                                               CalifCP, 
                                               CalifLP, 
                                               MonTE, 
                                               Sucursal, 
                                               CtaCli, 
                                               UsuAlta, 
                                               FecAlta)


            VALUES (@v_Cuit, 
            		@v_FechaAlta, 
            		@v_FecVenc, 
            		@v_RiesgCP, 
            		@v_RiesgLP, 
            		@v_CalifCP,
            		@v_CalifLP,
            		@v_MonTE,
            		@v_Sucursal,
            		@v_CtaCli,
            		''SIBE'',
            		@v_FechaAlta
            	    );

     	END TRY
		BEGIN CATCH
		END CATCH;
     
			
			
			

            SET @p_Message = ''Riesgo y calificación Registrados'';
        
     END


');


execute('delete from dbo.operaciones where titulo=7901 and identificacion=7937');

execute('INSERT INTO dbo.OPERACIONES (TITULO, IDENTIFICACION, NOMBRE, DESCRIPCION, MNEMOTECNICO, AUTORIZACION, FORMULARIOPRINCIPAL, PROXOPERACION, ESTADO, TZ_LOCK, COPIAS, SUBOPERACION, PERMITEBAJA, COMPORTAMIENTOENCIERRE, REQUIERECONTRASENA, PERMITECONCURRENTE, PERMITEESTADODIFERIDO, ICONO_TITULO, ESTILO)
VALUES (7901, 7937, ''SIBE RIESGO 1.14.21'', ''Impacto de riesgo de SIBE'', ''7937'', ''N'', NULL, NULL, ''P'', 0, NULL, 0, ''S'', ''N'', ''N'', ''N'', ''N'', NULL, 0)
');