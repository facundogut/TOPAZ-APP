execute ('
	delete from opciones where numerodecampo=6310;
	delete from opciones where numerodecampo=6313;
	delete from opciones where numerodecampo=6314;
	update DICCIONARIO set opciones=1 where numerodecampo in (6310 , 6313, 6314);
	update DICCIONARIO set DESCRIPCION=''Sector contable'', PROMPT=''Sector contable'' where numerodecampo =6310;
	update DICCIONARIO set DESCRIPCION=''Garantía'', PROMPT=''Garantía'' where numerodecampo =6313;
	update DICCIONARIO set DESCRIPCION=''Tipo DPF'', PROMPT=''Tipo DPF'' where numerodecampo =6314;
	update CLI_Intermed_Financ set intermed = '' '' where trim(intermed)='''';
');

execute ('
	INSERT INTO OPCIONES VALUES 
	(6310, ''E'', ''No Analiza'', '' '', '' ''), 
	(6310, ''E'', ''Privado'', ''01'', ''01''),
	(6310, ''E'', ''Publico'', ''02'', ''02''),
	(6310, ''E'', ''Financiero'', ''03'', ''03'') ;

	INSERT INTO OPCIONES VALUES 
	(6313, ''E'', ''No Analiza'', '' '', '' ''), 
	(6313, ''E'', ''Solo Firma'', ''00'', ''00''),
	(6313, ''E'', ''Con Garantia Prendaria'', ''01'', ''01''),
	(6313, ''E'', ''Con Garantia Hipotecaria'', ''02'', ''02'') ;

	INSERT INTO OPCIONES VALUES 
	(6314, ''E'', ''No Analiza'', '' '', '' ''), 
	(6314, ''E'', ''Intransferible'', ''01'', ''01''),
	(6314, ''E'', ''Transferible'', ''02'', ''02'');
');

execute ('
	UPDATE PLANCTAS SET C6310='' '' WHERE TRIM(C6310)='''';
	UPDATE PLANCTAS SET C6313='' '' WHERE TRIM(C6313)='''';
	UPDATE PLANCTAS SET C6314='' '' WHERE TRIM(C6314)='''';
	UPDATE PLANCTAS SET C6307='' '' WHERE TRIM(C6307)='''';
');

execute ('
	CREATE OR ALTER PROCEDURE SP_CON_VALIDA_CUENTA_CONTABLE
		@pRubro     NUMERIC(12),
		@pszMon     VARCHAR(1),
		@pszRes	    VARCHAR(1),
		@pszSubD1   VARCHAR(2),	
		@pszSubD2   VARCHAR(2),	
		@pszSubD3   VARCHAR(2),	
		@pszSubC1   VARCHAR(2),	
		@pszSubC2   VARCHAR(2),	
		@pszSubC3   VARCHAR(2),
		@pCant      NUMERIC(6) OUT
		
	AS
	BEGIN
	   DECLARE @vCant NUMERIC(6) 

	   
	 SELECT @vCant = count(*) from PLANCTAS
	  WHERE (PlanCtas.C6340=@pRubro   )
		AND (PlanCtas.C6302=@pszMon   )
		AND (PlanCtas.C6308=@pszRes   )
		AND (PlanCtas.C6310=@pszSubD1 ) 
		AND (PlanCtas.C6311=@pszSubD2 ) 
		AND (PlanCtas.C6312=@pszSubD3 ) 
		AND (PlanCtas.C6313=@pszSubC1 ) 
		AND (PlanCtas.C6314=@pszSubC2 )
		AND (PlanCtas.C6315=@pszSubC3 )
		AND (PlanCtas.TZ_LOCK=0 )
	   
		
		IF @vCant > 0
			SET @pCant = 1
		ELSE
			SET @pCant = 0

	END
')