EXECUTE('
CREATE OR ALTER PROCEDURE SP_VALIDA_SOPORTE_AGENCIEROS
   @P_ID		NUMERIC(15),
   @P_OPCION	VARCHAR(1),
   @P_RESULTADO	VARCHAR(5) OUTPUT
   
AS 

BEGIN

	SET @P_RESULTADO = ''ERROR''
	
	   
	IF @P_OPCION = ''A''
	BEGIN
	   
	    UPDATE REC_Agencieros
		   SET
			   ESTADO = ''V'',
			   DETALLE_ESTADO = ''Validado''
		 WHERE ID_TICKET = @P_ID
		   AND ESTADO = ''H''; 
	   
		UPDATE REC_Agencieros
		   SET
			   ESTADO = ''E'',
			   DETALLE_ESTADO = ''Error''
		 WHERE ID_TICKET = @P_ID
		   AND ESTADO = ''F''; 
	   
		
		
		SET @P_RESULTADO = ''OK''
	
	END
	
	IF @P_OPCION = ''R''
	BEGIN
	
		UPDATE REC_Agencieros
		   SET
			   ESTADO = ''X'',
			   DETALLE_ESTADO = ''Rechazado''
		 WHERE ID_TICKET = @P_ID;
	
		SET @P_RESULTADO = ''OK''
	
	END
	
	IF @P_ID = 0
	BEGIN
	
	 SET @P_RESULTADO = ''ERROR''
	 
	END
	

END
')
