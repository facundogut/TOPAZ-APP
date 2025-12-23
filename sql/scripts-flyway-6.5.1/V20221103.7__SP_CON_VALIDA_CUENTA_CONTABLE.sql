--SP_CON_VALIDA_CUENTA_CONTABLE

EXECUTE('
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
	AND (PlanCtas.C6307=@pszRes   )
	AND (PlanCtas.C6310=@pszSubD1 ) 
	AND (PlanCtas.C6311=@pszSubD2 ) 
	AND (PlanCtas.C6312=@pszSubD3 ) 
	AND (PlanCtas.C6313=@pszSubC1 ) 
	AND (PlanCtas.C6314=@pszSubC2 )
	AND (PlanCtas.C6315=@pszSubC3 )
   
	
	IF @vCant > 0
		SET @pCant = 1
	ELSE
		SET @pCant = 0

end
')