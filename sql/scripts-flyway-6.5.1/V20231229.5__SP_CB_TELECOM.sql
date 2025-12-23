EXECUTE('
CREATE OR ALTER PROCEDURE SP_CB_TELECOM 
	-- Parametro de Entrada
    @CB_INI varchar(max),
	-- Parametro salida
    @P_RETORNO varchar(max)  OUTPUT

AS 

	BEGIN

      DECLARE

    	@AUX1 INT,
		@I INT,
		@RESTO INT,
		@DV INT,
		@FACTOR varchar(max),
		@DV_TXT varchar(1),
		@CB_FIN varchar(max),
		@NUM_1 INT,
		@NUM_2 INT,
		@MULT INT,	
		--Variables para manejar largo variable del CB
		@IND_FAC INT,
		@NRO_FAC INT,
		@LARGO_CB INT
         
        --Cargo el Factor para todas las posiciones 		
		-- VALORES FACTOR ''31''
		SET @LARGO_CB = LEN(@CB_INI)		 
		SET @IND_FAC = 1
		SET @NRO_FAC = 3
		SET @I = 1;
		SET @AUX1 = 0;
		WHILE (@I <= @LARGO_CB)
		BEGIN
			-- Cargo el primer nro del CB y el primer nro del Factor
			SET @NUM_1 = CAST(SUBSTRING(@CB_INI,@I,1) AS INT);
		 	SET @NUM_2 = @NRO_FAC;
			-- Pondero
		 	SET @MULT = (@NUM_1 * @NUM_2);
		 	SET @AUX1 = (@AUX1 + @MULT);
			SET @I += 1;

			--Obtengo proximo indice del Factor 
			IF @IND_FAC = 2
				SET @IND_FAC = 1
			ELSE
				SET @IND_FAC += 1
			-- CARGO PROXIMO CHAR DEL FACTOR
			SET @NRO_FAC = 
				(
					CASE
						WHEN @IND_FAC = 1 THEN 3
						WHEN @IND_FAC = 2 THEN 1
					END
				)

		END		 
		-- Obtengo el resto	
		SET @RESTO = @AUX1%10;
		-- Calculo el Dígito Verificador
		IF @RESTO = 0
			SET @DV = 0
		ELSE
			SET @DV = 10 - @RESTO

		-- Agrego al final del Codigo de Barras		
		SET @DV_TXT = CAST(@DV AS varchar);
		SET @CB_FIN = CONCAT(@CB_INI, @DV_TXT);
		
		-- DEVUELVO CODIGO BARRAS CON DV CALCULADO.
		SET @P_RETORNO = @CB_FIN;	 
		 
	END
')
